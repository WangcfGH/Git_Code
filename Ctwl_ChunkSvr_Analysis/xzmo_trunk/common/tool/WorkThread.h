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

    // 开始工作消息线程
    BOOL Start();
    // 停止工作消息线程
    VOID Stop();

    //抛消息
    BOOL PostMessage(UINT uMsg, WPARAM wParam, LPARAM lParam);
    //阻塞消息
    BOOL SendMessage(UINT uMsg, WPARAM wParam, LPARAM lParam);

    BOOL PostWithCheck(Runable* pRun, const char* src, std::size_t line);

    //抛工作任务
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

    //设置定时器
    UINT SetTimer(UINT uID, UINT uElapse);
    //销毁定时器
    VOID KillTimer(UINT uID);
    //工作线程是否开启
    BOOL IsRunning();

    // 方便的timer接口
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
    // 定时器的消息函数（不需要重载）
    virtual BOOL _Timer(WPARAM wParam, LPARAM lParam);
    // 消息的筛选工作，主要用于对我们自定义的消息进行筛选，一般不要重载
    virtual BOOL _MsgFilter(UINT uMsg, WPARAM wParam, LPARAM lParam);
    virtual BOOL _MsgOper(const _MsgMap* msgMap, UINT uMsg, WPARAM wParam, LPARAM lParam);

    // 可重载的接口
    // 消息循环开始之前可以进行初始化，如果返回为FALSE，消息线程直接退出
    virtual BOOL _OnInit() { return TRUE; }
    // 当消息线程结束后可以进行清理
    virtual VOID _OnDestroy() {}
    // 定时器工作函数
    virtual BOOL _OnTimer(int uID);
    // 清理定时器调用函数
    virtual void _OnClearTimerFunc();

    virtual void CheckPostError(Runable* pRun, const char* src, std::size_t line)
    {
        pRun->destroy();
    }
    //////////////////////////////////////////////////////////////////////////
    // task 函数
    // 任务工作函数（不需要重载）
    virtual BOOL _TaskRun(WPARAM wParam, LPARAM lParam);
    // 出现异常的时候是否收集崩溃
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