local LuckyPackDef = 
{
	GR_LUCKY_PACK_QUERY_CONFIG                  = (400000 + 2401),                      --请求幸运礼包配置数据
    GR_LUCKY_PACK_QUERY_STATE                   = (400000 + 2402),                      --请求幸运礼包购买状态数据
    GR_LUCKY_PACK_SAVE_LOTTERY_INFO             = (400000 + 2403),                      --同步幸运礼包抽取信息
    GR_LUCKY_PACK_AWARD                         = (400000 + 2404),                      --响应幸运礼包购买成功并发放奖励
    GR_LUCKY_PACK_QUERY_FL_INFO_AND_SL_STATE    = (400000 + 2405),                      --获取幸运礼包今日首次抽奖信息和今日特殊抽奖状态
    GR_LUCKY_PACK_QUERY_LB_STATE_AND_LB_INFO    = (400000 + 2406),                      --获取幸运礼包今日最后购买状态和今日最后购买信息

    LUCKYPACK_APPTYPE_AN_TCY        = 1,                                    --安卓平台包
	LUCKYPACK_APPTYPE_AN_SINGLE     = 2,                                    --安卓单包
	LUCKYPACK_APPTYPE_AN_SET        = 3,                                    --安卓合集包
	LUCKYPACK_APPTYPE_IOS_TCY       = 4,                                    --IOS平台包
    LUCKYPACK_APPTYPE_IOS_SINGLE    = 5,                                    --IOS单包

    LUCKY_PACK_ITEMS_TYPE_AND       = 1,                                    --安卓包抽奖项
    LUCKY_PACK_ITEMS_TYPE_IOS       = 2,                                    --IOS包抽奖项
    LUCKY_PACK_ITEMS_TYPE_HEJI      = 3,                                    --合集包抽奖项

    LUCKY_PACK_QUERY_CONFIG_RSP                 = 'LUCKY_PACK_QUERY_CONFIG_RSP',                --获取幸运礼包配置数据响应事件
    LUCKY_PACK_QUERY_STATE_RSP                  = 'LUCKY_PACK_QUERY_STATE_RSP',                 --获取幸运礼包购买状态响应事件
    LUCKY_PACK_SAVE_LOTTERY_INFO_RSP            = 'LUCKY_PACK_SAVE_LOTTERY_INFO_RSP',           --同步幸运礼包抽取信息响应事件
    LUCKY_PACK_AWARD_RSP                        = 'LUCKY_PACK_AWARD_RSP',                       --响应幸运礼包购买成功并发放奖励事件
    LUCKY_PACK_QUERY_FL_INFO_AND_SL_STATE_RSP   = 'LUCKY_PACK_QUERY_FL_INFO_AND_SL_STATE_RSP',  --响应幸运礼包今日首次抽奖信息和今日特殊抽奖状态
    LUCKY_PACK_QUERY_LB_STATE_AND_LB_INFO       = 'LUCKY_PACK_QUERY_LB_STATE_AND_LB_INFO',      --响应幸运礼包今日最后购买状态和今日最后购买信息

    LUCKY_PACK_STATUS_WAIT_LOTTERY  = 1,                                    --幸运礼包状态：待抽取
    LUCKY_PACK_STATUS_WAIT_BUY      = 2,                                    --幸运礼包状态：待购买
    LUCKY_PACK_STATUS_BUYYED        = 3,                                    --幸运礼包状态：已购买
    
    LUCKY_PACK_DIVICE_MAX_BUY_COUNT = 3,                                    --幸运礼包设备最大购买次数

    LUCKY_PACK_LOTTERY_MODE_COMMON          = 1,                            --幸运红包抽奖模式：普通
    LUCKY_PACK_LOTTERY_MODE_DISCOUNT_FIRST  = 2,                            --幸运红包抽奖模式：优惠于第一次抽取
    LUCKY_PACK_LOTTERY_MODE_PRICE_FIRST     = 3,                            --幸运红包抽奖模式：金额大于上次
}

return LuckyPackDef