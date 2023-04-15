#include "stdafx.h"
#include "TreasureModule.h"
#include <fstream>

#define TREASURERE_CONFIG_FILE_NAME "treasure_task_config.json"
#define TREASURERE_DATA				"treasure_task_data_"	//  nUserID+nRoomID 主键
#define TREASURERE_GLOBAL_DBKEY		"treasure_global_dbkey"

unsigned long ulRand() {
    return (
        (((unsigned long)rand() << 24) & 0xFF000000ul)
        | (((unsigned long)rand() << 12) & 0x00FFF000ul)
        | (((unsigned long)rand()) & 0x00000FFFul));
}

int GetRandCount(std::vector< TREASUREREWARDINFO > LotteryChance)
{
    int nLotteryNum = LotteryChance.size();
    if (nLotteryNum <= 0)
    {
        UwlLogFile("抽奖ID异常");
        return -1;
    }
    srand((int)time(0));

    int i = 0;
    for (i = 0; nLotteryNum > i; ++i)
    {
        if (0 > LotteryChance[i].rate)
        {
            UwlLogFile("抽奖概率配置异常");
            return rand() % nLotteryNum;
        }
    }

    int nCurChance = 0;

    int RandNum = ulRand() % TREASURE_AWARD_ALL_CHANCE;
    for (i = 0; nLotteryNum > i; ++i)
    {
        nCurChance += LotteryChance[i].rate * TREASURE_AWARD_ALL_CHANCE;
        if (RandNum < nCurChance)
        {
            return i;
        }
    }
    UwlLogFile("抽奖概率配置异常");
    return rand() % nLotteryNum;
}

void TreasureModule::OnServerStart(BOOL &ret, TcyMsgCenter *msgCenter)
{
    if (ret) {
        AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_QUERY_TREASURE_INFO, OnQueryTreasureInfo);
        AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_TAKE_TREASURE_AWARD, OnTaskTreasureAward);
        AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_TREASURE_UPDATE_TASK_DATA, OnTreasureUpdateTaskData);

		// 刷新json文件名称
		TCHAR szFullName[MAX_PATH];
		TCHAR szJsonFile[MAX_PATH];//配置文件
		GetModuleFileName(GetModuleHandle(NULL), szFullName, sizeof(szFullName));
		UwlSplitPath(szFullName, SPLIT_DRIVE_DIR, szJsonFile);
		lstrcat(szJsonFile, TREASURERE_CONFIG_FILE_NAME);
		m_jsonFileName = szJsonFile;
		ZeroMemory(&m_jsonFileLastFresh, sizeof(m_jsonFileLastFresh));

		// 读取本地ini文件配置
		readFromLocalIni();

		// 读取本地
		readFromLocalJson();

		// 刷新当天时间
		m_curTime = CTime::GetCurrentTime();

		// 删除昨天的表
		deletePredayTable();

		// 创建表
		createTodayTable();

		// 一分钟刷新一次
		m_timerFresh = evp().loopTimer([this](){this->onFreshTimer(); }, std::chrono::minutes(1), strand());
    }
}

void TreasureModule::OnShutDown()
{
	m_timerFresh.reset();
}

