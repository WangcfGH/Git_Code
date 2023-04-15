#include "stdafx.h"

void CTaskDelegate::OnChunkClient(TcyMsgCenter* msgCenter)
{
    // 模板代码中 chunk返回消息的调用被注释了。。。暂时不写了
}

void CTaskDelegate::UpdateTaskRecordAboutBout(LPCONTEXT_HEAD lpContext, CTable* pTable, void* pData)
{
    if (!pTable)
    {
        return;
    }

    GAME_WIN* pGameWin = (GAME_WIN*)pData;

    for (int i = 0; i < pTable->m_nTotalChairs; i++)
    {
        int nAddParamType = 0;
        CPlayer* pPlayer = pTable->m_ptrPlayers[i];
        if (pPlayer)
        {
            int nChairNo = pPlayer->m_nChairNO;
            if (pGameWin->nDepositDiffs[i] > 0)
            {
                nAddParamType = TASK_GAME_RESULT_WIN;
            }
            else
            {
                nAddParamType = TASK_GAME_RESULT_LOSE;
            }

            UpdateTaskRecordByAddParam(lpContext, pTable, nChairNo, nAddParamType);
        }
    }
}

void CTaskDelegate::UpdateTaskRecordAboutBoutEx(LPCONTEXT_HEAD lpContext, CTable* pTable, void* pData)
{
    //if (!pTable)
    //{
    //    return;
    //}
    //for (int i = 0; i < pTable->m_nTotalChairs; i++)
    //{
    //    CPlayer* pPlayer = pTable->m_ptrPlayers[i];
    //    if (pPlayer)
    //    {
    //        int nChairNo = pPlayer->m_nChairNO;

    //        UpdateTaskRecordByAddParam(lpContext, pTable, nChairNo, TASK_GAME_ROUND_COUNT);
    //        UpdateLTaskRecordByAddParam(lpContext, pTable, nChairNo, LFTASK_GAME_BOUT);
    //    }
    //}
}

void CTaskDelegate::UpdateTaskRecordByAddParam(LPCONTEXT_HEAD lpContext, CTable* pTable, int nChairNO, int nType, int nValue) //add on 2016.02.17
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
    if (pPlayer)
    {
        lpContext->hSocket = pPlayer->m_hSocket;
        lpContext->lTokenID = pPlayer->m_lTokenID;

        int nUserType = pPlayer->m_nUserType;
        //request chunkSvr
        TASKPARAMCHANGE paramChange;
        memset(&paramChange, 0, sizeof(paramChange));
        paramChange.nUserID = pPlayer->m_nUserID;
        paramChange.nType = nType;
        paramChange.nValue = nValue;
        paramChange.bIsHandPhone = IS_BIT_SET(nUserType, UT_HANDPHONE);

        REQUEST Request;
        memset(&Request, 0, sizeof(Request));
        Request.head.nRequest = GR_TASK_CHANGE_PARAM;
        Request.pDataPtr = &paramChange;
        Request.nDataLen = sizeof(paramChange);
        Request.head.nRepeated = 0;
        imMsg2Chunk.notify(lpContext, &Request);
    }
}

BOOL CTaskDelegate::OnTaskParamRet(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)//add on 2015.6
{
    LPTASKPARAMINFO pDataResp = RequestDataParse<TASKPARAMINFO>(lpRequest);


    if (UR_OPERATE_SUCCEEDED != lpRequest->head.nSubReq)
    {
        UwlTrace(_T("OnTaskParamRet failed! ERRCODE=%d"), lpRequest->head.nSubReq);
        UwlLogFile(_T("OnTaskParamRet failed! ERRCODE=%d"), lpRequest->head.nSubReq);

        return FALSE;
    }

    UwlTrace(_T("OnTaskParamRet OK!"));

    auto* lpClientContext = RequestDataToContext(lpRequest);
    if (lpClientContext)
    {
        SOCKET sock = lpClientContext->hSocket;
        LONG   token = lpClientContext->lTokenID;
        imNotifyOneUser.notify(sock, token, GR_TASK_QUERY_PARAM, pDataResp, sizeof(TASKPARAMINFO), FALSE);
    }

    return TRUE;
}

