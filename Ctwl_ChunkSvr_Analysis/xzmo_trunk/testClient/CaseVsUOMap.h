#pragma once
#include <iostream>
#include <unordered_map>
#include <chrono>

/*
	����unorder_map ����case�Ĵ���
	���ۣ����Ż�����������£����Ժ������ߵĲ��
*/
class CaseVsUOMap
{
public:
	CaseVsUOMap();
	~CaseVsUOMap();

	void IfElseInvoke(int n);

	pair<int64_t, int64_t> TestUOMapVSIfElse();
	void OnTest(const std::string& cmd);

	unordered_map<int, function<void()>> m_id2func;
};

