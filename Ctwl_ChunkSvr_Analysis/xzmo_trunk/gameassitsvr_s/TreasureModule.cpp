#include "StdAfx.h"
#include "TreasureModule.h"
#include "TreasureReq.h"
#include "tcycomponents/TcyMsgCenter.h"

TreasureModule::TreasureModule()
{
#ifdef _DEBUG
	m_strAddr = "http://hdrw.uc108.org:1505";
#elif _RS125
	m_strAddr = "http://hdrw.uc108.org:1505";
#else
	m_strAddr = "http://hdrw.tcy365.net";
#endif
}

void TreasureModule::OnAssistServerStart(BOOL& ret, TcyMsgCenter* msgCenter)
{
    if (ret) {
		AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_QUERY_TREASURE_INFO, OnQueryTreasureInfo);
		AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_TAKE_TREASURE_AWARD, OnTakeTreasureAward);
    }
}

void TreasureModule::OnChunkClientStart(TcyMsgCenter* msgCenter)
{
	AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_QUERY_TREASURE_INFO, OnQueryTreasureInfoRet);
	AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_TAKE_TREASURE_AWARD, OnTakeTreasureAwardRet);
}

BOOL TreasureModule::OnQueryTreasureInfo(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
    LPREQTREASUREAWARDPRIZE lpTreasureQuery = static_cast<LPREQTREASUREAWARDPRIZE>(lpRequest->pDataPtr);
    if (NULL == lpTreasureQuery)
    {
        UwlLogFile("invalid Treasure info query struct!");
        return FALSE;
    }

    imMsgToChunk(lpContext, lpRequest);
    return TRUE;
}

BOOL TreasureModule::OnTakeTreasureAward(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
    LPREQTREASUREINFO lpTreasureAward = static_cast<LPREQTREASUREINFO>(lpRequest->pDataPtr);
    if (NULL == lpTreasureAward)
    {
        UwlLogFile("invalid wxtask query struct!");
        return FALSE;
    }
    imMsgToChunk(lpContext, lpRequest);
    return TRUE;
}

BOOL TreasureModule::OnQueryTreasureInfoRet(LPCONTEXT_HEAD lpContext, LPREQUEST lpReqFromSvr)
{
    if (UR_OPERATE_SUCCEEDED != lpReqFromSvr->head.nSubReq)
    {
        UwlTrace(_T("OnQueryTreasureInfoRet failed! ErrCode=%d"), lpReqFromSvr->head.nSubReq);
        UwlLogFile(_T("OnQueryTreasureInfoRet failed! ErrCode=%d"), lpReqFromSvr->head.nSubReq);
        imNotifyOneWithParseContext(lpReqFromSvr, lpContext, lpReqFromSvr->head.nSubReq, nullptr, 0);
        //m_pServer->NotifyOneUserErrorInfo(lpContext, TREASURE_ERR_CHUNKERR);
        return FALSE;
    }

    LPRSPTREASUREINFO pResp = (LPRSPTREASUREINFO)(PBYTE(lpReqFromSvr->pDataPtr) + lpReqFromSvr->head.nRepeated * sizeof(CONTEXT_HEAD));
    imNotifyOneWithParseContext(lpReqFromSvr, lpContext, GR_QUERY_TREASURE_INFO, pResp, sizeof(RSPTREASUREINFO));
    return TRUE;
}

static CString  MD5String(LPTSTR lpszContent)
{
    CString sRet;

    MD5_CTX mdContext;
    UwlMD5Init(&mdContext);
    UwlMD5Update(&mdContext, (unsigned char *)(LPTSTR)lpszContent, lstrlen(lpszContent));
    UwlMD5Final(&mdContext);

    UwlConvertHexToStr(mdContext.digest, 16, sRet);

    return sRet;
}


