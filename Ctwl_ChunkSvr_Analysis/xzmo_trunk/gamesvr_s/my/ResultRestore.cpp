#include "stdafx.h"
#include "ResultRestore.h"

void CResultRestore::OnPreResult(LPCONTEXT_HEAD lpContext, CMyGameTable* pTable, int roomid, int flag, int chairno, GAME_RESULT_EX *pGameResults, int nResultCount)
{
    if ((ResultByHu == flag && !pTable->IsXueLiuRoom()) ||
        ResultByGiveUp == flag)
    {
        for (int i = 0; i < nResultCount; i++)
        {
            if (pGameResults[i].nChairNO == chairno)
            {
                int nUniqueID = ((CMyGameTable*)pTable)->GetUniqueID();
                int nDeposit = pTable->m_stPreSaveInfo[chairno].nPreSaveAllDeposit;
                UpdateDepositRecord(lpContext, pTable, chairno, nUniqueID, nDeposit);
            }
        }
    }
}

void CResultRestore::OnGameWin(LPCONTEXT_HEAD lpContext, CRoom* pRoom, CTable* pTable, int chairno, BOOL bout_invalid, int roomid)
{
    /****************** Ìí¼Ó½áËãÃâÅâ¼ÇÂ¼ start ***************************/
    int nUniqueID = ((CMyGameTable*)pTable)->GetUniqueID();
    if (((CMyGameTable*)pTable)->IsXueLiuRoom())
    {
        for (int i = 0; i < pTable->m_nTotalChairs; i++)
        {
            if (((CMyGameTable*)pTable)->m_HuReady[i] != MJ_GIVE_UP)
            {
                int nDeposit = ((CMyGameTable*)pTable)->m_stPreSaveInfo[i].nPreSaveAllDeposit;
                UpdateDepositRecord(lpContext, pTable, i, nUniqueID, nDeposit);
            }
        }
    }
    else
    {
        for (int i = 0; i < pTable->m_nTotalChairs; i++)
        {
            DWORD dwHuReady = ((CMyGameTable*)pTable)->m_HuReady[i];
            if (dwHuReady == 0 || dwHuReady == MJ_HU_TING || dwHuReady == MJ_HU_HUAZHU || chairno == i)
            {
                int nDeposit = ((CMyGameTable*)pTable)->m_stPreSaveInfo[i].nPreSaveAllDeposit;
                UpdateDepositRecord(lpContext, pTable, i, nUniqueID, nDeposit);
            }
        }
    }
    /****************** Ìí¼Ó½áËãÃâÅâ¼ÇÂ¼ end ***************************/
}

void CResultRestore::UpdateDepositRecord(LPCONTEXT_HEAD lpContext, CTable* pTable, int nChairNO, int nUniqueID, int nDeposit /*= 1*/)
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

        //request chunkSvr
        ReqResultDepositSave reqInfo;
        memset(&reqInfo, 0, sizeof(reqInfo));
        reqInfo.nUserID = pPlayer->m_nUserID;
        reqInfo.nUniqueID = nUniqueID;
        reqInfo.nDeposit = nDeposit;

        REQUEST Request;
        memset(&Request, 0, sizeof(Request));
        Request.head.nRequest = GR_RESULT_DEPOSIT_SAVE;
        Request.pDataPtr = &reqInfo;
        Request.nDataLen = sizeof(reqInfo);
        Request.head.nRepeated = 0;
        LOG_DEBUG(_T("UpdateDepositRecord: userid: [%d], deposit[%d]"), reqInfo.nUserID, nDeposit);
        imMsg2Chunk.notify(lpContext, &Request);
    }
}

void CResultRestore::CleanDepositRecord(LPCONTEXT_HEAD lpContext, CTable* pTable)
{
    if (!pTable)
    {
        return;
    }

    ReqResultDepositClean reqInfo;
    memset(&reqInfo, 0, sizeof(reqInfo));
    for (int i = 0; i < pTable->m_nTotalChairs; i++)
    {
        CPlayer* pPlayer = pTable->m_ptrPlayers[i];
        if (pPlayer)
        {
            reqInfo.nUserID[i] = pPlayer->m_nUserID;
        }
    }

    REQUEST Request;
    memset(&Request, 0, sizeof(Request));
    Request.head.nRequest = GR_RESULT_DEPOSIT_CLEAN;
    Request.pDataPtr = &reqInfo;
    Request.nDataLen = sizeof(reqInfo);
    Request.head.nRepeated = 0;
    imMsg2Chunk.notify(lpContext, &Request);
}
