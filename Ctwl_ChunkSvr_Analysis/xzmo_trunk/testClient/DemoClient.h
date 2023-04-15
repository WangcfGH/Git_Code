#pragma once
#include "TcySockClient.h"

class TcyMsgCenter;
class DemoClient : public TcySockClient
{
public:
	DemoClient(
		int nKeyType, DWORD flagEncrypt = 0, DWORD flagCompress = 0)
		: TcySockClient(nKeyType, flagEncrypt, flagCompress)
	{

	}


	void OnServerStart(BOOL& ret, TcyMsgCenter* msgCenter);
	void OnShutdown();
};

class DEMOClientToSelf : public TcySockClient
{
public:
	DEMOClientToSelf(
		int nKeyType, DWORD flagEncrypt = 0, DWORD flagCompress = 0)
		: TcySockClient(nKeyType, flagEncrypt, flagCompress)
	{

	}

	DEMOClientToSelf(const BYTE key[] = 0, const ULONG key_len = 0,
		DWORD flagEncrypt = 0, DWORD flagCompress = 0)
		:TcySockClient(key, key_len, flagEncrypt, flagCompress){

	}

	void OnServerStart(BOOL& ret, TcyMsgCenter* msgCenter);
	void OnShutdown();

};


#include "../common/plana/event/Event.h"
class TaskTest
{
public:

	void OnServerStart(BOOL& ret, TcyMsgCenter* msgCenter);

	BOOL OnTaskAward(LPREQUEST, LPCONTEXT_HEAD);

	plana::events::BasicEventNoMutex<LPCONTEXT_HEAD, LPREQUEST> evMsgToChunk;
};