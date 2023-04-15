#include "stdafx.h"
#include "DemoServer.h"


DemoServer::~DemoServer()
{
}

BOOL DemoServer::Initialize()
{
	setIPAndPort("192.168.7.201", PORT_OF_ASSITSVR);

	TCHAR szFullName[MAX_PATH];
	GetModuleFileName(GetModuleHandle(NULL), szFullName, sizeof(szFullName));

	TCHAR szIniFile[MAX_PATH];
	ZeroMemory(szIniFile, sizeof(szIniFile));
	UwlSplitPath(szFullName, SPLIT_DRIVE_DIR, szIniFile);
	lstrcat(szIniFile, PRODUCT_NAME);
	lstrcat(szIniFile, _T(".ini"));
	setIniFile(szIniFile);

	return __super::Initialize();
}
