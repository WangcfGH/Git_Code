
local additionConfigCtrl = import('src.app.GameHall.config.AdditionConfigCtrl')

local function isXXXSupported(...)
    local support = additionConfigCtrl:getInstance():isFunctionSupported(...)
    return support
end

local function getXXXValue(...)
    return additionConfigCtrl:getInstance():getConfigKey(...)
end

local function getFunctionKeys()
    return additionConfigCtrl:getInstance():getFunctionKeys()
end

local function getConfigKey(...)
    return additionConfigCtrl:getInstance():getConfigKey(...)
end

function cc.exports.getCopyRightConfig()
    return getConfigKey(getFunctionKeys().KEY_COPYRIGHT)
end

function cc.exports.getHealthTipConfig()
    return getConfigKey(getFunctionKeys().KEY_HEALTHDESCRIPTION)
end

function cc.exports.isDepositSupported()
    return isXXXSupported(getFunctionKeys().KEY_DEPOSIT)
end

function cc.exports.isScoreSupported()
    return isXXXSupported(getFunctionKeys().KEY_SCORE)
end

function cc.exports.isReliefSupported()
    return isXXXSupported(getFunctionKeys().KEY_RELIEF)
end

function cc.exports.getReliefShopItemIDValue()
    return getXXXValue(getFunctionKeys().KEY_RELIEF, getFunctionKeys().KEY_RELIEFSHOPITEMID)
end

function cc.exports.getReliefLargePriceValue()
    return getXXXValue(getFunctionKeys().KEY_RELIEF, getFunctionKeys().KEY_RELIEFLARGEPRICE)
end

function cc.exports.getReliefSmallPriceValue()
    return getXXXValue(getFunctionKeys().KEY_RELIEF, getFunctionKeys().KEY_RELIEFSMALLPRICE)
end

function cc.exports.getReliefLargeExtraValue()
    return getXXXValue(getFunctionKeys().KEY_RELIEF, getFunctionKeys().KEY_RELIEFLARGE)
end

function cc.exports.getReliefSmallExtraValue()
    return getXXXValue(getFunctionKeys().KEY_RELIEF, getFunctionKeys().KEY_RELIEFSMALL)
end

function cc.exports.getReliefSmallHeJiExtraValue()
    return getXXXValue(getFunctionKeys().KEY_RELIEF, getFunctionKeys().KEY_RELIEFSMALLHEJI)
end

function cc.exports.getReliefSilverValue()
    return getXXXValue(getFunctionKeys().KEY_RELIEF, getFunctionKeys().KEY_RELIEFSLIVER)
end

function cc.exports.isCheckinSupported()
    return isXXXSupported(getFunctionKeys().KEY_CHECKIN)
end

function cc.exports.isShareSupported()
    return isXXXSupported(getFunctionKeys().KEY_SHARE)
end

--兑换码
function cc.exports.isGiftExchangeSupported()
    return isXXXSupported(getFunctionKeys().KEY_GIFT_EXCHANGE)
end

function cc.exports.isActivitiesSupported()
    return isXXXSupported(getFunctionKeys().KEY_ACTIVITIES) and
    (cc.exports.isReliefSupported() or cc.exports.isCheckinSupported() or cc.exports.isShareSupported())
end

function cc.exports.isExitGameSupported()
    return isXXXSupported(getFunctionKeys().KEY_EXITGAME)
end

function cc.exports.isFirstRechargeSupported()
    return isXXXSupported(getFunctionKeys().KEY_FIRSTRECHARGE) and isShopSupported()
end

function cc.exports.isLimitTimeSpecialSupported()
    return isXXXSupported(getFunctionKeys().KEY_LIMITTIMESPECIAL) and isShopSupported()
end

function cc.exports.isQuickPaySupported()
    return isShopSupported()
end

function cc.exports.isShopSupported()
    return isXXXSupported(getFunctionKeys().KEY_SHOP)
end

function cc.exports.isExchangeSupported()
    return isXXXSupported(getFunctionKeys().KEY_EXCHANGE)
end

function cc.exports.isExchangeRealItemSupported()
    return isXXXSupported(getFunctionKeys().KEY_EXCHANGE, getFunctionKeys().KEY_EXCHANGE_REALITEM)
end

function cc.exports.isExchangePhoneFeeSupported()
    return isXXXSupported(getFunctionKeys().KEY_EXCHANGE, getFunctionKeys().KEY_EXCHANGE_PHONEFEE)
end

function cc.exports.isTongBaoSupported()
    return isXXXSupported(getFunctionKeys().KEY_TONGBAO)
end

function cc.exports.isSafeBoxSupported()
    if not isDepositSupported() or not isXXXSupported(getFunctionKeys().KEY_SAFEBOX) then
        return false
    end

    local SafeboxModel = import('src.app.plugins.safebox.SafeboxModel'):getInstance()
    return SafeboxModel:isSafeboxSupported()
end

function cc.exports.isBackBoxSupported()
    return isDepositSupported() and isXXXSupported(getFunctionKeys().KEY_BACKBOX)
end

function cc.exports.isVIPSupported()
    return isXXXSupported(getFunctionKeys().KEY_VIP)
end

function cc.exports.isShoptipSupported()
    return isXXXSupported(getFunctionKeys().KEY_SHOPTIP)
end

function cc.exports.isBindphoneSupported()
    return isXXXSupported(getFunctionKeys().KEY_BINDPHONE)
end

function cc.exports.isModifyphoneSupported()
    return isXXXSupported(getFunctionKeys().KEY_BINDPHONE, getFunctionKeys().KEY_MODIFYPHONE)
end

function cc.exports.isModifyNameSupported()
    return isXXXSupported(getFunctionKeys().KEY_MODIFYNAME)
end

function cc.exports.isModifyNickNameSupported()
    return isXXXSupported(getFunctionKeys().KEY_MODIFYNICKNAME)
end

function cc.exports.isModifySexSupported()
    return isXXXSupported(getFunctionKeys().KEY_MODIFYSEX)
end

function cc.exports.isModifyPasswordSupported()
    return isXXXSupported(getFunctionKeys().KEY_MODIFYPASSWORD)
end

function cc.exports.isSocialSupported()
    return isXXXSupported(getFunctionKeys().KEY_ISSOCIAL)
end

function cc.exports.isSDKBallSupported()
    return isXXXSupported(getFunctionKeys().KEY_ISSOCIAL, getFunctionKeys().KEY_SDKBALL)
end

function cc.exports.isFriendSupported()
    if cc.exports.isIosALONE() == true then
        return false
    end
    return isXXXSupported(getFunctionKeys().KEY_ISSOCIAL, getFunctionKeys().KEY_FRIEND)
end

function cc.exports.isShowLoginWindowWhenFailedSupported()
    return isXXXSupported(getFunctionKeys().KEY_SHOWLOGINWINDOWWHENFAILED)
