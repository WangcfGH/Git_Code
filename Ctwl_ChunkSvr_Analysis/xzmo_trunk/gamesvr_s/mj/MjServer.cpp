#include "stdafx.h"
CMJServer::CMJServer(const TCHAR* szLicenseFile, const TCHAR* szProductName, const TCHAR* szProductVer, const int nListenPort, const int nGameID, DWORD flagEncrypt, DWORD flagCompress)
    : CCommonBaseServer(szLicenseFile, szProductName, szProductVer, nListenPort, nGameID, flagEncrypt, flagCompress)
{
}

CTable* CMJServer::OnNewTable(int roomid, int tableno, int score_mult)
{
    int playerNum = GetChairCount(roomid);
    UwlLogFile("OnNewTable = %d", playerNum);

    CMJTable* pTable = new CMJTable(roomid, tableno, score_mult, playerNum);

    pTable->InitModel();

    evNewTable(pTable);

    return (CTable*)pTable;
}

BOOL CMJServer::OnRequest(void* lpParam1, void* lpParam2)
{
    LPCONTEXT_HEAD  lpContext = LPCONTEXT_HEAD(lpParam1);
    LPREQUEST       lpRequest = LPREQUEST(lpParam2);

    UwlTrace(_T("----------------------start of request process-------------------"));

#if defined(_UWL_TRACE) | defined(UWL_TRACE)
    DWORD dwTimeStart = GetTickCount();
#else
    DWORD dwTimeStart = 0;
#endif
    CWorkerContext* pThreadCxt = reinterpret_cast<CWorkerContext*>(GetWorkerContext());

    assert(lpContext && lpRequest);
    UwlTrace(_T("socket = %ld requesting..."), lpContext->hSocket);
    switch (lpRequest->head.nRequest)
    {
        CASE_REQUEST_HANDLE(GR_CATCH_CARD, OnCatchCard)
        //CASE_REQUEST_HANDLE(GR_GUO_CARD, OnGuoCard)
        CASE_REQUEST_HANDLE(GR_PREPENG_CARD, OnPrePengCard)
        CASE_REQUEST_HANDLE(GR_PREGANG_CARD, OnPreGangCard)
        CASE_REQUEST_HANDLE(GR_PRECHI_CARD, OnPreChiCard)
        //CASE_REQUEST_HANDLE(GR_PENG_CARD, OnPengCard)
        //CASE_REQUEST_HANDLE(GR_CHI_CARD, OnChiCard)
        //CASE_REQUEST_HANDLE(GR_MN_GANG_CARD, OnMnGangCard)
        //CASE_REQUEST_HANDLE(GR_AN_GANG_CARD, OnAnGangCard)
        //CASE_REQUEST_HANDLE(GR_AN_GANG_CARD, OnPnGangCard)
        CASE_REQUEST_HANDLE(GR_HUA_CARD, OnHuaCard)
        CASE_REQUEST_HANDLE(GR_HU_CARD, OnHuCard)
        CASE_REQUEST_HANDLE(GR_AUCTION_BANKER, OnAuctionBanker)
        CASE_REQUEST_HANDLE(GR_THROW_CARDS, OnThrowCards)
        CASE_REQUEST_HANDLE(GR_MERGE_THROWCARDS, onMergeThrowCards)
        //吃碰杠牌重构begin;
        CASE_REQUEST_HANDLE(GR_CHI_CARD, OnReconsChiCard)
        CASE_REQUEST_HANDLE(GR_PENG_CARD, OnReconsPengCard)
        CASE_REQUEST_HANDLE(GR_MN_GANG_CARD, OnReconsMnGangCard)
        CASE_REQUEST_HANDLE(GR_PN_GANG_CARD, OnReconsPnGangCard)
        CASE_REQUEST_HANDLE(GR_AN_GANG_CARD, OnReconsAnGangCard)
        CASE_REQUEST_HANDLE(GR_GUO_CARD, OnReconsGuoCard)

        CASE_REQUEST_HANDLE(GR_RECONS_CHI_CARD, OnReconsChiCard)
        CASE_REQUEST_HANDLE(GR_RECONS_PENG_CARD, OnReconsPengCard)
        CASE_REQUEST_HANDLE(GR_RECONS_MNGANG_CARD, OnReconsMnGangCard)
        CASE_REQUEST_HANDLE(GR_RECONS_PNGANG_CARD, OnReconsPnGangCard)
        CASE_REQUEST_HANDLE(GR_RECONS_ANGANG_CARD, OnReconsAnGangCard)
        CASE_REQUEST_HANDLE(GR_RECONS_GUO_CARD, OnReconsGuoCard)
        //end
        CASE_REQUEST_HANDLE(MJ_GR_PREHU_TINGCARD, onThrowHuTingCards)
    default:
        UwlTrace(_T("goto default proceeding..."));
        __super::OnRequest(lpParam1, lpParam2);
        break;
    }
    UwlClearRequest(lpRequest);

#if defined(_UWL_TRACE) | defined(UWL_TRACE)
    DWORD dwTimeEnd = GetTickCount();
#else
    DWORD dwTimeEnd = 0;
#endif
    UwlTrace(_T("request process time costs: %d ms"), dwTimeEnd - dwTimeStart);
    UwlTrace(_T("----------------------end of request process---------------------\r\n"));

    return TRUE;
}

BOOL CMJServer::ConstructEnterGameDXXW(int roomid, CTable* pTable, int chairno, int userid, BOOL lookon, LPREQUEST lpResponse)
{
    if (!pTable)
    {
        return FALSE;
    }

    BOOL ret = __super::ConstructEnterGameDXXW(roomid, pTable, chairno, userid, lookon, lpResponse);

    // 在尾部追加听牌提示结构
    CPlayer* pPlayer = pTable->m_ptrPlayers[chairno];
    if (ret && !lookon && pPlayer
        && IS_BIT_SET(pPlayer->m_nUserType, UT_HANDPHONE)
        && IsSoloRoom(roomid) && ((CMJTable*)pTable)->IsTingPaiActive())
    {
        int tableinfo_size = pTable->GetGameTableInfoSize();
        int nLen = tableinfo_size + sizeof(SOLOPLAYER_HEAD) + pTable->GetPlayerCountOnTable() * sizeof(SOLO_PLAYER);
        int nLenAddTingDetail = nLen;
        if (IS_BIT_SET(((CMJTable*)pTable)->m_dwGameFlags, MJ_GF_16_CARDS))
        {
            nLenAddTingDetail = nLen + sizeof(CARD_TING_DETAIL_16);

            LPVOID temp = lpResponse->pDataPtr;
            lpResponse->pDataPtr = new_byte_array(nLenAddTingDetail, 0);
            memcpy(lpResponse->pDataPtr, temp, nLen);
            SAFE_DELETE_ARRAY(temp);

            lpResponse->nDataLen = nLenAddTingDetail;

            ((CMJTable*)pTable)->CalcTingCard_17(chairno);
            PBYTE ptr_tingDetail = (PBYTE)lpResponse->pDataPtr + nLen;
            memcpy(ptr_tingDetail, &(((CMJTable*)pTable)->m_CardTingDetail_16), sizeof(CARD_TING_DETAIL_16));
        }
        else
        {
            nLenAddTingDetail = nLen + sizeof(CARD_TING_DETAIL);

            LPVOID temp = lpResponse->pDataPtr;
            lpResponse->pDataPtr = new_byte_array(nLenAddTingDetail, 0);
            memcpy(lpResponse->pDataPtr, temp, nLen);
            SAFE_DELETE_ARRAY(temp);

            lpResponse->nDataLen = nLenAddTingDetail;

            ((CMJTable*)pTable)->CalcTingCard(chairno);
            PBYTE ptr_tingDetail = (PBYTE)lpResponse->pDataPtr + nLen;
            memcpy(ptr_tingDetail, &(((CMJTable*)pTable)->m_CardTingDetail), sizeof(CARD_TING_DETAIL));
        }
    }
    return ret;
}

BOOL CMJServer::OnCPHandCardInfoToLooker(int roomid, CPlayer* pPlayer, CPlayer* pLooker, CTable* pTable)
{
    CARDS_INFO cardsinfo;
    ZeroMemory(&cardsinfo, sizeof(cardsinfo));
    cardsinfo.nUserID = pPlayer->m_nUserID;
    cardsinfo.nChairNO = pPlayer->m_nChairNO;
    XygInitChairCards(cardsinfo.nCardIDs, MAX_CARDS_PER_CHAIR);
    cardsinfo.nCardsCount = ((CMJTable*)pTable)->GetChairCards(pPlayer->m_nChairNO, cardsinfo.nCardIDs, COUNT_OF(cardsinfo.nCardIDs));

    NotifyOneUser(pLooker->m_hSocket, pLooker->m_lTokenID, GR_CARDS_INFO, &cardsinfo,
        sizeof(cardsinfo) - sizeof(int) * (MAX_CARDS_PER_CHAIR - cardsinfo.nCardsCount));
    return TRUE;
}

BOOL CMJServer::OnAuctionBanker(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt)
{
    LOG_TRACE(_T("CMJServer::OnAuctionBanker"));
    REQUEST response;
    memset(&response, 0, sizeof(response));

    SOCKET sock = lpContext->hSocket;
    LONG token = lpContext->lTokenID;

    SAFETY_NET_REQUEST(lpRequest, AUCTION_BANKER, pAuctionBanker);
    int roomid = pAuctionBanker->nRoomID;
    int tableno = pAuctionBanker->nTableNO;
    int userid = pAuctionBanker->nUserID;
    int chairno = pAuctionBanker->nChairNO;
    CRoom* pRoom = NULL;
    CMJTable* pTable = NULL;

    if (!(pRoom = GetRoomPtr(roomid)))
    {
        return NotifyResponseFaild(lpContext);
    }

    if (!(pTable = (CMJTable*)GetTablePtr(roomid, tableno)))
    {
        return NotifyResponseFaild(lpContext);
    }
    if (pTable)
    {
        LOCK_TABLE(pTable, chairno, FALSE, userid, token);

        if (!pTable->IsPlayer(userid)) // 不是玩家
        {
            UwlLogFile(_T("user not player. user %ld auction banker failed."), userid);
            return NotifyResponseFaild(lpContext);
        }
        if (!IS_BIT_SET(pTable->m_dwStatus, TS_PLAYING_GAME)) //游戏未开始，或结束
        {
            return NotifyResponseFaild(lpContext);
        }

        UwlTrace(_T("chair %ld, user %ld auction banker."), chairno, userid);
        if (!IS_BIT_SET(pTable->m_dwStatus, TS_WAITING_AUCTION))
        {
            UwlLogFile(_T("status not waiting_auction. chair %ld auction banker failed."), chairno);
            return NotifyResponseFaild(lpContext);
        }
        if (chairno != pTable->GetCurrentChair()) //不该此人叫庄!
        {
            LOG_TRACE(_T("current chair not same, chair %ld auction failed. "), chairno);
            return NotifyResponseFaild(lpContext);
        }
        int auction_finished = 0;
        if (!pTable->OnAuctionBanker(pAuctionBanker, auction_finished))
        {
            UwlLogFile(_T("OnAuctionBanker() return FALSE. chair %ld auction banker failed."), chairno);
            return NotifyResponseFaild(lpContext);
        }

        response.head.nRequest = UR_OPERATE_SUCCEEDED;
        SendUserResponse(lpContext, &response);
        if (2 == auction_finished) // 游戏结束
        {
            DWORD dwWinFlags = pTable->CalcWinOnStandOff(chairno);
            if (dwWinFlags)
            {
                OnGameWin(lpContext, pRoom, pTable, chairno, TRUE, roomid);
            }
        }
        else if (1 == auction_finished)  // 叫庄结束
        {
            if (pTable->OnAuctionFinished())
            {
                // 事件分发
                evMJAuctionBanker.notify(pTable, pAuctionBanker, auction_finished);

                NotifyAuctionFinished(pTable, pAuctionBanker);
            }
        }
        else
        {
            // 事件分发
            evMJAuctionBanker.notify(pTable, pAuctionBanker, auction_finished);

            NotifyAuctionBanker(pTable, pAuctionBanker, token);
        }
    }
    return TRUE;
}

BOOL CMJServer::OnCatchCard(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt)
{
    LOG_TRACE(_T("CMJServer::OnCatchCard"));
    SAFETY_NET_REQUEST(lpRequest, CATCH_CARD, pCatchCard);
    REQUEST response;
    memset(&response, 0, sizeof(response));

    SOCKET sock = lpContext->hSocket;
    LONG token = lpContext->lTokenID;

    int roomid = pCatchCard->nRoomID;
    int tableno = pCatchCard->nTableNO;
    int userid = pCatchCard->nUserID;
    int chairno = pCatchCard->nChairNO;

    LPSENDER_INFO pSenderInfo = LPSENDER_INFO(&(pCatchCard->sender_info));
    BOOL bPassive = (chairno != pSenderInfo->nSendChair) ? TRUE : FALSE;

    if (bPassive && !IsSupportPassive())
    {
        return NotifyResponseFaild(lpContext, bPassive);
    }

    CRoom* pRoom = NULL;
    CMJTable* pTable = NULL;
    if (!(pRoom = GetRoomPtr(roomid)))
    {
        return NotifyResponseFaild(lpContext, bPassive);
    }

    if (!(pTable = (CMJTable*)GetTablePtr(roomid, tableno)))
    {
        return NotifyResponseFaild(lpContext, bPassive);
    }

    if (pTable)
    {
        LOCK_TABLE(pTable, chairno, bPassive, pSenderInfo->nSendUser, token);

        if (!pTable->IsPlayer(userid)) // 不是玩家
        {
            UwlLogFile(_T("user not player. user %ld catch card failed. auto: %ld"), userid, bPassive);
            return NotifyResponseFaild(lpContext, bPassive);
        }
        UwlTrace(_T("chair %ld, user %ld catch card. auto: %ld"), chairno, userid, bPassive);
        if (bPassive)
        {
            sock = pTable->m_ptrPlayers[chairno]->m_hSocket;
            token = pTable->m_ptrPlayers[chairno]->m_lTokenID;
        }

        if (!IS_BIT_SET(pTable->m_dwStatus, TS_PLAYING_GAME)) //游戏未开始，或结束
        {
            return NotifyResponseFaild(lpContext, bPassive);
        }

        if (!IS_BIT_SET(pTable->m_dwStatus, TS_WAITING_CATCH)) // 不是等待抓牌状态
        {
            LOG_DEBUG(_T("status not waiting_catch, chair %ld catch failed. auto: %ld"), chairno, bPassive);
            return NotifyResponseFaild(lpContext, bPassive);
        }
        if (chairno != pTable->GetCurrentChair()) //不该此人抓牌!
        {
            LOG_TRACE(_T("current chair not same, chair %ld catch failed. auto: %ld"), chairno, bPassive);
            return NotifyResponseFaild(lpContext, bPassive);
        }
        if (bPassive)
        {
            int diff = 0;
            if (!pTable->ValidateAutoCatch(chairno, diff))
            {
                UwlLogFile(_T("time not exceeded, chair %ld autocatch failed. auto: %ld, diff: %ld"), chairno, bPassive, diff);
                return NotifyResponseFaild(lpContext, bPassive);
            }
            pTable->m_nAutoCount[chairno]++;
            if (pTable->m_nAutoCount[chairno] >= pTable->m_nMaxAutoThrow)
            {
                if (OnTooManyAuto(userid, roomid, tableno, chairno, sock, token))
                {
                    return NotifyResponseFaild(lpContext, bPassive);
                }
            }
        }
        else
        {
            if (0 == pTable->ValidateCatch(chairno))
            {
                UwlLogFile(_T("ValidateCatch() return 0, chair %ld catch failed. auto: %ld"), chairno, bPassive);
                return NotifyResponseFaild(lpContext, bPassive);
            }
        }
        BOOL bBuHua = FALSE;
        int current_catch = pTable->CatchCard(chairno, bBuHua);
        if (bBuHua)
        {
            NotifySomeOneBuHua(pTable);
        }
        if (pTable->m_nJokerNO == current_catch) // 抓到翻牌
        {
            bBuHua = FALSE;
            current_catch = OnJokerShownCaught(pTable, chairno, bBuHua);
            if (bBuHua)
            {
                NotifySomeOneBuHua(pTable);
            }
        }
        if (INVALID_OBJECT_ID == current_catch) // 没牌抓了
        {
            response.head.nRequest = GR_NO_CARD_CATCH;
            SendUserResponse(lpContext, &response, bPassive);

            OnNoCardLeft(pTable, chairno);
            DWORD dwWinFlags = pTable->CalcWinOnStandOff(chairno);
            if (dwWinFlags)
            {
                OnGameWin(lpContext, pRoom, pTable, chairno, FALSE, roomid);
            }
        }
        else
        {
            OnCardCaught(pTable, chairno);

            CARD_CAUGHT card_caught;
            ZeroMemory(&card_caught, sizeof(card_caught));
            card_caught.nChairNO = chairno;
            card_caught.nCardID = pTable->GetCardID(current_catch);
            card_caught.nCardNO = current_catch;
            card_caught.dwFlags = pTable->CalcHu_Zimo(chairno, card_caught.nCardID);
            LOG_DEBUG(_T("***********ROBOT_BOUT_LOG_CATCH***********roomid:%d, tableno:%d, chairno:%d, userid:%d, 牌张：%s"), roomid, tableno, chairno, userid, pTable->RobotBoutLog(card_caught.nCardID));
            CBuffer buff;
            buff.Write((BYTE*)&card_caught, sizeof(CARD_CAUGHT));

            if (((CMJTable*)pTable)->IsTingPaiActive())
            {
                if (IS_BIT_SET(pTable->m_dwGameFlags, MJ_GF_16_CARDS))
                {
                    pTable->CalcTingCard_17(card_caught.nChairNO);
                    buff.Write((BYTE*) & (pTable->m_CardTingDetail_16), sizeof(CARD_TING_DETAIL_16));
                }
                else
                {
                    pTable->CalcTingCard(card_caught.nChairNO);
                    buff.Write((BYTE*) & (pTable->m_CardTingDetail), sizeof(CARD_TING_DETAIL));
                }
            }

            // 事件分发
            evMJCatch.notify(pTable, pCatchCard, &card_caught);

            response.pDataPtr = buff.GetBuffer();
            response.nDataLen = buff.GetBufferLen();
            response.head.nRequest = UR_OPERATE_SUCCEEDED;
            SendUserResponse(lpContext, &response, bPassive);

            UwlTrace(_T("chair %ld, user %ld catch OK! cardid: %ld, currentcatch: %ld, auto: %ld"), chairno, userid, card_caught.nCardID, current_catch, bPassive);
            if (bPassive)
            {
                if (IsServerAutoCatch())
                {
                    NotifyCardCaught(pTable, &card_caught, token);
                    //ServerAutoOperate(chairno, pRoom, pTable);
                }
                else
                {
                    NotifyCardCaught(pTable, &card_caught, 0);
                }
            }
            else
            {
                NotifyCardCaught(pTable, &card_caught, token);
            }
        }
    }
    return TRUE;
}

