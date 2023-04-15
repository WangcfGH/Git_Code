#pragma once
#include "tcycomponents/TcyMsgCenter.h"
#include <functional>
#include <unordered_map>

// 库中的SysMsgToServer 在SK/HW 层； 我们这里把它放在MJ层

class CCommonBaseTable;
class CCommonBaseServer;
struct SysMsgOperaPack
{
    LPCONTEXT_HEAD lpContext;
    LPREQUEST lpRequest;
    GAME_MSG* pMsg;
    BYTE* pData;
    USER_DATA* user_data;

    BOOL bPassive;

    int roomid;
    int tableno;
    int userid;
    int chairno;

    CRoom* pRoom;
    CCommonBaseTable* pTable;
    CPlayer* pPlayer;
};

class SysMsgToServer
{
public:
    using SysMsgOperation = std::function<BOOL(SysMsgOperaPack*)>;

    SysMsgToServer(CCommonBaseServer* pServer) : m_pServer(pServer) {}

    void OnServerStart(BOOL& ret, TcyMsgCenter* msgCenter);

protected:
    virtual void RegsiterSysMsgOpera();

    virtual BOOL OnSendSysMsgToServer(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);

    virtual BOOL GameMsgCheck(GAME_MSG* pMsg);

    virtual BOOL NotifyTableMsg(CTable* pTable, int nDest, int nMsgID, int datalen = 0, void* data = NULL, LONG tokenExcept = 0);
    virtual BOOL NotifyPlayerMsgAndResponse(LPCONTEXT_HEAD lpContext, CTable* pTable, int nDest, DWORD dwFlags, DWORD datalen = 0, void* data = NULL);
protected:
    virtual BOOL OnSysMsg_GameClockStop(SysMsgOperaPack* pack);
    virtual BOOL OnSysMsg_PlayerOnline(SysMsgOperaPack* pack);
    virtual BOOL OnSysMsg_GameOnAutoPlay(SysMsgOperaPack* pack);
    virtual BOOL OnSysMsg_GameCancelAutoPlay(SysMsgOperaPack* pack);
    virtual BOOL OnSysMsg_ModuleMsgVoice(SysMsgOperaPack* pack);
protected:
    CCommonBaseServer* m_pServer;
    std::unordered_map<UINT, SysMsgOperation> m_msgid2Opera;
};

