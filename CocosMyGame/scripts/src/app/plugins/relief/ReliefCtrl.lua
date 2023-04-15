local viewCreater					= import('src.app.plugins.relief.ReliefView')
local NobilityPrivilegeModel      	= import("src.app.plugins.NobilityPrivilege.NobilityPrivilegeModel"):getInstance()
local ShopModel 					= mymodel("ShopModel"):getInstance()
local ReliefCtrl 					= class('ReliefCtrl',cc.load('BaseCtrl'))
local relief						= mymodel('hallext.ReliefActivity'):getInstance()
local ReliefDef						= import('src.app.plugins.relief.ReliefDef')
local user							= mymodel('UserModel'):getInstance()
local SKGameDef     				= import("src.app.Game.mSKGame.SKGameDef")

ReliefCtrl.RUN_ENTERACTION 	= 	true       	-- 弹出时播放动画

function ReliefCtrl:onCreate(params)
	self._viewNode			= nil
	self._reliefCount		= 0
	self._nobilityLevel		= 0
	self._nobilityCount		= 0
	self._reliefSilver 		= 0
	self._buyExtraSilver 	= 0
	self._isLargePrice 		= false
	self._reliefShopID		= 0
	self._reliefShopItemData= nil
	self._reliefShopPrice  	= 0
	self._reliefExtra		= 0
	self._reliefShopID		= 0
	self._reliefShopID		= 0
	self._fromScene			= params.fromSence
	self._promtParentNode	= params.promptParentNode
	self._leftTime			= params.leftTime
	self._limit				= params.limit
	self._videoadRelief 	= params.VideoAdRelief
	self._bHasLog 			= false

	local viewNode=self:setViewIndexer(viewCreater:createViewIndexer())
	self._viewNode = viewNode

	local size = cc.Director:getInstance():getVisibleSize()
	viewNode:setPosition(cc.p(0 + (size.width - 1280) / 2, 0 + (size.height - 720) / 2))

	self:bindSomeDestroyButtons(viewNode,{'closeBt'})
	self:bindUserEventHandler(viewNode,{'takeBt','buyBt'})

	self:init()
end

function ReliefCtrl:init()

	if self._videoadRelief then
		self._reliefCount = relief:getVideoAdReliefLeftCount()
	else
		-- 获取低保每日赠送次数
		if cc.exports.gameReliefData then
			self._reliefCount = ((cc.exports.gameProtectData or {}).reliefDailyNum) or self._reliefCount
		end

		-- 获取贵族等级及赠送低保次数
		local status,reliefCount,level,levelCount,bVisible = NobilityPrivilegeModel:TakeNobilityPrivilegeReliefInfo()
		self._nobilityLevel = level
		self._nobilityCount = levelCount
		self._bNobilityVisible = bVisible
		if status and reliefCount > 0 then
			self._reliefCount = reliefCount
		end
	end

	-- 获取低保商品ID
	self._reliefShopID = cc.exports.getReliefShopItemIDValue()
	self._reliefShopItemData = clone(ShopModel:GetItemByID(self._reliefShopID))

	local exchangeID, price = self:getProductInfo()
	self._reliefShopItemData["Product_Name"] = "福利礼包充值"
	local through_data = string.format("{\"RewardToGame\":%d,\"ExchangeId\":%d}", 0, exchangeID)
	self._reliefShopItemData["through_data"] = through_data
	self._reliefShopItemData["price"] = price    --价格
	self._reliefShopItemData["exchangeid"] = exchangeID
	dump(self._reliefShopItemData, "ReliefCtrl:init _reliefShopItemData")

	self._reliefShopPrice = self._reliefShopItemData.price
	
	if self._videoadRelief then
		self._limit = relief:getVideoAdReliefLimitConfig()
		self._reliefSilver 	= self._limit.UpperLimit
	else
		self._limit = self._limit or ((relief or {}).config or {}).Limit
		-- 低保赠送银两
		if self._limit and self._limit.UpperLimit then
			self._reliefSilver 	= self._limit.UpperLimit
		else
			self._reliefSilver 	= cc.exports.getReliefSilverValue()
		end
	end

	-- 获取低保充值额外赠送银两
	local reliefLargePrice	= cc.exports.getReliefLargePriceValue()
	local reliefSmallPrice	= cc.exports.getReliefSmallPriceValue()
	local reliefLargeExtra	= cc.exports.getReliefLargeExtraValue()
	local reliefSmallExtra	= cc.exports.getReliefSmallExtraValue()
	local reliefSmallExtraHj= cc.exports.getReliefSmallHeJiExtraValue()
	if self._reliefShopPrice > reliefSmallPrice then
		self._buyExtraSilver 	= reliefLargeExtra
		self._isLargePrice 		= true
	else
		if cc.exports.IsHejiPackage() then
			self._buyExtraSilver 	= reliefSmallExtraHj
		else
			self._buyExtraSilver 	= reliefSmallExtra
		end

		self._isLargePrice 		= false
	end

	self:refreshInfo()

	if not self._bHasLog then
        local logData = relief:getGiftBagClickLogData(0, self._reliefShopPrice, true)
        my.dataLink(cc.exports.DataLinkCodeDef.GIFT_BAG_CLICK, logData) --礼包点击事件埋点

        self._bHasLog = true
    end
