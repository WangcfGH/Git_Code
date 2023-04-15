local VivoPrivilegeStartUpDef = 
{
	GR_VIVO_PRIVILEGE_STARTUP_QUERY_CONFIG      = (400000 + 2701),                              --请求Vivo特权活动配置数据
    GR_VIVO_PRIVILEGE_STARTUP_QUERY_INFO        = (400000 + 2702),                              --请求Vivo特权活动领奖状态数据
    GR_VIVO_PRIVILEGE_STARTUP_TAKE_REWARD       = (400000 + 2703),                              --领取Vivo特权活动奖励

    VIVO_PRIVILEGE_STARTUP_QUERY_CONFIG_RSP     = 'VIVO_PRIVILEGE_STARTUP_QUERY_CONFIG_RSP',    --获取Vivo特权活动配置数据响应事件
    VIVO_PRIVILEGE_STARTUP_QUERY_STATE_RSP      = 'VIVO_PRIVILEGE_STARTUP_QUERY_INFO_RSP',      --获取Vivo特权活动领奖状态响应事件
    GR_VIVO_PRIVILEGE_STARTUP_TAKE_REWARD_RSP   = 'GR_VIVO_PRIVILEGE_STARTUP_TAKE_REWARD_RSP',  --领取Vivo特权活动奖励响应事件

    VIVO_PRIVILEGE_STARTUP_NOT_REWARD           = 0,                                            --Vivo特权活动奖励状态：未领取
    VIVO_PRIVILEGE_STARTUP_REWARDED             = 1,                                            --Vivo特权活动奖励状态：已领取
    
    REWARD_TYPE_SILVER                          = 1,                                            --奖励类型：银子
    REWARD_TYPE_EXCHANGE                        = 2,                                            --奖励类型：兑换券
    REWARD_TYPE_PROP                            = 3,                                            --奖励类型：道具
    
    REWARD_PROP_ID_EXPRESSION_ROSE              = 6,                                            --道具ID：表情玫瑰
    REWARD_PROP_ID_EXPRESSION_LIGHTNING         = 7,                                            --道具ID：表情闪电
    REWARD_PROP_ID_ONEBOUT_CARDMARKER           = 8,                                            --道具ID：单局记牌器
    REWARD_PROP_ID_TIMING_GAME_TICKET           = 17,                                            --道具ID：定时赛门票
}

return VivoPrivilegeStartUpDef