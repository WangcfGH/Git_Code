#pragma once
#include "plana.h"
#include "../common/tcycomponents/TcySockClient.h"

class SimpleSubClient : public TcySockClient
{
public:
	SimpleSubClient(
		int nKeyType, DWORD flagEncrypt = 0, DWORD flagCompress = 0)
		: TcySockClient(nKeyType, flagEncrypt, flagCompress){}


	SimpleSubClient(const BYTE key[] = 0, const ULONG key_len = 0,
		DWORD flagEncrypt = 0, DWORD flagCompress = 0,
		BOOL bUseCRC32 = FALSE, int packet_size = DEF_PACKET_SIZE)
		:TcySockClient(key, key_len, flagEncrypt, flagCompress, bUseCRC32, packet_size){}

	void OnServerStart(BOOL& ret, TcyMsgCenter* msgCenter);

	ImportFunctional<void(const char*, const char*, std::string&)> imGetConfigStr;
	ImportFunctional<void(const char*, const char*, int&)> imGetConfigInt;
	ImportFunctional<void(int&) > imGetGameID;
	ImportFunctional<void(int &)> imGetClientID;

protected:
	// ����ҪValidateClientEx
	virtual BOOL ValidateClientEx() final { return TRUE; }
	virtual BOOL ValidateClientInfo() override;
	virtual void OnReconnect() final;

	// �̳е����࣬��Ҫ��д�������ӿ�
	virtual BOOL SubcribeMsg() = 0;
	virtual void RegesterMsgCenter() = 0;
};

class OnlineClient : public SimpleSubClient
{
public:
	OnlineClient(
		int nKeyType, DWORD flagEncrypt = 0, DWORD flagCompress = 0)
		: SimpleSubClient(nKeyType, flagEncrypt, flagCompress){}


	OnlineClient(const BYTE key[] = 0, const ULONG key_len = 0,
		DWORD flagEncrypt = 0, DWORD flagCompress = 0,
		BOOL bUseCRC32 = FALSE, int packet_size = DEF_PACKET_SIZE)
		:SimpleSubClient(key, key_len, flagEncrypt, flagCompress, bUseCRC32, packet_size){}

	EventNoMutex<NTF_PLAYERLOGON&>	evPlayerLogin;
	EventNoMutex<NTF_PLAYERLOGOFF&>	evPlayerLogoff;


protected:
	// ע���ƶ����û���¼�ǳ�����Ϣ
	virtual BOOL SubcribeMsg() override;
	virtual void RegesterMsgCenter() override;

	BOOL OnPlayerlogin(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);
	BOOL OnPlayerlogoff(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);

};