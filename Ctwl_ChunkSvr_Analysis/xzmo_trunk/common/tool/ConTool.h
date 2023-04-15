#pragma once
#include <iostream>
#include <mutex>
#include <condition_variable>
#include <list>

template <typename T>
class CConTool
{
    typedef std::list<T*>   ListT;
public:
    CConTool(int nMax = 4096) : m_nMax(nMax) {}
    ~CConTool(void) {}

    T* Wait();
    void Notify(T* t);
    void NotifyAll(int nMax);

    void Dump()
    {
        using namespace std;
        std::unique_lock<std::mutex> scopeLck(m_lck);
        cout << "Left Task:" << m_lT.size() << endl;
    }
private:
    std::mutex                  m_lck;
    std::condition_variable     m_cv;
    ListT                       m_lT;
    std::size_t                 m_nMax;
};

template <typename T>
void CConTool<T>::NotifyAll(int nMax)
{
    std::unique_lock<std::mutex> scopeLck(m_lck);
    for (int i = 0; i < nMax; ++i)
    {
        m_lT.push_back(NULL);
    }
    m_cv.notify_all();
}

template <typename T>
T* CConTool<T>::Wait()
{
    std::unique_lock<std::mutex> scopeLck(m_lck);
    while (m_lT.empty())
    {
        m_cv.wait(scopeLck);
    }
    T* task = m_lT.front();
    m_lT.pop_front();
    return task;
}

template <typename T>
void CConTool<T>::Notify(T* t)
{
    std::unique_lock<std::mutex> scopeLck(m_lck);
    while (m_lT.size() > m_nMax)
    {
        m_cv.wait(scopeLck);
    }
    m_lT.push_back(t);
    m_cv.notify_one();
}

