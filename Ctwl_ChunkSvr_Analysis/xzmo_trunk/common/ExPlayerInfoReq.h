#pragma once

#define GR_EXPLAYERINFO_QUERY               (GAME_REQ_INDIVIDUAL + 7111)    //查询额外玩家信息
#define GR_EXPLAYERINFO_CHANGE_PARAM        (GAME_REQ_INDIVIDUAL + 7112)    //改变额外玩家信息

#define TOTAL_CHAIRS 4

enum RoomType
{
    EXPLAEYER_COUT_XZ = 1,          // 血战
    EXPLAEYER_COUT_XL               // 血流
};

typedef struct _tagExPlayerInfoParamQuery
{
    int nRoomID;                    //房间ID
    int nTableNo;                   //桌号
    int nUserID[TOTAL_CHAIRS];      // userid

    int nReserved[4];            // 保留字段
} EXPLAYERINFOPARAMQUERY, *LPEXPLAYERINFOPARAMQUERY;

typedef struct _tagExPlayerInfoParamQueryRsp
{
    int nRoomID;                    //房间ID
    int nTableNo;                   //桌号
    int nUserID[TOTAL_CHAIRS];      // userid
    int nXZCount[TOTAL_CHAIRS];     // 血战对局
    int nXLCount[TOTAL_CHAIRS];     // 血流对局
    int nPerDayCount[TOTAL_CHAIRS]; // 当日对局

    int nReserved[4];            // 保留字段
} EXPLAYERINFOPARAMQUERYRSP, *LPEXPLAYERINFOPARAMQUERYRSP;

typedef struct _tagExPlayerInfoParamChange
{
    int nUserID;                 // userid
    BOOL bIsHandPhone;           // 是否手机端用户
    int nType;                   // 房间类型
    int nValue;                  // 任务数值
    int nRoomID;                // 房间ID
    int nTableNo;               // 桌号
    int nChairNo;               // 位置号

    int nReserved[4];            // 保留字段
} EXPLAYERINFOPARAMCHANGE, *LPEXPLAYERINFOPARAMCHANGE;

typedef struct _tagExPlayerInfoParamChangeRsp
{
    int nUserID;                // userid
    int nRoomID;                // 房间ID
    int nTableNo;               // 桌号
    int nChairNo;               // 位置号
    int nXZCount;               // 血战对局
    int nXLCount;               // 血流对局
    int nPerDayCount;           // 当日对局

    int nReserved[4];            // 保留字段
} EXPLAYERINFOPARAMCHANGERSP, *LPEXPLAYERINFOPARAMCHANGERSP;

typedef struct _tagExPlayerInfoPerAdd
{
    int nUserId;
    int nAddCount;
    int type;
} EXPLAYERINFOPERADD, *LPEXPLAYERINFOPERADD;

typedef struct _tagExPlayerInfoPer
{
    int nUserId;
    int nXueZhanCount;
    int nXueLiuCount;
} EXPLAYERINFOPER, *LPEXPLAYERINFOPER;
