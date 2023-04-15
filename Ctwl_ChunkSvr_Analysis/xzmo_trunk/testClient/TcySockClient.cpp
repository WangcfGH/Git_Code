#include "stdafx.h"
#include "TcySockClient.h"

TcySockClient::~TcySockClient()
{
}

BOOL TcySockClient::Initialize()
{
	// 业务方自己进行create 成功了，再调用我
	//////////////////////////////////////////////////////////////////////////
	int nFreshDiff = GetPrivateProfileInt(_T("Timer"), _T("Interval"), FRESH_TIMER_DIFF, m_iniFile.c_str());
	m_timerFresh = evp().loopTimer([this](){
		this->OnTimerFresh();
    }, std::chrono::minutes(nFreshDiff), strand());

    int nPulseDiff = GetPrivateProfileInt(_T("ServerPulse"), _T("Interval"), PULSE_TIMER_DIFF, m_iniFile.c_str());
	m_timerPulse = evp().loopTimer([this](){
		this->OnTimerPulse();
	}, std::chrono::seconds(nPulseDiff), strand());

	m_timerDoClear = evp().loopTimer([this](){
		SYSTEMTIME time;
		ZeroMemory(&time, sizeof(time));
		if (time.wHour == 6) {
			// 每天早上，进行清理
			this->DoTimingWork();
		}
	}, std::chrono::hours(1), strand());

	m_msgCenter.setMsgOper(UR_SOCKET_CLOSE, [this](LPCONTEXT_HEAD context, LPREQUEST req){
		this->OnConnectClose(req, context);
	});
	
	m_msgCenter.setMsgOper(UR_SOCKET_ERROR, [this](LPCONTEXT_HEAD context, LPREQUEST req){
		this->OnConnectClose(req, context);
	});
	m_msgCenter.setMsgOper(GR_SEND_PULSE, [this](LPCONTEXT_HEAD context, LPREQUEST req){
		this->OnServerPulse(req, context);
	});

    evClientStart.notify(&m_msgCenter);
	return TRUE;
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
	std::shared_ptr<CONTEXT_HEAD> pContext = std::make_shared<CONTEXT_HEAD>(*lpContext);
	std::shared_ptr<REQUEST> pRequest = std::make_shared<REQUEST>(*lpRequest);
	pRequest->pDataPtr = new BYTE[lpRequest->nDataLen];
	pRequest->nDataLen = lpRequest->nDataLen;
	memcpy(pRequest->pDataPtr, lpRequest->pDataPtr, lpRequest->nDataLen);

    auto f = [this, pContext, pRequest]{
		int nLen = sizeof(CONTEXT_HEAD) + pRequest->nDataLen;
		PBYTE pData = new BYTE[nLen];
		memcpy(pData, pContext.get(), sizeof(CONTEXT_HEAD));
		memcpy(pData + sizeof(CONTEXT_HEAD), pRequest->pDataPtr, pRequest->nDataLen);
		REQUEST request;
		memset(&request, 0, sizeof(request));
		request.nDataLen = nLen;
		request.pDataPtr = pData;
		request.head.nRequest = pRequest->head.nRequest;
		request.head.nRepeated = 1;

		UwlClearRequest(pRequest.get());
		CONTEXT_HEAD context;
		memset(&context, 0, sizeof(context));

		BOOL bTimeout = FALSE;
        BOOL bRet = SendRequest(&context, &request, NULL, bTimeout);
		UwlClearRequest(&request);
	};

	strand().post(f);
}

BOOL TcySockClient::OnTimerPulse()
{
	int nCheck = GetPrivateProfileInt(_T("ServerPulse"), _T("Check"), 1, m_iniFile.c_str());

	if (nCheck) {
		int nLatest = m_ChunkSvrPulseInfo.nLatestTime;
		if (nLatest != 0) {
			int nNow = UwlGetCurrentSeconds();
			if (nNow - nLatest > PULSE_TIMER_DIFF * 1000) {
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

void TcySockClient::OnReconnect()
{

	CloseSockets();

	if (FALSE == BeginConnect(m_szIp.c_str(), m_nPort, 1, DEF_ADDRESS_FAMILY, SOCK_STREAM,
		IPPROTO_TCP,
		1000)) {
		UwlTrace(_T("Can not connect to server %s."), typeid(*this).name());
		UwlLogFile(_T("Can not connect to server %s."), typeid(*this).name());
	}
	else {
		UwlTrace(_T("connect to server %s."), typeid(*this).name());
		UwlLogFile(_T("connect to server %s."), typeid(*this).name());
		m_timerReconnect = nullptr;
	}

}

BOOL TcySockClient::OnRequest(void* lpParam1, void* lpParam2)
{
	LPCONTEXT_HEAD pContext = LPCONTEXT_HEAD(lpParam1);
	LPREQUEST pRequest = LPREQUEST(lpParam2);
	
	if (!m_msgCenter.notify(pContext, pRequest)) {
		__super::OnRequest(lpParam1, lpParam2);
	}
	UwlClearRequest(pRequest);
	return TRUE;
}

BOOL TcySockClient::OnConnectClose(LPREQUEST, LPCONTEXT_HEAD)
{
	m_timerReconnect = evp().loopTimer([this](){
		this->OnReconnect();
	}, std::chrono::seconds(RECONNECT_TIME_DIFF), strand());
	return TRUE;
}

BOOL TcySockClient::OnServerPulse(LPREQUEST, LPCONTEXT_HEAD)
{
	strand().dispatch([this](){
		m_ChunkSvrPulseInfo.nLatestTime = UwlGetCurrentSeconds();
	});
	return TRUE;
}

