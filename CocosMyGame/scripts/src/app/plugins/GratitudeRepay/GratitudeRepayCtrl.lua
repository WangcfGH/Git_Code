local GratitudeRepayCtrl = class('GratitudeRepayCtrl', cc.load('SceneCtrl'))
local viewCreater = import('src.app.plugins.GratitudeRepay.GratitudeRepayView')
local GratitudeRepayModel = require('src.app.plugins.GratitudeRepay.GratitudeRepayModel'):getInstance()
local GratitudeRepayDef = require('src.app.plugins.GratitudeRepay.GratitudeRepayDef')
local json = cc.load("json").json
local DeviceModel = require("src.app.GameHall.models.DeviceModel"):getInstance()
local RewardTipDef = import("src.app.plugins.RewardTip.RewardTipDef")
local RichText = require("src.app.mycommon.myrichtext.MyRichText")

-- 创建实例
function GratitudeRepayCtrl:onCreate( ... )
    local viewNode = self:setViewIndexer(viewCreater:createViewIndexer())

    local params = {...}

    self:initialListenTo()
    self:updateUI()
    self:palyEnterAni()
    self:initialBtnClick()

    GratitudeRepayModel:reqGratitudeRepayConfig()
    GratitudeRepayModel:QueryGratitudeRepayInfo()
end

-- 注册监听
function GratitudeRepayCtrl:initialListenTo()
    self:listenTo(GratitudeRepayModel, GratitudeRepayDef.GRATITUDE_REPAY_QUERY_CONFIG_RSP, handler(self,self.updateUI))
    self:listenTo(GratitudeRepayModel, GratitudeRepayDef.GRATITUDE_REPAY_QUERY_INFO_RSP, handler(self,self.updateUI))
    self:listenTo(GratitudeRepayModel, GratitudeRepayDef.GRATITUDE_REPAY_PAY_SUCCEED, handler(self,self.lotterySuccess))
end

-- 刷新界面
function GratitudeRepayCtrl:updateUI()    
    if self._viewNode == nil then return end
    local viewNode = self._viewNode

    local config = GratitudeRepayModel:getConfig()
    local info = GratitudeRepayModel:getInfo()
    local playMultBtnAni = true

    if not config or not info then return end

    if not GratitudeRepayModel:isOpen() then
        self:onClose()
    else
        local todayItemInfo = GratitudeRepayModel:todayItemInfo()
        if not todayItemInfo then return end
    
        for i=1, GratitudeRepayDef.LOTTERY_GIVE_ITEM_COUNT do
            local giveSliver = todayItemInfo.GiveItems[i].SliverNum
            local baseSliver = todayItemInfo.BaseSliver
            local giveRatio = math.ceil((giveSliver / baseSliver) * 100)
            viewNode["imgSelect"..i]:setVisible(false)
            viewNode["txtRatioValue"..i]:setString(string.format("多送%d%s", giveRatio, "%"))
            viewNode["txtSliver"..i]:setString(string.format("%d两", todayItemInfo.GiveItems[i].SliverNum))
        end
    
        viewNode.txtBaseSliver:setString(string.format( "X%d两X", todayItemInfo.BaseSliver))
        viewNode.txtOpenDate:setString(string.format( "%s", config.OpenDate))    
        --显示概率按钮问号
        viewNode.helpBt:setVisible(true)

        viewNode.btnLotteryOneOnly:setTouchEnabled(true)
        viewNode.btnLotteryOneOnly:setBright(true)
        viewNode.btnLotteryOne:setTouchEnabled(true)
        viewNode.btnLotteryOne:setBright(true)
        viewNode.btnLotteryMult:setTouchEnabled(true)
        viewNode.btnLotteryMult:setBright(true)
        viewNode.txtRemainCount:setVisible(false)
        if config.LotteryCount >= 0 then
            if info.remainCount > 0 and info.remainCount < config.MultipleNum then
                viewNode.btnLotteryOneOnly:setTouchEnabled(true)
                viewNode.btnLotteryOneOnly:setBright(true)
                viewNode.btnLotteryOne:setTouchEnabled(true)
                viewNode.btnLotteryOne:setBright(true)
                viewNode.btnLotteryMult:setTouchEnabled(false)
                viewNode.btnLotteryMult:setBright(false)
                playMultBtnAni = false
            elseif info.remainCount <= 0 then
                viewNode.btnLotteryOneOnly:setTouchEnabled(false)
                viewNode.btnLotteryOneOnly:setBright(false)
                viewNode.btnLotteryOne:setTouchEnabled(false)
                viewNode.btnLotteryOne:setBright(false)
                viewNode.btnLotteryMult:setTouchEnabled(false)
                viewNode.btnLotteryMult:setBright(false)
                playMultBtnAni = false
            end
    
            viewNode.txtRemainCount:setVisible(true)
            viewNode.txtRemainCount:setString(string.format( "今日剩余可抽取 %d/%d", info.remainCount, config.LotteryCount))
            if info.remainCount < 0 then
                viewNode.txtRemainCount:setString(string.format( "今日剩余可抽取 0/%d", config.LotteryCount))
            end        
        end
    
        viewNode.txtLotteryOneOnly:setString(string.format( "￥%d元", todayItemInfo.OnePrice))
        viewNode.txtLotteryOne:setString(string.format( "￥%d元", todayItemInfo.OnePrice))
        viewNode.txtLotteryMult:setString(string.format( "￥%d元", todayItemInfo.MultPrice))
    
        if config.MultipleLotteryEnable == 0 then
            viewNode.btnLotteryOneOnly:setVisible(true)
            viewNode.btnLotteryOne:setVisible(false)
            viewNode.btnLotteryMult:setVisible(false)
            playMultBtnAni = false
        else
            viewNode.btnLotteryOneOnly:setVisible(false)
            viewNode.btnLotteryOne:setVisible(true)
            viewNode.btnLotteryMult:setVisible(true)
        end

        if playMultBtnAni then
            self:palyMultBtnAni()
        else
            self:stopMultBtnAni()
        end
    end
