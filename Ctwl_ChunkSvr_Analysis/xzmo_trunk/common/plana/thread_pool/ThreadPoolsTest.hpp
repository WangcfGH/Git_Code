#pragma once
#ifdef _UNIT_TEST_
#include "EventPools.h"

#include "gtest/gtest.h"
#include "gmock/gmock.h"
using namespace std;
using namespace testing;
using namespace plana;
using namespace threadpools;

struct TEST_PLANA_EventPools_Fix : public Test
{
	virtual void SetUp() {
		threadpools->start();
	}
	virtual void TearDown() {
		threadpools->stop();
	}
	EventPools::Ptr threadpools = std::make_shared<EventPools>();
};

TEST_F(TEST_PLANA_EventPools_Fix, start_and_stop)
{

	ASSERT_TRUE(threadpools->running());
}

TEST_F(TEST_PLANA_EventPools_Fix, post)
{
	int nl = 0;
	for (int i = 0; i < 10; ++i)
	{
		nl++;
		threadpools->ios().post([i, &nl](){
			std::cout << "threadid:" << std::this_thread::get_id() << ":";
			std::cout << "index :" << i << std::endl;
			--nl;
		});
	}
	while (nl > 0) {
		std::this_thread::sleep_for(std::chrono::milliseconds(50));
	}
}


TEST_F(TEST_PLANA_EventPools_Fix, strand_post)
{
	int nl = 0;
	auto st = threadpools->strand();
	for (int i = 0; i < 10; ++i)
	{
		nl++;
		st.post([i, &nl](){
			std::cout << "threadid:" << std::this_thread::get_id() << ":";
			std::cout << "index :" << i << std::endl;
			--nl;
		});
	}
	while (nl == 0) {
		std::this_thread::sleep_for(std::chrono::milliseconds(50));
	}
}

TEST_F(TEST_PLANA_EventPools_Fix, deadlinetimer)
{
	auto dtimer = threadpools->timerPtr<boost::asio::deadline_timer>();
	dtimer->expires_from_now(boost::posix_time::seconds(1));

	dtimer->async_wait([dtimer](boost::system::error_code ec){
		if (!ec) {
			std::cout << "thread:" << std::this_thread::get_id() << "hehe" << std::endl;
		}
	});

	dtimer->async_wait([dtimer](boost::system::error_code ec){
		if (!ec) {
			std::cout << "thread:" << std::this_thread::get_id() << "haha" << std::endl;
		}
	});
}

TEST_F(TEST_PLANA_EventPools_Fix, strand_deadlinetimer)
{
	auto st = threadpools->strand();
	auto dtimer = threadpools->timer<boost::asio::deadline_timer>();
	dtimer.expires_from_now(boost::posix_time::seconds(1));

	auto wrapf1 = st.wrap([](boost::system::error_code ec){
		if (!ec) {
			std::cout << "thread:" << std::this_thread::get_id() << "hehe" << std::endl;
		}
	});

	dtimer.async_wait(wrapf1);

	auto wrapf2 = st.wrap([](boost::system::error_code ec){
		if (!ec) {
			std::cout << "thread:" << std::this_thread::get_id() << "haha" << std::endl;
		}
	});
	dtimer.async_wait(wrapf2);
}

TEST_F(TEST_PLANA_EventPools_Fix, timer_once)
{
	static int LoopN = 10;
	int i = 0;
	std::vector<std::shared_ptr<stdtimer>> timers;
	for (int j = 0; j < LoopN; ++j)
	{
		auto p = threadpools->onceTimer([&i](){
			i++;
			cout << "thread:" << std::this_thread::get_id() << ", i" << i << endl;
		}, std::chrono::milliseconds(12));
		timers.push_back(p);
	}

	while (i < LoopN) {
		std::this_thread::sleep_for(std::chrono::milliseconds(1));
	}
	timers.clear();
	i = 0;
	auto st = threadpools->strand();
	for (int j = 0; j < LoopN; ++j)
	{
		auto p = threadpools->onceTimer([&i](){
			i++;
			cout << "sthread:" << std::this_thread::get_id() << ", i" << i << endl;
		}, std::chrono::milliseconds(12), st);
		timers.push_back(p);
	}
	while (i < LoopN) {
		std::this_thread::sleep_for(std::chrono::milliseconds(1));
	}
}

TEST_F(TEST_PLANA_EventPools_Fix, timer_loop)
{
	int i = 0;
	auto p = threadpools->loopTimer([&i](){
		cout << "tlthread:" << std::this_thread::get_id() << ", i:" << i++ << endl;
	}, std::chrono::milliseconds(200));

	auto p1 = threadpools->loopTimer<boost::asio::deadline_timer>([&i](){
		cout << "tlthread:" << std::this_thread::get_id() << ", i:" << i++ << endl;
	}, boost::posix_time::milliseconds(200));
	
	while (i < 20) {
		std::this_thread::sleep_for(std::chrono::milliseconds(50));
	}
}

