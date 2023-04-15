#include "stdafx.h"
#include "MySysMsgToServer.h"

void MySysMsgToServer::RegsiterSysMsgOpera()
{
    __super::RegsiterSysMsgOpera();
    m_msgid2Opera.insert({ LOCAL_GAME_MSG_AUTO_EXCHANGECARDS, [this](SysMsgOperaPack * pack) {
            return OnSysMsg_AutoExchangeCards(pack);
        }
    });
    m_msgid2Opera.insert({ LOCAL_GAME_MSG_AUTO_GIVEUP, [this](SysMsgOperaPack * pack) {
            return OnSysMsg_AutoGiveup(pack);
        }
    });
    m_msgid2Opera.insert({ LOCAL_GAME_MSG_AUTO_HU, [this](SysMsgOperaPack * pack){
            return OnSysMsg_AutoGiveup(pack);
        }
    });
    m_msgid2Opera.insert({ LOCAL_GAME_MSG_AUTO_GUO, [this](SysMsgOperaPack * pack) {
            return OnSysMsg_AutoGuo(pack);
        }
    });
    m_msgid2Opera.insert({ LOCAL_GAME_MSG_AN_GANG, [this](SysMsgOperaPack * pack) {
            return OnSysMsg_GameLocalAnGang(pack);
        }
    });
    m_msgid2Opera.insert({ LOCAL_GAME_MSG_AUTO_FIXMISS, [this](SysMsgOperaPack * pack) {
        return OnSysMsg_GameLocalFixMiss(pack);
    	}
    });

}

BOOL MySysMsgToServer::OnSysMsg_AutoExchangeCards(SysMsgOperaPack* pack)
{
    auto* pData = pack->pData;
    auto* pRoom = pack->pRoom;
    auto roomid = pack->roomid;
    auto tableno = pack->tableno;
    auto userid = pack->userid;
    auto chairno = pack->chairno;
    auto* lpContext = pack->lpContext;

    CMyGameTable* pTable = static_cast<CMyGameTable*>(pack->pTable);
    EXCHANGE3CARDS* pExchangeCards = (EXCHANGE3CARDS*)(pack->pData);

    if (!IS_BIT_SET(pTable->m_dwStatus, TS_WAITING_EXCHANGE3CARDS))
    {
        return m_pMyServer->NotifyResponseFaild(lpContext);
    }

    BOOL bn = pTable->OnExchangeCards(pExchangeCards);

    SYSTEMMSG msg;
    ZeroMemory(&msg, sizeof(SYSTEMMSG));
    msg.nMsgID = SYSMSG_PLAYER_EXCHANGE3CARDS;
    msg.nChairNO = chairno;
    msg.nMJID = pExchangeCards->nExchange3Cards[0][0];
    msg.nEventID = pExchangeCards->nExchange3Cards[0][1];
    msg.nFangCardChairNO = pExchangeCards->nExchange3Cards[0][2];
    m_pMyServer->NotifySystemMSG(pTable, &msg, -1);
    if (bn)
    {
        EXCHANGE3CARDS exchangefinished;
        ZeroMemory(&exchangefinished, sizeof(exchangefinished));
        memcpy(&exchangefinished, pExchangeCards, sizeof(EXCHANGE3CARDS));
        memcpy(exchangefinished.nExchange3Cards, pTable->m_nExchangeCards, sizeof(exchangefinished.nExchange3Cards));
        m_pMyServer->NotifyTablePlayers(pTable, GR_EXCHANGE3CARDS_FINISHED, &exchangefinished, sizeof(exchangefinished));
        m_pMyServer->NotifyTableVisitors(pTable, GR_EXCHANGE3CARDS_FINISHED, &exchangefinished, sizeof(exchangefinished));
        pTable->m_dwDingQueStartTime = GetTickCount();

        //if (pTable->IsRoboter(pTable->GetCurrentChair()))
        //{
        //  OnRobotAIPlay(pRoom, pTable, pTable->GetCurrentChair());
        //}
        for (int j = 0; j < TOTAL_CHAIRS; j++)
        {
            if (pTable->IsRoboter(j))
            {
                m_pMyServer->OnRobotStartExchangeOrFixmiss(pRoom, pTable);
                break;
            }
        }
        m_pMyServer->CreateRobotTimer(pRoom, pTable, pTable->m_dwStatus, pTable->m_nDingQueWait * 1000 + 5000);
    }

    return 0;
}

