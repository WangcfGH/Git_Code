/**********************************************************************************************************/
#define GR_TASK_GET_DATA_FOR_JSON_EX        (GAME_REQ_INDIVIDUAL + 2135)    // 获取数据库任务配置 	(主动请求, 0点推送)
#define GR_TASK_QUERY_PARAM_EX              (GAME_REQ_INDIVIDUAL + 2134)    // 查询任务数据	   	(主动请求)
#define GR_TASK_CHANGE_PARAM_EX             (GAME_REQ_INDIVIDUAL + 2133)    // 改变任务量数据	   	(主动请求)
#define GR_TASK_AWARD_PRIZE_EX              (GAME_REQ_INDIVIDUAL + 2132)    // 领取任务奖励		(主动请求)
#define GR_TASK_GET_TASK_COMPLETE_COUNT     (GAME_REQ_INDIVIDUAL + 2130)    // 获取任务红点数量   	(主动请求, 0点推送, 变更时推送)
/**********************************************************************************************************/
#define GR_TASK_GET_LOGON_MSG            (GAME_REQ_INDIVIDUAL + 2131)    // 通知Assist, 让在线玩家请求完成登录任务 
enum
{
    NEW_TASKDATA_FLAG_DOING = 0,     // 任务正在进行中
    NEW_TASKDATA_FLAG_CANGET_REWARD, // 任务可领取
    NEW_TASKDATA_FLAG_FINISHED,      // 任务已完成
};

enum
{
    NEW_TASK_TYPE_ACTIVITY = 0,                 // 活跃度
    NEW_TASK_TYPE_CHECKIN = 1,                  // 签到
    NEW_TASK_TYPE_RECHARGE = 3,                 // 充值
    NEW_TASK_TYPE_LOGON_START = 10,             // 登录请求
    NEW_TASK_TYPE_LOGON_ONE= 11,                // 第一时间段登录
    NEW_TASK_TYPE_LOGON_TWO = 12,               // 第二时间段登录
    NEW_TASK_TYPE_LOGON_MAX = 19,               // 登录任务最大值
    NEW_TASK_TYPE_GAME_BOUT = 100,              // 任意对局任务
    NEW_TASK_TYPE_GAME_WIN = 101,               // 任意赢局任务
    NEW_TASK_TYPE_GAME_WIN_DEPOSIT = 102,       // 累计赢钱任务
    NEW_TASK_TYPE_GAME_GANG_GUA_FENG = 103,     // 刮风任务(碰杠, 明杠)
    NEW_TASK_TYPE_GAME_GANG_XIA_YU = 104,       // 下雨任务(暗杠)
    NEW_TASK_TYPE_GAME_PENG = 105,              // 碰任务
    NEW_TASK_TYPE_GAME_HU_DADANDIAO = 106,      // 胡大单钓
    NEW_TASK_TYPE_GAME_HU_QIDUI = 107,          // 胡七对
    NEW_TASK_TYPE_GAME_HU_QINGYISE = 108,       // 胡清一色
    NEW_TASK_TYPE_GAME_HU_PENGPENGHU = 109,     // 胡碰碰胡
    NEW_TASK_TYPE_GAME_HU_DAIYAOJIU = 110,      // 胡带么九
    NEW_TASK_TYPE_GAME_HU_JIANGDUI = 111,       // 胡将对
    NEW_TASK_TYPE_GAME_HU_ZIMO = 112            // 自摸
};

enum
{
    NEW_TASK_OPE_SUCCESS = 0,   // 操作成功
    NEW_TASK_DATE_ERROR = 1,    // 时间错误
    NEW_TASK_DEPOSIT_LIMIT = 2, // 携银超出限制
    NEW_TASK_NOT_FINISHED = 3,  // 任务未完成
    NEW_TASK_ALLREADY_FINISHED = 4  // 任务已完成
};

struct TaskInfo
{
    int nTaskID;			// 任务ID
    int nCurProgress;		// 当前进度
    int nRewardStatus;		// 领奖状态
};

