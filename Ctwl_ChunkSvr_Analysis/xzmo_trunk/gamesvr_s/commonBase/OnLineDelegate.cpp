#include "stdafx.h"

COnLineDelegate::COnLineDelegate(CCommonBaseServer* pServer)
    : CModuleDelegate(pServer)
{

}


COnLineDelegate::~COnLineDelegate()
{

}

BOOL COnLineDelegate::OnUpdateOnLineData(int userID, int value)
{
	//CString strCommand;
	//CString strValue;
	//int nHour = GetPrivateProfileInt(_T("OnLine"), _T("RefreshHour"), 6, GetINIFileName());
	//int nDaySpan = 0;
	//SYSTEMTIME time;
	//GetLocalTime(&time);
	//if (nHour > time.wHour)
	//{
	//	nDaySpan = -1;
	//}
	//CTime t = CTime::GetCurrentTime();
	//if (0 < nDaySpan){
	//	t += CTimeSpan(nDaySpan, 0, 0, 0);
	//}
	//else{
	//	t -= CTimeSpan(-nDaySpan, 0, 0, 0);
	//}

	//int nCurrentDate = atoi(t.Format("%Y%m%d"));

	//strCommand.Format("HINCRBY OnLineConditionData:%d %d %d", nCurrentDate, userID, value);
	//CRedisMgr* redisMgr = m_pServer->GetRedisContext();
	//if (redisMgr)
	//{
	//	redisMgr->RedisCommand(strCommand);
	//}
	return TRUE;
}

void COnLineDelegate::OnUpdateOnLineDataWhenGameWin(CTable* pTable)
{
	if (!pTable) return;
	for (int i = 0; i < pTable->m_nTotalChairs; ++i)
	{
		CPlayer* ptrPlayer = pTable->m_ptrPlayers[i];
		if (ptrPlayer)
		{
			OnUpdateOnLineData(ptrPlayer->m_nUserID);
		}
	}
}