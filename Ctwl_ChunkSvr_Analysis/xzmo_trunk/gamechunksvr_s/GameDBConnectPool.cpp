#include "stdafx.h"
#include "GameDBConnectPool.h"
DBConnectEntry::DBConnectEntry(DBConnectPool* pool) :PoolEntry(pool)
{
	
}

void DBConnectEntry::enterThread()
{
	CoInitialize(NULL);
	mysql_connect();
	sqlsvr_open();
	MysqlConnector::beginThread();
}

void DBConnectEntry::leaveThread()
{
	if (m_sqlCon && m_sqlCon->GetState() == adStateClosed) {
		m_sqlCon->Close();
		m_sqlCon->Release();
	}
	pCon.reset();
	MysqlConnector::endThread();
	sqlsvr_close();
	::CoUninitialize();
}



//////////////////////////////////////////////////////////////////////////
GameDBConnectPool::GameDBConnectPool(int nthread/* = 8*/):DBConnectPool(nthread)

{
}


GameDBConnectPool::~GameDBConnectPool()
{
}


void GameDBConnectPool::start(int n /* = 8 */)
{
	ReadGameChunkDBConfig();

	__super::start(n);
}

std::shared_ptr<ThreadEntryBase> GameDBConnectPool::createThreadEntry()
{
	auto entry = std::make_shared<DBConnectEntry>(this);
	entry->mysql_set_connectInfo(m_mysql_dbInfo.szSource, m_mysql_dbInfo.szUserName, m_mysql_dbInfo.szPassword, m_mysql_dbInfo.szCatalog);
	CString sRet;
	if (m_sqlsvr_dbinfo.nSecurityMode == 1)
	{
		sRet.Format(_T("Provider=sqloledb;Integrated Security=SSPI;Persist Security Info=True;Data Source=%s;Initial Catalog=%s;"), m_sqlsvr_dbinfo.szSource, m_sqlsvr_dbinfo.szCatalog);
	}
	else
	{
		sRet.Format(_T("Provider=sqloledb;Data Source=%s;Initial Catalog=%s;User Id=%s;Password=%s;"), m_sqlsvr_dbinfo.szSource, m_sqlsvr_dbinfo.szCatalog, m_sqlsvr_dbinfo.szUserName, m_sqlsvr_dbinfo.szPassword);
	}
	
	entry->set_sqlsvr_info(sRet.GetBuffer());

	std::string ip = "127.0.0.1";
	std::string auth;
	int port;
	imIniStr("Redis", "IP", ip);
	imIniStr("Redis", "Auth", auth);
	imIniInt("Redis", "Port", port);
	if (!entry->ConnectServer(ip.c_str(), auth.c_str(), port, 0)) {
		throw std::exception("redis connect error!");
	}
	return entry;
}

BOOL GameDBConnectPool::ReadGameChunkDBConfig()
{
	TCHAR szFullName[MAX_PATH];
	GetModuleFileName(GetModuleHandle(NULL), szFullName, sizeof(szFullName));

	TCHAR			szDBAFile[MAX_PATH];
	UwlSplitPath(szFullName, SPLIT_DRIVE_DIR, szDBAFile);
	lstrcat(szDBAFile, _T("dbaccount.dba"));
	m_dbaFile = szDBAFile;

	int dbCount = 0;
	imIniInt("chunkdb", "count", dbCount);

	TCHAR szKey[32];
	TCHAR szValue[256];
	TCHAR *p1, *p2;
	TCHAR *fields[32];
	memset(fields, 0, sizeof(fields));
	memset(szKey, 0, sizeof(szKey));
	memset(szValue, 0, sizeof(szValue));
	m_mysql_dbInfo.nID = -1;
	m_mysql_dbIndex = -1;
	m_sqlsvr_dbinfo.nID = -1;
	m_sqlsvr_dbIndex = -1;
	for (int i = 0; i < dbCount; ++i)
	{
		_snprintf_s(szKey, sizeof(szKey), sizeof(szKey) - 1, _T("CD%d"), i);
		std::string value;
		imIniStr("chunkdb", szKey, value);
		if (value.empty()) {
			continue;
		}
		memcpy(szValue, value.data(), sizeof(szValue));
		p1 = szValue;
		xyRetrieveFields(p1, fields, 8, &p2);
		TCHAR szName[MAX_SERVERNAME_LEN] = {0};
		lstrcpy(szName, fields[1]);

		if (0 == lstrcmpi(szName, NAME_CHUNKDB_GAME)) {
			lstrcpy(m_mysql_dbInfo.szName, fields[1]);
			m_mysql_dbInfo.nID = atoi(fields[0]);
			lstrcpy(m_mysql_dbInfo.szSource, fields[2]);
			lstrcpy(m_mysql_dbInfo.szCatalog, fields[3]);
			//调试时可直接读写配置文件中的账号密码
#ifdef _DEBUG
			lstrcpy(m_mysql_dbInfo.szUserName, fields[4]);
			lstrcpy(m_mysql_dbInfo.szPassword, fields[5]);
#endif
#ifdef _RS125
			lstrcpy(m_mysql_dbInfo.szUserName, fields[4]);
			lstrcpy(m_mysql_dbInfo.szPassword, fields[5]);
#endif
			m_mysql_dbInfo.nSecurityMode = atoi(fields[6]);
			m_mysql_dbIndex = i;
			continue;
		}
		else if (0 == lstrcmpi(szName, "GAME1")) {
			lstrcpy(m_sqlsvr_dbinfo.szName, fields[1]);
			m_sqlsvr_dbinfo.nID = atoi(fields[0]);
			lstrcpy(m_sqlsvr_dbinfo.szSource, fields[2]);
			lstrcpy(m_sqlsvr_dbinfo.szCatalog, fields[3]);
			//调试时可直接读写配置文件中的账号密码
#ifdef _DEBUG
			lstrcpy(m_sqlsvr_dbinfo.szUserName, fields[4]);
			lstrcpy(m_sqlsvr_dbinfo.szPassword, fields[5]);
#endif
#ifdef _RS125
			lstrcpy(m_sqlsvr_dbinfo.szUserName, fields[4]);
			lstrcpy(m_sqlsvr_dbinfo.szPassword, fields[5]);
#endif
			m_sqlsvr_dbinfo.nSecurityMode = atoi(fields[6]);
			m_sqlsvr_dbIndex = i;
			continue;
		}
	}
	//正式发布时ReleaseS版本，需要读写加密dba文件中的账号密码
#ifndef _DEBUG
#ifndef _RS125
	FillGameDBAccount();
#endif
#endif

	if (m_mysql_dbInfo.nID == -1 || m_sqlsvr_dbinfo.nID == -1) {
		throw std::exception("no game db info");
	}
	return TRUE;
}

