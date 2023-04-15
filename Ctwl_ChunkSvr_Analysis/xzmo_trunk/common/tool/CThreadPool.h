#pragma once
#include "ConTool.h"
#include "Runable.h"
#include <iostream>
#include <thread>
#include <list>
#include <memory>
#include <atomic>

class ErrorHandleBase
{
public:
    virtual ~ErrorHandleBase() {}
    virtual void HandleError(int nErrorCode) {};
    virtual void HandleError(const std::string& strError) {};
    virtual void HandleError(const std::exception& e) {};
    virtual void HandleError(const std::string& strTypeName, const std::exception& e) {};

    virtual void DumpError(std::ostream& os) = 0;
    virtual void Clean() {};
};

class ThreadEntry;
typedef std::shared_ptr<ErrorHandleBase>        PtrEHandler;
class CThreadPool
{
    friend class ThreadEntry;
    typedef std::list<std::thread>              ListThread;
public:
    // threadnum >= 1
    CThreadPool(std::size_t nThreadNum = 32);
    ~CThreadPool(void);

    void ResetErrorHanlde(ErrorHandleBase* handler);

    bool Start();
    bool Start(std::size_t nNum);
    void Stop();

    void PostTask(Runable* t);

    template<typename T>
    void PostT(const T& t)
    {
        return PostTask(new FuncTask<T>(t));
    }

    bool IsRunning() const {return m_bRunning;}
    PtrEHandler ErrorHandle();
protected:
    Runable* _wait();
private:
    std::size_t             m_nThreadNum;
    CConTool<Runable>       m_cv;
    ListThread              m_threads;
    std::atomic<bool>       m_bRunning;
    PtrEHandler             m_eHandler;
};

