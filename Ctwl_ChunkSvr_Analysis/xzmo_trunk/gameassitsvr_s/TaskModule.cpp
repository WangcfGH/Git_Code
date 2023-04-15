#include "StdAfx.h"
#include "TaskModule.h"
#include "tcycomponents/DingTalkRobot.h"
#include "tcycomponents/TcyMsgCenter.h"
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

CString TaskModule::complete(int nTaskActionID, LPTASKRESULT pData, IXYSoapClientPtr& pSoapClient)
{
    // { soap===========================================
    // ����1
    _bstr_t sMethodName = (_bstr_t)_T("complete");
    // ����2	

    CString strJson;
    //KPI:�ͻ��������ϱ�
    if (pData->kpiClientData.GameId == m_gameid) {
        strJson.Format("{\"%s\":\"%s\",\"%s\":\"%s\",\"%s\":%d,\"%s\":%d,\"%s\":%d,\"%s\":%d,\"%s\":\"%s\",\"%s\":\"%s\"}",
            "Ip", "127.0.0.1",						// IP
            "MId", pData->szWebID,					// WebID
            "MgId", nTaskActionID,					// �ID
            "RewardNum", pData->nRewardNum,			// ��������
            "SilverLocation", 2,					// ��������Ϸ
            "UId", pData->nUserID,					// �û�ID
            "UserName", "",							// �û���
            "GsClientData", GetKPiJson(&pData->kpiClientData)
            );
    }
    else {
        strJson.Format("{\"%s\":\"%s\",\"%s\":\"%s\",\"%s\":%d,\"%s\":%d,\"%s\":%d,\"%s\":%d,\"%s\":\"%s\"}",
            "Ip", "127.0.0.1",						// IP
            "MId", pData->szWebID,					// WebID
            "MgId", nTaskActionID,					// �ID
            "RewardNum", pData->nRewardNum,			// ��������
            "SilverLocation", 2,					// ��������Ϸ
            "UId", pData->nUserID,					// �û�ID
            "UserName", ""							// �û���
            );
    }

    _variant_t vJson = (_bstr_t)strJson;
    // ����3
    CString strMD5Get;
    strMD5Get.Format("%d|%s|%d|%d", nTaskActionID, pData->szWebID, pData->nUserID, pData->nRewardNum);
    CString strMD5GetDest = MD5String(strMD5Get.GetBuffer(strMD5Get.GetLength() + 1));
    strMD5Get.ReleaseBuffer();
    _variant_t key = (_bstr_t)strMD5GetDest;

    //����invokeMethod����������Web���� (����˳�������Ҫ����վ�ṩ�Ĳ���˳��һ��)
    _variant_t strResult = pSoapClient->InvokeMethod(sMethodName, vJson, key);
    CString strGetRet = (LPCTSTR)(_bstr_t)strResult;
    // } soap===========================================

    // ��¼��־
    UwlLogFile(_T("userid:%10d complete %s\nret:%s"), pData->nUserID, strJson, strMD5GetDest);
    return strGetRet;
}

