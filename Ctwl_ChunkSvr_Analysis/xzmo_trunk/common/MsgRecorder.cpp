#include "StdAfx.h"

ULONGLONG CMsgRecorder::GetCurrentTimestamp()
{
    SYSTEMTIME st = {0};
    GetLocalTime(&st);
    FILETIME ft = {0};
    SystemTimeToFileTime(&st, &ft);
    ULARGE_INTEGER uli = {ft.dwLowDateTime, ft.dwHighDateTime};
    return uli.QuadPart;
}

std::string CMsgRecorder::GetFormatDataTime(ULONGLONG ts)
{
    ULARGE_INTEGER uli = {0};
    uli.QuadPart = ts;
    FILETIME ft = {uli.LowPart, uli.HighPart};
    SYSTEMTIME st = {0};
    FileTimeToSystemTime(&ft, &st);

    char buff[32] = {0};
    sprintf_s(buff, "%04d-%02d-%02d %02d:%02d:%02d.%03d",
        st.wYear, st.wMonth, st.wDay, st.wHour, st.wMinute, st.wSecond, st.wMilliseconds);

    return buff;
}

ULONGLONG CMsgRecorder::GetData(ULONGLONG ts)
{
    ULARGE_INTEGER uli = { 0 };
    uli.QuadPart = ts;
    FILETIME ft = { uli.LowPart, uli.HighPart };
    SYSTEMTIME st = { 0 };
    FileTimeToSystemTime(&ft, &st);
    if (m_nModel == MSGRECORD_MODE_DAY)
    {
        return (ULONGLONG)(st.wYear * 10000 + st.wMonth * 100 + st.wDay);
    }
    else if (m_nModel == MSGRECORD_MODE_HOUR)
    {
        return (ULONGLONG)(st.wYear * 10000 + st.wMonth * 100 + st.wDay) * 100 + st.wHour;
    }
    else if (m_nModel == MSGRECORD_MODE_HOUR2)
    {
        return (ULONGLONG)(st.wYear * 10000 + st.wMonth * 100 + st.wDay) * 10000 + (st.wHour / 2 * 2) * 100 + (st.wHour / 2 * 2 + 1);
    }
    else
    {
        return 0;
    }
}

BOOL CMsgRecorder::CreateMsgRecorderThread()
{
    m_hThreadMsgRecorder = (HANDLE)_beginthreadex(NULL,             // Security
            0,                          // Stack size - use default
            MsgRecorderThreadFunc,      // Thread fn entry point
            (void*) this,               // Param for thread
            0,                          // Init flag
            &m_uiThreadMsgRecorder);    // Thread address;
    if (0 == m_hThreadMsgRecorder)
    {
        printf("start MsgRecorder thread failed\n");
        CloseHandle(m_hThreadMsgRecorder);
        return FALSE;
    }
    return TRUE;
}

unsigned __stdcall CMsgRecorder::MsgRecorderThreadFunc(LPVOID lpVoid)
{
    CMsgRecorder* pThread = (CMsgRecorder*)lpVoid;

    return pThread->MsgRecorderThreadProc();
}

unsigned CMsgRecorder::MsgRecorderThreadProc()
{
    UwlTrace(_T("CMsgRecorder Thread Started. ID = %d"), GetCurrentThreadId());
    UwlLogFile(_T("CMsgRecorder Thread Started. ID = %d"), GetCurrentThreadId());


    MSG msg;
    memset(&msg, 0, sizeof(msg));
    while (GetMessage(&msg, 0, 0, 0))
    {
        // 消息处理
        if (UM_DATA_TOSEND == msg.message)
        {
            LPMSG_RECORDER pRecorder = LPMSG_RECORDER(msg.wParam);
            BOOL recordOK = MsgServerResponse(pRecorder);
            if (!recordOK)
            {
                UwlTrace(_T("MsgServerResponse is return false"));
            }

            SAFE_DELETE(pRecorder);
        }
        else
        {
            DispatchMessage(&msg);
        }
    }

    return 0;
}
void CMsgRecorder::OnClientRequest(SOCKET sock, int request_id, int user_id, int game_id, int session_id)
{
    if (!m_bEnable)
    {
        return;
    }

    CAutoLock lock(&_mutex);

    while (_set.size() >= _limit)
    {
        recorder_set_itor itor = _set.begin();
        _map.erase(itor->second);
        _set.erase(itor);
    }

    {
        recorder_map_itor itor = _map.find(sock);
        if (itor != _map.end())
        {
            ULONGLONG ts = itor->second.first;
            _map.erase(itor);
            _set.erase(std::make_pair(ts, sock));
        }
    }

    ULONGLONG ts = GetCurrentTimestamp();
    MSG_RECORD msg_record = { request_id, user_id, game_id, session_id };
    _map.insert(std::make_pair(sock, std::make_pair(ts, msg_record)));
    _set.insert(std::make_pair(ts, sock));
}


