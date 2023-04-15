#include "StdAfx.h"
#include "Predefine.h"

static int  xyRetrieveFields_Ref(TCHAR* buf, TCHAR** fields, int maxfields, TCHAR** buf2)
{
    if (buf == NULL)
    {
        return 0;
    }

    TCHAR* p;
    p = buf;
    int count = 0;

    try
    {
        while (1)
        {
            fields[count++] = p;
            while (*p != '|' && *p != '\0')
            {
                p++;
            }
            if (*p == '\0' || count >= maxfields)
            {
                break;
            }
            *p = '\0';
            p++;
        }
    }
    catch (...)
    {
        buf2 = NULL;
        return 0;
    }

    if (*p == '\0')
    {
        *buf2 = NULL;
    }
    else
    {
        *buf2 = p + 1;
    }
    *p = '\0';

    return count;
}



void CPredefine::init()
{
    TCHAR szFullName[MAX_PATH];
    GetModuleFileName(GetModuleHandle(NULL), szFullName, sizeof(szFullName));

    TCHAR           szIniFile[MAX_PATH];
    UwlSplitPath(szFullName, SPLIT_DRIVE_DIR, szIniFile);
    lstrcat(szIniFile, PRODUCT_NAME);
    lstrcat(szIniFile, _T(".ini"));

    InitClientID();

    iniFile = szIniFile;
}

void CPredefine::getInitDataInt(const char* areaname, const char* key, int &result)
{
	result = ::GetPrivateProfileInt(areaname, key, result, iniFile.c_str());
}

void CPredefine::getInitDataString(const char* areaname, const char* key, std::string& result)
{
	char buffer[1024];
	ZeroMemory(buffer, sizeof(buffer));
	::GetPrivateProfileString(areaname, key, result.c_str(), buffer, sizeof(buffer)-1, iniFile.c_str());
	result = buffer;
}

void CPredefine::evGetClientID(int &nClientID)
{
    nClientID = m_nClientID;
}

BOOL CPredefine::InitClientID()
{
	m_nClientID = GetPrivateProfileInt(_T("listen"), _T("clientid"), 0, iniFile.c_str());
	if (0 == m_nClientID)
	{
		UwlTrace(_T("invalid client id!"));
		UwlLogFile(_T("invalid client id!"));
		return FALSE;
	}
	else
	{
		UwlTrace(_T("client id=%d!"), m_nClientID);
		UwlLogFile(_T("client id=%d!"), m_nClientID);
	}

    return TRUE;
}