local PhoneFeeGiftDef = 
{
    GR_PHONE_FEE_GIFT_REQ				=		410316,    --查询话费礼信息 (使用新的协议号2021.3.26)
    GR_PHONE_FEE_GIFT_RSP				=		410311, -- 回包
    GR_PHONE_FEE_GIFT_ADD_BOUT			=		410312, -- 结算对局增加请求
    GR_PHONE_FEE_GIFT_REWARD		    =		410317, -- 领奖请求 (使用新的协议号2021.3.26)
    GR_PHONE_FEE_GIFT_REWARD_RESP	     =		410314, -- 领奖请求回报


    ID_IN_ACTIVITY_CENTER               = 101,
    MSG_PHONE_FEE_GIFT_UPDATE       = "PhoneFeeGiftUpdate", -- 通知刷新界面
    MSG_PHONE_FEE_GIFT_REWARD_GETED = "PhoneFeeGiftRewardGeted",
    MSG_PHONE_FEE_GIFT_REWARD_FAILED = "PhoneFeeGiftRewardFailed",
    MSG_PHONE_FEE_GIFT_ADD_BOUT    = "PhoneFeeGiftAddBout",
    MSG_PHONE_FEE_GIFT_CLOCK_ZERO = "PhoneFeeGiftClockZero",
    MSG_PHONE_FEE_GIFT_NEW_DAY = "PhoneFeeGiftNewDay",
    PHONE_FEE_GIFT_UPDATE_REDDOT = "PhoneFeeGiftUpdateRedDot",

    STATUS_NOMAL = 0,
	STATUS_DEVICELIMIT = 1,			-- 超出设备限制
	STATUS_REWARD_EXCEED=2,			-- 过期
	STATUS_ALEADY_REWARD=3,			-- 重复领取
	STATUS_REWARD_SOAP_FAILED=4,		-- soap调用失败
	STATUS_ERROR = 5,					-- 非法

}

return PhoneFeeGiftDef