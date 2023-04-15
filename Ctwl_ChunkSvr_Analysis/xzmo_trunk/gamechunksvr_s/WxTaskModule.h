#pragma once

using namespace plana::threadpools;
class DBConnectEntry;
class WxTaskModule : public PlanaStaff
{
public:
    void OnServerStart(BOOL &, TcyMsgCenter *);
    void OnShutDown();

    BOOL OnChangeWxTaskParam(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);
    BOOL OnChangeWxTaskData(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);
    BOOL OnQueryWxTaskParam(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);
    BOOL OnQueryWxTaskData(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);
    BOOL OnReqGetWxTaskConfigData(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);
    BOOL OnAwardWxTaskPrizeForJson(LPCONTEXT_HEAD lpContext, LPREQUEST lpRequest);

    // ������Ϣ
    ImportFunctional<void(LPCONTEXT_HEAD, REQUEST&)> imSendOpeRequest;
	ImportFunctional<void(LPCONTEXT_HEAD, UINT, void*, REQUEST&) > imSendOpeReqOnlyCxt;
	ImportFunctional<void(const char*, const char*, int&)> imGetIniInt;

    // DB����
	ImportFunctional < std::future<int>(const std::string&, std::function<int(DBConnectEntry*)>) >
        imDBOpera;
    ////////////////////////////////////
protected:
    // ��ʱˢ��, ����ˢ������
    void onFreshTimer();

    void clearTableCache();
    void ReadWxTaskJsonConfig();
    void loadWxTaskConfig();
    std::string toKey(int userid);
    int GetCurTime();
    std::string GetTaskJsonString();
    BOOL GetWxTaskInfo(int nGroupID, int nSubID, LPTASKINFOJSON pTaskInfo);
    /********************************���ݿ����*************************/
    int Redis_UpdateWxTaskParam(DBConnectEntry* entry, int nDate, int nUserID, int nType, int nValue);
    int Redis_UpdateWxTaskParamWin(DBConnectEntry* entry, int nDate, int nUserID, int nType1, int nValue, int nType2);
    int Redis_UpdateWxTaskParamLose(DBConnectEntry* entry, int nDate, int nUserID, int nType, int nValue);
    int Redis_QueryWxTaskParam(DBConnectEntry* entry, int nDate, int nUserID, int nParam[]);
    int Redis_UpdateWxTaskData(DBConnectEntry* entry, int nDate, int nUserID, int nGroupID, int nSubID, int nFlag);
    int Redis_QueryWxTaskData(DBConnectEntry* entry, int nDate, int nUserID, int& nNum, TASKDATA taskData[]);
    int Redis_QueryWxTaskDataByTaskID(DBConnectEntry* entry, int nDate, int nUserID, int nGroupID, int nSubID, LPTASKDATA pTaskData);

    BOOL OnDeleteLastWxTaskTable(DBConnectEntry* entry);
    /*******************************************************************/
private:
    // ���е����ݶ���������onReqeust�߳�ֱ�ӷ���,������strand�з���
    stdtimerPtr m_timerFresh;

// -------------���е����ݶ���������onReqeust�߳�ֱ�ӷ���,������strand�з��� ------------------------------------
    Json::Value m_vTaskJsonRoot;
    int m_nFreshTime;                       // every day task fresh time (from ini)
    int m_nRetainDaysOfParam;               // how many param tables retained (from ini)
    int m_nRetainDaysOfData;                // how many data tables retained (from ini)
    CTime m_tTime;                          // ˢ��ʱ��
    int m_nCurrentDate;                     // cunrrent date
// --------------------------------------------------------------------------------------------------------------
};