BOOL CMJServer::OnThrowCards(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt)
{
    if (lpRequest->nDataLen <= (sizeof(THROW_CARDS) - sizeof(int)*MAX_CARDS_PER_CHAIR))
    {
        return NotifyResponseFaild(lpContext);
    }

    // 客户端与服务端结构体不一致， 不能用SAFETY_NET_REQUEST
    THROW_CARDS throwcards;
    ZeroMemory(&throwcards, sizeof(throwcards));
    XygInitChairCards(throwcards.nCardIDs, MAX_CARDS_PER_CHAIR);
    memcpy(&throwcards, lpRequest->pDataPtr, lpRequest->nDataLen);
    LPTHROW_CARDS pThrowCards = &throwcards;

    REQUEST response;
    memset(&response, 0, sizeof(response));

    SOCKET sock = lpContext->hSocket;
    LONG token = lpContext->lTokenID;

    int roomid = pThrowCards->nRoomID;
    int tableno = pThrowCards->nTableNO;
    int userid = pThrowCards->nUserID;
    int chairno = pThrowCards->nChairNO;

    LPSENDER_INFO pSenderInfo = LPSENDER_INFO(&(pThrowCards->sender_info));
    BOOL bPassive = (chairno != pSenderInfo->nSendChair) ? TRUE : FALSE;

    if (bPassive && !IsSupportPassive())
    {
        return NotifyResponseFaild(lpContext, bPassive);
    }

    CRoom* pRoom = NULL;
    CMJTable* pTable = NULL;
    if (!(pRoom = GetRoomPtr(roomid)))
    {
        return NotifyResponseFaild(lpContext, bPassive);
    }

    if (!(pTable = (CMJTable*)GetTablePtr(roomid, tableno)))
    {
        return NotifyResponseFaild(lpContext, bPassive);
    }

    if (pTable)
    {
        LOCK_TABLE(pTable, chairno, bPassive, pSenderInfo->nSendUser, token);

        if (!pTable->IsPlayer(userid)) // 不是玩家
        {
            UwlLogFile(_T("user not player. user %ld throw cards failed. auto: %ld"), userid, bPassive);
            return NotifyResponseFaild(lpContext, bPassive);
        }
        UwlTrace(_T("chair %ld, user %ld throw cards. auto: %ld"), chairno, userid, bPassive);
        if (bPassive)
        {
            sock = pTable->m_ptrPlayers[chairno]->m_hSocket;
            token = pTable->m_ptrPlayers[chairno]->m_lTokenID;
        }

        if (!IS_BIT_SET(pTable->m_dwStatus, TS_PLAYING_GAME)) //游戏未开始，或结束
        {
            return NotifyResponseFaild(lpContext, bPassive);
        }

        if (!IS_BIT_SET(pTable->m_dwStatus, TS_WAITING_THROW)) // 不是等待出牌状态
        {
            UwlLogFile(_T("status not waiting_throw, chair %ld throw failed. auto: %ld"), chairno, bPassive);
            return NotifyResponseFaild(lpContext, bPassive);
        }
        if (chairno != pTable->GetCurrentChair()) //不该此人出牌!
        {
            LOG_TRACE(_T("current chair not same, chair %ld throw failed. auto: %ld"), chairno, bPassive);
            return NotifyResponseFaild(lpContext, bPassive);
        }
        if (bPassive)
        {
            if (!pTable->ValidateAutoThrow(chairno))
            {
                UwlLogFile(_T("time not exceeded, chair %ld autothrow failed. auto: %ld"), chairno, bPassive);
                return NotifyResponseFaild(lpContext, bPassive);
            }
            pTable->m_nAutoCount[chairno]++;
            if (pTable->m_nAutoCount[chairno] >= pTable->m_nMaxAutoThrow)
            {
                if (OnTooManyAuto(userid, roomid, tableno, chairno, sock, token))
                {
                    return NotifyResponseFaild(lpContext, bPassive);
                }
            }
            if (!pTable->ReplaceAutoThrow(pThrowCards))
            {
                UwlLogFile(_T("ReplaceAutoThrow() failed. chair %ld. auto: %ld"), chairno, bPassive);
                return NotifyResponseFaild(lpContext, bPassive);
            }
        }
        if (!pTable->IsCardIDsInHand(chairno, pThrowCards->nCardIDs))
        {
            UwlLogFile(_T("cards not in hand! roomid = %ld, tableno = %ld, chairno = %ld, userid = %ld. cardid = %ld, auto: %ld"),
                roomid, tableno, chairno, userid, pThrowCards->nCardIDs[0], bPassive);
            return NotifyResponseFaild(lpContext, bPassive);
        }
        if (0 == pThrowCards->dwCardsType)
        {
            UwlLogFile(_T("wrong type of cards! chair %ld throw failed. auto: %ld "), chairno, bPassive);
            return NotifyResponseFaild(lpContext, bPassive);
        }
        if (0 == pThrowCards->nCardsCount)
        {
            UwlLogFile(_T("zero count of cards! chair %ld throw failed. auto: %ld "), chairno, bPassive);
            return NotifyResponseFaild(lpContext, bPassive);
        }
        int nValidIDs[MAX_CARDS_PER_CHAIR];
        XygInitChairCards(nValidIDs, MAX_CARDS_PER_CHAIR);
        int rt = pTable->ValidateThrow(chairno, pThrowCards->nCardIDs,
                pThrowCards->nCardsCount, pThrowCards->dwCardsType, nValidIDs);
        if (0 == rt)
        {
            UwlLogFile(_T("ValidateThrow() return 0. chair %ld throw failed. auto: %ld "), chairno, bPassive);
            return NotifyResponseFaild(lpContext, bPassive);
        }
        else if (rt < 0)
        {
            UwlLogFile(_T("ValidateThrow() return -1. chair %ld throw failed. auto: %ld "), chairno, bPassive);
            NotifyInvalidThrow(pTable, pThrowCards, token);
            return ResponseThrowAgain(lpContext, nValidIDs, bPassive);
        }
        UwlTrace(_T("chair %ld, user %ld throw OK! cardid: %ld, auto: %ld"),
            chairno, userid, pThrowCards->nCardIDs[0], bPassive);
        if (!pTable->ThrowCards(chairno, pThrowCards->nCardIDs))
        {
            LOG_ERROR(_T("pTable->ThrowCards error"));
            return NotifyResponseFaild(lpContext, bPassive);
        }

        pTable->SetWaitingsOnThrow(chairno, pThrowCards->nCardIDs, pThrowCards->dwCardsType);

        pTable->SetStatusOnThrow();
        pTable->SetCurrentChairOnThrow();

        ResponseThrowCardSucceed(response, lpContext, pTable, pThrowCards, bPassive);
        if (bPassive)
        {
            NotifyCardsThrow(pTable, pThrowCards, GR_CARDS_THROW, 0);
            if (IsServerAutoCatch())
            {
                //ServerAutoOperate(chairno, pRoom, pTable);
            }
        }
        else
        {
            NotifyCardsThrow(pTable, pThrowCards, GR_CARDS_THROW, token);
        }
        if (0 == pTable->HaveCards(chairno)) // 自己手里牌已出完
        {
            pTable->OnNoCardRemains(chairno);
            OnNoCardRemains(pTable, chairno);
        }
        DWORD dwWinFlags = pTable->CalcWinOnThrow(chairno, pThrowCards->nCardIDs, pThrowCards->dwCardsType);
        if (dwWinFlags)
        {
            BOOL bout_invalid = pTable->IsBoutInvalid(GetBoutTimeMin());
            OnGameWin(lpContext, pRoom, pTable, chairno, bout_invalid, roomid);
        }
        if (IsServerAutoCatch())
        {
            //服务端自动抓牌
            if (!dwWinFlags)
            {
                OnServerAutoPlay(pRoom, pTable, pTable->GetCurrentChair(), !pTable->IsOffline(pTable->GetCurrentChair()));
            }
            //end
        }
    }
    return TRUE;
}

void CMJServer::ResponseThrowCardSucceed(REQUEST response, LPCONTEXT_HEAD lpContext, CMJTable* pTable, LPTHROW_CARDS pThrowCards, BOOL bPassive)
{
    THROW_OK throwOK;
    ZeroMemory(&throwOK, sizeof(throwOK));
    throwOK.nNextChair = pTable->GetCurrentChair();
    throwOK.bNextFirst = pTable->IsNextFirstHand();
    response.head.nRequest = UR_OPERATE_SUCCEEDED;
    response.pDataPtr = &throwOK;
    response.nDataLen = sizeof(throwOK);
    SendUserResponse(lpContext, &response, bPassive);

    pTable->SaveTingCardsForDXXW(pThrowCards->nCardIDs[0], pThrowCards->nChairNO);
}

BOOL CMJServer::OnPreChiCard(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt)
{
    LOG_TRACE(_T("CMJServer::OnPreChiCard"));
    SAFETY_NET_REQUEST(lpRequest, PRECHI_CARD, pPreChiCard);

    LONG token = lpContext->lTokenID;
    int roomid = pPreChiCard->nRoomID;
    int tableno = pPreChiCard->nTableNO;
    int userid = pPreChiCard->nUserID;
    int chairno = pPreChiCard->nChairNO;
    int cardchair = pPreChiCard->nCardChair;

    CMJTable* pTable = NULL;
    if (!(pTable = (CMJTable*)GetTablePtr(roomid, tableno)))
    {
        return TRUE;
    }
    if (pTable)
    {
        LOCK_TABLE(pTable, chairno, FALSE, userid, token);

        if (!pTable->IsPlayer(userid)) // 不是玩家
        {
            UwlLogFile(_T("user not player. user %ld prechi card failed."), userid);
            return TRUE;
        }
        if (!IS_BIT_SET(pTable->m_dwStatus, TS_PLAYING_GAME)) // 游戏未在进行中
        {
            return TRUE;
        }
        if (!pTable->ValidateChair(chairno) || !pTable->ValidateChair(cardchair))
        {
            return TRUE;
        }
        if (chairno != pTable->GetCurrentChair()) //不该此人抓牌!
        {
            LOG_TRACE(_T("current chair not same, chair %ld prechi failed."), chairno);
        }
        if (!pTable->ValidatePreChi(pPreChiCard))
        {
            return TRUE;
        }
        pTable->OnPreChi(pPreChiCard);

        pTable->SetActionBegin();

        NotifyCardPreChi(pTable, pPreChiCard, token);
    }
    return TRUE;
}

BOOL CMJServer::OnChiCard(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt)
{
    LOG_TRACE(_T("CMJServer::OnChiCard"));
    SAFETY_NET_REQUEST(lpRequest, CHI_CARD, pChiCard);
    REQUEST response;
    memset(&response, 0, sizeof(response));

    LONG token = lpContext->lTokenID;
    int roomid = pChiCard->nRoomID;
    int tableno = pChiCard->nTableNO;
    int userid = pChiCard->nUserID;
    int chairno = pChiCard->nChairNO;
    int cardchair = pChiCard->nCardChair;

    CMJTable* pTable = NULL;
    BOOL bPassive = FALSE;
    if (!(pTable = (CMJTable*)GetTablePtr(roomid, tableno)))
    {
        return NotifyResponseFaild(lpContext, bPassive);
    }
    if (pTable)
    {
        LOCK_TABLE(pTable, chairno, FALSE, userid, token);

        if (!pTable->IsPlayer(userid)) // 不是玩家
        {
            UwlLogFile(_T("user not player. user %ld chi card failed."), userid);
            return NotifyResponseFaild(lpContext, bPassive);
        }
        if (!IS_BIT_SET(pTable->m_dwStatus, TS_PLAYING_GAME)) // 游戏未在进行中
        {
            return NotifyResponseFaild(lpContext, bPassive);
        }
        if (!pTable->ValidateChair(chairno) || !pTable->ValidateChair(cardchair))
        {
            return NotifyResponseFaild(lpContext, bPassive);
        }
        if (pTable->ShouldChiWait(pChiCard))
        {
            response.head.nRequest = GR_WAIT_FEW_SECONDS;
            return SendUserResponse(lpContext, &response, bPassive);
        }
        if (!pTable->ValidateChi(pChiCard))
        {
            return NotifyResponseFaild(lpContext, bPassive);
        }
        pTable->OnChi(pChiCard);

        if (((CMJTable*)pTable)->IsTingPaiActive())
        {
            if (IS_BIT_SET(pTable->m_dwGameFlags, MJ_GF_16_CARDS))
            {
                pTable->CalcTingCard_17(pChiCard->nChairNO);
                response.pDataPtr = &(pTable->m_CardTingDetail_16);
                response.nDataLen = sizeof(CARD_TING_DETAIL_16);
            }
            else
            {
                pTable->CalcTingCard(pChiCard->nChairNO);
                response.pDataPtr = &(pTable->m_CardTingDetail);
                response.nDataLen = sizeof(CARD_TING_DETAIL);
            }
        }
        else
        {
            response.pDataPtr = NULL;
            response.nDataLen = 0;
        }

        response.head.nRequest = UR_OPERATE_SUCCEEDED;
        SendUserResponse(lpContext, &response, bPassive);

        NotifyCardChi(pTable, pChiCard, token);
    }
    return TRUE;
}

BOOL CMJServer::OnPrePengCard(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt)
{
    LOG_TRACE(_T("CMJServer::OnPrePengCard"));
    SAFETY_NET_REQUEST(lpRequest, PREPENG_CARD, pPrePengCard);

    LONG token = lpContext->lTokenID;
    int roomid = pPrePengCard->nRoomID;
    int tableno = pPrePengCard->nTableNO;
    int userid = pPrePengCard->nUserID;
    int chairno = pPrePengCard->nChairNO;
    int cardchair = pPrePengCard->nCardChair;

    CMJTable* pTable = NULL;
    if (!(pTable = (CMJTable*)GetTablePtr(roomid, tableno)))
    {
        return TRUE;
    }

    if (pTable)
    {
        LOCK_TABLE(pTable, chairno, FALSE, userid, token);

        if (!pTable->IsPlayer(userid)) // 不是玩家
        {
            UwlLogFile(_T("user not player. user %ld prepeng card failed."), userid);
            return TRUE;
        }
        if (!IS_BIT_SET(pTable->m_dwStatus, TS_PLAYING_GAME)) // 游戏未在进行中
        {
            return TRUE;
        }
        if (!pTable->ValidateChair(chairno) || !pTable->ValidateChair(cardchair))
        {
            return TRUE;
        }
        if (!pTable->ValidatePrePeng(pPrePengCard))
        {
            return TRUE;
        }
        pTable->OnPrePeng(pPrePengCard);

        NotifyCardPrePeng(pTable, pPrePengCard, token);
    }
    return TRUE;
}

BOOL CMJServer::OnPengCard(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt)
{
    LOG_TRACE(_T("CMJServer:OnPengCard"));
    SAFETY_NET_REQUEST(lpRequest, PENG_CARD, pPengCard);

    REQUEST response;
    memset(&response, 0, sizeof(response));

    LONG token = lpContext->lTokenID;
    int roomid = pPengCard->nRoomID;
    int tableno = pPengCard->nTableNO;
    int userid = pPengCard->nUserID;
    int chairno = pPengCard->nChairNO;
    int cardchair = pPengCard->nCardChair;

    BOOL bPassive = FALSE;
    CMJTable* pTable = NULL;
    if (!(pTable = (CMJTable*)GetTablePtr(roomid, tableno)))
    {
        return NotifyResponseFaild(lpContext, bPassive);
    }

    if (pTable)
    {
        LOCK_TABLE(pTable, chairno, FALSE, userid, token);

        if (!pTable->IsPlayer(userid)) // 不是玩家
        {
            UwlLogFile(_T("user not player. user %ld peng card failed."), userid);
            return NotifyResponseFaild(lpContext, bPassive);
        }
        if (!IS_BIT_SET(pTable->m_dwStatus, TS_PLAYING_GAME)) // 游戏未在进行中
        {
            return NotifyResponseFaild(lpContext, bPassive);
        }
        if (!pTable->ValidateChair(chairno) || !pTable->ValidateChair(cardchair))
        {
            return NotifyResponseFaild(lpContext, bPassive);
        }
        if (pTable->ShouldPengWait(pPengCard))
        {
            UWLCurrentChairCards(pTable, chairno, pPengCard->nCardID, roomid, tableno, userid);
            response.head.nRequest = GR_WAIT_FEW_SECONDS;
            return SendUserResponse(lpContext, &response, bPassive);
        }
        if (!pTable->ValidatePeng(pPengCard))
        {
            UWLCurrentChairCards(pTable, chairno, pPengCard->nCardID, roomid, tableno, userid);
            return NotifyResponseFaild(lpContext, bPassive);
        }

        pTable->OnPeng(pPengCard);

        if (((CMJTable*)pTable)->IsTingPaiActive())
        {
            if (IS_BIT_SET(pTable->m_dwGameFlags, MJ_GF_16_CARDS))
            {
                pTable->CalcTingCard_17(pPengCard->nChairNO);
                response.pDataPtr = &(pTable->m_CardTingDetail_16);
                response.nDataLen = sizeof(CARD_TING_DETAIL_16);
            }
            else
            {
                pTable->CalcTingCard(pPengCard->nChairNO);
                response.pDataPtr = &(pTable->m_CardTingDetail);
                response.nDataLen = sizeof(CARD_TING_DETAIL);
            }
        }
        else
        {
            response.pDataPtr = NULL;
            response.nDataLen = 0;
        }

        response.head.nRequest = UR_OPERATE_SUCCEEDED;
        SendUserResponse(lpContext, &response, bPassive);

        NotifyCardPeng(pTable, pPengCard, token);
    }
    return TRUE;
}

BOOL CMJServer::OnPreGangCard(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt)
{
    LOG_TRACE(_T("CMJServer::OnPreGangCard"));
    SAFETY_NET_REQUEST(lpRequest, PREGANG_CARD, pPreGangCard);

    REQUEST response;
    memset(&response, 0, sizeof(response));

    LONG token = lpContext->lTokenID;
    int roomid = pPreGangCard->nRoomID;
    int tableno = pPreGangCard->nTableNO;
    int userid = pPreGangCard->nUserID;
    int chairno = pPreGangCard->nChairNO;
    int cardchair = pPreGangCard->nCardChair;

    BOOL bPassive = FALSE;
    CMJTable* pTable = NULL;
    if (!(pTable = (CMJTable*)GetTablePtr(roomid, tableno)))
    {
        return NotifyResponseFaild(lpContext, bPassive);
    }
    if (pTable)
    {
        LOCK_TABLE(pTable, chairno, FALSE, userid, token);

        if (!pTable->IsPlayer(userid)) // 不是玩家
        {
            UwlLogFile(_T("user not player. user %ld pregang card failed."), userid);
            return NotifyResponseFaild(lpContext, bPassive);
        }
        if (!IS_BIT_SET(pTable->m_dwStatus, TS_PLAYING_GAME)) // 游戏未在进行中
        {
            return NotifyResponseFaild(lpContext, bPassive);
        }
        if (!pTable->ValidateChair(chairno) || !pTable->ValidateChair(cardchair))
        {
            return NotifyResponseFaild(lpContext, bPassive);
        }
        if (!pTable->ValidatePreGang(pPreGangCard))
        {
            return NotifyResponseFaild(lpContext, bPassive);
        }
        pTable->OnPreGang(pPreGangCard);

        PREGANG_OK pregang_ok;
        memset(&pregang_ok, 0, sizeof(pregang_ok));

        pTable->CalcPreGangOK(pPreGangCard, pregang_ok);

        response.head.nRequest = UR_OPERATE_SUCCEEDED;
        response.pDataPtr = &pregang_ok;
        response.nDataLen = sizeof(pregang_ok);
        SendUserResponse(lpContext, &response, bPassive);

        NotifyPreGangOK(pTable, &pregang_ok, token);
    }
    return TRUE;
}

