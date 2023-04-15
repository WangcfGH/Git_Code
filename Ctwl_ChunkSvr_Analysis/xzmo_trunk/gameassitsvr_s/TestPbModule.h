#pragma once

class TestPbModule
{
public:
	//发送消息到chunk
	ImportFunctional<void(LPCONTEXT_HEAD, LPREQUEST)> imMsgToChunk;
	// 模拟发送消息
	ImportFunctional<BOOL(LPCONTEXT_HEAD, LPREQUEST)> imSimulatorMsgToLoacl;

	void OnServerStart(BOOL&ret, TcyMsgCenter* msgCenter);
	void OnChunkClient(TcyMsgCenter* msgCenter);
	void OnTest(bool&ok, std::string&cmd);
protected:
	BOOL OnTestPbModuleRsp1(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);

};