end

function ReliefCtrl:refreshInfo()
	self._viewNode:refreshInfo(self._videoadRelief, self._reliefCount, self._nobilityLevel, self._nobilityCount,self._bNobilityVisible, self._reliefShopPrice, self._reliefSilver, self._buyExtraSilver)
end

function ReliefCtrl:takeBtClicked(e)
	if self._videoadRelief then
		local AdvertModel = import('src.app.plugins.advert.AdvertModel'):getInstance()
		AdvertModel:ShowVideoAd(function (code, msg)
			if code == AdvertModel.AdSdkRetType.ADSDK_RET_AD_VIDEOCOMPLETE then
				relief:takeVideoAdRelief()
				self:removeSelfInstance()
			elseif code == AdvertModel.AdSdkRetType.ADSDK_RET_LOADAD_FAIL
				or code == AdvertModel.AdSdkRetType.ADSDK_RET_AD_NOT_SUPPORT
				or code == AdvertModel.AdSdkRetType.ADSDK_RET_AD_VIDEOPLAYERROR
				or code == AdvertModel.AdSdkRetType.ADSDK_RET_AD_DIMISS then
				my.informPluginByName({pluginName='ToastPlugin',params={tipString = '视频播放失败,请您稍后再试',removeTime=2}})
			elseif code ~= AdvertModel.AdSdkRetType.ADSDK_RET_LOADAD_SUCCESS
				and code ~= AdvertModel.AdSdkRetType.ADSDK_RET_LOADAD_SUCCESS
				and code ~= AdvertModel.AdSdkRetType.ADSDK_RET_SHOWAD_SUCCESS
				and code ~= AdvertModel.AdSdkRetType.ADSDK_RET_AD_CLICKED
				and code ~= AdvertModel.AdSdkRetType.ADSDK_RET_AD_CLOSED
				and code ~= AdvertModel.AdSdkRetType.ADSDK_RET_AD_VIDEOPLAY
				and code ~= AdvertModel.AdSdkRetType.ADSDK_RET_AD_VIDEOSTOP then
				my.informPluginByName({pluginName='ToastPlugin',params={tipString = '当前广告播放异常,请您稍后再试',removeTime=2}})
			end
		end)
	else
		if relief.state ~= 'SATISFIED' then
			my.informPluginByName({pluginName='ToastPlugin',params={tipString = '今日低保次数已用完~',removeTime=2}})
			self:removeSelfInstance()
			return
		end

		--贵族使用缓存
		local status,reliefCount = NobilityPrivilegeModel:TakeNobilityPrivilegeReliefInfo()
		local reliefUsedCount = tonumber(CacheModel:getCacheByKey("NobilityPrivilegeRelief"..user.nUserID..os.date('%Y%m%d',os.time())))
		if not reliefUsedCount then reliefUsedCount = 0 end
		if status and reliefUsedCount and reliefUsedCount >= reliefCount then   --当天升级使用低保超过了缓存，则返回
			my.informPluginByName({pluginName='ToastPlugin',params={tipString = '今日低保次数已用完~',removeTime=2}})
			self:removeSelfInstance()
			return
		end

		if self._fromScene == ReliefDef.FROM_SCENE_MAINCTRL then
			local MyGamePromptAllowances = import("src.app.Game.mMyGame.MyGamePromptAllowances")
			local prompt = MyGamePromptAllowances:create(self, self._leftTime, true, self._limit)
			if prompt then
				prompt:setName("Node_MyGamePromptAllowances")
				local mountNode = nil
				if  cc.exports.GamePublicInterface and cc.exports.GamePublicInterface._gameController then
					mountNode = cc.exports.GamePublicInterface._gameController._baseGameScene
					if mountNode:getChildByName("Node_MyGamePromptAllowances") then
						mountNode:getChildByName("Node_MyGamePromptAllowances"):removeFromParent()
					end
					mountNode:addChild(prompt, 1910)
				else
					mountNode = self._promtParentNode
					if mountNode:getChildByName("Node_MyGamePromptAllowances") then
						mountNode:getChildByName("Node_MyGamePromptAllowances"):removeFromParent()
					end
					mountNode:addChild(prompt, 100)
				end
				prompt:setPosition(display.center)
			end
			relief:takeRelief()
		elseif self._fromScene == ReliefDef.FROM_SCENE_GAMECONTROLLER or self._fromScene == ReliefDef.FROM_SCENE_GAMESCENE then
			local MyGamePromptAllowances = import("src.app.Game.mMyGame.MyGamePromptAllowances")
			local prompt = MyGamePromptAllowances:create(self._promtParentNode._gameController, self._leftTime, nil, self._limit)
			if prompt then
				self._promtParentNode:addChild(prompt, SKGameDef.SK_ZORDER_CUSTOM_PROMPT)
				prompt:setPosition(display.center)
			end
			relief:takeRelief()
		elseif self._fromScene == ReliefDef.FROM_SCENE_ROOMMANAGER then
			local MyGamePromptAllowances = import("src.app.Game.mMyGame.MyGamePromptAllowances")
			local prompt = MyGamePromptAllowances:create(self._promtParentNode, self._leftTime, true, self._limit)
			if prompt then
				prompt:setName("Node_GuideTipOfDepositUnSatisfied_OnEnterRoom")
				local targetScene =  display.getRunningScene()
				if targetScene then
					prompt:setLocalZOrder(100000)
					targetScene:addChild(prompt)
					prompt:setPosition(display.center)
				end
			end
			relief:takeRelief()
		else
			relief:takeRelief()
		end
	end
	self:removeSelfInstance()
