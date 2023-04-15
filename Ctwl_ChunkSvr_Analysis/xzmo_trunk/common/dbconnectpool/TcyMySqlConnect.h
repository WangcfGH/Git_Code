#pragma once
#include <iostream>
#include <memory>
#include <mysql_connection.h>
#include <cppconn/driver.h>
#include <cppconn/exception.h>
#include <cppconn/resultset.h>
#include <cppconn/statement.h>
#include <cppconn/prepared_statement.h>

namespace sql
{
	class Connection;
	class PreparedStatement;
	class ResultSet;
}

class MysqlConnectorImp;
class MysqlConnector
{
public:
	MysqlConnector();
	~MysqlConnector();
	
	static void init();
	static void beginThread();
	static void endThread();
	static sql::Connection* getConnect(const std::string& sHostName, const std::string& sUserName, const std::string& sPwd);

private:
	static std::unique_ptr<MysqlConnectorImp> m_imp;
};

class MysqlSession
{
public:
	MysqlSession();
	~MysqlSession();

	void mysql_set_connectInfo(const std::string& szHost,
		const std::string& szUser,
		const std::string& szPwd,
		const std::string& szDbName);

	void mysql_connect();

	// ����ֵfirst��err��ֻҪ��0���Ǵ���
	// ����ֵsecond�ǽ�����ĸ���
	// �ڶ���������һ��ִ�н���������ĺ����������ؽ���ĸ���
	std::pair<int, std::size_t> mysql_excute(const std::string& stm, std::function<int(sql::ResultSet*)> op);
	int mysql_check_result(std::pair<int, std::size_t> res) {
		if (res.first) return res.first;
		if (res.second <= 0) return -1;
		return 0;
	}
	// ִ��һ��sql��䣬�޷��ؽ��
	// ����ֵ:0 ����;����ֵ �쳣
	int mysql_excute(const std::string& stm);
	// ÿ����ʹ��sqlconǰ������һ�μ�飬sql�Ƿ���Ч
	void mysql_check_con();

protected:
	// �����һ��mysql����ʱ��
	std::chrono::system_clock::time_point m_tpLastMqlCon;
	// �����һ�β���mysql�����쳣,������Ϊtrue��������һ���ٲ���mysql��ʱ�򣬻�ǿ�Ƽ����Ч��
	bool m_mqlConBad;

	std::string m_szHostName;
	std::string m_szUser;
	std::string m_szPwd;
	std::string m_szDbName;

	std::unique_ptr<sql::Connection> pCon;
};