end

function cc.exports.isMoreGameSupported()
    return isXXXSupported(getFunctionKeys().KEY_MOREGAME)
end

function cc.exports.isRealNameSupported()
    return isXXXSupported(getFunctionKeys().KEY_REALNAME)
end

function cc.exports.isAntiAddictionSupported()
    return isXXXSupported(getFunctionKeys().KEY_ANTIADDICTION)
end

function cc.exports.isSwitchAccountSupported()
    return isXXXSupported(getFunctionKeys().KEY_SWITCHACCOUNT)
end

function cc.exports.isQQShowSupported()
    return isXXXSupported(getFunctionKeys().KEY_QQSHOW)
end

function cc.exports.isUploadHeadIconSupported()
    return isXXXSupported(getFunctionKeys().KEY_UPLOADHEADICON)
end

function cc.exports.isLoginLotterySupported()
    return isXXXSupported(getFunctionKeys().KEY_LOGIN_LOTTERY)
end

function cc.exports.isRollItemSupported()
    return isXXXSupported(getFunctionKeys().KEY_ROLLITEM)
end
function cc.exports.isRankingSupported()
    return isXXXSupported(getFunctionKeys().KEY_RANKING)
end

function cc.exports.isTaskSupported()
    return isXXXSupported(getFunctionKeys().KEY_TASK)
end

function cc.exports.isUserItemsSupported()
    return isXXXSupported(getFunctionKeys().KEY_USERITEMS)
end

function cc.exports.isRoomCardSupported()
    return isXXXSupported(getFunctionKeys().KEY_ROOMCARD)
end

function cc.exports.isShareLinkSupported()
    return isXXXSupported(getFunctionKeys().KEY_ROOMCARD, getFunctionKeys().KEY_ROOMCARD_SHARELINK)
end

function cc.exports.isRoomCardChargeSupported()
    return isXXXSupported(getFunctionKeys().KEY_ROOMCARD, getFunctionKeys().KEY_ROOMCARD_CHARGE)
end

function cc.exports.isNovoiceGuideSupported()
    return isXXXSupported(getFunctionKeys().KEY_NOVOICEGUIDE)
end

function cc.exports.isSocialRoomSupported()
    return isXXXSupported(getFunctionKeys().KEY_ISSOCIAL, getFunctionKeys().KEY_SOCIALROOM)
end

function cc.exports.getQQNumber()
    return getXXXValue(getFunctionKeys().KEY_QQSHOW, getFunctionKeys().KEY_QQSTRING)
end

function cc.exports.isWechatFirstSupported()
    return isXXXSupported(getFunctionKeys().KEY_ROOMCARD, getFunctionKeys().KEY_WECHATFIRST)
end

function cc.exports.getShareForGiftType()
    return getXXXValue(getFunctionKeys().KEY_SHARE, getFunctionKeys().KEY_SHARE_FOR_GIFT)
end

function cc.exports.isLogNetStatusSupported()
    return isXXXSupported(getFunctionKeys().KEY_LOGNETSTATUS)
end

function cc.exports.isLogUserStackSupported()
    return isXXXSupported(getFunctionKeys().KEY_GAMELOGUSERSTACk)
end

function cc.exports.isRankMatchSupported()
    return isXXXSupported(getFunctionKeys().KEY_RANKMATCH)
end

function cc.exports.isRoomCardCouponSupported()
    return isXXXSupported(getFunctionKeys().KEY_ROOMCARD, getFunctionKeys().KEY_COUPON)
end

function cc.exports.isAASupported()
    return isXXXSupported(getFunctionKeys().KEY_ROOMCARD, getFunctionKeys().KEY_PAYFORAA)
end

function cc.exports.isBigWinSupported()
    return isXXXSupported(getFunctionKeys().KEY_ROOMCARD, getFunctionKeys().KEY_PAYFORBIGWIN)
end

function cc.exports.isIOSLogSDKSupported()
    return isXXXSupported(getFunctionKeys().KEY_IOSLOGSDK)
end

function cc.exports.getWechatCSName()
    return getXXXValue(getFunctionKeys().KEY_ROOMCARD, getFunctionKeys().KEY_ROOMCARD_CHARGE, getFunctionKeys().KEY_ROOMCARD_CHARGENAME)
end

function cc.exports.isXXYChargeSupported()
    return isXXXSupported(getFunctionKeys().KEY_ROOMCARD, getFunctionKeys().KEY_XXY_CHARGE)
end

function cc.exports.isXXYBindCodeSupported()
    return isXXXSupported(getFunctionKeys().KEY_ROOMCARD, getFunctionKeys().KEY_XXY_CHARGE, getFunctionKeys().KEY_XXY_BINDCODE)
end

function cc.exports.getXXYBindCodeDomain(isGameDebugMode)
    if isGameDebugMode then
        return getXXXValue(getFunctionKeys().KEY_ROOMCARD, getFunctionKeys().KEY_XXY_CHARGE, getFunctionKeys().KEY_XXY_BINDCODE, getFunctionKeys().KEY_XXY_DOMAINDEBUG)
    else
        return getXXXValue(getFunctionKeys().KEY_ROOMCARD, getFunctionKeys().KEY_XXY_CHARGE, getFunctionKeys().KEY_XXY_BINDCODE, getFunctionKeys().KEY_XXY_DOMAINRELEASE)
    end
end

function cc.exports.getXXYChargeDomain(isGameDebugMode)
    if isGameDebugMode then
        return getXXXValue(getFunctionKeys().KEY_ROOMCARD, getFunctionKeys().KEY_XXY_CHARGE, getFunctionKeys().KEY_XXY_DOMAINDEBUG)
    else
        return getXXXValue(getFunctionKeys().KEY_ROOMCARD, getFunctionKeys().KEY_XXY_CHARGE, getFunctionKeys().KEY_XXY_DOMAINRELEASE)
    end
end

function cc.exports.isAutoUpdateDBGLogSupported()
    return isXXXSupported(getFunctionKeys().KEY_AUTO_UPDATE_DBG_LOG)
end

function cc.exports.getGameReconnectCountDBGLog()
    return getXXXValue(getFunctionKeys().KEY_AUTO_UPDATE_DBG_LOG, getFunctionKeys().KEY_GAME_RECONNECT_COUNT_DBG_LOG)
end

function cc.exports.getHallReconnectTimeDBGLog()
    return getXXXValue(getFunctionKeys().KEY_AUTO_UPDATE_DBG_LOG, getFunctionKeys().KEY_HALL_RECONNECT_TIME_DBG_LOG)
end

function cc.exports.isInviteGiftSupported()
    return isXXXSupported(getFunctionKeys().KEY_INVITE_GIFT) and plugin.AgentManager:getInstance():getUserPlugin().getThirdUserAccount
