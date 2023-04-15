#include "StdAfx.h"
#include "TaskModule.h"
#include "tcycomponents/DingTalkRobot.h"
#include "Json.h"

static CString MD5String(LPTSTR lpszContent)
{
    CString sRet;

    MD5_CTX mdContext;
    UwlMD5Init(&mdContext);
    UwlMD5Update(&mdContext, (unsigned char*)(LPTSTR)lpszContent, lstrlen(lpszContent));
    UwlMD5Final(&mdContext);

    UwlConvertHexToStr(mdContext.digest, 16, sRet);

    return sRet;
}

static int GetTaskActionID(char szIniFile[])
{
    int nTaskActID = GetPrivateProfileInt(_T("Task"), _T("ActID"), -1, szIniFile);
    if (nTaskActID <= 0)
    {
        UwlLogFile("任务活动ID配置错误，请及时纠正！！");
    }
    return nTaskActID;
}

static int GetLTaskActionID(char szIniFile[])
{
    int nTaskActID = GetPrivateProfileInt(_T("lifeTask"), _T("ActID"), -1, szIniFile);
    if (nTaskActID <= 0)
    {
        UwlLogFile("任务活动ID配置错误，请及时纠正！！");
    }
    return nTaskActID;
}


CString CTaskModule::complete(int nTaskActionID, LPTASKRESULT pData, IXYSoapClientPtr& pSoapClient)
{
    // { soap===========================================
    // 参数1
    _bstr_t sMethodName = (_bstr_t)_T("complete");
    // 参数2	

    CString strJson;
    //KPI:客户端数据上报
    if (pData->kpiClientData.GameId == m_gameid) {
        strJson.Format("{\"%s\":\"%s\",\"%s\":\"%s\",\"%s\":%d,\"%s\":%d,\"%s\":%d,\"%s\":%d,\"%s\":\"%s\",\"%s\":\"%s\"}",
            "Ip", "127.0.0.1",						// IP
            "MId", pData->szWebID,					// WebID
            "MgId", nTaskActionID,					// 活动ID
            "RewardNum", pData->nRewardNum,			// 奖励数量
            "SilverLocation", 2,					// 奖励到游戏
            "UId", pData->nUserID,					// 用户ID
            "UserName", "",							// 用户名
            "GsClientData", GetKPiJson(&pData->kpiClientData)
            );
    }
    else {
        strJson.Format("{\"%s\":\"%s\",\"%s\":\"%s\",\"%s\":%d,\"%s\":%d,\"%s\":%d,\"%s\":%d,\"%s\":\"%s\"}",
            "Ip", "127.0.0.1",						// IP
            "MId", pData->szWebID,					// WebID
            "MgId", nTaskActionID,					// 活动ID
            "RewardNum", pData->nRewardNum,			// 奖励数量
            "SilverLocation", 2,					// 奖励到游戏
            "UId", pData->nUserID,					// 用户ID
            "UserName", ""							// 用户名
            );
    }

    _variant_t vJson = (_bstr_t)strJson;
    // 参数3
    CString strMD5Get;
    strMD5Get.Format("%d|%s|%d|%d", nTaskActionID, pData->szWebID, pData->nUserID, pData->nRewardNum);
    CString strMD5GetDest = MD5String(strMD5Get.GetBuffer(strMD5Get.GetLength() + 1));
    strMD5Get.ReleaseBuffer();
    _variant_t key = (_bstr_t)strMD5GetDest;

    //调用invokeMethod方法来调用Web方法 (参数顺序和类型要跟网站提供的参数顺序一致)
    _variant_t strResult = pSoapClient->InvokeMethod(sMethodName, vJson, key);
    CString strGetRet = (LPCTSTR)(_bstr_t)strResult;
    // } soap===========================================

    // 记录日志
    UwlLogFile(_T("userid:%10d complete %s\nret:%s"), pData->nUserID, strJson, strMD5GetDest);
    return strGetRet;
}

