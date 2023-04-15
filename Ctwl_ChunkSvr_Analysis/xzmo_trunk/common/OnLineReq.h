#pragma once

// 消息号;
#define	GR_ON_LING_DATA				(GAME_REQ_INDIVIDUAL + 3300)    // 在线活动数据;
#define	GR_ON_LING_GET_REWARDS		(GAME_REQ_INDIVIDUAL + 3301)    // 获取在线奖励;
#define GR_ON_LINE_SOAP_REWARDS     (GAME_REQ_INDIVIDUAL + 3302)    // soap领取任务奖励;

enum ON_LINE_RESULT
{
	SUCCESS = 0,		//成功;
	FAIL_CONDITIONS,	//未满足条件;
	FAIL_LIMIT,			//已达上限;
	FAIL_TASK			//任务领取失败;
};

typedef struct _tagONLINE_CONDITION
{
	int	nUserID;                // 玩家ID;
	int nValue;                 // 条件更改值;
}ONLINE_CONDITION, *LPONLINE_CONDITION;