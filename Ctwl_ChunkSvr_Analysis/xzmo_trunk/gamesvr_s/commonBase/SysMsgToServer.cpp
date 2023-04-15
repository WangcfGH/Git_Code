#include "stdafx.h"
#include "SysMsgToServer.h"

void SysMsgToServer::OnServerStart(BOOL& ret, TcyMsgCenter* msgCenter)
{
    if (ret)
    {
        AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_SENDMSG_TO_SERVER, OnSendSysMsgToServer);

        RegsiterSysMsgOpera();
    }
}

void SysMsgToServer::RegsiterSysMsgOpera()
{
    m_msgid2Opera.insert({ SYSMSG_GAME_CLOCK_STOP, [this](SysMsgOperaPack * pack) {
            return OnSysMsg_GameClockStop(pack);
        }
    });
    m_msgid2Opera.insert({ YQW_SYSMSG_PLAYER_ONLINE, [this](SysMsgOperaPack * pack) {
            return OnSysMsg_PlayerOnline(pack);
        }
    });
    m_msgid2Opera.insert({ SYSMSG_PLAYER_ONLINE, [this](SysMsgOperaPack * pack) {
            return OnSysMsg_PlayerOnline(pack);
        }
    });
    m_msgid2Opera.insert({ SYSMSG_GAME_ON_AUTOPLAY, [this](SysMsgOperaPack * pack) {
            return OnSysMsg_GameOnAutoPlay(pack);
        }
    });
    m_msgid2Opera.insert({ SYSMSG_GAME_CANCEL_AUTOPLAY, [this](SysMsgOperaPack * pack) {
            return OnSysMsg_GameCancelAutoPlay(pack);
        }
    });
    m_msgid2Opera.insert({ MODULE_MSG_VOICE, [this](SysMsgOperaPack * pack) {
            return OnSysMsg_ModuleMsgVoice(pack);
        }
    });
}