BOOL CMJServer::OnMnGangCard(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt)
{
    LOG_TRACE(_T("CMJServer::OnMnGangCard"));

    SAFETY_NET_REQUEST(lpRequest, GANG_CARD, pGangCard);
    REQUEST response;
    memset(&response, 0, sizeof(response));

    LONG token = lpContext->lTokenID;
    int roomid = pGangCard->nRoomID;
    int tableno = pGangCard->nTableNO;
    int userid = pGangCard->nUserID;
    int chairno = pGangCard->nChairNO;
    int cardchair = pGangCard->nCardChair;

    BOOL bPassive = FALSE;
    CRoom* pRoom = NULL;
    CMJTable* pTable = NULL;
    if (!(pRoom = GetRoomPtr(roomid)))
    {
        return NotifyResponseFaild(lpContext);
    }

    if (!(pTable = (CMJTable*)GetTablePtr(roomid, tableno)))
    {
        return NotifyResponseFaild(lpContext, bPassive);
    }

    if (pTable)
    {
        LOCK_TABLE(pTable, chairno, FALSE, userid, token);

        if (!pTable->IsPlayer(userid)) // 不是玩家
        {
            UwlLogFile(_T("user not player. user %ld mn gang card failed."), userid);
            return NotifyResponseFaild(lpContext, bPassive);
        }
        if (!IS_BIT_SET(pTable->m_dwStatus, TS_PLAYING_GAME)) // 游戏未在进行中
        {
            UWLCurrentChairCards(pTable, chairno, pGangCard->nCardID, roomid, tableno, userid);
            return NotifyResponseFaild(lpContext, bPassive);
        }
        if (!pTable->ValidateChair(chairno) || !pTable->ValidateChair(cardchair))
        {
            UWLCurrentChairCards(pTable, chairno, pGangCard->nCardID, roomid, tableno, userid);
            return NotifyResponseFaild(lpContext, bPassive);
        }
        if (pTable->ShouldMnGangWait(pGangCard))
        {
            UWLCurrentChairCards(pTable, chairno, pGangCard->nCardID, roomid, tableno, userid);
            response.head.nRequest = GR_WAIT_FEW_SECONDS;
            return SendUserResponse(lpContext, &response, bPassive);
        }
        if (!pTable->ValidateMnGang(pGangCard))
        {
            UWLCurrentChairCards(pTable, chairno, pGangCard->nCardID, roomid, tableno, userid);
            return NotifyResponseFaild(lpContext, bPassive);
        }
        BOOL bBuHua = FALSE;
        int nCardID = pTable->GetGangCard(chairno, bBuHua);
        if (bBuHua)
        {
            NotifySomeOneBuHua(pTable);
        }

        if (INVALID_OBJECT_ID == nCardID) // 没牌抓了
        {
            response.head.nRequest = GR_NO_CARD_CATCH;
            SendUserResponse(lpContext, &response, bPassive);

            OnNoCardLeft(pTable, chairno);
            DWORD dwWinFlags = pTable->CalcWinOnStandOff(chairno);
            if (dwWinFlags)
            {
                OnGameWin(lpContext, pRoom, pTable, chairno, FALSE, roomid);
            }
        }
        else
        {
            pTable->OnMnGang(pGangCard);

            CARD_CAUGHT card_caught;
            ZeroMemory(&card_caught, sizeof(card_caught));
            card_caught.nChairNO = chairno;
            card_caught.nCardID = nCardID;
            card_caught.nCardNO = pTable->GetCardNO(card_caught.nCardID);
            card_caught.dwFlags = pTable->CalcHu_Zimo(chairno, card_caught.nCardID);

            CBuffer buff;
            buff.Write((BYTE*)&card_caught, sizeof(CARD_CAUGHT));
            if (((CMJTable*)pTable)->IsTingPaiActive())
            {
                if (IS_BIT_SET(pTable->m_dwGameFlags, MJ_GF_16_CARDS))
                {
                    pTable->CalcTingCard_17(card_caught.nChairNO);
                    buff.Write((BYTE*) & (pTable->m_CardTingDetail_16), sizeof(CARD_TING_DETAIL_16));
                }
                else
                {
                    pTable->CalcTingCard(card_caught.nChairNO);
                    buff.Write((BYTE*) & (pTable->m_CardTingDetail), sizeof(CARD_TING_DETAIL));
                }
            }

            response.pDataPtr = buff.GetBuffer();
            response.nDataLen = buff.GetBufferLen();
            response.head.nRequest = UR_OPERATE_SUCCEEDED;
            SendUserResponse(lpContext, &response, bPassive);

            NotifyCardMnGang(pTable, pGangCard, card_caught.nCardID, card_caught.nCardNO, token);
        }
    }
    return TRUE;
}

BOOL CMJServer::OnAnGangCard(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt)
{
    LOG_TRACE(_T("CMJServer::OnAnGangCard"));

    SAFETY_NET_REQUEST(lpRequest, GANG_CARD, pGangCard);
    REQUEST response;
    memset(&response, 0, sizeof(response));

    LONG token = lpContext->lTokenID;
    int roomid = pGangCard->nRoomID;
    int tableno = pGangCard->nTableNO;
    int userid = pGangCard->nUserID;
    int chairno = pGangCard->nChairNO;
    int cardchair = pGangCard->nCardChair;

    BOOL bPassive = FALSE;
    CRoom* pRoom = NULL;
    CMJTable* pTable = NULL;
    if (!(pRoom = GetRoomPtr(roomid)))
    {
        return NotifyResponseFaild(lpContext);
    }
    if (!(pTable = (CMJTable*)GetTablePtr(roomid, tableno)))
    {
        return NotifyResponseFaild(lpContext, bPassive);
    }

    if (pTable)
    {
        LOCK_TABLE(pTable, chairno, FALSE, userid, token);

        if (!pTable->IsPlayer(userid)) // 不是玩家
        {
            UwlLogFile(_T("user not player. user %ld an gang card failed."), userid);
            return NotifyResponseFaild(lpContext, bPassive);
        }
        if (!IS_BIT_SET(pTable->m_dwStatus, TS_PLAYING_GAME)) // 游戏未在进行中
        {
            UWLCurrentChairCards(pTable, chairno, pGangCard->nCardID, roomid, tableno, userid);
            return NotifyResponseFaild(lpContext, bPassive);
        }
        if (!pTable->ValidateChair(chairno) || !pTable->ValidateChair(cardchair))
        {
            UWLCurrentChairCards(pTable, chairno, pGangCard->nCardID, roomid, tableno, userid);
            return NotifyResponseFaild(lpContext, bPassive);
        }

        if (pTable->ShouldAnGangWait(pGangCard))
        {
            UWLCurrentChairCards(pTable, chairno, pGangCard->nCardID, roomid, tableno, userid);
            response.head.nRequest = GR_WAIT_FEW_SECONDS;
            return SendUserResponse(lpContext, &response, bPassive);
        }

        if (!pTable->ValidateAnGang(pGangCard))
        {
            UWLCurrentChairCards(pTable, chairno, pGangCard->nCardID, roomid, tableno, userid);
            return NotifyResponseFaild(lpContext, bPassive);
        }
        BOOL bBuHua = FALSE;
        int nCardID = pTable->GetGangCard(chairno, bBuHua);
        if (bBuHua)
        {
            NotifySomeOneBuHua(pTable);
        }

        if (INVALID_OBJECT_ID == nCardID) // 没牌抓了
        {
            response.head.nRequest = GR_NO_CARD_CATCH;
            SendUserResponse(lpContext, &response, bPassive);

            OnNoCardLeft(pTable, chairno);
            DWORD dwWinFlags = pTable->CalcWinOnStandOff(chairno);
            if (dwWinFlags)
            {
                OnGameWin(lpContext, pRoom, pTable, chairno, FALSE, roomid);
            }
        }
        else
        {
            pTable->OnAnGang(pGangCard);

            CARD_CAUGHT card_caught;
            ZeroMemory(&card_caught, sizeof(card_caught));
            card_caught.nChairNO = chairno;
            card_caught.nCardID = nCardID;
            card_caught.nCardNO = pTable->GetCardNO(card_caught.nCardID);
            card_caught.dwFlags = pTable->CalcHu_Zimo(chairno, card_caught.nCardID);

            CBuffer buff;
            buff.Write((BYTE*)&card_caught, sizeof(CARD_CAUGHT));
            if (((CMJTable*)pTable)->IsTingPaiActive())
            {
                if (IS_BIT_SET(pTable->m_dwGameFlags, MJ_GF_16_CARDS))
                {
                    pTable->CalcTingCard_17(card_caught.nChairNO);
                    buff.Write((BYTE*) & (pTable->m_CardTingDetail_16), sizeof(CARD_TING_DETAIL_16));
                }
                else
                {
                    pTable->CalcTingCard(card_caught.nChairNO);
                    buff.Write((BYTE*) & (pTable->m_CardTingDetail), sizeof(CARD_TING_DETAIL));
                }
            }

            response.pDataPtr = buff.GetBuffer();
            response.nDataLen = buff.GetBufferLen();
            response.head.nRequest = UR_OPERATE_SUCCEEDED;
            SendUserResponse(lpContext, &response, bPassive);

            NotifyCardAnGang(pTable, pGangCard, card_caught.nCardID, card_caught.nCardNO, token);
        }
    }
    return TRUE;
}

BOOL CMJServer::OnPnGangCard(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt)
{
    LOG_TRACE(_T("CMJServer::OnPnGangCard"));

    SAFETY_NET_REQUEST(lpRequest, GANG_CARD, pGangCard);
    REQUEST response;
    memset(&response, 0, sizeof(response));

    LONG token = lpContext->lTokenID;
    int roomid = pGangCard->nRoomID;
    int tableno = pGangCard->nTableNO;
    int userid = pGangCard->nUserID;
    int chairno = pGangCard->nChairNO;
    int cardchair = pGangCard->nCardChair;

    BOOL bPassive = FALSE;
    CRoom* pRoom = NULL;
    CMJTable* pTable = NULL;
    if (!(pRoom = GetRoomPtr(roomid)))
    {
        return NotifyResponseFaild(lpContext);
    }
    if (!(pTable = (CMJTable*)GetTablePtr(roomid, tableno)))
    {
        return NotifyResponseFaild(lpContext, bPassive);
    }

    if (pTable)
    {
        LOCK_TABLE(pTable, chairno, FALSE, userid, token);

        if (!pTable->IsPlayer(userid)) // 不是玩家
        {
            UwlLogFile(_T("user not player. user %ld pn gang card failed."), userid);
            return NotifyResponseFaild(lpContext, bPassive);
        }
        if (!IS_BIT_SET(pTable->m_dwStatus, TS_PLAYING_GAME)) // 游戏未在进行中
        {
            UWLCurrentChairCards(pTable, chairno, pGangCard->nCardID, roomid, tableno, userid);
            return NotifyResponseFaild(lpContext, bPassive);
        }
        if (!pTable->ValidateChair(chairno) || !pTable->ValidateChair(cardchair))
        {
            UWLCurrentChairCards(pTable, chairno, pGangCard->nCardID, roomid, tableno, userid);
            return NotifyResponseFaild(lpContext, bPassive);
        }
        if (pTable->ShouldPnGangWait(pGangCard))
        {
            response.head.nRequest = GR_WAIT_FEW_SECONDS;
            return SendUserResponse(lpContext, &response, bPassive);
        }
        if (!pTable->ValidatePnGang(pGangCard))
        {
            UWLCurrentChairCards(pTable, chairno, pGangCard->nCardID, roomid, tableno, userid);
            return NotifyResponseFaild(lpContext, bPassive);
        }
        BOOL bBuHua = FALSE;
        int nCardID = pTable->GetGangCard(chairno, bBuHua);
        if (bBuHua)
        {
            NotifySomeOneBuHua(pTable);
        }

        if (INVALID_OBJECT_ID == nCardID) // 没牌抓了
        {
            response.head.nRequest = GR_NO_CARD_CATCH;
            SendUserResponse(lpContext, &response, bPassive);

            OnNoCardLeft(pTable, chairno);
            DWORD dwWinFlags = pTable->CalcWinOnStandOff(chairno);
            if (dwWinFlags)
            {
                OnGameWin(lpContext, pRoom, pTable, chairno, FALSE, roomid);
            }
        }
        else
        {
            pTable->OnPnGang(pGangCard);

            CARD_CAUGHT card_caught;
            ZeroMemory(&card_caught, sizeof(card_caught));
            card_caught.nChairNO = chairno;
            card_caught.nCardID = nCardID;
            card_caught.nCardNO = pTable->GetCardNO(card_caught.nCardID);
            card_caught.dwFlags = pTable->CalcHu_Zimo(chairno, card_caught.nCardID);

            CBuffer buff;
            buff.Write((BYTE*)&card_caught, sizeof(CARD_CAUGHT));
            if (((CMJTable*)pTable)->IsTingPaiActive())
            {
                if (IS_BIT_SET(pTable->m_dwGameFlags, MJ_GF_16_CARDS))
                {
                    pTable->CalcTingCard_17(card_caught.nChairNO);
                    buff.Write((BYTE*) & (pTable->m_CardTingDetail_16), sizeof(CARD_TING_DETAIL_16));
                }
                else
                {
                    pTable->CalcTingCard(card_caught.nChairNO);
                    buff.Write((BYTE*) & (pTable->m_CardTingDetail), sizeof(CARD_TING_DETAIL));
                }
            }

            response.pDataPtr = buff.GetBuffer();
            response.nDataLen = buff.GetBufferLen();
            response.head.nRequest = UR_OPERATE_SUCCEEDED;
            SendUserResponse(lpContext, &response, bPassive);

            NotifyCardPnGang(pTable, pGangCard, card_caught.nCardID, card_caught.nCardNO, token);
        }
    }
    return TRUE;
}

BOOL CMJServer::OnGuoCard(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt)
{
    LOG_TRACE(_T("CMJServer::OnGuoCard"));
    SAFETY_NET_REQUEST(lpRequest, GUO_CARD, pGuoCard);

    LONG token = lpContext->lTokenID;
    int roomid = pGuoCard->nRoomID;
    int tableno = pGuoCard->nTableNO;
    int userid = pGuoCard->nUserID;
    int chairno = pGuoCard->nChairNO;
    int cardchair = pGuoCard->nCardChair;

    CMJTable* pTable = NULL;
    if (!(pTable = (CMJTable*)GetTablePtr(roomid, tableno)))
    {
        return TRUE;
    }
    if (pTable)
    {
        LOCK_TABLE(pTable, chairno, FALSE, userid, token);

        if (!pTable->IsPlayer(userid)) // 不是玩家
        {
            UwlLogFile(_T("user not player. user %ld pass card failed."), userid);
            return TRUE;
        }
        if (!IS_BIT_SET(pTable->m_dwStatus, TS_PLAYING_GAME)) // 游戏未在进行中
        {
            return TRUE;
        }
        if (IS_BIT_SET(pTable->m_dwStatus, TS_WAITING_THROW)) // 等待出牌状态
        {
            return TRUE;
        }
        if (!pTable->ValidateChair(chairno) || !pTable->ValidateChair(cardchair))
        {
            return TRUE;
        }
        if (!pTable->ValidateGuo(chairno, cardchair))
        {
            return TRUE;
        }
        pTable->OnGuo(chairno, cardchair);

        if (pTable->m_dwPGCHFlags[chairno])
        {
            // 事件分发
            evMJGuo.notify(pTable, pGuoCard);

            CPlayer* pPlayer = pTable->m_ptrPlayers[pTable->GetNextChair(cardchair)];
            NotifyOneUser(pPlayer->m_hSocket, pPlayer->m_lTokenID, GR_CARD_GUO, pGuoCard, sizeof(GUO_CARD));
            pTable->m_dwPGCHFlags[chairno] = 0;
        }
    }
    return TRUE;
}

BOOL CMJServer::OnHuCard(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt)
{
    LOG_TRACE(_T("CMJServer::OnHuCard"));
    SAFETY_NET_REQUEST(lpRequest, HU_CARD, pHuCard);
    REQUEST response;
    memset(&response, 0, sizeof(response));

    LONG token = lpContext->lTokenID;
    int roomid = pHuCard->nRoomID;
    int tableno = pHuCard->nTableNO;
    int userid = pHuCard->nUserID;
    int chairno = pHuCard->nChairNO;
    int cardchair = pHuCard->nCardChair;

    BOOL bPassive = FALSE;
    CRoom* pRoom = NULL;
    CMJTable* pTable = NULL;
    if (!(pRoom = GetRoomPtr(roomid)))
    {
        return NotifyResponseFaild(lpContext, bPassive);
    }
    if (!(pTable = (CMJTable*)GetTablePtr(roomid, tableno)))
    {
        return NotifyResponseFaild(lpContext, bPassive);
    }

    if (pTable)
    {
        LOCK_TABLE(pTable, chairno, FALSE, userid, token);

        if (!pTable->IsPlayer(userid)) // 不是玩家
        {
            UwlLogFile(_T("user not player. user %ld hu card failed."), userid);
            return NotifyResponseFaild(lpContext, bPassive);
        }
        if (!IS_BIT_SET(pTable->m_dwStatus, TS_PLAYING_GAME)) // 游戏未在进行中
        {
            return NotifyResponseFaild(lpContext, bPassive);
        }
        if (!pTable->ValidateChair(chairno) || !pTable->ValidateChair(cardchair))
        {
            return NotifyResponseFaild(lpContext, bPassive);
        }
        if (!pTable->ValidateHu(pHuCard))
        {
            return NotifyResponseFaild(lpContext, bPassive);
        }
        int hu_count = pTable->OnHu(pHuCard);
        if (hu_count > 0)
        {
            response.head.nRequest = UR_OPERATE_SUCCEEDED;
        }
        else
        {
            response.head.nRequest = pTable->GetFailedResponse(chairno);
        }
        // 事件分发
        evMJHu.notify(pTable, pHuCard, hu_count);

        SendUserResponse(lpContext, &response, bPassive);

        DWORD dwWinFlags = pTable->CalcWinOnHu(chairno);
        if (dwWinFlags)
        {
            OnGameWin(lpContext, pRoom, pTable, chairno, FALSE, roomid);
        }
    }
    return TRUE;
}

