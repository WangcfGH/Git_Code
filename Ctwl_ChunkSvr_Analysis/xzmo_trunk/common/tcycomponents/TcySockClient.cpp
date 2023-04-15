#include "stdafx.h"
#include "TcySockClient.h"

#ifndef GR_SEND_PULSE
    // 游戏服务器内的tcy头文件，跟assist和chunk有很大不同；不能使用tcycomment.h
    #define     GR_SEND_PULSE           GR_SEND_PULSE_EX
#endif //GR_SEND_PULSE

TcySockClient::~TcySockClient()
{
}

BOOL TcySockClient::Initialize()
{
    // 业务方自己进行create 成功了，再调用我
    //////////////////////////////////////////////////////////////////////////
    int nFreshDiff = GetPrivateProfileInt(_T("Timer"), _T("Interval"), FRESH_TIMER_DIFF, m_iniFile.c_str());
    m_timerFresh = evp().loopTimer([this]()
    {
        this->OnTimerFresh();
    }, std::chrono::minutes(nFreshDiff), strand());

    int nPulseDiff = GetPrivateProfileInt(_T("ServerPulse"), _T("Interval"), PULSE_TIMER_DIFF, m_iniFile.c_str());
    m_timerPulse = evp().loopTimer([this]()
    {
        this->OnTimerPulse();
    }, std::chrono::seconds(nPulseDiff), strand());

    m_timerDoClear = evp().loopTimer([this]()
    {
        SYSTEMTIME time;
        ZeroMemory(&time, sizeof(time));
        if (time.wHour == 6)
        {
            // 每天早上，进行清理
            this->DoTimingWork();
        }
    }, std::chrono::hours(1), strand());

    m_msgCenter.setMsgOper(UR_SOCKET_CLOSE, [this](LPCONTEXT_HEAD context, LPREQUEST req)
    {
        this->OnConnectClose(req, context);
    });

    m_msgCenter.setMsgOper(UR_SOCKET_ERROR, [this](LPCONTEXT_HEAD context, LPREQUEST req)
    {
        this->OnConnectClose(req, context);
    });
    m_msgCenter.setMsgOper(GR_SEND_PULSE, [this](LPCONTEXT_HEAD context, LPREQUEST req)
    {
        this->OnServerPulse(req, context);
    });

    evClientStart.notify(&m_msgCenter);
    int ret = ValidateClientEx();
    if (ret)
    {
        ValidateClientInfo();
    }
    return ret;
}

void TcySockClient::Shutdown()
{
    __super::Shutdown();

    m_msgCenter.clear();
    m_timerFresh = nullptr;
    m_timerPulse = nullptr;
    m_timerDoClear = nullptr;
}

void TcySockClient::DoSendMsg(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
    auto tcyMsgHead = CopyTcyMsgHead(lpRequest, lpContext);

    auto f = [this, tcyMsgHead]{
		SendMsgByAddContexthead(tcyMsgHead);
	};
	strand().post(f);
}

void TcySockClient::DoSendMsgByMoveData(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
    auto tcyMsgHead = MoveTcyMsgHead(lpRequest, lpContext);

    auto f = [this, tcyMsgHead]{
		SendMsgByAddContexthead(tcyMsgHead);
    };

    strand().post(f);
}


void TcySockClient::DoSendMsgWaitRsp(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest, LPREQUEST lpResponse, int nTimeOut)
{
    auto tcyMsgHead = MoveTcyMsgHead(lpRequest, lpContext);

    auto f = [this, tcyMsgHead, lpResponse, nTimeOut]{
        CONTEXT_HEAD context;
        memset(&context, 0, sizeof(context));
        context.hSocket = GetSocket();
        context.lSession = 0;
        context.bNeedEcho = TRUE;
        BOOL bTimeout = FALSE;
        BOOL bRet = SendRequest(&context, &tcyMsgHead->requst, lpResponse, bTimeout, nTimeOut);
        return bRet;
    };

    async<int>(f).get();
}

BOOL TcySockClient::OnTimerPulse()
{
    int nCheck = GetPrivateProfileInt(_T("ServerPulse"), _T("Check"), 1, m_iniFile.c_str());

    if (nCheck)
    {
        int nLatest = m_ChunkSvrPulseInfo.nLatestTime;
        if (nLatest != 0)
        {
            int nNow = UwlGetCurrentSeconds();
            if (nNow - nLatest > PULSE_TIMER_DIFF * 1000)
            {
                int nDate, nTime;
                UwlGetCurrentDateTime(nDate, nTime);

                if (m_ChunkSvrPulseInfo.nCurrentDate == nDate)
                {
                    m_ChunkSvrPulseInfo.nReconnectCount++;
                }
                else
                {
                    m_ChunkSvrPulseInfo.nCurrentDate = nDate;
                    m_ChunkSvrPulseInfo.nReconnectCount = 0;
                }

                OnReconnect();
            }
        }
    }

    return TRUE;
}

BOOL TcySockClient::OnTimerFresh()
{
    OnSendPulseData();
    return TRUE;
}

void TcySockClient::OnSendPulseData()
{
    REQUEST request;
    memset(&request, 0, sizeof(request));
    REQUEST response;
    memset(&response, 0, sizeof(response));

    CONTEXT_HEAD context;
    memset(&context, 0, sizeof(context));
    context.hSocket = GetSocket();

    request.head.nRequest = GR_SEND_PULSE;

    SendCast(&context, &request, &response);
}

int TcySockClient::DoTimingWork()
{
    int count = ReleaseSockBufPool();
    UwlLogFile(_T("release chunk_client buffer pool done. count = %ld."), count);
    return 0;
}

