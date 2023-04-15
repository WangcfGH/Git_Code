local RechargeActivityDef = 
{
    --充值有礼
    GR_RECHARGE_INFO_REQ                        = 410041, --获取充值有礼信息
    GR_RECHARGE_LOTTERY_REQ                     = 410042,
    GR_RECHARGE_INFO_RESP                       = 410043,
    GR_RECHARGE_LOTTERY_RESP                    = 410044,
    GR_RECHARGE_LOTTERY_FAILED                  = 410045,

    EVENT_RECHARGE_INFO_UPDATE = "EVENT_RECHARGE_INFO_UPDATE",
    EVENT_GET_LOTTERY_RESULT = "EVENT_GET_LOTTERY_RESULT",
    EVENT_GET_LOTTERY_FAILED = "EVENT_GET_LOTTERY_FAILED",

    RECHARGE_APPTYPE_AN_TCY        = 1,                                    --安卓平台包
	RECHARGE_APPTYPE_AN_SINGLE     = 2,                                    --安卓单包
	RECHARGE_APPTYPE_AN_SET        = 3,                                    --安卓合集包
	RECHARGE_APPTYPE_IOS_TCY       = 4,                                    --IOS平台包
    RECHARGE_APPTYPE_IOS_SINGLE    = 5,                                    --IOS单包

    TYPE_SILVER = 0,
    TYPE_TICKET = 1,       --礼券
    COLOR_PURPLE = 0,      --紫色
    COLOR_RED = 1,         --红色
}

return RechargeActivityDef