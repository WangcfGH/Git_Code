#include "stdafx.h"
#include "DataRecord.h"

static CString GetHexadecimalString(TCHAR* desString)
{
    if (!desString || '\0' == desString[0])
    {
        return "";
    }
    const TCHAR* pString = desString;
    int nCount = strlen(pString);
    char* pBuf = new char[2 * nCount + 1];
    char* p = pBuf;
    for (int j = 0; j < nCount; j++)
    {
        p += sprintf_s(p, 2 * nCount + 1 - 2 * j, "%02x", (BYTE)pString[j]);
    }

    CString srcString(pBuf);
    delete[] pBuf;
    return srcString;
}

static int GetDateTime(int nDaySpan = 0)
{
    CTime t = CTime::GetCurrentTime();
    if (0 < nDaySpan)
    {
        t += CTimeSpan(nDaySpan, 0, 0, 0);
    }
    else
    {
        t -= CTimeSpan(-nDaySpan, 0, 0, 0);
    }

    return atoi(t.Format("%Y%m%d"));
}

static CString GetCurTime()
{
    CTime t = CTime::GetCurrentTime();
    return t.Format("%Y-%m-%d %H:%M:%S");
}

void DataRecord::OnServerStart(BOOL &ret, TcyMsgCenter *msgCenter)
{
    if (ret) {
        AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_DATARECORD_LOG_EVENT, OnLogEvent);
        AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_DATARECORD_LOG_FUNC_USED, OnLogEventFuncUsed);
        AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_DATARECORD_NEW_APP_UPLOAD, OnLogEventAppUpload);
        AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_TAKE_TREASURE_AWARD, OnLogEventTreasureAward);
        AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_DATARECORD_LOG_USERBEHAVIOR, OnLogEventUserBehavior);

        UpdateDeleteTime();
        m_timerFresh = evp().loopTimer([this](){this->onFreshTimer(); }, std::chrono::minutes(1), strand());

        // 服务器跑起来的时候先创建一次表
        DB_CreateTableEveryDay(0);
        DB_CreateUserRecordTableEveryDay(0);
        DB_CreateTableEveryDay(1);
        DB_CreateUserRecordTableEveryDay(1);
    }
}

void DataRecord::OnShutdown()
{
    m_timerFresh = nullptr;
    async<void>([this](){
        m_funcUsedLog.RemoveAll();
    }).get();
}

void DataRecord::OnPlayerLogon(NTF_PLAYERLOGON& playerLogon)
{
    auto dbkey = toKey(playerLogon.nUserID);
    imDBOpera(dbkey, [playerLogon, this](DBConnectEntry* entry){
        TCHAR szSql[MAX_SQL_LENGTH];
        struct sockaddr_in addr;
        addr.sin_addr.s_addr = playerLogon.dwIPAddr;
        CTime time(playerLogon.nLogonTime);
        sprintf_s(szSql, _T("call usp_log_player_logon(%d, %d, '%s', '%s', '%s')"),
            GetDateTime(), playerLogon.nUserID, time.Format("%Y-%m-%d %H:%M:%S"),
            inet_ntoa(addr.sin_addr), playerLogon.szHardID);
        return entry->mysql_excute(szSql);
    }).get();
}

void DataRecord::OnLogEvent(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
    //开始解析数据
    int nRepeated = lpRequest->head.nRepeated;

    LOG_HEAD Head;
    memcpy(&Head, (PBYTE(lpRequest->pDataPtr) + nRepeated * sizeof(CONTEXT_HEAD)), sizeof(LOG_HEAD));
    switch (Head.nEventID)
    {
    case LOG_EVENT_3DCOUNT:
    {
        OnLogEvent3DCount(lpContext, lpRequest);
    }
    break;

    }
}

