#include "stdafx.h"
#include "GameServer.h"


GameServer::GameServer(
	const TCHAR* szLicenseFile, 
	const TCHAR* szProductName, 
	const TCHAR* szProductVer, 
	const int nListenPort, 
	const int nGameID, 
	DWORD flagEncrypt, 
	DWORD flagCompress):
	CMainServer(szLicenseFile, szProductName, szProductVer, nListenPort, nGameID, flagEncrypt, flagCompress)
{

}

GameServer::~GameServer()
{
}

BOOL GameServer::OnRequest(void* lpParam1, void* lpParam2)
{
	LPCONTEXT_HEAD  lpContext = LPCONTEXT_HEAD(lpParam1);
	LPREQUEST       lpRequest = LPREQUEST(lpParam2);

#if defined(_UWL_TRACE) | defined(UWL_TRACE)
	DWORD dwTimeStart = GetTickCount();
#else
	DWORD dwTimeStart = 0;
#endif

	if (!m_msgCenter.notify(lpContext, lpRequest)) {
		__super::OnRequest(lpParam1, lpParam2);
	}
	
	UwlClearRequest(lpRequest);
#if defined(_UWL_TRACE) | defined(UWL_TRACE)
	DWORD dwTimeEnd = GetTickCount();
#else
	DWORD dwTimeEnd = 0;
#endif
	UwlTrace(_T("request process time costs: %d ms"), dwTimeEnd - dwTimeStart);
	UwlTrace(_T("----------------------end of request process---------------------\r\n"));

	return TRUE;
}

BOOL GameServer::Initialize()
{
	BOOL ret = __super::Initialize();
	evSvrStart.notify(ret, &m_msgCenter);
	return ret;
}

VOID GameServer::Shutdown()
{
	__super::Shutdown();

	m_msgCenter.clear();

	evShutdown.notify();
}
