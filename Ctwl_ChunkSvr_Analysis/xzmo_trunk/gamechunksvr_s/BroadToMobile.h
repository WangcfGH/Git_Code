#pragma once
#include "plana/plana.h"

class BroadToMobile
{
public:
	void OnServerStart(BOOL& ret, TcyMsgCenter* msgCenter);

	// ��ȡ��������socket
	ImportFunctional<void(SOCKET&, LONG&)> imGetAssistSvrSocket;
	ImportFunctional<void(LPCONTEXT_HEAD, REQUEST&)> imSendOpeRequest;
protected:
	void OnBroadcastFromGameSvr(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);
};

