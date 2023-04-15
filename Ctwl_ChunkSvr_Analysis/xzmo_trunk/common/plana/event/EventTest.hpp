#pragma once
#ifdef _UNIT_TEST_
#include "Event.h"
#include "gtest/gtest.h"
#include "gmock/gmock.h"
using namespace testing;
using namespace std;
using namespace plana;
using namespace events;

TEST(Plan_Event_Function, call_equal)
{

}

TEST(Plan_Event_Function, Delegate)
{
	using namespace plana;
	struct FFF
	{
		void f(int a) {
			cout << a << endl;
		}
	};
	std::shared_ptr<FFF> fptr = std::make_shared<FFF>();
	std::weak_ptr<FFF> fwptr = fptr;

	auto df = delegate(fwptr, &FFF::f);
	auto df1 = delegate(fwptr, &FFF::f);
	df(5);
	df1(7);
	df1.notify(5);
	ASSERT_TRUE(df == df1);

	struct QQQ
	{
		void p(const char *s) {
			cout << s << endl;
		}
		void p1(const char* s) {
			cout << s << endl;
		}
	};
	std::shared_ptr<QQQ> qptr = std::make_shared<QQQ>();
	std::weak_ptr<QQQ> qwptr = qptr;
	auto dq = delegate(qwptr, &QQQ::p);
	auto dq1 = delegate(qwptr, &QQQ::p);
	auto dq2 = delegate(qwptr, &QQQ::p1);
	dq("hello");
	dq1("world");
	dq2("!");
	dq2.notify("");

	ASSERT_TRUE(dq == dq1);

	ASSERT_TRUE(dq != dq2);


	//////////////////////////////////////////////////////////////////////////
	// 原生指针测试
	QQQ q;
	QQQ q1;
	auto rdq = delegate(&q, &QQQ::p);
	auto rdqq = delegate(&q, &QQQ::p);
	auto rdq1 = delegate(&q1, &QQQ::p);
	rdq("hello world");

	ASSERT_EQ(rdqq, rdq);
	ASSERT_NE(rdq, rdq1);
	//////////////////////////////////////////////////////////////////////////
	// 智能指针
	auto sqptr = std::make_shared<QQQ>();
	auto sqptr1 = std::make_shared<QQQ>();

	auto sdq = delegate(sqptr, &QQQ::p);
	auto sdqq = delegate(sqptr, &QQQ::p);
	auto sdqq1 = delegate(sqptr1, &QQQ::p);
	ASSERT_EQ(sdq, sdqq);
	ASSERT_NE(sdq , sdqq1);
	sdq("hello world");
	
}


TEST(Plan_Event_Function, LockUnLockTrait)
{
	struct LockT
	{
		void lock(){}
	};

	struct unlockT
	{
		void unlock() {}
	};

	struct lockandunlockT
	{
		void lock() {}
		void unlock() {}
	};

	auto r = std::is_same<decltype(std::declval<LockT>().lock(), 1), decltype(1)>::value;
	ASSERT_TRUE(r);
	r = std::is_same<decltype(std::declval<unlockT>().unlock(), 1), decltype(1)>::value;
	ASSERT_TRUE(r);
	r = std::is_same<decltype(std::declval<lockandunlockT>().unlock(), std::declval<lockandunlockT>().lock(), 1), decltype(1)>::value;
	ASSERT_TRUE(r);

	r = lock_unlock_helper<LockT>::value;
	ASSERT_FALSE(r);
	r = lock_unlock_helper<unlockT>::value;
	ASSERT_FALSE(r);
	r = lock_unlock_helper<lockandunlockT>::value;
	ASSERT_TRUE(r);

	ASSERT_TRUE(lock_unlock_helper<std::mutex>::value);
}

struct TestHelperDo
{
	void gun() {
		cout << "gun" << endl;
	}
	void fun() {
		cout << "fun" << endl;
	}
	int i = 0;
	void func(int a) {
		i++;
		cout << "a:" << a << endl;
	}
	void gunc(int b) {
		cout << "b:" << b << endl;
		i++;
	}

	int j = 0;
	void funcc(int a, const char *s) {
		j++;
		cout << "a:" << a << ",s:" << s << endl;
	}
	void guncc(int b, const char *s) {
		j++;
		cout << "b:" << b << ",s:" << s << endl;
	}
};

TEST(Plan_Event_Function, EventTest)
{
	std::shared_ptr<TestHelperDo> one = std::make_shared<TestHelperDo>();
	std::weak_ptr<TestHelperDo> wo = one;
	auto dfunc = delegate(wo, &TestHelperDo::func);
	auto dgunc = delegate(wo, &TestHelperDo::gunc);

	BasicEvent<int> e1;
	e1 += dfunc;
	e1 += dgunc;

	e1.notify(10);
	ASSERT_THAT(one->i, Eq(2));

	e1 -= dfunc;
	e1.notify(20);
	ASSERT_THAT(one->i, Eq(3));

	auto dfuncc = delegate(wo, &TestHelperDo::funcc);
	auto dguncc = delegate(wo, &TestHelperDo::guncc);
	BasicEvent<int, const char*> e2;
	e2 += dfuncc;
	e2 += dguncc;
	e2.notify(5, "nihao");
	ASSERT_THAT(one->j, Eq(2));

	e2 -= dguncc;
	e2.notify(1, "world");
	ASSERT_THAT(one->j, Eq(3));


	BasicEvent<> ev;
	auto woppp = std::make_shared<TestHelperDo>();
	auto dfun = delegate(ConvertToWeakPtr(woppp), &TestHelperDo::fun);
	auto dgun = delegate(wo, &TestHelperDo::gun);
	ev += dfun;
	ev += dgun;

	woppp.reset();
	ev.notify();

	ev.remove(dfun);
	ev.remove(dgun);
	ASSERT_TRUE(ev.empty());
}

