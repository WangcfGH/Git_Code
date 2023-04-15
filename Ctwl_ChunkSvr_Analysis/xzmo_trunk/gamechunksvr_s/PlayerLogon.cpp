#include "stdafx.h"
#include "PlayerLogon.h"

void PlayerLogon::OnServerStart(BOOL &ret, TcyMsgCenter *msgCenter)
{
}

void PlayerLogon::OnNTFPlayerLogon(NTF_PLAYERLOGON& playerLogonInfo)
{
    CONTEXT_HEAD context;
    memset(&context, 0, sizeof(CONTEXT_HEAD));
    REQUEST request;
    memset(&request, 0, sizeof(request));
    NTF_PLAYERLOGON pData;
    memcpy(&pData, &playerLogonInfo, sizeof(NTF_PLAYERLOGON));

    imGetAssistSvrSocket(context.hSocket, context.lTokenID);

    request.head.nRequest = GR_NTF_PLAYERLOGON;
    request.pDataPtr = &pData;
    request.nDataLen = sizeof(NTF_PLAYERLOGON);

    if (context.hSocket != 0 && context.lTokenID != 0) {
        imSendOpeRequest(&context, request);
    }
    
}

void PlayerLogon::OnNTFPlayerLogoff(NTF_PLAYERLOGOFF &playerLogoffInfo)
{
    CONTEXT_HEAD context;
    memset(&context, 0, sizeof(CONTEXT_HEAD));
    REQUEST request;
    memset(&request, 0, sizeof(request));
    NTF_PLAYERLOGOFF pData;
    memcpy(&pData, &playerLogoffInfo, sizeof(NTF_PLAYERLOGOFF));

    imGetAssistSvrSocket(context.hSocket, context.lTokenID);

    request.head.nRequest = GR_NTF_PLAYERLOGOFF;
    request.pDataPtr = &pData;
    request.nDataLen = sizeof(NTF_PLAYERLOGON);

    if (context.hSocket != 0 && context.lTokenID != 0) {
        imSendOpeRequest(&context, request);
    }
}
