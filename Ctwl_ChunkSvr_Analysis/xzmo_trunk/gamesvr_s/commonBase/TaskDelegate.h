#pragma once

class CTaskDelegate
{
public:
    ImportFunctional<void(LPCONTEXT_HEAD, LPREQUEST)> imMsg2Chunk;
    // args:[sock,token,nRequest,pData,nLen, compressed=FALSE]
    ImportFunctional<BOOL(SOCKET, LONG, UINT, void*, int, BOOL)> imNotifyOneUser;

    void OnChunkClient(TcyMsgCenter* msgCenter);

    virtual void UpdateTaskRecordAboutBout(LPCONTEXT_HEAD lpContext, CTable* pTable, void* pData);
    virtual void UpdateTaskRecordAboutBoutEx(LPCONTEXT_HEAD lpContext, CTable* pTable, void* pData);
    virtual void UpdateTaskRecordByAddParam(LPCONTEXT_HEAD lpContext, CTable* pTable, int nChairNO, int nType, int nValue = 1);

    virtual BOOL OnTaskParamRet(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);
    virtual BOOL OnTaskDataRet(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);

    virtual void UpdateLTaskRecordByAddParam(LPCONTEXT_HEAD lpContext, CTable* pTable, int nChairNO, int nType, int nValue = 1);

    virtual void UpdateCreateRoomTaskByPlayer(LPCONTEXT_HEAD lpContext, CTable* pTable);
};

