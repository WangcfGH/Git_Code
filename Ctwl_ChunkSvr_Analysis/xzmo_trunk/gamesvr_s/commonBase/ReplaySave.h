#pragma once
#include <QUEUE>

#define UM_CLEAR_REPLAYFILE (WM_USER + 10001)
const char g_szIndexFile[] = "ReplayIndex.csv";

extern HANDLE g_hEventEndRecordReplay;
extern unsigned __stdcall RecordReplayThreadFunc(LPVOID lpVoid);

class CReplayRecord;
class CReplaySave
{
    enum { MAX_REPLAY_CACHE_NUM = 128}; // 缓存最大128，超出丢弃不存文件
    typedef std::vector<CReplayRecord*> ReplayVector;

public:
    CReplaySave();
    virtual ~CReplaySave();

    BOOL Initialize();
    BOOL Push(const CReplayRecord& stReplayRecord);

    BOOL WriteIndexFile(CString& strSavePath, CReplayRecord* pReplayRecord);
    void ComeDownRecordSaveSpace();
    int  GetCanSaveCount() const { return m_nCanSaveCount; }
    void RecordToLocalFile();
    void BuildSavePath();
    CString BuildDaySavePath();
    BOOL DeleteFiles(CString& strDeleteDay);

    BOOL CreateRecordThread();
    UINT GetThreadID() { return m_uiThread; }
private:
    ReplayVector m_vecReplayCache;
    int          m_nCacheCount;
    int          m_nCanSaveCount;
    CCritSec     m_csReplayCache;

    CString      m_strSaveMainPath;
    CString      m_strLastDeleteDay;

    UINT         m_uiThread;
};
