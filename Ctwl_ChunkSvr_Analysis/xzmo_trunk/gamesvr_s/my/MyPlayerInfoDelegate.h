#pragma once
#include "stdafx.h"

class CMyExPlayerInfoDelegate
{
public:
    ImportFunctional<void(LPCONTEXT_HEAD, LPREQUEST)> imMsg2Chunk;
    // args:[roomid,tableno,bCreateIfNotExist=FALSE,nScoreMult=0]
    ImportFunctional < CGetTableResult(int, int, BOOL, int)> imGetTablePtr;
    // args:[LPCONTEXT_HEAD lpContext, BOOL bPassive = FALSE]
    ImportFunctional<BOOL(LPCONTEXT_HEAD, BOOL)> imNotifyResponseFaild;

    void OnChunkClient(TcyMsgCenter* msgCenter);

    virtual void QueryExPlayerInfoAboutBout(CTable* pTable);

    virtual void UpdateExPlayerInfoAboutBout(LPCONTEXT_HEAD lpContext, CTable* pTable, void* pData);
    virtual void UpdateExPlayerInfoByAddParam(LPCONTEXT_HEAD lpContext, CTable* pTable, int nChairNO, int nType, int nValue = 1);

    virtual BOOL OnExPlayerInfoParamRet(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);
    virtual BOOL OnExPlayerInfoParamChangeRet(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);

public:
    // ÒµÎñ´¥·¢
    void OnCPGameStarted(CCommonBaseTable* table, void* pData);
    void OnCPStartSoloTable(START_SOLOTABLE* pStartSoloTable, CCommonBaseTable* pTable, void* pData);
};