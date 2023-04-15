#include "stdafx.h"
#include "TcyMySqlConnect.h"

class MysqlConnectorImp
{
public:
	MysqlConnectorImp() {
		std::call_once(onceInit, [](){
			bool ret = true;
			try{
				pDriver = get_driver_instance();
			}
			catch (sql::SQLException &e) {
				LOG_WARN(_T("ErrCode:%d, SqlState:%s, Message:%s"), e.getErrorCode(), e.getSQLState().c_str(), e.what());
				LOG_ERROR("global mysql driver init error!");
				ret = false;
			}
			return ret;
		});
	}
	static std::once_flag onceInit;
	static sql::Driver* pDriver;
};
// mysql connector ��Դ����ʾ��driver�ᱣ�浽һ��map��,��Ҳ�޷��ͷţ�ֻ�ܵȽ��̽���
// ���ԣ���ֱ�Ӱ�����������ֻ����һ��ʵ��������ֻ�ṩ��ʼ�������ṩ�ͷţ����ҳ�ʼ��Ҫ�̰߳�ȫ
sql::Driver* MysqlConnectorImp::pDriver = nullptr;
std::once_flag MysqlConnectorImp::onceInit;

std::unique_ptr<MysqlConnectorImp> MysqlConnector::m_imp;
MysqlConnector::MysqlConnector()
{

}

MysqlConnector::~MysqlConnector()
{
	
}

void MysqlConnector::init()
{
	m_imp = std::make_unique<MysqlConnectorImp>();
}

void MysqlConnector::beginThread()
{
	m_imp->pDriver->threadInit();
}

void MysqlConnector::endThread()
{
	m_imp->pDriver->threadEnd();
}

sql::Connection* MysqlConnector::getConnect(
	const std::string& sHostName, 
	const std::string& sUserName, 
	const std::string& sPwd)
{
	auto* con = m_imp->pDriver->connect(sHostName, sUserName, sPwd);
	return con;
}

//////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////
#define ERR_SUCC		0
#define ERR_FAILD		-1

#define LOG_SQLEXCEPTION	LOG_WARN(_T("ErrCode:%d, SqlState:%s, Message:%s"), e.getErrorCode(), e.getSQLState().c_str(), e.what())
// ����������һ��Ҫȷ�����õ�getMoreResults����falseΪֹ��������������޷��ٽ����κβ�ѯ����
#define FREE_MORE_RESULTS(pStmt)	while (pStmt != nullptr && true == pStmt->getMoreResults());


MysqlSession::MysqlSession()
	
{
	m_tpLastMqlCon = std::chrono::system_clock::now();
	m_mqlConBad = false;
}


MysqlSession::~MysqlSession()
{

}

void MysqlSession::mysql_set_connectInfo(const std::string& szHost, const std::string& szUser, const std::string& szPwd, const std::string& szDbName)
{
	m_szHostName = szHost;
	m_szUser = szUser;
	m_szPwd = szPwd;
	m_szDbName = szDbName;
}

void MysqlSession::mysql_connect()
{
	pCon.reset(MysqlConnector::getConnect(
		m_szHostName, m_szUser, m_szPwd));
	pCon->setSchema(m_szDbName);
}

std::pair<int, std::size_t> MysqlSession::mysql_excute(const std::string& stm, std::function<int(sql::ResultSet*)> op)
{
	std::pair<int, std::size_t> r{ 0, 0 };
	try {
		mysql_check_con();
		std::unique_ptr<sql::PreparedStatement> pStmt(pCon->prepareStatement(stm.c_str()));
		pStmt->execute();
		std::unique_ptr<sql::ResultSet> pRes(pStmt->getResultSet());
		r.second = op(pRes.get());
		FREE_MORE_RESULTS(pStmt);
	}
	catch (sql::SQLException &e)
	{
		LOG_SQLEXCEPTION;
		m_mqlConBad = true;
		r.first = e.getErrorCode();
		r.first = r.first == 0 ? -1 : r.first;
		UwlTrace(_T("database access error!"));
		UwlLogFile(_T("database access error!"));
		UwlLogFile(_T("sql: exec %s"), stm.c_str());
	}
	return r;
}

int MysqlSession::mysql_excute(const std::string& stm)
{
	LONG errcode = 0;
	try {
		mysql_check_con();
		std::unique_ptr<sql::PreparedStatement> pStmt(pCon->prepareStatement(stm.c_str()));
		pStmt->execute();
		std::unique_ptr<sql::ResultSet> pRes(pStmt->getResultSet());
		FREE_MORE_RESULTS(pStmt);
	}
	catch (sql::SQLException &e)
	{
		LOG_SQLEXCEPTION;
		m_mqlConBad = true;
		errcode = e.getErrorCode();
		errcode = errcode == 0 ? -1 : errcode;
		UwlTrace(_T("database access error!"));
		UwlLogFile(_T("database access error!"));
		UwlLogFile(_T("sql: exec %s"), stm.c_str());
	}
	return errcode;
}

void MysqlSession::mysql_check_con()
{
	// ˢ�¼��ʱ��
	auto lastTp = m_tpLastMqlCon;
	m_tpLastMqlCon = std::chrono::system_clock::now();
	bool forceCheckValid = m_mqlConBad;
	m_mqlConBad = false;
	try {
		if (!pCon) {
			// ����鵽pConΪnil��ʱ�����´���
			pCon.reset(MysqlConnector::getConnect(m_szHostName, m_szUser, m_szPwd));
			if (pCon) {
				pCon->setSchema(m_szDbName);
				return;
			}
			char buffer[4096];
			ZeroMemory(buffer, sizeof(buffer));
			sprintf_s(buffer, "MysqlConnect Error:%s,%s,%s",
				m_szHostName.c_str(), m_szUser.c_str(), m_szPwd.c_str());
			throw sql::SQLException(buffer);
		}

		// ǰ�ü����Ч�Ե�ʱ�򣬺���ʱ����
		if (!forceCheckValid) {
			auto dur = std::chrono::duration_cast<std::chrono::hours>(m_tpLastMqlCon - lastTp);
			if (dur.count() < 6) {
				// ֻ�г���6��Сʱ�޲������Ż����mysql con��Ч�Լ��
				return;
			}
		}

		if (pCon->isValid()) {
			return;
		}

		// ����
		bool r = false;
		r = pCon->reconnect();
		pCon->setSchema(m_szDbName);
		if (r) {
			return;
		}

		// ����ʧ�ܣ��������´���һ��
		pCon.reset(MysqlConnector::getConnect(m_szHostName, m_szUser, m_szPwd));
		if (pCon) {
			pCon->setSchema(m_szDbName);
			return;
		}
		char buffer[4096];
		ZeroMemory(buffer, sizeof(buffer));
		sprintf_s(buffer, "MysqlConnect Error:%s,%s,%s",
			m_szHostName.c_str(), m_szUser.c_str(), m_szPwd.c_str());
		throw sql::SQLException(buffer);
	}
	catch (...) {
		// ����������ֻҪ�������쳣�������׳�ȥ�����ⲿ����
		std::rethrow_exception(std::current_exception());
	}
}
