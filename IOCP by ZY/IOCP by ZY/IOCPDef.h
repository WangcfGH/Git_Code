#pragma once
#define _WINSOCK_DEPRECATED_NO_WARNINGS

#include <WinSock2.h>
#include <MSWSock.h>
#include <MSTcpIP.h>//用于心跳包的头文件
#include <list>
#pragma comment(lib, "ws2_32.lib")

#define MAX_BUFFER_LEN					4096		// 江湖规矩一般为8k
#define WORKER_THREADS_PER_PROCESSOR	2
#define MAX_POST_ACCEPT					10			// 同时投递AcceptEx的请求数量
#define EXIT_CODE						NULL			

// 释放指针宏
#define RELEASE(x)                      {if(x != NULL ){delete x;x=NULL;}}
// 释放句柄宏
#define RELEASE_HANDLE(x)               {if(x != NULL && x!=INVALID_HANDLE_VALUE){ CloseHandle(x);x = NULL;}}
// 释放Socket宏
#define RELEASE_SOCKET(x)               {if(x !=INVALID_SOCKET) { closesocket(x);x=INVALID_SOCKET;}}

////////////////////////////////////////////////////////////////////
#define	NC_CLIENT_CONNECT		0x0001
#define	NC_CLIENT_DISCONNECT	0x0002
#define	NC_TRANSMIT				0x0003
#define	NC_RECEIVE				0x0004
#define NC_RECEIVE_COMPLETE		0x0005 // 完整接收

//////////////////////////////////////////////////////////////////
// 在完成端口上投递的I/O操作的类型
typedef enum _IOType
{
	IOAccept,						 // 标志投递的 Accept初始化操作
	IOSend,							 // 标志投递的是 发送操作(写)
	IORecv,							 // 标志投递的是 接收操作(读)
	IOIdle					   	     // 用于初始化，无意义
}IOType;

//====================================================================================
//				单IO数据结构体定义(用于每一个重叠操作的参数)
//====================================================================================
struct PER_IO_CONTEXT
{
	OVERLAPPED     m_ol;										// 每一个重叠网络操作的重叠结构(针对每一个Socket的每一个操作，都要有一个)              
	WSABUF         m_wsaBuf;                                    // WSA类型的缓冲区，用于给重叠操作传参数的
	SOCKET         m_sock;									    // 接收到的连接的套接字 
	SOCKADDR_IN	   m_addr;										// 套接字地址信息
	char           m_szBuf[MAX_BUFFER_LEN];		                // 这个是WSABUF里具体存字符的缓冲区
	IOType		   m_ioType;                                    // 标识网络操作的类型(对应上面的枚举)
	DWORD		   m_dwBytesSend;	                            // 发送的字节数
	DWORD		   m_dwBytesRecv;								// 接收的字节数

	void Clear()
	{
		ZeroMemory(&m_ol, sizeof(OVERLAPPED));
		ZeroMemory(m_szBuf, MAX_BUFFER_LEN);
		ZeroMemory(&m_addr, sizeof(SOCKADDR_IN));
		m_sock = INVALID_SOCKET;
		m_wsaBuf.buf = m_szBuf;
		m_wsaBuf.len = MAX_BUFFER_LEN;
		m_ioType = IOIdle;
		m_dwBytesSend = 0;
		m_dwBytesRecv = 0;
	}
};

struct IOCP_PARAM					 // 完成端口传递的参数
{
	SOCKET m_sock;
};