struct RewardInfo
{
    int nRewardID;		// 奖励ID
    int nRewardCount;	// 奖励数量
    int nSuccess;		// 奖励是否成功
};

//1. 获取任务配置
typedef struct ReqTaskQueryConfig
{
    int nUserID;		// 用户ID
    int nDate;
}REQTASKQUERYCONFIG, *LPREQTASKQUERYCONFIG;

typedef struct RspTaskQueryConfig
{
    int nDate;
    int nUserID;
    char Data[0];   // json格式的config
}RSPTASKQUERYCONFIG, *LPRSPTASKQUERYCONFIG;

//2. 获取红点数量:
typedef struct ReqTaskGetCompleteCount
{
    int nUserID;	// 用户ID
    int nDate;		// 请求发起时间
}REQTASKGETCOMPLETECOUNT, *LPREQTASKGETCOMPLETECOUNT;

typedef struct RspTaskGetCompleteCount
{
    int nUserID;	// 主动推送时,需要知道推送给哪个玩家
    int nDate;
    int nCount;		// 任务完成数量
}RSPTASKGETCOMPLETECOUNT, *LPRSPTASKGETCOMPLETECOUNT;

//3. 获取任务量数据
typedef struct ReqTaskQueryParams
{
    int nUserID;	// 用户ID
    int nDate;		// 请求发起时间
    int nTaskID;	// 任务id, 填写0代表获取全部任务进度
}REQTASKQUERYPARAMS, *LPREQTASKQUERYPARAMS;

typedef struct RspTaskQueryParams
{
    int nDate;
    int nUserID;
    int nTaskCount;		// 任务数量
    struct TaskInfo sTaskInfo[0];
}RSPTASKQUERYPARAMS, *LPRSPTASKQUERYPARAMS;

//4. 改变任务量数据:
typedef struct ReqTaskChangeParams
{
    int nUserID;
    int nDate;		// 请求发起时间
    int nTypeID;	// 任务id
    int nCount;		// 加或者减进度量
}REQTASKCHANGEPARAMS, *LPREQTASKCHANGEPARAMS;

typedef struct RspTaskChangeParams
{
    int nDate;
    int nUserID;
    int nTypeID;		// 任务ID
    int nCurProgress;	// 当前进度
}RSPTASKCHANGEPARAMS, *LPRSPTASKCHANGEPARAMS;

//5. 领奖
typedef struct ReqTaskAwardPrize
{
    int nUserID;	 // 用户ID
    int nDate;		 // 请求时间
    int nTaskID;	 // 任务ID
    int nCurDeposit; // 当前银两 
    KPI::KPI_CLIENT_DATA kpiClientData; //KPI客户端数据
}REQTASKAWARDPRIZE, *LPREQTASKAWARDPRIZE;

typedef struct RspTaskAwardPrize
{
    struct TaskInfo sTaskInfo;		// 当前任务信息
    int nRet;                       // 返回值
    int nActive;					// 当前活跃度
    int nUserID;
    int nRewardCount;				// 奖励类型数量
    struct RewardInfo sRewardInfo[0];	// 奖励列表
}RSPTASKAWARDPRIZE, *LPRSPTASKAWARDPRIZE;

//三.服务器之间交互部分:
typedef struct rewardInfoForAssist
{
    int nRewardID;
    int nRewardCount;	// 奖励数量
    char webID[32];		// 奖励的webid
}REWARDINFOFORASSIST, *LPREWARDINFOFORASSIST;

//1. 领奖 chunk->assist
typedef struct TaskRewardInfo
{
    struct TaskInfo sTaskInfo; 	// 当前任务信息
    int nRet;                   // 返回值
    int nActive;				// 当前活跃度
    int nUserID;				// 用户ID
    int nRewardCount;
    KPI::KPI_CLIENT_DATA kpiClientData; //KPI客户端数据
    REWARDINFOFORASSIST rewardInfo[0];
}TASKREWARDINFO, *LPTASKREWARDINFO;
