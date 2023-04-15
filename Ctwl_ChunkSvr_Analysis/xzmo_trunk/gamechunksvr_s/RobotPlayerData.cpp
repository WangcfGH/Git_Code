#include "stdafx.h"
#include "RobotPlayerData.h"
#include <list>
#define ROBOT_REDIS_SELECT_INDEX    1
#define TABLE_ROBOT_PLAYERDATA		"robot_player_data_"	// 
#define REDIS_LOSE_KEY				"nLose"
#define REDIS_BOUTCOUNT_KEY			"nBout"	
#define REDIS_MATCHTIME_KEY			"nMatchTime"
#define REDIS_NEEDROBOT_KEY			"nNeedTime"


static int GetDateTime(int nDaySpan = 0)
{
	CTime t = CTime::GetCurrentTime();
	if (0 < nDaySpan){
		t += CTimeSpan(nDaySpan, 0, 0, 0);
	}
	else{
		t -= CTimeSpan(-nDaySpan, 0, 0, 0);
	}

	return atoi(t.Format("%Y%m%d"));
}

//获取当晚的清零unix时间戳
static int GetTonightAbortTime()
{
	CTime time = CTime::GetCurrentTime();
	time += CTimeSpan(1, 0, 0, 0);
	CTime tonightTime = CTime(time.GetYear(), time.GetMonth(), time.GetDay(), 0, 0, 0);
	return tonightTime.GetTime();
}

void RobotPlayerData::OnServerStart(BOOL &ret, TcyMsgCenter *msgCenter)
{
    if (ret){
        AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_UPDATE_ROBOT_INFO, OnUpdateRobotPlayerInfo);
        AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_QUERY_ROBOT_INFO, OnQueryRobotPlayerInfo);
    }

	// 刷新当天时间
	m_nCurrentDate = GetDateTime();

	// 一分钟刷新一次
	m_timerFresh = evp().loopTimer([this](){this->OnFreshTimer(); }, std::chrono::minutes(1), strand());
}

void RobotPlayerData::OnShutDown()
{
    m_timerFresh = nullptr;
}

void RobotPlayerData::OnFreshTimer()
{
	if (GetDateTime() != m_nCurrentDate) {
		m_nCurrentDate = GetDateTime();
	}
}

int RobotPlayerData::GetCurDate()
{
    return async<int>([this](){
        return m_nCurrentDate;
    }).get();
}

std::string RobotPlayerData::toKey(int userid)
{
    std::stringstream ss;
    ss << typeid(*this).name() << "_" << userid;

    return ss.str();
}

