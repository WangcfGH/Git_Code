#pragma once

/*
	测试消息发送和返回的性能，需要另外一处测试代码
	class TestOtherThreadRsp
	{
	public:
	SingleEventNoMutex < int, std::function<void(LPSOAP_SERVICE, IXYSoapClientPtr&)> >
	evSoap;
	SingleEventNoMutex<SOCKET, LONG, UINT, void*, int> evNotifyOneUser;
	void OnServerStart(BOOL& ret, TcyMsgCenter* msgCenter) {
	if (ret) {
	AUTO_REGISTER_MSG_OPERATOR(msgCenter, 1010105, OnTest);
	}
	}
	void OnTest(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest) {
	auto tcyMsg = MoveTcyMsgHead(lpRequest, lpContext);
	evSoap(0, [this, tcyMsg](LPSOAP_SERVICE pSoapService, IXYSoapClientPtr& pSoapClient){
	evNotifyOneUser(tcyMsg->context.hSocket, tcyMsg->context.lTokenID, tcyMsg->requst.head.nRequest,
	tcyMsg->requst.pDataPtr, tcyMsg->requst.nDataLen);
	});
	}
	};

	class TestOtherThreadRsp_o
	{
	public:
	SingleEventNoMutex<SOCKET, LONG, UINT, void*, int> evNotifyOneUser;

	UINT m_threadID;
	HANDLE m_hThread;

	static unsigned __stdcall OnThreadWait(LPVOID lpVoid)
	{
	TestOtherThreadRsp_o* p = (TestOtherThreadRsp_o*)(lpVoid);
	MSG msg;
	memset(&msg, 0, sizeof(msg));
	while (GetMessage(&msg, 0, 0, 0))
	{
	if (UM_DATA_TOSEND == msg.message)
	{
	LPCONTEXT_HEAD pContext = LPCONTEXT_HEAD(msg.wParam);
	LPREQUEST pRequest = LPREQUEST(msg.lParam);
	p->evNotifyOneUser(pContext->hSocket, pContext->lTokenID, pRequest->head.nRequest,
	pRequest->pDataPtr, pRequest->nDataLen);
	UwlClearRequest(pRequest);
	SAFE_DELETE(pContext);
	SAFE_DELETE(pRequest);
	}
	else
	{
	DispatchMessage(&msg);
	}
	}

	return 0;
	}

	void OnServerStart(BOOL& ret, TcyMsgCenter* msgCenter) {
	if (ret) {
	AUTO_REGISTER_MSG_OPERATOR(msgCenter, 1010106, OnTest);
	m_hThread = (HANDLE)_beginthreadex(NULL,       // Security
	0,                              // Stack size - use default
	OnThreadWait,                 // Thread fn entry point
	(void*)this,      // Param for thread
	0,                              // Init flag
	&m_threadID);
	}
	}
	void PostSoapReqeust(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest) {
	LPREQUEST pRequest = new REQUEST;
	memcpy(pRequest, lpRequest, sizeof(REQUEST));

	int nDataLen = lpRequest->nDataLen;

	pRequest->pDataPtr = new BYTE[nDataLen];
	memset(pRequest->pDataPtr, 0, nDataLen);
	pRequest->nDataLen = nDataLen;
	memcpy(pRequest->pDataPtr, lpRequest->pDataPtr, lpRequest->nDataLen);

	LPCONTEXT_HEAD pContext = new CONTEXT_HEAD;
	memcpy(pContext, lpContext, sizeof(CONTEXT_HEAD));

	if (!PostThreadMessage(m_threadID, UM_DATA_TOSEND, (WPARAM)pContext, (LPARAM)pRequest))
	{
	UwlClearRequest(pRequest);
	SAFE_DELETE(pRequest);
	SAFE_DELETE(pContext);
	return ;
	}
	else
	{
	return ;
	}
	}
	void OnTest(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest) {
	PostSoapReqeust(lpContext, lpRequest);
	}
	};
*/

class TestMsgRsp
{
public:
	SingleEventNoMutex<int, const void *, int, int > evSendMsgRandom;
	enum
	{
		MSG_ID1 = 1010105,
		MSG_ID2 = 1010106,
		COUNT = 10000
	};

	int m_n = 0;
	std::chrono::system_clock::time_point m_tp;
	void OnServerStart(int index, TcyMsgCenter* msgCenter)
	{
		AUTO_REGISTER_MSG_OPERATOR(msgCenter, MSG_ID1, OnMsgRsp);
		AUTO_REGISTER_MSG_OPERATOR(msgCenter, MSG_ID2, OnMsgRsp);
	}

	void OnMsgRsp(LPCONTEXT_HEAD pContext, LPREQUEST pRequest) {
		if (++m_n == COUNT) {
			auto n = std::chrono::system_clock::now();
			auto diff = std::chrono::duration_cast<std::chrono::milliseconds>(n - m_tp);
			UwlTrace("1000 total:%d", diff.count());
		}
	}

	void OnTest(const std::string& cmd) {
		if ("msgrsptest1" == cmd) {
			int n = 0;
			m_n = 0;
			m_tp = std::chrono::system_clock::now();
			evSendMsgRandom(MSG_ID1, &n, sizeof(n), COUNT);
		}
		else if ("msgrsptest2" == cmd) {
			int n = 0;
			m_n = 0;
			m_tp = std::chrono::system_clock::now();
			evSendMsgRandom(MSG_ID2, &n, sizeof(n), COUNT);
		}
	}
};

