#include "stdafx.h"
#include "WxTaskModule.h"
#include <fstream>
#include "hiredis.h"
#include <list>

#define DAILY_WXTASK_PARAM_REDIS_KEY "dailyWxTaskParam"
#define DAILY_WXTASK_DATA_REDIS_KEY "dailyWxTaskData"
#define WXTASK_REDIS_SELECT_INDEX 4
/*json配置相关*/
/* 命令行(包含所属路径)最大长度*/
static const int SC_OS_PROCESS_CMD_BUF_LEN = 1024;
static char SC_OS_SEPARATE = '\\';
const char  TASK_JSON_FILE[] = "TaskConfig.json";
const char  WXTASK_JSON_FILE[] = "WxTaskConfig.json";

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

static const char* GetExecName()
{
    static char s_szCmdName[SC_OS_PROCESS_CMD_BUF_LEN] = { 0 };
    static char* s_pszCmdName = NULL;

    if (!s_pszCmdName)
    {
        ::GetModuleFileNameA(
            NULL,
            s_szCmdName,
            sizeof(s_szCmdName));

        s_pszCmdName = s_szCmdName;
    }

    return s_pszCmdName;
}

static const char* GetProcessName()
{
    const char* pszExecName = GetExecName();

    if (pszExecName)
    {
        const char* pchFind = pszExecName + strlen(pszExecName);

        while ((pchFind > pszExecName) &&
            (SC_OS_SEPARATE != *pchFind))
        {
            pchFind--;
        }

        if (SC_OS_SEPARATE == *pchFind)
        {
            pchFind++;
        }

        return pchFind;
    }
    else
    {
        return "UnknowProcess";
    }
}

static const char* GetExecDir()
{
    static char s_szExecDir[SC_OS_PROCESS_CMD_BUF_LEN] = { 0 };
    static char* s_pszExecDir = NULL;

    if (NULL == s_pszExecDir)
    {
        const char* pSzExecCmdName = GetExecName();
        const char* pSzProcessName = GetProcessName();
        const char* pOffset = ::strstr(pSzExecCmdName, pSzProcessName);
#if ( _MSC_VER <= 1200 )
        ::strncpy(s_szExecDir, pSzExecCmdName, (pOffset - pSzExecCmdName));
#else
        ::strncpy_s(s_szExecDir, pSzExecCmdName, (pOffset - pSzExecCmdName));
#endif
        s_pszExecDir = s_szExecDir;
    }

    return s_pszExecDir;
}
void WxTaskModule::OnServerStart(BOOL &ret, TcyMsgCenter *msgCenter)
{
    if (ret) {
        AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_WXTASK_CHANGE_PARAM, OnChangeWxTaskParam);
        AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_WXTASK_CHANGE_DATA, OnChangeWxTaskData);
        AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_WXTASK_QUERY_PARAM, OnQueryWxTaskParam);
        AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_WXTASK_QUERY_DATA, OnQueryWxTaskData);
        AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_WXTASK_GET_DATA_FOR_JSON, OnReqGetWxTaskConfigData);
        AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_WXTASK_AWARD_PRIZE_JSON, OnAwardWxTaskPrizeForJson);

        m_tTime = CTime::GetCurrentTime();
        loadWxTaskConfig();
        if (m_nFreshTime > (m_tTime.GetHour() * 100 + m_tTime.GetMinute()))
        {// everyday xx:xx, reset task table
            m_nCurrentDate = GetDateTime(-1);
        }
        else
        {
            m_nCurrentDate = GetDateTime();
        }
        clearTableCache();
        ReadWxTaskJsonConfig();

        m_timerFresh = evp().loopTimer([this](){this->onFreshTimer(); }, std::chrono::minutes(1), strand());
    }
}