BOOL TreasureModule::OnQueryTreasureInfo(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
    REQUEST response;
    memset(&response, 0, sizeof(response));
    response.head.nRequest = lpRequest->head.nRequest;
    response.head.nSubReq = UR_OPERATE_FAILED;
    int nRepeated = lpRequest->head.nRepeated;
    response.head.nRepeated = nRepeated;
    std::string buffer;
    buffer.append((char*)lpRequest->pDataPtr, sizeof(CONTEXT_HEAD) * nRepeated);
    response.pDataPtr = (void*)buffer.data();
    response.nDataLen = buffer.size();

    LPREQTREASUREINFO pData = (LPREQTREASUREINFO)(PBYTE(lpRequest->pDataPtr) + nRepeated * sizeof(CONTEXT_HEAD));
    if (NULL == pData) {
        imSendOpeRequest(lpContext, response);
        return FALSE;
    }

    RSPTREASUREINFO rspTreasureInfo;
    ZeroMemory(&rspTreasureInfo, sizeof(rspTreasureInfo));

    rspTreasureInfo.enable = isEnable();
    if (!rspTreasureInfo.enable) {
        // 未开启，直接返回
        response.head.nSubReq = UR_OPERATE_CLOSE;
        imSendOpeRequest(lpContext, response);
        return FALSE;
    }

    auto dbkey = toKey(pData->nUserID);
    auto curTime = getCurTime();

    tbl_TreasureTaskData data;
    ZeroMemory(&data, sizeof(data));
    data.roomid = pData->nRoomID;
    data.userid = pData->nUserID;

    auto task_config = getTreasureRoomInfo(pData->nRoomID);
    if (task_config.tasks.empty()) {
        response.head.nSubReq = UR_OPERATE_CLOSE;
        imSendOpeRequest(lpContext, response);
        return FALSE;
    }

    std::future<void> f;
    int nRet = 0;

    imDBOpera(dbkey, [&nRet, curTime, pData, &data, &task_config, &rspTreasureInfo, &response, this](DBConnectEntry* entry){
        std::string paramTblName = tableName(TREASURERE_DATA, curTime);
        int nRet = getDBTreasureTaskData(entry, paramTblName, pData->nUserID, pData->nRoomID, data);
        if (nRet) {
            return ;
        }

        rspTreasureInfo.color = task_config.color;
        if (data.task_reward_round >= task_config.tasks.size()) {
            // 已经超过最大轮数了，不能再抽奖了
            rspTreasureInfo.goal = 0;
            rspTreasureInfo.progress = 0;
        }
        else {
            rspTreasureInfo.goal = task_config.tasks[data.task_reward_round].task_goal;
            rspTreasureInfo.progress = data.count - data.last_reward_count;
            rspTreasureInfo.last_count = data.last_reward_count;
        }
        response.head.nSubReq = UR_OPERATE_SUCCEEDED;
        nRet = 0;
        return ;
    }).get();
    if (nRet) {
        imSendOpeRequest(lpContext, response);
        return FALSE;
    }

    buffer.append((char*)&rspTreasureInfo, sizeof(rspTreasureInfo));

    response.pDataPtr = (void*)buffer.data();
    response.nDataLen = buffer.size();

    imSendOpeRequest(lpContext, response);
    return TRUE;
}

