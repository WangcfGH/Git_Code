#pragma once

#include "json.h"

// 消息号
#define GR_TASK_CHANGE_PARAM        (GAME_REQ_INDIVIDUAL + 2100)    // 改变任务量数据
#define GR_TASK_CHANGE_DATA         (GAME_REQ_INDIVIDUAL + 2101)    // 改变做任务数据

#define GR_TASK_QUERY_DATA          (GAME_REQ_INDIVIDUAL + 2105)    // 查询做任务数据
#define GR_TASK_QUERY_PARAM         (GAME_REQ_INDIVIDUAL + 2106)    // 查询任务量数据
#define GR_TASK_AWARD_PRIZE         (GAME_REQ_INDIVIDUAL + 2107)    // 领取任务奖励

#define GR_TASK_SOAP_PRIZE          (GAME_REQ_INDIVIDUAL + 2110)    // soap领取任务奖励
#define GR_TASK_DELETE_TABLE        (GAME_REQ_INDIVIDUAL + 2111)    // 删除数据库表


#define GR_TASK_QUERY_TASK_INFO     (GAME_REQ_INDIVIDUAL + 2117)    // 获取LTASK数据情况
#define GR_TASK_QUERY_LTASK_DATA    (GAME_REQ_INDIVIDUAL + 2118)    // 获取LTASK数据情况
#define GR_TASK_QUERY_LTASK_PARAM   (GAME_REQ_INDIVIDUAL + 2119)
#define GR_TASK_CHANGE_LTASK_DATA   (GAME_REQ_INDIVIDUAL + 2120)
#define GR_TASK_CHANGE_LTASK_PARAM  (GAME_REQ_INDIVIDUAL + 2121)
#define GR_TASK_AWARD_LTASK         (GAME_REQ_INDIVIDUAL + 2122)
#define GR_LTASK_SOAP_PRIZE         (GAME_REQ_INDIVIDUAL + 2123)
#define GR_TASK_ROOMCARD_AWARD_LTASK        (GAME_REQ_INDIVIDUAL + 2124)    // 任务自动领取房卡奖励
#define GR_TASK_GET_DATA_FOR_JSON   (GAME_REQ_INDIVIDUAL + 2125)    // 获取数据库任务配置
#define GR_TASK_AWARD_PRIZE_JSON    (GAME_REQ_INDIVIDUAL + 2126)    // 日常任务领取奖励
#define GR_TASK_AWARD_LTASK_JSON    (GAME_REQ_INDIVIDUAL + 2127)    // 成长任务领取奖励

// 任务类型
#define TASK_PARAM_TOTAL 28
enum
{
    /*****************通用参数*****************/
    TASK_GAME_RESULT_WIN = 1,       // 1 - 赢的局数
    TASK_GAME_RESULT_LOSE,          // 2 - 输的局数
    TASK_GAME_RESULT_DRAW,          // 3 - 平的局数
    TASK_GAME_CUR_WIN_STREAK,       // 4 - 当前连胜
    TASK_GAME_MAX_WIN_STREAK,       // 5 - 最大连胜
    /*****************游戏特有*****************/
    TASK_GAME_QINGYISE_COUNT,       // 6 - 清一色次数
    TASK_GAME_XUELIU_HUCOUNT_2,     // 7 - 血流一局内胡2次
    TASK_GAME_GANG_COUNT,           // 8 - 杠的次数
    TASK_GAME_WINDEPOSIT_2000,      // 9 - 单局赢2000两
    TASK_GAME_WINDEPOSIT_5000,      // 10 - 单局赢5000两
    TASK_GAME_WINDEPOSIT_10000,     // 11 - 单局赢10000两
    TASK_GAME_WINDEPOSIT_50000,     // 12 - 单局赢50000两
    TASK_GAME_ZIMO_COUNT,           // 13 - 自摸次数
    TASK_GAME_HUBOUT_16,            // 14 - 胡16倍
    TASK_GAME_HUBOUT_32,            // 15 - 胡32倍
    TASK_GAME_HUBOUT_64,            // 16 - 胡64倍
    TASK_GAME_HUBOUT_128,           // 17 - 胡128倍
    ASK_GAME_XUELIU_HUCOUNT_4,      // 18 - 血流一局内胡4次
    ASK_GAME_XUELIU_HUCOUNT_8,      // 19 - 血流一局内胡8次
    ASK_GAME_XUELIU_HUCOUNT_10,     // 20 - 血流一局内胡10次