struct TestHelperA
{
	void fun() { cout << "void func" << endl; }
	void func() { cout << "func" << endl; }
	void gunc(int a) { cout << "gunc:" << a << endl; }
	void hunc(std::string& s) { cout << "hunc:" << s << endl; }
};

TEST(Plan_Event_Function, TestCustomMutex)
{
	struct lockandunlockT
	{
		void lock() {}
		void unlock() {}
	};

	BasicEvent<int> ei;
	TestHelperA a;
	auto d = delegate(&a, &TestHelperA::gunc);
	ei += d;

	BasicEventWithMutex<lockandunlockT, int> einl;
	einl += d;

	BasicEventNoMutex<int> ein2;
	ein2 += d;
}

struct XXE
{
	void ppp(const char*s) {
		auto tid = std::this_thread::get_id();
		cout << tid << ":" << endl;
		for (int i = 0; i < strlen(s); ++i)
		{
			cout.put(s[i]);
		}
		cout << endl;
	}
};

TEST(Plana_Event_Mult_Notify, test1)
{
	BasicEventNoMutex<const char*> e;
	auto x1 = std::make_shared<XXE>();
	auto x2 = std::make_shared<XXE>();
	auto x3 = std::make_shared<XXE>();
	auto x4 = std::make_shared<XXE>();

	auto x5 = std::make_shared<XXE>();
	auto x6 = std::make_shared<XXE>();
	auto x7 = std::make_shared<XXE>();
	auto x8 = std::make_shared<XXE>();

	auto x9 = std::make_shared<XXE>();
	auto x10 = std::make_shared<XXE>();
	auto x11 = std::make_shared<XXE>();
	auto x12 = std::make_shared<XXE>();

	auto x13 = std::make_shared<XXE>();
	auto x14 = std::make_shared<XXE>();
	auto x15 = std::make_shared<XXE>();
	auto x16 = std::make_shared<XXE>();

	e += delegate(ConvertToWeakPtr(x1), &XXE::ppp);
	e += delegate(ConvertToWeakPtr(x2), &XXE::ppp);
	e += delegate(ConvertToWeakPtr(x3), &XXE::ppp);
	e += delegate(ConvertToWeakPtr(x4), &XXE::ppp);

	e += delegate(ConvertToWeakPtr(x5), &XXE::ppp);
	e += delegate(ConvertToWeakPtr(x6), &XXE::ppp);
	e += delegate(ConvertToWeakPtr(x7), &XXE::ppp);
	e += delegate(ConvertToWeakPtr(x8), &XXE::ppp);

	e += delegate(ConvertToWeakPtr(x9), &XXE::ppp);
	e += delegate(ConvertToWeakPtr(x10), &XXE::ppp);
	e += delegate(ConvertToWeakPtr(x11), &XXE::ppp);
	e += delegate(ConvertToWeakPtr(x12), &XXE::ppp);

	e += delegate(ConvertToWeakPtr(x13), &XXE::ppp);
	e += delegate(ConvertToWeakPtr(x14), &XXE::ppp);
	e += delegate(ConvertToWeakPtr(x15), &XXE::ppp);
	e += delegate(ConvertToWeakPtr(x16), &XXE::ppp);

	const  int N = 1500;
	std::thread t[N];
	std::atomic<int> index = 0;
	for (int i = 0; i < N; ++i)
	{
		t[i] = std::thread([&index, &e, i](){
			char buf[32] = {0};
			sprintf_s(buf, sizeof buf, "t:%d", i);
			e.notify(buf);
			index++;
		});
	}

	for (int i = 0; i < N; ++i)
	{
		t[i].join();
	}
	ASSERT_EQ(index, N);
	cout << index << "end" << endl;
}

struct TEST_DELEGATE_A
{
	void print()
	{
		cout << "a" << endl;
	}
};

struct TEST_DELEGATE_B
{
	void print()
	{
		cout << "b" << endl;
	}
};

TEST(Plan_Event_Function, mul_type_delegate)
{
	

}

static void test_event_cb1(int a)
{
	cout << "test_event_cb1:" << a << endl;
}

static void test_event_cb1_1(int b)
{
	cout << "test_event_cb1_1" << b << endl;
}

static void test_event_cb2(const char* s)
{
	cout << "test_event_cb2" << s << endl;
}

static void test_event_cb3(int &b)
{
	cout << "test_event_cb3 begin" << b << endl;
	++b;
	cout << "test_event_cb3 end" << b << endl;
}

TEST(Plan_Event_Function, test_cb_ev)
{
	auto ev1 = delegate(test_event_cb1);
	ev1.notify(5);

	auto ev11 = delegate(test_event_cb1);
	ev11.notify(6);

	ASSERT_EQ(ev1, ev11);
	
	auto ev2 = delegate(test_event_cb1_1);
	ev2.notify(12);

	ASSERT_NE(ev2, ev1);
}

#endif // _UNIT_TEST_