BOOL MySysMsgToServer::OnSysMsg_AutoGiveup(SysMsgOperaPack* pack)
{
    auto roomid = pack->roomid;
    auto pRoom = pack->pRoom;
    auto lpContext = pack->lpContext;
    LPGIVE_UP_GAME pGiveUpGame = (LPGIVE_UP_GAME)pack->pData;
    CMyGameTable* pTable = static_cast<CMyGameTable*>(pack->pTable);
    int chairno = pGiveUpGame->nChairNO;

    if (!IS_BIT_SET(pTable->m_dwStatus, TS_WAITING_GIVEUP)) // 不是等待放弃状态
    {
        return m_pMyServer->NotifyResponseFaild(lpContext);
    }

    if (!pTable->OnPlayerGiveUp(chairno))
    {
        return m_pMyServer->NotifyResponseFaild(lpContext);
    }
    else
    {
        SYSTEMMSG PlayerGiveUp;
        ZeroMemory(&PlayerGiveUp, sizeof(SYSTEMMSG));
        PlayerGiveUp.nChairNO = chairno;
        PlayerGiveUp.nMsgID = SYSMSG_PLAYER_GIVEUP;
        PlayerGiveUp.nEventID = MJ_GIVE_UP;

        m_pMyServer->NotifyTablePlayers(pTable, GR_SYSTEMMSG, &PlayerGiveUp, sizeof(SYSTEMMSG), 0);
        m_pMyServer->NotifyTableVisitors(pTable, GR_SYSTEMMSG, &PlayerGiveUp, sizeof(SYSTEMMSG), 0);
    }

    DWORD dwWinFlags = pTable->CalcWinOnGiveUp(chairno, TRUE);
    if (dwWinFlags)
    {
        pTable->ResetPlayerGiveUpInfo();
        int bout_time = m_pMyServer->GetBoutTimeMin();
        BOOL bout_invalid = pTable->IsBoutInvalid(bout_time);
        m_pMyServer->OnGameWin(lpContext, pRoom, pTable, chairno, bout_invalid, roomid);
    }
    else
    {
        m_pMyServer->PreSaveResult(lpContext, pTable, roomid, ResultByGiveUp, chairno);

        BOOL bIsAllGiveUp = pTable->IsAllPlayerGiveUp();
        if (bIsAllGiveUp)
        {
            int nCurrentChair = pTable->GetCurrentChair();
            pTable->RemoveStatusOnGiveUp();
            pTable->m_dwCheckBreakTime[nCurrentChair] = GetTickCount();
            pTable->m_dwWaitOperateTick = (pTable->m_nPGCHWait + SVR_WAIT_SECONDS) * 1000;
            m_pMyServer->NotifyNextTurn(pTable, nCurrentChair);
        }

        if (IS_BIT_SET(pTable->m_dwStatus, TS_WAITING_GIVEUP))
        {
            m_pMyServer->CreateRobotTimer(pRoom, pTable, pTable->m_dwStatus, pTable->m_nGiveUpTime * 1000);
        }
        else
        {
            m_pMyServer->CreateRobotTimer(pRoom, pTable, pTable->m_dwStatus, pTable->m_nPGCHWait * 1000);
        }

        //掉线自动抓牌
        if (pTable->IsOffline(pTable->GetCurrentChair()))
        {
            m_pMyServer->OnServerAutoPlay(pRoom, pTable, pTable->GetCurrentChair(), !pTable->IsOffline(pTable->GetCurrentChair()));
        }
    }

    return 0;
}

