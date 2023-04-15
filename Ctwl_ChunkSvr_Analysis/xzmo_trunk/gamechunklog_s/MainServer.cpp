#include "stdafx.h"
#include "MainServer.h"

static BOOL DB_FindInValidWord(LPCTSTR lpszName)
{
    CString sMask = _T("¡¡%	<>()[]{}*';\"/\\| ¡¡ ");

    CString sName;
    sName = lpszName;

    if (sName.FindOneOf(sMask) != -1)
    {
        return TRUE;
    }
    return FALSE;
}

MainServer::~MainServer()
{
}

BOOL MainServer::Initialize()
{
    setIPAndPort("", PORT_OF_CHUNKLOG);
	
	std::string iniFile;
	imGetIniFile(iniFile);
	setIniFile(iniFile);

    BOOL ret = TRUE;
    do
    {
        if (CoInitialize(NULL) == S_FALSE) {
            ret = FALSE;
            UwlLogFile("CoInitialize Fail!");
            break;
        }

		SYSTEM_INFO SystemInfo;
		ZeroMemory(&SystemInfo, sizeof(SystemInfo));
		GetSystemInfo(&SystemInfo);
		UwlTrace(_T("number of processors: %lu"), SystemInfo.dwNumberOfProcessors);
		UwlLogFile(_T("number of processors: %lu"), SystemInfo.dwNumberOfProcessors);

		int nWorkThreadCount = (SystemInfo.dwNumberOfProcessors > MAX_PROCESSORS_SUPPORT) ? MAX_PROCESSORS_SUPPORT * 2 : SystemInfo.dwNumberOfProcessors * 2;

        if (!CDefIocpServer::Initialize(m_strServerIP.c_str(), m_nPort, GetHelloData(), GetHelloLength() + 1, 0, 10,
            MAX_OVERLAPPED_ACCEPTS,
            MAX_OVERLAPPED_SENDS,
            DEF_ACCEPT_WAIT,
            DEF_SOCBUF_SIZE,
            nWorkThreadCount,
            nWorkThreadCount)) {
            ret = FALSE;
            UwlLogFile("Initialize Fail! listen<%s,%d>", m_strServerIP.c_str(), m_nPort);
            break;
        }

        m_msgCenter.setMsgOper(GR_SEND_PULSE, [this](LPCONTEXT_HEAD lpContext, LPREQUEST lpReqeust){
            this->OnClientPulse(lpReqeust, lpContext);
        });
        m_msgCenter.setMsgOper(GR_VALIDATE_CLIENT, [this](LPCONTEXT_HEAD lpContext, LPREQUEST lpReqeust){
            this->OnValidateClient(lpContext, lpReqeust);
        });
        m_msgCenter.setMsgOper(GR_VALIDATE_CLIENT_EX, [this](LPCONTEXT_HEAD lpContext, LPREQUEST lpReqeust){
            this->OnValidateClientEx(lpContext, lpReqeust);
        });
		m_msgCenter.setMsgOper(GR_VALIDATE_GAMESVR_EX, [this](LPCONTEXT_HEAD lpContext, LPREQUEST lpReqeust){
			this->OnValidateGameSvr(lpContext, lpReqeust);
		});
        m_msgCenter.setMsgOper(UR_SOCKET_CONNECT, [this](LPCONTEXT_HEAD lpContext, LPREQUEST lpReqeust){
            this->OnConnectSocket(lpContext, lpReqeust);
        });
        m_msgCenter.setMsgOper(UR_SOCKET_CLOSE, [this](LPCONTEXT_HEAD lpContext, LPREQUEST lpReqeust){
            this->OnCloseSocket(lpContext, lpReqeust);
        });
        ret = TRUE;
    } while (0);

    evSvrStart.notify(ret, &m_msgCenter);
    return ret;
}

void MainServer::SendOpeRequestForModule(LPCONTEXT_HEAD lpContext, REQUEST& response)
{
    SendOpeRequest(lpContext, response);
}

void MainServer::SendOpeReqOnlyCxtForModule(LPCONTEXT_HEAD lpContext, UINT nRepeatHead, void* pData, REQUEST& response)
{
    SendOpeReqOnlyCxt(lpContext, nRepeatHead, pData, response);
}