end

function ReliefCtrl:buyBtClicked(e)
	-- 先领取低保
	if self._videoadRelief then
		relief:takeVideoAdRelief()
	else
		relief:takeRelief()
	end
	
	local ActId = require("src.app.HallConfig.ActivitysConfig").BuyReliefId
	if device.platform == 'ios' then
		ActId = require("src.app.HallConfig.ActivitysConfig").BuyReliefIdIOS
	elseif cc.exports.IsHejiPackage() then
		ActId = require("src.app.HallConfig.ActivitysConfig").BuyReliefIdHeji
	end

	-- 调用充值入口进行充值
	local extraParams = {}
    local shopconfig = ShopModel:GetShopTipsConfig()
    if shopconfig then
        extraParams["Pay_Title"]    = shopconfig["RechargeNeeded_Title"]
		extraParams["Pay_Content"]  = shopconfig["RechargeNeeded_Content"]
		local device = mymodel('DeviceModel'):getInstance()
		local szWifiID,szImeiID,szSystemID=device.szWifiID,device.szImeiID,device.szSystemID
		local deviceId=string.format('%s,%s,%s',szWifiID,szImeiID,szSystemID)
		
		if self._reliefShopItemData.through_data then
			local oldThroughData = self._reliefShopItemData["through_data"]
			local newThroughData = string.gsub(oldThroughData, "}", ",\"ActId\":".. ActId .. ",\"DeviceId\":\""..deviceId.."\"}")
			print("xxxxxxxxxxxxxxxx newThroughData", newThroughData)
			self._reliefShopItemData["through_data"] = newThroughData
		else
			self._reliefShopItemData["through_data"] = "{\"ActId\":"..ActId.."}"
		end

		local logData = relief:getGiftBagClickLogData(0, self._reliefShopPrice, false)
		local function ReliefPayCallBack(code, msg)
			printInfo("%d", code)
			printInfo("%s", msg)
			printf("ReliefPay.paycallback_working")
		
			if code == PayResultCode.kPaySuccess then
				printf("ReliefPay.kPaySuccess")
				if type(logData) == "table" then
					logData.PayStatus = 1
					local user = mymodel('UserModel'):getInstance()
					logData.NowDeposit = user.nDeposit
				end
			else
				if string.len(msg) ~=0 then
					my.informPluginByName({pluginName='TipPlugin',params={tipString=msg,removeTime=1}})
				end
				
				if code == PayResultCode.kPayFail then
					printf("ReliefPay.BuyFailed")
				elseif code == PayResultCode.kPayTimeOut then
					printf("ReliefPay.Timeout")
				elseif code == PayResultCode.kPayProductionInforIncomplete then
					printf("ReliefPay.Infoincomplete")
				end
			end
			my.dataLink(cc.exports.DataLinkCodeDef.GIFT_BAG_CLICK, logData) --礼包点击事件埋点
		end
		dump(self._reliefShopItemData, "ReliefCtrl:buyBtClicked _reliefShopItemData")
		dump(self.extraParams, "ReliefCtrl:buyBtClicked extraParams")
		mymodel("PayModel"):getInstance():payForProduct(self._reliefShopItemData, ReliefPayCallBack, extraParams, self._buyExtraSilver)
		if device.platform == "windows" then
			mymodel("PayModel"):getInstance():payCallback(PayResultCode.kPaySuccess, msg)
        	mymodel("PayModel"):getInstance()._shopCallback(PayResultCode.kPaySuccess, msg)
		end
	end

	self:removeSelfInstance()
end

function ReliefCtrl:getProductInfo()
	if device.platform == 'ios' then
		return getReliefLargeExchangeID(), getReliefLargePriceValue()
	end

	local platFormType = 1
    if MCAgent:getInstance().getLaunchSubMode and MCAgent:getInstance():getLaunchSubMode() == 1 then
        platFormType = 2
    elseif cc.exports.LaunchMode["PLATFORM"] == MCAgent:getInstance():getLaunchMode() then
        if device.platform == 'ios' then
            platFormType = 3
        else
            platFormType = 1
        end
	end
	
	local info = {
		{12965,2},
		{12958,2},
		{12951,6},
	}
	return info[platFormType][1], info[platFormType][2]
end

return ReliefCtrl