BOOL MySysMsgToServer::OnSysMsg_AutoHu(SysMsgOperaPack* pack)
{
    int nTempForCatch = 0;
    try
    {
        auto userid = pack->userid;
        auto tableno = pack->tableno;
        auto pPlayer = pack->pPlayer;
        auto roomid = pack->roomid;
        auto pRoom = pack->pRoom;
        auto lpContext = pack->lpContext;
        CMyGameTable* pTable = static_cast<CMyGameTable*>(pack->pTable);
        HU_CARD* pHuCard = (HU_CARD*)pack->pData;
        auto chairno = pHuCard->nChairNO;
        auto cardchair = pHuCard->nCardChair;
        nTempForCatch = 1;
        if (!pTable->ValidateMultiHu(pHuCard))
        {
            //UwlLogFile("AutoHu ValidateMultiHu, chairno is %d", chairno);
            return m_pMyServer->NotifyResponseFaild(lpContext);
        }

        if (!pTable->ValidateHu(pHuCard))
        {
            if (pTable->m_bOpenSaveResultLog)
            {
                UwlLogFile("AutoHu ValidateMultiHu, chairno is %d", chairno);
            }
            return m_pMyServer->NotifyResponseFaild(lpContext);
        }

        nTempForCatch = 2;
        int nTemp = 0;
        BOOL bAlreadyHu = pTable->m_HuReady[chairno];
        if (pTable->IsXueLiuRoom())
        {
            bAlreadyHu = FALSE;
        }
        if (!bAlreadyHu)
        {
            nTemp = pTable->OnHu(pHuCard);
            LOG_DEBUG(_T("***********ROBOT_BOUT_LOG_HU***********roomid:%d, tableno:%d, userid:%d, chairno:%d, cardchair:%d, cardid:%s"), roomid, tableno, userid, chairno, cardchair,
                pTable->RobotBoutLog(pHuCard->nCardID));
        }
        nTempForCatch = 3;
        BOOL bTemp = pTable->m_HuReady[chairno];
        if (pTable->IsXueLiuRoom())
        {
            bTemp = (nTemp > 0) && (pTable->m_HuReady[chairno]);
        }
        if (bTemp)
        {
            nTempForCatch = 4;

            int nRet = pTable->ShouldHuCardWait(pHuCard);
            if (nRet == 1)
            {
                LOG_DEBUG(" OnSysMsg_AutoHu ShouldHuCardWait = 1");
                return m_pMyServer->NotifyResponseFaild(lpContext);
            }

            nTempForCatch = 5;
            if (nTemp > 0)
            {
                pTable->OnHuAfterWait(pHuCard, nTemp);
            }

            BOOL bOverTime = pTable->OverTimeMultiHu(cardchair);
            pTable->ResetMultiHuInfo();
            for (int i = 0; i < TOTAL_CHAIRS; i++)
            {
                if ((bOverTime && IS_BIT_SET(pTable->m_dwPGCHFlags[i], MJ_HU) && (pTable->m_HuReady[i] && pTable->m_HuReady[i] != MJ_GIVE_UP) && pTable->OnHuFang(i, cardchair, pHuCard->nCardID))
                    || (!bOverTime && pTable->m_HuReady[i] && pTable->m_HuReady[i] != MJ_GIVE_UP && pTable->m_HuMJID[i] == pHuCard->nCardID))
                {
                    LOG_DEBUG(_T("***********ROBOT_BOUT_LOG_HU***********roomid:%d, tableno:%d, userid:%d, chairno:%d, cardchair:%d, cardid:%s, bOverTime: %d"), roomid, tableno, userid, chairno, cardchair,
                        pTable->RobotBoutLog(pHuCard->nCardID), bOverTime);
                    UwlLogFile("AutoHu OverTime XunHuan Hu, chairno is %d, i is %d", chairno, i);
                    pTable->CalcHuPoints(i, cardchair, pHuCard->nCardID);

                    CPlayer* pPlayerHuTemp = pTable->m_ptrPlayers[i];
                    if (pPlayerHuTemp && pPlayerHuTemp->m_nUserID > 0 && IS_BIT_SET(pPlayerHuTemp->m_nUserType, UT_HANDPHONE))
                    {
                        int nHuFan = pTable->m_nResults[i] - g_nHuGains[HU_GAIN_BASE];
                        m_pMyServer->evTaskHu.notify(lpContext, pTable, pPlayerHuTemp->m_nUserID, i, pTable->m_HuReady[i], nHuFan);
                    }

                    //胡番倍数统计 //屁胡算0番？
                    pTable->m_nMultiple[i] = pTable->m_nMultiple[i] + pTable->m_nResults[i] - g_nHuGains[HU_GAIN_BASE];
                    pTable->m_nTimeCost[i] = (GetTickCount() - pTable->m_dwGameStart) / 1000;
                    if (!pTable->IsXueLiuRoom()) //血战房统计胡牌次序
                    {
                        assert(pTable->m_nWinOrder[i] == 0);
                        pTable->m_nWinOrder[i] = *max_element(pTable->m_nWinOrder, pTable->m_nWinOrder + TOTAL_CHAIRS) + 1;
                    }
                    //房统计胡牌次数(用于血流房统计)
                    pTable->m_nHuTimes[i]++;

                    SYSTEMMSG PlayerHu;
                    ZeroMemory(&PlayerHu, sizeof(SYSTEMMSG));
                    PlayerHu.nChairNO = i;
                    PlayerHu.nMsgID = SYSMSG_PLAYER_HU;
                    PlayerHu.nEventID = pTable->m_HuReady[i];
                    PlayerHu.nMJID = pHuCard->nCardID;
                    PlayerHu.nFangCardChairNO = cardchair;

                    m_pMyServer->NotifyTablePlayers(pTable, GR_SYSTEMMSG, &PlayerHu, sizeof(SYSTEMMSG), 0);
                    m_pMyServer->NotifyTableVisitors(pTable, GR_SYSTEMMSG, &PlayerHu, sizeof(SYSTEMMSG), 0);
                }
            }
            
            nTempForCatch = 10;
            pTable->FinishHu(cardchair, chairno, pHuCard->nCardID);
        }
        else
        {
            return m_pMyServer->NotifyResponseFaild(lpContext);
        }
        m_pMyServer->NotifyResponseSucceesd(lpContext);
        nTempForCatch = 11;
        DWORD dwWinFlags = pTable->CalcWinOnHu(chairno);
        if (dwWinFlags)
        {
            nTempForCatch = 12;
            for (int i = 0; i < TOTAL_CHAIRS; i++)
            {
                if (pTable->m_HuReady[i] && pTable->m_HuMJID[i] == pHuCard->nCardID)
                {
                    pTable->m_bLastHuChairs[i] = TRUE;
                }
            }

            if (pTable->IsXueLiuRoom())
            {
                pTable->m_bLastGang = FALSE;
                pTable->CalcWinOnStandOff(-1);
                m_pMyServer->OnGameWin(lpContext, pRoom, pTable, chairno, FALSE, roomid);
            }
            else
            {
                pTable->m_bLastGang = FALSE;
                m_pMyServer->OnGameWin(lpContext, pRoom, pTable, chairno, FALSE, roomid);
            }
        }
        else
        {
            nTempForCatch = 13;
            //XL 胡实时结算
            m_pMyServer->PreSaveResult(lpContext, pTable, roomid, ResultByHu, pHuCard->nChairNO);
            //微信任务
            for (int i = 0; i < TOTAL_CHAIRS; i++)
            {
                if (!pTable->IsXueLiuRoom())
                {
                    CPlayer* pTmpPlayer = pTable->m_ptrPlayers[i];
                    if (pTmpPlayer && pTable->m_HuReady[i] && pTable->m_HuMJID[i] == pHuCard->nCardID)
                    {
                        //m_pMyServer->WxTask_Win(lpContext, pTable, pTmpPlayer->m_nUserID, i);
                    }
                }
                if (pTable->m_HuReady[i] && pTable->m_HuMJID[i] == pHuCard->nCardID)
                {
                    m_pMyServer->evWxTaskHu.notify(lpContext, pTable, i);
                }
            }

            nTempForCatch = 14;
            BOOL bIsAllGiveUp = pTable->IsAllPlayerGiveUp();
            if (bIsAllGiveUp)
            {
                pTable->ResetWaitOpe();
                int nCurrentChair = pTable->GetCurrentChair();
                pTable->RemoveStatusOnGiveUp();
                pTable->m_dwCheckBreakTime[nCurrentChair] = GetTickCount();
                pTable->m_dwWaitOperateTick = (pTable->m_nPGCHWait + SVR_WAIT_SECONDS) * 1000;
                m_pMyServer->NotifyNextTurn(pTable, nCurrentChair);
            }

            nTempForCatch = 15;
            if (IS_BIT_SET(pTable->m_dwStatus, TS_WAITING_GIVEUP))
            {
                m_pMyServer->CreateRobotTimer(pRoom, pTable, pTable->m_dwStatus, pTable->m_nGiveUpTime * 1000);
            }
            else
            {
                m_pMyServer->CreateRobotTimer(pRoom, pTable, pTable->m_dwStatus, pTable->m_nPGCHWait * 1000);
            }
            //掉线自动抓牌
            if (pTable->IsOffline(pTable->GetCurrentChair()))
            {
                m_pMyServer->OnServerAutoPlay(pRoom, pTable, pTable->GetCurrentChair(), !pTable->IsOffline(pTable->GetCurrentChair()));
            }
        }
        //血战房 一炮多响可能多个人的任务会同时完成
        if (!pTable->IsXueLiuRoom())
        {
            for (int i = 0; i < pTable->m_nTotalChairs; i++)
            {
                CPlayer* pTmpPlayer = pTable->m_ptrPlayers[i];
                if (pTmpPlayer && IS_BIT_SET(pTmpPlayer->m_nUserType, UT_HANDPHONE) && pTable->m_HuReady[chairno] > 0 && pTable->m_HuReady[chairno] != MJ_GIVE_UP)
                {
                    //Task_Win(lpContext, pTable, pTmpPlayer->m_nUserID, i);
                    //NewTask_WinDeposit(lpContext, pTable, i);
                    m_pMyServer->evWinDeposit.notify(lpContext, pTable, pTmpPlayer->m_nUserID, i);
                }
            }

        }
        if (!pTable->IsXueLiuRoom())
        {
            for (int i = 0; i < pTable->m_nTotalChairs; i++)
            {
                if (pTable->m_stHuMultiInfo.nHuChair[i] != INVALID_OBJECT_ID)
                {
                    //必须先结算，后面需要用到结算保存的数据
                    pPlayer = pTable->m_ptrPlayers[i];
                    if (pPlayer)
                    {
                        m_pMyServer->SetServerMakeCardInfo(pTable, i);

                        if (IS_BIT_SET(pPlayer->m_nUserType, UT_HANDPHONE))
                        {
                            //新手任务

                            int nLen = pTable->GetGameWinSize() + sizeof(HU_ITEM_HEAD) + pTable->GetTotalItemCount(i) * sizeof(HU_ITEM_INFO)
                                + sizeof(GAMEEND_CHECK_INFO) + sizeof(ABORTPLAYER_INFO) * TOTAL_CHAIRS;
                            void* pData = new_byte_array(nLen);
                            pTable->FillupPlayerHu(pData, nLen, i);
                            int offsetLen = pTable->GetGameWinSize();
                            int itemCount = pTable->GetTotalItemCount(i);
                            pTable->FillupAllHuItems(pData, offsetLen, i, itemCount);
                            int nEndLen = pTable->GetGameWinSize() + sizeof(HU_ITEM_HEAD) + pTable->GetTotalItemCount(i) * sizeof(HU_ITEM_INFO);
                            pTable->FillUpGameWinCheckInfos(pData, nEndLen, chairno);
                            int nGamePlayerInfoOffset = pTable->GetGameWinSize() + sizeof(HU_ITEM_HEAD)
                                + pTable->GetTotalItemCount(i) * sizeof(HU_ITEM_INFO) + sizeof(GAMEEND_CHECK_INFO);
                            pTable->FillupGameStartPlayerInfo(pData, nGamePlayerInfoOffset);
                            m_pMyServer->NotifyOneUser(pPlayer->m_hSocket, pPlayer->m_lTokenID, GR_ON_PLAYER_HU, pData, nLen);
                            //NotifyChairVisitors(pTable, i, GR_ON_PLAYER_HU, pData, nLen);
                            SAFE_DELETE(pData);

                            //旁观
                            if (!pTable->m_mapVisitors[i].empty())
                            {
                                int nTotalCount = 0;
                                int nItemCount[TOTAL_CHAIRS];
                                for (int j = 0; j < TOTAL_CHAIRS; j++)
                                {
                                    nItemCount[j] = pTable->GetTotalItemCount(j);
                                    nTotalCount += nItemCount[j];
                                }

                                int nLenVisitor = pTable->GetGameWinSize() + sizeof(HU_ITEM_HEAD_PC) + nTotalCount * sizeof(HU_ITEM_INFO);
                                void* pDataVisitor = new_byte_array(nLenVisitor);
                                pTable->FillupPlayerHu(pDataVisitor, nLenVisitor, i);

                                offsetLen = pTable->GetGameWinSize();
                                pTable->FillupAllPCHuItems(pDataVisitor, offsetLen, nItemCount);

                                int u_id = 0;
                                CPlayer* ptrV = NULL;
                                auto pos = pTable->m_mapVisitors[i].GetStartPosition();
                                while (pos)
                                {
                                    pTable->m_mapVisitors[i].GetNextAssoc(pos, u_id, ptrV);
                                    if (ptrV && ptrV->m_lTokenID != 0)
                                    {
                                        m_pMyServer->NotifyOneUser(ptrV->m_hSocket, ptrV->m_lTokenID, GR_ON_PLAYER_HU, pDataVisitor, nLenVisitor);
                                    }
                                }
                            }
                        }
                        else
                        {
                            int nTotalCount = 0;
                            int nItemCount[TOTAL_CHAIRS];
                            for (int j = 0; j < TOTAL_CHAIRS; j++)
                            {
                                nItemCount[j] = pTable->GetTotalItemCount(j);
                                nTotalCount += nItemCount[j];
                            }

                            int nLen = pTable->GetGameWinSize() + sizeof(HU_ITEM_HEAD_PC) + nTotalCount * sizeof(HU_ITEM_INFO);
                            void* pData = new_byte_array(nLen);
                            pTable->FillupPlayerHu(pData, nLen, i);

                            int offsetLen = pTable->GetGameWinSize();
                            pTable->FillupAllPCHuItems(pData, offsetLen, nItemCount);

                            m_pMyServer->NotifyOneUser(pPlayer->m_hSocket, pPlayer->m_lTokenID, GR_ON_PLAYER_HU, pData, nLen);
                            m_pMyServer->NotifyChairVisitors(pTable, i, GR_ON_PLAYER_HU, pData, nLen);
                            SAFE_DELETE(pData);
                        }
                    }
                }
            }
        }
        // 模拟完 胡牌消息后，这里需要清除一下等待状态， 不然会不抓牌
        pTable->ResetWaitOpe();
    }
    catch (...)
    {
        UwlLogFile(_T("The Exception LOCAL_GAME_MSG_AUTO_HU nTempForCatch: %d"), nTempForCatch);
    }
    return 0;
}

