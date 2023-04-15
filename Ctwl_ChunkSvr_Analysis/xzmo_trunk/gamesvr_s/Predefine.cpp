#include "stdafx.h"
#include "Predefine.h"

void CPredefine::init()
{
    TCHAR szFullName[MAX_PATH];
    GetModuleFileName(GetModuleHandle(NULL), szFullName, sizeof(szFullName));

    TCHAR           szIniFile[MAX_PATH];
    UwlSplitPath(szFullName, SPLIT_DRIVE_DIR, szIniFile);
    lstrcat(szIniFile, PRODUCT_NAME);
    lstrcat(szIniFile, _T(".ini"));

    iniFile = szIniFile;
}

void CPredefine::getInitDataInt(const char* areaname, const char* key, int& result)
{
    result = ::GetPrivateProfileInt(areaname, key, result, iniFile.c_str());
}

void CPredefine::getInitDataString(const char* areaname, const char* key, std::string& result)
{
    char buffer[1024];
    ZeroMemory(buffer, sizeof(buffer));
    ::GetPrivateProfileString(areaname, key, result.c_str(), buffer, sizeof(buffer) - 1, iniFile.c_str());
    result = buffer;
}