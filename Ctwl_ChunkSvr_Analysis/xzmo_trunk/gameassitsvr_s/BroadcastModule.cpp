#include "stdafx.h"
#include "BroadcastModule.h"


void BroadcastModule::OnServerStart(BOOL& ret, TcyMsgCenter* msgCenter)
{
	if (ret) {
		AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_BROADCAST_CONFIG, OnGetBroadCastConfig);
		m_freshTimer = evp().loopTimer([this](){
			OnFreshMsg();
		}, std::chrono::seconds(1), strand());
	}
}

void BroadcastModule::OnShutdown()
{
	m_freshTimer = nullptr;
}

void BroadcastModule::OnChunkClient(TcyMsgCenter* msgCenter)
{
	AUTO_REGISTER_MSG_OPERATOR(msgCenter, GR_BROADCAST_FROM_GAMESVR, OnBroadcastFromGameSvr);
}

void BroadcastModule::OnTest(bool& ret, std::string& cmd)
{
	if ("broadcast" == cmd) {
		strand().dispatch([this](){
			BROADCAST_MSG bm;
			bm.nDelaySec = 5;
			m_vcBroadcast.push_back(bm);
			bm.nDelaySec = 4;
			m_vcBroadcast.push_back(bm);
			bm.nDelaySec = 3;
			m_vcBroadcast.push_back(bm);
			bm.nDelaySec = 2;
			m_vcBroadcast.push_back(bm);
		});
	}
}

BOOL BroadcastModule::OnGetBroadCastConfig(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
	BROADCAST_CONFIG BroadcastConfig;
	memset(&BroadcastConfig, 0, sizeof(BroadcastConfig));

	imGetIniNumber("Broadcast", "Enable", BroadcastConfig.bEnable);
	imGetIniNumber("Broadcast", "RunType", BroadcastConfig.nRunType);
	imGetIniNumber("Broadcast", "MoveSpeed", BroadcastConfig.nMoveSpeed);
	std::string s;
	imGetIniStr("Broadcast", "noticeurl", s);
	memcpy(BroadcastConfig.szNoticeUrl, s.data(), s.size());
	sprintf_s(BroadcastConfig.szNoticeUrl, sizeof(BroadcastConfig.szNoticeUrl), "%s", s.data());

	imNotifyOneUser(lpContext->hSocket, lpContext->lTokenID, GR_BROADCAST_CONFIG, &BroadcastConfig, sizeof(BroadcastConfig));
	return TRUE;
}

BOOL BroadcastModule::OnBroadcastFromGameSvr(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
	BROADCAST_MSG* pBradcastMsg = RequestDataParse<BROADCAST_MSG>(lpRequest);
	if (nullptr == pBradcastMsg) {
		UwlLogFile("lpRequest->nDataLen != sizeof(BROADCAST_MSG) + nRepeated * sizeof(CONTEXT_HEAD)");
		return FALSE;
	}
	auto tcyMsg = MoveTcyMsgHead(lpRequest, lpContext);
	strand().dispatch([tcyMsg, this](){
		BROADCAST_MSG* pBradcastMsg = RequestDataParse<BROADCAST_MSG>(&tcyMsg->requst);
		m_vcBroadcast.push_back(*pBradcastMsg);
	});
	return TRUE;
}

void BroadcastModule::OnFreshMsg()
{
	// 每秒刷新一次
	BOOL bEnable = 0;
	imGetIniNumber("Broadcast", "Enable", bEnable);
	if (!bEnable) {
		return;
	}

	if (m_vcBroadcast.empty()) {
		return;
	}

	for (auto& it : m_vcBroadcast)
	{
		it.nDelaySec -= 1;
		it.nDelaySec = std::max<int>(0, it.nDelaySec);
	}
	std::sort(m_vcBroadcast.begin(), m_vcBroadcast.end(), [](BROADCAST_MSG&l, BROADCAST_MSG&r){
		return l.nDelaySec < r.nDelaySec;
	});
	
	auto it_b = m_vcBroadcast.begin();
	for (; it_b != m_vcBroadcast.end(); ++it_b)
	{
		if (it_b->nDelaySec > 0) {
			break;
		}
		imNotifyAllMobile(GR_BROADCAST, &(*it_b), sizeof(*it_b));
	}
	m_vcBroadcast.erase(m_vcBroadcast.begin(), it_b);
}
