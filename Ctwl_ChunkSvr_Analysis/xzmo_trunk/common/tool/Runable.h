#pragma once
#include <iostream>

class Runable
{
public:
    virtual bool run() = 0;
    virtual void destroy()
    {
        delete this;
    }
    const std::string GetName()
    {
        return typeid(*this).name();
    }
    virtual ~Runable() {}
};

template <typename T>
class FuncTask : public Runable
{
public:
    FuncTask(const T& t) : m_t(t) {}
    virtual bool run()
    {
        m_t();
        return true;
    }
    T m_t;
};