CString TaskModule::complete(int nTaskActionID, LPLTaskResult pData, IXYSoapClientPtr& pSoapClient)
{
    // { soap===========================================
    // ����1
    _bstr_t sMethodName = (_bstr_t)_T("complete");
    // ����2	
    CString strJson;
    UwlLogFile("yml complete date is %d,and the gameid 2 is %d", m_gameid, pData->kpiClientData.GameId);
    //KPI:�ͻ��������ϱ�
    if (pData->kpiClientData.GameId == m_gameid) {
        strJson.Format("{\"%s\":\"%s\",\"%s\":\"%s\",\"%s\":%d,\"%s\":%d,\"%s\":%d,\"%s\":%d,\"%s\":\"%s\",\"%s\":\"%s\"}",
            "Ip", "127.0.0.1",						// IP
            "MId", pData->szWebID,					// WebID
            "MgId", nTaskActionID,					// �ID
            "RewardNum", pData->nTaskReward,			// ��������
            "SilverLocation", 2,					// ��������Ϸ
            "UId", pData->nUserID,					// �û�ID
            "UserName", "",                         // �û���
            "GsClientData", GetKPiJson(&pData->kpiClientData)
            );
    }
    else {
        strJson.Format("{\"%s\":\"%s\",\"%s\":\"%s\",\"%s\":%d,\"%s\":%d,\"%s\":%d,\"%s\":%d,\"%s\":\"%s\"}",
            "Ip", "127.0.0.1",						// IP
            "MId", pData->szWebID,					// WebID
            "MgId", nTaskActionID,					// �ID
            "RewardNum", pData->nTaskReward,			// ��������
            "SilverLocation", 2,					// ��������Ϸ
            "UId", pData->nUserID,					// �û�ID
            "UserName", ""							// �û���
            );
    }
    _variant_t vJson = (_bstr_t)strJson;
    // ����3
    CString strMD5Get;
    strMD5Get.Format("%d|%s|%d|%d", nTaskActionID, pData->szWebID, pData->nUserID, pData->nTaskReward);
    CString strMD5GetDest = MD5String(strMD5Get.GetBuffer(strMD5Get.GetLength() + 1));
    strMD5Get.ReleaseBuffer();
    _variant_t key = (_bstr_t)strMD5GetDest;

    //����invokeMethod����������Web���� (����˳�������Ҫ����վ�ṩ�Ĳ���˳��һ��)
    _variant_t strResult = pSoapClient->InvokeMethod(sMethodName, vJson, key);
    CString strGetRet = (LPCTSTR)(_bstr_t)strResult;
    // } soap===========================================

    // ��¼��־
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
        // �����־
        UwlLogFile(_T("complete failed, error status is %d"), nStatus);
    }
}

void TaskModule::OnChunkClientStart(TcyMsgCenter* msgCenter)
{
	AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_TASK_CHANGE_PARAM, OnChangeTaskParamRet);
    AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_TASK_CHANGE_LTASK_PARAM, OnReqLTaskChangeParamRet);
    AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_TASK_AWARD_PRIZE, OnAwardTaskPrizeRet);
    AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_TASK_AWARD_LTASK, OnReqLTaskAwardRet);
    AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_TASK_QUERY_PARAM, OnTransmitRequestFromChunk);
    AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_TASK_QUERY_DATA, OnTransmitRequestFromChunk);
    AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_TASK_QUERY_TASK_INFO, OnTransmitRequestFromChunk);
    AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_TASK_QUERY_LTASK_DATA, OnTransmitRequestFromChunk);
    AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_TASK_QUERY_LTASK_PARAM, OnTransmitRequestFromChunk);
    AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_TASK_GET_DATA_FOR_JSON, OnTransmitRequestFromChunk);
    UwlTrace("");
}

void TaskModule::OnAssistServerStart(BOOL& ret, TcyMsgCenter* msgCenter)
{
    if (ret) {
        AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_TASK_CHANGE_PARAM, OnTransmitRequest);
        AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_TASK_QUERY_PARAM, OnTransmitRequest);
        AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_TASK_QUERY_DATA, OnTransmitRequest);
        AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_TASK_AWARD_PRIZE, OnTransmitRequest);
        AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_TASK_AWARD_PRIZE_JSON, OnTransmitRequest);
        AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_TASK_QUERY_TASK_INFO, OnTransmitRequest);
        AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_TASK_QUERY_LTASK_DATA, OnTransmitRequest);
        AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_TASK_QUERY_LTASK_PARAM, OnTransmitRequest);
        AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_TASK_CHANGE_LTASK_PARAM, OnTransmitRequest);
        AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_TASK_AWARD_LTASK, OnTransmitRequest);
        AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_TASK_AWARD_LTASK_JSON, OnTransmitRequest);
        AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_TASK_GET_DATA_FOR_JSON, imMsgToChunk);
    }
}

void TaskModule::OnShutdown()
{

}

/////////////////////////////////////////////////////////////////////////////////////////

BOOL TaskModule::OnTransmitRequest(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
    if (lpRequest->pDataPtr == nullptr) {
        UwlLogFile("OnTransmitRequest Error:%d", lpRequest->head.nRequest);
        return FALSE;
    }
    imMsgToChunk(lpContext, lpRequest);
    return TRUE;
}

/*********************************************************************************************************************/