CString CTaskModule::complete(int nTaskActionID, LPLTaskResult pData, IXYSoapClientPtr& pSoapClient)
{
    // { soap===========================================
    // 参数1
    _bstr_t sMethodName = (_bstr_t)_T("complete");
    // 参数2	
    CString strJson;
    UwlLogFile("yml complete date is %d,and the gameid 2 is %d", m_gameid, pData->kpiClientData.GameId);
    //KPI:客户端数据上报
    if (pData->kpiClientData.GameId == m_gameid) {
        strJson.Format("{\"%s\":\"%s\",\"%s\":\"%s\",\"%s\":%d,\"%s\":%d,\"%s\":%d,\"%s\":%d,\"%s\":\"%s\",\"%s\":\"%s\"}",
            "Ip", "127.0.0.1",						// IP
            "MId", pData->szWebID,					// WebID
            "MgId", nTaskActionID,					// 活动ID
            "RewardNum", pData->nTaskReward,			// 奖励数量
            "SilverLocation", 2,					// 奖励到游戏
            "UId", pData->nUserID,					// 用户ID
            "UserName", "",                         // 用户名
            "GsClientData", GetKPiJson(&pData->kpiClientData)
            );
    }
    else {
        strJson.Format("{\"%s\":\"%s\",\"%s\":\"%s\",\"%s\":%d,\"%s\":%d,\"%s\":%d,\"%s\":%d,\"%s\":\"%s\"}",
            "Ip", "127.0.0.1",						// IP
            "MId", pData->szWebID,					// WebID
            "MgId", nTaskActionID,					// 活动ID
            "RewardNum", pData->nTaskReward,			// 奖励数量
            "SilverLocation", 2,					// 奖励到游戏
            "UId", pData->nUserID,					// 用户ID
            "UserName", ""							// 用户名
            );
    }
    _variant_t vJson = (_bstr_t)strJson;
    // 参数3
    CString strMD5Get;
    strMD5Get.Format("%d|%s|%d|%d", nTaskActionID, pData->szWebID, pData->nUserID, pData->nTaskReward);
    CString strMD5GetDest = MD5String(strMD5Get.GetBuffer(strMD5Get.GetLength() + 1));
    strMD5Get.ReleaseBuffer();
    _variant_t key = (_bstr_t)strMD5GetDest;

    //调用invokeMethod方法来调用Web方法 (参数顺序和类型要跟网站提供的参数顺序一致)
    _variant_t strResult = pSoapClient->InvokeMethod(sMethodName, vJson, key);
    CString strGetRet = (LPCTSTR)(_bstr_t)strResult;
    // } soap===========================================

    // 记录日志
    UwlLogFile(_T("userid:%10d complete %s\nret:%s"), pData->nUserID, strJson, strMD5GetDest);
    return strGetRet;
}

static void parseJsonOfComplete(CString strGetRet, int& nResult, int& nStatus)
{
    Json::Reader reader;
    Json::Value item;
    if (reader.parse(strGetRet.GetBuffer(0), item, false))
    {
        if (!item.isNull() && item.isObject())
        {
            nResult = item["Ok"].asInt();
            nStatus = item["Status"].asInt();
        }
    }

    if (!nResult)
    {
        // 结果日志
        UwlLogFile(_T("complete failed, error status is %d"), nStatus);
    }
}

void CTaskModule::OnChunkClientStart(TcyMsgCenter* msgCenter)
{
	msgCenter->setMsgOper(GR_TASK_CHANGE_PARAM, [this](LPCONTEXT_HEAD lpContext, LPREQUEST lpReqeust){
        this->OnChangeTaskParamRet(lpContext, lpReqeust);
    });
	msgCenter->setMsgOper(GR_TASK_QUERY_PARAM, [this](LPCONTEXT_HEAD lpContext, LPREQUEST lpReqeust){
        this->OnQueryTaskParamRet(lpContext, lpReqeust);
    });
	msgCenter->setMsgOper(GR_TASK_QUERY_DATA, [this](LPCONTEXT_HEAD lpContext, LPREQUEST lpReqeust){
        this->OnQueryTaskDataRet(lpContext, lpReqeust);
    });
	msgCenter->setMsgOper(GR_TASK_AWARD_PRIZE, [this](LPCONTEXT_HEAD lpContext, LPREQUEST lpReqeust){
        this->OnAwardTaskPrizeRet(lpContext, lpReqeust);
    });
	msgCenter->setMsgOper(GR_TASK_QUERY_TASK_INFO, [this](LPCONTEXT_HEAD lpContext, LPREQUEST lpReqeust){
        this->OnReqTaskInfoDataRet(lpContext, lpReqeust);
    });
	msgCenter->setMsgOper(GR_TASK_QUERY_LTASK_DATA, [this](LPCONTEXT_HEAD lpContext, LPREQUEST lpReqeust){
        this->OnReqLTaskDataRet(lpContext, lpReqeust);
    });
	msgCenter->setMsgOper(GR_TASK_QUERY_LTASK_PARAM, [this](LPCONTEXT_HEAD lpContext, LPREQUEST lpReqeust){
        this->OnReqLTaskParamRet(lpContext, lpReqeust);
    });
	msgCenter->setMsgOper(GR_TASK_CHANGE_LTASK_PARAM, [this](LPCONTEXT_HEAD lpContext, LPREQUEST lpReqeust){
        this->OnReqLTaskChangeParamRet(lpContext, lpReqeust);
    });
	msgCenter->setMsgOper(GR_TASK_AWARD_LTASK, [this](LPCONTEXT_HEAD lpContext, LPREQUEST lpReqeust){
        this->OnReqLTaskAwardRet(lpContext, lpReqeust);
    });
	msgCenter->setMsgOper(GR_TASK_GET_DATA_FOR_JSON, [this](LPCONTEXT_HEAD lpContext, LPREQUEST lpReqeust){
        this->OnReqGetTaskJsonConfigRet(lpContext, lpReqeust);
    });
    UwlTrace("");
}