end

-- 播放进入动画
function GratitudeRepayCtrl:palyEnterAni()
    if self._viewNode == nil or self._viewNode.titleAniNode == nil or self._viewNode.openDateAniNode == nil or self._viewNode.enterAniNode == nil then return end

    local aniFileBt = "res/hallcocosstudio/GratitudeRepay/gd_ganenhuikui_biaoti.csb"
    local aniNodeBt = self._viewNode.titleAniNode
    aniNodeBt:stopAllActions()
    local actionBt = cc.CSLoader:createTimeline(aniFileBt)
    if not tolua.isnull(actionBt) then
        aniNodeBt:runAction(actionBt)
        actionBt:play("TitleAni", true)
    end

    local aniFileQp = "res/hallcocosstudio/GratitudeRepay/gd_ganenhuikui_qipao.csb"
    local aniNodeQp = self._viewNode.openDateAniNode
    aniNodeQp:stopAllActions()
    local actionQp = cc.CSLoader:createTimeline(aniFileQp)
    if not tolua.isnull(actionQp) then
        aniNodeQp:runAction(actionQp)
        actionQp:play("OpenDateEnterAni", false)
    end

    local aniFileCd = "res/hallcocosstudio/GratitudeRepay/gd_ganenhuikui_caidai.csb"
    local aniNodeCd = self._viewNode.enterAniNode
    aniNodeCd:stopAllActions()
    local actionCd = cc.CSLoader:createTimeline(aniFileCd)
    if not tolua.isnull(actionCd) then
        aniNodeCd:runAction(actionCd)
        actionCd:play("EnterStayAni", true)
    end

    if self._viewNode.enterSpineNode then
        local nodeName = "gratitudeRepaySkeletonAni"
        local skeletonJson = 'res/hallcocosstudio/GratitudeRepay/spineAni/ganen_pai.json'
        local skeletonAtlas = "res/hallcocosstudio/GratitudeRepay/spineAni/ganen_pai.atlas"
		local nodeAni = sp.SkeletonAnimation:create(skeletonJson, skeletonAtlas, 1.0)  
		nodeAni:setAnimation(0, "ganen_pai", true)
		nodeAni:setDebugBonesEnabled(false)
		nodeAni:setName(nodeName)
		self._viewNode.enterSpineNode:addChild(nodeAni)
	end
end