BOOL MainServer::OnValidateClient(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
    return TRUE;
}

BOOL MainServer::OnValidateClientEx(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
    LPVALIDATE_CLIENT_EX lpvce = LPVALIDATE_CLIENT_EX(PBYTE(lpRequest->pDataPtr));
    lpvce->dwIPAddr = GetClientAddress(lpContext->hSocket, lpContext->lTokenID);

    TCHAR szIP[MAX_SERVERIP_LEN];
    ZeroMemory(szIP, sizeof(szIP));
    UwlAddrToName(lpvce->dwIPAddr, szIP);

    REQUEST response;
    memset(&response, 0, sizeof(response));

    std::stringstream dbkey;
    dbkey << typeid(*this).name() << "_" << "OnValidateClientEx";

    imDBOpera(dbkey.str(), [this, lpvce, &response](DBConnectEntry* entry){
        return DB_ValidateClientEx(entry, lpvce, response.head.nRequest);
    }).get();
#ifdef _RS125
    response.head.nRequest = UR_FETCH_SUCCEEDED;
#endif

#ifdef _DEBUG
    response.head.nRequest = UR_FETCH_SUCCEEDED;
#endif

    BOOL bSendOK = FALSE;
    CONTEXT_HEAD context;
    memcpy(&context, lpContext, sizeof(context));
    context.bNeedEcho = FALSE;
    bSendOK = SendResponse(lpContext->hSocket, &context, &response);
    return TRUE;
}

BOOL MainServer::OnValidateGameSvr(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
	auto* vg = RequestDataParse<VALIDATE_GAMESVR>(lpRequest);
	if (nullptr == vg) {
		return FALSE;
	}

	return TRUE;
}

int MainServer::DB_ValidateClientEx(DBConnectEntry* entry, const LPVALIDATE_CLIENT_EX lpValidateClientEx, UINT& nResponse)
{
    nResponse = UR_FETCH_SUCCEEDED;
    return TRUE;
    //nResponse = UR_OBJECT_NOT_EXIST;
    //if (DB_FindInValidWord(lpValidateClientEx->szVolumeID))
    //{
    //    UwlLogFile(_T("InValidWord->DB_ValidateClientEx():%s"), lpValidateClientEx->szVolumeID);
    //    return 0;
    //}

    //if (lstrlen(lpValidateClientEx->szVolumeID) >= MAX_HARDID_LEN)
    //{
    //    return ERR_FAILD;
    //}

    //TCHAR szSql[MAX_SQL_LENGTH];
    //sprintf_s(szSql, _T("select * from tblHost where VolumeID = '%s' and status = 0; "), lpValidateClientEx->szVolumeID);
    //auto r = entry->excute(szSql, [](sql::ResultSet* res){
    //    return res->rowsCount();
    //});

    //int nRet = entry->checkResult(r);
    //if (nRet == 0) {
    //    nResponse = UR_FETCH_SUCCEEDED;
    //}
    //else {
    //    nResponse = UR_DATABASE_ERROR;
    //}
    //
    //return nRet;
}

BOOL MainServer::InitStart()
{
	TCHAR szFullName[MAX_PATH];
	GetModuleFileName(GetModuleHandle(NULL), szFullName, sizeof(szFullName));

	TCHAR			szDBAFile[MAX_PATH];
	UwlSplitPath(szFullName, SPLIT_DRIVE_DIR, szDBAFile);
	lstrcat(szDBAFile, _T("dbaccount.dba"));
	m_dbaFile = szDBAFile;

	std::string iniFile;
	imGetIniFile(iniFile);
	m_nClientID = GetPrivateProfileInt(_T("listen"), _T("clientid"), 0, iniFile.c_str());

	if (0 == m_nClientID) {
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

void MainServer::OnConnectSocket(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
    UwlTrace(_T("UR_SOCKET_CONNECT requesting..."));
}

void MainServer::OnCloseSocket(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
    UwlTrace(_T("UR_SOCKET_CLOSE requesting..."));
}

