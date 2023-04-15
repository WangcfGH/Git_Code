#pragma once

class CMJReplayDelegate : public CReplayDelegate
{
public:
    CMJReplayDelegate(CCommonBaseServer* pServer);
    virtual ~CMJReplayDelegate();

    virtual void SaveReplayTableInfo(CTable* pTable);
    virtual void FillupReplayInitialData(CTable* pTable);
};