-- 播放抽N次动画
function GratitudeRepayCtrl:palyMultBtnAni()
    if self._viewNode == nil or self._viewNode.btnMultAni == nil then return end

    self._viewNode.btnMultAni:setVisible(true)
    
    local aniFileAn = "res/hallcocosstudio/GratitudeRepay/gd_ganenhuikui_anniu.csb"
    local aniNodeAn = self._viewNode.btnMultAni
    aniNodeAn:stopAllActions()
    local actionAn = cc.CSLoader:createTimeline(aniFileAn)
    if not tolua.isnull(actionAn) then
        aniNodeAn:runAction(actionAn)
        actionAn:play("MultBtnAni", true)
    end
end

-- 停止播放抽N次动画
function GratitudeRepayCtrl:stopMultBtnAni()
    if self._viewNode == nil or self._viewNode.btnMultAni == nil then return end

    local aniNodeAn = self._viewNode.btnMultAni
    aniNodeAn:stopAllActions()

    self._viewNode.btnMultAni:setVisible(false)
end

-- 抽奖成功界面
function GratitudeRepayCtrl:lotterySuccess()
    if self._viewNode == nil then return end
    local viewNode = self._viewNode  
    
    local config = GratitudeRepayModel:getConfig()
    local info = GratitudeRepayModel:getInfo()
    local lotterySuccessInfo = GratitudeRepayModel:getLotterySuccessInfo()

    if not config or not info or not lotterySuccessInfo then return end

    local todayItemInfo = GratitudeRepayModel:todayItemInfo()
    if not todayItemInfo then return end    

    self:updateUI()    

    local giveItemIndex = lotterySuccessInfo.giveItemIndex + 1
    self:playLotterySuccessAnimation(giveItemIndex)

    local rewardList    = {}
    table.insert(rewardList, {nType = RewardTipDef.TYPE_SILVER, nCount = lotterySuccessInfo.baseSliver})
    for i=1, #lotterySuccessInfo.giveSliver do
        table.insert(rewardList, {nType = RewardTipDef.TYPE_SILVER, nCount = lotterySuccessInfo.giveSliver[i]})
    end
    my.informPluginByName({pluginName = 'RewardTipCtrl', params = {data = rewardList, showOkOnly = true, lotteryCount = lotterySuccessInfo.lotteryCount}})
end

-- 注册点击事件
function GratitudeRepayCtrl:initialBtnClick()
    if self._viewNode == nil then return end    
    local viewNode = self._viewNode

    viewNode.btnClose:addClickEventListener(function() 
        local PluginProcessModel = mymodel('hallext.PluginProcessModel'):getInstance()
        PluginProcessModel:PopNextPlugin()
        self:onClose()
    end)
    viewNode.btnLotteryOneOnly:addClickEventListener(handler(self, self.onLotteryOneBtnClick))
    viewNode.btnLotteryOne:addClickEventListener(handler(self, self.onLotteryOneBtnClick))
    viewNode.btnLotteryMult:addClickEventListener(handler(self, self.onLotteryMultBtnClick))
    --绑定事件 点击按钮问号，实例化GratitudeRepayRuleCtrl
    viewNode.helpBt:addClickEventListener(handler(self, self.onHelp))
end

--实例化显示界面
function GratitudeRepayCtrl:onHelp()
    my.informPluginByName({pluginName = "GratitudeRepayRuleCtrl"})
end

-- 按钮点击延时
function GratitudeRepayCtrl:isInBtnClickGap()
    local GAP_SCHEDULE = 2 --间隔时间2秒
    local nowTime = os.time()
    self._lastBtnTime = self._lastBtnTime or 0
    if nowTime - self._lastBtnTime > GAP_SCHEDULE then
        self._lastBtnTime = nowTime
    else
        my.informPluginByName({pluginName = 'TipPlugin',params = {tipString = "点击太频繁，请2秒后再操作", removeTime = 3}})
        return true
    end

    return false
end

-- 点击抽一次按钮
function GratitudeRepayCtrl:onLotteryOneBtnClick()
    if self:isInBtnClickGap() then return end

    my.playClickBtnSound()
    local config = GratitudeRepayModel:getConfig()
    local info = GratitudeRepayModel:getInfo()

    if not config or not info then return end

    local todayItemInfo = GratitudeRepayModel:todayItemInfo()
    if not todayItemInfo then return end

    self:updateUI()
    for i=1, GratitudeRepayDef.LOTTERY_GIVE_ITEM_COUNT do
        self:stopLotterySuccessAnimation(i)
    end
    self:payForProduct(todayItemInfo.OneExchangeID, todayItemInfo.OnePrice) 
end

