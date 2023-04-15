#pragma once
#include "tcycomponents/TcySockSvr.h"

#define	MAX_PROCESSORS_SUPPORT	4

class DBConnectEntry;
class MainServer : public TcySockSvr
{
public:
    MainServer(const BYTE key[] = 0, const ULONG key_len = 0, DWORD flagEncrypt = 0, DWORD flagCompress = 0)
		: TcySockSvr(key, key_len, flagEncrypt, flagCompress){
		m_nPort = -1;
	}

    MainServer(int nKeyType, DWORD flagEncrypt = 0, DWORD flagCompress = 0)
		: TcySockSvr(nKeyType, flagEncrypt, flagCompress){
		m_nPort = -1;
	}


	~MainServer();

    ImportFunctional<void(std::string&)> imGetIniFile;

    // DB²Ù×÷
    ImportFunctional < std::future<int>(const std::string&, std::function<int(DBConnectEntry*)>) >
        imDBOpera;

	virtual BOOL Initialize() override;

    void SendOpeRequestForModule(LPCONTEXT_HEAD lpContext, REQUEST& response);
    void SendOpeReqOnlyCxtForModule(LPCONTEXT_HEAD lpContext, UINT nRepeatHead, void* pData, REQUEST& response);

	void GetClientID(int& clientid) {
		clientid = m_nClientID;
	}

    int DB_ValidateClientEx(DBConnectEntry* entry, const LPVALIDATE_CLIENT_EX lpValidateClientEx, UINT& nResponse);
    void GetAssistSvrSocket(SOCKET &nSock, LONG& token);
protected:
	BOOL InitStart();
    
    void OnConnectSocket(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);
    void OnCloseSocket(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);
    
	BOOL OnValidateClient(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);
	BOOL OnValidateClientEx(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);
	BOOL OnValidateGameSvr(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);

private:

	std::string			m_dbaFile;
	int					m_nClientID = 0;
};
