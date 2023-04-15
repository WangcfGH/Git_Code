#pragma once
#include "KPIReq.h"
#include "TaskReq.h"
#include "LotteryReq.h"
#include "DataRecordReq.h"
#include "RankMatchReq.h"
#include "OnLineReq.h"
#include "WxTaskReq.h"
#include "TreasureReq.h"
#include "ExPlayerInfoReq.h"
#include "UserRecordDataReq.h"
#include "NewTaskReq.h"
#include "ResultRestoreReq.h"
// 1000 ~
//分享送礼品
#define  GR_EXCHANGE_SHARE      (GAME_REQ_INDIVIDUAL + 1107)  // 送兑换劵的分享
#define  GR_ROOMCARD_SHARE      (GAME_REQ_INDIVIDUAL + 1108)  // 送房卡的分享
#define  GR_GET_SHARE_GIFTCOUNT (GAME_REQ_INDIVIDUAL + 1109)  // 获取分享送奖励数目
#define  GR_QUERY_SHAREINFO     (GAME_REQ_INDIVIDUAL + 1110)  // 查询今日是否分享过
#define  GR_NTF_MYPLAYERLOGON   (GAME_REQ_INDIVIDUAL + 1111)  // 自己弄的登录信息

#define YQW_THUMB_C2S           (GAME_REQ_INDIVIDUAL + 3201)    // 一起玩的点赞c->s
#define YQW_THUMB_S2C           (GAME_REQ_INDIVIDUAL + 3202)    // 一起玩的点赞s->c
#define YQW_QUERY_THUMB         (GAME_REQ_INDIVIDUAL + 3203)    // 查询点赞数
#define YQW_QUERY_THUMB_S2C     (GAME_REQ_INDIVIDUAL + 3204)    // 返回点赞数
#define GR_QUERY_FLAUNT_INFO    (GAME_REQ_INDIVIDUAL + 3205)    // 查询炫耀分享信息
#define GR_UPDATE_FLAUNT_INFO   (GAME_REQ_INDIVIDUAL + 3206)    // 更新炫耀分享信息

#define GR_SYNC_PLAYER_PORTRAIT         (GAME_REQ_INDIVIDUAL+6001)      // 客户端同步用户头像数据
#define GR_GET_PLAYER_PORTRAIT          (GAME_REQ_INDIVIDUAL+6002)      // 客户端获取用户数据

// ChunkSvr Response
#define UR_LUCKCARD_ZERO        (UR_OPERATE_FAILED + 4)


typedef struct _tagSERVERPULSE_INFO // Pulse info of GameSvr / ChunkSvr
{
    int   nCurrentDate;    // 20150303
    int   nLatestTime;     // 2038秒
    int   nReconnectCount; // 每日统计，次日清0
} SERVERPULSE_INFO, *LPSERVERPULSE_INFO;

typedef struct _tagRoomCardShare
{
    int nGameID;
    int nUserID;
    int nItemID;
    int nShareType;
    int nFirst;
    int nCount;
    TCHAR szIemi[31];
} ROOMCARDSHARE, *LPROOMCARDSHARE;

typedef struct _tagGetShareGiftCount
{
    int nGameID;
    int nUserID;
    int nCount;
} GetShareGiftCount, *LPGetShareGiftCount;

typedef struct _tagQueryShareInfo
{
    int nGameID;
    int nUserID;
    int nStatus;
    TCHAR szIemi[31];
} QueryShareInfo, *LPQueryShareInfo;

typedef struct _tagNtfServerLogon
{
    int nGameID;
    int nUserID;
    int nStatus;
    LONG lToken;
    SOCKET sock;
    int nReserve[32];
} NtfServerLogon, *LpNtfServerLogon;

typedef struct _tagThumbC2S
{
    int nUserID;
    int nDestUserID;
    int nOtherUserID[8];
    int nRoomNO;
    DWORD dwTimeStamp;
    int nReserve[32];
} ThumbC2S, *LpThumbC2S;

typedef struct _tagQueryThumbInfo
{
    int     nUserID;
    int     nThumbCount;
    int     nReserved[8];
} QueryThumbInfo, *LPQueryThumbInfo;

typedef struct _tagUpdateFlauntBout
{
    int     nUserID;
    BOOL    bWin;
    int     nReserved[8];
} UpdateFlauntBout, *LPUpdateFlauntBout;

typedef struct _tagQueryFlauntInfo
{
    int     nUserID;
    int     nRepeatWinBout;
    int     nRepeatLoseBout;
    int     nReserved[8];
} QueryFlauntInfo, *LPQueryFlauntInfo;

typedef struct _tagPAY_RESULTEX
{
	int nUserID;
	TCY_PAY_TO nPayTo;
	TCY_PAY_FOR nPayFor;
	int nGameID; //充值到游戏的gameid；或者充值到后备箱的gameid；充值到保险箱为0
	LONGLONG llOperationID; //操作ID
	LONGLONG llBalance; //余额
	int nOperateAmount; //操作数量
	int nCreateTime;
	DWORD dwFlags;
	int nRoomID; //玩家所在房间roomid，和充值行为无关
	char szGameGoodsID[17]; //游戏商品ID
	char szLinkNo[33]; //操作订单号
	char Reserved[10];				 //字段复用时，一定要注意调整后的结构体长度还是要保持112字节
	int nActID;  //活动id
} PAY_RESULTEX, * LPPAY_RESULTEX;