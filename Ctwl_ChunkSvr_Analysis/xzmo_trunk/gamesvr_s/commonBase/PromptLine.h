#pragma once
// 原混合在commonBase层的房间提示线功能


struct PromptComponent
{
    int  m_nRoomPromptLine;      //房间提示线  如果玩家的银子大于提示线  提示玩家去其他房间
};

class PromptSystem
{
public:
    ImportFunctional<void(const char*, const char*, int&)> imGetIniInt;
    // args:[sock,token,nRequest,pData,nLen, compressed=FALSE]
    ImportFunctional<BOOL(SOCKET, LONG, UINT, void*, int, BOOL)> imNotifyOneUser;

    void OnServerStart(BOOL& ret, TcyMsgCenter* msgCenter);
    void OnNewTable(CCommonBaseTable* table);

    virtual void    InitPromptLine(CCommonBaseTable* table);
    virtual void    ResetPromptLine(CCommonBaseTable* table);

    void OnCPEnterGameDXXW(LPCONTEXT_HEAD lpContext, int nRoomid, CCommonBaseTable* pTable, CPlayer* pPlayer);
};