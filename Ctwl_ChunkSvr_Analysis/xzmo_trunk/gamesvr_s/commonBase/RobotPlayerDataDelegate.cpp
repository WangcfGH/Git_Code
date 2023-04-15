#include "stdafx.h"
#include "commonBase\RobotPlayerDataDelegate.h"

void CRobotPlayerDataDelegate::OnCPGameWin(LPCONTEXT_HEAD lpContext, int roomid, CCommonBaseTable* pTable, void* pData)
{
    UpdateRobotPlayerDataOnGameWin(pTable, pData);
}

void CRobotPlayerDataDelegate::OnPreResult(LPCONTEXT_HEAD lpContext, CMyGameTable* pTable, int roomid, int flag, int chairno, GAME_RESULT_EX *pGameResults, int nResultCount)
{
    if (chairno != INVALID_OBJECT_ID)
    {
        BOOL isPlayerHu = (flag == ResultByHu);
        BOOL isPlayerGiveup = (flag == ResultByGiveUp);

        if (isPlayerGiveup)
        {
            UpdateRobotPlayerData(pTable, chairno, pTable->m_stPreSaveInfo[chairno].nPreSaveAllDeposit);
        }
        else if (isPlayerHu)
        {
            if (!pTable->IsXueLiuRoom()) //XL 血战游戏结束
            {
                for (int i = 0; i < pTable->m_nTotalChairs; i++)
                {
                    if (pTable->m_stHuMultiInfo.nHuChair[i] != INVALID_OBJECT_ID)
                    {
                        UpdateRobotPlayerData(pTable, i, pTable->m_stPreSaveInfo[i].nPreSaveAllDeposit);
                    }
                }
            }
        }
    }
}

void CRobotPlayerDataDelegate::UpdateRobotPlayerDataOnGameWin(CCommonBaseTable* pTable, void* pData)
{
    if (!pTable)
    {
        return;
    }

    CMyGameTable* pGameTable = (CMyGameTable*)pTable;
    LPGAME_WIN_RESULT pGameWin = (LPGAME_WIN_RESULT)pData;
    int nRobotCount = 0;  //本桌机器人数
    for (int i = 0; i < pTable->m_nTotalChairs; i++)
    {
        if (pGameTable->m_bIsRobot[i])
        {
            nRobotCount++;
        }
    }

    BOOL bIsSpecialRobot = (nRobotCount == TOTAL_CHAIRS - 1) ? 1 : 0;  //是否匹配了新手机器人

    for (int i = 0; i < pTable->m_nTotalChairs; i++)
    {
        if (pGameTable->m_bIsRobot[i] || (pGameTable->m_ptrPlayers[i] == nullptr) || (pGameTable->m_ptrPlayers[i] != nullptr && pGameTable->m_ptrPlayers[i]->m_bIdlePlayer))
        {
            continue;
        }
        CPLAYER_INFO playerInfo = pTable->m_PlayersBackup[i];
        if (playerInfo.nUserID > 0)
        {
            int nWin = 0;
            if (pGameWin->nTotalDepositDiff[i] > 0)
            {
                nWin = 1;
            }
            else if (pGameWin->nTotalDepositDiff[i] < 0)
            {
                nWin = -1;
            }
            CONTEXT_HEAD context;
            memset(&context, 0, sizeof(context));
            REQUEST request;
            memset(&request, 0, sizeof(request));
            request.head.nRequest = GR_UPDATE_ROBOT_INFO;
            ROBOT_UPDATE_PLAYERDATA reqUpdatePlayerData;
            memset(&reqUpdatePlayerData, 0, sizeof(reqUpdatePlayerData));
            reqUpdatePlayerData.nUserID = playerInfo.nUserID;
            reqUpdatePlayerData.nWin = nWin;
            reqUpdatePlayerData.bSpecialRobot = bIsSpecialRobot;
            reqUpdatePlayerData.nTotalBouts = playerInfo.nBout;

            request.nDataLen = sizeof(reqUpdatePlayerData);
            request.pDataPtr = &reqUpdatePlayerData;
            imMsg2Chunk.notify(&context, &request);
            LOG_DEBUG(_T("UpdateRobotPlayerData userid: %d, nWin: %d, specialrobot: %d"), playerInfo.nUserID, nWin, bIsSpecialRobot);
        }
    }
}

void CRobotPlayerDataDelegate::UpdateRobotPlayerData(CCommonBaseTable* pTable, int nChairNO, int nDepositDiff)
{
    if (!pTable)
    {
        return;
    }

    CMyGameTable* pGameTable = (CMyGameTable*)pTable;
    int nRobotCount = 0;  //本桌机器人数
    for (int i = 0; i < pTable->m_nTotalChairs; i++)
    {
        if (pGameTable->m_bIsRobot[i])
        {
            nRobotCount++;
        }
    }

    BOOL bIsSpecialRobot = (nRobotCount == TOTAL_CHAIRS - 1) ? 1 : 0;  //是否匹配了新手机器人

    if (pGameTable->m_bIsRobot[nChairNO])
    {
        return;
    }
    CPLAYER_INFO playerInfo = pTable->m_PlayersBackup[nChairNO];
    if (playerInfo.nUserID > 0)
    {
        int nWin = 0;
        if (nDepositDiff > 0)
        {
            nWin = 1;
        }
        else if (nDepositDiff < 0)
        {
            nWin = -1;
        }
        CONTEXT_HEAD context;
        memset(&context, 0, sizeof(context));
        REQUEST request;
        memset(&request, 0, sizeof(request));
        request.head.nRequest = GR_UPDATE_ROBOT_INFO;
        ROBOT_UPDATE_PLAYERDATA reqUpdatePlayerData;
        memset(&reqUpdatePlayerData, 0, sizeof(reqUpdatePlayerData));
        reqUpdatePlayerData.nUserID = playerInfo.nUserID;
        reqUpdatePlayerData.nWin = nWin;
        reqUpdatePlayerData.bSpecialRobot = bIsSpecialRobot;
        reqUpdatePlayerData.nTotalBouts = playerInfo.nBout;

        request.nDataLen = sizeof(reqUpdatePlayerData);
        request.pDataPtr = &reqUpdatePlayerData;
        imMsg2Chunk.notify(&context, &request);
        LOG_DEBUG(_T("UpdateRobotPlayerData userid: %d, nWin: %d, specialrobot: %d"), playerInfo.nUserID, nWin, bIsSpecialRobot);
    }
}
