
local PublicModule={}


cc.exports.hasStartGame = false            --been playing card
cc.exports.inTickoff    = false
cc.exports.sdkSession   = nil
cc.exports.isInHall=true
cc.exports.isAutogotoCharteredRoom=false
--cc.exports.isShowFirstRecharge=false
--cc.exports.isShowLimitTimeGift=false
cc.exports.isLimitTimeGift=false
cc.exports.limitTimeGiftInfo = {}
cc.exports.limitTimeGiftList = {}
cc.exports.limitTimeGiftConfig = {}
cc.exports.shopDespoit = 0 --当前充值金额
--cc.exports.isExchangeCenterOpen = true --兑换中心
cc.exports.isQuickStart = false --快速开始
cc.exports.inGame = false
cc.exports.hasLogined = false
cc.exports.needShowGuideComments = false
cc.exports.autoPopVivoPrivilegeStartUp = false
cc.exports.anchorWXShow = false
cc.exports.clipboardContent = ""
--cc.exports.isAutoEnterNewRoom=false
--cc.exports.fromType=0 --0:from chartered room query --1:from system find --2:from friend find
--cc.exports.isShowLoadingPanel=false

--cc.exports.isShareOpen = false
--cc.exports.isYuLeDaTingOpen = false
--[[cc.exports.moduleSwitches = {
    ["DWCSDKName"] = true --电玩城
}]]--

cc.exports.MonthCardInfo = {} --Global MonthCard Info
--cc.exports.uiConfig = require('src.app.HallConfig.AdditionConfig')
cc.exports.resConfig = require('src.app.HallConfig.ResConfig')
cc.exports.nScoreInfo = {}  --积分场的积分和奖励
cc.exports.nScoreInfoNeedResponse = -1 --当前正在查询积分场信息，等待回应中 -1 空闲 0 查询中 1 查到
cc.exports.CardMakerInfo = {}
cc.exports.ExpressionInfo = {}
cc.exports.globalData = { --保存一些全局的标志或数据
    ["lastDoReplaceAniSceneTime"] = -1
}
cc.exports.DataLinkCodeDef = require('src.app.BaseModule.DataLinkCodeDef')

local resConfig          = import('src.app.HallConfig.ResConfig')
local PluginConfig       = import('src.app.HallConfig.PluginConfig') or {}
local additionConfigCtrl = import('src.app.GameHall.config.AdditionConfigCtrl')

--一些工具类
cc.exports.UIHelper = import("src.app.common.component.UIHelper"):getInstance()
cc.exports.TimerManager = import("src.app.common.global.TimerManager"):getInstance()
cc.exports.MapOperator = import("src.app.common.global.MapOperator"):getInstance()
cc.exports.DateUtil = import("src.app.common.global.DateUtil"):getInstance()
cc.exports.CommonData = import("src.app.common.global.CommonData"):getInstance()
cc.exports.SubViewHelper = import("src.app.plugins.mainpanel.SubViewHelper"):getInstance()

--充值埋点begin
cc.exports.ReChargeType = {
    RECHARGE_TYPE_COMMON_PAY = 1,
    RECHARGE_TYPE_LIMIT_TIME_BAG = 2,
    RECHARGE_TYPE_FIRST_RECHARGE = 3,
    RECHARGE_TYPE_MONTH_CARD = 4,
}

cc.exports.ReChargeScene = {
    RECHARGE_SCENE_IN_HALL   = 1,       -- 大厅
    RECHARGE_SCENE_IN_LEVEL0 = 2,       -- 新手房
    RECHARGE_SCENE_IN_LEVEL1 = 3,       -- 初级房
    RECHARGE_SCENE_IN_LEVEL2 = 4,       -- 中级房
    RECHARGE_SCENE_IN_LEVEL3 = 5,       -- 高级房
    RECHARGE_SCENE_IN_SHUIHU = 6,       -- 水浒传
    RECHARGE_SCENE_IN_HALL_EX = 7,      -- 大厅弹窗
}
--限时礼包价格对应的类型
cc.exports.LimitTimeGiftType = {
    [1]      =  "0",
    [3]      =  "1",
    [6]      =  "2",
    [12]     =  "3",
    [28]     =  "4",
    [98]     =  "5"
}
cc.exports.LogReChargeData = {}         --充值操作时记录埋点数据，支付成功后回调里发送给chunksvr
--充值埋点end


