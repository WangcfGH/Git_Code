#pragma once
#include "plana/plana.h"
using namespace plana::threadpools;

class DBConnectEntry;
class DataRecord : public PlanaStaff
{
public:
    void OnServerStart(BOOL &ret, TcyMsgCenter *msgCenter);
    void OnShutdown();
    void OnPlayerLogon(NTF_PLAYERLOGON& playerLogon);

    //获取配置int信息
    ImportFunctional<void(const char*, const char*, int &)> imGetIniInt;

    // DB操作
    ImportFunctional <std::future<int>(const std::string&, std::function<int(DBConnectEntry*)>)  > imDBOpera;

protected:
    void OnLogEvent(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);
    void OnLogEventFuncUsed(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);
    void OnLogEventAppUpload(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);
    void OnLogEventTreasureAward(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);
    void OnLogEventUserBehavior(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);
    void OnLogEvent3DCount(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);

    void DB_CreateTableEveryDay(int day);
    void DB_CreateUserRecordTableEveryDay(int day);
    void DB_DeleteOverdueLog(int nDate);
    void DB_DeleteUserRecordOverdueLog(int nDate);
    void DB_RecordFuncUsedLog();

    std::string toKey(int userid);

    // 获取数据库保存时间的配置
    int GetExpireSetConfig();

    // 点击事件埋点保存时间
    int GetUerRecordExpireSetConfig();

    BOOL IsInPeriodOfProfile(LPCTSTR lpSection, int nBegin, int nEnd);

    // 定时刷新, 用于刷新配置
    void onFreshTimer();

    //随机一个删除时间出来 防止所有的chunklog服务都在2:30这个同一时间进行删除操作
    void UpdateDeleteTime();

private:
    stdtimerPtr m_timerFresh;

    CTime m_tTime;
    int m_nDeleteHour;
    int m_nDeleteMinute;
    CStringINTMap m_funcUsedLog;

};