    //成长任务
    LTASK_PLAYGAME_LOW,               // 21 - 初级场游戏一局
    LTASK_PLAYGAME_MID,               // 22 - 中级场游戏一局
    LTASK_PLAYGAME_HIGH,               // 23 - 高级场游戏一局
    LTASK_GAME_PENCOUNT,            // 24 - 碰的次数
    LTASK_GAME_GANGCOUNT,           // 25 - 杠的次数
    LTASK_GAME_WINDEPOSIT_1000,     // 26 - 单局累计赢1000两
    LTASK_GAME_WINDEPOSIT_5000,     // 27 - 单局累计赢5000两

    /******************客户端******************/
    TASK_GAME_SHARE_COUNT,          // 28- 分享次数

    TASK_CONDITION_MAX = TASK_PARAM_TOTAL + 1,       //数据库最大的TASK_PARAM_TOTAL个目前支持
    TASK_CONDITION_COM_GAME_COUNT = 1001           //参数组合 1+2+3
};

enum
{
    TASKDATA_FLAG_DOING = 0,     // 任务正在进行中
    TASKDATA_FLAG_CANGET_REWARD, // 任务可领取
    TASKDATA_FLAG_FINISHED,      // 任务已完成
};

enum
{
    TASK_AWARD_WRONG_TASK_NULL = 1,     // 没有这条任务
    TASK_AWARD_WRONG_NOT_ACTIVE,        // 该任务未激活
    TASK_AWARD_WRONG_CONDITION,         // 完成条件有误
    TASK_AWARD_WRONG_REWARD,            // 任务奖励有误
    TASK_AWARD_WRONG_ALREADY_AWARD,     // 任务已经领取
    TASK_AWARD_WRONG_NOT_FINISHED,      // 任务没有完成
    TASK_AWARD_WRONG_OPERATE_FAST,      // 频繁领取操作
};

// 数据库相关
typedef struct _tagTaskValue
{
    int nType;                  // 类型
    int nValue;                 // 数值
} TASKVALUE, *LPTASKVALUE;

typedef struct _tagTaskParam
{
    int nParam[TASK_PARAM_TOTAL];   // 任务量
} TASKPARAM, *LPTASKPARAM;

typedef struct _tagTaskData
{
    int nGroupID;               // 任务组ID
    int nSubID;                 // 任务子ID
    int nFlag;                  // 任务状态
} TASKDATA, *LPTASKDATA;

typedef struct _tagTaskDataEx
{
    int nGroupID;               // 任务组ID
    int nSubID;                 // 任务子ID
    int nFlag;                  // 任务状态
    CTime tTime;                // 领取时间
} TASKDATAEX, *LPTASKDATAEX;

typedef struct _tagTaskInfo
{
    int nGroupID;               // 任务组ID
    int nSubID;                 // 任务子ID
    TCHAR szWebID[32];          // 奖励WebID
    int nType;                  // 任务类型
    TCHAR szCondition[32];      // 完成条件
    TCHAR szReward[32];         // 完成奖励
    int nNextID;                // 下一个子ID
    int nActive;                // 激活标志
} TASKINFO, *LPTASKINFO;

// 请求任务（Data或者Param的数据）
typedef struct _tagTaskQuery
{
    int nUserID;                // userid
    int nType;                  // 任务类型
    int nDate;                  // 请求发生日期

    int nReserved[4];           // 保留字段
} TASKQUERY, *LPTASKQUERY;

