#pragma once
#include "plana/plana.h"

#define  GR_GET_LIMITCONFIG     (GAME_REQ_INDIVIDUAL + 1112)  // 获取房间提示线
class LimitConfig : public plana::threadpools::PlanaStaff
{
public:
	void OnServerStart(BOOL& ret, TcyMsgCenter* msgCenter);
	void OnServerStop();

	ImportFunctional<void(const char*, const char*, std::string&)> imGetIniString;
	ImportFunctional<void(SOCKET, LONG, UINT, void*, int)> imNotifyOneUser;

	void OnUserLogin(const NtfServerLogon& login);

protected:
	void OnFreshTimer();
private:
	plana::threadpools::stdtimerPtr m_timerFresh;

	std::string m_szLimitSetting;
};