BOOL CTaskDelegate::OnTaskDataRet(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)//add on 2015.6
{
    LPTASKDATAINFO pDataResp = RequestDataParse<TASKDATAINFO>(lpRequest);

    if (UR_OPERATE_SUCCEEDED != lpRequest->head.nSubReq)
    {
        UwlTrace(_T("OnTaskDataRet failed! ERRCODE=%d"), lpRequest->head.nSubReq);
        UwlLogFile(_T("OnTaskDataRet failed! ERRCODE=%d"), lpRequest->head.nSubReq);

        return FALSE;
    }

    UwlTrace(_T("OnTaskDataRet OK!"));
    auto lpClientContext = RequestDataToContext(lpRequest);
    if (lpClientContext)
    {
        SOCKET sock = lpClientContext->hSocket;
        LONG   token = lpClientContext->lTokenID;
        imNotifyOneUser.notify(sock, token, GR_TASK_QUERY_DATA, pDataResp, sizeof(TASKDATAINFO), FALSE);
    }

    return TRUE;
}

void CTaskDelegate::UpdateLTaskRecordByAddParam(LPCONTEXT_HEAD lpContext, CTable* pTable, int nChairNO, int nType, int nValue /*= 1*/)
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
    if (pPlayer)
    {
        lpContext->hSocket = pPlayer->m_hSocket;
        lpContext->lTokenID = pPlayer->m_lTokenID;

        int nUserType = pPlayer->m_nUserType;
        //request chunkSvr
        LTaskParam paramChange;
        memset(&paramChange, 0, sizeof(paramChange));
        paramChange.nuserid = pPlayer->m_nUserID;
        paramChange.type = nType;
        paramChange.countadd = nValue;

        REQUEST Request;
        memset(&Request, 0, sizeof(Request));
        Request.head.nRequest = GR_TASK_CHANGE_LTASK_PARAM;
        Request.pDataPtr = &paramChange;
        Request.nDataLen = sizeof(paramChange);
        Request.head.nRepeated = 0;
        imMsg2Chunk.notify(lpContext, &Request);
    }
}

void CTaskDelegate::UpdateCreateRoomTaskByPlayer(LPCONTEXT_HEAD lpContext, CTable* pTable)
{
    ////创建房间任务;
    //CYQWGameData yqwGameData;
    //if (m_pServer->YQW_LookupGameData(pTable->m_nRoomID, pTable->m_nTableNO, yqwGameData))
    //{
    //    if ((pTable->m_nYqwHistoryBoutCount % pTable->m_nYqwBoutPerRound) == 1 && !pTable->IsYQWAgent())
    //    {
    //        CPlayer* pPlayer = pTable->GetPlayer(yqwGameData.game_data.nUserId);
    //        if (pPlayer)
    //        {
    //            LPCONTEXT_HEAD lpContext = new CONTEXT_HEAD;
    //            lpContext->hSocket = pPlayer->m_hSocket;
    //            lpContext->lTokenID = pPlayer->m_lTokenID;
    //            UpdateTaskRecordByAddParam(lpContext, pTable, pPlayer->m_nChairNO, TASK_GAME_CREATE_BOUT);
    //            UpdateLTaskRecordByAddParam(lpContext, pTable, pPlayer->m_nChairNO, LFTASK_GAME_CREATE);
    //            m_pServer->m_pLotteryDelegate->ChangeLotteryTaskProcess(lpContext, pTable, pPlayer->m_nChairNO, LOTTERYTASK_GAME_CREATE_BOUT);
    //            SAFE_DELETE(lpContext);
    //        }
    //        else
    //        {
    //            UwlLogFile("YQW_CloseSoloTable yqwGameData.game_data.nUserId:%d", yqwGameData.game_data.nUserId);
    //        }
    //    }
    //}
}