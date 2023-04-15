#include "stdafx.h"
#include "MyTaskDelegate.h"

void CMyExTaskDelegate::UpdateNewTaskRcordByAddParam(LPCONTEXT_HEAD lpContext, CTable* pTable, int nChairNO, int nType, int nValue /*= 1*/)
{
    if (!pTable)
    {
        return;
    }
    if (!pTable->ValidateChair(nChairNO))
    {
        return;
    }

    CPlayer* pPlayer = pTable->m_ptrPlayers[nChairNO];
    if (pPlayer)
    {
        lpContext->hSocket = pPlayer->m_hSocket;
        lpContext->lTokenID = pPlayer->m_lTokenID;

        CTime tTime = CTime::GetCurrentTime();

        //request chunkSvr
        REQTASKCHANGEPARAMS paramChange;
        memset(&paramChange, 0, sizeof(paramChange));
        paramChange.nUserID = pPlayer->m_nUserID;
        paramChange.nTypeID = nType;
        paramChange.nCount = nValue;
        paramChange.nDate = atoi(tTime.Format("%Y%m%d"));

        REQUEST Request;
        memset(&Request, 0, sizeof(Request));
        Request.head.nRequest = GR_TASK_CHANGE_PARAM_EX;
        Request.pDataPtr = &paramChange;
        Request.nDataLen = sizeof(paramChange);
        Request.head.nRepeated = 0;
        LOG_DEBUG(_T("UpdateNewTaskRcordByAddParam nUserID: %d, nTypeID: %d, nCount: %d"), paramChange.nUserID, nType, nValue);
        imMsg2Chunk.notify(lpContext, &Request);
    }
}

void CMyExTaskDelegate::UpdateNewTaskRecordAboutBout(LPCONTEXT_HEAD lpContext, CTable* pTable)
{
    if (!pTable)
    {
        return;
    }

    for (int i = 0; i < pTable->m_nTotalChairs; i++)
    {
        UpdateNewTaskRcordByAddParam(lpContext, pTable, i, NEW_TASK_TYPE_GAME_BOUT);
    }
}

void CMyExTaskDelegate::OnCPOnGameStarted(CCommonBaseTable* pTable, void* pData)
{
    LPCONTEXT_HEAD lpContext = new CONTEXT_HEAD;
    memset(lpContext, 0, sizeof(CONTEXT_HEAD));
    UpdateNewTaskRecordAboutBout(lpContext, pTable);
}

void CMyExTaskDelegate::OnCPStartSoloTable(START_SOLOTABLE* pStartSoloTable, CCommonBaseTable* pTable, void* pData)
{
    LPCONTEXT_HEAD lpContext = new CONTEXT_HEAD;
    memset(lpContext, 0, sizeof(CONTEXT_HEAD));
    UpdateNewTaskRecordAboutBout(lpContext, pTable);
}

void CMyExTaskDelegate::OnTaskWinDeposit(LPCONTEXT_HEAD lpContext, CMyGameTable* pTable, int nUserID, int nChairNO)
{
    if (!pTable)
    {
        return ;
    }
    int nWinDeposit = pTable->m_stPreSaveInfo[nChairNO].nPreSaveAllDeposit;
    if (nWinDeposit >= 0)
    {
        UpdateNewTaskRcordByAddParam(lpContext, pTable, nChairNO, NEW_TASK_TYPE_GAME_WIN_DEPOSIT, nWinDeposit);
    }
}

void CMyExTaskDelegate::OnTaskPeng(LPCONTEXT_HEAD lpContext, CMyGameTable* pTable, int nUserID, int nChairNO, int nPengCardID)
{
    if (!pTable)
    {
        return ;
    }

    UpdateNewTaskRcordByAddParam(lpContext, pTable, nChairNO, NEW_TASK_TYPE_GAME_PENG);
    return ;
}

void CMyExTaskDelegate::OnTaskGang(LPCONTEXT_HEAD lpContext, CMyGameTable* pTable, int nUserID, int nChairNO, DWORD type)
{
    if (!pTable)
    {
        return ;
    }
    if (type == MJ_GANG_AN)
    {
        UpdateNewTaskRcordByAddParam(lpContext, pTable, nChairNO, NEW_TASK_TYPE_GAME_GANG_XIA_YU);
    }
    else if (type == MJ_GANG_PN || type == MJ_GANG_MN)
    {
        UpdateNewTaskRcordByAddParam(lpContext, pTable, nChairNO, NEW_TASK_TYPE_GAME_GANG_GUA_FENG);
    }
    return ;
}

void CMyExTaskDelegate::OnTaskHu(LPCONTEXT_HEAD lpContext, CMyGameTable* pTable, int nUserID, int nChairNO, int nHuType, int nHuFan)
{
    if (!pTable)
    {
        return ;
    }
    if (!pTable->ValidateChair(nChairNO))
    {
        return ;
    }
    if (pTable->m_huDetails[nChairNO].nHuGains[HU_GAIN_SOUBAYI] > 0)
    {
        UpdateNewTaskRcordByAddParam(lpContext, pTable, nChairNO, NEW_TASK_TYPE_GAME_HU_DADANDIAO);
    }
    if (pTable->m_huDetails[nChairNO].nHuGains[HU_GAIN_7DUI] > 0)
    {
        UpdateNewTaskRcordByAddParam(lpContext, pTable, nChairNO, NEW_TASK_TYPE_GAME_HU_QIDUI);
    }
    if (pTable->m_huDetails[nChairNO].nHuGains[HU_GAIN_1CLR] > 0)
    {
        UpdateNewTaskRcordByAddParam(lpContext, pTable, nChairNO, NEW_TASK_TYPE_GAME_HU_QINGYISE);
    }
    if (pTable->m_huDetails[nChairNO].nHuGains[HU_GAIN_PNPN] > 0)
    {
        UpdateNewTaskRcordByAddParam(lpContext, pTable, nChairNO, NEW_TASK_TYPE_GAME_HU_PENGPENGHU);
    }
    if (pTable->m_huDetails[nChairNO].nHuGains[HU_GAIN_19] > 0)
    {
        UpdateNewTaskRcordByAddParam(lpContext, pTable, nChairNO, NEW_TASK_TYPE_GAME_HU_DAIYAOJIU);
    }
    if (pTable->m_huDetails[nChairNO].nHuGains[HU_GAIN_258] > 0)
    {
        UpdateNewTaskRcordByAddParam(lpContext, pTable, nChairNO, NEW_TASK_TYPE_GAME_HU_JIANGDUI);
    }
    if (MJ_HU_ZIMO == nHuType)
    {
        UpdateNewTaskRcordByAddParam(lpContext, pTable, nChairNO, NEW_TASK_TYPE_GAME_HU_ZIMO);
    }

    return ;
}

void CMyExTaskDelegate::onTest(bool& next, std::string& cmd)
{
    if (cmd == "TaskUpdate") {
        CONTEXT_HEAD Context = {0};
        CTime tTime = CTime::GetCurrentTime();
        REQTASKCHANGEPARAMS paramChange;
        memset(&paramChange, 0, sizeof(paramChange));
        paramChange.nUserID = 123456;
        paramChange.nTypeID = 1;
        paramChange.nCount = 1;
        paramChange.nDate = atoi(tTime.Format("%Y%m%d"));

        REQUEST Request;
        memset(&Request, 0, sizeof(Request));
        Request.head.nRequest = GR_TASK_CHANGE_PARAM_EX;
        Request.pDataPtr = &paramChange;
        Request.nDataLen = sizeof(paramChange);
        Request.head.nRepeated = 0;
        imMsg2Chunk.notify(&Context, &Request);
    }
}