end

function cc.exports.isGoodFriendGiftInviteGiftSupported()
    return isXXXSupported(getFunctionKeys().KEY_GOOD_FRIEND_GIFT_INVITE_GIFT)
end

function cc.exports.is3DMJSupportd()
    return isXXXSupported(getFunctionKeys().KEY_SETTING_3DMJ)
end

function cc.exports.isHeaderImgLogSupported()
    return isXXXSupported(getFunctionKeys().KEY_HEADERIMGLOG)
end


function cc.exports.isConsultAdjustChairsSupported()
    return isXXXSupported(getFunctionKeys().KEY_CONSULT_ADJUST_CHAIRS)
end

function cc.exports.isClubSupported()
    return isXXXSupported(getFunctionKeys().KEY_ROOMCARD, getFunctionKeys().KEY_CLUB)
end

function cc.exports.isSwitch2DGameDialogSupported()
    return isXXXSupported(getFunctionKeys().KEY_SWITCH_2DGAME_DIALOG)
end

function cc.exports.isGoodLuckPropSupported()
    return isXXXSupported(getFunctionKeys().KEY_GOOD_LUCK_PROP)
end

function cc.exports.isGoodLuckFreeShowGuideSupported()
    return isXXXSupported(getFunctionKeys().KEY_GOOD_LUCK_PROP, getFunctionKeys().KEY_GOOD_LUCK_FREE_SHOW_GUIDE)
end

function cc.exports.isAccountSafeSupported()
    return isXXXSupported(getFunctionKeys().KEY_ACCOUNT_SAFE)
end

function cc.exports.isNewActivitySupported()
    return isXXXSupported(getFunctionKeys().KEY_NEWACTIVITY)
end

function cc.exports.isRoomCardDonateSupported()
    return isXXXSupported(getFunctionKeys().KEY_ROOMCARD, getFunctionKeys().KEY_ROOMCARD_DONATE)
end

function cc.exports.getRuleChooseTabsSupport()
    return isXXXSupported(getFunctionKeys().KEY_RULE_TABS) and getXXXValue(getFunctionKeys().KEY_RULE_TABS, getFunctionKeys().KEY_SUPPORT_TABS)
end

function cc.exports.isDWCSupported()
    return isXXXSupported(getFunctionKeys().KEY_DWC)
end

function cc.exports.isFuseModel()            
    return isXXXSupported(getFunctionKeys().KEY_FUSEMODEL)
end

function cc.exports.getFuseModelPanelSetting()      
    return isXXXSupported(getFunctionKeys().KEY_FUSEMODEL) and getXXXValue(getFunctionKeys().KEY_FUSEMODEL, getFunctionKeys().KEY_PANELSET)
end

function cc.exports.isFuseMoreGameSupported()            
    return isXXXSupported(getFunctionKeys().KEY_MOREGAMECONFIG)
end

-- function cc.exports.getMoreGameSetting()      
--     return isXXXSupported(getFunctionKeys().KEY_MOREGAMECONFIG) and getXXXValue(getFunctionKeys().KEY_MOREGAMECONFIG, getFunctionKeys().KEY_MOREGAMESET)
-- end

function cc.exports.isNovicePacksSupported()
    return isXXXSupported(getFunctionKeys().KEY_NOVICE_PACKS)
end

--自定义功能
function cc.exports.isLimitTimeGiftSupported()
    return isXXXSupported(getFunctionKeys().KEY_LIMITTIMEGIFT)
end

function cc.exports.isActivityCenterSupported()
    return isXXXSupported(getFunctionKeys().KEY_ACTIVITYCENTER)
end

function cc.exports.isMonthCardSupported()
    return isXXXSupported(getFunctionKeys().KEY_MONTHCARD)
end

function cc.exports.isWeekCardSupported()
    return isXXXSupported(getFunctionKeys().KEY_WEEKCARD)
end

function cc.exports.getWeekCardBout()
    return getXXXValue(getFunctionKeys().KEY_WEEKCARD, getFunctionKeys().KEY_BOUTLIMIT)
end

function cc.exports.isWeekMonthSuperCardSupported()
    return isXXXSupported(getFunctionKeys().KEY_WEEKMONTHSUPERCARD)
end

function cc.exports.isNewPlayerGiftSupported()
    return isXXXSupported(getFunctionKeys().KEY_NEWPLAYERGIFT)
end

function cc.exports.isTopRankSupported()
    return isXXXSupported(getFunctionKeys().KEY_TOPRANK)
end

function cc.exports.isRechargeActivitySupported()
    return isXXXSupported(getFunctionKeys().KEY_RECHARGEACTIVITY)
end

function cc.exports.isPPLSupported()
    return isXXXSupported(getFunctionKeys().KEY_PPL)
end

function cc.exports.getPPLDepositLimit()
    return getXXXValue(getFunctionKeys().KEY_PPL, getFunctionKeys().KEY_PPL_DEPOSITLIMIT)
end

function cc.exports.isGoldEggSupported()
    return isXXXSupported(getFunctionKeys().KEY_GOLDEGG)
end

function cc.exports.isGoldSilverSupported()
    return isXXXSupported(getFunctionKeys().KEY_GOLDSILVER)
end

function cc.exports.isGoldSilverCopySupported()
    return isXXXSupported(getFunctionKeys().KEY_GOLDSILVER_COPY)
end

function cc.exports.isOutlayGameSupported(isPrintLog)
    local isSupport = isXXXSupported(getFunctionKeys().KEY_OUTLAYGAME)
    if isSupport == false then
        if isPrintLog == true then
            print("isSupport by additionconfig false")
        end
        return false
    end

    if my.isEngineSupportVersion("v1.4.20171019") == false then
        if isPrintLog == true then
            print("isEngineSupportVersion v1.4.20171019 false")
        end
        return false
    end
    if my.isShowOutlayGameForTcyApp(true) == false then
        if isPrintLog == true then
            print("isShowOutlayGameForTcyApp false")
        end
        return false
    end

    --局数限制
    local openLimit = cc.exports.getOutlayGameBoutLimit() or 50
    local UserModel = mymodel('UserModel'):getInstance()
    if UserModel.nBout and UserModel.nBout >= openLimit then
        return true
    end

    if isPrintLog == true then
        print("boutLimit false, curBout "..tostring(UserModel.nBout))
    end
    return false
end

function cc.exports.getOutlayGameBoutLimit()
    return getXXXValue(getFunctionKeys().KEY_OUTLAYGAME, getFunctionKeys().KEY_BOUTLIMIT)
end

function cc.exports.isLegendComeSupported()
    if cc.exports.isOutlayGameSupported() == false then
        return false
    end

    return isXXXSupported(getFunctionKeys().KEY_LEGENDCOME)
end

