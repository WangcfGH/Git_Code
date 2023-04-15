#pragma once
#include "TcySockSvr.h"
class DemoServer : public TcySockSvr
{
public:
	DemoServer(const BYTE key[] = 0, const ULONG key_len = 0, DWORD flagEncrypt = 0, DWORD flagCompress = 0)
		: TcySockSvr(key, key_len, flagEncrypt, flagCompress){
		m_nPort = -1;
	}

	DemoServer(int nKeyType, DWORD flagEncrypt = 0, DWORD flagCompress = 0)
		: TcySockSvr(nKeyType, flagEncrypt, flagCompress){}


	~DemoServer();

	virtual BOOL Initialize() override;
};
