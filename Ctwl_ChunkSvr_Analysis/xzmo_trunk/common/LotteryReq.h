#pragma once

#define     GR_SHARE_SUCCESS           (GAME_REQ_INDIVIDUAL + 3100)  // 分享成功通知服务器

#define     GR_LOTTERY_SHOW            (GAME_REQ_INDIVIDUAL + 3105)  // 查询当前版本抽奖是否可以显示
#define     GR_LOTTERY_HARVEST         (GAME_REQ_INDIVIDUAL + 3105)  // 通过各种动作(局数、分享、...)收获抽奖次数
#define     GR_LOTTERY_QUERY           (GAME_REQ_INDIVIDUAL + 3106)  // 查询抽奖信息
#define     GR_LOTTERY_DO              (GAME_REQ_INDIVIDUAL + 3107)  // 执行抽奖动作
#define     GR_LOTTERY_AWARD           (GAME_REQ_INDIVIDUAL + 3108)  // 发放抽奖奖品
#define     GR_LOTTERY_CONTINUE        (GAME_REQ_INDIVIDUAL + 3109)  // 继续上次未完的发奖动作
#define     GR_SOAP_LOTTERY            (GAME_REQ_INDIVIDUAL + 3110)  // soap抽奖消息
#define     GR_SOAP_GET_PRIZE          (GAME_REQ_INDIVIDUAL + 3111)  // soap发奖消息
//任务抽奖start
#define     GR_LOTTERY_ALL_TASKINFO_REQ     (GAME_REQ_INDIVIDUAL + 3112)    //获取所有任务抽奖数据
#define     GR_LOTTERY_FINISHTASK_REQ       (GAME_REQ_INDIVIDUAL + 3113)    //提交任务完成请求
#define     GR_LOTTERY_UPDATE_TASKJSON      (GAME_REQ_INDIVIDUAL + 3114)    //通过版本号更新任务json
#define     GR_LOTTERY_UPDATE_TASKPROCESS   (GAME_REQ_INDIVIDUAL + 3115)    //更新任务进度
#define     GR_LOTTERY_NTF_PROCESS_UPDATE   (GAME_REQ_INDIVIDUAL + 3116)    //通知客户端任务进度有更新(暂未使用）
//任务抽奖end

//抽奖相关 数据库结构
#define MAX_LOTTERY_KIND  5  // 抽奖类型支持种数，目前模板用5种，方便扩充
#define MAX_GAME_CODE_LEN 16
enum
{
    tLotteryKindBegin,
    tLotteryBout = tLotteryKindBegin,     // 局数抽奖(经典局)
    tLotteryShare,                        // 分享抽奖
    tLooteryTask,                         // 任务抽奖
    tLooteryYQW,                          // 房卡模式局数抽奖
    tLooteryTQWFk,                        // 房卡模式开房抽奖
    // ... 其他抽奖类型在这扩充

    tLotteryKindEnd,
};

enum
{
    tLotteryStatusNormal,           // 查询正常状态
    tLotteryStatusClose,            // 活动已关闭
    tLotteryStatusSaturation,       // 今日抽奖次数已经用完
    tLotteryStatusUnable,           // 次数不够不能抽奖
};

enum
{
    tLotteryResultStatusSuccess,     // 抽奖结果：立即到账
    tLotteryResultStatusDelay,       // 抽奖结果：延迟到账，比如话费
    tLotteryResultStatusFailed,      // 抽奖结果：失败
};

enum
{
    tLotteryPrizeTypeSilver = 1,
    tLotteryPrizeTypeHF,
    tLotteryPrizeTypeCloth,
    tLotteryPrizeTypeGoods,
    tLotteryPrizeTypeScore  = 6,
    tLotteryPrizeTypeTicket = 8,
};

enum
{
    LOTTERY_TASKSTATUS_DOING,                   //任务已领取, 正在做任务
    LOTTERY_TASKSTATUS_FINISH,                  //任务已完成，还未领取奖励（任务抽奖的任务奖励的都是抽奖次数，存在redis中，立刻发放，所以不存在该状态）
    LOTTERY_TASKSTATUS_OVER,                    //已领取奖励，任务结束
};

enum
{
    LOTTERYTASK_REFRESH_DAILY,                  //每晚24点清零
    LOTTERYTASK_REFRESH_WEEKEND,                //每周日24点清零
    LOTTERYTASK_REFRESH_APPOINT                 //指定时间刷新
};


