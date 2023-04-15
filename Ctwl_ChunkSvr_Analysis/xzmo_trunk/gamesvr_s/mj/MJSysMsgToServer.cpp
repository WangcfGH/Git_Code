#include "StdAfx.h"
#include "MJSysMsgToServer.h"

void MJSysMsgToServer::RegsiterSysMsgOpera()
{
    __super::RegsiterSysMsgOpera();

    m_msgid2Opera.insert({ LOCAL_GAME_MSG_CHI, [this](SysMsgOperaPack * pack) {
            return OnSysMsg_GameLocalChi(pack);
        }
    });
    m_msgid2Opera.insert({ LOCAL_GAME_MSG_PENG, [this](SysMsgOperaPack * pack) {
            return OnSysMsg_GameLocalPeng(pack);
        }
    });
    m_msgid2Opera.insert({ LOCAL_GAME_MSG_MN_GANG, [this](SysMsgOperaPack * pack) {
            return OnSysMsg_GameLocalMnGang(pack);
        }
    });
    m_msgid2Opera.insert({ LOCAL_GAME_MSG_PN_GANG, [this](SysMsgOperaPack * pack) {
            return OnSysMsg_GameLocalPnGang(pack);
        }
    });
    m_msgid2Opera.insert({ LOCAL_GAME_MSG_AUTO_THROW, [this](SysMsgOperaPack * pack) {
            return OnSysMsg_GameLocalAutoThrow(pack);
        }
    });
    m_msgid2Opera.insert({ LOCAL_GAME_MSG_AUTO_CATCH, [this](SysMsgOperaPack * pack) {
            return OnSysMsg_GameLocalAutoCatch(pack);
        }
    });
    m_msgid2Opera.insert({ LOCAL_GAME_MSG_QUICK_CATCH, [this](SysMsgOperaPack * pack) {
            return OnSysMsg_GameLocalAutoCatch(pack);
        }
    });

    m_msgid2Opera.insert({ SYSMSG_PLAYER_ONLINE, [this](SysMsgOperaPack * pack) {
            return OnSysMsg_GamePlayerOnline(pack);
        }
    });
    m_msgid2Opera.insert({ SYSMSG_GAME_ON_AUTOPLAY, [this](SysMsgOperaPack * pack) {
            return OnSysMsg_GameAutoPlay(pack);
        }
    });
    m_msgid2Opera.insert({ SYSMSG_GAME_CANCEL_AUTOPLAY, [this](SysMsgOperaPack * pack) {
            return OnSysMsg_GameAutoPlay(pack);
        }
    });
}

BOOL MJSysMsgToServer::OnSysMsg_GameLocalChi(SysMsgOperaPack* pack)
{
    auto* pData = pack->pData;
    CMJTable* pTable = static_cast<CMJTable*>(pack->pTable);
    LPCHI_CARD pChiCard = (LPCHI_CARD)(pData);
    int chairno = pChiCard->nChairNO;
    int cardchair = pChiCard->nCardChair;

    if (!IS_BIT_SET(pTable->m_dwStatus, TS_PLAYING_GAME))  // 游戏未在进行中
    {
        return TRUE;
    }
    if (!pTable->ValidateChair(chairno) || !pTable->ValidateChair(cardchair))
    {
        return TRUE;
    }
    if (!pTable->ValidateChi(pChiCard))
    {
        return TRUE;
    }
    pTable->OnChi(pChiCard);
    m_pMJServer->NotifyCardChi(pTable, pChiCard, 0);
    return TRUE;
}

BOOL MJSysMsgToServer::OnSysMsg_GameLocalPeng(SysMsgOperaPack* pack)
{
    auto* pData = pack->pData;
    auto* pRoom = pack->pRoom;
    auto roomid = pack->roomid;
    auto tableno = pack->tableno;
    auto userid = pack->userid;
    CMJTable* pTable = static_cast<CMJTable*>(pack->pTable);
    LPPENG_CARD pPengCard = (LPPENG_CARD)(pData);
    int chairno = pPengCard->nChairNO;
    int cardchair = pPengCard->nCardChair;


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
    m_pMJServer->NotifyCardPeng(pTable, pPengCard, 0);

    if (pTable->IsRoboter(pTable->GetCurrentChair()))
    {
        m_pMJServer->OnRobotAIPlay(pRoom, pTable, pTable->GetCurrentChair());
    }
    return TRUE;
}

