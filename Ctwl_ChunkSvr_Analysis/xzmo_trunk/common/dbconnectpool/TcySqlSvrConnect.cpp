#include "StdAfx.h"
#include "TcySqlSvrConnect.h"
#include <tclog.h>

namespace sqlsvrutils {

	inline void TESTHR(HRESULT x) { if FAILED(x) _com_issue_error(x); };

	void _TraceProviderError(_ConnectionPtr pConnection)
	{
		// Print Provider Errors from Connection object.
		// pErr is a record object in the Connection's Error collection.
		ErrorPtr  pErr = NULL;

		if ((pConnection->Errors->Count) > 0) {
			long nCount = pConnection->Errors->Count;
			// Collection ranges from 0 to nCount -1.
			for (long i = 0; i < nCount; i++) {
				pErr = pConnection->Errors->GetItem(i);
				LOG_TRACE(_T("\t Error number: %x\t%s"), pErr->Number,
					(LPCTSTR)pErr->Description);
				LOG_TRACE(_T("\t Error native: %d\t%s"), pErr->NativeError,
					(LPCTSTR)pErr->SQLState);
			}
		}
	}

	void LogProviderError(_ConnectionPtr pConnection)
	{
		// Print Provider Errors from Connection object.
		// pErr is a record object in the Connection's Error collection.
		ErrorPtr  pErr = NULL;

		if ((pConnection->Errors->Count) > 0) {
			long nCount = pConnection->Errors->Count;
			// Collection ranges from 0 to nCount -1.
			for (long i = 0; i < nCount; i++) {
				pErr = pConnection->Errors->GetItem(i);
				LOG_ERROR(_T("\t Error number: %x\t%s"), pErr->Number,
					(LPCTSTR)pErr->Description);
				LOG_ERROR(_T("\t Error native: %d\t%s"), pErr->NativeError,
					(LPCTSTR)pErr->SQLState);
			}
		}
	}

	void LogComError(_com_error& e)
	{
		_bstr_t bstrSource(e.Source());
		_bstr_t bstrDescription(e.Description());

		// Print Com errors.
		LOG_ERROR(_T("Error\n"));
		LOG_ERROR(_T("\tCode = %08lx\n"), e.Error());
		LOG_ERROR(_T("\tCode meaning = %s\n"), e.ErrorMessage());
		LOG_ERROR(_T("\tSource = %s\n"), (LPCTSTR)bstrSource);
		LOG_ERROR(_T("\tDescription = %s\n"), (LPCTSTR)bstrDescription);
	}

	void _TraceComError(_com_error& e)
	{
		_bstr_t bstrSource(e.Source());
		_bstr_t bstrDescription(e.Description());

		// Print Com errors.
		UwlTrace(_T("Error\n"));
		UwlTrace(_T("\tCode = %08lx\n"), e.Error());
		UwlTrace(_T("\tCode meaning = %s\n"), e.ErrorMessage());
		UwlTrace(_T("\tSource = %s\n"), (LPCTSTR)bstrSource);
		UwlTrace(_T("\tDescription = %s\n"), (LPCTSTR)bstrDescription);
	}

	std::string SqlCommdArgs(const char* fmt, ...)
	{
		char buffer[2048] = { 0 };
		va_list va;
		va_start(va, fmt);
		vsprintf_s(buffer, sizeof(buffer) - 1, fmt, va);
		va_end(va);
		return std::string(buffer);
	}

}

using namespace sqlsvrutils;
SqlSvrSession::SqlSvrSession()
{
	m_tpLastMqlCon = std::chrono::system_clock::now();
	m_mqlConBad = false;
}

SqlSvrSession::~SqlSvrSession()
{

}

BOOL SqlSvrSession::sqlsvr_open()
{
	HRESULT hr = m_sqlCon.CreateInstance(__uuidof(Connection));
	if (FAILED(hr)) return FALSE;
	sqlsvrutils::TESTHR(m_sqlCon->Open(m_sConnect.c_str(), "", "", adConnectUnspecified));
	return m_sqlCon->State != adStateClosed;
}

BOOL SqlSvrSession::sqlsvr_test()
{
	try
	{
		// 不需要它的返回值，因为该调用，主要为了判断链接是否正常；
		// 链接断开，就会抛出异常来，由此区分TRUE和FALSE
		_RecordsetPtr pRecordset = NULL;
		sqlsvrutils::TESTHR(pRecordset.CreateInstance(__uuidof(Recordset)));
		sqlsvrutils::TESTHR(pRecordset->Open("select GETDATE() AS CurTime", _variant_t((IDispatch*)m_sqlCon, true),
			adOpenStatic, adLockOptimistic, adCmdText));
		sqlsvrutils::TESTHR(pRecordset);
		sqlsvrutils::TESTHR(pRecordset->Close());
	}
	catch (_com_error & e) {
		return FALSE;
	}

	return TRUE;
}

