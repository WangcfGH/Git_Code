#include "stdafx.h"
#include "GameLogData.h"
#include <fstream>
#include <chrono>

//////////////////////////////////////////////////////////////////////////
GameLogData::GameLogData(CString strIniFile, CMyGameServer* pServer) : DataLogerModule(strIniFile), m_pMyServer(pServer)
{
}


GameLogData::~GameLogData()
{
}

void GameLogData::Init()
{
    auto headerPlayRecord_XZ = []()
    {
        static std::vector<std::string> header = { "时间点", "房间ID", "茶水费", "基础银", "总番数",
                                            "玩家1", "耗时", "终端", "血战总对局数", "川麻总对局数", "角色", "输赢顺序", "初始银两", "剩余银两", "番数", "保险箱银值", "是否做牌", "玩家类型", "渠道号",
                                            "玩家2", "耗时", "终端", "血战总对局数", "川麻总对局数", "角色", "输赢顺序", "初始银两", "剩余银两", "番数", "保险箱银值", "是否做牌", "玩家类型", "渠道号",
                                            "玩家3", "耗时", "终端", "血战总对局数", "川麻总对局数", "角色", "输赢顺序", "初始银两", "剩余银两", "番数", "保险箱银值", "是否做牌", "玩家类型", "渠道号",
                                            "玩家4", "耗时", "终端", "血战总对局数", "川麻总对局数", "角色", "输赢顺序", "初始银两", "剩余银两", "番数", "保险箱银值", "是否做牌", "玩家类型", "渠道号"
                                        };
        std::stringstream ss;
        for (auto it = header.begin(); it != header.end(); ++it)
        {
            ss << it->data() << ",";
        }
        ss << std::endl;
        return ss.str();
    };
    Start();
    SetLoger("PlayRecordXZ", std::make_shared<DataLogerRule>(
            GetINIFileName(), std::string("PlayRecordXZ"), ".log", headerPlayRecord_XZ
        ));

    auto headerPlayRecord_XL = []()
    {
        static std::vector<std::string> header = { "时间点", "房间ID", "茶水费", "基础银", "总番数",
                                            "玩家1", "耗时", "终端", "血流总对局数", "川麻总对局数", "角色", "胡牌次数", "初始银两", "剩余银两", "个人总番数", "保险箱银值", "是否做牌", "玩家类型", "渠道号",
                                            "玩家2", "耗时", "终端", "血流总对局数", "川麻总对局数", "角色", "胡牌次数", "初始银两", "剩余银两", "个人总番数", "保险箱银值", "是否做牌", "玩家类型", "渠道号",
                                            "玩家3", "耗时", "终端", "血流总对局数", "川麻总对局数", "角色", "胡牌次数", "初始银两", "剩余银两", "个人总番数", "保险箱银值", "是否做牌", "玩家类型", "渠道号",
                                            "玩家4", "耗时", "终端", "血流总对局数", "川麻总对局数", "角色", "胡牌次数", "初始银两", "剩余银两", "个人总番数", "保险箱银值", "是否做牌", "玩家类型", "渠道号"
                                        };
        std::stringstream ss;
        for (auto it = header.begin(); it != header.end(); ++it)
        {
            ss << it->data() << ",";
        }
        ss << std::endl;
        return ss.str();
    };
    Start();
    SetLoger("PlayRecordXL", std::make_shared<DataLogerRule>(
            GetINIFileName(), std::string("PlayRecordXL"), ".log", headerPlayRecord_XL
        ));
}

BOOL GameLogData::_OnInit()
{
    __super::_OnInit();

    WORKER_SET_TIMER_WITH_FUNC(TIMER_FRESH_LOGER_FILE, 60 * 1000, &GameLogData::OnTimerFreshFile);

    return TRUE;
}

BOOL GameLogData::OnTimerFreshFile(UINT id)
{
    return __super::OnTimerFreshFile(id);
}

void GameLogData::UnInit()
{
    Stop();
}

void GameLogData::OnServerStart(BOOL& ret, TcyMsgCenter* msgCenter)
{
    if (ret)
    {
        Init();
    }
}

void GameLogData::OnShutDown()
{
    UnInit();
}

void GameLogData::OnNewTable(CCommonBaseTable* pTable)
{
    using namespace plana::events;
    pTable->m_entity.assign<GameLogCom>();
    pTable->evStartAfter += delegate(this, &GameLogData::OnStartAfter);
	pTable->evResetRound += delegate(this, &GameLogData::OnRestMembers);
}

void GameLogData::OnCPGameWin(LPCONTEXT_HEAD lpContext, int roomid, CCommonBaseTable* pTable, void* pData)
{
    FreshCache((CMyGameTable*)pTable);
    if (((CMyGameTable*)pTable)->IsXueLiuRoom())
    {
        PushT<PLAYRECORDFORLOG_XL>("PlayRecordXL", (CMyGameTable*)pTable, (LPGAME_WIN)pData, m_pMyServer);
    }
    else
    {
        PushT<PLAYRECORDFORLOG_XZ>("PlayRecordXZ", (CMyGameTable*)pTable, (LPGAME_WIN)pData, m_pMyServer);
    }
}

