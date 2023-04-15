#include "stdafx.h"
#include "MainServer.h"


MainServer::~MainServer()
{
}

BOOL MainServer::Initialize()
{
	setIPAndPort("127.0.0.1", PORT_OF_ASSITSVR);
	
	std::string iniFile;
	iniFile = imGetIniFile();
	setIniFile(iniFile);

	return __super::Initialize();
}

void MainServer::NotifyOneUser(SOCKET sock, LONG token, UINT nRequest, void* pData, int nLen)
{
    if (sock == 0 || token == 0) return ;

    BOOL bSendOK = FALSE;

    CONTEXT_HEAD context;
    memset(&context, 0, sizeof(context));

    context.bNeedEcho = FALSE;
    context.hSocket = sock;
    context.lTokenID = token;

    REQUEST request;
    memset(&request, 0, sizeof(request));

    request.head.nRequest = nRequest;
    request.pDataPtr = pData;
    request.nDataLen = nLen;

    SendRequest(context.hSocket, &context, &request, MSG_REQUEST, 0, COMPRESS_ZIP);
}

void MainServer::NotifyOneUserErrorInfo(LPREQUEST lpRequest, LPCONTEXT_HEAD lpContext, LPCTSTR lpErroMsg)
{
    if (!lpContext || !lpErroMsg || lstrlen(lpErroMsg) <= 0)
    {
        return;
    }
    ERROR_INFO ei = { 0 };
    int len = lstrlen(lpErroMsg);
    int szSize = sizeof(ei.szMsg);

    if (len >= szSize)
    {
        lstrcpyn(ei.szMsg, lpErroMsg, szSize);
    }
    else
    {
        lstrcpy(ei.szMsg, lpErroMsg);
    }

    if (lpRequest->head.nRepeated != 0) {
        CONTEXT_HEAD context;
        memcpy(&context, lpRequest->pDataPtr, sizeof(context));
        context.bNeedEcho = FALSE;
        NotifyOneUser(context.hSocket, context.lTokenID, GR_ERROR_INFOMATION_EX, &ei, sizeof(ei));
    }
    else {
        NotifyOneUser(lpContext->hSocket, lpContext->lTokenID, GR_ERROR_INFOMATION_EX, &ei, sizeof(ei));
    }
}

void MainServer::NotifyOneWithParseContext(LPREQUEST lpRequest, LPCONTEXT_HEAD lpContext, UINT nRequest, void* pData, int nLen)
{
    if (lpRequest->head.nRepeated != 0) {
        CONTEXT_HEAD context;
        memcpy(&context, lpRequest->pDataPtr, sizeof(context));
        context.bNeedEcho = FALSE;
        NotifyOneUser(context.hSocket, context.lTokenID, nRequest, pData, nLen);
    }
    else {
        NotifyOneUser(lpContext->hSocket, lpContext->lTokenID, nRequest, pData, nLen);
    }
}

BOOL MainServer::SimulatorMsgToLoacl(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
	LPCONTEXT_HEAD pContext = new CONTEXT_HEAD;
	memcpy(pContext, lpContext, sizeof(CONTEXT_HEAD));

	LPREQUEST pRequest = new REQUEST;
	memcpy(pRequest, lpRequest, sizeof(REQUEST));

	BYTE* pData = nullptr;
	if (lpRequest->nDataLen != 0) {
		pData = new BYTE[lpRequest->nDataLen];
		memcpy(pData, lpRequest->pDataPtr, lpRequest->nDataLen);
		pRequest->nDataLen = lpRequest->nDataLen;
		pRequest->pDataPtr = pData;
	}
	return PutRequestToWorker(pRequest->nDataLen, DWORD(pContext->hSocket),
		pContext, pRequest, pRequest->pDataPtr);
}
