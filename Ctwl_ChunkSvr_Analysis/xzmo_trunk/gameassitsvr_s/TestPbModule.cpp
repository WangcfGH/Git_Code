#include "stdafx.h"
#include "TestPbModule.h"
#include "../pb/TestPbModule/TestPbModule.pb.h"

#define TEST_PB_MODULE_REQ1		(GAME_REQ_INDIVIDUAL + 5000)

void TestPbModule::OnServerStart(BOOL&ret, TcyMsgCenter* msgCenter)
{
	AUTO_REGISTER_MSG_OPERATOR(msgCenter, TEST_PB_MODULE_REQ1, imMsgToChunk);
}

void TestPbModule::OnChunkClient(TcyMsgCenter* msgCenter)
{
	AUTO_REGISTER_MSG_OPERATOR(msgCenter, TEST_PB_MODULE_REQ1, OnTestPbModuleRsp1);
}

void TestPbModule::OnTest(bool&ok, std::string&cmd)
{
	if (cmd == "TestPbModule") {
		TestPbModulePg::ReqTestPbModule1 req;
		req.set_userid(12345678);
		req.set_channel(12345678);

		TcyMsgBuffer buffer;
		buffer.packPbMessage(req);

		CONTEXT_HEAD cc;
		ZeroMemory(&cc, sizeof(cc));
		REQUEST request;
		request.head.nRequest = TEST_PB_MODULE_REQ1;
		request.pDataPtr = buffer.data();
		request.nDataLen = buffer.size();
		imSimulatorMsgToLoacl(&cc, &request);
	}
}

BOOL TestPbModule::OnTestPbModuleRsp1(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
	auto rsp = RequestToPbMessage<TestPbModulePg::RspTestPbModule1>(lpRequest);
	if (!rsp) {
		return FALSE;
	}
	LOG_INFO("rsp ok <%d>", rsp->ok());
	std::string s;
	for (int i = 0; i < rsp->list_data_size(); ++i)
	{
		auto& p = rsp->list_data(i);
		s += std::to_string(p.f1());
		s.append(",");
		// 由于f2是 optional 所以要先判断
		if (p.has_f2()) {
			s += p.f2();
		}
		s.append("\r\n");
	}
	LOG_INFO("rsp data <%s>", s.c_str());
	return TRUE;
}