void SqlSvrSession::sqlsvr_close()
{
	try {
		if (m_sqlCon) {
			m_sqlCon->Close();
			m_sqlCon = NULL;
		}
	}
	catch (_com_error e) {
		sqlsvrutils::_TraceProviderError(m_sqlCon);
		sqlsvrutils::_TraceComError(e);
		sqlsvrutils::LogProviderError(m_sqlCon);
		sqlsvrutils::LogComError(e);
		return;
	}
}

HRESULT SqlSvrSession::sqlsvr_excute(SqlCommandState& cmder)
{
	HRESULT ret = S_OK;
	try
	{
		check_connect();

		_RecordsetPtr pRecordset = NULL;
		sqlsvrutils::TESTHR(pRecordset.CreateInstance(__uuidof(Recordset)));
		sqlsvrutils::TESTHR(pRecordset->Open(cmder.sql_text.c_str(), _variant_t((IDispatch*)m_sqlCon, true),
			cmder.sql_cursorType, cmder.sql_lockType, cmder.sql_cmdType));
	}
	catch (_com_error & e)
	{
		ret = e.Error();
		m_mqlConBad = true;
		sqlsvrutils::_TraceProviderError(m_sqlCon);
		sqlsvrutils::_TraceComError(e);
		sqlsvrutils::LogProviderError(m_sqlCon);
		sqlsvrutils::LogComError(e);
		LOG_TRACE("SQL SERVER param<%s>", cmder.sql_text.c_str());
		LOG_ERROR("SQL SERVER param<%s>", cmder.sql_text.c_str());
	}
	catch (std::exception & e) {
		ret = S_FALSE;
		m_mqlConBad = true;
		LOG_TRACE("SQL SERVER invoke error:%s", e.what());
		LOG_TRACE("SQL SERVER param<%s>", cmder.sql_text.c_str());
		LOG_ERROR("SQL SERVER invoke error:%s", e.what());
		LOG_ERROR("SQL SERVER param<%s>", cmder.sql_text.c_str());
	}
	return ret;
}

std::pair<HRESULT, std::size_t> SqlSvrSession::sqlsvr_excute(SqlCommandState& cmder, std::function<int(_RecordsetPtr&)> result)
{
	std::pair<HRESULT, std::size_t> r = { S_OK, 0 };

	try
	{
		check_connect();
		_RecordsetPtr pRecordset = NULL;
		sqlsvrutils::TESTHR(pRecordset.CreateInstance(__uuidof(Recordset)));
		sqlsvrutils::TESTHR(pRecordset->Open(cmder.sql_text.c_str(), _variant_t((IDispatch*)m_sqlCon, true),
			cmder.sql_cursorType, cmder.sql_lockType, cmder.sql_cmdType));

		r.second = result(pRecordset);
		sqlsvrutils::TESTHR(pRecordset->Close());
	}
	catch (_com_error & e)
	{
		r.first = e.Error();
		m_mqlConBad = true;
		sqlsvrutils::_TraceProviderError(m_sqlCon);
		sqlsvrutils::_TraceComError(e);
		sqlsvrutils::LogProviderError(m_sqlCon);
		sqlsvrutils::LogComError(e);
		LOG_TRACE("SQL SERVER param<%s>", cmder.sql_text.c_str());
		LOG_ERROR("SQL SERVER param<%s>", cmder.sql_text.c_str());
	}
	catch (std::exception & e) {
		r.first = S_FALSE;
		m_mqlConBad = true;
		LOG_TRACE("SQL SERVER invoke error:%s", e.what());
		LOG_TRACE("SQL SERVER param<%s>", cmder.sql_text.c_str());
		LOG_ERROR("SQL SERVER invoke error:%s", e.what());
		LOG_ERROR("SQL SERVER param<%s>", cmder.sql_text.c_str());
	}
	return r;
}

HRESULT SqlSvrSession::sqlsvr_beginTrans()
{
	HRESULT ret = S_OK;

	try {
		check_connect();
		sqlsvrutils::TESTHR(m_sqlCon->BeginTrans());
	}
	catch (_com_error e) {
		ret = e.Error();
		m_mqlConBad = true;
		sqlsvrutils::_TraceProviderError(m_sqlCon);
		sqlsvrutils::_TraceComError(e);
		sqlsvrutils::LogProviderError(m_sqlCon);
		sqlsvrutils::LogComError(e);
		LOG_TRACE("SQL SERVER beginTrans");
		LOG_ERROR("SQL SERVER beginTrans");
	}
	catch (std::exception & e) {
		ret = S_FALSE;
		m_mqlConBad = true;
		LOG_TRACE("SQL SERVER invoke error:%s", e.what());
		LOG_TRACE("SQL SERVER beginTrans");
		LOG_ERROR("SQL SERVER invoke error:%s", e.what());
		LOG_ERROR("SQL SERVER beginTrans");
	}
	return ret;
}