function cc.exports.isCustomerServiceSupported()
    return isXXXSupported(getFunctionKeys().KEY_CUSTOMERSERVICE)
end

function cc.exports.isWinningStreakSupported()
    return isXXXSupported(getFunctionKeys().KEY_WINNINGSTREAK)
end

function cc.exports.getWinningStreakNeedBout()
    return getXXXValue(getFunctionKeys().KEY_WINNINGSTREAK, getFunctionKeys().KEY_WINNINGSTREAK_NEED_BOUT)
end

function cc.exports.getDWCDepositLimit()
    return getXXXValue(getFunctionKeys().KEY_DWC, getFunctionKeys().KEY_DEPOSITLIMIT)
end

function cc.exports.isExchangeTelephoneLabelSupported()
    return isXXXSupported(getFunctionKeys().KEY_TELEPHONELABEL)
end

function cc.exports.getExchangeNumValue()
    return getXXXValue(getFunctionKeys().KEY_TELEPHONELABEL, getFunctionKeys().KEY_EXCHANGE_NUM)
end

function cc.exports.isRedPacket100Supported()
    return isXXXSupported(getFunctionKeys().KEY_REDPACKET100)
end

function cc.exports.getGoldSilverTipLevelValue()
    return getXXXValue(getFunctionKeys().KEY_GOLDSILVER, getFunctionKeys().KEY_GOLDSILVER_TIPLEVEL) or 10
end

function cc.exports.getGoldSilverTipDayValue()
    return getXXXValue(getFunctionKeys().KEY_GOLDSILVER, getFunctionKeys().KEY_GOLDSILVER_TIPDAY) or 3
end

function cc.exports.getGoldSilverTipLevelCopyValue()
    return getXXXValue(getFunctionKeys().KEY_GOLDSILVER_COPY, getFunctionKeys().KEY_GOLDSILVER_TIPLEVEL_COPY) or 10
end

function cc.exports.getGoldSilverTipDayCopyValue()
    return getXXXValue(getFunctionKeys().KEY_GOLDSILVER_COPY, getFunctionKeys().KEY_GOLDSILVER_TIPDAY_COPY) or 3
end

function cc.exports.getGoldSilverCopyStartDate()
    return getXXXValue(getFunctionKeys().KEY_GOLDSILVER_COPY, getFunctionKeys().KEY_GOLDSILVERCOPY_START_DATE)
end

function cc.exports.getGoldSilverCopyEndDate()
    return getXXXValue(getFunctionKeys().KEY_GOLDSILVER_COPY, getFunctionKeys().KEY_GOLDSILVERCOPY_END_DATE)
end

function cc.exports.isNobilityPrivilegeSupported()
    return isXXXSupported(getFunctionKeys().KEY_NOBILITYPRIVILEGE)
end

function cc.exports.isNobilityPrivilegeGiftSupported()
    return isXXXSupported(getFunctionKeys().KEY_NOBILITYPRIVILEGEGIFT)
end

function cc.exports.isLuckyCatSupported()
    return isXXXSupported(getFunctionKeys().KEY_LUCKYCAT)
end

function cc.exports.isAdverSupported()
    return isXXXSupported(getFunctionKeys().KEY_ADVER)
end

function cc.exports.getAdverRoomValue()
    return getXXXValue(getFunctionKeys().KEY_ADVER, getFunctionKeys().KEY_ADVERROOM)
end

function cc.exports.getAdverBoutValue()
    return getXXXValue(getFunctionKeys().KEY_ADVER, getFunctionKeys().KEY_ADVERBOUT)
end

function cc.exports.getAdverInterScene()
    return getXXXValue(getFunctionKeys().KEY_ADVER, getFunctionKeys().KEY_ADVERINTERSCENE)
end

function cc.exports.getAdverInterLimit()
    return getXXXValue(getFunctionKeys().KEY_ADVER, getFunctionKeys().KEY_ADVERINTERLIMIT)
end

function cc.exports.getAdverInterPro()
    return getXXXValue(getFunctionKeys().KEY_ADVER, getFunctionKeys().KEY_ADVERINTERPRO)
end

function cc.exports.getAdverInterBout()
    return getXXXValue(getFunctionKeys().KEY_ADVER, getFunctionKeys().KEY_ADVERINTERBOUT)
end

function cc.exports.getAdverInterStandTime()
    return getXXXValue(getFunctionKeys().KEY_ADVER, getFunctionKeys().KEY_ADVERINTERTIME)
end

function cc.exports.isAutoSupplySupported()
    return cc.exports.isSafeBoxSupported() and isXXXSupported(getFunctionKeys().KEY_AUTOSUPPLY)
end

function cc.exports.isAutoSupplySaveSupported()
    local support = isXXXSupported(getFunctionKeys().KEY_AUTOSUPPLY_SAVE)
    print("isAutoSupplySaveSupported support: ", support)
    return cc.exports.isSafeBoxSupported() and support
end

function cc.exports.getAutoSupplyRoomValue()
    return getXXXValue(getFunctionKeys().KEY_AUTOSUPPLY, getFunctionKeys().KEY_AUTOSUPPLYROOM)
end

function cc.exports.getAutoSupplyRatioValue()
    return getXXXValue(getFunctionKeys().KEY_AUTOSUPPLY, getFunctionKeys().KEY_AUTOSUPPLYRATIO)
end

function cc.exports.getAutoSupplyDepositLimit()
    return getXXXValue(getFunctionKeys().KEY_AUTOSUPPLY, getFunctionKeys().KEY_AUTOSUPPLYDEPOSITLIMIT)
end

function cc.exports.isAutoJumpRoomSupported()
    return isXXXSupported(getFunctionKeys().KEY_AUTOJUMPROOM)
end

function cc.exports.getJumpNormalRoomValue()
    return getXXXValue(getFunctionKeys().KEY_AUTOJUMPROOM, getFunctionKeys().KEY_NORMALROOM)
end

function cc.exports.getJumpNoWashRoomValue()
    return getXXXValue(getFunctionKeys().KEY_AUTOJUMPROOM, getFunctionKeys().KEY_NOWASHROOM)
end

function cc.exports.getJumpRoomDSRMDValue()
    return getXXXValue(getFunctionKeys().KEY_AUTOJUMPROOM, getFunctionKeys().KEY_DSRMD)
end

function cc.exports.getJumpRoomNWDSRMDValue()
    return getXXXValue(getFunctionKeys().KEY_AUTOJUMPROOM, getFunctionKeys().KEY_NWDSRMD)
end

function cc.exports.getJumpNormalRoomSafeValue()
    return getXXXValue(getFunctionKeys().KEY_AUTOJUMPROOM, getFunctionKeys().KEY_NORMALROOMSAFE)
end

function cc.exports.getJumpNoWashRoomSafeValue()
    return getXXXValue(getFunctionKeys().KEY_AUTOJUMPROOM, getFunctionKeys().KEY_NOWASHROOMSAFE)
