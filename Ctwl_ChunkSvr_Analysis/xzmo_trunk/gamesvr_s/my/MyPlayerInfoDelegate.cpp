#include "stdafx.h"

void CMyExPlayerInfoDelegate::OnChunkClient(TcyMsgCenter* msgCenter)
{
    AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_EXPLAYERINFO_QUERY, OnExPlayerInfoParamRet);
    AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_EXPLAYERINFO_QUERY, OnExPlayerInfoParamChangeRet);
}

void CMyExPlayerInfoDelegate::QueryExPlayerInfoAboutBout(CTable* pTable)
{
    if (!pTable)
    {
        return;
    }

    EXPLAYERINFOPARAMQUERY paramQuery;
    memset(&paramQuery, 0, sizeof(paramQuery));
    paramQuery.nRoomID = pTable->m_nRoomID;
    paramQuery.nTableNo = pTable->m_nTableNO;
    for (int i = 0; i < pTable->m_nTotalChairs; i++)
    {
        int nAddParamType = 0;
        CPlayer* pPlayer = pTable->m_ptrPlayers[i];
        if (pPlayer)
        {
            if (!pTable->ValidateChair(pPlayer->m_nChairNO))
            {
                return;
            }
            paramQuery.nUserID[i] = pPlayer->m_nUserID;
        }
    }
    //request chunkSvr
    REQUEST Request;
    memset(&Request, 0, sizeof(Request));
    Request.head.nRequest = GR_EXPLAYERINFO_QUERY;
    Request.pDataPtr = &paramQuery;
    Request.nDataLen = sizeof(paramQuery);
    Request.head.nRepeated = 0;

    CONTEXT_HEAD context;//事实上这个参数没有用
    memset(&context, 0, sizeof(context));
    context.hSocket = 0;
    context.lTokenID = 0;
    imMsg2Chunk.notify(&context, &Request);
}

void CMyExPlayerInfoDelegate::UpdateExPlayerInfoAboutBout(LPCONTEXT_HEAD lpContext, CTable* pTable, void* pData)
{
    if (!pTable)
    {
        return;
    }
    for (int i = 0; i < pTable->m_nTotalChairs; i++)
    {
        CPlayer* pPlayer = pTable->m_ptrPlayers[i];
        if (pPlayer)
        {
            int nChairNo = pPlayer->m_nChairNO;
            UpdateExPlayerInfoByAddParam(lpContext, pTable, nChairNo, ((CMyGameTable*)pTable)->IsXueLiuRoom() ? EXPLAEYER_COUT_XL : EXPLAEYER_COUT_XZ);
            LOG_TRACE(_T("task UpdateExPlayerInfoAboutBout userID = %d "), pPlayer->m_nUserID);
        }
    }
}

void CMyExPlayerInfoDelegate::UpdateExPlayerInfoByAddParam(LPCONTEXT_HEAD lpContext, CTable* pTable, int nChairNO, int nType, int nValue)
{
    if (!pTable)
    {
        return;
    }
    if (!pTable->ValidateChair(nChairNO))
    {
        return;
    }
    CPlayer* pPlayer = pTable->m_ptrPlayers[nChairNO];
    if (!pPlayer)
    {
        return;
    }
    lpContext->hSocket = 0;
    lpContext->lTokenID = 0;

    int nUserType = pPlayer->m_nUserType;
    //request chunkSvr
    EXPLAYERINFOPARAMCHANGE paramChange;
    memset(&paramChange, 0, sizeof(paramChange));
    paramChange.nUserID = pPlayer->m_nUserID;
    paramChange.nType = nType;
    paramChange.nValue = nValue;
    paramChange.bIsHandPhone = IS_BIT_SET(nUserType, UT_HANDPHONE);
    paramChange.nRoomID = pTable->m_nRoomID;
    paramChange.nTableNo = pTable->m_nTableNO;
    paramChange.nChairNo = nChairNO;

    REQUEST Request;
    memset(&Request, 0, sizeof(Request));
    Request.head.nRequest = GR_EXPLAYERINFO_CHANGE_PARAM;
    Request.pDataPtr = &paramChange;
    Request.nDataLen = sizeof(paramChange);
    Request.head.nRepeated = 0;
    imMsg2Chunk.notify(lpContext, &Request);
}

