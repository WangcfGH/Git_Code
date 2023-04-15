#pragma once
class CResultRestore
{
public:
    ImportFunctional<void(LPCONTEXT_HEAD, LPREQUEST)> imMsg2Chunk;

public:
    // 业务事件
    void OnPreResult(LPCONTEXT_HEAD lpContext, CMyGameTable* pTable, int roomid, int flag, int chairno, GAME_RESULT_EX *pGameResults, int nResultCount);

    void OnGameWin(LPCONTEXT_HEAD lpContext, CRoom* pRoom, CTable* pTable, int chairno, BOOL bout_invalid, int roomid);

protected:
    void UpdateDepositRecord(LPCONTEXT_HEAD lpContext, CTable* pTable, int nChairNO, int nUniqueID, int nDeposit /*= 1*/);

    void CleanDepositRecord(LPCONTEXT_HEAD lpContext, CTable* pTable);
};