BOOL MySysMsgToServer::OnSysMsg_AutoGuo(SysMsgOperaPack* pack)
{
    LOG_TRACE(_T("CMJServer::OnReconsGuoCard"));
    LPGUO_CARD pGuoCard = (LPGUO_CARD)pack->pData;
    LOG_DEBUG("OnSysMsg_AutoGuo Start nUseriID: %d", pack->userid);

    auto* pData = pack->pData;
    auto* pRoom = pack->pRoom;
    auto roomid = pack->roomid;
    auto tableno = pack->tableno;
    auto userid = pack->userid;
    auto chairno = pack->chairno;
    auto* lpContext = pack->lpContext;

    CMyGameTable* pTable = static_cast<CMyGameTable*>(pack->pTable);

    if (!IS_BIT_SET(pTable->m_dwStatus, TS_PLAYING_GAME))  // 游戏未在进行中
    {
        LOG_DEBUG("OnSysMsg_AutoGuo not Playing Game");
        return TRUE;
    }

    if (IS_BIT_SET(pTable->m_dwStatus, TS_WAITING_THROW))
    {
        if (!pTable->IsRoboter(chairno))
        {
            // 等待出牌状态
            if (!IS_BIT_SET(pTable->m_dwStatus, MJ_TS_GANG_PN)
                && !IS_BIT_SET(pTable->m_dwStatus, MJ_TS_GANG_MN)
                && !IS_BIT_SET(pTable->m_dwStatus, MJ_TS_GANG_AN))
            {
                LOG_DEBUG("OnSysMsg_AutoGuo waiting throw return");
                return TRUE;
            }
        }
    }
    
    if (!pTable->ValidateChair(chairno))
    {
        LOG_DEBUG("OnSysMsg_AutoGuo ValidateChair");
        return TRUE;
    }

    int nRet = pTable->OnReconsGuo(chairno);
    LOG_DEBUG("OnSysMsg_AutoGuo OnReconsGuo = %d", nRet);
    if (nRet == -1)
    {
        UwlLogFile("[GR_CARD_GUO], chair[%d] cant pass", chairno);
        return FALSE;
    }
    else if (nRet == 0)
    {
        UwlLogFile("some one not pass");
        return TRUE;
    }
    else if (nRet == 1)
    {
        if (m_pMyServer->JudgeGuoCanAutoPlay(pTable->m_nTotalChairs, pTable->m_dwPGCHFlags))
        {
            LOG_DEBUG("OnSysMsg_AutoGuo -> JudgeGuoCanAutoPlay");
            m_pMyServer->OnServerAutoPlay(pRoom, pTable, pTable->GetCurrentChair(), !pTable->IsOffline(pTable->GetCurrentChair()));
        }
    }
    else if (nRet == 2)
    {
        m_pMyServer->OnServerChiPengGangCard(pRoom, pTable);
    }
    return 0;
}

