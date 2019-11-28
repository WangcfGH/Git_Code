// CriticalSection.cpp : 定义控制台应用程序的入口点。
//

#include "stdafx.h"
#include "iostream"
#include "afxwin.h"
#include "windows.h"
using namespace std;

CRITICAL_SECTION cs;		//可以理解为锁定一个资源
static int n_AddValue = 0;	//定义一个静态的全部变量n_AddValue

//第一个线程
UINT FirstThread(LPVOID lParam)
{
	EnterCriticalSection(&cs);//加锁 接下来的代码处理过程中不允许其他线程进行操作，除非遇到LeaveCriticalSection
	for (int i = 0; i < 10; i++){
		n_AddValue++;
		cout << "n_AddValue in FirstThread is " << n_AddValue << endl;

	}
	LeaveCriticalSection(&cs);//解锁 到EnterCriticalSection之间代码资源已经释放了，其他线程可以进行操作   
	return 0;
}

//第一个线程
UINT FirstThread_2(LPVOID lParam)
{
	for (int i = 0; i < 10; i++){
		EnterCriticalSection(&cs);//加锁 接下来的代码处理过程中不允许其他线程进行操作，除非遇到LeaveCriticalSection
		n_AddValue++;
		cout << "n_AddValue in FirstThread_2 is " << n_AddValue << endl;
		LeaveCriticalSection(&cs);//解锁 到EnterCriticalSection之间代码资源已经释放了，其他线程可以进行操作   
	}
	return 0;
}

//第二个线程
UINT SecondThread(LPVOID lParam)
{
	EnterCriticalSection(&cs);//加锁
	for (int i = 0; i < 10; i++){
		n_AddValue++;
		cout << "n_AddValue in SecondThread is " << n_AddValue << endl;

	}
	LeaveCriticalSection(&cs);//解锁

	return 0;
}

//第二个线程
UINT SecondThread_2(LPVOID lParam)
{
	for (int i = 0; i < 10; i++){
		EnterCriticalSection(&cs);//加锁
		n_AddValue++;
		cout << "n_AddValue in SecondThread_2 is " << n_AddValue << endl;
		LeaveCriticalSection(&cs);//解锁
	}

	return 0;
}

//在主函数添加以下代码
int _tmain(int argc, TCHAR* argv[], TCHAR* envp[])
{
	int nRetCode = 0;

	// 初始化 MFC 并在失败时显示错误
	if (!AfxWinInit(::GetModuleHandle(NULL), NULL, ::GetCommandLine(), 0))
	{
		// TODO: 更改错误代码以符合您的需要
		_tprintf(_T("错误: MFC 初始化失败/n"));
		nRetCode = 1;
	}
	else
	{

		InitializeCriticalSection(&cs);//初始化结构CRITICAL_SECTION


		CWinThread *pFirstThread, *pSecondThread;//存储函数AfxBeginThread返回的CWinThread指针

		pFirstThread = AfxBeginThread(FirstThread, LPVOID(NULL));//启动第一个线程
		pSecondThread = AfxBeginThread(SecondThread, LPVOID(NULL));//启动第二个线程

		HANDLE hThreadHandle[2];
		hThreadHandle[0] = pFirstThread->m_hThread;
		hThreadHandle[1] = pSecondThread->m_hThread;

		//等待线程返回
		WaitForMultipleObjects(2, hThreadHandle, TRUE, INFINITE);

		CWinThread *pFirstThread_2, *pSecondThread_2;//存储函数AfxBeginThread返回的CWinThread指针

		pFirstThread_2 = AfxBeginThread(FirstThread_2, LPVOID(NULL));//启动第一个线程
		pSecondThread_2 = AfxBeginThread(SecondThread_2, LPVOID(NULL));//启动第二个线程

		HANDLE hThreadHandle_2[2];
		hThreadHandle_2[0] = pFirstThread_2->m_hThread;
		hThreadHandle_2[1] = pSecondThread_2->m_hThread;

		//等待线程返回
		WaitForMultipleObjects(2, hThreadHandle_2, TRUE, INFINITE);
	}

	getchar();
	getchar();

	return nRetCode;
}