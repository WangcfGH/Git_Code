#pragma once
#include "BroadcastReq.h"
#include <vector>
#include "plana/plana.h"


class BroadcastModule : public plana::threadpools::PlanaStaff
{
public:

	void OnServerStart(BOOL& ret, TcyMsgCenter* msgCenter);
	void OnShutdown();
	void OnChunkClient(TcyMsgCenter* msgCenter);

	ImportFunctional<void(const char*, const char*, std::string&)> imGetIniStr;
	ImportFunctional<void(const char*, const char*, int&)> imGetIniNumber;
	ImportFunctional<void(SOCKET, LONG, UINT, void*, int)> imNotifyOneUser;
	ImportFunctional<void(int, void*, int)> imNotifyAllMobile;	// reqeustid,data,size

	void OnTest(bool& ret, std::string& cmd);

protected:
	BOOL OnGetBroadCastConfig(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);
	BOOL OnBroadcastFromGameSvr(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);

	void OnFreshMsg();
private:
	std::vector<BROADCAST_MSG>			m_vcBroadcast;	 //广播队列
	plana::threadpools::stdtimerPtr		m_freshTimer;	// 定时刷新消息发到客户端
};