void GameLogData::OnStartAfter(CCommonBaseTable* pTable)
{
    auto com = pTable->m_entity.component<GameLogCom>();
    com->m_startGameTime = CTime::GetCurrentTime();
}

void GameLogData::OnStartSoloTable(START_SOLOTABLE* pStartSoloTable, CCommonBaseTable* pTable, void* pData)
{
	auto com = pTable->m_entity.component<GameLogCom>();
	for (int i = 0; i < pTable->m_nTotalChairs; ++i) {
		CPlayer* ptrP = pTable->m_ptrPlayers[i];
		if (ptrP) {
			tc::KPIClientData temp;
			imGetKPIClientData(pTable->m_ptrPlayers[i]->m_nUserID, temp);
			com->m_pkgType[i] = temp.pkgtype();
			if (temp.has_recommgameid()) {
				com->m_nRecommandid[i] = temp.recommgameid();
			}
			else {
				com->m_nRecommandid[i] = 0;
			}
		}
	}
}

void GameLogData::OnGameStarted(CCommonBaseTable* pTable, void* pData)
{
	auto com = pTable->m_entity.component<GameLogCom>();
	for (int i = 0; i < pTable->m_nTotalChairs; i++)
	{
		CPlayer* ptrP = pTable->m_ptrPlayers[i];
		if (ptrP)
		{
			tc::KPIClientData temp;

			imGetKPIClientData(pTable->m_ptrPlayers[i]->m_nUserID, temp);
			com->m_pkgType[i] = temp.pkgtype();
			if (temp.has_recommgameid())
			{
				com->m_nRecommandid[i] = temp.recommgameid();
			}
			else
			{
				com->m_nRecommandid[i] = 0;
			}
		}
	}
}

void GameLogData::OnRestMembers(CCommonBaseTable* pTable)
{
	auto com = pTable->m_entity.component<GameLogCom>();
	ZeroMemory(com->m_pkgType, sizeof(com->m_pkgType));
	ZeroMemory(com->m_nRecommandid, sizeof(com->m_nRecommandid));
}

void GameLogData::FreshCache(CMyGameTable* pTable)
{
    int roomid = pTable->m_nRoomID;
    int tableno = pTable->m_nTableNO;

    auto f = [roomid, tableno, this]()
    {
        auto key = ToKey(roomid, tableno);

        m_tableCache.erase(key);
        m_tableCache[key] = std::make_shared<MTableData>();
    };
    PostT(f);
}

MTableData::Ptr GameLogData::GetMTablePtr(int roomid, int tableno)
{
    MTableData::Ptr ptr;
    auto key = ToKey(roomid, tableno);
    auto it = m_tableCache.find(key);
    if (it != m_tableCache.end())
    {
        ptr = it->second;
    }
    return ptr;
}

std::string GameLogData::ToKey(int roomid, int tableno)
{
    std::stringstream ss;
    ss << roomid << "," << tableno;
    return ss.str();
}

//////////////////////////////////////////////////////////////////////////
bool PlayRecordUtils::ParseTableDesposit(int nRoomID, TableDesposit& tableDesposit)
{
    CString strIniFile = GetINIFileName();
    std::stringstream ss;
    ss << "TableDeposit" << nRoomID;
    int count = GetPrivateProfileInt(ss.str().c_str(), "Count", 0, strIniFile);
    for (auto i = 0; i < count; ++i)
    {
        char szBuffer[256] = { 0 };
        GetPrivateProfileString(ss.str().c_str(), std::to_string(i).c_str(), "", szBuffer, sizeof(szBuffer), strIniFile);
        if (0 == strlen(szBuffer))
        {
            continue;
        }
        TableDespositLine one;
        one.id = i;
        int r = sscanf_s(szBuffer, "%d|%d|%d", &one.low, &one.high, &one.base);
        tableDesposit.config.push_back(one);

        if (3 != r)
        {
            UwlLogFile("TableDeposit<s> i<%d> data<%s>", ss.str().c_str(), i, szBuffer);
        }
    }
    return !tableDesposit.config.empty();
}

std::string PlayRecordUtils::TableDesposit::GetArea(int tableno)
{
    int i = 0;
    TableDespositLine* line = nullptr;
    for (; i < config.size(); ++i)
    {
        const auto& one = config.at(i);
        if (tableno == min(one.high, max(tableno, one.low)))
        {
            line = &config[i];
            break;
        }
    }

    if (nullptr == line)
    {
        return std::to_string(tableno) + "||";
    }

    // 判断下一个配置是否可以当成它的上限
    if (i + 1 >= config.size())
    {
        return std::to_string(line->id) + "|" + std::to_string(line->base) + "|";
    }

    TableDespositLine* next = &config[i + 1];
    return std::to_string(line->id) + "|" + std::to_string(line->base) + "|" + std::to_string(next->base);
}

std::string MTableData::GetUniqeID()
{
    USES_CONVERSION;
    GUID Guid;
    ::CoCreateGuid(&Guid);
    OLECHAR szClassID[39];
    int cchGuid = ::StringFromGUID2(Guid, szClassID, sizeof(szClassID));
    CString sGuid = OLE2CT(szClassID);
    sGuid.Replace(_T("{"), _T(""));
    sGuid.Replace(_T("}"), _T(""));
    sGuid.Replace(_T("-"), _T(""));
    return std::string(sGuid);
}