HRESULT SqlSvrSession::sqlsvr_rollback()
{
	HRESULT ret = S_OK;

	try {
		check_connect();
		sqlsvrutils::TESTHR(m_sqlCon->RollbackTrans());
	}
	catch (_com_error e) {
		ret = e.Error();
		m_mqlConBad = true;
		sqlsvrutils::_TraceProviderError(m_sqlCon);
		sqlsvrutils::_TraceComError(e);
		sqlsvrutils::LogProviderError(m_sqlCon);
		sqlsvrutils::LogComError(e);
		LOG_TRACE("SQL SERVER RollbackTrans");
		LOG_ERROR("SQL SERVER RollbackTrans");
	}
	catch (std::exception & e) {
		ret = S_FALSE;
		m_mqlConBad = true;
		LOG_TRACE("SQL SERVER invoke error:%s", e.what());
		LOG_TRACE("SQL SERVER RollbackTrans");
		LOG_ERROR("SQL SERVER invoke error:%s", e.what());
		LOG_ERROR("SQL SERVER RollbackTrans");
	}
	return ret;
}

HRESULT SqlSvrSession::sqlsvr_commit()
{
	HRESULT ret = S_OK;

	try {
		check_connect();
		sqlsvrutils::TESTHR(m_sqlCon->CommitTrans());
	}
	catch (_com_error e) {
		ret = e.Error();
		m_mqlConBad = true;
		sqlsvrutils::_TraceProviderError(m_sqlCon);
		sqlsvrutils::_TraceComError(e);
		sqlsvrutils::LogProviderError(m_sqlCon);
		sqlsvrutils::LogComError(e);
		LOG_TRACE("SQL SERVER CommitTrans");
		LOG_ERROR("SQL SERVER CommitTrans");
	}
	catch (std::exception & e) {
		ret = S_FALSE;
		m_mqlConBad = true;
		LOG_TRACE("SQL SERVER invoke error:%s", e.what());
		LOG_TRACE("SQL SERVER CommitTrans");
		LOG_ERROR("SQL SERVER invoke error:%s", e.what());
		LOG_ERROR("SQL SERVER CommitTrans");
	}
	return ret;
}

std::pair<HRESULT, std::size_t> SqlSvrSession::sqlsvr_excute(std::function<int(_ConnectionPtr&)> invoke)
{
	std::pair<HRESULT, std::size_t> r = { S_OK, 0 };
	try
	{
		check_connect();
		r.second = invoke(m_sqlCon);
	}
	catch (_com_error & e)
	{
		r.first = e.Error();
		m_mqlConBad = true;
		sqlsvrutils::_TraceProviderError(m_sqlCon);
		sqlsvrutils::_TraceComError(e);
		sqlsvrutils::LogProviderError(m_sqlCon);
		sqlsvrutils::LogComError(e);
	}
	catch (std::exception & e) {
		r.first = S_FALSE;
		m_mqlConBad = true;
		LOG_TRACE("SQL SERVER invoke error:%s", e.what());
		LOG_ERROR("SQL SERVER invoke error:%s", e.what());
	}
	return r;
}

void SqlSvrSession::check_connect()
{
	auto lastTp = m_tpLastMqlCon;
	m_tpLastMqlCon = std::chrono::system_clock::now();
	bool forceCheckValid = m_mqlConBad;
	m_mqlConBad = false;
	try {
		if (!m_sqlCon) {
			if (!sqlsvr_open()) {
				char buffer[1024] = { 0 };
				ZeroMemory(buffer, sizeof(buffer));
				sprintf_s(buffer, "SqlServer Connect Error:%s",
					m_sConnect.c_str());
				throw std::exception(buffer);
			}
			return;
		}

		if (adStateClosed == m_sqlCon->State) {
			// 发现了它没有打开，直接开始重连
			if (!sqlsvr_open()) {
				char buffer[1024] = { 0 };
				ZeroMemory(buffer, sizeof(buffer));
				sprintf_s(buffer, "SqlServer Connect Error:%s",
					m_sConnect.c_str());
				throw std::exception(buffer);
			}
			return;
		}

		if (!forceCheckValid) {
			auto dur = std::chrono::duration_cast<std::chrono::hours>(m_tpLastMqlCon - lastTp);
			if (dur.count() < 1) {
				// 只有超过1个小时无操作，才会进行sqlsvr con有效性检查
				return;
			}
		}

		// 请求一下sqlserver的时间，通过它来确认连接正常
		if (sqlsvr_test()) {
			return;
		}
		if (!sqlsvr_open()) {
			char buffer[1024] = { 0 };
			ZeroMemory(buffer, sizeof(buffer));
			sprintf_s(buffer, "SqlServer Connect Error:%s",
				m_sConnect.c_str());
			throw std::exception(buffer);
		}
		return;
	}
	catch (...) {
		// 操作过程里只要发生了异常，都再抛出去，由外部处理
		std::rethrow_exception(std::current_exception());
	}
}
