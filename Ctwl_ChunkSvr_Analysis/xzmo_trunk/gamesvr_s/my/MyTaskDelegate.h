#pragma once
class CMyExTaskDelegate 
{
public:
    ImportFunctional<void(LPCONTEXT_HEAD, LPREQUEST)> imMsg2Chunk;

public:
    // 业务事件
    void OnCPOnGameStarted(CCommonBaseTable* pTable, void* pData);
    void OnCPStartSoloTable(START_SOLOTABLE* pStartSoloTable, CCommonBaseTable* pTable, void* pData);

    void OnTaskWinDeposit(LPCONTEXT_HEAD lpContext, CMyGameTable* pTable, int nUserID, int nChairNO);
    void OnTaskPeng(LPCONTEXT_HEAD lpContext, CMyGameTable* pTable, int nUserID, int nChairNO, int nPengCardID);
    void OnTaskGang(LPCONTEXT_HEAD lpContext, CMyGameTable* pTable, int nUserID, int nChairNO, DWORD type);
    void OnTaskHu(LPCONTEXT_HEAD lpContext, CMyGameTable* pTable, int nUserID, int nChairNO, int nHuType, int nHuFan);

    void onTest(bool& next, std::string& cmd);

protected:
    // new task
    virtual void UpdateNewTaskRcordByAddParam(LPCONTEXT_HEAD lpContext, CTable* pTable, int nChairNO, int nType, int nValue = 1);
    virtual void UpdateNewTaskRecordAboutBout(LPCONTEXT_HEAD lpContext, CTable* pTable);
};

