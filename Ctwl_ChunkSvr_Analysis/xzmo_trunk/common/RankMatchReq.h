#pragma once

// 消息号;
#define	GR_RANK_MATCH_CHANGE_DATA 			(GAME_REQ_INDIVIDUAL + 2800) 	// 改变排行数据;
#define	GR_RANK_MATCH_GET_DATA_SHOW			(GAME_REQ_INDIVIDUAL + 2801)	// 获取排行显示;
#define	GR_RANK_MATCH_UPLOAD_NAME			(GAME_REQ_INDIVIDUAL + 2802)	// 上传名字;
#define	GR_RANK_MATCH_REWARD_CONFIG			(GAME_REQ_INDIVIDUAL + 2803)	// 奖励配置;
#define	GR_RANK_MATCH_REWARD_MAIL			(GAME_REQ_INDIVIDUAL + 2804)	// 邮件奖励;

#ifndef MAX_YQW_PORTRAIT_LEN
#define MAX_YQW_PORTRAIT_LEN 260
#endif

#define MAX_YQW_NICKNAME_LEN				128  //微信昵称是128字节，普通昵称是32，用长的;

typedef struct _tagUpdateMatchData
{
    int     nUserID;
	TCHAR   szUserName[MAX_YQW_NICKNAME_LEN];
	TCHAR   szPortrait[MAX_YQW_PORTRAIT_LEN];
	BOOL	needUpdateName;  //是否实时更新名字（默认一起玩的名字实时更新）;
	int		nMatchValue;
}UPDATE_MATCH_DATA, *LPUPDATE_MATCH_DATA;

typedef struct _tagRankMatchListDataReq
{
    int     nUserID;
	int		nSeason;	//0为本赛季，1为上个赛季;
}RankMatchListDataReq, *LPRankMatchListDataReq;

typedef struct _tagRankMatchListDataRsp
{
	int		nSelfRank;
	int		nSelfScore;
	int		nRankNum;	//总排行数  最大为ini配置;
	BOOL	bOpenMatch;	//是否有开启（上个赛季有无也用该字段）;
	int		nSeason;	//0为本赛季，1为上个赛季;
	int		nSeasonDate;	//赛季结束时间2017072406的格式;
}RankMatchListDataRsp, *LPRankMatchListDataRsp;

typedef struct _tagRankMatchUserInfo
{
	int		nUserID;
	TCHAR   szUserName[MAX_YQW_NICKNAME_LEN];
	TCHAR   szPortrait[MAX_YQW_PORTRAIT_LEN];       // 头像URL  //预留下结构;
	int		nUserScore;
}RankMatchUserInfo, *LPRankMatchUserInfo;