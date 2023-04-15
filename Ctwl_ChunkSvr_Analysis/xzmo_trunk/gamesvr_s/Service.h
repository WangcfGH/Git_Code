#pragma once

class CGameService : public CMainService
{
public:
    CGameService(const TCHAR* szServiceName, const TCHAR* szDisplayName,
        const int iMajorVersion, const int iMinorVersion,
        const TCHAR* szLicenseFile,
        const TCHAR* szProductName,
        const TCHAR* szProductVer,
        const int nListenPort, const int nGameID,
        DWORD flagEncrypt = 0, DWORD flagCompress = 0)
        : CMainService(szServiceName, szDisplayName,
              iMajorVersion, iMinorVersion,
              szLicenseFile,
              szProductName,
              szProductVer,
              nListenPort, nGameID,
              flagEncrypt, flagCompress) {}
    // override
    virtual CBaseServer* OnNewServer()
    {
        CBaseServer* pMainServer = new CMyGameServer(m_szLicenseFile, m_szProductName, m_szProductVer,
            m_nListenPort, m_nGameID,
            m_flagEncrypt, m_flagCompress);
        return pMainServer;
    }

};
