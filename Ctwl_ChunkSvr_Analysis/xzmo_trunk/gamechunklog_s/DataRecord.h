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

    //��ȡ����int��Ϣ
    ImportFunctional<void(const char*, const char*, int &)> imGetIniInt;

    // DB����
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

    // ��ȡ���ݿⱣ��ʱ�������
    int GetExpireSetConfig();

    // ����¼���㱣��ʱ��
    int GetUerRecordExpireSetConfig();

    BOOL IsInPeriodOfProfile(LPCTSTR lpSection, int nBegin, int nEnd);

    // ��ʱˢ��, ����ˢ������
    void onFreshTimer();

    //���һ��ɾ��ʱ����� ��ֹ���е�chunklog������2:30���ͬһʱ�����ɾ������
    void UpdateDeleteTime();

private:
    stdtimerPtr m_timerFresh;

    CTime m_tTime;
    int m_nDeleteHour;
    int m_nDeleteMinute;
    CStringINTMap m_funcUsedLog;

};

