local FirstRechargeDef = 
{
    FIRST_RECHARGE_UNSTARTED   = 0,	-- 未开始
	FIRST_RECHARGE_STARTING    = 1,	-- 在进行中
	FIRST_RECHARGE_UNTAKE      = 2,	-- 已完成未领取
	FIRST_RECHARGE_TAKED       = 3,	-- 已完成已领取
    FIRST_RECHARGE_OUTDATE     = 4,	-- 已过期

    GR_FIRST_RECHARGE_GET_INFO    = 401901,
    GR_FIRST_RECHARGE_PAY_SUCCESS  = 401902,
    GR_FIRST_RECHARGE_TAKE_REWARD  = 401903,
    GR_BUY_FIRST_RECHARGE_SUCCESS = 401904,
    GR_CHALLENGE_BUTTON_CLICK_LOG = 401908,
    GR_LIMITTIME_SPECIAL_GET_INFO = 401909,

    FIRST_RECHARGE_APPTYPE_AN     = 1,
	FIRST_RECHARGE_APPTYPE_IOS    = 2,
	FIRST_RECHARGE_APPTYPE_SET    = 3,
    
	FirstRechargeInfoRet        = "FirstRechargeInfoRet",
    LimitTimeSpecialInfoRet     = "LimitTimeSpecialInfoRet"
}

return FirstRechargeDef