BOOL WxTaskModule::OnDeleteLastWxTaskTable(DBConnectEntry* entry)
{
    if (0 < m_nRetainDaysOfParam)
    {
        CString strName("Param");
        int nDateOfParam = GetDateTime(-m_nRetainDaysOfParam);

        CString strCommand;
        strCommand.Format("DEL %s:%d", DAILY_WXTASK_PARAM_REDIS_KEY, nDateOfParam);
        entry->RedisCommand_pach((LPCTSTR)strCommand);

        UwlLogFile("delete DAILY_WXTASK_PARAM_REDIS_KEY");
    }
    if (0 < m_nRetainDaysOfData)
    {
        CString strName("Data");
        int nDateOfData = GetDateTime(-m_nRetainDaysOfData);

        std::list<CString> listHashes;
        CString strCommand;
        strCommand.Format("KEYS %s%d:*", DAILY_WXTASK_DATA_REDIS_KEY, nDateOfData);
		entry->RedisCommandEx((LPCTSTR)strCommand, listHashes);

        strCommand = _T("DEL");
        CString strSpace = _T(" ");
        std::list<CString>::iterator iter;
        for (iter = listHashes.begin(); iter != listHashes.end(); iter++)
        {
            strCommand = strCommand + strSpace + *iter;
        }
		entry->RedisCommand_pach((LPCTSTR)strCommand);

        UwlLogFile("delete DAILY_WXTASK_DATA_REDIS_KEY");
    }
    return TRUE;
}

void WxTaskModule::OnShutDown()
{
    m_timerFresh = nullptr;
}

BOOL WxTaskModule::OnChangeWxTaskParam(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
    REQUEST response;
    memset(&response, 0, sizeof(response));
    response.head.nRequest = lpRequest->head.nRequest;
    response.head.nSubReq = UR_OPERATE_FAILED;
    response.head.nRepeated = 1;

    int nRepeated = lpRequest->head.nRepeated;
    if ((nRepeated * sizeof(CONTEXT_HEAD) + sizeof(TASKPARAMCHANGE)) != lpRequest->nDataLen)
    {
        return FALSE;
    }
    LPTASKPARAMCHANGE lpReqData = (LPTASKPARAMCHANGE)(PBYTE(lpRequest->pDataPtr) + nRepeated * sizeof(CONTEXT_HEAD));
    int nUserID = lpReqData->nUserID;
    TASKPARAMINFO taskParamInfo;
    memset(&taskParamInfo, 0, sizeof(taskParamInfo));
    taskParamInfo.nUserID = nUserID;
    int nCurTime = GetCurTime();
    taskParamInfo.nDate = nCurTime;

    auto dbkey = toKey(nUserID);
	int r = imDBOpera(dbkey, [this, nCurTime, lpReqData, nUserID, &taskParamInfo](DBConnectEntry* entry){
        if (TRUE != entry->SelectDB(WXTASK_REDIS_SELECT_INDEX)) {
            return FALSE;
        }
        //////////////////////////////////////////////////////////////////////////
        Redis_UpdateWxTaskParam(entry, nCurTime, nUserID, lpReqData->nType, lpReqData->nValue);

        if (WXTASK_GAME_RESULT_WIN == lpReqData->nType) // bout win
        {
            Redis_UpdateWxTaskParamWin(entry, nCurTime, nUserID, WXTASK_GAME_CUR_WIN_STREAK, 1, WXTASK_GAME_MAX_WIN_STREAK);
        }
        else if (WXTASK_GAME_RESULT_LOSE == lpReqData->nType || WXTASK_GAME_RESULT_DRAW == lpReqData->nType) // bout not win
        {
            Redis_UpdateWxTaskParamLose(entry, nCurTime, nUserID, WXTASK_GAME_CUR_WIN_STREAK, 0);
        }
        //////////////////////////////////////////////////////////////////////////

        return Redis_QueryWxTaskParam(entry, nCurTime, nUserID, taskParamInfo.nParam);
        //////////////////////////////////////////////////////////////////////////
    }).get();
    if (r == FALSE) {
        return FALSE;
    }
    // ope succeed
    response.head.nSubReq = UR_FETCH_SUCCEEDED;

    int nLen = nRepeated*sizeof(CONTEXT_HEAD) + sizeof(taskParamInfo);
    PBYTE pData = NULL;
    pData = new BYTE[nLen];
    memset(pData, 0, nLen);

    memcpy(pData, lpRequest->pDataPtr, nRepeated*sizeof(CONTEXT_HEAD));
    memcpy(pData + nRepeated*sizeof(CONTEXT_HEAD), &taskParamInfo, sizeof(taskParamInfo));
    response.pDataPtr = pData;
    response.nDataLen = nLen;

    imSendOpeRequest(lpContext, response);
    UwlClearRequest(&response);
    return TRUE;
}