BOOL TreasureModule::OnTaskTreasureAward(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
    REQUEST response;
    memset(&response, 0, sizeof(response));
    response.head.nRequest = lpRequest->head.nRequest;
    response.head.nSubReq = UR_OPERATE_FAILED;
    int nRepeated = lpRequest->head.nRepeated;
    response.head.nRepeated = nRepeated;
    std::string buffer;
    buffer.append((char*)lpRequest->pDataPtr, sizeof(CONTEXT_HEAD) * nRepeated);
    response.pDataPtr = (void*)buffer.data();
    response.nDataLen = buffer.size();

    LPREQTREASUREAWARDPRIZE pData = (LPREQTREASUREAWARDPRIZE)(PBYTE(lpRequest->pDataPtr) + nRepeated * sizeof(CONTEXT_HEAD));
    if (nullptr == pData) {
        imSendOpeRequest(lpContext, response);
        return FALSE;
    }

    bool enable = isEnable();
    if (!enable) {
        response.head.nSubReq = UR_OPERATE_CLOSE;
        imSendOpeRequest(lpContext, response);
        return FALSE;
    }

    auto treasureRoomInfo = getTreasureRoomInfo(pData->nRoomID);
    if (treasureRoomInfo.tasks.empty()) {
        response.head.nSubReq = UR_OPERATE_CLOSE;
        imSendOpeRequest(lpContext, response);
        return FALSE;
    }
    auto curTime = getCurTime();

    RSPTREASUREAWARDPRIZE rsp;
    ZeroMemory(&rsp, sizeof(rsp));
    tbl_TreasureTaskData data;
    ZeroMemory(&data, sizeof(data));
    auto dbkey = toKey(pData->nUserID);
    auto config = getTreasureConfig();
    int nRet = 0;
    std::future<void> f;

    imDBOpera(dbkey, [&nRet, &config, curTime, &data, &treasureRoomInfo, pData, &rsp, &response, this](DBConnectEntry* entry){
        std::string paramTblName = tableName(TREASURERE_DATA, curTime);
        nRet = getDBTreasureTaskData(entry, paramTblName, pData->nUserID, pData->nRoomID, data);
        if (nRet) {
            return ;
        }

        if (data.task_reward_round < 0) {
            // 数据异常
            nRet = -1;
            return ;
        }

        if (data.task_reward_round >= treasureRoomInfo.tasks.size()) {
            // 今天已经完成超标了
            response.head.nSubReq = UR_OPERATE_RE_ARWARD;
            return ;
        }

        TREASURETASKINFO& cur_taskinfo = treasureRoomInfo.tasks[data.task_reward_round];
        if ((data.count - data.last_reward_count) < cur_taskinfo.task_goal) {
            response.head.nSubReq = UR_OPERATE_NOT_READY;
            return ;
        }
        int next_round = data.task_reward_round + 1;
        int index = GetRandCount(cur_taskinfo.rewards);
        rsp.boutcount = data.count;
        rsp.roomid = pData->nRoomID;
        rsp.prize_count = cur_taskinfo.rewards[index].reward_count;
        rsp.type = cur_taskinfo.rewards[index].type;
        memcpy(rsp.MId, cur_taskinfo.rewards[index].webid.c_str(), sizeof(rsp.MId) - 1);

        int saveRound = next_round;
        if (next_round >= treasureRoomInfo.tasks.size()) {
            // 该房间的宝箱都已经领取完毕了
            rsp.next_goal = 0;
            saveRound = treasureRoomInfo.tasks.size();
        }
        else {
            TREASURETASKINFO& next_taskinfo = treasureRoomInfo.tasks[next_round];
            rsp.next_goal = next_taskinfo.task_goal;
        }

        rsp.MgId = config.taskeid;
        rsp.userid = pData->nUserID;
        nRet = updateDBTreasureTaskData(entry, paramTblName, pData->nUserID, pData->nRoomID, data.count, saveRound);
        rsp.last_count = data.count;

        if (nRet) {
            return;
        }
        response.head.nSubReq = UR_OPERATE_SUCCEEDED;
        return ;
    }).get();
    if (nRet) {
        // 数据库操作异常
        imSendOpeRequest(lpContext, response);
        return FALSE;
    }

    buffer.append((char*)&rsp, sizeof(rsp));
    response.pDataPtr = (void*)buffer.data();
    response.nDataLen = buffer.size();

    imSendOpeRequest(lpContext, response);
    return TRUE;
}