void TcySockClient::SendMsgByAddContexthead(std::shared_ptr<TcyMsgHead> tcyMsgHead)
{
	LPREQUEST pRequest = &tcyMsgHead->requst;
	LPCONTEXT_HEAD pContext = &tcyMsgHead->context;
	int nLen = sizeof(CONTEXT_HEAD) + pRequest->nDataLen;
	PBYTE pData = new BYTE[nLen];
	memcpy(pData, pContext, sizeof(CONTEXT_HEAD));
	memcpy(pData + sizeof(CONTEXT_HEAD), pRequest->pDataPtr, pRequest->nDataLen);
	REQUEST request;
	memset(&request, 0, sizeof(request));
	request.nDataLen = nLen;
	request.pDataPtr = pData;
	request.head.nRequest = pRequest->head.nRequest;
	request.head.nRepeated = 1;

	CONTEXT_HEAD context;
	memset(&context, 0, sizeof(context));

	BOOL bTimeout = FALSE;
	BOOL bRet = SendRequest(&context, &request, NULL, bTimeout);
	if (!bRet) {
		UwlLogFile("%s sendRequest ret False %d", typeid(*this).name(), request.head.nRequest);
		m_faildRequests.push_back(tcyMsgHead);
		OnConnectClose(nullptr, nullptr);
	}
	UwlClearRequest(&request);
}

void TcySockClient::OnReconnect()
{

    CloseSockets();

    if (FALSE == BeginConnect(m_szIp.c_str(), m_nPort, 1, DEF_ADDRESS_FAMILY, SOCK_STREAM,
            IPPROTO_TCP,
            1000))
    {
        UwlTrace(_T("Can not connect to server %s."), typeid(*this).name());
        UwlLogFile(_T("Can not connect to server %s."), typeid(*this).name());
    }
    else
    {
        UwlTrace(_T("connect to server %s."), typeid(*this).name());
        UwlLogFile(_T("connect to server %s."), typeid(*this).name());
        m_timerReconnect = nullptr;
        ValidateClientInfo();

		std::vector<std::shared_ptr<TcyMsgHead> > tmp = m_faildRequests;
		m_faildRequests.clear();
		for (auto it: tmp)
		{
			UwlLogFile("faild request send~");
			SendMsgByAddContexthead(it);
		}

        evConnectOK();
    }

}

BOOL TcySockClient::OnRequest(void* lpParam1, void* lpParam2)
{
    LPCONTEXT_HEAD pContext = LPCONTEXT_HEAD(lpParam1);
    LPREQUEST pRequest = LPREQUEST(lpParam2);

    if (!m_msgCenter.notify(pContext, pRequest))
    {
        __super::OnRequest(lpParam1, lpParam2);
    }
    UwlClearRequest(pRequest);
    return TRUE;
}

BOOL TcySockClient::OnConnectClose(LPREQUEST, LPCONTEXT_HEAD)
{
    m_timerReconnect = evp().loopTimer([this]()
    {
        this->OnReconnect();
    }, std::chrono::seconds(RECONNECT_TIME_DIFF), strand());
    return TRUE;
}

BOOL TcySockClient::OnServerPulse(LPREQUEST, LPCONTEXT_HEAD)
{
    strand().dispatch([this]()
    {
        m_ChunkSvrPulseInfo.nLatestTime = UwlGetCurrentSeconds();
    });
    return TRUE;
}

BOOL TcySockClient::ValidateClientEx()
{
    REQUEST request;
    memset(&request, 0, sizeof(request));
    REQUEST response;
    memset(&response, 0, sizeof(response));

    CONTEXT_HEAD context;
    context.hSocket = GetSocket();
    context.lSession = 0;
    context.bNeedEcho = TRUE;

    VALIDATE_CLIENT_EX vce;
    ZeroMemory(&vce, sizeof(vce));
    vce.nClientType = m_nClientType; //
	vce.nClientID = imGetGameID();
    xyGetHardID(vce.szHardID);
    xyGetVolumeID(vce.szVolumeID);
    xyGetMachineID(vce.szMachineID);
    request.head.nRequest = GR_VALIDATE_CLIENT_EX;
    request.nDataLen = sizeof(vce);
    request.pDataPtr = &vce;

    BOOL bTimeout = FALSE;
    BOOL bSendOK = SendRequest(&context, &request, &response, bTimeout, 10000);
    if (!bSendOK || UR_FETCH_SUCCEEDED != response.head.nRequest)
    {
        UwlLogFile(_T("ValidateClientEx() failed!"));
        UwlClearRequest(&response);
        return FALSE;
    }

    UwlClearRequest(&response);
    UwlLogFile(_T("ValidateClientEx() OK!"));
    return TRUE;
}

BOOL TcySockClient::ValidateClientInfo()
{
    REQUEST request;
    memset(&request, 0, sizeof(request));
    REQUEST response;
    memset(&response, 0, sizeof(response));

    CONTEXT_HEAD context;
    memset(&context, 0, sizeof(context));
    context.hSocket = GetSocket();

    VALIDATE_CLIENT vc;
    ZeroMemory(&vc, sizeof(vc));
	vc.nClientID = imGetClientID();
    vc.nClientType = m_nClientType; //

    request.head.nRequest = GR_VALIDATE_CLIENT;
    request.nDataLen = sizeof(vc);
    request.pDataPtr = &vc;

    BOOL bTimeout = FALSE;
    BOOL bSendOK = SendRequest(&context, &request, &response, bTimeout);
    return bSendOK;
}

void TcySockClient::setClientType(int type)
{
    m_nClientType = type;
}
