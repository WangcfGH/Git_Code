#pragma once
#include "plana/plana.h"
#include <map>



class PlayerLogon : public plana::threadpools::PlanaStaff
{
public:
    void OnServerStart(BOOL &ret, TcyMsgCenter *msgCenter);
    void OnShutDown();

    ImportFunctional<void(const char*, const char*, std::string&)> imGetIniString;
    ImportFunctional<void(SOCKET, LONG, UINT, void*, int)> imNotifyOneUser;

	EventNoMutex<const NtfServerLogon&> evUserLogin;

	void NotifyAllLogin(int requestid, void* data, int size);

protected:

	void OnNTFLogon(LPCONTEXT_HEAD, LPREQUEST);
	void OnCloseSocket(LPCONTEXT_HEAD, LPREQUEST);
private:
    
	std::map<int, NtfServerLogon>	m_user2sock;
	std::map<LONG, int>				m_token2user;
};

