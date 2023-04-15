#pragma once

class CCommonBaseTable;
class CRobotPlayerDataDelegate
{
public:
    ImportFunctional<void(LPCONTEXT_HEAD, LPREQUEST)> imMsg2Chunk;

public:
    // 业务事件
    void OnCPGameWin(LPCONTEXT_HEAD lpContext, int roomid, CCommonBaseTable* pTable, void* pData);
    void OnPreResult(LPCONTEXT_HEAD lpContext, CMyGameTable* pTable, int roomid, int flag, int chairno, GAME_RESULT_EX *pGameResults, int nResultCount);
protected:
    virtual void UpdateRobotPlayerDataOnGameWin(CCommonBaseTable* pTable, void* pData);
    virtual void UpdateRobotPlayerData(CCommonBaseTable* pTable, int nChairNO, int nDepositDiff);
};