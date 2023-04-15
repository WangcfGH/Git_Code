local NobilityPrivilegeDef = 
{
    NOBILITY_PRIVILEGE_UNLOCK      = -1,	-- 未解锁
	NOBILITY_PRIVILEGE_UNTAKE      = 0,	-- 可领取
    NOBILITY_PRIVILEGE_TAKED       = 1,	-- 已完成已领取
    
    --周、月礼包用新的状态
    NOBILITY_PRIVILEGE_UNLOCK_NEW      = 0,	-- 未解锁
	NOBILITY_PRIVILEGE_UNTAKE_NEW      = 1,	-- 可领取
	NOBILITY_PRIVILEGE_TAKED_NEW       = 2,	-- 已完成已领取

    GR_NOBILITY_PRIVILEGE_GET_INFO    = 402901,
    GR_NOBILITY_PRIVILEGE_PAY_SUCCESS  = 402902,
    GR_NOBILITY_PRIVILEGE_DAILYGIFTBAG_TAKE  = 402903,
    GR_NOBILITY_PRIVILEGE_UPGRADEGIFTBAG_TAKE = 402904,
    GR_NOBILITY_PRIVILEGE_USER_LOGIN          = 402905,
    GR_NOBILITY_PRIVILEGE_WEEKGIFTBAG_TAKE  = 402908,
    GR_NOBILITY_PRIVILEGE_MONTHGIFTBAG_TAKE  = 402909,
    GR_NOBILITY_PRIVILEGE_TAKE_ADDITIONGIFT  = 402910,

    NOBILITY_PRIVILEGE_APPTYPE_AN     = 1,
    NOBILITY_PRIVILEGE_APPTYPE_IOS    = 2,
    NOBILITY_PRIVILEGE_APPTYPE_SET    = 3,

    PRIVILEGE_REMOVE_ADVERT = 10,  --去除广告显示
	PRIVILEGE_RELIEFTIME_ADD = 11,  --增加低保次数
    PRIVILEGE_SHOP_GIVE = 12,      --商城购买加赠
    PRIVILEGE_LOTTERYTIME_ADD = 14, --转盘抽奖次数增加
	PRIVILEGE_AUTO_SUPPLY = 15,    --自动存取银
	PRIVILEGE_EXCHANGE_GIVE = 16,  --礼券中心兑换加赠
	PRIVILEGE_EXCHANGE_BROADCAST = 17,  --礼券中心兑换广播
    
    NobilityPrivilegeInfoRet        = "NobilityPrivilegeInfoRet",
}

return NobilityPrivilegeDef