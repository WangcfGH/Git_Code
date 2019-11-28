#include "stdafx.h"

struct TEST{
	int a;
	int b;
	int c;
	TEST(int a, int b, int c) : a(a), b(b), c(c){}
	TEST(const TEST& other)
	{
		a = other.a;
		b = other.b;
		c = other.c;
	}
};

#include<map>
#include<algorithm>
#include<iostream>

using namespace std;

class  Cmp{
public:
	bool operator()(const TEST& lhs, const TEST& rhs)const
	{
		if (lhs.a != rhs.a)
		{
			return lhs.a < rhs.a;
		}
		else
		{
			if (lhs.b != rhs.b)
			{
				return lhs.b < rhs.b;
			}
			else
			{
				return lhs.c < rhs.c;
			}
		}
	}

};

int _tmain(int argc, _TCHAR* argv[])
{

	TEST a[] = { { 5, 4, 6 }, { 6, 1, 1 }, { 7, 1, 1 }, { 8, 1, 1 }, { 9, 1, 1 }, { 9, 2, 2 }, { 9, 3, 3 }, { 9, 4, 4 }, { 9, 5, 5 }, { 9, 6, 6 }, { 9, 7, 7 }, { 9, 8, 8 }, { 1, 3, 7 }, { 2, 5, 8 }, { 3, 1, 4 }, { 3, 2, 3 }, { 3, 2, 5 }, { 3, 2, 7 }, { 3, 2, 9 }, { 4, 3, 2 } };
	std::map<TEST, bool, Cmp> oTestMap;
	cout << sizeof(a) / sizeof(TEST) << endl;
	for_each(a, a + sizeof(a) / sizeof(TEST), [&](const TEST& tmp)
	{
		oTestMap.insert(make_pair(tmp, true));
	});
	for_each(begin(oTestMap), end(oTestMap), [](pair<TEST, bool> tmp)
	{
		auto x = tmp.first;
		cout << x.a << ' ' << x.b << ' ' << x.c << endl;
	});
	system("pause");
	return 0;
}
