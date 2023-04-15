#include "StdAfx.h"
#include "FirstRecharge.h"
#include "Json.h"
#include "tcycomponents/TcyMsgCenter.h"

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

CString  FirstRecharge::complete(int nTaskActionID, LPLTaskResult pData, IXYSoapClientPtr& pSoapClient)
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

void FirstRecharge::OnAsisstStart(BOOL& ret, TcyMsgCenter* msgCenter)
{
    if (ret) {
		AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_GET_FIRSTRECHARGE_AWARD, OnFirstRechargeAward);
    }
}

void FirstRecharge::OnFirstRechargeAward(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
    LPLTaskResult pData = static_cast<LPLTaskResult>(lpRequest->pDataPtr);
    if (NULL == pData)
    {
        UwlLogFile("invalid task query struct!");
        return ;
    }

	auto tcyMsgHead = MoveTcyMsgHead(lpRequest, lpContext);
    imDoSoap(SOAP_INDEX_OF_FIRST_RECHARGE, [tcyMsgHead, this](LPSOAP_SERVICE pSoapService, IXYSoapClientPtr& pSoapClient){
        BOOL bResult = FALSE;
		LPCONTEXT_HEAD lpContext = &tcyMsgHead->context;
		LPLTaskResult pData = static_cast<LPLTaskResult>(tcyMsgHead->requst.pDataPtr);
        try
        {
            int nTaskActionID = -1;
            imGetIniInt("FirstCharge", "ActID", nTaskActionID);
            memcpy(pData->szWebID, "a1004", 6);

            CString strGetRet = complete(nTaskActionID, pData, pSoapClient);
            int nStatus = -1;
            parseJsonOfComplete(strGetRet, bResult, nStatus);

            //֪ͨ�ͻ���
            pData->nResult = bResult;
            imNotifyOneUser(lpContext->hSocket, lpContext->lTokenID, tcyMsgHead->requst.head.nRequest, pData, sizeof(LTaskResult));
        }
        catch (...)
        {
            UwlTrace(_T("%s error: %s"), pSoapService->szSoapWhat, (LPCTSTR)(pSoapClient->GetLastError()));
            UwlLogFile(_T("%s apply error: %s"), pSoapService->szSoapWhat, (LPCTSTR)(pSoapClient->GetLastError()));
        }
    });
}