BOOL RobotPlayerData::OnUpdateRobotPlayerInfo(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest) 
{
	REQUEST response;
	memset(&response, 0, sizeof(response));
	response.head.nRequest = lpRequest->head.nRequest;
	response.head.nSubReq = UR_OPERATE_FAILED;
	response.head.nRepeated = 1;

	int  nResult = 0;

	int nRepeated = lpRequest->head.nRepeated;
	if ((nRepeated * sizeof(CONTEXT_HEAD) + sizeof(ROBOT_UPDATE_PLAYERDATA)) != lpRequest->nDataLen)
	{
		return FALSE;
	}
	LPROBOT_UPDATE_PLAYERDATA lpReqData = (LPROBOT_UPDATE_PLAYERDATA)(PBYTE(lpRequest->pDataPtr) + nRepeated * sizeof(CONTEXT_HEAD));
	int nUserID = lpReqData->nUserID;

	ROBOT_PLAYER_DATA robotData;
	memset(&robotData, 0, sizeof(ROBOT_PLAYER_DATA));
	robotData.nUserID = nUserID;
    int nCurDate = GetCurDate();

    auto dbkey = toKey(nUserID);
	imDBOpera(dbkey, [nCurDate, nUserID, &robotData, &lpReqData, this](DBConnectEntry* entry){
		if (TRUE != entry->SelectDB(ROBOT_REDIS_SELECT_INDEX)) {
			return FALSE;
		}
        Redis_QueryRobotData(entry, nCurDate, nUserID, robotData);

		//连输
		if (lpReqData->nWin <= 0)
		{
			//输/平		
			robotData.nLoseCount += 1;
		}
		else{
			robotData.nLoseCount = 0;
		}

		//今日局数
		robotData.nTodayCount += 1;

		if (lpReqData->bSpecialRobot)
		{
			robotData.nRobotCountGot += 1;
			if (lpReqData->nWin > 0)
			{
				
			}
			else{
				//机器人机会保留
				robotData.nContainRobot = 1;
			}
		}

        return Redis_UpdateRobotData(entry, nCurDate, nUserID, lpReqData, robotData);
    }).get();
	// ope succeed
	response.head.nSubReq = UR_FETCH_SUCCEEDED;

	int nLen = nRepeated*sizeof(CONTEXT_HEAD) + sizeof(int);
	PBYTE pData = NULL;
	pData = new BYTE[nLen];
	memset(pData, 0, nLen);

	memcpy(pData, lpRequest->pDataPtr, nRepeated*sizeof(CONTEXT_HEAD));
	memcpy(pData + nRepeated*sizeof(CONTEXT_HEAD), &nResult, sizeof(nResult));
	response.pDataPtr = pData;
	response.nDataLen = nLen;

    // 发送给游戏服务的消息
	imSendOpeRequest(lpContext, response);


    //-------------------------发通知到房间服务-------------------------------------
    CONTEXT_HEAD context;
    memset(&context, 0, sizeof(CONTEXT_HEAD));
    REQUEST request;

    imGetRoomSvrSock(context.hSocket, context.lTokenID);
    request.head.nRequest = lpRequest->head.nRequest;
    request.pDataPtr = &robotData;
    request.nDataLen = sizeof(robotData);

    // 发通知到房间服务
    imSendOpeRequest(&context, request);
    //------------------------------------------------------------------
	UwlClearRequest(&response);

	return TRUE;
}

BOOL RobotPlayerData::OnQueryRobotPlayerInfo(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
	REQUEST response;
	memset(&response, 0, sizeof(response));
	response.head.nRequest = lpRequest->head.nRequest;
	response.head.nSubReq = UR_OPERATE_FAILED;
	response.head.nRepeated = 1;

	int nRepeated = lpRequest->head.nRepeated;
	LPROBOT_QUERY_USERDATA lpReqData = LPROBOT_QUERY_USERDATA(PBYTE(lpRequest->pDataPtr) + nRepeated * sizeof(CONTEXT_HEAD));
	int nUserID = lpReqData->nUserID;

	if (nUserID <= 0){
		UwlLogFile("OnQueryRobotPlayerInfo userid is invalid.");
        imSendOpeResponse(lpContext, FALSE, response);
		return FALSE;
	}

	//////////////////////////////////////////////////////////////////////////
	ROBOT_PLAYER_DATA robotData;
	memset(&robotData, 0, sizeof(robotData));
	robotData.nUserID = nUserID;
    int nCurDate = GetCurDate();

    auto dbkey = toKey(nUserID);
    std::future<int> f;
	auto r = imDBOpera(dbkey, [nCurDate, nUserID, &robotData, this](DBConnectEntry* entry){
		if (TRUE != entry->SelectDB(ROBOT_REDIS_SELECT_INDEX)) {
			return FALSE;
		}
        int nResult = Redis_QueryRobotData(entry, nCurDate, nUserID, robotData);
        if (nResult == 0)
        {
            //当天还没有数据，先计算一下要不要机器人,同步到redis
            nResult = Redis_InitRobotData(entry, nCurDate, nUserID, robotData);
        }
        return nResult;
    }).get();
	//////////////////////////////////////////////////////////////////////////
	// ope succeed
	response.head.nSubReq = UR_FETCH_SUCCEEDED;

	int nLen = nRepeated*sizeof(CONTEXT_HEAD) + sizeof(robotData);
	PBYTE pData = NULL;
	pData = new BYTE[nLen];
	memset(pData, 0, nLen);

	memcpy(pData, lpRequest->pDataPtr, nRepeated*sizeof(CONTEXT_HEAD));
	memcpy(pData + nRepeated*sizeof(CONTEXT_HEAD), &robotData, sizeof(robotData));
	response.pDataPtr = pData;
	response.nDataLen = nLen;

    imSendOpeRequest(lpContext, response);
	UwlClearRequest(&response);

	return TRUE;
}

