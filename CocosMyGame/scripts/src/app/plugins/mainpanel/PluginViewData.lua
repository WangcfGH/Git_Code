
cc.exports.MODULE_NAMES = {
    ["goldSilver"] = "goldSilver",
	["goldSilverCopy"] = "goldSilverCopy",
    ["shop"] = "shop",
    ["lottery"] = "lottery",
    ["task"] = "task",
    ["exchange"] = "exchange"
}

local pluginViewData = {
    --左侧区域
    ["packSet"] = {
        ["itemName"] = "packSet",
		["nodeName"] = "Btn_GiftPacks", --按钮节点名称
		["belongedPanel"] = "leftBar", --所属面板

		["pluginName"] = nil, --插件名称
		["pluginBtn"] = nil, --插件按钮
        ["checkSupport"] = nil, --开关检查，checkSupport返回false会自动将isAvail置为false

        ["btnAniType"] = "spineAni", --按钮动画类型（spineAni：骨骼动画，由代码动态添加；frameAni：帧动画，在cocosstudio中静态添加）
        ["btnAniCondition"] = "onReddot", --动画播放条件（onReddot：有红点则播放动画，onAvail：按钮可见即播放，onNeed：按需）
        ["isNeedBtnAni"] = false,

		["isAvail"] = true, --是否显示
        ["isAvailOnlyByCheckSupport"] = true, --isAvail是否仅依赖于checkSupport
		["isNeedReddot"] = false, --是否显示红点
	},

	["gameCity"] = {
        ["itemName"] = "gameCity",
		["nodeName"] = "Btn_GameCity",
		["belongedPanel"] = "leftBar",

		["pluginName"] = nil, 
		["pluginBtn"] = nil,
        ["checkSupport"] = function() return cc.exports.isDWCSupported() end,

        ["btnAniType"] = "spineAni",
        ["btnAniCondition"] = "onAvail",

		["isAvail"] = false,
        ["isAvailOnlyByCheckSupport"] = true,
		["isNeedReddot"] = false,
	},

	["PPL"] = {
        ["itemName"] = "PPL",
		["nodeName"] = "Btn_PPL",
		["belongedPanel"] = "leftBar",

		["pluginName"] = "nil", 
		["pluginBtn"] = nil,
        ["checkSupport"] = function() return cc.exports.isPPLSupported() end,
		["isAvail"] = false,
        ["isAvailOnlyByCheckSupport"] = true,
		["isNeedReddot"] = false,
	},
	["WatchVideo"] = {
		["itemName"] = "WatchVideo",
		["nodeName"] = "Btn_WatchVideo",
		["belongedPanel"] = "leftBar",

		["pluginName"] = "nil", 
		["pluginBtn"] = nil,
		["checkSupport"] = function()
			local WatchVideoTakeRewardModel = require("src.app.plugins.watchvideotakereward.WatchVideoTakeRewardModel"):getInstance()
			return WatchVideoTakeRewardModel:isOpen()
		end,
		["isAvail"] = false,
        ["isAvailOnlyByCheckSupport"] = true,
		["isNeedReddot"] = false,
	},
	["rechargeFlopCard"] = {
		["itemName"] = "rechargeFlopCard",
		["nodeName"] = "Btn_RechargeFlopCard",
		["belongedPanel"] = "leftBar",

		["pluginName"] = "nil", 
		["pluginBtn"] = nil,
		["checkSupport"] = function()
			local rechargeFlopCardModel = require("src.app.plugins.RechargeFlopCard.RechargeFlopCardModel"):getInstance()
			return rechargeFlopCardModel:isOpen()
		end,
		["isAvail"] = false,
        ["isAvailOnlyByCheckSupport"] = true,
		["isNeedReddot"] = false,
		["btnAniType"] = "frameAni",
        ["btnAniCsbPath"] = "res/hallcocosstudio/RechargeFlopCard/ffl.csb",
        ["btnAniCondition"] = "onAvail",
	},
	["goldSilver"] = {
        ["itemName"] = "goldSilver",
		["nodeName"] = "Btn_GoldSilver",
		["belongedPanel"] = "leftBar",

		["pluginName"] = "nil", 
		["pluginBtn"] = nil,
        ["checkSupport"] = function() return cc.exports.isGoldSilverSupported() end,

        ["btnAniType"] = "frameAni",
        ["btnAniCsbPath"] = "res/hallcocosstudio/passcheck/jyb.csb",
        ["btnAniCondition"] = "onAvail",

		["isAvail"] = false,
        ["isAvailOnlyByCheckSupport"] = false,
		["isNeedReddot"] = false,
	},
	["goldSilverCopy"] = {
        ["itemName"] = "goldSilverCopy",
		["nodeName"] = "Btn_GoldSilverCopy",
		["belongedPanel"] = "leftBar",

		["pluginName"] = "nil", 
		["pluginBtn"] = nil,
        ["checkSupport"] = function() return cc.exports.isGoldSilverCopySupported() end,

        ["btnAniType"] = "spineAni",
        --["btnAniCsbPath"] = "res/hallcocosstudio/passcheckCopy/jybCopy.csb",
        ["btnAniCondition"] = "onAvail",

		["isAvail"] = false,
        ["isAvailOnlyByCheckSupport"] = false,
		["isNeedReddot"] = false,
	},
	["rechargeAct"] = {
        ["itemName"] = "rechargeAct",
		["nodeName"] = "Btn_RechargeActivity",
		["belongedPanel"] = "leftBar",

		["pluginName"] = "RechargeActivityCtrl", 
		["pluginBtn"] = nil,
        ["checkSupport"] = function() return cc.exports.isRechargeActivitySupported() end,

        ["btnAniType"] = "frameAni",
        ["btnAniCsbPath"] = "res/hallcocosstudio/RechargeActivity/czyl.csb",
        ["btnAniCondition"] = "onNeed",

		["isAvail"] = false,
        ["isAvailOnlyByCheckSupport"] = false,
		["isNeedReddot"] = false,
	},

	["topRank"] = {
        ["itemName"] = "topRank",
		["nodeName"] = "Btn_TopRank",
		["belongedPanel"] = "leftBar",

		["pluginName"] = nil, 
		["pluginBtn"] = nil,
        ["checkSupport"] = function() return cc.exports.isTopRankSupported() end,

        ["btnAniType"] = "frameAni",
        ["btnAniCsbPath"] = "res/hallcocosstudio/NationalDayActivity/dfb.csb",
        ["btnAniCondition"] = "onAvail",

		["isAvail"] = false,
        ["isAvailOnlyByCheckSupport"] = false,
		["isNeedReddot"] = false,
	},

	["legendCome"] = {
        ["itemName"] = "legendCome",
		["nodeName"] = "Btn_LegendCome",
		["belongedPanel"] = "leftBar",

		["pluginName"] = nil, 
		["pluginBtn"] = nil,
        ["checkSupport"] = function() return cc.exports.isLegendComeSupported() end,

		["isAvail"] = false,
        ["isAvailOnlyByCheckSupport"] = true,
		["isNeedReddot"] = false,
	},

	["rechargepool"] = {
		["itemName"] = "rechargepool",
		["nodeName"] = "Btn_RechargePool", --按钮节点名称
		["belongedPanel"] = "leftBar", --所属面板

		--
		["pluginName"] = nil,
		["pluginBtn"] = nil,
		["checkSupport"] = function ()   
			if cc.exports.isRechargePoolSupported() then
				local rechargePoolModel = require("src.app.plugins.rechargepool.RechargePoolModel"):getInstance()
				return rechargePoolModel:isShowEntry()
			end
			return false
		end,
		["isAvailOnlyByCheckSupport"] = true, --isAvail是否仅依赖于checkSupport
		["isAvail"] = false, --是否显示
	},

	["gratitudeRepay"] = {
		["itemName"] = "gratitudeRepay",
		["nodeName"] = "Btn_GratitudeRepay", --按钮节点名称
		["belongedPanel"] = "leftBar", --所属面板

		--
		["pluginName"] = "GratitudeRepayCtrl",
		["pluginBtn"] = nil,
		["checkSupport"] = function ()   
			if cc.exports.isGratitudeRepaySupported() then
				local GratitudeRepayModel = require("src.app.plugins.GratitudeRepay.GratitudeRepayModel"):getInstance()
				return GratitudeRepayModel:isOpen()
			end
			return false
		end,

		["btnAniType"] = "spineAni",
		["isAvail"] = false,
        ["isAvailOnlyByCheckSupport"] = true,
		["isNeedReddot"] = false,
		["btnAniCondition"] = "onAvail",
	},
	
	["continueRecharge"] = {
		["itemName"] = "continueRecharge",
		["nodeName"] = "Btn_ContRecharge", --按钮节点名称
		["belongedPanel"] = "leftBar", --所属面板

		--
		["pluginName"] = nil,
		["pluginBtn"] = nil,
		["checkSupport"] = function ()   
			local continueRechargeModel = require("src.app.plugins.continuerecharge.ContinueRechargeModel"):getInstance()
			return continueRechargeModel:isOpen()
		end,
		["btnAniType"] = "frameAni",
        ["btnAniCsbPath"] = "res/hallcocosstudio/huafei/bshf.csb",
        ["btnAniCondition"] = "onAvail",
		["isAvailOnlyByCheckSupport"] = true, --isAvail是否仅依赖于checkSupport
		["isAvail"] = false, --是否显示
	},

	["luckyPack"] = {
		["itemName"] = "luckyPack",
		["nodeName"] = "Btn_Redenvelope", --按钮节点名称
		["belongedPanel"] = "leftBar", --所属面板

		--
		["pluginName"] = nil,
		["pluginBtn"] = nil,
		["checkSupport"] = function()
			local LuckyPackModel = import('src.app.plugins.LuckyPack.LuckyPackModel'):getInstance()
			return LuckyPackModel:isOpen()
		end,
		
		["btnAniType"] = "spineAni",
		["btnAniCondition"] = "onAvail",
		
		["isAvail"] = true, --是否显示
        ["isAvailOnlyByCheckSupport"] = true, --isAvail是否仅依赖于checkSupport
		["isNeedReddot"] = false, --是否显示红点
	},

	["vivoPrivilegeStartUp"] = {
		["itemName"] = "vivoPrivilegeStartUp",
		["nodeName"] = "Btn_VivoPrivilegeStartUp", --按钮节点名称
		["belongedPanel"] = "leftBar", --所属面板

		["pluginName"] = nil,
		["pluginBtn"] = nil,
		["checkSupport"] = function()
			return cc.exports.isVivoVipActivitySupported()
		end,
		
		["isAvail"] = true, --是否显示
        ["isAvailOnlyByCheckSupport"] = true, --isAvail是否仅依赖于checkSupport
		["isNeedReddot"] = false, --是否显示红点
	},

    --礼包集合
	["loginPack"] = {
        ["itemName"] = "loginPack",
		["nodeName"] = "Btn_LoginPack",
		["belongedPanel"] = "packSet",

		["pluginName"] = "NewPlayerGiftCtrl", 
		["pluginBtn"] = nil,
        ["checkSupport"] = function() return cc.exports.isNewPlayerGiftSupported() end,

		["isAvail"] = false,
        ["isAvailOnlyByCheckSupport"] = false,
		["isNeedReddot"] = false,
	},

	["firstRechargePack"] = {
        ["itemName"] = "firstRechargePack",
		["nodeName"] = "Btn_FirstChargePack",
		["belongedPanel"] = "packSet",

		["pluginName"] = "FirstRecharge", 
		["pluginBtn"] = nil,
        ["checkSupport"] = function() return cc.exports.isFirstRechargeSupported() end,

		["isAvail"] = false,
        ["isAvailOnlyByCheckSupport"] = false,
		["isNeedReddot"] = false,
	},

	["limitTimeSpecialPack"] = {
		["itemName"] = "limitTimeSpecialPack",
		["nodeName"] = "Btn_LimitTimeSpecial",
		["belongedPanel"] = "packSet",

		["pluginName"] = "LimitTimeSpecial",
		["pluginBtn"] = nil,
		["checkSupport"] = function () return cc.exports.isLimitTimeSpecialSupported() end,

		["isAvail"] = false,
		["isAvailOnlyByCheckSupport"] = false,
		["isNeedReddot"] = false,
	},

	["monthCardPack"] = {
        ["itemName"] = "monthCardPack",
		["nodeName"] = "Btn_MonthCardPack",
		["belongedPanel"] = "packSet",

		["pluginName"] = "WeekCard", 
		["pluginBtn"] = nil,
		["checkSupport"] = function() return cc.exports.isMonthCardSupported()
		or cc.exports.isWeekCardSupported() end,

		["isAvail"] = false,
        ["isAvailOnlyByCheckSupport"] = false,
		["isNeedReddot"] = false,
	},

	["weekMonthSuperCard"] = {
		["itemName"] = "weekMonthSuperCard",
		["nodeName"] = "Btn_WeekMonthSuperCard",
		["belongedPanel"] = "leftBar",

		["pluginName"] = "nil", 
		["pluginBtn"] = nil,
		["checkSupport"] = function()
			local WeekMonthSuperCardModel = require("src.app.plugins.WeekMonthSuperCard.WeekMonthSuperCardModel"):getInstance()
			return WeekMonthSuperCardModel:isOpen()
		end,
		["isAvail"] = false,
        ["isAvailOnlyByCheckSupport"] = true,
		["isNeedReddot"] = false,
		["btnAniType"] = "spineAni",
		["btnAniCondition"] = "onAvail",
	},

	["bankruptcyPack"] = {
        ["itemName"] = "bankruptcyPack",
		["nodeName"] = "Btn_TimeLimitPack",
		["belongedPanel"] = "packSet",

		["pluginName"] = "BankruptcyCtrl", 
		["pluginBtn"] = nil,
        ["checkSupport"] = function() return cc.exports.isBankruptcySupported() end,

		["isAvail"] = false,
        ["isAvailOnlyByCheckSupport"] = false,
		["isNeedReddot"] = false,
	},

    ["NobilityPrivilegeGift"] = {
        ["itemName"] = "NobilityPrivilegeGift",
		["nodeName"] = "Btn_NobilityPrivilegeGift",
		["belongedPanel"] = "packSet",

		["pluginName"] = "NobilityPrivilegeGiftCtrl", 
		["pluginBtn"] = nil,
        ["checkSupport"] = function() return cc.exports.isNobilityPrivilegeGiftSupported() end,

		["isAvail"] = false,
        ["isAvailOnlyByCheckSupport"] = false,
		["isNeedReddot"] = false,
	},


	["loginPack_LeftBar"] = {
        ["itemName"] = "loginPack_LeftBar",
		["nodeName"] = "Btn_LoginPack",
		["belongedPanel"] = "leftBar",

		["pluginName"] = "NewPlayerGiftCtrl", 
		["pluginBtn"] = nil,
        ["checkSupport"] = function() return cc.exports.isNewPlayerGiftSupported() end,

		["isAvail"] = false,
        ["isAvailOnlyByCheckSupport"] = false,
		["isNeedReddot"] = false,
	},

	["firstRechargePack_LeftBar"] = {
        ["itemName"] = "firstRechargePack_LeftBar",
		["nodeName"] = "Btn_FirstChargePack",
		["belongedPanel"] = "leftBar",

		["pluginName"] = "FirstRecharge", 
		["pluginBtn"] = nil,
        ["checkSupport"] = function() return cc.exports.isFirstRechargeSupported() end,

		["isAvail"] = false,
        ["isAvailOnlyByCheckSupport"] = false,
		["isNeedReddot"] = false,
	},

	["limitTimeSpecialPack_LeftBar"] = {
        ["itemName"] = "limitTimeSpecialPack_LeftBar",
		["nodeName"] = "Btn_LimitTimeSpecial",
		["belongedPanel"] = "leftBar",

		["pluginName"] = "LimitTimeSpecial", 
		["pluginBtn"] = nil,
        ["checkSupport"] = function() return cc.exports.isLimitTimeSpecialSupported() end,

		["isAvail"] = false,
        ["isAvailOnlyByCheckSupport"] = false,
		["isNeedReddot"] = false,
	},

	["monthCardPack_LeftBar"] = {
        ["itemName"] = "monthCardPack_LeftBar",
		["nodeName"] = "Btn_MonthCardPack",
		["belongedPanel"] = "leftBar",

		["pluginName"] = "WeekCard", 
		["pluginBtn"] = nil,
		["checkSupport"] = function() return cc.exports.isMonthCardSupported()
		or cc.exports.isWeekCardSupported() end,

		["isAvail"] = false,
        ["isAvailOnlyByCheckSupport"] = false,
		["isNeedReddot"] = false,
	},

	["bankruptcyPack_LeftBar"] = {
        ["itemName"] = "bankruptcyPack_LeftBar",
		["nodeName"] = "Btn_TimeLimitPack",
		["belongedPanel"] = "leftBar",

		["pluginName"] = "BankruptcyCtrl", 
		["pluginBtn"] = nil,
        ["checkSupport"] = function() return cc.exports.isBankruptcySupported() end,

		["isAvail"] = false,
        ["isAvailOnlyByCheckSupport"] = false,
		["isNeedReddot"] = false,
	},

    ["NobilityPrivilegeGift_LeftBar"] = {
        ["itemName"] = "NobilityPrivilegeGift_LeftBar",
		["nodeName"] = "Btn_NobilityPrivilegeGift",
		["belongedPanel"] = "leftBar",

		["pluginName"] = "NobilityPrivilegeGiftCtrl", 
		["pluginBtn"] = nil,
        ["checkSupport"] = function() return cc.exports.isNobilityPrivilegeGiftSupported() end,

		["isAvail"] = false,
        ["isAvailOnlyByCheckSupport"] = false,
		["isNeedReddot"] = false,
	},

	["timingGameTicketTask"] = {
        ["itemName"] = "timingGameTicketTask",
		["nodeName"] = "Btn_TimingGameTicketTask",
		["belongedPanel"] = "leftBar",

		["pluginName"] = "TimingGameTicketTask", 
		["pluginBtn"] = nil,
        ["checkSupport"] = function()
			local TimingGameModel = import('src.app.plugins.TimingGame.TimingGameModel'):getInstance()
			if TimingGameModel:isTicketTaskEntryShow() then
				return true
			end
			return false 
		end,

		["isAvail"] = false,
        ["isAvailOnlyByCheckSupport"] = true,
		["isNeedReddot"] = false,
	},

	-- 超值连购
	["valuablePurchase"] = {
		["itemName"] = "valuablePurchase",
		["nodeName"] = "Btn_ValuablePurchase",
		["belongedPanel"] = "leftBar",

		["pluginName"] = nil, 
		["pluginBtn"] = nil,
		["checkSupport"] = function() return cc.exports.isValuablePurchaseSupported() end,

		["btnAniType"] = "spineAni",
		["isAvail"] = false,
		["isAvailOnlyByCheckSupport"] = false,
		["isNeedReddot"] = false,
		["btnAniCondition"] = "onAvail",
	},
	
    --底部区域
    ["shop"] = {
        ["itemName"] = "shop",
		["nodeName"] = "Btn_Shop",
		["belongedPanel"] = "bottomBar",

		["pluginName"] = "ShopCtrl", 
		["pluginBtn"] = nil,
        ["checkSupport"] = function() return cc.exports.isShopSupported() end,        
		["isAvail"] = false,
        ["isAvailOnlyByCheckSupport"] = true,
		["isNeedReddot"] = false,
	},

    ["more"] = {
        ["itemName"] = "more",
		["nodeName"] = "Btn_More",
		["belongedPanel"] = "bottomBar",

		["pluginName"] = nil, 
		["pluginBtn"] = nil,

		["isAvail"] = true,
        ["isAvailOnlyByCheckSupport"] = false,
		["isNeedReddot"] = false,
	},

    ["safeBox"] = {
        ["itemName"] = "safeBox",
		["nodeName"] = "Btn_SaveBox",
		["belongedPanel"] = "bottomBar",

		["pluginName"] = "SafeboxCtrl", 
		["pluginBtn"] = nil,
        ["checkSupport"] = function() return cc.exports.isSafeBoxSupported() end,

		["isAvail"] = false,
        ["isAvailOnlyByCheckSupport"] = true,
		["isNeedReddot"] = false,
	},

    ["lottery"] = {
        ["itemName"] = "lottery",
		["nodeName"] = "Btn_Lottery",
		["belongedPanel"] = "bottomBar",

		["pluginName"] = "LoginLotteryCtrl", 
		["pluginBtn"] = nil,
        ["checkSupport"] = function() return cc.exports.isLoginLotterySupported() end,

		["isAvail"] = false,
        ["isAvailOnlyByCheckSupport"] = true,
		["isNeedReddot"] = false,
	},

    ["exchange"] = {
        ["itemName"] = "exchange",
		["nodeName"] = "Btn_Exchange",
		["belongedPanel"] = "bottomBar",

		["pluginName"] = "ExchangeCenterPlugin", 
		["pluginBtn"] = nil,
        ["checkSupport"] = function() return cc.exports.isExchangeSupported() end,

		["isAvail"] = false,
        ["isAvailOnlyByCheckSupport"] = true,
		["isNeedReddot"] = false,
	},

    ["task"] = {
        ["itemName"] = "task",
		["nodeName"] = "Btn_Mission",
		["belongedPanel"] = "bottomBar",

		["pluginName"] = "MyTaskPlugin", 
		["pluginBtn"] = nil,
        ["checkSupport"] = function() return cc.exports.isTaskSupported() end,

		["isAvail"] = false,
        ["isAvailOnlyByCheckSupport"] = true,
		["isNeedReddot"] = false,
	},

    ["activity"] = {
        ["itemName"] = "activity",
		["nodeName"] = "Btn_Activity",
		["belongedPanel"] = "bottomBar",

		["pluginName"] = "ActivityCenterCtrl", 
		["pluginBtn"] = nil,
        ["checkSupport"] = function() return cc.exports.isActivityCenterSupported() end,

		["isAvail"] = false,
        ["isAvailOnlyByCheckSupport"] = true,
		["isNeedReddot"] = false,
	},

	["yuleRoom"] = {
        ["itemName"] = "yuleRoom",
		["nodeName"] = "Btn_YuleRoom",
		["belongedPanel"] = "bottomBar",

		["pluginName"] = nil,
		["pluginBtn"] = nil,
        ["checkSupport"] = function() return cc.exports.isYuleRoomSupported() end,

		["isAvail"] = false,
        ["isAvailOnlyByCheckSupport"] = true,
		["isNeedReddot"] = false,
	},

    --更多按钮区域
    ["mail"] = {
        ["itemName"] = "mail",
		["nodeName"] = "Btn_Mail",
		["belongedPanel"] = "panelMore",

		["pluginName"] = "EmailPlugin", 
		["pluginBtn"] = nil,

		["isAvail"] = true,
        ["isAvailOnlyByCheckSupport"] = false,
		["isNeedReddot"] = false,
        ["reddotVal"] = -1
	},

    ["friendRoom"] = {
        ["itemName"] = "friendRoom",
		["nodeName"] = "Btn_FriendRoom",
		["belongedPanel"] = "panelMore",

		["pluginName"] = nil, 
		["pluginBtn"] = nil,
        ["checkSupport"] = function() return cc.exports.isSocialRoomSupported() end,

		["isAvail"] = false,
        ["isAvailOnlyByCheckSupport"] = true,
		["isNeedReddot"] = false,
	},

    ["friend"] = {
        ["itemName"] = "friend",
		["nodeName"] = "Btn_Friend",
		["belongedPanel"] = "panelMore",

		["pluginName"] = nil, 
		["pluginBtn"] = nil,
        ["checkSupport"] = function() return cc.exports.isFriendSupported() end,

		["isAvail"] = false,
        ["isAvailOnlyByCheckSupport"] = true,
		["isNeedReddot"] = false,
	},

    ["share"] = {
        ["itemName"] = "share",
		["nodeName"] = "Btn_Share",
		["belongedPanel"] = "panelMore",

		["pluginName"] = nil, 
		["pluginBtn"] = nil,
        ["checkSupport"] = function() return cc.exports.isShareSupported() end,

		["isAvail"] = false,
        ["isAvailOnlyByCheckSupport"] = true,
		["isNeedReddot"] = false,
	},

	--兑换码
	["giftexchange"] = {
        ["itemName"] = "giftexchange",
		["nodeName"] = "Btn_GiftExchange",
		["belongedPanel"] = "panelMore",

		["pluginName"] = nil, 
		["pluginBtn"] = nil,
        ["checkSupport"] = function() return cc.exports.isGiftExchangeSupported() end,

		["isAvail"] = false,
        ["isAvailOnlyByCheckSupport"] = true,
		["isNeedReddot"] = false,
	},

	['anchorLuckyBag'] = {
		["itemName"] = "anchorLuckyBag",
		["nodeName"] = "Button_AnchorLuckyBag",
		["belongedPanel"] = "panelTop",

		["pluginName"] = nil, 
		["pluginBtn"] = nil,
        ["checkSupport"] = function() return cc.exports.isAnchorLuckyBagSupported() end,

		["isAvail"] = false,
        ["isAvailOnlyByCheckSupport"] = true,
		["isNeedReddot"] = false,
	},

    --右上区域
    ["help"] = {
        ["itemName"] = "help",
		["nodeName"] = "Button_Help",
		["belongedPanel"] = "panelTop",

		["pluginName"] = nil, 
		["pluginBtn"] = nil,

		["isAvail"] = true,
        ["isAvailOnlyByCheckSupport"] = false,
		["isNeedReddot"] = false,
	},

    ["moregame"] = {
        ["itemName"] = "moregame",
		["nodeName"] = "Button_MoreGame",
		["belongedPanel"] = "panelTop",

		["pluginName"] = "MoreGameCtrl", 
		["pluginBtn"] = nil,
        ["checkSupport"] = function() return cc.exports.isGiftExchangeSupported() end,

		["isAvail"] = false,
        ["isAvailOnlyByCheckSupport"] = true,
		["isNeedReddot"] = false,
	},


    --其它
}

return pluginViewData
