#pragma once
#include "dbconnectpool/DBConnectPool.h"
#include "dbconnectpool/TcyMySqlConnect.h"


class GameDbPool;
class DBConnectEntry : public PoolEntry, public MysqlSession
{
public:
	DBConnectEntry(GameDbPool* pool);

	virtual void enterThread() override;
	virtual void leaveThread() override;
};

class GameDbPool : public DBConnectPool
{
public:
	GameDbPool(int nthread=8);
	~GameDbPool();

	virtual void start(int n /* = 8 */) override;

protected:
	virtual std::shared_ptr<ThreadEntryBase> createThreadEntry() override;

	BOOL ReadGameChunkDBConfig();
	void FillGameDBAccount();

private:
	std::string m_dbaFile;
	CHUNK_DB m_dbInfo;
	int m_dbIndex;
};

