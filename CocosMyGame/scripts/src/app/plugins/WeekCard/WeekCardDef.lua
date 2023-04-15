local WeekCardDef = 
{
	GR_WEEKCARD_REQ_STATUS = (400000 + 3701),
    GR_WEEKCARD_REQ_TAKE_DAILY = (400000 + 3702),
    GR_WEEKCARD_PAY_SUCCEED = (400000 + 3703),
    
    WEEK_CARD_APPTYPE_AN_TCY = 1,
	WEEK_CARD_APPTYPE_AN_SINGLE = 2,
	WEEK_CARD_APPTYPE_AN_SET = 3,
	WEEK_CARD_APPTYPE_IOS_TCY = 4,
    WEEK_CARD_APPTYPE_IOS_SINGLE = 5,

	ServiceClose = 'ServiceClose',          -- 服务端enbale为0,所有接口关闭
    ServiceOK = 'ServiceOK',      

	WEEK_CARD_STATUS_RSP = 'WEEK_CARD_STATUS_RSP',
	WEEK_CARD_UPDATE_REDDOT = 'WEEK_CARD_UPDATE_REDDOT',
	
	REWARD_CANNOT_GET = 0,
    REWARD_CAN_GET = 1,
	REWARD_ALREADY_GET = 2,
	
	TakeFail = 'TakeFail',       
    TaskNotComplete = 'TaskNotComplete',    
    TaskRewarded = 'TaskRewarded',    
    TakeSucceed = 'TakeSucceed',    
}

return WeekCardDef