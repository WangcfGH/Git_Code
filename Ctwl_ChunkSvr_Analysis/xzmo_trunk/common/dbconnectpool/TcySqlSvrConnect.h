#pragma once
#include <iostream>
#include <chrono>
#include <map>
#include <functional>

#include <msado15.tlh>
#include <msjro.tlh>

/*
参考：
https://blog.csdn.net/Timeinsist/article/details/80545988
https://blog.csdn.net/aasmfox/article/details/6536123

微软官方文档
还有公司已有项目的代码


这个回答反馈了 GetRecordCount 返回值的问题
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
	std::string				sql_text;						// 执行语句
	CommandTypeEnum			sql_cmdType = adCmdText;		// 执行类型
	CursorTypeEnum			sql_cursorType = adOpenStatic;	// 游标类型
	LockTypeEnum			sql_lockType = adLockOptimistic;// 锁类型
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

	// 事务接口
	// 尽量使用 SqlsvrTransScope 而不是手动begin和commit,这样可以避免漏掉commit或rollback
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

	// 最近的一次mysql操作时间
	std::chrono::system_clock::time_point m_tpLastMqlCon;
	// 如果上一次操作mysql出现异常,则设置为true，这样下一次再操作mysql的时候，会强制检查有效性
	bool m_mqlConBad;

	_ConnectionPtr m_sqlCon;
	std::string m_sConnect;
};