--理牌埋点begin
cc.exports.LogSortCardData ={}
--理牌埋点end

--物品系统物品类型枚举
cc.exports.ItemType = {
    USERITEM = {
        100000000,
        200000000,
        100007000,
        100008000,
        100010000,
        100006001,
        100006002,
        100006003,
        100006004,
        100006005
    },                              --用户物品（道具）
    JF              = 100006000,    --积分
    MATCHTICKETS    = 100011000,    --比赛券
    VIRTUALITEM     = 100012000,    --用户虚拟物品
    SILVER          = 300001000,    --银子
    EXCHANGETICKETS = 300002000,    --礼券
    HAPPYCOIN       = 300003000,    --***
    REALITEM        = 400000000,    --实物
    MOBILEBILL      = 500000000,    --话费
    HAPPYCOINTIKET  = 300004002,    --***券
}

local json = cc.load("json").json
local AppJsonObj = nil

function cc.exports.GetButtonScale(button)
	local size   = button:getContentSize()
	local length = size.width+size.height
	local d      = 15+1.043*length-32/(1+length)
	local scale  = d/(1+length)
	return scale
end

function cc.exports.GetLoginExtra()
    local userID = plugin.AgentManager:getInstance():getUserPlugin():getUserID()
    local gameID = BusinessUtils:getInstance():getGameID()
    if userID and gameID and type(userID) == "string" and type(gameID) == "number" then
        local promoteCodeCache = CacheModel:getCacheByKey("PromoteCode_"..userID.."_"..gameID)
        if type(promoteCodeCache) == "number" then
            return "{\"Recommenderid\":\""..BusinessUtils:getInstance():getRecommenderId().."\""..", \"PromoteCode\":\""..promoteCodeCache.."\"}"
        end
    end    
	return "{\"Recommenderid\":\""..BusinessUtils:getInstance():getRecommenderId().."\"}"
end
function cc.exports.GetShopConfig()
    local ShopModel = mymodel("ShopModel"):getInstance()
    return ShopModel:GetShopConfig()
end

function cc.exports.IS_BIT_SET(flag, mybit)
    if not flag or not mybit then
        return false
    end
    return(mybit == bit.band(mybit, flag))
end

function cc.exports.getPayExtArgs(product)
	local strPayExtArgs = "{" 
	if cc.exports.LaunchMode["PLATFORM"] == MCAgent:getInstance():getLaunchMode() then
		if (cc.exports.GetShopConfig()['platform_app_client_id'] and cc.exports.GetShopConfig()['platform_app_client_id'] ~= "") then 
			strPayExtArgs = strPayExtArgs..string.format("\"platform_app_client_id\":\"%d\",", 
		  		cc.exports.GetShopConfig()['platform_app_client_id'])
		end
		if (cc.exports.GetShopConfig()['platform_cooperate_way_id'] and cc.exports.GetShopConfig()['platform_cooperate_way_id'] ~= "") then 
			strPayExtArgs = strPayExtArgs..string.format("\"platform_cooperate_way_id\":\"%d\",", 
		   		cc.exports.GetShopConfig()['platform_cooperate_way_id'])
		end
	else
		print("single app")
	end

    if product["First_Support"] == 1 then
        if product["fristpay_product_subject"] then
            strPayExtArgs = strPayExtArgs..string.format("\"product_subject\":\"%s\",", 
		        product["fristpay_product_subject"])
        end
        if product["fristpay_product_body"] then
            strPayExtArgs = strPayExtArgs..string.format("\"product_body\":\"%s\",", 
		        product["fristpay_product_body"])
        end
        if product["fristpay_app_currency_name"] then
            strPayExtArgs = strPayExtArgs..string.format("\"app_currency_name\":\"%s\",", 
		        product["fristpay_app_currency_name"])
	    end

        if product["fristpay_app_currency_rate"] then
            strPayExtArgs = strPayExtArgs..string.format("\"app_currency_rate\":\"%s\",", 
		        product["fristpay_app_currency_rate"])
        end
    else
        if product["product_subject"] then
            strPayExtArgs = strPayExtArgs..string.format("\"product_subject\":\"%s\",", 
		        product["product_subject"])
        end
        if product["product_body"] then
            strPayExtArgs = strPayExtArgs..string.format("\"product_body\":\"%s\",", 
	            product["product_body"])
	    end

        if product["app_currency_name"] then
	        strPayExtArgs = strPayExtArgs..string.format("\"app_currency_name\":\"%s\",", 
	    	    product["app_currency_name"])
	    end
        if product["app_currency_rate"] then
	        strPayExtArgs = strPayExtArgs..string.format("\"app_currency_rate\":\"%s\",", 
	    	    product["app_currency_rate"])
	    end
    end

    local userID = plugin.AgentManager:getInstance():getUserPlugin():getUserID()
    local gameID = BusinessUtils:getInstance():getGameID()
    if userID and gameID and type(userID) == "string" and type(gameID) == "number" then
        local promoteCodeCache = CacheModel:getCacheByKey("PromoteCode_"..userID.."_"..gameID)
        if type(promoteCodeCache) == "number" then
            strPayExtArgs = strPayExtArgs..string.format("\"promote_code\":\"%s\",", tostring(promoteCodeCache))
        end
    end

	if string.sub(strPayExtArgs, string.len(strPayExtArgs)) == "," then 
		strPayExtArgs = string.sub(strPayExtArgs, 1, string.len(strPayExtArgs) - 1)
	end

    if 1 == string.len(strPayExtArgs) then
        strPayExtArgs = ""
    else
	    strPayExtArgs = strPayExtArgs .. "}"
    end

	print("pay_ext_args:", strPayExtArgs)
	return strPayExtArgs