void CTaskModule::OnAssistServerStart(BOOL& ret, TcyMsgCenter* msgCenter)
{
    // 读取本地配置
    TCHAR szFullName[MAX_PATH];
    GetModuleFileName(GetModuleHandle(NULL), szFullName, sizeof(szFullName));

    UwlSplitPath(szFullName, SPLIT_DRIVE_DIR, m_szIniFile);
    lstrcat(m_szIniFile, PRODUCT_NAME);
    lstrcat(m_szIniFile, _T(".ini"));

    if (ret) {
		msgCenter->setMsgOper(GR_TASK_CHANGE_PARAM, [this](LPCONTEXT_HEAD lpContext, LPREQUEST lpReqeust){
            this->OnChangeTaskParam(lpContext, lpReqeust);
        });
		msgCenter->setMsgOper(GR_TASK_QUERY_PARAM, [this](LPCONTEXT_HEAD lpContext, LPREQUEST lpReqeust){
            this->OnQueryTaskParam(lpContext, lpReqeust);
        });
		msgCenter->setMsgOper(GR_TASK_QUERY_DATA, [this](LPCONTEXT_HEAD lpContext, LPREQUEST lpReqeust){
            this->OnQueryTaskData(lpContext, lpReqeust);
        });
		msgCenter->setMsgOper(GR_TASK_AWARD_PRIZE, [this](LPCONTEXT_HEAD lpContext, LPREQUEST lpReqeust){
            this->OnAwardTaskPrize(lpContext, lpReqeust);
        });
		msgCenter->setMsgOper(GR_TASK_AWARD_PRIZE_JSON, [this](LPCONTEXT_HEAD lpContext, LPREQUEST lpReqeust){
            this->OnAwardTaskPrize(lpContext, lpReqeust);
        });
		msgCenter->setMsgOper(GR_TASK_QUERY_TASK_INFO, [this](LPCONTEXT_HEAD lpContext, LPREQUEST lpReqeust){
            this->OnReqTaskInfoData(lpContext, lpReqeust);
        });
		msgCenter->setMsgOper(GR_TASK_QUERY_LTASK_DATA, [this](LPCONTEXT_HEAD lpContext, LPREQUEST lpReqeust){
            this->OnReqLTaskData(lpContext, lpReqeust);
        });
		msgCenter->setMsgOper(GR_TASK_QUERY_LTASK_PARAM, [this](LPCONTEXT_HEAD lpContext, LPREQUEST lpReqeust){
            this->OnReqLTaskParam(lpContext, lpReqeust);
        });
		msgCenter->setMsgOper(GR_TASK_CHANGE_LTASK_PARAM, [this](LPCONTEXT_HEAD lpContext, LPREQUEST lpReqeust){
            this->OnReqLTaskChangeParam(lpContext, lpReqeust);
        });
		msgCenter->setMsgOper(GR_TASK_AWARD_LTASK, [this](LPCONTEXT_HEAD lpContext, LPREQUEST lpReqeust){
            this->OnReqLTaskAward(lpContext, lpReqeust);
        });
		msgCenter->setMsgOper(GR_TASK_AWARD_LTASK_JSON, [this](LPCONTEXT_HEAD lpContext, LPREQUEST lpReqeust){
            this->OnReqLTaskAward(lpContext, lpReqeust);
        });
		msgCenter->setMsgOper(GR_TASK_GET_DATA_FOR_JSON, [this](LPCONTEXT_HEAD lpContext, LPREQUEST lpReqeust){
            this->OnReqGetTaskJsonConfig(lpContext, lpReqeust);
        });
    }
}

void CTaskModule::OnShutdown()
{

}

//////////////////////////////////////////////////////////////////////////////////////////

// 改变任务量数据
BOOL CTaskModule::OnChangeTaskParam(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
    LPTASKQUERY lpTaskQuery = static_cast<LPTASKQUERY>(lpRequest->pDataPtr);
    if (NULL == lpTaskQuery)
    {
        UwlLogFile("invalid task query struct!");
        return FALSE;
    }

    evMsgToChunk(lpContext, lpRequest);

    return TRUE;
}

