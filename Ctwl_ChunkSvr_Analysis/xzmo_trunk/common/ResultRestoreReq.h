#define GR_RESULT_DEPOSIT_SAVE      (GAME_REQ_INDIVIDUAL + 2160)    // 修改银两记录请求
#define GR_RESULT_DEPOSIT_CLEAN     (GAME_REQ_INDIVIDUAL + 2161)    // 清理银两记录
#define GR_RESULT_RESTORE_CONFIG    (GAME_REQ_INDIVIDUAL + 2162)    // 获取免赔配置
#define GR_RESULT_RESTORE           (GAME_REQ_INDIVIDUAL + 2163)    // 领取免赔奖励
#define GR_RESULT_DOUBLE            (GAME_REQ_INDIVIDUAL + 2164)    // 获取翻倍奖励

enum
{
    STATUS_RESULT_NULL = 0,             // 不存在记录
    STATUS_RESULT_CAN_AWARD = 1,        // 可以免赔或者翻倍
    STATUS_RESULT_ALLREADY_AWARD = 2    // 已经奖励过了
};

// 1.修改银两记录请求
typedef struct{
    int nUserID;
    int nUniqueID;
    int nDeposit;
}ReqResultDepositSave, *LPReqResultDepositSave;

// 2. 清理银两记录请求
typedef struct 
{
    int nUserID[TOTAL_CHAIRS];  // 开局必定有4个人
}ReqResultDepositClean, *LPReqResultDepositClean;

// 3. 获取获取配置和剩余次数req
typedef struct{
    int nUserID;
}ReqResultRestoreConfig, *LPReqResultRestoreConfig;

// 获取获取配置域剩余次数接口rsp
typedef struct
{
    int nUserID;
    int nRestoreCount;
    int nDoubleCount;
}RspResultRestoreConfig, *LPRspResultRestoreConfig;

// 4. 领奖接口(免赔和翻倍)
typedef struct{
    int nUserID;
    int nDeposit;       // 当前银两输赢变化: -100代表输100, +100代表赢100
    KPI::KPI_CLIENT_DATA kpiClientData; //KPI客户端数据
}ReqResultRestoreAward, *LPReqResultRestoreAward;

// 领奖Rsp到assist
typedef struct
{
    int nUserID;
    int nDeposit;   // 领取到的银子数量
    int nStatus;   // 奖励状态
    int nCount;     // 根据是免赔还是翻倍操作来返回不同类型的剩余数量
    KPI::KPI_CLIENT_DATA kpiClientData; //KPI客户端数据
}RspResultRestoreAwardForAssist, *LPRspResultRestoreAwardForAssist;

// 领奖Rsp到app
typedef struct
{
    int nUserID;
    int nDeposit;   // 领取到的银子数量
    int nStatus;   // 奖励状态
    int nCount;     // 根据是免赔还是翻倍操作来返回不同类型的剩余数量
}RspResultRestoreAward, *LPRspResultRestoreAward;