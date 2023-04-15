#pragma once
#include "Runable.h"
#include <afx.h>
#include <Windows.h>
#include <iostream>
#include <map>
#include <functional>
#include <atomic>

class WorkThread;
typedef BOOL (WorkThread::*_OnMsgFunc)(WPARAM, LPARAM);
typedef struct _tagMsgEntry
{
    int nMsgID;
    _OnMsgFunc OnMsgFunc;
} _MsgEntry;

typedef struct _tagMsgMap
{
    const _MsgEntry*    thisEntry;
    const _tagMsgMap*   baseMap;
} _MsgMap;

//////////////////////////////////////////////////////////////////////////
#define WORK_MAP_DEF()                          \
    protected:                                  \
    virtual const _MsgEntry* GetMsgEntry();     \
    virtual const _MsgMap* GetMsgMap();

//////////////////////////////////////////////////////////////////////////
#define WORK_MAP_MSG_DEF(id, func)              \
{id, static_cast<_OnMsgFunc>(func)},
//////////////////////////////////////////////////////////////////////////
#define WORK_MAP_BASE_BEGIN(classname)          \
    const _MsgEntry* classname::GetMsgEntry(){  \
    static const _MsgEntry _entry[] = {         \

#define WORK_MAP_BASE_END(classname)            \
    {0,NULL}};                                  \
    return _entry;                              \
}                                               \
const _MsgMap* classname::GetMsgMap(){          \
static const _MsgMap _table[] = {               \
{classname::GetMsgEntry(), NULL}                \
    };                                          \
    return _table;                              \
}
//////////////////////////////////////////////////////////////////////////
#define WORK_MAP_BEGIN(classname, baseclass)    \
    const _MsgEntry* classname::GetMsgEntry(){  \
    static const _MsgEntry _entry[] = {         \

#define WORK_MAP_END(classname,baseclass)       \
    {0, NULL} };                                \
    return _entry;                              \
    }                                           \
    const _MsgMap* classname::GetMsgMap(){      \
        static const _MsgMap _table[] = {       \
{classname::GetMsgEntry(),baseclass::GetMsgMap()}           \
    };                                          \
    return _table;                              \
}

//////////////////////////////////////////////////////////////////////////
enum ENUM_WORK_MSG
{
    MSG_WORK_TASK = WM_USER + 1000,
    MSG_WORK_TEST,
    MSG_WORK_CUSTOM,
};

#define WORKER_SET_TIMER_WITH_FUNC(id, elaspe, func)    SetTimerWithFunction(id, elaspe, std::bind(func, this, std::placeholders::_1))
#define THIS_POST_CHECK(t)      \
    PostTWithCheck(t, __FUNCTION__, __LINE__);

#define POST_CHECK(wt, t)       \
    wt->PostTWithCheck(t, __FUNCTION__, __LINE__);

class WorkThread
{
    WORK_MAP_DEF()
public:
    WorkThread();
    virtual ~WorkThread();

    // ��ʼ������Ϣ�߳�
    BOOL Start();
    // ֹͣ������Ϣ�߳�
    VOID Stop();

    //����Ϣ
    BOOL PostMessage(UINT uMsg, WPARAM wParam, LPARAM lParam);
    //������Ϣ
    BOOL SendMessage(UINT uMsg, WPARAM wParam, LPARAM lParam);

    BOOL PostWithCheck(Runable* pRun, const char* src, std::size_t line);

    //�׹�������
    BOOL PostTask(Runable* pRun);

    template<typename T>
    BOOL PostT(const T& t)
    {
        return PostTask(new FuncTask<T>(t));
    }

    template <typename T>
    BOOL PostTWithCheck(const T& t, const char* src, std::size_t line)
    {
        return PostWithCheck(new FuncTask<T>(t), src, line);
    }

    //���ö�ʱ��
    UINT SetTimer(UINT uID, UINT uElapse);
    //���ٶ�ʱ��
    VOID KillTimer(UINT uID);
    //�����߳��Ƿ���
    BOOL IsRunning();

    // �����timer�ӿ�
    template <typename F>
    UINT SetTimerWithFunction(UINT uID, UINT uElapse, F f)
    {
        auto it = m_timerFuncMap.find(uID);
        if (it == m_timerFuncMap.end())
        {
            m_timerFuncMap.insert(std::make_pair(uID, f));
        }
        else
        {
            m_timerFuncMap.erase(it);
            KillTimer(uID);
            m_timerFuncMap.insert(std::make_pair(uID, f));
        }
        return SetTimer(uID, uElapse);
    }

    VOID KillTimerWithFunction(UINT uID);

protected:
    void _MessageLoop();
    static unsigned __stdcall _ThreadFunc(void*);
    static LRESULT CALLBACK _WNDPROC(HWND, UINT, WPARAM, LPARAM);
    //////////////////////////////////////////////////////////////////////////
    BOOL OnTest(WPARAM wParam, LPARAM lParam);
    //////////////////////////////////////////////////////////////////////////
    // ��ʱ������Ϣ����������Ҫ���أ�
    virtual BOOL _Timer(WPARAM wParam, LPARAM lParam);
    // ��Ϣ��ɸѡ��������Ҫ���ڶ������Զ������Ϣ����ɸѡ��һ�㲻Ҫ����
    virtual BOOL _MsgFilter(UINT uMsg, WPARAM wParam, LPARAM lParam);
    virtual BOOL _MsgOper(const _MsgMap* msgMap, UINT uMsg, WPARAM wParam, LPARAM lParam);

    // �����صĽӿ�
    // ��Ϣѭ����ʼ֮ǰ���Խ��г�ʼ�����������ΪFALSE����Ϣ�߳�ֱ���˳�
    virtual BOOL _OnInit() { return TRUE; }
    // ����Ϣ�߳̽�������Խ�������
    virtual VOID _OnDestroy() {}
    // ��ʱ����������
    virtual BOOL _OnTimer(int uID);
    // ����ʱ�����ú���
    virtual void _OnClearTimerFunc();

    virtual void CheckPostError(Runable* pRun, const char* src, std::size_t line)
    {
        pRun->destroy();
    }
    //////////////////////////////////////////////////////////////////////////
    // task ����
    // ����������������Ҫ���أ�
    virtual BOOL _TaskRun(WPARAM wParam, LPARAM lParam);
    // �����쳣��ʱ���Ƿ��ռ�����
    virtual BOOL _SehFiler(int code, LPEXCEPTION_POINTERS p_exinfo, Runable* run = nullptr) { return TRUE; }
    //////////////////////////////////////////////////////////////////////////

protected:
    BOOL m_bInit;
    HWND m_hwnd;
    HANDLE m_hThread;
    UINT m_dwThreadID;
    HANDLE m_sgStart;
    HANDLE m_sgWorking;
    std::map<UINT, std::function<BOOL(UINT uId)>>   m_timerFuncMap;

    std::atomic_size_t m_postNum = 0;
};