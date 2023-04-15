#pragma once
/*
	线程池，每个线程维护一个redis和mysql实例
	主要用于向该线程投递数据库操作

*/
#include <chrono>
#include <boost/any.hpp>
#include "plana.h"

using plana::threadpools::ThreadEntryBase;
using plana::threadpools::EventPools;
using plana::threadpools::PlanaStaff;

class DBConnectPool;

// 每个业务线程对应一个
struct StrandInfo
{
	using Ptr = std::shared_ptr < StrandInfo > ;

	PlanaStaff::Ptr staff;
	int strand_bind_count = 0; // 绑定到该strand的数量
};

// 每个分配出去的业务key对应一个
struct StrandAssginInfo
{
	using Ptr = std::shared_ptr < StrandAssginInfo > ;

	int assgin_count = 0;  // 同一个key有多少个队列操作
	StrandInfo::Ptr strand;
	std::weak_ptr<boost::any> user_data; // 缓存
};

class PoolEntry : public ThreadEntryBase
{
public:
	PoolEntry(DBConnectPool* p);

	virtual ~PoolEntry(){
	};

	std::weak_ptr<boost::any> *user_data;
	DBConnectPool* pools;
};

class DBConnectPool : public EventPools
{
	friend class PoolEntry;
public:
	DBConnectPool(int nthread = 8);
	~DBConnectPool();

	ImportFunctional<void(const char*, const char*, std::string&)> imIniStr;
	ImportFunctional<void(const char*, const char*, int&)> imIniInt;

	void OnServerStart(BOOL& ret, TcyMsgCenter* msgCenter);
		
	void OnServerStop();

	// 实际启动多少个线程
	virtual void start(int n = 8) override;
	virtual void stop() override;

	template <typename R, typename Entry>
	// 该模板函数key -> 业务线程的id，所有该id的业务，线性执行，不需要加锁
	// invoke是一个函数，会抛到dbentry的线程里执行
	// 返回值futrue可以进行同步等待结果
	//typename std::enable_if<!std::is_void<R>::value, std::future<R>>::type 
	typename std::enable_if<!std::is_void<R>::value, std::future<R>>::type
		dbInvokeByStrand(const std::string&key, std::function<R(Entry*)> invoke);

	// 特化，支持void返回值  c++17可使用 if constexpr来避免重载
	// 可以直接写 std::futrue<void> dbInvokeByStrand(const std::string&key, std::function<void(PoolEntry*)> invoke);
	// 直接写调用void返回函数的时候，要写dbInvokeByStrand(...)，而不是dbInvokeByStrand<void>(...)
	// 这样虽然看起来更简单，实际上写法就不能保持统一，所以强制把返回值特化标出来更好
	template <typename R, typename Entry> // R = void
	typename std::enable_if<std::is_void<R>::value, std::future<R>>::type
		dbInvokeByStrand(const std::string&key, std::function<R(Entry*)> invoke);


	// 不经过strand 直接分发到thread上执行，当操作不用考虑线程安全的时候，可以这样操作
	template <typename R, typename Entry>
	typename std::enable_if<!std::is_void<R>::value, std::future<R>>::type
		dbInvokeByThread(std::function<R(Entry*)> invoke);

	template <typename R, typename Entry> // R = void
	typename std::enable_if<std::is_void<R>::value, std::future<R>>::type
		dbInvokeByThread(std::function<R(Entry*)> invoke);
protected:
	//virtual std::shared_ptr<ThreadEntryBase> createThreadEntry() override;

	StrandAssginInfo::Ptr getStrandPtr(const std::string& key);
	void giveBackStrandPtr(const std::string& key);

	struct AutoEraseKey
	{
	public:
		AutoEraseKey(DBConnectPool* pool, const std::string& k) :parrent(pool), key(k){}
		~AutoEraseKey() {
			parrent->giveBackStrandPtr(key);
		}
	private:
		std::string key;
		DBConnectPool* parrent;
	};

	void onTimerFreshBindMap();
private:
	std::mutex m_lock;
	std::map<std::string, StrandAssginInfo::Ptr> m_bindMap;
	std::vector<StrandInfo::Ptr> m_strands;
	std::uint32_t	m_bindTotal = 0; // 一共绑定了多少，这个值暂时没有使用，以后可能需要统计
	plana::threadpools::stdtimerPtr m_timerBindMap;
};

template <typename R, typename Entry>
typename std::enable_if<!std::is_void<R>::value, std::future<R>>::type
DBConnectPool::dbInvokeByStrand(const std::string&key, std::function<R(Entry*)> invoke)
{
	auto p = std::make_shared<std::promise < R >>();
	auto assign = getStrandPtr(key);
	assign->strand->staff->strand().dispatch([key, p, invoke, assign, this](){
		auto entry = getThreadEntryByType<PoolEntry>();
		AutoEraseKey erase_key(this, key);
		try {
			entry->user_data = &assign->user_data;
			static_assert(std::is_convertible<Entry, PoolEntry>::value, "Entry Must Driver from PoolEntry");
			p->set_value(invoke(static_cast<Entry*>(entry)));
		}
		catch (...) {
			p->set_exception(std::current_exception());
		}
	});
	return p->get_future();
}

template <typename R, typename Entry>
typename std::enable_if<std::is_void<R>::value, std::future<R>>::type
DBConnectPool::dbInvokeByStrand(const std::string&key, std::function<R(Entry*)> invoke)
{
	auto p = std::make_shared<std::promise < R >>();
	auto assign = getStrandPtr(key);
	assign->strand->staff->strand().dispatch([key, p, invoke, assign, this](){
		auto entry = getThreadEntryByType<PoolEntry>();
		AutoEraseKey erase_key(this, key);
		try {
			entry->user_data = &assign->user_data;
			static_assert(std::is_convertible<Entry, PoolEntry>::value, "Entry Must Driver from PoolEntry");
			invoke(static_cast<Entry*>(entry));
			p->set_value();
		}
		catch (...) {
			p->set_exception(std::current_exception());
		}
	});
	return p->get_future();
}

template <typename R, typename Entry>
typename std::enable_if<!std::is_void<R>::value, std::future<R>>::type
DBConnectPool::dbInvokeByThread(std::function<R(Entry*)> invoke)
{
	auto p = std::make_shared<std::promise < R >>();
	this->ios().dispatch([p, invoke, this](){
		auto entry = getThreadEntryByType<PoolEntry>();
		try {
			entry->user_data = nullptr;
			static_assert(std::is_convertible<Entry, PoolEntry>::value, "Entry Must Driver from PoolEntry");
			p->set_value(invoke(static_cast<Entry*>(entry)));
		}
		catch (...) {
			p->set_exception(std::current_exception());
		}
	});
	return p->get_future();
}

template <typename R, typename Entry> 
typename std::enable_if<std::is_void<R>::value, std::future<R>>::type
DBConnectPool::dbInvokeByThread(std::function<R(Entry*)> invoke)
{
	auto p = std::make_shared<std::promise < R >>();
	this->ios().dispatch([p, invoke, this](){
		auto entry = getThreadEntryByType<PoolEntry>();
		try {
			entry->user_data = nullptr;
			static_assert(std::is_convertible<Entry, PoolEntry>::value, "Entry Must Driver from PoolEntry");
			invoke(static_cast<Entry*>(entry));
			p->set_value();
		}
		catch (...) {
			p->set_exception(std::current_exception());
		}
	});
	return p->get_future();
}

