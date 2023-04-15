#pragma once

#include "json.h"

// 消息号
#define GR_WXTASK_CHANGE_PARAM        (GAME_REQ_INDIVIDUAL + 4100)    // 改变任务量数据
#define GR_WXTASK_CHANGE_DATA         (GAME_REQ_INDIVIDUAL + 4101)    // 改变做任务数据

#define GR_WXTASK_QUERY_DATA          (GAME_REQ_INDIVIDUAL + 4105)    // 查询做任务数据
#define GR_WXTASK_QUERY_PARAM         (GAME_REQ_INDIVIDUAL + 4106)    // 查询任务量数据
#define GR_WXTASK_AWARD_PRIZE         (GAME_REQ_INDIVIDUAL + 4107)    // 领取任务奖励

#define GR_WXTASK_SOAP_PRIZE          (GAME_REQ_INDIVIDUAL + 4110)    // soap领取任务奖励
#define GR_WXTASK_DELETE_TABLE        (GAME_REQ_INDIVIDUAL + 4111)    // 删除数据库表

#define GR_WXTASK_QUERY_TASK_INFO     (GAME_REQ_INDIVIDUAL + 4117) 
#define GR_WXTASK_GET_DATA_FOR_JSON   (GAME_REQ_INDIVIDUAL + 4125)    // 获取数据库任务配置
#define GR_WXTASK_AWARD_PRIZE_JSON    (GAME_REQ_INDIVIDUAL + 4126)    // 日常任务领取奖励

// 任务类型
#define WXTASK_PARAM_TOTAL 28
enum
{
    /*****************通用参数*****************/
    WXTASK_GAME_RESULT_WIN = 1,       // 1 - 赢的局数
    WXTASK_GAME_RESULT_LOSE,          // 2 - 输的局数
    WXTASK_GAME_RESULT_DRAW,          // 3 - 平的局数
    WXTASK_GAME_CUR_WIN_STREAK,       // 4 - 当前连胜
    WXTASK_GAME_MAX_WIN_STREAK,       // 5 - 最大连胜
    /*****************游戏特有*****************/
    WXTASK_GAME_WIN_DEPOSIT,          // 6 - 今日赢得银两数
    WXTASK_HU_TIMES,                  //7胡牌次数
  

    /******************客户端******************/
    WXTASK_PARAM_FROM_CLIENT = 20,
    WXTASK_GAME_SHARE_COUNT,            // 21- 分享次数
    WXTASK_GAME_LOOKADVER_COUNT,        // 22- 看广告次数

    WXTASK_CONDITION_COM_GAME_COUNT = 1001           //参数组合 1+2+3
};

enum
{
    WXTASKDATA_FLAG_DOING = 0,     // 任务正在进行中
    WXTASKDATA_FLAG_CANGET_REWARD, // 任务可领取
    WXTASKDATA_FLAG_FINISHED,      // 任务已完成
};

enum
{
    WXTASK_AWARD_WRONG_TASK_NULL = 1,     // 没有这条任务
    WXTASK_AWARD_WRONG_NOT_ACTIVE,        // 该任务未激活
    WXTASK_AWARD_WRONG_CONDITION,         // 完成条件有误
    WXTASK_AWARD_WRONG_REWARD,            // 任务奖励有误
    WXTASK_AWARD_WRONG_ALREADY_AWARD,     // 任务已经领取
    WXTASK_AWARD_WRONG_NOT_FINISHED,      // 任务没有完成
    WXTASK_AWARD_WRONG_OPERATE_FAST,      // 频繁领取操作
};

// 数据库相关
typedef struct _tagWxTaskValue
{
    int nType;                  // 类型
    int nValue;                 // 数值
} WXTASKVALUE, *LPWXTASKVALUE;

typedef struct _tagWxTaskParam
{
    int nParam[WXTASK_PARAM_TOTAL];   // 任务量
} WXTASKPARAM, *LPWXTASKPARAM;

