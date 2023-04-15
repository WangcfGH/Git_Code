#pragma once
class PlayerLogon
{
public:
    void OnServerStart(BOOL &ret, TcyMsgCenter *msgCenter);

    void OnNTFPlayerLogon(NTF_PLAYERLOGON& playerLogonInfo);
    void OnNTFPlayerLogoff(NTF_PLAYERLOGOFF &playerLogoffInfo);

    // 获取房间服务的socket
    ImportFunctional<void(SOCKET&, LONG&)> imGetAssistSvrSocket;
	ImportFunctional<void(LPCONTEXT_HEAD, REQUEST&)> imSendOpeRequest;
};

