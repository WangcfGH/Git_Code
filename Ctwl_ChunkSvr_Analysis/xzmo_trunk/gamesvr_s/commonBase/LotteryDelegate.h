#pragma once
#include "tcycomponents/TcyMsgCenter.h"
#include "plana/plana.h"

class CCommonBaseTable;
class CLotteryDelegate
{
public:
    ImportFunctional<void(LPCONTEXT_HEAD, LPREQUEST)> imMsg2Chunk;
    // args:[sock,token,nRequest,pData,nLen, compressed=FALSE]
    ImportFunctional<BOOL(SOCKET, LONG, UINT, void*, int, BOOL)> imNotifyOneUser;
    // args:[int roomid, int tableno, CYQWGameData& game_data]
    ImportFunctional<BOOL(int, int, CYQWGameData&)> imYQW_LookupGameData;

    void YQW_OnCPGameWin(LPCONTEXT_HEAD lpContext, int nRoomId, CCommonBaseTable* pTable, void* pData);
    void OnCPGameWin(LPCONTEXT_HEAD lpContext, int nRoomId, CCommonBaseTable* pTable, void* pData);

    virtual void UpdateLotteryData(LPCONTEXT_HEAD lpContext, CTable* pTable);
    virtual void YQW_UpdateLotteryData(LPCONTEXT_HEAD lpContext, CTable* pTable);

    virtual void ChangeLotteryTaskProcess(LPCONTEXT_HEAD lpContext, CTable* pTable, int nChairNO, int nProcessType, int nProcessCount = 1);
    virtual void ChangeLotteryTaskProcessOnGameWin(LPCONTEXT_HEAD lpContext, CTable* pTable, void* pData);
    virtual void ChangeLotteryTaskProcessOnYQWGameWin(LPCONTEXT_HEAD lpContext, CTable* pTable, void* pData);

};

