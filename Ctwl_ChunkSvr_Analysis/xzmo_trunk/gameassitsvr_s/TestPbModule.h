#pragma once

class TestPbModule
{
public:
	//������Ϣ��chunk
	ImportFunctional<void(LPCONTEXT_HEAD, LPREQUEST)> imMsgToChunk;
	// ģ�ⷢ����Ϣ
	ImportFunctional<BOOL(LPCONTEXT_HEAD, LPREQUEST)> imSimulatorMsgToLoacl;

	void OnServerStart(BOOL&ret, TcyMsgCenter* msgCenter);
	void OnChunkClient(TcyMsgCenter* msgCenter);
	void OnTest(bool&ok, std::string&cmd);
protected:
	BOOL OnTestPbModuleRsp1(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);

};

