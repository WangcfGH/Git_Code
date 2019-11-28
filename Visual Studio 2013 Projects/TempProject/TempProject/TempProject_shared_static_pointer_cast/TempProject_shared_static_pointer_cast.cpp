// TempProject_shared_static_pointer_cast.cpp : 定义控制台应用程序的入口点。
//

//当我们用“裸”指针进行类层次上的上下行转换时，可以使用dynamic_cast。当然我们也可以使用static_cast，只是dynamic_cast在进行下行转换的时候（即基类到派生类）具有类型检查功能，而static_cast没有。因此存在安全问题。
//
//当我们使用智能指针时，如果需要进行类层次上的上下行转换时，可以使用boost::static_pointer_cast和boost::dynamic_pointer_cast。（C++11中也支持智能指针和转换，只是命名空间改成std即可）。
//-------------------- -
//作者：huangjh2018
//来源：CSDN
//原文：https ://blog.csdn.net/huangjh2017/article/details/74276134 
//版权声明：本文为博主原创文章，转载请附上博文链接！



#include "stdafx.h"
#include <memory>
#include <iostream>
#include <iostream>
using namespace std;

class CBase
{
public:
	CBase() { }
	virtual ~CBase() { }

	void myBase()
	{
		cout << "CBase::myBase" << endl;
	}
};

class CDerive : public CBase
{
public:
	CDerive() { }
	~CDerive() { }

	void myDerive()
	{
		cout << "CDerive::myDerive" << endl;
	}
};

//1. static_pointer_cast
int _tmain(int argc, _TCHAR* argv[])
{
	//上行的转换（派生类到基类的转换）
	shared_ptr<CDerive> spDeriveUp;
	shared_ptr<CBase> spBaseUp;
	spDeriveUp = make_shared<CDerive>();
	spBaseUp = static_pointer_cast<CBase>(spDeriveUp);
	spBaseUp->myBase();

	//下行的转换（基类到派生类的转换）这是不安全的
	shared_ptr<CDerive> spDeriveDown;
	shared_ptr<CBase> spBaseDown;
	spBaseDown = make_shared<CBase>();
	spDeriveDown = static_pointer_cast<CDerive>(spBaseDown);
	spDeriveDown->myBase();		//不允许访问myDerive

	return 0;
}

////2. dynamic_pointer_cast
//int _tmain(int argc, _TCHAR* argv[])
//{
//	//上行的转换（派生类到基类的转换）
//	shared_ptr<CDerive> spDeriveUp;
//	shared_ptr<CBase> spBaseUp;
//	spDeriveUp = make_shared<CDerive>();
//	spBaseUp = dynamic_pointer_cast<CBase>(spDeriveUp);
//	spBaseUp->myBase();
//
//	//下行的转换（基类到派生类的转换)
//	shared_ptr<CDerive> spDeriveDown;
//	shared_ptr<CBase> spBaseDown;
//	spBaseDown = make_shared<CBase>();
//	spDeriveDown = dynamic_pointer_cast<CDerive>(spBaseDown);
//	if (spDeriveDown == NULL)	//由于会进行类型的检查，这边是返回NULL
//		cout << "spDeriveDown is null" << endl;
//
//	return 0;
//}
//
////3. const_pointer_cast
//int _tmain(int argc, _TCHAR* argv[])
//{
//	{
//		shared_ptr<int> spInt;
//		shared_ptr<const int> spConstInt;
//
//		spInt = make_shared<int>(100);
//		spConstInt = const_pointer_cast<const int>(spInt);
//		cout << "*spConstInt = " << *spConstInt << endl;
//	}
//
//	{
//		shared_ptr<int> spInt;
//		shared_ptr<const int> spConstInt;
//		//事实上不允许通过spInt修改值
//		spConstInt = make_shared<const int>(100);
//		spInt = const_pointer_cast<int>(spConstInt);
//		cout << "*spInt = " << *spInt << endl;
//	}
//
//	return 0;
//}