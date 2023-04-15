#pragma once

#include "json.h"

// ��Ϣ��
#define GR_WXTASK_CHANGE_PARAM        (GAME_REQ_INDIVIDUAL + 4100)    // �ı�����������
#define GR_WXTASK_CHANGE_DATA         (GAME_REQ_INDIVIDUAL + 4101)    // �ı�����������

#define GR_WXTASK_QUERY_DATA          (GAME_REQ_INDIVIDUAL + 4105)    // ��ѯ����������
#define GR_WXTASK_QUERY_PARAM         (GAME_REQ_INDIVIDUAL + 4106)    // ��ѯ����������
#define GR_WXTASK_AWARD_PRIZE         (GAME_REQ_INDIVIDUAL + 4107)    // ��ȡ������

#define GR_WXTASK_SOAP_PRIZE          (GAME_REQ_INDIVIDUAL + 4110)    // soap��ȡ������
#define GR_WXTASK_DELETE_TABLE        (GAME_REQ_INDIVIDUAL + 4111)    // ɾ�����ݿ��

#define GR_WXTASK_QUERY_TASK_INFO     (GAME_REQ_INDIVIDUAL + 4117) 
#define GR_WXTASK_GET_DATA_FOR_JSON   (GAME_REQ_INDIVIDUAL + 4125)    // ��ȡ���ݿ���������
#define GR_WXTASK_AWARD_PRIZE_JSON    (GAME_REQ_INDIVIDUAL + 4126)    // �ճ�������ȡ����

// ��������
#define WXTASK_PARAM_TOTAL 28
enum
{
    /*****************ͨ�ò���*****************/
    WXTASK_GAME_RESULT_WIN = 1,       // 1 - Ӯ�ľ���
    WXTASK_GAME_RESULT_LOSE,          // 2 - ��ľ���
    WXTASK_GAME_RESULT_DRAW,          // 3 - ƽ�ľ���
    WXTASK_GAME_CUR_WIN_STREAK,       // 4 - ��ǰ��ʤ
    WXTASK_GAME_MAX_WIN_STREAK,       // 5 - �����ʤ
    /*****************��Ϸ����*****************/
    WXTASK_GAME_WIN_DEPOSIT,          // 6 - ����Ӯ��������
    WXTASK_HU_TIMES,                  //7���ƴ���
  

    /******************�ͻ���******************/
    WXTASK_PARAM_FROM_CLIENT = 20,
    WXTASK_GAME_SHARE_COUNT,            // 21- �������
    WXTASK_GAME_LOOKADVER_COUNT,        // 22- ��������

    WXTASK_CONDITION_COM_GAME_COUNT = 1001           //������� 1+2+3
};

enum
{
    WXTASKDATA_FLAG_DOING = 0,     // �������ڽ�����
    WXTASKDATA_FLAG_CANGET_REWARD, // �������ȡ
    WXTASKDATA_FLAG_FINISHED,      // ���������
};

enum
{
    WXTASK_AWARD_WRONG_TASK_NULL = 1,     // û����������
    WXTASK_AWARD_WRONG_NOT_ACTIVE,        // ������δ����
    WXTASK_AWARD_WRONG_CONDITION,         // �����������
    WXTASK_AWARD_WRONG_REWARD,            // ����������
    WXTASK_AWARD_WRONG_ALREADY_AWARD,     // �����Ѿ���ȡ
    WXTASK_AWARD_WRONG_NOT_FINISHED,      // ����û�����
    WXTASK_AWARD_WRONG_OPERATE_FAST,      // Ƶ����ȡ����
};

// ���ݿ����
typedef struct _tagWxTaskValue
{
    int nType;                  // ����
    int nValue;                 // ��ֵ
} WXTASKVALUE, *LPWXTASKVALUE;

typedef struct _tagWxTaskParam
{
    int nParam[WXTASK_PARAM_TOTAL];   // ������
} WXTASKPARAM, *LPWXTASKPARAM;

typedef struct _tagWxTaskData
{
    int nGroupID;               // ������ID
    int nSubID;                 // ������ID
    int nFlag;                  // ����״̬
} WXTASKDATA, *LPWXTASKDATA;