BOOL TaskModule::OnTransmitRequestFromChunk(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
    if (UR_OPERATE_SUCCEEDED != lpRequest->head.nSubReq)
    {
        UwlTrace(_T("OnTransmitRequestFromChunk failed! RequstID:%d, ErrCode=%d"), lpRequest->head.nRequest, lpRequest->head.nSubReq);
        UwlLogFile(_T("OnTransmitRequestFromChunk failed! RequstID:%d, ErrCode=%d"), lpRequest->head.nRequest, lpRequest->head.nSubReq);

        imNotifyOneUserErrorInfo(lpRequest, lpContext, TASK_ERR_CHUNKERR);
        return FALSE;
    }

    void* pResp = (void *)(PBYTE(lpRequest->pDataPtr) + lpRequest->head.nRepeated * sizeof(CONTEXT_HEAD));
    int len = lpRequest->nDataLen - lpRequest->head.nRepeated * sizeof(CONTEXT_HEAD);

    imNotifyOneWithParseContext(lpRequest, lpContext, lpRequest->head.nRequest, pResp, len);
    return TRUE;
}

// �ı����������ݷ���
BOOL TaskModule::OnChangeTaskParamRet(LPCONTEXT_HEAD lpContext, LPREQUEST lpReqFromSvr)
{
    if (UR_OPERATE_SUCCEEDED != lpReqFromSvr->head.nSubReq)
    {
        UwlTrace(_T("OnChangeTaskParamRet failed! ErrCode=%d"), lpReqFromSvr->head.nSubReq);
        UwlLogFile(_T("OnChangeTaskParamRet failed! ErrCode=%d"), lpReqFromSvr->head.nSubReq);

        imNotifyOneUserErrorInfo(lpReqFromSvr, lpContext, TASK_ERR_CHUNKERR);
        return FALSE;
    }

    LPTASKPARAMINFO pResp = (LPTASKPARAMINFO)(PBYTE(lpReqFromSvr->pDataPtr) + lpReqFromSvr->head.nRepeated * sizeof(CONTEXT_HEAD));
    imNotifyOneWithParseContext(lpReqFromSvr, lpContext, GR_TASK_QUERY_PARAM, pResp, sizeof(TASKPARAMINFO));
    return TRUE;
}

// ��ȡ����������
BOOL TaskModule::OnAwardTaskPrizeRet(LPCONTEXT_HEAD lpContext, LPREQUEST lpReqFromSvr)
{
    if (UR_OPERATE_FAILED == lpReqFromSvr->head.nSubReq)
    {
        switch (lpReqFromSvr->head.nValue)
        {
        case TASK_AWARD_WRONG_TASK_NULL:
            UwlLogFile(_T("OnQueryTaskDataRet failed! ErrInfo=%s"), _T("û���ҵ�����������Ϣ������"));
            break;
        case TASK_AWARD_WRONG_NOT_ACTIVE:
            UwlLogFile(_T("OnQueryTaskDataRet failed! ErrInfo=%s"), _T("��������û�м������"));
            break;
        case TASK_AWARD_WRONG_CONDITION:
            UwlLogFile(_T("OnQueryTaskDataRet failed! ErrInfo=%s"), _T("������������������󣡣���"));
            break;
        case TASK_AWARD_WRONG_REWARD:
            UwlLogFile(_T("OnQueryTaskDataRet failed! ErrInfo=%s"), _T("������������Ϣ���󣡣���"));
            break;
        case TASK_AWARD_WRONG_ALREADY_AWARD:
            UwlLogFile(_T("OnQueryTaskDataRet failed! ErrInfo=%s"), _T("���������Ѿ���ȡ������������"));
            break;
        case TASK_AWARD_WRONG_NOT_FINISHED:
            UwlLogFile(_T("OnQueryTaskDataRet failed! ErrInfo=%s"), _T("û�дﵽ�������ȡ����������"));
            break;
        case TASK_AWARD_WRONG_OPERATE_FAST:
            UwlLogFile(_T("OnQueryTaskDataRet failed! ErrInfo=%s"), _T("Ƶ������ȡ��������������"));
			break;
        default:
            UwlLogFile(_T("OnQueryTaskDataRet failed! ErrInfo=%s"), _T("û�и�����ϸ������Ϣ������"));
            break;
        }
    }

    if (UR_OPERATE_SUCCEEDED != lpReqFromSvr->head.nSubReq)
    {
        UwlTrace(_T("OnQueryTaskDataRet failed! ErrCode=%d"), lpReqFromSvr->head.nSubReq);
        UwlLogFile(_T("OnQueryTaskDataRet failed! ErrCode=%d"), lpReqFromSvr->head.nSubReq);

        imNotifyOneUserErrorInfo(lpReqFromSvr, lpContext, TASK_ERR_CHUNKERR);
        return FALSE;
    }

    auto tcyMsgHead = MoveTcyMsgHead(lpReqFromSvr, lpContext);
    imDoSoap.notify(SOAP_INDEX_OF_TASK, [this, tcyMsgHead](LPSOAP_SERVICE pSoapService, IXYSoapClientPtr& pSoapClient){
        this->DoWorkGetTaskPrize(pSoapService, pSoapClient, &tcyMsgHead->context, &tcyMsgHead->requst);
    });


    return TRUE;
}