BOOL CMJServer::onMergeThrowCards(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt)
{
    LOG_TRACE(_T("CMJServer::onMergeThrowCards"));

    if (lpRequest->nDataLen <= (sizeof(THROW_CARDS) - sizeof(int)*MAX_CARDS_PER_CHAIR))
    {
        return NotifyResponseFaild(lpContext);
    }

    // 客户端与服务端结构体不一致， 不能用SAFETY_NET_REQUEST
    THROW_CARDS throwcards;
    ZeroMemory(&throwcards, sizeof(throwcards));
    XygInitChairCards(throwcards.nCardIDs, MAX_CARDS_PER_CHAIR);
    memcpy(&throwcards, lpRequest->pDataPtr, lpRequest->nDataLen);
    LPTHROW_CARDS pThrowCards = &throwcards;

    REQUEST response;
    memset(&response, 0, sizeof(response));

    SOCKET sock = lpContext->hSocket;
    LONG token = lpContext->lTokenID;
    int roomid = pThrowCards->nRoomID;
    int tableno = pThrowCards->nTableNO;
    int userid = pThrowCards->nUserID;
    int chairno = pThrowCards->nChairNO;
    int bout_time = GetBoutTimeMin();
    LPSENDER_INFO pSenderInfo = LPSENDER_INFO(&(pThrowCards->sender_info));

    BOOL bPassive = (chairno != pSenderInfo->nSendChair) ? TRUE : FALSE;
    int senduser = pSenderInfo->nSendUser;
    CRoom* pRoom = NULL;
    CMJTable* pTable = NULL;

    if (bPassive && !IsSupportPassive())
    {
        return NotifyResponseFaild(lpContext, bPassive);
    }
    if (!(pRoom = GetRoomPtr(roomid)))
    {
        return NotifyResponseFaild(lpContext, bPassive);
    }
    if (!(pTable = (CMJTable*)GetTablePtr(roomid, tableno)))
    {
        return NotifyResponseFaild(lpContext, bPassive);
    }

    if (pTable)
    {
        LOCK_TABLE(pTable, chairno, bPassive, senduser, token);

        if (!pTable->IsPlayer(userid))  // 不是玩家
        {
            UwlLogFile(_T("user not player. user %ld merge throw cards failed. auto: %ld"), userid, bPassive);
            return NotifyResponseFaild(lpContext, bPassive);
        }
        UwlTrace(_T("chair %ld, user %ld merge throw cards. auto: %ld"), chairno, userid, bPassive);
        if (bPassive)
        {
            sock = pTable->m_ptrPlayers[chairno]->m_hSocket;
            token = pTable->m_ptrPlayers[chairno]->m_lTokenID;
        }
        if (!IS_BIT_SET(pTable->m_dwStatus, TS_WAITING_THROW))  // 不是等待出牌状态
        {
            UwlLogFile(_T("status not waiting_throw, chair %ld merge throw failed. auto: %ld"), chairno, bPassive);
            return NotifyResponseFaild(lpContext, bPassive);
        }
        if (chairno != pTable->GetCurrentChair())  //不该此人出牌!
        {
            LOG_TRACE(_T("current chair not same, chair %ld merge throw failed. auto: %ld"), chairno, bPassive);
            return NotifyResponseFaild(lpContext, bPassive);
        }
        if (bPassive)
        {
            if (!pTable->ValidateAutoThrow(chairno))
            {
                UwlLogFile(_T("time not exceeded, chair %ld merge autothrow failed. auto: %ld"), chairno, bPassive);
                return NotifyResponseFaild(lpContext, bPassive);
            }
            pTable->m_nAutoCount[chairno]++;
            if (pTable->m_nAutoCount[chairno] >= pTable->m_nMaxAutoThrow)
            {
                if (OnTooManyAuto(userid, roomid, tableno, chairno, sock, token))
                {
                    return NotifyResponseFaild(lpContext, bPassive);
                }
            }
            if (!pTable->ReplaceAutoThrow((THROW_CARDS*)pThrowCards))
            {
                UwlLogFile(_T("ReplaceAutoThrow() failed. chair %ld. auto: %ld"), chairno, bPassive);
                return NotifyResponseFaild(lpContext, bPassive);
            }
        }

        // ***************************************************************
        //服务器与客户端同步检查
        if (!pTable->IsCardIDsInHand(chairno, pThrowCards->nCardIDs))
        {
            //客户端数据与服务器不符合
            UwlLogFile(_T("merge throw cards not in hand! roomid = %ld, tableno = %ld, chairno = %ld, userid = %ld. cardid = %ld, auto: %ld"),
                roomid, tableno, chairno, userid, pThrowCards->nCardIDs[0], bPassive);

            //将该玩家的牌重新发给他
            CARDS_INFO cardsinfo;
            ZeroMemory(&cardsinfo, sizeof(cardsinfo));
            cardsinfo.nUserID = userid;
            cardsinfo.nChairNO = chairno;
            cardsinfo.nCardsCount = pTable->GetChairCards(chairno, cardsinfo.nCardIDs, MAX_CARDS_PER_CHAIR);
            CPlayer* pPlayer = pTable->m_ptrPlayers[chairno];
            if (pPlayer != NULL)
            {
                NotifyOneUser(pPlayer->m_hSocket, pPlayer->m_lTokenID, GR_CARDS_INFO, &cardsinfo,
                    sizeof(cardsinfo) - sizeof(int) * (MAX_CARDS_PER_CHAIR - cardsinfo.nCardsCount));
            }
            response.head.nRequest = GR_GAMEDATA_ERROR;
            return SendUserResponse(lpContext, &response, bPassive);
        }


        if (pThrowCards->nCardsCount > 1)
        {
            int MJID = pThrowCards->nCardIDs[0];
            XygInitChairCards(pThrowCards->nCardIDs, MAX_CARDS_PER_CHAIR);
            pThrowCards->nCardIDs[0] = MJID;
            pThrowCards->nCardsCount = 1;//每次只可能出一张牌
        }
        // ****************************************************************

        if (0 == pThrowCards->dwCardsType)
        {
            UwlLogFile(_T("wrong type of cards! chair %ld merge throw failed. auto: %ld "), chairno, bPassive);
            return NotifyResponseFaild(lpContext, bPassive);
        }
        if (0 == pThrowCards->nCardsCount)
        {
            UwlLogFile(_T("zero count of cards! chair %ld merge throw failed. auto: %ld "), chairno, bPassive);
            return NotifyResponseFaild(lpContext, bPassive);
        }
        int nValidIDs[MAX_CARDS_PER_CHAIR];
        XygInitChairCards(nValidIDs, MAX_CARDS_PER_CHAIR);
        int rt = pTable->ValidateThrow(chairno, pThrowCards->nCardIDs,
                pThrowCards->nCardsCount, pThrowCards->dwCardsType, nValidIDs);
        if (0 == rt)
        {
            UwlLogFile(_T("ValidateThrow() return 0. chair %ld merge throw failed. auto: %ld "), chairno, bPassive);
            return NotifyResponseFaild(lpContext, bPassive);
        }
        else if (rt < 0)
        {
            UwlLogFile(_T("ValidateThrow() return -1. chair %ld merge throw failed. auto: %ld "), chairno, bPassive);
            NotifyInvalidThrow(pTable, (THROW_CARDS*)pThrowCards, token);
            return ResponseThrowAgain(lpContext, nValidIDs, bPassive);
        }
        UwlTrace(_T("chair %ld, user %ld merge throw OK! cardid: %ld, auto: %ld"),
            chairno, userid, pThrowCards->nCardIDs[0], bPassive);
        if (!pTable->ThrowCards(chairno, pThrowCards->nCardIDs))
        {
            LOG_ERROR(_T("pTable->ThrowCards error"));
            return NotifyResponseFaild(lpContext, bPassive);
        }
        pTable->SetWaitingsOnThrow(chairno, pThrowCards->nCardIDs, pThrowCards->dwCardsType);

        pTable->SetStatusOnThrow();
        pTable->SetCurrentChairOnThrow();

        int nCurrentChairNO = pTable->GetCurrentChair();
        int nCardNO = -2;
        if (pTable->ValidateMergeCatch(nCurrentChairNO))
        {
            BOOL bBuHua = FALSE;
            int nCardNO = pTable->CatchCard(nCurrentChairNO, bBuHua);
            if (bBuHua)
            {
                NotifySomeOneBuHua(pTable);
            }
            if (pTable->m_nJokerNO == nCardNO)   //抓到翻牌
            {
                bBuHua = FALSE;
                nCardNO = OnJokerShownCaught(pTable, nCurrentChairNO, bBuHua);
                if (bBuHua)
                {
                    NotifySomeOneBuHua(pTable);
                }
            }
            if (INVALID_OBJECT_ID == nCardNO || !IS_BIT_SET(pTable->m_dwStatus, TS_WAITING_CATCH))
            {
                ResponseThrowCardSucceed(response, lpContext, pTable, pThrowCards, bPassive);

                if (bPassive)
                {
                    NotifyCardsThrow(pTable, pThrowCards, GR_CARDS_THROW, 0);
                }
                else
                {
                    NotifyCardsThrow(pTable, pThrowCards, GR_CARDS_THROW, token);
                }

                OnNoCardLeft(pTable, nCurrentChairNO);
                DWORD dwWinFlags = pTable->CalcWinOnStandOff(nCurrentChairNO);
                if (dwWinFlags)
                {
                    OnGameWin(lpContext, pRoom, pTable, nCurrentChairNO, FALSE, roomid);
                }
            }
            else
            {
                OnCardCaught(pTable, nCurrentChairNO);

                int nCardID = pTable->GetCardID(nCardNO);
                CARD_CAUGHT Card = { nCurrentChairNO, nCardID, nCardNO,
                                pTable->CalcHu_Zimo(nCurrentChairNO, nCardID)
                            };

                MERGE_THROWCARDS mergeThrowCards;
                ZeroMemory(&mergeThrowCards, sizeof(mergeThrowCards));

                mergeThrowCards.bPassive = pThrowCards->bPassive;
                mergeThrowCards.dwCardsType = pThrowCards->dwCardsType;
                mergeThrowCards.nCardsCount = pThrowCards->nCardsCount;
                mergeThrowCards.nChairNO = pThrowCards->nChairNO;
                mergeThrowCards.nRoomID = pThrowCards->nRoomID;
                mergeThrowCards.nTableNO = pThrowCards->nTableNO;
                mergeThrowCards.nUserID = pThrowCards->nUserID;

                memcpy(mergeThrowCards.nReserved, pThrowCards->nReserved, sizeof(mergeThrowCards.nReserved));
                memcpy(mergeThrowCards.nCardIDs, pThrowCards->nCardIDs, sizeof(mergeThrowCards.nCardIDs));
                memcpy(&mergeThrowCards.card_caught, &Card, sizeof(CARD_CAUGHT));
                memcpy(&mergeThrowCards.sender_info, &pThrowCards->sender_info, sizeof(SENDER_INFO));

                response.head.nRequest = UR_OPERATE_SUCCEEDED;
                response.pDataPtr = &mergeThrowCards;
                response.nDataLen = sizeof(mergeThrowCards);
                SendUserResponse(lpContext, &response, bPassive);

                pTable->SaveTingCardsForDXXW(pThrowCards->nCardIDs[0], pThrowCards->nChairNO);
                if (bPassive)
                {
                    NotifyMergeCardsThrow(pTable, &mergeThrowCards, GR_MERGE_CARDSTHROW, 0);
                }
                else
                {
                    NotifyMergeCardsThrow(pTable, &mergeThrowCards, GR_MERGE_CARDSTHROW, token);
                }

                OnServerAutoPlay(pRoom, pTable, pTable->GetCurrentChair(), !pTable->IsOffline(pTable->GetCurrentChair()));
            }
        }
        else
        {
            THROW_OK throwOK;
            ZeroMemory(&throwOK, sizeof(throwOK));
            throwOK.nNextChair = pTable->GetCurrentChair();
            throwOK.bNextFirst = pTable->IsNextFirstHand();

            response.head.nRequest = UR_OPERATE_SUCCEEDED;
            response.pDataPtr = &throwOK;
            response.nDataLen = sizeof(throwOK);
            SendUserResponse(lpContext, &response, bPassive);

            pTable->SaveTingCardsForDXXW(pThrowCards->nCardIDs[0], pThrowCards->nChairNO);
            if (bPassive)
            {
                NotifyCardsThrow(pTable, pThrowCards, GR_CARDS_THROW, 0);

                if (pTable->m_nAutoCount[chairno] >= 2 && !pTable->IsOffline(chairno))
                {
                    OnPlayerOffline(pTable, chairno);
                    OnServerAutoPlay(pRoom, pTable, chairno, !pTable->IsOffline(chairno));
                }
            }
            else
            {
                NotifyCardsThrow(pTable, pThrowCards, GR_CARDS_THROW, token);
            }

            if (0 == pTable->HaveCards(chairno))  // 自己手里牌已出完
            {
                pTable->OnNoCardRemains(chairno);
                OnNoCardRemains(pTable, chairno);
            }
            DWORD dwWinFlags = pTable->CalcWinOnThrow(chairno, pThrowCards->nCardIDs, pThrowCards->dwCardsType);
            if (dwWinFlags)
            {
                BOOL bout_invalid = pTable->IsBoutInvalid(bout_time);
                OnGameWin(lpContext, pRoom, pTable, chairno, bout_invalid, roomid);
            }
            //服务端自动抓牌
            if (!dwWinFlags)
            {
                OnServerAutoPlay(pRoom, pTable, pTable->GetCurrentChair(), !pTable->IsOffline(pTable->GetCurrentChair()));
            }
            //end
        }
    }
    return TRUE;
}

BOOL CMJServer::OnReconsChiCard(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt)
{
    LOG_TRACE(_T("CMJServer::OnReconsChiCard"));
    SAFETY_NET_REQUEST(lpRequest, CHI_CARD, pChiCard);
    REQUEST response;
    memset(&response, 0, sizeof(response));

    LONG token = lpContext->lTokenID;
    int roomid = pChiCard->nRoomID;
    int tableno = pChiCard->nTableNO;
    int userid = pChiCard->nUserID;
    int chairno = pChiCard->nChairNO;
    int cardchair = pChiCard->nCardChair;

    BOOL bPassive = FALSE;
    CRoom* pRoom = NULL;
    CMJTable* pTable = NULL;
    if (!(pRoom = GetRoomPtr(roomid)))
    {
        return NotifyResponseFaild(lpContext, bPassive);
    }
    if (!(pTable = (CMJTable*)GetTablePtr(roomid, tableno)))
    {
        return NotifyResponseFaild(lpContext, bPassive);
    }

    if (pTable)
    {
        LOCK_TABLE(pTable, chairno, FALSE, userid, token);

        if (!pTable->IsPlayer(userid))  // 不是玩家
        {
            UwlLogFile(_T("user not player. user %ld chi card failed."), userid);
            return NotifyResponseFaild(lpContext, bPassive);
        }
        if (!IS_BIT_SET(pTable->m_dwStatus, TS_PLAYING_GAME))  // 游戏未在进行中
        {
            return NotifyResponseFaild(lpContext, bPassive);
        }
        if (!pTable->ValidateChair(chairno) || !pTable->ValidateChair(cardchair))
        {
            return NotifyResponseFaild(lpContext, bPassive);
        }
        if (!pTable->ValidateChi(pChiCard))
        {
            return NotifyResponseFaild(lpContext, bPassive);
        }

        int nRet = pTable->ShouldReConsChiWait(pChiCard);
        if (nRet == 1)
        {
            response.head.nRequest = GR_WAIT_FEW_SECONDS;
            return SendUserResponse(lpContext, &response, bPassive);
        }
        else if (nRet == 2)
        {
            OnServerChiPengGangCard(pRoom, pTable);
            return TRUE;
        }

        pTable->OnChi(pChiCard);

        if (((CMJTable*)pTable)->IsTingPaiActive())
        {
            if (IS_BIT_SET(pTable->m_dwGameFlags, MJ_GF_16_CARDS))
            {
                DWORD dwTingFlag = pTable->CalcTingCard_17(pChiCard->nChairNO);
                response.pDataPtr = &(pTable->m_CardTingDetail_16);
                response.nDataLen = sizeof(CARD_TING_DETAIL_16);
            }
            else
            {
                DWORD dwTingFlag = pTable->CalcTingCard(pChiCard->nChairNO);
                response.pDataPtr = &(pTable->m_CardTingDetail);
                response.nDataLen = sizeof(CARD_TING_DETAIL);
            }

            response.head.nRequest = UR_OPERATE_SUCCEEDED;
            SendUserResponse(lpContext, &response, bPassive);
        }
        else
        {
            response.pDataPtr = NULL;
            response.nDataLen = 0;
            response.head.nRequest = UR_OPERATE_SUCCEEDED;
            SendUserResponse(lpContext, &response, bPassive);
        }

        NotifyCardChi(pTable, pChiCard, token);
    }
    return TRUE;
}

