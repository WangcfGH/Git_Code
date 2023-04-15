#pragma once

HINSTANCE XygInit(LPCTSTR lpszAppTitle = NULL, DWORD dwTraceMode 
						= UWL_TRACE_DATETIME | UWL_TRACE_FILELINE | UWL_TRACE_NOTFULLPATH
						| UWL_TRACE_FORCERETURN | UWL_TRACE_DUMPFILE | UWL_TRACE_CONSOLE,
						BOOL bNoResDll = FALSE);
void XygTerm(HINSTANCE hResDll, BOOL bNoResDll = FALSE);


int XygInitNoRes(LPCTSTR lpszAppTitle = NULL, DWORD dwTraceMode 
						= UWL_TRACE_DATETIME | UWL_TRACE_FILELINE | UWL_TRACE_NOTFULLPATH
						| UWL_TRACE_FORCERETURN | UWL_TRACE_DUMPFILE | UWL_TRACE_CONSOLE);
void XygTermNoRes();

class CAssitService  : public CNTService{
public:	
	CAssitService(const TCHAR* szServiceName, const TCHAR* szDisplayName,
		const int iMajorVersion, const int iMinorVersion,
		const TCHAR* szLicenseFile,
		const TCHAR* szProductName,
		const TCHAR* szProductVer,
		const int nListenPort, const int nGameID,
		DWORD flagEncrypt = 0, DWORD flagCompress = 0);
	virtual ~CAssitService();
	
	// common
	virtual BOOL OnInit();
    virtual void Run();
	virtual void OnStop();
    virtual BOOL OnUserControl(DWORD dwOpcode);
	
    virtual void SaveStatus();
	
	// Control parameters
	int				m_iStartParam;
	int				m_iIncParam;
	
	// Current state
	int				m_iState;
	
	//
	TCHAR			m_szLicenseFile[MAX_PATH];
	TCHAR			m_szProductName[MAX_PRODUCT_LEN];
	TCHAR			m_szProductVer[MAX_VERSION_LEN];
	int				m_nListenPort;
	int				m_nGameID;
	DWORD			m_flagEncrypt;
	DWORD			m_flagCompress;
	//
	DWORD			m_dwThreadId;
};