BOOL TreasureModule::OnTreasureUpdateTaskData(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
    REQUEST response;
    memset(&response, 0, sizeof(response));
    response.head.nRequest = lpRequest->head.nRequest;
    response.head.nSubReq = UR_OPERATE_FAILED;
    int nRepeated = lpRequest->head.nRepeated;
    response.head.nRepeated = nRepeated;
    std::string buffer;
    buffer.append((char*)lpRequest->pDataPtr, sizeof(CONTEXT_HEAD) * nRepeated);
    response.pDataPtr = (void*)buffer.data();
    response.nDataLen = buffer.size();

    int  nResult = 0;
    LONG errcode = 0;
    int nTransStarted = 0;
    UINT nResponse = 0;


    if ((nRepeated * sizeof(CONTEXT_HEAD) + sizeof(REQADDTREASURETASKDATA)) != lpRequest->nDataLen)
    {
        return FALSE;
    }
    LPREQADDTREASURETASKDATA lpReqData = (LPREQADDTREASURETASKDATA)(PBYTE(lpRequest->pDataPtr) + nRepeated * sizeof(CONTEXT_HEAD));
    int nUserID = lpReqData->userid;
    int nUoomID = lpReqData->roomid;
    int nCount = lpReqData->count;
    /////////////////////////////////////////////////////////////////////////
    RSPADDTREASURETASKDATA sRspAddTaskData = { 0 };

    bool enable = isEnable();
    if (!enable) {
        response.head.nSubReq = UR_OPERATE_CLOSE;
        imSendOpeRequest(lpContext, response);
        return FALSE;
    }
    int nRet = 0;
    std::future<void> f;
    auto curTime = getCurTime();
    imDBOpera(toKey(lpReqData->userid), [&nRet, lpReqData, curTime, &response, &sRspAddTaskData, this](DBConnectEntry* entry){
        std::string paramTblName = tableName(TREASURERE_DATA, curTime);
        tbl_TreasureTaskData data;
        nRet = getDBTreasureTaskData(entry, paramTblName, lpReqData->userid, lpReqData->roomid, data);
        if (nRet) {
            return ;
        }
        data.count += lpReqData->count;
        nRet = insertOrUpdateDBTreasureTaskData(entry, paramTblName, data);
        if (nRet) {
            return ;
        }
        response.head.nSubReq = UR_FETCH_SUCCEEDED;
        sRspAddTaskData.ret = data.count;
        return ;
    }).get();
    if (nRet) {
        imSendOpeRequest(lpContext, response);
        return FALSE;
    }
    //////////////////////////////////////////////////////////////////////////
    // ope succeed
    response.head.nSubReq = UR_FETCH_SUCCEEDED;

    int nLen = nRepeated*sizeof(CONTEXT_HEAD) + sizeof(RSPADDTREASURETASKDATA);
    PBYTE pData = NULL;
    pData = new BYTE[nLen];
    memset(pData, 0, nLen);

    memcpy(pData, lpRequest->pDataPtr, nRepeated*sizeof(CONTEXT_HEAD));
    memcpy(pData + nRepeated*sizeof(CONTEXT_HEAD), &sRspAddTaskData, sizeof(RSPADDTREASURETASKDATA));
    response.pDataPtr = pData;
    response.nDataLen = nLen;

    imSendOpeRequest(lpContext, response);
    UwlClearRequest(&response);
    return TRUE;
}

void TreasureModule::OnInputTest(bool& next, std::string& cmd)
{
	if (cmd == "test") {
		std::future<void> f;
		auto curTime = getCurTime();
		imDBOpera("hello", [this, curTime](DBConnectEntry* entry){
			std::string paramTblName = tableName(TREASURERE_DATA, curTime);
			tbl_TreasureTaskData data;
			getDBTreasureTaskData(entry, paramTblName, 732263, 5258, data);

		}).get();
	}
}

void TreasureModule::onFreshTimer()
{
	// 一分钟刷新一次
	auto pre = m_curTime;
	m_curTime = CTime::GetCurrentTime();

	// 先判断是否已经超过一天了
	if (pre.GetDay() != m_curTime.GetDay()) {
        // 重新创建新的表
        createTodayTable();
        // 删除前天的表
        m_timerDeleteOnce = evp().onceTimer([this](){
            deletePredayTable();
            // 隔一天清理一次缓存
            deleteCache();
        }, std::chrono::minutes(1), strand());
	}

	readFromLocalIni();

	// 判断json文件是否被修改了
	auto tp = getFileLastWriteTime(m_jsonFileName);
	if (tp.dwLowDateTime != m_jsonFileLastFresh.dwLowDateTime
		|| tp.dwHighDateTime != m_jsonFileLastFresh.dwHighDateTime) {
		readFromLocalJson();
	}
}