end

--[[function cc.exports.getHeadResPath(isGirl)
    if isGirl and isGirl ~=0 then
        printf("getHeadRes girl")
        return resConfig.girlhead
    end
    printf("getHeadRes boy")
    return resConfig.boyhead
end

--isGirl是boolean
function cc.exports.getPersonResPath(isGirl)
    if not isGirl then
        return resConfig.boypersoninfo
    end
    return resConfig.girlpersoninfo
end]]--

function cc.exports.safeDecoding(content)
    local jsonContent = nil
    my.mxpcall(function() jsonContent = json.decode(content) end, __G__TRACKBACK__)
    return jsonContent
end

--[[function cc.exports.getShopIconPath(icontype)
    local path
    if not icontype or icontype <= 0  or icontype > resConfig.shopiconcount then
        path = resConfig.shopicon.."1.png"
    else
        path = resConfig.shopicon ..icontype.. ".png"
    end
    return path
end]]--

--[[function cc.exports.getShopFirstRechargeLabel()
    return resConfig.shopfirstrechangelabel
end]]--

--商城代码有待优化 叶文
function cc.exports.LoadConfigs()
    ShopModel:LoadShopVersionConfig()
end

function cc.exports.QueryShopConfigUpdate()
    ShopModel:QueryShopConfigUpdate()
end

function cc.exports.LoadShopItemsConfig(bReadCache)
    local ShopModel = mymodel("ShopModel"):getInstance()
    ShopModel:LoadShopItemsConfig(bReadCache)
end

function cc.exports.GetShopItemsInfo()
    local ShopModel = mymodel("ShopModel"):getInstance()
	return ShopModel:GetShopItemsInfo()
end

function cc.exports.GetShopUIConfig()
    local ShopModel = mymodel("ShopModel"):getInstance()
    return ShopModel:GetShopUIConfig()
end

function cc.exports.GetFirstRechargeItem()
    local ShopModel = mymodel("ShopModel"):getInstance()
    return ShopModel:GetFirstRechargeItem()
end

function cc.exports.GetShopTipsConfig()
    local ShopModel = mymodel("ShopModel"):getInstance()
    return ShopModel:GetShopTipsConfig()
end

