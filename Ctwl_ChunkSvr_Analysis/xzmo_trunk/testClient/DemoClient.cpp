#include "StdAfx.h"
#include "DemoClient.h"
#include "TcyMsgCenter.h"

void DemoClient::OnServerStart(BOOL& ret, TcyMsgCenter* msgCenter)
{
	if (ret) {
		TCHAR szFullName[MAX_PATH];
		GetModuleFileName(GetModuleHandle(NULL), szFullName, sizeof(szFullName));

		TCHAR szIniFile[MAX_PATH];
		ZeroMemory(szIniFile, sizeof(szIniFile));
		UwlSplitPath(szFullName, SPLIT_DRIVE_DIR, szIniFile);
		lstrcat(szIniFile, PRODUCT_NAME);
		lstrcat(szIniFile, _T(".ini"));
		setIniFile(szIniFile);

		setIpAndPort("127.0.0.1", PORT_OF_CHUNKSVR);

		ret = Create(m_szIp.c_str(), m_nPort, 10, TRUE, GetHelloData(), GetHelloLength() + 1, 1, 10);
		if (ret) {
			ret = Initialize();
		}
	}
}

void DemoClient::OnShutdown()
{
	Shutdown();
}


//////////////////////////////////////////////////////////////////////////
void DEMOClientToSelf::OnServerStart(BOOL& ret, TcyMsgCenter* msgCenter)
{
	if (ret) {
		setIpAndPort("192.168.7.201", PORT_OF_ASSITSVR);

		TCHAR szFullName[MAX_PATH];
		GetModuleFileName(GetModuleHandle(NULL), szFullName, sizeof(szFullName));

		TCHAR szIniFile[MAX_PATH];
		ZeroMemory(szIniFile, sizeof(szIniFile));
		UwlSplitPath(szFullName, SPLIT_DRIVE_DIR, szIniFile);
		lstrcat(szIniFile, PRODUCT_NAME);
		lstrcat(szIniFile, _T(".ini"));
		setIniFile(szIniFile);

		ret = Create(m_szIp.c_str(), m_nPort, 10, FALSE, GetHelloData(), GetHelloLength() + 1, 1, 10);
		if (ret) {
			ret = Initialize();
		}
	}
}

void DEMOClientToSelf::OnShutdown()
{
	Shutdown();
}

void TaskTest::OnServerStart(BOOL& ret, TcyMsgCenter* msgCenter)
{
	if (ret) {

		msgCenter->setMsgOper(100005, [this](LPREQUEST lpReqeust, LPCONTEXT_HEAD lpContext){
			this->OnTaskAward(lpReqeust, lpContext);
		});

	}
}

BOOL TaskTest::OnTaskAward(LPREQUEST req, LPCONTEXT_HEAD pContext)
{
	evMsgToChunk.notify(pContext, req);
	return TRUE;
}
