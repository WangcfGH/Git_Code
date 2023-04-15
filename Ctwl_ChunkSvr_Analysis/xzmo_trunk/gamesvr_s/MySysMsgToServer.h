#pragma once
#include "mj/MJSysMsgToServer.h"

class CMyGameServer;
class MySysMsgToServer : public MJSysMsgToServer
{
public:
    MySysMsgToServer(CMyGameServer* pServer) :
        MJSysMsgToServer(pServer), m_pMyServer(pServer)
    {
    }

protected:
    virtual void RegsiterSysMsgOpera() override;

protected:
    virtual BOOL OnSysMsg_AutoExchangeCards(SysMsgOperaPack* pack);
    virtual BOOL OnSysMsg_AutoGiveup(SysMsgOperaPack* pack);
    virtual BOOL OnSysMsg_AutoHu(SysMsgOperaPack* pack);
    virtual BOOL OnSysMsg_AutoGuo(SysMsgOperaPack* pack);

    virtual BOOL OnSysMsg_GameLocalPeng(SysMsgOperaPack* pack) override;
    virtual BOOL OnSysMsg_GameLocalMnGang(SysMsgOperaPack* pack) override;
    virtual BOOL OnSysMsg_GameLocalPnGang(SysMsgOperaPack* pack) override;
    virtual BOOL OnSysMsg_GameLocalAnGang(SysMsgOperaPack* pack) ;

    // xzmo add
    virtual BOOL OnSysMsg_GameLocalFixMiss(SysMsgOperaPack* pack);
private:
    CMyGameServer* m_pMyServer;
};