function cc.exports.DealPayResult(payResult)
    print("cc.exports.DealPayResult")
    if payResult == nil then
        print("payResult is nil")
        return
    end

    local QRCodePayModel = import('src.app.plugins.QRCodePay.QRCodePayModel'):getInstance()
    QRCodePayModel:dealPayResult(payResult)

    local goodsid = payResult['szGameGoodsID']
    local SilverGoodsID = { "11362", "11366", "11816", "11817", "11818", "11820", "11821", "11822", "11824", "11825", "11826" }
    local GoldGoodsID = { "11860", "11861", "11862", "11967", "11863", "11864", "11865", "11823", "11866", "11867", "11868", "11827" }

    local SilverGoodsIDCopy = { "17664", "17663", "17662", "17661", "17659", "17658", "17657", "17656", "17654", "17653", "17652", "17651" }
    local GoldGoodsIDCopy = { "17680", "17679", "17678", "17677", "17676", "17675", "17674", "17673", "17672", "17665", "17660", "17655"}
    
    local isBuySilverCup = false
    local isBuyGoldCup = false
    local isBuySilverCupCopy = false
    local isBuyGoldCupCopy = false
    for k,v in pairs(SilverGoodsID) do
        if goodsid == v then
            isBuySilverCup = true
            break
        end
    end
    for k,v in pairs(GoldGoodsID) do
        if goodsid == v then
            isBuyGoldCup = true
            break
        end
    end

    for k,v in pairs(SilverGoodsIDCopy) do
        if goodsid == v then
            isBuySilverCupCopy = true
            break
        end
    end
    for k,v in pairs(GoldGoodsIDCopy) do
        if goodsid == v then
            isBuyGoldCupCopy = true
            break
        end
    end

    if isBuySilverCup == true or isBuyGoldCup == true then
        local GoldSilverModel = import("src.app.plugins.goldsilver.GoldSilverModel"):getInstance()
        GoldSilverModel:DealPayResult(isBuySilverCup,isBuyGoldCup)
    elseif isBuySilverCupCopy == true or isBuyGoldCupCopy == true then
        local GoldSilverModelCopy = import("src.app.plugins.goldsilverCopy.GoldSilverModelCopy"):getInstance()
        GoldSilverModelCopy:DealPayResult(isBuySilverCupCopy,isBuyGoldCupCopy)
    else
        local ShopModel = mymodel("ShopModel"):getInstance()
	    ShopModel:DealPayResult(payResult)
    end
end

function cc.exports.DealPayVIPResult(payResult)
    local ShopModel = mymodel("ShopModel"):getInstance()
	ShopModel:DealPayVIPResult(payResult)
end

function cc.exports.SaveLastBuyItem(productrice, producttype, productnum, isfirstsupport)
    local ShopModel = mymodel("ShopModel"):getInstance()
	ShopModel:SaveLastBuyItem(productrice, producttype, productnum, isfirstsupport)
end

function cc.exports.GetLastBuyItem()
    local ShopModel = mymodel("ShopModel"):getInstance()
	return ShopModel:GetLastBuyItem()
end

function cc.exports.GetQuickBuyItem()
    local ShopModel = mymodel("ShopModel"):getInstance()
    return ShopModel:GetQuickBuyItem()
end

function cc.exports.SaveQuickBuyItem(id)
    local ShopModel = mymodel("ShopModel"):getInstance()
    return ShopModel:SaveQuickBuyItem(id)
end

function cc.exports.isIDinTabs(id)
    local ShopModel = mymodel("ShopModel"):getInstance()
    return ShopModel:isIDinTabs(id)
end

function cc.exports.isScoreLimit(limit)
    local ShopModel = mymodel("ShopModel"):getInstance()
    return ShopModel:isScoreLimit(limit)
end

--[[function cc.exports.GetPersonInfoGotoTab(index)
    local ShopModel = mymodel("ShopModel"):getInstance()
     return ShopModel:GetPersonInfoGotoTab(index)
end]]--






local FriendConfig = nil
local function loadFriendConfig()
	local json = cc.load("json").json
    local filePath = "FriendConfig.json"
    if cc.FileUtils:getInstance():isFileExist(filePath) then
	    local s = cc.FileUtils:getInstance():getStringFromFile(filePath)
        FriendConfig = json.decode(s)
    end
end

function cc.exports.IsSocialSupportted()
	if (FriendConfig == nil) then 
	    loadFriendConfig()
	end
    if FriendConfig then
	    return FriendConfig["support"] > 0
    else
        return false
    end
end

function cc.exports.DealSDKFind(sdkFind)

    printf("start DealSDKFind")

    cc.exports.isInviteBySDK = true
    my.scheduleOnce(function ()        
        local  tips = require('src.app.plugins.charteredroom.CharteredInviteTips').new()
        --cc.exports.fromType=2--2:from friend find
        tips:CreateViewNode(sdkFind)
    end,0.4)
