#pragma once

#include "json.h"

// ��Ϣ��
#define GR_TASK_CHANGE_PARAM        (GAME_REQ_INDIVIDUAL + 2100)    // �ı�����������
#define GR_TASK_CHANGE_DATA         (GAME_REQ_INDIVIDUAL + 2101)    // �ı�����������

#define GR_TASK_QUERY_DATA          (GAME_REQ_INDIVIDUAL + 2105)    // ��ѯ����������
#define GR_TASK_QUERY_PARAM         (GAME_REQ_INDIVIDUAL + 2106)    // ��ѯ����������
#define GR_TASK_AWARD_PRIZE         (GAME_REQ_INDIVIDUAL + 2107)    // ��ȡ������

#define GR_TASK_SOAP_PRIZE          (GAME_REQ_INDIVIDUAL + 2110)    // soap��ȡ������
#define GR_TASK_DELETE_TABLE        (GAME_REQ_INDIVIDUAL + 2111)    // ɾ�����ݿ��


#define GR_TASK_QUERY_TASK_INFO     (GAME_REQ_INDIVIDUAL + 2117)    // ��ȡLTASK�������
#define GR_TASK_QUERY_LTASK_DATA    (GAME_REQ_INDIVIDUAL + 2118)    // ��ȡLTASK�������
#define GR_TASK_QUERY_LTASK_PARAM   (GAME_REQ_INDIVIDUAL + 2119)
#define GR_TASK_CHANGE_LTASK_DATA   (GAME_REQ_INDIVIDUAL + 2120)
#define GR_TASK_CHANGE_LTASK_PARAM  (GAME_REQ_INDIVIDUAL + 2121)
#define GR_TASK_AWARD_LTASK         (GAME_REQ_INDIVIDUAL + 2122)
#define GR_LTASK_SOAP_PRIZE         (GAME_REQ_INDIVIDUAL + 2123)
#define GR_TASK_ROOMCARD_AWARD_LTASK        (GAME_REQ_INDIVIDUAL + 2124)    // �����Զ���ȡ��������
#define GR_TASK_GET_DATA_FOR_JSON   (GAME_REQ_INDIVIDUAL + 2125)    // ��ȡ���ݿ���������
#define GR_TASK_AWARD_PRIZE_JSON    (GAME_REQ_INDIVIDUAL + 2126)    // �ճ�������ȡ����
#define GR_TASK_AWARD_LTASK_JSON    (GAME_REQ_INDIVIDUAL + 2127)    // �ɳ�������ȡ����

// ��������
#define TASK_PARAM_TOTAL 28
enum
{
    /*****************ͨ�ò���*****************/
    TASK_GAME_RESULT_WIN = 1,       // 1 - Ӯ�ľ���
    TASK_GAME_RESULT_LOSE,          // 2 - ��ľ���
    TASK_GAME_RESULT_DRAW,          // 3 - ƽ�ľ���
    TASK_GAME_CUR_WIN_STREAK,       // 4 - ��ǰ��ʤ
    TASK_GAME_MAX_WIN_STREAK,       // 5 - �����ʤ
    /*****************��Ϸ����*****************/
    TASK_GAME_QINGYISE_COUNT,       // 6 - ��һɫ����
    TASK_GAME_XUELIU_HUCOUNT_2,     // 7 - Ѫ��һ���ں�2��
    TASK_GAME_GANG_COUNT,           // 8 - �ܵĴ���
    TASK_GAME_WINDEPOSIT_2000,      // 9 - ����Ӯ2000��
    TASK_GAME_WINDEPOSIT_5000,      // 10 - ����Ӯ5000��
    TASK_GAME_WINDEPOSIT_10000,     // 11 - ����Ӯ10000��
    TASK_GAME_WINDEPOSIT_50000,     // 12 - ����Ӯ50000��
    TASK_GAME_ZIMO_COUNT,           // 13 - ��������
    TASK_GAME_HUBOUT_16,            // 14 - ��16��
    TASK_GAME_HUBOUT_32,            // 15 - ��32��
    TASK_GAME_HUBOUT_64,            // 16 - ��64��
    TASK_GAME_HUBOUT_128,           // 17 - ��128��
    ASK_GAME_XUELIU_HUCOUNT_4,      // 18 - Ѫ��һ���ں�4��
    ASK_GAME_XUELIU_HUCOUNT_8,      // 19 - Ѫ��һ���ں�8��
    ASK_GAME_XUELIU_HUCOUNT_10,     // 20 - Ѫ��һ���ں�10��

    //�ɳ�����
    LTASK_PLAYGAME_LOW,               // 21 - ��������Ϸһ��
    LTASK_PLAYGAME_MID,               // 22 - �м�����Ϸһ��
    LTASK_PLAYGAME_HIGH,               // 23 - �߼�����Ϸһ��
    LTASK_GAME_PENCOUNT,            // 24 - ���Ĵ���
    LTASK_GAME_GANGCOUNT,           // 25 - �ܵĴ���
    LTASK_GAME_WINDEPOSIT_1000,     // 26 - �����ۼ�Ӯ1000��
    LTASK_GAME_WINDEPOSIT_5000,     // 27 - �����ۼ�Ӯ5000��

    /******************�ͻ���******************/
    TASK_GAME_SHARE_COUNT,          // 28- �������

    TASK_CONDITION_MAX = TASK_PARAM_TOTAL + 1,       //���ݿ�����TASK_PARAM_TOTAL��Ŀǰ֧��
    TASK_CONDITION_COM_GAME_COUNT = 1001           //������� 1+2+3
};

enum
{
    TASKDATA_FLAG_DOING = 0,     // �������ڽ�����
    TASKDATA_FLAG_CANGET_REWARD, // �������ȡ
    TASKDATA_FLAG_FINISHED,      // ���������
};

enum
{
    TASK_AWARD_WRONG_TASK_NULL = 1,     // û����������
    TASK_AWARD_WRONG_NOT_ACTIVE,        // ������δ����
    TASK_AWARD_WRONG_CONDITION,         // �����������
    TASK_AWARD_WRONG_REWARD,            // ����������
    TASK_AWARD_WRONG_ALREADY_AWARD,     // �����Ѿ���ȡ
    TASK_AWARD_WRONG_NOT_FINISHED,      // ����û�����
    TASK_AWARD_WRONG_OPERATE_FAST,      // Ƶ����ȡ����
};

// ���ݿ����
typedef struct _tagTaskValue
{
    int nType;                  // ����
    int nValue;                 // ��ֵ
} TASKVALUE, *LPTASKVALUE;

typedef struct _tagTaskParam
{
    int nParam[TASK_PARAM_TOTAL];   // ������
} TASKPARAM, *LPTASKPARAM;

typedef struct _tagTaskData
{
    int nGroupID;               // ������ID
    int nSubID;                 // ������ID
    int nFlag;                  // ����״̬
} TASKDATA, *LPTASKDATA;

typedef struct _tagTaskDataEx
{
    int nGroupID;               // ������ID
    int nSubID;                 // ������ID
    int nFlag;                  // ����״̬
    CTime tTime;                // ��ȡʱ��
} TASKDATAEX, *LPTASKDATAEX;

typedef struct _tagTaskInfo
{
    int nGroupID;               // ������ID
    int nSubID;                 // ������ID
    TCHAR szWebID[32];          // ����WebID
    int nType;                  // ��������
    TCHAR szCondition[32];      // �������
    TCHAR szReward[32];         // ��ɽ���
    int nNextID;                // ��һ����ID
    int nActive;                // �����־
} TASKINFO, *LPTASKINFO;

// ��������Data����Param�����ݣ�
typedef struct _tagTaskQuery
{
    int nUserID;                // userid
    int nType;                  // ��������
    int nDate;                  // ����������

    int nReserved[4];           // �����ֶ�
} TASKQUERY, *LPTASKQUERY;

// ��ȡ����
typedef struct _tagTaskAward
{
    int nUserID;                // userid
    int nType;                  // ��������
    int nGroupID;               // ������ID
    int nSubID;                 // ������ID
    int nDate;                  // ����������

    int nReserved[4];           // �����ֶ�
    KPI::KPI_CLIENT_DATA kpiClientData; //KPI�ͻ�������
} TASKAWARD, *LPTASKAWARD;

// ����������
typedef struct _tagTaskParamInfo
{
    int nUserID;                // userid
    int nDate;                  // ��������
    int nParam[TASK_PARAM_TOTAL];  // ��������

    int nReserved[4];           // �����ֶ�
} TASKPARAMINFO, *LPTASKPARAMINFO;

// ����������
#define MAX_TASK_DATA_NUM       20
typedef struct _tagTaskDataInfo
{
    int nUserID;                // userid
    int nDate;                  // ��������
    int nDataNum;               // ��������
    TASKDATA tData[MAX_TASK_DATA_NUM];  // ��������

    int nReserved[4];           // �����ֶ�
} TASKDATAINFO, *LPTASKDATAINFO;

