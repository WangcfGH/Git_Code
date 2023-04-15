#include "stdafx.h"


CCommonBaseServer::CCommonBaseServer(const TCHAR* szLicenseFile, const TCHAR* szProductName, const TCHAR* szProductVer, const int nListenPort, const int nGameID, DWORD flagEncrypt, DWORD flagCompress)
    : CMainServer(szLicenseFile, szProductName, szProductVer, nListenPort, nGameID, flagEncrypt, flagCompress)
{
}

BOOL CCommonBaseServer::Initialize()
{
    BOOL bRet = __super::Initialize();
    evSvrStart.notify(bRet, &m_msgCenter);
    return bRet;
}

void CCommonBaseServer::Shutdown()
{
    evShutdown.notify();
    __super::Shutdown();
}

BOOL CCommonBaseServer::OnRequest(void* lpParam1, void* lpParam2)
{
    LPCONTEXT_HEAD  lpContext = LPCONTEXT_HEAD(lpParam1);
    LPREQUEST       lpRequest = LPREQUEST(lpParam2);

    CWorkerContext* pThreadCxt = reinterpret_cast<CWorkerContext*>(GetWorkerContext());
    if (!m_msgCenter.notify(lpContext, lpRequest))
    {
        switch (lpRequest->head.nRequest)
        {
            CASE_REQUEST_HANDLE(GR_SEND_LBSINFO, OnSendLBSInfo)
            CASE_REQUEST_HANDLE(GR_PROMPT_PLAYER, OnPromptPlayer)
        default:
            UwlTrace(_T("goto default proceeding..."));
            __super::OnRequest(lpParam1, lpParam2);
            break;
        }
    }
    UwlClearRequest(lpRequest);

    return TRUE;
}

CTable* CCommonBaseServer::OnNewTable(int roomid, int tableno, int score_mult)
{
    //chairNum
    int nRoomOption = GetRoomOption(roomid);
    int playerNum = GetChairCount(roomid);
    LOG_INFO("OnNewTable = playernum:%d, roomOption:%d", playerNum, nRoomOption);

    CCommonBaseTable* table = new CCommonBaseTable(roomid, tableno, score_mult, playerNum);

    table->InitModel();

    evNewTable(table);

    return table;
}

BOOL CCommonBaseServer::SendUserResponse(LPCONTEXT_HEAD lpContext, LPREQUEST lpResponse, BOOL passive /*= FALSE*/, BOOL compressed /*= FALSE*/)
{
    evSendResponse.notify(lpContext, lpResponse, passive, compressed);
    return __super::SendUserResponse(lpContext, lpResponse, passive, compressed);
}

BOOL CCommonBaseServer::NotifyResponseSucceesd(LPCONTEXT_HEAD lpContext, void* pData/* = NULL*/, int nLen/* = 0*/)
{
    if (lpContext->bNeedEcho)
    {
        lpContext->bNeedEcho = FALSE; //已经回应过不再回应
        REQUEST response;
        memset(&response, 0, sizeof(response));
        response.pDataPtr = pData;
        response.nDataLen = nLen;
        response.head.nRequest = UR_OPERATE_SUCCEEDED;
        return SendUserResponse(lpContext, &response);
    }
    else
    {
        return TRUE;
    }
}

BOOL CCommonBaseServer::NotifyResponseFaild(LPCONTEXT_HEAD lpContext, BOOL bPassive)
{
    if (lpContext->bNeedEcho)
    {
        return SendFailedResponse(lpContext, bPassive);
    }
    else
    {
        return TRUE;
    }
}

BOOL CCommonBaseServer::YQW_OnPlayerInfo(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt)

