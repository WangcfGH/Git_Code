// ConsoleApplication1.cpp : 定义控制台应用程序的入口点。
//

#include "stdafx.h"
#include <vector>


int _tmain(int argc, _TCHAR* argv[])
{	
	int i;
	std::vector<int> vt;

	vt.push_back(1);

	std::vector<int>::iterator it;

	for (it = vt.begin(); it != vt.end(); it++)
		memcpy(&i, &(*it), sizeof(int));
	
	printf("%d\n", i);

	return 0;
}