end

--图片资源相关

function cc.exports.getHeadResPath(isGirl)
    print("cc.exports.getHeadResPath, isGirl "..tostring(isGirl))
    if isGirl == 0 or isGirl == false then
        printf("getHeadRes boy")
        return cc.exports.resConfig.boyhead
    else
        printf("getHeadRes girl")
        return cc.exports.resConfig.girlhead
    end
end

function cc.exports.getPersonResPath(isGirl)
    print("cc.exports.getPersonResPath, isGirl "..tostring(isGirl))
    if isGirl == 0 or isGirl == false then
        return cc.exports.resConfig.boypersoninfo
    else
        return cc.exports.resConfig.girlpersoninfo
    end
end


cc.exports.oneRoundGameWinData={} --没轮数据提示

cc.exports.gameProtectData={} --退出时提示的保护数据  reliefCount, reliefMoney, checkinMoney, lotteryCount, showLottery
cc.exports.reliefVipConfig = {} --会员低保配置，显示低保次数用
cc.exports.reliefConfig = {}
cc.exports.gameReliefData = {}

--等级数据
cc.exports._userLevelData={} --等级数据

function cc.exports.LevelResAndTextForData(level)
    local imageIndex = (level-1) % 4
    local ColorResName = "res/hall/hallpic/Game/GamePic/GameContents/PlayerInfo_LevelColor"..tostring(imageIndex)..".png"

    local textIndex = math.floor((level-1) / 4)
    local levelString = tostring(textIndex + 2)
    if textIndex == 9 then
        levelString = "J"
    elseif textIndex == 10 then
        levelString = "Q"
    elseif textIndex == 11 then
        levelString = "K"
    elseif textIndex == 12 then
        levelString = "A"
    end
    
    local BGIndex = 0
    if textIndex <= 2 then
        BGIndex = 0
    elseif textIndex <= 5 then
        BGIndex = 1
    elseif textIndex <= 8 then
        BGIndex = 2
    else
        BGIndex = 3
    end
    local BGResName = "res/hall/hallpic//GamePic/GameContents/PlayerInfo_LevelBG"..tostring(BGIndex)..".png"
    return BGResName, ColorResName, levelString
end

cc.exports._gameJsonConfig = {} --游戏服务配置

function  cc.exports.IsHejiPackage()
    if  MCAgent:getInstance().getLaunchSubMode and MCAgent:getInstance():getLaunchSubMode() == cc.exports.LaunchSubMode.PLATFORMSET then
        return true
    end

    -- 2018年7月31日 Android单包被要求使用合集包的购买配置
    if device.platform ~= "ios" and cc.exports.LaunchMode["ALONE"] == MCAgent:getInstance():getLaunchMode() then
        if device.platform == "windows" then
            return false
        end
        return true
    end

    return false
end

function  cc.exports.IsPackage_qh360()
    --360渠道特殊处理，用渠道的返回消息
    local userPlugin = plugin.AgentManager:getInstance():getUserPlugin()
    if userPlugin then
        local textSdkName = userPlugin:getUsingSDKName()
        if textSdkName == "qh360" then
            return  true
        end
    end
    return false
end

function  cc.exports.GetPlayerMinDeposit()
    local minDeposit = 10000 -- 2018年7月9日， 外更改最低携带银 10000两
    if 1 == DEBUG then
        minDeposit = 5000
    end
    if cc.exports._gameJsonConfig.playerMinDeposit then
        minDeposit = cc.exports._gameJsonConfig.playerMinDeposit.min
    end
    return minDeposit
end


-- 是否是安卓tcy
function cc.exports.isAndTCY()
    if DEBUG == 2 then
        return true
    end
    return  (not cc.exports.isIOS()) and cc.exports.LaunchMode["PLATFORM"] == MCAgent:getInstance():getLaunchMode()
end

--是否是安卓单包
function cc.exports.isALONE()
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if targetPlatform == cc.PLATFORM_OS_WINDOWS then 
        return true
    end

    return  (not cc.exports.isIOS()) and cc.exports.LaunchMode["ALONE"] == MCAgent:getInstance():getLaunchMode()
end

