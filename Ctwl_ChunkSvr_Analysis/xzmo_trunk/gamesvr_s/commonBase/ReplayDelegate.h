#pragma once

class CReplayDelegate : public CModuleDelegate
{
public:
    CReplayDelegate(CCommonBaseServer* pServer);
    virtual ~CReplayDelegate();

    virtual void OnHourTriggered(int wHour); //ÿСʱ����һ��

    int GetMajorVersion() { return GetPrivateProfileInt(_T("clientversion"), _T("major"), 0, GetINIFileName()); }
    int GetMinorVersion() { return GetPrivateProfileInt(_T("clientversion"), _T("minor"), 0, GetINIFileName()); }

    // ¼���������
    BOOL IsReplayActive() { return GetPrivateProfileInt(_T("Replay"), _T("enable"), 0, GetINIFileName()) == 1; }
    BOOL IsReplayDefSave() { return GetPrivateProfileInt(_T("Replay"), _T("DefaultSave"), 0, GetINIFileName()); }
    BOOL IsRoomReplayActive(int nRoomID);

    // ¼����ؽӿ�
    virtual void SaveReplayTableInfo(CTable* pTable) = 0; //�齫���������ݲ�һ����������
    void SaveReplayHeadAndTableInfo(CTable* pTable);
    void SaveReplayHeadInfo(CTable* pTable);
    int  YQW_OpeSaveReplayData(CTable* pTable);
    BOOL RequestNeedRecord(UINT nRequest) { return TRUE; }   //¼�����Ϣ������Ҫ���⴦����
    // ¼�����ݴ������
    virtual void NotifyTableVisitors(CTable* pTable, UINT nRequest, void* pData, int nLen);
    virtual void OnCPOnGameStarted(CTable* pTable, void* pData);
    virtual void OnCPStartSoloTable(START_SOLOTABLE* pStartSoloTable, CTable* pTable, void* pData);
    virtual void OnCPDealReplayGameWinData(CTable* pTable, void* pData, int nLen);
    void YQW_OpeSaveGameWinData(CTable* pTable, UINT nRequest, void* _pData, int _nLen, LONG tokenExcept = 0, BOOL compressed = FALSE);
    virtual void OnGameWin(CTable* pTable);
    virtual int YQW_OpeSaveErrorReplayData(CTable* pTable, DWORD dwAbortFlag);
    virtual void FillupReplayInitialData(CTable* pTable) = 0;
};

