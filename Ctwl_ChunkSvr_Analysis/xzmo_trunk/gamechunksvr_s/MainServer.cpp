#include "stdafx.h"
#include "MainServer.h"

static BOOL DB_FindInValidWord(LPCTSTR lpszName)
{
    CString sMask = _T("　%	<>()[]{}*';\"/\\| 　 ");

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
	setIPAndPort("", PORT_OF_CHUNKSVR);
	
	std::string iniFile = imGetIniFile();
	setIniFile(iniFile);

    BOOL ret = TRUE;
    do
    {
        if (CoInitialize(NULL) == S_FALSE) {
            ret = FALSE;
            UwlLogFile("CoInitialize Fail!");
            break;
        }

		if (!InitStart()) {
			ret = FALSE;
			break;
		}


        SYSTEM_INFO SystemInfo;
        ZeroMemory(&SystemInfo, sizeof(SystemInfo));
        GetSystemInfo(&SystemInfo);
        UwlTrace(_T("number of processors: %lu"), SystemInfo.dwNumberOfProcessors);
        UwlLogFile(_T("number of processors: %lu"), SystemInfo.dwNumberOfProcessors);

        int nWorkThreadCount = (SystemInfo.dwNumberOfProcessors > MAX_PROCESSORS_SUPPORT) ? MAX_PROCESSORS_SUPPORT * 2 : SystemInfo.dwNumberOfProcessors * 2;

		if (!InitChunkDB(nWorkThreadCount)) {
			ret = FALSE;
			break;
		}
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

void MainServer::SendOpeResponseForModule(LPCONTEXT_HEAD lpContext, BOOL bNeedEcho, REQUEST& response)
{
    CONTEXT_HEAD context;
    memcpy(&context, lpContext, sizeof(context));
    context.bNeedEcho = FALSE;
    SendResponse(lpContext->hSocket, &context, &response);
}

// 暂时没去实现
BOOL MainServer::OnValidateClient(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest)
{
    int nRepeated = lpRequest->head.nRepeated;

    LPVALIDATE_CLIENT lpValidateClient = LPVALIDATE_CLIENT(PBYTE(lpRequest->pDataPtr)
        + nRepeated * sizeof(CONTEXT_HEAD));

    if (CLIENT_TYPE_ROOM == lpValidateClient->nClientType)
    {
        async<int>([this, lpContext](){
            memcpy(&m_RoomSvrClient, lpContext, sizeof(CONTEXT_HEAD));
            return TRUE;
        }).get();
    }
    else if (CLIENT_TYPE_ASSIT == lpValidateClient->nClientType) {
        async<int>([this, lpContext](){
            memcpy(&m_AssistSvrClient, lpContext, sizeof(CONTEXT_HEAD));
            return TRUE;
        }).get();
    }
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

	{
		std::lock_guard<std::mutex> guard(m_dbLock);
		DB_ValidateClientEx(&m_mainDbCon, lpvce, response.head.nRequest);
	}
	
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

	int gameid = imGetGameID();
	if (gameid != vg->nGameID) {
		return FALSE;
	}

	return async<int>([this, lpContext](){
		memcpy(&m_GameSvrClient, lpContext, sizeof(CONTEXT_HEAD));
		return TRUE;
	}).get();
}

int MainServer::DB_ValidateClientEx(MysqlSession* entry, const LPVALIDATE_CLIENT_EX lpValidateClientEx, UINT& nResponse)
{
    nResponse = UR_OBJECT_NOT_EXIST;
    if (DB_FindInValidWord(lpValidateClientEx->szVolumeID))
    {
        UwlLogFile(_T("InValidWord->DB_ValidateClientEx():%s"), lpValidateClientEx->szVolumeID);
        return 0;
    }

    if (lstrlen(lpValidateClientEx->szVolumeID) >= MAX_HARDID_LEN)
    {
        return -1;
    }

    TCHAR szSql[MAX_SQL_LENGTH];
    sprintf_s(szSql, _T("select * from tblHost where VolumeID = '%s' and status = 0; "), lpValidateClientEx->szVolumeID);
    auto r = entry->mysql_excute(szSql, [](sql::ResultSet* res){
        return res->rowsCount();
    });

    int nRet = entry->mysql_check_result(r);
    if (nRet == 0) {
        nResponse = UR_FETCH_SUCCEEDED;
    }
    else {
        nResponse = UR_DATABASE_ERROR;
    }
    
    return nRet;
}

int MainServer::ReadChunkDBConfig()
{
	TCHAR szKey[32];
	TCHAR szValue[256];
	TCHAR *p1, *p2;
	TCHAR *fields[32];
	memset(fields, 0, sizeof(fields));
	memset(szKey, 0, sizeof(szKey));
	memset(szValue, 0, sizeof(szValue));

	std::string iniFile = imGetIniFile();
	int nDBCount = GetPrivateProfileInt(_T("chunkdb"), _T("count"), 1, iniFile.c_str());
	
	std::string name;
	std::string host;
	std::string user;
	std::string passwd;
	std::string dbname;
	m_nChunkDb = std::min<int>(MAX_TOTALDB_COUNT, nDBCount);
	for (int i = 0; i < m_nChunkDb; ++i) {
		_snprintf_s(szKey, sizeof(szKey), sizeof(szKey) - 1, _T("CD%d"), i);
		GetPrivateProfileString(_T("chunkdb"), szKey, _T(""), szValue, sizeof(szValue), iniFile.c_str());

		p1 = szValue;
		xyRetrieveFields(p1, fields, 8, &p2);
		m_chunkdb[i].nID = atoi(fields[0]);
		lstrcpy(m_chunkdb[i].szName, fields[1]);
		lstrcpy(m_chunkdb[i].szSource, fields[2]);
		lstrcpy(m_chunkdb[i].szCatalog, fields[3]);

		//调试时可直接读写配置文件中的账号密码
#ifdef _DEBUG
		lstrcpy(m_chunkdb[i].szUserName, fields[4]);
		lstrcpy(m_chunkdb[i].szPassword, fields[5]);
#endif
#ifdef _RS125
		lstrcpy(m_chunkdb[i].szUserName ,fields[4]);
		lstrcpy(m_chunkdb[i].szPassword ,fields[5]);
#endif
		m_chunkdb[i].nSecurityMode = atoi(fields[6]);

		m_chunkdb[i].nType = -1;
		if (!lstrcmpi(m_chunkdb[i].szName, NAME_CHUNKDB_MAIN))
			m_chunkdb[i].nType = TYPE_CHUNKDB_MAIN;
		else if (!lstrcmpi(m_chunkdb[i].szName, NAME_CHUNKDB_GAME))
			m_chunkdb[i].nType = TYPE_CHUNKDB_GAME;
		else if (!lstrcmpi(m_chunkdb[i].szName, NAME_CHUNKDB_LOG))
			m_chunkdb[i].nType = TYPE_CHUNKDB_LOG;
			
	}
	//正式发布时ReleaseS版本，需要读写加密dba文件中的账号密码
#ifndef _DEBUG
#ifndef _RS125
	FillDBAccount();
#endif
#endif
	return m_nChunkDb;
}

void MainServer::FillDBAccount()
{
	if (!UwlPathExists(m_dbaFile.c_str(), FALSE))//文件没有找到
		return;

	HANDLE hFile;
	hFile = CreateFile(m_dbaFile.c_str(),
		GENERIC_READ,
		FILE_SHARE_READ, NULL,
		OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL);
	if (hFile == INVALID_HANDLE_VALUE)
		return;

	DWORD dwFileSize = GetFileSize(hFile, NULL);
	if (dwFileSize < sizeof(DB_ACCOUNT_HEADER))
		return;

	SetFilePointer(hFile, 0, NULL, FILE_BEGIN);

	int nLen = dwFileSize;
	BYTE * pData = new BYTE[nLen];
	memset(pData, 0, nLen);
	DWORD dwRead;
	ReadFile(hFile, (LPVOID)pData, dwFileSize, &dwRead, NULL);
	CloseHandle(hFile);

	BYTE * pDecryptData = new BYTE[nLen];
	TcyDecryptData(nLen, pDecryptData, pData);
	SAFE_DELETE_ARRAY(pData);

	BYTE* pByte = pDecryptData;
	DB_ACCOUNT_HEADER*  pDBAHeader = (DB_ACCOUNT_HEADER*)pByte;
	pByte += sizeof(DB_ACCOUNT_HEADER);

	if (dwRead >= (sizeof(DB_ACCOUNT_HEADER) + pDBAHeader->nCount*sizeof(DB_ACCOUNT)))
	{
		DB_ACCOUNT* pDA = (DB_ACCOUNT*)pByte;
		for (int i = 0; i < pDBAHeader->nCount; i++)
		{
			if (pDA->nDBIndex < MAX_TOTALDB_COUNT&&pDA->nDBIndex >= 0)
			{
				lstrcpyn(m_chunkdb[pDA->nDBIndex].szUserName, pDA->szUserName, MAX_USERNAME_LEN);
				lstrcpyn(m_chunkdb[pDA->nDBIndex].szPassword, pDA->szPassword, MAX_PASSWORD_LEN);
			}

			pDA++;
		}
	}

	SAFE_DELETE_ARRAY(pDecryptData);
}

BOOL MainServer::InitStart()
{
	TCHAR szFullName[MAX_PATH];
	GetModuleFileName(GetModuleHandle(NULL), szFullName, sizeof(szFullName));

	TCHAR			szDBAFile[MAX_PATH];
	UwlSplitPath(szFullName, SPLIT_DRIVE_DIR, szDBAFile);
	lstrcat(szDBAFile, _T("dbaccount.dba"));
	m_dbaFile = szDBAFile;

	TCHAR szPID[32];
	_snprintf_s(szPID, sizeof(szPID), sizeof(szPID) - 1, _T("%d"), GetCurrentProcessId());


	std::string iniFile = imGetIniFile();
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

BOOL MainServer::InitChunkDB(int nConnCount)
{
	ZeroMemory(m_chunkdb, sizeof(m_chunkdb));
	BOOL bRet = FALSE;
	try {
		int nDBCount = ReadChunkDBConfig();

		UwlLogFile(_T("Init %d chunk db success."), nDBCount);

		bRet = TRUE;
	}
	catch (...) {
		UwlLogFile(_T("Init chunk db failed."));

		bRet = FALSE;
	}
	if (!bRet) {
		return bRet;
	}

	if (0 == m_nChunkDb) {
		UwlLogFile(_T("0 == m_nChunkDb"));
		return FALSE;
	}

	for (int i = 0; i < m_nChunkDb; ++i)
	{
		if (m_chunkdb[i].nType == TYPE_CHUNKDB_MAIN) {
			m_mainDbCon.mysql_set_connectInfo(m_chunkdb[i].szSource, m_chunkdb[i].szUserName, m_chunkdb[i].szPassword, m_chunkdb[i].szCatalog);
			m_mainDbCon.mysql_connect();
		}
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
    async<void>([this, lpContext](){
        if (lpContext->lTokenID == m_RoomSvrClient.lTokenID) {
            memset(&m_RoomSvrClient, 0, sizeof(m_RoomSvrClient));
        }
        else if (lpContext->lTokenID == m_AssistSvrClient.lTokenID){
            memset(&m_AssistSvrClient, 0, sizeof(m_AssistSvrClient));
        }
    }).get();
}

void MainServer::GetRoomSvrSocket(SOCKET &nSock, LONG& token)
{
    async<int>([this, &nSock, &token](){
        nSock = m_RoomSvrClient.hSocket;
        token = m_RoomSvrClient.lTokenID;
        return TRUE;
    }).get();
}

void MainServer::GetAssistSvrSocket(SOCKET &nSock, LONG& token)
{
    async<int>([this, &nSock, &token](){
        nSock = m_AssistSvrClient.hSocket;
        token = m_AssistSvrClient.lTokenID;
        return TRUE;
    }).get();
}

void MainServer::GetGameSvrSocket(SOCKET &sock, LONG& token)
{
	async<int>([this, &sock, &token](){
		sock = m_GameSvrClient.hSocket;
		token = m_GameSvrClient.lTokenID;
		return TRUE;
	}).get();
}
