#pragma once

class FlauntBoutModule
{
public:
    ImportFunctional<void(LPCONTEXT_HEAD, LPREQUEST)> imMsg2Chunk;

    void OnCPGameWin(LPCONTEXT_HEAD lpContext, int nRoomId, CCommonBaseTable* pTable, void* pData);
};