#include "stdafx.h"
#include "DBConnectPool.h"


PoolEntry::PoolEntry(DBConnectPool* p)
{
	pools = p;
}

//////////////////////////////////////////////////////////////////////////
DBConnectPool::DBConnectPool(int nthread/* = 8*/)
{
	m_strands.resize(nthread);
}


DBConnectPool::~DBConnectPool()
{
}

void DBConnectPool::OnServerStart(BOOL& ret, TcyMsgCenter* msgCenter)
{
	if (ret) {
		try {
			start(m_strands.size());
		}
		catch (const std::exception& e) {
			LOG_ERROR("DBConnectPool start error:%s", e.what());
			ret = FALSE;
		}
	}
}

void DBConnectPool::OnServerStop()
{
	stop();
}

void DBConnectPool::start(int n /*= 8*/)
{
	__super::start(n);

	//////////////////////////////////////////////////////////////////////////
	// ����strands
	{
		std::lock_guard<std::mutex> guard(m_lock);
		// �������Կ��Ƶ�strand
		for (int i = 0; i < n; ++i)
		{
			auto strand_info = std::make_shared<StrandInfo>();
			strand_info->staff = std::make_shared<PlanaStaff>(shared_from_this());
			strand_info->strand_bind_count = 0;
			m_strands[i] = strand_info;
		}
	}

	//////////////////////////////////////////////////////////////////////////
	// ��ʱ�� һ��ʱ��ˢ��һ��bindMap ʡ���ڴ�й©
	m_timerBindMap = loopTimer([this](){
		onTimerFreshBindMap();
	}, std::chrono::hours(1));
}

void DBConnectPool::stop()
{
	__super::stop();
	m_bindMap.clear();
	m_strands.clear();
	m_timerBindMap = nullptr;
}

//std::shared_ptr<ThreadEntryBase> DBConnectPool::createThreadEntry()
//{
//	auto entry = std::make_shared<PoolEntry>(this);
//	return entry;
//}

StrandAssginInfo::Ptr DBConnectPool::getStrandPtr(const std::string& key)
{
	std::lock_guard<std::mutex> guard(m_lock);
	auto it = m_bindMap.find(key);
	if (it != m_bindMap.end()) {
		if (it->second->assgin_count != 0) {
			it->second->assgin_count++;
			it->second->strand->strand_bind_count++;
			m_bindTotal++;
			return it->second;
		}

		std::sort(m_strands.begin(), m_strands.end(), [](StrandInfo::Ptr l, StrandInfo::Ptr r){
			return l->strand_bind_count < r->strand_bind_count;
		});

		if (it->second->strand == *m_strands.begin()) {
			it->second->assgin_count++;
			it->second->strand->strand_bind_count++;
			m_bindTotal++;
			return it->second;
		}

		auto wptr = it->second->user_data;
		m_bindMap.erase(it);
		auto assgin = std::make_shared<StrandAssginInfo>();
		m_bindMap[key] = assgin;

		auto r = *m_strands.begin();
		r->strand_bind_count++;
		assgin->strand = r;
		assgin->user_data = wptr;
		assgin->assgin_count++;
		m_bindTotal++;
		return assgin;
	}


	std::sort(m_strands.begin(), m_strands.end(), [](StrandInfo::Ptr l, StrandInfo::Ptr r){
		return l->strand_bind_count < r->strand_bind_count;
	});
	// ����һ���µİ�
	auto assgin = std::make_shared<StrandAssginInfo>();
	m_bindMap[key] = assgin;

	auto r = *m_strands.begin();
	r->strand_bind_count++;
	assgin->strand = r;
	assgin->assgin_count++;
	m_bindTotal++;
	return assgin;
}

void DBConnectPool::giveBackStrandPtr(const std::string& key)
{
	std::lock_guard<std::mutex> guard(m_lock);
	auto it = m_bindMap.find(key);
	if (it == m_bindMap.end()) {
		assert(FALSE);
		return;
	}

	it->second->assgin_count--;
	it->second->strand->strand_bind_count--;
	--m_bindTotal;
	if (it->second->assgin_count < 0) {
		assert(FALSE);
	}

	if (it->second->assgin_count == 0 && it->second->user_data.expired()) {
		m_bindMap.erase(it);
	}

	return;
}

void DBConnectPool::onTimerFreshBindMap()
{
	std::lock_guard<std::mutex> guard(m_lock);
	for (auto it = m_bindMap.begin(); it != m_bindMap.end();)
	{
		if (it->second->assgin_count == 0 && it->second->user_data.expired()) {
			// ��Щʱ�򻺴���������߻�û��ɾ��
			it = m_bindMap.erase(it);
		}
		else {
			// ���ڰ󶨣����߻���δʧЧ��˵�������ģ����ڴ�һֱû���ͷţ��ȴ����ͷ�
			++it;
		}
	}
}