// 查询任务量数据
BOOL CTaskModule::OnQueryTaskParam(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
    LPTASKQUERY lpTaskQuery = static_cast<LPTASKQUERY>(lpRequest->pDataPtr);
    if (NULL == lpTaskQuery)
    {
        UwlLogFile("invalid task query struct!");
        return FALSE;
    }

    evMsgToChunk(lpContext, lpRequest);

    return TRUE;
}

// 查询做任务数据
BOOL CTaskModule::OnQueryTaskData(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
    LPTASKQUERY lpTaskQuery = static_cast<LPTASKQUERY>(lpRequest->pDataPtr);
    if (NULL == lpTaskQuery)
    {
        UwlLogFile("invalid task query struct!");
        return FALSE;
    }

    evMsgToChunk(lpContext, lpRequest);

    return TRUE;
}

// 领取任务奖励
BOOL CTaskModule::OnAwardTaskPrize(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
    LPTASKAWARD lpTaskAward = static_cast<LPTASKAWARD>(lpRequest->pDataPtr);
    if (NULL == lpTaskAward)
    {
        UwlLogFile("invalid task query struct!");
        return FALSE;
    }

    evMsgToChunk(lpContext, lpRequest);

    return TRUE;
}


BOOL CTaskModule::OnReqTaskInfoData(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
    LPReqTaskInfo lpTaskReqInfo = static_cast<LPReqTaskInfo>(lpRequest->pDataPtr);
    if (NULL == lpTaskReqInfo)
    {
        UwlLogFile("invalid task query struct!");
        return FALSE;
    }

    evMsgToChunk(lpContext, lpRequest);

    return TRUE;
}

BOOL CTaskModule::OnReqLTaskData(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
    LPTaskDataReq lpTaskReqData = static_cast<LPTaskDataReq>(lpRequest->pDataPtr);
    if (NULL == lpTaskReqData)
    {
        UwlLogFile("invalid task query struct!");
        return FALSE;
    }

    evMsgToChunk(lpContext, lpRequest);

    return TRUE;
}


BOOL CTaskModule::OnReqLTaskParam(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
    LPTaskParamReq lpTaskReqData = static_cast<LPTaskParamReq>(lpRequest->pDataPtr);
    if (NULL == lpTaskReqData)
    {
        UwlLogFile("invalid task query struct!");
        return FALSE;
    }

    evMsgToChunk(lpContext, lpRequest);

    return TRUE;
}

BOOL CTaskModule::OnReqLTaskChangeParam(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
    LPLTaskParam lpTaskReqData = static_cast<LPLTaskParam>(lpRequest->pDataPtr);
    if (NULL == lpTaskReqData)
    {
        UwlLogFile("invalid task query struct!");
        return FALSE;
    }

    evMsgToChunk(lpContext, lpRequest);

    return TRUE;
}


BOOL CTaskModule::OnReqLTaskAward(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
    LPLTaskAward lpTaskReqData = static_cast<LPLTaskAward>(lpRequest->pDataPtr);
    if (NULL == lpTaskReqData)
    {
        UwlLogFile("invalid task query struct!");
        return FALSE;
    }

    evMsgToChunk(lpContext, lpRequest);

    return TRUE;
}

BOOL CTaskModule::OnReqGetTaskJsonConfig(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
    evMsgToChunk(lpContext, lpRequest);
    return TRUE;
}

/*********************************************************************************************************************/

// 改变任务量数据返回
BOOL CTaskModule::OnChangeTaskParamRet(LPCONTEXT_HEAD lpContext, LPREQUEST lpReqFromSvr)
{
    if (UR_OPERATE_SUCCEEDED != lpReqFromSvr->head.nSubReq)
    {
        UwlTrace(_T("OnChangeTaskParamRet failed! ErrCode=%d"), lpReqFromSvr->head.nSubReq);
        UwlLogFile(_T("OnChangeTaskParamRet failed! ErrCode=%d"), lpReqFromSvr->head.nSubReq);

        evNotifyOneUserErrorInfo(lpReqFromSvr, lpContext, TASK_ERR_CHUNKERR);
        return FALSE;
    }

    LPTASKPARAMINFO pResp = (LPTASKPARAMINFO)(PBYTE(lpReqFromSvr->pDataPtr) + lpReqFromSvr->head.nRepeated * sizeof(CONTEXT_HEAD));
    evNotifyOneWithParseContext(lpReqFromSvr, lpContext, GR_TASK_QUERY_PARAM, pResp, sizeof(TASKPARAMINFO));
    return TRUE;
}

