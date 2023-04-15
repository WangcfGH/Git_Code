#pragma once
#include "tcycomponents/TcySockSvr.h"
class MainServer : public TcySockSvr
{
public:
    MainServer(const BYTE key[] = 0, const ULONG key_len = 0, DWORD flagEncrypt = 0, DWORD flagCompress = 0)
		: TcySockSvr(key, key_len, flagEncrypt, flagCompress){
		m_nPort = -1;
	}

    MainServer(int nKeyType, DWORD flagEncrypt = 0, DWORD flagCompress = 0)
		: TcySockSvr(nKeyType, flagEncrypt, flagCompress){
	}


	~MainServer();

    ImportFunctional<std::string()> imGetIniFile;

	virtual BOOL Initialize() override;

    void NotifyOneUser(SOCKET sock, LONG token, UINT nRequest, void* pData, int nLen);

    // 通知错误信息到app
    void NotifyOneUserErrorInfo(LPREQUEST lpRequest, LPCONTEXT_HEAD lpContext, LPCTSTR lpErroMsg);
    
    // 通知消息到app
    void NotifyOneWithParseContext(LPREQUEST lpRequest, LPCONTEXT_HEAD lpContext, UINT nRequest, void* pData, int nLen);

	BOOL SimulatorMsgToLoacl(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);
};