BOOL CMJServer::OnReconsPengCard(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt)
{
    LOG_TRACE(_T("CMJServer::OnReconsPengCard"));
    SAFETY_NET_REQUEST(lpRequest, PENG_CARD, pPengCard);
    REQUEST response;
    memset(&response, 0, sizeof(response));

    LONG token = lpContext->lTokenID;
    int roomid = pPengCard->nRoomID;
    int tableno = pPengCard->nTableNO;
    int userid = pPengCard->nUserID;
    int chairno = pPengCard->nChairNO;
    int cardchair = pPengCard->nCardChair;

    BOOL bPassive = FALSE;
    CRoom* pRoom = NULL;
    CMJTable* pTable = NULL;
    if (!(pRoom = GetRoomPtr(roomid)))
    {
        return NotifyResponseFaild(lpContext, bPassive);
    }
    if (!(pTable = (CMJTable*)GetTablePtr(roomid, tableno)))
    {
        return NotifyResponseFaild(lpContext, bPassive);
    }

    if (pTable)
    {
        LOCK_TABLE(pTable, chairno, FALSE, userid, token);

        if (!pTable->IsPlayer(userid))  // 不是玩家
        {
            UwlLogFile(_T("user not player. user %ld reconspeng card failed."), userid);
            return NotifyResponseFaild(lpContext, bPassive);
        }
        if (!IS_BIT_SET(pTable->m_dwStatus, TS_PLAYING_GAME))  // 游戏未在进行中
        {
            UwlLogFile(_T("OnReConsPengCard game is not TS_PLAYING_GAME m_dwStatus: %ld, roomid:%ld, tableno:%ld, chairno:%ld, userid:%ld"),
                pTable->m_dwStatus, roomid, tableno, chairno, userid);
            return NotifyResponseFaild(lpContext, bPassive);
        }

        if (!pTable->ValidateChair(chairno) || !pTable->ValidateChair(cardchair))
        {
            UwlLogFile(_T("OnReconsPengCard game is not TS_PLAYING_GAME m_dwStatus: %ld, roomid:%ld, tableno:%ld, chairno:%ld, userid:%ld"),
                pTable->m_dwStatus, roomid, tableno, chairno, userid);

            return NotifyResponseFaild(lpContext, bPassive);
        }

        if (!pTable->ValidatePeng(pPengCard))
        {

            UwlLogFile(("OnReconsPengCard game is not ValidatePeng fail, pengbaseid:%d %d"),
                pPengCard->nBaseIDs[0], pPengCard->nBaseIDs[1]);
            UWLCurrentChairCards(pTable, chairno, pPengCard->nCardID, roomid, tableno, userid);

            return NotifyResponseFaild(lpContext, bPassive);
        }

        int nRet = pTable->ShouldReConsPengWait(pPengCard);
        if (nRet == 1)
        {
            response.head.nRequest = GR_WAIT_FEW_SECONDS;
            return SendUserResponse(lpContext, &response, bPassive);
        }
        else if (nRet == 2)
        {
            OnServerChiPengGangCard(pRoom, pTable);
            return TRUE;
        }

        pTable->OnPeng(pPengCard);

        if (((CMJTable*)pTable)->IsTingPaiActive())
        {
            if (IS_BIT_SET(pTable->m_dwGameFlags, MJ_GF_16_CARDS))
            {
                pTable->CalcTingCard_17(pPengCard->nChairNO);
                response.pDataPtr = &(pTable->m_CardTingDetail_16);
                response.nDataLen = sizeof(CARD_TING_DETAIL_16);
            }
            else
            {
                pTable->CalcTingCard(pPengCard->nChairNO);
                response.pDataPtr = &(pTable->m_CardTingDetail);
                response.nDataLen = sizeof(CARD_TING_DETAIL);
            }
        }
        else
        {
            response.pDataPtr = NULL;
            response.nDataLen = 0;
        }
        response.head.nRequest = UR_OPERATE_SUCCEEDED;
        SendUserResponse(lpContext, &response, bPassive);

        NotifyCardPeng(pTable, pPengCard, token);
    }
    return TRUE;
}

BOOL CMJServer::OnReconsMnGangCard(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt)
{
    LOG_TRACE(_T("CMJServer::OnReconsMnGangCard"));
    SAFETY_NET_REQUEST(lpRequest, GANG_CARD, pGangCard);
    REQUEST response;
    memset(&response, 0, sizeof(response));

    LONG token = lpContext->lTokenID;
    int roomid = pGangCard->nRoomID;
    int tableno = pGangCard->nTableNO;
    int userid = pGangCard->nUserID;
    int chairno = pGangCard->nChairNO;
    int cardchair = pGangCard->nCardChair;

    BOOL bPassive = FALSE;
    CRoom* pRoom = NULL;
    CMJTable* pTable = NULL;
    if (!(pRoom = GetRoomPtr(roomid)))
    {
        return NotifyResponseFaild(lpContext, bPassive);
    }
    if (!(pTable = (CMJTable*)GetTablePtr(roomid, tableno)))
    {
        return NotifyResponseFaild(lpContext, bPassive);
    }

    if (pTable)
    {
        LOCK_TABLE(pTable, chairno, FALSE, userid, token);

        if (!pTable->IsPlayer(userid))  // 不是玩家
        {
            UwlLogFile(_T("user not player. user %ld reconsmn gang card failed."), userid);
            return NotifyResponseFaild(lpContext, bPassive);
        }
        if (!IS_BIT_SET(pTable->m_dwStatus, TS_PLAYING_GAME))  // 游戏未在进行中
        {
            UwlLogFile(_T("OnReconsMnGangCard game is not TS_PLAYING_GAME m_dwStatus: %ld"), pTable->m_dwStatus);
            UWLCurrentChairCards(pTable, chairno, pGangCard->nCardID, roomid, tableno, userid);

            return NotifyResponseFaild(lpContext, bPassive);
        }

        if (!pTable->ValidateChair(chairno) || !pTable->ValidateChair(cardchair))
        {
            UwlLogFile(_T("OnReconsMnGangCard chairno %d or cardchair %d is error"), chairno, cardchair);
            UWLCurrentChairCards(pTable, chairno, pGangCard->nCardID, roomid, tableno, userid);

            return NotifyResponseFaild(lpContext, bPassive);
        }

        if (!pTable->ValidateMnGang(pGangCard))
        {
            UwlLogFile("OnReconsMnGangCard ValidateMnGang false OnMnGangCard:%d,%d,%d",
                pGangCard->nBaseIDs[0], pGangCard->nBaseIDs[1], pGangCard->nBaseIDs[2]);
            UWLCurrentChairCards(pTable, chairno, pGangCard->nCardID, roomid, tableno, userid);

            return NotifyResponseFaild(lpContext, bPassive);
        }

        int nRet = pTable->ShouldReconsMnGangWait(pGangCard);
        if (nRet == 1)
        {
            response.head.nRequest = GR_WAIT_FEW_SECONDS;
            return SendUserResponse(lpContext, &response, bPassive);
        }
        else if (nRet == 2)
        {
            OnServerChiPengGangCard(pRoom, pTable);
            return TRUE;
        }

        BOOL bBuHua = FALSE;
        int nCardID = pTable->GetGangCard(chairno, bBuHua);
        if (bBuHua)
        {
            NotifySomeOneBuHua(pTable);
        }
        if (INVALID_OBJECT_ID == nCardID)  // 没牌抓了
        {
            response.head.nRequest = GR_NO_CARD_CATCH;
            SendUserResponse(lpContext, &response, bPassive);

            OnNoCardLeft(pTable, chairno);
            DWORD dwWinFlags = pTable->CalcWinOnStandOff(chairno);
            if (dwWinFlags)
            {
                OnGameWin(lpContext, pRoom, pTable, chairno, FALSE, roomid);
            }
        }
        else
        {
            pTable->OnMnGang(pGangCard);

            CARD_CAUGHT card_caught;
            ZeroMemory(&card_caught, sizeof(card_caught));
            card_caught.nChairNO = chairno;
            card_caught.nCardID = nCardID;
            card_caught.nCardNO = pTable->GetCardNO(card_caught.nCardID);
            card_caught.dwFlags = pTable->CalcHu_Zimo(chairno, card_caught.nCardID);

            CBuffer buff;
            buff.Write((BYTE*)&card_caught, sizeof(CARD_CAUGHT));

            if (((CMJTable*)pTable)->IsTingPaiActive())
            {
                if (IS_BIT_SET(pTable->m_dwGameFlags, MJ_GF_16_CARDS))
                {
                    pTable->CalcTingCard_17(card_caught.nChairNO);
                    buff.Write((BYTE*) & (pTable->m_CardTingDetail_16), sizeof(CARD_TING_DETAIL_16));
                }
                else
                {
                    pTable->CalcTingCard(card_caught.nChairNO);
                    buff.Write((BYTE*) & (pTable->m_CardTingDetail), sizeof(CARD_TING_DETAIL));
                }
            }

            response.pDataPtr = buff.GetBuffer();
            response.nDataLen = buff.GetBufferLen();
            response.head.nRequest = UR_OPERATE_SUCCEEDED;
            SendUserResponse(lpContext, &response, bPassive);

            NotifyCardMnGang(pTable, pGangCard, card_caught.nCardID, card_caught.nCardNO, token);
        }
    }
    return TRUE;
}

BOOL CMJServer::OnReconsPnGangCard(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt)
{
    LOG_TRACE(_T("CMJServer::OnReconsPnGangCard"));
    SAFETY_NET_REQUEST(lpRequest, GANG_CARD, pGangCard);
    REQUEST response;
    memset(&response, 0, sizeof(response));

    LONG token = lpContext->lTokenID;
    int roomid = pGangCard->nRoomID;
    int tableno = pGangCard->nTableNO;
    int userid = pGangCard->nUserID;
    int chairno = pGangCard->nChairNO;
    int cardchair = pGangCard->nCardChair;

    BOOL bPassive = FALSE;
    CRoom* pRoom = NULL;
    CMJTable* pTable = NULL;
    if (!(pRoom = GetRoomPtr(roomid)))
    {
        return NotifyResponseFaild(lpContext, bPassive);
    }
    if (!(pTable = (CMJTable*)GetTablePtr(roomid, tableno)))
    {
        return NotifyResponseFaild(lpContext, bPassive);
    }

    if (pTable)
    {
        LOCK_TABLE(pTable, chairno, FALSE, userid, token);

        if (!pTable->IsPlayer(userid))  // 不是玩家
        {
            UwlLogFile(_T("user not player. user %ld reconspn gang card failed."), userid);
            return NotifyResponseFaild(lpContext, bPassive);
        }
        if (!IS_BIT_SET(pTable->m_dwStatus, TS_PLAYING_GAME))  // 游戏未在进行中
        {
            UwlLogFile(_T("OnReconsPnGangCard status %ld not TS_PLAYING_GAME"), pTable->m_dwStatus);
            UWLCurrentChairCards(pTable, chairno, pGangCard->nCardID, roomid, tableno, userid);

            return NotifyResponseFaild(lpContext, bPassive);
        }

        if (!pTable->ValidateChair(chairno) || !pTable->ValidateChair(cardchair))
        {
            UwlLogFile(_T("OnReconsPnGangCard chairno %d or cardchair %d is error"), chairno, cardchair);
            UWLCurrentChairCards(pTable, chairno, pGangCard->nCardID, roomid, tableno, userid);

            return NotifyResponseFaild(lpContext, bPassive);
        }

        if (!pTable->ValidatePnGang(pGangCard))
        {
            UwlLogFile("OnReconsPnGangCard ValidatePnGang false OnReconsPnGangCard:%d,%d,%d",
                pGangCard->nBaseIDs[0], pGangCard->nBaseIDs[1], pGangCard->nBaseIDs[2]);
            UWLCurrentChairCards(pTable, chairno, pGangCard->nCardID, roomid, tableno, userid);

            return NotifyResponseFaild(lpContext, bPassive);
        }

        int nRet = pTable->ShouldReconsPnGangWait(pGangCard);
        if (nRet == 1)
        {
            response.head.nRequest = GR_WAIT_FEW_SECONDS;
            return SendUserResponse(lpContext, &response, bPassive);
        }
        else if (nRet == 2)
        {
            OnServerChiPengGangCard(pRoom, pTable);
            return TRUE;
        }
        BOOL bBuHua = FALSE;
        int nCardID = pTable->GetGangCard(chairno, bBuHua);
        if (bBuHua)
        {
            NotifySomeOneBuHua(pTable);
        }
        if (INVALID_OBJECT_ID == nCardID)  // 没牌抓了
        {
            response.head.nRequest = GR_NO_CARD_CATCH;
            SendUserResponse(lpContext, &response, bPassive);

            OnNoCardLeft(pTable, chairno);
            DWORD dwWinFlags = pTable->CalcWinOnStandOff(chairno);
            if (dwWinFlags)
            {
                OnGameWin(lpContext, pRoom, pTable, chairno, FALSE, roomid);
            }
        }
        else
        {
            pTable->OnPnGang(pGangCard);

            CARD_CAUGHT card_caught;
            ZeroMemory(&card_caught, sizeof(card_caught));
            card_caught.nChairNO = chairno;
            card_caught.nCardID = nCardID;
            card_caught.nCardNO = pTable->GetCardNO(card_caught.nCardID);
            card_caught.dwFlags = pTable->CalcHu_Zimo(chairno, card_caught.nCardID);

            CBuffer buff;
            buff.Write((BYTE*)&card_caught, sizeof(CARD_CAUGHT));
            if (((CMJTable*)pTable)->IsTingPaiActive())
            {
                if (IS_BIT_SET(pTable->m_dwGameFlags, MJ_GF_16_CARDS))
                {
                    pTable->CalcTingCard_17(card_caught.nChairNO);
                    buff.Write((BYTE*) & (pTable->m_CardTingDetail_16), sizeof(CARD_TING_DETAIL_16));
                }
                else
                {
                    pTable->CalcTingCard(card_caught.nChairNO);
                    buff.Write((BYTE*) & (pTable->m_CardTingDetail), sizeof(CARD_TING_DETAIL));
                }
            }

            response.pDataPtr = buff.GetBuffer();
            response.nDataLen = buff.GetBufferLen();
            response.head.nRequest = UR_OPERATE_SUCCEEDED;
            SendUserResponse(lpContext, &response, bPassive);

            NotifyCardPnGang(pTable, pGangCard, card_caught.nCardID, card_caught.nCardNO, token);
        }
    }
    return TRUE;
}

BOOL CMJServer::OnReconsAnGangCard(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt)
{
    LOG_TRACE(_T("CMJServer::OnReconsAnGangCard"));
    SAFETY_NET_REQUEST(lpRequest, GANG_CARD, pGangCard);
    REQUEST response;
    memset(&response, 0, sizeof(response));

    LONG token = lpContext->lTokenID;
    int roomid = pGangCard->nRoomID;
    int tableno = pGangCard->nTableNO;
    int userid = pGangCard->nUserID;
    int chairno = pGangCard->nChairNO;
    int cardchair = pGangCard->nCardChair;

    BOOL bPassive = FALSE;
    CRoom* pRoom = NULL;
    CMJTable* pTable = NULL;
    if (!(pRoom = GetRoomPtr(roomid)))
    {
        return NotifyResponseFaild(lpContext, bPassive);
    }
    if (!(pTable = (CMJTable*)GetTablePtr(roomid, tableno)))
    {
        return NotifyResponseFaild(lpContext, bPassive);
    }

    if (pTable)
    {
        LOCK_TABLE(pTable, chairno, FALSE, userid, token);

        if (!pTable->IsPlayer(userid))  // 不是玩家
        {
            UwlLogFile(_T("user not player. user %ld recons an gang card failed."), userid);
            return NotifyResponseFaild(lpContext, bPassive);
        }
        if (!IS_BIT_SET(pTable->m_dwStatus, TS_PLAYING_GAME))  // 游戏未在进行中
        {
            UwlLogFile(_T("OnReconsAnGangCard status %ld not TS_PLAYING_GAME"), pTable->m_dwStatus);
            UWLCurrentChairCards(pTable, chairno, pGangCard->nCardID, roomid, tableno, userid);

            return NotifyResponseFaild(lpContext, bPassive);
        }
        if (!pTable->ValidateChair(chairno) || !pTable->ValidateChair(cardchair))
        {
            UwlLogFile(_T("chairno %d or cardchair %d is error"), chairno, cardchair);
            UWLCurrentChairCards(pTable, chairno, pGangCard->nCardID, roomid, tableno, userid);

            return NotifyResponseFaild(lpContext, bPassive);
        }

        int nRet = pTable->ShouldReconsAnGangWait(pGangCard);
        if (nRet == 1)
        {
            response.head.nRequest = GR_WAIT_FEW_SECONDS;
            return SendUserResponse(lpContext, &response, bPassive);
        }
        else if (nRet == 2)
        {
            OnServerChiPengGangCard(pRoom, pTable);
            return TRUE;
        }

        if (!pTable->ValidateAnGang(pGangCard))
        {
            UwlLogFile("OnReconsAnGangCard ValidateAnGang false OnReconsAnGangCard:%d,%d,%d",
                pGangCard->nBaseIDs[0], pGangCard->nBaseIDs[1], pGangCard->nBaseIDs[2]);
            UWLCurrentChairCards(pTable, chairno, pGangCard->nCardID, roomid, tableno, userid);

            return NotifyResponseFaild(lpContext, bPassive);
        }

        BOOL bBuHua = FALSE;
        int nCardID = pTable->GetGangCard(chairno, bBuHua);
        if (bBuHua)
        {
            NotifySomeOneBuHua(pTable);
        }
        if (INVALID_OBJECT_ID == nCardID)  // 没牌抓了
        {
            response.head.nRequest = GR_NO_CARD_CATCH;
            SendUserResponse(lpContext, &response, bPassive);

            OnNoCardLeft(pTable, chairno);
            DWORD dwWinFlags = pTable->CalcWinOnStandOff(chairno);
            if (dwWinFlags)
            {
                OnGameWin(lpContext, pRoom, pTable, chairno, FALSE, roomid);
            }
        }
        else
        {
            pTable->OnAnGang(pGangCard);

            CARD_CAUGHT card_caught;
            ZeroMemory(&card_caught, sizeof(card_caught));
            card_caught.nChairNO = chairno;
            card_caught.nCardID = nCardID;
            card_caught.nCardNO = pTable->GetCardNO(card_caught.nCardID);
            card_caught.dwFlags = pTable->CalcHu_Zimo(chairno, card_caught.nCardID);

            CBuffer buff;
            buff.Write((BYTE*)&card_caught, sizeof(CARD_CAUGHT));
            if (((CMJTable*)pTable)->IsTingPaiActive())
            {
                if (IS_BIT_SET(pTable->m_dwGameFlags, MJ_GF_16_CARDS))
                {
                    pTable->CalcTingCard_17(card_caught.nChairNO);
                    buff.Write((BYTE*) & (pTable->m_CardTingDetail_16), sizeof(CARD_TING_DETAIL_16));
                }
                else
                {
                    pTable->CalcTingCard(card_caught.nChairNO);
                    buff.Write((BYTE*) & (pTable->m_CardTingDetail), sizeof(CARD_TING_DETAIL));
                }
            }

            response.pDataPtr = buff.GetBuffer();
            response.nDataLen = buff.GetBufferLen();
            response.head.nRequest = UR_OPERATE_SUCCEEDED;
            SendUserResponse(lpContext, &response, bPassive);

            NotifyCardAnGang(pTable, pGangCard, card_caught.nCardID, card_caught.nCardNO, token);
        }
    }
    return TRUE;
}

