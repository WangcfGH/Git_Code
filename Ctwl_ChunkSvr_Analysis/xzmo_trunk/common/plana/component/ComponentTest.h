#pragma once
#ifdef _UNIT_TEST_
#include "gtest/gtest.h"
#include "gmock/gmock.h"
#include "Component.h"

using namespace std;
using namespace plana;
using namespace entitys;

namespace component_test
{
	TEST(Plana_Component_Test, test_type_index)
	{
		//https://en.cppreference.com/w/cpp/types/type_index
		// type_index ¨°y¨®?¦Ì??¡ã¡ê?¨¤¨¤D¨ª?¦Ì¨º??¨¤¨ª?¦Ì?¡ê?
#define TEST_TYPE_INDEX(t)	std::type_index(typeid(t));
		ASSERT_NE(std::type_index(typeid(int)), std::type_index(typeid(int*)));
		ASSERT_EQ(std::type_index(typeid(int)), std::type_index(typeid(int&)));
		ASSERT_NE(std::type_index(typeid(int*)), std::type_index(typeid(int&)));

		std::string *s = new std::string;
		// index -> sizeof(T)+1
		// std::size_t sz = sizeof(std::string);
		// malloc(sz) -> ptr
		// new(ptr) (args...)

		//delete
		//t->~T()
		//free(t);
	}

	TEST(Plana_Component_Test, test_assgin)
	{
		Entity e;
		e.assign<std::string>("hello world!");
		ASSERT_TRUE(e.has_component<std::string>());
		ASSERT_TRUE(e.has_component<std::string&>());
		ASSERT_STREQ(e.component<std::string>()->c_str(), "hello world!");

		std::string s("hello world!~");
		e.assign<std::string*>(&s);
		ASSERT_TRUE(e.has_component<std::string*>());
		ASSERT_STREQ(e.component<std::string*>()->c_str(), "hello world!~");

		e.share_assign<std::string>("hello world!~~");
		ASSERT_TRUE(e.has_component<std::shared_ptr<std::string>>());
		ASSERT_STREQ(e.share_component<std::string>()->c_str(), "hello world!~~");
	}

	struct TestCDACT
	{
		int &a;
		TestCDACT(int& n) :a(n)
		{
			a++;
		}
		~TestCDACT()
		{
			--a;
		}
	};

	TEST(Plana_Component_Test, test_decontract)
	{
		Entity e;
		int n = 0;
		e.assign<TestCDACT>(n);
		ASSERT_EQ(n, 1);
		e.remove<TestCDACT>();
		ASSERT_EQ(n, 0);

		e.share_assign<TestCDACT>(n);
		ASSERT_EQ(n, 1);
	}
}
#endif // _UNIT_TEST_