-- 是否是ios
function cc.exports.isIOS()
    if DEBUG == 3 or DEBUG == 4 then
        return true
    end
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    return targetPlatform == cc.PLATFORM_OS_IPHONE or targetPlatform == cc.PLATFORM_OS_IPAD
end

--是否是ios单包
function cc.exports.isIosALONE()
    if device.platform == "ios" and cc.exports.LaunchMode["ALONE"] == MCAgent:getInstance():getLaunchMode() then
        return true
    end
    return false

    --return true --测试代码
end

function cc.exports.string_split(s,p)
    local ret = {}
    string.gsub(s, '[^'..p..']+', function(w) table.insert(ret, w) end)
    return ret
end

function cc.exports.onCloseViewsForScene()
    local child = false
    local shop = cc.Director:getInstance():getRunningScene():getChildByName("ShopCtrl")
    if shop then
        child = true
        shop:removeFromParent()
        shop = nil
    end
    local limitTimeGift = cc.Director:getInstance():getRunningScene():getChildByName("LimitTimeGift")
    if limitTimeGift then
        child = true
        require("src.app.plugins.limitTimeGift.limitTimeGiftView"):onClose()
        limitTimeGift = nil
    end
    return child
end

function cc.exports.isOutlayGameSupported()
    if cc.exports.isYuLeDaTingOpen then
        return cc.exports.isYuLeDaTingOpen
    end
    return false
end

-- 银两不足，玩家获取房间底银的倍数
function cc.exports.getTakeDepositeMulti(roomID)
    local multiple = 2
    if cc.exports._gameJsonConfig and cc.exports._gameJsonConfig.roomTakeDepositeMuli then
        if type(cc.exports._gameJsonConfig.roomTakeDepositeMuli) == 'table' and
        cc.exports._gameJsonConfig.roomTakeDepositeMuli[tostring(roomID)] and
        toint(cc.exports._gameJsonConfig.roomTakeDepositeMuli[tostring(roomID)] > 0) then
            multiple = toint(cc.exports._gameJsonConfig.roomTakeDepositeMuli[tostring(roomID)])
        end
    end
    return multiple
end

-- 银两不足，玩家获取房间底银限制
function cc.exports.getTakeDepositeLimit(roomID, roomMinDeposit)
    local DefaultMultiple = 2
    local DepositeLimit = nil
    if cc.exports._gameJsonConfig and cc.exports._gameJsonConfig.roomTakeDepositeLimit then
        if type(cc.exports._gameJsonConfig.roomTakeDepositeLimit) == 'table' and
        cc.exports._gameJsonConfig.roomTakeDepositeLimit[tostring(roomID)] and
        toint(cc.exports._gameJsonConfig.roomTakeDepositeLimit[tostring(roomID)] > 0) then
            DepositeLimit = toint(cc.exports._gameJsonConfig.roomTakeDepositeLimit[tostring(roomID)])
        end
    end
    
    if DepositeLimit == nil then
        DepositeLimit = roomMinDeposit * DefaultMultiple
    end

    return DepositeLimit
end

function cc.exports.getInt64Val(highInt, lowUint)
    if highInt == nil or lowUint == nil then return 0 end

    local int64Val = 0;
    if bit._and(highInt, 0x80000000) > 0 then
        int64Val = -(bit._not(lowUint) + bit._not(highInt) * 4294967296.0 + 1)
    else
        int64Val = lowUint + highInt * 4294967296.0
    end

    return int64Val
end

function cc.exports.GetRoomConfig()
    local HallContext = import('src.app.plugins.mainpanel.HallContext'):getInstance()
    return HallContext.context["roomStrings"]
end

function cc.exports.parseGameVersion( version )
    local verTab = {}
    verTab = cc.exports.string_split(version,'.')

    local ma = 1
    local mi = 0
    local bu = 0
    if #verTab >= 3 then
        ma = verTab[1]
        mi = verTab[2]
        bu = verTab[3]
    end

    return ma,mi,bu
end

