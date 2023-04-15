#pragma once
class PlayerLogon
{
public:
    void OnServerStart(BOOL &ret, TcyMsgCenter *msgCenter);

    void OnNTFPlayerLogon(NTF_PLAYERLOGON& playerLogonInfo);
    void OnNTFPlayerLogoff(NTF_PLAYERLOGOFF &playerLogoffInfo);

    // ��ȡ��������socket
    ImportFunctional<void(SOCKET&, LONG&)> imGetAssistSvrSocket;
	ImportFunctional<void(LPCONTEXT_HEAD, REQUEST&)> imSendOpeRequest;
};

