#pragma once
#include "../commonBase/SysMsgToServer.h"

class CMJServer;
class MJSysMsgToServer : public SysMsgToServer
{
public:
    MJSysMsgToServer(CMJServer* pMJServer)
        : SysMsgToServer(pMJServer), m_pMJServer(pMJServer)
    {}

protected:
    virtual void RegsiterSysMsgOpera() override;

protected:
    virtual BOOL OnSysMsg_GameLocalChi(SysMsgOperaPack* pack);
    virtual BOOL OnSysMsg_GameLocalPeng(SysMsgOperaPack* pack);
    virtual BOOL OnSysMsg_GameLocalMnGang(SysMsgOperaPack* pack);
    virtual BOOL OnSysMsg_GameLocalPnGang(SysMsgOperaPack* pack);
    virtual BOOL OnSysMsg_GameLocalAutoThrow(SysMsgOperaPack* pack);
    virtual BOOL OnSysMsg_GameLocalAutoCatch(SysMsgOperaPack* pack);

    virtual BOOL OnSysMsg_GamePlayerOnline(SysMsgOperaPack* pack);
    virtual BOOL OnSysMsg_GameAutoPlay(SysMsgOperaPack* pack);
    virtual BOOL OnSysMsg_GameCancelPlay(SysMsgOperaPack* pack);
protected:

    CMJServer* m_pMJServer;
};
