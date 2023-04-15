#pragma once

class TcyMsgCenter;
class TestSockClient : public TcySockClient
{
public:
    TestSockClient(
		int nKeyType, DWORD flagEncrypt = 0, DWORD flagCompress = 0)
		: TcySockClient(nKeyType, flagEncrypt, flagCompress)
	{

	}

    EventNoMutex<std::string&> evGetIniFile;
    EventNoMutex<const char*, const char*, std::string&> evGetIniString;

    void TestDoSendMsg(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);

	void OnServerStart(BOOL& ret, TcyMsgCenter* msgCenter);
	void OnShutdown();

	virtual BOOL ValidateClientEx() { return TRUE; }
};
