#include "stdafx.h"
#include "CaseVsUOMap.h"


#define AUTO_INSERT_I2F(n)  m_id2func[n] = [](){volatile int m = n + 1;;};
#define AUTO_SWITCH_PN(n)   case n: {volatile int m = n + 1;;}break;
CaseVsUOMap::CaseVsUOMap()
{
	AUTO_INSERT_I2F(0);
	AUTO_INSERT_I2F(1);
	AUTO_INSERT_I2F(2);
	AUTO_INSERT_I2F(3);
	AUTO_INSERT_I2F(4);
	AUTO_INSERT_I2F(5);
	AUTO_INSERT_I2F(6);
	AUTO_INSERT_I2F(7);
	AUTO_INSERT_I2F(8);
	AUTO_INSERT_I2F(9);
	AUTO_INSERT_I2F(10)
	AUTO_INSERT_I2F(11);
	AUTO_INSERT_I2F(12);
	AUTO_INSERT_I2F(13);
	AUTO_INSERT_I2F(14);
	AUTO_INSERT_I2F(15);
	AUTO_INSERT_I2F(16);
	AUTO_INSERT_I2F(17);
	AUTO_INSERT_I2F(18);
	AUTO_INSERT_I2F(19);
	AUTO_INSERT_I2F(20);
	AUTO_INSERT_I2F(21);
	AUTO_INSERT_I2F(22);
	AUTO_INSERT_I2F(23);
	AUTO_INSERT_I2F(24);
	AUTO_INSERT_I2F(25);
	AUTO_INSERT_I2F(26);
	AUTO_INSERT_I2F(27);
	AUTO_INSERT_I2F(28);
	AUTO_INSERT_I2F(29);
}


CaseVsUOMap::~CaseVsUOMap()
{
}

void CaseVsUOMap::IfElseInvoke(int n)
{
	switch (n)
	{
		AUTO_SWITCH_PN(0)
			AUTO_SWITCH_PN(1)
			AUTO_SWITCH_PN(2)
			AUTO_SWITCH_PN(3)
			AUTO_SWITCH_PN(4)
			AUTO_SWITCH_PN(5)
			AUTO_SWITCH_PN(6)
			AUTO_SWITCH_PN(7)
			AUTO_SWITCH_PN(8)
			AUTO_SWITCH_PN(9)
			AUTO_SWITCH_PN(10)
			AUTO_SWITCH_PN(11)
			AUTO_SWITCH_PN(12)
			AUTO_SWITCH_PN(13)
			AUTO_SWITCH_PN(14)
			AUTO_SWITCH_PN(15)
			AUTO_SWITCH_PN(16)
			AUTO_SWITCH_PN(17)
			AUTO_SWITCH_PN(18)
			AUTO_SWITCH_PN(19)
			AUTO_SWITCH_PN(20)
			AUTO_SWITCH_PN(21)
			AUTO_SWITCH_PN(22)
			AUTO_SWITCH_PN(23)
			AUTO_SWITCH_PN(24)
			AUTO_SWITCH_PN(25)
			AUTO_SWITCH_PN(26)
			AUTO_SWITCH_PN(27)
			AUTO_SWITCH_PN(28)
			AUTO_SWITCH_PN(29)
	default:
		break;
	}
}

std::pair<int64_t, int64_t> CaseVsUOMap::TestUOMapVSIfElse()
{
	auto t = chrono::system_clock::now();
	for (int i = 0; i < 2000000; ++i) {
		auto n = i % 30;
		m_id2func.find(n)->second();
	}
	auto diff1 = chrono::duration_cast<chrono::milliseconds>(chrono::system_clock::now() - t);


	t = chrono::system_clock::now();
	for (int i = 0; i < 2000000; ++i) {
		auto n = i % 30;
		IfElseInvoke(n);
	}
	auto diff2 = chrono::duration_cast<chrono::milliseconds>(chrono::system_clock::now() - t);

	return make_pair(diff1.count(), diff2.count());
}

void CaseVsUOMap::OnTest(const std::string& cmd)
{
	if (cmd == "ifelseuomap") {
		vector<pair<int64_t, int64_t>> s;
		for (size_t i = 0; i < 5; i++)
		{
			s.emplace_back(TestUOMapVSIfElse());
		}
		cout << endl;
		for (auto& i : s) {
			cout << i.first << "-" << i.second << ",";
		}
	}
}
