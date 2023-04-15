#include "stdafx.h"
#include "SocketClientManager.h"
#include "TestSockClient.h"
#include "plana/event/Event.h"

SocketClientManager::SocketClientManager()
{
}


SocketClientManager::~SocketClientManager()
{
}

void SocketClientManager::OnServerStart(BOOL& ret)
{   
    if (ret) {
        m_clientCount = 2;
        evGetIniInt("testClient", "count", m_clientCount);
        for (int i = 0; i < m_clientCount; i++){
            auto client = new TestSockClient(KEY_GAMESVR_2_0, ENCRYPT_AES, 0);
            m_clientList.push_back(client);
            evSvrStart.notify(i, &client->m_msgCenter);
            client->OnServerStart(ret, nullptr);
        }
    }
}

void SocketClientManager::Initialize()
{
    int ret = TRUE;
    OnServerStart(ret);
}

void SocketClientManager::Shutdown()
{
    for (TestSockClient* &client : m_clientList)
    {
        client->Shutdown();
    }
}

void SocketClientManager::SendMsg(int index, int requestId, const void *data,int length, int repeat)
{
    if (m_clientList[index]) {
        LPCONTEXT_HEAD pContext = new CONTEXT_HEAD;
        ZeroMemory(pContext, sizeof(CONTEXT_HEAD));
        pContext->hSocket = 0;
        pContext->lTokenID = 0;
        pContext->dwFlags |= CH_FLAG_SYSTEM_EJECT;
        LPREQUEST pRequest = new REQUEST;
        ZeroMemory(pRequest, sizeof(REQUEST));

        PBYTE pNewData = new BYTE[length];
        memset(pNewData, 0, length);
        memcpy(pNewData, data, length);

        pRequest->head.nRequest = requestId;
        pRequest->pDataPtr = pNewData;
        pRequest->nDataLen = length;

        for (int i = 0; i < repeat; i++) {
            m_clientList[index]->TestDoSendMsg(pContext, pRequest);
        }
        UwlClearRequest(pRequest);
        SAFE_DELETE(pContext);
    }
}

void SocketClientManager::SendMsgRandom(int requestId, const void* data,int length, int repeat)
{
    LPCONTEXT_HEAD pContext = new CONTEXT_HEAD;
    ZeroMemory(pContext, sizeof(CONTEXT_HEAD));
    pContext->hSocket = 0;
    pContext->lTokenID = 0;
    pContext->dwFlags |= CH_FLAG_SYSTEM_EJECT;
    LPREQUEST pRequest = new REQUEST;
    ZeroMemory(pRequest, sizeof(REQUEST));

    PBYTE pNewData = new BYTE[length];
    memset(pNewData, 0, length);
    memcpy(pNewData, data, length);

    pRequest->head.nRequest = requestId;
    pRequest->pDataPtr = pNewData;
    pRequest->nDataLen = length;
    int size = m_clientList.size();
    for (int i = 0; i < repeat; i++) {
        srand((int)time(0));
        int index = rand() % size;
        m_clientList[index]->DoSendMsg(pContext, pRequest);
    }
    UwlClearRequest(pRequest);
    SAFE_DELETE(pContext);
}