// 任务类型
enum
{
    /*****************通用参数*****************/
    LOTTERYTASK_GAME_RESULT_WIN = 1,       // 1 - 赢的局数
    LOTTERYTASK_GAME_RESULT_LOSE,          // 2 - 输的局数
    LOTTERYTASK_GAME_RESULT_DRAW,          // 3 - 平的局数
    LOTTERYTASK_GAME_CUR_WIN_STREAK,       // 4 - 当前连胜
    LOTTERYTASK_GAME_MAX_WIN_STREAK,       // 5 - 最大连胜
    /*****************游戏特有*****************/
    LOTTERYTASK_GAME_GANG,                 //6 -  杠牌
    LOTTERYTASK_GAME_RESULT_SDB,           //7 -  双吊宝

    LOTTERYTASK_GAME_ZIMO_COUNT,           //8 - 自摸次数
    LOTTERYTASK_GAME_CREATE_BOUT,          //9 - 创建房间次数
    LOTTERYTASK_GAME_7FENQ_COUNT,          //10 - 13烂七风全门缺次数
    LOTTERYTASK_GAME_ROUND_COUNT,          //11 - 一起玩的局数任务
    LOTTERYTASK_GAME_13LAN_COUNT,          //12 - 13烂
    LOTTERYTASK_GAME_CREATEFINISH_BOUT,    //13 - 创建房间并且完成全部对局
    /******************客户端******************/
    LOTTERYTASK_PARAM_FROM_CLIENT = 20,
    LOTTERYTASK_GAME_SHARE_COUNT,          // 21- 分享次数
};

typedef struct _tagLotteryHarvest
{
    int nUserID;                      // userid
    int nTypeID;                      // 抽奖类型
    int nCount;                       // 要增加的次数
    int nReserved[4];
} LOTTERYHARVEST, *LPLOTTERYHARVEST;

// 请求抽奖(请求抽奖信息或者请求执行抽奖动作)
typedef struct _tagLotteryQuery
{
    int  nUserID;                       // userid
    char szHardID[MAX_HARDID_LEN];      // 硬件码
    int nDate;                          // 该请求发生日期

    int  nReserved[4];
} LOTTERYQUERY, *LPLOTTERYQUERY;

// 抽奖信息
typedef struct _tagLotteryInfo
{
    int nUserID;                                // userid
    char szHardID[MAX_HARDID_LEN];              // 硬件码
    int nDate;                                  // 返回的信息的日期

    int nMaxCountEveryday[MAX_LOTTERY_KIND];    // 各种抽奖类型次数
    int nEveryCountEveryKind[MAX_LOTTERY_KIND]; // 多少次送一次该类型的抽奖次数
    int nCurrentCount[MAX_LOTTERY_KIND];        // 各种抽奖类型累计的次数
    int nLotteryToday;                          // 今日累计抽奖次数
    int nLotteryHF;                             // 今日累计中话费的次数
    int nLotteryHFHardID;                       // 此硬件码今日抽中话费的次数
    int nLotteryRelease;                        // 目前剩余可抽次数
    int nStatus;                                // 当前活动状态

    int nBeginDate;                             // 活动开始时间
    int nEndDate;                               // 活动结束时间

    int  nReserved[4];
} LOTTERYINFO, *LPLOTTERYINFO;

// 抽奖结果
typedef struct _tagLotteryResult
{
    int nUserID;                                // userid
    char szHardID[MAX_HARDID_LEN];              // 硬件码
    int nDate;                                  // 该抽奖发生日期

    int nPrizeCount;                            // 奖品数量
    int nPrizeType;                             // 奖品类型
    int nStatus;                                // 抽奖结果
    char szPhone[32];                           // 手机号
} LOTTERYRESULT, *LPLOTTERYRESULT;

typedef struct _tagTempLotteryResult
{
    SOCKET hSocket;
    LONG   lTokenID;
    int    nActivityID;
    LOTTERYRESULT lotteryResult;
} TempLotteryResult, *LPTempLotteryResult;

// 发放话费需要的信息
typedef struct _tagLotteryAward
{
    int nUserID;                        // userid
    char szHardID[MAX_HARDID_LEN];      // 硬件码

    char szPhone[16];                   // 手机号

    int nReserved[4];
} LOTTERYAWARD, *LPLOTTERYAWARD;

///////////////////////////////////////////////////////////////////////////////////
//任务抽奖开始， 2018,04,04

//请求任务信息的请求结构体
typedef struct _tagLOTTERY_ALL_TASKINFO_REQ
{
    int nUserID;
    int nGameID;
    TCHAR szGameCode[MAX_GAME_CODE_LEN];
    int nReserved[8];
} LOTTERY_ALL_TASKINFO_REQ, *LPLOTTERY_ALL_TASKINFO_REQ;

