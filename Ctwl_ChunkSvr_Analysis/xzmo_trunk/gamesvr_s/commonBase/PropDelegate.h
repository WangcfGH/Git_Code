#pragma once
#include "tcycomponents/TcyMsgCenter.h"


class CPropDelegate
{
public:
    // args:[table,nRequest,pData,nLen,tokenExcept=0,compressed=FALSE]
    ImportFunctional<int((CTable*, UINT, void*, int, LONG, BOOL))>  imNotifyTablePlayers;
    // args:[roomid,tableno,bCreateIfNotExist=FALSE,nScoreMult=0]
    ImportFunctional < CGetTableResult(int, int, BOOL, int)> imGetTablePtr;

    void OnServerStart(BOOL& ret, TcyMsgCenter* msgCenter);

public:
    // msg
    BOOL OnThrowProp(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);
};