BOOL WxTaskModule::OnChangeWxTaskData(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
    REQUEST response;
    memset(&response, 0, sizeof(response));
    response.head.nRequest = lpRequest->head.nRequest;
    response.head.nSubReq = UR_OPERATE_FAILED;
    response.head.nRepeated = 1;

    int nRepeated = lpRequest->head.nRepeated;
    LPTASKDATACHANGE lpReqData = (LPTASKDATACHANGE)(PBYTE(lpRequest->pDataPtr) + nRepeated * sizeof(CONTEXT_HEAD));
    int nUserID = lpReqData->nUserID;

    auto dbkey = toKey(nUserID);
    imDBOpera(dbkey, [this, lpReqData, nUserID](DBConnectEntry* entry){
        if (TRUE != entry->SelectDB(WXTASK_REDIS_SELECT_INDEX)) {
            return FALSE;
        }
        return Redis_UpdateWxTaskData(entry, lpReqData->nDate, nUserID, lpReqData->nGroupID, lpReqData->nSubID, lpReqData->nFlag);
    }).get();
    UwlClearRequest(&response);
    return TRUE;
}

BOOL WxTaskModule::OnQueryWxTaskParam(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
    REQUEST response;
    memset(&response, 0, sizeof(response));
    response.head.nRequest = lpRequest->head.nRequest;
    response.head.nSubReq = UR_OPERATE_FAILED;
    response.head.nRepeated = 1;

    int nRepeated = lpRequest->head.nRepeated;
    LPTASKQUERY lpReqData = LPTASKQUERY(PBYTE(lpRequest->pDataPtr) + nRepeated * sizeof(CONTEXT_HEAD));
    int nUserID = lpReqData->nUserID;
    int nCurTime = GetCurTime();
    lpReqData->nDate = nCurTime; // 以该时刻为准;

    if (nUserID <= 0){
        UwlLogFile("OnQueryWxTaskParam userid is invalid.");
        imSendOpeReqOnlyCxt(lpContext, nRepeated, lpRequest->pDataPtr, response);
        return FALSE;
    }

    //////////////////////////////////////////////////////////////////////////
    TASKPARAMINFO taskParamInfo;
    memset(&taskParamInfo, 0, sizeof(taskParamInfo));
    taskParamInfo.nUserID = nUserID;
    taskParamInfo.nDate = lpReqData->nDate;
    auto dbkey = toKey(nUserID);
	int r = imDBOpera(dbkey, [this, lpReqData, nUserID, &taskParamInfo](DBConnectEntry* entry){
        if (TRUE != entry->SelectDB(WXTASK_REDIS_SELECT_INDEX)) {
            return FALSE;
        }
        return Redis_QueryWxTaskParam(entry, lpReqData->nDate, nUserID, taskParamInfo.nParam);
    }).get();
    if (r == FALSE) {
        return FALSE;
    }
    //////////////////////////////////////////////////////////////////////////
    // ope succeed
    response.head.nSubReq = UR_FETCH_SUCCEEDED;

    int nLen = nRepeated*sizeof(CONTEXT_HEAD) + sizeof(taskParamInfo);
    PBYTE pData = NULL;
    pData = new BYTE[nLen];
    memset(pData, 0, nLen);

    memcpy(pData, lpRequest->pDataPtr, nRepeated*sizeof(CONTEXT_HEAD));
    memcpy(pData + nRepeated*sizeof(CONTEXT_HEAD), &taskParamInfo, sizeof(taskParamInfo));
    response.pDataPtr = pData;
    response.nDataLen = nLen;

    imSendOpeRequest(lpContext, response);
    UwlClearRequest(&response);
    return TRUE;
}

