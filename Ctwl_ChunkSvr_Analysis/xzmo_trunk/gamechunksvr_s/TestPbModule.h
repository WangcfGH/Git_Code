#pragma once
class TestPbModule
{
public:

	ImportFunctional<void(LPCONTEXT_HEAD, REQUEST&)> imSendOpeRequest;
	void OnServerStart(BOOL&ret, TcyMsgCenter* msgCenter);


protected:
	BOOL OnTestPbModuleReq1(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);
};