void TreasureModule::readFromLocalIni()
{
	std::string s;
	imGetIniString("Treasure", "beginDate", s);
	m_config.begin_time = atoi(s.c_str());
	
	s.clear();
	imGetIniString("Treasure", "endDate", s);
	m_config.end_time = atoi(s.c_str());

	s.clear();
	imGetIniString("Treasure", "taskID", s);
	m_config.taskeid = atoi(s.c_str());
}

void TreasureModule::readFromLocalJson()
{
	Json::Reader reader;
	Json::Value root;
	std::ifstream is;
	is.open(m_jsonFileName.c_str(), std::ios::binary);

	if (!is.is_open()) {
		UwlTrace(_T("Json Can`t Read <%s>"), m_jsonFileName.c_str());
		UwlLogFile(_T("Json Can`t Read <%s>"), m_jsonFileName.c_str());
		return;
	}

	m_jsonFileLastFresh = getFileLastWriteTime(m_jsonFileName);

	if (!reader.parse(is, root)) {
		UwlTrace(_T("CTreasureModule ReadWxTaskJsonConfig Fail"));
		UwlLogFile(_T("CTreasureModule ReadWxTaskJsonConfig Fail"));
		return;
	}

	auto task_rewards = root["task_rewards"];
	if (task_rewards.isNull() || !task_rewards.isArray()) {
		UwlTrace(_T("task_rewards is null"));
		UwlLogFile(_T("task_rewards is null"));
		return;
	}
	std::map<int, TREASUREREWARDITEM> m_reward_map;

	for (int i = 0; i < task_rewards.size(); i++) {
		TREASUREREWARDITEM rewardItem;
		rewardItem.id = task_rewards[i]["id"].asInt();
		rewardItem.count = task_rewards[i]["count"].asInt();
		rewardItem.webid = task_rewards[i]["webid"].asString();
		rewardItem.type = task_rewards[i]["type"].asInt();
		m_reward_map.insert(std::pair<int, TREASUREREWARDITEM>(rewardItem.id, rewardItem));
	}

	auto task_treasure = root["room_baoxiang"];
	if (task_treasure.isNull() || !task_treasure.isArray()) {
		UwlTrace(_T("room_baoxiang is null"));
		UwlLogFile(_T("room_baoxiang is null"));
		return;
	}

	for (int i = 0; i < task_treasure.size(); i++) {
		TREASUREROOMINFO taskItem;
		auto tasks = task_treasure[i]["tasks"];
		if (!tasks.isArray()){
			break;
		}
		taskItem.roomid = task_treasure[i]["roomid"].asInt();
		taskItem.color = task_treasure[i]["baoxiang_color"].asInt();

		for (int j = 0; j < tasks.size(); j++) {
			TREASURETASKINFO taskInfo;
			auto rewards = tasks[j]["reward"];
			if (!rewards.isArray()) {
				break;
			}
			taskInfo.task_goal = tasks[j]["task_goal"].asInt();
			float nRateTotal = 0;
			for (int k = 0; k < rewards.size(); k++) {
				TREASUREREWARDINFO rewardItem;
				int rewardid = rewards[k]["rewardid"].asInt();
				TREASUREREWARDITEM  tmpreward = m_reward_map[rewardid];
				rewardItem.reward_count = tmpreward.count;
				rewardItem.webid = tmpreward.webid;
				rewardItem.type = tmpreward.type;
				rewardItem.rate = rewards[k]["rate"].asFloat();
				nRateTotal += rewards[k]["rate"].asFloat();
				taskInfo.rewards.push_back(rewardItem);
			}

			nRateTotal = nRateTotal ? nRateTotal : 1;
			for (auto it = taskInfo.rewards.begin(); it != taskInfo.rewards.end(); it++)
			{
				it->rate /= nRateTotal;
			}

			taskItem.tasks.push_back(taskInfo);
		}
		m_task_config.push_back(taskItem);
	}
}