BOOL WxTaskModule::OnQueryWxTaskData(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
    REQUEST response;
    memset(&response, 0, sizeof(response));
    response.head.nRequest = lpRequest->head.nRequest;
    response.head.nSubReq = UR_OPERATE_FAILED;
    response.head.nRepeated = 1;

    int nRepeated = lpRequest->head.nRepeated;
    LPTASKQUERY lpReqData = LPTASKQUERY(PBYTE(lpRequest->pDataPtr) + nRepeated * sizeof(CONTEXT_HEAD));
    int nUserID = lpReqData->nUserID;
    int nCurTime = GetCurTime();
    lpReqData->nDate = nCurTime; // 以该时刻为准

    if (nUserID <= 0){
        UwlLogFile("OnQueryWxTaskData userid is invalid.");
        imSendOpeReqOnlyCxt(lpContext, nRepeated, lpRequest->pDataPtr, response);
        return FALSE;
    }

    //////////////////////////////////////////////////////////////////////////
    TASKDATAINFO taskDataInfo;
    memset(&taskDataInfo, 0, sizeof(taskDataInfo));
    taskDataInfo.nUserID = nUserID;
    taskDataInfo.nDate = lpReqData->nDate;
    auto dbkey = toKey(nUserID);
	auto r = imDBOpera(dbkey, [this, lpReqData, nUserID, &taskDataInfo](DBConnectEntry* entry){
        if (TRUE != entry->SelectDB(WXTASK_REDIS_SELECT_INDEX)) {
            return FALSE;
        }
        return Redis_QueryWxTaskData(entry, lpReqData->nDate, nUserID, taskDataInfo.nDataNum, taskDataInfo.tData);
    }).get();
    if (r == FALSE) {
        return FALSE;
    }
    //////////////////////////////////////////////////////////////////////////
    // ope succeed
    response.head.nSubReq = UR_FETCH_SUCCEEDED;

    int nLen = nRepeated*sizeof(CONTEXT_HEAD) + sizeof(taskDataInfo);
    PBYTE pData = NULL;
    pData = new BYTE[nLen];
    memset(pData, 0, nLen);

    memcpy(pData, lpRequest->pDataPtr, nRepeated*sizeof(CONTEXT_HEAD));
    memcpy(pData + nRepeated*sizeof(CONTEXT_HEAD), &taskDataInfo, sizeof(taskDataInfo));
    response.pDataPtr = pData;
    response.nDataLen = nLen;

    imSendOpeRequest(lpContext, response);
    UwlClearRequest(&response);
    return TRUE;
}

BOOL WxTaskModule::OnReqGetWxTaskConfigData(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
    REQUEST response;
    memset(&response, 0, sizeof(response));
    response.head.nRequest = lpRequest->head.nRequest;
    response.head.nSubReq = UR_OPERATE_FAILED;
    response.head.nRepeated = 1;
    int nRepeated = lpRequest->head.nRepeated;

    std::string taskJsonConfig = GetTaskJsonString();

    int nLen = nRepeated*sizeof(CONTEXT_HEAD) + taskJsonConfig.length();
    PBYTE pData = new BYTE[nLen];
    memset(pData, 0, nLen);

    memcpy(pData, lpRequest->pDataPtr, nRepeated*sizeof(CONTEXT_HEAD));
    memcpy(pData + nRepeated*sizeof(CONTEXT_HEAD), (void*)taskJsonConfig.c_str(), taskJsonConfig.length());
    response.head.nSubReq = UR_FETCH_SUCCEEDED;
    response.pDataPtr = pData;
    response.nDataLen = nLen;

    imSendOpeRequest(lpContext, response);
    UwlClearRequest(&response);
    return TRUE;
}

