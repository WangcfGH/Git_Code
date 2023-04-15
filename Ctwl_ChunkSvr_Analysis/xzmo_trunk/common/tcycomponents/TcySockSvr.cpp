#include "stdafx.h"
#include "TcySockSvr.h"
#include <CommReq-.h>

TcySockSvr::~TcySockSvr()
{
}

BOOL TcySockSvr::Initialize()
{
    BOOL ret = TRUE;
    do
    {
        if (CoInitialize(NULL) == S_FALSE)
        {
            ret = FALSE;
            UwlLogFile("CoInitialize Fail!");
            break;
        }
        if (!__super::Initialize(m_strServerIP.c_str(), m_nPort, GetHelloData(), GetHelloLength() + 1))
        {
            ret = FALSE;
            UwlLogFile("Initialize Fail! listen<%s,%d>", m_strServerIP.c_str(), m_nPort);
            break;
        }

        m_msgCenter.setMsgOper(GR_SEND_PULSE, [this](LPCONTEXT_HEAD lpContext, LPREQUEST lpReqeust)
        {
            this->OnClientPulse(lpReqeust, lpContext);
        });
        ret = TRUE;
    } while (0);

    //////////////////////////////////////////////////////////////////////////

    evSvrStart.notify(ret, &m_msgCenter);
    return ret;
}

void TcySockSvr::Shutdown()
{
    __super::Shutdown();

    // 清理所有注册的消息处理回调
    m_msgCenter.clear();

    // 分发服务停止的事件
    evShutdown.notify();

    //////////////////////////////////////////////////////////////////////////
    ::CoUninitialize();
}

BOOL TcySockSvr::SendOpeResponse(LPCONTEXT_HEAD lpContext, BOOL bNeedEcho, REQUEST& response)
{
    BOOL bSendOK = FALSE;
    CONTEXT_HEAD context;
    memcpy(&context, lpContext, sizeof(context));
    context.bNeedEcho = bNeedEcho;
    bSendOK = SendResponse(lpContext->hSocket, &context, &response);
    return bSendOK;
}

BOOL TcySockSvr::SendOpeRequest(LPCONTEXT_HEAD lpContext, REQUEST& response)
{
    CONTEXT_HEAD context;
    memset(&context, 0, sizeof(context));
    memcpy(&context, lpContext, sizeof(context));
    context.bNeedEcho = FALSE;

    BOOL bSendOK = SendRequest(lpContext->hSocket, &context, &response);
    return bSendOK;
}

BOOL TcySockSvr::SendOpeRequest(LPCONTEXT_HEAD lpContext, void* pData, int nLen, REQUEST& response)
{
    CONTEXT_HEAD context;
    memset(&context, 0, sizeof(context));
    memcpy(&context, lpContext, sizeof(context));
    context.bNeedEcho = FALSE;

    PBYTE pNewData = NULL;
    pNewData = new BYTE[nLen];
    memset(pNewData, 0, nLen);
    memcpy(pNewData, pData, nLen);
    response.pDataPtr = pNewData;//!
    response.nDataLen = nLen;

    BOOL bSendOK = SendRequest(lpContext->hSocket, &context, &response);
    UwlClearRequest(&response);
    return bSendOK;
}

BOOL TcySockSvr::SendOpeReqOnlyCxt(LPCONTEXT_HEAD lpContext, UINT nRepeatHead, void* pData, REQUEST& response)
{
    if (0 == nRepeatHead || !pData)
    {
        return FALSE;
    }

    int nLen = nRepeatHead * sizeof(CONTEXT_HEAD);
    return SendOpeRequest(lpContext, pData, nLen, response);
}

BOOL TcySockSvr::OnRequest(void* lpParam1, void* lpParam2)
{
    LPCONTEXT_HEAD  lpContext = LPCONTEXT_HEAD(lpParam1);
    LPREQUEST       lpRequest = LPREQUEST(lpParam2);

#if defined(_UWL_TRACE) | defined(UWL_TRACE)
    DWORD dwTimeStart = GetTickCount();
#else
    DWORD dwTimeStart = 0;
#endif

    if (!m_msgCenter.notify(lpContext, lpRequest))
    {
        __super::OnRequest(lpParam1, lpParam2);
    }


    UwlClearRequest(lpRequest);
#if defined(_UWL_TRACE) | defined(UWL_TRACE)
    DWORD dwTimeEnd = GetTickCount();
#else
    DWORD dwTimeEnd = 0;
#endif
    UwlTrace(_T("request process time costs: %d ms"), dwTimeEnd - dwTimeStart);
    UwlTrace(_T("----------------------end of request process---------------------\r\n"));

    return TRUE;
}

BOOL TcySockSvr::OnClientPulse(LPREQUEST req, LPCONTEXT_HEAD lpContext)
{
    SendOpeRequest(lpContext, *req);
    return TRUE;
}
