#pragma once
#include <vector>

#define TREASURE_ERR_TRANSMIT        _T("服务器网络故障，请过段时间后再试。")
#define TREASURE_ERR_CHUNKERR        _T("服务器查询异常，请过段时间后再试。")

// 消息号 和客户端交互的
#define GR_QUERY_TREASURE_INFO          (GAME_REQ_INDIVIDUAL + 2200)  // 请求宝箱任务信息
#define GR_TAKE_TREASURE_AWARD          (GAME_REQ_INDIVIDUAL + 2201)  // 请求领奖

// 服务端之间交互的数据
#define GR_TREASURE_UPDATE_TASK_DATA    (GAME_REQ_INDIVIDUAL + 2202)  // 修改宝箱任务进度
#define TREASURE_AWARD_ALL_CHANCE       100000

// chunk和assist返回值
#define UR_OPERATE_CLOSE        (UR_REQ_BASE + 10101)       // 活动已经关闭了
#define UR_OPERATE_RE_ARWARD    (UR_OPERATE_CLOSE + 1)      // 重复领奖
#define UR_OPERATE_NOT_READY    (UR_OPERATE_RE_ARWARD + 1)  // 未达到领奖条件

#define TREASURE_MID_MAX_LEN            12
#define TREASURE_TASKS_MAX_LEN          12

enum
{
    TREASURE_COLOR_GREEN = 1,
    TREASURE_COLOR_BLUE,
    TREASURE_COLOR_PURPLE,
    TREASURE_COLOE_ORANGE
};

// 客户端交互结构体定义 **************************
// 客户端领奖请求结构体
typedef struct _reqTreasureAwardPrize
{
    int nUserID;
    int nRoomID;
} REQTREASUREAWARDPRIZE, *LPREQTREASUREAWARDPRIZE;

// trunk返回assist领奖结构体
typedef struct rspTreasureAwardPrize
{
    int userid;
    int roomid;
    int boutcount;
    int next_goal;      // 下一轮的次数 0 代表没有了
    int prize_count;    // 奖励数量
    int last_count;     // 上一次领奖时的对局数
    int type;           // 0银两,1兑换券
    int MgId;           // 任务组Id
    char MId[TREASURE_MID_MAX_LEN];     // 任务Id
} RSPTREASUREAWARDPRIZE, *LPRSPTREASUREAWARDPRIZE;

// 客户端领奖rsp结构体
typedef struct RspAwardPrize
{
    int ret;            // 1 OK, 其他 error
    int prize_count;    // 奖励数量
    int type;           // 0银两,1兑换券
    int next_goal;      // 下一轮的次数 0 代表没有了
    int last_count;     // 上一次领奖时的对局数
} RSPAWARDPRIZE, *LPRSPAWARDPRIZE;

// 客户端任务数据请求结构体
typedef struct ReqTreasureInfo
{
    int nUserID;
    int nRoomID;
} REQTREASUREINFO, *LPREQTREASUREINFO;

// 客户端任务数据rsp结构体
typedef struct _rspTreasureInfo
{
    int enable;
    int color;      // 0 - 绿, 1 – 蓝, 2 - 紫, 3 – 橙
    int goal;       // 如果goal 是0，说明所有任务都已经领取完毕了，今日不用再领取了。
    int progress;   // 当前进度
    int last_count; // 上一次领奖的对局数量
} RSPTREASUREINFO, *LPRSPTREASUREINFO;
// *****************************************************


// 内部数据维护
typedef struct _tagTreasureConfig
{
    int taskeid;    //任务抽奖的ID
    int begin_time; //开始时间
    int end_time;   //结束时间
} TREASURERE_CONFIG, *LPTREASURERE_CONFIG;

// 任务信息info配置 *********************************
typedef struct _tagTreasureRewardItem
{
    int id;         //  json中的id
    int count;      //  物品数量
    int type;       //  奖品类型; 0 银子;1 兑换券
    std::string webid;  //  物品类型
} TREASUREREWARDITEM;

// 任务奖励及概率子结构体
typedef struct _tagTreasureRewardInfo
{
    std::string webid;
    int type;   //奖励类型 0 银子; 1 兑换券
    int reward_count;
    float rate;
} TREASUREREWARDINFO, *LPTREASUREREWARDINFO;

// 单条任务局数配置结构体
typedef struct _tagTreasureTaskInfo
{
    int task_goal;
    std::vector< TREASUREREWARDINFO > rewards;
} TREASURETASKINFO, *LPTREASURETASKINFO;

// 房间任务配置结构体
typedef struct TreasureRoomInfo
{
    int roomid;
    int color;
    std::vector< TREASURETASKINFO > tasks;
} TREASUREROOMINFO, *LPTREASUREROOMINFO;
/***************************************************/


/* 服务端交互接口 *****************************************/
// 服务端获取任务进度结构体
typedef struct reqTreasureTaskData
{
    int userid;
    int roomid;
} REQTREASURETASKDATA, *LPREQTREASURETASKDATA;


// 服务端请求添加次数
typedef struct reqAddTreasureTaskData
{
    int userid;
    int roomid;
    int count;   // 添加次数
} REQADDTREASURETASKDATA, *LPREQADDTREASURETASKDATA;

// 服务端添加次数的回复
typedef struct rspAddTreasureTaskData
{
    int ret;
} RSPADDTREASURETASKDATA, *LPRSPADDTREASURETASKDATA;
/********************************************************/


//////////////////////////////////////////////////////////////////////////
// 表结构体
struct tbl_TreasureTaskData
{
    int roomid;
    int userid;
    int count;
    int last_reward_count;
    int task_reward_round;
};
//////////////////////////////////////////////////////////////////////
// 埋点结构体
typedef struct _logTreasureAward
{
    int nUserID;
    int nRoomID;
    int nBoutCount;
    int nPrizeType;
    int nPrizeCount;
    int nAwardSuccess;
} LOGTREASUREAWARD, *LPLOGTREASUREAWARD;