// 查询任务量数据返回
BOOL CTaskModule::OnQueryTaskParamRet(LPCONTEXT_HEAD lpContext, LPREQUEST lpReqFromSvr)
{
    if (UR_OPERATE_SUCCEEDED != lpReqFromSvr->head.nSubReq)
    {
        UwlTrace(_T("OnQueryTaskParamRet failed! ErrCode=%d"), lpReqFromSvr->head.nSubReq);
        UwlLogFile(_T("OnQueryTaskParamRet failed! ErrCode=%d"), lpReqFromSvr->head.nSubReq);

        evNotifyOneUserErrorInfo(lpReqFromSvr, lpContext, TASK_ERR_CHUNKERR);
        return FALSE;
    }

    LPTASKPARAMINFO pResp = (LPTASKPARAMINFO)(PBYTE(lpReqFromSvr->pDataPtr) + lpReqFromSvr->head.nRepeated * sizeof(CONTEXT_HEAD));
    evNotifyOneWithParseContext(lpReqFromSvr, lpContext, GR_TASK_QUERY_PARAM, pResp, sizeof(TASKPARAMINFO));

    return TRUE;
}

// 查询做任务数据返回
BOOL CTaskModule::OnQueryTaskDataRet(LPCONTEXT_HEAD lpContext, LPREQUEST lpReqFromSvr)
{
    if (UR_OPERATE_SUCCEEDED != lpReqFromSvr->head.nSubReq)
    {
        UwlTrace(_T("OnQueryTaskDataRet failed! ErrCode=%d"), lpReqFromSvr->head.nSubReq);
        UwlLogFile(_T("OnQueryTaskDataRet failed! ErrCode=%d"), lpReqFromSvr->head.nSubReq);

        evNotifyOneUserErrorInfo(lpReqFromSvr, lpContext, TASK_ERR_CHUNKERR);
        return FALSE;
    }

    LPTASKDATAINFO pResp = (LPTASKDATAINFO)(PBYTE(lpReqFromSvr->pDataPtr) + lpReqFromSvr->head.nRepeated * sizeof(CONTEXT_HEAD));
    evNotifyOneWithParseContext(lpReqFromSvr, lpContext, GR_TASK_QUERY_DATA, pResp, sizeof(TASKDATAINFO));

    return TRUE;
}

// 领取任务奖励返回
BOOL CTaskModule::OnAwardTaskPrizeRet(LPCONTEXT_HEAD lpContext, LPREQUEST lpReqFromSvr)
{
    if (UR_OPERATE_FAILED == lpReqFromSvr->head.nSubReq)
    {
        switch (lpReqFromSvr->head.nValue)
        {
        case TASK_AWARD_WRONG_TASK_NULL:
            UwlLogFile(_T("OnQueryTaskDataRet failed! ErrInfo=%s"), _T("没有找到这条任务信息！！！"));
            break;
        case TASK_AWARD_WRONG_NOT_ACTIVE:
            UwlLogFile(_T("OnQueryTaskDataRet failed! ErrInfo=%s"), _T("这条任务没有激活！！！"));
            break;
        case TASK_AWARD_WRONG_CONDITION:
            UwlLogFile(_T("OnQueryTaskDataRet failed! ErrInfo=%s"), _T("这条任务完成条件有误！！！"));
            break;
        case TASK_AWARD_WRONG_REWARD:
            UwlLogFile(_T("OnQueryTaskDataRet failed! ErrInfo=%s"), _T("这条任务奖励信息有误！！！"));
            break;
        case TASK_AWARD_WRONG_ALREADY_AWARD:
            UwlLogFile(_T("OnQueryTaskDataRet failed! ErrInfo=%s"), _T("这条任务已经领取过奖励！！！"));
            break;
        case TASK_AWARD_WRONG_NOT_FINISHED:
            UwlLogFile(_T("OnQueryTaskDataRet failed! ErrInfo=%s"), _T("没有达到任务的领取条件！！！"));
            break;
        case TASK_AWARD_WRONG_OPERATE_FAST:
            UwlLogFile(_T("OnQueryTaskDataRet failed! ErrInfo=%s"), _T("频繁的领取奖励操作！！！"));
            break;
        default:
            UwlLogFile(_T("OnQueryTaskDataRet failed! ErrInfo=%s"), _T("没有更多详细错误信息！！！"));
            break;
        }
    }

    if (UR_OPERATE_SUCCEEDED != lpReqFromSvr->head.nSubReq)
    {
        UwlTrace(_T("OnQueryTaskDataRet failed! ErrCode=%d"), lpReqFromSvr->head.nSubReq);
        UwlLogFile(_T("OnQueryTaskDataRet failed! ErrCode=%d"), lpReqFromSvr->head.nSubReq);

        evNotifyOneUserErrorInfo(lpReqFromSvr, lpContext, TASK_ERR_CHUNKERR);
        return FALSE;
    }

	auto tcyMsgHead = MoveTcyMsgHead(lpReqFromSvr, lpContext);
	evDoSoap.notify(0, [this, tcyMsgHead](LPSOAP_SERVICE pSoapService, IXYSoapClientPtr& pSoapClient){
		this->DoWorkGetTaskPrize(pSoapService, pSoapClient, &tcyMsgHead->context, &tcyMsgHead->requst);
    });
    

    return TRUE;
}

