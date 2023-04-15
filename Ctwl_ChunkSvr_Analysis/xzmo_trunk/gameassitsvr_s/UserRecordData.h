#pragma once
#include "plana.h"

class TcyMsgCenter;
class UserRecordData
{
public:
    UserRecordData();
    ~UserRecordData();


    void OnServerStart(BOOL& ret, TcyMsgCenter* msgCenter);

    ImportFunctional<void(LPCONTEXT_HEAD, LPREQUEST)> imToChunkLog;
};

