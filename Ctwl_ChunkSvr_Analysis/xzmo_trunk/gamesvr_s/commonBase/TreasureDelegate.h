#pragma once
#include "tcycomponents/TcyMsgCenter.h"
#include "plana/plana.h"

// ¸ÄÔì

class CCommonBaseTable;
class CTreasureDelegate
{
public:
    ImportFunctional<void(LPCONTEXT_HEAD, LPREQUEST)> imMsg2Chunk;
    // args:[sock,token,nRequest,pData,nLen, compressed=FALSE]
    ImportFunctional<BOOL(SOCKET, LONG, UINT, void*, int, BOOL)> imNotifyOneUser;

    void OnChunkClient(TcyMsgCenter* msgCenter);

    void OnCPGameStarted(CCommonBaseTable* table, void* pData);
    void OnCPStartSoloTable(START_SOLOTABLE* pStartSoloTable, CCommonBaseTable* table, void* pData);

    virtual void UpdateTreasureBount(CCommonBaseTable* pTable);
    virtual BOOL OnTreasureRet(LPCONTEXT_HEAD lpContext, LPREQUEST lpReqeust);

};