BOOL TreasureModule::OnTakeTreasureAwardRet(LPCONTEXT_HEAD lpContext, LPREQUEST lpReqFromSvr)
{
    if (UR_OPERATE_SUCCEEDED != lpReqFromSvr->head.nSubReq)
    {
        UwlTrace(_T("OnTakeTreasureAwardRet failed! ErrCode=%d"), lpReqFromSvr->head.nSubReq);
        UwlLogFile(_T("OnTakeTreasureAwardRet failed! ErrCode=%d"), lpReqFromSvr->head.nSubReq);
		imNotifyOneWithParseContext(lpReqFromSvr, lpContext, lpReqFromSvr->head.nSubReq, nullptr, 0);
        return FALSE;
    }

	auto tcyMsgHead = MoveTcyMsgHead(lpReqFromSvr, lpContext);
	imDoHttp([tcyMsgHead, this](CHttpClient& httpClient){
        
		LPRSPTREASUREAWARDPRIZE pResp = (LPRSPTREASUREAWARDPRIZE)(PBYTE(tcyMsgHead->requst.pDataPtr) + tcyMsgHead->requst.head.nRepeated * sizeof(CONTEXT_HEAD));

        CString strMD5Get;
        strMD5Get.Format("%d|%s|%d|%d", pResp->MgId, pResp->MId, pResp->userid, pResp->prize_count);
        CString strMD5GetDest = MD5String(strMD5Get.GetBuffer(strMD5Get.GetLength() + 1));
        strMD5Get.ReleaseBuffer();

		CString strAddr = m_strAddr.c_str();
        TCHAR szJson[MAX_PATH] = "";

        /*if (pDataResp->kpiClientData.GameId == g_pPreDefine->getGameID()) {
        http.addHeaders("GsClientData", GetHttpKPiJson(&pDataResp->kpiClientData));
        UwlLogFile("update kpi param");
        }*/
        sprintf(szJson, "%s/mission/complete?MgId=%d&UId=%d&MId=%s&RewardNum=%d&SilverLocation=%d&UserName=&TelPhone=&ip=127.0.0.1&key=%s",
            strAddr,
            pResp->MgId,							 // 接口地址
            pResp->userid,                    // 抽奖活动ID
            pResp->MId,
            pResp->prize_count,
            2,
            strMD5GetDest                       // MD5校验
            );//格式由网站提供


        auto strGetRet = httpClient.doGet(szJson);
        // 记录日志
        UwlLogFile(_T("[NewLottery send]%s\n[NewLottery recv]%s"), szJson, strGetRet);

		int ret = ParseAwardResult(strGetRet);
        
        /*************************************************************
        *  领奖埋点
        ***********/
        LOGTREASUREAWARD data = { 0 };
        data.nUserID = pResp->userid;
        data.nPrizeCount = pResp->prize_count;
        data.nPrizeType = pResp->type;
        data.nRoomID = pResp->roomid;
        data.nBoutCount = pResp->boutcount;
        data.nAwardSuccess = ret;

        REQUEST requestToChunkLog;
        requestToChunkLog = tcyMsgHead->requst;
        requestToChunkLog.nDataLen = sizeof(data);
        requestToChunkLog.pDataPtr = &data;
        imMsgToChunkLog(&tcyMsgHead->context, &requestToChunkLog);

        /***********************************************************/
        RSPAWARDPRIZE rspAwardData = { 0 };
        rspAwardData.last_count = pResp->last_count;
        rspAwardData.ret = ret;
        rspAwardData.next_goal = pResp->next_goal;
        rspAwardData.prize_count = pResp->prize_count;
        rspAwardData.type = pResp->type;
        UwlTrace(_T("OnTakeTreasureAwardRet success!"));
        UwlLogFile(_T("OnTakeTreasureAwardRet success"));

        imNotifyOneWithParseContext(&tcyMsgHead->requst, &tcyMsgHead->context, GR_TAKE_TREASURE_AWARD, &rspAwardData, sizeof(RSPAWARDPRIZE));
    });

    return TRUE;
}

int TreasureModule::ParseAwardResult(CString result)
{
	Json::Reader reader;
	Json::Value item;
	int ret = 0;
	if (reader.parse(result.GetBuffer(0), item, false))
	{
		if (!item.isNull() && item.isObject())
		{
			ret = item["Status"].asInt();
		}
	}
	return ret;
}