BOOL CMJServer::OnReconsGuoCard(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt)
{
    LOG_TRACE(_T("CMJServer::OnReconsGuoCard"));
    SAFETY_NET_REQUEST(lpRequest, GUO_CARD, pGuoCard);

    LONG token = lpContext->lTokenID;
    int roomid = pGuoCard->nRoomID;
    int tableno = pGuoCard->nTableNO;
    int userid = pGuoCard->nUserID;
    int chairno = pGuoCard->nChairNO;
    int cardchair = pGuoCard->nCardChair;

    CRoom* pRoom = NULL;
    CMJTable* pTable = NULL;
    if (!(pRoom = GetRoomPtr(roomid)))
    {
        return TRUE;
    }
    if (!(pTable = (CMJTable*)GetTablePtr(roomid, tableno)))
    {
        return TRUE;
    }
    if (pTable)
    {
        LOCK_TABLE(pTable, chairno, FALSE, userid, token);

        if (!pTable->IsPlayer(userid))  // 不是玩家
        {
            UwlLogFile(_T("user not player. user %ld recons pass card failed."), userid);
            return TRUE;
        }
        if (!IS_BIT_SET(pTable->m_dwStatus, TS_PLAYING_GAME))  // 游戏未在进行中
        {
            return TRUE;
        }
        if (IS_BIT_SET(pTable->m_dwStatus, TS_WAITING_THROW))
        {
            // 等待出牌状态
            if (!IS_BIT_SET(pTable->m_dwStatus, MJ_TS_GANG_PN)
                && !IS_BIT_SET(pTable->m_dwStatus, MJ_TS_GANG_MN)
                && !IS_BIT_SET(pTable->m_dwStatus, MJ_TS_GANG_AN))
            {
                return TRUE;
            }
        }
        if (!pTable->ValidateChair(chairno))
        {
            return TRUE;
        }

        int nRet = pTable->OnReconsGuo(chairno);
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
            if (JudgeGuoCanAutoPlay(pTable->m_nTotalChairs, pTable->m_dwPGCHFlags))
            {
                OnServerAutoPlay(pRoom, pTable, pTable->GetCurrentChair(), !pTable->IsOffline(pTable->GetCurrentChair()));
            }
        }
        else if (nRet == 2)
        {
            OnServerChiPengGangCard(pRoom, pTable);
        }
    }
    return TRUE;
}

BOOL CMJServer::OnHuaCard(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt)
{
    LOG_TRACE(_T("CMJServer::OnHuaCard"));
    SAFETY_NET_REQUEST(lpRequest, HUA_CARD, pHuaCard);
    REQUEST response;
    memset(&response, 0, sizeof(response));

    LONG token = lpContext->lTokenID;
    int roomid = pHuaCard->nRoomID;
    int tableno = pHuaCard->nTableNO;
    int userid = pHuaCard->nUserID;
    int chairno = pHuaCard->nChairNO;
    int cardchair = pHuaCard->nChairNO;

    BOOL bPassive = FALSE;
    CRoom* pRoom = NULL;
    CMJTable* pTable = NULL;
    if (!(pRoom = GetRoomPtr(roomid)))
    {
        return NotifyResponseFaild(lpContext, bPassive);
    }

    if (!(pTable = (CMJTable*)GetTablePtr(roomid, tableno)))
    {
        return NotifyResponseFaild(lpContext, bPassive);

    }

    if (pTable)
    {
        LOCK_TABLE(pTable, chairno, FALSE, userid, token);

        if (!pTable->IsPlayer(userid)) // 不是玩家
        {
            UwlLogFile(_T("user not player. user %ld hua card failed."), userid);
            return NotifyResponseFaild(lpContext, bPassive);
        }
        if (!IS_BIT_SET(pTable->m_dwStatus, TS_PLAYING_GAME)) // 游戏未在进行中
        {
            return NotifyResponseFaild(lpContext, bPassive);
        }
        if (!pTable->ValidateChair(chairno) || !pTable->ValidateChair(cardchair))
        {
            return NotifyResponseFaild(lpContext, bPassive);
        }
        if (!pTable->ValidateHua(pHuaCard))
        {
            return NotifyResponseFaild(lpContext, bPassive);
        }
        BOOL bBuHua = FALSE;
        int nCardID = pTable->GetGangCard(chairno, bBuHua);

        if (INVALID_OBJECT_ID == nCardID) // 没牌抓了
        {
            response.head.nRequest = GR_NO_CARD_CATCH;
            SendUserResponse(lpContext, &response, bPassive);

            OnNoCardLeft(pTable, chairno);
            DWORD dwWinFlags = pTable->CalcWinOnStandOff(chairno);
            if (dwWinFlags)
            {
                OnGameWin(lpContext, pRoom, pTable, chairno, FALSE, roomid);
            }
        }
        else
        {
            pTable->OnHua(pHuaCard);

            CARD_CAUGHT card_caught;
            ZeroMemory(&card_caught, sizeof(card_caught));
            card_caught.nChairNO = chairno;
            card_caught.nCardID = nCardID;
            card_caught.nCardNO = pTable->GetCardNO(card_caught.nCardID);
            card_caught.dwFlags = pTable->CalcHu_Zimo(chairno, card_caught.nCardID);

            response.head.nRequest = UR_OPERATE_SUCCEEDED;
            response.pDataPtr = &card_caught;
            response.nDataLen = sizeof(card_caught);
            SendUserResponse(lpContext, &response, bPassive);

            NotifyCardHua(pTable, pHuaCard, card_caught.nCardID, card_caught.nCardNO, token);
        }
    }
    return TRUE;
}

BOOL CMJServer::onThrowHuTingCards(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt)
{
    REQUEST response;
    memset(&response, 0, sizeof(response));

    SOCKET sock = lpContext->hSocket;
    LONG token = lpContext->lTokenID;

    SAFETY_PB_REQUEST(lpRequest, game::PB_TING_THROW_CARDS, tingThrowCards);

    THROW_CARDS ThrowCards;
    ZeroMemory(&ThrowCards, sizeof(THROW_CARDS));
    XygInitChairCards(ThrowCards.nCardIDs, MAX_CARDS_PER_CHAIR);
    ThrowCards.bPassive = tingThrowCards.passive();
    ThrowCards.dwCardsType = tingThrowCards.cards_type();
    for (int i = 0; i < tingThrowCards.card_ids_size(); i++)
    {
        ThrowCards.nCardIDs[i] = tingThrowCards.card_ids(i);
    }
    ThrowCards.nCardsCount = tingThrowCards.cards_cout();
    ThrowCards.nChairNO = tingThrowCards.chair_no();
    ThrowCards.nRoomID = tingThrowCards.room_id();
    ThrowCards.nTableNO = tingThrowCards.table_no();
    ThrowCards.nUserID = tingThrowCards.user_id();
    auto tmpSenderInfo = tingThrowCards.mutable_sender_info();
    ThrowCards.sender_info.nSendChair = tmpSenderInfo->send_chair();
    ThrowCards.sender_info.nSendTable = tmpSenderInfo->send_table();
    ThrowCards.sender_info.nSendUser = tmpSenderInfo->send_user();
    memcpy(ThrowCards.sender_info.szHardID, tmpSenderInfo->mutable_sz_hardid(), tmpSenderInfo->ByteSize());

    int roomid = ThrowCards.nRoomID;
    int tableno = ThrowCards.nTableNO;
    int userid = ThrowCards.nUserID;
    int chairno = ThrowCards.nChairNO;

    int bout_time = GetBoutTimeMin();

    LPSENDER_INFO pSenderInfo = LPSENDER_INFO(&(ThrowCards.sender_info));

    BOOL bPassive = (chairno != pSenderInfo->nSendChair) ? TRUE : FALSE;
    CRoom* pRoom = NULL;
    CMJTable* pTable = NULL;
    int senduser = pSenderInfo->nSendUser;
    if (bPassive && !IsSupportPassive())
    {
        return NotifyResponseFaild(lpContext, bPassive);
    }
    if (!(pRoom = GetRoomPtr(roomid)))
    {
        return NotifyResponseFaild(lpContext, bPassive);
    }

    if (!(pTable = (CMJTable*)GetTablePtr(roomid, tableno)))
    {
        return NotifyResponseFaild(lpContext, bPassive);
    }

    if (pTable)
    {
        LOCK_TABLE(pTable, chairno, bPassive, senduser, token);

        if (!pTable->IsPlayer(userid))  // 不是玩家
        {
            UwlLogFile(_T("user not player. user %ld merge throw cards failed. auto: %ld"), userid, bPassive);
            return NotifyResponseFaild(lpContext, bPassive);
        }
        UwlTrace(_T("chair %ld, user %ld merge throw cards. auto: %ld"), chairno, userid, bPassive);
        if (bPassive)
        {
            sock = pTable->m_ptrPlayers[chairno]->m_hSocket;
            token = pTable->m_ptrPlayers[chairno]->m_lTokenID;
        }
        if (!IS_BIT_SET(pTable->m_dwStatus, TS_WAITING_THROW))  // 不是等待出牌状态
        {
            UwlLogFile(_T("status not waiting_throw, chair %ld merge throw failed. auto: %ld"), chairno, bPassive);
            return NotifyResponseFaild(lpContext, bPassive);
        }
        if (chairno != pTable->GetCurrentChair())  //不该此人出牌!
        {
            LOG_TRACE(_T("current chair not same, chair %ld merge throw failed. auto: %ld"), chairno, bPassive);
            return NotifyResponseFaild(lpContext, bPassive);
        }
        if (bPassive)
        {
            if (!pTable->ValidateAutoThrow(chairno))
            {
                UwlLogFile(_T("time not exceeded, chair %ld merge autothrow failed. auto: %ld"), chairno, bPassive);
                return NotifyResponseFaild(lpContext, bPassive);
            }
            pTable->m_nAutoCount[chairno]++;
            if (pTable->m_nAutoCount[chairno] >= pTable->m_nMaxAutoThrow)
            {
                if (OnTooManyAuto(userid, roomid, tableno, chairno, sock, token))
                {
                    return NotifyResponseFaild(lpContext, bPassive);
                }
            }
            if (!pTable->ReplaceAutoThrow(&ThrowCards))
            {
                UwlLogFile(_T("ReplaceAutoThrow() failed. chair %ld. auto: %ld"), chairno, bPassive);
                return NotifyResponseFaild(lpContext, bPassive);
            }
        }

        // ***************************************************************
        //服务器与客户端同步检查
        if (!pTable->IsCardIDsInHand(chairno, ThrowCards.nCardIDs))
        {
            //客户端数据与服务器不符合
            UwlLogFile(_T("merge throw cards not in hand! roomid = %ld, tableno = %ld, chairno = %ld, userid = %ld. cardid = %ld, auto: %ld"),
                roomid, tableno, chairno, userid, ThrowCards.nCardIDs[0], bPassive);

            //将该玩家的牌重新发给他
            CARDS_INFO cardsinfo;
            ZeroMemory(&cardsinfo, sizeof(cardsinfo));
            cardsinfo.nUserID = userid;
            cardsinfo.nChairNO = chairno;
            cardsinfo.nCardsCount = pTable->GetChairCards(chairno, cardsinfo.nCardIDs, MAX_CARDS_PER_CHAIR);
            CPlayer* pPlayer = pTable->m_ptrPlayers[chairno];
            if (pPlayer != NULL)
            {
                NotifyOneUser(pPlayer->m_hSocket, pPlayer->m_lTokenID, GR_CARDS_INFO, &cardsinfo,
                    sizeof(cardsinfo) - sizeof(int) * (MAX_CARDS_PER_CHAIR - cardsinfo.nCardsCount));
            }
            response.head.nRequest = GR_GAMEDATA_ERROR;
            return SendUserResponse(lpContext, &response, bPassive);
        }

        if (ThrowCards.nCardsCount > 1)
        {
            int MJID = ThrowCards.nCardIDs[0];
            XygInitChairCards(ThrowCards.nCardIDs, MAX_CARDS_PER_CHAIR);
            ThrowCards.nCardIDs[0] = MJID;
            ThrowCards.nCardsCount = 1;//每次只可能出一张牌
        }
        if (0 == ThrowCards.dwCardsType)
        {
            UwlLogFile(_T("wrong type of cards! chair %ld merge throw failed. auto: %ld "), chairno, bPassive);
            return NotifyResponseFaild(lpContext, bPassive);
        }
        if (0 == ThrowCards.nCardsCount)
        {
            UwlLogFile(_T("zero count of cards! chair %ld merge throw failed. auto: %ld "), chairno, bPassive);
            return NotifyResponseFaild(lpContext, bPassive);
        }
        int nValidIDs[MAX_CARDS_PER_CHAIR];
        XygInitChairCards(nValidIDs, MAX_CARDS_PER_CHAIR);
        int rt = pTable->ValidateThrow(chairno, ThrowCards.nCardIDs,
                ThrowCards.nCardsCount, ThrowCards.dwCardsType, nValidIDs);
        if (0 == rt)
        {
            UwlLogFile(_T("ValidateThrow() return 0. chair %ld merge throw failed. auto: %ld "), chairno, bPassive);
            return NotifyResponseFaild(lpContext, bPassive);
        }
        else if (rt < 0)
        {
            UwlLogFile(_T("ValidateThrow() return -1. chair %ld merge throw failed. auto: %ld "), chairno, bPassive);
            NotifyInvalidThrow(pTable, &ThrowCards, token);
            return ResponseThrowAgain(lpContext, nValidIDs, bPassive);
        }
        UwlTrace(_T("chair %ld, user %ld merge throw OK! cardid: %ld, auto: %ld"),
            chairno, userid, ThrowCards.nCardIDs[0], bPassive);
        if (!pTable->ThrowCards(chairno, ThrowCards.nCardIDs))
        {
            LOG_ERROR(_T("pTable->ThrowCards error"));
            return NotifyResponseFaild(lpContext, bPassive);
        }
        pTable->SetWaitingsOnThrow(chairno, ThrowCards.nCardIDs, ThrowCards.dwCardsType);
        pTable->SetStatusOnThrow();
        pTable->SetCurrentChairOnThrow();

        int nCurrentChairNO = pTable->GetCurrentChair();

        if (pTable->ValidateMergeCatch(nCurrentChairNO))
        {
            BOOL bBuHua = FALSE;
            int nTmpCardNO = pTable->CatchCard(nCurrentChairNO, bBuHua);
            if (bBuHua)
            {
                NotifySomeOneBuHua(pTable);
            }
            if (pTable->m_nJokerNO == nTmpCardNO)   //抓到翻牌
            {
                bBuHua = FALSE;
                nTmpCardNO = OnJokerShownCaught(pTable, nCurrentChairNO, bBuHua);
                if (bBuHua)
                {
                    NotifySomeOneBuHua(pTable);
                }
            }
            if (INVALID_OBJECT_ID == nTmpCardNO || !IS_BIT_SET(pTable->m_dwStatus, TS_WAITING_CATCH))
            {
                pTable->SetBaoTingFlag(ThrowCards.nChairNO);
                ResponseThrowCardSucceed(response, lpContext, pTable, &ThrowCards, bPassive);

                if (bPassive)
                {
                    NotifyCardsThrow(pTable, &ThrowCards, MJ_GR_BAOTING_THROWCARDS, 0);
                }
                else
                {
                    NotifyCardsThrow(pTable, &ThrowCards, MJ_GR_BAOTING_THROWCARDS, token);
                }

                OnNoCardLeft(pTable, nCurrentChairNO);
                DWORD dwWinFlags = pTable->CalcWinOnStandOff(nCurrentChairNO);
                if (dwWinFlags)
                {
                    OnGameWin(lpContext, pRoom, pTable, nCurrentChairNO, FALSE, roomid);
                }
            }
            else
            {
                OnCardCaught(pTable, nCurrentChairNO);

                int nCardID = pTable->GetCardID(nTmpCardNO);
                CARD_CAUGHT Card = { nCurrentChairNO, nCardID, nTmpCardNO, pTable->CalcHu_Zimo(nCurrentChairNO, nCardID) };

                MERGE_THROWCARDS mergeThrowCards;
                ZeroMemory(&mergeThrowCards, sizeof(mergeThrowCards));

                mergeThrowCards.bPassive = ThrowCards.bPassive;
                mergeThrowCards.dwCardsType = ThrowCards.dwCardsType;
                mergeThrowCards.nCardsCount = ThrowCards.nCardsCount;
                mergeThrowCards.nChairNO = ThrowCards.nChairNO;
                mergeThrowCards.nRoomID = ThrowCards.nRoomID;
                mergeThrowCards.nTableNO = ThrowCards.nTableNO;
                mergeThrowCards.nUserID = ThrowCards.nUserID;

                memcpy(mergeThrowCards.nReserved, ThrowCards.nReserved, sizeof(mergeThrowCards.nReserved));
                memcpy(mergeThrowCards.nCardIDs, ThrowCards.nCardIDs, sizeof(mergeThrowCards.nCardIDs));
                memcpy(&mergeThrowCards.card_caught, &Card, sizeof(CARD_CAUGHT));
                memcpy(&mergeThrowCards.sender_info, &ThrowCards.sender_info, sizeof(SENDER_INFO));

                pTable->SetBaoTingFlag(ThrowCards.nChairNO);
                response.head.nRequest = UR_OPERATE_SUCCEEDED;
                response.pDataPtr = &mergeThrowCards;
                response.nDataLen = sizeof(mergeThrowCards);
                SendUserResponse(lpContext, &response, bPassive);

                pTable->SaveTingCardsForDXXW(ThrowCards.nCardIDs[0], ThrowCards.nChairNO);
                if (bPassive)
                {
                    NotifyMergeCardsThrow(pTable, &mergeThrowCards, MJ_GR_BAOTING_MERGETHROWCARDS, 0);
                }
                else
                {
                    NotifyMergeCardsThrow(pTable, &mergeThrowCards, MJ_GR_BAOTING_MERGETHROWCARDS, token);
                }

                OnServerAutoPlay(pRoom, pTable, pTable->GetCurrentChair(), !pTable->IsOffline(pTable->GetCurrentChair()));
            }
        }
        else
        {
            pTable->SetBaoTingFlag(ThrowCards.nChairNO);
            ResponseThrowCardSucceed(response, lpContext, pTable, &ThrowCards, bPassive);

            if (bPassive)
            {
                NotifyCardsThrow(pTable, &ThrowCards, MJ_GR_BAOTING_THROWCARDS, 0);

                if (pTable->m_nAutoCount[chairno] >= 2 && !pTable->IsOffline(chairno))
                {
                    OnPlayerOffline(pTable, chairno);
                    OnServerAutoPlay(pRoom, pTable, chairno, !pTable->IsOffline(chairno));
                }
            }
            else
            {
                NotifyCardsThrow(pTable, &ThrowCards, MJ_GR_BAOTING_THROWCARDS, token);
            }

            if (0 == pTable->HaveCards(chairno))  // 自己手里牌已出完
            {
                pTable->OnNoCardRemains(chairno);
                OnNoCardRemains(pTable, chairno);
            }
            DWORD dwWinFlags = pTable->CalcWinOnThrow(chairno, ThrowCards.nCardIDs, ThrowCards.dwCardsType);
            if (dwWinFlags)
            {
                BOOL bout_invalid = pTable->IsBoutInvalid(bout_time);
                OnGameWin(lpContext, pRoom, pTable, chairno, bout_invalid, roomid);
            }
            //服务端自动抓牌
            if (!dwWinFlags)
            {
                OnServerAutoPlay(pRoom, pTable, pTable->GetCurrentChair(), !pTable->IsOffline(pTable->GetCurrentChair()));
            }
            //end
        }
    }
    return TRUE;
}