{
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
    BOOL lookon = FALSE;

    CTable* pTable = NULL;
    CPlayer* pPlayer = NULL;

    token = lpContext->lTokenID;
    sock = lpContext->hSocket;

    if (lpRequest->nDataLen < (int)sizeof(YQW_PLAYER_INFO))
    {
        response.head.nRequest = UR_OPERATE_FAILED;
        return SendUserResponse(lpContext, &response);
    }

    LPYQW_PLAYER_INFO lpPlayerInfo = (LPYQW_PLAYER_INFO)(lpRequest->pDataPtr);

    roomid = lpPlayerInfo->nRoomID;
    tableno = lpPlayerInfo->nTableNO;
    userid = lpPlayerInfo->nUserID;
    chairno = lpPlayerInfo->nChairNO;

    if (!IsYQWRoom(roomid))
    {
        response.head.nRequest = UR_OPERATE_FAILED;
        return SendUserResponse(lpContext, &response);
    }

    if (!(pTable = GetTablePtr(roomid, tableno)))
    {
        response.head.nRequest = UR_OPERATE_FAILED;
        return SendUserResponse(lpContext, &response);
    }

    if (pTable)
    {
        LOCK_TABLE(pTable, chairno, FALSE, userid, token);

        pPlayer = pTable->m_ptrPlayers[chairno];
        if (!pPlayer || pPlayer->m_nUserID != userid)
        {
            response.head.nRequest = UR_OPERATE_FAILED;
            return SendUserResponse(lpContext, &response);
        }

        if (!(lpPlayerInfo->nUserIdent == YQW_USER_IDENT_MASTER
                || lpPlayerInfo->nUserIdent == YQW_USER_IDENT_GUEST
                || lpPlayerInfo->nUserIdent == YQW_USER_IDENT_AGENT))
        {
            response.head.nRequest = UR_OPERATE_FAILED;
            return SendUserResponse(lpContext, &response);
        }

        int nPreferAmount = 0;
        if (lpPlayerInfo->nUserIdent == YQW_USER_IDENT_GUEST)
        {
            CYQWGameData yqwGameData;
            if (!YQW_LookupGameData(roomid, tableno, yqwGameData))
            {
                response.head.nRequest = UR_OPERATE_FAILED;
                return SendUserResponse(lpContext, &response);
            }

            YQW_RemoveTempEnterGame(userid);
            response.head.nRequest = UR_OPERATE_SUCCEEDED;
            (void)SendUserResponse(lpContext, &response);
        }
        else if (lpPlayerInfo->nUserIdent == YQW_USER_IDENT_MASTER)
        {
            if (lpRequest->nDataLen < (int)(sizeof(YQW_PLAYER_INFO) + sizeof(YQW_ROOM_SETTING)))
            {
                response.head.nRequest = UR_OPERATE_FAILED;
                return SendUserResponse(lpContext, &response);
            }

            YQW_ROOM_VALUE room_value = { 0 };
            if (!YQW_LookupTempRoomValue(roomid, tableno, room_value))
            {
                response.head.nRequest = UR_OPERATE_FAILED;
                return SendUserResponse(lpContext, &response);
            }
            if (room_value.nAllocFlag != YQW_ALLOC_FLAG_NORMAL_ROOM)
            {
                response.head.nRequest = UR_OPERATE_FAILED;
                return SendUserResponse(lpContext, &response);
            }
            YQW_RemoveTempRoomValue(room_value.nRoomNo);
            YQW_RemoveTempEnterGame(userid);

            response.head.nRequest = UR_OPERATE_SUCCEEDED;
            (void)SendUserResponse(lpContext, &response);
            //////////////////////////////////////////////////////////////////////////
            LPYQW_ROOM_SETTING lpRoomSetting = (LPYQW_ROOM_SETTING)(lpPlayerInfo + 1);
            BYTE* lpRuleData = (BYTE*)(lpRoomSetting + 1);

            CYQWGameData yqwGameData;
            yqwGameData.game_data.nUserId = room_value.nUserID;
            YQW_ConstructGameData(yqwGameData, &room_value, lpRoomSetting, lpRuleData);
            //////////////////////////////////////////////////////////////////////////
            pTable->m_bYqwTable = TRUE;
            pTable->m_nYqwRoomNo = yqwGameData.game_data.nRoomNo;
            pTable->m_dwYqwFeeMode = yqwGameData.game_data.dwFeeMode;
            pTable->m_dwYqwRoomOption = yqwGameData.game_data.dwRoomOption;
            pTable->YQW_SetRuleString(std::string((const char*)lpRuleData, lpRoomSetting->nRuleLen));
            //////////////////////////////////////////////////////////////////////////
            yqwGameData.game_data.nTotalCost = pTable->YQW_CalcDeductHappyCoin();

            if (IS_BIT_SET(yqwGameData.game_data.dwFeeMode, YQW_FEE_MODE_COUPON))
            {
                LPYQW_COUPON_SETTING lpCouponSetting = (LPYQW_COUPON_SETTING)(lpRuleData + lpRoomSetting->nRuleLen);
                nPreferAmount = lpCouponSetting->nPreferAmount;
                lstrcpyn(yqwGameData.game_data.szCouponId, lpCouponSetting->szCouponId, DEF_YQW_COUPONID_LEN);
                int sprintfLen = _stprintf_s(yqwGameData.game_data.szCouponOrder, _T("%s_%s_coupon"),
                        yqwGameData.game_data.szYQWRoomId, m_szProductName);
                assert(sprintfLen < MAX_HAPPYCOUPON_ORDER_LEN);
            }
            YQW_SetGameData(roomid, tableno, yqwGameData);
        }
        else if (lpPlayerInfo->nUserIdent == YQW_USER_IDENT_AGENT)
        {
            CYQWGameData yqwGameData;
            if (YQW_LookupGameData(roomid, tableno, yqwGameData))
            {
                YQW_RemoveTempEnterGame(userid);
                response.head.nRequest = UR_OPERATE_SUCCEEDED;
                (void)SendUserResponse(lpContext, &response);
            }
            else
            {
                if (lpRequest->nDataLen < (int)(sizeof(YQW_PLAYER_INFO) + sizeof(YQW_ROOM_SETTING)))
                {
                    response.head.nRequest = UR_OPERATE_FAILED;
                    return SendUserResponse(lpContext, &response);
                }

                YQW_ROOM_VALUE room_value = { 0 };
                if (!YQW_LookupTempRoomValue(roomid, tableno, room_value))
                {
                    response.head.nRequest = UR_OPERATE_FAILED;
                    return SendUserResponse(lpContext, &response);
                }

                if (room_value.nAllocFlag == YQW_ALLOC_FLAG_NORMAL_ROOM)
                {
                    response.head.nRequest = UR_OPERATE_FAILED;
                    return SendUserResponse(lpContext, &response);
                }

                YQW_RemoveTempRoomValue(room_value.nRoomNo);
                YQW_RemoveTempEnterGame(userid);

                response.head.nRequest = UR_OPERATE_SUCCEEDED;
                (void)SendUserResponse(lpContext, &response);
                //////////////////////////////////////////////////////////////////////////
                LPYQW_ROOM_SETTING lpRoomSetting = (LPYQW_ROOM_SETTING)(lpPlayerInfo + 1);
                BYTE* lpRuleData = (BYTE*)(lpRoomSetting + 1);

                yqwGameData.game_data.nUserId = room_value.nUserID;
                YQW_ConstructGameData(yqwGameData, &room_value, lpRoomSetting, lpRuleData);

                // 扣玩家币模式计算应扣欢乐币，在游戏开始时校验欢乐币余额
                if (TRUE == yqwGameData.IsAgentPayerPlayer())
                {
                    yqwGameData.game_data.nTotalCost = lpRoomSetting->nTotalCost;
                }

                YQW_SetGameData(roomid, tableno, yqwGameData);
                //////////////////////////////////////////////////////////////////////////
                pTable->m_bYqwTable = TRUE;
                pTable->m_bYqwAgent = TRUE;
                pTable->m_nYqwRoomNo = yqwGameData.game_data.nRoomNo;
                pTable->m_dwYqwFeeMode = yqwGameData.game_data.dwFeeMode;
                pTable->m_dwYqwRoomOption = yqwGameData.game_data.dwRoomOption;
                pTable->YQW_SetRuleString(std::string((const char*)lpRuleData, lpRoomSetting->nRuleLen));
            }
        }

        //////////////////////////////////////////////////////////////////////////
        YQW_PLAYER yqwPlayer;
        ZeroMemory(&yqwPlayer, sizeof(yqwPlayer));
        YQW_ConstructPlayerData(yqwPlayer, pTable, lpPlayerInfo);
        YQW_SetPlayer(userid, yqwPlayer);
        //////////////////////////////////////////////////////////////////////////

        if (lpPlayerInfo->nUserIdent == YQW_USER_IDENT_MASTER)
        {
            YQW_OnPlayerEnterGame(lpContext, lpPlayerInfo, pTable, pPlayer);
            (void)YQW_TransmitUserEnter(pTable, chairno, TRUE);

            if (pTable->IsYQWCouponMode())
            {
                (void)YQW_EjectPreDeductCoupon(pTable, nPreferAmount);
            }
        }
        else if (lpPlayerInfo->nUserIdent == YQW_USER_IDENT_GUEST)
        {
            YQW_OnPlayerEnterGame(lpContext, lpPlayerInfo, pTable, pPlayer);
            (void)YQW_TransmitUserEnter(pTable, chairno, FALSE);
        }
        else if (lpPlayerInfo->nUserIdent == YQW_USER_IDENT_AGENT)
        {
            YQW_OnPlayerEnterGame(lpContext, lpPlayerInfo, pTable, pPlayer);
            (void)YQW_TransmitUserEnter(pTable, chairno, FALSE);
        }
    }

    return TRUE;
}

