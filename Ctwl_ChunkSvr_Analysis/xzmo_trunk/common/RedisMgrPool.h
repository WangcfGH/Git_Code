#pragma once

#include <list>
#include "tcRedis.h"

class CRedisMgrPool
{
public:
	CRedisMgrPool();
	~CRedisMgrPool();
	BOOL Init(const std::string &strHost, const int &nPort, const int &nIndex, const std::string &strPwd, int nNum);
	void UnInit();
	CRedisMgr *GetContext(const int &nWaitTime = INFINITE);
	//void GiveBackContext(CRedisMgr *pContext);
	CRedisMgr *TryNewContext(CRedisMgr *pOldContext = NULL);
private:
	CRedisMgr *CreateRedisContext(const std::string &strHost, const int &nPort, const int &nIndex, const std::string &strPwd);
private:
	std::list<CRedisMgr*> m_oListReidsMgr;
	CCritSec m_csListContextLock;
	std::map<DWORD, CRedisMgr*> m_mapReidsMgrByThreadID;
	CCritSec m_csMapContextLock;
	std::string	 m_strHostIP;
	std::string	 m_strPasswd;
	int m_nPort;
	int m_nDBIndex;

};