//任务信息回应
typedef struct _tagLOTTERY_ALL_TASKINFO_RESP
{
    int nUserID;
    int nGameID;
    TCHAR szGameCode[MAX_GAME_CODE_LEN];
    int nReserved[8];
    //nTaskCount;
    //LOTTERY_TASKINFO * nTaskCount;
    //nProcessTypeCount;
    //LOTTERY_TASKPROCESS * nProcessTypeCount;
    //nLotteryTypeCount;
    //LOTTERY_INFO * nLotteryTypeCount;
} LOTTERY_ALL_TASKINFO_RESP, *LPLOTTERY_ALL_TASKINFO_RESP;

//抽奖任务信息结构体
typedef struct _tagLOTTERY_TASKINFO
{
    int nTaskID;        //任务id
    int nTaskGroupID;   //任务组号（例如，同样是开房次数任务，那么就属于同一组，客户端通常会显示开房任务中比较低级的任务）
    int nTaskStatus;    //任务状态(未完成 已完成 已领取）
    int nAbortTime;     //任务失效时间
    int nReserved[4];
} LOTTERY_TASKINFO, *LPLOTTERY_TASKINFO;

//抽奖任务进度结构体
typedef struct _tagLOTTERY_TASKPROCESS
{
    int nProcessType;       //任务类型id（例如，开房属于王筝开房类型任务一次，这个任务类型可能是完成多个任务的条件）
    int nProcessCount;  //任务进度count
    int nAbortTime;     //进度归零的时间
    int nReserved[4];
} LOTTERY_TASKPROCESS, *LPLOTTERY_TASKPROCESS;

//可抽奖类型以及次数结构体
typedef struct _tagLOTTERY_INFO
{
    int nLotteryType;   //抽奖类型（比如高级抽奖，低级抽奖）
    int nLotteryCount;  //抽奖次数
    int nAbortTime;     //抽奖机会销毁时间
    int nReserved[4];
} LOTTERY_INFO, *LPLOTTERY_INFO;

//完成领取任务奖励（目前只有抽奖次数的奖励）
typedef struct _tagLOTTERY_FINISHTASK_REQ
{
    int nUserID;
    int nGameID;
    TCHAR szGameCode[MAX_GAME_CODE_LEN];
    int nTaskID;        //任务id
    int nReserved[4];
} LOTTERY_FINISHTASK_REQ, *LPLOTTERY_FINISHTASK_REQ;

typedef struct _tagLOTTERY_FINISHTASK_RESP
{
    int nUserID;
    LOTTERY_TASKINFO stTaskInfo;        //被完成的任务结构体
    int nReserved[8];
    //nProcessTypeCount;
    //nProcessTypeCount*LOTTERY_TASKPROCESS;    //被减少的任务进度
    //nLotteryTypeCount;
    //nLotteryTypeCount*LOTTERY_INFO;       //修改的抽奖类型及次数
} LOTTERY_FINISHTASK_RESP, *LPLOTTERY_FINISHTASK_RESP;

//请求最新的抽奖任务json文件的结构体
typedef struct _tagLOTTERY_UPDATE_TASKJSON_REQ
{
    int nGameID;
    TCHAR szGameCode[MAX_GAME_CODE_LEN];
    int nVersionCode;
    //int nMajorVer;                        //配置文件大版本号  请求只能获取到大版本号相同的配置文件，大版本号不同认定为不兼容（建议各个大版本的配置都可以留一份）
    //int nMinorVer;                        //配置文件小版本号  存在大版本号相同，小版本号不同的文件则即刻触发更新
    //int nBuildNO;                     //配置文件buildno   存在大版本号相同小版本号相同，buildno不同的配置文件则即可触发更新
    int nReserved[8];
} LOTTERY_UPDATE_TASKJSON_REQ, *LPLOTTERY_UPDATE_TASKJSON_REQ;

typedef struct _tagLOTTERY_TASKJSON_RESP
{
    int nVersionCode;
    //int nLen;
    //taskjson;
} LOTTERY_TASKJSON_RESP, *LPLOTTERY_TASKJSON_RESP;

typedef struct _tagLOTTERY_TASKPROCESS_CHANGE
{
    int nUserID;
    LOTTERY_TASKPROCESS stTaskProcess;
    int nReserved[8];
} LOTTERY_TASKPROCESS_CHANGE, *LPLOTTERY_TASKPROCESS_CHANGE;

typedef struct _tagLOTTERY_NTF_PROCESS_UPDATE
{
    int nUserID;
    int nReserved[8];
    //nProcessTypeCount;
    //nProcessTypeCount * LOTTERY_TASKPROCESS;
} LOTTERY_NTF_PROCESS_UPDATE, *LPLOTTERY_NTF_PROCESS_UPDATE;
//任务抽奖结束
///////////////////////////////////////////////////////////////////////////////////