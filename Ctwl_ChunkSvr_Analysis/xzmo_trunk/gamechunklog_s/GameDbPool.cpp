#include "stdafx.h"
#include "GameDbPool.h"



DBConnectEntry::DBConnectEntry(GameDbPool* pool) :PoolEntry(pool)
{
	
}

void DBConnectEntry::enterThread()
{
    mysql_connect();
	MysqlConnector::beginThread();
}

void DBConnectEntry::leaveThread()
{
	pCon.reset();
	MysqlConnector::endThread();
}

//////////////////////////////////////////////////////////////////////////
GameDbPool::GameDbPool(int nthread/* = 8*/) :DBConnectPool(nthread)
{
	ZeroMemory(&m_dbInfo, sizeof(m_dbInfo));
}

GameDbPool::~GameDbPool()
{
}

void GameDbPool::start(int n /* = 8 */)
{
	ReadGameChunkDBConfig();

	__super::start(n);
}

std::shared_ptr<ThreadEntryBase> GameDbPool::createThreadEntry()
{
	auto entry = std::make_shared<DBConnectEntry>(this);
    entry->mysql_set_connectInfo(m_dbInfo.szSource, m_dbInfo.szUserName, m_dbInfo.szPassword, m_dbInfo.szCatalog);
	return entry;
}

BOOL GameDbPool::ReadGameChunkDBConfig()
{
	TCHAR szFullName[MAX_PATH];
	GetModuleFileName(GetModuleHandle(NULL), szFullName, sizeof(szFullName));

	TCHAR			szDBAFile[MAX_PATH];
	UwlSplitPath(szFullName, SPLIT_DRIVE_DIR, szDBAFile);
	lstrcat(szDBAFile, _T("dbaccount.dba"));
	m_dbaFile = szDBAFile;

	int dbCount = 0;
	imIniInt("chunklogdb", "count", dbCount);

	TCHAR szKey[32];
	TCHAR szValue[256];
	TCHAR *p1, *p2;
	TCHAR *fields[32];
	memset(fields, 0, sizeof(fields));
	memset(szKey, 0, sizeof(szKey));
	memset(szValue, 0, sizeof(szValue));
	m_dbInfo.nID = -1;
	m_dbIndex = -1;
	for (int i = 0; i < dbCount; ++i)
	{
		_snprintf_s(szKey, sizeof(szKey), sizeof(szKey) - 1, _T("CD%d"), i);
		std::string value;
		imIniStr("chunklogdb", szKey, value);
		if (value.empty()) {
			continue;
		}
		memcpy(szValue, value.data(), sizeof(szValue));
		p1 = szValue;
		xyRetrieveFields(p1, fields, 8, &p2);
		lstrcpy(m_dbInfo.szName, fields[1]);
		if (0 != lstrcmpi(m_dbInfo.szName, NAME_CHUNKDB_LOG)) {
			continue;
		}
		m_dbInfo.nID = atoi(fields[0]);
		lstrcpy(m_dbInfo.szSource, fields[2]);
		lstrcpy(m_dbInfo.szCatalog, fields[3]);
		//调试时可直接读写配置文件中的账号密码
#ifdef _DEBUG
		lstrcpy(m_dbInfo.szUserName, fields[4]);
		lstrcpy(m_dbInfo.szPassword, fields[5]);
#endif
#ifdef _RS125
		lstrcpy(m_dbInfo.szUserName, fields[4]);
		lstrcpy(m_dbInfo.szPassword, fields[5]);
#endif
		m_dbInfo.nSecurityMode = atoi(fields[6]);
		m_dbIndex = i;
		break;
	}
	//正式发布时ReleaseS版本，需要读写加密dba文件中的账号密码
#ifndef _DEBUG
#ifndef _RS125
	FillGameDBAccount();
#endif
#endif

	if (m_dbInfo.nID == -1) {
		throw std::exception("no game db info");
	}
	return TRUE;
}

void GameDbPool::FillGameDBAccount()
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

	BOOL bFind = FALSE;
	if (dwRead >= (sizeof(DB_ACCOUNT_HEADER) + pDBAHeader->nCount*sizeof(DB_ACCOUNT)))
	{
		DB_ACCOUNT* pDA = (DB_ACCOUNT*)pByte;
		for (int i = 0; i < pDBAHeader->nCount; i++)
		{
			if (pDA->nDBIndex < MAX_TOTALDB_COUNT&&pDA->nDBIndex >= 0)
			{
				if (m_dbIndex == pDA->nDBIndex) {
					lstrcpyn(m_dbInfo.szUserName, pDA->szUserName, MAX_USERNAME_LEN);
					lstrcpyn(m_dbInfo.szPassword, pDA->szPassword, MAX_PASSWORD_LEN);
					bFind = TRUE;
					break;
				}
			}

			pDA++;
		}
	}

	SAFE_DELETE_ARRAY(pDecryptData);

	if (!bFind) {
		throw std::exception("no game db info with Decrypt");
	}
}
