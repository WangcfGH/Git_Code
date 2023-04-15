#pragma once
#include <list>
#include <map>
#include <boost/any.hpp>
#include "plana/plana.h"

using namespace plana::threadpools;
class DBConnectEntry;
class TreasureModule : public PlanaStaff
{
public:
    void OnServerStart(BOOL &, TcyMsgCenter *);
    void OnShutDown();

    BOOL OnQueryTreasureInfo(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);
    BOOL OnTaskTreasureAward(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);
    BOOL OnTreasureUpdateTaskData(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);

    // 返回消息
    ImportFunctional<void(LPCONTEXT_HEAD, REQUEST&)> imSendOpeRequest;
	ImportFunctional<void(const char*, const char*, std::string&)> imGetIniString;

	// DB操作
	ImportFunctional < std::future<void>(const std::string&, std::function<void(DBConnectEntry*)>) >
		imDBOpera;

	void OnInputTest(bool& next, std::string& cmd);

protected:
	// 定时刷新, 用于刷新配置
	void onFreshTimer();

	// 读取本地ini文件
	void readFromLocalIni();

	// 读取本地json文件
	void readFromLocalJson();

	// 创建今天的表
	void createTodayTable();

	// 删除昨天的表
	void deletePredayTable();

	// 删除缓存
	void deleteCache();

	using TreasureTaskDataMap = std::map < int, tbl_TreasureTaskData > ;
	std::shared_ptr<boost::any> createCache(tbl_TreasureTaskData &data);

	// 获取当前的时间 
	CTime getCurTime();

	// 获取db key
	std::string toKey(int userid);

	// 根据当前的时间戳获取表名称
	static std::string tableName(const std::string& tblTag, CTime);

	// 读取json的最后修改时间
	static FILETIME getFileLastWriteTime(const std::string& filename);

	// 获取TaskData数据
	int getDBTreasureTaskData(DBConnectEntry* entry, const std::string& tblname, int userid, int roomid, tbl_TreasureTaskData& data);

	// 更新TaskData数据
	int updateDBTreasureTaskData(DBConnectEntry* entry, const std::string& tblname, int userid, int roomid, int last_reward_count, int task_reward_round);

	// insertTaskData数据
	int insertOrUpdateDBTreasureTaskData(DBConnectEntry* entry, const std::string& tblname, tbl_TreasureTaskData& data);

	// 获取房间的宝箱配置
	TREASUREROOMINFO getTreasureRoomInfo(int roomid);

	// 获取全局配置
	TREASURERE_CONFIG getTreasureConfig();

	// 任务是否打开
	bool isEnable();
private:
	stdtimerPtr m_timerFresh;
    stdtimerPtr m_timerDeleteOnce;

	// 所有的数据都不允许在onReqeust线程直接访问,必须在strand中返回
	FILETIME m_jsonFileLastFresh;
	std::string m_jsonFileName;
	CTime m_curTime;
	TREASURERE_CONFIG m_config;
	std::vector<TREASUREROOMINFO > m_task_config;

	// 缓存
	std::list<std::shared_ptr<boost::any>> m_cacheList;
};