BOOL WxTaskModule::OnAwardWxTaskPrizeForJson(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
    REQUEST response;
    memset(&response, 0, sizeof(response));
    response.head.nRequest = GR_WXTASK_AWARD_PRIZE;//lpRequest->head.nRequest;
    response.head.nSubReq = UR_OPERATE_FAILED;
    response.head.nRepeated = 1;

    int nRepeated = lpRequest->head.nRepeated;
    LPTASKAWARD lpReqData = LPTASKAWARD(PBYTE(lpRequest->pDataPtr) + nRepeated * sizeof(CONTEXT_HEAD));
    int nUserID = lpReqData->nUserID;
    int nCurDate = GetCurTime();
    lpReqData->nDate = nCurDate; // 以该时刻为准;
    int nGroupID = lpReqData->nGroupID;
    int nSubID = lpReqData->nSubID;
    if (nUserID <= 0){
        UwlLogFile("OnAwardWxTaskPrizeForJson userid is invalid.");
        imSendOpeReqOnlyCxt(lpContext, nRepeated, lpRequest->pDataPtr, response);
        return FALSE;
    }
    auto dbkey = toKey(nUserID);
    TASKINFOJSON tTaskInfo;
    memset(&tTaskInfo, 0, sizeof(tTaskInfo));
    if (0 >= GetWxTaskInfo(nGroupID, nSubID, &tTaskInfo))
    {
        response.head.nSubReq = 0;
        imSendOpeReqOnlyCxt(lpContext, nRepeated, lpRequest->pDataPtr, response);
        return FALSE;
    }
    imDBOpera(dbkey, [this, nCurDate, lpReqData, nUserID, &response, lpContext, lpRequest, tTaskInfo](DBConnectEntry* entry){
        if (TRUE != entry->SelectDB(WXTASK_REDIS_SELECT_INDEX)) {
            return FALSE;
        }
        //////////////////////////////////////////////////////////////////////////任务状态校验;
        int nGroupID = lpReqData->nGroupID;
        int nSubID = lpReqData->nSubID;
        int nResult = 0;
        int nRepeated = lpRequest->head.nRepeated;
        UINT nResponse = 0;
        {
            TASKDATA tTaskData;
            memset(&tTaskData, 0, sizeof(tTaskData));
            int nTaskState = Redis_QueryWxTaskDataByTaskID(entry, nCurDate, nUserID, nGroupID, nSubID, &tTaskData);
            if (1 == nTaskState && WXTASKDATA_FLAG_CANGET_REWARD < tTaskData.nFlag)
            {
                response.head.nSubReq = UR_OPERATE_FAILED;
                response.head.nValue = WXTASK_AWARD_WRONG_ALREADY_AWARD;
                imSendOpeReqOnlyCxt(lpContext, nRepeated, lpRequest->pDataPtr, response);
                return FALSE;
            }
            //////////////////////////////////////////////////////////////////////////查询任务信息;
        }
        if (0 >= tTaskInfo.nActive)
        {
            response.head.nSubReq = UR_OPERATE_FAILED;
            response.head.nValue = WXTASK_AWARD_WRONG_NOT_ACTIVE;
            imSendOpeReqOnlyCxt(lpContext, nRepeated, lpRequest->pDataPtr, response);
            return FALSE;
        }

        //////////////////////////////////////////////////////////////////////////生成任务条件;
        int nStartPos = 0;
        TASKVALUE tTaskValue;

        std::vector<TASKVALUE> stCondition;
        memset(&tTaskValue, 0, sizeof(tTaskValue));
        for (int m = 0; m < tTaskInfo.vCondition.size(); m++)
        {
            tTaskValue.nType = tTaskInfo.vCondition[m]["ConType"].asInt();
            tTaskValue.nValue = tTaskInfo.vCondition[m]["ConValue"].asInt();
            stCondition.push_back(tTaskValue);
            memset(&tTaskValue, 0, sizeof(tTaskValue));
        }
        if (0 == stCondition.size())
        {
            response.head.nSubReq = UR_OPERATE_FAILED;
            response.head.nValue = WXTASK_AWARD_WRONG_CONDITION;
            imSendOpeReqOnlyCxt(lpContext, nRepeated, lpRequest->pDataPtr, response);
            return FALSE;
        }

        //////////////////////////////////////////////////////////////////////////计算任务进度;
        TASKPARAM tTaskParam;
        memset(&tTaskParam, 0, sizeof(tTaskParam));
        nResult = Redis_QueryWxTaskParam(entry, lpReqData->nDate, nUserID, tTaskParam.nParam);
        if (0 >= nResult)
        {
            response.head.nSubReq = nResponse;
            imSendOpeReqOnlyCxt(lpContext, nRepeated, lpRequest->pDataPtr, response);
            return FALSE;
        }

        BOOL bFinished = TRUE;
        for (int i = 0; i < stCondition.size(); i++)
        {
            int nCount = 0;
            if (WXTASK_CONDITION_COM_GAME_COUNT == stCondition[i].nType)
            {
                nCount = tTaskParam.nParam[WXTASK_GAME_RESULT_WIN]
                    + tTaskParam.nParam[WXTASK_GAME_RESULT_LOSE]
                    + tTaskParam.nParam[WXTASK_GAME_RESULT_DRAW];
            }
            else
            {
                nCount = tTaskParam.nParam[stCondition[i].nType];
            }
            if (nCount < stCondition[i].nValue)
            {
                bFinished = FALSE;
                break;
            }
        }
        if (!bFinished)
        {
            response.head.nSubReq = UR_OPERATE_FAILED;
            response.head.nValue = WXTASK_AWARD_WRONG_NOT_FINISHED;
            imSendOpeReqOnlyCxt(lpContext, nRepeated, lpRequest->pDataPtr, response);
            return FALSE;
        }

        //////////////////////////////////////////////////////////////////////////生成任务奖励;
        nStartPos = 0;
        int nRewardType = tTaskInfo.vReward[0]["RewardType"].asInt();
        int nRewardNum = tTaskInfo.vReward[0]["RewardValueMin"].asInt();
        if (0 >= nRewardType || 0 >= nRewardNum)
        {
            response.head.nSubReq = UR_OPERATE_FAILED;
            response.head.nValue = WXTASK_AWARD_WRONG_REWARD;
            imSendOpeReqOnlyCxt(lpContext, nRepeated, lpRequest->pDataPtr, response);
            return FALSE;
        }

        //////////////////////////////////////////////////////////////////////////

        // ope succeed
        response.head.nSubReq = UR_FETCH_SUCCEEDED;

        TASKRESULT taskResult;
        memset(&taskResult, 0, sizeof(taskResult));
        if (0 == tTaskInfo.nNextID)
        {
            taskResult.nTaskID = nSubID;
            taskResult.nFlag = WXTASKDATA_FLAG_FINISHED;
        }
        else
        {
            taskResult.nTaskID = tTaskInfo.nNextID;
            taskResult.nFlag = WXTASKDATA_FLAG_DOING;
        }
        taskResult.nUserID = nUserID;
        taskResult.nDate = lpReqData->nDate;
        taskResult.nGroupID = nGroupID;
        taskResult.nRewardType = nRewardType;
        taskResult.nRewardNum = nRewardNum;
        memcpy(taskResult.szWebID, tTaskInfo.szWebID, sizeof(taskResult.szWebID));

        //KPI:客户端数据上报
        if ((lpRequest->nDataLen - nRepeated * sizeof(CONTEXT_HEAD)) == sizeof(*lpReqData)) {
            UwlLogFile("yml kpi kpiClientData wx");
            memcpy(&taskResult.kpiClientData, &(lpReqData->kpiClientData), sizeof(taskResult.kpiClientData));
        }
        //设置已经领取状态;
        Redis_UpdateWxTaskData(entry, nCurDate, nUserID, nGroupID, taskResult.nTaskID, taskResult.nFlag);

        int nLen = nRepeated*sizeof(CONTEXT_HEAD) + sizeof(taskResult);
        PBYTE pData = NULL;
        pData = new BYTE[nLen];
        memset(pData, 0, nLen);

        memcpy(pData, lpRequest->pDataPtr, nRepeated*sizeof(CONTEXT_HEAD));
        memcpy(pData + nRepeated*sizeof(CONTEXT_HEAD), &taskResult, sizeof(taskResult));
        response.pDataPtr = pData;
        response.nDataLen = nLen;

        imSendOpeRequest(lpContext, response);
        UwlClearRequest(&response);
        return TRUE;
    }).get();
    return TRUE;
}

