local ExchangeLotteryDef = 
{
	ExchangeLotteryInfoRet = "ExchangeLotteryInfoRet",
	ExchangeLotteryDrawRet = "ExchangeLotteryDrawRet",
	ExchangeLotterySynSeizeCount = "ExchangeLotterySynSeizeCount",
	ExchangeLotteryConfigChange = "ExchangeLotteryConfigChange",
	ExchangeLotteryUpdateRedDot = "ExchangeLotteryUpdateRedDot",
	ExchangeLotteryDrawFailed = "ExchangeLotteryDrawFailed",

	EXCHANGE_LOTTERY_SUCCESS = 0,
	EXCHANGE_LOTTERY_FAILED = 1,
	EXCHANGE_LOTTERY_CHANNEL_CLOSE = 2,
	EXCHANGE_LOTTERY_HAS_END = 3,
	EXCHANGE_LOTTERY_NOT_REACH_BOUT = 4,
	EXCHANGE_LOTTERY_REDIS_ERROR = 5,
	EXCHANGE_LOTTERY_NO_DRAWCOUNT = 6,
	EXCHANGE_LOTTERY_END = 7,
    
	GR_EXCHAGNE_LOTTERY_INFO_REQ = 410300,
	GR_EXCHAGNE_LOTTERY_INFO_RESP = 410301,
	GR_EXCHAGNE_LOTTERY_DRAW_REQ = 410302,
	GR_EXCHAGNE_LOTTERY_DRAW_RESP = 410303,
	GR_SYN_EXCHAGNE_LOTTERY_CONFIG = 410304,

	GR_EXPRESSION_LETTORY_GAME = 410211, --抽奖次数

	REWARD_TYPE_SILVER = 1,
	REWARD_TYPE_TICKET = 2,
	REWARD_TYPE_CARDMARKER_1D = 3,
	REWARD_TYPE_CARDMARKER_7D = 4,
	REWARD_TYPE_CARDMARKER_30D = 5,

	EXCHANGE_LOTTERY_ID = 102,

	TipContent = "购买互动表情：闪电，即可获赠抽奖机会，是否前往购买？",
	Broadcast = "<c=255>【惊喜夺宝】<>活动已经开启，快去<c=65535>【活动】<>界面参加吧！",
	TipQuickLotteryContent = "是否需要开启快速抽奖，一次性获取所有奖励？",
	TipQuickLottery100Content = "是否需要开启快速抽奖，一次性获取100次奖励？",
	TipNoRemindAgainContent = "不再提示",

	ErrorString1 = "奖励库存不足",
	ErrorString2 = "活动已结束",
	ErrorString3 = "还需要对局",
	ErrorString4 = "redis错误",
	ErrorString5 = "抽奖次数不够",
}

return ExchangeLotteryDef