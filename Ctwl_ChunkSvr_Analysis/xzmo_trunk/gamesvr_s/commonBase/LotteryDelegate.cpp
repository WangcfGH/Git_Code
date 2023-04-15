#include "stdafx.h"


void CLotteryDelegate::YQW_OnCPGameWin(LPCONTEXT_HEAD lpContext, int nRoomId, CCommonBaseTable* pTable, void* pData)
{
    YQW_UpdateLotteryData(lpContext, pTable);
    ChangeLotteryTaskProcessOnYQWGameWin(lpContext, pTable, pData);
}

void CLotteryDelegate::OnCPGameWin(LPCONTEXT_HEAD lpContext, int nRoomId, CCommonBaseTable* pTable, void* pData)
{
    UpdateLotteryData(lpContext, pTable);
    ChangeLotteryTaskProcessOnGameWin(lpContext, pTable, pData);
}

//提交移动端抽奖局数
void CLotteryDelegate::UpdateLotteryData(LPCONTEXT_HEAD lpContext, CTable* pTable)
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
            request.head.nRequest = GR_LOTTERY_HARVEST;
            LOTTERYHARVEST lotteryHarvest;
            memset(&lotteryHarvest, 0, sizeof(lotteryHarvest));
            lotteryHarvest.nTypeID = tLotteryBout;
            lotteryHarvest.nCount = 1;
            lotteryHarvest.nUserID = pPlayer->m_nUserID;

            request.nDataLen = sizeof(lotteryHarvest);
            request.pDataPtr = &lotteryHarvest;
            imMsg2Chunk.notify(&context, &request);
        }
    }
}

//提交移动端抽奖局数;
void CLotteryDelegate::YQW_UpdateLotteryData(LPCONTEXT_HEAD lpContext, CTable* pTable)
{
    if (!pTable)
    {
        return;
    }

    for (int i = 0; i < TOTAL_CHAIRS; i++)
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
            request.head.nRequest = GR_LOTTERY_HARVEST;
            LOTTERYHARVEST lotteryHarvest;
            memset(&lotteryHarvest, 0, sizeof(lotteryHarvest));
            lotteryHarvest.nTypeID = tLooteryYQW;
            lotteryHarvest.nCount = 1;
            lotteryHarvest.nUserID = pPlayer->m_nUserID;

            request.nDataLen = sizeof(lotteryHarvest);
            request.pDataPtr = &lotteryHarvest;
            imMsg2Chunk.notify(&context, &request);
        }
    }

    CYQWGameData yqwGameData;
    if (imYQW_LookupGameData.notify(pTable->m_nRoomID, pTable->m_nTableNO, yqwGameData))
    {
        if (pTable->m_nBoutCount == 1)
        {
            CPlayer* pPlayer = pTable->GetPlayer(yqwGameData.game_data.nUserId);
            if (pPlayer && IS_BIT_SET(pPlayer->m_nUserType, UT_HANDPHONE))
            {
                CONTEXT_HEAD context;
                memset(&context, 0, sizeof(context));
                REQUEST request;
                memset(&request, 0, sizeof(request));
                request.head.nRequest = GR_LOTTERY_HARVEST;
                LOTTERYHARVEST lotteryHarvest;
                memset(&lotteryHarvest, 0, sizeof(lotteryHarvest));
                lotteryHarvest.nTypeID = tLooteryTQWFk;
                lotteryHarvest.nCount = 1;
                lotteryHarvest.nUserID = pPlayer->m_nUserID;

                request.nDataLen = sizeof(lotteryHarvest);
                request.pDataPtr = &lotteryHarvest;
                imMsg2Chunk.notify(&context, &request);
            }
        }
    }
}

//任务抽奖进度收集
void CLotteryDelegate::ChangeLotteryTaskProcess(LPCONTEXT_HEAD lpContext, CTable* pTable, int nChairNO, int nProcessType, int nProcessCount)
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
        if (IS_BIT_SET(nUserType, UT_HANDPHONE))
        {
            //request chunkSvr
            LOTTERY_TASKPROCESS_CHANGE stLotteryTaskChange;
            memset(&stLotteryTaskChange, 0, sizeof(stLotteryTaskChange));
            stLotteryTaskChange.nUserID = pPlayer->m_nUserID;
            stLotteryTaskChange.stTaskProcess.nProcessType = nProcessType;
            stLotteryTaskChange.stTaskProcess.nProcessCount = nProcessCount;

            REQUEST Request;
            memset(&Request, 0, sizeof(Request));
            Request.head.nRequest = GR_LOTTERY_UPDATE_TASKPROCESS;
            Request.pDataPtr = &stLotteryTaskChange;
            Request.nDataLen = sizeof(stLotteryTaskChange);
            Request.head.nRepeated = 0;
            imMsg2Chunk.notify(lpContext, &Request);
        }
    }
}


void CLotteryDelegate::ChangeLotteryTaskProcessOnGameWin(LPCONTEXT_HEAD lpContext, CTable* pTable, void* pData)
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
                nAddParamType = LOTTERYTASK_GAME_RESULT_WIN;
            }
            else
            {
                nAddParamType = LOTTERYTASK_GAME_RESULT_LOSE;
            }

            ChangeLotteryTaskProcess(lpContext, pTable, nChairNo, nAddParamType);
        }
    }
}

void CLotteryDelegate::ChangeLotteryTaskProcessOnYQWGameWin(LPCONTEXT_HEAD lpContext, CTable* pTable, void* pData)
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

            ChangeLotteryTaskProcess(lpContext, pTable, nChairNo, LOTTERYTASK_GAME_ROUND_COUNT);
        }
    }
}