// load config
void WxTaskModule::loadWxTaskConfig()
{
    m_nFreshTime = 0;
    imGetIniInt(_T("WxTask"), _T("FreshTime"), m_nFreshTime);
    if (m_nFreshTime < 0 || m_nFreshTime > 600) // 00:00 ~ 06:00
        m_nFreshTime = 0;
    m_nRetainDaysOfParam = 0;
	imGetIniInt(_T("WxTask"), _T("ParamTableRetain"), m_nRetainDaysOfParam);
    if (m_nRetainDaysOfParam < 7)
        m_nRetainDaysOfParam = 7;
    m_nRetainDaysOfData = 0;
	imGetIniInt(_T("WxTask"), _T("DataTableRetain"), m_nRetainDaysOfData);
    if (m_nRetainDaysOfData < 7)
        m_nRetainDaysOfData = 7;
}

int WxTaskModule::Redis_UpdateWxTaskParam(DBConnectEntry* entry, int nDate, int nUserID, int nType, int nValue)
{
    CString strCommand;
    CString strValue;
    strCommand.Format("HINCRBY %s:%d %d_%d %d", DAILY_WXTASK_PARAM_REDIS_KEY, nDate, nUserID, nType, nValue);
    strValue = entry->RedisCommand_pach((LPCTSTR)strCommand);
    int nResultValue = atoi(strValue);
    return nResultValue;
}

