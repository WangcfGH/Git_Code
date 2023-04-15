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
// boost::aios::io_service��Ҳ�����¼��ַ����̹߳���ĺ�����
typedef boost::asio::io_service         Ios;

// Strand һ��io_service�Դ��Ĵ���ִ�б�֤����
typedef boost::asio::strand             Strand;

// ��׼��clock���͵�timer
typedef boost::asio::basic_waitable_timer<std::chrono::steady_clock>    stdtimer;
typedef std::shared_ptr<stdtimer>                                       stdtimerPtr;

// ios �ܵ�ִ���߳�
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


// ������ʱ�������ظ�ע�����
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

// ������ʱ�������ظ�ע�����
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
    // ����ָ�룬��������ͨ��make_share����
    typedef std::shared_ptr<EventPools>     Ptr;

    static void Init();
    static void Uinit();

    // ���캯��ʹ��Ĭ��
    EventPools() = default;

    // ����������ʱ�򣬻����һ��stop
    virtual ~EventPools();


    // ����[1,32] ֮����̳߳�
    // ��start������running���Է���true������������һ���߳�
    virtual void start(int n = 8);

    // ֹͣ��ǿ�ҽ��� start��stop��ͬһ���̣߳���Ҫ��start��stop�ĵ��ò�������
    virtual void stop();

    // �Ƿ�start�ɹ�
    bool running() { return m_bRunning; }

    // ����Iosʵ���� ��Ҫ�Ĳ���Ҳ����ͨ���������õ�
    // Ios:  post,dispatch
    Ios& ios()
    {
        return m_ios;
    }

    // Strandʵ����
    // post,dispatch����֤�ɸ�ʵ�����͵�ִ�ж��ǲ���Ҫ�����ġ�
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
    // Timer ������һ�ֶ�ʱ��
    // F = std::funcion<void()> ����
    // T ����೤ʱ��֮��ִ��
    // onceTimerһ��Ҫִ��cancel����ֹͣ��
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
    // Timer ������һ�ֶ�ʱ��
    // F = std::funcion<void()> ����
    // T ����೤ʱ��֮��ִ��
    // onceTimerһ��Ҫִ��cancel����ֹͣ��
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
    // Timer ������һ�ֶ�ʱ��
    // F = std::funcion<void()> ����
    // T ����೤ʱ��֮��ִ��
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
    // Timer ������һ�ֶ�ʱ��
    // F = std::funcion<void()> ����
    // T ����೤ʱ��֮��ִ�� std::chrono::second��std::chrono::minutes...
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

    // ��һ��Ĭ�ϵ�eventpools��ȫ����
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


// һ���򵥵��࣬���ڷ���һ��EventPools
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