-- 点击抽N次按钮
function GratitudeRepayCtrl:onLotteryMultBtnClick()
    if self:isInBtnClickGap() then return end

    my.playClickBtnSound()

    local config = GratitudeRepayModel:getConfig()
    local info = GratitudeRepayModel:getInfo()

    if not config or not info then return end

    local todayItemInfo = GratitudeRepayModel:todayItemInfo()
    if not todayItemInfo then return end

    self:updateUI()
    for i=1, GratitudeRepayDef.LOTTERY_GIVE_ITEM_COUNT do
        self:stopLotterySuccessAnimation(i)
    end
    self:payForProduct(todayItemInfo.MultExchangeID, todayItemInfo.MultPrice) 
end

-- 播放抽取成功动画
function GratitudeRepayCtrl:playLotterySuccessAnimation(giveItemIndex)
    if self._viewNode == nil then return end    
    local viewNode = self._viewNode

    local aniFileHb = "res/hallcocosstudio/GratitudeRepay/gd_ganenhuikui_xuanzhong.csb"
    local aniNodeHb = viewNode["itemAniNode"..giveItemIndex]
    aniNodeHb:setVisible(true)
    aniNodeHb:stopAllActions()
    local actionHb = cc.CSLoader:createTimeline(aniFileHb)
    if not tolua.isnull(actionHb) then
        aniNodeHb:runAction(actionHb)
        actionHb:play("ItemSelectAni", true)
    end
end

-- 停止抽取成功动画
function GratitudeRepayCtrl:stopLotterySuccessAnimation(giveItemIndex)
    if self._viewNode == nil then return end    
    local viewNode = self._viewNode

    local aniNodeHb = viewNode["itemAniNode"..giveItemIndex]
    aniNodeHb:setVisible(false)
    aniNodeHb:stopAllActions()
end

-- 获取包类型
function GratitudeRepayCtrl:AppType()
    local type = GratitudeRepayDef.GRATITUDE_REPAY_APPTYPE_AN_TCY
    if device.platform == 'android' then
        if MCAgent:getInstance().getLaunchSubMode and MCAgent:getInstance().getLaunchMode then
            local launchMode = MCAgent:getInstance():getLaunchMode()
            local launchSubMode = MCAgent:getInstance():getLaunchSubMode()
            if launchSubMode == cc.exports.LaunchSubMode.PLATFORMSET then
                type = GratitudeRepayDef.GRATITUDE_REPAY_APPTYPE_AN_SET
            elseif launchMode == cc.exports.LaunchMode.PLATFORM then
                type = GratitudeRepayDef.GRATITUDE_REPAY_APPTYPE_AN_TCY
            else
                type = GratitudeRepayDef.GRATITUDE_REPAY_APPTYPE_AN_SINGLE
            end
        elseif MCAgent:getInstance().getLaunchMode then
            local launchMode = MCAgent:getInstance():getLaunchMode()
            if launchMode == cc.exports.LaunchMode.PLATFORM then
                type = GratitudeRepayDef.GRATITUDE_REPAY_APPTYPE_AN_TCY
            else
                type = GratitudeRepayDef.GRATITUDE_REPAY_APPTYPE_AN_SINGLE
            end
        else 
            type = GratitudeRepayDef.GRATITUDE_REPAY_APPTYPE_AN_TCY
        end
    elseif device.platform == 'ios' then
        local launchMode = MCAgent:getInstance():getLaunchMode()
        if launchMode == cc.exports.LaunchMode.PLATFORM then
            type = GratitudeRepayDef.GRATITUDE_REPAY_APPTYPE_IOS_TCY
        else
            type = GratitudeRepayDef.GRATITUDE_REPAY_APPTYPE_IOS_SINGLE
        end
    else
        --other os
    end

    return type
end

