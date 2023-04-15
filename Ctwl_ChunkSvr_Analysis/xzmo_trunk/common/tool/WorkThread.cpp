#include "StdAfx.h"
#include "WorkThread.h"
#include <process.h>
#include <assert.h>
#include <iostream>
#include <algorithm>
#include <MMSystem.h >

#define WORKTHREAD_WND_NAME     ("WorkThread")
//////////////////////////////////////////////////////////////////////////
class AutoCominit
{
public:
    AutoCominit()
    {
        ::CoInitialize(NULL);
    }
    ~AutoCominit()
    {
        ::CoUninitialize();
    }
};

//////////////////////////////////////////////////////////////////////////
WORK_MAP_BASE_BEGIN(WorkThread)
WORK_MAP_MSG_DEF(MSG_WORK_TASK, &WorkThread::_TaskRun)
WORK_MAP_MSG_DEF(WM_TIMER, &WorkThread::_Timer)
WORK_MAP_MSG_DEF(MSG_WORK_TEST, &WorkThread::OnTest)
WORK_MAP_BASE_END(WorkThread)
//////////////////////////////////////////////////////////////////////////


WorkThread::WorkThread()
{
    m_sgStart = ::CreateEvent(NULL, TRUE, FALSE, NULL);
    m_sgWorking = ::CreateEvent(NULL, TRUE, FALSE, NULL);

    m_bInit = FALSE;
    m_hThread = nullptr;
    m_hwnd = nullptr;
    m_dwThreadID = 0;
}

WorkThread::~WorkThread()
{
    CloseHandle(m_sgStart);
    CloseHandle(m_sgWorking);
}

BOOL WorkThread::Start()
{
    if (m_hThread)
    {
        return TRUE;
    }
    ::ResetEvent(m_sgWorking);
    m_bInit = FALSE;
    ::ResetEvent(m_sgStart);
    m_hThread = (HANDLE)_beginthreadex(NULL, 0, _ThreadFunc, this, 0, &m_dwThreadID);
    WaitForSingleObject(m_sgStart, INFINITE);

    if (!m_bInit)
    {
        WaitForSingleObject(m_hThread, INFINITE);
        CloseHandle(m_hThread);
        m_hThread = NULL;
        return FALSE;
    }
    return TRUE;
}

VOID WorkThread::Stop()
{
    if (NULL == m_hThread)
    {
        return ;
    }
    ::PostMessage(m_hwnd, WM_QUIT, 0, 0);
    SetEvent(m_sgWorking);
    WaitForSingleObject(m_hThread, INFINITE);
    CloseHandle(m_hThread);
    m_hThread = NULL;
    m_timerFuncMap.clear();
}

BOOL WorkThread::PostMessage(UINT uMsg, WPARAM wParam, LPARAM lParam)
{
    assert(NULL != m_hwnd);
    return ::PostMessage(m_hwnd, uMsg, wParam, lParam);
}

BOOL WorkThread::SendMessage(UINT uMsg, WPARAM wParam, LPARAM lParam)
{
    assert(NULL != m_hwnd);
    return ::SendMessage(m_hwnd, uMsg, wParam, lParam);
}

BOOL WorkThread::PostWithCheck(Runable* pRun, const char* src, std::size_t line)
{
    assert(NULL != m_hwnd);
    if (!::PostMessage(m_hwnd, MSG_WORK_TASK, 0, (LPARAM)pRun))
    {
        CheckPostError(pRun, src, line);
        return FALSE;
    }
    m_postNum++;
    return TRUE;
}

BOOL WorkThread::PostTask(Runable* pRun)
{
    assert(NULL != m_hwnd);
    if (!::PostMessage(m_hwnd, MSG_WORK_TASK, 0, (LPARAM)pRun))
    {
        pRun->destroy();
        return FALSE;
    }
    m_postNum++;
    return TRUE;
}

UINT WorkThread::SetTimer(UINT uID, UINT uElapse)
{
    assert(NULL != m_hwnd);
    return ::SetTimer(m_hwnd, uID, uElapse, NULL);
}

unsigned WorkThread::_ThreadFunc(void* lPData)
{
    WorkThread* ptr = (WorkThread*)lPData;
    if (ptr)
    {
        ptr->_MessageLoop();
    }
    return 0;
}