// db begin
// Update Current_Win_Streak(nType1) And Maximum_Win_Streak(nType2) When Win
int WxTaskModule::Redis_UpdateWxTaskParamWin(DBConnectEntry* entry, int nDate, int nUserID, int nType1, int nValue, int nType2)
{
    int winValue = Redis_UpdateWxTaskParam(entry, nDate, nUserID, nType1, nValue);
    CString strCommand;
    CString strValue;
    strCommand.Format("HGET %s:%d %d_%d", DAILY_WXTASK_PARAM_REDIS_KEY, nDate, nUserID, nType2);
    strValue = entry->RedisCommand_pach((LPCTSTR)strCommand);
    int maxWinValue = atoi(strValue);
    if (maxWinValue < winValue)
    {
        strCommand.Format("HSET %s:%d %d_%d %d", DAILY_WXTASK_PARAM_REDIS_KEY, nDate, nUserID, nType2, winValue);
		entry->RedisCommand_pach((LPCTSTR)strCommand);
    }

    return 1;
}

// Update Current_Win_Streak(nType) When Lose
int WxTaskModule::Redis_UpdateWxTaskParamLose(DBConnectEntry* entry,int nDate, int nUserID, int nType, int nValue)
{
    return Redis_UpdateWxTaskParam(entry, nDate, nUserID, nType, nValue);
}

int WxTaskModule::Redis_QueryWxTaskParam(DBConnectEntry* entry, int nDate, int nUserID, int nParam[])
{
    CString strCommand;
    CString strValue;

    for (int i = 0; i < WXTASK_PARAM_TOTAL - 1; i++)
    {
        strCommand.Format("HGET %s:%d %d_%d", DAILY_WXTASK_PARAM_REDIS_KEY, nDate, nUserID, i + 1);
		strValue = entry->RedisCommand_pach((LPCTSTR)strCommand);
        nParam[i + 1] = atoi(strValue);
    }
    return 1;
}


int WxTaskModule::Redis_UpdateWxTaskData(DBConnectEntry* entry, int nDate, int nUserID, int nGroupID, int nSubID, int nFlag)
{
    CString strCommand;
    CString strValue;
    strCommand.Format("HSET %s%d:%d %d %d_%d", DAILY_WXTASK_DATA_REDIS_KEY, nDate, nUserID, nGroupID, nSubID, nFlag);
	entry->RedisCommand_pach((LPCTSTR)strCommand);
    return 1;
}

int WxTaskModule::Redis_QueryWxTaskData(DBConnectEntry* entry, int nDate, int nUserID, int& nNum, TASKDATA taskData[])
{
    CString strCommand;
    BOOL bValue;
    strCommand.Format("HGETALL %s%d:%d ", DAILY_WXTASK_DATA_REDIS_KEY, nDate, nUserID);
    std::list<CString> data;
    bValue = entry->RedisCommandEx(data, (LPCTSTR)strCommand);
    if (!bValue)
    {
        return 0;
    }

    CString groupValue;
    nNum = 0;
    std::list<CString>::iterator iter = data.begin();
    for (int i = 0; i < data.size() / 2; i++)
    {
        taskData[nNum].nGroupID = atoi(*iter);
        iter++;
        groupValue = *iter;
        iter++;
        int userIndex = groupValue.Find("_");
        taskData[nNum].nSubID = atoi(groupValue.Left(userIndex));
        taskData[nNum].nFlag = atoi(groupValue.Right(groupValue.GetLength() - userIndex - 1));
        nNum++;
    }

    return 1;
}

int WxTaskModule::Redis_QueryWxTaskDataByTaskID(DBConnectEntry* entry, int nDate, int nUserID, int nGroupID, int nSubID, LPTASKDATA pTaskData)
{
    CString strCommand;
    CString strValue;
    strCommand.Format("HGET %s%d:%d %d ", DAILY_WXTASK_DATA_REDIS_KEY, nDate, nUserID, nGroupID);
	strValue = entry->RedisCommand_pach((LPCTSTR)strCommand);

    pTaskData->nGroupID = nGroupID;
    int userIndex = strValue.Find("_");
    pTaskData->nSubID = atoi(strValue.Left(userIndex));
    pTaskData->nFlag = atoi(strValue.Right(strValue.GetLength() - userIndex - 1));;

    return 1;
}