int RobotPlayerData::Redis_QueryRobotData(DBConnectEntry* entry, int nDate, int nUserID, ROBOT_PLAYER_DATA& robotData)
{
	CString strCommand;
	BOOL bValue;
	strCommand.Format("HGETALL %s%d:%d ", TABLE_ROBOT_PLAYERDATA, nDate, nUserID);
	std::list<CString> data;
	bValue = entry->RedisCommandEx(data, (LPCTSTR)strCommand);
	if (!bValue)
	{
		return -1;
	}

	CString groupValue;
	std::list<CString>::iterator iter = data.begin();
	if (data.size() == 0)
	{
		//当天还没有数据，先计算一下要不要机器人,同步到redis
		//Redis_InitRobotData(nDate, nUserID, nTotalBouts, robotData);
		return 0;
	}
	for (int i = 0; i < data.size() / 2; i++, iter++)
	{
		if (*iter == REDIS_LOSE_KEY)
		{
			iter++;
			robotData.nLoseCount = atoi(*iter);
		}		
		else if (*iter == REDIS_MATCHTIME_KEY)
		{
			iter++;
			robotData.nRobotCountGot = atoi(*iter);
		}	
		else if (*iter == REDIS_BOUTCOUNT_KEY)
		{
			iter++;
			robotData.nTodayCount = atoi(*iter);
		}
		continue;
	}

	return 1;
}

int RobotPlayerData::Redis_InitRobotData(DBConnectEntry* entry, int nDate, int nUserID, ROBOT_PLAYER_DATA& robotData)
{
	CString strCommand;
	CString strValue;

	strCommand.Format("HMSET %s%d:%d %s %d %s %d %s %d", TABLE_ROBOT_PLAYERDATA, nDate, nUserID, REDIS_LOSE_KEY, robotData.nLoseCount, REDIS_BOUTCOUNT_KEY, robotData.nTodayCount, REDIS_MATCHTIME_KEY, robotData.nRobotCountGot);
	strValue = entry->RedisCommand_pach(strCommand);
	int nResultValue = atoi(strValue);

	//设置数据自动销毁时间
	strCommand.Format("EXPIREAT %s%d:%d %d", TABLE_ROBOT_PLAYERDATA, nDate, nUserID, GetTonightAbortTime());
	strValue = entry->RedisCommand_pach(strCommand);

	return nResultValue;
}

int RobotPlayerData::Redis_UpdateRobotData(DBConnectEntry* entry, int nDate, int nUserID, LPROBOT_UPDATE_PLAYERDATA lpReqPlayerData, ROBOT_PLAYER_DATA& robotData)
{
	CString strCommand;
	CString strValue;

	strCommand.Format("HMSET %s%d:%d %s %d %s %d %s %d", TABLE_ROBOT_PLAYERDATA, nDate, nUserID, REDIS_LOSE_KEY, robotData.nLoseCount, REDIS_BOUTCOUNT_KEY, robotData.nTodayCount, REDIS_MATCHTIME_KEY, robotData.nRobotCountGot);
	strValue = entry->RedisCommand_pach(strCommand);
	int nResultValue = atoi(strValue);

	//设置数据自动销毁时间
	strCommand.Format("EXPIREAT %s%d:%d %d", TABLE_ROBOT_PLAYERDATA, nDate, nUserID, GetTonightAbortTime());
	strValue = entry->RedisCommand_pach(strCommand);

	LOG_DEBUG("[ROBOT]UpdateRobotData %d: nLose: %d, nBout: %d, nMatchTime: %d", nUserID, robotData.nLoseCount, robotData.nTodayCount, robotData.nRobotCountGot);
	return nResultValue;
}