BOOL SysMsgToServer::OnSendSysMsgToServer(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
    GAME_MSG* pMsg = RequestDataParse<GAME_MSG>(lpRequest, false);
    if (nullptr == pMsg)
    {
        LOG_INFO("%ld发送了不合法的消息结构，结构长度:%ld", lpContext->lTokenID, lpRequest->nDataLen);
        return m_pServer->NotifyResponseFaild(lpContext);
    }
    auto token = lpContext->lTokenID;
    BOOL bPassive = IS_BIT_SET(lpContext->dwFlags, CH_FLAG_SYSTEM_EJECT);//是否系统自己生成的消息
    BYTE* pData = PBYTE(lpRequest->pDataPtr) + sizeof(GAME_MSG);
    int roomid = pMsg->nRoomID;
    int userid = pMsg->nUserID;
    LOG_DEBUG("OnSendSysMsgToServer###########:%ld ...", pMsg->nMsgID);

    if (!GameMsgCheck(pMsg))
    {
        LOG_INFO(_T("%ld发送了不合法的消息结构，消息号为:%ld"), lpContext->lTokenID, pMsg->nMsgID);
        return m_pServer->NotifyResponseFaild(lpContext);
    }
    int tableno = -1;
    int chairno = -1;
    USER_DATA user_data;
    memset(&user_data, 0, sizeof(user_data));
    if (!m_pServer->LookupUserData(userid, user_data) && bPassive == FALSE)
    {
        UwlLogFile(_T("user:%ld未在服务器注册，试图发送消息号为:%ld"), userid, pMsg->nMsgID);
        return m_pServer->NotifyResponseFaild(lpContext);
    }
    else
    {
        roomid = user_data.nRoomID;
        tableno = user_data.nTableNO;
        chairno = user_data.nChairNO;
    }
    CRoom* pRoom = NULL;
    CCommonBaseTable* pTable = NULL;
    if (!(pRoom = m_pServer->GetRoomPtr(roomid)))
    {
        return m_pServer->NotifyResponseFaild(lpContext, bPassive);
    }

    if (!(pTable = (CCommonBaseTable*)m_pServer->GetTablePtr(roomid, tableno)))
    {
        return m_pServer->NotifyResponseFaild(lpContext, bPassive);
    }
    if (pTable)
    {
        CAutoLock lock(&(pTable->m_csTable));
        if (!pTable->ValidateChair(chairno))
        {
            return TRUE;
        }
        if (userid && token != pTable->FindTokenByUser(userid))
        {
            if (!lpContext->bNeedEcho)
            {
                return TRUE;
            }
            REQUEST response2;
            memset(&response2, 0, sizeof(response2));
            response2.head.nRequest = UR_OPERATE_FAILED;
            return m_pServer->SendUserResponse(lpContext, &response2, bPassive, FALSE);
        }
        if (!bPassive)
        {
            pTable->m_dwLatestAction[chairno] = GetTickCount();
        }
        if (!bPassive)
        {
            pTable->m_dwCheckBreakTime[chairno] = 0;
        }

        if (!pTable->IsPlayer(userid))
        {
            // 不是玩家
            LOG_INFO(_T("user not player. user %ld SendMsgToPlayer Failed,dwFlags:%ld"), userid, pMsg->nMsgID);
            return m_pServer->NotifyResponseFaild(lpContext);
        }
        if (!pTable->ValidateChair(chairno))
        {
            LOG_INFO(_T("chairno Error. user %ld SendMsgToPlayer Failed,chairno:%ld"), userid, chairno);
            return m_pServer->NotifyResponseFaild(lpContext);
        }
        if (!IS_BIT_SET(pTable->m_dwStatus, TS_PLAYING_GAME) && pMsg->nMsgID != SYSMSG_PLAYER_ONLINE && pMsg->nMsgID != MODULE_MSG_VOICE)
        {
            LOG_ERROR(_T("OnSendSysMsgToServer:pTable is not in TS_PLAYING_GAME.nMsgID:%d"), pMsg->nMsgID);
            return m_pServer->NotifyResponseFaild(lpContext);
        }

        CPlayer* pPlayer = pTable->m_ptrPlayers[chairno];
        SysMsgOperaPack pack;
        pack.lpContext = lpContext;
        pack.lpRequest = lpRequest;
        pack.user_data = &user_data;
        pack.pMsg = pMsg;
        pack.pData = pData;
        pack.roomid = roomid;
        pack.chairno = chairno;
        pack.tableno = tableno;
        pack.userid = userid;
        pack.pRoom = pRoom;
        pack.pTable = pTable;
        pack.pPlayer = pPlayer;
        pack.bPassive = bPassive;

        auto it = m_msgid2Opera.find(pMsg->nMsgID);
        if (it != m_msgid2Opera.end())
        {
            it->second(&pack);
        }
    }
    return TRUE;
}

BOOL SysMsgToServer::GameMsgCheck(GAME_MSG* pMsg)
{
    BOOL ret = FALSE;
    auto resquesID = pMsg->nMsgID;
    do
    {
        if (SYSMSG_BEGIN < resquesID && resquesID < SYSMSG_END)
        {
            ret = TRUE;
            break;
        }
        if (LOCAL_GAME_MSG_BEGIN < resquesID && resquesID < LOCAL_GAME_MSG_END)
        {
            ret = TRUE;
            break;
        }
        if (GAMEMSGEX_BEGIN < resquesID && resquesID < GAMEMSGEX_END)
        {
            ret = TRUE;
            break;
        }
        if (resquesID == MODULE_MSG_VOICE)
        {
            ret = TRUE;
            break;
        }

    } while (0);

    if (!ret)
    {
        return FALSE;
    }

    if (m_pServer->IsYQWRoom(pMsg->nRoomID) && (pMsg->nMsgID == SYSMSG_PLAYER_ONLINE))
    {
        // 一起玩房间不需要这个消息
        return FALSE;
    }

    return TRUE;
}