typedef struct _tagWxTaskData
{
    int nGroupID;               // 任务组ID
    int nSubID;                 // 任务子ID
    int nFlag;                  // 任务状态
} WXTASKDATA, *LPWXTASKDATA;

typedef struct _tagWxTaskDataEx
{
    int nGroupID;               // 任务组ID
    int nSubID;                 // 任务子ID
    int nFlag;                  // 任务状态
    CTime tTime;                // 领取时间
} WXTASKDATAEX, *LPWXTASKDATAEX;

typedef struct _tagWxTaskInfo
{
    int nGroupID;               // 任务组ID
    int nSubID;                 // 任务子ID
    TCHAR szWebID[32];          // 奖励WebID
    int nType;                  // 任务类型
    TCHAR szCondition[32];      // 完成条件
    TCHAR szReward[32];         // 完成奖励
    int nNextID;                // 下一个子ID
    int nActive;                // 激活标志
} WXTASKINFO, *LPWXTASKINFO;

// 请求任务（Data或者Param的数据）
typedef struct _tagWxTaskQuery
{
    int nUserID;                // userid
    int nType;                  // 任务类型
    int nDate;                  // 请求发生日期

    int nReserved[4];           // 保留字段
} WXTASKQUERY, *LPWXTASKQUERY;

// 领取奖励
typedef struct _tagWxTaskAward
{
    int nUserID;                // userid
    int nType;                  // 任务类型
    int nGroupID;               // 任务组ID
    int nSubID;                 // 任务子ID
    int nDate;                  // 请求发生日期

    int nReserved[4];           // 保留字段
    KPI::KPI_CLIENT_DATA kpiClientData; //KPI客户端数据
} WXTASKAWARD, *LPWXTASKAWARD;

// 任务量数据
typedef struct _tagWxTaskParamInfo
{
    int nUserID;                // userid
    int nDate;                  // 返回日期
    int nParam[TASK_PARAM_TOTAL];  // 任务数据

    int nReserved[4];           // 保留字段
} WXTASKPARAMINFO, *LPWXTASKPARAMINFO;

// 做任务数据
#define MAX_TASK_DATA_NUM       20
typedef struct _tagWxTaskDataInfo
{
    int nUserID;                // userid
    int nDate;                  // 返回日期
    int nDataNum;               // 数据数量
    WXTASKDATA tData[MAX_TASK_DATA_NUM];  // 任务数据

    int nReserved[4];           // 保留字段
} WXTASKDATAINFO, *LPWXTASKDATAINFO;

// 任务奖励结果
typedef struct _tagWxTaskResult
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
} WXTASKRESULT, *LPWXTASKRESULT;

// 数据量变化
#define MAX_TASK_PARAM_NUM      10
typedef struct _tagWxTaskParamChange
{
    int nUserID;                 // userid
    BOOL bIsHandPhone;           // 是否手机端用户
    int nType;                   // 任务类型
    int nValue;                  // 任务数值

    int nReserved[4];            // 保留字段
} WXTASKPARAMCHANGE, *LPWXTASKPARAMCHANGE;

// 做任务变化
typedef struct _tagWxTaskDataChange
{
    int nUserID;                 // userid
    int nDate;                   // 请求日期
    int nGroupID;                // 任务组ID
    int nSubID;                  // 任务子ID
    int nFlag;                   // 任务标志

    int nReserved[4];            // 保留字段
} WXTASKDATACHANGE, *LPWXTASKDATACHANGE;

typedef struct _tagReqWxTaskInfo
{
    int nReq;       // 0 task, 1 ltask, 3 all
    int nUserID;
    int nVersion;   //版本信息
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
    int nVersion;   //版本信息
} WxTaskInfoData, *LPWxTaskInfoData;

/*json 任务的结构体*/

typedef struct _tagWxTaskInfoJson
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
} WXTASKINFOJSON, *LPWXTASKINFOJSON;