BOOL CTaskModule::OnReqTaskInfoDataRet(LPCONTEXT_HEAD lpContext, LPREQUEST lpReqFromSvr)
{
    if (UR_OPERATE_SUCCEEDED != lpReqFromSvr->head.nSubReq)
    {
        UwlTrace(_T("OnReqTaskInfoDataRet failed! ErrCode=%d"), lpReqFromSvr->head.nSubReq);
        UwlLogFile(_T("OnReqTaskInfoDataRet failed! ErrCode=%d"), lpReqFromSvr->head.nSubReq);

        evNotifyOneUserErrorInfo(lpReqFromSvr, lpContext, TASK_ERR_CHUNKERR);
        return FALSE;
    }

    LPTaskInfoData pResp = (LPTaskInfoData)(PBYTE(lpReqFromSvr->pDataPtr) + lpReqFromSvr->head.nRepeated * sizeof(CONTEXT_HEAD));
    evNotifyOneWithParseContext(lpReqFromSvr, lpContext, GR_TASK_QUERY_TASK_INFO, pResp, sizeof(TaskInfoData) + pResp->nCount * sizeof(TaskInfoRecord));
    return TRUE;
}

BOOL CTaskModule::OnReqLTaskDataRet(LPCONTEXT_HEAD lpContext, LPREQUEST lpReqFromSvr)
{
    if (UR_OPERATE_SUCCEEDED != lpReqFromSvr->head.nSubReq)
    {
        UwlTrace(_T("OnReqLTaskDataRet failed! ErrCode=%d"), lpReqFromSvr->head.nSubReq);
        UwlLogFile(_T("OnReqLTaskDataRet failed! ErrCode=%d"), lpReqFromSvr->head.nSubReq);

        evNotifyOneUserErrorInfo(lpReqFromSvr, lpContext, TASK_ERR_CHUNKERR);
        return FALSE;
    }

    LPLTaskDataRsp pResp = (LPLTaskDataRsp)(PBYTE(lpReqFromSvr->pDataPtr) + lpReqFromSvr->head.nRepeated * sizeof(CONTEXT_HEAD));
    evNotifyOneWithParseContext(lpReqFromSvr, lpContext, GR_TASK_QUERY_LTASK_DATA, pResp, sizeof(LTaskDataRsp) + pResp->nCount * sizeof(LFTaskData));
    return TRUE;
}

BOOL CTaskModule::OnReqLTaskParamRet(LPCONTEXT_HEAD lpContext, LPREQUEST lpReqFromSvr)
{
    if (UR_OPERATE_SUCCEEDED != lpReqFromSvr->head.nSubReq)
    {
        UwlTrace(_T("OnReqLTaskParamRet failed! ErrCode=%d"), lpReqFromSvr->head.nSubReq);
        UwlLogFile(_T("OnReqLTaskParamRet failed! ErrCode=%d"), lpReqFromSvr->head.nSubReq);

        evNotifyOneUserErrorInfo(lpReqFromSvr, lpContext, TASK_ERR_CHUNKERR);
        return FALSE;
    }

    LPLTaskParamRsp pResp = (LPLTaskParamRsp)(PBYTE(lpReqFromSvr->pDataPtr) + lpReqFromSvr->head.nRepeated * sizeof(CONTEXT_HEAD));
    evNotifyOneWithParseContext(lpReqFromSvr, lpContext, GR_TASK_QUERY_LTASK_PARAM, pResp, sizeof(LTaskParamRsp) + pResp->nCount * sizeof(LTaskParam));
    return TRUE;
}