function GratitudeRepayCtrl:payForProduct(excahngeID, price)
    if self._waitingPayResult then 
        my.informPluginByName({pluginName='TipPlugin',params={tipString="操作太频繁，请稍后再试！",removeTime=2}})
        return 
    end
    local Def = GratitudeRepayDef
 
    local szWifiID, szImeiID, szSystemID = DeviceModel.szWifiID, DeviceModel.szImeiID, DeviceModel.szSystemID
    local deviceId = string.format('%s,%s,%s',szWifiID,szImeiID,szSystemID)

    local function getPayExtArgs()
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
            print("WeekMonthSuperCardCtrl single app")
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

        print("WeekMonthSuperCardCtrl pay_ext_args:", strPayExtArgs)
        return strPayExtArgs        
    end

    local paymodel = mymodel("PayModel"):getInstance()
    local param = clone(paymodel:getPayMetaTable())

    param["Product_Name"] = "感恩大回馈礼包"

    param["Product_Id"] = ""  --sid
    
    local apptype = self:AppType()
    print("----------------------------------apptype = ",apptype)

    local price,exchangeid = price, excahngeID
    print("------ price and exchangeid:",price,exchangeid)
    if apptype == Def.GRATITUDE_REPAY_APPTYPE_AN_TCY then
        print("GRATITUDE_REPAY_APPTYPE_AN_TCY")
    elseif apptype == Def.GRATITUDE_REPAY_APPTYPE_AN_SINGLE then
        print("GRATITUDE_REPAY_APPTYPE_AN_SINGLE")
    elseif apptype == Def.GRATITUDE_REPAY_APPTYPE_AN_SET then
        print("GRATITUDE_REPAY_APPTYPE_AN_SET")
        param["Product_Id"] = "com.uc108.mobile.gamecenter.tongbao" .. price
    elseif apptype == Def.GRATITUDE_REPAY_APPTYPE_IOS_TCY then
        print("GRATITUDE_REPAY_APPTYPE_IOS_TCY")
        param["Product_Id"] = "com.uc108.mobile.gamecenter.tongbao" .. price
    elseif apptype == Def.GRATITUDE_REPAY_APPTYPE_IOS_SINGLE then
        print("GRATITUDE_REPAY_APPTYPE_IOS_SINGLE")
        param["Product_Id"] = "com.uc108.mobile.hagd.deposit6.add45000"
    end

    --local through_data = string.format("{\"GameCode\":\"%s\",\"DeviceId\":\"%s\",\"RewardToGame\":%d,\"ExchangeId\":%d}", gamecode, deviceId, 0, exchangeid)
    local through_data = string.format("{\"RewardToGame\":%d,\"ExchangeId\":%d}", 0, exchangeid)

    param["pay_point_num"]  = 0
    param["Product_Price"] = tostring(price)     --价格
    param["Exchange_Id"]  = tostring(1)      --物品ID  1是银子 2是会员 3是积分 4是钻石
    param["through_data"] = through_data;
    param["ext_args"] = getPayExtArgs();
    
    local kpiData = my.getKPIClientData()
    param["RecomGameId"]   = tostring(kpiData.RecomGameId)
    param["RecomGameCode"] = kpiData.RecomGameCode
    param["RecomGameVers"] = ""

    if device.platform == 'windows' or cc.exports.isHSoxRaySupported() then
        print("To Create ActivityRechargeHSoxCtrl")
        dump(param, "WeekMonthSuperCardCtrl:payForProduct param")
        my.informPluginByName({pluginName='ActivityRechargeHSoxCtrl',params = param})
        self._waitingPayResult = true
        my.scheduleOnce(function()
            self._waitingPayResult = false
        end,3)
    else
        local iapPlugin = plugin.AgentManager:getInstance():getIAPPlugin()
        local function payCallBack(code, msg)
            my.scheduleOnce(function()
                self._waitingPayResult = false
            end,3)
            if code == PayResultCode.kPaySuccess then

            else
                if string.len(msg) ~= 0 then
                    my.informPluginByName({pluginName='TipPlugin',params={tipString=msg,removeTime=2}})
                end
                if( code == PayResultCode.kPayFail )then

                elseif( code == PayResultCode.kPayTimeOut )then

                elseif( code == PayResultCode.kPayProductionInforIncomplete )then

                end
            end
        end
        iapPlugin:setCallback(payCallBack)
        dump(param, "GratitudeRepayCtrl:payForProduct param")
        iapPlugin:payForProduct(param)
        self._waitingPayResult = true
    end
end

function GratitudeRepayCtrl:onClose( )
    printf("GratitudeRepayCtrl onClose")
    self:playEffectOnPress()
    my.scheduleOnce(function()
        if(self:informPluginByName(nil,nil))then
            self:removeSelfInstance()
        end
    end)
end

function GratitudeRepayCtrl:goBack()
    if type(self._callback) == 'function' then
        self._callback()
    end
    GratitudeRepayCtrl.super.removeSelf(self)
end

return GratitudeRepayCtrl