// ���������
typedef struct _tagTaskResult
{
    int nUserID;                // userid
    int nDate;                  // ��������
    BOOL bResult;               // �������Ž��
    int nGroupID;               // ������ID
    int nTaskID;                // ������ID
    int nFlag;                  // �����־
    TCHAR szWebID[32];          // �콱WebID
    int nRewardType;            // ��������
    int nRewardNum;             // ��������

    int nReserved[4];           // �����ֶ�
    KPI::KPI_CLIENT_DATA kpiClientData; //KPI�ͻ�������
} TASKRESULT, *LPTASKRESULT;

// �������仯
#define MAX_TASK_PARAM_NUM      10
typedef struct _tagTaskParamChange
{
    int nUserID;                 // userid
    BOOL bIsHandPhone;           // �Ƿ��ֻ����û�
    int nType;                   // ��������
    int nValue;                  // ������ֵ

    int nReserved[4];            // �����ֶ�
} TASKPARAMCHANGE, *LPTASKPARAMCHANGE;

// ������仯
typedef struct _tagTaskDataChange
{
    int nUserID;                 // userid
    int nDate;                   // ��������
    int nGroupID;                // ������ID
    int nSubID;                  // ������ID
    int nFlag;                   // �����־

    int nReserved[4];            // �����ֶ�
} TASKDATACHANGE, *LPTASKDATACHANGE;


enum LIFE_TASK_TYPE
{
    LFTASK_GAME_SHARE,
    LFTASK_GAME_BOUT,
    LFTASK_GAME_CREATE,
    LFTASK_GAME_3DMJ_COUNT,         // 3 - 3D�齫��Ϸ����
};

typedef struct _tagLFTaskInfo
{
    int taskid;
    int taskgoal;
    int taskreward;
    int nextid;
} LFTaskInfo, *LPTaskInfo;

typedef struct _tagReqTaskInfo
{
    int nReq;       // 0 task, 1 ltask, 3 all
    int nUserID;
    int nVersion;   //�汾��Ϣ
} ReqTaskInfo, *LPReqTaskInfo;

typedef struct _tagTaskInfoRecord
{
    int taskid;
    int conditionType;
    int conditionCount;
    int reward;
    int rewardType;
    int nextid;
    char szWebID[32];
} TaskInfoRecord, *LPTaskInfoRecord;

typedef struct _tagTaskInfoData
{
    int nCount;
    int nReqType;   //0 task, 1 ltask
    int nVersion;   //�汾��Ϣ
} TaskInfoData, *LPTaskInfoData;

typedef struct _tagLTaskDataReq
{
    int nUserID;
} LTaskDataReq, *LPTaskDataReq;

typedef struct _tagLTaskDataRsp
{
    int nCount;
} LTaskDataRsp, *LPLTaskDataRsp;

typedef struct _tagLFTaskData
{
    int userid;
    int taskid;
    int status;
    int time;
} LFTaskData, *LPLTaskData;

typedef struct _tagLTaskParamReq
{
    int nUserID;
} LTaskParamReq, *LPTaskParamReq;

typedef struct _tagLTaskParamRsp
{
    int nCount;
} LTaskParamRsp, *LPLTaskParamRsp;

typedef struct _tagLTaskParam
{
    int nuserid;
    int countadd;
    int type;
} LTaskParam, *LPLTaskParam;

typedef struct _tagLTaskAward
{
    int nUserID;
    int nTaskID;
    int nTaskType;

    KPI::KPI_CLIENT_DATA kpiClientData; //KPI�ͻ�������
} LTaskAward, *LPLTaskAward;

typedef struct _tagLTaskResult
{
    int nUserID;
    int nTaskID;
    int nTaskType;
    int nTaskReward;
    int nTaskRewardType;
    int nDate;
    int nNextID;
    int nStatus;
    int nResult;
    char szWebID[32];
    KPI::KPI_CLIENT_DATA kpiClientData; //KPI�ͻ�������
} LTaskResult, *LPLTaskResult;

/*json ����Ľṹ��*/

typedef struct _tagTaskInfoJson
{
    int nGroupID;               // ������ID
    int nSubID;                 // ������ID
    TCHAR szWebID[32];          // ����WebID
    int nType;                  // ��������
    int nConditionType;
    int nCondition;             // �������
    int nRewardType;
    int nReward;                // ��ɽ���
    Json::Value vCondition;
    Json::Value vReward;
    int nNextID;                // ��һ����ID
    int nActive;                // �����־
} TASKINFOJSON, *LPTASKINFOJSON;