local GratitudeRepayDef = 
{
    GR_GRATITUDE_REPAY_QUERY_CONFIG						= (400000 + 4401),                              	-- 查询感恩回馈活动配置
    GR_GRATITUDE_REPAY_QUERY_INFO						= (400000 + 4402),                              	-- 查询感恩回馈活动信息
    GR_GRATITUDE_REPAY_PAY_SUCCEED						= (400000 + 4403),                              	-- 感恩回馈活动抽取成功

    GRATITUDE_REPAY_QUERY_CONFIG_RSP 	                = 'GRATITUDE_REPAY_QUERY_CONFIG_RSP',	
	GRATITUDE_REPAY_QUERY_INFO_RSP 	                    = 'GRATITUDE_REPAY_QUERY_INFO_RSP',
	GRATITUDE_REPAY_PAY_SUCCEED 	                    = 'GRATITUDE_REPAY_PAY_SUCCEED',
    
    GRATITUDE_REPAY_APPTYPE_AN_TCY                   	= 1,                                     			--安卓平台包
	GRATITUDE_REPAY_APPTYPE_AN_SINGLE                	= 2,                                     			--安卓单包
	GRATITUDE_REPAY_APPTYPE_AN_SET                   	= 3,                                     			--安卓合集包
	GRATITUDE_REPAY_APPTYPE_IOS_TCY                  	= 4,                                     			--IOS平台包
    GRATITUDE_REPAY_APPTYPE_IOS_SINGLE               	= 5,                                     			--IOS单包

    LOTTERY_SUCCESS                    					= 1,                                             	--抽取成功
	LOTTERY_COUNT_NOT_ENGOUGH                    		= 2,                                             	--剩余次数不够
	LOTTERY_ITEM_INDEX_NOT_SAME                    		= 3,                                             	--购买项和选中项不同

    LOTTERY_GIVE_ITEM_COUNT                             = 6,                                                --感恩大回馈赠送项数量
}

return GratitudeRepayDef