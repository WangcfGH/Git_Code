#pragma once

//#include "json.h"

#define ROBOT_ERR_TRANSMIT        _T("服务器网络故障，请过段时间后再试。")
#define ROBOT_ERR_CHUNKERR        _T("服务器查询异常，请过段时间后再试。")

#define GR_QUERY_ROBOT_INFO         (GAME_REQ_INDIVIDUAL + 2300)    // 请求机器人房间数据
#define GR_UPDATE_ROBOT_INFO        (GAME_REQ_INDIVIDUAL + 2301)    // 更新机器人数据

// 客户端交互结构体定义 **************************
// 客户端机器人数据请求
typedef struct _reqRobotInfoQuery
{
    int nUserID;
    char sDeviceID[32];
    int nBout;      // 玩家总对局数(胜负平相加, 用来判断是否符合新手条件)
} REQROBOTINFOQUERY, *LPREQROBOTINFOQUERY;

typedef struct _rspRobtInfoQuery
{
    int nUserID;
    int bCanJoinRobot; // 只需要回复能不能进机器人场
} RSPROBOTINFOQUERY, *LPRSPROBOTINFOQUERY;


typedef struct _reqRobotInfoUpdate
{
    int nUserID;
    char sDeviceID[32];
    int nIsLose;
    int bIsRobot;
    int nBout;      // 玩家总对局数(胜负平相加, 用来判断是否符合新手条件)
} REQROBOTINFOUPDATE, *LPRREQROBOTINFOUPDATE;

typedef struct _rspRobotInfoUpdate
{
    int nUserID;
    int bCanJoinRobot; // 只需要回复能不能进机器人场
} RSPROBOTINFOUPDATE, *LPRSPROBOTINFOUPDATE;
//*************************************************

typedef struct _robotConfig
{
    int nTotalLimitBout;        // 新手条件, 几局之内算新手
    int nRobotLimitBount;       // 机器人房可以打几局
    int nDeviceLimitBount;      // 设备上限
    int nDailyLimitBount;       // 每天首N局可进机器人房
    int nLoseCondition;         // 连败N保护
} ROBOT_CONFIG;

typedef struct _dataUserRobotInfo
{
    int nUserID;
    int nRobotBout;        // 机器人场对局数
    int nDailyBout;        // 每日对局数
    int nLoseBout;         // 连败数
} data_userRobotInfo;

typedef struct _robotUpdatePlayerData
{
    int nUserID;            //用户ID
    int nTotalBouts;        //总局数
    int nWin;               //输 -1 赢 1 平 0
    int bSpecialRobot;      //是否是新手机器人对局
} ROBOT_UPDATE_PLAYERDATA, *LPROBOT_UPDATE_PLAYERDATA;

typedef struct _robotPlayerData
{
    int nUserID;
    int nTodayCount;  //今日局数
    int nLoseCount;   //连输
    int nRobotCountGot;  //今日已匹配机器人次数
    int nContainRobot;  //机器人房输了，需要保留次数
} ROBOT_PLAYER_DATA, *LPROBOT_PLAYER_DATA;

typedef struct _tagQueryUserRobotData
{
    int         nUserID;                        //用户ID
} ROBOT_QUERY_USERDATA, *LPROBOT_QUERY_USERDATA;


typedef struct _tagRemoveUserRobotData
{
    int         nUserID;                        //用户ID
} ROBOT_REMOVE_USERDATA, *LPROBOT_REMOVE_USERDATA;