BOOL MJSysMsgToServer::OnSysMsg_GameLocalMnGang(SysMsgOperaPack* pack)
{
    auto* pData = pack->pData;
    auto* pRoom = pack->pRoom;
    auto roomid = pack->roomid;
    auto* lpContext = pack->lpContext;
    CMJTable* pTable = static_cast<CMJTable*>(pack->pTable);
    LPGANG_CARD pGangCard = (LPGANG_CARD)(pData);
    int chairno = pGangCard->nChairNO;
    int cardchair = pGangCard->nCardChair;


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
    BOOL bBuHua = FALSE;
    int nCardID = pTable->GetGangCard(chairno, bBuHua);
    if (bBuHua)
    {
        m_pMJServer->NotifySomeOneBuHua(pTable);
    }
    int nCardNO = pTable->GetCardNO(nCardID);
    if (INVALID_OBJECT_ID == nCardID)  // 没牌抓了
    {
        m_pMJServer->OnNoCardLeft(pTable, chairno);
        DWORD dwWinFlags = pTable->CalcWinOnStandOff(chairno);
        if (dwWinFlags)
        {
            m_pMJServer->OnGameWin(lpContext, pRoom, pTable, chairno, FALSE, roomid);
        }
    }
    else
    {
        pTable->OnMnGang(pGangCard);
        pGangCard->dwFlags = pTable->CalcHu_Zimo(chairno, nCardID);

        m_pMJServer->NotifyCardMnGang(pTable, pGangCard, nCardID, nCardNO, 0);
    }
    return TRUE;
}

BOOL MJSysMsgToServer::OnSysMsg_GameLocalPnGang(SysMsgOperaPack* pack)
{
    auto* pData = pack->pData;
    auto* pRoom = pack->pRoom;
    auto roomid = pack->roomid;
    auto userid = pack->userid;
    auto* lpContext = pack->lpContext;
    CMJTable* pTable = static_cast<CMJTable*>(pack->pTable);

    LPGANG_CARD pGangCard = (LPGANG_CARD)(pData);
    int chairno = pGangCard->nChairNO;
    int cardchair = pGangCard->nCardChair;
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
    BOOL bBuHua = FALSE;
    int nCardID = pTable->GetGangCard(chairno, bBuHua);
    if (bBuHua)
    {
        m_pMJServer->NotifySomeOneBuHua(pTable);
    }
    int nCardNO = pTable->GetCardNO(nCardID);

    if (INVALID_OBJECT_ID == nCardID)  // 没牌抓了
    {
        m_pMJServer->OnNoCardLeft(pTable, chairno);
        DWORD dwWinFlags = pTable->CalcWinOnStandOff(chairno);
        if (dwWinFlags)
        {
            m_pMJServer->OnGameWin(lpContext, pRoom, pTable, chairno, FALSE, roomid);
        }
    }
    else
    {
        pTable->OnPnGang(pGangCard);
        pGangCard->dwFlags = pTable->CalcHu_Zimo(chairno, nCardID);

        m_pMJServer->NotifyCardPnGang(pTable, pGangCard, nCardID, nCardNO, 0);

        LOG_DEBUG("PN_GANG33333 userid:%d Chair:%d\n", userid, pTable->GetCurrentChair());
    }
    return TRUE;
}

