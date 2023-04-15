#include "stdafx.h"
#include "TaskModule.h"
#include <fstream>
#include "hiredis.h"
#define  TASK_JSON_FILE  "TaskConfig.json"
#define  CLASSIC_TASK_JSON_FILE  "TaskConfig_Classic.json"
#define TASK_REDIS_SELECT_INDEX 4
#define DAILY_TASK_PARAM_REDIS_KEY "dailyTaskParam"
#define DAILY_TASK_DATA_REDIS_KEY "dailyTaskData"

typedef struct _tagLTaskDataTime
{
    int nTaskID;
    int nTaskTime;
}LTaskDataTime, *LPTaskDataTime;

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

/*json配置相关*/
/* 命令行(包含所属路径)最大长度*/
static const int SC_OS_PROCESS_CMD_BUF_LEN = 1024;
static char SC_OS_SEPARATE = '\\';

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

void TaskModule::OnServerStart(BOOL &ret, TcyMsgCenter * msgCenter)
{
    if (ret) {
        AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_TASK_CHANGE_PARAM, OnChangeTaskParam);
        AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_TASK_CHANGE_DATA, OnChangeTaskData);
        AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_TASK_QUERY_PARAM, OnQueryTaskParam);
        AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_TASK_QUERY_DATA, OnQueryTaskData);
        AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_TASK_AWARD_PRIZE, OnAwardClassicTaskPrizeForJson);
        AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_TASK_QUERY_LTASK_DATA, OnReqLTaskData);
        AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_TASK_QUERY_LTASK_PARAM, OnReqLTaskParam);
        AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_TASK_CHANGE_LTASK_DATA, OnReqLTaskChangeData);
        AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_TASK_CHANGE_LTASK_PARAM, OnReqLTaskChangeParam);
        AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_TASK_AWARD_LTASK, OnReqLTaskAwardForJson);
        AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_TASK_GET_DATA_FOR_JSON, OnReqGetTaskConfigData);
        AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_TASK_AWARD_PRIZE_JSON, OnAwardTaskPrizeForJson);
        AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_TASK_AWARD_LTASK_JSON, OnReqLTaskAwardForJson);

        readFromLocalIni();
        m_tTime = CTime::GetCurrentTime();

        // 刷新时间
        if (m_nFreshTime > m_tTime.GetHour() * 100 + m_tTime.GetMinute()) {
            m_nCurTime = GetDateTime(-1);
        }
        else {
            m_nCurTime = GetDateTime();
        }

        readFromLocalJson();

        m_timerFresh = evp().loopTimer([this](){this->onFreshTimer(); }, std::chrono::minutes(1), strand());
    }
}

void TaskModule::OnShutDown()
{
    m_timerFresh = nullptr;
}

