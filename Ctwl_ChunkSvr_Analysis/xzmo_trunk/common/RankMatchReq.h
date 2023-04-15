#pragma once

// ��Ϣ��;
#define	GR_RANK_MATCH_CHANGE_DATA 			(GAME_REQ_INDIVIDUAL + 2800) 	// �ı���������;
#define	GR_RANK_MATCH_GET_DATA_SHOW			(GAME_REQ_INDIVIDUAL + 2801)	// ��ȡ������ʾ;
#define	GR_RANK_MATCH_UPLOAD_NAME			(GAME_REQ_INDIVIDUAL + 2802)	// �ϴ�����;
#define	GR_RANK_MATCH_REWARD_CONFIG			(GAME_REQ_INDIVIDUAL + 2803)	// ��������;
#define	GR_RANK_MATCH_REWARD_MAIL			(GAME_REQ_INDIVIDUAL + 2804)	// �ʼ�����;

#ifndef MAX_YQW_PORTRAIT_LEN
#define MAX_YQW_PORTRAIT_LEN 260
#endif

#define MAX_YQW_NICKNAME_LEN				128  //΢���ǳ���128�ֽڣ���ͨ�ǳ���32���ó���;

typedef struct _tagUpdateMatchData
{
    int     nUserID;
	TCHAR   szUserName[MAX_YQW_NICKNAME_LEN];
	TCHAR   szPortrait[MAX_YQW_PORTRAIT_LEN];
	BOOL	needUpdateName;  //�Ƿ�ʵʱ�������֣�Ĭ��һ���������ʵʱ���£�;
	int		nMatchValue;
}UPDATE_MATCH_DATA, *LPUPDATE_MATCH_DATA;

typedef struct _tagRankMatchListDataReq
{
    int     nUserID;
	int		nSeason;	//0Ϊ��������1Ϊ�ϸ�����;
}RankMatchListDataReq, *LPRankMatchListDataReq;

typedef struct _tagRankMatchListDataRsp
{
	int		nSelfRank;
	int		nSelfScore;
	int		nRankNum;	//��������  ���Ϊini����;
	BOOL	bOpenMatch;	//�Ƿ��п������ϸ���������Ҳ�ø��ֶΣ�;
	int		nSeason;	//0Ϊ��������1Ϊ�ϸ�����;
	int		nSeasonDate;	//��������ʱ��2017072406�ĸ�ʽ;
}RankMatchListDataRsp, *LPRankMatchListDataRsp;

typedef struct _tagRankMatchUserInfo
{
	int		nUserID;
	TCHAR   szUserName[MAX_YQW_NICKNAME_LEN];
	TCHAR   szPortrait[MAX_YQW_PORTRAIT_LEN];       // ͷ��URL  //Ԥ���½ṹ;
	int		nUserScore;
}RankMatchUserInfo, *LPRankMatchUserInfo;