BOOL MJSysMsgToServer::OnSysMsg_GameLocalAutoThrow(SysMsgOperaPack* pack)
{
    auto* pData = pack->pData;
    auto* pRoom = pack->pRoom;
    auto roomid = pack->roomid;
    auto* lpContext = pack->lpContext;
    auto bPassive = pack->bPassive;
    CMJTable* pTable = static_cast<CMJTable*>(pack->pTable);

    auto chairno = pack->chairno;

    //弃用传过来的cards,因为延迟函数,传过来的牌不一定还在
    if (!pTable->IsOffline(chairno))
    {
        LOG_ERROR(_T("someone online but server want to throw card!!!"));
        return TRUE;
    }
    int nCardIDs[MAX_CARDS_PER_CHAIR];
    XygInitChairCards(nCardIDs, MAX_CARDS_PER_CHAIR);
    int nCardCount = pTable->GetChairCards(chairno, nCardIDs, MAX_CARDS_PER_CHAIR);
    if (nCardCount)
    {
        THROW_CARDS Card;
        memset(&Card, 0, sizeof(THROW_CARDS));
        XygInitChairCards(Card.nCardIDs, MAX_CARDS_PER_CHAIR);
        Card.nChairNO = chairno;
        Card.dwCardsType = 1;
        Card.nCardsCount = 1;

        //保证出牌不会花和财神
        int cardid = INVALID_OBJECT_ID;
        for (int i = nCardCount - 1; i >= 0; i--)
        {
            if (!pTable->m_pCalclator->MJ_IsHuaEx(nCardIDs[i], pTable->m_nJokerID, pTable->m_nJokerID2, pTable->m_dwGameFlags) &&
                !pTable->m_pCalclator->MJ_IsJokerEx(nCardIDs[i], pTable->m_nJokerID, pTable->m_nJokerID2, pTable->m_dwGameFlags))
            {
                cardid = nCardIDs[i];
                break;
            }
        }

        if (cardid < 0)
        {
            Card.nCardIDs[0] = nCardIDs[0];
        }
        else
        {
            Card.nCardIDs[0] = cardid;
        }

        int nChairNO = Card.nChairNO;
        if (!IS_BIT_SET(pTable->m_dwStatus, TS_PLAYING_GAME))  //游戏未开始，或结束
        {
            LOG_DEBUG(_T("LOCAL_GAME_MSG_AUTO_THROW status is not TS_PLAYING_GAME"));
            return m_pMJServer->NotifyResponseFaild(lpContext);
        }
        if (!IS_BIT_SET(pTable->m_dwStatus, TS_WAITING_THROW))
        {
            LOG_DEBUG(_T("LOCAL_GAME_MSG_AUTO_THROW status is not TS_WAITING_THROW"));
            return m_pMJServer->NotifyResponseFaild(lpContext);
        }
        if (nChairNO != pTable->GetCurrentChair())
        {
            //不该此人出牌!
            LOG_DEBUG(_T("LOCAL_GAME_MSG_AUTO_THROW nChairNO[%d] is not GetCurrentChair[%d]"), nChairNO, pTable->GetCurrentChair());
            return m_pMJServer->NotifyResponseFaild(lpContext);
        }
        if (!pTable->IsCardIDsInHand(chairno, Card.nCardIDs))
        {
            LOG_DEBUG(_T("LOCAL_GAME_MSG_AUTO_THROW is not InHand %d"), Card.nCardIDs[0]);
            return m_pMJServer->NotifyResponseFaild(lpContext);
        }


        // ThrowCard ID validation
        {
            int nValidIDs[MAX_CARDS_PER_CHAIR];
            XygInitChairCards(nValidIDs, MAX_CARDS_PER_CHAIR);
            int ret = pTable->ValidateThrow(nChairNO, Card.nCardIDs, Card.nCardsCount, Card.dwCardsType, nValidIDs);
            if (!bPassive || ret == 0)
            {
                return m_pMJServer->NotifyResponseFaild(lpContext);
            }
        }

        pTable->ThrowCards(nChairNO, Card.nCardIDs);
        pTable->SetWaitingsOnThrow(nChairNO, Card.nCardIDs, Card.dwCardsType);
        pTable->SetStatusOnThrow();
        pTable->SetCurrentChairOnThrow();

        m_pMJServer->NotifyResponseSucceesd(lpContext);
        m_pMJServer->NotifyCardsThrow(pTable, &Card, 0);

        DWORD dwWinFlags = pTable->CalcWinOnThrow(nChairNO, Card.nCardIDs, Card.dwCardsType);
        if (dwWinFlags)
        {
            int bout_time = GetPrivateProfileInt(
                    _T("bout"),         // section name
                    _T("time"),         // key name
                    0,                  // default int
                    m_pMJServer->m_szIniFile         // initialization file name
                );
            BOOL bout_invalid = pTable->IsBoutInvalid(bout_time);
            m_pMJServer->OnGameWin(lpContext, pRoom, pTable, nChairNO, bout_invalid, roomid);
        }

        //掉线自动抓牌
        //if (!dwWinFlags&&pTable->IsOffline(pTable->GetCurrentChair()))
        //服务器自动抓牌
        if (!dwWinFlags)
        {
            m_pMJServer->OnServerAutoPlay(pRoom, pTable, pTable->GetCurrentChair(), !pTable->IsOffline(pTable->GetCurrentChair()));
        }
        //end
    }
    return TRUE;
}