BOOL CMJServer::OnGetTableInfo(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt)
{
    SAFETY_NET_REQUEST(lpRequest, GET_TABLE_INFO, pGetTableInfo);

    REQUEST response;
    memset(&response, 0, sizeof(response));

    BOOL lookon = FALSE;
    LONG token = lpContext->lTokenID;
    int roomid = pGetTableInfo->nRoomID;
    int tableno = pGetTableInfo->nTableNO;
    int userid = pGetTableInfo->nUserID;
    int chairno = pGetTableInfo->nChairNO;

    CTable* pTable = NULL;
    CPlayer* pPlayer = NULL;
    if (IsRandomRoom(roomid))
    {
        CAutoLock lock(&m_csSoloPlayer);
        SOLO_PLAYER soloPlayer;
        memset(&soloPlayer, 0, sizeof(SOLO_PLAYER));
        if (!m_mapSoloPlayer.Lookup(userid, soloPlayer))
        {
            response.head.nRequest = UR_OPERATE_FAILED;
            return SendUserResponse(lpContext, &response);
        }
        tableno = soloPlayer.nTableNO;
        chairno = soloPlayer.nChairNO;
    }

    if (!(pTable = (CMJTable*)GetTablePtr(roomid, tableno)))
    {
        return NotifyResponseFaild(lpContext);
    }


    if (pTable)
    {
        LOCK_TABLE(pTable, chairno, FALSE, userid, token);

        pTable->m_mapUser.Lookup(userid, pPlayer);
        if (!pPlayer || !pPlayer->m_nUserID || pPlayer->m_nChairNO != chairno)
        {
            response.head.nRequest = UR_OPERATE_FAILED;
            return SendUserResponse(lpContext, &response);
        }
        lookon = pPlayer->m_bLookOn;

        int nLen = pTable->GetGameTableInfoSize();
        LPVOID pData = (LPBYTE)malloc(sizeof(BYTE) * nLen);

        pTable->FillupGameTableInfo(pData, nLen, chairno, lookon);

        // TODO : 库里开接口给我们 ***********************************************************************
        if (((CMJTable*)pTable)->IsTingPaiActive())
        {

            if (IS_BIT_SET(((CMJTable*)pTable)->m_dwGameFlags, MJ_GF_16_CARDS))
            {
                nLen = pTable->GetGameTableInfoSize() + sizeof(CARD_TING_DETAIL_16);
                pData = realloc(pData, nLen);

                ((CMJTable*)pTable)->CalcTingCard_17(chairno);

                PBYTE ptr_tingDetail = (PBYTE)pData + pTable->GetGameTableInfoSize();
                memcpy(ptr_tingDetail, &(((CMJTable*)pTable)->m_CardTingDetail_16), sizeof(CARD_TING_DETAIL_16));
            }
            else
            {
                nLen = pTable->GetGameTableInfoSize() + sizeof(CARD_TING_DETAIL);
                pData = realloc(pData, nLen);

                ((CMJTable*)pTable)->CalcTingCard(chairno);

                PBYTE ptr_tingDetail = (PBYTE)pData + pTable->GetGameTableInfoSize();
                memcpy(ptr_tingDetail, &(((CMJTable*)pTable)->m_CardTingDetail), sizeof(CARD_TING_DETAIL));
            }
        }
        // TODO : 库里开接口给我们 ***********************************************************************

        response.head.nRequest = UR_OPERATE_SUCCEEDED;
        response.pDataPtr = pData;
        response.nDataLen = nLen;
    }
    BOOL bSendOK = SendUserResponse(lpContext, &response, FALSE, TRUE);
    if (response.pDataPtr)
    {
        free(response.pDataPtr);
    }
    return TRUE;
}

void CMJServer::NotifyAuctionBanker(CMJTable* pTable, LPAUCTION_BANKER pAuctionBanker, LONG tokenExcept)
{
    BANKER_AUCTION bankerauction;
    ZeroMemory(&bankerauction, sizeof(bankerauction));

    bankerauction.nUserID = pAuctionBanker->nUserID;
    bankerauction.nChairNO = pAuctionBanker->nChairNO;
    bankerauction.bPassed = pAuctionBanker->bPassed;
    bankerauction.nGains = pAuctionBanker->nGains;

    NotifyTablePlayers(pTable, GR_BANKER_AUCTION, &bankerauction, sizeof(bankerauction), tokenExcept);
    NotifyTableVisitors(pTable, GR_BANKER_AUCTION, &bankerauction, sizeof(bankerauction), tokenExcept);
}

void CMJServer::NotifyAuctionFinished(CMJTable* pTable, LPAUCTION_BANKER pAuctionBanker, LONG tokenExcept)
{
    AUCTION_FINISHED auctionfinished;
    ZeroMemory(&auctionfinished, sizeof(auctionfinished));

    auctionfinished.nBanker = pTable->m_nBanker;
    auctionfinished.nObjectGains = pTable->m_nObjectGains;
    memcpy(auctionfinished.nBottomIDs, pTable->m_nBottomIDs, sizeof(auctionfinished.nBottomIDs));

    NotifyTablePlayers(pTable, GR_AUCTION_FINISHED, &auctionfinished, sizeof(auctionfinished), tokenExcept);
    NotifyTableVisitors(pTable, GR_AUCTION_FINISHED, &auctionfinished, sizeof(auctionfinished), tokenExcept);
}

void CMJServer::NotifyInvalidThrow(CMJTable* pTable, LPTHROW_CARDS pThrowCards, LONG tokenExcept)
{
    CARDS_THROW cardsthrow;
    ZeroMemory(&cardsthrow, sizeof(cardsthrow));

    cardsthrow.nUserID = pThrowCards->nUserID;
    cardsthrow.nChairNO = pThrowCards->nChairNO;
    cardsthrow.nNextChair = pTable->GetCurrentChair();
    cardsthrow.bNextFirst = FALSE;
    cardsthrow.nRemains = pTable->HaveCards(pThrowCards->nChairNO);
    cardsthrow.dwCardsType = pThrowCards->dwCardsType;
    cardsthrow.nCardsCount = pThrowCards->nCardsCount;
    memcpy(cardsthrow.nCardIDs, pThrowCards->nCardIDs, sizeof(cardsthrow.nCardIDs));

    NotifyTablePlayers(pTable, GR_INVALID_THROW, &cardsthrow,
        sizeof(cardsthrow) - sizeof(int) * (MAX_CARDS_PER_CHAIR - cardsthrow.nCardsCount),
        tokenExcept);
    NotifyTableVisitors(pTable, GR_INVALID_THROW, &cardsthrow,
        sizeof(cardsthrow) - sizeof(int) * (MAX_CARDS_PER_CHAIR - cardsthrow.nCardsCount),
        tokenExcept);
}

BOOL CMJServer::ResponseThrowAgain(LPCONTEXT_HEAD lpContext, int nCardIDs[], BOOL bPassive)
{
    REQUEST response;
    memset(&response, 0, sizeof(response));
    THROW_AGAIN throwagain;
    memset(&throwagain, 0, sizeof(throwagain));

    memcpy(throwagain.nCardIDs, nCardIDs, sizeof(throwagain.nCardIDs));
    throwagain.nCardsCount = XygGetCountOfCards(nCardIDs, MAX_CARDS_PER_CHAIR);

    response.head.nRequest = GR_THROW_AGAIN;
    response.pDataPtr = &throwagain;
    response.nDataLen = sizeof(throwagain) - sizeof(int) * (MAX_CARDS_PER_CHAIR - throwagain.nCardsCount);
    return SendUserResponse(lpContext, &response, bPassive);
}

void CMJServer::NotifyCardsThrow(CMJTable* pTable, LPTHROW_CARDS pThrowCards, UINT nRequest, LONG tokenExcept)
{
    CARDS_THROW cardsthrow;
    ZeroMemory(&cardsthrow, sizeof(cardsthrow));

    for (int i = 0; i < pTable->m_nTotalChairs; i++)
    {
        CMJTable* pTb = (CMJTable*)pTable;
        cardsthrow.dwFlags[i] = pTb->m_dwPGCHFlags[i];
        cardsthrow.dwFlags[i] |= pTb->m_dwGuoFlags[i];
    }
    cardsthrow.nUserID = pThrowCards->nUserID;
    cardsthrow.nChairNO = pThrowCards->nChairNO;
    cardsthrow.nNextChair = pTable->GetCurrentChair();
    cardsthrow.bNextFirst = pTable->IsNextFirstHand();
    cardsthrow.nRemains = pTable->HaveCards(pThrowCards->nChairNO);
    cardsthrow.nThrowCount = pTable->m_nThrowCount;
    cardsthrow.dwCardsType = pThrowCards->dwCardsType;
    cardsthrow.nCardsCount = pThrowCards->nCardsCount;
    memcpy(cardsthrow.nCardIDs, pThrowCards->nCardIDs, sizeof(cardsthrow.nCardIDs));
    memcpy(cardsthrow.nReserved, pThrowCards->nReserved, sizeof(pThrowCards->nReserved));
    // 断线自动出牌，记录下标记，录像用
    if (pTable->IsOffline(cardsthrow.nChairNO))
    {
        cardsthrow.nReserved[1] = 1;
    }

    // 分发事件
    evMJThrow.notify(pTable, pThrowCards);

    NotifyTablePlayers(pTable, nRequest, &cardsthrow,
        sizeof(cardsthrow) - sizeof(int) * (MAX_CARDS_PER_CHAIR - cardsthrow.nCardsCount),
        tokenExcept);
    NotifyTableVisitors(pTable, nRequest, &cardsthrow,
        sizeof(cardsthrow) - sizeof(int) * (MAX_CARDS_PER_CHAIR - cardsthrow.nCardsCount),
        tokenExcept);
}

void CMJServer::NotifyCardCaught(CMJTable* pTable, LPCARD_CAUGHT pCardCaught, LONG tokenExcept)
{
    CPlayer* ptrP = pTable->m_ptrPlayers[pCardCaught->nChairNO];
    if (tokenExcept == 0)
    {
        tokenExcept = ptrP->m_lTokenID;
        NotifyOneUser(ptrP->m_hSocket, ptrP->m_lTokenID, GR_CARD_CAUGHT, pCardCaught, sizeof(CARD_CAUGHT));
    }
    else if (tokenExcept != ptrP->m_lTokenID)
    {
        ASSERT(FALSE);//目前没这种用法，遇到了就重载吧
    }

    int nCardID = pCardCaught->nCardID;
    pCardCaught->nCardID = INVALID_OBJECT_ID;
    NotifyTablePlayers(pTable, GR_CARD_CAUGHT, pCardCaught, sizeof(CARD_CAUGHT), tokenExcept);
    pCardCaught->nCardID = nCardID;

    NotifyTableVisitors(pTable, GR_CARD_CAUGHT, pCardCaught, sizeof(CARD_CAUGHT), tokenExcept);
}

void CMJServer::NotifyCardPreChi(CMJTable* pTable, LPPRECHI_CARD pPreChiCard, LONG tokenExcept)
{
    CARD_PRECHI cardprechi;
    ZeroMemory(&cardprechi, sizeof(cardprechi));
    memcpy(&cardprechi, pPreChiCard, sizeof(cardprechi));

    NotifyTablePlayers(pTable, GR_CARD_PRECHI, &cardprechi, sizeof(cardprechi), tokenExcept);
    NotifyTableVisitors(pTable, GR_CARD_PRECHI, &cardprechi, sizeof(cardprechi), tokenExcept);
}

void CMJServer::NotifyCardChi(CMJTable* pTable, LPCHI_CARD pChiCard, LONG tokenExcept)
{
    CARD_CHI cardchi;
    ZeroMemory(&cardchi, sizeof(cardchi));
    memcpy(&cardchi, pChiCard, sizeof(cardchi));

    // 分发事件
    evMJChi.notify(pTable, pChiCard);

    NotifyTablePlayers(pTable, GR_CARD_CHI, &cardchi, sizeof(cardchi), tokenExcept);
    NotifyTableVisitors(pTable, GR_CARD_CHI, &cardchi, sizeof(cardchi), tokenExcept);
}

void CMJServer::NotifyCardPrePeng(CMJTable* pTable, LPPREPENG_CARD pPrePengCard, LONG tokenExcept)
{
    CARD_PREPENG cardprepeng;
    ZeroMemory(&cardprepeng, sizeof(cardprepeng));
    memcpy(&cardprepeng, pPrePengCard, sizeof(cardprepeng));

    NotifyTablePlayers(pTable, GR_CARD_PREPENG, &cardprepeng, sizeof(cardprepeng), tokenExcept);
    NotifyTableVisitors(pTable, GR_CARD_PREPENG, &cardprepeng, sizeof(cardprepeng), tokenExcept);
}

void CMJServer::NotifyCardPeng(CMJTable* pTable, LPPENG_CARD pPengCard, LONG tokenExcept)
{
    CARD_PENG cardpeng;
    ZeroMemory(&cardpeng, sizeof(cardpeng));
    memcpy(&cardpeng, pPengCard, sizeof(cardpeng));

    // 事件分发
    evMJPeng.notify(pTable, pPengCard);

    NotifyTablePlayers(pTable, GR_CARD_PENG, &cardpeng, sizeof(cardpeng), tokenExcept);
    NotifyTableVisitors(pTable, GR_CARD_PENG, &cardpeng, sizeof(cardpeng), tokenExcept);
}

void CMJServer::NotifyPreGangOK(CMJTable* pTable, LPPREGANG_OK pPreGangOK, LONG tokenExcept)
{
    NotifyTablePlayers(pTable, GR_PREGANG_OK, pPreGangOK, sizeof(PREGANG_OK), tokenExcept);
    NotifyTableVisitors(pTable, GR_PREGANG_OK, pPreGangOK, sizeof(PREGANG_OK), tokenExcept);
}

void CMJServer::NotifyCardMnGang(CMJTable* pTable, LPGANG_CARD pGangCard, int card_got, int card_no, LONG tokenExcept)
{
    CARD_GANG cardgang;
    ZeroMemory(&cardgang, sizeof(cardgang));
    memcpy(&cardgang, pGangCard, sizeof(cardgang));
    cardgang.nCardGot = card_got;
    cardgang.nCardNO = card_no;

    // 事件分发
    evMJMnGang.notify(pTable, pGangCard, &cardgang);

    CPlayer* ptrP = pTable->m_ptrPlayers[cardgang.nChairNO];
    if (tokenExcept == 0)
    {
        tokenExcept = ptrP->m_lTokenID;
        NotifyOneUser(ptrP->m_hSocket, ptrP->m_lTokenID, GR_CARD_MN_GANG, &cardgang, sizeof(cardgang));
    }
    else if (tokenExcept != ptrP->m_lTokenID)
    {
        ASSERT(FALSE);//目前没这种用法，遇到了就重载吧
    }

    cardgang.nCardGot = INVALID_OBJECT_ID;
    NotifyTablePlayers(pTable, GR_CARD_MN_GANG, &cardgang, sizeof(cardgang), tokenExcept);
    cardgang.nCardGot = card_got;

    NotifyTableVisitors(pTable, GR_CARD_MN_GANG, &cardgang, sizeof(cardgang), tokenExcept);
}

void CMJServer::NotifyCardAnGang(CMJTable* pTable, LPGANG_CARD pGangCard, int card_got, int card_no, LONG tokenExcept)
{
    CARD_GANG cardgang;
    ZeroMemory(&cardgang, sizeof(cardgang));
    memcpy(&cardgang, pGangCard, sizeof(cardgang));
    cardgang.nCardGot = card_got;
    cardgang.nCardNO = card_no;

    // 事件分发
    evMJAnGang.notify(pTable, pGangCard, &cardgang);

    CPlayer* ptrP = pTable->m_ptrPlayers[cardgang.nChairNO];
    if (tokenExcept == 0)
    {
        tokenExcept = ptrP->m_lTokenID;
        NotifyOneUser(ptrP->m_hSocket, ptrP->m_lTokenID, GR_CARD_AN_GANG, &cardgang, sizeof(cardgang));
    }
    else if (tokenExcept != ptrP->m_lTokenID)
    {
        ASSERT(FALSE);//目前没这种用法，遇到了就重载吧
    }

    cardgang.nCardGot = INVALID_OBJECT_ID;
    NotifyTablePlayers(pTable, GR_CARD_AN_GANG, &cardgang, sizeof(cardgang), tokenExcept);
    cardgang.nCardGot = card_got;

    NotifyTableVisitors(pTable, GR_CARD_AN_GANG, &cardgang, sizeof(cardgang), tokenExcept);
}

void CMJServer::NotifyCardPnGang(CMJTable* pTable, LPGANG_CARD pGangCard, int card_got, int card_no, LONG tokenExcept)
{
    CARD_GANG cardgang;
    ZeroMemory(&cardgang, sizeof(cardgang));

    memcpy(&cardgang, pGangCard, sizeof(cardgang));
    cardgang.nCardGot = card_got;
    cardgang.nCardNO = card_no;

    // 事件分发
    evMJPnGang.notify(pTable, pGangCard, &cardgang);

    CPlayer* ptrP = pTable->m_ptrPlayers[cardgang.nChairNO];
    if (tokenExcept == 0)
    {
        tokenExcept = ptrP->m_lTokenID;
        NotifyOneUser(ptrP->m_hSocket, ptrP->m_lTokenID, GR_CARD_PN_GANG, &cardgang, sizeof(cardgang));
    }
    else if (tokenExcept != ptrP->m_lTokenID)
    {
        ASSERT(FALSE);//目前没这种用法，遇到了就重载吧
    }

    cardgang.nCardGot = INVALID_OBJECT_ID;
    NotifyTablePlayers(pTable, GR_CARD_PN_GANG, &cardgang, sizeof(cardgang), tokenExcept);
    cardgang.nCardGot = card_got;

    NotifyTableVisitors(pTable, GR_CARD_PN_GANG, &cardgang, sizeof(cardgang), tokenExcept);
}

void CMJServer::NotifyCardHua(CMJTable* pTable, LPHUA_CARD pHuaCard, int card_got, int card_no, LONG tokenExcept)
{
    CARD_HUA cardhua;
    ZeroMemory(&cardhua, sizeof(cardhua));

    memcpy(&cardhua, pHuaCard, sizeof(cardhua));
    cardhua.nCardGot = card_got;
    cardhua.nCardNO = card_no;

    // 事件分发
    evMJHua.notify(pTable, pHuaCard, &cardhua);
    NotifyTablePlayers(pTable, GR_CARD_HUA, &cardhua, sizeof(cardhua), tokenExcept);
    NotifyTableVisitors(pTable, GR_CARD_HUA, &cardhua, sizeof(cardhua), tokenExcept);
}

