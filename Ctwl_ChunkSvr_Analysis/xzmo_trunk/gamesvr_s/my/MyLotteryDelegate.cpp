#include "stdafx.h"
#include "MyLotteryDelegate.h"



void CMyExLotteryDelegate::ChangeLotteryTaskProcessOnGameWin(LPCONTEXT_HEAD lpContext, CTable* pTable, void* pData)
{
    if (!pTable)
    {
        return;
    }

    GAME_WIN_RESULT* pGameWin = (GAME_WIN_RESULT*)pData;
    CMyGameTable* pGameTable = (CMyGameTable*)pTable;
    LPHU_DETAILS_EX pHuDetails = LPHU_DETAILS_EX((PBYTE)pGameWin + sizeof(GAME_WIN_RESULT));

    for (int i = 0; i < pTable->m_nTotalChairs; i++)
    {
        int nAddParamType = 0;
        CPlayer* pPlayer = pTable->m_ptrPlayers[i];
        if (pPlayer)
        {
            int nChairNo = pPlayer->m_nChairNO;
            if (pGameWin->gamewin.gamewin.nDepositDiffs[i] > 0)
            {
                nAddParamType = LOTTERYTASK_GAME_RESULT_WIN;
            }
            else
            {
                nAddParamType = LOTTERYTASK_GAME_RESULT_LOSE;
            }

            //m_pServer->m_pTaskDelegate->UpdateTaskRecordByAddParam(lpContext, pTable, nChairNo, nAddParamType);
            if (pHuDetails)
            {
                //m_pServer->m_pTaskDelegate->UpdateTaskRecordByAddParam(lpContext, pTable, nChairNo, LOTTERYTASK_GAME_RESULT_SDB);
            }
        }

        pHuDetails++;
    }

}

void CMyExLotteryDelegate::ChangeLotteryTaskProcessOnYQWGameWin(LPCONTEXT_HEAD lpContext, CTable* pTable, void* pData)
{
    if (!pTable)
    {
        return;
    }

    GAME_WIN_RESULT* pGameWin = (GAME_WIN_RESULT*)pData;
    LPHU_DETAILS_EX pHuDetails = LPHU_DETAILS_EX((PBYTE)pGameWin + sizeof(GAME_WIN_RESULT));
    CMyGameTable* pGameTable = (CMyGameTable*)pTable;

    for (int i = 0; i < pTable->m_nTotalChairs; i++)
    {
        CPlayer* pPlayer = pTable->m_ptrPlayers[i];
        if (pPlayer)
        {
            int nChairNo = pPlayer->m_nChairNO;

            ChangeLotteryTaskProcess(lpContext, pTable, nChairNo, LOTTERYTASK_GAME_ROUND_COUNT);
            if (pHuDetails)
            {
                ChangeLotteryTaskProcess(lpContext, pTable, nChairNo, LOTTERYTASK_GAME_7FENQ_COUNT);
            }
            if (pGameTable->m_nHuChair == nChairNo && (INVALID_OBJECT_ID == pGameTable->m_nLoseChair))
            {
                ChangeLotteryTaskProcess(lpContext, pTable, nChairNo, LOTTERYTASK_GAME_ZIMO_COUNT);
            }
            if (pHuDetails && IS_BIT_SET(pHuDetails->dwHuFlags[0], MJ_HU_13BK))
            {
                ChangeLotteryTaskProcess(lpContext, pTable, nChairNo, LOTTERYTASK_GAME_13LAN_COUNT);
            }
            if (pTable->IsYQWTable())
            {
                CYQWGameData yqwGameData;
                if (imYQW_LookupGameData.notify(pTable->m_nRoomID, pTable->m_nTableNO, yqwGameData) && !yqwGameData.IsAgentTblRoom())
                {
                    if (pTable->YQW_IsLastBout())
                    {
                        if (pPlayer->m_nUserID == yqwGameData.game_data.nUserId)
                        {
                            ChangeLotteryTaskProcess(lpContext, pTable, nChairNo, LOTTERYTASK_GAME_CREATEFINISH_BOUT);
                        }
                    }
                }
            }
        }

        pHuDetails++;
    }
}