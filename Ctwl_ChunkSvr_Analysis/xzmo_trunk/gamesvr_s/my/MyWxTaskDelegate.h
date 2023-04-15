#pragma once

class CMyExWxTaskDelegate
{
public:
    // args:[int nUserId, tc::KPIClientData & data]
    ImportFunctional<BOOL(int, tc::KPIClientData&)> imGetKPIClientData;
    ImportFunctional<void(LPCONTEXT_HEAD, LPREQUEST)> imMsg2Chunk;

public:
    // 业务事件
    void OnCPOnGameStarted(CCommonBaseTable* pTable, void* pData);
    void OnCPStartSoloTable(START_SOLOTABLE* pStartSoloTable, CCommonBaseTable* pTable, void* pData);

    void OnWxTaskWinDeposit(LPCONTEXT_HEAD lpContext, CMyGameTable* pTable, int nUserID, int nChairNO);
    void OnWxTaskHu(LPCONTEXT_HEAD lpContext, CTable* pTable, int nChairNO);
protected:
    virtual void UpdateWxTaskRecordAboutBout(LPCONTEXT_HEAD lpContext, CTable* pTable, void* pData);
    virtual void UpdateWxTaskRecordByAddParam(LPCONTEXT_HEAD lpContext, CTable* pTable, int nChairNO, int nType, int nValue = 1);

};

