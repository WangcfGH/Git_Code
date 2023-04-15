#include "stdafx.h"
#include "MyWxTaskDelegate.h"

void CMyExWxTaskDelegate::OnCPOnGameStarted(CCommonBaseTable* pTable, void* pData)
{
    CONTEXT_HEAD context = {0};
    UpdateWxTaskRecordAboutBout(&context, pTable, pData);
}

void CMyExWxTaskDelegate::OnCPStartSoloTable(START_SOLOTABLE* pStartSoloTable, CCommonBaseTable* pTable, void* pData)
{
    CONTEXT_HEAD context = { 0 };
    UpdateWxTaskRecordAboutBout(&context, pTable, pData);
}

void CMyExWxTaskDelegate::OnWxTaskWinDeposit(LPCONTEXT_HEAD lpContext, CMyGameTable* pTable, int nUserID, int nChairNO)
{
    if (!pTable)
    {
        return;
    }
    int nWinDeposit = pTable->m_stPreSaveInfo[nChairNO].nPreSaveAllDeposit;
    LOG_TRACE("WxTask_Win, nUserID<%d>, winD<%d>, isxueliu<%d>", nUserID, nWinDeposit, pTable->IsXueLiuRoom());
    if (nWinDeposit >= 0)
    {
        UpdateWxTaskRecordByAddParam(lpContext, pTable, nChairNO, WXTASK_GAME_WIN_DEPOSIT, nWinDeposit);
    }
}

void CMyExWxTaskDelegate::OnWxTaskHu(LPCONTEXT_HEAD lpContext, CTable* pTable, int nChairNO)
{
    UpdateWxTaskRecordByAddParam(lpContext, pTable, nChairNO, WXTASK_HU_TIMES, 1);
}

void CMyExWxTaskDelegate::UpdateWxTaskRecordAboutBout(LPCONTEXT_HEAD lpContext, CTable* pTable, void* pData)
{
    if (!pTable)
    {
        return;
    }
    for (int i = 0; i < pTable->m_nTotalChairs; i++)
    {
        int nAddParamType = 0;
        CPlayer* pPlayer = pTable->m_ptrPlayers[i];
        if (pPlayer)
        {
            int nChairNo = pPlayer->m_nChairNO;
            nAddParamType = WXTASK_GAME_RESULT_LOSE;
            UpdateWxTaskRecordByAddParam(lpContext, pTable, nChairNo, nAddParamType);
            LOG_TRACE(_T("task UpdateWxTaskRecordAboutBout userID = %d "), pPlayer->m_nUserID);
        }
    }
}

void CMyExWxTaskDelegate::UpdateWxTaskRecordByAddParam(LPCONTEXT_HEAD lpContext, CTable* pTable, int nChairNO, int nType, int nValue)
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
    if (!pPlayer)
    {
        return;
    }
    tc::KPIClientData temp;
    imGetKPIClientData.notify(pPlayer->m_nUserID, temp);
    if (temp.pkgtype() != 300)
    {
        return;
    }

    lpContext->hSocket = pPlayer->m_hSocket;
    lpContext->lTokenID = pPlayer->m_lTokenID;

    int nUserType = pPlayer->m_nUserType;
    //request chunkSvr
    TASKPARAMCHANGE paramChange;
    memset(&paramChange, 0, sizeof(paramChange));
    paramChange.nUserID = pPlayer->m_nUserID;
    paramChange.nType = nType;
    paramChange.nValue = nValue;
    paramChange.bIsHandPhone = IS_BIT_SET(nUserType, UT_HANDPHONE);

    REQUEST Request;
    memset(&Request, 0, sizeof(Request));
    Request.head.nRequest = GR_WXTASK_CHANGE_PARAM;
    Request.pDataPtr = &paramChange;
    Request.nDataLen = sizeof(paramChange);
    Request.head.nRepeated = 0;
    imMsg2Chunk.notify(lpContext, &Request);
}