void CCommonBaseServer::YQW_OnPlayerEnterGame(LPCONTEXT_HEAD lpContext, LPYQW_PLAYER_INFO pPlayerInfo, CTable* pTable, CPlayer* pPlayer)
{
    __super::YQW_OnPlayerEnterGame(lpContext, pTable, pPlayer);
    evYQWPlayerInfo.notify(lpContext, pPlayerInfo, static_cast<CCommonBaseTable*>(pTable), pPlayer);
}

BOOL CCommonBaseServer::YQW_TransmitUserLeaveE1(CTable* pTable, int chairno, DWORD flag)
{
    evYQW_TransmitUserLeaveE1.notify(static_cast<CCommonBaseTable*>(pTable), chairno, flag);
    return __super::YQW_TransmitUserLeaveE1(pTable, chairno, flag);
}

void CCommonBaseServer::OnCPGameWin(LPCONTEXT_HEAD lpContext, int nRoomId, CTable* pTable, void* pData)
{
    __super::OnCPGameWin(lpContext, nRoomId, pTable, pData);
    evOnCPGameWin.notify(lpContext, nRoomId, static_cast<CCommonBaseTable*>(pTable), pData);
}

VOID CCommonBaseServer::OnCPPlayerEnterGame(LPCONTEXT_HEAD lpContext, int roomid, CTable* pTable, CPlayer* pPlayer)
{
    __super::OnCPPlayerEnterGame(lpContext, roomid, pTable, pPlayer);
    evOnCPPlayerEnterGame.notify(lpContext, roomid, static_cast<CCommonBaseTable*>(pTable), pPlayer);
}

