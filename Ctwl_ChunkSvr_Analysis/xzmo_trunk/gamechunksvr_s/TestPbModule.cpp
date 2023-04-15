#include "stdafx.h"
#include "TestPbModule.h"
#include "../pb/TestPbModule/TestPbModule.pb.h"


#define TEST_PB_MODULE_REQ1		(GAME_REQ_INDIVIDUAL + 5000)

void TestPbModule::OnServerStart(BOOL&ret, TcyMsgCenter* msgCenter)
{
	AUTO_REGISTER_MSG_OPERATOR(msgCenter, TEST_PB_MODULE_REQ1, OnTestPbModuleReq1);
}

BOOL TestPbModule::OnTestPbModuleReq1(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
	auto req = RequestToPbMessage<TestPbModulePg::ReqTestPbModule1>(lpRequest);
	if (!req) {
		return FALSE;
	}

	auto userid = req->userid();
	auto channel = req->channel();

	TcyMsgBuffer buffer;
	buffer.packContextHead(lpRequest);	// 打包头部的context_head
	TestPbModulePg::RspTestPbModule1 rsp;
	rsp.set_ok(true);
	for (int i = 0; i < 10; ++i)
	{
		auto* p = rsp.add_list_data();
		p->set_f1(1);
		if (i % 2 == 0) {
			p->set_f2(std::to_string(i).c_str());
		}

	}
	buffer.packPbMessage(rsp);

	REQUEST response;
	response.head.nRequest = lpRequest->head.nRequest;
	response.head.nRepeated = lpRequest->head.nRepeated;
	response.pDataPtr = buffer.data();
	response.nDataLen = buffer.size();
	imSendOpeRequest(lpContext, response);
	return TRUE;
}
