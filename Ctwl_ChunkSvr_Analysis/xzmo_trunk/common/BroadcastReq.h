#pragma once

//////////////////////////////////////
#define     GR_BROADCAST                (GAME_REQ_INDIVIDUAL + 5000)  // 广播消息
#define     GR_BROADCAST_CONFIG         (GAME_REQ_INDIVIDUAL + 5001)  // 获取走马灯配置
#define     GR_BROADCAST_FROM_GAMESVR   (GAME_REQ_INDIVIDUAL + 5002)  // 从游戏服务来的广播消息

#define     MAX_MSG_LEN     256

enum enMSG_TYPE
{
    enMsgTypeNormal = 0,        //普通消息
    enMsgTypeRollItem,          //拉霸
    enMsgTypeLottery,           //转盘抽奖
    enMsgTypeImportant,         //紧急消息, 优先级最高
    enMsgTypeNotice,            //网站公告, 网站读取的公告
    enMsgTypeLocal,             //本地消息, 本地公告, 非联网也能播放
    enMsgTypeTask,              //任务
    enMsgTypeGame,              //游戏
    enMsgTypeArena,             //比赛
    enMsgTypeExchange,          //兑换
    enMsgTypeEmail,             //邮件
    enMsgTypeChat,              //聊天

    enMsgTypeCustom = 100,      //自定义消息请加在该值之后
};

//走马灯配置
typedef struct _tagBROADCAST_CONFIG
{
    BOOL        bEnable;                    //是否开启走马灯功能
    int         nMoveSpeed;                 //播放速度
    TCHAR       szNoticeUrl[MAX_PATH];      //后台公告网址

    int         nRunType;                   //滚动类型, 0从右到左, 1从下往上
    int         nReserved[3];
} BROADCAST_CONFIG, *LPBROADCAST_CONFIG;

typedef struct _tagMESSAGE_INFO
{
    enMSG_TYPE  enMsgType;              //消息类型
    TCHAR       szMsg[MAX_MSG_LEN];     //描述

    int         nReserved[4];
} MESSAGE_INFO, *LPMESSAGE_INFO;

//单条消息信息
typedef struct _tagBROADCAST_MSG
{
    int         nDelaySec;              //延迟N秒广播, 服务端用

    MESSAGE_INFO MessageInfo;

    int         nRoadID;                //跑道ID
    int         nRepeatTimes;           //播放重复次数, 第一次除外
    int         nInterval;              //重复间隔(s)

    int         nReserved[4];

} BROADCAST_MSG, *LPBROADCAST_MSG;