--[[KPI start]]
--获取KPI上报的数据
--[[function cc.exports.getKPIClientData()
    local clientData = my.getKPIClientData()
    local PublicInterface = cc.exports.PUBLIC_INTERFACE
    local playerInfo = PublicInterface.GetPlayerInfo()

    local gameVersion   = clientData.GameVers
    local splitArray    = string.split(gameVersion, ".")
    local majorVer          = 0
    local minorVer          = 0
    local buildno           = 0
    if #splitArray == 3 then
        majorVer        = tonumber(splitArray[1])
        minorVer        = tonumber(splitArray[2])
        buildno         = tonumber(splitArray[3])
    end

    local data  = {
        UserId  = playerInfo.nUserID,
        GameId  = clientData.GameId,
        GameCode = clientData.GameCode,
        ExeMajorVer = majorVer,
        ExeMinorVer = minorVer,
        ExeBuildno = buildno,
        RecomGameId = tonumber(clientData.RecomGameId),
        RecomGameCode = tonumber(clientData.RecomGameCode),
        GroupId = clientData.GroupId,
        Channel = clientData.Channel,
        HardId = clientData.HardId,
        MobileHardInfo = clientData.MobileHardInfo,
        PkgType = clientData.PkgType,
        CUID    = clientData.CUID
    }
    return data
end]]--

function cc.exports.getTodayDate()
    local timeNow=os.date('%Y_%m_%d',os.time())
    return timeNow
end

function cc.exports.scaleFrameSizeByHeight(viewNode, scalePer)
    local frameSize = cc.Director:getInstance():getOpenGLView():getFrameSize()
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    local scalY =visibleSize.height/frameSize.height
    local  ratio = frameSize.width/ frameSize.height
    if ratio>=1.85 and ratio<2 then --这个值大约估计，可能不满足一些机型
       local per = scalePer or 0.9
       viewNode:setScaleY(per)
       viewNode:setPositionY(viewNode:getPositionY())
    end
    if ratio >= 2 and  ratio < 2.1 then
       local per = scalePer or 0.85
       viewNode:setScaleY(per)
       viewNode:setPositionY(viewNode:getPositionY())
    end
    if ratio >= 2.1 then
       local per = scalePer or 0.8
       viewNode:setScale(per)
       viewNode:setPositionY(viewNode:getPositionY())
    end
end

-- param srcDateTime:20130908232828   interval:1   dateUnit: Day/Hour/Minute/Second
function cc.exports.getNewDate(srcDateTime,interval ,dateUnit)
    --从日期字符串中截取出年月日时分秒
    local Y = string.sub(srcDateTime,1,4)
    local M = string.sub(srcDateTime,5,6)
    local D = string.sub(srcDateTime,7,8)
    local H = string.sub(srcDateTime,9,10)
    local MM = string.sub(srcDateTime,11,12)
    local SS = string.sub(srcDateTime,13,14)

    --把日期时间字符串转换成对应的日期时间
    local dt1 = os.time{year=Y, month=M, day=D, hour=H,min=MM,sec=SS}
    --根据时间单位和偏移量得到具体的偏移数据
    local ofset=0
    if dateUnit =='Day' then
        ofset = 60 *60 * 24 * interval
    elseif dateUnit == 'Hour' then
        ofset = 60 *60 * interval
    elseif dateUnit == 'Minute' then
        ofset = 60 * interval
    elseif dateUnit == 'Second' then
        ofset = interval
    end

    --指定的时间+时间偏移量
    local newDate = os.date("%Y%m%d", dt1 + tonumber(ofset))
    local newTime = os.date("%Y%m%d%H%M%S", dt1 + tonumber(ofset))
    return newDate, newTime
end

function cc.exports.reverseTable(tab)
    local tmp = {}
    for i = 1, #tab do
	    local key = #tab
	    tmp[i] = table.remove(tab)
    end

    return tmp
end

--------------------------------------------------------------
local function pb_convert(tbl)
    if not tbl then return nil end
    local result = {}
    for k, v in pairs(tbl) do
        if type(v) ~= 'table' then
            result[k] = v
        else
            result[k] = pb_convert(v)
        end
    end
    return result
end

function cc.exports.pb_decode(packageName, data)
    if not packageName or not data then return nil end
    local res = protobuf.decode(packageName, data)
    if not res then return nil end
    protobuf.extract(res)
    return pb_convert(res)
end
--------------------------------------------------------------
function cc.exports.removeSchedule(id)
    if id then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(id)
    end
end

function cc.exports.createSchedule(f, delay)
    local id = cc.Director:getInstance():getScheduler():scheduleScriptFunc(f, delay or 0, false)
    return id