BOOL MJSysMsgToServer::OnSysMsg_GameLocalAutoCatch(SysMsgOperaPack* pack)
{
    auto* pData = pack->pData;
    auto* pRoom = pack->pRoom;
    auto roomid = pack->roomid;
    auto* lpContext = pack->lpContext;
    auto bPassive = pack->bPassive;
    auto* pMsg = pack->pMsg;
    auto chairno = pack->chairno;
    CMJTable* pTable = static_cast<CMJTable*>(pack->pTable);

    //这里需要验证下状态 不然可能会导致 抓两张牌 从而跳过一张牌
    if (!IS_BIT_SET(pTable->m_dwStatus, TS_WAITING_CATCH)) // 不是等待抓牌状态
    {
        LOG_DEBUG(_T("LOCAL_GAME_MSG_QUICK_CATCH status not waiting_catch, chair %ld catch failed. auto: %ld"), chairno, bPassive);
        return FALSE;
    }

    CATCH_CARD& Card = *LPCATCH_CARD(pData);
    int nChairNO = Card.nChairNO;
    int diff = 0;

    if (nChairNO != pTable->GetCurrentChair()) //不该此人抓牌!
    {
        LOG_TRACE(_T("LOCAL_GAME_MSG_QUICK_CATCH current chair not same, chair %ld catch failed. auto: %ld"), chairno, bPassive);
        return FALSE;
    }
    //服务器自动抓牌
    if (!bPassive || 0 == pTable->ValidateAutoCatch(nChairNO, diff, pMsg->nMsgID == LOCAL_GAME_MSG_QUICK_CATCH))
    {
        return m_pMJServer->NotifyResponseFaild(lpContext);
    }
    BOOL bBuHua = FALSE;
    int nCardNO = pTable->CatchCard(nChairNO, bBuHua);
    if (bBuHua)
    {
        m_pMJServer->NotifySomeOneBuHua(pTable);
    }
    if (pTable->m_nJokerNO == nCardNO)  // 抓到翻牌
    {
        bBuHua = FALSE;
        nCardNO = m_pMJServer->OnJokerShownCaught(pTable, nChairNO, bBuHua);
        if (bBuHua)
        {
            m_pMJServer->NotifySomeOneBuHua(pTable);
        }
    }
    if (INVALID_OBJECT_ID == nCardNO)  // 没牌抓了
    {
        m_pMJServer->NotifyResponseFaild(lpContext);

        m_pMJServer->OnNoCardLeft(pTable, nChairNO);
        DWORD winFlags = pTable->CalcWinOnStandOff(nChairNO);
        if (winFlags)
        {
            m_pMJServer->OnGameWin(lpContext, pRoom, pTable, nChairNO, FALSE, roomid);
        }
    }
    else
    {
        CMyGameTable& GameTable = *static_cast<CMyGameTable*>(pTable);
        m_pMJServer->OnCardCaught(pTable, nChairNO);

        m_pMJServer->NotifyResponseSucceesd(lpContext);
        int nCardID = GameTable.GetCardID(nCardNO);
        CARD_CAUGHT tmpCard = { nChairNO, nCardID, nCardNO,
                        GameTable.CalcHu_Zimo(chairno, nCardID)
                    };

        if (((CMJTable*)pTable)->IsTingPaiActive())
        {
            CBuffer buff;
            buff.Write((BYTE*)&tmpCard, sizeof(CARD_CAUGHT));

            if (IS_BIT_SET(pTable->m_dwGameFlags, MJ_GF_16_CARDS))
            {
                pTable->CalcTingCard_17(nChairNO);
                buff.Write((BYTE*)&pTable->m_CardTingDetail_16, sizeof(CARD_TING_DETAIL_16));
            }
            else
            {
                pTable->CalcTingCard(nChairNO);
                buff.Write((BYTE*)&pTable->m_CardTingDetail, sizeof(CARD_TING_DETAIL));
            }

            //bugid:31887
            for (int i = 0; i < pTable->m_nTotalChairs; i++)
            {
                CPlayer* ptrP = pTable->m_ptrPlayers[i];
                if (ptrP && ptrP->m_lTokenID != 0)
                {
                    if (i == tmpCard.nChairNO)
                    {
                        m_pMJServer->NotifyOneUser(ptrP->m_hSocket, ptrP->m_lTokenID, GR_CARD_CAUGHT, buff.GetBuffer(), buff.GetBufferLen());
                    }
                    else
                    {
                        m_pMJServer->NotifyOneUser(ptrP->m_hSocket, ptrP->m_lTokenID, GR_CARD_CAUGHT, &tmpCard, sizeof(tmpCard));
                    }
                }
            }

            m_pMJServer->NotifyTableVisitors(pTable, GR_CARD_CAUGHT, buff.GetBuffer(), buff.GetBufferLen(), 0);
        }
        else
        {
            m_pMJServer->NotifyCardCaught(pTable, &tmpCard, 0);
        }

        //if (pTable->IsOffline(pTable->GetCurrentChair()))
        {
            //服务器自动出牌
            m_pMJServer->OnServerAutoPlay(pRoom, pTable, pTable->GetCurrentChair(), !pTable->IsOffline(pTable->GetCurrentChair()));
        }
    }
    return 0;
}

