#pragma once
#include <iostream>
#include <chrono>
#include <map>
#include <functional>

#include <msado15.tlh>
#include <msjro.tlh>

/*
�ο���
https://blog.csdn.net/Timeinsist/article/details/80545988
https://blog.csdn.net/aasmfox/article/details/6536123

΢��ٷ��ĵ�
���й�˾������Ŀ�Ĵ���


����ش����� GetRecordCount ����ֵ������
https://zhidao.baidu.com/question/17972552.html
*/

namespace sqlsvrutils
{
	inline void TESTHR(HRESULT x);

	void _TraceProviderError(_ConnectionPtr pConnection);

	void LogProviderError(_ConnectionPtr pConnection);

	void LogComError(_com_error& e);

	void _TraceComError(_com_error& e);

	std::string SqlCommdArgs(const char* fmt, ...);
};


struct SqlCommandState
{
	std::string				sql_text;						// ִ�����
	CommandTypeEnum			sql_cmdType = adCmdText;		// ִ������
	CursorTypeEnum			sql_cursorType = adOpenStatic;	// �α�����
	LockTypeEnum			sql_lockType = adLockOptimistic;// ������
};

class SqlSvrSession
{
public:
	SqlSvrSession();
	~SqlSvrSession();

	void set_sqlsvr_info(const std::string& sConnect) {
		m_sConnect = sConnect;
	}

	std::pair<HRESULT, std::size_t> sqlsvr_excute(std::function<int(_ConnectionPtr&)> invoke);
	HRESULT sqlsvr_excute(SqlCommandState& cmder);
	std::pair<HRESULT, std::size_t> sqlsvr_excute(SqlCommandState& cmder, std::function<int(_RecordsetPtr&)> result);

	// ����ӿ�
	// ����ʹ�� SqlsvrTransScope �������ֶ�begin��commit,�������Ա���©��commit��rollback
	struct SqlsvrTransScope
	{
	private:
		SqlSvrSession* con;
		bool ok = false;
		bool bad = false;
	public:
		SqlsvrTransScope(SqlSvrSession* session) :con(session) {
			ok = session->sqlsvr_beginTrans() == S_OK;
		}
		bool check() { return ok; }
		void setbad(bool b) { bad = b; }
		~SqlsvrTransScope() {
			if (ok) {
				if (!bad) {
					if (con->sqlsvr_commit() != S_OK) {
						LOG_ERROR("sqlsver trans close error");
					}
				}
				else {
					if (con->sqlsvr_rollback() != S_OK) {
						LOG_ERROR("sqlsver trans rollback error");
					}
				}
			}
		}
	};
	HRESULT sqlsvr_beginTrans();
	HRESULT sqlsvr_rollback();
	HRESULT sqlsvr_commit();
	_ConnectionPtr sqlsvr_connectPtr() {
		return m_sqlCon;
	}
protected:
	BOOL sqlsvr_open();
	BOOL sqlsvr_test();
	void sqlsvr_close();
	void check_connect();

	// �����һ��mysql����ʱ��
	std::chrono::system_clock::time_point m_tpLastMqlCon;
	// �����һ�β���mysql�����쳣,������Ϊtrue��������һ���ٲ���mysql��ʱ�򣬻�ǿ�Ƽ����Ч��
	bool m_mqlConBad;

	_ConnectionPtr m_sqlCon;
	std::string m_sConnect;
};