BOOL TaskModule::OnChangeTaskParam(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
    REQUEST response;
    memset(&response, 0, sizeof(response));
    response.head.nRequest = lpRequest->head.nRequest;
    response.head.nSubReq = UR_OPERATE_FAILED;
    response.head.nRepeated = 1;
    UINT nResponse = 0;

    int nRepeated = lpRequest->head.nRepeated;
    LPTASKPARAMCHANGE lpReqData = (LPTASKPARAMCHANGE)(PBYTE(lpRequest->pDataPtr) + nRepeated * sizeof(CONTEXT_HEAD));
    int nUserID = lpReqData->nUserID;

    if (1 == m_nRecordOnlyPhone && !lpReqData->bIsHandPhone)
    {
        return FALSE;
    }
    auto dbkey = toKey(nUserID);
    auto curTime = getCurTime();
    TASKPARAMINFO taskParamInfo;
    memset(&taskParamInfo, 0, sizeof(taskParamInfo));
    taskParamInfo.nUserID = nUserID;
    taskParamInfo.nDate = curTime;
    std::future<int> f;
	int r = imDBOpera(dbkey, [curTime, nUserID, lpReqData, &taskParamInfo, this](DBConnectEntry* entry){
        if (TRUE != entry->SelectDB(TASK_REDIS_SELECT_INDEX)) {
            return FALSE;
        }
        Redis_UpdateTaskParam(entry, curTime, nUserID, lpReqData->nType, lpReqData->nValue);

        if (TASK_GAME_RESULT_WIN == lpReqData->nType) // bout win
        {
            Redis_UpdateTaskParamWin(entry, curTime, nUserID, TASK_GAME_CUR_WIN_STREAK, 1, TASK_GAME_MAX_WIN_STREAK);
        }
        else if (TASK_GAME_RESULT_LOSE == lpReqData->nType || TASK_GAME_RESULT_DRAW == lpReqData->nType) // bout not win
        {
            Redis_UpdateTaskParamLose(entry, curTime, nUserID, TASK_GAME_CUR_WIN_STREAK, 0);
        }
        Redis_QueryTaskParam(entry, curTime, nUserID, taskParamInfo.nParam);
        return TRUE;
    }).get();
    if (!r) {
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

BOOL TaskModule::OnChangeTaskData(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
    REQUEST response;
    memset(&response, 0, sizeof(response));
    response.head.nRequest = lpRequest->head.nRequest;
    response.head.nSubReq = UR_OPERATE_FAILED;
    response.head.nRepeated = 1;

    int  nResult = 0;
    UINT nResponse = 0;

    int nRepeated = lpRequest->head.nRepeated;
    LPTASKDATACHANGE lpReqData = (LPTASKDATACHANGE)(PBYTE(lpRequest->pDataPtr) + nRepeated * sizeof(CONTEXT_HEAD));
    int nUserID = lpReqData->nUserID;
    auto dbkey = toKey(nUserID);
    std::future<int> f;
    imDBOpera(dbkey, [lpReqData, nUserID, this](DBConnectEntry* entry){
        if (TRUE != entry->SelectDB(TASK_REDIS_SELECT_INDEX)) {
            return FALSE;
        }
        Redis_UpdateTaskData(entry, lpReqData->nDate, nUserID, lpReqData->nGroupID, lpReqData->nSubID, lpReqData->nFlag);
        return TRUE;
    }).get();
    UwlClearRequest(&response);
    return TRUE;
}

BOOL TaskModule::OnQueryTaskParam(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
    REQUEST response;
    memset(&response, 0, sizeof(response));
    response.head.nRequest = lpRequest->head.nRequest;
    response.head.nSubReq = UR_OPERATE_FAILED;
    response.head.nRepeated = 1;

    int nResult = 0;
    UINT nResponse = 0;

    int nRepeated = lpRequest->head.nRepeated;
    LPTASKQUERY lpReqData = LPTASKQUERY(PBYTE(lpRequest->pDataPtr) + nRepeated * sizeof(CONTEXT_HEAD));
    int nUserID = lpReqData->nUserID;
    int nCurTime = getCurTime();
    lpReqData->nDate = nCurTime; // 以该时刻为准;

    if (nUserID <= 0){
        UwlLogFile("OnQueryTaskParam userid is invalid.");
        imSendOpeReqOnlyCxt(lpContext, nRepeated, lpRequest->pDataPtr, response);
    }

    //////////////////////////////////////////////////////////////////////////
    TASKPARAMINFO taskParamInfo;
    memset(&taskParamInfo, 0, sizeof(taskParamInfo));
    taskParamInfo.nUserID = nUserID;
    taskParamInfo.nDate = lpReqData->nDate;
    auto dbkey = toKey(nUserID);
    std::future<int> f;
	int r = imDBOpera(dbkey, [nCurTime, nUserID, &taskParamInfo, this](DBConnectEntry* entry){
        if (TRUE != entry->SelectDB(TASK_REDIS_SELECT_INDEX)) {
            return FALSE;
        }
        Redis_QueryTaskParam(entry, nCurTime, nUserID, taskParamInfo.nParam);
        return TRUE;
    }).get();
    if (!r) {
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

BOOL TaskModule::OnQueryTaskData(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
    REQUEST response;
    memset(&response, 0, sizeof(response));
    response.head.nRequest = lpRequest->head.nRequest;
    response.head.nSubReq = UR_OPERATE_FAILED;
    response.head.nRepeated = 1;

    int nResult = 0;
    UINT nResponse = 0;

    int nRepeated = lpRequest->head.nRepeated;
    LPTASKQUERY lpReqData = LPTASKQUERY(PBYTE(lpRequest->pDataPtr) + nRepeated * sizeof(CONTEXT_HEAD));
    int nUserID = lpReqData->nUserID;
    int nCurTime = getCurTime();
    lpReqData->nDate = nCurTime; // 以该时刻为准

    if (nUserID <= 0){
        UwlLogFile("OnQueryTaskData userid is invalid.");
        imSendOpeReqOnlyCxt(lpContext, nRepeated, lpRequest->pDataPtr, response);
        return FALSE;
    }

    auto dbkey = toKey(nUserID);
    std::future<int> f;
    TASKDATAINFO taskDataInfo;
    memset(&taskDataInfo, 0, sizeof(taskDataInfo));
    taskDataInfo.nUserID = nUserID;
    taskDataInfo.nDate = lpReqData->nDate;
	int r = imDBOpera(dbkey, [nUserID, nCurTime, &taskDataInfo, this](DBConnectEntry* entry){
        if (TRUE != entry->SelectDB(TASK_REDIS_SELECT_INDEX)) {
            return FALSE;
        }
        Redis_QueryTaskData(entry, nCurTime, nUserID, taskDataInfo.nDataNum, taskDataInfo.tData);
        return TRUE;
    }).get();
    if (!r) {
        return FALSE;
    }
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

BOOL TaskModule::OnReqLTaskData(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
    REQUEST response;
    memset(&response, 0, sizeof(response));
    response.head.nRequest = lpRequest->head.nRequest;
    response.head.nSubReq = UR_OPERATE_FAILED;
    response.head.nRepeated = 1;

    UINT nResponse = 0;

    int nRepeated = lpRequest->head.nRepeated;
    LPTaskDataReq lpTaskReq = LPTaskDataReq(PBYTE(lpRequest->pDataPtr) + nRepeated * sizeof(CONTEXT_HEAD));
    int nUserID = lpTaskReq->nUserID;

    if (nUserID <= 0){
        UwlLogFile("OnQueryTaskData userid is invalid.");
       imSendOpeReqOnlyCxt(lpContext, nRepeated, lpRequest->pDataPtr, response);
       return FALSE;
    }

    LTaskDataRsp taskdata;
    std::vector<LFTaskData> taskrecords;
    auto dbkey = toKey(nUserID);
    std::future<int> f;
	int nResult = imDBOpera(dbkey, [nUserID, &taskrecords, this](DBConnectEntry* entry){
        return DB_QueryLTaskData1(entry, nUserID, taskrecords);
    }).get();
    if (0 != nResult)
    {
        response.head.nSubReq = UR_OBJECT_NOT_EXIST;
        imSendOpeReqOnlyCxt(lpContext, nRepeated, lpRequest->pDataPtr, response);
        return FALSE;
    }
    taskdata.nCount = taskrecords.size();

    int nLen = nRepeated*sizeof(CONTEXT_HEAD) + sizeof(taskdata) + sizeof(LFTaskData)*taskdata.nCount;
    PBYTE pData = NULL;
    pData = new BYTE[nLen];
    memset(pData, 0, nLen);

    memcpy(pData, lpRequest->pDataPtr, nRepeated*sizeof(CONTEXT_HEAD));
    memcpy(pData + nRepeated*sizeof(CONTEXT_HEAD), &taskdata, sizeof(taskdata));
    if (taskrecords.size() > 0)
    {
        memcpy(pData + nRepeated*sizeof(CONTEXT_HEAD) + sizeof(taskdata), &taskrecords[0], taskdata.nCount*sizeof(LFTaskData));
    }
    response.head.nSubReq = UR_FETCH_SUCCEEDED;
    response.pDataPtr = pData;
    response.nDataLen = nLen;

    imSendOpeRequest(lpContext, response);
    UwlClearRequest(&response);
    return TRUE;
}

BOOL TaskModule::OnReqLTaskParam(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
    REQUEST response;
    memset(&response, 0, sizeof(response));
    response.head.nRequest = lpRequest->head.nRequest;
    response.head.nSubReq = UR_OPERATE_FAILED;
    response.head.nRepeated = 1;

    UINT nResponse = 0;

    int nRepeated = lpRequest->head.nRepeated;
    LPTaskParamReq lpTaskReq = LPTaskParamReq(PBYTE(lpRequest->pDataPtr) + nRepeated * sizeof(CONTEXT_HEAD));
    int nUserID = lpTaskReq->nUserID;

    if (nUserID <= 0){
        UwlLogFile("OnQueryTaskData userid is invalid.");
        imSendOpeReqOnlyCxt(lpContext, nRepeated, lpRequest->pDataPtr, response);
        return FALSE;
    }

    std::vector<LTaskParam> taskParams;
    auto dbkey = toKey(nUserID);
    std::future<int> f;
	int nResult = imDBOpera(dbkey, [nUserID, &taskParams, this](DBConnectEntry* entry){
        return DB_QueryLTaskParam1(entry, nUserID, taskParams);
    }).get();
    if (0 != nResult)
    {
        response.head.nSubReq = UR_OBJECT_NOT_EXIST;
        imSendOpeReqOnlyCxt(lpContext, nRepeated, lpRequest->pDataPtr, response);
        return FALSE;
    }
    LTaskParamRsp taskdata;
    taskdata.nCount = taskParams.size();

    int nLen = nRepeated*sizeof(CONTEXT_HEAD) + sizeof(taskdata) + sizeof(LTaskParam)*taskdata.nCount;
    PBYTE pData = NULL;
    pData = new BYTE[nLen];
    memset(pData, 0, nLen);

    memcpy(pData, lpRequest->pDataPtr, nRepeated*sizeof(CONTEXT_HEAD));
    memcpy(pData + nRepeated*sizeof(CONTEXT_HEAD), &taskdata, sizeof(taskdata));
    if (taskParams.size() > 0)
    {
        memcpy(pData + nRepeated*sizeof(CONTEXT_HEAD) + sizeof(taskdata), &taskParams[0], taskdata.nCount*sizeof(LTaskParam));
    }
    response.head.nSubReq = UR_FETCH_SUCCEEDED;
    response.pDataPtr = pData;
    response.nDataLen = nLen;

    imSendOpeRequest(lpContext, response);
    UwlClearRequest(&response);
    return TRUE;
}

BOOL TaskModule::OnReqLTaskChangeData(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
    REQUEST response;
    memset(&response, 0, sizeof(response));
    response.head.nRequest = lpRequest->head.nRequest;
    response.head.nSubReq = UR_OPERATE_FAILED;
    response.head.nRepeated = 1;

    UINT nResponse = 0;

    int nRepeated = lpRequest->head.nRepeated;
    LPLTaskData lpTaskReq = LPLTaskData(PBYTE(lpRequest->pDataPtr) + nRepeated * sizeof(CONTEXT_HEAD));
    int nUserID = lpTaskReq->userid;

    if (nUserID <= 0){
        UwlLogFile("OnQueryTaskData userid is invalid.");
        imSendOpeReqOnlyCxt(lpContext, nRepeated, lpRequest->pDataPtr, response);
        return FALSE;
    }
    auto dbkey = toKey(nUserID);
    std::future<int> f;
	int nResult = imDBOpera(dbkey, [nUserID, &lpTaskReq, this](DBConnectEntry* entry){
        return DB_LTaskUpdateLTaskDataEx(entry, *lpTaskReq);
    }).get();
    if (0 != nResult)
    {
        response.head.nSubReq = UR_OBJECT_NOT_EXIST;
        imSendOpeReqOnlyCxt(lpContext, nRepeated, lpRequest->pDataPtr, response);
        return FALSE;
    }
    UwlClearRequest(&response);
    return TRUE;
}

BOOL TaskModule::OnReqLTaskChangeParam(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
    REQUEST response;
    memset(&response, 0, sizeof(response));
    response.head.nRequest = lpRequest->head.nRequest;
    response.head.nSubReq = UR_OPERATE_FAILED;
    response.head.nRepeated = 1;
    UINT nResponse = 0;

    int nRepeated = lpRequest->head.nRepeated;
    LPLTaskParam lpTaskReq = LPLTaskParam(PBYTE(lpRequest->pDataPtr) + nRepeated * sizeof(CONTEXT_HEAD));
    int nUserID = lpTaskReq->nuserid;

    if (nUserID <= 0){
        UwlLogFile("OnQueryTaskData userid is invalid.");
        imSendOpeReqOnlyCxt(lpContext, nRepeated, lpRequest->pDataPtr, response);
        return FALSE;
    }

    auto dbkey = toKey(nUserID);
    std::future<int> f;
    LTaskParamReq taskParamRep;
    taskParamRep.nUserID = nUserID;
    std::vector<LTaskParam> taskParams;
	int nResult = imDBOpera(dbkey, [nUserID, &lpTaskReq, &taskParams, this](DBConnectEntry* entry){
        int nRet = DB_LTaskUpdateLTaskParamEx(entry, *lpTaskReq);
        if (0 != nRet)
        {
            return nRet;
        }
        //////////////////////////////////////////////////////////////////////////
        return DB_QueryLTaskParam1(entry, nUserID, taskParams);
    }).get();

    if (0 != nResult)
    {
        response.head.nSubReq = UR_OBJECT_NOT_EXIST;
        imSendOpeReqOnlyCxt(lpContext, nRepeated, lpRequest->pDataPtr, response);
        return FALSE;
    }

    LTaskParamRsp taskdata;
    taskdata.nCount = taskParams.size();
    int nLen = nRepeated*sizeof(CONTEXT_HEAD) + sizeof(taskdata) + sizeof(LTaskParam)*taskdata.nCount;
    PBYTE pData = NULL;
    pData = new BYTE[nLen];
    memset(pData, 0, nLen);

    memcpy(pData, lpRequest->pDataPtr, nRepeated*sizeof(CONTEXT_HEAD));
    memcpy(pData + nRepeated*sizeof(CONTEXT_HEAD), &taskdata, sizeof(taskdata));
    if (taskParams.size() > 0)
    {
        memcpy(pData + nRepeated*sizeof(CONTEXT_HEAD) + sizeof(taskdata), &taskParams[0], taskdata.nCount*sizeof(LTaskParam));
    }
    response.head.nSubReq = UR_FETCH_SUCCEEDED;
    response.pDataPtr = pData;
    response.nDataLen = nLen;

    imSendOpeRequest(lpContext, response);
    UwlClearRequest(&response);
    return TRUE;
}

BOOL TaskModule::OnReqGetTaskConfigData(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
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

BOOL TaskModule::OnAwardTaskPrizeForJson(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
    REQUEST response;
    memset(&response, 0, sizeof(response));
    response.head.nRequest = GR_TASK_AWARD_PRIZE;//lpRequest->head.nRequest;
    response.head.nSubReq = UR_OPERATE_FAILED;
    response.head.nRepeated = 1;
    
    int nRepeated = lpRequest->head.nRepeated;
    LPTASKAWARD lpReqData = LPTASKAWARD(PBYTE(lpRequest->pDataPtr) + nRepeated * sizeof(CONTEXT_HEAD));
    int nUserID = lpReqData->nUserID;
    int nGroupID = lpReqData->nGroupID;
    int nSubID = lpReqData->nSubID;
    int nCurTime = getCurTime();
    lpReqData->nDate = nCurTime; // 以该时刻为准;

    if (nUserID <= 0){
        UwlLogFile("OnQueryTaskData userid is invalid.");
        imSendOpeReqOnlyCxt(lpContext, nRepeated, lpRequest->pDataPtr, response);
        return FALSE;
    }
    TASKINFOJSON tTaskInfo;
    memset(&tTaskInfo, 0, sizeof(tTaskInfo));
    if (0 >= GetTaskInfo(nGroupID, nSubID, &tTaskInfo))
    {
        response.head.nSubReq = 0;
        imSendOpeReqOnlyCxt(lpContext, nRepeated, lpRequest->pDataPtr, response);
        return FALSE;
    }
    auto dbkey = toKey(nUserID);

    std::future<int> f;
    imDBOpera(dbkey, [this, nUserID, &response, lpContext, nCurTime, lpRequest, &lpReqData, tTaskInfo](DBConnectEntry* entry){
        if (TRUE != entry->SelectDB(TASK_REDIS_SELECT_INDEX)) {
            return FALSE;
        }
        int nRepeated = lpRequest->head.nRepeated;
        int nGroupID = lpReqData->nGroupID;
        int nSubID = lpReqData->nSubID;
        int nResult = 0;
        UINT nResponse = 0;
        //////////////////////////////////////////////////////////////////////////任务状态校验;
        {
            
            TASKDATA tTaskData;
            memset(&tTaskData, 0, sizeof(tTaskData));
            int nTaskState = Redis_QueryTaskDataByTaskID(entry, nCurTime, nUserID, nGroupID, nSubID, &tTaskData);
            if (1 == nTaskState && TASKDATA_FLAG_CANGET_REWARD < tTaskData.nFlag)
            {
                response.head.nSubReq = UR_OPERATE_FAILED;
                response.head.nValue = TASK_AWARD_WRONG_ALREADY_AWARD;
                imSendOpeReqOnlyCxt(lpContext, nRepeated, lpRequest->pDataPtr, response);
                return FALSE;
            }
        }
        //////////////////////////////////////////////////////////////////////////查询任务信息;
        if (0 >= tTaskInfo.nActive)
        {
            response.head.nSubReq = UR_OPERATE_FAILED;
            response.head.nValue = TASK_AWARD_WRONG_NOT_ACTIVE;
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
            response.head.nValue = TASK_AWARD_WRONG_CONDITION;
            imSendOpeReqOnlyCxt(lpContext, nRepeated, lpRequest->pDataPtr, response);
            return FALSE;
        }

        //////////////////////////////////////////////////////////////////////////计算任务进度;
        TASKPARAM tTaskParam;
        memset(&tTaskParam, 0, sizeof(tTaskParam));
        nResult = Redis_QueryTaskParam(entry, lpReqData->nDate, nUserID, tTaskParam.nParam);
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
            if (TASK_CONDITION_COM_GAME_COUNT == stCondition[i].nType)
            {
                nCount = tTaskParam.nParam[TASK_GAME_RESULT_WIN - 1]
                    + tTaskParam.nParam[TASK_GAME_RESULT_LOSE - 1]
                    + tTaskParam.nParam[TASK_GAME_RESULT_DRAW - 1];
            }
            else
            {
                nCount = tTaskParam.nParam[stCondition[i].nType - 1];
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
            response.head.nValue = TASK_AWARD_WRONG_NOT_FINISHED;
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
            response.head.nValue = TASK_AWARD_WRONG_REWARD;
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
            taskResult.nFlag = TASKDATA_FLAG_FINISHED;
        }
        else
        {
            taskResult.nTaskID = tTaskInfo.nNextID;
            taskResult.nFlag = TASKDATA_FLAG_DOING;
        }
        taskResult.nUserID = nUserID;
        taskResult.nDate = lpReqData->nDate;
        taskResult.nGroupID = nGroupID;
        taskResult.nRewardType = nRewardType;
        taskResult.nRewardNum = nRewardNum;
        memcpy(taskResult.szWebID, tTaskInfo.szWebID, sizeof(taskResult.szWebID));

        //设置已经领取状态;
        Redis_UpdateTaskData(entry, nCurTime, nUserID, nGroupID, taskResult.nTaskID, taskResult.nFlag);
        if ((lpRequest->nDataLen - nRepeated * sizeof(CONTEXT_HEAD)) == sizeof(*lpReqData)) {
            //KPI:客户端数据上报
            UwlLogFile("yml kpi kpiClientData");
            memcpy(&taskResult.kpiClientData, &(lpReqData->kpiClientData), sizeof(taskResult.kpiClientData));
        }
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

BOOL TaskModule::OnReqLTaskAwardForJson(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
    REQUEST response;
    memset(&response, 0, sizeof(response));
    response.head.nRequest = GR_TASK_AWARD_LTASK;//lpRequest->head.nRequest;
    response.head.nSubReq = UR_OPERATE_FAILED;
    response.head.nRepeated = 1;
    UINT nResponse = 0;

    int nRepeated = lpRequest->head.nRepeated;
    auto lpTaskReq = RequestDataParse<LTaskAward>(lpRequest);
    if (nullptr == lpTaskReq) {
        UwlLogFile("OnReqLTaskAwardForJson request is invalid.");
        imSendOpeReqOnlyCxt(lpContext, nRepeated, lpRequest->pDataPtr, response);
        return FALSE;
    }

    int nUserID = lpTaskReq->nUserID;

    if (nUserID <= 0){
        UwlLogFile("OnQueryTaskData userid is invalid.");
        imSendOpeReqOnlyCxt(lpContext, nRepeated, lpRequest->pDataPtr, response);
        return FALSE;
    }
    TaskInfoRecord taskConition = { 0 };
    if (0 >= GetLTaskInfo(lpTaskReq->nTaskID, &taskConition))
    {
        response.head.nSubReq = UR_OBJECT_NOT_EXIST;
        imSendOpeReqOnlyCxt(lpContext, nRepeated, lpRequest->pDataPtr, response);
        return FALSE;
    }
    auto dbkey = toKey(nUserID);

    std::future<int> f;
    imDBOpera(dbkey, [this, nUserID, &response, lpContext, &lpTaskReq, lpRequest, taskConition](DBConnectEntry* entry){
        int nRepeated = lpRequest->head.nRepeated;
        LTaskParam taskParam;
        LFTaskData taskData = { 0 };
        
        int nResult = DB_QueryLTaskParamEx1(entry, lpTaskReq->nUserID, lpTaskReq->nTaskType, taskParam);
        if (0 != nResult)
        {
            response.head.nSubReq = UR_OBJECT_NOT_EXIST;
            imSendOpeReqOnlyCxt(lpContext, nRepeated, lpRequest->pDataPtr, response);
            return FALSE;
        }

        BOOL bRet = FALSE;
        do
        {
            nResult = DB_QueryLTaskDataEx1(entry, nUserID, lpTaskReq->nTaskID, taskData);
            if (0 != nResult)
            {
                response.head.nSubReq = UR_OBJECT_NOT_EXIST;
                imSendOpeReqOnlyCxt(lpContext, nRepeated, lpRequest->pDataPtr, response);
                return FALSE;
            }

            response.head.nValue = TASK_AWARD_WRONG_NOT_FINISHED;
            if (0 == taskConition.conditionCount)
            {
                response.head.nValue = TASK_AWARD_WRONG_REWARD;
                UwlLogFile("0 == taskConition.conditionCount userid<%d>", nUserID);
                break;
            }
            if (TASKDATA_FLAG_FINISHED == taskData.status)
            {
                response.head.nValue = TASK_AWARD_WRONG_ALREADY_AWARD;
                UwlLogFile("taskData.status = TASKDATA_FLAG_FINISHED");
                break;
            }
            if (lpTaskReq->nTaskType != taskConition.conditionType)
            {
                response.head.nValue = TASK_AWARD_WRONG_TASK_NULL;
                UwlLogFile("task type != req type");
                break;
            }
            if (taskParam.countadd < taskConition.conditionCount)
            {
                response.head.nValue = TASK_AWARD_WRONG_NOT_FINISHED;
                UwlLogFile("taskParam.countadd < taskConition.conditionCount");
                break;
            }
            if (time(NULL) - taskData.time <= 2)
            {
                response.head.nValue = TASK_AWARD_WRONG_OPERATE_FAST;
                UwlLogFile("time(NULL) - taskData.time <= 2");
                break;
            }
            LTaskDataTime taskTime;
            taskTime.nTaskID = lpTaskReq->nTaskID;
            taskTime.nTaskTime = ::time(NULL);

            // 缓存等下加
            //std::vector<LFTaskData> taskDatas;
            //if (g_synMapCachOfLTaskData.GetList(nUserID, taskDatas))
            //{
            //    bool isFind = false;
            //    std::vector<LFTaskData>::iterator it = taskDatas.begin();
            //    for (; it != taskDatas.end(); ++it)
            //    {
            //        if (it->taskid == taskTime.nTaskID)
            //        {
            //            it->time = taskTime.nTaskTime;
            //            isFind = true;
            //            break;
            //        }
            //    }

            //    if (!isFind)
            //    {
            //        taskData.userid = nUserID;
            //        taskData.taskid = taskTime.nTaskID;
            //        taskData.time = taskTime.nTaskTime;
            //        //taskDatas.push_back(taskData);
            //        g_synMapCachOfLTaskData.InsertValue(nUserID, taskData);
            //    }
            //}
            //else
            //{
            //    taskData.userid = nUserID;
            //    taskData.taskid = taskTime.nTaskID;
            //    taskData.time = taskTime.nTaskTime;
            //    taskDatas.push_back(taskData);
            //    g_synMapCachOfLTaskData.UpdateValue(nUserID, taskDatas);
            //}
            bRet = TRUE;
        } while (0);
        if (!bRet)
        {
            response.head.nSubReq = UR_OPERATE_FAILED;
            imSendOpeReqOnlyCxt(lpContext, nRepeated, lpRequest->pDataPtr, response);
            return FALSE;
        }

        LTaskResult taskResult;
        taskResult.nUserID = nUserID;
        taskResult.nTaskType = lpTaskReq->nTaskType;
        taskResult.nTaskID = lpTaskReq->nTaskID;
        taskResult.nTaskReward = taskConition.reward;
        taskResult.nTaskRewardType = taskConition.rewardType;
        taskResult.nNextID = taskConition.nextid;
        memcpy(taskResult.szWebID, taskConition.szWebID, sizeof(taskResult.szWebID));
        taskResult.nStatus = TASKDATA_FLAG_FINISHED;
        //KPI:客户端数据上报
        if ((lpRequest->nDataLen - nRepeated * sizeof(CONTEXT_HEAD)) == sizeof(*lpTaskReq)) {
            UwlLogFile("yml kpi kpiClientData 22222");
            memcpy(&taskResult.kpiClientData, &(lpTaskReq->kpiClientData), sizeof(taskResult.kpiClientData));
        }

        int nLen = nRepeated*sizeof(CONTEXT_HEAD) + sizeof(taskResult);
        PBYTE pData = new BYTE[nLen];
        memset(pData, 0, nLen);

        memcpy(pData, lpRequest->pDataPtr, nRepeated*sizeof(CONTEXT_HEAD));
        memcpy(pData + nRepeated*sizeof(CONTEXT_HEAD), &taskResult, sizeof(taskResult));
        response.head.nSubReq = UR_FETCH_SUCCEEDED;
        response.pDataPtr = pData;
        response.nDataLen = nLen;

        imSendOpeRequest(lpContext, response);
        UwlClearRequest(&response);

        //保存任务进度;
        LFTaskData taskDataChange;
        memset(&taskDataChange, 0, sizeof(taskDataChange));
        taskDataChange.userid = nUserID;
        taskDataChange.status = TASKDATA_FLAG_FINISHED;
        taskDataChange.taskid = lpTaskReq->nTaskID;
        ChangeLTaskData(entry, lpContext, lpRequest->head.nRequest, &taskDataChange);
        return TRUE;
    }).get();
    return TRUE;
}

BOOL TaskModule::ChangeLTaskData(DBConnectEntry* entry, LPCONTEXT_HEAD lpContext, UINT nRequest, LPLTaskData lpTaskReq)
{
    int nResult = 0;
    UINT nResponse = 0;

    int nUserID = lpTaskReq->userid;

    if (nUserID <= 0){
        UwlLogFile("ChangeLTaskParam userid is invalid.");
        return FALSE;
    }

    nResult = DB_LTaskUpdateLTaskDataEx(entry, *lpTaskReq);
    if (0 != nResult)
    {
        return FALSE;
    }
    return TRUE;
}

int TaskModule::DB_QueryLTaskDataEx1(DBConnectEntry* entry, int nUserID, int nTaskID, LFTaskData& taskData)
{
    LOG_INFO(_T("*********DB_QueryLTaskDataEx1 begin nUserID:%d"), nUserID);
    int nResult = 0;

    TCHAR szSql[MAX_SQL_LENGTH];
    sprintf_s(szSql, _T("call usp_query_ltask_data_ex(%d,%d)"), nUserID, nTaskID);

    auto r = entry->mysql_excute(szSql, [&taskData, nUserID, nTaskID](sql::ResultSet* res){
        while (res->next()) {
            LFTaskData record = { 0 };
            taskData.taskid = nTaskID;
            taskData.userid = nUserID;
            taskData.status = res->getInt("status");
        }
        return res->rowsCount();
    });

    return r.first;
}

int TaskModule::DB_QueryLTaskParamEx1(DBConnectEntry* entry, int nUserID, int nType, LTaskParam& taskParam)
{
    LOG_INFO(_T("*********DB_QueryLTaskParamEx1 begin nUserID:%d"), nUserID);
    int nResult = 0;

    TCHAR szSql[MAX_SQL_LENGTH];
    sprintf_s(szSql, _T("call usp_query_ltask_param_ex(%d,%d)"), nUserID, nType);
    auto r = entry->mysql_excute(szSql, [&taskParam, nUserID, nType](sql::ResultSet* res){
        while (res->next()) {
            taskParam.countadd = res->getInt("count");
            taskParam.nuserid = nUserID;
            taskParam.type = nType;
        }
        return res->rowsCount();
    });

    return r.first;
}

int TaskModule::DB_QueryLTaskParam1(DBConnectEntry* entry, int nUserID, std::vector<LTaskParam>& taskParams)
{
    LOG_INFO(_T("*********DB_QueryLTaskParam1 begin nUserID:%d"), nUserID);
    int nResult = 0;

    TCHAR szSql[MAX_SQL_LENGTH];
    sprintf_s(szSql, _T("call usp_query_ltask_param(%d)"), nUserID);
    auto r = entry->mysql_excute(szSql, [&taskParams, nUserID](sql::ResultSet* res){
        while (res->next()) {
            LTaskParam record;
            record.countadd = res->getInt("count");
            record.type = res->getInt("type");
            record.nuserid = nUserID;
            taskParams.push_back(record);
        }
        return res->rowsCount();
    });

    return r.first;
}

BOOL TaskModule::OnAwardClassicTaskPrizeForJson(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
    REQUEST response;
    memset(&response, 0, sizeof(response));
    response.head.nRequest = GR_TASK_AWARD_PRIZE;//lpRequest->head.nRequest;
    response.head.nSubReq = UR_OPERATE_FAILED;
    response.head.nRepeated = 1;
    int nRepeated = lpRequest->head.nRepeated;
    LPTASKAWARD lpReqData = LPTASKAWARD(PBYTE(lpRequest->pDataPtr) + nRepeated * sizeof(CONTEXT_HEAD));
    int nUserID = lpReqData->nUserID;
    int nGroupID = lpReqData->nGroupID;
    int nSubID = lpReqData->nSubID;
    int nCurTime = getCurTime();

    //////////////////////////////////////////////////////////////////////////查询任务信息;
    TASKINFOJSON tTaskInfo;
    memset(&tTaskInfo, 0, sizeof(tTaskInfo));
    if (0 >= GetClassicTaskInfo(nGroupID, nSubID, &tTaskInfo))
    {
        response.head.nSubReq = UR_OBJECT_NOT_EXIST;
        imSendOpeReqOnlyCxt(lpContext, lpRequest->head.nRepeated, lpRequest->pDataPtr, response);
        return FALSE;
    }
    if (0 >= tTaskInfo.nActive)
    {
        response.head.nSubReq = UR_OPERATE_FAILED;
        response.head.nValue = TASK_AWARD_WRONG_NOT_ACTIVE;
        imSendOpeReqOnlyCxt(lpContext, lpRequest->head.nRepeated, lpRequest->pDataPtr, response);
        return FALSE;
    }

    std::future<int> f;
    auto key = toKey(nUserID);
    imDBOpera(key, [this, nUserID, lpReqData, lpContext, lpRequest, &response, nCurTime, tTaskInfo](DBConnectEntry* entry)
    {
        if (TRUE != entry->SelectDB(TASK_REDIS_SELECT_INDEX)) {
            return FALSE;
        }
        int nResult = 0;
        UINT nResponse = 0;
        int nGroupID = lpReqData->nGroupID;
        int nSubID = lpReqData->nSubID;
        
        lpReqData->nDate = nCurTime; // 以该时刻为准;

        if (nUserID <= 0){
            UwlLogFile("OnQueryTaskData userid is invalid.");
            imSendOpeReqOnlyCxt(lpContext, lpRequest->head.nRepeated, lpRequest->pDataPtr, response);
            return FALSE;
        }
        //////////////////////////////////////////////////////////////////////////任务状态校验;
        {
            TASKDATA tTaskData;
            memset(&tTaskData, 0, sizeof(tTaskData));
            int nTaskState = Redis_QueryTaskDataByTaskID(entry, nCurTime, nUserID, nGroupID, nSubID, &tTaskData);
            if (TRUE == nTaskState && TASKDATA_FLAG_CANGET_REWARD < tTaskData.nFlag)
            {
                response.head.nSubReq = UR_OPERATE_FAILED;
                response.head.nValue = TASK_AWARD_WRONG_ALREADY_AWARD;
                imSendOpeReqOnlyCxt(lpContext, lpRequest->head.nRepeated, lpRequest->pDataPtr, response);
                return FALSE;
            }
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
            response.head.nValue = TASK_AWARD_WRONG_CONDITION;
            imSendOpeReqOnlyCxt(lpContext, lpRequest->head.nRepeated, lpRequest->pDataPtr, response);
            return FALSE;
        }

        //////////////////////////////////////////////////////////////////////////计算任务进度;
        TASKPARAM tTaskParam;
        memset(&tTaskParam, 0, sizeof(tTaskParam));
        nResult = Redis_QueryTaskParam(entry, lpReqData->nDate, nUserID, tTaskParam.nParam);
        if (0 >= nResult)
        {
            response.head.nSubReq = nResponse;
            imSendOpeReqOnlyCxt(lpContext, lpRequest->head.nRepeated, lpRequest->pDataPtr, response);
            return FALSE;
        }

        BOOL bFinished = TRUE;
        for (int i = 0; i < stCondition.size(); i++)
        {
            int nCount = 0;
            if (TASK_CONDITION_COM_GAME_COUNT == stCondition[i].nType)
            {
                nCount = tTaskParam.nParam[TASK_GAME_RESULT_WIN - 1]
                    + tTaskParam.nParam[TASK_GAME_RESULT_LOSE - 1]
                    + tTaskParam.nParam[TASK_GAME_RESULT_DRAW - 1];
            }
            else
            {
                nCount = tTaskParam.nParam[stCondition[i].nType - 1];
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
            response.head.nValue = TASK_AWARD_WRONG_NOT_FINISHED;
            imSendOpeReqOnlyCxt(lpContext, lpRequest->head.nRepeated, lpRequest->pDataPtr, response);
            return FALSE;
        }

        //////////////////////////////////////////////////////////////////////////生成任务奖励;
        nStartPos = 0;
        int nRewardType = tTaskInfo.vReward[0]["RewardType"].asInt();
        int nRewardNum = tTaskInfo.vReward[0]["RewardValueMin"].asInt();
        if (0 >= nRewardType || 0 >= nRewardNum)
        {
            response.head.nSubReq = UR_OPERATE_FAILED;
            response.head.nValue = TASK_AWARD_WRONG_REWARD;
            imSendOpeReqOnlyCxt(lpContext, lpRequest->head.nRepeated, lpRequest->pDataPtr, response);
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
            taskResult.nFlag = TASKDATA_FLAG_FINISHED;
        }
        else
        {
            taskResult.nTaskID = tTaskInfo.nNextID;
            taskResult.nFlag = TASKDATA_FLAG_DOING;
        }
        taskResult.nUserID = nUserID;
        taskResult.nDate = lpReqData->nDate;
        taskResult.nGroupID = nGroupID;
        taskResult.nRewardType = nRewardType;
        taskResult.nRewardNum = nRewardNum;
        memcpy(taskResult.szWebID, tTaskInfo.szWebID, sizeof(taskResult.szWebID));

        //设置已经领取状态;
        Redis_UpdateTaskData(entry, nCurTime, nUserID, nGroupID, taskResult.nTaskID, taskResult.nFlag);

        if ((lpRequest->nDataLen - lpRequest->head.nRepeated * sizeof(CONTEXT_HEAD)) == sizeof(*lpReqData)) {
            //KPI:客户端数据上报
            memcpy(&taskResult.kpiClientData, &(lpReqData->kpiClientData), sizeof(taskResult.kpiClientData));
        }
        int nLen = lpRequest->head.nRepeated*sizeof(CONTEXT_HEAD) + sizeof(taskResult);
        PBYTE pData = NULL;
        pData = new BYTE[nLen];
        memset(pData, 0, nLen);

        memcpy(pData, lpRequest->pDataPtr, lpRequest->head.nRepeated*sizeof(CONTEXT_HEAD));
        memcpy(pData + lpRequest->head.nRepeated*sizeof(CONTEXT_HEAD), &taskResult, sizeof(taskResult));
        response.pDataPtr = pData;
        response.nDataLen = nLen;

        imSendOpeRequest(lpContext, response);
        UwlClearRequest(&response);
        return TRUE;
    }).get();
    return TRUE;
}

void TaskModule::onFreshTimer()
{
    // 一分钟刷新一次
    auto pre = m_tTime;
    m_tTime = CTime::GetCurrentTime();

    // 先判断是否已经超过一天了
    if (pre.GetDay() != m_tTime.GetDay()) {
        readFromLocalIni();

        std::stringstream dbkey;
        dbkey << typeid(*this).name() << "_" << "DeleteLastTaskTable";
        std::future<int> f;
        imDBOpera(dbkey.str(), [this](DBConnectEntry* entry){
            // 删除前天的表
            return deletePredayTable(entry);
        }).get();
    }

    if (m_nFreshTime / 100 == m_tTime.GetHour() && m_nFreshTime % 100 == m_tTime.GetMinute()) {
        // 每天 xx:xx, 清理缓存   
        m_nCurTime = GetDateTime();
        deleteCache();
    }

    if (pre.GetHour() != m_tTime.GetHour()) {
        readFromLocalJson();
    }
}

void TaskModule::readFromLocalIni()
{
    m_nRecordOnlyPhone = 1;
    m_nFreshTime = 0;
    m_nRetainDaysOfParam = 0;
    m_nRetainDaysOfData = 0;
    imGetIniInt(_T("Task"), _T("OnlyPhoneData"), m_nRecordOnlyPhone);
    imGetIniInt(_T("Task"), _T("FreshTime"), m_nFreshTime);
    if (m_nFreshTime < 0 || m_nFreshTime > 600) { // 00:00 ~ 06:00
        m_nFreshTime = 0;
    }
        
    imGetIniInt(_T("Task"), _T("ParamTableRetain"), m_nRetainDaysOfParam);
    if (m_nRetainDaysOfParam < 7) {
        m_nRetainDaysOfParam = 7;
    }
        
    imGetIniInt(_T("Task"), _T("DataTableRetain"), m_nRetainDaysOfData);
    if (m_nRetainDaysOfData < 7) {
        m_nRetainDaysOfData = 7;
    }
}

void TaskModule::readFromLocalJson()
{
    Json::Reader reader;
    Json::Value root;
    std::ifstream is;
    std::string	strWorkDir = GetExecDir();
    std::string strPath = strWorkDir + TASK_JSON_FILE;
    const char* filename = strPath.c_str();
    is.open(filename, std::ios::binary);
    if (reader.parse(is, root))
    {
        m_vTaskJsonRoot = root;
    }
    else
    {
        UwlTrace(_T("CTaskModuleEx ReadTaskJsonConfig Fail"));
        UwlLogFile(_T("CTaskModuleEx ReadTaskJsonConfig Fail"));
    }
    is.close();

    ReadClassicTaskJsonConfig();
}

void TaskModule::ReadClassicTaskJsonConfig()
{
    Json::Reader reader;
    Json::Value root;
    std::ifstream is;
    std::string	strWorkDir = GetExecDir();
    std::string strPath = strWorkDir + CLASSIC_TASK_JSON_FILE;
    const char* filename = strPath.c_str();
    is.open(filename, std::ios::binary);
    if (reader.parse(is, root))
    {
        m_vClassicTaskJsonRoot = root;
    }
    else
    {
        UwlTrace(_T("CTaskModuleEx ReadClassicTaskJsonConfig Fail"));
        UwlLogFile(_T("CTaskModuleEx ReadClassicTaskJsonConfig Fail"));
    }
    is.close();
}

int TaskModule::getCurTime()
{
    return async<int>([this](){
        return m_nCurTime;
    }).get();
}

BOOL TaskModule::deletePredayTable(DBConnectEntry* entry)
{
    if (TRUE != entry->SelectDB(TASK_REDIS_SELECT_INDEX)) {
        return FALSE;
    }
    if (0 < m_nRetainDaysOfParam)
    {
        CString strName("Param");
        int nDateOfParam = GetDateTime(-m_nRetainDaysOfParam);

        CString strCommand;
        strCommand.Format("DEL %s:%d", DAILY_TASK_PARAM_REDIS_KEY, nDateOfParam);
		entry->RedisCommand_pach((LPCTSTR)strCommand);

        UwlLogFile("delete DAILY_TASK_PARAM_REDIS_KEY");
    }
    if (0 < m_nRetainDaysOfData)
    {
        CString strName("Data");
        int nDateOfData = GetDateTime(-m_nRetainDaysOfData);

        std::vector<CString> vecHashes;
        CString strCommand;
        strCommand.Format("KEYS %s%d:*", DAILY_TASK_DATA_REDIS_KEY, nDateOfData);
        entry->RedisCommandEx((LPCTSTR)strCommand, vecHashes);

        strCommand = _T("DEL");
        CString strSpace = _T(" ");
        for (int i = 0; i < vecHashes.size(); i++)
        {
            strCommand = strCommand + strSpace + vecHashes[i];
        }
		entry->RedisCommand_pach((LPCTSTR)strCommand);

        UwlLogFile("delete DAILY_TASK_DATA_REDIS_KEY");
    }
    return TRUE;
}

void TaskModule::deleteCache()
{

}

int TaskModule::Redis_UpdateTaskParam(DBConnectEntry* entry, int nDate, int nUserID, int nType, int nValue)
{
    LOG_INFO(_T("*********Redis_UpdateTaskParam begin nUserID:%d"), nUserID);
    CString strCommand;
    strCommand.Format("HINCRBY %s:%d %d_%d %d", DAILY_TASK_PARAM_REDIS_KEY, nDate, nUserID, nType, nValue);
	entry->RedisCommand_pach((LPCTSTR)strCommand);
    LOG_INFO(_T("*********Redis_UpdateTaskParam end nUserID:%d"), nUserID);
    return TRUE;
}

int TaskModule::Redis_UpdateTaskParamWin(DBConnectEntry* entry, int nDate, int nUserID, int nType1, int nValue, int nType2)
{
    LOG_INFO(_T("*********Redis_UpdateTaskParamWin begin nUserID:%d"), nUserID);
    int winValue = Redis_UpdateTaskParam(entry, nDate, nUserID, nType1, nValue);

    CString strCommand;
    CString strValue;
    strCommand.Format("HGET %s:%d %d_%d", DAILY_TASK_PARAM_REDIS_KEY, nDate, nUserID, nType2);
	strValue = entry->RedisCommand_pach((LPCTSTR)strCommand);
    int maxWinValue = atoi(strValue);
    if (maxWinValue < winValue)
    {
        strCommand.Format("HSET %s:%d %d_%d %d", DAILY_TASK_PARAM_REDIS_KEY, nDate, nUserID, nType2, winValue);
		entry->RedisCommand_pach((LPCTSTR)strCommand);
    }
    LOG_INFO(_T("*********Redis_UpdateTaskParamWin end nUserID:%d"), nUserID);
    return TRUE;
}

int TaskModule::Redis_UpdateTaskParamLose(DBConnectEntry* entry, int nDate, int nUserID, int nType, int nValue)
{
    LOG_INFO(_T("*********Redis_UpdateTaskParamLose begin nUserID:%d"), nUserID);
    Redis_UpdateTaskParam(entry, nDate, nUserID, nType, nValue);
    LOG_INFO(_T("*********Redis_UpdateTaskParamLose end nUserID:%d"), nUserID);
    return TRUE;
}

int TaskModule::Redis_QueryTaskParam(DBConnectEntry* entry, int nDate, int nUserID, int nParam[])
{
    LOG_INFO(_T("*********Redis_QueryTaskParam begin nUserID:%d"), nUserID);
    CString strCommand;
    CString strValue;

    for (int i = 0; i < TASK_PARAM_TOTAL; i++)
    {
        strCommand.Format("HGET %s:%d %d_%d", DAILY_TASK_PARAM_REDIS_KEY, nDate, nUserID, i + 1);
		strValue = entry->RedisCommand_pach((LPCTSTR)strCommand);
        nParam[i] = atoi(strValue);
    }
    LOG_INFO(_T("*********Redis_QueryTaskParam end nUserID:%d"), nUserID);
    return TRUE;
}

int TaskModule::Redis_UpdateTaskData(DBConnectEntry* entry, int nDate, int nUserID, int nGroupID, int nSubID, int nFlag)
{
    LOG_INFO(_T("*********Redis_UpdateTaskData begin nUserID:%d"), nUserID);
    CString strCommand;
    CString strValue;
    strCommand.Format("HSET %s%d:%d %d %d_%d", DAILY_TASK_DATA_REDIS_KEY, nDate, nUserID, nGroupID, nSubID, nFlag);
	entry->RedisCommand_pach((LPCTSTR)strCommand);
    LOG_INFO(_T("*********Redis_UpdateTaskData end nUserID:%d"), nUserID);
    return TRUE;
}

int TaskModule::Redis_QueryTaskData(DBConnectEntry* entry, int nDate, int nUserID, int& nNum, TASKDATA taskData[])
{
    LOG_INFO(_T("*********Redis_QueryTaskData begin nUserID:%d"), nUserID);
    CString strCommand;
    strCommand.Format("HGETALL %s%d:%d ", DAILY_TASK_DATA_REDIS_KEY, nDate, nUserID);
    std::map<CString, CString> oResMap;
    entry->RedisCommandEx(oResMap, strCommand);

    CString groupValue;
    nNum = 0;
    auto it = oResMap.begin();
    while (it != oResMap.end()) {
        taskData[nNum].nGroupID = atoi(it->first);
        groupValue = it->second;
        int userIndex = groupValue.Find("_");
        taskData[nNum].nSubID = atoi(groupValue.Left(userIndex));
        taskData[nNum].nFlag = atoi(groupValue.Right(groupValue.GetLength() - userIndex - 1));
        nNum++;
        it++;
    }
    LOG_INFO(_T("*********Redis_QueryTaskData end nUserID:%d"), nUserID);
    return TRUE;
}

int TaskModule::Redis_QueryTaskDataByTaskID(DBConnectEntry* entry, int nDate, int nUserID, int nGroupID, int nSubID, LPTASKDATA pTaskData)
{
    LOG_INFO(_T("*********Redis_QueryTaskDataByTaskID begin nUserID:%d"), nUserID);
    CString strCommand;
    CString strValue;
    strCommand.Format("HGET %s%d:%d %d ", DAILY_TASK_DATA_REDIS_KEY, nDate, nUserID, nGroupID);
    strValue = entry->RedisCommand_pach((LPCTSTR)strCommand);

    pTaskData->nGroupID = nGroupID;
    int userIndex = strValue.Find("_");
    pTaskData->nSubID = atoi(strValue.Left(userIndex));
    pTaskData->nFlag = atoi(strValue.Right(strValue.GetLength() - userIndex - 1));;
    LOG_INFO(_T("*********Redis_QueryTaskDataByTaskID end nUserID:%d"), nUserID);
    return TRUE;

}

int TaskModule::DB_QueryLTaskData1(DBConnectEntry* entry, int nUserID, std::vector<LFTaskData>& taskInfos)
{
    LOG_INFO(_T("*********DB_QueryLTaskData1 begin nUserID:%d"), nUserID);
    int nResult = 0;

    TCHAR szSql[MAX_SQL_LENGTH] = {0};
    sprintf_s(szSql, "call usp_query_ltask_data(%d)", nUserID);
    auto r = entry->mysql_excute(szSql, [&taskInfos, nUserID](sql::ResultSet* res){
        while (res->next()) {
            LFTaskData record = { 0 };
            record.taskid = res->getInt("task_id");
            record.userid = nUserID;
            record.status = res->getInt("status");
            taskInfos.push_back(record);
        }
        return res->rowsCount();
    });
 
    return r.first;
}

int TaskModule::DB_LTaskUpdateLTaskDataEx(DBConnectEntry* entry, LFTaskData& taskData)
{
    LOG_INFO(_T("*********DB_LTaskUpdateLTaskDataEx begin nUserID:%d"), taskData.userid);
    int nResult = 0;

    TCHAR szSql[MAX_SQL_LENGTH];
    sprintf_s(szSql, _T("call usp_update_ltask_data(%d,%d,%d)"), taskData.userid, taskData.taskid, taskData.status);
    LOG_INFO(_T("*********DB_LTaskUpdateLTaskDataEx end nUserID:%d"), taskData.userid);
    return entry->mysql_excute(szSql);
}

int TaskModule::DB_LTaskUpdateLTaskParamEx(DBConnectEntry* entry, LTaskParam& taskParam)
{
    LOG_INFO(_T("*********DB_LTaskUpdateLTaskParamEx begin nUserID:%d"), taskParam.nuserid);
    int nResult = 0;

    TCHAR szSql[MAX_SQL_LENGTH];
    sprintf_s(szSql, _T("call usp_update_ltask_param(%d,%d,%d)"), taskParam.nuserid, taskParam.type, taskParam.countadd);
    LOG_INFO(_T("*********DB_LTaskUpdateLTaskParamEx end nUserID:%d"), taskParam.nuserid);
    return entry->mysql_excute(szSql);
}

std::string TaskModule::toKey(int userid)
{
    std::stringstream ss;
    ss << typeid(*this).name() << "_" << userid;

    return ss.str();
}

void TaskModule::OnTest(bool& ret, std::string& cmd)
{
    if (cmd == "task") {
        OnQueryTaskParam(NULL, NULL);
        auto dbkey = toKey(1234);
        std::future<int> f;
        auto r =imDBOpera(dbkey, [this](DBConnectEntry* entry){
            Redis_UpdateTaskData(entry, 20180101, 1234, 1, 3, 2);
            Redis_UpdateTaskData(entry, 20180101, 1234, 2, 7, 1);
            TASKDATAINFO taskDataInfo;
            memset(&taskDataInfo, 0, sizeof(taskDataInfo));
            Redis_QueryTaskData(entry, 20180101, 1234, taskDataInfo.nDataNum, taskDataInfo.tData);
            return 1;
        }).get();
    }
}

BOOL TaskModule::GetClassicTaskInfo(int nGroupID, int nSubID, LPTASKINFOJSON pTaskInfo)
{
    return async<BOOL>([nGroupID, nSubID, &pTaskInfo, this](){
        if (!m_vClassicTaskJsonRoot.isObject()) return FALSE;

        Json::Value taskRoot = m_vClassicTaskJsonRoot["Task"];
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

BOOL TaskModule::GetLTaskInfo(int nTaskID, LPTaskInfoRecord pTaskInfo)
{
    return async<BOOL>([nTaskID, &pTaskInfo, this](){
        if (!m_vTaskJsonRoot.isObject()) return FALSE;

        Json::Value taskRoot = m_vTaskJsonRoot["TaskLevel"];
        if (!taskRoot.isArray()) return FALSE;
        for (int i = 0; i < taskRoot.size(); i++)
        {
            Json::Value tasklist = taskRoot[i]["TaskList"];
            if (!tasklist.isArray()) return FALSE;
            for (int j = 0; j < tasklist.size(); j++)
            {
                if (tasklist[j]["ID"] == nTaskID)
                {
                    if (!tasklist[j]["Condition"].isArray()) return FALSE;
                    if (!tasklist[j]["Reward"].isArray()) return FALSE;
                    pTaskInfo->taskid = nTaskID;
                    pTaskInfo->nextid = tasklist[j]["NextID"].asInt();
                    memcpy(pTaskInfo->szWebID, tasklist[j]["WebID"].asString().c_str(), sizeof(pTaskInfo->szWebID));
                    pTaskInfo->conditionType = tasklist[j]["Condition"][0]["ConType"].asInt();
                    pTaskInfo->conditionCount = tasklist[j]["Condition"][0]["ConValue"].asInt();
                    pTaskInfo->rewardType = tasklist[j]["Reward"][0]["RewardType"].asInt();
                    pTaskInfo->reward = tasklist[j]["Reward"][0]["RewardValueMin"].asInt();
                    return TRUE;
                }
            }
        }
        return FALSE;
    }).get();
}

BOOL TaskModule::GetTaskInfo(int nGroupID, int nSubID, LPTASKINFOJSON pTaskInfo)
{
    return async<BOOL>([nGroupID, nSubID, &pTaskInfo, this](){
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

std::string TaskModule::GetTaskJsonString()
{
    return async<std::string>([this](){
        return m_vTaskJsonRoot.toStyledString();
    }).get();
}
