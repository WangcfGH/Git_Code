#pragma once
#pragma push_macro("new")
#undef new

#include <vector>
#include <thread>
#include <memory>
#include <atomic>
#include <chrono>
#include <future>
#include <boost/asio.hpp>


namespace plana {
namespace threadpools {
// boost::aios::io_service，也就是事件分发，线程管理的核心类
typedef boost::asio::io_service         Ios;

// Strand 一个io_service自带的串行执行保证的类
typedef boost::asio::strand             Strand;

// 标准库clock类型的timer
typedef boost::asio::basic_waitable_timer<std::chrono::steady_clock>    stdtimer;
typedef std::shared_ptr<stdtimer>                                       stdtimerPtr;

// ios 跑的执行线程
class ThreadEntryBase
{
public:
    ThreadEntryBase() = default;
    virtual void enterThread() = 0;
    virtual void leaveThread() = 0;
    virtual ~ThreadEntryBase() {}

    std::thread t;
    std::shared_ptr<boost::asio::io_service::work> work;
};


// 帮助定时器进行重复注册调用
template <typename Timer, typename T>
struct TimerHelper : public std::enable_shared_from_this<TimerHelper<Timer, T>>
{
    using Ptr = std::shared_ptr<TimerHelper>;

    T t;
    std::function<void()> f;
    std::weak_ptr<Timer> tptr;

    TimerHelper(const T& time) : t(time) {}

    void registerTimer()
    {
        auto sp = tptr.lock();
        if (sp)
        {
            auto self = shared_from_this();
            sp->expires_from_now(t);
            sp->async_wait([self](boost::system::error_code ec)
            {
                if (ec)
                {
                    return;
                }
                self->f();
                self->registerTimer();
            });
        }
    }
};

// 帮助定时器进行重复注册调用
template <typename Timer, typename T>
struct StrandTimerHelper : public std::enable_shared_from_this<StrandTimerHelper<Timer, T>>
{
    using Ptr = std::shared_ptr<StrandTimerHelper>;

    T t;
    std::function<void()> f;
    Strand& strand;
    std::weak_ptr<Timer> tptr;

    StrandTimerHelper(const T& time, Strand& st) : t(time), strand(st) {}

    void registerTimer()
    {
        auto sp = tptr.lock();
        if (sp)
        {
            auto self = shared_from_this();
            sp->expires_from_now(t);
            auto wrapf = strand.wrap([self](boost::system::error_code ec)
            {
                if (ec)
                {
                    return;
                }
                self->f();
                self->registerTimer();
            });
            sp->async_wait(wrapf);
        }
    }
};

class EventPools : public std::enable_shared_from_this<EventPools>
{
public:
    // 智能指针，该类智能通过make_share创建
    typedef std::shared_ptr<EventPools>     Ptr;

    static void Init();
    static void Uinit();

    // 构造函数使用默认
    EventPools() = default;

    // 析构函数的时候，会调用一次stop
    virtual ~EventPools();


    // 启动[1,32] 之间的线程池
    // 当start结束，running可以返回true，至少启动了一个线程
    virtual void start(int n = 8);

    // 停止，强烈建议 start和stop在同一个线程，不要让start和stop的调用产生竞争
    virtual void stop();

    // 是否start成功
    bool running() { return m_bRunning; }

    // 返回Ios实例： 主要的操作也都是通过它来调用的
    // Ios:  post,dispatch
    Ios& ios()
    {
        return m_ios;
    }

    // Strand实例：
    // post,dispatch【保证由该实例发送的执行都是不需要加锁的】
    Strand strand()
    {
        return boost::asio::strand(m_ios);
    }


    // boost::asio::deadline_timer
    // boost::asio_basic_wait_timer
    // .....
    template <typename Timer>
    Timer timer()
    {
        return Timer(ios());
    }

    template <typename Timer>
    std::shared_ptr<Timer> timerPtr()
    {
        return std::make_shared<Timer>(ios());
    }

    template <typename Timer = stdtimer, typename T, typename F>
    // Timer 代表哪一种定时器
    // F = std::funcion<void()> 兼容
    // T 代表多长时间之后执行
    // onceTimer一定要执行cancel才能停止！
    std::shared_ptr<Timer> onceTimer(F& f, const T& t)
    {
        auto tp = timerPtr<Timer>();
        tp->expires_from_now(t);
        tp->async_wait([f, tp](boost::system::error_code ec)
        {
            if (ec)
            {
                return;
            }
            f();
        });
        return tp;
    }