BOOL MJSysMsgToServer::OnSysMsg_GamePlayerOnline(SysMsgOperaPack* pack)
{
    auto* pData = pack->pData;
    auto* pRoom = pack->pRoom;
    auto roomid = pack->roomid;
    auto* lpContext = pack->lpContext;
    auto bPassive = pack->bPassive;
    auto* pMsg = pack->pMsg;
    auto chairno = pack->chairno;
    auto pPlayer = pack->pPlayer;
    CMJTable* pTable = static_cast<CMJTable*>(pack->pTable);

    if (pTable->IsOffline(chairno))
    {
        //断线续完
        pTable->m_dwUserStatus[chairno] &= ~US_USER_OFFLINE;
        pTable->m_bOffline[chairno] = FALSE;
        /////////////////////////////////////////////////////////////////////////
        NotifyTableMsg(pTable, GAME_MSG_SEND_OTHER, SYSMSG_RETURN_GAME, 4, &pPlayer->m_nChairNO, pPlayer->m_lTokenID);
        /////////////////////////////////////////////////////////////////////////
    }

    return 0;
}

BOOL MJSysMsgToServer::OnSysMsg_GameAutoPlay(SysMsgOperaPack* pack)
{
    auto* pData = pack->pData;
    auto* pRoom = pack->pRoom;
    auto roomid = pack->roomid;
    auto* lpContext = pack->lpContext;
    auto bPassive = pack->bPassive;
    auto* pMsg = pack->pMsg;
    auto chairno = pack->chairno;
    CMJTable* pTable = static_cast<CMJTable*>(pack->pTable);

    if (!pTable->IsAutoPlay(chairno))
    {
        pTable->m_dwUserStatus[chairno] |= US_USER_AUTOPLAY;
        NotifyPlayerMsgAndResponse(lpContext, pTable, GAME_MSG_SEND_EVERYONE, SYSMSG_GAME_ON_AUTOPLAY, sizeof(int), &chairno);
    }
    else
    {
        NotifyPlayerMsgAndResponse(lpContext, pTable, chairno, SYSMSG_GAME_ON_AUTOPLAY, sizeof(int), &chairno);
    }
    return 0;
}

BOOL MJSysMsgToServer::OnSysMsg_GameCancelPlay(SysMsgOperaPack* pack)
{
    auto* pData = pack->pData;
    auto* pRoom = pack->pRoom;
    auto roomid = pack->roomid;
    auto* lpContext = pack->lpContext;
    auto bPassive = pack->bPassive;
    auto* pMsg = pack->pMsg;
    auto chairno = pack->chairno;
    CMJTable* pTable = static_cast<CMJTable*>(pack->pTable);

    if (pTable->IsAutoPlay(chairno))
    {
        pTable->m_dwUserStatus[chairno] &= ~US_USER_AUTOPLAY;
        NotifyPlayerMsgAndResponse(lpContext, pTable, GAME_MSG_SEND_EVERYONE, SYSMSG_GAME_CANCEL_AUTOPLAY, sizeof(int), &chairno);
    }
    else
    {
        NotifyPlayerMsgAndResponse(lpContext, pTable, chairno, SYSMSG_GAME_CANCEL_AUTOPLAY, sizeof(int), &chairno);
    }
    return 0;
}
