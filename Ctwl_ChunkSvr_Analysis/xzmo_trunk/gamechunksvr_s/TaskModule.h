#pragma once
#include <list>
#include <map>
#include <boost/any.hpp>
#include "plana/plana.h"

using namespace plana::threadpools;
class DBConnectEntry;
class TaskModule : public PlanaStaff
{
public:
    void OnServerStart(BOOL &, TcyMsgCenter *);
    void OnShutDown();

    BOOL OnChangeTaskParam(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);
    BOOL OnChangeTaskData(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);
    BOOL OnQueryTaskParam(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);
    BOOL OnQueryTaskData(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);
    BOOL OnReqLTaskData(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);
    BOOL OnReqLTaskParam(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);
    BOOL OnReqLTaskChangeData(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);
    BOOL OnReqLTaskChangeParam(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);
    BOOL OnReqGetTaskConfigData(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);
    BOOL OnAwardTaskPrizeForJson(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);
    BOOL OnReqLTaskAwardForJson(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);
    BOOL OnAwardClassicTaskPrizeForJson(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);

    // ������Ϣ
    ImportFunctional<void(LPCONTEXT_HEAD, REQUEST&)> imSendOpeRequest;
	ImportFunctional<void(LPCONTEXT_HEAD, UINT , void* , REQUEST&) > imSendOpeReqOnlyCxt;

    // DB����
	ImportFunctional < std::future<int>(const std::string&, std::function<int(DBConnectEntry*)>) >
        imDBOpera;

    //��ȡ����int��Ϣ
	ImportFunctional<void(const char*, const char*, int&)> imGetIniInt;

    void OnTest(bool&, std::string&);
protected:
    // ��ʱˢ��, ����ˢ������
    void onFreshTimer();

    // ��ȡ����ini�ļ�
    void readFromLocalIni();

    // ��ȡ����json�ļ�
    void readFromLocalJson();

    void ReadClassicTaskJsonConfig();
    BOOL GetClassicTaskInfo(int nGroupID, int nSubID, LPTASKINFOJSON pTaskInfo);
    BOOL GetLTaskInfo(int nTaskID, LPTaskInfoRecord pTaskInfo);
    BOOL GetTaskInfo(int nGroupID, int nSubID, LPTASKINFOJSON pTaskInfo);
    std::string GetTaskJsonString();
    // ��ȡ��ǰ���������� 
    int getCurTime();

    // ɾ��ǰһ��ı�
    BOOL deletePredayTable(DBConnectEntry* entry);

    // ɾ������
    void deleteCache();

    // ��ȡdb key
    std::string toKey(int userid);

    /****************************���ݿ����***************************/
    int Redis_UpdateTaskParam(DBConnectEntry* entry, int nDate, int nUserID, int nType, int nValue);
    int Redis_UpdateTaskParamWin(DBConnectEntry* entry, int nDate, int nUserID, int nType1, int nValue, int nType2);
    int Redis_UpdateTaskParamLose(DBConnectEntry* entry, int nDate, int nUserID, int nType, int nValue);
    int Redis_QueryTaskParam(DBConnectEntry* entry, int nDate, int nUserID, int nParam[]);
    int Redis_UpdateTaskData(DBConnectEntry* entry, int nDate, int nUserID, int nGroupID, int nSubID, int nFlag);
    int Redis_QueryTaskData(DBConnectEntry* entry, int nDate, int nUserID, int& nNum, TASKDATA taskData[]);
    int Redis_QueryTaskDataByTaskID(DBConnectEntry* entry, int nDate, int nUserID, int nGroupID, int nSubID, LPTASKDATA pTaskData);

    int DB_QueryLTaskData1(DBConnectEntry* entry, int nUserID, std::vector<LFTaskData>& taskInfos);
    int DB_QueryLTaskDataEx1(DBConnectEntry* entry, int nUserID, int nTaskID, LFTaskData& taskData);
    int DB_QueryLTaskParamEx1(DBConnectEntry* entry, int nUserID, int nType, LTaskParam& taskParam);
    int DB_QueryLTaskParam1(DBConnectEntry* entry, int nUserID, std::vector<LTaskParam>& taskParams);
    int DB_LTaskUpdateLTaskDataEx(DBConnectEntry* entry, LFTaskData& taskData);
    int DB_LTaskUpdateLTaskParamEx(DBConnectEntry* entry, LTaskParam& taskParam);
    BOOL ChangeLTaskData(DBConnectEntry* entry, LPCONTEXT_HEAD lpContext, UINT nRequest, LPLTaskData lpTaskReq);
    /*****************************************************************/
private:
    stdtimerPtr m_timerFresh;

// -------------���е����ݶ���������onReqeust�߳�ֱ�ӷ���,������strand�з��� ------------------------------------
    int m_nCurTime;                 // ��������
    CTime m_tTime;                  // ˢ������ʱ��
    int m_nRecordOnlyPhone;         // only record data from phone
    int m_nFreshTime;               // every day task fresh time (from ini)
    int m_nRetainDaysOfParam;       // how many param tables retained (from ini)
    int m_nRetainDaysOfData;        // how many data tables retained (from ini)
    Json::Value m_vTaskJsonRoot;
    //��������;
    Json::Value m_vClassicTaskJsonRoot;
// -----------------------------------------------------------------------------------------------------------------

};