void TreasureModule::createTodayTable()
{
	auto curTime = getCurTime();

	std::future<void> f;
	imDBOpera(TREASURERE_GLOBAL_DBKEY, [curTime](DBConnectEntry*entry){
		char buf[4096];
		ZeroMemory(buf, sizeof(buf));
		std::string paramTblName = tableName(TREASURERE_DATA, curTime);
		const char *fmt = R"(CREATE TABLE IF NOT EXISTS %s 
			(
				userid	INT,
				roomid INT,
				count INT,
				last_reward_count INT,
				task_reward_round INT,
				PRIMARY KEY(userid,roomid)
			) )";
		sprintf_s(buf, fmt, paramTblName.c_str());
		entry->mysql_excute(buf);
	}).get();
}

void TreasureModule::deletePredayTable()
{
	auto curTime = getCurTime();
	std::future<void> f;
	imDBOpera(TREASURERE_GLOBAL_DBKEY, [curTime](DBConnectEntry*entry){
		CTime preTime = curTime - CTimeSpan(1, 0, 0, 0);
		char buf[4096];
		ZeroMemory(buf, sizeof(buf));

		std::string paramTblName = tableName(TREASURERE_DATA, preTime);
		const char *fmt = R"(DROP TABLE IF EXISTS %s)";
		sprintf_s(buf, fmt, paramTblName.c_str());
		entry->mysql_excute(buf);
	}).get();
}

void TreasureModule::deleteCache()
{
	m_cacheList.swap(std::list<std::shared_ptr<boost::any>>());
}

std::shared_ptr<boost::any> TreasureModule::createCache(tbl_TreasureTaskData &data)
{
	std::shared_ptr<boost::any > sptr = std::make_shared<boost::any>();
	*sptr = TreasureTaskDataMap();

	async<void>([sptr, this](){
		m_cacheList.push_back(sptr);
	}).get();

	auto* m = boost::any_cast<TreasureTaskDataMap>(sptr.get());
	m->insert({ data.roomid, data });
	return sptr;
}

CTime TreasureModule::getCurTime()
{
	return async<CTime>([this](){
		return m_curTime;
	}).get();
}

std::string TreasureModule::toKey(int userid)
{
	std::stringstream ss;
	ss << typeid(*this).name() << "_" << userid;

	return ss.str();
}

std::string TreasureModule::tableName(const std::string& tblTag, CTime t)
{
	char buffer[256];
	ZeroMemory(buffer, sizeof(buffer));
	sprintf_s(buffer, "%s%04d%02d%02d", tblTag.c_str(), t.GetYear(), t.GetMonth(), t.GetDay());
	return std::string(buffer);
}

FILETIME TreasureModule::getFileLastWriteTime(const std::string& filename)
{
	WIN32_FILE_ATTRIBUTE_DATA a;
	if (GetFileAttributesEx(filename.c_str(), GetFileExInfoStandard, &a)) {
		return a.ftLastWriteTime;
	}

	return{ 0, 0 };
}

int TreasureModule::getDBTreasureTaskData(DBConnectEntry* entry, const std::string& tblname, int userid, int roomid, tbl_TreasureTaskData& data)
{
	auto sptr = entry->user_data->lock();
	if (sptr) {
		auto* m = boost::any_cast<TreasureTaskDataMap>(sptr.get());
		auto it = m->find(roomid);
		if (it != m->end()) {
			data = it->second;
			return 0;
		}
	}

	char buf[4096];
	ZeroMemory(buf, sizeof(buf));
	sprintf_s(buf, "SELECT * FROM %s WHERE userid=%d AND roomid = %d", 
		tblname.c_str(), userid, roomid);
	ZeroMemory(&data, sizeof(data));
	data.roomid = roomid;
	data.userid = userid;
	auto r = entry->mysql_excute(buf, [&data](sql::ResultSet* res){
		if (res->next()) {
			data.count = res->getInt("count");
			data.last_reward_count = res->getInt("last_reward_count");
			data.task_reward_round = res->getInt("task_reward_round");
		}
		return res->rowsCount();
	});

	if (r.first || r.second == 0) {
		return 0;
	}

	if (!sptr) {
		sptr = createCache(data);
		*entry->user_data = sptr;
	}
	else {
		auto& m = *boost::any_cast<TreasureTaskDataMap>(sptr.get());
		m[roomid] = data;
	}

	return 0;
}