BOOL CTaskModule::OnReqLTaskChangeParamRet(LPCONTEXT_HEAD lpContext, LPREQUEST lpReqFromSvr)
{
    if (UR_OPERATE_SUCCEEDED != lpReqFromSvr->head.nSubReq)
    {
        UwlTrace(_T("OnReqLTaskChangeParamRet failed! ErrCode=%d"), lpReqFromSvr->head.nSubReq);
        UwlLogFile(_T("OnReqLTaskChangeParamRet failed! ErrCode=%d"), lpReqFromSvr->head.nSubReq);

        evNotifyOneUserErrorInfo(lpReqFromSvr, lpContext, TASK_ERR_CHUNKERR);
        return FALSE;
    }

    LPLTaskParamRsp pResp = (LPLTaskParamRsp)(PBYTE(lpReqFromSvr->pDataPtr) + lpReqFromSvr->head.nRepeated * sizeof(CONTEXT_HEAD));
    evNotifyOneWithParseContext(lpReqFromSvr, lpContext, GR_TASK_QUERY_LTASK_PARAM, pResp, sizeof(LTaskParamRsp) + pResp->nCount * sizeof(LTaskParam));
    return TRUE;
}


BOOL CTaskModule::OnReqLTaskAwardRet(LPCONTEXT_HEAD lpContext, LPREQUEST lpReqFromSvr)
{
    if (UR_OPERATE_FAILED == lpReqFromSvr->head.nSubReq)
    {
        switch (lpReqFromSvr->head.nValue)
        {
        case TASK_AWARD_WRONG_TASK_NULL:
            UwlLogFile(_T("OnReqLTaskAwardRet failed! ErrInfo=%s"), _T("没有找到这条任务信息！！！"));
            break;
        case TASK_AWARD_WRONG_NOT_ACTIVE:
            UwlLogFile(_T("OnReqLTaskAwardRet failed! ErrInfo=%s"), _T("这条任务没有激活！！！"));
            break;
        case TASK_AWARD_WRONG_CONDITION:
            UwlLogFile(_T("OnReqLTaskAwardRet failed! ErrInfo=%s"), _T("这条任务完成条件有误！！！"));
            break;
        case TASK_AWARD_WRONG_REWARD:
            UwlLogFile(_T("OnReqLTaskAwardRet failed! ErrInfo=%s"), _T("这条任务奖励信息有误！！！"));
            break;
        case TASK_AWARD_WRONG_ALREADY_AWARD:
            UwlLogFile(_T("OnReqLTaskAwardRet failed! ErrInfo=%s"), _T("这条任务已经领取过奖励！！！"));
            break;
        case TASK_AWARD_WRONG_NOT_FINISHED:
            UwlLogFile(_T("OnReqLTaskAwardRet failed! ErrInfo=%s"), _T("没有达到任务的领取条件！！！"));
            break;
        case TASK_AWARD_WRONG_OPERATE_FAST:
            UwlLogFile(_T("OnReqLTaskAwardRet failed! ErrInfo=%s"), _T("频繁的领取奖励操作！！！"));
            break;
        default:
            UwlLogFile(_T("OnReqLTaskAwardRet failed! ErrInfo=%s"), _T("没有更多详细错误信息！！！"));
            break;
        }
    }

    if (UR_OPERATE_SUCCEEDED != lpReqFromSvr->head.nSubReq)
    {
        UwlTrace(_T("OnReqLTaskAwardRet failed! ErrCode=%d"), lpReqFromSvr->head.nSubReq);
        UwlLogFile(_T("OnReqLTaskAwardRet failed! ErrCode=%d"), lpReqFromSvr->head.nSubReq);

        evNotifyOneUserErrorInfo(lpReqFromSvr, lpContext, TASK_ERR_CHUNKERR);
        return FALSE;
    }

	auto tcyMsgHead = MoveTcyMsgHead(lpReqFromSvr, lpContext);
	evDoSoap.notify(0, [this, tcyMsgHead](LPSOAP_SERVICE pSoapService, IXYSoapClientPtr& pSoapClient){
        this->DoWorkGetLTaskPrize(pSoapService, pSoapClient, &tcyMsgHead->context, &tcyMsgHead->requst);
    });
    
    return TRUE;
}

BOOL CTaskModule::OnReqGetTaskJsonConfigRet(LPCONTEXT_HEAD lpContext, LPREQUEST lpReqFromSvr)
{
    if (UR_OPERATE_SUCCEEDED != lpReqFromSvr->head.nSubReq)
    {
        UwlTrace(_T("OnChangeTaskParamRet failed! ErrCode=%d"), lpReqFromSvr->head.nSubReq);
        UwlLogFile(_T("OnChangeTaskParamRet failed! ErrCode=%d"), lpReqFromSvr->head.nSubReq);

        evNotifyOneUserErrorInfo(lpReqFromSvr, lpContext, TASK_ERR_CHUNKERR);
        return FALSE;
    }

    void* pResp = (void*)(PBYTE(lpReqFromSvr->pDataPtr) + lpReqFromSvr->head.nRepeated * sizeof(CONTEXT_HEAD));
    evNotifyOneWithParseContext(lpReqFromSvr, lpContext, GR_TASK_GET_DATA_FOR_JSON, pResp, lpReqFromSvr->nDataLen - sizeof(CONTEXT_HEAD));
    return TRUE;
}