void DataRecord::OnLogEventFuncUsed(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
    int nRepeated = lpRequest->head.nRepeated;
    auto pDataResp = RequestDataParse<FUNCUSED_LOG>(lpRequest);
    if (nullptr == pDataResp) {
        return ;
    }

    TCHAR key[KEY_DEFAULT_LEN];
    sprintf_s(key, _T("%d_%d"), pDataResp->nUserID, pDataResp->nFuncID);

    async<void>([&key, pDataResp, this](){
        m_funcUsedLog.SetAt(key, pDataResp->nFuncID);
    }).get();
}

void DataRecord::OnLogEventAppUpload(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
    //开始解析数据
    int nRepeated = lpRequest->head.nRepeated;
    auto pDataResp = RequestDataParse<APPUPLOAD_DATA>(lpRequest);
    if (nullptr == pDataResp) {
        return;
    }

    LOG_TRACE(_T("START DR_onNewAppUpload UserID = %d"), pDataResp->nUserID);
    //开始数据库操作
    auto dbkey = toKey(pDataResp->nUserID);
    imDBOpera(dbkey, [pDataResp, this](DBConnectEntry* entry){
        auto Log = pDataResp;
        TCHAR szSql[MAX_SQL_LENGTH];
        sprintf_s(szSql, _T("call usp_new_app_data_upload(%d, '%s', '%s', %d, %d, %d, %d, %d, %d, %d, %d, '%s', '%s', '%s')"),
            pDataResp->nUserID, LPCTSTR(GetHexadecimalString(Log->szWeChatName)), GetCurTime().GetBuffer(), Log->nFirstLogon,
            Log->nHappyCoin, Log->nFreeHappyCoin, Log->nScoreNum, Log->nDepositNum, Log->nSafeboxNum, Log->nNetType,
            Log->nChannelNO, Log->szClientVer, Log->szExtend, Log->szHardID);
        return entry->mysql_excute(szSql);
    }).get();
    LOG_TRACE(_T("END DR_onNewAppUpload UserID = %d"), pDataResp->nUserID);
}

void DataRecord::OnLogEventTreasureAward(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
    //开始解析数据
    int nRepeated = lpRequest->head.nRepeated;
    auto pDataResp = RequestDataParse<LOGTREASUREAWARD>(lpRequest);
    if (nullptr == pDataResp) {
        return;
    }

    auto dbkey = toKey(pDataResp->nUserID);
    imDBOpera(dbkey, [pDataResp, this](DBConnectEntry* entry){
        auto Log = pDataResp;
        TCHAR szSql[MAX_SQL_LENGTH];
        sprintf_s(szSql, _T("call usp_add_treasure_award_log(%d, %d, %d, %d, %d, %d, '%s', %d)"),
            GetDateTime(), Log->nUserID, Log->nRoomID, Log->nPrizeType, Log->nPrizeCount,
            Log->nBoutCount, GetCurTime().GetBuffer(), Log->nAwardSuccess);
        return entry->mysql_excute(szSql);
    }).get();
}

void DataRecord::OnLogEventUserBehavior(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
    int nRepeated = lpRequest->head.nRepeated;
    auto pDataResp = RequestDataParse<USERBEHAVIOR>(lpRequest);
    if (nullptr == pDataResp) {
        return;
    }
    auto dbkey = toKey(pDataResp->nUserID);
    imDBOpera(dbkey, [pDataResp, this](DBConnectEntry* entry){
        TCHAR szSql[MAX_SQL_LENGTH];
        auto Log = pDataResp;
        sprintf_s(szSql, _T("call usp_insert_user_record(%d, '%s', %d, '%s', '%s', '%s')"),
            Log->nUserID, GetCurTime().GetBuffer(), Log->nBehaviorID, Log->szPlatformVersion,
            Log->szGameVersion, Log->szChannelID);
        return entry->mysql_excute(szSql);
    }).get();
}

