#pragma once

class CCommonBaseTable;
class CRankMatchDelegate
{
public:
    // args:[userid,yqw_player]
    ImportFunctional<BOOL((int, YQW_PLAYER))> imYQW_LookupPlayer;
    ImportFunctional<void(LPCONTEXT_HEAD, LPREQUEST)> imMsg2Chunk;
    // arg1:roomid
    ImportFunctional<BOOL(int)> imIsYQWRoom;
    // args:[userid,solo_player]
    ImportFunctional<int(int, SOLO_PLAYER&)> imLookupSoloPlayer;

public:
    void YQW_CloseSoloTable(CCommonBaseTable* pTable, int roomid, DWORD dwAbortFlag);

protected:
    virtual void YQW_AddRankMatchScore(LPCONTEXT_HEAD lpContext, CTable* pTable);

    virtual void ChangeRankMatchParam(LPCONTEXT_HEAD lpContext, int userID, int paramValue, BOOL needUpdateName = FALSE);
};