void CCommonBaseServer::OnCPEnterGameDXXW(LPCONTEXT_HEAD lpContext, int nRoomid, CTable* pTable, CPlayer* pPlayer)
{
    __super::OnCPEnterGameDXXW(lpContext, nRoomid, pTable, pPlayer);
    evOnCPEnterGameDXXW.notify(lpContext, nRoomid, static_cast<CCommonBaseTable*>(pTable), pPlayer);
}

void CCommonBaseServer::YQW_CloseSoloTable(CTable* pTable, int roomid, DWORD dwAbortFlag)
{
    evYQWCloseSoloTable.notify(static_cast<CCommonBaseTable*>(pTable), roomid, dwAbortFlag);
    __super::YQW_CloseSoloTable(pTable, roomid, dwAbortFlag);
}

void CCommonBaseServer::OnCPDealReplayGameWinData(CTable* pTable, void* pData, int nLen)
{
    __super::OnCPDealReplayGameWinData(pTable, pData, nLen);
    evOnCPDealReplayGameWinData.notify(static_cast<CCommonBaseTable*>(pTable), pData, nLen);
}

int CCommonBaseServer::RemoveOneClients(CTable* pTable, int nUserID, BOOL to_close /*= FALSE*/)
{
    evRemoveOneClients.notify(static_cast<CCommonBaseTable*>(pTable), nUserID, to_close);

    int r_id = 0;
    int t_no = INVALID_OBJECT_ID;
    int u_id = 0;

    int userid = 0;
    CPlayer* ptr = NULL;
    auto pos = pTable->m_mapUser.GetStartPosition();
    while (pos)
    {
        pTable->m_mapUser.GetNextAssoc(pos, userid, ptr);

        if (ptr && ptr->m_nUserID == nUserID)
        {
            (void)RemoveTokenData(ptr->m_lTokenID, r_id, t_no, u_id);
            //          if(to_close) CloseClient(ptr->m_hSocket, ptr->m_lTokenID);
            BOOL bRoboter = ptr->IsRoboter();
            if (to_close || bRoboter)   //Modify on 20130415 被强制关闭的，清除token,nLastConnect，防止断线被多记录一次
            {
                (void)CloseClient(ptr->m_hSocket, ptr->m_lTokenID);
                UserCloseClient(ptr->m_lTokenID);
            }
        }
    }

    return CBaseServer::RemoveOneClients(pTable, nUserID, to_close);
}

