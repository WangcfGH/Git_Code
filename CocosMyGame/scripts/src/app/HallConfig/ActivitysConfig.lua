local config={
    ReliefActId=179,
    MemberReliefActId=303,
    NobilityPrivilegeReliefActId=1759,
    VideoAdReliefActId=2045,
    NoSafeboxReliefActId=2043,
    NPNoSafeboxReliefActId=2044,
    BuyReliefId=1791,
    BuyReliefIdIOS=2046,
    BuyReliefIdHeji=1790,
	CheckinActId=180,
    MemberCheckActId=304,
	RechargeId=181,
    LimitTimeGiftId=1059,
    RechargeId_HJ=1201,
    LimitTimeGiftId_HJ=1202,
    ExchangeGUID        = "",   --兑换
    DailyShareActId     = 0,
    NovicePacksActId    = 0,
    InviteGiftActId     = 0,
    NewActivity          = 137,        --新版活动签到
}

if BusinessUtils:getInstance():isGameDebugMode() then
    config.ReliefActId=333
    config.MemberReliefActId=589
    config.NobilityPrivilegeReliefActId=2711
    config.VideoAdReliefActId=2767
    config.NoSafeboxReliefActId=2764
    config.NPNoSafeboxReliefActId=2765
    config.BuyReliefId=2742
    config.BuyReliefIdIOS=2771
    config.BuyReliefIdHeji=2741
	config.CheckinActId=429
    config.MemberCheckActId=588
	config.RechargeId=1123
    config.LimitTimeGiftId=1881
    config.RechargeId_HJ=2050
    config.LimitTimeGiftId_HJ=2049
    config.ExchangeGUID = ""
    config.DailyShareActId  = 0
    config.NovicePacksActId = 0
    config.InviteGiftActId  = 0
    config.NewActivity = 68
end

return config