void DataRecord::OnLogEvent3DCount(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
    int nRepeated = lpRequest->head.nRepeated;
    LOG3DDATA DataResp;
    ZeroMemory(&DataResp, sizeof(DataResp));
    memcpy(&DataResp, (PBYTE(lpRequest->pDataPtr) + nRepeated * sizeof(CONTEXT_HEAD)) + sizeof(LOG_HEAD), lpRequest->nDataLen - sizeof(CONTEXT_HEAD) - sizeof(LOG_HEAD));

    LOG_TRACE(_T("START LOG_EVENT_3DCOUNT UserID = %d"), DataResp.nUserID);
    auto dbkey = toKey(DataResp.nUserID);
    imDBOpera(dbkey, [DataResp, this](DBConnectEntry* entry){
        TCHAR szSql[MAX_SQL_LENGTH];
        sprintf_s(szSql, _T("call usp_add_3d_data(%d, %d, %d, %d, %d, '%s')"),
            DataResp.date, DataResp.nUserID, DataResp.n3DCount,
            DataResp.n2DCount, DataResp.support3D, DataResp.szExtend);
        return entry->mysql_excute(szSql);
    }).get();
    LOG_TRACE(_T("END LOG_EVENT_3DCOUNT UserID = %d"), DataResp.nUserID);
}

void DataRecord::DB_CreateTableEveryDay(int day)
{
    std::string dbKey = "CreateTableEveryDay";
    imDBOpera(dbKey, [day, this](DBConnectEntry* entry){
        TCHAR szSql[MAX_SQL_LENGTH];
        sprintf_s(szSql, _T("call usp_create_table_every_day(%d)"), GetDateTime(day));
        return entry->mysql_excute(szSql);
    }).get();
}

void DataRecord::DB_CreateUserRecordTableEveryDay(int day)
{
    std::string dbKey = "CreateUserRecordTableEveryDay";
    imDBOpera(dbKey, [day, this](DBConnectEntry* entry){
        TCHAR szSql[MAX_SQL_LENGTH];
        sprintf_s(szSql, _T("call usp_create_userrecord_table_every_day(%d)"), GetDateTime(day));
        return entry->mysql_excute(szSql);
    }).get();
}

void DataRecord::DB_DeleteOverdueLog(int nDate)
{
    std::string dbKey = "DeleteOverdueLog";
    imDBOpera(dbKey, [nDate, this](DBConnectEntry* entry){
        TCHAR szSql[MAX_SQL_LENGTH];
        sprintf_s(szSql, _T("call usp_delete_overdue_log(%d)"), nDate);
        return entry->mysql_excute(szSql);
    }).get();
}

void DataRecord::DB_DeleteUserRecordOverdueLog(int nDate)
{
    std::string dbKey = "DeleteUserRecordOverdueLog";
    imDBOpera(dbKey, [nDate, this](DBConnectEntry* entry){
        TCHAR szSql[MAX_SQL_LENGTH];
        sprintf_s(szSql, _T("call usp_delete_userrecord_overdue_log(%d)"), nDate);
        return entry->mysql_excute(szSql);
    }).get();
}

std::string DataRecord::toKey(int userid)
{
    std::stringstream ss;
    ss << typeid(*this).name() << "_" << userid;

    return ss.str();
}

BOOL DataRecord::IsInPeriodOfProfile(LPCTSTR lpSection, int nBegin, int nEnd)
{
    int begin = nBegin;
    imGetIniInt(
        lpSection,          // section name
        _T("begin"),        // key name
        nBegin             // default int
        );
    int end = nEnd;
    imGetIniInt(
        lpSection,          // section name
        _T("end"),          // key name
        nEnd               // default int
        );
    if (0 == begin && 0 == end)
    {
        return FALSE;
    }
    int curDate = 0;
    int curTime = 0;
    int result = UwlGetCurrentDateTime(curDate, curTime);
    curTime /= 100;
    if (curTime > begin && curTime < end)
    {
        return TRUE;
    }

    return FALSE;

}

