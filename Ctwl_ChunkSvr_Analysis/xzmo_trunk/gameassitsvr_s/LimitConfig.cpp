#include "stdafx.h"
#include "LimitConfig.h"



void LimitConfig::OnServerStart(BOOL& ret, TcyMsgCenter* msgCenter)
{
	if (ret) {
		imGetIniString(_T("limitDeposit"), _T("key"), m_szLimitSetting);

		// 一分钟刷新一次
		m_timerFresh = evp().loopTimer([this](){this->OnFreshTimer(); }, std::chrono::minutes(1), strand());
	}
}

void LimitConfig::OnServerStop()
{
	m_timerFresh = nullptr;
}

void LimitConfig::OnUserLogin(const NtfServerLogon& login)
{
	auto pData = async<std::string>([this](){
		return m_szLimitSetting;
	}).get();
	imNotifyOneUser(login.sock, login.lToken, GR_GET_LIMITCONFIG, (void *)pData.c_str(), pData.size());
}

void LimitConfig::OnFreshTimer()
{
	imGetIniString(_T("limitDeposit"), _T("key"), m_szLimitSetting);
}