BOOL CMJServer::NotifyTableMsg(CTable* pTable, int nDest, int nMsgID, int datalen, void* data, LONG tokenExcept)
{
    int size = datalen + sizeof(GAME_MSG);
    BYTE* pGameMsg = new BYTE[size];
    memset(pGameMsg, 0, size);
    GAME_MSG* pHead = (GAME_MSG*)pGameMsg;
    BYTE* pData = pGameMsg + sizeof(GAME_MSG);
    pHead->nMsgID = nMsgID;
    pHead->nUserID = -1;
    pHead->nVerifyKey = -1;
    pHead->nDatalen = datalen;
    if (datalen)
    {
        memcpy(pData, data, datalen);
    }

    if (pTable->ValidateChair(nDest))
    {
        //发送给个体
        CPlayer* pPlayer = pTable->m_ptrPlayers[nDest];
        NotifyOneUser(pPlayer->m_hSocket, pPlayer->m_lTokenID, GR_SENDMSG_TO_PLAYER, pGameMsg, size);
    }
    else
    {
        if (nDest == GAME_MSG_SEND_OTHER)
        {
            NotifyTablePlayers(pTable, GR_SENDMSG_TO_PLAYER, pGameMsg, size, tokenExcept);
            NotifyTableVisitors(pTable, GR_SENDMSG_TO_PLAYER, pGameMsg, size, tokenExcept);
        }
        else if (nDest == GAME_MSG_SEND_OTHER_PLAYER)
        {
            NotifyTablePlayers(pTable, GR_SENDMSG_TO_PLAYER, pGameMsg, size, tokenExcept);
        }
        else if (nDest == GAME_MSG_SEND_EVERY_PLAYER)
        {
            NotifyTablePlayers(pTable, GR_SENDMSG_TO_PLAYER, pGameMsg, size);
        }
        else
        {
            NotifyTablePlayers(pTable, GR_SENDMSG_TO_PLAYER, pGameMsg, size);
            NotifyTableVisitors(pTable, GR_SENDMSG_TO_PLAYER, pGameMsg, size);
        }
    }

    delete[]pGameMsg;
    return TRUE;
}

BOOL CMJServer::NotifyPlayerMsgAndResponse(LPCONTEXT_HEAD lpContext, CTable* pTable, int nDest, DWORD dwFlags, DWORD datalen, void* data)
{
    int size = datalen + sizeof(GAME_MSG);
    BYTE* pGameMsg = new BYTE[size];
    memset(pGameMsg, 0, size);
    GAME_MSG* pHead = (GAME_MSG*)pGameMsg;
    BYTE* pData = pGameMsg + sizeof(GAME_MSG);
    pHead->nMsgID = dwFlags;
    pHead->nUserID = -1;
    pHead->nVerifyKey = -1;
    pHead->nDatalen = datalen;
    if (datalen)
    {
        memcpy(pData, data, datalen);
    }

    REQUEST response;
    memset(&response, 0, sizeof(response));
    response.head.nRequest = UR_OPERATE_SUCCEEDED;
    response.pDataPtr = pGameMsg;
    response.nDataLen = size;

    if (pTable->ValidateChair(nDest))
    {
        CPlayer* pPlayer = pTable->m_ptrPlayers[nDest];
        if (lpContext->lTokenID == pPlayer->m_lTokenID
            && lpContext->bNeedEcho)
        {
            //是自己，那么回应
            lpContext->bNeedEcho = FALSE; //已经回应过不再回应
            SendUserResponse(lpContext, &response);
        }
        else
        {
            //不是发送家，那么发送
            NotifyOneUser(pPlayer->m_hSocket, pPlayer->m_lTokenID, GR_SENDMSG_TO_PLAYER, pGameMsg, size);
        }
    }
    else
    {
        if (nDest == GAME_MSG_SEND_OTHER)
        {
            NotifyTablePlayers(pTable, GR_SENDMSG_TO_PLAYER, pGameMsg, size, lpContext->lTokenID);
            NotifyTableVisitors(pTable, GR_SENDMSG_TO_PLAYER, pGameMsg, size, lpContext->lTokenID);
        }
        else if (nDest == GAME_MSG_SEND_OTHER_PLAYER)
        {
            NotifyTablePlayers(pTable, GR_SENDMSG_TO_PLAYER, pGameMsg, size, lpContext->lTokenID);
        }
        else if (nDest == GAME_MSG_SEND_VISITOR)
        {
            NotifyTableVisitors(pTable, GR_SENDMSG_TO_PLAYER, pGameMsg, size);
        }
        else if (nDest == GAME_MSG_SEND_EVERY_PLAYER)
        {
            if (lpContext->bNeedEcho)
            {
                lpContext->bNeedEcho = FALSE; //已经回应过不再回应
                SendUserResponse(lpContext, &response);
                NotifyTablePlayers(pTable, GR_SENDMSG_TO_PLAYER, pGameMsg, size, lpContext->lTokenID);
            }
            else
            {
                NotifyTablePlayers(pTable, GR_SENDMSG_TO_PLAYER, pGameMsg, size, 0);
            }
        }
        else
        {
            if (lpContext->bNeedEcho)
            {
                lpContext->bNeedEcho = FALSE; //已经回应过不再回应
                SendUserResponse(lpContext, &response);
                NotifyTablePlayers(pTable, GR_SENDMSG_TO_PLAYER, pGameMsg, size, lpContext->lTokenID);
                NotifyTableVisitors(pTable, GR_SENDMSG_TO_PLAYER, pGameMsg, size, lpContext->lTokenID);
            }
            else
            {
                NotifyTablePlayers(pTable, GR_SENDMSG_TO_PLAYER, pGameMsg, size, 0);
                NotifyTableVisitors(pTable, GR_SENDMSG_TO_PLAYER, pGameMsg, size, 0);
            }
        }

    }

    delete[]pGameMsg;
    return TRUE;
}

void CMJServer::NotifyMergeCardsThrow(CMJTable* pTable, LPMERGE_THROWCARDS pMergeThrowCards, UINT nRequest, LONG tokenExcept /*= 0*/)
{
    MERGE_CARDSTHROW mergecardsthrow;
    ZeroMemory(&mergecardsthrow, sizeof(mergecardsthrow));

    for (int i = 0; i < pTable->m_nTotalChairs; i++)
    {

        mergecardsthrow.dwFlags[i] = pTable->m_dwPGCHFlags[i];
        mergecardsthrow.dwFlags[i] |= pTable->m_dwGuoFlags[i];
    }
    mergecardsthrow.nUserID = pMergeThrowCards->nUserID;
    mergecardsthrow.nChairNO = pMergeThrowCards->nChairNO;
    mergecardsthrow.nNextChair = pTable->GetCurrentChair();
    mergecardsthrow.bNextFirst = pTable->IsNextFirstHand();
    mergecardsthrow.nRemains = pTable->HaveCards(pMergeThrowCards->nChairNO);
    mergecardsthrow.nThrowCount = pTable->m_nThrowCount;
    mergecardsthrow.dwCardsType = pMergeThrowCards->dwCardsType;
    mergecardsthrow.nCardsCount = pMergeThrowCards->nCardsCount;
    mergecardsthrow.card_caught.dwFlags = pMergeThrowCards->card_caught.dwFlags;
    mergecardsthrow.card_caught.nCardID = pMergeThrowCards->card_caught.nCardID;
    mergecardsthrow.card_caught.nCardNO = pMergeThrowCards->card_caught.nCardNO;
    mergecardsthrow.card_caught.nChairNO = pMergeThrowCards->card_caught.nChairNO;
    memcpy(mergecardsthrow.card_caught.nReserved, pMergeThrowCards->card_caught.nReserved, sizeof(mergecardsthrow.card_caught.nReserved));

    memcpy(mergecardsthrow.nCardIDs, pMergeThrowCards->nCardIDs, sizeof(mergecardsthrow.nCardIDs));
    memcpy(mergecardsthrow.nReserved, pMergeThrowCards->nReserved, sizeof(mergecardsthrow.nReserved));

    mergecardsthrow.nReserved[0] = MERGE_THROWCARDS_CATCHCARDS;
    CPlayer* pPlayer = pTable->m_ptrPlayers[pTable->GetPrevChair(mergecardsthrow.nNextChair)];

    if (((CMJTable*)pTable)->IsTingPaiActive())
    {
        CBuffer buff;
        buff.Write((BYTE*)&mergecardsthrow, sizeof(MERGE_CARDSTHROW));
        if (IS_BIT_SET(pTable->m_dwGameFlags, MJ_GF_16_CARDS))
        {
            pTable->CalcTingCard_17(mergecardsthrow.card_caught.nChairNO);
            buff.Write((BYTE*) & (pTable->m_CardTingDetail_16), sizeof(CARD_TING_DETAIL_16));
        }
        else
        {
            pTable->CalcTingCard(mergecardsthrow.card_caught.nChairNO);
            buff.Write((BYTE*) & (pTable->m_CardTingDetail), sizeof(CARD_TING_DETAIL));
        }
        // BUGId：31887
        for (int i = 0; i < pTable->m_nTotalChairs; i++)
        {
            CPlayer* ptrP = pTable->m_ptrPlayers[i];
            if (ptrP && ptrP->m_lTokenID != tokenExcept)
            {
                if (i == mergecardsthrow.card_caught.nChairNO)
                {
                    NotifyOneUser(ptrP->m_hSocket, ptrP->m_lTokenID, GR_MERGE_CARDSTHROW, buff.GetBuffer(), buff.GetBufferLen());
                }
                else
                {
                    NotifyOneUser(ptrP->m_hSocket, ptrP->m_lTokenID, GR_MERGE_CARDSTHROW, &mergecardsthrow
                        , sizeof(mergecardsthrow) - sizeof(int) * (MAX_CARDS_PER_CHAIR - mergecardsthrow.nCardsCount));
                }
            }
        }

        //NotifyTablePlayers(pTable, GR_MERGE_CARDSTHROW, buff.GetBuffer(), buff.GetBufferLen(), tokenExcept);
        NotifyTableVisitors(pTable, GR_MERGE_CARDSTHROW, buff.GetBuffer(), buff.GetBufferLen(), tokenExcept);
    }
    else
    {
        NotifyTablePlayers(pTable, GR_MERGE_CARDSTHROW, &mergecardsthrow,
            sizeof(mergecardsthrow) - sizeof(int) * (MAX_CARDS_PER_CHAIR - mergecardsthrow.nCardsCount),
            tokenExcept);
        NotifyTableVisitors(pTable, GR_MERGE_CARDSTHROW, &mergecardsthrow,
            sizeof(mergecardsthrow) - sizeof(int) * (MAX_CARDS_PER_CHAIR - mergecardsthrow.nCardsCount),
            tokenExcept);
    }
}

int CMJServer::OnJokerShownCaught(CMJTable* pTable, int chairno, BOOL& bBuHua)
{
    if (IS_BIT_SET(pTable->m_dwGameFlags, MJ_GF_JOKER_SHOWN_SKIP)) // 摸到财神跳过
    {
        pTable->ThrowJokerShown(chairno);
        return pTable->CatchCard(chairno, bBuHua);
    }
    else
    {
        return INVALID_OBJECT_ID;
    }
}

int CMJServer::OnCardCaught(CMJTable* pTable, int chairno)
{
    pTable->SetStatusOnCatch();
    pTable->SetCurrentChairOnCatch();

    return 1;
}

BOOL CMJServer::NotifySomeOneBuHua(CMJTable* pTable, LONG tokenExcept/* = 0*/)
{
    // tableinfo
    game::PB_NTF_SOMEONE_BUHUA* pMsg = (game::PB_NTF_SOMEONE_BUHUA*)(((CMJTable*)pTable)->GetHuaData());

    int nLen = pMsg->ByteSize();
    if (nLen == 0)
    {
        return FALSE;
    }
    LPVOID pData = new_byte_array(nLen);
    if (!pMsg->SerializeToArray(pData, nLen))
    {
        SAFE_DELETE(pMsg);
        SAFE_DELETE_ARRAY(pData);
        UWL_ERR("NotifySomeOneBuHua Serialize faild.");
    }

    SAFE_DELETE(pMsg);
    NotifyTablePlayers(pTable, NTF_SOMEONE_BUHUA, pData, nLen, tokenExcept);
    NotifyTableVisitors(pTable, NTF_SOMEONE_BUHUA, pData, nLen, tokenExcept);

    SAFE_DELETE_ARRAY(pData);
    return TRUE;
}

void CMJServer::OnServerChiPengGangCard(CRoom* pRoom, CMJTable* pTable)
{
    CMJTable* pGameTable = (CMJTable*)pTable;
    int nRoomID = pRoom->m_nRoomID;
    int chairno = pGameTable->m_nWaitOpeChair;

    if (!IS_BIT_SET(pGameTable->m_dwStatus, TS_PLAYING_GAME) || !pGameTable->ValidateChair(chairno))
    {
        return;
    }

    CPlayer* pPlayer = pGameTable->m_ptrPlayers[chairno];
    if (!pPlayer)
    {
        return;
    }
    COMB_CARD MsgData;
    memcpy(&MsgData, &pGameTable->m_WaitOpeMsgData, sizeof(COMB_CARD));

    int nMsgID = -1;
    if (pGameTable->m_nWaitOpeMsgID == GR_RECONS_CHI_CARD)
    {
        nMsgID = LOCAL_GAME_MSG_CHI;
    }
    else if (pGameTable->m_nWaitOpeMsgID == GR_RECONS_PENG_CARD)
    {
        nMsgID = LOCAL_GAME_MSG_PENG;
    }
    else if (pGameTable->m_nWaitOpeMsgID == GR_RECONS_MNGANG_CARD)
    {
        nMsgID = LOCAL_GAME_MSG_MN_GANG;
    }
    else if (pGameTable->m_nWaitOpeMsgID == GR_RECONS_PNGANG_CARD)
    {
        nMsgID = LOCAL_GAME_MSG_PN_GANG;
    }

    if (nMsgID != -1)
    {
        DWORD dwTickWait = GetPrivateProfileInt(_T("AutoCPGHWait"), _T("WaitTime"), 100, m_szIniFile);
        SimulateGameMsgFromUser(nRoomID, pPlayer, nMsgID, sizeof(COMB_CARD), &MsgData, dwTickWait);
    }
    return;
}

BOOL CMJServer::JudgeGuoCanAutoPlay(int totalChairs, DWORD dwPGCHFlags[])
{
    LOG_TRACE(_T("JudgeGuoCanAotuPlay"));

    for (int i = 0; i < totalChairs; i++)
    {
        if (dwPGCHFlags[i])
        {
            return FALSE;
        }
    }
    return TRUE;
}

BOOL CMJServer::YQW_OnGetTableInfo(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt)
{
    SAFETY_NET_REQUEST(lpRequest, GET_TABLE_INFO, pGetTableInfo);

    REQUEST response;
    memset(&response, 0, sizeof(response));


    BOOL lookon = FALSE;
    BOOL lookV2 = FALSE;
    LONG token = lpContext->lTokenID;
    int roomid = pGetTableInfo->nRoomID;
    int tableno = pGetTableInfo->nTableNO;
    int userid = pGetTableInfo->nUserID;
    int chairno = pGetTableInfo->nChairNO;

    CRoom* pRoom = NULL;
    CTable* pTable = NULL;
    CPlayer* pPlayer = NULL;
    if (IsRandomRoom(roomid) || IsYQWRoom(roomid))
    {
        CAutoLock lock(&m_csSoloPlayer);
        SOLO_PLAYER soloPlayer;
        memset(&soloPlayer, 0, sizeof(SOLO_PLAYER));
        if (!m_mapSoloPlayer.Lookup(userid, soloPlayer))
        {
            return NotifyResponseFaild(lpContext);
        }
        tableno = soloPlayer.nTableNO;
        chairno = soloPlayer.nChairNO;
    }
    if (!(pRoom = GetRoomPtr(roomid)))
    {
        return NotifyResponseFaild(lpContext);
    }

    if (!(pTable = (CMJTable*)GetTablePtr(roomid, tableno)))
    {
        return NotifyResponseFaild(lpContext);
    }

    if (pTable)
    {
        LOCK_TABLE(pTable, chairno, FALSE, userid, token);

        pTable->m_mapUser.Lookup(userid, pPlayer);
        if (!pPlayer || !pPlayer->m_nUserID)
        {
            return NotifyResponseFaild(lpContext);
        }
        lookon = pPlayer->m_bLookOn;
        lookV2 = pPlayer->IsLookerV2();
        if (!lookV2 && pPlayer->m_nChairNO != chairno)
        {
            return NotifyResponseFaild(lpContext);
        }

        int nLen = pTable->YQW_GetGameTableInfoSize();
        LPVOID pData = (LPBYTE)malloc(sizeof(BYTE) * nLen);

        pTable->YQW_FillupGameTableInfo(pData, nLen, chairno, lookon);

        // TODO : 库里开接口给我们 ***********************************************************************
        if (((CMJTable*)pTable)->IsTingPaiActive())
        {
            if (IS_BIT_SET(((CMJTable*)pTable)->m_dwGameFlags, MJ_GF_16_CARDS))
            {
                nLen = pTable->YQW_GetGameTableInfoSize() + sizeof(CARD_TING_DETAIL_16);
                pData = realloc(pData, nLen);

                ((CMJTable*)pTable)->CalcTingCard_17(chairno);

                PBYTE ptr_tingDetail = (PBYTE)pData + pTable->YQW_GetGameTableInfoSize();
                memcpy(ptr_tingDetail, &(((CMJTable*)pTable)->m_CardTingDetail_16), sizeof(CARD_TING_DETAIL_16));
            }
            else
            {
                nLen = pTable->YQW_GetGameTableInfoSize() + sizeof(CARD_TING_DETAIL);
                pData = realloc(pData, nLen);

                ((CMJTable*)pTable)->CalcTingCard(chairno);

                PBYTE ptr_tingDetail = (PBYTE)pData + pTable->YQW_GetGameTableInfoSize();
                memcpy(ptr_tingDetail, &(((CMJTable*)pTable)->m_CardTingDetail), sizeof(CARD_TING_DETAIL));
            }
        }
        // TODO : 库里开接口给我们 ***********************************************************************

        response.head.nRequest = UR_OPERATE_SUCCEEDED;
        response.pDataPtr = pData;
        response.nDataLen = nLen;
    }
    BOOL bSendOK = SendUserResponse(lpContext, &response, FALSE, TRUE);
    if (response.pDataPtr)
    {
        free(response.pDataPtr);
    }

    // 新版旁观 客户端可能需要一些数据 从在 size 和 fill
    if (lookV2)
    {
        NtfGetTableLookerInfo(lpContext, pTable, userid);
    }
    return TRUE;
}

void CMJServer::YQW_SetGameData(int roomid, int tableno, CYQWGameData& game_data)
{
    {
        int old_roomid = 0;
        int old_tableno = INVALID_OBJECT_ID;
        if (YQW_LookupRoomTable(game_data.game_data.nRoomNo, old_roomid, old_tableno))
        {
            if (!(old_roomid == roomid && old_tableno == tableno))
            {
                LOG_DEBUG(_T("YQW_SetGameData data mismatch!!! old_roomid: %d, old_tableno: %d"),
                    old_roomid, old_tableno);
            }
        }
    }

    __super::YQW_SetGameData(roomid, tableno, game_data);
}
