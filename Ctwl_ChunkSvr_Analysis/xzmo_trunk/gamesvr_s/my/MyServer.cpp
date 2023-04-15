#include "stdafx.h"
#include "MyServer.h"

CMyGameServer::CMyGameServer(const TCHAR* szLicenseFile, const TCHAR* szProductName, const TCHAR* szProductVer, const int nListenPort, const int nGameID, DWORD flagEncrypt, DWORD flagCompress)
    : CMJServer(szLicenseFile, szProductName, szProductVer, nListenPort, nGameID, flagEncrypt, flagCompress)
{
}

CTable* CMyGameServer::OnNewTable(int roomid /*= INVALID_OBJECT_ID*/, int tableno /*= INVALID_OBJECT_ID*/, int score_mult /*= 1*/)
{

    LOG_TRACE(_T("OnNewTable"));
    int nRoomOption = GetRoomOption(roomid);
    //chairNum
    int playerNum = GetChairCount(roomid);
    UwlLogFile("OnNewTable = %d", playerNum);

    auto pTable = new CMyGameTable(roomid, tableno, score_mult, playerNum);
    pTable->InitModel();

    evNewTable(pTable);

    return pTable;
}

BOOL CMyGameServer::OnRequest(void* lpParam1, void* lpParam2)
{
    LPCONTEXT_HEAD  lpContext = LPCONTEXT_HEAD(lpParam1);
    LPREQUEST       lpRequest = LPREQUEST(lpParam2);
    CWorkerContext* pThreadCxt = reinterpret_cast<CWorkerContext*>(GetWorkerContext());

    UwlTrace(_T("----------------------start of request process-------------------"));
    switch (lpRequest->head.nRequest)
    {
        CASE_REQUEST_HANDLE(GR_MY_TAKE_SAFE_DEPOSIT, OnMyTakeSafeDeposit)
        CASE_REQUEST_HANDLE(GR_MY_TAKE_BACK_DEPOSIT, OnMyTakeSafeDeposit)
        CASE_REQUEST_HANDLE(GR_EXCHANGE_CARDS, OnExchangeCards)
        CASE_REQUEST_HANDLE(GR_PLAYER_RECHARGE, OnPlayerRecharge)
        CASE_REQUEST_HANDLE(GR_PLAYER_RECHARGEOK, OnPlayerRechargeOK)
        CASE_REQUEST_HANDLE(GR_PLAYER_GOSENIOR, OnPlayerGoSeniorRoom)
        CASE_REQUEST_HANDLE(GR_GET_WELFAREPRESENT, OnGetWelfarePersent)
        CASE_REQUEST_HANDLE(GR_GAME_TIMER, RobotOnGameTimer)

    default:
        UwlTrace(_T("goto default proceeding..."));
        __super::OnRequest(lpParam1, lpParam2);
        break;
    }
    UwlClearRequest(lpRequest);

    return TRUE;
}

BOOL CMyGameServer::OnThrowCards(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt)
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
    CMyGameTable* pTable = NULL;

    if (!(pRoom = GetRoomPtr(roomid)))
    {
        return NotifyResponseFaild(lpContext, bPassive);
    }

    if (!(pTable = (CMyGameTable*)GetTablePtr(roomid, tableno)))
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
            UwlLogFile(_T("status not waiting_throw, chair %ld throw failed.userid %ld, auto: %ld"), chairno, userid, bPassive);
            return NotifyResponseFaild(lpContext, bPassive);
        }
        if (chairno != pTable->GetCurrentChair()) //不该此人出牌!
        {
            UwlLogFile(_T("current chair not same, chair %ld throw failed.userid %ld, auto: %ld"), chairno, userid, bPassive);
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

        LOG_DEBUG(_T("***********ROBOT_BOUT_LOG_THROW***********roomid:%d, tableno:%d, chairno:%d, userid:%d, cardid:%s"), roomid, tableno, chairno, userid, pTable->RobotBoutLog(pThrowCards->nCardIDs[0]));

        pTable->SetWaitingsOnThrow(chairno, pThrowCards->nCardIDs, pThrowCards->dwCardsType);

        pTable->SetStatusOnThrow();
        pTable->SetCurrentChairOnThrow();

        CreateRobotTimer(pRoom, pTable, pTable->m_dwStatus, pTable->m_nPGCHWait * 1000);

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
        pTable->CalcTingByRobotBoutPlayer();
        DWORD dwWinFlags = pTable->CalcWinOnThrow(chairno, pThrowCards->nCardIDs, pThrowCards->dwCardsType);
        if (dwWinFlags)
        {
            BOOL bout_invalid = pTable->IsBoutInvalid(GetBoutTimeMin());
            OnGameWin(lpContext, pRoom, pTable, chairno, bout_invalid, roomid);
        }
        else
        {
            BOOL bSomeOneHU = FALSE;
            for (int i = 0; i < pTable->m_nTotalChairs; i++)
            {
                if (IS_BIT_SET(pTable->m_dwPGCHFlags[i], MJ_HU))
                {
                    bSomeOneHU = TRUE;
                }
            }
            if (!bSomeOneHU && pTable->IsRoboter(pTable->GetCurrentChair()))
            {
                OnRobotAIPlay(pRoom, pTable, pTable->GetCurrentChair());
            }
            else if (!bSomeOneHU && pTable->IsOffline(pTable->GetCurrentChair()))
            {
                OnServerAutoPlay(pRoom, pTable, pTable->GetCurrentChair(), !pTable->IsOffline(pTable->GetCurrentChair()));
            }
        }
        if (IsServerAutoCatch())
        {
            //服务端自动抓牌
            if (!dwWinFlags)
            {
                if (pTable->IsRoboter(pTable->GetCurrentChair()))
                {
                    OnRobotAIPlay(pRoom, pTable, pTable->GetCurrentChair());
                }
                else
                {
                    OnServerAutoPlay(pRoom, pTable, pTable->GetCurrentChair(), !pTable->IsOffline(pTable->GetCurrentChair()));
                }
            }
            //end
        }
    }
    return TRUE;
}

void CMyGameServer::UWLCurrentChairCards(CMJTable* pTable, int nChairNO, int nCardID, int nRoomID, int nTableNO, int nUserID)
{
    if (!OnOperationLogEnable())
    {
        return;
    }

    int nCardIDs[MAX_CARDS_PER_CHAIR];
    XygInitChairCards(nCardIDs, MAX_CARDS_PER_CHAIR);
    pTable->GetChairCards(nChairNO, nCardIDs, MAX_CARDS_PER_CHAIR);

    LOG_TRACE(_T("UWLCurrentChairCards roomid:%d, tableno = %d, userid = %d, nCardID = %d, m_njoker = %d"), nRoomID, nTableNO, nUserID, nCardID, pTable->m_nJokerID);
    CString str;
    for (int i = 0; i < MJ_INIT_HAND_CARDS; i++)
    {
        CString strTmp;
        strTmp.Format("[%d,%d],", i, nCardIDs[i]);
        str += strTmp;
    }
    LOG_TRACE(str);
}

BOOL CMyGameServer::OnCloseSocket(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt)
{
    GAME_ABORT GameAbort;
    ZeroMemory(&GameAbort, sizeof(GameAbort));
    LOOKON_ABORT LookOnAbort;
    ZeroMemory(&LookOnAbort, sizeof(LookOnAbort));

    // 连接异常断开
    LONG token = 0;
    int roomid = 0;
    int tableno = INVALID_OBJECT_ID;
    int userid = 0;
    int r_id = 0;
    int t_no = INVALID_OBJECT_ID;
    int u_id = 0;

    CRoom* pRoom = NULL;
    CTable* pTable = NULL;
    CPlayer* pPlayer = NULL;

    token = lpContext->lTokenID;

    (void)RemoveTokenData(token, roomid, tableno, userid);
    UserCloseClient(token);

    if (roomid <= 0)
    {
        return TRUE;
    }
    if (tableno <= INVALID_OBJECT_ID)
    {
        return TRUE;
    }
    if (userid <= 0)
    {
        return TRUE;
    }

    pRoom = GetRoomPtr(roomid);
    if (!pRoom)
    {
        return TRUE;
    }
    if (pRoom->IsOnMatch())//比赛模式直接返回
    {
        return TRUE;
    }

    pTable = pRoom->GetTablePtr(tableno);
    if (pTable)
    {
        CAutoLock lock(&(pTable->m_csTable));

        (void)pTable->m_mapUser.Lookup(userid, pPlayer);

        if (pPlayer)
        {
            int breakchair = pPlayer->m_nChairNO;
            if (pTable->IsPlayer(userid))  // 玩家断线
            {
                GameAbort.nUserID = pPlayer->m_nUserID;
                GameAbort.nChairNO = pPlayer->m_nChairNO;
                GameAbort.nOldScore = pPlayer->m_nScore;
                GameAbort.nOldDeposit = pPlayer->m_nDeposit;
                GameAbort.nTableNO = pTable->m_nTableNO;

                BOOL bCanLeaveAsLock = TRUE; //

                if (IS_BIT_SET(pTable->m_dwStatus, TS_PLAYING_GAME))  // 游戏进行中，准备断线续玩
                {
                    pTable->m_dwBreakTime[breakchair] = GetTickCount(); // 记录下断线时间
                }
                else  // 游戏未在进行中，本桌游戏结束(自动开始的游戏，第一次进入时30秒内锁定除外)
                {
                    int locktime = GetPrivateProfileInt(
                            _T("break"),    // section name
                            _T("locktime"), // key name
                            DEF_BREAK_LOCK, // default int
                            m_szIniFile     // initialization file name
                        );
                    if (pTable->IsBrokenAsLock(breakchair, locktime))
                    {
                        bCanLeaveAsLock = FALSE;
                    }
                }

                if (!bCanLeaveAsLock)
                {
                    //不可退出时，不做任何处理。

                }
                else if (IS_BIT_SET(pTable->m_dwStatus, TS_PLAYING_GAME)
                    || !pTable->IsGameOver())//游戏中,或者多局游戏还没有结束
                {
                    DWORD dwConfig = GetRoomConfig(roomid);
                    if (XygTellAllBreak(pTable->m_dwBreakTime, pTable->m_nTotalChairs)
                        && pTable->m_nTotalChairs > 1
                        && !IS_BIT_SET(dwConfig, RC_ALLBREAKNOCLEAR))
                    {
                        (void)RemoveClients(pTable, 0, FALSE);

                        (void)NotifyTablePlayers(pTable, GR_GAME_ABORT, &GameAbort, sizeof(GameAbort));
                        (void)NotifyTableVisitors(pTable, GR_GAME_ABORT, &GameAbort, sizeof(GameAbort));

                        pTable->Reset(); // 清空桌子
                    }
                    else
                    {
                        if (IsVariableChairRoom(roomid)
                            && pTable->m_ptrPlayers[breakchair]
                            && pTable->m_ptrPlayers[breakchair]->m_bIdlePlayer)
                        {
                            // xzmo 新增
                            SOLO_PLAYER soloPlayer;
                            memset(&soloPlayer, 0, sizeof(SOLO_PLAYER));
                            LookupSoloPlayer(pPlayer->m_nUserID, soloPlayer);
                            //end
                            //空闲玩家离开不清空桌子
                            (void)RemoveOneClients(pTable, userid, TRUE);

                            if (!IsCloakingRoom(roomid))
                            {
                                // xzmo 新增
                                if (((CMyGameTable*)pTable)->m_stAbortPlayerInfo[GameAbort.nChairNO].nUserID <= 0)
                                {
                                    soloPlayer.nDeposit = GameAbort.nOldDeposit;
                                    ((CMyGameTable*)pTable)->saveAbortPlayerInfo(soloPlayer);
                                }
                                // end
                                (void)NotifyTablePlayers(pTable, GR_PLAYER_ABORT, &GameAbort, sizeof(GameAbort));
                            }

                            (void)NotifyTableVisitors(pTable, GR_PLAYER_ABORT, &GameAbort, sizeof(GameAbort));

                            (void)pTable->PlayerLeave(userid);

                            (void)OnGameLeft(userid, roomid, tableno, breakchair);
                            (void)OnChangeHomeUserID(roomid, pTable);
                            (void)TryFreeEMChatID(pTable);
                        }

                        if (IsYQWRoom(roomid)
                            && pTable->m_ptrPlayers[breakchair])
                        {
                            pTable->YQW_SetOnline(breakchair, FALSE);
                            YQW_NotifyOnlineChanged(pTable, breakchair, FALSE);
                            YQW_NotifyUnReadyStatus(pTable, breakchair);
                        }
                        //其他情况都不处理
                    }
                }
                else if (pTable->IsFirstBout())//第一局开始前
                {
                    if (IsSoloRoom(pTable->m_nRoomID))
                    {
                        //普通Solo房间，随机Solo房间
                        NotifyRefuseSwapChair(pTable, pTable->m_ptrPlayers[breakchair]);
                        (void)RemoveOneClients(pTable, userid, FALSE);

                        if (!IsCloakingRoom(roomid))
                        {
                            (void)NotifyTablePlayers(pTable, GR_PLAYER_ABORT, &GameAbort, sizeof(GameAbort));
                        }

                        (void)NotifyTableVisitors(pTable, GR_PLAYER_ABORT, &GameAbort, sizeof(GameAbort));

                        (void)pTable->PlayerLeave(userid);
                        pTable->ResetTable();
                        (void)OnGameLeft(userid, roomid, tableno, breakchair);
                        (void)OnChangeHomeUserID(roomid, pTable);
                        (void)TryFreeEMChatID(pTable);

                        //终止倒计时
                        //自由人数模式，游戏未开始时退出
                        if (IsVariableChairRoom(roomid)
                            && pTable->IsGameOver()
                            && pTable->IsNeedCountdown())
                        {
                            int  startcount = XygGetStartCount(pTable->m_dwUserStatus, pTable->m_nTotalChairs);
                            BOOL bAllowStartGame = IsAllowStartGame(pTable, startcount);
                            BOOL bInCountdown = pTable->IsInCountDown();
                            if (!bAllowStartGame && bInCountdown)
                            {
                                //结束倒计时
                                START_COUNTDOWN  sc;
                                memset(&sc, 0, sizeof(START_COUNTDOWN));
                                sc.nUserID = userid;
                                sc.nRoomID = roomid;
                                sc.nTableNO = tableno;
                                sc.nChairNO = breakchair;
                                sc.bStartorStop = FALSE;
                                (void)pTable->SetCountDown(FALSE);
                                (void)NotifyTablePlayers(pTable, GR_START_COUNTDOWN, &sc, sizeof(START_COUNTDOWN));
                            }
                        }
                    }
                    else
                    {
                        //普通房间
                        (void)RemoveClients(pTable, 0, FALSE);

                        (void)NotifyTablePlayers(pTable, GR_GAME_ABORT, &GameAbort, sizeof(GameAbort));
                        (void)NotifyTableVisitors(pTable, GR_GAME_ABORT, &GameAbort, sizeof(GameAbort));

                        pTable->Reset(); // 清空桌子
                    }
                }
                else if (!pTable->IsFirstBout())//第一局结束后，新一局未开始前
                {
                    //                  if( IsSoloRoom(pTable->m_nRoomID)
                    // &&(!IsRandomRoom(pTable->m_nRoomID)||IsLeaveAlone(pTable->m_nRoomID)))
                    //                  {//普通Solo房间和有单独离桌标记的随机Solo房间
                    BOOL bRandomRoom = IsRandomRoom(pTable->m_nRoomID);

                    if (IsLeaveAlone(pTable->m_nRoomID))
                    {
                        NotifyRefuseSwapChair(pTable, pTable->m_ptrPlayers[breakchair]);
                        (void)RemoveOneClients(pTable, userid, FALSE);

                        if (!IsCloakingRoom(roomid))
                        {
                            (void)NotifyTablePlayers(pTable, GR_PLAYER_ABORT, &GameAbort, sizeof(GameAbort));
                        }

                        (void)NotifyTableVisitors(pTable, GR_PLAYER_ABORT, &GameAbort, sizeof(GameAbort));

                        (void)pTable->PlayerLeave(userid);
                        pTable->ResetTable();

                        (void)OnGameLeft(userid, roomid, tableno, breakchair);
                        (void)OnChangeHomeUserID(roomid, pTable);
                        (void)TryFreeEMChatID(pTable);

                        if (bRandomRoom)
                        {
                            //随机分桌模式中，如果至少玩过一局后
                            //有玩家退出,需要把其他已经按下开始键的玩家重新加入等待分桌序列。
                            for (int i = 0; i < pTable->m_nTotalChairs; i++)
                            {
                                CPlayer* pStartedPlayer = pTable->m_ptrPlayers[i];
                                if (pStartedPlayer
                                    && IS_BIT_SET(pTable->m_dwUserStatus[i], US_GAME_STARTED))
                                {
                                    if (pStartedPlayer->m_bTeamMember)
                                    {
                                        continue;    // 队员不管
                                    }
                                    pTable->m_dwUserStatus[i] &= ~US_GAME_STARTED;//去掉准备状态
                                    pTable->m_dwUserStatus[i] |= US_USER_WAITNEWTABLE; //pengsy
                                    PostAskNewTable(pStartedPlayer->m_nUserID, roomid, tableno, i);
                                    (void)NotifyOneUser(pStartedPlayer->m_hSocket, pStartedPlayer->m_lTokenID, GR_WAIT_NEWTABLE, NULL, 0);
                                }
                            }
                        }
                    }
                    else
                    {
                        //随机Solo房间与普通房间
                        (void)RemoveClients(pTable, 0, FALSE);

                        (void)NotifyTablePlayers(pTable, GR_GAME_ABORT, &GameAbort, sizeof(GameAbort));
                        (void)NotifyTableVisitors(pTable, GR_GAME_ABORT, &GameAbort, sizeof(GameAbort));

                        pTable->Reset(); // 清空桌子
                    }
                }
            }
            else if (pTable->IsVisitor(userid))  // 旁观者断线
            {
                LookOnAbort.nUserID = pPlayer->m_nUserID;
                LookOnAbort.nChairNO = pPlayer->m_nChairNO;

                (void)NotifyTablePlayers(pTable, GR_LOOKON_ABORT, &LookOnAbort, sizeof(LookOnAbort), token);
                (void)NotifyTableVisitors(pTable, GR_LOOKON_ABORT, &LookOnAbort, sizeof(LookOnAbort), token);

                (void)OnGameLeft(userid, roomid, tableno, breakchair);// 清理旁观者提交的信息
                (void)YQW_TransmitLookerEvent(pTable, pPlayer, FALSE);
                pTable->RemoveVisitor(userid, TRUE);//pTable->VisitorLeave(userid, chairno);

            }

        }
    }
    return TRUE;
}

BOOL CMyGameServer::OnStartGame(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt)
{
    LOG_TRACE("CMyGameServer::OnStartGame");
    SAFETY_NET_REQUEST(lpRequest, START_GAME, pStartGame);
    LONG token = 0;
    int roomid = 0;
    int tableno = INVALID_OBJECT_ID;
    int userid = 0;
    int chairno = INVALID_OBJECT_ID;
    int r_id = 0;
    int t_no = INVALID_OBJECT_ID;
    int u_id = 0;
    int c_no = INVALID_OBJECT_ID;

    CTable* pTable = NULL;
    CPlayer* pPlayer = NULL;

    token = lpContext->lTokenID;

    roomid = pStartGame->nRoomID;
    tableno = pStartGame->nTableNO;
    userid = pStartGame->nUserID;
    chairno = pStartGame->nChairNO;

    pTable = GetTablePtr(roomid, tableno);
    if (pTable)
    {
        LOCK_TABLE(pTable, chairno, FALSE, userid, token);

        if (!pTable->IsPlayer(userid)) // 不是玩家
        {
            UwlLogFile(_T("user not player. user %ld start game failed."), userid);
            return TRUE;
        }

        if (IS_BIT_SET(pTable->m_dwStatus, TS_PLAYING_GAME)) // 游戏进行中
        {
            return TRUE;
        }

        if (IS_BIT_SET(pTable->m_dwUserStatus[chairno], US_GAME_STARTED)) // 已经开始
        {
            return TRUE;
        }

        BOOL bSoloRoom = IsSoloRoom(roomid);
        BOOL bRandomRoom = IsRandomRoom(roomid);

        if (!VerifyRoomTableChair(roomid, tableno, chairno, userid)) // 该位置上用户不匹配
        {
            return TRUE;
        }
        if (!PlayerCanArenaMatchOnStart(roomid, userid, pStartGame))
        {
            return TRUE;
        }
        //是否专家号受限
        CString sRet;
        if (CheckAccountBillingLimit(userid, sRet))
        {
            return TRUE;
        }
        //
        if (bSoloRoom)
        {
            //Modify on 20130106
            //独离模式下，按下开始时，判断下银子是否足够达到房间下限，不够清退
            if (IsLeaveAlone(roomid))
            {
                pPlayer = pTable->m_ptrPlayers[chairno];
                if (pPlayer && IsNeedDepositRoom(roomid))
                {
                    int nMinDeposit = GetMinPlayingDeposit(pTable, roomid);

                    if (nMinDeposit > pPlayer->m_nDeposit)
                    {
                        DEPOSIT_NOT_ENOUGH depositNotEnough;
                        ZeroMemory(&depositNotEnough, sizeof(depositNotEnough));

                        depositNotEnough.nUserID = pPlayer->m_nUserID;
                        depositNotEnough.nChairNO = chairno;
                        depositNotEnough.nDeposit = pPlayer->m_nDeposit;
                        depositNotEnough.nMinDeposit = nMinDeposit;

                        NotifyOneUser(pPlayer->m_hSocket, pPlayer->m_lTokenID, GR_DEPOSIT_NOT_ENOUGH, &depositNotEnough, sizeof(depositNotEnough));
                        return FALSE;
                    }
                }
            }
            // xzmo 新增m_nextAskNewTable
            CMyGameTable* gameTable = (CMyGameTable*)pTable;
            if (bRandomRoom
                && (gameTable->m_nextAskNewTable    //中途有人强退
                    || pTable->IsFirstBout()
                    || (IsLeaveAlone(roomid)
                        && IsNeedWaitArrageTable(pTable, roomid, userid)))) //已经达到桌局数上限，那么重新向RoomSvr请求分桌
            {
                pPlayer = pTable->m_ptrPlayers[chairno];
                CheckResumeTeam(pTable, false);
                if (pPlayer && pPlayer->m_bTeamMember)
                {
                    return TRUE;
                }
                pTable->m_dwUserStatus[chairno] |= US_USER_WAITNEWTABLE; //pengsy
                PostAskNewTable(userid, roomid, tableno, chairno);

                pPlayer = pTable->m_ptrPlayers[chairno];
                if (pPlayer)
                {
                    NotifyOneUser(pPlayer->m_hSocket, pPlayer->m_lTokenID, GR_WAIT_NEWTABLE, NULL, 0);
                }

                return TRUE;
            }
            //Modify end
        }

        if (IS_BIT_SET(GetGameOption(roomid), GO_NOT_VERIFYSTART))
        {
            OnUserStart(pTable, chairno);
        }
        else
        {
            PostVerifyStart(userid, roomid, tableno, chairno);
        }
    }
    return TRUE;
}

BOOL CMyGameServer::OnEnterGame(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt)
{
    LOG_TRACE("CMyGameServer OnEnterGame");
    REQUEST response;
    memset(&response, 0, sizeof(response));
    BOOL compressed = FALSE;

    SOCKET sock = INVALID_SOCKET;
    LONG token = 0;
    int gameid = 0;
    int roomid = 0;
    int tableno = INVALID_OBJECT_ID;
    int userid = 0;
    int usertype = 0;
    int chairno = INVALID_OBJECT_ID;
    int nettype = 0;
    int r_id = 0;
    int t_no = INVALID_OBJECT_ID;
    int u_id = 0;
    int c_no = INVALID_OBJECT_ID;
    LONG room_tokenid = 0;
    BOOL lookon = FALSE;

    DWORD dwRoomOption = 0;
    DWORD dwRoomConfig = 0;

    CTable* pTable = NULL;
    CPlayer* pPlayer = NULL;

    sock = lpContext->hSocket;
    token = lpContext->lTokenID;

    LPENTER_GAME_EX pEnterGame = (LPENTER_GAME_EX)(PBYTE(lpRequest->pDataPtr));
    if (lpRequest->nDataLen < sizeof(ENTER_GAME_EX) || !pEnterGame) //长度指针检查
    {
        response.head.nRequest = UR_OPERATE_FAILED;
        return SendUserResponse(lpContext, &response);
    }
    gameid = pEnterGame->nGameID;
    roomid = pEnterGame->nRoomID;
    tableno = pEnterGame->nTableNO;
    userid = pEnterGame->nUserID;
    usertype = pEnterGame->nUserType;
    chairno = pEnterGame->nChairNO;
    lookon = pEnterGame->bLookOn;
    nettype = pEnterGame->nMbNetType;
    LPCTSTR hardid = LPCTSTR(pEnterGame->szHardID);
    room_tokenid = pEnterGame->nRoomTokenID;

    if (roomid <= 0 || tableno < 0 || userid <= 0 || chairno < 0 || chairno >= MAX_CHAIR_COUNT
        || gameid != m_nGameID)
    {
        return SendFailedResponse(lpContext);
    }
    //长度检查
    if (IsSoloRoom(roomid) && lpRequest->nDataLen != (sizeof(ENTER_GAME_EX) + sizeof(SOLO_PLAYER)))
    {
        response.head.nRequest = UR_OPERATE_FAILED;
        return SendUserResponse(lpContext, &response);
    }
    // xzmo 新增
    // 这里跟校验一下 桌椅号对不对
    if (!IsTrueChairAndTable(userid, roomid, tableno, chairno, sock, token))
    {
        MODIFY_TABLEANDCHAIR modifyTableAndChair;
        memset(&modifyTableAndChair, 0, sizeof(MODIFY_TABLEANDCHAIR));
        USER_DATA tempUData;
        LookupUserData(userid, tempUData);
        modifyTableAndChair.nUserID = tempUData.nUserID;
        modifyTableAndChair.nRoomID = tempUData.nRoomID;
        modifyTableAndChair.nTableNO = tempUData.nTableNO;
        modifyTableAndChair.nChairNO = tempUData.nChairNO;

        chairno = tempUData.nChairNO;
        tableno = tempUData.nTableNO;
        pEnterGame->nChairNO = tempUData.nChairNO;
        pEnterGame->nTableNO = tempUData.nTableNO;

        NotifyOneUser(lpContext->hSocket, lpContext->lTokenID,
            GR_MODIFY_TABLEANDCHAIR, &modifyTableAndChair, sizeof(MODIFY_TABLEANDCHAIR), TRUE);
    }
    // end
#ifndef _DEBUG
    {
        DWORD dwCode = GetHardCode(userid);
        if (!dwCode)
        {
            response.head.nRequest = GR_HARDID_MISMATCH;
            return SendUserResponse(lpContext, &response);
        }
        DWORD hardcode = 0;
        xygMakeHardID2Code(hardid, lstrlen(hardid), hardcode);
        if (hardcode != dwCode)
        {
            response.head.nRequest = GR_HARDID_MISMATCH;
            return SendUserResponse(lpContext, &response);
        }

        int nRoomToken = GetRoomTokenID(userid);
        if (!nRoomToken)
        {
            response.head.nRequest = GR_ROOM_TOKENID_MISMATCH;
            return SendUserResponse(lpContext, &response);
        }
        if (room_tokenid != nRoomToken)
        {
            response.head.nRequest = GR_ROOM_TOKENID_MISMATCH;
            return SendUserResponse(lpContext, &response);
        }
    }

    if (!lookon) //
    {
        DWORD dwRoomTableChair = MakeRoomTableChair(roomid, tableno, chairno);

        int nUserID = GetUserID(dwRoomTableChair);
        if (!nUserID)
        {
            UwlLogFile("User OnEnterGame Faild1,RoomTableChair miss match!,roomid:%ld,tableno:%ld,chairno:%ld,userid:%ld", roomid, tableno, chairno, userid);
            response.head.nRequest = GR_ROOMTABLECHAIR_MISMATCH;
            return SendUserResponse(lpContext, &response);
        }
        if (userid != nUserID)
        {
            UwlLogFile("User OnEnterGame Faild2,RoomTableChair miss match!,roomid:%ld,tableno:%ld,chairno:%ld,userid:%ld", roomid, tableno, chairno, userid);
            response.head.nRequest = GR_ROOMTABLECHAIR_MISMATCH;
            return SendUserResponse(lpContext, &response);
        }
    }
#endif
    if (!VerifyOnlyOneGame(userid, roomid, tableno, chairno, sock, token))
    {
        response.head.nRequest = GR_HARDID_MISMATCH;
        return SendUserResponse(lpContext, &response);
    }

    //在提交结果，需等待
    if (NeedEnterWaitGameWin(roomid, tableno, chairno, userid, token, lookon))
    {
        response.head.nRequest = GR_WAIT_CHECKRESULT;
        return SendUserResponse(lpContext, &response);
    }
    //组对房已经开始匹配
    if (VerifyTeamRoomMatched(roomid, tableno))
    {
        response.head.nRequest = GR_TEAMROOM_MATCHED;
        return SendUserResponse(lpContext, &response);
    }
    //是否专家号受限
    CString sRet;
    if (CheckAccountBillingLimit(userid, sRet))
    {
        response.head.nRequest = GR_ERROR_INFOMATION_EX;
        response.pDataPtr = (LPVOID)LPCTSTR(sRet);
        response.nDataLen = sRet.GetLength() + 1;
        return SendUserResponse(lpContext, &response);
    }
    //能否作为比赛选手进入
    if (!PlayerCanArenaMatchOnEnter(roomid, userid, pEnterGame))
    {
        response.head.nRequest = GR_MATCHID_MISMATCH;
        return SendUserResponse(lpContext, &response);
    }
    //能否作为房卡玩家进入
    if (!VerifyRoomCardPlayerOnEnter(roomid, userid, pEnterGame))
    {
        response.head.nRequest = GR_ROOMCARD_MISMATCH;
        return SendUserResponse(lpContext, &response);
    }
    {
        SetEnterParams(userid, roomid, tableno, chairno, usertype, nettype, sock, token);
    }

    {
        CAutoLock lock(&m_csTokenData);
        m_mapTokenRoom.SetAt(token, roomid);
        m_mapTokenTable.SetAt(token, tableno);
        m_mapTokenPlayer.SetAt(token, userid);
        ID_SOCKET user = { userid, sock };
        m_mapTokenUser.SetAt(token, user);
    }

    {
        if (IsSoloRoom(roomid))
        {
            LPSOLO_PLAYER pSoloPlayer = (LPSOLO_PLAYER)(PBYTE(pEnterGame) + sizeof(ENTER_GAME_EX));
            SetSoloPlayer(userid, *pSoloPlayer);
        }
    }

    GetRoomPtr(roomid, TRUE);

    pTable = GetTablePtr(roomid, tableno, TRUE, m_nScoreMult);
    dwRoomOption = GetRoomOption(roomid);
    dwRoomConfig = GetRoomConfig(roomid);
    if (pTable)
    {
        LOCK_TABLE(pTable, chairno, FALSE, 0, 0);

        if (!lookon) // 玩家进入
        {
            CPlayer* ptrP = pTable->m_ptrPlayers[chairno];
            if (ptrP && ptrP->m_nUserID && userid != ptrP->m_nUserID)
            {
                // if( !CheckIsPlayingInGame(pTable,chairno,pPlayer,pEnterGame) && !IS_BIT_SET(pTable->m_dwStatus, TS_PLAYING_GAME) ){ // 游戏未在进行中
                // 新旧玩家不一致
                if (IS_BIT_SET(pTable->m_dwStatus, TS_PLAYING_GAME))
                {
                    //如果原来的玩家是空闲玩家，那么只踢掉这个空闲玩家
                    if (ptrP->m_bIdlePlayer)
                    {
                        UwlLogFile(_T("Cancel reset table,previous player is a idlePlayer! roomid = %ld, tableno = %ld, chairno = %ld, userid = %ld, previous = %ld"),
                            roomid, tableno, chairno, userid, ptrP->m_nUserID);

                        RemoveOneClients(pTable, ptrP->m_nUserID, TRUE);
                        pTable->PlayerLeave(ptrP->m_nUserID, TRUE);
                    }
                    else
                    {
                        //Modify on 20150927
                        //暂时关闭指定房间进入游戏散桌
                        TCHAR szKey[32];
                        sprintf_s(szKey, _T("%d"), roomid);
                        int nForbidResetTable = GetPrivateProfileInt(_T("ForbidResetTable"), szKey, 0, GetINIFileName());
                        if (nForbidResetTable > 0)
                        {
                            UwlLogFile(_T("Forbid reset table! roomid = %ld, tableno = %ld, chairno = %ld, userid = %ld, previous = %ld"),
                                roomid, tableno, chairno, userid, ptrP->m_nUserID);
                            response.head.nRequest = UR_OPERATE_FAILED;
                            return SendUserResponse(lpContext, &response);
                        }
                        else
                        {

                            //游戏中，本桌游戏结束
                            UwlLogFile(_T("reset table as different user enter! roomid = %ld, tableno = %ld, chairno = %ld, userid = %ld, previous = %ld"),
                                roomid, tableno, chairno, userid, ptrP->m_nUserID);

                            RemoveClients(pTable, token, TRUE);
                            pTable->Reset(); // 清空桌子
                        }
                    }
                }
                else if (IsLeaveAlone(roomid))
                {
                    //独离房间，如果原来的位置尚有玩家的信息没有清理，则清除原玩家信息
                    //此处忽略了对原玩家旁观者的处理。
                    RemoveOneClients(pTable, ptrP->m_nUserID, TRUE);
                    pTable->PlayerLeave(ptrP->m_nUserID, TRUE);
                }
            }
        }
        pTable->m_mapUser.Lookup(userid, pPlayer);
        if (pPlayer) // 用户已存在，清除已有信息
        {
            if (pPlayer->m_lTokenID != token)
            {
                RemoveTokenData(pPlayer->m_lTokenID, r_id, t_no, u_id);
                CloseClient(pPlayer->m_hSocket, pPlayer->m_lTokenID);
            }
            pPlayer->SetChairLookOn(chairno, lookon);
            pPlayer->m_nUserType = usertype;        //断线续完时，更新玩家类型，可能换成了手机端
        }
        else   // 新建用户
        {
            //pPlayer = new CPlayer(hardid, userid, usertype, chairno, lookon);
            pPlayer = OnNewPlayer(hardid, userid, usertype, chairno, lookon);
            pTable->m_mapUser.SetAt(userid, pPlayer);
            if (IS_BIT_SET(usertype, USER_TYPE_THIRDAUDIT))
            {
                InsertBillingAccount(userid);
            }
        }
        pPlayer->SetSocketToken(lpContext->hSocket, lpContext->lTokenID);
        //在普通桌  - 入口就可以了
        //随机桌的话- 需要在开始的时候再检测一次
        CheckApplyEMChatID(lpContext, pTable);
        // xzmo 新增
        PostRecordUserNetworkType(roomid, userid, nettype);
        // end
        if (!lookon) // 玩家进入
        {
            if (!IS_BIT_SET(pTable->m_dwStatus, TS_PLAYING_GAME))  // 游戏未在进行中
            {
                pTable->m_ptrPlayers[chairno] = pPlayer;
                pTable->m_dwUserStatus[chairno] &= ~US_GAME_STARTED;
                pTable->m_dwUserConfig[chairno] = pEnterGame->dwUserConfigs;
                pTable->m_dwRoomOption[chairno] = dwRoomOption;
                pTable->m_dwRoomConfig[chairno] = dwRoomConfig;
                pTable->m_ptrPlayers[chairno]->m_bIdlePlayer = FALSE;

                pTable->m_bForbidChat = XygGetOptionOneTrue(pTable->m_dwRoomOption, pTable->m_nTotalChairs, RO_FORBID_CHAT);
                pTable->m_bForbidLookChat = XygGetOptionOneTrue(pTable->m_dwRoomOption, pTable->m_nTotalChairs, RO_FORBID_LOOKCHAT);
                pTable->m_bAutoStart = XygGetOptionOneTrue(pTable->m_dwRoomOption, pTable->m_nTotalChairs, RO_AUTO_STARTGAME);
                pTable->m_bDarkRoom = XygGetOptionOneTrue(pTable->m_dwRoomConfig, pTable->m_nTotalChairs, RC_DARK_ROOM);

                TransmitEnterGame(lpContext, pEnterGame);
                return TRUE;
            }
            else if (IsVariableChairRoom(roomid) && NULL == pTable->m_ptrPlayers[chairno])  //本局已经开始，新进入的玩家，先上桌旁观
            {
                pTable->m_ptrPlayers[chairno] = pPlayer;
                pTable->m_dwUserStatus[chairno] &= ~US_GAME_STARTED;
                pTable->m_dwUserConfig[chairno] = pEnterGame->dwUserConfigs;
                pTable->m_dwRoomOption[chairno] = dwRoomOption;
                pTable->m_dwRoomConfig[chairno] = dwRoomConfig;
                pTable->m_ptrPlayers[chairno]->m_bIdlePlayer = TRUE;

                pTable->m_bForbidChat = XygGetOptionOneTrue(pTable->m_dwRoomOption, pTable->m_nTotalChairs, RO_FORBID_CHAT);
                pTable->m_bForbidLookChat = XygGetOptionOneTrue(pTable->m_dwRoomOption, pTable->m_nTotalChairs, RO_FORBID_LOOKCHAT);
                pTable->m_bAutoStart = XygGetOptionOneTrue(pTable->m_dwRoomOption, pTable->m_nTotalChairs, RO_AUTO_STARTGAME);
                pTable->m_bDarkRoom = XygGetOptionOneTrue(pTable->m_dwRoomConfig, pTable->m_nTotalChairs, RC_DARK_ROOM);

                TransmitEnterGame(lpContext, pEnterGame);
                return TRUE;
            }
            else   // 断线续玩
            {
                BOOL continue_allowed = TRUE;
                int maxallowed = GetPrivateProfileInt(
                        _T("breakoff"),         // section name
                        _T("maxallowed"),       // key name
                        -1,     // default int
                        m_szIniFile             // initialization file name
                    );
                pTable->m_nBreakCount[chairno]++;
                if (maxallowed != -1 && pTable->m_nBreakCount[chairno] > maxallowed)
                {
                    if (OnTooManyBreak(userid, roomid, tableno, chairno, sock, token))
                    {
                        response.head.nRequest = UR_OPERATE_FAILED;
                        continue_allowed = FALSE;
                        UWL_WRN("OnEnterGame Faild, as OnTooManyBreak.userId:%d", userid);
                    }
                }
                if (continue_allowed)
                {
                    ConstructEnterGameDXXW(roomid, pTable, chairno, userid, FALSE, &response);
                    SendAbortPlayerInfo((CMyGameTable*)pTable, roomid, tableno, pPlayer->m_hSocket, pPlayer->m_lTokenID);

                    compressed = TRUE;
                    LOG_TRACE(_T("continue playing after broken! roomid = %ld, tableno = %ld, chairno = %ld, userid = %ld"),
                        roomid, tableno, chairno, userid);
                    pTable->m_dwBreakTime[chairno] = 0;
                    if (chairno == pTable->GetCurrentChair()) // 未超时
                    {
                        pTable->m_dwActionBegin = GetTickCount(); // 重新开始计时
                    }
                    OnTellHomeInfoOnDXXW(lpContext, roomid, pTable, pPlayer);
                    OnTcMatcherEnterOnDXXW(lpContext, userid);
                    OnEnterGameDXXW(lpContext, pEnterGame);
                    //发送排行榜网址
                    NotifyMatchWWW(roomid, pPlayer->m_nUserID, pPlayer->m_hSocket, pPlayer->m_lTokenID);
                    //发送二维码扫描地址
                    NotifyHandPhoneQRCodeURL(roomid, pPlayer->m_nUserType, pPlayer->m_hSocket, pPlayer->m_lTokenID);
                    //局数抽奖
                    Lottery_LoadData(lpContext, pTable, pPlayer, roomid);
                }
            }
        }
        else   // 旁观者
        {
            BOOL can_lookon = FALSE;

            if (IS_BIT_SET(pTable->m_dwStatus, TS_PLAYING_GAME)) // 游戏进行中
            {
                can_lookon = TRUE;
            }
            else   // 游戏未在进行中
            {
                can_lookon = LookOnNoPlaying();
            }
            if (!can_lookon) // 游戏未在进行中
            {
                response.head.nRequest = GR_GAME_NOT_READY;
            }
            else
            {
                pTable->RemoveVisitor(userid, FALSE);
                // xzmo 新增
                if (pTable->m_mapVisitors[chairno].GetCount() >= MAX_VISITORS_PER_CHAIR) // 没有多余座位
                {
                    response.head.nRequest = GR_HAVE_NO_CHAIR;
                }
                else
                {
                    pTable->m_mapVisitors[chairno].SetAt(userid, pPlayer);

                    if (IS_BIT_SET(pTable->m_dwStatus, TS_PLAYING_GAME))
                    {
                        ConstructEnterGameDXXW(roomid, pTable, chairno, userid, TRUE, &response);
                    }
                    else
                    {
                        ConstructEnterGameOK(roomid, pTable, chairno, userid, TRUE, &response);
                    }

                    compressed = TRUE;
                    ZeroMemory(pEnterGame->szHardID, sizeof(pEnterGame->szHardID));

                    if (!IS_BIT_SET(usertype, UT_ADMIN)) // 非管理员进入
                    {

                        USER_ENTERGAME ue;
                        memset(&ue, 0, sizeof(USER_ENTERGAME));

                        ue.nUserID = pEnterGame->nUserID;
                        ue.nTableNO = pEnterGame->nTableNO;
                        ue.nChairNO = pEnterGame->nChairNO;

                        NotifyTablePlayers(pTable, GR_LOOKON_ENTER, &ue, sizeof(USER_ENTERGAME), token);
                        NotifyTableVisitors(pTable, GR_LOOKON_ENTER, &ue, sizeof(USER_ENTERGAME), token);
                    }
                    OnTellHomeInfoOnDXXW(lpContext, roomid, pTable, pPlayer);
                    OnEnterGameDXXW(lpContext, pEnterGame);
                    //发送排行榜网址,显示被旁观者的名次
                    CPlayer* pPlayerOnSeat = pTable->m_ptrPlayers[chairno];
                    if (pPlayerOnSeat)
                    {
                        NotifyMatchWWW(roomid, pPlayerOnSeat->m_nUserID, pPlayer->m_hSocket, pPlayer->m_lTokenID);
                    }
                    NotifyHandPhoneQRCodeURL(roomid, pPlayer->m_nUserType, pPlayer->m_hSocket, pPlayer->m_lTokenID);
                    //
                    Lottery_LoadData(lpContext, pTable, pPlayer, roomid);
                }
            }
        }
        BOOL bSendOK = SendUserResponse(lpContext, &response, FALSE, compressed);

        if (IS_BIT_SET(pTable->m_dwStatus, TS_PLAYING_GAME))
        {
            //断线重连检查下是否需要弹出认输界面
            CheckGiveUp((CMyGameTable*)pTable, chairno);
        }
    }
    // end
    UwlClearRequest(&response);
    return TRUE;
}

// 血战血流 不同的数据结构
BOOL CMyGameServer::ConstructEnterGameDXXW(int roomid, CTable* pTable, int chairno, int userid, BOOL lookon,
    LPREQUEST lpResponse)
{
    if (lookon)
    {
        CMyGameTable* pGameTable = (CMyGameTable*)pTable;
        if (pGameTable->IsXueLiuRoom())
        {
            int entergameok_size = 0;
            int tableinfo_size = pTable->GetGameTableInfoSize();

            HU_ID_HEAD idHead;
            ZeroMemory(&idHead, sizeof(idHead));
            int nTotalCount = 0;
            int nHuIDs[TOTAL_CHAIRS][MAX_CARDS_PER_CHAIR / 2];
            int i = 0;
            for (i = 0; i < TOTAL_CHAIRS; i++)
            {
                XygInitChairCards(nHuIDs[i], MAX_CARDS_PER_CHAIR / 2);
                idHead.nCount[i] = pGameTable->GetHuItemIDs(i, nHuIDs[i]);
                nTotalCount += idHead.nCount[i];
            }

            int nLen = tableinfo_size + sizeof(HU_ITEM_HEAD) + pGameTable->GetTotalItemCount(chairno) * sizeof(HU_ITEM_INFO) + sizeof(HU_ID_HEAD) + nTotalCount * sizeof(int);
            PBYTE pData = NULL;
            if (nLen)
            {
                pData = new BYTE[nLen];
            }
            ZeroMemory(pData, nLen);
            pTable->FillupGameTableInfo(pData, tableinfo_size, chairno, lookon);

            //先填HU_ITEM_HEAD_INFO
            int offsetLen = tableinfo_size;
            int itemCount = pGameTable->GetTotalItemCount(chairno);
            pGameTable->FillupAllHuItems(pData, offsetLen, chairno, itemCount);

            //HU_ID_HEAD
            offsetLen += sizeof(HU_ITEM_HEAD) + itemCount * sizeof(HU_ITEM_INFO);
            LPHU_ID_HEAD pIDHead = LPHU_ID_HEAD((PBYTE)pData + offsetLen);
            memcpy(pIDHead, &idHead, sizeof(HU_ID_HEAD));

            //IDs
            offsetLen += sizeof(HU_ID_HEAD);
            int* pDataIDs = (int*)((PBYTE)pData + offsetLen);
            int index = 0;
            for (i = 0; i < TOTAL_CHAIRS; i++)
            {
                for (int j = 0; j < idHead.nCount[i]; j++)
                {
                    pDataIDs[index] = nHuIDs[i][j];
                    index++;
                }
            }

            lpResponse->head.nRequest = GR_RESPONE_ENTER_GAME_DXXW;
            lpResponse->pDataPtr = pData;
            lpResponse->nDataLen = nLen;
        }
        else
        {
            int entergameok_size = 0;
            int tableinfo_size = pTable->GetGameTableInfoSize();
            int nLen = tableinfo_size;
            PBYTE pData = NULL;
            if (nLen)
            {
                pData = new BYTE[nLen];
            }

            pTable->FillupGameTableInfo(pData, tableinfo_size, chairno, lookon);

            lpResponse->head.nRequest = GR_RESPONE_ENTER_GAME_DXXW;
            lpResponse->pDataPtr = pData;
            lpResponse->nDataLen = nLen;
        }
    }
    else
    {
        int tableno = pTable->m_nTableNO;

        CPlayer* pPlayer = pTable->m_ptrPlayers[chairno];

        if (pPlayer
            && IS_BIT_SET(pPlayer->m_nUserType, UT_HANDPHONE)
            && IsSoloRoom(roomid))
        {
            CMyGameTable* pGameTable = (CMyGameTable*)pTable;
            int tableinfo_size = pTable->GetGameTableInfoSize();

            HU_ID_HEAD idHead;
            ZeroMemory(&idHead, sizeof(idHead));
            int nTotalCount = 0;
            int nHuIDs[TOTAL_CHAIRS][MAX_CARDS_PER_CHAIR / 2];
            int i = 0;
            for (i = 0; i < TOTAL_CHAIRS; i++)
            {
                XygInitChairCards(nHuIDs[i], MAX_CARDS_PER_CHAIR / 2);
                idHead.nCount[i] = pGameTable->GetHuItemIDs(i, nHuIDs[i]);
                nTotalCount += idHead.nCount[i];
            }

            SOLOPLAYER_HEAD sph;
            memset(&sph, 0, sizeof(SOLOPLAYER_HEAD));
            sph.nRoomID = roomid;
            sph.nTableNO = tableno;
            sph.nPlayerCount = pTable->GetPlayerCountOnTable();
            memcpy(sph.dwUserStatus, pTable->m_dwUserStatus, sizeof(sph.dwUserStatus));

            //TableInfo + SOLOPLAYER_HEAD + n*SOLO_PLAYER
            int nLen = tableinfo_size + sizeof(SOLOPLAYER_HEAD) + sph.nPlayerCount * sizeof(SOLO_PLAYER) + sizeof(HU_ITEM_HEAD) + pGameTable->GetTotalItemCount(chairno) * sizeof(HU_ITEM_INFO) + sizeof(
                    HU_ID_HEAD) + nTotalCount * sizeof(int);
            PBYTE pData = NULL;
            if (nLen)
            {
                pData = new BYTE[nLen];
            }
            ZeroMemory(pData, nLen);
            //TableInfo
            pTable->FillupGameTableInfo(pData, tableinfo_size, chairno, lookon);

            //先填HU_ITEM_HEAD_INFO
            int offsetLen = tableinfo_size;
            int itemCount = pGameTable->GetTotalItemCount(chairno);
            pGameTable->FillupAllHuItems(pData, offsetLen, chairno, itemCount);

            //idhead
            offsetLen += sizeof(HU_ITEM_HEAD) + itemCount * sizeof(HU_ITEM_INFO);
            LPHU_ID_HEAD pIDHead = LPHU_ID_HEAD((PBYTE)pData + offsetLen);
            memcpy(pIDHead, &idHead, sizeof(HU_ID_HEAD));

            //ids
            offsetLen += sizeof(HU_ID_HEAD);
            int* pDataIDs = (int*)((PBYTE)pData + offsetLen);
            int index = 0;
            for (i = 0; i < TOTAL_CHAIRS; i++)
            {
                for (int j = 0; j < idHead.nCount[i]; j++)
                {
                    pDataIDs[index] = nHuIDs[i][j];
                    index++;
                }
            }

            //SOLOPLAYER_HEAD
            offsetLen += nTotalCount * sizeof(int);
            memcpy(pData + offsetLen, &sph, sizeof(SOLOPLAYER_HEAD));

            //n*SOLO_PLAYER
            offsetLen += sizeof(SOLOPLAYER_HEAD);
            int nPlayerCount = 0;
            for (i = 0; i < pTable->m_nTotalChairs; i++)
            {
                if (pTable->m_ptrPlayers[i] && pTable->m_ptrPlayers[i]->m_nUserID > 0)
                {
                    SOLO_PLAYER sp;
                    memset(&sp, 0, sizeof(sp));
                    if (LookupSoloPlayer(pTable->m_ptrPlayers[i]->m_nUserID, sp))
                    {
                        //更新soloplayer
                        {
                            sp.nTableNO = pTable->m_nTableNO;
                            sp.nChairNO = i;
                            sp.nScore = pTable->m_ptrPlayers[i]->m_nScore;
                            sp.nDeposit = pTable->m_ptrPlayers[i]->m_nDeposit;
                            sp.nPlayerLevel = pTable->m_ptrPlayers[i]->m_nLevelID;
                            sp.nBout = pTable->m_ptrPlayers[i]->m_nBout;
                            sp.nTimeCost = pTable->m_ptrPlayers[i]->m_nExperience * 60;
                            SetSoloPlayer(pTable->m_ptrPlayers[i]->m_nUserID, sp);

                            if (IsCloakingRoom(roomid))
                            {
                                if (chairno != sp.nChairNO)
                                {
                                    pTable->SetSoloPlayerDXXW(chairno, &sp);
                                }
                            }
                        }
                        memcpy(pData + offsetLen + nPlayerCount * sizeof(SOLO_PLAYER), &sp, sizeof(SOLO_PLAYER));
                        nPlayerCount++;
                    }
                }
            }

            lpResponse->head.nRequest = GR_RESPONE_ENTER_GAME_DXXW;
            lpResponse->pDataPtr = pData;
            lpResponse->nDataLen = nLen;
        }
        else if (IsCloakingRoom(roomid))
        {
            SOLOPLAYER_HEAD sph;
            memset(&sph, 0, sizeof(SOLOPLAYER_HEAD));
            sph.nRoomID = roomid;
            sph.nTableNO = tableno;
            sph.nPlayerCount = pTable->GetPlayerCountOnTable();
            memcpy(sph.dwUserStatus, pTable->m_dwUserStatus, sizeof(sph.dwUserStatus));

            //TableInfo + SOLOPLAYER_HEAD + n*SOLO_PLAYER
            int tableinfo_size = pTable->GetGameTableInfoSize();
            int nLen = tableinfo_size + sizeof(SOLOPLAYER_HEAD) + sph.nPlayerCount * sizeof(SOLO_PLAYER);
            PBYTE pData = NULL;
            if (nLen)
            {
                pData = new BYTE[nLen];
            }
            ZeroMemory(pData, nLen);

            //SOLOPLAYER_HEAD
            memcpy(pData, &sph, sizeof(SOLOPLAYER_HEAD));
            //n*SOLO_PLAYER
            int nPlayerCount = 0;
            for (int i = 0; i < pTable->m_nTotalChairs; i++)
            {
                if (pTable->m_ptrPlayers[i] && pTable->m_ptrPlayers[i]->m_nUserID > 0)
                {
                    SOLO_PLAYER sp;
                    memset(&sp, 0, sizeof(sp));
                    if (LookupSoloPlayer(pTable->m_ptrPlayers[i]->m_nUserID, sp))
                    {
                        //更新soloplayer
                        {
                            sp.nTableNO = pTable->m_nTableNO;
                            sp.nChairNO = i;

                            SetSoloPlayer(pTable->m_ptrPlayers[i]->m_nUserID, sp);

                            if (chairno != i)
                            {
                                pTable->SetSoloPlayerDXXW(chairno, &sp);
                            }
                        }
                        memcpy(pData + sizeof(SOLOPLAYER_HEAD) + nPlayerCount * sizeof(SOLO_PLAYER), &sp, sizeof(SOLO_PLAYER));
                        nPlayerCount++;
                    }
                }
            }

            //TableInfo
            pTable->FillupGameTableInfo(pData + (nLen - tableinfo_size), tableinfo_size, chairno, lookon);

            lpResponse->head.nRequest = GR_RESPONE_ENTER_GAME_DXXW;
            lpResponse->pDataPtr = pData;
            lpResponse->nDataLen = nLen;
        }
        else
        {
            CMyGameTable* pGameTable = (CMyGameTable*)pTable;
            if (pGameTable->IsXueLiuRoom())
            {
                int entergameok_size = 0;
                int tableinfo_size = pTable->GetGameTableInfoSize();

                HU_ID_HEAD idHead;
                ZeroMemory(&idHead, sizeof(idHead));
                int nTotalCount = 0;
                int nHuIDs[TOTAL_CHAIRS][MAX_CARDS_PER_CHAIR / 2];
                int i = 0;
                for (i = 0; i < TOTAL_CHAIRS; i++)
                {
                    XygInitChairCards(nHuIDs[i], MAX_CARDS_PER_CHAIR / 2);
                    idHead.nCount[i] = pGameTable->GetHuItemIDs(i, nHuIDs[i]);
                    nTotalCount += idHead.nCount[i];
                }

                int nLen = tableinfo_size + sizeof(HU_ITEM_HEAD) + pGameTable->GetTotalItemCount(chairno) * sizeof(HU_ITEM_INFO) + sizeof(HU_ID_HEAD) + nTotalCount * sizeof(int);
                PBYTE pData = NULL;
                if (nLen)
                {
                    pData = new BYTE[nLen];
                }
                ZeroMemory(pData, nLen);
                pTable->FillupGameTableInfo(pData, tableinfo_size, chairno, lookon);

                //先填HU_ITEM_HEAD_INFO
                int offsetLen = tableinfo_size;
                int itemCount = pGameTable->GetTotalItemCount(chairno);
                pGameTable->FillupAllHuItems(pData, offsetLen, chairno, itemCount);

                //HU_ID_HEAD
                offsetLen += sizeof(HU_ITEM_HEAD) + itemCount * sizeof(HU_ITEM_INFO);
                LPHU_ID_HEAD pIDHead = LPHU_ID_HEAD((PBYTE)pData + offsetLen);
                memcpy(pIDHead, &idHead, sizeof(HU_ID_HEAD));

                //IDs
                offsetLen += sizeof(HU_ID_HEAD);
                int* pDataIDs = (int*)((PBYTE)pData + offsetLen);
                int index = 0;
                for (i = 0; i < TOTAL_CHAIRS; i++)
                {
                    for (int j = 0; j < idHead.nCount[i]; j++)
                    {
                        pDataIDs[index] = nHuIDs[i][j];
                        index++;
                    }
                }

                lpResponse->head.nRequest = GR_RESPONE_ENTER_GAME_DXXW;
                lpResponse->pDataPtr = pData;
                lpResponse->nDataLen = nLen;
            }
            else
            {
                int entergameok_size = 0;
                int tableinfo_size = pTable->GetGameTableInfoSize();
                int nLen = tableinfo_size;
                PBYTE pData = NULL;
                if (nLen)
                {
                    pData = new BYTE[nLen];
                }

                pTable->FillupGameTableInfo(pData, tableinfo_size, chairno, lookon);

                lpResponse->head.nRequest = GR_RESPONE_ENTER_GAME_DXXW;
                lpResponse->pDataPtr = pData;
                lpResponse->nDataLen = nLen;
            }
        }
    }

    return TRUE;
}

int CMyGameServer::StartSoloTable(START_SOLOTABLE* pStartSoloTable)
{
    CRoom* pRoom = NULL;
    CTable* pTable = NULL;
    CPlayer* pPlayer = NULL;
    int roomid = pStartSoloTable->nRoomID;

    BOOL bCreate = FALSE;
    std::tie(pTable, pRoom, bCreate) = GetTablePtr(pStartSoloTable->nRoomID, pStartSoloTable->nTableNO, TRUE, m_nScoreMult);//清理桌子，以RoomSvr为准
    if (!pRoom)
    {
        return -1;
    }

    if (FALSE == bCreate) // 找到桌子
    {
        //分桌时，目标桌子必须是空
        LOCK_TABLE_EX(pTable, 0, TRUE, 0, 0);

        if (pTable->IsPlayerOnChair())
        {
            //如果只清除旁观玩家，不输出日志
            if (pTable->GetPlayerCountOnTable() > 0)
            {
                UwlLogFile("Clear DestTable On StartSoloTable.RoomID:%ld,TableNO:%ld", pStartSoloTable->nRoomID, pStartSoloTable->nTableNO);
            }

            //清空桌子
            (void)RemoveClients(pTable, 0, TRUE, FALSE);    //该桌上所有roomtablechair已经被清空
            pTable->Reset(); // 清空桌子
        }
    }

    if (pTable)
    {
        SOLO_PLAYER* pSoloPlayer = NULL;
        int i = 0;
        for (i = 0; i < pStartSoloTable->nUserCount; i++)
        {
            int nUserID = pStartSoloTable->nUserIDs[i];
            if (nUserID != 0)
            {
                pSoloPlayer = (SOLO_PLAYER*)(((BYTE*)pStartSoloTable) + sizeof(START_SOLOTABLE) + sizeof(SOLO_PLAYER) * i);
                if (!pSoloPlayer)
                {
                    return -1;
                }
                if (!MoveUserToChair(nUserID, pStartSoloTable->nTableNO, i, pSoloPlayer))
                {
                    UwlLogFile("StartSoloTable Faild,roomid:%ld,tableno:%ld", pStartSoloTable->nRoomID, pStartSoloTable->nTableNO);

                    //移动玩家座位失败,退出所有玩家
                    for (int k = 0; k < pStartSoloTable->nUserCount; k++)
                    {
                        CloseClientInSolo(pStartSoloTable->nUserIDs[k]);
                    }

                    PostCloseSoloTable(pStartSoloTable->nRoomID, pStartSoloTable->nTableNO);
                    return -1;
                }
            }
        }

        //启动游戏
        TCHAR szRoomID[16];
        memset(szRoomID, 0, sizeof(szRoomID));
        _stprintf_s(szRoomID, _T("%ld"), pTable->m_nRoomID);

        if (!CheckBeforeGameStart(pTable))
        {
            return -1;
        }

        if (IS_BIT_SET(GetRoomManage(pTable->m_nRoomID), RM_MATCHONGAME))
        {
            if (!CheckOpenTime(pTable))
            {
                return -1;
            }
        }

        CAutoLock lock2(&(pTable->m_csTable)); //锁住桌子

        int deposit_mult = GetPrivateProfileInt(
                _T("multisilver"),      // section name
                szRoomID,               // key name
                1,                      // default int
                m_szIniFile             // initialization file name
            );
        int fee_ratio = GetPrivateProfileInt(   // 胜方每人收取n%的手续费
                _T("fee"),              // section name
                _T("ratio"),            // key name
                1,                      // default int
                m_szIniFile             // initialization file name
            );
        int max_trans = GetPrivateProfileInt(   //
                _T("deposit"),          // section name
                _T("maxtrans"),         // key name
                0,                      // default int
                m_szIniFile             // initialization file name
            );
        int cut_ratio = GetPrivateProfileInt(   // 胜方每人收取n%的手续费
                _T("cut"),              // section name
                _T("ratio"),            // key name
                100,                    // default int
                m_szIniFile             // initialization file name
            );
        int deposit_logdb = GetPrivateProfileInt(  //
                _T("deposit"),          // section name
                _T("logdb"),            // key name
                0,                      // default int
                m_szIniFile             // initialization file name
            );
        int fee_mode = GetPrivateProfileInt(
                _T("feemode"),  // section name
                szRoomID,       // key name
                FEE_MODE_TEA,   // default int
                m_szIniFile     // initialization file name
            );
        int fee_value = GetPrivateProfileInt(
                _T("feevalue"), // section name
                szRoomID,       // key name
                1,              // default int
                m_szIniFile     // initialization file name
            );
        int fee_tenthousandth = GetPrivateProfileInt(
                _T("feeTTratio"),   // section name
                szRoomID,           // key name
                10,                 // default int
                m_szIniFile         // initialization file name
            );
        int fee_minimum = GetPrivateProfileInt(
                _T("feeminimum"),   // section name
                szRoomID,           // key name
                1000,               // default int
                m_szIniFile         // initialization file name
            );

        ////玩游戏所需的最小银两下限, 修改为接口模式，可以重载
        int deposit_min = GetMinPlayingDeposit(pTable, pTable->m_nRoomID);

        //Modify on 20130225
        int nBaseSliverDefault = 1;
        if (pTable->IsFeeModeService(fee_mode))//服务费模式下，有没有配置基础银，决定了是使用配置的基础银，还是计算出的基础银
        {
            nBaseSliverDefault = 0;
        }


        int base_silver = GetPrivateProfileInt(
                _T("basesilver"),   // section name
                szRoomID,           // key name
                nBaseSliverDefault, // default int
                m_szIniFile         // initialization file name
            );
        int base_score = GetPrivateProfileInt(
                _T("basescore"),    // section name
                szRoomID,           // key name
                0,                  // default int
                m_szIniFile         // initialization file name
            );
        int max_bouttime = GetBoutTimeMax();

        int max_user_bout = GetPrivateProfileInt(
                _T("maxuserbout"),  // section name
                szRoomID,           // key name
                MAX_USER_BOUT,      // default int
                m_szIniFile         // initialization file name
            );

        int max_table_bout = GetPrivateProfileInt(
                _T("maxtablebout"), // section name
                szRoomID,           // key name
                MAX_TABLE_BOUT,     // default int
                m_szIniFile         // initialization file name
            );

        int score_min = GetMinPlayScore(pTable->m_nRoomID);
        int score_max = GetMaxPlayScore(pTable->m_nRoomID);

        TELLCLIENT_SOCLALLY tellSoclally;
        ONE_PLAYER_SOCLALLY   otherSoclally[MAX_CHAIR_COUNT - 1];
        //可变玩家人数游戏模式
        int min_player_count = GetMinPlayerCount(pTable, pTable->m_nRoomID);
        // xzmo 新增
        SetTableMakeCardInfo((CMyGameTable*)pTable);
        // end
        int errchair = INVALID_OBJECT_ID;
        int error = pTable->Restart(errchair, deposit_mult, deposit_min,
                fee_ratio, max_trans, cut_ratio, deposit_logdb,
                fee_mode, fee_value, base_silver, max_bouttime,
                base_score, score_min, score_max,
                max_user_bout, max_table_bout, min_player_count,
                fee_tenthousandth, fee_minimum);
        if (error < 0)
        {
            if (TE_DEPOSIT_NOT_ENOUGH == error) // 有人银子不够
            {
                DEPOSIT_NOT_ENOUGH depositNotEnough;
                ZeroMemory(&depositNotEnough, sizeof(depositNotEnough));

                depositNotEnough.nUserID = pTable->m_ptrPlayers[errchair]->m_nUserID;
                depositNotEnough.nChairNO = errchair;
                depositNotEnough.nDeposit = pTable->m_ptrPlayers[errchair]->m_nDeposit;
                depositNotEnough.nMinDeposit = pTable->m_nDepositMin;

                NotifyTablePlayers(pTable, GR_DEPOSIT_NOT_ENOUGH, &depositNotEnough, sizeof(depositNotEnough));
                NotifyTableVisitors(pTable, GR_DEPOSIT_NOT_ENOUGH, &depositNotEnough, sizeof(depositNotEnough));
            }
            else if (TE_PLAYER_NOT_SEATED == error)  // 有人离开游戏
            {
                PLAYER_NOT_SEATED playNotSeated;
                ZeroMemory(&playNotSeated, sizeof(playNotSeated));

                //playNotSeated.nUserID = pTable->m_ptrPlayers[errchair]->m_nUserID; // NULL == pTable->m_ptrPlayers[errchair]
                playNotSeated.nChairNO = errchair;

                NotifyTablePlayers(pTable, GR_PLAYER_NOT_SEATED, &playNotSeated, sizeof(playNotSeated));
                NotifyTableVisitors(pTable, GR_PLAYER_NOT_SEATED, &playNotSeated, sizeof(playNotSeated));
            }
            else if (TE_SCORE_NOT_ENOUGH == error)  // 有人积分不够
            {
                SCORE_NOT_ENOUGH scoreNotEnough;
                ZeroMemory(&scoreNotEnough, sizeof(scoreNotEnough));

                scoreNotEnough.nUserID = pTable->m_ptrPlayers[errchair]->m_nUserID;
                scoreNotEnough.nChairNO = errchair;
                scoreNotEnough.nScore = pTable->m_ptrPlayers[errchair]->m_nScore;
                scoreNotEnough.nMinScore = pTable->m_nScoreMin;

                NotifyTablePlayers(pTable, GR_SCORE_NOT_ENOUGH, &scoreNotEnough, sizeof(scoreNotEnough));
                NotifyTableVisitors(pTable, GR_SCORE_NOT_ENOUGH, &scoreNotEnough, sizeof(scoreNotEnough));
                //UwlLogFile(_T("someone score not enough! userid = %ld, chairno = %ld, score = %ld, minscore = %ld."),
                //              scoreNotEnough.nUserID, scoreNotEnough.nChairNO, scoreNotEnough.nScore, scoreNotEnough.nMinScore);
            }
            else if (TE_SCORE_TOO_HIGH == error)  // 有人积分超出
            {
                SCORE_TOO_HIGH scoreTooHigh;
                ZeroMemory(&scoreTooHigh, sizeof(scoreTooHigh));

                scoreTooHigh.nUserID = pTable->m_ptrPlayers[errchair]->m_nUserID;
                scoreTooHigh.nChairNO = errchair;
                scoreTooHigh.nScore = pTable->m_ptrPlayers[errchair]->m_nScore;
                scoreTooHigh.nMaxScore = pTable->m_nScoreMax;

                NotifyTablePlayers(pTable, GR_SCORE_TOO_HIGH, &scoreTooHigh, sizeof(scoreTooHigh));
                NotifyTableVisitors(pTable, GR_SCORE_TOO_HIGH, &scoreTooHigh, sizeof(scoreTooHigh));
                //UwlLogFile(_T("someone score too high! userid = %ld, chairno = %ld, score = %ld, maxscore = %ld."),
                //              scoreTooHigh.nUserID, scoreTooHigh.nChairNO, scoreTooHigh.nScore, scoreTooHigh.nMaxScore);
            }
            else if (TE_USER_BOUT_TOO_HIGH == error)  // 有玩家游戏局数超过上限
            {
                USER_BOUT_TOO_HIGH userBoutTooHigh;
                ZeroMemory(&userBoutTooHigh, sizeof(userBoutTooHigh));

                userBoutTooHigh.nUserID = pTable->m_ptrPlayers[errchair]->m_nUserID;
                userBoutTooHigh.nChairNO = errchair;
                userBoutTooHigh.nBout = pTable->m_ptrPlayers[errchair]->m_nBout;
                userBoutTooHigh.nMaxBout = max_user_bout;

                NotifyTablePlayers(pTable, GR_USER_BOUT_TOO_HIGH, &userBoutTooHigh, sizeof(userBoutTooHigh));
                NotifyTableVisitors(pTable, GR_USER_BOUT_TOO_HIGH, &userBoutTooHigh, sizeof(userBoutTooHigh));
            }
            else if (TE_TABLE_BOUT_TOO_HIGH == error)  // 本桌游戏局数超过上限
            {
                TABLE_BOUT_TOO_HIGH tableBoutTooHigh;
                ZeroMemory(&tableBoutTooHigh, sizeof(tableBoutTooHigh));

                tableBoutTooHigh.nTableNO = pTable->m_nTableNO;
                tableBoutTooHigh.nBout = pTable->m_nBoutCount;
                tableBoutTooHigh.nMaxBout = max_table_bout;

                NotifyTablePlayers(pTable, GR_TABLE_BOUT_TOO_HIGH, &tableBoutTooHigh, sizeof(tableBoutTooHigh));
                NotifyTableVisitors(pTable, GR_TABLE_BOUT_TOO_HIGH, &tableBoutTooHigh, sizeof(tableBoutTooHigh));
            }
            else
            {
            }

            //Add on 20121210 by chenyang
            //防止另外几人重新被分桌，确保散桌
            for (i = 0; i < pTable->m_nTotalChairs; i++)
            {
                pTable->m_dwUserStatus[i] &= ~US_GAME_STARTED; //去掉准备状态
                pTable->m_dwUserStatus[i] &= ~US_USER_WAITNEWTABLE; //pengsy 去掉等待分桌状态
            }
            //Add end

            //Solo模式启动游戏失败,退出所有玩家
            UwlLogFile("StartSoloTable Restart Game Faild,roomid:%ld,tableno:%ld", pStartSoloTable->nRoomID, pStartSoloTable->nTableNO);


            for (i = 0; i < pStartSoloTable->nUserCount; i++)
            {
                CloseClientInSolo(pStartSoloTable->nUserIDs[i]);
            }

            PostCloseSoloTable(pStartSoloTable->nRoomID, pStartSoloTable->nTableNO);

            return FALSE;
        }

        RecordUserGameBout(pTable);//记录用户游戏局数
        // xzmo 新增
        //查询上桌玩家的保险箱银子
        //查询玩家保险箱信息
        for (int i = 0; i < pTable->m_nTotalChairs; i++)
        {
            CPlayer* pPlayer = pTable->m_ptrPlayers[i];
            memset(&((CMyGameTable*)pTable)->m_SafeDeposits[i], 0, sizeof(SAFE_DEPOSIT_EX));
            if (pPlayer)
            {
                if (!pTable->ValidateChair(pPlayer->m_nChairNO))
                {
                    continue;
                }
                GetPlayerSafeBoxDeposit(pPlayer, (CMyGameTable*)pTable, i);
            }
        }
        // end
        pTable->m_bForbidChat = XygGetOptionOneTrue(pTable->m_dwRoomOption, pTable->m_nTotalChairs, RO_FORBID_CHAT);
        pTable->m_bForbidLookChat = XygGetOptionOneTrue(pTable->m_dwRoomOption, pTable->m_nTotalChairs, RO_FORBID_LOOKCHAT);
        pTable->m_bAutoStart = XygGetOptionOneTrue(pTable->m_dwRoomOption, pTable->m_nTotalChairs, RO_AUTO_STARTGAME);
        pTable->m_bDarkRoom = XygGetOptionOneTrue(pTable->m_dwRoomConfig, pTable->m_nTotalChairs, RC_DARK_ROOM);

        int nTableSize = sizeof(SOLO_TABLE) + pStartSoloTable->nUserCount * sizeof(SOLO_PLAYER);
        int nStartSize = pTable->GetGameStartSize();
        int nLen = nStartSize + nTableSize;

        void* pData = new BYTE[nLen];
        memset(pData, 0, nLen);
        memcpy(pData, ((PBYTE)pStartSoloTable), nTableSize);

        void* pTempData = NULL;
        if (IsCloakingRoom(pTable->m_nRoomID))
        {
            pTempData = new BYTE[nLen];
            memset(pTempData, 0, nLen);
            pTable->SaveCloakPlayersReal(pData);
        }

        void* pGameStart = ((PBYTE)pData + nTableSize);

        for (i = 0; i < pTable->m_nTotalChairs; i++)
        {
            //玩家
            pTable->FillupGameStart(pGameStart, nStartSize, i, FALSE);
            CPlayer* ptrP = pTable->m_ptrPlayers[i];
            if (ptrP)
            {
                if (IsCloakingRoom(pTable->m_nRoomID))
                {
                    memcpy(pTempData, pData, nLen);
                    pTable->FillSoloPlayersData(i, pTempData);

                    //2014.1.27 modify by pgl
                    NotifyOneUserStartSoloTable(pStartSoloTable->nUserCount, ptrP->m_hSocket, ptrP->m_lTokenID, pTempData, nLen);
                }
                else
                {
                    //2014.1.27 modify by pgl
                    NotifyOneUserStartSoloTable(pStartSoloTable->nUserCount, ptrP->m_hSocket, ptrP->m_lTokenID, pData, nLen);
                }

                // 补发一次 同步信息lbs head
                ZeroMemory(&tellSoclally, sizeof(tellSoclally));
                ZeroMemory(otherSoclally, sizeof(otherSoclally));
                tellSoclally.nCount = pTable->FillPlayerCache(ptrP->m_nUserID, otherSoclally);
                int nSoclallyLen = sizeof(TELLCLIENT_SOCLALLY) + sizeof(ONE_PLAYER_SOCLALLY) * tellSoclally.nCount;
                if (tellSoclally.nCount > 0)
                {
                    BYTE* pData = new BYTE[nSoclallyLen];
                    //                  UwlLogFile("Cloud:咋的了%d",nSoclallyLen);
                    memcpy(pData, &tellSoclally, sizeof(TELLCLIENT_SOCLALLY));
                    memcpy(pData + sizeof(TELLCLIENT_SOCLALLY), otherSoclally, sizeof(ONE_PLAYER_SOCLALLY)*tellSoclally.nCount);
                    NotifyOneUser(ptrP->m_hSocket, ptrP->m_lTokenID, GR_TOCLIENT_SYNCH_SOCLALLY, pData, nSoclallyLen, TRUE);
                    SAFE_DELETE_ARRAY(pData);
                    //旁观者暂时不处理
                    //NotifyTableVisitors(pTable, GR_TOCLIENT_SYNCH_SOCLALLY, &pData, sizeof(TELLCLIENT_SOCLALLY)+sizeof(ONE_PLAYER_SOCLALLY)*tellSoclally.nCount);
                }
            }

            //          if (!IsCloakingRoom(pTable->m_nRoomID)) //隐身房不传旁观
            {
                //旁观者
                pTable->FillupGameStart(pGameStart, nStartSize, i, TRUE);
                CPlayer* ptrV = NULL;
                int userid = 0;
                auto pos = pTable->m_mapVisitors[i].GetStartPosition();
                while (pos)
                {
                    pTable->m_mapVisitors[i].GetNextAssoc(pos, userid, ptrV);
                    if (ptrV)
                    {
                        //2014.1.27 modify by pgl
                        //NotifyOneUser(ptrV->m_hSocket, ptrV->m_lTokenID, GR_START_SOLOTABLE, pData, nLen, TRUE);
                        NotifyOneUserStartSoloTable(pStartSoloTable->nUserCount, ptrP->m_hSocket, ptrP->m_lTokenID, pData, nLen);
                    }
                }
            }
        }

        auto pGameTable = (CMyGameTable*)pTable;
        OnCPStartSoloTable(pStartSoloTable, pTable, pData);

        SAFE_DELETE_ARRAY(pData);
        SAFE_DELETE_ARRAY(pTempData);

        if (0 == pGameTable->m_nTakeFeeTime)
        {
            //服务费的通知
            NotifyServiceFee(pTable);
        }
    }

    return 1;
}

BOOL CMyGameServer::OnGameStarted(CTable* pTable, DWORD dwFlags /*= 0*/)
{
    int i = 0;
    for (i = 0; i < pTable->m_nTotalChairs; i++)
    {
        CPlayer* ptrP = pTable->m_ptrPlayers[i];
        if (!ptrP)
        {
            continue;
        }
        int roomid = pTable->m_nRoomID;
        int tableno = pTable->m_nTableNO;
        int userid = ptrP->m_nUserID;
        int chairno = ptrP->m_nChairNO;

        if (!VerifyRoomTableChair(roomid, tableno, chairno, userid)) // 该位置上用户不匹配
        {
            return FALSE;
        }
    }

    if (!CheckBeforeGameStart(pTable))
    {
        return FALSE;
    }


    if (IS_BIT_SET(GetRoomManage(pTable->m_nRoomID), RM_MATCHONGAME))
    {
        if (!CheckOpenTime(pTable))
        {
            return FALSE;
        }
    }

    TCHAR szRoomID[16];
    memset(szRoomID, 0, sizeof(szRoomID));
    _stprintf_s(szRoomID, _T("%ld"), pTable->m_nRoomID);

    /*
    int deposit_mult = GetPrivateProfileInt(
    _T("deposit"),          // section name
    _T("multiple"),         // key name
    1,                      // default int
    m_szIniFile             // initialization file name
    );
    */
    int deposit_mult = GetPrivateProfileInt(
            _T("multisilver"),      // section name
            szRoomID,               // key name
            1,                      // default int
            m_szIniFile             // initialization file name
        );
    int fee_ratio = GetPrivateProfileInt(   // 胜方每人收取n%的手续费
            _T("fee"),              // section name
            _T("ratio"),            // key name
            1,                      // default int
            m_szIniFile             // initialization file name
        );
    int max_trans = GetPrivateProfileInt(   //
            _T("deposit"),          // section name
            _T("maxtrans"),         // key name
            0,                      // default int
            m_szIniFile             // initialization file name
        );
    int cut_ratio = GetPrivateProfileInt(   // 胜方每人收取n%的手续费
            _T("cut"),              // section name
            _T("ratio"),            // key name
            100,                    // default int
            m_szIniFile             // initialization file name
        );
    int deposit_logdb = GetPrivateProfileInt(  //
            _T("deposit"),          // section name
            _T("logdb"),            // key name
            0,                      // default int
            m_szIniFile             // initialization file name
        );
    int fee_mode = GetPrivateProfileInt(
            _T("feemode"),          // section name
            szRoomID,               // key name
            FEE_MODE_TEA,           // default int
            m_szIniFile             // initialization file name
        );
    int fee_value = GetPrivateProfileInt(
            _T("feevalue"),         // section name
            szRoomID,               // key name
            1,                      // default int
            m_szIniFile             // initialization file name
        );

    int fee_tenthousandth = GetPrivateProfileInt(
            _T("feeTTratio"),   // section name
            szRoomID,           // key name
            10,                 // default int
            m_szIniFile         // initialization file name
        );
    int fee_minimum = GetPrivateProfileInt(
            _T("feeminimum"),   // section name
            szRoomID,           // key name
            1000,               // default int
            m_szIniFile         // initialization file name
        );

    ////玩游戏所需的最小银两下限, 修改为接口模式，可以重载
    int deposit_min = GetMinPlayingDeposit(pTable, pTable->m_nRoomID);
    // xzmo 新增
    SetTableMakeCardInfo((CMyGameTable*)pTable);
    // end
    //Modify on 20130225
    int nBaseSliverDefault = 1;
    if (pTable->IsFeeModeService(fee_mode))//服务费模式下，有没有配置基础银，决定了是使用配置的基础银，还是计算出的基础银
    {
        nBaseSliverDefault = 0;
    }

    int base_silver = GetPrivateProfileInt(
            _T("basesilver"),   // section name
            szRoomID,           // key name
            nBaseSliverDefault, // default int
            m_szIniFile         // initialization file name
        );
    int base_score = GetPrivateProfileInt(
            _T("basescore"),    // section name
            szRoomID,           // key name
            0,                  // default int
            m_szIniFile         // initialization file name
        );
    int max_bouttime = GetBoutTimeMax();

    int max_user_bout = GetPrivateProfileInt(
            _T("maxuserbout"),  // section name
            szRoomID,           // key name
            MAX_USER_BOUT,      // default int
            m_szIniFile         // initialization file name
        );

    int max_table_bout = GetPrivateProfileInt(
            _T("maxtablebout"), // section name
            szRoomID,           // key name
            MAX_TABLE_BOUT,     // default int
            m_szIniFile         // initialization file name
        );

    int score_min = GetMinPlayScore(pTable->m_nRoomID);
    int score_max = GetMaxPlayScore(pTable->m_nRoomID);

    //可变玩家人数游戏模式
    int min_player_count = GetMinPlayerCount(pTable, pTable->m_nRoomID);

    int errchair = INVALID_OBJECT_ID;
    int error = pTable->Restart(errchair, deposit_mult, deposit_min,
            fee_ratio, max_trans, cut_ratio, deposit_logdb,
            fee_mode, fee_value, base_silver, max_bouttime,
            base_score, score_min, score_max,
            max_user_bout, max_table_bout, min_player_count,
            fee_tenthousandth, fee_minimum);
    if (error < 0)
    {
        if (TE_DEPOSIT_NOT_ENOUGH == error) // 有人银子不够
        {
            DEPOSIT_NOT_ENOUGH depositNotEnough;
            ZeroMemory(&depositNotEnough, sizeof(depositNotEnough));

            depositNotEnough.nUserID = pTable->m_ptrPlayers[errchair]->m_nUserID;
            depositNotEnough.nChairNO = errchair;
            depositNotEnough.nDeposit = pTable->m_ptrPlayers[errchair]->m_nDeposit;
            depositNotEnough.nMinDeposit = pTable->m_nDepositMin;

            NotifyTablePlayers(pTable, GR_DEPOSIT_NOT_ENOUGH, &depositNotEnough, sizeof(depositNotEnough));
            NotifyTableVisitors(pTable, GR_DEPOSIT_NOT_ENOUGH, &depositNotEnough, sizeof(depositNotEnough));
        }
        else if (TE_PLAYER_NOT_SEATED == error)  // 有人离开游戏
        {
            PLAYER_NOT_SEATED playNotSeated;
            ZeroMemory(&playNotSeated, sizeof(playNotSeated));

            //playNotSeated.nUserID = pTable->m_ptrPlayers[errchair]->m_nUserID; // NULL == pTable->m_ptrPlayers[errchair]
            playNotSeated.nChairNO = errchair;

            NotifyTablePlayers(pTable, GR_PLAYER_NOT_SEATED, &playNotSeated, sizeof(playNotSeated));
            NotifyTableVisitors(pTable, GR_PLAYER_NOT_SEATED, &playNotSeated, sizeof(playNotSeated));
        }
        else if (TE_SCORE_NOT_ENOUGH == error)  // 有人积分不够
        {
            SCORE_NOT_ENOUGH scoreNotEnough;
            ZeroMemory(&scoreNotEnough, sizeof(scoreNotEnough));

            scoreNotEnough.nUserID = pTable->m_ptrPlayers[errchair]->m_nUserID;
            scoreNotEnough.nChairNO = errchair;
            scoreNotEnough.nScore = pTable->m_ptrPlayers[errchair]->m_nScore;
            scoreNotEnough.nMinScore = pTable->m_nScoreMin;

            NotifyTablePlayers(pTable, GR_SCORE_NOT_ENOUGH, &scoreNotEnough, sizeof(scoreNotEnough));
            NotifyTableVisitors(pTable, GR_SCORE_NOT_ENOUGH, &scoreNotEnough, sizeof(scoreNotEnough));
        }
        else if (TE_SCORE_TOO_HIGH == error)  // 有人积分超出
        {
            SCORE_TOO_HIGH scoreTooHigh;
            ZeroMemory(&scoreTooHigh, sizeof(scoreTooHigh));

            scoreTooHigh.nUserID = pTable->m_ptrPlayers[errchair]->m_nUserID;
            scoreTooHigh.nChairNO = errchair;
            scoreTooHigh.nScore = pTable->m_ptrPlayers[errchair]->m_nScore;
            scoreTooHigh.nMaxScore = pTable->m_nScoreMax;

            NotifyTablePlayers(pTable, GR_SCORE_TOO_HIGH, &scoreTooHigh, sizeof(scoreTooHigh));
            NotifyTableVisitors(pTable, GR_SCORE_TOO_HIGH, &scoreTooHigh, sizeof(scoreTooHigh));
        }
        else if (TE_USER_BOUT_TOO_HIGH == error)  // 有玩家游戏局数超过上限
        {
            USER_BOUT_TOO_HIGH userBoutTooHigh;
            ZeroMemory(&userBoutTooHigh, sizeof(userBoutTooHigh));

            userBoutTooHigh.nUserID = pTable->m_ptrPlayers[errchair]->m_nUserID;
            userBoutTooHigh.nChairNO = errchair;
            userBoutTooHigh.nBout = pTable->m_ptrPlayers[errchair]->m_nBout;
            userBoutTooHigh.nMaxBout = max_user_bout;

            NotifyTablePlayers(pTable, GR_USER_BOUT_TOO_HIGH, &userBoutTooHigh, sizeof(userBoutTooHigh));
            NotifyTableVisitors(pTable, GR_USER_BOUT_TOO_HIGH, &userBoutTooHigh, sizeof(userBoutTooHigh));
        }
        else if (TE_TABLE_BOUT_TOO_HIGH == error)  // 本桌游戏局数超过上限
        {
            TABLE_BOUT_TOO_HIGH tableBoutTooHigh;
            ZeroMemory(&tableBoutTooHigh, sizeof(tableBoutTooHigh));

            tableBoutTooHigh.nTableNO = pTable->m_nTableNO;
            tableBoutTooHigh.nBout = pTable->m_nBoutCount;
            tableBoutTooHigh.nMaxBout = max_table_bout;

            NotifyTablePlayers(pTable, GR_TABLE_BOUT_TOO_HIGH, &tableBoutTooHigh, sizeof(tableBoutTooHigh));
            NotifyTableVisitors(pTable, GR_TABLE_BOUT_TOO_HIGH, &tableBoutTooHigh, sizeof(tableBoutTooHigh));
        }
        else
        {
        }

        //Add on 20121210 by chenyang
        //防止另外几人重新被分桌，确保散桌
        for (i = 0; i < pTable->m_nTotalChairs; i++)
        {
            pTable->m_dwUserStatus[i] &= ~US_GAME_STARTED; //去掉准备状态
        }
        //Add end

        return FALSE;
    }

    RecordUserGameBout(pTable);
    // xzmo 新增
    //查询玩家保险箱信息
    for (int i = 0; i < pTable->m_nTotalChairs; i++)
    {
        CPlayer* pPlayer = pTable->m_ptrPlayers[i];
        memset(&((CMyGameTable*)pTable)->m_SafeDeposits[i], 0, sizeof(SAFE_DEPOSIT_EX));
        if (pPlayer)
        {
            if (!pTable->ValidateChair(pPlayer->m_nChairNO))
            {
                continue;
            }
            GetPlayerSafeBoxDeposit(pPlayer, (CMyGameTable*)pTable, i);
        }
    }
    // end
    //Del by chenyang on 20130507
    //所有房间都发生游戏开始消息到roomsvr
    //  if (IsSoloRoom(pTable->m_nRoomID))
    {
        if (IsVariableChairRoom(pTable->m_nRoomID))
        {
            int nChairStatus[MAX_CHAIRS_PER_TABLE];
            memset(&nChairStatus, 0, sizeof(nChairStatus));
            for (i = 0; i < MAX_CHAIRS_PER_TABLE; i++)
            {
                if (pTable->m_ptrPlayers[i]
                    && !(pTable->m_ptrPlayers[i]->m_bIdlePlayer))
                {
                    nChairStatus[i] = 1;
                }
            }

            DWORD dwTableChairStatus = MakeTableChairStatus(pTable->m_nTableNO, nChairStatus, MAX_CHAIRS_PER_TABLE);

            PostGameStart(pTable->m_nRoomID, dwTableChairStatus);

            //踢掉连续多局不参与的玩家
            KickOffTooManyIdlePlayer(pTable, pTable->m_nRoomID);
        }
        else
        {
            PostGameStart(pTable->m_nRoomID, pTable->m_nTableNO);
        }
    }

    int nLen = 0;
    nLen = pTable->GetGameStartSize();

    void* pData = new BYTE[nLen];

    for (i = 0; i < pTable->m_nTotalChairs; i++)
    {

        pTable->FillupGameStart(pData, nLen, i, FALSE);
        CPlayer* ptrP = pTable->m_ptrPlayers[i];
        if (ptrP)
        {
            NotifyOneUser(ptrP->m_hSocket, ptrP->m_lTokenID, GR_GAME_START, pData, nLen, TRUE);
        }
    }
    for (i = 0; i < pTable->m_nTotalChairs; i++)
    {
        pTable->FillupGameStart(pData, nLen, i, TRUE);
        int userid = 0;
        CPlayer* ptrV = NULL;
        auto pos = pTable->m_mapVisitors[i].GetStartPosition();
        while (pos)
        {
            pTable->m_mapVisitors[i].GetNextAssoc(pos, userid, ptrV);
            if (ptrV)
            {
                NotifyOneUser(ptrV->m_hSocket, ptrV->m_lTokenID, GR_GAME_START, pData, nLen, TRUE);
            }
        }
    }

    OnCPOnGameStarted(pTable, pData);
    SAFE_DELETE(pData);
    // 这里会导致流程卡死
    auto pGameTable = (CMyGameTable*)pTable;
    if (0 == pGameTable->m_nTakeFeeTime)
    {
        //服务费的通知
        NotifyServiceFee(pTable);
    }

    return TRUE;
}

void CMyGameServer::OnServerAutoPlay(CRoom* pRoom, CTable* ptr, int chairno, bool bOnline, BOOL bClockZero)
{
    LOG_TRACE(_T("OnSeverAutoPlay"));

    int nRoomID = pRoom->m_nRoomID;

    auto pTable = dynamic_cast<CMyGameTable*>(ptr);
    if (!IS_BIT_SET(pTable->m_dwStatus, TS_PLAYING_GAME))
    {
        return;
    }
    if (!IS_BIT_SET(pTable->m_dwStatus, TS_WAITING_AUCTION) && !IS_BIT_SET(pTable->m_dwStatus, TS_WAITING_EXCHANGE3CARDS) && !IS_BIT_SET(pTable->m_dwStatus, TS_WAITING_GIVEUP))
    {
        if (chairno != pTable->GetCurrentChair())
        {
            return;
        }
    }

    if (!pTable->ValidateChair(chairno))
    {
        return;
    }

    CPlayer* pPlayer = pTable->m_ptrPlayers[chairno];
    if (!pPlayer)
    {
        return;
    }

    DWORD dwTickWait = 2000;

    if (GetTickCount() - pTable->m_dwActionBegin >= dwTickWait || !bOnline)
    {
        dwTickWait = 0;//等待超时，那么立即执行
    }
    else if (!bOnline)                  //等待未超时,且不是在线快速抓牌
    {
        LOG_DEBUG("OnServerAutoPlay  等待未超时,且不是在线快速抓牌");
        return;
    }
    CMyGameTable* pMyGameTable = (CMyGameTable*)pTable;
    //自动换三张
    if (IS_BIT_SET(pTable->m_dwStatus, TS_WAITING_EXCHANGE3CARDS))
    {
        LOG_DEBUG("TS_WAITING_EXCHANGE3CARDS#########;%d, %ld, %ld", pTable->m_nDingQueWait, GetTickCount(), pTable->m_dwDingQueStartTime);
        if (((GetTickCount() - pTable->m_dwDingQueStartTime)) > (pTable->m_nDingQueWait * 1000 + 5000))
        {
            for (int offline = 0; offline < pTable->m_nTotalChairs; offline++)
            {
                if (pTable->ValidateChair(offline)
                    && pTable->CheckOffline(offline) && (!pTable->m_bExchangeCards[offline]))
                {
                    OnPlayerOffline(pTable, offline);
                    EXCHANGE3CARDS exchange3cards;
                    ZeroMemory(&exchange3cards, sizeof(exchange3cards));
                    exchange3cards.nChairNO = offline;
                    pTable->OnAutoExchangeCards(&exchange3cards);
                    LOG_DEBUG(_T("***********ROBOT_BOUT_LOG_EXCHANGECARDS***********roomid:%d, tableno:%d, userid:%d, chairno:%d, cardids:%s, %s, %s"), exchange3cards.nRoomID, pMyGameTable->m_nTableNO,
                        pTable->m_ptrPlayers[offline]->m_nUserID, offline, pMyGameTable->RobotBoutLog(exchange3cards.nExchange3Cards[0][0]), pMyGameTable->RobotBoutLog(exchange3cards.nExchange3Cards[0][1]),
                        pMyGameTable->RobotBoutLog(exchange3cards.nExchange3Cards[0][2]));
                    pPlayer = pTable->m_ptrPlayers[offline];
                    SimulateGameMsgFromUser(nRoomID, pPlayer, LOCAL_GAME_MSG_AUTO_EXCHANGECARDS, sizeof(EXCHANGE3CARDS), &exchange3cards, dwTickWait);
                }
            }
        }
        return;
    }

    //自动定缺
    if (IS_BIT_SET(pTable->m_dwStatus, TS_WAITING_AUCTION))
    {
        int nLimitTime = (pTable->m_nDingQueWait * 1000 + 5000);
        if (TRUE == IS_BIT_SET(pTable->m_dwRoomOption[0], ROOM_TYPE_EXCHANGE3CARDS))
        {
            nLimitTime = 5000;
        }
        LOG_DEBUG("TS_WAITING_AUCTION#########;%d, %ld, %ld", nLimitTime, GetTickCount(), pTable->m_dwDingQueStartTime);
        if (((GetTickCount() - pTable->m_dwDingQueStartTime)) > nLimitTime)
        {
            LOG_DEBUG("TS_WAITING_AUCTION : Time > nLimitTime");
            for (int offline = 0; offline < pTable->m_nTotalChairs; offline++)
            {
                if (pTable->ValidateChair(offline)
                    && pTable->CheckOffline(offline) && (-1 == pTable->m_nDingQueCardType[offline]))
                {
                    OnPlayerOffline(pTable, offline);
                    int nCardIDs[MAX_CARDS_PER_CHAIR];
                    XygInitChairCards(nCardIDs, MAX_CARDS_PER_CHAIR);
                    int nCardCount = pTable->GetChairCards(offline, nCardIDs, MAX_CARDS_PER_CHAIR);
                    if (nCardCount)
                    {
                        AUCTION_DINGQUE dingquecard;
                        ZeroMemory(&dingquecard, sizeof(dingquecard));
                        dingquecard.nChairNO = offline;
                        dingquecard.nDingQueCardType[offline] = -1;

                        int nTiaoCount = 0, nWanCount = 0, nTongCount = 0;
                        int nCardType = 0;
                        for (int k = 0; k < nCardCount; k++)
                        {
                            nCardType = pTable->m_pCalclator->MJ_CalculateCardShape(nCardIDs[k], 0);
                            if (MJ_CS_TIAO == nCardType)
                            {
                                nTiaoCount++;
                            }
                            else if (MJ_CS_DONG == nCardType)
                            {
                                nTongCount++;
                            }
                            else if (MJ_CS_WAN == nCardType)
                            {
                                nWanCount++;
                            }
                        }
                        nCardType = MJ_CS_WAN;
                        if (nTiaoCount < nWanCount)
                        {
                            nCardType = nTongCount < nTiaoCount ? MJ_CS_DONG : MJ_CS_TIAO;
                        }
                        else if (nTongCount < nWanCount)
                        {
                            nCardType = MJ_CS_DONG;
                        }
                        //rand() % (b-a+1)+ a
                        if (nCardType == MJ_CS_WAN)
                        {
                            if (nWanCount == nTiaoCount)
                            {
                                int nTime = rand() % 2;
                                if (nTime == 0)
                                {
                                    nCardType = MJ_CS_WAN;
                                }
                                else
                                {
                                    nCardType = MJ_CS_TIAO;
                                }
                            }
                            else if (nWanCount == nTongCount)
                            {
                                int nTime = rand() % 2;
                                if (nTime == 0)
                                {
                                    nCardType = MJ_CS_WAN;
                                }
                                else
                                {
                                    nCardType = MJ_CS_DONG;
                                }
                            }
                            else if ((nWanCount == nTiaoCount) && (nTiaoCount == nTongCount))
                            {
                                int nTime = rand() % 3;
                                if (nTime == 0)
                                {
                                    nCardType = MJ_CS_WAN;
                                }
                                else if (nTime == 1)
                                {
                                    nCardType = MJ_CS_TIAO;
                                }
                                else
                                {
                                    nCardType = MJ_CS_DONG;
                                }
                            }
                        }
                        else if (nCardType == MJ_CS_TIAO)
                        {
                            if (nWanCount == nTiaoCount)
                            {
                                int nTime = rand() % 2;
                                if (nTime == 0)
                                {
                                    nCardType = MJ_CS_WAN;
                                }
                                else
                                {
                                    nCardType = MJ_CS_TIAO;
                                }
                            }
                            else if (nTiaoCount == nTongCount)
                            {
                                int nTime = rand() % 2;
                                if (nTime == 0)
                                {
                                    nCardType = MJ_CS_TIAO;
                                }
                                else
                                {
                                    nCardType = MJ_CS_DONG;
                                }
                            }
                            else if ((nWanCount == nTiaoCount) && (nTiaoCount == nTongCount))
                            {
                                int nTime = rand() % 3;
                                if (nTime == 0)
                                {
                                    nCardType = MJ_CS_WAN;
                                }
                                else if (nTime == 1)
                                {
                                    nCardType = MJ_CS_TIAO;
                                }
                                else
                                {
                                    nCardType = MJ_CS_DONG;
                                }
                            }
                        }
                        else
                        {
                            if (nTongCount == nTiaoCount)
                            {
                                int nTime = rand() % 2;
                                if (nTime == 0)
                                {
                                    nCardType = MJ_CS_DONG;
                                }
                                else
                                {
                                    nCardType = MJ_CS_TIAO;
                                }
                            }
                            else if (nWanCount == nTongCount)
                            {
                                int nTime = rand() % 2;
                                if (nTime == 0)
                                {
                                    nCardType = MJ_CS_WAN;
                                }
                                else
                                {
                                    nCardType = MJ_CS_DONG;
                                }
                            }
                            else if ((nWanCount == nTiaoCount) && (nTiaoCount == nTongCount))
                            {
                                int nTime = rand() % 3;
                                if (nTime == 0)
                                {
                                    nCardType = MJ_CS_WAN;
                                }
                                else if (nTime == 1)
                                {
                                    nCardType = MJ_CS_TIAO;
                                }
                                else
                                {
                                    nCardType = MJ_CS_DONG;
                                }
                            }
                        }

                        dingquecard.nDingQueCardType[offline] = nCardType;
                        pPlayer = pTable->m_ptrPlayers[offline];
                        SimulateGameMsgFromUser(nRoomID, pPlayer, LOCAL_GAME_MSG_AUTO_FIXMISS, sizeof(AUCTION_DINGQUE), &dingquecard, dwTickWait);
                    }
                }
            }
            return;
        }
    }
    //自动放弃
    if (IS_BIT_SET(pTable->m_dwStatus, TS_WAITING_GIVEUP))
    {
        BOOL bRobotBout = FALSE;
        for (int j = 0; j < TOTAL_CHAIRS; j++)
        {
            if (pTable->IsRoboter(j))
            {
                bRobotBout = True;
            }
        }
        for (int offline = 0; offline < pTable->m_nTotalChairs; offline++)
        {
            if (bRobotBout)
            {
                int nTime = rand() % 4 + 2;
                if (bClockZero)
                {
                    if (pTable->ValidateChair(offline) && pTable->CheckOffline(offline) && (pTable->m_nGiveUpChair[offline] != -1))
                    {
                        pPlayer = pTable->m_ptrPlayers[offline];

                        GIVE_UP_GAME giveUpGame;
                        memset(&giveUpGame, 0, sizeof(giveUpGame));
                        giveUpGame.nRoomID = pTable->m_nRoomID;
                        giveUpGame.nTableNO = pTable->m_nTableNO;
                        giveUpGame.nUserID = pPlayer->m_nUserID;
                        giveUpGame.nChairNO = offline;

                        SimulateGameMsgFromUser(nRoomID, pPlayer, LOCAL_GAME_MSG_AUTO_GIVEUP, sizeof(GIVE_UP_GAME), &giveUpGame, nTime * 1000);
                    }
                }
                else
                {
                    if (pTable->ValidateChair(offline) && pTable->IsRoboter(offline) && (pTable->m_nGiveUpChair[offline] != -1))
                    {
                        pPlayer = pTable->m_ptrPlayers[offline];

                        GIVE_UP_GAME giveUpGame;
                        memset(&giveUpGame, 0, sizeof(giveUpGame));
                        giveUpGame.nRoomID = pTable->m_nRoomID;
                        giveUpGame.nTableNO = pTable->m_nTableNO;
                        giveUpGame.nUserID = pPlayer->m_nUserID;
                        giveUpGame.nChairNO = offline;

                        SimulateGameMsgFromUser(nRoomID, pPlayer, LOCAL_GAME_MSG_AUTO_GIVEUP, sizeof(GIVE_UP_GAME), &giveUpGame, nTime * 1000);
                    }
                }
            }
            else
            {
                int nTime = rand() % 8 + 6;
                if (pTable->ValidateChair(offline)
                    && pTable->CheckOffline(offline) && (pTable->m_nGiveUpChair[offline] != -1))
                {
                    OnPlayerOffline(pTable, offline);
                    pPlayer = pTable->m_ptrPlayers[offline];

                    GIVE_UP_GAME giveUpGame;
                    memset(&giveUpGame, 0, sizeof(giveUpGame));
                    giveUpGame.nRoomID = pTable->m_nRoomID;
                    giveUpGame.nTableNO = pTable->m_nTableNO;
                    giveUpGame.nUserID = pPlayer->m_nUserID;
                    giveUpGame.nChairNO = offline;
                    SimulateGameMsgFromUser(nRoomID, pPlayer, LOCAL_GAME_MSG_AUTO_GIVEUP, sizeof(GIVE_UP_GAME), &giveUpGame, dwTickWait);
                }
            }
        }
        return;
    }

    //自动抓牌
    if (IS_BIT_SET(pTable->m_dwStatus, TS_WAITING_CATCH))
    {
        LOG_DEBUG("OnServerAutoPlay TS_WAITING_CATCH");
        int nTempForCatch = 0;
        try
        {
            BOOL bSomeOnehu = FALSE;
            int nThrowChairNO = pTable->GetPrevChair(pTable->GetCurrentChair());
            nTempForCatch = 1;
            int nThrowIndex = 0;
            if (nThrowChairNO > INVALID_OBJECT_ID)
            {
                nThrowIndex = pTable->m_nOutCards[nThrowChairNO].GetSize() - 1;
            }
            nTempForCatch = 2;
            if (nThrowIndex >= 0)
            {
                nTempForCatch = 3;
                int nThrowCardID = pTable->m_nOutCards[nThrowChairNO][nThrowIndex];
                nTempForCatch = 4;
                if (nThrowCardID > INVALID_OBJECT_ID)
                {
                    for (int i = 0; i < pTable->m_nTotalChairs; i++)
                    {
                        if (nThrowChairNO == i)
                        {
                            continue;
                        }

                        if (IS_BIT_SET(pTable->m_dwPGCHFlags[i], MJ_HU) && (pTable->m_HuReady[i] != MJ_GIVE_UP))  //胡过一次后必须胡
                        {
                            LOG_DEBUG("OnServerAutoPlay : Some One hu[%d]", i);
                            // 超时时  不能判断谁断线了,因为放炮玩家和i不是同一个玩家
                            bSomeOnehu = TRUE;
                            //剩四必胡
                            if (pTable->IsLastFourCard() && bClockZero)
                            {
                                LOG_DEBUG("OnServerAutoPlay -> [bClockZero]OnSeverAutoPlayFangChongHu");
                                OnSeverAutoPlayFangChongHu(pRoom, pTable, i, nThrowChairNO, nThrowCardID);

                            }
                            else if (pTable->m_HuReady[i] && pTable->IsOffline(i))
                            {
                                LOG_DEBUG("OnServerAutoPlay -> [IsOffline]OnSeverAutoPlayFangChongHu");
                                OnSeverAutoPlayFangChongHu(pRoom, pTable, i, nThrowChairNO, nThrowCardID);
                            }
                            else if (bClockZero)
                            {
                                LOG_DEBUG("OnServerAutoPlay bClockZero");
                                bSomeOnehu = FALSE;
                            }
                        }
                        else if (pTable->m_dwPGCHFlags[i] != 0 && (pTable->IsOffline(i)))
                        {
                            LOG_DEBUG("OnServerAutoPlay Not PengStatus And IsOffline[%d]", i);
                            //if (!pTable->m_Pass[i])
                            {
                                GUO_CARD cardguo;
                                ZeroMemory(&cardguo, sizeof(GUO_CARD));
                                cardguo.nChairNO = i;
                                cardguo.nCardChair = nThrowChairNO;
                                CPlayer* pGuoPlayer = pTable->m_ptrPlayers[i];
                                SimulateGameMsgFromUser(nRoomID, pGuoPlayer, LOCAL_GAME_MSG_AUTO_GUO, sizeof(GUO_CARD), &cardguo, dwTickWait);
                            }
                        }

                        if (bClockZero && pTable->m_dwPGCHFlags[i] != 0)
                        {
                            LOG_DEBUG("OnServerAutoPlay bClockZero And Not PengStatus[%d]", i);
                            GUO_CARD cardguo;
                            ZeroMemory(&cardguo, sizeof(GUO_CARD));
                            cardguo.nChairNO = i;
                            cardguo.nCardChair = nThrowChairNO;
                            CPlayer* pGuoPlayer = pTable->m_ptrPlayers[i];
                            SimulateGameMsgFromUser(nRoomID, pGuoPlayer, LOCAL_GAME_MSG_AUTO_GUO, sizeof(GUO_CARD), &cardguo, dwTickWait);
                        }
                    }
                    // 解决一炮多响,一个切后台,两个点胡,直接过的问题
                    if (pTable->m_nWaitOpeMsgID == GR_RECONS_FANGPAO)
                    {
                        LOG_DEBUG("OnServerAutoPlay GR_RECONS_FANGPAO");
                        bSomeOnehu = TRUE;
                    }
                }
                nTempForCatch = 6;
            }
            if (bSomeOnehu)
            {
                LOG_DEBUG("OnServerAutoPlay bSomeOnehu: TRUE");
                return;
            }
        }
        catch (...)
        {
            UwlLogFile(_T("The Exception OnSeverAutoPlay TS_WAITING_CATCH nTempForCatch:%d"), nTempForCatch);
        }
        CATCH_CARD Card;
        memset(&Card, 0, sizeof(Card));
        Card.nChairNO = chairno;
        if (pTable->IsRoboter(chairno))
        {
            int nTime = rand() % 4 + 1;
            SimulateGameMsgFromUser(nRoomID, pPlayer,
                bOnline ? LOCAL_GAME_MSG_QUICK_CATCH : LOCAL_GAME_MSG_AUTO_CATCH, sizeof(CATCH_CARD), &Card, 0);
        }
        else
        {
            int nAutoCatchTime = GetPrivateProfileInt(_T("autoCatchTime"), _T("catchtime"), 500, m_szIniFile);
            SimulateGameMsgFromUser(nRoomID, pPlayer,
                bOnline ? LOCAL_GAME_MSG_QUICK_CATCH : LOCAL_GAME_MSG_AUTO_CATCH, sizeof(CATCH_CARD), &Card, bOnline ? nAutoCatchTime : dwTickWait);
        }

        return;
    }
    if (bOnline)
    {
        LOG_DEBUG("OnServerAutoPlay bOnline: TRUE");
        return;
    }

    //yqwautoplay begin
    if (IsYQWRoom(nRoomID) && !pTable->IsYQWAutoPlay() && !pTable->IsYQWQuickRoom())
    {
        return;
    }
    //yqwautoplay end
    //自动出牌
    if (IS_BIT_SET(pTable->m_dwStatus, TS_WAITING_THROW))
    {
        LOG_DEBUG("OnServerAutoPlay TS_WAITING_THROW ");
        if (bClockZero && pTable->IsLastFourCard())
        {
            DWORD dRet = pTable->CalcHu_Zimo(chairno, pTable->m_nCurrentCard);
            if (IS_BIT_SET(dRet, MJ_HU))
            {
                OnSeverAutoPlayHuZiMo(pRoom, pTable, pTable->GetCurrentChair(), pTable->m_nCurrentCard);
                return;
            }
        }

        int nCardIDs[MAX_CARDS_PER_CHAIR];
        XygInitChairCards(nCardIDs, MAX_CARDS_PER_CHAIR);
        int nCardCount = pTable->GetChairCards(chairno, nCardIDs, MAX_CARDS_PER_CHAIR);
        if (nCardCount)
        {
            if (IsYQWRoom(nRoomID))
            {
                // 这里加个2秒  消息传输总需要点时间
                dwTickWait = pTable->m_nYQWQuickThrowWait * 1000 + 2000;
            }

            if (pTable->IsRoboter(chairno))
            {
                LOG_DEBUG("OnServerAutoPlay IsRoboter[%d]", chairno);
                int nTime = rand() % 4 + 1;
                SimulateGameMsgFromUser(nRoomID, pPlayer,
                    LOCAL_GAME_MSG_AUTO_THROW, 0, NULL, nTime * 1000);
            }
            else
            {
                if (GetTickCount() - pTable->m_dwActionBegin >= dwTickWait)
                {
                    //等待超时，那么立即执行
                    SimulateGameMsgFromUser(nRoomID, pPlayer,
                        LOCAL_GAME_MSG_AUTO_THROW, 0, NULL, bOnline ? 0 : 2000);
                }
            }

        }
    }
}

void CMyGameServer::OnServerAutoPlay(CRoom* pRoom, CTable* pTable, int chairno, bool bOnline)
{
    OnServerAutoPlay(pRoom, pTable, chairno, bOnline, FALSE);
}

void CMyGameServer::OnSeverAutoPlayFangChongHu(CRoom* pRoom, CTable* ptr, int chairno, int nFangChongChair, int nFangChongCardID)
{
    if (NULL == pRoom)
    {
        return;
    }

    int nRoomID = pRoom->m_nRoomID;

    CMyGameTable* pTable = (CMyGameTable*)ptr;
    if (NULL == pTable)
    {
        return;
    }
    if (!IS_BIT_SET(pTable->m_dwStatus, TS_PLAYING_GAME))
    {
        return;
    }
    if (!pTable->ValidateChair(chairno))
    {
        return;
    }
    if (!pTable->ValidateChair(pTable->GetCurrentChair()))
    {
        return;
    }

    CPlayer* pPlayer = pTable->m_ptrPlayers[chairno];
    if (!pPlayer)
    {
        return;
    }

    DWORD dwTickWait = 2000;

    if ((GetTickCount() - pTable->m_dwActionBegin) > dwTickWait)
    {
        dwTickWait = 0;    //等待超时，那么立即执行
    }

    //自动抓牌
    if (IS_BIT_SET(pTable->m_dwStatus, TS_WAITING_CATCH))
    {
        if (IS_BIT_SET(pTable->m_dwPGCHFlags[chairno], MJ_HU))
        {
            HU_CARD hc;
            ZeroMemory(&hc, sizeof(hc));
            hc.nChairNO = chairno;
            hc.nCardChair = nFangChongChair;
            hc.nCardID = nFangChongCardID;
            hc.dwFlags = MJ_HU_FANG;
            hc.nReserved[0] = MJ_HU_FANG;

            if (pTable->IsRoboter(chairno))
            {
                int operateTime = pTable->GetRobotOperateTimeRate();
                int nTime = rand() % operateTime + 1;
                LOG_DEBUG("OnSeverAutoPlayFangChongHu: nTime[%d], operateTime[%d]", nTime, operateTime);
                // 这里时间必须用0 不然下局开始可能还会收到结算消息
                SimulateGameMsgFromUser(nRoomID, pPlayer, LOCAL_GAME_MSG_AUTO_HU, sizeof(HU_CARD), &hc, 0);
            }
            else
            {
                SimulateGameMsgFromUser(nRoomID, pPlayer, LOCAL_GAME_MSG_AUTO_HU, sizeof(HU_CARD), &hc, dwTickWait);
            }
        }

        return;
    }
}
void CMyGameServer::OnSeverAutoPlayHuZiMo(CRoom* pRoom, CTable* ptr, int chairno, int nHuCardID)
{
    if (NULL == pRoom)
    {
        return;
    }
    int nRoomID = pRoom->m_nRoomID;

    CMyGameTable* pTable = (CMyGameTable*)ptr;
    if (NULL == pTable)
    {
        return;
    }
    if (!IS_BIT_SET(pTable->m_dwStatus, TS_PLAYING_GAME))
    {
        return;
    }
    if (!pTable->ValidateChair(chairno))
    {
        return;
    }
    if (!pTable->ValidateChair(pTable->GetCurrentChair()))
    {
        return;
    }

    if (chairno != pTable->GetCurrentChair())
    {
        return;
    }

    CPlayer* pPlayer = pTable->m_ptrPlayers[chairno];
    if (!pPlayer)
    {
        return;
    }

    DWORD dwTickWait = 2000;

    if (GetTickCount() - pTable->m_dwActionBegin > dwTickWait)
    {
        dwTickWait = 0;    //等待超时，那么立即执行
    }

    //自动出牌
    if (IS_BIT_SET(pTable->m_dwStatus, TS_WAITING_THROW))
    {
        HU_CARD hc;
        ZeroMemory(&hc, sizeof(hc));
        hc.nChairNO = chairno;
        hc.nCardChair = chairno;
        hc.nCardID = nHuCardID;
        hc.dwFlags = MJ_HU_ZIMO;
        hc.nReserved[0] = MJ_HU_ZIMO;

        if (pTable->IsRoboter(chairno))
        {
            int operateTime = pTable->GetRobotOperateTimeRate();
            int nTime = rand() % operateTime + 1;
            SimulateGameMsgFromUser(nRoomID, pPlayer, LOCAL_GAME_MSG_AUTO_HU, sizeof(HU_CARD), &hc, 0);
        }
        else
        {
            SimulateGameMsgFromUser(nRoomID, pPlayer, LOCAL_GAME_MSG_AUTO_HU, sizeof(HU_CARD), &hc, dwTickWait);
        }
    }
}
void CMyGameServer::OnSeverAutoPlayHuQiangGang(CRoom* pRoom, CTable* ptr, int chairno, int ngangChair, int nHuCardID, DWORD dwGangFlags)
{
    if (NULL == pRoom)
    {
        return;
    }
    int nRoomID = pRoom->m_nRoomID;

    CMyGameTable* pTable = (CMyGameTable*)ptr;
    if (NULL == pTable)
    {
        return;
    }
    if (!IS_BIT_SET(pTable->m_dwStatus, TS_PLAYING_GAME))
    {
        return;
    }
    if (!pTable->ValidateChair(chairno))
    {
        return;
    }
    if (!pTable->ValidateChair(pTable->GetCurrentChair()))
    {
        return;
    }

    //if (chairno!=pTable->GetCurrentChair())
    //  return;

    CPlayer* pPlayer = pTable->m_ptrPlayers[chairno];
    if (!pPlayer)
    {
        return;
    }

    DWORD dwTickWait = 2000;

    if (GetTickCount() - pTable->m_dwActionBegin > dwTickWait)
    {
        dwTickWait = 0;    //等待超时，那么立即执行
    }

    //自动出牌
    //if (IS_BIT_SET(pTable->m_dwStatus,TS_WAITING_THROW))
    {
        HU_CARD hc;
        ZeroMemory(&hc, sizeof(hc));
        hc.nChairNO = chairno;
        hc.nCardChair = ngangChair;
        hc.nCardID = nHuCardID;
        hc.dwFlags = MJ_HU_QGNG;
        hc.dwSubFlags = dwGangFlags;
        hc.nReserved[0] = MJ_HU_QGNG;

        SimulateGameMsgFromUser(nRoomID, pPlayer, LOCAL_GAME_MSG_AUTO_HU, sizeof(HU_CARD), &hc, dwTickWait);
    }
}

void CMyGameServer::SetTableMakeCardInfo(CMyGameTable* pTable)
{
    if (NULL == pTable)
    {
        return;
    }

    SOLO_PLAYER sp;
    for (int i = 0; i < pTable->m_nTotalChairs; i++)
    {
        if (pTable->m_ptrPlayers[i] && pTable->m_ptrPlayers[i]->m_nUserID > 0)
        {
            memset(&sp, 0, sizeof(sp));
            if (LookupSoloPlayer(pTable->m_ptrPlayers[i]->m_nUserID, sp))
            {
                pTable->m_stMakeCardInfo[i].nLossCount = sp.nReserved3[0];
                pTable->m_stMakeCardInfo[i].nJumpCount = sp.nReserved3[1];
                pTable->m_stMakeCardInfo[i].nPayCount = sp.nReserved3[2];
                pTable->m_stMakeCardInfo[i].nWinBout = sp.nWin;
            }
        }
    }
}

BOOL CMyGameServer::OnMyTakeSafeDeposit(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt)
{
    LOG_TRACE(_T("CMyGameServer::OnMyTakeSafeDeposit"));
    SAFETY_NET_REQUEST(lpRequest, TAKE_SAFE_DEPOSIT, pTakeSafeDeposit);

    REQUEST response;
    memset(&response, 0, sizeof(response));

    SOCKET sock = INVALID_SOCKET;
    LONG token = 0;
    int gameid = 0;
    int roomid = 0;
    int tableno = INVALID_OBJECT_ID;
    int userid = 0;
    int chairno = INVALID_OBJECT_ID;
    int r_id = 0;
    int t_no = INVALID_OBJECT_ID;
    int u_id = 0;
    int c_no = INVALID_OBJECT_ID;
    LONG room_tokenid = 0;

    CTable* pTable = NULL;
    CPlayer* pPlayer = NULL;

    sock = lpContext->hSocket;
    token = lpContext->lTokenID;

    response.head.nRequest = UR_OPERATE_FAILED;
    gameid = pTakeSafeDeposit->nGameID;
    roomid = pTakeSafeDeposit->nRoomID;
    tableno = pTakeSafeDeposit->nTableNO;
    userid = pTakeSafeDeposit->nUserID;
    chairno = pTakeSafeDeposit->nChairNO;
    LPCTSTR hardid = LPCTSTR(pTakeSafeDeposit->szHardID);

    if (roomid <= 0 || tableno < 0 || userid <= 0 || chairno < 0 || gameid != m_nGameID
        || chairno >= MAX_CHAIR_COUNT)
    {
        return SendUserResponse(lpContext, &response);
    }

    if (!IsNeedDepositRoom(roomid))
    {
        response.head.nRequest = GR_NO_THIS_FUNCTION_EX;
        return SendUserResponse(lpContext, &response);
    }

    if (!IsTakeDepositRoom(roomid))
    {
        response.head.nRequest = GR_NO_THIS_FUNCTION_EX;
        return SendUserResponse(lpContext, &response);
    }

    //校验hardid reserved
    {
        DWORD dwCode = GetHardCode(userid);
        if (!dwCode)
        {
            response.head.nRequest = GR_HARDID_MISMATCH_EX;
            return SendUserResponse(lpContext, &response);
        }
        DWORD hardcode = 0;
        xygMakeHardID2Code(hardid, lstrlen(hardid), hardcode);
        if (hardcode != dwCode)
        {
            response.head.nRequest = GR_HARDID_MISMATCH_EX;
            return SendUserResponse(lpContext, &response);
        }
    }

    pTable = GetTablePtr(roomid, tableno);

    if (pTable)
    {
        LOCK_TABLE(pTable, chairno, FALSE, userid, token);
        CMyGameTable* gameTable = (CMyGameTable*)pTable;
        if (!pTable->IsPlayer(userid)) // 不是玩家
        {
            UwlLogFile(_T("user not player. user %ld take deposit failed."), userid);
            return SendUserResponse(lpContext, &response);
        }

        pPlayer = pTable->m_ptrPlayers[chairno];
        if (!pPlayer || pPlayer->m_nUserID != userid)
        {
            response.head.nRequest = UR_OPERATE_FAILED;
            return SendUserResponse(lpContext, &response);
        }

        if (IS_BIT_SET(pTable->m_dwStatus, TS_PLAYING_GAME))
        {
            if (pTakeSafeDeposit->nDeposit + pPlayer->m_nDeposit != gameTable->GetPlayingNeedDeposit() && gameTable->IsPlayerFitGiveUp(chairno))
            {
                response.head.nRequest = UR_OPERATE_FAILED;
                return SendUserResponse(lpContext, &response);
            }
        }
        else
        {
            if (IS_BIT_SET(pTable->m_dwUserStatus[chairno], US_GAME_STARTED))
            {
                response.head.nRequest = GR_SAFEBOX_GAME_READY;
                return SendUserResponse(lpContext, &response);
            }
        }

        //与玩家手中银子不等
        if (pPlayer->m_nDeposit != pTakeSafeDeposit->nGameDeposit)
        {
            response.head.nRequest = GR_SAFEBOX_DEPOSIT_DIFFER;
            //return SendUserResponse(lpContext, &response);
            UwlLogFile(_T("user %ld take mydeposit differ, server is %d, client is %d"), userid, pPlayer->m_nDeposit, pTakeSafeDeposit->nGameDeposit);
        }

        pTakeSafeDeposit->dwIPAddr = GetClientAddress(lpContext->hSocket, lpContext->lTokenID);
        gameTable->m_bShowGiveUp[chairno] = FALSE;

        CONTEXT_HEAD context;
        memcpy(&context, lpContext, sizeof(context));
        context.bNeedEcho = TRUE;

        REQUEST request;
        ZeroMemory(&request, sizeof(request));
        request.head.nRequest = lpRequest->head.nRequest == GR_MY_TAKE_SAFE_DEPOSIT ? GR_TAKE_SAFE_DEPOSIT : GR_TAKE_BACKDEPOSIT_INGAME;
        request.nDataLen = sizeof(TAKE_SAFE_DEPOSIT);
        request.pDataPtr = pTakeSafeDeposit;

        TransmitRequest(&context, &request);
    }

    return TRUE;
}

BOOL CMyGameServer::OnExchangeCards(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt)
{
    LOG_TRACE(_T("CMyGameServer::OnExchangeCards"));
    SAFETY_NET_REQUEST(lpRequest, EXCHANGE3CARDS, pExchangeCards);

    REQUEST response;
    memset(&response, 0, sizeof(response));

    SOCKET sock = INVALID_SOCKET;
    LONG token = 0;
    int roomid = 0;
    int tableno = INVALID_OBJECT_ID;
    int userid = 0;
    int chairno = INVALID_OBJECT_ID;
    int r_id = 0;
    int t_no = INVALID_OBJECT_ID;
    int u_id = 0;
    int c_no = INVALID_OBJECT_ID;

    CMyGameTable* pTable = NULL;
    CPlayer* pPlayer = NULL;

    sock = lpContext->hSocket;
    token = lpContext->lTokenID;

    roomid = pExchangeCards->nRoomID;
    tableno = pExchangeCards->nTableNO;
    userid = pExchangeCards->nUserID;
    chairno = pExchangeCards->nChairNO;

    CRoom* pRoom = NULL;
    if (!(pRoom = GetRoomPtr(roomid)))
    {
        return NotifyResponseFaild(lpContext);
    }


    pTable = GetTablePtr(roomid, tableno);
    if (pTable)
    {
        LOCK_TABLE(pTable, chairno, FALSE, userid, token);

        if (!pTable->IsPlayer(userid)) // 不是玩家
        {
            UwlLogFile(_T("user not player. user %ld auction banker failed."), userid);
            response.head.nRequest = UR_OPERATE_FAILED;
            return SendUserResponse(lpContext, &response);
        }
        if (!IS_BIT_SET(pTable->m_dwStatus, TS_PLAYING_GAME)) //游戏未开始，或结束
        {
            response.head.nRequest = UR_OPERATE_FAILED;
            return SendUserResponse(lpContext, &response);
        }

        UwlTrace(_T("chair %ld, user %ld exchange cards."), chairno, userid);
        if (!IS_BIT_SET(pTable->m_dwStatus, TS_WAITING_EXCHANGE3CARDS))
        {
            UwlLogFile(_T("status not waiting_exchange3cards. chair %ld exchange3cards failed."), chairno);
            response.head.nRequest = UR_OPERATE_FAILED;
            return SendUserResponse(lpContext, &response);
        }

        if (pTable->m_bExchangeCards[chairno])
        {
            UwlLogFile(_T("chair %ld, user %ld have exchange cards"), chairno, userid);
            response.head.nRequest = UR_OPERATE_FAILED;
            return SendUserResponse(lpContext, &response);
        }

        BOOL bn = pTable->OnExchangeCards(pExchangeCards);
        LOG_DEBUG(_T("***********ROBOT_BOUT_LOG_EXCHANGECARDS***********roomid:%d, tableno:%d, userid:%d, chairno:%d, cardids:%s, %s, %s"), pExchangeCards->nRoomID, pExchangeCards->nTableNO,
            pExchangeCards->nUserID, chairno, pTable->RobotBoutLog(pExchangeCards->nExchange3Cards[chairno][0]), pTable->RobotBoutLog(pExchangeCards->nExchange3Cards[chairno][1]),
            pTable->RobotBoutLog(pExchangeCards->nExchange3Cards[chairno][2]));

        response.head.nRequest = UR_OPERATE_SUCCEEDED;
        SendUserResponse(lpContext, &response);

        SYSTEMMSG msg;
        ZeroMemory(&msg, sizeof(SYSTEMMSG));
        msg.nMsgID = SYSMSG_PLAYER_EXCHANGE3CARDS;
        msg.nChairNO = chairno;
        msg.nMJID = pExchangeCards->nExchange3Cards[0][0];
        msg.nEventID = pExchangeCards->nExchange3Cards[0][1];
        msg.nFangCardChairNO = pExchangeCards->nExchange3Cards[0][2];
        NotifySystemMSG(pTable, &msg, -1);

        if (bn)
        {
            EXCHANGE3CARDS exchangefinished;
            ZeroMemory(&exchangefinished, sizeof(exchangefinished));
            memcpy(&exchangefinished, pExchangeCards, sizeof(EXCHANGE3CARDS));
            memcpy(exchangefinished.nExchange3Cards, pTable->m_nExchangeCards, sizeof(exchangefinished.nExchange3Cards));
            NotifyTablePlayers(pTable, GR_EXCHANGE3CARDS_FINISHED, &exchangefinished, sizeof(exchangefinished));
            NotifyTableVisitors(pTable, GR_EXCHANGE3CARDS_FINISHED, &exchangefinished, sizeof(exchangefinished));
            pTable->m_dwDingQueStartTime = GetTickCount();

            for (int j = 0; j < TOTAL_CHAIRS; j++)
            {
                if (pTable->IsRoboter(j))
                {
                    OnRobotStartExchangeOrFixmiss(pRoom, pTable);
                    break;
                }
            }
            CreateRobotTimer(pRoom, pTable, pTable->m_dwStatus, pTable->m_nDingQueWait * 1000 + 5000);
        }
    }
    return TRUE;
}

BOOL CMyGameServer::NotifySystemMSG(CMyGameTable* pTable, LPSYSTEMMSG pMsg, int chairno)
{
    SYSTEMMSG msg;
    ZeroMemory(&msg, sizeof(msg));
    memcpy(&msg, pMsg, sizeof(SYSTEMMSG));

    if (chairno == -1)
    {
        NotifyTablePlayers(pTable, GR_SYSTEMMSG, &msg, sizeof(msg));
        NotifyTableVisitors(pTable, GR_SYSTEMMSG, &msg, sizeof(msg));
    }
    else
    {
        CPlayer* pPlayer = pTable->m_ptrPlayers[chairno];
        if (pPlayer)
        {
            NotifyOneUser(pPlayer->m_hSocket, pPlayer->m_lTokenID, GR_SYSTEMMSG, &msg, sizeof(msg));
        }
    }

    return TRUE;
}

BOOL CMyGameServer::OnPlayerRecharge(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt)
{
    LOG_TRACE(_T("CMyGameServer::OnExchangeCards"));
    SAFETY_NET_REQUEST(lpRequest, PLAYER_RECHARGE, pPlayerRecharge);

    REQUEST response;
    memset(&response, 0, sizeof(response));

    LONG token = 0;
    int roomid = 0;
    int tableno = INVALID_OBJECT_ID;
    int userid = 0;
    int chairno = INVALID_OBJECT_ID;
    int r_id = 0;
    int t_no = INVALID_OBJECT_ID;
    int u_id = 0;
    int c_no = INVALID_OBJECT_ID;
    BOOL lookon = FALSE;
    BOOL timeout = FALSE;

    CMyGameTable* pTable = NULL;
    CPlayer* pPlayer = NULL;

    token = lpContext->lTokenID;
    roomid = pPlayerRecharge->nRoomID;
    tableno = pPlayerRecharge->nTableNO;
    userid = pPlayerRecharge->nUserID;
    chairno = pPlayerRecharge->nChairNO;

    pTable = GetTablePtr(roomid, tableno);
    if (pTable)
    {
        LOCK_TABLE(pTable, chairno, FALSE, userid, token);

        if (!pTable->IsPlayer(userid)) // 不是玩家
        {
            UwlLogFile(_T("user not player. user %ld giveup game failed."), userid);
            return TRUE;
        }
        if (!IS_BIT_SET(pTable->m_dwStatus, TS_PLAYING_GAME)) // 不是正在进行状态
        {
            return TRUE;
        }
        if (!IS_BIT_SET(pTable->m_dwStatus, TS_WAITING_GIVEUP)) // 不是等待放弃状态
        {
            return TRUE;
        }

        pTable->OnPlayeRecharge(chairno);

        PLAYER_RECHARGE PlayerRecharge;
        ZeroMemory(&PlayerRecharge, sizeof(PLAYER_RECHARGE));
        memcpy(&PlayerRecharge, pPlayerRecharge, sizeof(PLAYER_RECHARGE));
        PlayerRecharge.nDelayTime = pTable->m_nRechargeTime;

        NotifyTablePlayers(pTable, GR_PLAYER_RECHARGE, &PlayerRecharge, sizeof(PLAYER_RECHARGE), 0);
        NotifyTableVisitors(pTable, GR_PLAYER_RECHARGE, &PlayerRecharge, sizeof(PLAYER_RECHARGE), 0);
    }

    return TRUE;
}

BOOL CMyGameServer::OnPlayerRechargeOK(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt)
{
    LOG_TRACE(_T("CMyGameServer::OnPlayerRechargeOK"));
    SAFETY_NET_REQUEST(lpRequest, PLAYER_RECHARGE, pPlayerRecharge);

    REQUEST response;
    memset(&response, 0, sizeof(response));

    LONG token = 0;
    int roomid = 0;
    int tableno = INVALID_OBJECT_ID;
    int userid = 0;
    int chairno = INVALID_OBJECT_ID;

    CMyGameTable* pTable = NULL;

    token = lpContext->lTokenID;

    roomid = pPlayerRecharge->nRoomID;
    tableno = pPlayerRecharge->nTableNO;
    userid = pPlayerRecharge->nUserID;
    chairno = pPlayerRecharge->nChairNO;

    pTable = GetTablePtr(roomid, tableno);
    if (pTable)
    {
        LOCK_TABLE(pTable, chairno, FALSE, userid, token);

        if (!pTable->IsPlayer(userid))  // 不是玩家
        {
            UwlLogFile(_T("user not player. user %ld giveup game failed."), userid);
            return TRUE;
        }

        CPlayer* pPlayer = pTable->m_ptrPlayers[chairno];
        if (pPlayer)
        {
            SOLO_PLAYER sp = { 0 };
            if (LookupSoloPlayer(pPlayer->m_nUserID, sp))
            {
                //充值成功后3局
                sp.nReserved3[2] = 3;
                SetSoloPlayer(pPlayer->m_nUserID, sp);
            }
        }
    }

    return TRUE;
}

//  获取低保次数 start
void CMyGameServer::NotifyServiceFee(CTable* pTable)
{
    CMyGameTable* gameTable = (CMyGameTable*)pTable;
    TCHAR szRoomID[16];
    memset(szRoomID, 0, sizeof(szRoomID));
    _stprintf_s(szRoomID, _T("%ld"), pTable->m_nRoomID);

    int nNotifyFee = GetPrivateProfileInt(
            _T("feenotify"),    // section name
            szRoomID,           // key name
            0,                  // default int
            m_szIniFile         // initialization file name
        );

    if (gameTable->IsUseCustomFeeMode()
        || (FEE_MODE_SERVICE_FIXED == pTable->m_nFeeMode
            || FEE_MODE_SERVICE_MINDEPOSIT == pTable->m_nFeeMode
            || FEE_MODE_SERVICE_SELFDEPOSIT == pTable->m_nFeeMode))
    {
        GAME_WIN gameWin;
        memset(&gameWin, 0, sizeof(GAME_WIN));
        if (gameTable->IsUseCustomFeeMode())
        {
            gameTable->CalcCustomFees(gameWin.nWinFees);
        }
        else
        {
            pTable->FillupOldScoreDeposit(&gameWin, sizeof(GAME_WIN));
            int nOldDeposits[MAX_CHAIRS_PER_TABLE];                     // 旧银子
            memset(nOldDeposits, 0, sizeof(nOldDeposits));
            pTable->CalcWinFeesEx(gameWin.nOldDeposits, nOldDeposits, gameWin.nDepositDiffs, gameWin.nWinFees);
        }
        memcpy(gameTable->m_nRoomFees, gameWin.nWinFees, sizeof(int)*TOTAL_CHAIRS);

        if (nNotifyFee)
        {
            CHAT_FROM_TABLE cft;
            memset(&cft, 0, sizeof(cft));
            cft.nRoomID = pTable->m_nRoomID;
            for (int i = 0; i < pTable->m_nTotalChairs; i++)
            {
                CPlayer* ptrP = pTable->m_ptrPlayers[i];
                if (ptrP && !ptrP->m_bIdlePlayer && gameWin.nWinFees[i] > 0) //移动端发通知
                {
                    cft.nUserID = ptrP->m_nUserID;
                    sprintf_s(cft.szChatMsg, _T("%s 本局游戏将收取%d两服务费。\r\n"), GetChatTags(FLAG_CHAT_SERVICEFEE), gameWin.nWinFees[i]);
                    cft.nMsgLen = lstrlen(cft.szChatMsg) + 1;
                    cft.dwFlags = FLAG_CHAT_SYSNOTIFY;
                    int nSendLen = sizeof(CHAT_FROM_TABLE) - sizeof(cft.szChatMsg) + cft.nMsgLen;
                    NotifyOneUser(ptrP->m_hSocket, ptrP->m_lTokenID, GR_CHAT_FROM_TALBE, &cft, nSendLen);
                }
            }
        }
    }

    CONTEXT_HEAD context;
    memset(&context, 0, sizeof(context));
    context.bNeedEcho = FALSE;
    PreSaveResult(&context, gameTable, gameTable->m_nRoomID, ResultByFee);
}

BOOL CMyGameServer::CanChangeTableInGame(int roomid, CPlayer* pPlayer)
{
    // xzmo 新增
    return IsVariableChairRoom(roomid) && pPlayer && pPlayer->m_bIdlePlayer;
    // end
}

BOOL CMyGameServer::MoveUserToChair(int nUserID, int tableno, int chairno, SOLO_PLAYER* pSoloPlayer)
{
    USER_DATA user_data_;
    memset(&user_data_, 0, sizeof(user_data_));

    if (!UpdateUserData(nUserID, [&](USER_DATA & user_data, BOOL bCreate)
{
    user_data.nLastConnect = 0; //分桌重置，否则会被判定为一次断线。
    user_data_ = user_data;
}, FALSE))
    {
        return FALSE;
    }


    int roomid = user_data_.nRoomID;

    CTable* pTable = NULL;
    CPlayer* pPlayer = NULL;
    if (!(pTable = GetTablePtr(roomid, user_data_.nTableNO)))
    {
        return FALSE;
    }

    DWORD dwUserStatus = 0;
    DWORD dwUserConfig = 0;
    DWORD dwRoomOption = 0;
    DWORD dwRoomConfig = 0;

    //离开旧桌子
    if (pTable)
    {
        CAutoLock lock(&(pTable->m_csTable));
        (void)pTable->m_mapUser.Lookup(nUserID, pPlayer);

        if (!pPlayer || !pPlayer->m_nUserID)
        {
            return FALSE;
        }

        int nOldChair = pPlayer->m_nChairNO;

        GAME_ABORT GameAbort;
        ZeroMemory(&GameAbort, sizeof(GameAbort));

        GameAbort.nChairNO = nOldChair;
        GameAbort.nTableNO = pTable->m_nTableNO;
        GameAbort.nUserID = pPlayer->m_nUserID;
        GameAbort.bForce = FALSE;

        dwUserStatus = pTable->m_dwUserStatus[nOldChair];
        dwUserConfig = pTable->m_dwUserConfig[nOldChair];
        dwRoomOption = pTable->m_dwRoomOption[nOldChair];
        dwRoomConfig = pTable->m_dwRoomConfig[nOldChair];

        //Modify on 20130304
        //先通知，再移除player，确保旁观被通知到
        if (!IsCloakingRoom(roomid))
        {
            // xzmo 新增
            if (IS_BIT_SET(pTable->m_dwStatus, TS_PLAYING_GAME) && ((CMyGameTable*)pTable)->m_stAbortPlayerInfo[GameAbort.nChairNO].nUserID <= 0)
            {
                SOLO_PLAYER soloPlayer;
                memset(&soloPlayer, 0, sizeof(SOLO_PLAYER));
                LookupSoloPlayer(pPlayer->m_nUserID, soloPlayer);

                soloPlayer.nDeposit = GameAbort.nOldDeposit;
                ((CMyGameTable*)pTable)->saveAbortPlayerInfo(soloPlayer);
            }
            // end
            (void)NotifyTablePlayers(pTable, GR_PLAYER_ABORT, &GameAbort, sizeof(GameAbort));
        }

        (void)NotifyTableVisitors(pTable, GR_PLAYER_ABORT, &GameAbort, sizeof(GameAbort));

        (void)pTable->PlayerLeave(nUserID, FALSE);
        //pTable->ResetTable();
        if (NeedResetTblWhileChangeTbl(roomid, pPlayer))
        {
            pTable->ResetTable();
        }
        //Modify end
    }

    pTable = NULL;

    //加入新桌子
    pTable = GetTablePtr(roomid, tableno, TRUE, m_nScoreMult);

    //加入新桌子
    if (pTable)
    {
        CAutoLock lock(&(pTable->m_csTable));
        if (pTable->m_ptrPlayers[chairno])//已经有人
        {
            UwlLogFile("Move User To Chair Failed,m_ptrPlayers is not NULL,roomid:%ld,tableno:%ld,chairno:%ld,userid:%ld,", roomid, tableno, chairno, nUserID);
            return FALSE;
        }

        //拷贝用户数据，与checksvr一致
        ///////////////////////////////////////////////
        pSoloPlayer->nScore = pPlayer->m_nScore;
        pSoloPlayer->nDeposit = pPlayer->m_nDeposit;
        pSoloPlayer->nBout = pPlayer->m_nBout;
        pSoloPlayer->nPlayerLevel = pPlayer->m_nLevelID;
        //////////////////////////////////////////////

        pPlayer->m_nChairNO = chairno;
        pTable->m_mapUser.SetAt(nUserID, pPlayer);
        pTable->m_ptrPlayers[chairno] = pPlayer;

        pTable->m_dwUserStatus[chairno] = dwUserStatus;
        pTable->m_dwUserConfig[chairno] = dwUserConfig;
        pTable->m_dwRoomOption[chairno] = dwRoomOption;
        pTable->m_dwRoomConfig[chairno] = dwRoomConfig;

        //add on 20150907
        //换桌后立刻修改玩家状态..这里有锁保护..外面不一定有锁
        pTable->m_dwUserStatus[chairno] &= ~US_GAME_STARTED;

        if (IsVariableChairRoom(roomid) && IS_BIT_SET(pTable->m_dwStatus, TS_PLAYING_GAME))
        {
            pPlayer->m_bIdlePlayer = TRUE;//可变桌椅，本局已经开始，那么是空闲玩家
        }

        SetEnterParams(nUserID, roomid, tableno, chairno);
        //2012.11.10,重新分桌后强制设置RoomTableChair
        DWORD dwRoomTableChair = MakeRoomTableChair(roomid, tableno, chairno);
        SetUserID(dwRoomTableChair, nUserID);

        {
            CAutoLock lock2(&m_csTokenData);
            m_mapTokenRoom.SetAt(pPlayer->m_lTokenID, roomid);
            m_mapTokenTable.SetAt(pPlayer->m_lTokenID, tableno);
            m_mapTokenPlayer.SetAt(pPlayer->m_lTokenID, nUserID);
        }

        //Add on 20130506
        //换位置时，更新m_mapSoloPlayer
        if (IS_BIT_SET(GetRoomConfig(roomid), RC_SOLO_ROOM))
        {
            pSoloPlayer->nTableNO = tableno;
            pSoloPlayer->nChairNO = chairno;
            SetSoloPlayer(nUserID, *pSoloPlayer);
        }
        //Add end

        return TRUE;
    }
    return FALSE;
}
BOOL CMyGameServer::OnCurrencyExchange(LPREQUEST lpRequest)
{
    if (!lpRequest || !lpRequest->pDataPtr)
    {
        return FALSE;
    }

    if (lpRequest->nDataLen != sizeof(CURRENCY_EXCHANGE_EX))
    {
        return FALSE;
    }

    LPCURRENCY_EXCHANGE_EX lpExchange = LPCURRENCY_EXCHANGE_EX(lpRequest->pDataPtr);

    LOG_TRACE(_T("Receive OnCurrencyExchange, 玩家%d 领取了奖励，余额 %d "), lpExchange->currencyExchange.nUserID, lpExchange->currencyExchange.llBalance);

    USER_DATA user_data;
    memset(&user_data, 0, sizeof(user_data));
    if (!LookupUserData(lpExchange->currencyExchange.nUserID, user_data))
    {
        return FALSE;
    }

    int roomid = lpExchange->nEnterRoomID;
    int tableno = user_data.nTableNO;
    int chairno = user_data.nChairNO;
    int userid = lpExchange->currencyExchange.nUserID;
    if (!BaseVerify(roomid, tableno, chairno, userid))
    {
        return FALSE;
    }

    CTable*  pTable = NULL;
    CPlayer* pPlayer = NULL;

    pTable = GetTablePtr(roomid, tableno);
    if (!pTable)
    {
        return FALSE;
    }

    {
        CAutoLock lock(&(pTable->m_csTable));
        if (pTable->IsPlayer(userid))
        {
            pPlayer = pTable->m_ptrPlayers[chairno];
            if (!pPlayer || pPlayer->m_nUserID != userid)
            {
                return FALSE;
            }
        }
        else if (pTable->IsVisitor(userid))
        {
            if (!pTable->m_mapVisitors[chairno].Lookup(userid, pPlayer)
                || !pPlayer || pPlayer->m_nUserID != userid)
            {
                return FALSE;
            }
        }
        else
        {
            return FALSE;
        }

        SOLO_PLAYER sp;
        ZeroMemory(&sp, sizeof(sp));

        USER_CURRENCY_EXCHANGE ude;
        memset(&ude, 0, sizeof(ude));
        memcpy(&ude.stExchangeMsg, lpExchange, sizeof(CURRENCY_EXCHANGE_EX));
        ude.nChairNO = chairno;
        BOOL bExchangeToGame = (TCY_CURRENCY_CONTAINER_GAME == lpExchange->currencyExchange.nContainer);// 交易到游戏
        BOOL bExchangeForDeposit = (TCY_CURRENCY_DEPOSIT == lpExchange->currencyExchange.nCurrency); // 交易成银子
        BOOL bExchangeForScore = (TCY_CURRENCY_SCORE == lpExchange->currencyExchange.nCurrency);   // 交易成积分

        if (bExchangeToGame && lpExchange->currencyExchange.nExchangeGameID == m_nGameID) // 交易到游戏
        {
            if (bExchangeForDeposit) // for 银子
            {
                // xzmo 新增
                //补银成功后修改状态
                OnGetDepositOK(pTable, chairno);

                int oldDeposit = pPlayer->m_nDeposit;
                pPlayer->SetScoreDeposit(pPlayer->m_nScore, lpExchange->currencyExchange.llBalance);

                // 银两变化 埋点
                if (GetPrivateProfileInt(_T("DepositChangeDury"), _T("Enable"), 1, GetINIFileName()))
                {
                    CString strDepositeChange;
                    strDepositeChange = "OnCurrencyExchange\n";
                    strDepositeChange.Format(strDepositeChange + _T("uid[%d],oldDeposite[%d],changeDeposite[%d],"), pPlayer->m_nUserID, oldDeposit, pPlayer->m_nDeposit - oldDeposit);
                    LOG_INFO(strDepositeChange);
                }

                for (int i = 0; i < pTable->m_nTotalChairs; i++)
                {
                    CPlayer* ptrP = pTable->m_ptrPlayers[i];
                    if (ptrP && ptrP->m_lTokenID != 0)
                    {
                        if (IS_BIT_SET(ptrP->m_nUserType, UT_HANDPHONE))
                        {
                            //这里转个简单的结构
                            USER_DEPOSITEVENT udet;
                            memset(&udet, 0, sizeof(udet));
                            udet.nUserID = pPlayer->m_nUserID;
                            udet.nChairNO = pPlayer->m_nChairNO;
                            udet.nDepositDiff = pPlayer->m_nDeposit - oldDeposit;
                            udet.nDeposit = pPlayer->m_nDeposit;
                            NotifyOneUser(ptrP->m_hSocket, ptrP->m_lTokenID, GR_USER_CURRENCY_CONTAINER, &udet, sizeof(udet), FALSE);
                        }
                        else
                        {
                            NotifyOneUser(ptrP->m_hSocket, ptrP->m_lTokenID, GR_USER_CURRENCY_CONTAINER, &ude, sizeof(ude), FALSE);
                        }
                    }
                }
                // end
                //旁观都是PC端
                NotifyTableVisitors(pTable, GR_USER_CURRENCY_CONTAINER, &ude, sizeof(ude), 0);


                pTable->RecordPlayerOnCurrencyChange(false, chairno);
                //更新soloplayer
                if (LookupSoloPlayer(userid, sp))
                {
                    sp.nDeposit = lpExchange->currencyExchange.llBalance;
                    SetSoloPlayer(userid, sp);
                }
            }
            else if (bExchangeForScore) // for 积分
            {
                pPlayer->SetScoreDeposit(lpExchange->currencyExchange.llBalance, pPlayer->m_nDeposit);
                NotifyTablePlayers(pTable, GR_USER_CURRENCY_CONTAINER, &ude, sizeof(ude), 0);
                NotifyTableVisitors(pTable, GR_USER_CURRENCY_CONTAINER, &ude, sizeof(ude), 0);
                pTable->RecordPlayerOnCurrencyChange(false, chairno);
                //更新soloplayer
                if (LookupSoloPlayer(userid, sp))
                {
                    sp.nScore = lpExchange->currencyExchange.llBalance;
                    SetSoloPlayer(userid, sp);
                }
            }
            else
            {
                //直接发给前端
                NotifyOneUser(pPlayer->m_hSocket, pPlayer->m_lTokenID, GR_USER_CURRENCY_CONTAINER, &ude, sizeof(ude));
            }
        }
        else // 保险箱 或者 后备箱
        {
            //直接发给前端
            NotifyOneUser(pPlayer->m_hSocket, pPlayer->m_lTokenID, GR_USER_CURRENCY_CONTAINER, &ude, sizeof(ude));
        }
    }
    return TRUE;
}

BOOL CMyGameServer::OnPayResultToGame(LPREQUEST lpRequest)
{
    if (!lpRequest || !lpRequest->pDataPtr)
    {
        return FALSE;
    }

    if (lpRequest->nDataLen != sizeof(PAY_RESULT))
    {
        return FALSE;
    }

    LPPAY_RESULT lpPay = LPPAY_RESULT(lpRequest->pDataPtr);

    UwlLogFile(_T("Receive OnPayResultToGame, 玩家%d 充值，余额 %d "), lpPay->nUserID, lpPay->llBalance);

    USER_DATA user_data;
    memset(&user_data, 0, sizeof(user_data));
    if (!LookupUserData(lpPay->nUserID, user_data))
    {
        return FALSE;
    }

    int roomid = lpPay->nRoomID;
    int tableno = user_data.nTableNO;
    int chairno = user_data.nChairNO;
    int userid = lpPay->nUserID;
    if (!BaseVerify(roomid, tableno, chairno, userid))
    {
        return FALSE;
    }

    CTable*  pTable = NULL;
    CPlayer* pPlayer = NULL;

    pTable = GetTablePtr(roomid, tableno);

    if (!pTable)
    {
        return FALSE;
    }

    {
        CAutoLock lock(&(pTable->m_csTable));
        if (pTable->IsPlayer(userid))
        {
            pPlayer = pTable->m_ptrPlayers[chairno];
            if (!pPlayer || pPlayer->m_nUserID != userid)
            {
                return FALSE;
            }
        }
        else if (pTable->IsVisitor(userid))
        {
            if (!pTable->m_mapVisitors[chairno].Lookup(userid, pPlayer)
                || !pPlayer || pPlayer->m_nUserID != userid)
            {
                return FALSE;
            }
        }
        else
        {
            return FALSE;
        }

        SOLO_PLAYER sp;
        ZeroMemory(&sp, sizeof(sp));

        USER_PAYTOGAMEEVENT ude;
        memset(&ude, 0, sizeof(ude));
        memcpy(&ude.stPayMsg, lpPay, sizeof(PAY_RESULT));
        ude.nChairNO = chairno;

        if (PAY_TO_GAME == lpPay->nPayTo && lpPay->nGameID == m_nGameID) // 充值到游戏
        {
            if (PAY_FOR_DEPOSIT == lpPay->nPayFor) // for 银子
            {
                // xzmo 新增
                //补银成功后修改状态
                OnGetDepositOK(pTable, chairno);

                int oldDeposit = pPlayer->m_nDeposit;
                pPlayer->SetScoreDeposit(pPlayer->m_nScore, lpPay->llBalance);

                // 银两变化 埋点
                if (GetPrivateProfileInt(_T("DepositChangeDury"), _T("Enable"), 1, GetINIFileName()))
                {
                    CString strDepositeChange;
                    strDepositeChange = "OnCurrencyExchange\n";
                    strDepositeChange.Format(strDepositeChange + _T("uid[%d],oldDeposite[%d],changeDeposite[%d],"), pPlayer->m_nUserID, oldDeposit, pPlayer->m_nDeposit - oldDeposit);
                    LOG_INFO(strDepositeChange);
                }

                for (int i = 0; i < pTable->m_nTotalChairs; i++)
                {
                    CPlayer* ptrP = pTable->m_ptrPlayers[i];
                    if (ptrP && ptrP->m_lTokenID != 0)
                    {
                        if (IS_BIT_SET(ptrP->m_nUserType, UT_HANDPHONE))
                        {
                            //这里转个简单的结构
                            USER_DEPOSITEVENT udet;
                            memset(&udet, 0, sizeof(udet));
                            udet.nUserID = pPlayer->m_nUserID;
                            udet.nChairNO = pPlayer->m_nChairNO;
                            udet.nDepositDiff = pPlayer->m_nDeposit - oldDeposit;
                            udet.nDeposit = pPlayer->m_nDeposit;
                            NotifyOneUser(ptrP->m_hSocket, ptrP->m_lTokenID, GR_USER_PAYTOGAME_EVENT, &udet, sizeof(udet), FALSE);
                        }
                        else
                        {
                            NotifyOneUser(ptrP->m_hSocket, ptrP->m_lTokenID, GR_USER_PAYTOGAME_EVENT, &ude, sizeof(ude), FALSE);
                        }
                    }
                }
                // end
                //旁观都是PC端
                NotifyTableVisitors(pTable, GR_USER_PAYTOGAME_EVENT, &ude, sizeof(ude), 0);

                pTable->RecordPlayerOnCurrencyChange(false, chairno);
                //更新soloplayer
                if (LookupSoloPlayer(userid, sp))
                {
                    sp.nDeposit = lpPay->llBalance;
                    SetSoloPlayer(userid, sp);
                }
            }
            else if (PAY_FOR_SCORE == lpPay->nPayFor) // for 积分
            {
                pPlayer->SetScoreDeposit(lpPay->llBalance, pPlayer->m_nDeposit);
                NotifyTablePlayers(pTable, GR_USER_PAYTOGAME_EVENT, &ude, sizeof(ude), 0);
                NotifyTableVisitors(pTable, GR_USER_PAYTOGAME_EVENT, &ude, sizeof(ude), 0);
                pTable->RecordPlayerOnCurrencyChange(false, chairno);
                //更新soloplayer
                if (LookupSoloPlayer(userid, sp))
                {
                    sp.nScore = lpPay->llBalance;
                    SetSoloPlayer(userid, sp);
                }
            }
            else
            {
                //直接发给前端
                NotifyOneUser(pPlayer->m_hSocket, pPlayer->m_lTokenID, GR_USER_PAYTOGAME_EVENT, &ude, sizeof(ude));
            }
        }
        else // 保险箱 或者 后备箱
        {
            //直接发给前端
            NotifyOneUser(pPlayer->m_hSocket, pPlayer->m_lTokenID, GR_USER_PAYTOGAME_EVENT, &ude, sizeof(ude));
        }
        xygPayResultLog(_T("PayResult- 游戏ID[%d],充值到[%d],充值类型[%d],操作数量[%d],余额[%d]"),
            lpPay->nGameID, lpPay->nPayTo, lpPay->nPayFor, lpPay->nOperateAmount, lpPay->llBalance);
    }

    return TRUE;
}

BOOL CMyGameServer::OnGameUnableContinue(CTable* pTable, LPCTSTR szCause)
{
    RemoveClients(pTable, 0, FALSE);

    /*GAME_UNABLE_TO_CONTINUE unableContinue;
    ZeroMemory(&unableContinue, sizeof(unableContinue));

    strcpy(unableContinue.szCause,szCause);
    unableContinue.nMsgLen=sizeof(GAME_UNABLE_TO_CONTINUE)-MAX_SYSMSG_LEN+strlen(szCause)+1;*/
    // xzmo 新增
    int nLen = lstrlen(szCause) + 1;
    PBYTE pData = new BYTE[nLen];
    memcpy(pData, szCause, nLen - 1);
    pData[nLen - 1] = '\0';
    // end
    NotifyTablePlayers(pTable, GR_GAME_UNABLE_TO_CONTINUE, pData, nLen);
    NotifyTableVisitors(pTable, GR_GAME_UNABLE_TO_CONTINUE, pData, nLen);
    SAFE_DELETE_ARRAY(pData);

    pTable->Reset(); // 清空桌子
    PostGameBoutEnd(pTable->m_nRoomID, pTable->m_nTableNO, pTable);

    return TRUE;
}

BOOL CMyGameServer::OnPlayerGoSeniorRoom(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt)
{
    LOG_TRACE(_T("CMyGameServer::OnPlayerGoSeniorRoom"));
    SAFETY_NET_REQUEST(lpRequest, PLAYER_GO_SENIOR, pPlayerShowSenior);

    REQUEST response;
    memset(&response, 0, sizeof(response));

    LONG token = 0;
    int roomid = 0;
    int seniorid = 0;
    int tableno = INVALID_OBJECT_ID;
    int userid = 0;
    int chairno = INVALID_OBJECT_ID;
    BOOL showSenior = FALSE;
    CString strSerialNO;
    CMyGameTable* pTable = NULL;

    token = lpContext->lTokenID;
    roomid = pPlayerShowSenior->nRoomID;
    tableno = pPlayerShowSenior->nTableNO;
    userid = pPlayerShowSenior->nUserID;
    chairno = pPlayerShowSenior->nChairNO;
    seniorid = pPlayerShowSenior->nSeniorID;
    showSenior = pPlayerShowSenior->bShowSenior;
    strSerialNO = pPlayerShowSenior->szSerialNO;

    pTable = GetTablePtr(roomid, tableno);
    if (pTable)
    {
        LOCK_TABLE(pTable, chairno, FALSE, userid, token);

        if (!pTable->IsPlayer(userid))  // 不是玩家
        {
            UwlLogFile(_T("user not player. user %ld show senior failed."), userid);
            return FALSE;
        }

        /*if (strSerialNO.IsEmpty())
        {
        UwlLogFile(_T("show senior failed. serialno is empty."));
        return FALSE;
        }

        {
        CAutoLock lock(&m_csPlayRecord);
        vector<LPPLAYRECORD>::iterator iter = m_vecPlayRecord.begin();
        for (; iter != m_vecPlayRecord.end(); iter++)
        {
        LPPLAYRECORD pTempRecord = (LPPLAYRECORD)*iter;
        if (NULL == pTempRecord)
        {
        UwlLogFile(_T("show senior failed. pTempRecord is NULL."));
        continue;
        }

        if (0 == strSerialNO.CompareNoCase(pTempRecord->strSerialNO))
        {
        if (seniorid != 0)
        pTempRecord->role[chairno].goSeniorTime = CTime::GetCurrentTime();
        else
        {
        if (showSenior)
        pTempRecord->role[chairno].goSeniorTime = CTime(2018, 11, 11, 11, 11, 11);
        else
        pTempRecord->role[chairno].goSeniorTime = CTime(2018, 11, 11, 0, 0, 0);
        }
        break;
        }
        }
        }*/

        CPlayer* pPlayer = pTable->m_ptrPlayers[chairno];
        if (pPlayer && seniorid != 0)
        {
            SOLO_PLAYER sp = { 0 };
            if (LookupSoloPlayer(pPlayer->m_nUserID, sp))
            {
                //跳转房间后2局
                sp.nReserved3[1] = 2;
                SetSoloPlayer(pPlayer->m_nUserID, sp);
            }
        }
    }

    return TRUE;
}
//  获取低保次数 start
BOOL CMyGameServer::OnGetWelfarePersent(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt)
{
    LOG_TRACE(_T("CMyGameServer::OnGetWelfarePersent"));
    SAFETY_NET_REQUEST(lpRequest, GET_WELFAREPRESENT, lpGetWfPresent);

    //dwSoapFlags==0，表示该请求是客户端发上来的
    if (0 == lpGetWfPresent->dwSoapFlags)
    {
        REQUEST response;
        memset(&response, 0, sizeof(response));
        response.head.nRequest = UR_OPERATE_FAILED;

        LONG token = 0;
        int roomid = 0;
        int tableno = INVALID_OBJECT_ID;
        int userid = 0;
        int chairno = INVALID_OBJECT_ID;
        LONG room_tokenid = 0;
        CPlayer* pPlayer = NULL;

        roomid = lpGetWfPresent->nRoomID;
        tableno = lpGetWfPresent->nTableNO;
        userid = lpGetWfPresent->nUserID;
        chairno = lpGetWfPresent->nChairNO;

        if (!BaseVerify(roomid, tableno, chairno, userid))
        {
            return SendFailedResponse(lpContext);
        }

        //活动关闭
        if (!IsBaseWelfareActive())
        {
            return SendFailedResponse(lpContext);
        }

        //移动端玩家IP，游戏程序员需要在代理服务器处获取
        if (!IS_BIT_SET(lpGetWfPresent->dwFlags, FLAG_REQFROM_HANDPHONE))
        {
            lpGetWfPresent->dwIPAddr = GetClientAddress(lpContext->hSocket, lpContext->lTokenID);
        }

        //发送到soap线程，调用WebService
        UINT uiThrdID = GetThreadIDBySoapFlag(SOAP_FLAG_BASEWELFARE);
        if (uiThrdID > 0)
        {
            return PostSoapRequest(uiThrdID, lpContext, lpRequest);
        }

        return SendUserResponse(lpContext, &response);
    }
    else if (SOAP_FLAG_DEFAULTEX == lpGetWfPresent->dwSoapFlags)
    {
        //运行到此处则是服务端返回调用
        return OnGetWelfarePresentOK(lpContext, lpRequest, pThreadCxt);
    }

    return FALSE;
}

BOOL CMyGameServer::OnGetWelfarePresentOK(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt)
{
    LOG_TRACE(_T("CMyGameServer::OnGetWelfarePresentOK"));
    SAFETY_NET_REQUEST(lpRequest, GET_WELFAREPRESENT, lpGetWfPresent);
    LONG token = 0;
    int roomid = 0;
    int tableno = INVALID_OBJECT_ID;
    int userid = 0;
    int chairno = INVALID_OBJECT_ID;
    LONG room_tokenid = 0;
    CPlayer* pPlayer = NULL;

    token = lpContext->lTokenID;

    if (0 == strlen(lpGetWfPresent->szSoapReturn))
    {
        return SendErrorInfoResponse(lpContext, _T("获取低保剩余次数失败"));
    }
    else
    {
        GET_WELFARE_PRESENT_OK gwfPresent;
        REQUEST response;
        memset(&response, 0, sizeof(response));
        response.head.nRequest = UR_OPERATE_SUCCEEDED;

        string strValue(lpGetWfPresent->szSoapReturn);
        Json::Reader reader;
        Json::Value obj;
        if (!reader.parse(strValue, obj))
        {
            return SendErrorInfoResponse(lpContext, _T("解析低保剩余次数失败"));
        }

        gwfPresent.nCount = obj["Data"].asInt();
        gwfPresent.nActivityID = lpGetWfPresent->nActivityID;
        gwfPresent.nUserID = lpGetWfPresent->nUserID;

        response.pDataPtr = &gwfPresent;
        response.nDataLen = sizeof(gwfPresent);
        UwlTrace(_T("User(%d) present (%d) counts to get Welfare!"), gwfPresent.nUserID, gwfPresent.nCount);
        return SendUserResponse(lpContext, &response);
    }

    SendFailedResponse(lpContext);
    return FALSE;
}

void CMyGameServer::CheckGiveUp(CMyGameTable* pTable, int chairno /*= INVALID_OBJECT_ID*/)
{
    int nGiveUpCount = 0;
    for (int i = 0; i < pTable->m_nTotalChairs; ++i)
    {
        if (pTable->IsPlayerFitGiveUp(i))
        {
            if (pTable->m_nGiveUpChair[i] == INVALID_OBJECT_ID)
            {
                nGiveUpCount++;
                pTable->m_nGiveUpChair[i] = i;
                pTable->m_bShowGiveUp[i] = TRUE;
            }
        }
        else
        {
            pTable->m_nGiveUpChair[i] = INVALID_OBJECT_ID;
            pTable->m_bShowGiveUp[i] = FALSE;
        }
    }

    if (pTable->ValidateChair(chairno)) //断线续完
    {
        if (!pTable->IsAllPlayerGiveUp()) //有人充值中，包括自己
        {
            GIVEUP_INFO stGiveUpInfo;
            ZeroMemory(&stGiveUpInfo, sizeof(stGiveUpInfo));
            stGiveUpInfo.nNeedDeposit = pTable->GetPlayingNeedDeposit();
            int nWaitTime = pTable->m_bPlayerRecharge ? pTable->m_nRechargeTime : pTable->m_nGiveUpTime;
            stGiveUpInfo.nLastSecond = nWaitTime - ((GetTickCount() - pTable->m_dwGiveUpStartTime)) / 1000;
            memcpy(stGiveUpInfo.nGiveUpChair, pTable->m_nGiveUpChair, sizeof(stGiveUpInfo.nGiveUpChair));

            //补银的玩家已经操作过，则断线的时候不再显示补银框
            if (!pTable->m_bShowGiveUp[chairno])
            {
                stGiveUpInfo.nGiveUpChair[chairno] = INVALID_OBJECT_ID;
            }

            CPlayer* pPlayer = pTable->m_ptrPlayers[chairno];
            NotifyOneUser(pPlayer->m_hSocket, pPlayer->m_lTokenID, GR_PLAYING_DEPOSIT_NOT_ENOUGH, &stGiveUpInfo, sizeof(stGiveUpInfo));
        }
    }
    else
    {
        if (nGiveUpCount > 0)
        {
            pTable->SetStatusOnGiveUp();

            GIVEUP_INFO stGiveUpInfo;
            ZeroMemory(&stGiveUpInfo, sizeof(stGiveUpInfo));
            stGiveUpInfo.nLastSecond = pTable->m_nGiveUpTime;
            stGiveUpInfo.nNeedDeposit = pTable->GetPlayingNeedDeposit();
            memcpy(stGiveUpInfo.nGiveUpChair, pTable->m_nGiveUpChair, sizeof(stGiveUpInfo.nGiveUpChair));

            NotifyTablePlayers(pTable, GR_PLAYING_DEPOSIT_NOT_ENOUGH, &stGiveUpInfo, sizeof(stGiveUpInfo));
            NotifyTableVisitors(pTable, GR_PLAYING_DEPOSIT_NOT_ENOUGH, &stGiveUpInfo, sizeof(stGiveUpInfo));
        }
    }
}

void CMyGameServer::PostRecordUserNetworkType(int nRoomID, int nUserID, int nNetworkType)
{
    HWND hWnd = GetRoomSvrWnd(nRoomID);
    if (IsWindow(hWnd))
    {
        PostMessage(hWnd, WM_GTR_RECORD_USER_NETWORK_TYPE_EX, (WPARAM)nUserID, (LPARAM)nNetworkType);
    }
}

void CMyGameServer::SendAbortPlayerInfo(CMyGameTable* pTable, int nRoomID, int nTableNO, SOCKET hSocket, LONG lTokenID)
{
    int nAbortPlayerCount = pTable->getTotalAbortPlayerCount();
    if (nAbortPlayerCount > 0)
    {
        int nLen = sizeof(PLAYER_ABORT_HEAD) + nAbortPlayerCount * sizeof(ABORTPLAYER_INFO);
        PBYTE pData = NULL;
        if (nLen)
        {
            pData = new BYTE[nLen];
        }
        ZeroMemory(pData, nLen);

        PLAYER_ABORT_HEAD playerAbortHead;
        memset(&playerAbortHead, 0, sizeof(playerAbortHead));
        playerAbortHead.nRoomID = nRoomID;
        playerAbortHead.nTableNO = nTableNO;
        playerAbortHead.nAbortPlayerCount = nAbortPlayerCount;
        memcpy(pData, &playerAbortHead, sizeof(playerAbortHead));

        int offsetLen = sizeof(PLAYER_ABORT_HEAD);
        for (int i = 0; i < TOTAL_CHAIRS; i++)
        {
            if (pTable->m_stAbortPlayerInfo[i].nUserID > 0)
            {
                memcpy(pData + offsetLen, &pTable->m_stAbortPlayerInfo[i], sizeof(ABORTPLAYER_INFO));
                offsetLen += sizeof(ABORTPLAYER_INFO);
            }
        }

        NotifyOneUser(hSocket, lTokenID, GR_ABORTPLAYER_INFO_DXXW, pData, nLen);
        SAFE_DELETE_ARRAY(pData);
    }
}

BOOL CMyGameServer::OnAuctionBanker(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt)
{
    LOG_TRACE(_T("CMyGameServer::OnAuctionBanker"));
    SAFETY_NET_REQUEST(lpRequest, AUCTION_DINGQUE, pAuctionBanker);

    REQUEST response;
    memset(&response, 0, sizeof(response));

    SOCKET sock = INVALID_SOCKET;
    LONG token = 0;
    int roomid = 0;
    int tableno = INVALID_OBJECT_ID;
    int userid = 0;
    int chairno = INVALID_OBJECT_ID;
    int r_id = 0;
    int t_no = INVALID_OBJECT_ID;
    int u_id = 0;
    int c_no = INVALID_OBJECT_ID;

    CRoom* pRoom = NULL;
    CMyGameTable* pTable = NULL;
    CPlayer* pPlayer = NULL;

    sock = lpContext->hSocket;
    token = lpContext->lTokenID;

    roomid = pAuctionBanker->nRoomID;
    tableno = pAuctionBanker->nTableNO;
    userid = pAuctionBanker->nUserID;
    chairno = pAuctionBanker->nChairNO;

    pRoom = GetRoomPtr(roomid);
    pTable = GetTablePtr(roomid, tableno);
    if (pTable)
    {
        LOCK_TABLE(pTable, chairno, FALSE, userid, token);

        if (!pTable->IsPlayer(userid)) // 不是玩家
        {
            UwlLogFile(_T("user not player. user %ld auction banker failed."), userid);
            response.head.nRequest = UR_OPERATE_FAILED;
            return SendUserResponse(lpContext, &response);
        }
        if (!IS_BIT_SET(pTable->m_dwStatus, TS_PLAYING_GAME)) //游戏未开始，或结束
        {
            response.head.nRequest = UR_OPERATE_FAILED;
            return SendUserResponse(lpContext, &response);
        }

        UwlTrace(_T("chair %ld, user %ld auction banker."), chairno, userid);
        if (!IS_BIT_SET(pTable->m_dwStatus, TS_WAITING_AUCTION))
        {
            UwlLogFile(_T("status not waiting_auction. chair %ld auction banker failed."), chairno);
            response.head.nRequest = UR_OPERATE_FAILED;
            return SendUserResponse(lpContext, &response);
        }

        if (pTable->m_nDingQueCardType[chairno] != -1)
        {
            UwlLogFile(_T("chair %ld, user %ld have auction banker"), chairno, userid);
            response.head.nRequest = UR_OPERATE_FAILED;
            return SendUserResponse(lpContext, &response);
        }

        BOOL bn = pTable->OnAuctionDingQue(pAuctionBanker);
        response.head.nRequest = UR_OPERATE_SUCCEEDED;
        SendUserResponse(lpContext, &response);

        SYSTEMMSG msg;
        ZeroMemory(&msg, sizeof(SYSTEMMSG));
        msg.nMsgID = SYSMSG_PLAYER_FIXMISS;
        msg.nChairNO = chairno;
        msg.nEventID = pAuctionBanker->nDingQueCardType[pAuctionBanker->nChairNO];
        NotifySystemMSG(pTable, &msg, -1);

        if (bn)//四家定缺结束
        {
            if (1 == pTable->m_nTakeFeeTime)
            {
                //服务费的通知
                NotifyServiceFee(pTable);
            }

            pTable->OnAuctionBanker();
            AUCTION_DINGQUE auctionfinished;
            ZeroMemory(&auctionfinished, sizeof(auctionfinished));
            memcpy(&auctionfinished, pAuctionBanker, sizeof(AUCTION_DINGQUE));
            memcpy(&auctionfinished.nDingQueCardType, pTable->m_nDingQueCardType, sizeof(pTable->m_nDingQueCardType));
            NotifyTablePlayers(pTable, GR_AUCTION_FINISHED, &auctionfinished, sizeof(auctionfinished));
            NotifyTableVisitors(pTable, GR_AUCTION_FINISHED, &auctionfinished, sizeof(auctionfinished));
            CreateRobotTimer(pRoom, pTable, pTable->m_dwStatus, (pTable->m_nThrowWait + 6) * 1000);
        }

        for (int i = 0; i < TOTAL_CHAIRS; i++)
        {
            if (pTable->IsOffline(i))
            {
                OnServerAutoPlay(pRoom, pTable, i, !pTable->IsOffline(i));
            }
        }
    }
    return TRUE;
}

BOOL CMyGameServer::OnGiveUpGame(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt)
{
    LOG_TRACE(_T("CMyGameServer::OnGiveUpGame"));
    SAFETY_NET_REQUEST(lpRequest, GIVE_UP_GAME, pGiveUpGame);

    REQUEST response;
    memset(&response, 0, sizeof(response));

    LONG token = 0;
    int roomid = 0;
    int tableno = INVALID_OBJECT_ID;
    int userid = 0;
    int chairno = INVALID_OBJECT_ID;
    int r_id = 0;
    int t_no = INVALID_OBJECT_ID;
    int u_id = 0;
    int c_no = INVALID_OBJECT_ID;
    BOOL lookon = FALSE;
    BOOL timeout = FALSE;

    CRoom* pRoom = NULL;
    CMyGameTable* pTable = NULL;
    CPlayer* pPlayer = NULL;

    token = lpContext->lTokenID;

    roomid = pGiveUpGame->nRoomID;
    tableno = pGiveUpGame->nTableNO;
    userid = pGiveUpGame->nUserID;
    chairno = pGiveUpGame->nChairNO;
    timeout = pGiveUpGame->bTimeOut;

    int bout_time = GetBoutTimeMin();
    pRoom = GetRoomPtr(roomid);
    pTable = GetTablePtr(roomid, tableno);
    if (pTable)
    {
        LOCK_TABLE(pTable, chairno, FALSE, userid, token);

        if (!pTable->IsPlayer(userid)) // 不是玩家
        {
            UwlLogFile(_T("user not player. user %ld giveup game failed."), userid);
            response.head.nRequest = UR_OPERATE_FAILED;
            return TRUE;
        }
        if (!IS_BIT_SET(pTable->m_dwStatus, TS_PLAYING_GAME)) // 不是正在进行状态
        {
            response.head.nRequest = UR_OPERATE_FAILED;
            return TRUE;
        }

        if (!IS_BIT_SET(pTable->m_dwStatus, TS_WAITING_GIVEUP)) // 不是等待放弃状态
        {
            response.head.nRequest = UR_OPERATE_FAILED;
            return TRUE;
        }

        if (!pTable->OnPlayerGiveUp(chairno))
        {
            response.head.nRequest = UR_OPERATE_FAILED;
            return TRUE;
        }
        else
        {
            SYSTEMMSG PlayerGiveUp;
            ZeroMemory(&PlayerGiveUp, sizeof(SYSTEMMSG));
            PlayerGiveUp.nChairNO = chairno;
            PlayerGiveUp.nMsgID = SYSMSG_PLAYER_GIVEUP;
            PlayerGiveUp.nEventID = MJ_GIVE_UP;

            NotifyTablePlayers(pTable, GR_SYSTEMMSG, &PlayerGiveUp, sizeof(SYSTEMMSG), 0);
            NotifyTableVisitors(pTable, GR_SYSTEMMSG, &PlayerGiveUp, sizeof(SYSTEMMSG), 0);
        }

        DWORD dwWinFlags = pTable->CalcWinOnGiveUp(chairno, timeout);
        if (dwWinFlags)
        {
            pTable->ResetPlayerGiveUpInfo();
            BOOL bout_invalid = pTable->IsBoutInvalid(bout_time);
            OnGameWin(lpContext, pRoom, pTable, chairno, bout_invalid, roomid);
        }
        else
        {
            PreSaveResult(lpContext, pTable, roomid, ResultByGiveUp, chairno);
            //新手任务,放弃的玩家也要计算玩得局数

            SetServerMakeCardInfo(pTable, chairno);
            BOOL bIsAllGiveUp = pTable->IsAllPlayerGiveUp();
            if (bIsAllGiveUp)
            {
                int nCurrentChair = pTable->GetCurrentChair();
                pTable->RemoveStatusOnGiveUp();
                pTable->m_dwCheckBreakTime[nCurrentChair] = GetTickCount();
                pTable->m_dwWaitOperateTick = (pTable->m_nPGCHWait + SVR_WAIT_SECONDS) * 1000;
                NotifyNextTurn(pTable, nCurrentChair);
            }

            //掉线自动抓牌
            if (pTable->IsRoboter(pTable->GetCurrentChair()))
            {
                OnRobotAIPlay(pRoom, pTable, pTable->GetCurrentChair());
            }
            else if (pTable->IsOffline(pTable->GetCurrentChair()))
            {
                OnServerAutoPlay(pRoom, pTable, pTable->GetCurrentChair(), !pTable->IsOffline(pTable->GetCurrentChair()));
            }

            if (pTable->IsXueLiuRoom())
            {
                //发送结果
                CPlayer* pPlayer = pTable->m_ptrPlayers[chairno];
                if (pPlayer)
                {
                    //新手任务
                    int nLen = pTable->GetGameWinSize() + sizeof(HU_ITEM_HEAD) + pTable->GetNoSendItemCount(chairno) * sizeof(HU_ITEM_INFO)
                        + sizeof(GAMEEND_CHECK_INFO) + sizeof(ABORTPLAYER_INFO) * TOTAL_CHAIRS;
                    void* pData = new_byte_array(nLen);
                    pTable->FillupPlayerHu(pData, nLen, chairno);

                    int offsetLen = pTable->GetGameWinSize();
                    int itemCount = pTable->GetNoSendItemCount(chairno);
                    pTable->FillupAllHuItems(pData, offsetLen, chairno, itemCount);
                    int nEndLen = pTable->GetGameWinSize() + sizeof(HU_ITEM_HEAD) + pTable->GetNoSendItemCount(chairno) * sizeof(HU_ITEM_INFO);
                    pTable->FillUpGameWinCheckInfos(pData, nEndLen, chairno);
                    int nGamePlayerInfoOffset = pTable->GetGameWinSize() + sizeof(HU_ITEM_HEAD) +
                        pTable->GetNoSendItemCount(chairno) * sizeof(HU_ITEM_INFO) + sizeof(GAMEEND_CHECK_INFO);
                    pTable->FillupGameStartPlayerInfo(pData, nGamePlayerInfoOffset);

                    if (IS_BIT_SET(pPlayer->m_nUserType, UT_HANDPHONE))
                    {
                        NotifyOneUser(pPlayer->m_hSocket, pPlayer->m_lTokenID, GR_ON_PLAYER_HU, pData, nLen);
                    }
                    else
                    {
                        NotifyOneUser(pPlayer->m_hSocket, pPlayer->m_lTokenID, GR_ON_PLAYER_GIVE_UP, pData, nLen);
                    }

                    NotifyChairVisitors(pTable, chairno, GR_ON_PLAYER_GIVE_UP, pData, nLen);
                    SAFE_DELETE(pData);
                }
            }
            else
            {
                //发送结果
                CPlayer* pPlayer = pTable->m_ptrPlayers[chairno];
                if (pPlayer)
                {
                    if (IS_BIT_SET(pPlayer->m_nUserType, UT_HANDPHONE))
                    {
                        int nLen = pTable->GetGameWinSize() + sizeof(HU_ITEM_HEAD) + pTable->GetTotalItemCount(chairno) * sizeof(HU_ITEM_INFO)
                            + sizeof(GAMEEND_CHECK_INFO) + sizeof(ABORTPLAYER_INFO) * TOTAL_CHAIRS;
                        void* pData = new_byte_array(nLen);
                        pTable->FillupPlayerHu(pData, nLen, chairno);

                        int offsetLen = pTable->GetGameWinSize();
                        int itemCount = pTable->GetTotalItemCount(chairno);
                        pTable->FillupAllHuItems(pData, offsetLen, chairno, itemCount);

                        int nGameEndOffset = pTable->GetGameWinSize() + sizeof(HU_ITEM_HEAD) + pTable->GetTotalItemCount(chairno) * sizeof(HU_ITEM_INFO);
                        pTable->FillUpGameWinCheckInfos(pData, nGameEndOffset, chairno);
                        int nGamePlayerInfoOffset = nGameEndOffset + sizeof(GAMEEND_CHECK_INFO);
                        pTable->FillupGameStartPlayerInfo(pData, nGamePlayerInfoOffset);

                        NotifyOneUser(pPlayer->m_hSocket, pPlayer->m_lTokenID, GR_ON_PLAYER_HU, pData, nLen);
                        //NotifyChairVisitors(pTable, chairno, GR_ON_PLAYER_HU, pData, nLen);
                        SAFE_DELETE(pData);

                        //旁观
                        if (!pTable->m_mapVisitors[chairno].empty())
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
                            pTable->FillupPlayerHu(pDataVisitor, nLenVisitor, chairno);

                            offsetLen = pTable->GetGameWinSize();
                            pTable->FillupAllPCHuItems(pDataVisitor, offsetLen, nItemCount);

                            int u_id = 0;
                            CPlayer* ptrV = NULL;
                            auto pos = pTable->m_mapVisitors[chairno].GetStartPosition();
                            while (pos)
                            {
                                pTable->m_mapVisitors[chairno].GetNextAssoc(pos, u_id, ptrV);
                                if (ptrV && ptrV->m_lTokenID != 0)
                                {
                                    NotifyOneUser(ptrV->m_hSocket, ptrV->m_lTokenID, GR_ON_PLAYER_GIVE_UP, pDataVisitor, nLenVisitor);
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
                        pTable->FillupPlayerHu(pData, nLen, chairno);

                        int offsetLen = pTable->GetGameWinSize();
                        pTable->FillupAllPCHuItems(pData, offsetLen, nItemCount);

                        NotifyOneUser(pPlayer->m_hSocket, pPlayer->m_lTokenID, GR_ON_PLAYER_GIVE_UP, pData, nLen);
                        NotifyChairVisitors(pTable, chairno, GR_ON_PLAYER_GIVE_UP, pData, nLen);
                        SAFE_DELETE(pData);
                    }
                }
            }
        }
    }

    return TRUE;
}

void CMyGameServer::PreSaveResult(LPCONTEXT_HEAD lpContext, CMyGameTable* pTable, int roomid, int flag, int chairno /*= INVALID_OBJECT_ID*/)
{
    REFRESH_RESULT_EX RefreshResult;
    ZeroMemory(&RefreshResult, sizeof(RefreshResult));
    RefreshResult.nTableNO = pTable->m_nTableNO;

    GAME_RESULT_EX GameResults[MAX_CHAIRS_PER_TABLE];
    ZeroMemory(&GameResults, sizeof(GameResults));

    pTable->ConstructMyPreSaveResult(roomid, m_nGameID, &RefreshResult, GameResults, m_mapPlayerLevel, chairno, flag);

    //呼叫转移结算
    BOOL bTransfer = FALSE;
    int CallTransferDepositResults[MAX_CHAIRS_PER_TABLE];
    int nBeTransferChairNO = INVALID_OBJECT_ID;
    ZeroMemory(&CallTransferDepositResults, sizeof(CallTransferDepositResults));
    GAME_RESULT_EX HuAndTransferResults[MAX_CHAIRS_PER_TABLE];
    ZeroMemory(&HuAndTransferResults, sizeof(HuAndTransferResults));
    memcpy(HuAndTransferResults, GameResults, sizeof(HuAndTransferResults));
    if (pTable->m_bNewRuleOpen && ResultByHu == flag && pTable->m_bCallTransfer)
    {
        if (bTransfer = pTable->PresaveResultCallTransferDeposit(GameResults, CallTransferDepositResults))
        {
            pTable->updateDepositAfterTransfer(CallTransferDepositResults);

            CString tempStr[TOTAL_CHAIRS];
            for (int i = 0; i < pTable->m_nTotalChairs; i++)
            {
                if (pTable->m_bOpenSaveResultLog)   //呼叫转移日志
                {
                    tempStr[i].Format("tableNo:%d userID:%d chairNo:%d nOldDeposit:%d nDepositDiff:%d nTransferDeposit:%d", GameResults[i].nTableNO,
                        GameResults[i].nUserID, GameResults[i].nChairNO, GameResults[i].nOldDeposit, GameResults[i].nDepositDiff, CallTransferDepositResults[GameResults[i].nChairNO]);
                }
                if (HuAndTransferResults[i].nUserID != 0)
                {
                    HuAndTransferResults[i].nDepositDiff += CallTransferDepositResults[HuAndTransferResults[i].nChairNO];
                }
                if (CallTransferDepositResults[i] < 0)
                {
                    nBeTransferChairNO = i;
                }
            }
            if (pTable->m_bOpenSaveResultLog)
            {
                UwlLogFile(_T("PreSaveResult CallTransfer roomID:%d flag:transfer \n %s \n %s \n %s \n %s"), roomid, tempStr[0], tempStr[1], tempStr[2], tempStr[3]);
            }
        }
    }
    pTable->m_bCallTransfer = FALSE;

    if (RefreshResult.nResultCount > 0)
    {
        if (bTransfer)
        {
            TransmitGameResultEx(pTable, lpContext, &RefreshResult, HuAndTransferResults, RefreshResult.nResultCount * sizeof(GAME_RESULT_EX));
        }
        else
        {
            TransmitGameResultEx(pTable, lpContext, &RefreshResult, GameResults, RefreshResult.nResultCount * sizeof(GAME_RESULT_EX));
        }
        if (pTable->m_bOpenSaveResultLog)
        {
            CString tempStr[TOTAL_CHAIRS];
            for (int i = 0; i < TOTAL_CHAIRS; i++)
            {
                tempStr[i].Format("tableNo:%d userID:%d chairNo:%d nOldDeposit:%d nDepositDiff:%d", HuAndTransferResults[i].nTableNO,
                    HuAndTransferResults[i].nUserID, HuAndTransferResults[i].nChairNO, HuAndTransferResults[i].nOldDeposit, HuAndTransferResults[i].nDepositDiff);
            }
            UwlLogFile(_T("PreSaveResult normal roomID:%d flag:%d \n %s \n %s \n %s \n %s"), roomid, flag, tempStr[0], tempStr[1], tempStr[2], tempStr[3]);
        }
    }
    else
    {
        UwlLogFile(_T("PreSaveResult Flag is %d, RefreshResult.nResultCount = %d"), flag, RefreshResult.nResultCount);
    }

    //通知客户端
    PRE_SAVE_RESULT stPreSaveResult;
    memset(&stPreSaveResult, 0, sizeof(stPreSaveResult));
    stPreSaveResult.nFlag = flag;
    stPreSaveResult.nChairNO = chairno;
    if (chairno != INVALID_OBJECT_ID)
    {
        stPreSaveResult.nHuStatus = pTable->m_HuReady[chairno];
        stPreSaveResult.nHuStatus |= pTable->m_huDetails[chairno].dwHuFlags[0];
        stPreSaveResult.nPreSaveAllDeposit = pTable->m_stPreSaveInfo[chairno].nPreSaveAllDeposit;
    }

    int i = 0;
    for (i = 0; i < pTable->m_nTotalChairs; i++)
    {
        if (!pTable->m_ptrPlayers[i] || pTable->m_ptrPlayers[i]->m_bIdlePlayer)
        {
            stPreSaveResult.nIdlePlayerFlag |= (1 << i);
        }
    }

    for (i = 0; i < RefreshResult.nResultCount; ++i)
    {
        int chairno = GameResults[i].nChairNO;
        stPreSaveResult.nDepositDiffs[chairno] = GameResults[i].nDepositDiff;
        stPreSaveResult.nScoreDiffs[chairno] = GameResults[i].nScoreDiff;
        stPreSaveResult.nOldDeposits[chairno] = GameResults[i].nOldDeposit;
        stPreSaveResult.nOldScores[chairno] = GameResults[i].nOldScore;
    }
    if (bTransfer)
    {
        stPreSaveResult.nReserved[0] = TRUE;    //是否有呼叫转移
    }


    BOOL bSendItem = FALSE;
    int nItemCount[TOTAL_CHAIRS];
    ZeroMemory(nItemCount, sizeof(nItemCount));

    if (ResultByHu == flag)
    {
        bSendItem = TRUE;
        for (int i = 0; i < pTable->m_nTotalChairs; i++)
        {
            if (pTable->m_stHuMultiInfo.nHuChair[i] != INVALID_OBJECT_ID)
            {
                nItemCount[i] = pTable->GetNoSendItemCount(i);
                continue;
            }
            if (pTable->m_stHuMultiInfo.nLossChair[i] != INVALID_OBJECT_ID)
            {
                nItemCount[i] = pTable->GetNoSendItemCount(i);
                continue;
            }
        }
    }
    else if (ResultByMnGang == flag || ResultByAnGang == flag || ResultByPnGang == flag)
    {
        bSendItem = TRUE;
        for (int i = 0; i < pTable->m_nTotalChairs; i++)
        {
            if (pTable->m_stHuMultiInfo.nHuChair[i] != INVALID_OBJECT_ID)
            {
                nItemCount[i] = 1;
                continue;
            }
            if (pTable->m_stHuMultiInfo.nLossChair[i] != INVALID_OBJECT_ID)
            {
                nItemCount[i] = 1;
                continue;
            }
        }
    }

    evPreResult.notify(lpContext, pTable, roomid, flag, chairno, &GameResults[0], RefreshResult.nResultCount);

    if (pTable->IsXueLiuRoom())
    {
        if (bSendItem)
        {
            for (int i = 0; i < pTable->m_nTotalChairs; i++)
            {
                CPlayer* ptrP = pTable->m_ptrPlayers[i];
                if (ptrP && ptrP->m_lTokenID != 0)
                {
                    int nLen = sizeof(PRE_SAVE_RESULT) + sizeof(HU_ITEM_HEAD) + nItemCount[i] * sizeof(HU_ITEM_INFO);
                    if (bTransfer)
                    {
                        nLen += sizeof(TRANSFER_INFO);
                    }
                    void* pData = new_byte_array(nLen);
                    ZeroMemory(pData, nLen);
                    memcpy(pData, &stPreSaveResult, sizeof(PRE_SAVE_RESULT));

                    int offsetLen = sizeof(PRE_SAVE_RESULT);
                    int itemCount = nItemCount[i];
                    pTable->FillupAllHuItems(pData, offsetLen, i, itemCount);
                    //添加呼叫转移数据
                    if (bTransfer)
                    {
                        TRANSFER_INFO info;
                        ZeroMemory(&info, sizeof(info));
                        info.nAniChairNo = nBeTransferChairNO;
                        for (int j = 0; j < pTable->m_nTotalChairs; j++)
                        {
                            info.nDeposit[j] = CallTransferDepositResults[j];
                        }
                        LPTRANSFER_INFO pInfo = LPTRANSFER_INFO((PBYTE)pData + nLen - sizeof(TRANSFER_INFO));
                        memcpy(pInfo, &info, sizeof(TRANSFER_INFO));
                    }

                    NotifyOneUser(ptrP->m_hSocket, ptrP->m_lTokenID, GR_PRE_SAVE_RESULT, pData, nLen);
                    NotifyChairVisitors(pTable, i, GR_PRE_SAVE_RESULT, pData, nLen);
                    SAFE_DELETE(pData);
                }
            }
        }
        else
        {
            NotifyTablePlayers(pTable, GR_PRE_SAVE_RESULT, &stPreSaveResult, sizeof(stPreSaveResult), 0);
            NotifyTableVisitors(pTable, GR_PRE_SAVE_RESULT, &stPreSaveResult, sizeof(stPreSaveResult), 0);
        }
    }
    else
    {
        if (ResultByHu == flag)
        {
            int nItemCount2[TOTAL_CHAIRS];
            ZeroMemory(nItemCount2, sizeof(nItemCount2));
            for (int i = 0; i < TOTAL_CHAIRS; i++)
            {
                nItemCount2[i] = pTable->GetTotalItemCount(i);
            }

            for (int i = 0; i < pTable->m_nTotalChairs; i++)
            {
                CPlayer* ptrP = pTable->m_ptrPlayers[i];
                if (ptrP && ptrP->m_lTokenID != 0)
                {
                    int nLen = 0;
                    int itemCount = 0;
                    tc::KPIClientData temp;
                    GetKPIClientData(ptrP->m_nUserID, temp);

                    if (IS_BIT_SET(ptrP->m_nUserType, UT_HANDPHONE) && (temp.pkgtype() != 300))
                    {
                        nLen = sizeof(PRE_SAVE_RESULT) + sizeof(HU_ITEM_HEAD) + nItemCount[i] * sizeof(HU_ITEM_INFO);
                        itemCount = nItemCount[i];
                    }
                    else
                    {
                        nLen = sizeof(PRE_SAVE_RESULT) + sizeof(HU_ITEM_HEAD) + nItemCount2[i] * sizeof(HU_ITEM_INFO);
                        itemCount = nItemCount2[i];
                    }

                    if (bTransfer)
                    {
                        nLen += sizeof(TRANSFER_INFO);
                    }
                    void* pData = new_byte_array(nLen);
                    ZeroMemory(pData, nLen);
                    memcpy(pData, &stPreSaveResult, sizeof(PRE_SAVE_RESULT));

                    int offsetLen = sizeof(PRE_SAVE_RESULT);
                    pTable->FillupAllHuItems(pData, offsetLen, i, itemCount);
                    //添加呼叫转移数据
                    if (bTransfer)
                    {
                        TRANSFER_INFO info;
                        ZeroMemory(&info, sizeof(info));
                        info.nAniChairNo = nBeTransferChairNO;
                        for (int j = 0; j < pTable->m_nTotalChairs; j++)
                        {
                            info.nDeposit[j] = CallTransferDepositResults[j];
                        }
                        LPTRANSFER_INFO pInfo = LPTRANSFER_INFO((PBYTE)pData + nLen - sizeof(TRANSFER_INFO));
                        memcpy(pInfo, &info, sizeof(TRANSFER_INFO));
                    }

                    NotifyOneUser(ptrP->m_hSocket, ptrP->m_lTokenID, GR_PRE_SAVE_RESULT, pData, nLen);
                    NotifyChairVisitors(pTable, i, GR_PRE_SAVE_RESULT, pData, nLen);
                    SAFE_DELETE(pData);
                }
            }
        }
        else if (ResultByMnGang == flag || ResultByAnGang == flag || ResultByPnGang == flag)
        {
            for (int i = 0; i < pTable->m_nTotalChairs; i++)
            {
                CPlayer* ptrP = pTable->m_ptrPlayers[i];
                if (ptrP && ptrP->m_lTokenID != 0)
                {
                    tc::KPIClientData temp;
                    GetKPIClientData(ptrP->m_nUserID, temp);
                    //微信端和PC端没有血战账单，需要区分单独发消息
                    if (!IS_BIT_SET(ptrP->m_nUserType, UT_HANDPHONE) || (temp.pkgtype() == 300))
                    {
                        NotifyOneUser(ptrP->m_hSocket, ptrP->m_lTokenID, GR_PRE_SAVE_RESULT, &stPreSaveResult, sizeof(stPreSaveResult));
                        NotifyChairVisitors(pTable, i, GR_PRE_SAVE_RESULT, &stPreSaveResult, sizeof(stPreSaveResult));
                        continue;
                    }

                    int nLen = sizeof(PRE_SAVE_RESULT) + sizeof(HU_ITEM_HEAD) + nItemCount[i] * sizeof(HU_ITEM_INFO);
                    if (bTransfer)
                    {
                        nLen += sizeof(TRANSFER_INFO);
                    }
                    void* pData = new_byte_array(nLen);
                    ZeroMemory(pData, nLen);
                    memcpy(pData, &stPreSaveResult, sizeof(PRE_SAVE_RESULT));

                    int offsetLen = sizeof(PRE_SAVE_RESULT);
                    int itemCount = nItemCount[i];
                    pTable->FillupAllHuItems(pData, offsetLen, i, itemCount);
                    //添加呼叫转移数据
                    if (bTransfer)
                    {
                        TRANSFER_INFO info;
                        ZeroMemory(&info, sizeof(info));
                        info.nAniChairNo = nBeTransferChairNO;
                        for (int j = 0; j < pTable->m_nTotalChairs; j++)
                        {
                            info.nDeposit[j] = CallTransferDepositResults[j];
                        }
                        LPTRANSFER_INFO pInfo = LPTRANSFER_INFO((PBYTE)pData + nLen - sizeof(TRANSFER_INFO));
                        memcpy(pInfo, &info, sizeof(TRANSFER_INFO));
                    }

                    NotifyOneUser(ptrP->m_hSocket, ptrP->m_lTokenID, GR_PRE_SAVE_RESULT, pData, nLen);
                    NotifyChairVisitors(pTable, i, GR_PRE_SAVE_RESULT, pData, nLen);
                    SAFE_DELETE(pData);
                }
            }
        }
        else
        {
            NotifyTablePlayers(pTable, GR_PRE_SAVE_RESULT, &stPreSaveResult, sizeof(stPreSaveResult), 0);
            NotifyTableVisitors(pTable, GR_PRE_SAVE_RESULT, &stPreSaveResult, sizeof(stPreSaveResult), 0);
        }
    }
    //检查以小博大
    CheckandNotifyDepositWinLimit(pTable);

    //XL 胡牌和放弃玩家改成空闲玩家
    if (chairno != INVALID_OBJECT_ID)
    {
        BOOL isPlayerHu = (flag == ResultByHu);
        BOOL isPlayerGiveup = (flag == ResultByGiveUp);

        if (isPlayerGiveup)
        {
            pTable->m_dwUserStatus[chairno] = 0;
            pTable->m_ptrPlayers[chairno]->m_bIdlePlayer = TRUE;
            PostSoloUserBoutEnd(pTable->m_ptrPlayers[chairno]->m_nUserID, roomid);
            //evUpdateRobotPlayerData.notify(lpContext, pTable, chairno, pTable->m_stPreSaveInfo[chairno].nPreSaveAllDeposit);
            // UpdateRobotPlayerData
        }
        else if (isPlayerHu)
        {
            if (!pTable->IsXueLiuRoom()) //XL 血战游戏结束
            {
                for (int i = 0; i < pTable->m_nTotalChairs; i++)
                {
                    if (pTable->m_stHuMultiInfo.nHuChair[i] != INVALID_OBJECT_ID)
                    {
                        pTable->m_dwUserStatus[i] = 0;
                        pTable->m_ptrPlayers[i]->m_bIdlePlayer = TRUE;
                        PostSoloUserBoutEnd(pTable->m_ptrPlayers[i]->m_nUserID, roomid);
                        //evUpdateRobotPlayerData.notify(lpContext, pTable, i, pTable->m_stPreSaveInfo[chairno].nPreSaveAllDeposit);
                    }
                }
            }
        }
    }

    //检查玩家是否够玩下去
    CheckGiveUp(pTable);
}

void CMyGameServer::NotifyNextTurn(CTable* pTable, int chairno)
{
    SYSTEMMSG PlayerNext;
    ZeroMemory(&PlayerNext, sizeof(SYSTEMMSG));
    PlayerNext.nChairNO = chairno;
    PlayerNext.nMsgID = SYSMSG_PLAYER_NEXTTURN;

    NotifyTablePlayers(pTable, GR_SYSTEMMSG, &PlayerNext, sizeof(SYSTEMMSG), 0);
    NotifyTableVisitors(pTable, GR_SYSTEMMSG, &PlayerNext, sizeof(SYSTEMMSG), 0);

}

void CMyGameServer::SetServerMakeCardInfo(CMyGameTable* pTable, int chairno)
{
    if (NULL == pTable)
    {
        return;
    }

    CPlayer* pPlayer = pTable->m_ptrPlayers[chairno];
    if (pPlayer)
    {
        SOLO_PLAYER sp = { 0 };
        if (LookupSoloPlayer(pPlayer->m_nUserID, sp))
        {
            //连输2局后触发了做牌
            if (2 <= sp.nReserved3[0] && pTable->m_stMakeCardInfo[chairno].nMakeDeal != 0)
            {
                sp.nReserved3[0] = 0;
            }

            int nWinDeposit = pTable->m_stPreSaveInfo[chairno].nPreSaveAllDeposit;
            if (nWinDeposit < 0)
            {
                sp.nReserved3[0]++;
            }
            else
            {
                sp.nReserved3[0] = 0;
            }

            //跳转房间后2局
            if (sp.nReserved3[1] > 0)
            {
                sp.nReserved3[1]--;
            }

            //充值成功后3局
            if (sp.nReserved3[2] > 0)
            {
                sp.nReserved3[2]--;
            }

            SetSoloPlayer(pPlayer->m_nUserID, sp);
        }
    }
}

BOOL CMyGameServer::CheckandNotifyDepositWinLimit(CMyGameTable* pTable)
{
    BOOL ret = false;
    if (NULL == pTable)
    {
        return false;
    }
    for (int i = 0; i < TOTAL_CHAIRS; i++)
    {
        if (pTable->m_nDepositWinLimit[i] > 0)
        {
            pTable->m_nDepositWinLimit[i] = 0;

            SYSTEMMSG szmsg;
            ZeroMemory(&szmsg, sizeof(SYSTEMMSG));
            szmsg.nChairNO = i;
            szmsg.nMsgID = MJ_HU_DEPOSIT_LIMIT;
            szmsg.nEventID = 0;
            szmsg.nMJID = INVALID_OBJECT_ID;
            szmsg.nFangCardChairNO = INVALID_OBJECT_ID;

            CPlayer* ptrP = pTable->m_ptrPlayers[i];
            if (ptrP && ptrP->m_lTokenID != 0)
            {
                NotifyOneUser(ptrP->m_hSocket, ptrP->m_lTokenID, GR_SYSTEMMSG, &szmsg, sizeof(SYSTEMMSG));
            }
        }
    }
    pTable->resetDepositWinLimit();
    return ret;
}

BOOL CMyGameServer::OnReconsPengCard(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt)
{
    LOG_TRACE(_T("CMyGameServer::OnReconsPengCard"));
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
    CMyGameTable* pTable = NULL;

    if (!(pRoom = GetRoomPtr(roomid)))
    {
        return NotifyResponseFaild(lpContext, bPassive);
    }
    if (!(pTable = (CMyGameTable*)GetTablePtr(roomid, tableno)))
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

            UwlLogFile(("OnReconsPengCard game is not ValidatePeng fail, pengbaseid:%d %d, roomid:%ld, tableno:%ld, chairno:%ld, userid:%ld"),
                pPengCard->nBaseIDs[0], pPengCard->nBaseIDs[1], roomid, tableno, chairno, userid);
            UWLCurrentChairCards(pTable, chairno, pPengCard->nCardID, roomid, tableno, userid);
            // xzmo 新增
            BOOL bOtherHu = FALSE;
            for (int i = 0; i < pTable->m_nTotalChairs; i++)
            {
                if (pTable->m_HuMJID[i] == pPengCard->nCardID) //打算碰的这张牌已经是别人的胡张
                {
                    bOtherHu = TRUE;
                }
            }

            if (bOtherHu) //相当于点过
            {
                pTable->m_nPengWait = pPengCard->nChairNO;
                GUO_CARD cardguo;
                ZeroMemory(&cardguo, sizeof(GUO_CARD));
                cardguo.nChairNO = pPengCard->nChairNO;
                cardguo.nCardChair = pPengCard->nCardChair;
                CPlayer* pGuoPlayer = pTable->m_ptrPlayers[pPengCard->nChairNO];
                SimulateGameMsgFromUser(roomid, pGuoPlayer, LOCAL_GAME_MSG_AUTO_GUO, sizeof(GUO_CARD), &cardguo, 0);
            }
            // end
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
        LOG_DEBUG(_T("***********ROBOT_BOUT_LOG_PENG***********roomid:%d, tableno:%d, userid:%d, chairno:%d, cardchair:%d, cardid:%s, baseid[0]:%s, baseid[1]:%s"), roomid, tableno, userid, chairno, cardchair,
            pTable->RobotBoutLog(pPengCard->nCardID), pTable->RobotBoutLog(pPengCard->nBaseIDs[0]), pTable->RobotBoutLog(pPengCard->nBaseIDs[1]));
        CreateRobotTimer(pRoom, pTable, pTable->m_dwStatus, pTable->m_nThrowWait * 1000);

        pTable->m_dwCheckBreakTime[chairno] = GetTickCount();
        pTable->m_dwWaitOperateTick = (pTable->m_nThrowWait + SVR_WAIT_SECONDS) * 1000;

        if (pTable->m_ptrPlayers[chairno] && pTable->m_ptrPlayers[chairno]->m_nUserID > 0 && IS_BIT_SET(pTable->m_ptrPlayers[chairno]->m_nUserType, UT_HANDPHONE))
        {
            evTaskPeng.notify(lpContext, pTable, userid, chairno, pPengCard->nCardID);
            //新手任务
        }

        if (pTable->IsTingPaiActive())
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

BOOL CMyGameServer::OnReconsMnGangCard(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt)
{
    LOG_TRACE(_T("CMyGameServer::OnReconsMnGangCard"));
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
    CMyGameTable* pTable = NULL;
    if (!(pRoom = GetRoomPtr(roomid)))
    {
        return NotifyResponseFaild(lpContext, bPassive);
    }
    if (!(pTable = (CMyGameTable*)GetTablePtr(roomid, tableno)))
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
            // xzmo add
            UwlLogFile("OnReconsMnGangCard ValidateMnGang false OnMnGangCard:%d,%d,%d",
                pGangCard->nBaseIDs[0], pGangCard->nBaseIDs[1], pGangCard->nBaseIDs[2]);
            UWLCurrentChairCards(pTable, chairno, pGangCard->nCardID, roomid, tableno, userid);


            BOOL bOtherHu = FALSE;
            for (int i = 0; i < pTable->m_nTotalChairs; i++)
            {
                if (pTable->m_HuMJID[i] == pGangCard->nCardID) //打算碰的这张牌已经是别人的胡张
                {
                    bOtherHu = TRUE;
                }
            }

            if (bOtherHu) //相当于点过
            {
                GUO_CARD cardguo;
                ZeroMemory(&cardguo, sizeof(GUO_CARD));
                cardguo.nChairNO = pGangCard->nChairNO;
                cardguo.nCardChair = pGangCard->nCardChair;
                CPlayer* pGuoPlayer = pTable->m_ptrPlayers[pGangCard->nChairNO];
                SimulateGameMsgFromUser(roomid, pGuoPlayer, LOCAL_GAME_MSG_AUTO_GUO, sizeof(GUO_CARD), &cardguo, 0);
            }

            return NotifyResponseFaild(lpContext, bPassive);
            // end
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
        // xzmo change
        int nCardID = pTable->GetGangCardEx(chairno);
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
            // xzmo add
            pTable->ResetMultiHuInfo();
            pTable->OnMnGang(pGangCard);
            LOG_DEBUG(_T("***********ROBOT_BOUT_LOG_MNGANG***********roomid:%d, tableno:%d, userid:%d, chairno:%d, cardchair:%d, cardid:%s, baseid[0]:%s, baseid[1]:%ds, baseid[2]:%s"), roomid, tableno, userid,
                chairno, cardchair, pTable->RobotBoutLog(pGangCard->nCardID), pTable->RobotBoutLog(pGangCard->nBaseIDs[0]), pTable->RobotBoutLog(pGangCard->nBaseIDs[1]), pTable->RobotBoutLog(pGangCard->nBaseIDs[2]));
            CreateRobotTimer(pRoom, pTable, pTable->m_dwStatus, pTable->m_nThrowWait * 1000);
            PreSaveResult(lpContext, pTable, roomid, ResultByMnGang, chairno);

            CARD_CAUGHT_EX card_caught;
            ZeroMemory(&card_caught, sizeof(card_caught));
            card_caught.nChairNO = chairno;
            memcpy(card_caught.nGangPoint, pTable->m_GangPoint, sizeof(card_caught.nGangPoint));

            BOOL bIsAllGiveUp = pTable->IsAllPlayerGiveUp();
            if (bIsAllGiveUp)
            {
                BOOL bBuHua = FALSE;
                card_caught.nCardID = pTable->GetGangCard(chairno, bBuHua);
                LOG_DEBUG(_T("***********ROBOT_BOUT_LOG_MNGANG_CATCH***********roomid:%d, tableno:%d, chairno:%d, userid:%d, cardid:%s"), roomid, tableno, chairno, userid, pTable->RobotBoutLog(card_caught.nCardID));
                if (bBuHua)
                {
                    NotifySomeOneBuHua(pTable);
                }
                card_caught.nCardNO = pTable->GetCardNO(card_caught.nCardID);
                card_caught.dwFlags = pTable->CalcHu_Zimo(chairno, card_caught.nCardID);
            }
            else
            {
                card_caught.nCardID = INVALID_OBJECT_ID;
                card_caught.nCardNO = INVALID_OBJECT_ID;
            }

            pTable->m_dwCheckBreakTime[chairno] = GetTickCount();
            pTable->m_dwWaitOperateTick = (pTable->m_nThrowWait + SVR_WAIT_SECONDS) * 1000;

            CBuffer buff;
            buff.Write((BYTE*)&card_caught, sizeof(CARD_CAUGHT_EX));

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

            if (pTable->m_ptrPlayers[chairno] && pTable->m_ptrPlayers[chairno]->m_nUserID > 0 && IS_BIT_SET(pTable->m_ptrPlayers[chairno]->m_nUserType, UT_HANDPHONE))
            {
                evTaskGang.notify(lpContext, pTable, userid, chairno, MJ_GANG_MN);
                //新手任务
            }

            BOOL bRobotBout = FALSE;
            for (int j = 0; j < TOTAL_CHAIRS; j++)
            {
                if (pTable->IsRoboter(j))
                {
                    bRobotBout = True;
                }
            }
            if (bRobotBout)
            {
                OnRobotGiveUp(pRoom, pTable, chairno);
            }
            // end
        }
    }
    return TRUE;
}

BOOL CMyGameServer::OnReconsAnGangCard(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt)
{
    LOG_TRACE(_T("CMyGameServer::OnReconsAnGangCard"));
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
    CMyGameTable* pTable = NULL;
    if (!(pRoom = GetRoomPtr(roomid)))
    {
        return NotifyResponseFaild(lpContext, bPassive);
    }
    if (!(pTable = (CMyGameTable*)GetTablePtr(roomid, tableno)))
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
        // xzmo change
        int nCardID = pTable->GetGangCardEx(chairno);
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
            // xzmo add
            pTable->ResetMultiHuInfo();
            pTable->OnAnGang(pGangCard);
            LOG_DEBUG(_T("***********ROBOT_BOUT_LOG_ANGANG***********roomid:%d, tableno:%d, userid:%d, chairno:%d, cardchair:%d, cardid:%s, baseid[0]:%s, baseid[1]:%s, baseid[2]:%s"), roomid, tableno, userid,
                chairno, cardchair, pTable->RobotBoutLog(pGangCard->nCardID), pTable->RobotBoutLog(pGangCard->nBaseIDs[0]), pTable->RobotBoutLog(pGangCard->nBaseIDs[1]), pTable->RobotBoutLog(pGangCard->nBaseIDs[2]));
            CreateRobotTimer(pRoom, pTable, pTable->m_dwStatus, pTable->m_nThrowWait * 1000);
            PreSaveResult(lpContext, pTable, roomid, ResultByAnGang, chairno);
            LOG_DEBUG(_T("***********ROBOT_BOUT_LOG_ANGANG_CATCH***********roomid:%d, tableno:%d, chairno:%d, userid:%d, cardid:%s"), roomid, tableno, chairno, userid, pTable->RobotBoutLog(nCardID));
            CARD_CAUGHT_EX card_caught;
            ZeroMemory(&card_caught, sizeof(card_caught));
            card_caught.nChairNO = chairno;
            memcpy(card_caught.nGangPoint, pTable->m_GangPoint, sizeof(card_caught.nGangPoint));

            BOOL bIsAllGiveUp = pTable->IsAllPlayerGiveUp();
            if (bIsAllGiveUp)
            {
                BOOL bBuHua = FALSE;
                card_caught.nCardID = pTable->GetGangCard(chairno, bBuHua);
                if (bBuHua)
                {
                    NotifySomeOneBuHua(pTable);
                }
                card_caught.nCardNO = pTable->GetCardNO(card_caught.nCardID);
                card_caught.dwFlags = pTable->CalcHu_Zimo(chairno, card_caught.nCardID);
            }
            else
            {
                card_caught.nCardID = INVALID_OBJECT_ID;
                card_caught.nCardNO = INVALID_OBJECT_ID;
            }

            pTable->m_dwCheckBreakTime[chairno] = GetTickCount();
            //pTable->m_dwWaitOperateTick = (pTable->m_nThrowWait + SVR_WAIT_SECONDS) * 1000;
            pTable->m_dwWaitOperateTick = (10 + SVR_WAIT_SECONDS) * 1000;
            CBuffer buff;
            buff.Write((BYTE*)&card_caught, sizeof(CARD_CAUGHT_EX));
            if (pTable->IsTingPaiActive())
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

            if (pTable->m_ptrPlayers[chairno] && IS_BIT_SET(pTable->m_ptrPlayers[chairno]->m_nUserType, UT_HANDPHONE))
            {
                evTaskGang.notify(lpContext, pTable, userid, chairno, MJ_GANG_AN);
            }
            BOOL bRobotBout = FALSE;
            for (int j = 0; j < TOTAL_CHAIRS; j++)
            {
                if (pTable->IsRoboter(j))
                {
                    bRobotBout = True;
                }
            }
            if (bRobotBout)
            {
                OnRobotGiveUp(pRoom, pTable, chairno);
            }
            // end
        }
    }
    return TRUE;
}

BOOL CMyGameServer::OnReconsPnGangCard(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt)
{
    LOG_TRACE(_T("CMyGameServer::OnReconsPnGangCard"));
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
    CMyGameTable* pTable = NULL;
    if (!(pRoom = GetRoomPtr(roomid)))
    {
        return NotifyResponseFaild(lpContext, bPassive);
    }
    if (!(pTable = (CMyGameTable*)GetTablePtr(roomid, tableno)))
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

        // xzmo change
        int nCardID = pTable->GetGangCardEx(chairno);

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
            // xzmo add
            pTable->ResetMultiHuInfo();
            pTable->OnPnGang(pGangCard);
            LOG_DEBUG(_T("***********ROBOT_BOUT_LOG_PNGANG***********roomid:%d, tableno:%d, userid:%d, chairno:%d, cardchair:%d, cardid:%s, baseid[0]:%s, baseid[1]:%s, baseid[2]:%s"), roomid, tableno, userid,
                chairno, cardchair, pTable->RobotBoutLog(pGangCard->nCardID), pTable->RobotBoutLog(pGangCard->nBaseIDs[0]), pTable->RobotBoutLog(pGangCard->nBaseIDs[1]), pTable->RobotBoutLog(pGangCard->nBaseIDs[2]));
            CreateRobotTimer(pRoom, pTable, pTable->m_dwStatus, pTable->m_nThrowWait * 1000);
            PreSaveResult(lpContext, (CMyGameTable*)pTable, roomid, ResultByPnGang, chairno);

            CARD_CAUGHT_EX card_caught;
            ZeroMemory(&card_caught, sizeof(card_caught));
            card_caught.nChairNO = chairno;
            memcpy(card_caught.nGangPoint, pTable->m_GangPoint, sizeof(card_caught.nGangPoint));

            BOOL bIsAllGiveUp = pTable->IsAllPlayerGiveUp();
            if (bIsAllGiveUp)
            {
                BOOL bBuHua = FALSE;
                card_caught.nCardID = pTable->GetGangCard(chairno, bBuHua);
                NotifySomeOneBuHua(pTable);
                LOG_DEBUG(_T("***********ROBOT_BOUT_LOG_PNGANG_CATCH***********roomid:%d, tableno:%d, chairno:%d, userid:%d, cardid:%s"), roomid, tableno, chairno, userid, pTable->RobotBoutLog(card_caught.nCardID));
                card_caught.nCardNO = pTable->GetCardNO(card_caught.nCardID);
                card_caught.dwFlags = pTable->CalcHu_Zimo(chairno, card_caught.nCardID);
            }
            else
            {
                card_caught.nCardID = INVALID_OBJECT_ID;
                card_caught.nCardNO = INVALID_OBJECT_ID;
            }

            pTable->m_dwCheckBreakTime[chairno] = GetTickCount();
            pTable->m_dwWaitOperateTick = (pTable->m_nThrowWait + SVR_WAIT_SECONDS) * 1000;

            CBuffer buff;
            buff.Write((BYTE*)&card_caught, sizeof(CARD_CAUGHT_EX));
            if (pTable->IsTingPaiActive())
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
            if (pTable->m_ptrPlayers[chairno] && pTable->m_ptrPlayers[chairno]->m_nUserID > 0 && IS_BIT_SET(pTable->m_ptrPlayers[chairno]->m_nUserType, UT_HANDPHONE))
            {
                //新手任务
                evTaskGang.notify(lpContext, pTable, userid, chairno, MJ_GANG_PN);
            }
            BOOL bRobotBout = FALSE;
            for (int j = 0; j < TOTAL_CHAIRS; j++)
            {
                if (pTable->IsRoboter(j))
                {
                    bRobotBout = True;
                }
            }
            if (bRobotBout)
            {
                OnRobotGiveUp(pRoom, pTable, chairno);
            }
        }
        // end
    }
    return TRUE;
}

BOOL CMyGameServer::OnHuCard(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt)
{
    LOG_TRACE(_T("CMyGameServer::OnHuCard"));
    SAFETY_NET_REQUEST(lpRequest, HU_CARD, pHuCard);
    REQUEST response;
    memset(&response, 0, sizeof(response));

    LONG token = 0;
    int roomid = 0;
    int tableno = INVALID_OBJECT_ID;
    int userid = 0;
    int chairno = INVALID_OBJECT_ID;
    int cardchair = INVALID_OBJECT_ID;
    int r_id = 0;
    int t_no = INVALID_OBJECT_ID;
    int u_id = 0;
    int c_no = INVALID_OBJECT_ID;
    BOOL lookon = FALSE;

    CRoom* pRoom = NULL;
    CMyGameTable* pTable = NULL;
    CPlayer* pPlayer = NULL;

    token = lpContext->lTokenID;
    roomid = pHuCard->nRoomID;
    tableno = pHuCard->nTableNO;
    userid = pHuCard->nUserID;
    chairno = pHuCard->nChairNO;
    cardchair = pHuCard->nCardChair;

    BOOL bPassive = FALSE;
    pRoom = GetRoomPtr(roomid);
    pTable = GetTablePtr(roomid, tableno);
    if (pTable)
    {
        LOCK_TABLE(pTable, chairno, FALSE, userid, token);

        int nTempForCatch = 0;
        try
        {
            if (!pTable->IsPlayer(userid)) // 不是玩家
            {
                LOG_TRACE(_T("user not player. user %ld hu card failed."), userid);
                response.head.nRequest = UR_OPERATE_FAILED;
                return SendUserResponse(lpContext, &response, bPassive);
            }
            nTempForCatch = 1;
            if (!IS_BIT_SET(pTable->m_dwStatus, TS_PLAYING_GAME)) // 游戏未在进行中
            {
                response.head.nRequest = UR_OPERATE_FAILED;
                return SendUserResponse(lpContext, &response, bPassive);
            }
            nTempForCatch = 2;
            if (!pTable->ValidateChair(chairno) || !pTable->ValidateChair(cardchair))
            {
                response.head.nRequest = UR_OPERATE_FAILED;
                return SendUserResponse(lpContext, &response, bPassive);
            }
            nTempForCatch = 3;

            if (!pTable->ValidateMultiHu(pHuCard))
            {
                LOG_TRACE("OnHuCard ValidateMultiHu, chairno is %d", chairno);
                response.head.nRequest = UR_OPERATE_CANCEL;
                return SendUserResponse(lpContext, &response, bPassive);
            }

            nTempForCatch = 4;
            if (!pTable->ValidateHu(pHuCard))
            {
                if (pTable->m_bOpenSaveResultLog)
                {
                    LOG_TRACE("OnHuCard ValidateHu, chairno is %d", chairno);
                }
                response.head.nRequest = UR_OPERATE_FAILED;
                return SendUserResponse(lpContext, &response, bPassive);
            }

            int nHuCount = 0;
            BOOL bAlreadyHu = pTable->m_HuReady[chairno];
            if (pTable->IsXueLiuRoom())
            {
                bAlreadyHu = FALSE;
            }
            nTempForCatch = 5;

            if (!bAlreadyHu)
            {
                nHuCount = pTable->OnHu(pHuCard);
                LOG_DEBUG(_T("***********ROBOT_BOUT_LOG_HU***********roomid:%d, tableno:%d, userid:%d, chairno:%d, cardchair:%d, cardid:%s"), roomid, tableno, userid, chairno, cardchair,
                    pTable->RobotBoutLog(pHuCard->nCardID));
            }
            nTempForCatch = 6;

            BOOL bTemp = pTable->m_HuReady[chairno];
            if (pTable->IsXueLiuRoom())
            {
                bTemp = (nHuCount > 0) && (pTable->m_HuReady[chairno]);
            }
            if (bTemp)
            {
                nTempForCatch = 7;
                int nRet = pTable->ShouldHuCardWait(pHuCard);
                if (nRet == 1)
                {
                    response.head.nRequest = GR_WAIT_FEW_SECONDS;
                    return SendUserResponse(lpContext, &response, bPassive);
                }
                else if (nRet == 2)
                {
                    OnServerChiPengGangCard(pRoom, pTable);
                }

                nTempForCatch = 8;
                response.head.nRequest = UR_OPERATE_SUCCEEDED;
                SendUserResponse(lpContext, &response, bPassive);

                if (nHuCount > 0)
                {
                    nTempForCatch = 9;
                    pTable->OnHuAfterWait(pHuCard, nHuCount);
                }
                nTempForCatch = 10;

                BOOL bOverTime = pTable->OverTimeMultiHu(cardchair);

                pTable->ResetMultiHuInfo();
                for (int i = 0; i < TOTAL_CHAIRS; i++)
                {
                    if ((bOverTime && IS_BIT_SET(pTable->m_dwPGCHFlags[i], MJ_HU) && (pTable->m_HuReady[i] && pTable->m_HuReady[i] != MJ_GIVE_UP) && pTable->OnHuFang(i, cardchair, pHuCard->nCardID))
                        || (!bOverTime && pTable->m_HuReady[i] && pTable->m_HuMJID[i] == pHuCard->nCardID))
                    {
                        LOG_DEBUG(_T("***********ROBOT_BOUT_LOG_HU***********roomid:%d, tableno:%d, userid:%d, chairno:%d, cardchair:%d, cardid:%s, bOverTime: %d"), roomid, tableno, userid, chairno, cardchair, pTable->RobotBoutLog(pHuCard->nCardID), bOverTime);

                        pTable->CalcHuPoints(i, cardchair, pHuCard->nCardID);

                        CPlayer* pPlayerHuTemp = pTable->m_ptrPlayers[i];
                        if (pPlayerHuTemp && pPlayerHuTemp->m_nUserID > 0 && IS_BIT_SET(pPlayerHuTemp->m_nUserType, UT_HANDPHONE))
                        {
                            int nHuFan = pTable->m_nResults[i] - g_nHuGains[HU_GAIN_BASE];
                            // task
                            evTaskHu.notify(lpContext, pTable, pPlayerHuTemp->m_nUserID, i, pTable->m_HuReady[i], nHuFan);
                        }

                        //胡番倍数统计
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

                        NotifyTablePlayers(pTable, GR_SYSTEMMSG, &PlayerHu, sizeof(SYSTEMMSG), 0);
                        NotifyTableVisitors(pTable, GR_SYSTEMMSG, &PlayerHu, sizeof(SYSTEMMSG), 0);
                    }
                }
                nTempForCatch = 11;
                pTable->FinishHu(cardchair, chairno, pHuCard->nCardID);
                nTempForCatch = 12;
            }
            else
            {
                response.head.nRequest = pTable->GetFailedResponse(chairno);
                return SendUserResponse(lpContext, &response, bPassive);
            }

            nTempForCatch = 13;
            nTempForCatch = 14;

            DWORD dwWinFlags = pTable->CalcWinOnHu(chairno);
            nTempForCatch = 15;
            if (dwWinFlags)
            {

                for (int i = 0; i < TOTAL_CHAIRS; i++)
                {
                    if (pTable->m_HuReady[i] && pTable->m_HuMJID[i] == pHuCard->nCardID)
                    {
                        pTable->m_bLastHuChairs[i] = TRUE;
                    }
                }

                if (pTable->IsXueLiuRoom())
                {
                    nTempForCatch = 16;
                    pTable->m_bLastGang = FALSE;
                    pTable->CalcWinOnStandOff(-1);
                    nTempForCatch = 17;
                    OnGameWin(lpContext, pRoom, pTable, chairno, FALSE, roomid);
                    nTempForCatch = 18;
                }
                else
                {
                    nTempForCatch = 19;
                    pTable->m_bLastGang = FALSE;
                    nTempForCatch = 20;
                    OnGameWin(lpContext, pRoom, pTable, chairno, FALSE, roomid);
                    nTempForCatch = 21;
                }
            }
            else
            {
                nTempForCatch = 22;
                //XL 胡实时结算
                PreSaveResult(lpContext, pTable, roomid, ResultByHu, pHuCard->nChairNO);
                nTempForCatch = 24;

                BOOL bIsAllGiveUp = pTable->IsAllPlayerGiveUp();
                if (bIsAllGiveUp)
                {
                    int nCurrentChair = pTable->GetCurrentChair();
                    pTable->RemoveStatusOnGiveUp();
                    pTable->m_dwCheckBreakTime[nCurrentChair] = GetTickCount();
                    pTable->m_dwWaitOperateTick = (pTable->m_nPGCHWait + SVR_WAIT_SECONDS) * 1000;
                    NotifyNextTurn(pTable, nCurrentChair);
                    nTempForCatch = 25;
                }
                nTempForCatch = 26;

                pTable->ResetWaitOpe();

                //掉线自动抓牌
                if (pTable->IsOffline(pTable->GetCurrentChair()))
                {
                    OnServerAutoPlay(pRoom, pTable, pTable->GetCurrentChair(), !pTable->IsOffline(pTable->GetCurrentChair()));
                }
                nTempForCatch = 23;

                if (!pTable->IsXueLiuRoom())
                {
                    CPlayer* pTmpPlayer = pTable->m_ptrPlayers[chairno];
                    if (pTmpPlayer && IS_BIT_SET(pTmpPlayer->m_nUserType, UT_HANDPHONE))
                    {
                        evWinDeposit.notify(lpContext, pTable, pTmpPlayer->m_nUserID ,chairno);
                        // task
                    }
                }
                //微信任务
                for (int i = 0; i < TOTAL_CHAIRS; i++)
                {
                    if (!pTable->IsXueLiuRoom())
                    {
                        CPlayer* pTmpPlayer = pTable->m_ptrPlayers[i];
                        if (pTmpPlayer && pTable->m_HuReady[i] && pTable->m_HuMJID[i] == pHuCard->nCardID)
                        {
                            // task
                            // WxTask_Win(lpContext, pTable, pTmpPlayer->m_nUserID, i);
                        }
                    }
                    if (pTable->m_HuReady[i] && pTable->m_HuMJID[i] == pHuCard->nCardID)
                    {
                        // task
                        evWxTaskHu.notify(lpContext, pTable, i);
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
                                SetServerMakeCardInfo(pTable, i);

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
                                    pTable->FillUpGameWinCheckInfos(pData, nEndLen, i);
                                    int nGamePlayerInfoOffset = pTable->GetGameWinSize() + sizeof(HU_ITEM_HEAD)
                                        + pTable->GetTotalItemCount(i) * sizeof(HU_ITEM_INFO) + sizeof(GAMEEND_CHECK_INFO);
                                    pTable->FillupGameStartPlayerInfo(pData, nGamePlayerInfoOffset);

                                    NotifyOneUser(pPlayer->m_hSocket, pPlayer->m_lTokenID, GR_ON_PLAYER_HU, pData, nLen);
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
                                                NotifyOneUser(ptrV->m_hSocket, ptrV->m_lTokenID, GR_ON_PLAYER_HU, pDataVisitor, nLenVisitor);
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

                                    NotifyOneUser(pPlayer->m_hSocket, pPlayer->m_lTokenID, GR_ON_PLAYER_HU, pData, nLen);
                                    NotifyChairVisitors(pTable, i, GR_ON_PLAYER_HU, pData, nLen);
                                    SAFE_DELETE(pData);
                                }
                            }
                        }
                    }
                }
            }
        }
        catch (...)
        {
            UwlLogFile(_T("The Exception hu nTempForCatch:%d"), nTempForCatch);
        }
    }
    return TRUE;
}

void CMyGameServer::OnGetDepositOK(CTable* pTable, int chairno)
{
    CMyGameTable* pGameTable = (CMyGameTable*)pTable;
    if (pGameTable->OnPlayerNotGiveUp(chairno))
    {
        if (pGameTable->IsAllPlayerGiveUp())
        {
            pGameTable->RemoveStatusOnGiveUp();
            NotifyNextTurn(pTable, pTable->GetCurrentChair());
            if (pTable->IsRoboter(pTable->GetCurrentChair()))
            {
                CRoom* pRoom = NULL;
                pRoom = GetRoomPtr(pTable->m_nRoomID);
                if (pRoom)
                {
                    OnRobotAIPlay(pRoom, pTable, pTable->GetCurrentChair());
                }
            }
        }
    }
}

void CMyGameServer::OnServerChiPengGangCard(CRoom* pRoom, CMJTable* pTable)
{
    CMyGameTable* pGameTable = (CMyGameTable*)pTable;
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
    // zxmo add
    int nMsgID = -1;
    if (pGameTable->m_nWaitOpeMsgID == GR_RECONS_FANGPAO)
    {
        nMsgID = LOCAL_GAME_MSG_AUTO_HU;
    }

    if (nMsgID != -1)
    {
        DWORD dwTickWait = GetPrivateProfileInt(_T("AutoCPGHWait"), _T("WaitTime"), 100, m_szIniFile);
        SimulateGameMsgFromUser(nRoomID, pPlayer, nMsgID, sizeof(COMB_CARD), &MsgData, dwTickWait);
    }
    // end
    return __super::OnServerChiPengGangCard(pRoom, pTable);
}

BOOL CMyGameServer::OnStartGameEx(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt)
{
    REQUEST response;
    memset(&response, 0, sizeof(response));

    LONG token = 0;
    int roomid = 0;
    int tableno = INVALID_OBJECT_ID;
    int userid = 0;
    int chairno = INVALID_OBJECT_ID;
    int r_id = 0;
    int t_no = INVALID_OBJECT_ID;
    int u_id = 0;
    int c_no = INVALID_OBJECT_ID;

    CTable* pTable = NULL;
    CPlayer* pPlayer = NULL;

    token = lpContext->lTokenID;

    SAFETY_NET_REQUEST(lpRequest, START_GAME, pStartGame);
    roomid = pStartGame->nRoomID;
    tableno = pStartGame->nTableNO;
    userid = pStartGame->nUserID;
    chairno = pStartGame->nChairNO;

    BOOL bPassive = IS_BIT_SET(lpContext->dwFlags, CH_FLAG_SYSTEM_EJECT);
    response.head.nRequest = UR_OPERATE_FAILED;

    pTable = GetTablePtr(roomid, tableno);
    if (pTable)
    {
        LOCK_TABLE(pTable, chairno, FALSE, userid, token);

        if (!pTable->IsPlayer(userid)) // 不是玩家
        {
            UwlLogFile(_T("user not player. user %ld start game failed."), userid);
            return SendUserResponse(lpContext, &response, bPassive);
        }

        if (IS_BIT_SET(pTable->m_dwStatus, TS_PLAYING_GAME)) // 游戏进行中
        {
            return SendUserResponse(lpContext, &response, bPassive);
        }

        if (IS_BIT_SET(pTable->m_dwUserStatus[chairno], US_GAME_STARTED)) // 已经开始
        {
            return SendUserResponse(lpContext, &response, bPassive);
        }

        if (IS_BIT_SET(pTable->m_dwUserStatus[chairno], US_USER_WAITNEWTABLE)) // 已经进入分桌队列
        {
            return SendUserResponse(lpContext, &response, bPassive);
        }
        if (userid == pTable->m_nSrcSwaperId || userid == pTable->m_nDesSwaperId) // 正在交换中不能准备
        {
            return SendUserResponse(lpContext, &response, bPassive);
        }

        BOOL bSoloRoom = IsSoloRoom(roomid);
        BOOL bRandomRoom = IsRandomRoom(roomid);

        if (!VerifyRoomTableChair(roomid, tableno, chairno, userid)) // 该位置上用户不匹配
        {
            return SendUserResponse(lpContext, &response, bPassive);
        }

        if (!PlayerCanArenaMatchOnStart(roomid, userid, pStartGame))
        {
            return SendUserResponse(lpContext, &response, bPassive);
        }
        //是否专家号受限
        CString sRet;
        if (CheckAccountBillingLimit(userid, sRet))
        {
            response.head.nRequest = GR_ERROR_INFOMATION_EX;
            response.pDataPtr = (LPVOID)LPCTSTR(sRet);
            response.nDataLen = sRet.GetLength() + 1;
            return SendUserResponse(lpContext, &response, bPassive);
        }
        if (IsYQWRoom(roomid))
        {
            YQW_PLAYER yqwPlayer;
            ZeroMemory(&yqwPlayer, sizeof(yqwPlayer));
            if (!YQW_LookupPlayer(userid, yqwPlayer))
            {
                pPlayer = pTable->m_ptrPlayers[chairno];
                if (pPlayer)
                {
                    (void)EjectLeaveGameEx(userid, roomid, tableno, chairno, pPlayer->m_hSocket, pPlayer->m_lTokenID);
                }
                response.head.nRequest = UR_OPERATE_FAILED;
                return SendUserResponse(lpContext, &response);
            }
        }
        //
        if (bSoloRoom)
        {
            if (IsLeaveAlone(roomid))
            {
                //solo独离房, 按下开始时, 判断银子是否在房间限定范围内,否则返回超出银两值
                //add by thg, 20130802
                pPlayer = pTable->m_ptrPlayers[chairno];
                if (pPlayer && IsNeedDepositRoom(roomid))
                {
                    //检查银两最低要求
                    BOOL bDepositNotEnough = FALSE;
                    int nMinDeposit = 0;
                    if (IsCheckDepositMin(roomid))
                    {
                        nMinDeposit = GetMinDeposit(roomid);
                        if (pPlayer->m_nDeposit < nMinDeposit) //银子不够
                        {
                            bDepositNotEnough = TRUE;
                        }
                    }
                    else
                    {
                        nMinDeposit = GetMinPlayingDeposit(pTable, roomid);
                        if (pPlayer->m_nDeposit < nMinDeposit) //银子不够
                        {
                            bDepositNotEnough = TRUE;
                        }
                    }
                    if (bDepositNotEnough)
                    {
                        DEPOSIT_NOT_ENOUGH dne;
                        memset(&dne, 0, sizeof(dne));
                        dne.nUserID = userid;
                        dne.nChairNO = chairno;
                        dne.nDeposit = pPlayer->m_nDeposit;
                        dne.nMinDeposit = nMinDeposit;

                        response.head.nRequest = GR_RESPONE_DEPOSIT_NOTENOUGH;
                        response.nDataLen = sizeof(dne);
                        response.pDataPtr = &dne;
                        return SendUserResponse(lpContext, &response);
                    }

                    //检查银两是否超出
                    if (IsCheckDepositMax(roomid))
                    {
                        int nMaxDeposit = GetMaxDeposit(roomid); //银子超出
                        if (nMaxDeposit < pPlayer->m_nDeposit)
                        {
                            DEPOSIT_TOO_HIGH dth;
                            memset(&dth, 0, sizeof(dth));
                            dth.nUserID = userid;
                            dth.nChairNO = chairno;
                            dth.nDeposit = pPlayer->m_nDeposit;
                            dth.nMaxDeposit = nMaxDeposit;

                            response.head.nRequest = GR_RESPONE_DEPOSIT_TOOHIGH;
                            response.nDataLen = sizeof(dth);
                            response.pDataPtr = &dth;
                            return SendUserResponse(lpContext, &response, bPassive);
                        }
                    }
                }
            }
            // xzmo 新增m_nextAskNewTable
            CMyGameTable* gameTable = (CMyGameTable*)pTable;
            if (bRandomRoom
                && (gameTable->m_nextAskNewTable    //中途有人强退
                    || pTable->IsFirstBout()
                    || (IsLeaveAlone(roomid)
                        && IsNeedWaitArrageTable(pTable, roomid, userid)))) //已经达到桌局数上限，那么重新向RoomSvr请求分桌
            {
                pPlayer = pTable->m_ptrPlayers[chairno];

                CheckResumeTeam(pTable, false);
                if (pPlayer && pPlayer->m_bTeamMember)
                {
                    response.head.nRequest = UR_OPERATE_SUCCEEDED;
                    SendUserResponse(lpContext, &response);
                    return TRUE;
                }

                pTable->m_dwUserStatus[chairno] |= US_USER_WAITNEWTABLE;
                PostAskNewTable(userid, roomid, tableno, chairno);

                pPlayer = pTable->m_ptrPlayers[chairno];
                if (pPlayer)
                {
                    NotifyOneUser(pPlayer->m_hSocket, pPlayer->m_lTokenID, GR_WAIT_NEWTABLE, NULL, 0);
                }

                response.head.nRequest = UR_OPERATE_SUCCEEDED;
                return SendUserResponse(lpContext, &response, bPassive);
            }
        }

        response.head.nRequest = UR_OPERATE_SUCCEEDED;
        (void)SendUserResponse(lpContext, &response, bPassive);
        if (IS_BIT_SET(GetGameOption(roomid), GO_NOT_VERIFYSTART))
        {
            (void)OnUserStart(pTable, chairno);
        }
        else
        {
            PostVerifyStart(userid, roomid, tableno, chairno);
        }
    }

    return TRUE;
}

BOOL CMyGameServer::OnLeaveGameEx(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt)
{
    REQUEST response;
    memset(&response, 0, sizeof(response));

    GAME_ABORT GameAbort;
    ZeroMemory(&GameAbort, sizeof(GameAbort));

    int roomid = 0;
    int tableno = INVALID_OBJECT_ID;
    int userid = 0;
    int chairno = INVALID_OBJECT_ID;
    int r_id = 0;
    int t_no = INVALID_OBJECT_ID;
    int u_id = 0;
    int c_no = INVALID_OBJECT_ID;

    CTable* pTable = NULL;
    CPlayer* pPlayer = NULL;

    SAFETY_NET_REQUEST(lpRequest, LEAVE_GAME, pLeaveGame);
    roomid = pLeaveGame->nRoomID;
    tableno = pLeaveGame->nTableNO;
    userid = pLeaveGame->nUserID;
    chairno = pLeaveGame->nChairNO;

    LPSENDER_INFO pSenderInfo = LPSENDER_INFO(&(pLeaveGame->sender_info));

    BOOL bPassive = IS_BIT_SET(lpContext->dwFlags, CH_FLAG_SYSTEM_EJECT);

    int sendtable = pSenderInfo->nSendTable;
    int sendchair = pSenderInfo->nSendChair;
    int senduser = pSenderInfo->nSendUser;
    LONG token = lpContext->lTokenID;

    //在结算 不能散桌
    if (NeedLeaveWaitGameWin(roomid, tableno, chairno, userid, token))
    {
        response.head.nRequest = GR_WAIT_CHECKRESULT;
        return SendUserResponse(lpContext, &response, bPassive);
    }

    pTable = GetTablePtr(roomid, tableno);
    if (pTable)
    {
        LOCK_TABLE(pTable, chairno, bPassive, senduser, token);

        if (pTable->m_nRoomID != roomid)
        {
            UwlLogFile(_T("table.roomid %ld != leave.roomid %ld, tableno = %ld, chairno = %ld. leavegame failed."),
                pTable->m_nRoomID, roomid, tableno, chairno);
            response.head.nRequest = UR_OPERATE_FAILED;
            return SendUserResponse(lpContext, &response, bPassive);
        }
        pTable->m_mapUser.Lookup(userid, pPlayer);
        if (!pPlayer || !pPlayer->m_nUserID)
        {
            response.head.nRequest = UR_OPERATE_FAILED;
            return SendUserResponse(lpContext, &response, bPassive);
        }
        if (!VerifySenderInfo(pTable, pSenderInfo))
        {
            UwlLogFile(_T("verify sender_info failed! roomid = %ld, tableno = %ld, chairno = %ld, userid = %ld, sendtable = %ld, sendchair = %ld, senduser = %ld"),
                roomid, tableno, chairno, userid, sendtable, sendchair, senduser);
            response.head.nRequest = UR_OPERATE_FAILED;
            return SendUserResponse(lpContext, &response, bPassive);
        }
        if (pTable->IsPlayer(userid)) // 玩家离开
        {
            CPlayer* ptrP = pTable->m_ptrPlayers[chairno];
            if (!ptrP)
            {
                response.head.nRequest = UR_OPERATE_FAILED;
                return SendUserResponse(lpContext, &response, bPassive);
            }
            if (userid != ptrP->m_nUserID)
            {
                UwlLogFile(_T("leave userid not matched! roomid = %ld, tableno = %ld, chairno = %ld, userid = %ld, actualid = %ld"),
                    roomid, tableno, chairno, userid, ptrP->m_nUserID);
                response.head.nRequest = UR_OPERATE_FAILED;
                return SendUserResponse(lpContext, &response, bPassive);
            }
            GameAbort.nUserID = userid;
            GameAbort.nChairNO = chairno;
            GameAbort.nOldScore = pPlayer->m_nScore;
            GameAbort.nOldDeposit = pPlayer->m_nDeposit;
            GameAbort.nTableNO = pTable->m_nTableNO;

            //
            //新手任务

            // 判断是否要逃跑扣分
            int leastbout = GetBoutLeast();
            int leastround = GetPrivateProfileInt(
                    _T("round"),        // section name
                    _T("least"),    // key name
                    0,              // default int
                    m_szIniFile     // initialization file name
                );
            int breakwait = GetPrivateProfileInt(
                    _T("break"),        // section name
                    _T("wait"),         // key name
                    DEF_BREAK_WAIT,     // default int
                    m_szIniFile         // initialization file name
                );
            int defdouble = GetPrivateProfileInt(
                    _T("break"),        // section name
                    _T("double"),       // key name
                    DEF_BREAK_DOUBLE,   // default int
                    m_szIniFile         // initialization file name
                );
            int max_bouttime = GetBoutTimeMax();

            TCHAR szRoomID[16];
            memset(szRoomID, 0, sizeof(szRoomID));
            _stprintf_s(szRoomID, _T("%ld"), pTable->m_nRoomID);

            int least_entertable = GetPrivateProfileInt(
                    _T("KeepStartedSecond"),        // section name
                    szRoomID,       // key name
                    0,  // default int
                    m_szIniFile     // initialization file name
                );

            //判断是不是强退
            /////////////////////////////////////////////////////////////////////////
            BOOL bAsBreak = pTable->LeaveAsBreak(leastbout, leastround);

            //可变桌椅空闲玩家退出不算强退
            if (IsVariableChairRoom(roomid)
                && pTable->m_ptrPlayers[chairno]
                && pTable->m_ptrPlayers[chairno]->m_bIdlePlayer)
            {
                bAsBreak = FALSE;
            }

            int breakchair = -1;
            if (bAsBreak)
            {
                breakchair = pTable->TellBreakChair(chairno, breakwait);
            }
            ////////////////////////////////////////////////////////////////////////////

            if (!bPassive
                && IS_BIT_SET(pTable->m_dwStatus, TS_PLAYING_GAME)
                && pTable->m_bForbidDesert
                && bAsBreak
                && breakchair == chairno) //随机Solo房间禁止主动强退，其他人超时后可以退出
            {
                //游戏中不能退出
                response.head.nRequest = GR_LEAVEGAME_PLAYING;
                return SendUserResponse(lpContext, &response, bPassive);
            }

            DWORD dwEnterTime = GetTickCount() - pTable->m_dwFirstEnter[chairno];
            if (IsSoloRoom(roomid)              //增加solo房间判断，因为普通房间游戏也要会发送LeaveGameEx
                && !bPassive
                && dwEnterTime <= least_entertable * 1000
                && pTable->IsFirstBout()) //玩过一局以后总是可以退出了。
            {
                //太快退出
                response.head.nRequest = GR_LEAVEGAME_TOOFAST;
                response.pDataPtr = new int;
                *(int*)response.pDataPtr = (least_entertable * 1000 - dwEnterTime) / 1000 + 1;
                response.nDataLen = sizeof(int);

                SendUserResponse(lpContext, &response, bPassive);
                UwlClearRequest(&response);
                return TRUE;
            }

            if (bAsBreak && -1 != breakchair
                && pTable->m_ptrPlayers[breakchair])
            {
                //强退 // 增加m_ptrPlayers[breakchair]检查，如果为空，直接散桌，不扣分    //Add on 20121217 by chenyang
                if (!IsVariableChairRoom(roomid))
                {
                    TransmitBreakResult(lpContext, pTable, ptrP, GameAbort, breakchair, max_bouttime, defdouble);
                }
                else
                {
                    TransmitBreakResultEx(lpContext, pTable, ptrP, GameAbort, breakchair, max_bouttime, defdouble);
                }
            }

            if (!bAsBreak
                && IsSoloRoom(roomid)) //Solo模式
            {
                BOOL bLeaveAlone = IsLeaveAlone(roomid);
                BOOL bRandomRoom = IsRandomRoom(roomid);
                BOOL bFirstBount = pTable->IsFirstBout(); //第一局，还没有正式开始游戏

                if (bFirstBount || bLeaveAlone)
                {
                    // xzmo 新增
                    if (!IsCloakingRoom(roomid) && IS_BIT_SET(pTable->m_dwStatus, TS_PLAYING_GAME) && ((CMyGameTable*)pTable)->m_stAbortPlayerInfo[GameAbort.nChairNO].nUserID <= 0)
                    {
                        SOLO_PLAYER soloPlayer;
                        memset(&soloPlayer, 0, sizeof(SOLO_PLAYER));
                        LookupSoloPlayer(pPlayer->m_nUserID, soloPlayer);

                        soloPlayer.nDeposit = GameAbort.nOldDeposit;
                        ((CMyGameTable*)pTable)->saveAbortPlayerInfo(soloPlayer);
                    }
                    // end
                    RemoveOneClients(pTable, userid, FALSE);

                    if (!IsCloakingRoom(roomid))
                    {
                        NotifyTablePlayers(pTable, GR_PLAYER_ABORT, &GameAbort, sizeof(GameAbort));
                    }

                    NotifyTableVisitors(pTable, GR_PLAYER_ABORT, &GameAbort, sizeof(GameAbort));


                    if (IsVariableChairRoom(roomid)
                        && pTable->m_ptrPlayers[chairno]
                        && pTable->m_ptrPlayers[chairno]->m_bIdlePlayer
                        && !pTable->IsGameOver())
                    {
                        //空闲玩家离开不清空桌子
                        pTable->PlayerLeave(userid);
                    }
                    else
                    {
                        pTable->PlayerLeave(userid);
                        pTable->ResetTable();
                    }

                    OnGameLeft(userid, roomid, tableno, chairno);
                    OnChangeHomeUserID(roomid, pTable);
                    TryFreeEMChatID(pTable);

                    if (bRandomRoom && bLeaveAlone && !bFirstBount)
                    {
                        CMyGameTable* gameTable = (CMyGameTable*)pTable;
                        if (gameTable->IsGameOver())
                        {
                            //随机分桌模式中，如果至少玩过一局后
                            //有玩家退出,需要把其他已经按下开始键的玩家重新加入等待分桌序列。
                            for (int i = 0; i < pTable->m_nTotalChairs; i++)
                            {
                                CPlayer* pStartedPlayer = pTable->m_ptrPlayers[i];
                                if (pStartedPlayer
                                    && IS_BIT_SET(pTable->m_dwUserStatus[i], US_GAME_STARTED))
                                {
                                    if (pStartedPlayer->m_bTeamMember)
                                    {
                                        continue;    // 队员不管
                                    }
                                    pTable->m_dwUserStatus[i] &= ~US_GAME_STARTED; //去掉准备状态
                                    pTable->m_dwUserStatus[i] |= US_USER_WAITNEWTABLE; //pengsy
                                    PostAskNewTable(pStartedPlayer->m_nUserID, roomid, tableno, i);
                                    NotifyOneUser(pStartedPlayer->m_hSocket, pStartedPlayer->m_lTokenID, GR_WAIT_NEWTABLE, NULL, 0);
                                }
                            }
                        }
                        else   // xzmo 新增 m_nextAskNewTable
                        {
                            gameTable->m_nextAskNewTable = TRUE;
                        }
                    }

                    //自由人数模式，游戏未开始时退出，必要时终止倒计时
                    if (IsVariableChairRoom(roomid)
                        && pTable->IsGameOver()
                        && pTable->IsNeedCountdown())
                    {
                        int  startcount = XygGetStartCount(pTable->m_dwUserStatus, pTable->m_nTotalChairs);
                        BOOL bAllowStartGame = IsAllowStartGame(pTable, startcount);
                        BOOL bInCountdown = pTable->IsInCountDown();
                        if (!bAllowStartGame && bInCountdown)
                        {
                            //结束倒计时
                            START_COUNTDOWN  sc;
                            memset(&sc, 0, sizeof(START_COUNTDOWN));
                            sc.nUserID = userid;
                            sc.nRoomID = roomid;
                            sc.nTableNO = tableno;
                            sc.nChairNO = chairno;
                            sc.bStartorStop = FALSE;
                            pTable->SetCountDown(FALSE);
                            NotifyTablePlayers(pTable, GR_START_COUNTDOWN, &sc, sizeof(START_COUNTDOWN));
                        }
                    }
                }
                else
                {
                    RemoveClients(pTable, 0, FALSE);

                    NotifyTablePlayers(pTable, GR_GAME_ABORT, &GameAbort, sizeof(GameAbort));
                    NotifyTableVisitors(pTable, GR_GAME_ABORT, &GameAbort, sizeof(GameAbort));

                    pTable->Reset(); // 清空桌子
                }
            }
            else//非Solo模式或强退
            {
                RemoveClients(pTable, 0, FALSE);

                NotifyTablePlayers(pTable, GR_GAME_ABORT, &GameAbort, sizeof(GameAbort));
                NotifyTableVisitors(pTable, GR_GAME_ABORT, &GameAbort, sizeof(GameAbort));

                pTable->Reset(); // 清空桌子
            }
        }
        else if (pTable->IsVisitor(userid))  // 旁观者离开
        {
            LOOKON_ABORT LookOnAbort;
            ZeroMemory(&LookOnAbort, sizeof(LookOnAbort));
            LookOnAbort.nUserID = userid;
            LookOnAbort.nChairNO = chairno;

            NotifyTablePlayers(pTable, GR_LOOKON_ABORT, &LookOnAbort, sizeof(LookOnAbort));
            NotifyTableVisitors(pTable, GR_LOOKON_ABORT, &LookOnAbort, sizeof(LookOnAbort));

            pTable->VisitorLeave(userid, chairno);
        }
    }

    response.head.nRequest = UR_OPERATE_SUCCEEDED;
    return SendUserResponse(lpContext, &response, bPassive);
}

BOOL CMyGameServer::OnAskRandomTable(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt)
{
    REQUEST response;
    memset(&response, 0, sizeof(response));

    SOCKET sock = INVALID_SOCKET;
    LONG token = 0;
    int gameid = 0;
    int roomid = 0;
    int tableno = INVALID_OBJECT_ID;
    int userid = 0;
    int chairno = INVALID_OBJECT_ID;
    int r_id = 0;
    int t_no = INVALID_OBJECT_ID;
    int u_id = 0;
    int c_no = INVALID_OBJECT_ID;
    LONG room_tokenid = 0;

    CTable* pTable = NULL;
    CPlayer* pPlayer = NULL;

    sock = lpContext->hSocket;
    token = lpContext->lTokenID;

    response.head.nRequest = UR_OPERATE_FAILED;

    SAFETY_NET_REQUEST(lpRequest, ASK_RANDOM_TABLE, lpAskRandTable);
    gameid = m_nGameID;
    roomid = lpAskRandTable->nRoomID;
    tableno = lpAskRandTable->nTableNO;
    userid = lpAskRandTable->nUserID;
    chairno = lpAskRandTable->nChairNO;

    if (roomid <= 0 || tableno < 0 || userid <= 0 || chairno < 0 || chairno >= MAX_CHAIR_COUNT)
    {
        return SendUserResponse(lpContext, &response);
    }

    if (!IsRandomRoom(roomid)
        || !IsLeaveAlone(roomid))
    {
        return SendUserResponse(lpContext, &response);
    }
    if (!(pTable = GetTablePtr(roomid, tableno)))
    {
        return SendUserResponse(lpContext, &response);
    }
    CString sRet;
    if (CheckAccountBillingLimit(userid, sRet))
    {
        response.head.nRequest = GR_ERROR_INFOMATION_EX;
        response.pDataPtr = (LPVOID)LPCTSTR(sRet);
        response.nDataLen = sRet.GetLength() + 1;
        return SendUserResponse(lpContext, &response);
    }
    if (pTable)
    {
        LOCK_TABLE(pTable, chairno, FALSE, userid, token);

        if (!pTable->IsPlayer(userid)) // 不是玩家
        {
            UwlLogFile(_T("user not player. user %ld ask random table failed."), userid);
            return SendUserResponse(lpContext, &response);
        }

        pPlayer = pTable->m_ptrPlayers[chairno];
        if (!pPlayer || pPlayer->m_nUserID != userid)
        {
            return SendUserResponse(lpContext, &response);
        }

        if (IS_BIT_SET(pTable->m_dwUserStatus[chairno], US_USER_WAITNEWTABLE))
        {
            return SendUserResponse(lpContext, &response);
        }

        //判断银子足够，才能加入分桌队列 add by thg, 20130809
        if (IsNeedDepositRoom(roomid))
        {
            //检查银两最低要求
            BOOL bDepositNotEnough = FALSE;
            int nMinDeposit = 0;
            if (IsCheckDepositMin(roomid))
            {
                nMinDeposit = GetMinDeposit(roomid);
                if (pPlayer->m_nDeposit < nMinDeposit) //银子不够
                {
                    bDepositNotEnough = TRUE;
                }
            }
            else
            {
                nMinDeposit = GetMinPlayingDeposit(pTable, roomid);
                if (pPlayer->m_nDeposit < nMinDeposit) //银子不够
                {
                    bDepositNotEnough = TRUE;
                }
            }
            if (bDepositNotEnough)
            {
                DEPOSIT_NOT_ENOUGH dne;
                memset(&dne, 0, sizeof(dne));
                dne.nUserID = userid;
                dne.nChairNO = chairno;
                dne.nDeposit = pPlayer->m_nDeposit;
                dne.nMinDeposit = nMinDeposit;

                response.head.nRequest = GR_RESPONE_DEPOSIT_NOTENOUGH;
                response.nDataLen = sizeof(dne);
                response.pDataPtr = &dne;
                return SendUserResponse(lpContext, &response);
            }

            //检查银两是否超出
            if (IsCheckDepositMax(roomid))
            {
                int nMaxDeposit = GetMaxDeposit(roomid); //银子超出
                if (nMaxDeposit < pPlayer->m_nDeposit)
                {
                    DEPOSIT_TOO_HIGH dth;
                    memset(&dth, 0, sizeof(dth));
                    dth.nUserID = userid;
                    dth.nChairNO = chairno;
                    dth.nDeposit = pPlayer->m_nDeposit;
                    dth.nMaxDeposit = nMaxDeposit;

                    response.head.nRequest = GR_RESPONE_DEPOSIT_TOOHIGH;
                    response.nDataLen = sizeof(dth);
                    response.pDataPtr = &dth;
                    return SendUserResponse(lpContext, &response);
                }
            }
        }
        // xzmo 新增 判断 TS_PLAYING_GAME
        if (!IS_BIT_SET(pTable->m_dwStatus, TS_PLAYING_GAME))
        {
            pTable->ResetTable(); //散桌
        }

        // 尝试回复队伍 如果我本身就是队伍成员 直接返回
        CheckResumeTeam(pTable, false);
        if (pPlayer->m_bTeamMember)
        {
            response.head.nRequest = UR_OPERATE_SUCCEEDED;
            SendUserResponse(lpContext, &response);
            return TRUE;
        }

        //随机独离模式
        //需要把已经按下开始键的玩家重新加入分桌队列
        for (int i = 0; i < pTable->m_nTotalChairs; i++)
        {
            if (i == chairno)
            {
                continue;
            }
            CPlayer* pStartPlayer = pTable->m_ptrPlayers[i];
            if (!pStartPlayer)
            {
                continue;
            }

            if (pStartPlayer->m_bTeamMember)
            {
                continue;    // 队员不管
            }
            // xzmo 新增判断
            if (!IS_BIT_SET(pTable->m_dwStatus, TS_PLAYING_GAME))
            {
                if (IS_BIT_SET(pTable->m_dwUserStatus[i], US_GAME_STARTED))
                {
                    pTable->m_dwUserStatus[i] &= ~US_GAME_STARTED;//去掉准备状态
                    pTable->m_dwUserStatus[i] |= US_USER_WAITNEWTABLE;
                    PostAskNewTable(pStartPlayer->m_nUserID, roomid, tableno, i);
                    NotifyOneUser(pStartPlayer->m_hSocket, pStartPlayer->m_lTokenID, GR_WAIT_NEWTABLE, NULL, 0);
                }
            }

        }

        pTable->m_dwUserStatus[chairno] &= ~US_GAME_STARTED;
        pTable->m_dwUserStatus[chairno] |= US_USER_WAITNEWTABLE;
        PostAskNewTable(userid, roomid, tableno, chairno);
        NotifyOneUser(pPlayer->m_hSocket, pPlayer->m_lTokenID, GR_WAIT_NEWTABLE, NULL, 0);

        // xzmo 新增 m_nextAskNewTable
        ((CMyGameTable*)pTable)->m_nextAskNewTable = TRUE;
    }

    response.head.nRequest = UR_OPERATE_SUCCEEDED;
    SendUserResponse(lpContext, &response);
    return TRUE;
}

BOOL CMyGameServer::OnTakeSafeDepositOK(LPCONTEXT_HEAD lpContext, LPREQUEST lpReqToClient, LPREQUEST lpReqFromServer)
{
    SOCKET sock = lpContext->hSocket;
    LONG token = lpContext->lTokenID;
    int gameid = 0;
    int roomid = 0;
    int tableno = INVALID_OBJECT_ID;
    int userid = 0;
    int chairno = INVALID_OBJECT_ID;

    CTable* pTable = NULL;
    CPlayer* pPlayer = NULL;

    LPTAKE_SAFE_DEPOSIT_OK lpTakeDepositOK = (LPTAKE_SAFE_DEPOSIT_OK)(PBYTE(lpReqFromServer->pDataPtr) + sizeof(CONTEXT_HEAD));

    SOLO_PLAYER sp;
    ZeroMemory(&sp, sizeof(sp));

    USER_DATA user_data;
    memset(&user_data, 0, sizeof(user_data));
    if (!LookupUserData(lpTakeDepositOK->nUserID, user_data))
    {
        return FALSE;
    }

    gameid = lpTakeDepositOK->nGameID;
    roomid = user_data.nRoomID;
    tableno = user_data.nTableNO;
    chairno = user_data.nChairNO;
    userid = lpTakeDepositOK->nUserID;
    if (!BaseVerify(roomid, tableno, chairno, userid))
    {
        return FALSE;
    }

    pTable = GetTablePtr(roomid, tableno);
    if (pTable)
    {
        LOCK_TABLE(pTable, chairno, FALSE, userid, token);

        lpReqToClient->head.nRequest = UR_OPERATE_SUCCEEDED;
        lpReqToClient->nDataLen = 0;
        lpReqToClient->pDataPtr = NULL;
        SendUserResponse(lpContext, lpReqToClient, FALSE, TRUE);

        pPlayer = pTable->m_ptrPlayers[chairno];
        if (pPlayer)
        {
            //补银成功后修改状态    新增
            OnGetDepositOK(pTable, chairno);

            pPlayer->m_nDeposit = lpTakeDepositOK->nGameDeposit;
            pTable->RecordPlayerOnCurrencyChange(false, chairno);
            if (LookupSoloPlayer(userid, sp))
            {
                sp.nDeposit = lpTakeDepositOK->nGameDeposit;
                SetSoloPlayer(userid, sp);
            }

            //将对局过程中的保险箱或后备箱取银记录到对局日志中
            //AnalyzePlayRecordTakeDeposit(pTable, lpTakeDepositOK->nChairNO, lpTakeDepositOK->nDeposit);

            //通知其它玩家
            USER_DEPOSITEVENT ude;
            memset(&ude, 0, sizeof(ude));
            ude.nUserID = pPlayer->m_nUserID;
            ude.nChairNO = pPlayer->m_nChairNO;
            ude.nEvent = USER_TAKE_SAFE_DEPOSIT;
            ude.nDepositDiff = lpTakeDepositOK->nDeposit;
            ude.nDeposit = pPlayer->m_nDeposit;
            if (NeedChangeBaseDeposit(pTable, pPlayer))
            {
                int nBaseDepos = ChangeBaseDeposit(pTable);
                if (nBaseDepos > 0)
                {
                    ude.nBaseDeposit = nBaseDepos;
                }
            }
            // 银两变化 埋点
            if (GetPrivateProfileInt(_T("DepositChangeDury"), _T("Enable"), 1, GetINIFileName()))
            {
                CString strDepositeChange;
                strDepositeChange = "OnTakeSafeDepositOK";
                strDepositeChange.Format(strDepositeChange + _T("uid[%d],oldDeposite[%d],changeDeposite[%d],"), ude.nUserID, ude.nDeposit, ude.nDepositDiff);
                LOG_INFO(strDepositeChange);
            }

            NotifyTablePlayers(pTable, GR_USER_DEPOSIT_EVENT, &ude, sizeof(ude), 0);
            NotifyTableVisitors(pTable, GR_USER_DEPOSIT_EVENT, &ude, sizeof(ude), 0);
        }
    }

    return TRUE;
}

BOOL CMyGameServer::OnApplyBaseWelfare(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt)
{
    SAFETY_NET_REQUEST(lpRequest, APPLY_BASEWELFARE, lpApplyWelfare);
    if (0 == lpApplyWelfare->dwSoapFlags)
    {
        //dwSoapFlags==0，表示该请求由客户端上发

        LONG token = 0;
        int roomid = 0;
        int tableno = INVALID_OBJECT_ID;
        int userid = 0;
        int chairno = INVALID_OBJECT_ID;
        LONG room_tokenid = 0;
        CTable* pTable = NULL;
        CPlayer* pPlayer = NULL;

        roomid = lpApplyWelfare->nRoomID;
        tableno = lpApplyWelfare->nTableNO;
        userid = lpApplyWelfare->nUserID;
        chairno = lpApplyWelfare->nChairNO;
        token = lpContext->lTokenID;

        if (!BaseVerify(roomid, tableno, chairno, userid))
        {
            return SendFailedResponse(lpContext);
        }

        //活动关闭
        if (!IsBaseWelfareActive())
        {
            return SendFailedResponse(lpContext);
        }

        if (!IS_BIT_SET(lpApplyWelfare->dwFlags, FLAG_REQFROM_HANDPHONE))
        {
            lpApplyWelfare->dwIPAddr = GetClientAddress(lpContext->hSocket, lpContext->lTokenID);
        }

        if (!(pTable = GetTablePtr(roomid, tableno)))
        {
            return SendFailedResponse(lpContext);
        }
        if (pTable)
        {
            LOCK_TABLE(pTable, chairno, FALSE, userid, token);

            if (!pTable->IsPlayer(userid)) // 不是玩家
            {
                UwlLogFile(_T("user not player. user %ld apply welfare failed."), userid);
                return SendFailedResponse(lpContext);
            }

            pPlayer = pTable->m_ptrPlayers[chairno];
            if (!pPlayer || pPlayer->m_nUserID != userid)
            {
                UwlLogFile(_T("userid mismatch. user %ld apply welfare failed."), userid);
                return SendFailedResponse(lpContext);
            }

            /*if (IS_BIT_SET(pTable->m_dwUserStatus[chairno], US_GAME_STARTED))
            {
            UwlLogFile(_T("cannot send to ready player. user %ld apply welfare failed."), userid);
            return SendErrorInfoResponse(lpContext, _T("已准备用户不能领取"));
            }

            if (IS_BIT_SET(pTable->m_dwStatus, TS_PLAYING_GAME))
            {
            if (!pPlayer->m_bIdlePlayer){ //进行中不能送银
            UwlLogFile(_T("cannot send to game while playing. user %ld apply welfare failed."), userid);
            return SendFailedResponse(lpContext);
            }
            }*/

            // xzmo新增
            CMyGameTable* pGameTable = (CMyGameTable*)pTable;
            pGameTable->m_bShowGiveUp[chairno] = FALSE;
            // end

            //发送到soap线程，调用WebService
            UINT uiThrdID = GetThreadIDBySoapFlag(SOAP_FLAG_BASEWELFARE);
            if (uiThrdID > 0)
            {
                return PostSoapRequest(uiThrdID, lpContext, lpRequest);
            }
        }

        return SendFailedResponse(lpContext);
    }
    else if (SOAP_FLAG_DEFAULTEX == lpApplyWelfare->dwSoapFlags)
    {
        //运行到此处则是服务端返回调用
        return OnApplyBaseWelfareOK(lpContext, lpRequest, pThreadCxt);
    }

    return FALSE;
}

BOOL CMyGameServer::OnGetTableInfo(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt)
{
    REQUEST response;
    memset(&response, 0, sizeof(response));

    LONG token = 0;
    int roomid = 0;
    int tableno = INVALID_OBJECT_ID;
    int userid = 0;
    int chairno = INVALID_OBJECT_ID;
    int r_id = 0;
    int t_no = INVALID_OBJECT_ID;
    int u_id = 0;
    int c_no = INVALID_OBJECT_ID;
    BOOL lookon = FALSE;

    CMyGameTable* pTable = NULL;
    CPlayer* pPlayer = NULL;

    token = lpContext->lTokenID;

    SAFETY_NET_REQUEST(lpRequest, GET_TABLE_INFO, pGetTableInfo);
    roomid = pGetTableInfo->nRoomID;
    tableno = pGetTableInfo->nTableNO;
    userid = pGetTableInfo->nUserID;
    chairno = pGetTableInfo->nChairNO;
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

    if (!(pTable = (CMyGameTable*)GetTablePtr(roomid, tableno)))
    {
        response.head.nRequest = UR_OPERATE_FAILED;
        return SendUserResponse(lpContext, &response);
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
        // xzmo 新增
        HU_ID_HEAD idHead;
        ZeroMemory(&idHead, sizeof(idHead));
        int nTotalCount = 0;
        int nHuIDs[TOTAL_CHAIRS][MAX_CARDS_PER_CHAIR / 2];
        int i = 0;
        for (i = 0; i < TOTAL_CHAIRS; i++)
        {
            XygInitChairCards(nHuIDs[i], MAX_CARDS_PER_CHAIR / 2);
            idHead.nCount[i] = pTable->GetHuItemIDs(i, nHuIDs[i]);
            nTotalCount += idHead.nCount[i];
        }

        int nLen = 0;
        void* pData = NULL;
        nLen = pTable->GetGameTableInfoSize() + sizeof(HU_ITEM_HEAD) + pTable->GetTotalItemCount(chairno) * sizeof(HU_ITEM_INFO) + sizeof(HU_ID_HEAD) + nTotalCount * sizeof(int);
        if (nLen)
        {
            pData = new BYTE[nLen];
        }

        //table
        pTable->FillupGameTableInfo(pData, nLen, chairno, lookon);

        //items
        int offsetLen = pTable->GetGameTableInfoSize();
        int itemCount = pTable->GetTotalItemCount(chairno);
        pTable->FillupAllHuItems(pData, offsetLen, chairno, itemCount);

        //idhead
        offsetLen += sizeof(HU_ITEM_HEAD) + pTable->GetTotalItemCount(chairno) * sizeof(HU_ITEM_INFO);
        LPHU_ID_HEAD pIDHead = LPHU_ID_HEAD((PBYTE)pData + offsetLen);
        memcpy(pIDHead, &idHead, sizeof(HU_ID_HEAD));

        //ids
        offsetLen += sizeof(HU_ID_HEAD);
        int* pDataIDs = (int*)((PBYTE)pData + offsetLen);
        int index = 0;
        for (i = 0; i < TOTAL_CHAIRS; i++)
        {
            for (int j = 0; j < idHead.nCount[i]; j++)
            {
                pDataIDs[index] = nHuIDs[i][j];
                index++;
            }
        }

        response.head.nRequest = UR_OPERATE_SUCCEEDED;
        response.pDataPtr = pData;
        response.nDataLen = nLen;

        SendUserResponse(lpContext, &response, FALSE, TRUE);
        UwlClearRequest(&response);

        if (IS_BIT_SET(pTable->m_dwStatus, TS_PLAYING_GAME))
        {
            CheckGiveUp(pTable, chairno);
        }
        // end
    }
    else
    {
        SendUserResponse(lpContext, &response, FALSE, TRUE);
        UwlClearRequest(&response);
    }

    return TRUE;
}

void CMyGameServer::OpeAfterCheckResult(CTable* pTable, void* pOpeData, int nDataLen, int nRoomID, BOOL bClearTable)
{
    pTable->SetCheckingResult(FALSE); //等待标记 置0

    CMyGameTable* pGameTable = (CMyGameTable*)pTable;
    if (pGameTable->IsXueLiuRoom())
    {
        for (int i = 0; i < pTable->m_nTotalChairs; i++)
        {
            CPlayer* ptrP = pTable->m_ptrPlayers[i];
            if (ptrP && ptrP->m_lTokenID != 0)
            {

                int nTotalLen = nDataLen + sizeof(HU_ITEM_HEAD) + pGameTable->GetNoSendItemCount(i) * sizeof(HU_ITEM_INFO);
                int nTotalLenNew = nTotalLen + sizeof(GAMEEND_CHECK_INFO) + sizeof(ABORTPLAYER_INFO) * TOTAL_CHAIRS;
                void* pTotalData = new_byte_array(nTotalLenNew);
                memcpy(pTotalData, pOpeData, nDataLen);

                int offsetLen = nDataLen;
                int itemCount = pGameTable->GetNoSendItemCount(i);
                pGameTable->FillupAllHuItems(pTotalData, offsetLen, i, itemCount);
                pGameTable->FillUpGameWinCheckInfos(pTotalData, nTotalLen, i);

                int nGamePlayerInfoOffset = nTotalLen + sizeof(GAMEEND_CHECK_INFO);
                pGameTable->FillupGameStartPlayerInfo(pTotalData, nGamePlayerInfoOffset);

                nTotalLen = nTotalLenNew;
                NotifyOneUser(ptrP->m_hSocket, ptrP->m_lTokenID, GR_GAME_WIN, pTotalData, nTotalLen);
                NotifyChairVisitors(pTable, i, GR_GAME_WIN, pTotalData, nTotalLen);
                SAFE_DELETE(pTotalData);
            }
        }
    }
    else
    {
        for (int i = 0; i < pTable->m_nTotalChairs; i++)
        {
            CPlayer* ptrP = pTable->m_ptrPlayers[i];
            if (ptrP && ptrP->m_lTokenID != 0)
            {

                if (IS_BIT_SET(ptrP->m_nUserType, UT_HANDPHONE))
                {
                    int nTotalLen = nDataLen + sizeof(HU_ITEM_HEAD) + pGameTable->GetTotalItemCount(i) * sizeof(HU_ITEM_INFO);
                    int nTotalLenNew = nTotalLen + sizeof(GAMEEND_CHECK_INFO) + sizeof(ABORTPLAYER_INFO) * TOTAL_CHAIRS;
                    void* pTotalData = new_byte_array(nTotalLenNew);
                    memcpy(pTotalData, pOpeData, nDataLen);

                    int offsetLen = nDataLen;
                    int itemCount = pGameTable->GetTotalItemCount(i);
                    pGameTable->FillupAllHuItems(pTotalData, offsetLen, i, itemCount);

                    pGameTable->FillUpGameWinCheckInfos(pTotalData, nTotalLen, i);

                    int nGamePlayerInfoOffset = nTotalLen + sizeof(GAMEEND_CHECK_INFO);
                    pGameTable->FillupGameStartPlayerInfo(pTotalData, nGamePlayerInfoOffset);

                    nTotalLen = nTotalLenNew;
                    NotifyOneUser(ptrP->m_hSocket, ptrP->m_lTokenID, GR_GAME_WIN, pTotalData, nTotalLen);
                    //NotifyChairVisitors(pTable, i, GR_GAME_WIN, pTotalData, nTotalLen);
                    SAFE_DELETE(pTotalData);

                    //旁观
                    if (!pTable->m_mapVisitors[i].empty())
                    {
                        int nTotalCount = 0;
                        int nItemCount[TOTAL_CHAIRS];
                        for (int j = 0; j < TOTAL_CHAIRS; j++)
                        {
                            nItemCount[j] = pGameTable->GetTotalItemCount(j);
                            nTotalCount += nItemCount[j];
                        }

                        int nLenVisitor = nDataLen + sizeof(HU_ITEM_HEAD_PC) + nTotalCount * sizeof(HU_ITEM_INFO);
                        int nTotalLenNew = nLenVisitor + sizeof(GAMEEND_CHECK_INFO);
                        void* pDataVisitor = new_byte_array(nTotalLenNew);
                        memcpy(pDataVisitor, pOpeData, nDataLen);

                        offsetLen = nDataLen;
                        pGameTable->FillupAllPCHuItems(pDataVisitor, offsetLen, nItemCount);

                        pGameTable->FillUpGameWinCheckInfos(pDataVisitor, nLenVisitor, i);
                        nLenVisitor = nTotalLenNew;

                        int u_id = 0;
                        CPlayer* ptrV = NULL;
                        auto pos = pTable->m_mapVisitors[i].GetStartPosition();
                        while (pos)
                        {
                            pTable->m_mapVisitors[i].GetNextAssoc(pos, u_id, ptrV);
                            if (ptrV && ptrV->m_lTokenID != 0)
                            {
                                NotifyOneUser(ptrV->m_hSocket, ptrV->m_lTokenID, GR_GAME_WIN, pDataVisitor, nTotalLenNew);
                            }
                        }
                        SAFE_DELETE(pDataVisitor);
                    }
                }
                else
                {
                    int nTotalCount = 0;
                    int nItemCount[TOTAL_CHAIRS];
                    for (int j = 0; j < TOTAL_CHAIRS; j++)
                    {
                        nItemCount[j] = pGameTable->GetTotalItemCount(j);
                        nTotalCount += nItemCount[j];
                    }

                    int nTotalLen = nDataLen + sizeof(HU_ITEM_HEAD_PC) + nTotalCount * sizeof(HU_ITEM_INFO);
                    int nTotalLenNew = nTotalLen + sizeof(GAMEEND_CHECK_INFO);
                    void* pTotalData = new_byte_array(nTotalLenNew);
                    memcpy(pTotalData, pOpeData, nDataLen);

                    int offsetLen = nDataLen;
                    pGameTable->FillupAllPCHuItems(pTotalData, offsetLen, nItemCount);

                    pGameTable->FillUpGameWinCheckInfos(pTotalData, nTotalLen, i);
                    nTotalLen = nTotalLenNew;

                    NotifyOneUser(ptrP->m_hSocket, ptrP->m_lTokenID, GR_GAME_WIN, pTotalData, nTotalLen);
                    NotifyChairVisitors(pTable, i, GR_GAME_WIN, pTotalData, nTotalLen);
                    SAFE_DELETE(pTotalData);
                }
            }
        }
    }

    if (pGameTable->IsXueLiuRoom())
    {
        LPCONTEXT_HEAD lpContext = new CONTEXT_HEAD;
        memset(lpContext, 0, sizeof(CONTEXT_HEAD));
        for (int nTaskChairNO = 0; nTaskChairNO < pTable->m_nTotalChairs; nTaskChairNO++)
        {
            CPlayer* pPlayer = pTable->m_ptrPlayers[nTaskChairNO];
            if (pPlayer && IS_BIT_SET(pPlayer->m_nUserType, UT_HANDPHONE))
            {
                //task
                evWinDeposit.notify(lpContext, pGameTable, pPlayer->m_nUserID, nTaskChairNO);
                if (((CMyGameTable*)pTable)->m_bLastHuChairs[nTaskChairNO])
                {
                    //task
                    evWxTaskHu.notify(lpContext, pTable, nTaskChairNO);
                }
            }
        }
        SAFE_DELETE(lpContext);
    }
    else //血战
    {
        LPCONTEXT_HEAD lpContext = new CONTEXT_HEAD;
        memset(lpContext, 0, sizeof(CONTEXT_HEAD));
        for (int nTaskChairNO = 0; nTaskChairNO < pTable->m_nTotalChairs; nTaskChairNO++)
        {
            CPlayer* pPlayer = pTable->m_ptrPlayers[nTaskChairNO];
            int nHuReady = pGameTable->m_HuReady[nTaskChairNO];
            if (nHuReady == 0 || nHuReady == MJ_HU_HUAZHU || nHuReady == MJ_HU_TING || ((CMyGameTable*)pTable)->m_bLastHuChairs[nTaskChairNO])
            {
                if (pPlayer)
                {
                    //task
                    evWinDeposit.notify(lpContext, pGameTable, pPlayer->m_nUserID, nTaskChairNO);
                    if (((CMyGameTable*)pTable)->m_bLastHuChairs[nTaskChairNO])
                    {
                        //task
                        evWxTaskHu.notify(lpContext, pTable, nTaskChairNO);
                    }
                }
            }
        }
        SAFE_DELETE(lpContext)
    }

    NotifyScoreProtect(pTable);       // add on 20130723 by taohg
    NotifySoloPlayerRealData(pTable); // add on 20140213 by pengsy

    DWORD dwBreakTime[MAX_CHAIRS_PER_TABLE];
    memset(dwBreakTime, 0, sizeof(dwBreakTime));
    memcpy(dwBreakTime, pTable->m_dwBreakTime, sizeof(dwBreakTime));

    pTable->PrepareNextBout(pOpeData, nDataLen);

    if (bClearTable)
    {
        ClearGameWin(pTable);
    }
    else
    {
        SAFE_DELETE(pOpeData);
    }

    if (pTable->IsGameOver())
    {
        PostGameBoutEnd(nRoomID, pTable->m_nTableNO, pTable);

        //Solo 独离
        if (IsSoloRoom(nRoomID)
            && IsLeaveAlone(nRoomID))
        {
            //主动退掉已经掉线的玩家
            for (int i = 0; i < pTable->m_nTotalChairs; i++)
            {
                if (pTable->m_ptrPlayers[i]
                    && dwBreakTime[i] > 0)
                {
                    RemoveOneClients(pTable, pTable->m_ptrPlayers[i]->m_nUserID, TRUE);
                    EjectLeaveGameEx(pTable->m_ptrPlayers[i]->m_nUserID, nRoomID, pTable->m_nTableNO,
                        i, pTable->m_ptrPlayers[i]->m_hSocket, pTable->m_ptrPlayers[i]->m_lTokenID);
                }
            }
            //          }

            //将手机用户加入踢人队列
            if (IsKickMobileBkgActive())
            {
                AddToMobileBkgQueue_GameOver(pTable);
            }
        }
        // 结束 组队房换桌
        CheckResumeTeam(pTable);

    }
}

void CMyGameServer::CheckInGameResult(LPCONTEXT_HEAD lpContext, CTable* pTable, void* pData, int nLen, int roomid)
{
    if (!pTable || !pData)
    {
        return;
    }

    REFRESH_RESULT_EX RefreshResult;
    ZeroMemory(&RefreshResult, sizeof(RefreshResult));
    RefreshResult.nTableNO = pTable->m_nTableNO;

    GAME_RESULT_EX GameResults[MAX_CHAIRS_PER_TABLE];
    ZeroMemory(&GameResults, sizeof(GameResults));

    if (!IsVariableChairRoom(roomid))
    {
        pTable->ConstructGameResults(pData, nLen, roomid, m_nGameID, &RefreshResult, GameResults);
        pTable->RefreshPlayerData(GameResults);

        TransmitGameResult(lpContext, &RefreshResult, GameResults, pTable->m_nTotalChairs * sizeof(GAME_RESULT_EX));
    }
    else
    {
        int nPlayerCount = 0;
        int i = 0;
        for (i = 0; i < pTable->m_nTotalChairs; i++)
        {
            if (pTable->m_ptrPlayers[i] && !(pTable->m_ptrPlayers[i]->m_bIdlePlayer))
            {
                nPlayerCount++;
            }
        }
        pTable->ConstructEndSaveResult(pData, nLen, roomid, m_nGameID, &RefreshResult, GameResults);

        int nIndex = 0;
        for (i = 0; i < pTable->m_nTotalChairs; i++)
        {
            if (pTable->m_ptrPlayers[i] && !(pTable->m_ptrPlayers[i]->m_bIdlePlayer))
            {
                pTable->RefreshOnePlayerData(&(GameResults[nIndex++]));
            }
        }
        // xzmo 新增
        if (RefreshResult.nResultCount > 0)
        {
            TransmitGameResultEx(pTable, lpContext, &RefreshResult, GameResults, nPlayerCount * sizeof(GAME_RESULT_EX));
        }
        else
        {
            UwlLogFile(_T("CheckInGameResult RefreshResult.nResultCount = %d"), RefreshResult.nResultCount);
        }
        // end
    }
}

BOOL CMyGameServer::OnGameWin(LPCONTEXT_HEAD lpContext, CRoom* pRoom, CTable* pTable, int chairno, BOOL bout_invalid, int roomid)
{
    if (pRoom && pRoom->IsOnMatch())  //比赛
    {
        return OnMatchGameWin(lpContext, pRoom, pTable, chairno, bout_invalid, roomid);
    }

    if (pRoom && IsYQWRoom(roomid))  //yqw
    {
        return YQW_OnGameWin(lpContext, pRoom, pTable, chairno, bout_invalid, roomid);
    }
    //等待标记 置1
    //pTable->SetCheckingResult(TRUE);

    //结算延迟
    if (NeedGameWinDelay(lpContext, pTable, chairno, bout_invalid, roomid))
    {
        pTable->SetCheckingResult(TRUE);

        GAME_WIN_DELAY gameWin;
        memset(&gameWin, 0, sizeof(gameWin));
        if (ConstructDelayGameWin(lpContext, pTable, chairno, bout_invalid, roomid, gameWin, DEF_DELAY_GAMEWIN))
        {
            return DelayGameWin(lpContext, pTable, &gameWin, gameWin.dwDelay);
        }
    }

    //////////////////////////////////////////////////////////////////////////
    BOOL bWaitCheckRult = IsWaitCheckResult(roomid);
    (void)pTable->SetStatusOnEnd();

    int nLen = pTable->GetGameWinSize();
    void* pData = new_byte_array(nLen);

    (void)pTable->BuildUpGameWin(pData, nLen, chairno, bout_invalid, m_mapPlayerLevel);
    CalcResultWinOrLoss(pData, nLen, pTable);
    CalcAccountBilling((LPGAME_WIN)pData, pTable);
    OnTcMatchGameWin((LPGAME_WIN)pData, pTable);

    if (!bout_invalid && pTable->CheckInDB()) // 本局结果有效并且需要提交到数据库
    {
        OnCPGameWin(lpContext, roomid, pTable, pData);
        CheckInGameResult(lpContext, pTable, pData, nLen, roomid);

        //抽奖数据保存
        Lottery_SaveData(lpContext, pTable, roomid, chairno);
    }
    // xzmo 新增
    evOnGameWin.notify(lpContext, pRoom, pTable, chairno, bout_invalid, roomid);

    //血流房对局耗时等于开局到结束
    if (((CMyGameTable*)pTable)->IsXueLiuRoom())
    {
        for (int i = 0; i < TOTAL_CHAIRS; i++)
        {
            ((CMyGameTable*)pTable)->m_nTimeCost[i] = (GetTickCount() - pTable->m_dwGameStart) / 1000;
        }
    }
    else //血战房对局耗时如果为0表示没有胡牌
    {
        for (int i = 0; i < TOTAL_CHAIRS; i++)
        {
            if (((CMyGameTable*)pTable)->m_nTimeCost[i] <= 0)
            {
                ((CMyGameTable*)pTable)->m_nTimeCost[i] = (GetTickCount() - pTable->m_dwGameStart) / 1000;
            }
        }
    }

    //对局局数记录
    for (int i = 0; i < TOTAL_CHAIRS; i++)
    {
        //注意这里在开局增加对局数后会附带一次查询操作，因此已经包含了本局
        ((CMyGameTable*)pTable)->m_nTotalGameCount[i] = ((CMyGameTable*)pTable)->m_PlayersBackup[i].nBout;

        //注意这里在开局增加对局数后会附带一次查询操作，因此已经包含了本局
        if (((CMyGameTable*)pTable)->IsXueLiuRoom())
        {
            ((CMyGameTable*)pTable)->m_nXLTotalGameCount[i] = ((CMyGameTable*)pTable)->m_nXLTotalGameCount[i];
        }
        else
        {
            ((CMyGameTable*)pTable)->m_nXZTotalGameCount[i] = ((CMyGameTable*)pTable)->m_nXZTotalGameCount[i];
        }
    }

    if (!bWaitCheckRult)
    {
        ((CMyGameTable*)pTable)->m_nEndGameFlag |= ((CMyGameTable*)pTable)->m_huDetails[chairno].dwHuFlags[0];
        OpeAfterCheckResult(pTable, pData, nLen, roomid, FALSE);
        CheckandNotifyDepositWinLimit((CMyGameTable*)pTable);
        // end
    }
    else
    {
        //等待checksvr验证
        StoreUpGameWin(pTable, pData, nLen, chairno);
    }

    return TRUE;
}

BOOL CMyGameServer::OnPreGangCard(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt)
{
    LOG_TRACE(_T("CMyGameServer::OnPreGangCard"));
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
    CRoom* pRoom = NULL;
    CMyGameTable* pTable = NULL;

    if (!(pRoom = GetRoomPtr(roomid)))
    {
        return NotifyResponseFaild(lpContext, bPassive);
    }
    if (!(pTable = (CMyGameTable*)GetTablePtr(roomid, tableno)))
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
        // xzmo 新增
        CMyGameTable* pGameTable = (CMyGameTable*)pTable;
        if (pGameTable->IsXueLiuRoom())
        {
            for (int i = 0; i < TOTAL_CHAIRS; i++)
            {
                if ((pTable->IsOffline(i)) && (IS_BIT_SET(pregang_ok.dwResults[i], MJ_HU)))
                {
                    OnSeverAutoPlayHuQiangGang(pRoom, pTable, i,
                        pregang_ok.nCardChair, pregang_ok.nCardID, pregang_ok.dwFlags);
                }
                else if (pTable->IsLastFourCard() && (IS_BIT_SET(pregang_ok.dwResults[i], MJ_HU)))
                {
                    OnSeverAutoPlayHuQiangGang(pRoom, pTable, i,
                        pregang_ok.nCardChair, pregang_ok.nCardID, pregang_ok.dwFlags);
                }
            }
        }
        else
        {
            for (int i = 0; i < TOTAL_CHAIRS; i++)
            {
                if (pTable->IsLastFourCard() && (IS_BIT_SET(pregang_ok.dwResults[i], MJ_HU)))
                {
                    OnSeverAutoPlayHuQiangGang(pRoom, pTable, i,
                        pregang_ok.nCardChair, pregang_ok.nCardID, pregang_ok.dwFlags);
                }
            }
        }
    }
    // end
    return TRUE;
}

BOOL CMyGameServer::DealGetWelfarePresent(LPSOAP_SERVICE pSoapService, IXYSoapClientPtr& pSoapClient, LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
    BOOL bResult = FALSE;

    LPGET_WELFAREPRESENT lpGetWfPresent = (LPGET_WELFAREPRESENT)lpRequest->pDataPtr;
    if (pSoapService->nActID != 0)
    {
        lpGetWfPresent->nActivityID = pSoapService->nActID;
    }

    //json序列化 方式1
    TCHAR szJson[500] = "";

    SYSTEMTIME timenow;
    GetLocalTime(&timenow);
    long nTime = timenow.wYear * 10000 + timenow.wMonth * 100 + timenow.wDay;
    CString strMD5Get;
    strMD5Get.Format("%d|%d|%d", lpGetWfPresent->nActivityID, lpGetWfPresent->nUserID, nTime);
    CString strMD5GetDest = MD5String(strMD5Get.GetBuffer(strMD5Get.GetLength() + 1));

    sprintf_s(szJson,
        "{\"ActId\":\"%d\",\"DeviceId\":\"%s\",\"IP\":\"%s\",\"Key\":\"%s\",\"SilverLocation\":0,\"Time\":%d,\"UserId\":%d,\"UserName\":\"\"}"
        , lpGetWfPresent->nActivityID,
        lpGetWfPresent->szHardID,
        xyConvertIPToStr_Ref(lpGetWfPresent->dwIPAddr),
        strMD5GetDest,
        nTime,
        lpGetWfPresent->nUserID
    );

    try
    {
        _bstr_t sMethodName;
        sMethodName = (_bstr_t)_T("GetConfig");

        _variant_t sRet;

        sRet = pSoapClient->InvokeMethod(sMethodName, szJson);
        lstrcpy(lpGetWfPresent->szSoapReturn, (LPCSTR)_bstr_t(sRet));
    }
    catch (...)
    {

        UwlTrace(_T("%s error: %s"), pSoapService->szSoapWhat, (LPCTSTR)(pSoapClient->GetLastError()));
        UwlLogFile(_T("%s setLotUser error: %s"), pSoapService->szSoapWhat, (LPCTSTR)(pSoapClient->GetLastError()));
        lstrcpy(lpGetWfPresent->szSoapReturn, _T("exception"));
    }

    lpGetWfPresent->dwSoapFlags = SOAP_FLAG_DEFAULTEX;
    bResult = PutRequestToWorker(lpRequest->nDataLen, DWORD(lpContext->hSocket), lpContext, lpRequest, lpRequest->pDataPtr);

    return bResult;
}

BOOL CMyGameServer::DealSoapMessage(LPSOAP_SERVICE pSoapService, IXYSoapClientPtr& pSoapClient, LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
    BOOL bResult = FALSE;
    switch (lpRequest->head.nRequest)
    {
    case GR_GET_WELFAREPRESENT:
        bResult = DealGetWelfarePresent(pSoapService, pSoapClient, lpContext, lpRequest);
        break;
    default:
        bResult = CMainServer::DealSoapMessage(pSoapService, pSoapClient, lpContext, lpRequest); // 调用父类的处理方法
        break;
    }

    return bResult;
}

BOOL CMyGameServer::Initialize()
{
    return __super::Initialize();
}

void CMyGameServer::Shutdown()
{
    __super::Shutdown();
}

BOOL CMyGameServer::GetPlayerSafeBoxDeposit(CPlayer* pPlayer, CMyGameTable* pTable, int nChairNo)
{
    if (!pPlayer)
    {
        return false;
    }
    if (pPlayer->m_nUserID <= 0)
    {
        return false;
    }
    USER_DATA user_data;
    memset(&user_data, 0, sizeof(user_data));
    if (!LookupUserData(pPlayer->m_nUserID, user_data))
    {
        return false;
    }

    LOOK_SAFE_DEPOSIT looksafedeposit;
    memset(&looksafedeposit, 0, sizeof(looksafedeposit));
    looksafedeposit.dwIPAddr = GetClientAddress(user_data.hSocket, user_data.lTokenID);
    looksafedeposit.nGameID = m_nGameID;
    looksafedeposit.nUserID = user_data.nUserID;
    strcpy_s(looksafedeposit.szHardID, pPlayer->m_szHardID);

    CONTEXT_HEAD context;
    ZeroMemory(&context, sizeof context);
    context.bNeedEcho = FALSE;
    context.hSocket = 0;
    //由于目前LOOK_SAFE_DEPOSIT无法定位房间号和桌号，将roomID和TableNo合并到lToken中，前提是这两个ID都只占了Int的一部分
    //context.lTokenID = (LONG)(&stDeposit);//消息交互时，传递内存指针似乎不太好

    //由于目前LOOK_SAFE_DEPOSIT无法定位房间号和桌号，只能通过其他无用的字段传输；ugly design
    context.lTokenID = pTable->m_nRoomID;
    context.lSession = nChairNo << sizeof(int) / 2 * 8 | pTable->m_nTableNO;

    REQUEST request;
    ZeroMemory(&request, sizeof(request));
    request.head.nRequest = GR_LOOK_SAFE_DEPOSIT;
    request.head.nSubReq = 1;
    request.nDataLen = sizeof(looksafedeposit);
    request.pDataPtr = &looksafedeposit;
    if (!TransmitRequest(&context, &request))
    {
        //delete pr;
        return false;
    }
    return true;
}

BOOL CMyGameServer::OnLookSafeDepositOK(LPCONTEXT_HEAD lpContext, LPREQUEST lpReqToClient, LPREQUEST lpReqFromServer)
{
    int nLen = lpReqFromServer->nDataLen - sizeof(CONTEXT_HEAD);
    PBYTE pData = new BYTE[nLen];
    lpReqToClient->pDataPtr = pData;
    lpReqToClient->nDataLen = nLen;
    memcpy(lpReqToClient->pDataPtr, PBYTE(lpReqFromServer->pDataPtr) + sizeof(CONTEXT_HEAD), nLen);

    LPSAFE_DEPOSIT_EX lpDeposit = (LPSAFE_DEPOSIT_EX)lpReqToClient->pDataPtr;

    lpReqToClient->head.nRequest = UR_OPERATE_SUCCEEDED;

    if (0 == lpContext->hSocket)
    {
        int nRoomID = lpContext->lTokenID;
        int nTableNo = lpContext->lSession & 0x0000ffff;
        int nChairNo = lpContext->lSession >> sizeof(int) / 2 * 8;
        CMyGameTable* pTable = NULL;
        pTable = GetTablePtr(nRoomID, nTableNo);
        if (!pTable)
        {
            return NotifyResponseFaild(lpContext);
        }
        if (pTable)
        {
            CAutoLock lock(&(pTable->m_csTable));
            memcpy(&pTable->m_SafeDeposits[nChairNo], lpDeposit, sizeof(SAFE_DEPOSIT_EX));
        }
        return TRUE;
    }

    return SendUserResponse(lpContext, lpReqToClient, FALSE, TRUE);
}

//当机器人客户端进入游戏后触发
CBaseRobot* CMyGameServer::OnNewRobotUnit(int nUserId)
{
    return new CMyRobot(nUserId);
}

void CMyGameServer::OnRobotAIPlay(CRoom* pRoom, CTable* pTable, int chairno, BOOL bClockZero)
{
    //必要的检查
    if (chairno >= MAX_CHAIRS_PER_TABLE || !pRoom || !pTable)
    {
        return;
    }

    int roomid = pRoom->m_nRoomID;;
    int tableno = pTable->m_nTableNO;

    //根据桌位获得玩家
    CPlayer* ptrPlayer = pTable->m_ptrPlayers[chairno];
    if (!ptrPlayer)
    {
        return;
    }
    int userid = ptrPlayer->m_nUserID;
    //.......
    CMyGameTable* pMyGameTable = (CMyGameTable*)pTable;
    int operateTime = pMyGameTable->GetRobotOperateTimeRate();
    LOG_DEBUG("m_nAIOperateID:%d Chair:%d, m_nAIOperateChairNO:%d", pMyGameTable->m_nAIOperateID, chairno, pMyGameTable->m_nAIOperateChairNO);
    if (pMyGameTable->m_nAIOperateID != -1)
    {
        int nRate = rand() % 100 + 1;
        int nTime = rand() % operateTime + 1;
        pMyGameTable->GetAIBaseCardsID();
        if (pMyGameTable->m_nAIOperateID == LOCAL_GAME_MSG_PENG)
        {
            if (nRate <= pMyGameTable->GetAIPengRand())
            {
                LOG_DEBUG("OnRobotAIPlay AIPeng Success");
                PENG_CARD pengcard;
                ZeroMemory(&pengcard, sizeof(pengcard));
                pengcard.nRoomID = roomid;
                pengcard.nTableNO = tableno;
                pengcard.nChairNO = pMyGameTable->m_nAIOperateChairNO;
                pengcard.nUserID = userid;
                pengcard.nCardID = pMyGameTable->m_nAIOperateCardID;
                pengcard.nCardChair = pMyGameTable->m_nAIOperateCardChairNO;
                pengcard.nBaseIDs[0] = pMyGameTable->m_nAIOperateBaseCards[0];
                pengcard.nBaseIDs[1] = pMyGameTable->m_nAIOperateBaseCards[1];
                pengcard.nBaseIDs[2] = pMyGameTable->m_nAIOperateBaseCards[2];
                pengcard.dwFlags = MJ_PENG;

                SimulateGameMsgFromUser(roomid, pTable->m_ptrPlayers[pMyGameTable->m_nAIOperateChairNO], LOCAL_GAME_MSG_PENG, sizeof(PENG_CARD), &pengcard, nTime * 1000);
            }
            else
            {
                LOG_DEBUG("OnRobotAIPlay AIPeng Failed");
                OnRobotGuoCard(pRoom, pTable, chairno);
            }
        }
        else if (pMyGameTable->m_nAIOperateID == LOCAL_GAME_MSG_MN_GANG || pMyGameTable->m_nAIOperateID == LOCAL_GAME_MSG_PN_GANG || pMyGameTable->m_nAIOperateID == LOCAL_GAME_MSG_AN_GANG)
        {
            if (nRate <= pMyGameTable->GetAIGangRand())
            {
                LOG_DEBUG("OnRobotAIPlay AIGang Suceess");
                GANG_CARD gangcard;
                ZeroMemory(&gangcard, sizeof(gangcard));
                gangcard.nRoomID = roomid;
                gangcard.nTableNO = tableno;
                gangcard.nChairNO = pMyGameTable->m_nAIOperateChairNO;
                gangcard.nUserID = userid;
                gangcard.nCardID = pMyGameTable->m_nAIOperateCardID;
                gangcard.nCardChair = pMyGameTable->m_nAIOperateCardChairNO;
                gangcard.nBaseIDs[0] = pMyGameTable->m_nAIOperateBaseCards[0];
                gangcard.nBaseIDs[1] = pMyGameTable->m_nAIOperateBaseCards[1];
                gangcard.nBaseIDs[2] = pMyGameTable->m_nAIOperateBaseCards[2];
                // 神坑啊！！ 暗杠要获取全部的四张牌
                if (pMyGameTable->m_nAIOperateID == LOCAL_GAME_MSG_AN_GANG)
                {
                    gangcard.nCardID = pMyGameTable->m_nAIOperateBaseCards[3];
                }
                gangcard.dwFlags = MJ_GANG;

                SimulateGameMsgFromUser(roomid, pTable->m_ptrPlayers[pMyGameTable->m_nAIOperateChairNO], pMyGameTable->m_nAIOperateID, sizeof(GANG_CARD), &gangcard, nTime * 1000);
            }
            else
            {
                LOG_DEBUG("OnRobotAIPlay AIGang Failed");
                OnRobotGuoCard(pRoom, pTable, chairno);
            }
        }

        else if (pMyGameTable->m_nAIOperateID == LOCAL_GAME_MSG_HU)
        {
            if (pMyGameTable->IsXueLiuRoom() || pMyGameTable->IsLastFourCard())
            {
                LOG_DEBUG("OnRobotAIPlay [Xueliu] Or [LastFourCard]: AIHu");
                OnRobotXueLiuHu(pRoom, pTable, pTable->GetCurrentChair());
            }
            else
            {
                if (nRate <= pMyGameTable->GetAIHuRand() || (pMyGameTable->m_HuReady[chairno] && pMyGameTable->m_HuReady[chairno] != MJ_GIVE_UP) || pMyGameTable->IsLastFourCard())
                {
                    LOG_DEBUG("OnRobotAIPlay -> OnSeverAutoPlayFangChongHu");
                    OnSeverAutoPlayFangChongHu(pRoom, pTable, pMyGameTable->m_nAIOperateChairNO, pMyGameTable->m_nAIOperateCardChairNO, pMyGameTable->m_nAIOperateCardID);
                }
                else
                {
                    LOG_DEBUG("OnRobotAIPlay AIHu Failed");
                    OnRobotGuoCard(pRoom, pTable, chairno);
                }
            }
        }
        else if (pMyGameTable->m_nAIOperateID == LOCAL_GAME_MSG_ZIMO_HU)
        {
            if (pMyGameTable->IsLastFourCard())
            {
                LOG_DEBUG("OnRobotAIPlay [IsLastFourCard] AI ZIMO HU");
                OnRobotXueLiuHu(pRoom, pTable, pTable->GetCurrentChair());
            }
            else
            {
                if (nRate <= pMyGameTable->GetAIHuRand() || (pMyGameTable->m_HuReady[chairno] && pMyGameTable->m_HuReady[chairno] != MJ_GIVE_UP)
                    || pMyGameTable->IsLastFourCard())  // 这里的剩四必胡的判断感觉不用加
                {
                    LOG_DEBUG("OnRobotAIPlay AI ZIMO Hu Success");
                    OnSeverAutoPlayHuZiMo(pRoom, pTable, pMyGameTable->m_nAIOperateChairNO, pMyGameTable->m_nAIOperateCardID);
                }
                else
                {
                    LOG_DEBUG("OnRobotAIPlay AI ZIMO Hu Failed");
                    OnRobotGuoCard(pRoom, pTable, chairno);
                }
            }
        }
        else if (pMyGameTable->m_nAIOperateID == LOCAL_GAME_MSG_QGANG_HU)
        {
            if (pMyGameTable->IsLastFourCard())
            {
                LOG_DEBUG("OnRobotAIPlay [IsLastFourCard]: QGANG HU");
                OnRobotXueLiuHu(pRoom, pTable, pTable->GetCurrentChair());
            }
            else
            {
                if (nRate <= pMyGameTable->GetAIHuRand() || (pMyGameTable->m_HuReady[chairno] && pMyGameTable->m_HuReady[chairno] != MJ_GIVE_UP)
                    || pMyGameTable->IsLastFourCard()) // 这里的剩四必胡的判断感觉不用加
                {
                    LOG_DEBUG("OnRobotAIPlay QGang HU Success");
                    OnSeverAutoPlayHuQiangGang(pRoom, pTable, pMyGameTable->m_nAIOperateChairNO,
                        pMyGameTable->m_nAIOperateCardChairNO, pMyGameTable->m_nAIOperateCardID, pMyGameTable->m_nQghFlag);
                }
                else
                {
                    LOG_DEBUG("OnRobotAIPlay QGang HU Failed");
                    OnRobotGuoCard(pRoom, pTable, chairno);
                }
            }
        }
        else
        {
            LOG_DEBUG("OnRobotAIPlay -> OnServerAutoPlay");
            OnServerAutoPlay(pRoom, pTable, pTable->GetCurrentChair(), !pTable->IsOffline(chairno), bClockZero);
        }
    }
    else
    {
        LOG_DEBUG("OnRobotAIPlay [m_nAIOperateID == -1] -> OnServerAutoPlay");
        OnServerAutoPlay(pRoom, pTable, pTable->GetCurrentChair(), !pTable->IsOffline(chairno), bClockZero);
    }

    //托管接口出牌
    return __super::OnRobotAIPlay(pRoom, pTable, chairno);
}

void CMyGameServer::OnRobotStartExchangeOrFixmiss(CRoom* pRoom, CTable* pTable)
{
    CMyGameTable* pMyGameTable = (CMyGameTable*)pTable;
    CPlayer* pPlayer = pTable->m_ptrPlayers[0];
    if (!pPlayer)
    {
        return;
    }
    int roomid = pRoom->m_nRoomID;
    int nTime = rand() % 4 + 1;
    if (IS_BIT_SET(pTable->m_dwStatus, TS_WAITING_EXCHANGE3CARDS))
    {
        for (int offline = 0; offline < pTable->m_nTotalChairs; offline++)
        {
            if (pTable->ValidateChair(offline)
                && pTable->IsRoboter(offline) && (!pMyGameTable->m_bExchangeCards[offline]))
            {
                OnPlayerOffline(pTable, offline);
                EXCHANGE3CARDS exchange3cards;
                ZeroMemory(&exchange3cards, sizeof(exchange3cards));
                exchange3cards.nChairNO = offline;
                pMyGameTable->OnAutoExchangeCards(&exchange3cards);
                LOG_DEBUG(_T("***********ROBOT_BOUT_LOG_EXCHANGECARDS***********roomid:%d, tableno:%d, userid:%d, chairno:%d, cardids:%s, %s, %s"), roomid, pTable->m_nTableNO,
                    pTable->m_ptrPlayers[offline]->m_nUserID, offline, pMyGameTable->RobotBoutLog(exchange3cards.nExchange3Cards[0][0]), pMyGameTable->RobotBoutLog(exchange3cards.nExchange3Cards[0][1]),
                    pMyGameTable->RobotBoutLog(exchange3cards.nExchange3Cards[0][2]));
                pPlayer = pTable->m_ptrPlayers[offline];
                SimulateGameMsgFromUser(roomid, pPlayer, LOCAL_GAME_MSG_AUTO_EXCHANGECARDS, sizeof(EXCHANGE3CARDS), &exchange3cards, nTime * 1000);
            }
        }
    }
    else
    {
        for (int offline = 0; offline < pTable->m_nTotalChairs; offline++)
        {
            if (pTable->ValidateChair(offline)
                && pTable->IsRoboter(offline) && (-1 == pMyGameTable->m_nDingQueCardType[offline]))
            {
                OnPlayerOffline(pTable, offline);
                int nCardIDs[MAX_CARDS_PER_CHAIR];
                XygInitChairCards(nCardIDs, MAX_CARDS_PER_CHAIR);
                int nCardCount = pMyGameTable->GetChairCards(offline, nCardIDs, MAX_CARDS_PER_CHAIR);
                if (nCardCount)
                {
                    AUCTION_DINGQUE dingquecard;
                    ZeroMemory(&dingquecard, sizeof(dingquecard));
                    dingquecard.nChairNO = offline;
                    dingquecard.nDingQueCardType[offline] = -1;

                    int nTiaoCount = 0, nWanCount = 0, nTongCount = 0;
                    int nCardType = 0;
                    for (int k = 0; k < nCardCount; k++)
                    {
                        nCardType = pMyGameTable->m_pCalclator->MJ_CalculateCardShape(nCardIDs[k], 0);
                        if (MJ_CS_TIAO == nCardType)
                        {
                            nTiaoCount++;
                        }
                        else if (MJ_CS_DONG == nCardType)
                        {
                            nTongCount++;
                        }
                        else if (MJ_CS_WAN == nCardType)
                        {
                            nWanCount++;
                        }
                    }
                    nCardType = MJ_CS_WAN;
                    if (nTiaoCount < nWanCount)
                    {
                        nCardType = nTongCount < nTiaoCount ? MJ_CS_DONG : MJ_CS_TIAO;
                    }
                    else if (nTongCount < nWanCount)
                    {
                        nCardType = MJ_CS_DONG;
                    }
                    LOG_DEBUG("#############:%d", nCardType);
                    if (nCardType == MJ_CS_WAN)
                    {
                        if (nWanCount == nTiaoCount)
                        {
                            int nTime = rand() % 2;
                            if (nTime == 0)
                            {
                                nCardType = MJ_CS_WAN;
                            }
                            else
                            {
                                nCardType = MJ_CS_TIAO;
                            }
                        }
                        else if (nWanCount == nTongCount)
                        {
                            int nTime = rand() % 2;
                            if (nTime == 0)
                            {
                                nCardType = MJ_CS_WAN;
                            }
                            else
                            {
                                nCardType = MJ_CS_DONG;
                            }
                        }
                        else if ((nWanCount == nTiaoCount) && (nTiaoCount == nTongCount))
                        {
                            int nTime = rand() % 3;
                            if (nTime == 0)
                            {
                                nCardType = MJ_CS_WAN;
                            }
                            else if (nTime == 1)
                            {
                                nCardType = MJ_CS_TIAO;
                            }
                            else
                            {
                                nCardType = MJ_CS_DONG;
                            }
                        }
                    }
                    else if (nCardType == MJ_CS_TIAO)
                    {
                        if (nWanCount == nTiaoCount)
                        {
                            int nTime = rand() % 2;
                            if (nTime == 0)
                            {
                                nCardType = MJ_CS_WAN;
                            }
                            else
                            {
                                nCardType = MJ_CS_TIAO;
                            }
                        }
                        else if (nTiaoCount == nTongCount)
                        {
                            int nTime = rand() % 2;
                            if (nTime == 0)
                            {
                                nCardType = MJ_CS_TIAO;
                            }
                            else
                            {
                                nCardType = MJ_CS_DONG;
                            }
                        }
                        else if ((nWanCount == nTiaoCount) && (nTiaoCount == nTongCount))
                        {
                            int nTime = rand() % 3;
                            if (nTime == 0)
                            {
                                nCardType = MJ_CS_WAN;
                            }
                            else if (nTime == 1)
                            {
                                nCardType = MJ_CS_TIAO;
                            }
                            else
                            {
                                nCardType = MJ_CS_DONG;
                            }
                        }
                    }
                    else
                    {
                        if (nTongCount == nTiaoCount)
                        {
                            int nTime = rand() % 2;
                            if (nTime == 0)
                            {
                                nCardType = MJ_CS_DONG;
                            }
                            else
                            {
                                nCardType = MJ_CS_TIAO;
                            }
                        }
                        else if (nWanCount == nTongCount)
                        {
                            int nTime = rand() % 2;
                            if (nTime == 0)
                            {
                                nCardType = MJ_CS_WAN;
                            }
                            else
                            {
                                nCardType = MJ_CS_DONG;
                            }
                        }
                        else if ((nWanCount == nTiaoCount) && (nTiaoCount == nTongCount))
                        {
                            int nTime = rand() % 3;
                            if (nTime == 0)
                            {
                                nCardType = MJ_CS_WAN;
                            }
                            else if (nTime == 1)
                            {
                                nCardType = MJ_CS_TIAO;
                            }
                            else
                            {
                                nCardType = MJ_CS_DONG;
                            }
                        }
                    }
                    dingquecard.nDingQueCardType[offline] = nCardType;
                    pPlayer = pTable->m_ptrPlayers[offline];
                    SimulateGameMsgFromUser(roomid, pPlayer, LOCAL_GAME_MSG_AUTO_FIXMISS, sizeof(AUCTION_DINGQUE), &dingquecard, nTime * 1000);
                }
            }
        }
    }
}

void CMyGameServer::OnRobotGuoCard(CRoom* pRoom, CTable* pTable, int chairno)
{
    //必要的检查
    if (chairno >= MAX_CHAIRS_PER_TABLE || !pRoom || !pTable)
    {
        return;
    }

    LOG_DEBUG("OnRobotGuoCard: pRoom[%d] pTable[%d], chairno[%d]", pTable->m_nRoomID, pTable->m_nTableNO, chairno);
    CMyGameTable* pMyGameTable = (CMyGameTable*)pTable;

    int roomid = pRoom->m_nRoomID;
    int tableno = pTable->m_nTableNO;
    GUO_CARD cardguo;
    ZeroMemory(&cardguo, sizeof(GUO_CARD));
    cardguo.nChairNO = pMyGameTable->m_nAIOperateChairNO;
    cardguo.nCardChair = pMyGameTable->m_nAIOperateCardChairNO;
    CPlayer* pGuoPlayer = pTable->m_ptrPlayers[pMyGameTable->m_nAIOperateChairNO];
    pMyGameTable->ResetAIOpe();
    SimulateGameMsgFromUser(roomid, pGuoPlayer, LOCAL_GAME_MSG_AUTO_GUO, sizeof(GUO_CARD), &cardguo, 0);
}

void CMyGameServer::CalcResultWinOrLoss(void* pData, int nLen, CTable* pTable)
{
    LPGAME_WIN pGameWin = (LPGAME_WIN)pData;
    SOLO_PLAYER sp;
    CMyGameTable* pMyGameTable = (CMyGameTable*)pTable;
    for (int i = 0; i < pTable->m_nTotalChairs; i++)
    {
        //
        if (!pTable->m_ptrPlayers[i] || !LookupSoloPlayer(pTable->m_ptrPlayers[i]->m_nUserID, sp))
        {
            continue;
        }

        if (pTable->IsRoboter(i))
        {
            int nRate = pMyGameTable->GetShuffleRandomValue(100);
            UwlLogFile(_T("win lose rand = %d."), nRate);
            if (nRate > 0 && nRate <= pMyGameTable->GetRobotWinRate())
            {
                sp.nWin++;
            }
            else if (nRate > pMyGameTable->GetRobotWinRate() && nRate <= pMyGameTable->GetRobotWinRate() + pMyGameTable->GetRobotLossRate())
            {
                sp.nLoss++;
            }
            else
            {
                sp.nStandOff++;
            }
        }
        else
        {
            if (pTable->m_bNeedDeposit && pTable->m_nBaseDeposit)//优先按银子结算
            {
                if (pGameWin->nDepositDiffs[i] + pGameWin->nWinFees[i] > 0)
                {
                    sp.nWin++;                          // 赢(次数)
                }
                else if (pGameWin->nDepositDiffs[i] + pGameWin->nWinFees[i] < 0)
                {
                    sp.nLoss++;                     // 和(次数)
                }
                else
                {
                    sp.nStandOff++;                         // 输(次数)
                }
            }
            else
            {
                if (pGameWin->nScoreDiffs[i] > 0)
                {
                    sp.nWin++;                          // 赢(次数)
                }
                else if (pGameWin->nScoreDiffs[i] == 0)
                {
                    sp.nStandOff++;                     // 和(次数)
                }
                else
                {
                    sp.nLoss++;                         // 输(次数)
                }
            }
        }
        SetSoloPlayer(pTable->m_ptrPlayers[i]->m_nUserID, sp);
    }
}

BOOL CMyGameServer::CreateRobotTimer(CRoom* pRoom, CTable* pTable, DWORD dwStatus, int nWait)
{
    RemoveRobotTimer(pTable);
    LOG_DEBUG("CreateRobotTimer: pRoom[%d] pTable[%d]", pTable->m_nRoomID, pTable->m_nTableNO);
    if (pTable->GetCurrentChair() != INVALID_OBJECT_ID)
    {
        BOOL bRobotBout = FALSE;
        for (int j = 0; j < TOTAL_CHAIRS; j++)
        {
            if (pTable->IsRoboter(j))
            {
                bRobotBout = True;
            }
        }
        if (bRobotBout)
        {
            nWait = nWait + 3000; //超时3秒后走
            UwlTrace(_T("创建定时器成功, status=%x, nWait=%d......"), dwStatus, nWait);

            GAME_TIMER GameTimer;
            GameTimer.nRoomID = pTable->m_nRoomID;
            GameTimer.nTableNO = pTable->m_nTableNO;
            GameTimer.nChairNO = pTable->GetCurrentChair();
            GameTimer.dwStatus = dwStatus;

            SOCKET sock = GAME_SOCKET(pTable->m_nRoomID, pTable->m_nTableNO);
            LONG token = GAME_TOKEN(pTable->m_nRoomID, pTable->m_nTableNO);
            return SimulateDelayReqFromUser(sock, token, GR_GAME_TIMER, sizeof(GameTimer), &GameTimer, nWait);
        }

        return TRUE;
    }

    return FALSE;
}

BOOL CMyGameServer::RemoveRobotTimer(CTable* pTable)
{
    BOOL bRemove = FALSE;

    SOCKET sock = GAME_SOCKET(pTable->m_nRoomID, pTable->m_nTableNO);
    LONG token = GAME_TOKEN(pTable->m_nRoomID, pTable->m_nTableNO);

    try
    {
        CAutoLock lock(&m_csSimulate);

        SIMULATEREQ* font = NULL;
        SIMULATEREQ* req = m_SimulateHead;
        while (req)
        {
            if (req->hSocket == sock && req->lTokenID == token)
            {
                UwlTrace(_T("删除定时器成功......"));
                bRemove = TRUE;

                SIMULATEREQ* temp = req;
                if (font == NULL)
                {
                    m_SimulateHead = req->next;
                }
                else
                {
                    font->next = req->next;
                }

                req = req->next;
                SAFE_DELETE_ARRAY(temp->pDataPtr);
                SAFE_DELETE(temp);
                continue;
            }

            font = req;
            req = req->next;
        }
    }
    catch (...)
    {
        UwlLogFile(_T("服务器异常!!!,RemoveGameTimer, sock=%d, token=%d"), sock, token, pTable->m_nRoomID, pTable->m_nTableNO);
    }

    return bRemove;
}

BOOL CMyGameServer::RobotOnGameTimer(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt)
{
    LOG_TRACE(_T("CMyGameServer::RobotOnGameTimer"));
    SAFETY_NET_REQUEST(lpRequest, GAME_TIMER, pGameTimer);

    SOCKET sock = lpContext->hSocket;
    LONG token = lpContext->lTokenID;
    int roomid = pGameTimer->nRoomID;
    int tableno = pGameTimer->nTableNO;
    int chairno = INVALID_OBJECT_ID;
    int userid = 0;

    if (sock != GAME_SOCKET(roomid, tableno) || token != GAME_TOKEN(roomid, tableno))
    {
        LOG_DEBUG("RobotOnGameTimer Socket Or Token Error");
        UwlTrace(_T("定时器SOCKET,TOKEN和桌子号不一致, sock=%d, token=%d, roomid=%d, tableno=%d"), sock, token, roomid, tableno);
        UwlLogFile(_T("定时器SOCKET,TOKEN和桌子号不一致, sock=%d, token=%d, roomid=%d, tableno=%d"), sock, token, roomid, tableno);
        return TRUE;
    }

    CRoom* pRoom = NULL;
    CMyGameTable* pTable = NULL;

    if (!(pRoom = GetRoomPtr(roomid)))
    {
        LOG_DEBUG("RobotOnGameTimer Get No Room");
        return TRUE;
    }

    pTable = GetTablePtr(roomid, tableno);
    if (!pTable)
    {
        LOG_DEBUG("RobotOnGameTimer Get No Table");
        return TRUE;
    }

    if (pTable)
    {
        CAutoLock lock(&(pTable->m_csTable));
        LOG_DEBUG("RobotOnGameTimer Find Table");
        if (pTable->IsGameTimerValid(pGameTimer))
        {
            LOG_DEBUG("RobotOnGameTimer IsGameTimerValid");
            OnGameTimer(pGameTimer, pTable);
        }
    }

    return TRUE;
}

void CMyGameServer::OnGameTimer(LPGAME_TIMER pGameTimer, CMyGameTable* pTable)
{
    LOG_DEBUG("OnGameTimer Start");
    int nChairNO = pTable->GetCurrentChair();
    if (!pTable->ValidateChair(nChairNO))
    {
        return;
    }
    if (!pTable->m_ptrPlayers[nChairNO])
    {
        return;
    }
    LOG_DEBUG("OnGameTimer Find Player nChairNO[%d]", nChairNO);
    GAME_MSG GameMsg;
    memset(&GameMsg, 0, sizeof(GameMsg));

    GameMsg.nRoomID = pTable->m_nRoomID;
    GameMsg.nUserID = pTable->m_ptrPlayers[nChairNO]->m_nUserID;
    GameMsg.nMsgID = SYSMSG_GAME_CLOCK_STOP;

    SimulateDelayReqFromUser(pTable->m_ptrPlayers[nChairNO]->m_hSocket, pTable->m_ptrPlayers[nChairNO]->m_lTokenID, GR_SENDMSG_TO_SERVER, sizeof(GameMsg), &GameMsg, 0);
}

void CMyGameServer::OnRobotGiveUp(CRoom* pRoom, CTable* pTable, int chairno)
{
    //必要的检查
    if (chairno >= MAX_CHAIRS_PER_TABLE || !pRoom || !pTable)
    {
        return;
    }

    LOG_DEBUG("OnRobotGiveUp: room[%d], table[%d], chairNo[%d]", pTable->m_nRoomID, pTable->m_nTableNO, chairno);
    CMyGameTable* pMyGameTable = (CMyGameTable*)pTable;
    CPlayer* pPlayer = pTable->m_ptrPlayers[chairno];
    if (!pPlayer)
    {
        return;
    }
    int roomid = pRoom->m_nRoomID;;
    int tableno = pTable->m_nTableNO;
    if (IS_BIT_SET(pTable->m_dwStatus, TS_WAITING_GIVEUP))
    {
        for (int offline = 0; offline < pTable->m_nTotalChairs; offline++)
        {
            //if (bRobotBout)
            {
                int nTime = rand() % 4 + 2;
                if (pTable->ValidateChair(offline) && pTable->IsRoboter(offline) && (pMyGameTable->m_nGiveUpChair[offline] != -1))
                {
                    pPlayer = pTable->m_ptrPlayers[offline];

                    GIVE_UP_GAME giveUpGame;
                    memset(&giveUpGame, 0, sizeof(giveUpGame));
                    giveUpGame.nRoomID = pTable->m_nRoomID;
                    giveUpGame.nTableNO = pTable->m_nTableNO;
                    giveUpGame.nUserID = pPlayer->m_nUserID;
                    giveUpGame.nChairNO = offline;

                    SimulateGameMsgFromUser(roomid, pPlayer, LOCAL_GAME_MSG_AUTO_GIVEUP, sizeof(GIVE_UP_GAME), &giveUpGame, nTime * 1000);
                }
            }
        }
    }
    else
    {
        OnRobotAIPlay(pRoom, pTable, pTable->GetCurrentChair());
    }
}

void CMyGameServer::OnRobotXueLiuHu(CRoom* pRoom, CTable* pTable, int chairno)
{
    //必要的检查
    if (chairno >= MAX_CHAIRS_PER_TABLE || !pRoom || !pTable)
    {
        return;
    }
    DWORD dwTickWait = 2000;
    LOG_DEBUG("OnRobotXueLiuHu: room[%d], table[%d], chairNo[%d]", pTable->m_nRoomID, pTable->m_nTableNO, chairno);
    CMyGameTable* pMyGameTable = (CMyGameTable*)pTable;
    CPlayer* pPlayer = pTable->m_ptrPlayers[chairno];
    if (!pPlayer)
    {
        return;
    }
    int roomid = pRoom->m_nRoomID;;
    int tableno = pTable->m_nTableNO;
    int nRate = rand() % 100 + 1;

    //自动抓牌
    if (IS_BIT_SET(pTable->m_dwStatus, TS_WAITING_CATCH))
    {
        LOG_DEBUG("OnRobotXueLiuHu TS_WAITING_CATCH");
        int nTempForCatch = 0;
        try
        {
            BOOL bSomeOnehu = FALSE;
            int flag = 0;
            int nThrowChairNO = pTable->GetPrevChair(pTable->GetCurrentChair());
            nTempForCatch = 1;
            int nThrowIndex = 0;
            if (nThrowChairNO > INVALID_OBJECT_ID)
            {
                nThrowIndex = pMyGameTable->m_nOutCards[nThrowChairNO].GetSize() - 1;
            }
            nTempForCatch = 2;
            if (nThrowIndex >= 0)
            {
                nTempForCatch = 3;
                int nThrowCardID = pMyGameTable->m_nOutCards[nThrowChairNO][nThrowIndex];
                nTempForCatch = 4;
                if (nThrowCardID > INVALID_OBJECT_ID)
                {
                    for (int i = 0; i < pTable->m_nTotalChairs; i++)
                    {
                        if (nThrowChairNO == i)
                        {
                            continue;
                        }

                        if (IS_BIT_SET(pMyGameTable->m_dwPGCHFlags[i], MJ_HU) && (pMyGameTable->m_HuReady[i] && pMyGameTable->m_HuReady[i] != MJ_GIVE_UP))  //胡过一次后必须胡
                        {
                            LOG_DEBUG("OnRobotXueLiuHu Must Hu");
                            // 超时时  不能判断谁断线了,因为放炮玩家和i不是同一个玩家
                            bSomeOnehu = TRUE;
                            //剩四必胡
                            flag = 1;
                            if (pMyGameTable->IsLastFourCard())
                            {
                                LOG_DEBUG("OnRobotXueLiuHu IsLastFourCard");
                                OnSeverAutoPlayFangChongHu(pRoom, pTable, i, nThrowChairNO, nThrowCardID);

                            }
                            else if (pMyGameTable->m_HuReady[i] && pTable->IsOffline(i))
                            {
                                LOG_DEBUG("OnRobotXueLiuHu m_HuReady And IsOffline");
                                OnSeverAutoPlayFangChongHu(pRoom, pTable, i, nThrowChairNO, nThrowCardID);
                            }
                        }
                        else
                        {

                        }
                    }
                    if (flag == 0)
                    {
                        LOG_DEBUG("OnRobotXueLiuHu not Must Hu");
                        if (nRate <= pMyGameTable->GetAIHuRand() || pMyGameTable->IsLastFourCard())
                        {
                            LOG_DEBUG("OnRobotXueLiuHu AI FangChongHu Success");
                            OnSeverAutoPlayFangChongHu(pRoom, pTable, pMyGameTable->m_nAIOperateChairNO, pMyGameTable->m_nAIOperateCardChairNO, pMyGameTable->m_nAIOperateCardID);
                            //OnSeverAutoPlayFangChongHu(pRoom, pTable, i, nThrowChairNO, nThrowCardID);
                        }
                        else
                        {
                            LOG_DEBUG("OnRobotXueLiuHu AI FangChongHu Failed");
                            OnRobotGuoCard(pRoom, pTable, chairno);
                        }
                    }
                    // 解决一炮多响,一个切后台,两个点胡,直接过的问题
                    if (pMyGameTable->m_nWaitOpeMsgID == GR_RECONS_FANGPAO)
                    {
                        LOG_DEBUG("OnRobotXueLiuHu GR_RECONS_FANGPAO");
                        bSomeOnehu = TRUE;
                    }
                }
                nTempForCatch = 6;
            }
            if (bSomeOnehu)
            {
                LOG_DEBUG("OnRobotXueLiuHu bSomeOnehu = TRUE");
                return;
            }
        }
        catch (...)
        {
            UwlLogFile(_T("OnRobotXueLiuHu  The Exception OnSeverAutoPlay TS_WAITING_CATCH nTempForCatch:%d"), nTempForCatch);
        }
    }

    if (IS_BIT_SET(pTable->m_dwStatus, TS_WAITING_THROW))
    {
        LOG_DEBUG("OnRobotXueLiuHu TS_WAITING_THROW");
        if (pMyGameTable->IsLastFourCard())
        {
            DWORD dRet = pMyGameTable->CalcHu_Zimo(chairno, pMyGameTable->m_nCurrentCard);
            if (IS_BIT_SET(dRet, MJ_HU))
            {
                OnSeverAutoPlayHuZiMo(pRoom, pTable, pTable->GetCurrentChair(), pMyGameTable->m_nCurrentCard);
                return;
            }
        }

        int nCardIDs[MAX_CARDS_PER_CHAIR];
        XygInitChairCards(nCardIDs, MAX_CARDS_PER_CHAIR);
        int nCardCount = pMyGameTable->GetChairCards(chairno, nCardIDs, MAX_CARDS_PER_CHAIR);
        if (nCardCount)
        {
            if (pTable->IsRoboter(chairno))
            {
                int nTime = rand() % 4 + 1;
                LOG_DEBUG("OnRobotXueLiuHu Robtot send LOCAL_GAME_MSG_AUTO_THROW time[%d]", nTime);
                SimulateGameMsgFromUser(roomid, pPlayer,
                    LOCAL_GAME_MSG_AUTO_THROW, 0, NULL, nTime * 1000);
            }
            else
            {
                if (GetTickCount() - pTable->m_dwActionBegin >= dwTickWait)
                {
                    //等待超时，那么立即执行
                    SimulateGameMsgFromUser(roomid, pPlayer,
                        LOCAL_GAME_MSG_AUTO_THROW, 0, NULL, 0);
                }
            }

        }
    }
}

void CMyGameServer::OnCustomRoomWndMsg(IN CONST MSG* lpMsg)
{
    switch (lpMsg->message)
    {
    case WM_RTG_ROBOT_LEAVE:
        //case WM_RTG_ROBOT_INFO:
        LetRobotLeave(lpMsg->wParam);
        break;

    default:
        __super::OnCustomRoomWndMsg(lpMsg);
        break;
    }
}