int CCommonBaseServer::NotifyTableVisitors(CTable* pTable, UINT nRequest, void* pData, int nLen, LONG tokenExcept /*= 0*/, BOOL compressed /*= FALSE*/)
{
    evNotifyTableVisitors.notify(static_cast<CCommonBaseTable*>(pTable), nRequest, pData, nLen);
    return __super::NotifyTableVisitors(pTable, nRequest, pData, nLen, tokenExcept, compressed);
}

void CCommonBaseServer::OnCPStartSoloTable(START_SOLOTABLE* pStartSoloTable, CTable* pTable, void* pData)
{
    __super::OnCPStartSoloTable(pStartSoloTable, pTable, pData);
    evCPStartSoloTable.notify(pStartSoloTable, static_cast<CCommonBaseTable*>(pTable), pData);
}

void CCommonBaseServer::OnCPOnGameStarted(CTable* pTable, void* pData)
{
    __super::OnCPOnGameStarted(pTable, pData);
    evCPGameStarted.notify(static_cast<CCommonBaseTable*>(pTable), pData);
}

void CCommonBaseServer::YQW_OnCPDeductHappyCoinResult(CTable* pTable, LPYQW_DEDUCT_HAPPYCOIN pDeductReq, LPYQW_HAPPYCOIN_CHANGE pDeductRet)
{
    __super::YQW_OnCPDeductHappyCoinResult(pTable, pDeductReq, pDeductRet);
    evYQW_OnCPDeductHappyCoinResult.notify(static_cast<CCommonBaseTable*>(pTable), pDeductReq, pDeductRet);
}

void CCommonBaseServer::OnCPExchGameGoods(int nUserID, int nStatusCode, LPEXCH_GOODS_DATA pData)
{
    __super::OnCPExchGameGoods(nUserID, nStatusCode, pData);
    evOnCPExchGameGoods.notify(nUserID, nStatusCode, pData);
}