BOOL MySysMsgToServer::OnSysMsg_GameLocalPeng(SysMsgOperaPack* pack)
{
    auto* pData = pack->pData;
    auto* pRoom = pack->pRoom;
    auto roomid = pack->roomid;
    auto tableno = pack->tableno;
    auto userid = pack->userid;
    auto chairno = pack->chairno;
    auto* lpContext = pack->lpContext;

    CMyGameTable* pTable = static_cast<CMyGameTable*>(pack->pTable);
    LPPENG_CARD pPengCard = (LPPENG_CARD)(pData);
    chairno = pPengCard->nChairNO;
    auto cardchair = pPengCard->nCardChair;

    if (!IS_BIT_SET(pTable->m_dwStatus, TS_PLAYING_GAME)) // 游戏未在进行中
    {
        return TRUE;
    }
    if (!pTable->ValidateChair(chairno) || !pTable->ValidateChair(cardchair))
    {
        return TRUE;
    }
    if (!pTable->ValidatePeng(pPengCard))
    {
        return TRUE;
    }
    pTable->OnPeng(pPengCard);
    LOG_DEBUG(_T("***********ROBOT_BOUT_LOG_PENG***********roomid:%d, tableno:%d, userid:%d, chairno:%d, cardchair:%d, cardid:%s, baseid[0]:%s, baseid[1]:%s"), roomid, tableno, userid, chairno, cardchair,
        pTable->RobotBoutLog(pPengCard->nCardID), pTable->RobotBoutLog(pPengCard->nBaseIDs[0]), pTable->RobotBoutLog(pPengCard->nBaseIDs[1]));
    m_pMyServer->NotifyCardPeng(pTable, pPengCard, 0);
    if (pTable->IsRoboter(pTable->GetCurrentChair()))
    {
        m_pMyServer->OnRobotAIPlay(pRoom, pTable, pTable->GetCurrentChair());
    }
    return 0;
}