BOOL SysMsgToServer::NotifyTableMsg(CTable* pTable, int nDest, int nMsgID, int datalen, void* data, LONG tokenExcept)
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
        m_pServer->NotifyOneUser(pPlayer->m_hSocket, pPlayer->m_lTokenID, GR_SENDMSG_TO_PLAYER, pGameMsg, size);
    }
    else
    {
        if (nDest == GAME_MSG_SEND_OTHER)
        {
            m_pServer->NotifyTablePlayers(pTable, GR_SENDMSG_TO_PLAYER, pGameMsg, size, tokenExcept);
            m_pServer->NotifyTableVisitors(pTable, GR_SENDMSG_TO_PLAYER, pGameMsg, size, tokenExcept);
        }
        else if (nDest == GAME_MSG_SEND_OTHER_PLAYER)
        {
            m_pServer->NotifyTablePlayers(pTable, GR_SENDMSG_TO_PLAYER, pGameMsg, size, tokenExcept);
        }
        else if (nDest == GAME_MSG_SEND_EVERY_PLAYER)
        {
            m_pServer->NotifyTablePlayers(pTable, GR_SENDMSG_TO_PLAYER, pGameMsg, size);
        }
        else
        {
            m_pServer->NotifyTablePlayers(pTable, GR_SENDMSG_TO_PLAYER, pGameMsg, size);
            m_pServer->NotifyTableVisitors(pTable, GR_SENDMSG_TO_PLAYER, pGameMsg, size);
        }
    }

    delete[]pGameMsg;
    return TRUE;
}

BOOL SysMsgToServer::NotifyPlayerMsgAndResponse(LPCONTEXT_HEAD lpContext, CTable* pTable, int nDest, DWORD dwFlags, DWORD datalen, void* data)
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
            m_pServer->SendUserResponse(lpContext, &response);
        }
        else
        {
            //不是发送家，那么发送
            m_pServer->NotifyOneUser(pPlayer->m_hSocket, pPlayer->m_lTokenID, GR_SENDMSG_TO_PLAYER, pGameMsg, size);
        }
    }
    else
    {
        if (nDest == GAME_MSG_SEND_OTHER)
        {
            m_pServer->NotifyTablePlayers(pTable, GR_SENDMSG_TO_PLAYER, pGameMsg, size, lpContext->lTokenID);
            m_pServer->NotifyTableVisitors(pTable, GR_SENDMSG_TO_PLAYER, pGameMsg, size, lpContext->lTokenID);
        }
        else if (nDest == GAME_MSG_SEND_OTHER_PLAYER)
        {
            m_pServer->NotifyTablePlayers(pTable, GR_SENDMSG_TO_PLAYER, pGameMsg, size, lpContext->lTokenID);
        }
        else if (nDest == GAME_MSG_SEND_VISITOR)
        {
            m_pServer->NotifyTableVisitors(pTable, GR_SENDMSG_TO_PLAYER, pGameMsg, size);
        }
        else if (nDest == GAME_MSG_SEND_EVERY_PLAYER)
        {
            if (lpContext->bNeedEcho)
            {
                lpContext->bNeedEcho = FALSE; //已经回应过不再回应
                m_pServer->SendUserResponse(lpContext, &response);
                m_pServer->NotifyTablePlayers(pTable, GR_SENDMSG_TO_PLAYER, pGameMsg, size, lpContext->lTokenID);
            }
            else
            {
                m_pServer->NotifyTablePlayers(pTable, GR_SENDMSG_TO_PLAYER, pGameMsg, size, 0);
            }
        }
        else
        {
            if (lpContext->bNeedEcho)
            {
                lpContext->bNeedEcho = FALSE; //已经回应过不再回应
                m_pServer->SendUserResponse(lpContext, &response);
                m_pServer->NotifyTablePlayers(pTable, GR_SENDMSG_TO_PLAYER, pGameMsg, size, lpContext->lTokenID);
                m_pServer->NotifyTableVisitors(pTable, GR_SENDMSG_TO_PLAYER, pGameMsg, size, lpContext->lTokenID);
            }
            else
            {
                m_pServer->NotifyTablePlayers(pTable, GR_SENDMSG_TO_PLAYER, pGameMsg, size, 0);
                m_pServer->NotifyTableVisitors(pTable, GR_SENDMSG_TO_PLAYER, pGameMsg, size, 0);
            }
        }

    }

    delete[]pGameMsg;
    return TRUE;
}