void CCommonBaseServer::YQW_OnCPGameWin(LPCONTEXT_HEAD lpContext, int nRoomId, CTable* pTable, void* pData)
{
    __super::YQW_OnCPGameWin(lpContext, nRoomId, pTable, pData);
    evOnCPGameWin.notify(lpContext, nRoomId, static_cast<CCommonBaseTable*>(pTable), pData);
}

BOOL CCommonBaseServer::TransmitGameResultEx(CTable* pTable, LPCONTEXT_HEAD lpContext, LPREFRESH_RESULT_EX lpRefreshResult, LPGAME_RESULT_EX lpGameResult, int nGameResultSize)
{
    BOOL ret = __super::TransmitGameResultEx(pTable, lpContext, lpRefreshResult, lpGameResult, nGameResultSize);
    if (ret)
    {
        evTransmitGameResultEx.notify(static_cast<CCommonBaseTable*>(pTable), lpContext, lpRefreshResult, lpGameResult, nGameResultSize);
    }
    return ret;
}

BOOL CCommonBaseServer::IsNeedWaitArrageTable(CTable* pTable, int nRoomID, int nUserID)
{
    if (!pTable)
    {
        return FALSE;
    }

    if (!IsSoloRoom(nRoomID))
    {
        return FALSE;
    }

    /* nUserID reserved*/

    if (!pTable->IsGameOver())
    {
        return FALSE;
    }

    TCHAR szRoomID[16];
    memset(szRoomID, 0, sizeof(szRoomID));
    _stprintf_s(szRoomID, _T("%ld"), nRoomID);

    int max_table_bout = GetPrivateProfileInt(
            _T("maxtablebout"),     // section name
            szRoomID,               // key name
            MAX_TABLE_BOUT,         // default int
            m_szIniFile             // initialization file name
        );

    //已经达到桌局数上限，那么重新向RoomSvr请求分桌
    if (pTable->m_nBoutCount >= max_table_bout)
    {
        return TRUE;
    }

    //add by jinp 有玩家断线时，重新配桌，不太准确
    for (int i = 0; i < pTable->m_nTotalChairs; i++)
    {
        if (((CCommonBaseTable*)pTable)->m_bOffline[i])
        {
            return TRUE;
        }
    }

    return FALSE;
}

BOOL CCommonBaseServer::OnEnterGame(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt)
{
    REQUEST response;
    memset(&response, 0, sizeof(response));

    REQUEST YqwPlayerEnter;
    memset(&YqwPlayerEnter, 0, sizeof(YqwPlayerEnter));
    REQUEST YqwHistoryResult;
    memset(&YqwHistoryResult, 0, sizeof(YqwHistoryResult));

    SOCKET sock = INVALID_SOCKET;
    LONG token = 0;
    int gameid = 0;
    int roomid = 0;
    int tableno = INVALID_OBJECT_ID;
    int userid = 0;
    int chairno = INVALID_OBJECT_ID;

    sock = lpContext->hSocket;
    token = lpContext->lTokenID;

    LPENTER_GAME_EX pEnterGame = (LPENTER_GAME_EX)(PBYTE(lpRequest->pDataPtr));
    if (lpRequest->nDataLen < (int)sizeof(ENTER_GAME_EX) || !pEnterGame) //长度指针检查
    {
        return NotifyResponseFaild(lpContext);
    }

    gameid = pEnterGame->nGameID;
    roomid = pEnterGame->nRoomID;
    tableno = pEnterGame->nTableNO;
    userid = pEnterGame->nUserID;
    chairno = pEnterGame->nChairNO;

    if (roomid <= 0 || tableno < 0 || userid <= 0 || chairno < 0 || chairno >= MAX_CHAIR_COUNT
        || gameid != m_nGameID)
    {
        return SendFailedResponse(lpContext);
    }
    //长度检查
    if (IsSoloRoom(roomid) && lpRequest->nDataLen != (sizeof(ENTER_GAME_EX) + sizeof(SOLO_PLAYER)))
    {
        return NotifyResponseFaild(lpContext);
    }
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

    return __super::OnEnterGame(lpContext, lpRequest, pThreadCxt);
}