void DataRecord::onFreshTimer()
{
    // 一分钟刷新一次
    auto pre = m_tTime;
    m_tTime = CTime::GetCurrentTime();

    // 先判断是否已经超过一天了
    if (pre.GetDay() != m_tTime.GetDay()) {
        // 每天将功能使用率埋点从缓存推到数据库
        DB_RecordFuncUsedLog();
    }

    //每天凌晨2:30开始清除过期数据
    if (m_nDeleteHour == m_tTime.GetHour() && m_nDeleteMinute == m_tTime.GetMinute())
    {
        DB_CreateTableEveryDay(1);
        DB_CreateUserRecordTableEveryDay(1);

        if (IsInPeriodOfProfile(_T("dblock"), DEF_DBLOCK_BEGIN, DEF_DBLOCK_END))
        {
            return ;
        }
        int nExpireTime = GetExpireSetConfig();
        if (0 < nExpireTime) {
            DB_DeleteOverdueLog(nExpireTime);
        }
            
        nExpireTime = GetUerRecordExpireSetConfig();
        if (0 < nExpireTime) {
            DB_DeleteUserRecordOverdueLog(nExpireTime);
        }
    }
}

//返回数据保留天数(为0表示不删除)
int DataRecord::GetExpireSetConfig()
{
    int nExpireTime = 0;

    int nRetainDays = 0;
    imGetIniInt(_T("ExpireSet"), _T("RetainDays"), nRetainDays);

    if (0 < nRetainDays)
    {
        CTime t = CTime::GetCurrentTime();
        t -= CTimeSpan(nRetainDays, 0, 0, 0);
        nExpireTime = atoi(t.Format("%Y%m%d"));
    }

    return nExpireTime;
}

//返回数据保留天数(为0表示不删除)
int DataRecord::GetUerRecordExpireSetConfig()
{
    int nExpireTime = 0;

    int nRetainDays = 0;
    imGetIniInt(_T("ExpireSet"), _T("UserRecordRetainDays"), nRetainDays);

    if (0 < nRetainDays)
    {
        CTime t = CTime::GetCurrentTime();
        t -= CTimeSpan(nRetainDays, 0, 0, 0);
        nExpireTime = atoi(t.Format("%Y%m%d"));
    }

    return nExpireTime;
}

void DataRecord::UpdateDeleteTime()
{
    // 使用端口号做随机种子
    int nPort = PORT_OF_CHUNKLOG;
    imGetIniInt(_T("listen"), _T("port"), nPort);
    srand(nPort);
    m_nDeleteHour = rand() % 24;
    m_nDeleteMinute = rand() % 60;
    UwlLogFile(_T("current RecordModule DeleteTime = %d:%d every day"), m_nDeleteHour, m_nDeleteMinute);
}

void DataRecord::DB_RecordFuncUsedLog()
{
    INT funcID = 0;
    CString sKey;
    INT funcCount[FUNC_TYPE_MAX] = { 0 };
    POSITION pos = m_funcUsedLog.GetStartPosition();

    while (pos)
    {
        m_funcUsedLog.GetNextAssoc(pos, sKey, funcID);
        funcCount[funcID] += 1;
    }
    std::string dbkey = "RecordFuncUsedLog";
    imDBOpera(dbkey, [&funcCount, this](DBConnectEntry* entry){
        //获得昨天的日期
        int curTime = GetDateTime(-1);
        int nResult = 0;
        for (int i = 1; i < FUNC_TYPE_MAX && nResult == 0; i++)
        {
            if (0 == funcCount[i])
            {
                continue;
            }

            TCHAR szSql[MAX_SQL_LENGTH];
            sprintf_s(szSql, _T("call usp_log_func_used(%d, %d, %d)"), curTime, i, funcCount[i]);
            nResult = entry->mysql_excute(szSql);
        }
        return nResult;
    }).get();
    //清空前一天的数据
    m_funcUsedLog.RemoveAll();
}