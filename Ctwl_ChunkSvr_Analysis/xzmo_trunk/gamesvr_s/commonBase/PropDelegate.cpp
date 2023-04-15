#include "stdafx.h"

void CPropDelegate::OnServerStart(BOOL& ret, TcyMsgCenter* msgCenter)
{
    if (ret)
    {
        AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_THROW_PRO, OnThrowProp);
    }
}

BOOL CPropDelegate::OnThrowProp(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
    int token = 0;
    int roomid = 0;
    int tableno = INVALID_OBJECT_ID;
    int userid = 0;
    int chairno = INVALID_OBJECT_ID;

    token = lpContext->lTokenID;
    CTable* pTable = NULL;

    LPTHROWPROP pData = LPTHROWPROP(PBYTE(lpRequest->pDataPtr));
    roomid = pData->nRoomID;
    tableno = pData->nTableNO;
    userid = pData->nUserID;
    chairno = pData->nChairNO;

    if (pData->nPropID >= PROP_END || pData->nPropID <= PROP_BEGIN)
    {
        return TRUE;
    }
    if (!(pTable = imGetTablePtr.notify(roomid, tableno, FALSE, 0)))
    {
        return TRUE;
    }
    if (pTable)
    {
        CAutoLock lock(&(pTable->m_csTable));
        imNotifyTablePlayers.notify(pTable, GR_THROW_PRO, pData, sizeof(THROWPROP), token, FALSE);
    }

    return TRUE;
}