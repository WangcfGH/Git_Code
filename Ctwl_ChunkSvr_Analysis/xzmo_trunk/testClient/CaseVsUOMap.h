#pragma once
#include <iostream>
#include <unordered_map>
#include <chrono>

/*
	评测unorder_map 代替case的代价
	结论：在优化开启的情况下，可以忽略两者的差距
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