int TreasureModule::updateDBTreasureTaskData(DBConnectEntry* entry, const std::string& tblname, int userid, int roomid, int last_reward_count, int task_reward_round)
{
	char buf[4096];
	ZeroMemory(buf, sizeof(buf));
	sprintf_s(buf, "UPDATE %s SET last_reward_count=%d,task_reward_round=%d WHERE userid=%d AND roomid=%d", 
		tblname.c_str(), last_reward_count, task_reward_round, userid, roomid);
	int ret = entry->mysql_excute(buf);

	if (ret) {
		return ret;
	}
	tbl_TreasureTaskData data;
	data.roomid = roomid;
	data.userid = userid;
	data.count = last_reward_count;
	data.last_reward_count = last_reward_count;
	data.task_reward_round = task_reward_round;

	auto sptr = entry->user_data->lock();
	if (!sptr) {
		sptr = createCache(data);
		*entry->user_data = sptr;
	}
	else {
		auto& m = *boost::any_cast<TreasureTaskDataMap>(sptr.get());
		m[roomid] = data;
	}

	return ret;
}

int TreasureModule::insertOrUpdateDBTreasureTaskData(DBConnectEntry* entry, const std::string& tblname, tbl_TreasureTaskData& data)
{
	char buf[4096];
	ZeroMemory(buf, sizeof(buf));
	sprintf_s(buf, 
		"INSERT INTO %s(userid,roomid,last_reward_count,task_reward_round,count) VALUES(%d,%d,%d,%d,%d) ON DUPLICATE KEY UPDATE last_reward_count=%d,task_reward_round=%d,count=%d", 
		tblname.c_str(), data.userid, data.roomid, data.last_reward_count, data.task_reward_round, data.count, data.last_reward_count, data.task_reward_round, data.count);
	int ret = entry->mysql_excute(buf);
	if (ret) {
		return ret;
	}
	auto sptr = entry->user_data->lock();
	if (!sptr) {
		sptr = createCache(data);
		*entry->user_data = sptr;
	}
	else {
		auto& m = *boost::any_cast<TreasureTaskDataMap>(sptr.get());
		m[data.roomid] = data;
	}
	return ret;
}

TREASUREROOMINFO TreasureModule::getTreasureRoomInfo(int roomid)
{
	return async<TREASUREROOMINFO>([this, roomid](){
		TREASUREROOMINFO r;
		r.roomid = 0;
		r.color = 0;
		for (int i = 0; i < m_task_config.size(); ++i) {
			if (m_task_config[i].roomid == roomid) {
				r = m_task_config[i];
				break;
			}
		}
		return r;
	}).get();
}

TREASURERE_CONFIG TreasureModule::getTreasureConfig()
{
	return async<TREASURERE_CONFIG>([this](){
		return m_config;
	}).get();
}

bool TreasureModule::isEnable()
{
	return async<bool>([this](){
		int begin_year = m_config.begin_time / 10000;
		int begin_month = m_config.begin_time / 100 % 100;
		int begin_day = m_config.begin_time % 100;
		if (begin_year < 1900
			|| (begin_month < 1 && begin_month > 12)
			|| (begin_day < 1 && begin_day > 31)) {
			return false;
		}

		CTime begin(begin_year, begin_month, begin_day, 0, 0, 0);
		int end_year = m_config.end_time / 10000;
		int end_month = m_config.end_time / 100 % 100;
		int end_day = m_config.end_time % 100;
		if (end_year < 1900
			|| (end_month < 1 && end_month > 12)
			|| (end_day < 1 && end_day > 31)) {
			return false;
		}
		CTime end(end_year, end_month, end_day, 23, 59, 59);
		if (m_curTime > end || m_curTime < begin) {
			return false;
		}
		return true;
	}).get();
}
