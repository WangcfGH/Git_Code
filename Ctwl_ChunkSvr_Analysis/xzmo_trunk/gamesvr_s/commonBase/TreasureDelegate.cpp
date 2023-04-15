#include "stdafx.h"
#include "commonbase\TreasureDelegate.h"

void CTreasureDelegate::OnChunkClient(TcyMsgCenter* msgCenter)
{
    AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_TREASURE_UPDATE_TASK_DATA, OnTreasureRet);
}

void CTreasureDelegate::OnCPGameStarted(CCommonBaseTable* table, void* pData)
{
    UpdateTreasureBount(table);
}

void CTreasureDelegate::OnCPStartSoloTable(START_SOLOTABLE* pStartSoloTable, CCommonBaseTable* table, void* pData)
{
    UpdateTreasureBount(table);
}

void CTreasureDelegate::UpdateTreasureBount(CCommonBaseTable* pTable)
{
    if (!pTable)
    {
        return;
    }

    CCommonBaseTable* pGameTable = (CCommonBaseTable*)pTable;
    for (int i = 0; i < pTable->m_nTotalChairs; i++)
    {
        int nAddParamType = 0;
        CPlayer* pPlayer = pTable->m_ptrPlayers[i];
        if (pPlayer && IS_BIT_SET(pPlayer->m_nUserType, UT_HANDPHONE))
        {
            int nChairNo = pPlayer->m_nChairNO;

            CONTEXT_HEAD context;
            memset(&context, 0, sizeof(context));
            REQUEST request;
            memset(&request, 0, sizeof(request));
            context.hSocket = pPlayer->m_hSocket;
            context.lTokenID = pPlayer->m_lTokenID;
            request.head.nRequest = GR_TREASURE_UPDATE_TASK_DATA;
            REQADDTREASURETASKDATA reqTreasureTaskData;
            memset(&reqTreasureTaskData, 0, sizeof(reqTreasureTaskData));
            reqTreasureTaskData.count = 1;
            reqTreasureTaskData.roomid = pTable->m_nRoomID;
            reqTreasureTaskData.userid = pPlayer->m_nUserID;

            request.nDataLen = sizeof(reqTreasureTaskData);
            request.pDataPtr = &reqTreasureTaskData;
            imMsg2Chunk(&context, &request);
        }
    }
}

BOOL CTreasureDelegate::OnTreasureRet(LPCONTEXT_HEAD lpContext, LPREQUEST lpReqeust)
{
    LPRSPADDTREASURETASKDATA pDataResp = RequestDataParse<RSPADDTREASURETASKDATA>(lpReqeust);

    if (UR_OPERATE_SUCCEEDED != lpReqeust->head.nSubReq)
    {
        UwlTrace(_T("OnTaskParamRet failed! ERRCODE=%d"), lpReqeust->head.nSubReq);
        UwlLogFile(_T("OnTaskParamRet failed! ERRCODE=%d"), lpReqeust->head.nSubReq);

        return FALSE;
    }

    UwlTrace(_T("OnTaskParamRet OK!"));

    LPCONTEXT_HEAD pop_context = RequestDataToContext(lpReqeust);
    if (pop_context)
    {
        SOCKET sock = pop_context->hSocket;
        LONG   token = pop_context->lTokenID;
        imNotifyOneUser.notify(sock, token, GR_TREASURE_UPDATE_TASK_DATA, pDataResp, sizeof(RSPADDTREASURETASKDATA), FALSE);
    }
    return TRUE;
}
