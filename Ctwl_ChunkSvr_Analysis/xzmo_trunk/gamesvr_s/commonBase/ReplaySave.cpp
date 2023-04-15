#include "StdAfx.h"

HANDLE g_hEventEndRecordReplay;

CReplaySave::CReplaySave()
    : m_nCacheCount(0)
    , m_uiThread(0)
    , m_nCanSaveCount(0)
{
}

CReplaySave::~CReplaySave()
{
    ::SetEvent(g_hEventEndRecordReplay);

    {
        CAutoLock lock(&m_csReplayCache);
        while (!m_vecReplayCache.empty())
        {
            CReplayRecord* pReplayRecord = m_vecReplayCache.back();
            if (pReplayRecord)
            {
                delete pReplayRecord;
                pReplayRecord = NULL;
            }

            m_vecReplayCache.pop_back();
        }
    }
}

BOOL CReplaySave::Initialize()
{
    BuildSavePath();

    BOOL bRet = CreateRecordThread();
    return bRet;
}

void CReplaySave::BuildSavePath()
{
    TCHAR szFilePath[MAX_PATH];
    GetModuleFileName(NULL, szFilePath, MAX_PATH);

    TCHAR* p = strrchr(szFilePath, '\\');
    if (p)
    {
        *p = 0;
    }
    m_strSaveMainPath.Format(_T("%s\\Replay\\"), szFilePath);

    BuildDataDirectory(m_strSaveMainPath);
}

CString CReplaySave::BuildDaySavePath()
{
    CString strSavePath(m_strSaveMainPath);

    CTime timeNow = CTime::GetCurrentTime();
    CString strDay;
    strDay.Format(_T("%04d%02d%02d\\")
        , timeNow.GetYear()
        , timeNow.GetMonth()
        , timeNow.GetDay());
    strSavePath += strDay;

    BuildDataDirectory(strSavePath);

    return strSavePath;
}

BOOL CReplaySave::Push(const CReplayRecord& stReplayRecord)
{
    CAutoLock lock(&m_csReplayCache);

    if (m_nCacheCount < MAX_REPLAY_CACHE_NUM)
    {
        CReplayRecord* pReplayRecord = new CReplayRecord(stReplayRecord);
        if (pReplayRecord)
        {
            m_vecReplayCache.push_back(pReplayRecord);
            ++m_nCacheCount;
        }

        return TRUE;
    }
    return FALSE;
}

void CReplaySave::ComeDownRecordSaveSpace()
{
    CAutoLock lock(&m_csReplayCache);

    ReplayVector::reverse_iterator iter = m_vecReplayCache.rbegin();
    for (; iter != m_vecReplayCache.rend(); iter++)
    {
        CReplayRecord* pReplayRecord = (CReplayRecord*)(*iter);
        if (pReplayRecord && pReplayRecord->ComeDownSaveSpace())
        {
            ++m_nCanSaveCount;
        }
    }
}

void CReplaySave::RecordToLocalFile()
{
    CAutoLock lock(&m_csReplayCache);

    ReplayVector::reverse_iterator iter = m_vecReplayCache.rbegin();
    for (; iter != m_vecReplayCache.rend(); iter++)
    {
        CReplayRecord* pReplayRecord = (CReplayRecord*)(*iter);
        if (!pReplayRecord || !pReplayRecord->ReachSaveTime())
        {
            continue;
        }

        if (pReplayRecord->NeedSave())
        {
            //          //本地的文件就不存了，他们说hold不住
            //          CString strSavePath = BuildDaySavePath();
            //          if (pReplayRecord->WriteToFile(strSavePath))
            //          {
            //              WriteIndexFile(strSavePath, pReplayRecord);
            //          }
        }

        m_vecReplayCache.erase((++iter).base());
        --m_nCacheCount;
        --m_nCanSaveCount;

        delete pReplayRecord;

        break;
    }
}