void GameDBConnectPool::FillGameDBAccount()
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

	BOOL bFindMysql = FALSE;
	BOOL bFindSqlsvr = FALSE;
	if (dwRead >= (sizeof(DB_ACCOUNT_HEADER) + pDBAHeader->nCount*sizeof(DB_ACCOUNT)))
	{
		DB_ACCOUNT* pDA = (DB_ACCOUNT*)pByte;
		for (int i = 0; i < pDBAHeader->nCount; i++)
		{
			if (pDA->nDBIndex < MAX_TOTALDB_COUNT&&pDA->nDBIndex >= 0)
			{
				if (m_mysql_dbIndex == pDA->nDBIndex) {
					lstrcpyn(m_mysql_dbInfo.szUserName, pDA->szUserName, MAX_USERNAME_LEN);
					lstrcpyn(m_mysql_dbInfo.szPassword, pDA->szPassword, MAX_PASSWORD_LEN);
					bFindMysql = TRUE;
					break;
				}
				else if (m_sqlsvr_dbIndex == pDA->nDBIndex) {
					lstrcpyn(m_sqlsvr_dbinfo.szUserName, pDA->szUserName, MAX_USERNAME_LEN);
					lstrcpyn(m_sqlsvr_dbinfo.szPassword, pDA->szPassword, MAX_PASSWORD_LEN);
					bFindSqlsvr = TRUE;
					break;
				}
			}

			pDA++;
		}
	}

	SAFE_DELETE_ARRAY(pDecryptData);

	if (!bFindMysql && !bFindSqlsvr) {
		throw std::exception("no game db info with Decrypt");
	}
}

CString CRedisMgrEx::RedisCommand_pach(const char* format)
{
	CAutoLock lock(&m_csRedisCmd);
	redisReply* reply = (redisReply*)redisCommand(m_pContext, format);
	if (m_pContext->err != REDIS_OK)
	{
		DisConnect();
		if (!ConnectServer())
		{
			LOG_ERROR("Redis Reconnect faild. m_pContext = %d", (long)m_pContext);
			return REDIS_EXEC_ERROR;
		}
		reply = (redisReply*)redisCommand(m_pContext, format);
		LOG_ERROR("Redis Reconnect OK. m_pContext = %d", (long)m_pContext);
	}
	if (m_pContext->err != REDIS_OK)
	{
		LOG_ERROR("Redis ExecCommand faild after Reconnect. Err = %d", m_pContext->err);
		return REDIS_EXEC_ERROR;
	}
	if (nullptr == reply) {
		LOG_ERROR("Redis ExecCommand faild reply == nullptr.Err = %d", m_pContext->err);
		return REDIS_EXEC_ERROR;
	}
	CString ret;
	switch (reply->type)
	{
	case REDIS_REPLY_STRING:
	case REDIS_REPLY_STATUS:
	case REDIS_REPLY_ERROR:
	{
		ret = reply->str;
		break;
	}
	case REDIS_REPLY_NIL:
	{
		ret = "";
		break;
	}
	case REDIS_REPLY_INTEGER:
	{
		ret.Format("%lld", reply->integer);
		break;
	}
	default:
		break;
	}
	freeReplyObject(reply);
	return ret;
}