BOOL CMyExPlayerInfoDelegate::OnExPlayerInfoParamRet(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
    LPEXPLAYERINFOPARAMQUERYRSP pDataResp = RequestDataParse<EXPLAYERINFOPARAMQUERYRSP>(lpRequest);


    if (UR_OPERATE_SUCCEEDED != lpRequest->head.nSubReq)
    {
        UwlTrace(_T("OnExPlayerInfoParamRet failed! ERRCODE=%d"), lpRequest->head.nSubReq);
        UwlLogFile(_T("OnExPlayerInfoParamRet failed! ERRCODE=%d"), lpRequest->head.nSubReq);
        return FALSE;
    }
    UwlTrace(_T("OnExPlayerInfoParamRet OK!"));

    int nLen = lpRequest->nDataLen - sizeof(CONTEXT_HEAD);

    CMyGameTable* pTable = NULL;

    if (!(pTable = imGetTablePtr.notify(pDataResp->nRoomID, pDataResp->nTableNo, FALSE, 0)))
    {
        return imNotifyResponseFaild.notify(lpContext, FALSE);
    }
    if (pTable)
    {
        CAutoLock lock(&(pTable->m_csTable));
        for (int i = 0; i < TOTAL_CHAIRS; i++)
        {
            pTable->m_nXZTotalGameCount[i] = pDataResp->nXZCount[i];
            pTable->m_nXLTotalGameCount[i] = pDataResp->nXLCount[i];
            int nTotalCount = pDataResp->nXZCount[i] + pDataResp->nXLCount[i];
        }
    }
    return TRUE;
}

BOOL CMyExPlayerInfoDelegate::OnExPlayerInfoParamChangeRet(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
    LPEXPLAYERINFOPARAMCHANGERSP pDataResp = RequestDataParse<EXPLAYERINFOPARAMCHANGERSP>(lpRequest);

    if (UR_OPERATE_SUCCEEDED != lpRequest->head.nSubReq)
    {
        UwlTrace(_T("OnExPlayerInfoParamChangeRet failed! ERRCODE=%d"), lpRequest->head.nSubReq);
        UwlLogFile(_T("OnExPlayerInfoParamChangeRet failed! ERRCODE=%d"), lpRequest->head.nSubReq);
        return FALSE;
    }
    UwlTrace(_T("OnExPlayerInfoParamChangeRet OK!"));

    int nLen = lpRequest->nDataLen - sizeof(CONTEXT_HEAD);

    CMyGameTable* pTable = NULL;
    if (!(pTable = imGetTablePtr.notify(pDataResp->nRoomID, pDataResp->nTableNo, FALSE, 0)))
    {
        return imNotifyResponseFaild.notify(lpContext, FALSE);
    }

    if (pTable)
    {
        CAutoLock lock(&(pTable->m_csTable));
        pTable->m_nXZTotalGameCount[pDataResp->nChairNo] = pDataResp->nXZCount;
        pTable->m_nXLTotalGameCount[pDataResp->nChairNo] = pDataResp->nXLCount;
        int nTotalCount = pDataResp->nXZCount + pDataResp->nXLCount;
    }
    return TRUE;
}

void CMyExPlayerInfoDelegate::OnCPGameStarted(CCommonBaseTable* table, void* pData)
{
    CONTEXT_HEAD ctx;
    ZeroMemory(&ctx, sizeof(ctx));
    UpdateExPlayerInfoAboutBout(&ctx, table, pData);
}

void CMyExPlayerInfoDelegate::OnCPStartSoloTable(START_SOLOTABLE* pStartSoloTable, CCommonBaseTable* pTable, void* pData)
{
    CONTEXT_HEAD ctx;
    ZeroMemory(&ctx, sizeof(ctx));
    UpdateExPlayerInfoAboutBout(&ctx, pTable, pData);
}