BOOL TaskModule::OnReqLTaskChangeParamRet(LPCONTEXT_HEAD lpContext, LPREQUEST lpReqFromSvr)
{
    if (UR_OPERATE_SUCCEEDED != lpReqFromSvr->head.nSubReq)
    {
        UwlTrace(_T("OnReqLTaskChangeParamRet failed! ErrCode=%d"), lpReqFromSvr->head.nSubReq);
        UwlLogFile(_T("OnReqLTaskChangeParamRet failed! ErrCode=%d"), lpReqFromSvr->head.nSubReq);

        imNotifyOneUserErrorInfo(lpReqFromSvr, lpContext, TASK_ERR_CHUNKERR);
        return FALSE;
    }

    LPLTaskParamRsp pResp = (LPLTaskParamRsp)(PBYTE(lpReqFromSvr->pDataPtr) + lpReqFromSvr->head.nRepeated * sizeof(CONTEXT_HEAD));
    imNotifyOneWithParseContext(lpReqFromSvr, lpContext, GR_TASK_QUERY_LTASK_PARAM, pResp, sizeof(LTaskParamRsp) + pResp->nCount * sizeof(LTaskParam));
    return TRUE;
}


BOOL TaskModule::OnReqLTaskAwardRet(LPCONTEXT_HEAD lpContext, LPREQUEST lpReqFromSvr)
{
    if (UR_OPERATE_FAILED == lpReqFromSvr->head.nSubReq)
    {
        switch (lpReqFromSvr->head.nValue)
        {
        case TASK_AWARD_WRONG_TASK_NULL:
            UwlLogFile(_T("OnReqLTaskAwardRet failed! ErrInfo=%s"), _T("û���ҵ�����������Ϣ������"));
            break;
        case TASK_AWARD_WRONG_NOT_ACTIVE:
            UwlLogFile(_T("OnReqLTaskAwardRet failed! ErrInfo=%s"), _T("��������û�м������"));
            break;
        case TASK_AWARD_WRONG_CONDITION:
            UwlLogFile(_T("OnReqLTaskAwardRet failed! ErrInfo=%s"), _T("������������������󣡣���"));
            break;
        case TASK_AWARD_WRONG_REWARD:
            UwlLogFile(_T("OnReqLTaskAwardRet failed! ErrInfo=%s"), _T("������������Ϣ���󣡣���"));
            break;
        case TASK_AWARD_WRONG_ALREADY_AWARD:
            UwlLogFile(_T("OnReqLTaskAwardRet failed! ErrInfo=%s"), _T("���������Ѿ���ȡ������������"));
            break;
        case TASK_AWARD_WRONG_NOT_FINISHED:
            UwlLogFile(_T("OnReqLTaskAwardRet failed! ErrInfo=%s"), _T("û�дﵽ�������ȡ����������"));
            break;
        case TASK_AWARD_WRONG_OPERATE_FAST:
            UwlLogFile(_T("OnReqLTaskAwardRet failed! ErrInfo=%s"), _T("Ƶ������ȡ��������������"));
            break;
        default:
            UwlLogFile(_T("OnReqLTaskAwardRet failed! ErrInfo=%s"), _T("û�и�����ϸ������Ϣ������"));
            break;
        }
    }

    if (UR_OPERATE_SUCCEEDED != lpReqFromSvr->head.nSubReq)
    {
        UwlTrace(_T("OnReqLTaskAwardRet failed! ErrCode=%d"), lpReqFromSvr->head.nSubReq);
        UwlLogFile(_T("OnReqLTaskAwardRet failed! ErrCode=%d"), lpReqFromSvr->head.nSubReq);

        imNotifyOneUserErrorInfo(lpReqFromSvr, lpContext, TASK_ERR_CHUNKERR);
        return FALSE;
    }

    auto tcyMsgHead = MoveTcyMsgHead(lpReqFromSvr, lpContext);
    imDoSoap.notify(SOAP_INDEX_OF_TASK, [this, tcyMsgHead](LPSOAP_SERVICE pSoapService, IXYSoapClientPtr& pSoapClient){
        this->DoWorkGetLTaskPrize(pSoapService, pSoapClient, &tcyMsgHead->context, &tcyMsgHead->requst);
    });

    return TRUE;
}