end

function cc.exports.getQuickStartMatchType()
    return getXXXValue(getFunctionKeys().KEY_QUICKSTART, getFunctionKeys().KEY_QUICKSTART_MATCHTYPE)
end

function cc.exports.getQuickStartMatchRandom()      
    return getXXXValue(getFunctionKeys().KEY_QUICKSTART, getFunctionKeys().KEY_QUICKSTART_MATCHRANDOM)
end

function cc.exports.getQuickStartMatchSet()      
    return getXXXValue(getFunctionKeys().KEY_QUICKSTART, getFunctionKeys().KEY_QUICKSTART_MATCHSET)
end

function cc.exports.getExchangeMaxCount(prizeName)      
    local defaultCount = getXXXValue(getFunctionKeys().KEY_EXCHANGE_MAX, getFunctionKeys().KEY_EXCHANGE_DEFAULT_COUNT)
    local list = nil
    local str = getFunctionKeys().KEY_EXCHANGE_LIMIT_ZS
    if BusinessUtils:getInstance():isGameDebugMode() then
        str = getFunctionKeys().KEY_EXCHANGE_LIMIT_125
    end
    list = getXXXValue(getFunctionKeys().KEY_EXCHANGE_MAX, str)
    
    local bRet = defaultCount or 1 --没有配置默认1次
    if list then
        for name, limitCount in pairs(list) do
            if name == prizeName and type(limitCount) == 'number' then
                bRet = limitCount
            end
        end
    end

    return bRet
end

function cc.exports.isExchangeLotterySupported()      
    return isXXXSupported(getFunctionKeys().KEY_EXCHANGE_LOTTERY)
end

function cc.exports.isBankruptcySupported()      
    return isXXXSupported(getFunctionKeys().KEY_BANKRUPTCY)
end

function cc.exports.isDailyRechargeSupported()      
    return isXXXSupported(getFunctionKeys().KEY_DAILY_RECHARGE)
end

function cc.exports.isYuleRoomSupported()
    return isXXXSupported(getFunctionKeys().KEY_ISYULEROOM)
end

function cc.exports.isJiSuRoomSupported()
    return isXXXSupported(getFunctionKeys().KEY_JI_SU_ROOM)
end

--是否显示不无水印
function cc.exports.isUseMarkWithoutSupported()
    return isXXXSupported(getFunctionKeys().KEY_USE_MARK_WITHOUT)
end

--是否显示金鼎水印
function cc.exports.isUseMarkJdSupported()
    return isXXXSupported(getFunctionKeys().KEY_USE_MARK_JD)
end

--是否开启HSox网页支付
function cc.exports.isHSoxRaySupported()
    return isXXXSupported(getFunctionKeys().KEY_HSOX_PAY)
end

--是否显示定时赛
function cc.exports.isTimingGameSupported()
    return isXXXSupported(getFunctionKeys().KEY_TIMING_GAME)
end

--大厅人物提示
function cc.exports.getTimmingGameHallTips(  )
    return getXXXValue(getFunctionKeys().KEY_TIMING_GAME, getFunctionKeys().KEY_TIMING_GAME_HALL_TIPS)
end

--定时赛入口动画类型 1话费赛 2定时赛
function cc.exports.getTimmingGameEntryType(  )
    return getXXXValue(getFunctionKeys().KEY_TIMING_GAME, getFunctionKeys().KEY_TIMING_GAME_ENTRY_TYPE)
end

--定时赛首次购买商品的ExchangeIDs
function cc.exports.getTimmingGameFirstExchangeIDs(  )
    return getXXXValue(getFunctionKeys().KEY_TIMING_GAME, getFunctionKeys().KEY_TIMING_GAME_FIEIDS)
end

--定时赛广播提示语
function cc.exports.getTimmingGameBCTip(  )
    return getXXXValue(getFunctionKeys().KEY_TIMING_GAME, getFunctionKeys().KEY_TIMING_GAME_BC_TIP)
end

--定时赛广播提示语播报次数
function cc.exports.getTimmingGameBCRtimes(  )
    return getXXXValue(getFunctionKeys().KEY_TIMING_GAME, getFunctionKeys().KEY_TIMING_GAME_BC_RTIMES)
end

--定时赛门票入口开关
function cc.exports.getTimmingGameTicketEntranceSwitch(  )
    return getXXXValue(getFunctionKeys().KEY_TIMING_GAME, getFunctionKeys().KEY_TIMING_GAME_TICKET_ES)
end

--定时赛门票任务入口开关
function cc.exports.getTimmingGameTicketTaskEntranceSwitch(  )
    return getXXXValue(getFunctionKeys().KEY_TIMING_GAME, getFunctionKeys().KEY_TIMING_GAME_TICKET_TASK_ES)
end

--定时赛获取门票方式
function cc.exports.getTimmingGameGetTicketWay(  )
    return getXXXValue(getFunctionKeys().KEY_TIMING_GAME, getFunctionKeys().KEY_TIMING_GAME_GET_TICKET_WAY)
end

--定时赛超哥专属房间背景开关
function cc.exports.getTimmingGameChaoGeRoomBg(  )
    return getXXXValue(getFunctionKeys().KEY_TIMING_GAME, getFunctionKeys().KEY_TIMING_CHAO_GE_ROOM_BG)
end

--定时赛龙崎专属房间背景开关
function cc.exports.getTimmingGameLongQiRoomBg(  )
    return getXXXValue(getFunctionKeys().KEY_TIMING_GAME, getFunctionKeys().KEY_TIMING_LONG_QI_ROOM_BG)
end

--定时赛获取门票方式是否支持 参数"task"/"deposit"/"rmb"
--返回false true
function cc.exports.canTimmingGameGetTicketByWay(key)
    if not key then return false end
    local config = getXXXValue(getFunctionKeys().KEY_TIMING_GAME, getFunctionKeys().KEY_TIMING_GAME_GET_TICKET_WAY)
    local result = config and config[key] or 0
    return result == 1
end

--是否显示幸运礼包
function cc.exports.isLuckyPackSupported()
    return isXXXSupported(getFunctionKeys().KEY_LUCKY_PACK)
end

-- 是否是春节礼包
function cc.exports.isSpringFestivalType()
    return getXXXValue(getFunctionKeys().KEY_LUCKY_PACK, getFunctionKeys().KEY_SPRINGFESTIVAL)
end

-- 超级大奖池
function cc.exports.isRechargePoolSupported()
    return isXXXSupported(getFunctionKeys().KEY_RECHARGE_POOL)
end

function cc.exports.getRechargePoolRankUpdateInverval()
    local default = 300
    local tbl = getConfigKey(getFunctionKeys().KEY_RECHARGE_POOL)
    if type(tbl) ~= 'table' then
        return default
    end
    local value = tbl["rankupdateintervals"]
    if type(value) ~= 'number' then 
        return default
    end
    return value