void WxTaskModule::onFreshTimer()
{
    // 一分钟刷新一次
    auto pre = m_tTime;
    m_tTime = CTime::GetCurrentTime();

    if (12 == m_tTime.GetHour() && 0 == m_tTime.GetMinute())
    {// everyday 12:00, read config
        loadWxTaskConfig();
        std::stringstream dbkey;
        dbkey << typeid(*this).name() << "_" << "DeleteLastWxTaskTable";
        imDBOpera(dbkey.str(), [this](DBConnectEntry* entry){
            return OnDeleteLastWxTaskTable(entry);
        }).get();
    }

    if (m_nFreshTime / 100 == m_tTime.GetHour() && m_nFreshTime % 100 == m_tTime.GetMinute())
    {// everyday xx:xx, reset task table
        m_nCurrentDate = GetDateTime();
        clearTableCache();
    }

    if (m_tTime.GetHour() != pre.GetHour())
    {
        ReadWxTaskJsonConfig(); //每小时刷新
    }
}

void WxTaskModule::clearTableCache()
{

}

void WxTaskModule::ReadWxTaskJsonConfig()
{
    Json::Reader reader;
    Json::Value root;
    std::ifstream is;
    std::string	m_strWorkDir = GetExecDir();
    std::string strPath = m_strWorkDir + WXTASK_JSON_FILE;
    const char* filename = strPath.c_str();
    is.open(filename, std::ios::binary);
    if (reader.parse(is, root))
    {
        m_vTaskJsonRoot = root;
    }
    else
    {
        UwlTrace(_T("CWxTaskModule ReadWxTaskJsonConfig Fail"));
        UwlLogFile(_T("CWxTaskModule ReadWxTaskJsonConfig Fail"));
    }
    is.close();
}

std::string WxTaskModule::toKey(int userid)
{
    std::stringstream ss;
    ss << typeid(*this).name() << "_" << userid;

    return ss.str();
}

int WxTaskModule::GetCurTime()
{
    return async<int>([this](){
        return m_nCurrentDate;
    }).get();
}
std::string WxTaskModule::GetTaskJsonString()
{
    return async<std::string>([this](){
        return m_vTaskJsonRoot.toStyledString();
    }).get();
}

BOOL WxTaskModule::GetWxTaskInfo(int nGroupID, int nSubID, LPTASKINFOJSON pTaskInfo)
{
    return async<BOOL>([this, nGroupID, nSubID, &pTaskInfo](){
        if (!m_vTaskJsonRoot.isObject()) return FALSE;

        Json::Value taskRoot = m_vTaskJsonRoot["Task"];
        if (!taskRoot.isArray()) return FALSE;
        for (int i = 0; i < taskRoot.size(); i++)
        {
            if (taskRoot[i]["GroupID"].asInt() == nGroupID)
            {
                Json::Value tasklist = taskRoot[i]["TaskList"];
                if (!tasklist.isArray()) return FALSE;
                for (int j = 0; j < tasklist.size(); j++)
                {
                    if (tasklist[j]["ID"] == nSubID)
                    {
                        if (!tasklist[j]["Condition"].isArray()) return FALSE;
                        if (!tasklist[j]["Reward"].isArray()) return FALSE;
                        pTaskInfo->nGroupID = nGroupID;
                        pTaskInfo->nSubID = nSubID;
                        pTaskInfo->nActive = 1;
                        pTaskInfo->nType = tasklist[j]["Type"].asInt();
                        pTaskInfo->nNextID = tasklist[j]["NextID"].asInt();
                        memcpy(pTaskInfo->szWebID, tasklist[j]["WebID"].asString().c_str(), sizeof(pTaskInfo->szWebID));
                        pTaskInfo->vCondition = tasklist[j]["Condition"];
                        pTaskInfo->vReward = tasklist[j]["Reward"];
                        return TRUE;
                    }
                }
            }
        }
        return FALSE;
    }).get();
}