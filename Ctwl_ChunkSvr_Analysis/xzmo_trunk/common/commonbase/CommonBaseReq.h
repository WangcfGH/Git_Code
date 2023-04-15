#pragma once

#define  GR_MODIFY_TABLEANDCHAIR    (GAME_REQ_BASE_EX + 11001)  // 随机房dxxw进入游戏后桌子号和椅子号不一样修改下

#define     GR_THROW_PRO            (GAME_REQ_INDIVIDUAL + 5)       // 玩家扔道具消息
#define     GR_SEND_LBSINFO         (GAME_REQ_INDIVIDUAL + 6)       // 游戏内准备前玩家上传定位信息
#define     GR_PROMPT_PLAYER        (GAME_REQ_INDIVIDUAL + 7) // 玩家震动提醒消息
#define     GR_BUY_GOOD_LUCK_PROP   (GAME_REQ_INDIVIDUAL + 100) // 玩家购买好运来;
#define     GR_SHOW_GOOD_LUCK_PROP  (GAME_REQ_INDIVIDUAL + 101) // 向所有玩家展示好运来;
#define     GR_GOOD_LUCK_PROP_STATE (GAME_REQ_INDIVIDUAL + 102) // 下发玩家各自的好运来数据;
#define     GR_ROOM_PROMPT_LINE     (GAME_REQ_BASE_EX + 40001)
#define     DEFAULT_PROMPT_LIME     -1

//欢乐币操作码,0为开房消耗;
enum HAPPYCOIN_DEDUCT_CODE
{
    GOOD_LUCK_DEDUCT = 1,
};

enum GOOD_LUCK_RESULT_TYPE
{
    GOOD_LUCK_RESULT_FREE = 1, //购买成功（免费）;
    GOOD_LUCK_RESULT_PAY,       //购买成功（付费）;
    GOOD_LUCK_RESULT_ROBBED,    //购买失败（被抢）;
    GOOD_LUCK_RESULT_HAPPYCOIN_NOT_ENOUGH,  //购买失败（欢乐币不足）;
    GOOD_LUCK_RESULT_RETURN_FREE,   //（返还免费次数）;
    GOOD_LUCK_RESULT_ROOM_CHARGE_TOO_MORE,  //（欢乐币扣除后不足房费）;
};

enum PROP_ID
{
    PROP_BEGIN = 0,
    PROP_CHICKEN,
    PROP_EGG,
    PROP_MEDAL,
    PROP_SLIPPER,
    PROP_FLOWER,
    PROP_END
};

typedef struct _tagSENDLBSINFO
{
    int nUserID;
    int nRoomID;
    int nTableNO;
    int nChairNO;
    TCHAR szLBSInfo[MAX_YQW_LBS_LEN];               // LBS经纬度
    TCHAR szLbsArea[MAX_YQW_AREA_LEN];              // "浙江省杭州市滨江区江陵路"[超出则截断]
    int nReserved[4];
} SENDLBSINFO, *LPSENDLBSINFO;

typedef struct _tagTHROWPROP
{
    int nUserID;
    int nRoomID;
    int nTableNO;
    int nChairNO;
    int nDstChairNO;
    int nPropID;
} THROWPROP, *LPTHROWPROP;

struct REQ_REPLAY
{
    int  nUserID;                           // 用户ID
    int  nRoomID;                           // 房间ID
    int  nTableNO;                          // 桌号
    int  nChairNO;                          // 位置
    int  nReserved[4];
};



typedef struct _tagSHOW_GOOD_LUCK_PROP
{
    int nUserID;
} SHOW_GOOD_LUCK_PROP, *LPSHOW_GOOD_LUCK_PROP;

typedef struct _tagGOOD_LUCK_PROP_STATE
{
    int nUserID;
    int nFreeCount;
    int nAmount;    //价格;
    int nNoticeType;    //通知类型（1是结算,目前只有结算需要处理）;
    int nGoodLuckUserID;    //购买了好运来的玩家ID;
} GOOD_LUCK_PROP_STATE, *LPGOOD_LUCK_PROP_STATE;

typedef struct _tagPROMPTPLAYER
{
    int nUserID;
    int nRoomID;
    int nTableNO;
    int nChairNO;
    int nPromptUserID;
    int  nReserved[4];
} PROMPTPLAYER, *LPPROMPTPLAYER;

typedef struct  _tagMODIFY_TABLEANDCHAIR
{
    int     nUserID;                               // 用户ID
    int     nRoomID;                               // 房间ID
    int     nTableNO;                              // 桌号
    int     nChairNO;                              // 位置
    int     nReserved[8];
} MODIFY_TABLEANDCHAIR, *LPMODIFY_TABLEANDCHAIR;

typedef struct _tagROOM_PROMPT_LINE
{
    int nUserID;                // 用户ID
    int nRoomID;                // 房间ID
    int nTableNO;               // 桌号
    int nChairNO;               // 位置
    int nRoomPromptLine;        // 房间提示线
    int nReserved[4];
} ROOM_PROMPT_LINE, *LPROOM_PROMPT_LINE;