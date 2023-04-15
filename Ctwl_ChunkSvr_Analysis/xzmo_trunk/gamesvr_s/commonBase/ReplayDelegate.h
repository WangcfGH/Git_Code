#pragma once

class CReplayDelegate : public CModuleDelegate
{
public:
    CReplayDelegate(CCommonBaseServer* pServer);
    virtual ~CReplayDelegate();

    virtual void OnHourTriggered(int wHour); //每小时触发一次

    int GetMajorVersion() { return GetPrivateProfileInt(_T("clientversion"), _T("major"), 0, GetINIFileName()); }
    int GetMinorVersion() { return GetPrivateProfileInt(_T("clientversion"), _T("minor"), 0, GetINIFileName()); }

    // 录像相关配置
    BOOL IsReplayActive() { return GetPrivateProfileInt(_T("Replay"), _T("enable"), 0, GetINIFileName()) == 1; }
    BOOL IsReplayDefSave() { return GetPrivateProfileInt(_T("Replay"), _T("DefaultSave"), 0, GetINIFileName()); }
    BOOL IsRoomReplayActive(int nRoomID);

    // 录像相关接口
    virtual void SaveReplayTableInfo(CTable* pTable) = 0; //麻将跟跑牌数据不一样自行重载
    void SaveReplayHeadAndTableInfo(CTable* pTable);
    void SaveReplayHeadInfo(CTable* pTable);
    int  YQW_OpeSaveReplayData(CTable* pTable);
    BOOL RequestNeedRecord(UINT nRequest) { return TRUE; }   //录像的消息过滤需要特殊处理下
    // 录像数据处理相关
    virtual void NotifyTableVisitors(CTable* pTable, UINT nRequest, void* pData, int nLen);
    virtual void OnCPOnGameStarted(CTable* pTable, void* pData);
    virtual void OnCPStartSoloTable(START_SOLOTABLE* pStartSoloTable, CTable* pTable, void* pData);
    virtual void OnCPDealReplayGameWinData(CTable* pTable, void* pData, int nLen);
    void YQW_OpeSaveGameWinData(CTable* pTable, UINT nRequest, void* _pData, int _nLen, LONG tokenExcept = 0, BOOL compressed = FALSE);
    virtual void OnGameWin(CTable* pTable);
    virtual int YQW_OpeSaveErrorReplayData(CTable* pTable, DWORD dwAbortFlag);
    virtual void FillupReplayInitialData(CTable* pTable) = 0;
};