BOOL TaskModule::DoWorkGetTaskPrize(LPSOAP_SERVICE pSoapService, IXYSoapClientPtr& pSoapClient, LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
    BOOL bResult = FALSE;
    try
    {
        LPTASKRESULT pData = (LPTASKRESULT)(PBYTE(lpRequest->pDataPtr) + lpRequest->head.nRepeated * sizeof(CONTEXT_HEAD));

        int nTaskActionID = -1;
        imGetIniInt(_T("Task"), _T("ActID"), nTaskActionID);
        if (nTaskActionID < 0) {
            UwlLogFile("����ID���ô����뼰ʱ��������");
        }
        CString strGetRet = complete(nTaskActionID, pData, pSoapClient);
        int nStatus = -1;
        parseJsonOfComplete(strGetRet, bResult, nStatus);

        if (!bResult)
        {
            CString context;
            context.Format(_T("�����̨��ȡʧ�ܣ���ң�%d��״̬�룺%d"), pData->nUserID, nStatus);
            NoticeToDingTalkRobot(context);
        }

        //֪ͨ�ͻ���
        pData->bResult = bResult;
		imNotifyOneWithParseContext(lpRequest, lpContext, GR_TASK_AWARD_PRIZE, pData, sizeof(TASKRESULT));
    }
    catch (...)
    {
        UwlTrace(_T("%s error: %s"), pSoapService->szSoapWhat, (LPCTSTR)(pSoapClient->GetLastError()));
        UwlLogFile(_T("%s apply error: %s"), pSoapService->szSoapWhat, (LPCTSTR)(pSoapClient->GetLastError()));
        bResult = FALSE;
    }
    return bResult;
}


BOOL TaskModule::DoWorkGetLTaskPrize(LPSOAP_SERVICE pSoapService, IXYSoapClientPtr& pSoapClient, LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
    BOOL bResult = FALSE;
    try
    {
		LPLTaskResult pData = (LPLTaskResult)(PBYTE(lpRequest->pDataPtr) + lpRequest->head.nRepeated * sizeof(CONTEXT_HEAD));

        int nTaskActionID = -1;
        imGetIniInt(_T("lifeTask"), _T("ActID"), nTaskActionID);
        if (nTaskActionID < 0) {
            UwlLogFile("����ID���ô����뼰ʱ��������");
        }
        CString strGetRet = complete(nTaskActionID, pData, pSoapClient);
        int nStatus = -1;
        parseJsonOfComplete(strGetRet, bResult, nStatus);
        if (!bResult)
        {
            CString context;
            context.Format(_T("�����̨��ȡʧ�ܣ���ң�%d��״̬�룺%d"), pData->nUserID, nStatus);
            NoticeToDingTalkRobot(context);
        }

        //֪ͨ�ͻ���
        pData->nResult = bResult;
		imNotifyOneWithParseContext(lpRequest, lpContext, GR_TASK_AWARD_LTASK, pData, sizeof(LTaskResult));
    }
    catch (...)
    {
        UwlTrace(_T("%s error: %s"), pSoapService->szSoapWhat, (LPCTSTR)(pSoapClient->GetLastError()));
        UwlLogFile(_T("%s apply error: %s"), pSoapService->szSoapWhat, (LPCTSTR)(pSoapClient->GetLastError()));
        bResult = FALSE;
    }
    return bResult;
}

void TaskModule::NoticeToDingTalkRobot(CString text)
{
    MsgToDingRobot msg;
    msg.isAtAll = false;
    msg.strContext = text;
    imGetIniString("Task", "DingTalkRobotToken", msg.strToken);

    imNoticeTextToDingTalkRobot(msg);
}
