#pragma once
#include "tcycomponents/TcySockClient.h"

class GameToChunkClient : public TcySockClient
{
public:
    GameToChunkClient(
        int nKeyType, DWORD flagEncrypt = 0, DWORD flagCompress = 0)
        : TcySockClient(nKeyType, flagEncrypt, flagCompress)
    {

    }

    SingleEventNoMutex<std::string&> imGetIniFile;
    SingleEventNoMutex<const char*, const char*, std::string&> imGetIniString;
    SingleEventNoMutex<int&> imGetGameID;

    void OnServerStart(BOOL& ret, TcyMsgCenter* msgCenter);
    void OnShutdown();

protected:
    virtual BOOL ValidateClientEx() override { return TRUE; };
    virtual BOOL ValidateClientInfo() override;
};

