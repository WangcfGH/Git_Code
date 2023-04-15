local LuckyCatDef = 
{
	TAB_DAILY_TASK											= 1,		-- 每日任务
	TAB_WELFARE_TASK										= 2,		-- 福利任务

    LUCKY_CAT_DAY        									= 1,		-- 每日任务
	LUCKY_CAT_WELFARE    									= 2,		-- 福利任务
	LUCKY_CAT_BOX        									= 3,		-- 宝箱任务
						
    TASKDATA_FLAG_DOING             						= 0, 		-- 任务正在进行中
    TASKDATA_FLAG_CANGET_REWARD     						= 1, 		-- 任务可领取
    TASKDATA_FLAG_FINISHED          						= 2, 		-- 任务已完成
	
	LUCKYCAT_STATUS_CLOSE									= 0,		-- 活动未开启
	LUCKYCAT_STATUS_TASK									= 1,		-- 活动任务阶段
	LUCKYCAT_STATUS_REWARD									= 2,		-- 活动瓜分阶段

	LUCKYCAT_REWARD_SILVER									= 1,		-- 银子
	LUCKYCAT_REWARD_EXCHANGE								= 2,		-- 礼券

    GR_LUCKY_CAT_GET_INFO      								= 402201,
    GR_LUCKY_CAT_CHANGE_DATA   								= 402202,
    GR_LUCKY_CAT_CHANGE_PARAM  								= 402203,
    GR_LUCKY_CAT_TASK_PRIZE    								= 402204,
    GR_LUCKY_CAT_UPGRADE       								= 402205,
    GR_LUCKY_CAT_TAKE_AWARD    								= 402206,

	LUCKYCAT_TASK_DAILY_HALL_LOGIN 							= 1,      	-- 1.登录游戏
	LUCKYCAT_TASK_DAILY_HALL_SHARE 							= 2,      	-- 2.分享游戏
	LUCKYCAT_TASK_DAILY_HALL_EXCHANGE_LOTTERY 				= 3,        -- 3.惊喜夺宝
	LUCKYCAT_TASK_DAILY_HALL_TAKE_GOLDSILVER_REWARD 		= 4,        -- 4.领取金银杯奖励
	LUCKYCAT_TASK_DAILY_GAME_USE_EXPRESSION 				= 5,        -- 5.使用互动表情
	LUCKYCAT_TASK_DAILY_GAME_ROOM_CLASSIC 					= 6,        -- 6.经典场对局
	LUCKYCAT_TASK_DAILY_GAME_ROOM_NOWASH 					= 7,		-- 7.不洗牌场对局
	LUCKYCAT_TASK_DAILY_GAME_PLAY_TONGHUASHUN 				= 8,        -- 8.打出同花顺
	LUCKYCAT_TASK_DAILY_GAME_PLAY_FIRST 					= 9,        -- 9.头游
	LUCKYCAT_TASK_DAILY_HALL_RECHARGE 						= 10,       -- 10.充值
	LUCKYCAT_TASK_DAILY_GAME_ROOM_CLASSIC_MASTER 			= 11,       -- 11.经典大师房对局
	LUCKYCAT_TASK_DAILY_GAME_ROOM_NOWASH_MASTER 			= 12,       -- 12.不洗牌大师房对局

	LUCKYCAT_TASK_WELFARE_HALL_REALNAME 					= 101,      -- 101.实名认证
	LUCKYCAT_TASK_WELFARE_GAME_WIN_TOTAL 					= 102,      -- 102.对局累计获胜
	LUCKYCAT_TASK_WELFARE_HALL_RECHARGE_TOTAL 				= 103,      -- 103.累计充值

	LUCKYCAT_TASK_BOX_DAILY_TASK_FINISH 					= 201,      -- 201.每日任务完成
    
	LUCKYCATINFORET        									= "LUCKYCATINFORET",
	LUCKYCATAWARDGET        								= "LUCKYCATAWARDGET",
}

return LuckyCatDef