////
////BEGIN_SOAPMSG_MAP(CTaskModule, CModule)
////ON_SOAPMSG(GR_TASK_SOAP_PRIZE, DoWorkGetTaskPrize)
////ON_SOAPMSG(GR_LTASK_SOAP_PRIZE, DoWorkGetLTaskPrize)
////END_SOAPMSG_MAP()

BOOL CTaskModule::DoWorkGetTaskPrize(LPSOAP_SERVICE pSoapService, IXYSoapClientPtr& pSoapClient, LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
    BOOL bResult = FALSE;
    try
    {
		LPTASKRESULT pData = (LPTASKRESULT)(PBYTE(lpRequest->pDataPtr) + lpRequest->head.nRepeated * sizeof(CONTEXT_HEAD));

        int nTaskActionID = GetTaskActionID(m_szIniFile);
        CString strGetRet = complete(nTaskActionID, pData, pSoapClient);
        int nStatus = -1;
        parseJsonOfComplete(strGetRet, bResult, nStatus);

        if (!bResult)
        {
            CString context;
            context.Format(_T("任务后台领取失败，玩家：%d，状态码：%d"), pData->nUserID, nStatus);
            NoticeToDingTalkRobot(context);
        }

        //通知客户端
        pData->bResult = bResult;
		evNotifyOneWithParseContext(lpRequest, lpContext, GR_TASK_AWARD_PRIZE, pData, sizeof(TASKRESULT));
    }
    catch (...)
    {
        UwlTrace(_T("%s error: %s"), pSoapService->szSoapWhat, (LPCTSTR)(pSoapClient->GetLastError()));
        UwlLogFile(_T("%s apply error: %s"), pSoapService->szSoapWhat, (LPCTSTR)(pSoapClient->GetLastError()));
        bResult = FALSE;
    }
    return bResult;
}


BOOL CTaskModule::DoWorkGetLTaskPrize(LPSOAP_SERVICE pSoapService, IXYSoapClientPtr& pSoapClient, LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
    BOOL bResult = FALSE;
    try
    {
		LPLTaskResult pData = (LPLTaskResult)(PBYTE(lpRequest->pDataPtr) + lpRequest->head.nRepeated * sizeof(CONTEXT_HEAD));

        int nTaskActionID = GetLTaskActionID(m_szIniFile);
        CString strGetRet = complete(nTaskActionID, pData, pSoapClient);
        int nStatus = -1;
        parseJsonOfComplete(strGetRet, bResult, nStatus);
        if (!bResult)
        {
            CString context;
            context.Format(_T("任务后台领取失败，玩家：%d，状态码：%d"), pData->nUserID, nStatus);
            NoticeToDingTalkRobot(context);
        }

        //通知客户端
        pData->nResult = bResult;
		evNotifyOneWithParseContext(lpRequest, lpContext, GR_TASK_AWARD_LTASK, pData, sizeof(LTaskResult));
    }
    catch (...)
    {
        UwlTrace(_T("%s error: %s"), pSoapService->szSoapWhat, (LPCTSTR)(pSoapClient->GetLastError()));
        UwlLogFile(_T("%s apply error: %s"), pSoapService->szSoapWhat, (LPCTSTR)(pSoapClient->GetLastError()));
        bResult = FALSE;
    }
    return bResult;
}

void CTaskModule::NoticeToDingTalkRobot(CString text)
{
    MsgToDingRobot msg;
    msg.isAtAll = false;
    msg.strContext = text;
    evGetIniString("Task", "DingTalkRobotToken", msg.strToken);

    evNoticeTextToDingTalkRobot(msg);
}

//BOOL CTaskModule::OnChunKToClient(LPCONTEXT_HEAD lpContext, LPREQUEST lpReqFromSvr)
//{
//    void* pResp = (void*)(PBYTE(lpReqFromSvr->pDataPtr) + sizeof(CONTEXT_HEAD));
//    int nLen = lpReqFromSvr->nDataLen - sizeof(CONTEXT_HEAD);
//    SOCKET sock = lpContext->hSocket;
//    LONG   token = lpContext->lTokenID;
//
//    m_pServer->NotifyOneUser(sock, token, lpReqFromSvr->head.nRequest, pResp, nLen);
//
//    return TRUE;
//}
//
//
//CString CTaskModule::strIniFileName = "";
