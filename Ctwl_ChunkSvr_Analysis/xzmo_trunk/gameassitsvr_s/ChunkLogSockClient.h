#pragma once
#include "tcycomponents/TcySockClient.h"

// CHENSHU COMMENT
// 连接chunksvr成功之后，还需要进行ValidateClientEx
class ChunkLogSockClient : public TcySockClient
{
public:
    ChunkLogSockClient(
        int nKeyType, DWORD flagEncrypt = 0, DWORD flagCompress = 0)
        : TcySockClient(nKeyType, flagEncrypt, flagCompress)
    {

    }

    ImportFunctional<std::string()> imGetIniFile;
	ImportFunctional<void(const char*, const char*, std::string&)> imGetIniString;
	ImportFunctional<void(int&) > imGetGameID;
	ImportFunctional<void(int&)> imGetClientID;


    void OnServerStart(BOOL& ret, TcyMsgCenter* msgCenter);
    void OnShutdown();
protected:
	virtual BOOL ValidateClientEx() override;
	virtual BOOL ValidateClientInfo() override;
};