BOOL CCommonBaseServer::IsTrueChairAndTable(int nUserID, int nRoomID, int nTableNO, int nChairNO, SOCKET sock, LONG token)
{
    CTable* pTable = NULL;
    //CPlayer* pPlayer = NULL;

    //确认该玩家不在同房间的另外一桌上游戏
    USER_DATA user_data;
    memset(&user_data, 0, sizeof(user_data));
    if (!LookupUserData(nUserID, user_data))
    {
        return TRUE;
    }

    if (user_data.nRoomID == nRoomID
        && user_data.nTableNO == nTableNO
        && user_data.nChairNO == nChairNO)
    {
        return TRUE;
    }
    if (!(pTable = (CTable*)GetTablePtr(user_data.nRoomID, user_data.nTableNO)))
    {
        return TRUE;
    }
    if (pTable)
    {
        LOCK_TABLE_EX(pTable, user_data.nChairNO, FALSE, 0, 0);

        if (pTable->IsPlayer(nUserID) &&
            pTable->ValidateChair(user_data.nChairNO) &&
            user_data.nRoomID == nRoomID && IsRandomRoom(nRoomID))
        {
            if (nChairNO != user_data.nChairNO || nTableNO != user_data.nTableNO)
            {
                return FALSE;
            }
        }
    }

    return TRUE;
}

BOOL CCommonBaseServer::OnSendLBSInfo(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt)
{
    int token = 0;
    int roomid = 0;
    int tableno = INVALID_OBJECT_ID;
    int userid = 0;

    token = lpContext->lTokenID;
    CTable* pTable = NULL;

    LPSENDLBSINFO pData = LPSENDLBSINFO(PBYTE(lpRequest->pDataPtr));
    roomid = pData->nRoomID;
    tableno = pData->nTableNO;
    userid = pData->nUserID;
    if (!(pTable = (CTable*)GetTablePtr(roomid, tableno)))
    {
        return TRUE;
    }
    if (pTable)
    {
        YQW_PLAYER yqwPlayer;
        ZeroMemory(&yqwPlayer, sizeof(yqwPlayer));

        if (YQW_LookupPlayer(userid, yqwPlayer))
        {
            lstrcpyn(yqwPlayer.szLBSInfo, pData->szLBSInfo, MAX_YQW_LBS_LEN);
            lstrcpyn(yqwPlayer.szLbsArea, pData->szLbsArea, MAX_YQW_AREA_LEN);
            YQW_SetPlayer(userid, yqwPlayer);

            CAutoLock lock(&(pTable->m_csTable));
            NotifyTablePlayers(pTable, GR_SEND_LBSINFO, pData, sizeof(SENDLBSINFO), token);
        }
    }

    return TRUE;
}

