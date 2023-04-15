#pragma once
/*
	�̳߳أ�ÿ���߳�ά��һ��redis��mysqlʵ��
	��Ҫ��������߳�Ͷ�����ݿ����

*/
#include <chrono>
#include <boost/any.hpp>
#include "plana.h"

using plana::threadpools::ThreadEntryBase;
using plana::threadpools::EventPools;
using plana::threadpools::PlanaStaff;

class DBConnectPool;

// ÿ��ҵ���̶߳�Ӧһ��
struct StrandInfo
{
	using Ptr = std::shared_ptr < StrandInfo > ;

	PlanaStaff::Ptr staff;
	int strand_bind_count = 0; // �󶨵���strand������
};

// ÿ�������ȥ��ҵ��key��Ӧһ��
struct StrandAssginInfo
{
	using Ptr = std::shared_ptr < StrandAssginInfo > ;

	int assgin_count = 0;  // ͬһ��key�ж��ٸ����в���
	StrandInfo::Ptr strand;
	std::weak_ptr<boost::any> user_data; // ����
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

	// ʵ���������ٸ��߳�
	virtual void start(int n = 8) override;
	virtual void stop() override;

	template <typename R, typename Entry>
	// ��ģ�庯��key -> ҵ���̵߳�id�����и�id��ҵ������ִ�У�����Ҫ����
	// invoke��һ�����������׵�dbentry���߳���ִ��
	// ����ֵfutrue���Խ���ͬ���ȴ����
	//typename std::enable_if<!std::is_void<R>::value, std::future<R>>::type 
	typename std::enable_if<!std::is_void<R>::value, std::future<R>>::type
		dbInvokeByStrand(const std::string&key, std::function<R(Entry*)> invoke);

	// �ػ���֧��void����ֵ  c++17��ʹ�� if constexpr����������
	// ����ֱ��д std::futrue<void> dbInvokeByStrand(const std::string&key, std::function<void(PoolEntry*)> invoke);
	// ֱ��д����void���غ�����ʱ��ҪдdbInvokeByStrand(...)��������dbInvokeByStrand<void>(...)
	// ������Ȼ���������򵥣�ʵ����д���Ͳ��ܱ���ͳһ������ǿ�ưѷ���ֵ�ػ����������
	template <typename R, typename Entry> // R = void
	typename std::enable_if<std::is_void<R>::value, std::future<R>>::type
		dbInvokeByStrand(const std::string&key, std::function<R(Entry*)> invoke);


	// ������strand ֱ�ӷַ���thread��ִ�У����������ÿ����̰߳�ȫ��ʱ�򣬿�����������
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
	std::uint32_t	m_bindTotal = 0; // һ�����˶��٣����ֵ��ʱû��ʹ�ã��Ժ������Ҫͳ��
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