void CMsgRecorder::OnServerResponse(SOCKET sock, int response_id, int session_id, int nTheardId, int nListCount)
{
    if (!m_bEnable)
    {
        return;
    }
    LPMSG_RECORDER pRecorder = new MSG_RECORDER;
    pRecorder->hSocket = sock;
    pRecorder->response_id = response_id;
    pRecorder->session_id = session_id;
    pRecorder->nThread_id = nTheardId;
    pRecorder->nListCount = nListCount;
    if (!PostThreadMessage(m_uiThreadMsgRecorder, UM_DATA_TOSEND, (WPARAM)pRecorder, 0))
    {
        UwlTrace(_T("!!!!!!!!!!CMsgRecorder PostThreadMessage  failed"));
        UwlLogFile(_T("!!!!!!!!CMsgRecorder PostThreadMessage  failed"));
        SAFE_DELETE(pRecorder);
    }

}

BOOL CMsgRecorder::MsgServerResponse(LPMSG_RECORDER pRecorder)
{
    ULONGLONG ts2 = GetCurrentTimestamp();

    MSG_RECORD msg_record = { 0 };
    ULONGLONG ts = 0;
    {
        CAutoLock lock(&_mutex);

        recorder_map_itor itor = _map.find(pRecorder->hSocket);
        if (itor == _map.end())
        {
            return FALSE;
        }

        ts = itor->second.first;
        msg_record = itor->second.second;
        _map.erase(itor);
        _set.erase(std::make_pair(ts, pRecorder->hSocket));
    }


    if (msg_record.session_id != pRecorder->session_id)
    {
        return FALSE;
    }
    std::stringstream sout;
    sout << msg_record.request_id << ","
        << msg_record.user_id << ","
        << msg_record.game_id << ","
        << GetFormatDataTime(ts) << ","
        << GetFormatDataTime(ts2) << ","
        << (unsigned int)((ts2 - ts) / 10000) << ","
        << msg_record.session_id << ","
        << pRecorder->response_id << ","
        << pRecorder->nListCount;
    {
        CAutoLock lock(&_mutex);
        OnWriteLog(sout.str().c_str(), pRecorder->nThread_id);
    }
    return TRUE;
}

int CMsgRecorder::getInterval()
{
    return m_nModel;
}


void CMsgRecorder::setEnable(BOOL enable)
{
    m_bEnable = enable;
}

void CMsgRecorder::OnHourTriggered(int wHour)
{
    int nEnable = GetPrivateProfileInt(_T("MsgRecorder"), _T("enable"), 0, GetINIFileName());
    if (nEnable)
    {
        setEnable(TRUE);
    }
    else
    {
        setEnable(FALSE);
    }

    int nRecordInterval = GetPrivateProfileInt(_T("MsgRecorder"), _T("interval"), 0, GetINIFileName());
    int nIntervalBefore = getInterval();
    if (nRecordInterval != nIntervalBefore)
    {
        setInterval(nRecordInterval);
    }

}

void CMsgRecorder::setInterval(int model)
{
    m_nModel = model;
}

void CMsgRecorder::OnWriteLog(const char* log, int threadId)
{
    ULONGLONG ts = GetCurrentTimestamp();

    char sfile[MAX_PATH];

    TCHAR szFilePath[MAX_PATH];
    GetModuleFileName(NULL, szFilePath, MAX_PATH);
    *strrchr(szFilePath, '\\') = 0;

    sprintf_s(sfile, "%s\\msglog_%I64d.log", szFilePath, GetData(ts));

    std::stringstream ssline;
    ssline << GetFormatDataTime(ts) << ","
        << threadId << ",DEBUG";

    FILE* pf = NULL;
    fopen_s(&pf, sfile, "a");
    if (pf)
    {
        fprintf(pf, "%s,%s\n", ssline.str().c_str(), log);
        fclose(pf);
    }
}

CMsgRecorder::CMsgRecorder(unsigned int _l, int _m) : _limit(_l), _mode(_m)
{
    m_hThreadMsgRecorder = NULL;
    m_uiThreadMsgRecorder = 0;
    m_nModel = _m;
    int nEnable = GetPrivateProfileInt(_T("MsgRecorder"), _T("enable"), 0, GetINIFileName());
    if (nEnable)
    {
        m_bEnable = TRUE;
    }
    else
    {
        m_bEnable = FALSE;
    }
}
CMsgRecorder::~CMsgRecorder() {}