BOOL SysMsgToServer::OnSysMsg_GameClockStop(SysMsgOperaPack* pack)
{
    auto* pTable = pack->pTable;
    int chairno = pack->chairno;
    auto* pRoom = pack->pRoom;
    if (pTable->IsOperateTimeOver() && GetTickCount() - pTable->m_dwLastClockStop > 3000)
    {
        pTable->m_dwLastClockStop = GetTickCount();
        int chair = pTable->GetCurrentChair();
        if (pTable->ValidateChair(chair) &&
            pTable->CheckOffline(chair))
        {
            pTable->m_bOffline[chairno] = TRUE;
            m_pServer->OnPlayerOffline(pTable, chair);
            //服务端自动抓牌
            m_pServer->OnServerAutoPlay(pRoom, pTable, chair, !pTable->IsOffline(chair));
            //end
        }
    }
    return TRUE;
}

BOOL SysMsgToServer::OnSysMsg_PlayerOnline(SysMsgOperaPack* pack)
{
    auto* pTable = pack->pTable;
    auto chairno = pack->chairno;
    auto* pPlayer = pack->pPlayer;
    if (pTable->IsOffline(chairno))
    {
        //断线续完
        pTable->m_dwUserStatus[chairno] &= ~US_USER_OFFLINE;
        pTable->m_bOffline[chairno] = FALSE;
        /////////////////////////////////////////////////////////////////////////
        NotifyTableMsg(pTable, GAME_MSG_SEND_OTHER, SYSMSG_RETURN_GAME, 4, &pPlayer->m_nChairNO, pPlayer->m_lTokenID);
        /////////////////////////////////////////////////////////////////////////
    }
    return TRUE;
}

BOOL SysMsgToServer::OnSysMsg_GameOnAutoPlay(SysMsgOperaPack* pack)
{
    auto* pTable = pack->pTable;
    auto chairno = pack->chairno;
    auto* lpContext = pack->lpContext;
    if (!pTable->IsAutoPlay(chairno))
    {
        pTable->m_dwUserStatus[chairno] |= US_USER_AUTOPLAY;
        NotifyPlayerMsgAndResponse(lpContext, pTable, GAME_MSG_SEND_EVERYONE, SYSMSG_GAME_ON_AUTOPLAY, sizeof(int), &chairno);
    }
    else
    {
        NotifyPlayerMsgAndResponse(lpContext, pTable, chairno, SYSMSG_GAME_ON_AUTOPLAY, sizeof(int), &chairno);
    }
    return TRUE;
}

BOOL SysMsgToServer::OnSysMsg_GameCancelAutoPlay(SysMsgOperaPack* pack)
{
    auto* pTable = pack->pTable;
    auto chairno = pack->chairno;
    auto* lpContext = pack->lpContext;
    if (pTable->IsAutoPlay(chairno))
    {
        pTable->m_dwUserStatus[chairno] &= ~US_USER_AUTOPLAY;
        NotifyPlayerMsgAndResponse(lpContext, pTable, GAME_MSG_SEND_EVERYONE, SYSMSG_GAME_CANCEL_AUTOPLAY, sizeof(int), &chairno);
    }
    else
    {
        NotifyPlayerMsgAndResponse(lpContext, pTable, chairno, SYSMSG_GAME_CANCEL_AUTOPLAY, sizeof(int), &chairno);
    }
    return TRUE;
}

BOOL SysMsgToServer::OnSysMsg_ModuleMsgVoice(SysMsgOperaPack* pack)
{
    auto* pTable = pack->pTable;
    auto chairno = pack->chairno;
    auto* lpContext = pack->lpContext;
    auto* pMsg = pack->pMsg;
    auto* pData = pack->pData;

    SOUND_INDEX stIndex;
    memcpy(&stIndex, pData, pMsg->nDatalen);
    m_pServer->NotifyTablePlayers(pTable, MODULE_MSG_VOICE, &stIndex, sizeof(stIndex));
    m_pServer->NotifyTableVisitors(pTable, MODULE_MSG_VOICE, &stIndex, sizeof(stIndex));
    return TRUE;
}
