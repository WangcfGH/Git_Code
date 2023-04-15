#pragma once
#include "plana/plana.h"

class BroadToMobile
{
public:
	void OnServerStart(BOOL& ret, TcyMsgCenter* msgCenter);

	// 获取房间服务的socket
	ImportFunctional<void(SOCKET&, LONG&)> imGetAssistSvrSocket;
	ImportFunctional<void(LPCONTEXT_HEAD, REQUEST&)> imSendOpeRequest;
protected:
	void OnBroadcastFromGameSvr(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);
};