BOOL CReplaySave::WriteIndexFile(CString& strSavePath, CReplayRecord* pReplayRecord)
{
    CString strFileName(strSavePath);
    strFileName.TrimRight('\\');
    strFileName += '\\';
    strFileName += g_szIndexFile;

    try
    {
        BOOL bAddTitle = TRUE;
        if (IsFileExistEx(strFileName))
        {
            bAddTitle = FALSE;
        }

        CStdioFile file;
        if (!file.Open(strFileName, CFile::modeCreate | CFile::modeNoTruncate | CFile::modeWrite | CFile::shareDenyNone))
        {
            UwlLogFile("ReplaySave modle error, cannot open index data file.");
            return FALSE;
        }

        CString strText;
        if (bAddTitle)
        {
            strText.Format(_T("UserID1,IsReporter,UserID2,IsReporter,UserID3,IsReporter,UserID4,IsReporter,FileName\n"));
            file.WriteString(strText);
        }
        strText.Empty();

        CString strUserInfo;
        LPREP_YQWPLAYER pRepPlayer = (LPREP_YQWPLAYER)pReplayRecord->GetPlayerInfo();
        for (int i = 0; i < TOTAL_CHAIRS; i++)
        {
            strUserInfo.Format(_T("%d,%d"), pRepPlayer->nUserID, pRepPlayer->nReserved[0]);
            strText += strUserInfo;
            strText += ',';

            ++pRepPlayer;
        }

        CString strReplayFile = pReplayRecord->GetFileName();
        strText += strReplayFile;
        strText += "\n";

        file.SeekToEnd();
        file.WriteString(strText);

        file.Close();
    }
    catch (...)
    {
        UwlLogFile("ReplaySave modle error, write index data file failed.");
        return FALSE;
    }
    return TRUE;
}

BOOL CReplaySave::DeleteFiles(CString& strDeleteDay)
{
    if (0 == strDeleteDay.Compare(m_strLastDeleteDay))
    {
        return FALSE;
    }

    CString strPath(m_strSaveMainPath);
    strPath.TrimRight('\\');
    strPath += '\\';
    strPath += strDeleteDay;

    try
    {
        if (DeleteDirectory(strPath.GetBuffer(0)))
        {
            m_strLastDeleteDay = strDeleteDay;
            return TRUE;
        }
    }
    catch (...)
    {
        UwlLogFile(_T("ReplaySave model error, DeleteDirectory failed!"));
        return FALSE;
    }

    return FALSE;
}

BOOL CReplaySave::CreateRecordThread()
{
    g_hEventEndRecordReplay = ::CreateEvent(NULL, TRUE, FALSE, NULL);
    if (NULL == g_hEventEndRecordReplay)
    {
        UwlLogFile(_T("g_hEventEndRecordReplay is NULL!"));
        return FALSE;
    }

    HANDLE hThread = (HANDLE)::_beginthreadex(NULL, 0, RecordReplayThreadFunc, this, 0, &m_uiThread);
    if (NULL == hThread)
    {
        UwlLogFile(_T("CreateRecordReplayThread _beginthreadex failed!"));
        return FALSE;
    }

    return TRUE;
}

unsigned __stdcall RecordReplayThreadFunc(LPVOID lpVoid)
{
    UwlLogFile(_T("Record replay thread start."));

    CReplaySave* pReplayRecord = (CReplaySave*)lpVoid;
    DWORD dwInterval = 0;
    for (;;)
    {
        DWORD dwRst = ::WaitForSingleObject(g_hEventEndRecordReplay, 100);
        if (dwRst == WAIT_TIMEOUT)
        {
            dwInterval += 100;

            MSG msg;
            memset(&msg, 0, sizeof(msg));
            if (PeekMessage(&msg, NULL, 0, 0, PM_NOREMOVE))
            {
                if (0 == GetMessage(&msg, NULL, 0, 0))
                {
                    return (int)msg.wParam;
                }

                if (UM_CLEAR_REPLAYFILE == msg.message)
                {
                    int nSaveDay = msg.wParam;
                    CTime timeNow = CTime::GetCurrentTime();
                    CTimeSpan timeSpan = CTimeSpan(nSaveDay, 0, 0, 0);
                    CTime timeToDelete = timeNow - timeSpan;
                    CString strDeleteDay;
                    strDeleteDay.Format(_T("%04d%02d%02d")
                        , timeToDelete.GetYear()
                        , timeToDelete.GetMonth()
                        , timeToDelete.GetDay());

                    pReplayRecord->DeleteFiles(strDeleteDay);
                }
                else
                {
                    TranslateMessage(&msg);
                    DispatchMessage(&msg);
                }
            }
            else
            {
                if (dwInterval >= 1000)
                {
                    dwInterval = 0;
                    pReplayRecord->ComeDownRecordSaveSpace();
                }

                if (pReplayRecord->GetCanSaveCount() > 0)
                {
                    pReplayRecord->RecordToLocalFile();
                }
            }
        }
        else
        {
            break;
        }
    }

    UwlLogFile("Record replay thread end.");
    return 0;
}

