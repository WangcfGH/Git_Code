#include "StdAfx.h"
#include "CThreadPool.h"

//////////////////////////////////////////////////////////////////////////
class ThreadEntry : public Runable
{
public:
    ThreadEntry(CThreadPool* parrent): m_parrent(parrent) {}
    virtual bool run()
    {
        while (m_parrent->m_bRunning)
        {
            Runable* task = m_parrent->_wait();
            if (nullptr == task)
            {
                break;
            }
            try
            {
                task->run();
            }
            catch (const std::exception& e)
            {
                PtrEHandler handler = m_parrent->ErrorHandle();
                if (handler)
                {
                    handler->HandleError(task->GetName(), e);
                }
            }
            catch (...)
            {
                PtrEHandler handler = m_parrent->ErrorHandle();
                if (handler)
                {
                    handler->HandleError(task->GetName(), std::exception("Unkonw"));
                }
            }
            task->destroy();
        }
        return true;
    }
private:
    CThreadPool* m_parrent;
};

//////////////////////////////////////////////////////////////////////////
CThreadPool::CThreadPool(std::size_t nThreadNum) : m_nThreadNum(nThreadNum), m_bRunning(false)
{
    if (nThreadNum <= 0)
    {
        throw std::exception("Kill You!");
    }
}

CThreadPool::~CThreadPool(void)
{
    Stop();
}

void CThreadPool::ResetErrorHanlde(ErrorHandleBase* handler)
{
    m_eHandler.reset(handler);
}

bool CThreadPool::Start()
{
    if (m_bRunning)
    {
        return false;
    }
    m_bRunning = true;
    m_threads.resize(m_nThreadNum);
    for (auto& th : m_threads)
    {
        th = std::thread([&, this]()
        {
            ThreadEntry entry(this);
            entry.run();
        });
    }
    return true;
}

bool CThreadPool::Start(std::size_t nNum)
{
    if (nNum <= 0 || m_bRunning)
    {
        throw std::exception("Kill You!");
    }
    m_nThreadNum = nNum;
    return Start();
}

void CThreadPool::Stop()
{
    if (!m_bRunning)
    {
        return ;
    }
    m_cv.NotifyAll(m_nThreadNum);
    for (auto& th : m_threads)
    {
        th.join();
    }
    m_bRunning = false;
}

void CThreadPool::PostTask(Runable* t)
{
    m_cv.Notify(t);
}

Runable* CThreadPool::_wait()
{
    return m_cv.Wait();;
}

PtrEHandler CThreadPool::ErrorHandle()
{
    return m_eHandler;
}