    template <typename Timer = stdtimer, typename T, typename F>
    // Timer 代表哪一种定时器
    // F = std::funcion<void()> 兼容
    // T 代表多长时间之后执行
    // onceTimer一定要执行cancel才能停止！
    std::shared_ptr<Timer> onceTimer(F& f, const T& t, Strand& strand)
    {
        auto tp = timerPtr<Timer>();
        tp->expires_from_now(t);
        auto wrapf = strand.wrap([f](boost::system::error_code ec)
        {
            if (ec)
            {
                return;
            }
            f();
        });
        tp->async_wait(wrapf);
        return tp;
    }

    template <typename Timer = stdtimer, typename T, typename F>
    // Timer 代表哪一种定时器
    // F = std::funcion<void()> 兼容
    // T 代表多长时间之后执行
    std::shared_ptr<Timer> loopTimer(F& f, const T& t)
    {
        auto tp = timerPtr<Timer>();
        using ThisTimerHelper = TimerHelper<Timer, T>;
        using ThisTimerHelperPtr = ThisTimerHelper::Ptr;
        ThisTimerHelperPtr timerHelper = std::make_shared<ThisTimerHelper>(t);
        timerHelper->tptr = tp;
        timerHelper->f = f;
        timerHelper->t = t;
        timerHelper->registerTimer();
        return tp;
    }

    template <typename Timer = stdtimer, typename T, typename F>
    // Timer 代表哪一种定时器
    // F = std::funcion<void()> 兼容
    // T 代表多长时间之后执行 std::chrono::second、std::chrono::minutes...
    std::shared_ptr<Timer> loopTimer(F& f, const T& t, Strand& strand)
    {
        auto tp = timerPtr<Timer>();
        using ThisTimerHelper = StrandTimerHelper<Timer, T>;
        using ThisTimerHelperPtr = ThisTimerHelper::Ptr;
        ThisTimerHelperPtr timerHelper = std::make_shared<ThisTimerHelper>(t, strand);
        timerHelper->tptr = tp;
        timerHelper->f = f;
        timerHelper->t = t;
        timerHelper->registerTimer();
        return tp;
    }

    // 给一个默认的eventpools给全局用
    static EventPools::Ptr defaultEventPools();

protected:
    virtual std::shared_ptr<ThreadEntryBase> createThreadEntry();

    ThreadEntryBase* getThreadEntry();

    template <typename ThreadEntry>
    ThreadEntry* getThreadEntryByType()
    {
        static_assert(std::is_convertible<ThreadEntry, ThreadEntryBase>::value, "Error ThreadEntry Type");
        return static_cast<ThreadEntry*>(getThreadEntry());
    }

private:
    std::atomic<bool>               m_bRunning = false;
    std::vector<std::shared_ptr<ThreadEntryBase>>   m_guards;
    boost::asio::io_service         m_ios;
};


// 一个简单的类，用于分配一个EventPools
struct PlanaStaff
{
public:
    typedef std::shared_ptr<PlanaStaff> Ptr;
    typedef std::shared_ptr<Strand> StrandPtr;

    PlanaStaff() : m_evp(EventPools::defaultEventPools()), m_strand(std::make_shared<Strand>(m_evp->strand())) {}
    PlanaStaff(EventPools::Ptr evp) : m_evp(evp), m_strand(std::make_shared<Strand>(m_evp->strand())) {}

    EventPools& evp()
    {
        return *m_evp;
    }

    void setevp(EventPools::Ptr evp)
    {
        m_evp = evp;
        m_strand = std::make_shared<Strand>(evp->strand());
    }

    Strand& strand()
    {
        return *m_strand;
    }

    template <typename R>
    typename std::enable_if < !std::is_void<R>::value, std::future<R >>::type
        async(std::function<R()> invoke)
    {
        auto f = std::make_shared<std::promise<R>>();
        strand().dispatch([f, invoke]()
        {
            try
            {
                f->set_value(invoke());
            }
            catch (...)
            {
                f->set_exception(std::current_exception());
            }
        });
        return f->get_future();
    }

    template <typename R> // R = void
    typename std::enable_if<std::is_void<R>::value, std::future<R>>::type
        async(std::function<R()> invoke)
    {
        auto f = std::make_shared<std::promise<R>>();
        strand().dispatch([f, invoke]()
        {
            try
            {
                invoke();
                f->set_value();
            }
            catch (...)
            {
                f->set_exception(std::current_exception());
            }
        });
        return f->get_future();
    }

protected:
    EventPools::Ptr         m_evp;
    StrandPtr               m_strand;
};
}
}


//////////////////////////////////////////////////////////////////////////
#pragma pop_macro("new")