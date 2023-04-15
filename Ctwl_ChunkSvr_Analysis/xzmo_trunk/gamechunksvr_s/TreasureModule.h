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

    // ������Ϣ
    ImportFunctional<void(LPCONTEXT_HEAD, REQUEST&)> imSendOpeRequest;
	ImportFunctional<void(const char*, const char*, std::string&)> imGetIniString;

	// DB����
	ImportFunctional < std::future<void>(const std::string&, std::function<void(DBConnectEntry*)>) >
		imDBOpera;

	void OnInputTest(bool& next, std::string& cmd);

protected:
	// ��ʱˢ��, ����ˢ������
	void onFreshTimer();

	// ��ȡ����ini�ļ�
	void readFromLocalIni();

	// ��ȡ����json�ļ�
	void readFromLocalJson();

	// ��������ı�
	void createTodayTable();

	// ɾ������ı�
	void deletePredayTable();

	// ɾ������
	void deleteCache();

	using TreasureTaskDataMap = std::map < int, tbl_TreasureTaskData > ;
	std::shared_ptr<boost::any> createCache(tbl_TreasureTaskData &data);

	// ��ȡ��ǰ��ʱ�� 
	CTime getCurTime();

	// ��ȡdb key
	std::string toKey(int userid);

	// ���ݵ�ǰ��ʱ�����ȡ������
	static std::string tableName(const std::string& tblTag, CTime);

	// ��ȡjson������޸�ʱ��
	static FILETIME getFileLastWriteTime(const std::string& filename);

	// ��ȡTaskData����
	int getDBTreasureTaskData(DBConnectEntry* entry, const std::string& tblname, int userid, int roomid, tbl_TreasureTaskData& data);

	// ����TaskData����
	int updateDBTreasureTaskData(DBConnectEntry* entry, const std::string& tblname, int userid, int roomid, int last_reward_count, int task_reward_round);

	// insertTaskData����
	int insertOrUpdateDBTreasureTaskData(DBConnectEntry* entry, const std::string& tblname, tbl_TreasureTaskData& data);

	// ��ȡ����ı�������
	TREASUREROOMINFO getTreasureRoomInfo(int roomid);

	// ��ȡȫ������
	TREASURERE_CONFIG getTreasureConfig();

	// �����Ƿ��
	bool isEnable();
private:
	stdtimerPtr m_timerFresh;
    stdtimerPtr m_timerDeleteOnce;

	// ���е����ݶ���������onReqeust�߳�ֱ�ӷ���,������strand�з���
	FILETIME m_jsonFileLastFresh;
	std::string m_jsonFileName;
	CTime m_curTime;
	TREASURERE_CONFIG m_config;
	std::vector<TREASUREROOMINFO > m_task_config;

	// ����
	std::list<std::shared_ptr<boost::any>> m_cacheList;
};