// 领取奖励
typedef struct _tagTaskAward
{
    int nUserID;                // userid
    int nType;                  // 任务类型
    int nGroupID;               // 任务组ID
    int nSubID;                 // 任务子ID
    int nDate;                  // 请求发生日期

    int nReserved[4];           // 保留字段
    KPI::KPI_CLIENT_DATA kpiClientData; //KPI客户端数据
} TASKAWARD, *LPTASKAWARD;

// 任务量数据
typedef struct _tagTaskParamInfo
{
    int nUserID;                // userid
    int nDate;                  // 返回日期
    int nParam[TASK_PARAM_TOTAL];  // 任务数据

    int nReserved[4];           // 保留字段
} TASKPARAMINFO, *LPTASKPARAMINFO;

// 做任务数据
#define MAX_TASK_DATA_NUM       20
typedef struct _tagTaskDataInfo
{
    int nUserID;                // userid
    int nDate;                  // 返回日期
    int nDataNum;               // 数据数量
    TASKDATA tData[MAX_TASK_DATA_NUM];  // 任务数据

    int nReserved[4];           // 保留字段
} TASKDATAINFO, *LPTASKDATAINFO;

// 任务奖励结果
typedef struct _tagTaskResult
{
    int nUserID;                // userid
    int nDate;                  // 返回日期
    BOOL bResult;               // 奖励发放结果
    int nGroupID;               // 任务组ID
    int nTaskID;                // 任务子ID
    int nFlag;                  // 任务标志
    TCHAR szWebID[32];          // 领奖WebID
    int nRewardType;            // 奖励类型
    int nRewardNum;             // 奖励数量

    int nReserved[4];           // 保留字段
    KPI::KPI_CLIENT_DATA kpiClientData; //KPI客户端数据
} TASKRESULT, *LPTASKRESULT;

// 数据量变化
#define MAX_TASK_PARAM_NUM      10
typedef struct _tagTaskParamChange
{
    int nUserID;                 // userid
    BOOL bIsHandPhone;           // 是否手机端用户
    int nType;                   // 任务类型
    int nValue;                  // 任务数值

    int nReserved[4];            // 保留字段
} TASKPARAMCHANGE, *LPTASKPARAMCHANGE;

// 做任务变化
typedef struct _tagTaskDataChange
{
    int nUserID;                 // userid
    int nDate;                   // 请求日期
    int nGroupID;                // 任务组ID
    int nSubID;                  // 任务子ID
    int nFlag;                   // 任务标志

    int nReserved[4];            // 保留字段
} TASKDATACHANGE, *LPTASKDATACHANGE;


enum LIFE_TASK_TYPE
{
    LFTASK_GAME_SHARE,
    LFTASK_GAME_BOUT,
    LFTASK_GAME_CREATE,
    LFTASK_GAME_3DMJ_COUNT,         // 3 - 3D麻将游戏次数
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
    int nVersion;   //版本信息
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
    int nVersion;   //版本信息
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

    KPI::KPI_CLIENT_DATA kpiClientData; //KPI客户端数据
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
    KPI::KPI_CLIENT_DATA kpiClientData; //KPI客户端数据
} LTaskResult, *LPLTaskResult;

/*json 任务的结构体*/

typedef struct _tagTaskInfoJson
{
    int nGroupID;               // 任务组ID
    int nSubID;                 // 任务子ID
    TCHAR szWebID[32];          // 奖励WebID
    int nType;                  // 任务类型
    int nConditionType;
    int nCondition;             // 完成条件
    int nRewardType;
    int nReward;                // 完成奖励
    Json::Value vCondition;
    Json::Value vReward;
    int nNextID;                // 下一个子ID
    int nActive;                // 激活标志
} TASKINFOJSON, *LPTASKINFOJSON;