end

-- 超级大奖池提升数值提示
function cc.exports.getRechargePoolPromoteNumTip()
    return getXXXValue(getFunctionKeys().KEY_RECHARGE_POOL, getFunctionKeys().KEY_PROMOTE_NUM_TIP)
end

-- 春节换肤
function cc.exports.isSpringFestivalViewSupported()
    return isXXXSupported(getFunctionKeys().KEY_SPRING_FESTIVAL_VIEW)
end

-- 春节换肤开始时间
function cc.exports.getSpringFestivalViewStartDate()
    return getXXXValue(getFunctionKeys().KEY_SPRING_FESTIVAL_VIEW, getFunctionKeys().KEY_SPRING_FESTIVAL_VIEW_START_DATE)
end

-- 春节换肤结束时间
function cc.exports.getSpringFestivalViewEndDate()
    return getXXXValue(getFunctionKeys().KEY_SPRING_FESTIVAL_VIEW, getFunctionKeys().KEY_SPRING_FESTIVAL_VIEW_END_DATE)
end

--连充送话费
function cc.exports.getContinueRechargeSupport()
    local data = {}
    local tbl = getConfigKey("continuerecharge")
    if type(tbl) ~= 'table' then
        return data
    end
    data.support = tbl["support"]
    data.weak = tbl["weak"]
    return data
end

--是否启用自动弹窗数量限制
function cc.exports.isAutoPopCountSupported()
    return isXXXSupported(getFunctionKeys().KEY_AUTO_POP_COUNT)
end

--新用户自动弹窗数量
function cc.exports.isAutoPopNewPlayerCount()
    return getXXXValue(getFunctionKeys().KEY_AUTO_POP_COUNT, getFunctionKeys().KEY_AUTO_POP_NEWPLAYER)
end

--普通用户自动弹窗数量
function cc.exports.isAutoPopNormalPlayerCount()
    return getXXXValue(getFunctionKeys().KEY_AUTO_POP_COUNT, getFunctionKeys().KEY_AUTO_POP_NOMARLPLAYER)
end

--是否启用礼券翻倍
function cc.exports.isDoubleExchangeSupported()
    return isXXXSupported(getFunctionKeys().KEY_AUTO_DOUBLE_EXCHANGE)
end

--礼券翻倍周几开始
function cc.exports.isDoubleExchangeStartDate()
    return getXXXValue(getFunctionKeys().KEY_AUTO_DOUBLE_EXCHANGE, getFunctionKeys().KEY_AUTO_DE_STARTDATE)
end

--礼券翻倍周几结束
function cc.exports.isDoubleExchangeEndDate()
    return getXXXValue(getFunctionKeys().KEY_AUTO_DOUBLE_EXCHANGE, getFunctionKeys().KEY_AUTO_DE_ENDDATE)
end

--引导评论提示开关
function cc.exports.isGuideCommentsSupported()
    return isXXXSupported(getFunctionKeys().KEY_GUIDE_COMMENTS)
end

--获取引导评论最低局数限制
function cc.exports.getGuideCommentsMinBout()
    return getXXXValue(getFunctionKeys().KEY_GUIDE_COMMENTS, getFunctionKeys().KEY_GUIDE_COMMENTS_MIN_BOUT)
end

--获取引导评论连胜局数
function cc.exports.getGuideCommentsWSBout()
    return getXXXValue(getFunctionKeys().KEY_GUIDE_COMMENTS, getFunctionKeys().KEY_GUIDE_COMMENTS_WS_BOUT)
end

--获取引导评论提示语
function cc.exports.getGuideCommentsTip()
    return getXXXValue(getFunctionKeys().KEY_GUIDE_COMMENTS, getFunctionKeys().KEY_GUIDE_TIP)
end

--Vivo特权活动开关
function cc.exports.isVivoVipActivitySupported()
    return isXXXSupported(getFunctionKeys().KEY_GUIDE_VIVOVIPACTIVITY)
end

--隐藏不洗牌初级房2开关
function cc.exports.isHideJuniorRoomSupported()
    return isXXXSupported(getFunctionKeys().KEY_HIDE_JUNIOR_ROOM)
end

--合并不洗牌初级房2的RoomID
function cc.exports.getMergeHideJuniorRoomID()
    return getXXXValue(getFunctionKeys().KEY_HIDE_JUNIOR_ROOM, getFunctionKeys().KEY_MERGE_HIDE_ROOM_ID)
end

--隐藏不洗牌初级房2的RoomID
function cc.exports.getHideJuniorRoomID()
    return getXXXValue(getFunctionKeys().KEY_HIDE_JUNIOR_ROOM, getFunctionKeys().KEY_HIDE_ROOM_ID)
end

--隐藏不洗牌初级房的人数限制，超过后推送隐藏房间
function cc.exports.getUserCountLimit()
    return getXXXValue(getFunctionKeys().KEY_HIDE_JUNIOR_ROOM, getFunctionKeys().KEY_USER_COUNT_LIMIT)
end

-----------------------------------------
function cc.exports.getRoomQuickRechargeExchangeId(szRoomType, szRoomLevel)
    local tbl = getConfigKey("roomQuickRecharge")
    if type(tbl) ~= 'table' then
        return nil
    end
    local lv2Ids = tbl[szRoomType]
    if type(lv2Ids) ~= 'table' then
        return nil
    end
    local szPackageType = ""
    if cc.exports.IsHejiPackage() then
        szPackageType = "heji"
    elseif device.platform == "android" then
        szPackageType = "android"
    elseif device.platform == "ios" then
        szPackageType = "ios"
    end
    if string.len(szPackageType) <= 0 then 
        print("[ERROR] unknow platform...")
        return nil
    end
    local exchangeId = nil
    if szRoomType == 'deposit' then
        if szRoomLevel == "junior" or szRoomLevel == "middle" or 
                szRoomLevel == "senior" or szRoomLevel == "master" or szRoomLevel == "supermaster" or szRoomLevel == "zongshi" then  
            exchangeId = lv2Ids[szRoomLevel][szPackageType]
        end
    elseif szRoomType == 'noshuffle' then
        if szRoomLevel == "junior" or szRoomLevel == "middle" or 
                szRoomLevel == "senior" or szRoomLevel == "master" or szRoomLevel == "supermaster" or szRoomLevel == "zongshi" then  
            exchangeId = lv2Ids[szRoomLevel][szPackageType]
        end
    elseif szRoomType == 'jisu' then -- 血战
        if szRoomLevel == "junior" or szRoomLevel == "quanming" or 
                szRoomLevel == "senior" or szRoomLevel == "master" or szRoomLevel == "supermaster" or szRoomLevel == "zongshi" then  
            exchangeId = lv2Ids[szRoomLevel][szPackageType]
        end
    end
    return exchangeId