void WorkThread::_MessageLoop()
{
    AutoCominit comInit;
    // ³õÊ¼»¯´°¿Ú
    WNDCLASSEX wcex;
    wcex.cbSize = sizeof(WNDCLASSEX);
    wcex.style = CS_HREDRAW | CS_VREDRAW;
    wcex.lpfnWndProc = _WNDPROC;
    wcex.cbClsExtra = 0;
    wcex.cbWndExtra = 0;
    wcex.hInstance = ::GetModuleHandle(0);
    wcex.hIcon = NULL;
    wcex.hCursor = NULL;
    wcex.hbrBackground = NULL;
    wcex.lpszMenuName = NULL;
    wcex.lpszClassName = WORKTHREAD_WND_NAME;
    wcex.hIconSm = NULL;
    if (0 == ::RegisterClassEx(&wcex) && 1410 != ::GetLastError())
    {
        SetEvent(m_sgStart);
        //UwlTrace(_T("RegisterClassEx Error<%d>!\r\n"), ::GetLastError());
        return ;
    }
    m_hwnd = ::CreateWindow(WORKTHREAD_WND_NAME, NULL, WS_OVERLAPPED, 0, 0, 0, 0, NULL, NULL, ::GetModuleHandle(0), 0);
    if (NULL == m_hwnd)
    {
        SetEvent(m_sgStart);
        //UwlTrace(_T("CreateWindow Error<%d>!\r\n"), ::GetLastError());
        return ;
    }
    m_bInit = TRUE;
    SetEvent(m_sgStart);

    //UwlTrace(_T("WorkThread Start!\r\n"));
    UINT TARGET_RESOLUTION = 1; // 1 millisecond target resolution
    TIMECAPS tc;
    UINT wTimerRes = 0;
    if (TIMERR_NOERROR == timeGetDevCaps(&tc, sizeof(TIMECAPS)))
    {
        wTimerRes = min(max(tc.wPeriodMin, TARGET_RESOLUTION), tc.wPeriodMax);
        timeBeginPeriod(wTimerRes);
    }

    MSG msg;
    BOOL bWork = _OnInit();
    while (bWork && WAIT_TIMEOUT == ::WaitForSingleObject(m_sgWorking, wTimerRes))
    {
        while (::PeekMessage(&msg, m_hwnd, 0, 0, PM_NOREMOVE))
        {
            if (!::GetMessage(&msg, m_hwnd, 0, 0))
            {
                break;
            }
            if (!_MsgFilter(msg.message, msg.wParam, msg.lParam))
            {
                TranslateMessage(&msg);
                DispatchMessage(&msg);
            }
        }
    }
    if (wTimerRes != 0)
    {
        timeEndPeriod(wTimerRes);
    }
    _OnDestroy();
    _OnClearTimerFunc();
    ::DestroyWindow(m_hwnd);
    m_hwnd = NULL;
    ::ResetEvent(m_sgWorking);
    //UwlTrace(_T("WorkThread End!\r\n"));
}

LRESULT CALLBACK WorkThread::_WNDPROC(HWND hwnd, UINT uMsg, WPARAM wParam, LPARAM lParam)
{
    return DefWindowProc(hwnd, uMsg, wParam, lParam);
}

VOID WorkThread::KillTimer(UINT uID)
{
    assert(NULL != m_hwnd);
    ::KillTimer(m_hwnd, uID);
}

BOOL WorkThread::IsRunning()
{
    return m_hwnd != nullptr;
}

VOID WorkThread::KillTimerWithFunction(UINT uID)
{
    auto it = m_timerFuncMap.find(uID);
    if (it != m_timerFuncMap.end())
    {
        m_timerFuncMap.erase(uID);
        KillTimer(uID);
    }
}

BOOL WorkThread::_MsgFilter(UINT uMsg, WPARAM wParam, LPARAM lParam)
{
    return _MsgOper(GetMsgMap(), uMsg, wParam, lParam);
}

BOOL WorkThread::_MsgOper(const _MsgMap* msgMap, UINT uMsg, WPARAM wParam, LPARAM lParam)
{
    if (nullptr == msgMap)
    {
        return FALSE;
    }
    const _MsgMap* _msgTable = msgMap;
    const _MsgEntry* _entryMine = _msgTable->thisEntry;

    const _MsgEntry* entry = _entryMine;
    while (entry && entry->OnMsgFunc)
    {
        if (uMsg == entry->nMsgID)
        {
            if (((*this).*entry->OnMsgFunc)(wParam, lParam))
            {
                return TRUE;
            }
            else
            {
                break;
            }
        }
        else
        {
            entry = entry + 1;
        }
    }
    return _MsgOper(_msgTable->baseMap, uMsg, wParam, lParam);
}

BOOL WorkThread::_OnTimer(int uID)
{
    auto it = m_timerFuncMap.find(uID);
    if (it != m_timerFuncMap.end())
    {
        return (it->second)(uID);
    }
    return TRUE;
}

void WorkThread::_OnClearTimerFunc()
{
    m_timerFuncMap.swap(std::map<UINT, std::function<BOOL(UINT uId)>>());
}

BOOL WorkThread::_TaskRun(WPARAM wParam, LPARAM lParam)
{
    Runable* pRun = (Runable*)lParam;
    __try
    {
        pRun->run();
        pRun->destroy();
        --m_postNum;
    }
    __except (_SehFiler(GetExceptionCode(), GetExceptionInformation(), pRun))
    {

    }
    return TRUE;
}

BOOL WorkThread::_Timer(WPARAM wParam, LPARAM lParam)
{
    return _OnTimer(wParam);
}

BOOL WorkThread::OnTest(WPARAM wParam, LPARAM lParam)
{
    //UwlTrace(_T("Test <%d>\r\n"), wParam);
    return TRUE;
}



