#pragma once
#include "dbconnectpool/DBConnectPool.h"
#include "dbconnectpool/TcyMySqlConnect.h"
#include "dbconnectpool/TcySqlSvrConnect.h"
#include "RedisMgrPool.h"

class CRedisMgr;
class CRedisMgrEx : public CRedisMgr
{
public:
	CString RedisCommand_pach(const char* format);
};
class DBConnectEntry : public PoolEntry, public MysqlSession, public SqlSvrSession, public CRedisMgrEx
{
public:
	DBConnectEntry(DBConnectPool* pool);

	virtual void enterThread() override;
	virtual void leaveThread() override;
};

class GameDBConnectPool : public DBConnectPool
{
public:
    GameDBConnectPool(int);
    ~GameDBConnectPool();

	virtual void start(int n /* = 8 */) override;

protected:
	virtual std::shared_ptr<ThreadEntryBase> createThreadEntry() override;
	BOOL ReadGameChunkDBConfig();
	void FillGameDBAccount();

private:
	std::string m_dbaFile;
	CHUNK_DB m_mysql_dbInfo;
	int m_mysql_dbIndex;

	CHUNK_DB m_sqlsvr_dbinfo;
	int m_sqlsvr_dbIndex;
};