BOOL MySysMsgToServer::OnSysMsg_GameLocalMnGang(SysMsgOperaPack* pack)
{
    auto* pData = pack->pData;
    auto* pRoom = pack->pRoom;
    auto roomid = pack->roomid;
    auto tableno = pack->tableno;
    auto userid = pack->userid;
    auto chairno = pack->chairno;
    auto* lpContext = pack->lpContext;

    CMyGameTable* pTable = static_cast<CMyGameTable*>(pack->pTable);
    LPGANG_CARD pGangCard = (LPGANG_CARD)(pData);
    chairno = pGangCard->nChairNO;
    auto cardchair = pGangCard->nCardChair;

    if (!IS_BIT_SET(pTable->m_dwStatus, TS_PLAYING_GAME))  // 游戏未在进行中
    {
        return TRUE;
    }
    if (!pTable->ValidateChair(chairno) || !pTable->ValidateChair(cardchair))
    {
        return TRUE;
    }
    if (!pTable->ValidateMnGang(pGangCard))
    {
        return TRUE;
    }
    int nCardID = pTable->GetGangCardEx(chairno);
    int nCardNO = pTable->GetCardNO(nCardID);

    if (INVALID_OBJECT_ID == nCardID)  // 没牌抓了
    {
        m_pMyServer->OnNoCardLeft(pTable, chairno);
        DWORD dwWinFlags = pTable->CalcWinOnStandOff(chairno);
        if (dwWinFlags)
        {
            m_pMyServer->OnGameWin(lpContext, pRoom, pTable, chairno, FALSE, roomid);
        }
    }
    else
    {
        pTable->ResetMultiHuInfo();
        pTable->OnMnGang(pGangCard);
        LOG_DEBUG(_T("***********ROBOT_BOUT_LOG_MNGANG***********roomid:%d, tableno:%d, userid:%d, chairno:%d, cardchair:%d, cardid:%s, baseid[0]:%s, baseid[1]:%s, baseid[2]:%s"), roomid, tableno, userid,
            chairno, cardchair, pTable->RobotBoutLog(pGangCard->nCardID), pTable->RobotBoutLog(pGangCard->nBaseIDs[0]), pTable->RobotBoutLog(pGangCard->nBaseIDs[1]), pTable->RobotBoutLog(pGangCard->nBaseIDs[2]));
        m_pMyServer->CreateRobotTimer(pRoom, pTable, pTable->m_dwStatus, pTable->m_nThrowWait * 1000);
        m_pMyServer->PreSaveResult(lpContext, pTable, roomid, ResultByMnGang, chairno);

        BOOL bIsAllGiveUp = pTable->IsAllPlayerGiveUp();
        if (bIsAllGiveUp)
        {
            BOOL bBuHua = FALSE;
            pTable->GetGangCard(chairno, bBuHua);
            LOG_DEBUG(_T("***********ROBOT_BOUT_LOG_MNGANG_CATCH***********roomid:%d, tableno:%d, chairno:%d, userid:%d, cardid:%s"), roomid, tableno, chairno, userid, pTable->RobotBoutLog(nCardID));
            pGangCard->dwFlags = pTable->CalcHu_Zimo(chairno, nCardID);
            if (pTable->IsRoboter(chairno))
            {
                DWORD dwReturn = 0;
                dwReturn |= pTable->CalcGang(chairno, nCardID, MJ_GANG_AN);
                if (dwReturn != 0)
                {
                    pTable->m_nAIOperateID = LOCAL_GAME_MSG_AN_GANG;
                    pTable->m_nAIOperateChairNO = chairno;
                    pTable->m_nAIOperateCardID = nCardID;
                    pTable->m_nAIOperateCardChairNO = chairno;
                    pTable->m_dwGuoFlags[chairno] |= MJ_GUO;
                }
                dwReturn = 0;
                dwReturn |= pTable->CalcGang(chairno, nCardID, MJ_GANG_PN);
                if (dwReturn != 0)
                {
                    pTable->m_nAIOperateID = LOCAL_GAME_MSG_PN_GANG;
                    pTable->m_nAIOperateChairNO = chairno;
                    pTable->m_nAIOperateCardID = nCardID;
                    pTable->m_nAIOperateCardChairNO = chairno;
                    pTable->m_dwGuoFlags[chairno] |= MJ_GUO;
                }

                if (IS_BIT_SET(pGangCard->dwFlags, MJ_HU))
                {
                    pTable->m_nAIOperateChairNO = chairno;
                    pTable->m_nAIOperateID = LOCAL_GAME_MSG_ZIMO_HU;
                    pTable->m_nAIOperateCardID = nCardID;
                    pTable->m_nAIOperateCardChairNO = cardchair;
                    pTable->m_dwGuoFlags[chairno] |= MJ_GUO;
                }
            }
        }
        else
        {
            nCardID = INVALID_OBJECT_ID;
            nCardNO = INVALID_OBJECT_ID;
        }

        m_pMyServer->NotifyCardMnGang(pTable, pGangCard, nCardID, nCardNO, 0);

        if (pTable->IsRoboter(pTable->GetCurrentChair()))
        {
            LOG_DEBUG("MN_GANG userid:%d Chair:%d\n", userid, pTable->GetCurrentChair());
            m_pMyServer->OnRobotAIPlay(pRoom, pTable, pTable->GetCurrentChair());
        }
    }
    return 0;
}

