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
//��������Ʒ
#define  GR_EXCHANGE_SHARE      (GAME_REQ_INDIVIDUAL + 1107)  // �Ͷһ����ķ���
#define  GR_ROOMCARD_SHARE      (GAME_REQ_INDIVIDUAL + 1108)  // �ͷ����ķ���
#define  GR_GET_SHARE_GIFTCOUNT (GAME_REQ_INDIVIDUAL + 1109)  // ��ȡ�����ͽ�����Ŀ
#define  GR_QUERY_SHAREINFO     (GAME_REQ_INDIVIDUAL + 1110)  // ��ѯ�����Ƿ�����
#define  GR_NTF_MYPLAYERLOGON   (GAME_REQ_INDIVIDUAL + 1111)  // �Լ�Ū�ĵ�¼��Ϣ

#define YQW_THUMB_C2S           (GAME_REQ_INDIVIDUAL + 3201)    // һ����ĵ���c->s
#define YQW_THUMB_S2C           (GAME_REQ_INDIVIDUAL + 3202)    // һ����ĵ���s->c
#define YQW_QUERY_THUMB         (GAME_REQ_INDIVIDUAL + 3203)    // ��ѯ������
#define YQW_QUERY_THUMB_S2C     (GAME_REQ_INDIVIDUAL + 3204)    // ���ص�����
#define GR_QUERY_FLAUNT_INFO    (GAME_REQ_INDIVIDUAL + 3205)    // ��ѯ��ҫ������Ϣ
#define GR_UPDATE_FLAUNT_INFO   (GAME_REQ_INDIVIDUAL + 3206)    // ������ҫ������Ϣ

#define GR_SYNC_PLAYER_PORTRAIT         (GAME_REQ_INDIVIDUAL+6001)      // �ͻ���ͬ���û�ͷ������
#define GR_GET_PLAYER_PORTRAIT          (GAME_REQ_INDIVIDUAL+6002)      // �ͻ��˻�ȡ�û�����

// ChunkSvr Response
#define UR_LUCKCARD_ZERO        (UR_OPERATE_FAILED + 4)


typedef struct _tagSERVERPULSE_INFO // Pulse info of GameSvr / ChunkSvr
{
    int   nCurrentDate;    // 20150303
    int   nLatestTime;     // 2038��
    int   nReconnectCount; // ÿ��ͳ�ƣ�������0
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
	int nGameID; //��ֵ����Ϸ��gameid�����߳�ֵ�������gameid����ֵ��������Ϊ0
	LONGLONG llOperationID; //����ID
	LONGLONG llBalance; //���
	int nOperateAmount; //��������
	int nCreateTime;
	DWORD dwFlags;
	int nRoomID; //������ڷ���roomid���ͳ�ֵ��Ϊ�޹�
	char szGameGoodsID[17]; //��Ϸ��ƷID
	char szLinkNo[33]; //����������
	char Reserved[10];				 //�ֶθ���ʱ��һ��Ҫע�������Ľṹ�峤�Ȼ���Ҫ����112�ֽ�
	int nActID;  //�id
} PAY_RESULTEX, * LPPAY_RESULTEX;