TEST_F(TEST_PLANA_EventPools_Fix, strand_timer_loop)
{
	auto st = threadpools->strand();
	int i = 0;
	auto p = threadpools->loopTimer([&i](){
		cout << "tlthread:" << std::this_thread::get_id() << ", i:" << i++ << endl;
	}, std::chrono::milliseconds(200), st);

	auto p1 = threadpools->loopTimer([&i](){
		cout << "tlthread:" << std::this_thread::get_id() << ", i:" << i++ << endl;
	}, std::chrono::milliseconds(200), st);

	while (i < 20) {
		std::this_thread::sleep_for(std::chrono::milliseconds(50));
	}

}

TEST_F(TEST_PLANA_EventPools_Fix, stdtimertest)
{
	auto t = std::chrono::system_clock::now();
	stdtimerPtr timer = threadpools->loopTimer([&t](){
		auto nt = std::chrono::system_clock::now();
		auto count =  std::chrono::duration_cast<std::chrono::seconds>(nt - t).count();
		cout << "hehe:" << count << endl;
		t = nt;
	}, std::chrono::seconds(1), threadpools->strand());

	int i = 2;
	std::cin >> i;

	cout << "new timer diff:" << i << endl;
	timer = threadpools->loopTimer([&t](){
		auto nt = std::chrono::system_clock::now();
		auto count = std::chrono::duration_cast<std::chrono::seconds>(nt - t).count();
		cout << "hehe:" << count << endl;
		t = nt;
	}, std::chrono::seconds(i), threadpools->strand());
	std::cin >> i;
}

struct PlanaStaffFix : public Test
{
	struct TestStaff : PlanaStaff
	{
		TestStaff() = default;
		TestStaff(EventPools::Ptr evp) : PlanaStaff(evp) {}

	};

	virtual void SetUp() override
	{
		staff.evp().start();
	}

	TestStaff staff;
};

TEST_F(PlanaStaffFix, test_default_evp)
{
	auto& evpptr = staff.evp();
	evpptr.ios().post([](){
		cout << "test_default_evp" << endl;
	});
}

TEST_F(PlanaStaffFix, test_other_evp)
{
	auto evp = std::make_shared<EventPools>();
	staff.evp().ios().post([](){
		cout << "test_default_evp" << endl;
	});
}

TEST_F(PlanaStaffFix, big_num_timer)
{
	const int N = 1000;
	stdtimerPtr timers[1000];
	for (int i = 0; i < N; ++i)
	{
		timers[i] = staff.evp().loopTimer([i](){
			auto tid = std::this_thread::get_id();
			cout << "tid:" << tid.hash() << ",index:"<< i << endl;
		}, std::chrono::milliseconds(i % 20 * 10));
	}

	std::string s;
	cin >> s;

	for (int i = 0; i < N; ++i)
	{
		timers[i] = staff.evp().loopTimer([i](){
			auto tid = std::this_thread::get_id();
			cout << "tid:" << tid.hash() << ",index:" << i << endl;
		}, std::chrono::milliseconds(i % 20 * 10), staff.strand());
	}

	cin >> s;
}

class TEST_M_Staff : public plana::threadpools::PlanaStaff
{
public:
	// evp -> threadpool
	// strand 

};

TEST(TEST_M_Staff_TEST, TEST1)
{
	auto staff = PlanaStaff();
	staff.evp().start();
	for (int i = 0; i < 100; ++i)
	{
		staff.evp().ios().post([i](){
			cout << std::this_thread::get_id() << ":" << i << endl;
		});
	}
	std::string s;
	cin >> s;

	stdtimerPtr timer[100];
	for (int i = 0; i < 100; ++i)
	{
		timer[i] = staff.evp().onceTimer([i](){
			cout << std::this_thread::get_id() << ": timer:" << i << endl;
		}, std::chrono::seconds(1));
	}
	cin >> s;

	for (int i = 0; i < 100; ++i)
	{
		staff.strand().post([i](){
			cout << std::this_thread::get_id() << ":" << i << endl;
		});
	}

	cin >> s;

	for (int i = 0; i < 100; ++i)
	{
		timer[i] = staff.evp().onceTimer([i](){
			cout << std::this_thread::get_id() << ": timer:" << i << endl;
		}, std::chrono::seconds(1), staff.strand());
	}

	cin >> s;
}

TEST(TEST_M_Staff_TEST, TEST2)
{
	auto staff = PlanaStaff();
	staff.evp().start();
	

	staff.evp().ios().post([]() {});

	getchar();
}

#endif // _UNIT_TEST_