BOOL MySysMsgToServer::OnSysMsg_GameLocalPnGang(SysMsgOperaPack* pack)
{
    auto* pData = pack->pData;
    auto* pRoom = pack->pRoom;
    auto roomid = pack->roomid;
    auto tableno = pack->tableno;
    auto userid = pack->userid;
    auto chairno = pack->chairno;
    auto* lpContext = pack->lpContext;

    CMyGameTable* pTable = static_cast<CMyGameTable*>(pack->pTable);
    LPGANG_CARD pGangCard = (LPGANG_CARD)(pData);
    chairno = pGangCard->nChairNO;
    auto cardchair = pGangCard->nCardChair;

    if (!IS_BIT_SET(pTable->m_dwStatus, TS_PLAYING_GAME))  // 游戏未在进行中
    {
        return TRUE;
    }
    if (!pTable->ValidateChair(chairno) || !pTable->ValidateChair(cardchair))
    {
        return TRUE;
    }
    if (!pTable->ValidatePnGang(pGangCard))
    {
        return TRUE;
    }
    int nCardID = pTable->GetGangCardEx(chairno);
    int nCardNO = pTable->GetCardNO(nCardID);

    if (INVALID_OBJECT_ID == nCardID)  // 没牌抓了
    {
        m_pMyServer->OnNoCardLeft(pTable, chairno);
        DWORD dwWinFlags = pTable->CalcWinOnStandOff(chairno);
        if (dwWinFlags)
        {
            m_pMyServer->OnGameWin(lpContext, pRoom, pTable, chairno, FALSE, roomid);
        }
    }
    else
    {
        pTable->ResetMultiHuInfo();
        pTable->OnPnGang(pGangCard);
        LOG_DEBUG(_T("***********ROBOT_BOUT_LOG_PNGANG***********roomid:%d, tableno:%d, userid:%d, chairno:%d, cardchair:%d, cardid:%s, baseid[0]:%s, baseid[1]:%s, baseid[2]:%s"), roomid, tableno, userid,
            chairno, cardchair, pTable->RobotBoutLog(pGangCard->nCardID), pTable->RobotBoutLog(pGangCard->nBaseIDs[0]), pTable->RobotBoutLog(pGangCard->nBaseIDs[1]), pTable->RobotBoutLog(pGangCard->nBaseIDs[2]));
        m_pMyServer->CreateRobotTimer(pRoom, pTable, pTable->m_dwStatus, pTable->m_nThrowWait * 1000);
        m_pMyServer->PreSaveResult(lpContext, pTable, roomid, ResultByPnGang, chairno);

        BOOL bIsAllGiveUp = pTable->IsAllPlayerGiveUp();
        if (bIsAllGiveUp)
        {
            BOOL bBuHua = FALSE;
            pTable->GetGangCard(chairno, bBuHua);
            LOG_DEBUG(_T("***********ROBOT_BOUT_LOG_PNGANG_CATCH***********roomid:%d, tableno:%d, chairno:%d, userid:%d, cardid:%s"), roomid, tableno, chairno, userid, pTable->RobotBoutLog(nCardID));
            pGangCard->dwFlags = pTable->CalcHu_Zimo(chairno, nCardID);
            if (pTable->IsRoboter(chairno))
            {
                DWORD dwReturn = 0;
                dwReturn |= pTable->CalcGang(chairno, nCardID, MJ_GANG_AN);
                if (dwReturn != 0)
                {
                    pTable->m_nAIOperateID = LOCAL_GAME_MSG_AN_GANG;
                    pTable->m_nAIOperateChairNO = chairno;
                    pTable->m_nAIOperateCardID = nCardID;
                    pTable->m_nAIOperateCardChairNO = chairno;
                    pTable->m_dwGuoFlags[chairno] |= MJ_GUO;
                }
                dwReturn = 0;
                dwReturn |= pTable->CalcGang(chairno, nCardID, MJ_GANG_PN);
                if (dwReturn != 0)
                {
                    pTable->m_nAIOperateID = LOCAL_GAME_MSG_PN_GANG;
                    pTable->m_nAIOperateChairNO = chairno;
                    pTable->m_nAIOperateCardID = nCardID;
                    pTable->m_nAIOperateCardChairNO = chairno;
                    pTable->m_dwGuoFlags[chairno] |= MJ_GUO;
                }
                if (IS_BIT_SET(pGangCard->dwFlags, MJ_HU))
                {
                    pTable->m_nAIOperateChairNO = chairno;
                    pTable->m_nAIOperateID = LOCAL_GAME_MSG_ZIMO_HU;
                    pTable->m_nAIOperateCardID = nCardID;
                    pTable->m_nAIOperateCardChairNO = cardchair;
                    pTable->m_dwGuoFlags[chairno] |= MJ_GUO;
                }
            }
        }
        else
        {
            nCardID = INVALID_OBJECT_ID;
            nCardNO = INVALID_OBJECT_ID;
        }

        m_pMyServer->NotifyCardPnGang(pTable, pGangCard, nCardID, nCardNO, 0);
        LOG_DEBUG("PN_GANG1111 userid:%d Chair:%d, chairno", userid, pTable->GetCurrentChair(), pTable->m_nAIOperateChairNO);
        if (pTable->IsRoboter(pTable->GetCurrentChair()))
        {
            LOG_DEBUG("PN_GANG2222 userid:%d Chair:%d", userid, pTable->GetCurrentChair());
            m_pMyServer->OnRobotAIPlay(pRoom, pTable, pTable->GetCurrentChair());
        }
    }

    return 0;
}

BOOL MySysMsgToServer::OnSysMsg_GameLocalAnGang(SysMsgOperaPack* pack)
{
    auto* pData = pack->pData;
    auto* pRoom = pack->pRoom;
    auto roomid = pack->roomid;
    auto tableno = pack->tableno;
    auto userid = pack->userid;
    auto chairno = pack->chairno;
    auto* lpContext = pack->lpContext;

    CMyGameTable* pTable = static_cast<CMyGameTable*>(pack->pTable);
    LPGANG_CARD pGangCard = (LPGANG_CARD)(pData);
    chairno = pGangCard->nChairNO;
    auto cardchair = pGangCard->nCardChair;

    if (!IS_BIT_SET(pTable->m_dwStatus, TS_PLAYING_GAME))  // 游戏未在进行中
    {
        return TRUE;
    }
    if (!pTable->ValidateChair(chairno) || !pTable->ValidateChair(cardchair))
    {
        return TRUE;
    }
    if (!pTable->ValidateAnGang(pGangCard))
    {
        return TRUE;
    }
    int nCardID = pTable->GetGangCardEx(chairno);
    int nCardNO = pTable->GetCardNO(nCardID);

    if (INVALID_OBJECT_ID == nCardID)  // 没牌抓了
    {
        m_pMyServer->OnNoCardLeft(pTable, chairno);
        DWORD dwWinFlags = pTable->CalcWinOnStandOff(chairno);
        if (dwWinFlags)
        {
            m_pMyServer->OnGameWin(lpContext, pRoom, pTable, chairno, FALSE, roomid);
        }
    }
    else
    {
        pTable->ResetMultiHuInfo();
        pTable->OnAnGang(pGangCard);
        LOG_DEBUG(_T("***********ROBOT_BOUT_LOG_ANGANG***********roomid:%d, tableno:%d, userid:%d, chairno:%d, cardchair:%d, cardid:%s, baseid[0]:%s, baseid[1]:%s, baseid[2]:%s"), roomid, tableno, userid,
            chairno, cardchair, pTable->RobotBoutLog(pGangCard->nCardID), pTable->RobotBoutLog(pGangCard->nBaseIDs[0]), pTable->RobotBoutLog(pGangCard->nBaseIDs[1]), pTable->RobotBoutLog(pGangCard->nBaseIDs[2]));
        pTable->ResetAIOpe();
        m_pMyServer->CreateRobotTimer(pRoom, pTable, pTable->m_dwStatus, pTable->m_nThrowWait * 1000);
        m_pMyServer->PreSaveResult(lpContext, pTable, roomid, ResultByAnGang, chairno);

        BOOL bIsAllGiveUp = pTable->IsAllPlayerGiveUp();
        if (bIsAllGiveUp)
        {
            BOOL bBuHua = FALSE;
            pTable->GetGangCard(chairno, bBuHua);
            LOG_DEBUG(_T("***********ROBOT_BOUT_LOG_ANGANG_CATCH***********roomid:%d, tableno:%d, chairno:%d, userid:%d, cardid:%s"), roomid, tableno, chairno, userid, pTable->RobotBoutLog(nCardID));
            pGangCard->dwFlags = pTable->CalcHu_Zimo(chairno, nCardID);
            if (pTable->IsRoboter(chairno))
            {
                DWORD dwReturn = 0;
                dwReturn |= pTable->CalcGang(chairno, nCardID, MJ_GANG_AN);
                if (dwReturn != 0)
                {
                    pTable->m_nAIOperateID = LOCAL_GAME_MSG_AN_GANG;
                    pTable->m_nAIOperateChairNO = chairno;
                    pTable->m_nAIOperateCardID = nCardID;
                    pTable->m_nAIOperateCardChairNO = chairno;
                    pTable->m_dwGuoFlags[chairno] |= MJ_GUO;
                }
                dwReturn = 0;
                dwReturn |= pTable->CalcGang(chairno, nCardID, MJ_GANG_PN);
                if (dwReturn != 0)
                {
                    pTable->m_nAIOperateID = LOCAL_GAME_MSG_PN_GANG;
                    pTable->m_nAIOperateChairNO = chairno;
                    pTable->m_nAIOperateCardID = nCardID;
                    pTable->m_nAIOperateCardChairNO = chairno;
                    pTable->m_dwGuoFlags[chairno] |= MJ_GUO;
                }

                if (IS_BIT_SET(pGangCard->dwFlags, MJ_HU))
                {
                    pTable->m_nAIOperateChairNO = chairno;
                    pTable->m_nAIOperateID = LOCAL_GAME_MSG_ZIMO_HU;
                    pTable->m_nAIOperateCardID = nCardID;
                    pTable->m_nAIOperateCardChairNO = cardchair;
                    pTable->m_dwGuoFlags[chairno] |= MJ_GUO;
                }
            }
        }
        else
        {
            nCardID = INVALID_OBJECT_ID;
            nCardNO = INVALID_OBJECT_ID;
        }

        m_pMyServer->NotifyCardAnGang(pTable, pGangCard, nCardID, nCardNO, 0);

        if (pTable->IsRoboter(pTable->GetCurrentChair()))
        {
            LOG_DEBUG("AN_GANG userid:%d Chair:%d\n", userid, pTable->GetCurrentChair());
            m_pMyServer->OnRobotAIPlay(pRoom, pTable, pTable->GetCurrentChair());
        }
    }

    return 0;
}