typedef struct _tagWxTaskDataEx
{
    int nGroupID;               // ������ID
    int nSubID;                 // ������ID
    int nFlag;                  // ����״̬
    CTime tTime;                // ��ȡʱ��
} WXTASKDATAEX, *LPWXTASKDATAEX;

typedef struct _tagWxTaskInfo
{
    int nGroupID;               // ������ID
    int nSubID;                 // ������ID
    TCHAR szWebID[32];          // ����WebID
    int nType;                  // ��������
    TCHAR szCondition[32];      // �������
    TCHAR szReward[32];         // ��ɽ���
    int nNextID;                // ��һ����ID
    int nActive;                // �����־
} WXTASKINFO, *LPWXTASKINFO;

// ��������Data����Param�����ݣ�
typedef struct _tagWxTaskQuery
{
    int nUserID;                // userid
    int nType;                  // ��������
    int nDate;                  // ����������

    int nReserved[4];           // �����ֶ�
} WXTASKQUERY, *LPWXTASKQUERY;

// ��ȡ����
typedef struct _tagWxTaskAward
{
    int nUserID;                // userid
    int nType;                  // ��������
    int nGroupID;               // ������ID
    int nSubID;                 // ������ID
    int nDate;                  // ����������

    int nReserved[4];           // �����ֶ�
    KPI::KPI_CLIENT_DATA kpiClientData; //KPI�ͻ�������
} WXTASKAWARD, *LPWXTASKAWARD;

// ����������
typedef struct _tagWxTaskParamInfo
{
    int nUserID;                // userid
    int nDate;                  // ��������
    int nParam[TASK_PARAM_TOTAL];  // ��������

    int nReserved[4];           // �����ֶ�
} WXTASKPARAMINFO, *LPWXTASKPARAMINFO;

// ����������
#define MAX_TASK_DATA_NUM       20
typedef struct _tagWxTaskDataInfo
{
    int nUserID;                // userid
    int nDate;                  // ��������
    int nDataNum;               // ��������
    WXTASKDATA tData[MAX_TASK_DATA_NUM];  // ��������

    int nReserved[4];           // �����ֶ�
} WXTASKDATAINFO, *LPWXTASKDATAINFO;

// ���������
typedef struct _tagWxTaskResult
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
} WXTASKRESULT, *LPWXTASKRESULT;

// �������仯
#define MAX_TASK_PARAM_NUM      10
typedef struct _tagWxTaskParamChange
{
    int nUserID;                 // userid
    BOOL bIsHandPhone;           // �Ƿ��ֻ����û�
    int nType;                   // ��������
    int nValue;                  // ������ֵ

    int nReserved[4];            // �����ֶ�
} WXTASKPARAMCHANGE, *LPWXTASKPARAMCHANGE;

// ������仯
typedef struct _tagWxTaskDataChange
{
    int nUserID;                 // userid
    int nDate;                   // ��������
    int nGroupID;                // ������ID
    int nSubID;                  // ������ID
    int nFlag;                   // �����־

    int nReserved[4];            // �����ֶ�
} WXTASKDATACHANGE, *LPWXTASKDATACHANGE;

typedef struct _tagReqWxTaskInfo
{
    int nReq;       // 0 task, 1 ltask, 3 all
    int nUserID;
    int nVersion;   //�汾��Ϣ
} ReqWxTaskInfo, *LPReqWxTaskInfo;

typedef struct _tagWxTaskInfoRecord
{
    int taskid;
    int conditionType;
    int conditionCount;
    int reward;
    int rewardType;
    int nextid;
    char szWebID[32];
} WxTaskInfoRecord, *LPWxTaskInfoRecord;

typedef struct _tagWxTaskInfoData
{
    int nCount;
    int nReqType;   //0 task, 1 ltask
    int nVersion;   //�汾��Ϣ
} WxTaskInfoData, *LPWxTaskInfoData;

/*json ����Ľṹ��*/

typedef struct _tagWxTaskInfoJson
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
} WXTASKINFOJSON, *LPWXTASKINFOJSON;