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

    // 返回消息
    ImportFunctional<void(LPCONTEXT_HEAD, REQUEST&)> imSendOpeRequest;
	ImportFunctional<void(LPCONTEXT_HEAD, UINT , void* , REQUEST&) > imSendOpeReqOnlyCxt;

    // DB操作
	ImportFunctional < std::future<int>(const std::string&, std::function<int(DBConnectEntry*)>) >
        imDBOpera;

    //获取配置int信息
	ImportFunctional<void(const char*, const char*, int&)> imGetIniInt;

    void OnTest(bool&, std::string&);
protected:
    // 定时刷新, 用于刷新配置
    void onFreshTimer();

    // 读取本地ini文件
    void readFromLocalIni();

    // 读取本地json文件
    void readFromLocalJson();

    void ReadClassicTaskJsonConfig();
    BOOL GetClassicTaskInfo(int nGroupID, int nSubID, LPTASKINFOJSON pTaskInfo);
    BOOL GetLTaskInfo(int nTaskID, LPTaskInfoRecord pTaskInfo);
    BOOL GetTaskInfo(int nGroupID, int nSubID, LPTASKINFOJSON pTaskInfo);
    std::string GetTaskJsonString();
    // 获取当前的任务日期 
    int getCurTime();

    // 删除前一天的表
    BOOL deletePredayTable(DBConnectEntry* entry);

    // 删除缓存
    void deleteCache();

    // 获取db key
    std::string toKey(int userid);

    /****************************数据库操作***************************/
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

// -------------所有的数据都不允许在onReqeust线程直接访问,必须在strand中返回 ------------------------------------
    int m_nCurTime;                 // 任务日期
    CTime m_tTime;                  // 刷新任务时间
    int m_nRecordOnlyPhone;         // only record data from phone
    int m_nFreshTime;               // every day task fresh time (from ini)
    int m_nRetainDaysOfParam;       // how many param tables retained (from ini)
    int m_nRetainDaysOfData;        // how many data tables retained (from ini)
    Json::Value m_vTaskJsonRoot;
    //经典任务;
    Json::Value m_vClassicTaskJsonRoot;
// -----------------------------------------------------------------------------------------------------------------

};