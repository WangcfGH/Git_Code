#include "stdafx.h"
#include "BroadToMobile.h"
#include "BroadcastReq.h"

void BroadToMobile::OnServerStart(BOOL& ret, TcyMsgCenter* msgCenter)
{
	if (ret) {
		AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_BROADCAST_FROM_GAMESVR, OnBroadcastFromGameSvr);
	}
}

void BroadToMobile::OnBroadcastFromGameSvr(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
	int nRepeated = lpRequest->head.nRepeated;
	LPBROADCAST_MSG pBroadCastMsg = LPBROADCAST_MSG(PBYTE(lpRequest->pDataPtr) + nRepeated * sizeof(CONTEXT_HEAD));
	if (lpRequest->nDataLen != sizeof(BROADCAST_MSG) + nRepeated * sizeof(CONTEXT_HEAD))
	{
		UwlLogFile("lpRequest->nDataLen != sizeof(BROADCAST_MSG) + nRepeated * sizeof(CONTEXT_HEAD)");
		return;
	}

	CONTEXT_HEAD context;
	memset(&context, 0, sizeof(CONTEXT_HEAD));
	REQUEST request;

	imGetAssistSvrSocket(context.hSocket, context.lTokenID);
	request.head.nRequest = lpRequest->head.nRequest;
	request.pDataPtr = lpRequest->pDataPtr;
	request.nDataLen = lpRequest->nDataLen;

	if (context.hSocket != 0 && context.lTokenID != 0){
		// 发通知到assist服务
		imSendOpeRequest(&context, request);
	}
}