BOOL CCommonBaseServer::OnPromptPlayer(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, CWorkerContext* pThreadCxt)
{
    REQUEST response;
    memset(&response, 0, sizeof(response));

    LONG token = lpContext->lTokenID;
    CTable* pTable = NULL;
    CPlayer* pPlayer = NULL;
    CPlayer* pPromptPlayer = NULL;

    SAFETY_NET_REQUEST(lpRequest, PROMPTPLAYER, lpPromptPlayer);

    int nRoomId = lpPromptPlayer->nRoomID;
    int nTableNo = lpPromptPlayer->nTableNO;
    int nUserId = lpPromptPlayer->nUserID;
    int nChairNo = lpPromptPlayer->nChairNO;
    int nPromptUserId = lpPromptPlayer->nPromptUserID;

    if (!BaseVerify(nRoomId, nTableNo, nChairNo, nUserId))
    {
        return NotifyResponseFaild(lpContext);
    }

    if (!IsSoloRoom(nRoomId))
    {
        return NotifyResponseFaild(lpContext);
    }

    pTable = GetTablePtr(nRoomId, nTableNo);
    if (!pTable)
    {
        return NotifyResponseFaild(lpContext);
    }

    if (pTable)
    {
        LOCK_TABLE(pTable, nChairNo, FALSE, nUserId, token);
        if (!(pPlayer = pTable->GetPlayer(nUserId)))  // 不是玩家
        {
            UwlLogFile(_T("user not player. user %ld Shield Looker failed."), nUserId);
            return TRUE;
        }

        /*if (IS_BIT_SET(pTable->m_dwStatus, TS_PLAYING_GAME)){
        return SendUserResponse(lpContext, &response);
        }*/

        if (IsCloakingRoom(nRoomId))
        {
            return NotifyResponseFaild(lpContext);
        }

        //0表示给桌面所有玩家发送提醒
        if (nPromptUserId != 0)
        {
            for (int i = 0; i < pTable->m_nTotalChairs; i++)
            {
                if (pTable->m_ptrPlayers[i]->m_nUserID == nPromptUserId)
                {
                    pPromptPlayer = pTable->m_ptrPlayers[i];
                    break;
                }
            }
            if (pPromptPlayer)
            {
                NotifyOneUser(pPromptPlayer->m_hSocket, pPromptPlayer->m_lTokenID, GR_PROMPT_PLAYER, lpRequest->pDataPtr, lpRequest->nDataLen);
            }
        }
        else
        {
            for (int i = 0; i < pTable->m_nTotalChairs; i++)
            {
                pPromptPlayer = pTable->m_ptrPlayers[i];
                if (pPromptPlayer && (!IS_BIT_SET(pTable->m_dwUserStatus[i], US_GAME_STARTED)))
                {
                    NotifyOneUser(pPromptPlayer->m_hSocket, pPromptPlayer->m_lTokenID, GR_PROMPT_PLAYER, lpRequest->pDataPtr, lpRequest->nDataLen);
                }
            }
        }
    }

    response.head.nRequest = UR_OPERATE_SUCCEEDED;
    return SendUserResponse(lpContext, &response);
}

BOOL CCommonBaseServer::SimulateGameMsgFromUser(int nRoomID, CPlayer* player, int nMsgID, int nDatalen, void* data, DWORD dwSpace)
{
    if (!player)
    {
        return FALSE;
    }

    int size = nDatalen + sizeof(GAME_MSG);
    BYTE* pGameMsg = new BYTE[size];
    memset(pGameMsg, 0, size);
    GAME_MSG* pHead = (GAME_MSG*)pGameMsg;
    BYTE* pData = pGameMsg + sizeof(GAME_MSG);

    pHead->nRoomID = nRoomID;
    pHead->nMsgID = nMsgID;
    pHead->nUserID = player->m_nUserID;
    pHead->nVerifyKey = -1;
    pHead->nDatalen = nDatalen;

    //一起玩不能帮人出牌不能托管,但要走自动托管
    // 如果某些YQW的消息不能模拟，请程序在调用的时候区分不要走，而不是在这个功能接口内部进行判断
    //if (IsYQWRoom(nRoomID) && !YQWGameMsgCheck(pHead->nMsgID))
    //{
    //    return FALSE;
    //}

    if (nDatalen)
    {
        memcpy(pData, data, nDatalen);
    }
    LOG_DEBUG("SimulateGameMsgFromUser11111111111111:%d", nMsgID);
    BOOL bn = TRUE;
    if (dwSpace == 0)
    {
        LOG_DEBUG("SimulateGameMsgFromUser222222222222222");
        bn = SimulateReqFromUser(player->m_hSocket, player->m_lTokenID, GR_SENDMSG_TO_SERVER, size, pGameMsg);
    }
    else
    {
        CreateSimulateRequst(dwSpace, GR_SENDMSG_TO_SERVER, size, pGameMsg, player->m_hSocket, player->m_lTokenID);
        delete[]pGameMsg;
    }

    return bn;
}