end

function cc.exports.isAllChannelWeakenScoreRoomLimit()
    return getXXXValue("WeakenScoreRoom", "AllChannelActive")
end

function cc.exports.isChannelWeakenScoreRoomBoutLimit(channelId)
    if cc.exports.isAllChannelWeakenScoreRoomLimit() then
        return true
    end

    local channelList = getXXXValue("WeakenScoreRoom", "ActiveChannelList")
    if channelList and #channelList > 0 then
        return table.indexof(channelList, channelId) ~= false
    end
    return false
end

-- 每日抽奖(LoginLottery)是否启用视频
function cc.exports.isLoginLotteryApplyVideo()
    local default = true
    local tbl = getConfigKey("loginlottery")
    if type(tbl) ~= 'table' then
        return default
    end
    local value = tbl["applyVideoAd"]
    if type(value) ~= 'number' then 
        return default
    end
    local switch = value > 0
    local channelId = my.getTcyChannelId()
    local channels = tbl["applyVideoAdchannels"] -- channels配置优先
    if type(channels) == 'table' and type(channels[channelId]) == 'number' then
        switch = channels[channelId] > 0
    end
    return switch
end

function cc.exports.isWatchVideoTakeRewardSupport()
    return isXXXSupported("watchvideotakereward")
end

function cc.exports.isRechargeFlopCardSupport()
    return isXXXSupported("rechargeflopcard")
end

-- 娱乐大厅
function cc.exports.isMoreGameConfigSupported()
    return isXXXSupported(getFunctionKeys().KEY_MOREGAMECONFIG)
end

function cc.exports.getMoreGameSetting()
    return getXXXValue(getFunctionKeys().KEY_MOREGAMECONFIG,getFunctionKeys().KEY_MOREGAMESET)
end

function cc.exports.getMoreGamePanelType()
    return getXXXValue(getFunctionKeys().KEY_MOREGAMECONFIG,getFunctionKeys().KEY_MOREGAMEPANELTYPE)
end

function cc.exports.getMoreGameRecommand()
    return getXXXValue(getFunctionKeys().KEY_MOREGAMECONFIG,getFunctionKeys().KEY_MOREGAMERECOMMAND)
end

function cc.exports.getMoreGameHallEntry()
    return getXXXValue(getFunctionKeys().KEY_MOREGAMECONFIG,getFunctionKeys().KEY_MOREGAMEHALLENTRY)
end

-- 主播微信号开关
function cc.exports.isAnchorWeiXinSupported()
    return isXXXSupported(getFunctionKeys().KEY_HALL_ANCHOR_INFO)
end

-- 主播微信标题
function cc.exports.getAnchorWeiXinTitle()
    return getXXXValue(getFunctionKeys().KEY_HALL_ANCHOR_INFO, getFunctionKeys().KEY_HALL_WEIXIN_TITLE)
end

-- 主播微信名
function cc.exports.getAnchorWeiXinName()
    return getXXXValue(getFunctionKeys().KEY_HALL_ANCHOR_INFO, getFunctionKeys().KEY_HALL_WEIXIN_NAME)
end

-- 主播海报开关
function cc.exports.isAnchorPosterSupported()
    return isXXXSupported(getFunctionKeys().KEY_HALL_ANCHOR_POSTER)
end

-- 主播海报数量
function cc.exports.getAnchorPosterNum()
    return getXXXValue(getFunctionKeys().KEY_HALL_ANCHOR_POSTER, getFunctionKeys().KEY_HALL_ANCHOR_POSTER_NUM)
end

-- 主播海报主播名
function cc.exports.getAnchorPosterName()
    return getXXXValue(getFunctionKeys().KEY_HALL_ANCHOR_POSTER, getFunctionKeys().KEY_HALL_ANCHOR_POSTER_NAME)
end

-- 主播海报开播时间
function cc.exports.getAnchorPosterTime()
    return getXXXValue(getFunctionKeys().KEY_HALL_ANCHOR_POSTER, getFunctionKeys().KEY_HALL_ANCHOR_POSTER_TIME)
end

-- 主播海报图Url
function cc.exports.getAnchorPosterUrl()
    return getXXXValue(getFunctionKeys().KEY_HALL_ANCHOR_POSTER, getFunctionKeys().KEY_HALL_ANCHOR_POSTER_URL)
end

-- 主播海报主播直播间ID
function cc.exports.getAnchorRoomID()
    return getXXXValue(getFunctionKeys().KEY_HALL_ANCHOR_POSTER, getFunctionKeys().KEY_HALL_ANCHOR_ID)
end

-- 主播海报主播微信ID
function cc.exports.getAnchorWechatID()
    return getXXXValue(getFunctionKeys().KEY_HALL_ANCHOR_POSTER, getFunctionKeys().KEY_HALL_ANCHOR_WECHAT_ID)
end

-- 主播直播功能开关
function cc.exports.isAnchorRoomSupported()
    return isXXXSupported(getFunctionKeys().KEY_HALL_ANCHOR_ROOM)
end

-- 主播直播提示
function cc.exports.getAnchorRoomWarnningTip()
    return getXXXValue(getFunctionKeys().KEY_HALL_ANCHOR_ROOM, getFunctionKeys().KEY_HALL_WARNNING_TIP)
end

-- 主播人数
function cc.exports.getAnchorPlayerNum()
    return getXXXValue(getFunctionKeys().KEY_HALL_ANCHOR_ROOM, getFunctionKeys().KEY_HALL_ANCHOR_PLAYER_NUM)
end

-- 主播使用桌号
function cc.exports.getAnchorPlayerUseTableNO()
    return getXXXValue(getFunctionKeys().KEY_HALL_ANCHOR_ROOM, getFunctionKeys().KEY_HALL_ANCHOR_PLAYER_USE_TABLE_NO)
end

-- 主播使用的账号
function cc.exports.getAnchorPlayerUseID()
    return getXXXValue(getFunctionKeys().KEY_HALL_ANCHOR_ROOM, getFunctionKeys().KEY_HALL_ANCHOR_PLAYER_USE_ID)
end

-- 主播开播时间
function cc.exports.getAnchorPlayerUseTime()
    return getXXXValue(getFunctionKeys().KEY_HALL_ANCHOR_ROOM, getFunctionKeys().KEY_HALL_ANCHOR_PLAYER_TIME)
end

-- 宗师房限时开放开关
function cc.exports.isLimitTimeOpenSupported()
    return isXXXSupported(getFunctionKeys().KEY_HALL_OPEN_TIME)
end

-- 宗师房限时开放时间
function cc.exports.getOpenTime()
    return getXXXValue(getFunctionKeys().KEY_HALL_OPEN_TIME, getFunctionKeys().KEY_HALL_GAME_OPEN_TIME)
