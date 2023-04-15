#pragma once
#include <list>
#include <mutex>

#include "mysql_connection.h"
#include <cppconn/driver.h>
#include <cppconn/exception.h>
#include <cppconn/resultset.h>
#include <cppconn/statement.h>
#include <cppconn/prepared_statement.h>

#include "tclog.h"

#define ERR_SUCC		0
#define ERR_FAILD		-1

#define LOG_SQLEXCEPTION	LOG_WARN(_T("ErrCode:%d, SqlState:%s, Message:%s"), e.getErrorCode(), e.getSQLState().c_str(), e.what())

// 获取并校验connector;
#define GET_AND_CHECK_CONN(connPool, retValue)	\
	sql::Connection *pConn = nullptr;\
	CAutoConnection oAuto(connPool, pConn);\
	std::unique_ptr<sql::PreparedStatement> pStmt(nullptr);\
	if (nullptr == pConn)\
			{\
		LOG_ERROR(_T("null connection."));\
		return retValue;\
			}

// 多结果集操作一定要确保调用到getMoreResults返回false为止，否则该连接上无法再进行任何查询操作
#define FREE_MORE_RESULTS(pConn, oAuto, pStmt)	\
	try\
	{\
		while (pStmt != nullptr && true == pStmt->getMoreResults());\
	}\
	catch (sql::SQLException &e)\
	{\
		oAuto.SetConnBad();\
		LOG_SQLEXCEPTION;\
	}

class CAutoConnection;

class CMysqlConnPool
{
public:
	CMysqlConnPool();
	virtual ~CMysqlConnPool();

	// sHostName格式示例："tcp://127.0.0.1:3306"
	int Init(const std::string &sHostName, const std::string &sUserName, const std::string &sPwd, const std::string &sDBName, int nPoolSize);
	void UnInit();
	
	sql::Connection *GetConnection();
	void GiveBackConnection(sql::Connection *pConn, bool bBad = false);

private:
	sql::Connection * Connect();
	bool ReConnect(sql::Connection *pConn);

	bool EraseConnFromUsinglist(const sql::Connection *pConn);
	void AddConnToFreelist(sql::Connection *pConn);
private:
	friend CAutoConnection;

	sql::Driver *m_pDriver;
	std::string m_sHostName;
	std::string m_sUserName;
	std::string m_sPwd;
	std::string m_sDBName;

	bool m_bInitSucc;
	int m_nMaxPoolSize;
	int m_nCurrentPollSize;

	std::mutex m_oConnListMutex;
	std::list<sql::Connection *> m_oFreeConnList;
	std::list<sql::Connection *> m_oUsingConnList;
};

class CAutoConnection
{
public:
	CAutoConnection(CMysqlConnPool &oConnPool, sql::Connection *&pConn)
		:m_oConnPool(oConnPool)
		, m_bBad(false)
	{
		m_pConn = oConnPool.GetConnection();
		pConn = m_pConn;
	}

	~CAutoConnection()
	{
		m_oConnPool.GiveBackConnection(m_pConn, m_bBad);
	}

	void SetConnBad()
	{
		m_bBad = true;
	}

private:
	CMysqlConnPool &m_oConnPool;
	sql::Connection *m_pConn;
	bool m_bBad;
};

