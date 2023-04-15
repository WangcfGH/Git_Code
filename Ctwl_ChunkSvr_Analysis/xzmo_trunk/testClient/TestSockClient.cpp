#include "StdAfx.h"
#include "TestSockClient.h"
#include "tcycomponents/TcyMsgCenter.h"

void TestSockClient::OnServerStart(BOOL& ret, TcyMsgCenter* msgCenter)
{
	if (ret) {
		std::string iniFile;
		evGetIniFile(iniFile);
		setIniFile(iniFile);

        std::string ip = "127.0.0.1";
        evGetIniString("TestClient", "name", ip);
        setIpAndPort(ip, PORT_OF_ASSITSVR);

		ret = Create(m_szIp.c_str(), m_nPort, 10, FALSE, GetHelloData(), GetHelloLength() + 1, 1, 10);
		if (ret) {
			ret = Initialize();
		}
	}
}

void TestSockClient::OnShutdown()
{
	Shutdown();
}

void TestSockClient::TestDoSendMsg(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
    std::shared_ptr<CONTEXT_HEAD> pContext = std::make_shared<CONTEXT_HEAD>(*lpContext);
    std::shared_ptr<REQUEST> pRequest = std::make_shared<REQUEST>(*lpRequest);
    pRequest->pDataPtr = new BYTE[lpRequest->nDataLen];
    pRequest->nDataLen = lpRequest->nDataLen;
    memcpy(pRequest->pDataPtr, lpRequest->pDataPtr, lpRequest->nDataLen);

    auto f = [this, pContext, pRequest]{
        int nLen = pRequest->nDataLen;
        PBYTE pData = new BYTE[nLen];
        memcpy(pData, pRequest->pDataPtr, pRequest->nDataLen);
        REQUEST request;
        memset(&request, 0, sizeof(request));
        request.nDataLen = nLen;
        request.pDataPtr = pData;
        request.head.nRequest = pRequest->head.nRequest;
        request.head.nRepeated = 0;

        UwlClearRequest(pRequest.get());
        CONTEXT_HEAD context;
        memset(&context, 0, sizeof(context));

        BOOL bTimeout = FALSE;
        BOOL bRet = SendRequest(&context, &request, NULL, bTimeout);
        UwlClearRequest(&request);
    };

    strand().post(f);
}
