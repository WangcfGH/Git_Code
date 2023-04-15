
#include "stdafx.h"
#include <string>

// add stl
#include <list>
#include <string>

#include "RedisMgrPool.h"


CRedisMgrPool::CRedisMgrPool()
{
	m_nPort = 0;
	m_nDBIndex = 0;
}


CRedisMgrPool::~CRedisMgrPool()
{
	UnInit();
}

BOOL CRedisMgrPool::Init(const std::string &strHost, const int &nPort, const int &nIndex, const std::string &strPwd, int nNum)
{
	UnInit();

	m_strHostIP = strHost;
	m_strPasswd = strPwd;
	m_nPort = nPort;
	m_nDBIndex = nIndex;

	for (int i = 0; i < nNum; ++i)
	{
		CRedisMgr *pContext = CreateRedisContext(strHost, nPort, nIndex, strPwd);
		if (NULL == pContext)
		{
			UnInit();
			return FALSE;
		}

		CAutoLock oAutoLock(&m_csListContextLock);
		m_oListReidsMgr.push_back(pContext);
	}

	return TRUE;
}

void CRedisMgrPool::UnInit()
{
	{
		CAutoLock oAutoLock(&m_csListContextLock);
		for (auto itr = m_oListReidsMgr.begin(); itr != m_oListReidsMgr.end(); ++itr)
		{
			CRedisMgr *pContest = *itr;
			if (NULL != pContest)
			{
				delete pContest;
			}
		}
		m_oListReidsMgr.clear();
	}

	{
		CAutoLock oAutoLock(&m_csMapContextLock);
		for (auto itr = m_mapReidsMgrByThreadID.begin(); itr != m_mapReidsMgrByThreadID.end(); ++itr)
		{
			CRedisMgr *pContest = itr->second;
			if (NULL != pContest)
			{
				delete pContest;
			}
		}
		m_mapReidsMgrByThreadID.clear();
	}
}

CRedisMgr * CRedisMgrPool::GetContext(const int &nWaitTime)
{
	DWORD threadID = GetCurrentThreadId();
	{
		CAutoLock oAutoLock(&m_csMapContextLock);
		if (m_mapReidsMgrByThreadID.find(threadID) != m_mapReidsMgrByThreadID.end())
		{
			return m_mapReidsMgrByThreadID.find(threadID)->second;
		}
	}

	ULONGLONG dwBeginTicket;
	if (INFINITE != nWaitTime)
	{
		dwBeginTicket = GetTickCount();
	}
	
	while (true)
	{
        {
            CAutoLock oAutoLock(&m_csListContextLock);
            if (m_oListReidsMgr.size() > 0)
            {
				CRedisMgr *pContext = m_oListReidsMgr.front();
                m_oListReidsMgr.pop_front();

				if (NULL == pContext)
				{
					pContext = TryNewContext();
				}
				{
					CAutoLock oAutoLock(&m_csMapContextLock);
					m_mapReidsMgrByThreadID.insert(std::pair<DWORD, CRedisMgr*>(threadID, pContext));
				}
                return pContext;
			}
			else
			{
				CRedisMgr *pContext = TryNewContext();
				{
					CAutoLock oAutoLock(&m_csMapContextLock);
					m_mapReidsMgrByThreadID.insert(std::pair<DWORD, CRedisMgr*>(threadID, pContext));
				}
				return pContext;
			}
        }

        Sleep(0);
        if (INFINITE != nWaitTime)
        {
            if (GetTickCount() - dwBeginTicket > nWaitTime)
            {
                break;
            }
        }
	}
	return NULL;
}

/*void CRedisMgrPool::GiveBackContext(CRedisMgr *pContext)
{
	//CAutoLock oAutoLock(&m_csListContextLock);
	//m_oListReidsMgr.push_front(pContext);
}*/

CRedisMgr * CRedisMgrPool::CreateRedisContext(const std::string &strHost, const int &nPort, const int &nIndex, const std::string &strPwd)
{
	CRedisMgr *pRedisMgr = new CRedisMgr();

	if (pRedisMgr->ConnectServer(strHost.c_str(), strPwd.c_str(), nPort, nIndex))
	{
		pRedisMgr->SelectDB();
	}
	else
	{
		return FALSE;
	}

	return pRedisMgr;
}

CRedisMgr * CRedisMgrPool::TryNewContext(CRedisMgr *pOldContext)
{
	if (NULL != pOldContext)
	{
		delete pOldContext;
	}

	CRedisMgr *pContext = CreateRedisContext(m_strHostIP, m_nPort, m_nDBIndex, m_strPasswd);

	return pContext;
}