BOOL MySysMsgToServer::OnSysMsg_GameLocalFixMiss(SysMsgOperaPack* pack)
{
    auto* pData = pack->pData;
    auto* pRoom = pack->pRoom;
    auto roomid = pack->roomid;
    auto tableno = pack->tableno;
    auto userid = pack->userid;
    auto chairno = pack->chairno;
    auto* lpContext = pack->lpContext;

    CMyGameTable* pTable = static_cast<CMyGameTable*>(pack->pTable);
    AUCTION_DINGQUE* pDingquecard = (AUCTION_DINGQUE*)pData;

    if (!IS_BIT_SET(pTable->m_dwStatus, TS_WAITING_AUCTION))
    {
        LOG_TRACE(_T("status not waiting_auction. chair %ld auction banker failed."), chairno);
        return m_pMyServer->NotifyResponseFaild(lpContext);
    }

    if (pTable->m_nDingQueCardType[chairno] != -1)
    {
        LOG_TRACE(_T("LOCAL_GAME_MSG_AUTO_FIXMISS chair %ld, user %ld have auction banker."), chairno, userid);
        return m_pMyServer->NotifyResponseFaild(lpContext);
    }

    BOOL bn = pTable->OnAuctionDingQue(pDingquecard);
    m_pMyServer->NotifyResponseSucceesd(lpContext);

    SYSTEMMSG msg;
    ZeroMemory(&msg, sizeof(SYSTEMMSG));
    msg.nMsgID = SYSMSG_PLAYER_FIXMISS;
    msg.nChairNO = chairno;
    msg.nEventID = pDingquecard->nDingQueCardType[pDingquecard->nChairNO];
    m_pMyServer->NotifySystemMSG(pTable, &msg, -1);

    if (bn)//四家定缺结束
    {
        if (1 == pTable->m_nTakeFeeTime)
        {
            //服务费的通知
            m_pMyServer->NotifyServiceFee(pTable);
        }

        pTable->OnAuctionBanker();
        AUCTION_DINGQUE auctionfinished;
        ZeroMemory(&auctionfinished, sizeof(auctionfinished));
        memcpy(&auctionfinished, pDingquecard, sizeof(AUCTION_DINGQUE));
        memcpy(&auctionfinished.nDingQueCardType, pTable->m_nDingQueCardType, sizeof(pTable->m_nDingQueCardType));
        m_pMyServer->NotifyTablePlayers(pTable, GR_AUCTION_FINISHED, &auctionfinished, sizeof(auctionfinished));
        m_pMyServer->NotifyTableVisitors(pTable, GR_AUCTION_FINISHED, &auctionfinished, sizeof(auctionfinished));

        m_pMyServer->CreateRobotTimer(pRoom, pTable, pTable->m_dwStatus, (pTable->m_nThrowWait + 6) * 1000);

        if (pTable->IsRoboter(pTable->GetCurrentChair()))
        {
            m_pMyServer->OnRobotAIPlay(pRoom, pTable, pTable->GetCurrentChair());
        }
    }
    if (pTable->IsOffline(pTable->GetCurrentChair()))
    {
        m_pMyServer->OnServerAutoPlay(pRoom, pTable, pTable->GetCurrentChair(), !pTable->IsOffline(pTable->GetCurrentChair()));
    }

    return 0;
}