end

function cc.exports.createOnceSchedule(f, delay)
    local id = nil
    local function callfunc()
        cc.exports.removeSchedule(id)
        if f then
            f()
        end
    end
    id = cc.exports.createSchedule(callfunc, delay)
end

function cc.exports.checkBtnClickable()
    local lastclicktime = cc.exports.lastclicktime or 0
    local now = os.time()
    if now - lastclicktime < 2 then
        return false
    end
    cc.exports.lastclicktime = now
    return true
end

function cc.exports.convertFormat(v)
    if type(v) ~= 'table' then
        return nil
    end
    local shopItem={}
    shopItem["id"] = v["id"]
    if v["sid"] then
        shopItem["productid"] = v["sid"]
    else
        shopItem["productid"] = ""
    end

    shopItem["nofirstpay"] = v["nofirstpay"]

    shopItem["exchangeid"] = v["exchangeid"]
    shopItem["producttype"] = v["producttype"]

    --只有银子才有paytype
    if v["producttype"] == 1 then
        shopItem["paytype"] = v["paytype"]
    end
    
    shopItem["price"] = v["price"]
    shopItem["productnum"] =  v["productnum"]
    shopItem["limit"] =  v["limit"]
    shopItem["notetip"] =  v["notetip"]

    shopItem["page"] =  v["page"]
    shopItem["order"] =  v["order"]
    shopItem["icontype"] =  v["icontype"]
    shopItem["labeltype"] =  v["labeltype"]
    shopItem["title"] =  v["title"]
    shopItem["description"] =  v["description"]

    shopItem["productname"] =  v["productname"]
    shopItem["product_subject"] =  v["product_subject"]
    shopItem["product_body"] =  v["product_body"]
    shopItem["app_currency_name"] =  v["app_currency_name"]
    shopItem["app_currency_rate"] =  v["app_currency_rate"]

    shopItem["through_data"]=""

    local RewardToGame = 0
    if (v["producttype"] == 1) then
        RewardToGame = v["paytype"]
    else
        RewardToGame = 0
    end
    local ex = string.format("{\"RewardToGame\":%d,\"ExchangeId\":%d}",RewardToGame, v["exchangeid"])
    shopItem["through_data"] = ex

    return shopItem             
end

-- 新的获取设备id方法
function cc.exports.getDeviceID()
    local DeviceModel = mymodel('DeviceModel'):getInstance()
    local deviceID = string.format('%s%s%s', DeviceModel.szWifiID, DeviceModel.szImeiID, DeviceModel.szSystemID)
    if not (BusinessUtils:getInstance():isGameDebugMode()) then
        local analyticsPlugin = plugin.AgentManager:getInstance():getAnalyticsPlugin()
        if analyticsPlugin and analyticsPlugin.getDisdkDeviceInfo then
            local deviceinfo = analyticsPlugin:getDisdkDeviceInfo()
            local deviceinfoTbl = json.decode(deviceinfo)
            dump(deviceinfoTbl)
            if deviceinfoTbl.hardId and (deviceinfoTbl.hardId ~= "") then
                deviceID = deviceinfoTbl.hardId
            end
        end
    end

    return deviceID
end

-- 输出节点的纹理到本地
-- 参数: 需要绘制的节点 输出路径 图片格式 缩放参数
function cc.exports.outputNodeTexture(node, path, format, scale)
    scale = scale or cc.p(1, 1)
    local size = node:getContentSize()

    local lcoalPos = cc.p(node:getPosition())
    local parentNode = node:getParent()
    local worldPos = parentNode:convertToWorldSpace(lcoalPos)
    local winSize = cc.Director:getInstance():getWinSize()
    local outTexture = cc.RenderTexture:create(size.width, size.height)
    outTexture:setVirtualViewport(cc.p(worldPos.x, worldPos.y), cc.rect(0, 0, winSize.width, winSize.height), cc.rect(0, 0, winSize.width * scale.x, winSize.height * scale.y))
    outTexture:setKeepMatrix(true)
    outTexture:beginWithClear(0, 0, 0, 0, 0, 0)
    
    node:visit()
    
    outTexture:endToLua()
    outTexture:saveToFile(path, format or cc.IMAGE_FORMAT_PNG)
end