end

function cc.exports.isVideoAdSupported()
    local AdPlugin = plugin.AgentManager:getInstance():getAdsPlugin()
    if not AdPlugin then 
        return false
    end
    if not (AdPlugin.loadChannelAd and AdPlugin.showChannelAd) then
        return false
    end
    return true
end

function cc.exports.isVideoAdReliefSupported(  )
    return cc.exports.isVideoAdSupported() and cc.exports.isReliefSupported() and (getXXXValue('relief', 'VideoAdSupport') == 1)
end

function cc.exports.isCpsAppSupport()
    return isXXXSupported(getFunctionKeys().KEY_CPS_APP)
end

function cc.exports.isGameMarkSupport()
    return isXXXSupported(getFunctionKeys().KEY_GAME_MARK)
end

function cc.exports.isNewUserRewardSupported()
    return isXXXSupported("NewUserReward")
end

function cc.exports.isSafeboxNeedCheckCreateInfo()
    return getXXXValue('safebox', 'NeedCheckCreateInfo') == 1
end

function cc.exports.getSafeboxCheckCreateStartDate()
    return getXXXValue('safebox', 'CheckCreateStartDate')
end

function cc.exports.isSafeboxSaveFuncEnableLimit()
    return getXXXValue('safebox', 'SaveLimitConfig', 'EnableLimit') == 1
end

function cc.exports.getSafeboxNPLevelLimit()
    return getXXXValue('safebox', 'SaveLimitConfig', 'NPLevelLimit')
end

function cc.exports.getSafeboxSaveTimesLimit()
    return getXXXValue('safebox', 'SaveLimitConfig', 'TimesLimit')
end

function cc.exports.getSafeboxSaveCountLimit()
    return getXXXValue('safebox', 'SaveLimitConfig', 'CountLimit')
end


function cc.exports.isAnchorLuckyBagSupported()
    return isXXXSupported('AnchorLuckyBag')
end

function cc.exports.getReliefLowLimit()
    return getXXXValue('relief', 'lowlimit') or 2500
end

function cc.exports.isShopTongbaoSupport()
    return getXXXValue('shop', 'tongbao') == 1
end

function cc.exports.isShopTongbaoExchangeSupported()
    return getXXXValue('shop', 'exchange') == 1
end

function cc.exports.isValuablePurchaseSupported()
    return isXXXSupported('ValuablePurchase')
end

function cc.exports.isGratitudeRepaySupported()
    return isXXXSupported(getFunctionKeys().KEY_GRATITUDE_REPAY)
end

function cc.exports.isTeam2V2RoomSupported()
    return isXXXSupported(getFunctionKeys().KEY_TEAM_2V2_ROOM)
end

function cc.exports.isTeam2V2ShareSupported()
    local team2V2Share = getXXXValue(getFunctionKeys().KEY_TEAM_2V2_ROOM, getFunctionKeys().KEY_TEAM_2V2_SHARE)
    return team2V2Share == 1
end

function cc.exports.getReliefLargeExchangeID()
    return getXXXValue('relief', 'largerExchangID')
end

function cc.exports.getReliefSmallExchangeID()
    return getXXXValue('relief', 'smallExchangeID')
end

function cc.exports.getTeam2V2ShareObj()
    return getXXXValue('Team2V2Room', 'shareObj')
end

function cc.exports.getTeam2V2RoomList()
    return getXXXValue('Team2V2Room', 'roomList')
end

function cc.exports.getTeam2V2RoomInfo(roomID)
    local roomList = getTeam2V2RoomList()
    for i, roomInfo in ipairs(roomList) do
        if roomInfo.nRoomID == roomID then
            return roomInfo
        end
    end
    return nil
end

function cc.exports.getTeam2V2BoutNumLock()
    local boutNumLock = getXXXValue('Team2V2Room', 'boutNumLock')
    return boutNumLock and boutNumLock or 3
end

function cc.exports.getTeam2V2InviteExpire()
    local inviteExpire = getXXXValue('Team2V2Room', 'inviteExpire')
    return inviteExpire and inviteExpire or 3600
end

--添加弹窗可配置化的读取接口
--新用户的读取接口
function cc.exports.getNewUserPopPluginList()
    return getXXXValue('PluginProcess', 'NewUserPopPluginList')
end

--老用户的可读取接口
function cc.exports.getNormalUserPopPluginList()
    return getXXXValue('PluginProcess', 'NormalUserPopPluginList')
end


function cc.exports.isQRCodePaySupported()
    return isXXXSupported('QRCodePay')
end

--用于传到后台
local UsageType = {
    TCY    = 0,--单包
    TCYAPP = 0,--同城游
    UNOFFICIAL_PLATFORMSET = 1,    --非官方合集包
    OFFICIAL_PLATFORMSET = 2,    --官方合集包
}
function cc.exports.getUsageType()
    local subModle = nil
    if  MCAgent:getInstance().getLaunchSubMode then
        subModle = MCAgent:getInstance():getLaunchSubMode()
    end
    if subModle then
        if subModle == cc.exports.LaunchSubMode.PLATFORMSET2  then 
            return UsageType.OFFICIAL_PLATFORMSET
        elseif subModle == cc.exports.LaunchSubMode.PLATFORMSET then
            return UsageType.UNOFFICIAL_PLATFORMSET
        end
    end
    return 0
end

function cc.exports.isNewUserGuideSupported()
    return isXXXSupported('NewUserGuide')
end

function cc.exports.getNewUserGuideCheckCreateStartDate()
    return getXXXValue('NewUserGuide', 'CheckCreateStartDate')
end

function cc.exports.getNewUserGuideBoutCount()
    return getXXXValue('NewUserGuide', 'GuideBout')
end

function cc.exports.canSkipNewUserGuide()
    return getXXXValue('NewUserGuide', 'CanSkip') == 1
end

function cc.exports.getQRCodePayChannelID()
    return getXXXValue('QRCodePay', 'PayChannelID')
end

function cc.exports.isReportSupported()
    return isXXXSupported('Report')
end

function cc.exports.getReportRoomConfig()
    return getXXXValue('Report', 'room')
end

function cc.exports.isPeakRankSupported()
    return isXXXSupported('PeakRank')
end

function cc.exports.getPeakRankRankListUpdateInterval()
    return getXXXValue('PeakRank', 'RankListUpdateInterval') or 300
end

function cc.exports.getPeakRankAniLevelTbl()
    return getXXXValue('PeakRank', 'AniLevelTbl') or {0, 20, 40, 60, 80}
end

function cc.exports.getPeakRankRuleStrings()
    return getXXXValue('PeakRank', 'RuleStrings')
end

function cc.exports.isCommonMpSvrSupported()
    return isXXXSupported('ComonMpSvr')
end