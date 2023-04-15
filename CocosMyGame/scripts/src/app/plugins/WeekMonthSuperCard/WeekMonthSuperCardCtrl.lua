local WeekMonthSuperCardCtrl    = class('WeekMonthSuperCardCtrl', cc.load('SceneCtrl'))
local viewCreater               = import('src.app.plugins.WeekMonthSuperCard.WeekMonthSuperCardView')
local WeekMonthSuperCardModel   = import('src.app.plugins.WeekMonthSuperCard.WeekMonthSuperCardModel'):getInstance()
local WeekMonthSuperCardDef     = require('src.app.plugins.WeekMonthSuperCard.WeekMonthSuperCardDef')
local json                      = cc.load("json").json
local DeviceModel               = require("src.app.GameHall.models.DeviceModel"):getInstance()

function WeekMonthSuperCardCtrl:onCreate( ... )
    local viewNode = self:setViewIndexer(viewCreater:createViewIndexer())

    local params = {...}    

    self:initialListenTo()
    self:initialBtnClick()
    self:playBgAni()
    self:updateUI()    

    WeekMonthSuperCardModel:QueryWeekMonthSuperCardConfig()
    WeekMonthSuperCardModel:QueryWeekMonthSuperCardInfo()
end

function WeekMonthSuperCardCtrl:initialListenTo( )
    self:listenTo(WeekMonthSuperCardModel, WeekMonthSuperCardDef.WEEK_MONTH_SUPER_CARD_QUERY_CONFIG_RSP, handler(self,self.updateUI))
    self:listenTo(WeekMonthSuperCardModel, WeekMonthSuperCardDef.WEEK_MONTH_SUPER_CARD_QUERY_INFO_RSP, handler(self,self.updateUI))
    self:listenTo(WeekMonthSuperCardModel, WeekMonthSuperCardDef.WEEK_MONTH_SUPER_CARD_TAKE_AWARD_RSP, handler(self,self.updateUI))
    self:listenTo(WeekMonthSuperCardModel, WeekMonthSuperCardDef.WEEK_MONTH_SUPER_CARD_PAY_PAY_SUCCEED, handler(self,self.updateUI))
end

function WeekMonthSuperCardCtrl:initialBtnClick()
    self._viewNode.btnWeekBuy:addClickEventListener(function(sender, eventType) 
        self:onClickWeekBtn()
    end)

    self._viewNode.btnMonthBuy:addClickEventListener(function(sender, eventType) 
        self:onClickMonthBtn()
    end)

    self._viewNode.btnSuperBuy:addClickEventListener(function() 
        self:onClickSuperBtn()
    end)

    self._viewNode.btnClose:addClickEventListener(function() 
        local PluginProcessModel = mymodel('hallext.PluginProcessModel'):getInstance()
        PluginProcessModel:PopNextPlugin()
        self:onClose()
    end)
end

function WeekMonthSuperCardCtrl:onClickWeekBtn()
    if self:isInWeekBtnClickGap() then return end

    my.playClickBtnSound()
    
    local config    = WeekMonthSuperCardModel:getConfig()
    local info      = WeekMonthSuperCardModel:getInfo()

    if not config or not info then return end

    if info.weekCardStatus == WeekMonthSuperCardDef.WEEK_MONTH_SUPER_CARD_NOT_BUY then
        local exchangeID = WeekMonthSuperCardModel:getCardExchangeID(WeekMonthSuperCardDef.CARD_TYPE_WEEK_CARD)
        local price = WeekMonthSuperCardModel:getCardPrice(WeekMonthSuperCardDef.CARD_TYPE_WEEK_CARD)
        if exchangeID == 0 or price == 0 then
            print("WeekMonthSuperCardCtrl:onClickWeekBtn date error")
            WeekMonthSuperCardModel:QueryWeekMonthSuperCardConfig()
            WeekMonthSuperCardModel:QueryWeekMonthSuperCardInfo()            
            my.informPluginByName({pluginName='TipPlugin',params={tipString="服务器繁忙，请稍后再试！",removeTime=1}})            
            return 
        end
        self:payForProduct(exchangeID, price) 
    else
        if info.wCRewardStatus == WeekMonthSuperCardDef.WEEK_MONTH_SUPER_CARD_NOT_REWARD then
            WeekMonthSuperCardModel:TakeDailyAward(WeekMonthSuperCardDef.CARD_TYPE_WEEK_CARD)
        else
            WeekMonthSuperCardModel:QueryWeekMonthSuperCardConfig()
            WeekMonthSuperCardModel:QueryWeekMonthSuperCardInfo()
        end
    end
end

function WeekMonthSuperCardCtrl:onClickMonthBtn()
    if self:isInMonthBtnClickGap() then return end

    my.playClickBtnSound()

    local config    = WeekMonthSuperCardModel:getConfig()
    local info      = WeekMonthSuperCardModel:getInfo()

    if not config or not info then return end

    if info.monthCardStatus == WeekMonthSuperCardDef.WEEK_MONTH_SUPER_CARD_NOT_BUY then
        local exchangeID = WeekMonthSuperCardModel:getCardExchangeID(WeekMonthSuperCardDef.CARD_TYPE_MONTH_CARD)
        local price = WeekMonthSuperCardModel:getCardPrice(WeekMonthSuperCardDef.CARD_TYPE_MONTH_CARD)
        if exchangeID == 0 or price == 0 then
            print("WeekMonthSuperCardCtrl:onClickWeekBtn date error")
            WeekMonthSuperCardModel:QueryWeekMonthSuperCardConfig()
            WeekMonthSuperCardModel:QueryWeekMonthSuperCardInfo()            
            my.informPluginByName({pluginName='TipPlugin',params={tipString="服务器繁忙，请稍后再试！",removeTime=1}})            
            return 
        end
        self:payForProduct(exchangeID, price) 
    else
        if info.mCRewardStatus == WeekMonthSuperCardDef.WEEK_MONTH_SUPER_CARD_NOT_REWARD then
            WeekMonthSuperCardModel:TakeDailyAward(WeekMonthSuperCardDef.CARD_TYPE_MONTH_CARD)
        else
            WeekMonthSuperCardModel:QueryWeekMonthSuperCardConfig()
            WeekMonthSuperCardModel:QueryWeekMonthSuperCardInfo()
        end
    end
end

function WeekMonthSuperCardCtrl:onClickSuperBtn()
    if self:isInSuperBtnClickGap() then return end

    my.playClickBtnSound()

    local config    = WeekMonthSuperCardModel:getConfig()
    local info      = WeekMonthSuperCardModel:getInfo()

    if not config or not info then return end

    if info.superCardStatus == WeekMonthSuperCardDef.WEEK_MONTH_SUPER_CARD_NOT_BUY then
        local exchangeID = WeekMonthSuperCardModel:getCardExchangeID(WeekMonthSuperCardDef.CARD_TYPE_SUPER_CARD)
        local price = WeekMonthSuperCardModel:getCardPrice(WeekMonthSuperCardDef.CARD_TYPE_SUPER_CARD)
        if exchangeID == 0 or price == 0 then
            print("WeekMonthSuperCardCtrl:onClickWeekBtn date error")
            WeekMonthSuperCardModel:QueryWeekMonthSuperCardConfig()
            WeekMonthSuperCardModel:QueryWeekMonthSuperCardInfo()            
            my.informPluginByName({pluginName='TipPlugin',params={tipString="服务器繁忙，请稍后再试！",removeTime=1}})            
            return 
        end
        self:payForProduct(exchangeID, price) 
    else
        if info.sCRewardStatus == WeekMonthSuperCardDef.WEEK_MONTH_SUPER_CARD_NOT_REWARD then
            WeekMonthSuperCardModel:TakeDailyAward(WeekMonthSuperCardDef.CARD_TYPE_SUPER_CARD)
        else
            WeekMonthSuperCardModel:QueryWeekMonthSuperCardConfig()
            WeekMonthSuperCardModel:QueryWeekMonthSuperCardInfo()
        end
    end
end

function WeekMonthSuperCardCtrl:playBgAni()
    if self._viewNode == nil or self._viewNode.nodeWeekAni == nil or self._viewNode.nodeMonthAni == nil or self._viewNode.nodeSuperAni == nil then return end

    local aniFileCardBg = "res/hallcocosstudio/WeekMonthSuperCard/WeekMonthSuperCard.csb"
    self._viewNode:stopAllActions()
    local actionCardBg = cc.CSLoader:createTimeline(aniFileCardBg)
    if not tolua.isnull(actionCardBg) then
        self._viewNode:runAction(actionCardBg)
        actionCardBg:play("bg_ani", true)
    end
    
    local aniFileWeekCardBg = "res/hallcocosstudio/WeekMonthSuperCard/week_card_bg_ani.csb"
    local aniNodeWeekCard = self._viewNode.nodeWeekAni
    aniNodeWeekCard:stopAllActions()
    local actionWeekCardBg = cc.CSLoader:createTimeline(aniFileWeekCardBg)
    if not tolua.isnull(actionWeekCardBg) then
        aniNodeWeekCard:runAction(actionWeekCardBg)
        actionWeekCardBg:play("card_bg_ani", true)
    end

    local aniFileMonthCardBg = "res/hallcocosstudio/WeekMonthSuperCard/month_card_bg_ani.csb"
    local aniNodeMonthCard = self._viewNode.nodeMonthAni
    aniNodeMonthCard:stopAllActions()
    local actionMonthCardBg = cc.CSLoader:createTimeline(aniFileMonthCardBg)
    if not tolua.isnull(actionMonthCardBg) then
        aniNodeMonthCard:runAction(actionMonthCardBg)
        actionMonthCardBg:play("card_bg_ani", true)
    end

    local aniFileSuperCardBg = "res/hallcocosstudio/WeekMonthSuperCard/super_card_bg_ani.csb"
    local aniNodeSuperCard = self._viewNode.nodeSuperAni
    aniNodeSuperCard:stopAllActions()
    local actionSuperCardBg = cc.CSLoader:createTimeline(aniFileSuperCardBg)
    if not tolua.isnull(actionSuperCardBg) then
        aniNodeSuperCard:runAction(actionSuperCardBg)
        actionSuperCardBg:play("card_bg_ani", true)
    end
end

function WeekMonthSuperCardCtrl:updateUI( )
    self:refreshWeekCardInfo()
    self:refreshMonthCardInfo()
    self:refreshSuperCardInfo()
end

function WeekMonthSuperCardCtrl:refreshWeekCardInfo()
    if not self._viewNode then return end
    
    local config    = WeekMonthSuperCardModel:getConfig()
    local info      = WeekMonthSuperCardModel:getInfo()

    if not config or not info then return end

    -- 刷新周卡剩余时间
    self._viewNode.txtWeekValidDate:setString("有效期"..info.wCRewardLeftDate.."天")
    -- 刷新周卡总共获取金额
    local weekCardTotalSliver = WeekMonthSuperCardModel:calcCardTotalSliver(WeekMonthSuperCardDef.CARD_TYPE_WEEK_CARD)
    local weekCardTotalSliverStr = WeekMonthSuperCardModel:getSilverNumString(weekCardTotalSliver)
    self._viewNode.txtWeekTotalValue:setString(weekCardTotalSliverStr)
    -- 刷新周卡购买立即获得的银两和每日获得的银两
    local onceSliver, dailySliver = WeekMonthSuperCardModel:getOnceSliverDailySliver(WeekMonthSuperCardDef.CARD_TYPE_WEEK_CARD)
    local onceSliverStr     = WeekMonthSuperCardModel:getSilverNumString(onceSliver)
    local dailySliverStr    = WeekMonthSuperCardModel:getSilverNumString(dailySliver)
    self._viewNode.txtWeekOnceSliver:setString(onceSliverStr)
    self._viewNode.txtWeekDailySliver:setString(dailySliverStr)
    -- 刷新周卡按钮
    local weekCardPrice = WeekMonthSuperCardModel:getCardPrice(WeekMonthSuperCardDef.CARD_TYPE_WEEK_CARD)
    if info.weekCardStatus == WeekMonthSuperCardDef.WEEK_MONTH_SUPER_CARD_NOT_BUY then
        self._viewNode.btnWeekBuy:setEnabled(true)
        self._viewNode.btnWeekBuy:setBright(true)
        self._viewNode.txtWeekPrice:setString(weekCardPrice.."元购买")
    else
        if info.wCRewardStatus == WeekMonthSuperCardDef.WEEK_MONTH_SUPER_CARD_NO_AWARD then
            self._viewNode.btnWeekBuy:setEnabled(true)
            self._viewNode.btnWeekBuy:setBright(true)
            self._viewNode.txtWeekPrice:setString(weekCardPrice.."元购买")
        elseif info.wCRewardStatus == WeekMonthSuperCardDef.WEEK_MONTH_SUPER_CARD_NOT_REWARD then
            self._viewNode.btnWeekBuy:setEnabled(true)
            self._viewNode.btnWeekBuy:setBright(true)
            self._viewNode.txtWeekPrice:setString("立即领取")
        elseif info.wCRewardStatus == WeekMonthSuperCardDef.WEEK_MONTH_SUPER_CARD_REWARDED then
            self._viewNode.btnWeekBuy:setEnabled(false)
            self._viewNode.btnWeekBuy:setBright(false)
            self._viewNode.txtWeekPrice:setString("已领取")
        end
    end
end

function WeekMonthSuperCardCtrl:refreshMonthCardInfo()
    if not self._viewNode then return end
    
    local config    = WeekMonthSuperCardModel:getConfig()
    local info      = WeekMonthSuperCardModel:getInfo()
    
    if not config or not info then return end

    -- 刷新月卡剩余时间
    self._viewNode.txtMonthValidDate:setString("有效期"..info.mCRewardLeftDate.."天")
    -- 刷新月卡总共获取金额
    local monthCardTotalSliver      = WeekMonthSuperCardModel:calcCardTotalSliver(WeekMonthSuperCardDef.CARD_TYPE_MONTH_CARD)
    local monthCardTotalSliverStr   = WeekMonthSuperCardModel:getSilverNumString(monthCardTotalSliver)
    self._viewNode.txtMonthTotalValue:setString(monthCardTotalSliverStr)
    -- 刷新周卡购买立即获得的银两和每日获得的银两
    local onceSliver, dailySliver = WeekMonthSuperCardModel:getOnceSliverDailySliver(WeekMonthSuperCardDef.CARD_TYPE_MONTH_CARD)
    local onceSliverStr     = WeekMonthSuperCardModel:getSilverNumString(onceSliver)
    local dailySliverStr    = WeekMonthSuperCardModel:getSilverNumString(dailySliver)
    self._viewNode.txtMonthOnceSliver:setString(onceSliverStr)
    self._viewNode.txtMonthDailySliver:setString(dailySliverStr)
    -- 刷新月卡按钮
    local monthCardPrice = WeekMonthSuperCardModel:getCardPrice(WeekMonthSuperCardDef.CARD_TYPE_MONTH_CARD)
    if info.monthCardStatus == WeekMonthSuperCardDef.WEEK_MONTH_SUPER_CARD_NOT_BUY then
        self._viewNode.btnMonthBuy:setEnabled(true)
        self._viewNode.btnMonthBuy:setBright(true)        
        self._viewNode.txtMonthPrice:setString(monthCardPrice.."元购买")
    else
        if info.mCRewardStatus == WeekMonthSuperCardDef.WEEK_MONTH_SUPER_CARD_NO_AWARD then
            self._viewNode.btnMonthBuy:setEnabled(true)
            self._viewNode.btnMonthBuy:setBright(true)
            self._viewNode.txtMonthkPrice:setString(monthCardPrice.."元购买")
        elseif info.mCRewardStatus == WeekMonthSuperCardDef.WEEK_MONTH_SUPER_CARD_NOT_REWARD then
            self._viewNode.btnMonthBuy:setEnabled(true)
            self._viewNode.btnMonthBuy:setBright(true)
            self._viewNode.txtMonthPrice:setString("立即领取")
        elseif info.mCRewardStatus == WeekMonthSuperCardDef.WEEK_MONTH_SUPER_CARD_REWARDED then
            self._viewNode.btnMonthBuy:setEnabled(false)
            self._viewNode.btnMonthBuy:setBright(false)
            self._viewNode.txtMonthPrice:setString("已领取")
        end
    end
end

function WeekMonthSuperCardCtrl:refreshSuperCardInfo()
    if not self._viewNode then return end
    
    local config    = WeekMonthSuperCardModel:getConfig()
    local info      = WeekMonthSuperCardModel:getInfo()
    
    if not config or not info then return end

    -- 刷新至尊卡剩余时间
    self._viewNode.txtSuperValidDate:setString("有效期"..info.sCRewardLeftDate.."天")
    -- 刷新至尊卡总共获取金额
    local superCardTotalSliver = WeekMonthSuperCardModel:calcCardTotalSliver(WeekMonthSuperCardDef.CARD_TYPE_SUPER_CARD)
    local superCardTotalSliverStr = WeekMonthSuperCardModel:getSilverNumString(superCardTotalSliver)
    self._viewNode.txtSuperTotalValue:setString(superCardTotalSliverStr)
    -- 刷新至尊卡购买立即获得的银两和每日获得的银两
    local onceSliver, dailySliver = WeekMonthSuperCardModel:getOnceSliverDailySliver(WeekMonthSuperCardDef.CARD_TYPE_SUPER_CARD)
    local onceSliverStr     = WeekMonthSuperCardModel:getSilverNumString(onceSliver)
    local dailySliverStr    = WeekMonthSuperCardModel:getSilverNumString(dailySliver)
    self._viewNode.txtSuperOnceSliver:setString(onceSliverStr)
    self._viewNode.txtSuperDailySliver:setString(dailySliverStr)
    -- 刷新至尊卡按钮
    local superCardPrice = WeekMonthSuperCardModel:getCardPrice(WeekMonthSuperCardDef.CARD_TYPE_SUPER_CARD)
    if info.superCardStatus == WeekMonthSuperCardDef.WEEK_MONTH_SUPER_CARD_NOT_BUY then
        self._viewNode.btnSuperBuy:setEnabled(true)
        self._viewNode.btnSuperBuy:setBright(true)
        self._viewNode.txtSuperPrice:setString(superCardPrice.."元购买")
    else
        if info.sCRewardStatus == WeekMonthSuperCardDef.WEEK_MONTH_SUPER_CARD_NO_AWARD then
            self._viewNode.btnSuperBuy:setEnabled(true)
            self._viewNode.btnSuperBuy:setBright(true)
            self._viewNode.txtSuperPrice:setString(superCardPrice.."元购买")
        elseif info.sCRewardStatus == WeekMonthSuperCardDef.WEEK_MONTH_SUPER_CARD_NOT_REWARD then
            self._viewNode.btnSuperBuy:setEnabled(true)
            self._viewNode.btnSuperBuy:setBright(true)
            self._viewNode.txtSuperPrice:setString("立即领取")
        elseif info.sCRewardStatus == WeekMonthSuperCardDef.WEEK_MONTH_SUPER_CARD_REWARDED then
            self._viewNode.btnSuperBuy:setEnabled(false)
            self._viewNode.btnSuperBuy:setBright(false)
            self._viewNode.txtSuperPrice:setString("已领取")
        end
    end
end

function WeekMonthSuperCardCtrl:isInWeekBtnClickGap()
    local GAP_SCHEDULE = 2 --间隔时间2秒
    local nowTime = os.time()
    self._lastWeekBtnTime = self._lastWeekBtnTime or 0
    if nowTime - self._lastWeekBtnTime > GAP_SCHEDULE then
        self._lastWeekBtnTime = nowTime
    else
        my.informPluginByName({pluginName = 'TipPlugin',params = {tipString = "点击太频繁，请2秒后再操作", removeTime = 3}})
        return true
    end
    return false
end

function WeekMonthSuperCardCtrl:isInMonthBtnClickGap()
    local GAP_SCHEDULE = 2 --间隔时间2秒
    local nowTime = os.time()
    self._lastMonthBtnTime = self._lastMonthBtnTime or 0
    if nowTime - self._lastMonthBtnTime > GAP_SCHEDULE then
        self._lastMonthBtnTime = nowTime
    else
        my.informPluginByName({pluginName = 'TipPlugin',params = {tipString = "点击太频繁，请2秒后再操作", removeTime = 3}})
        return true
    end
    return false
end

function WeekMonthSuperCardCtrl:isInSuperBtnClickGap()
    local GAP_SCHEDULE = 2 --间隔时间2秒
    local nowTime = os.time()
    self._lastSuperBtnTime = self._lastSuperBtnTime or 0
    if nowTime - self._lastSuperBtnTime > GAP_SCHEDULE then
        self._lastSuperBtnTime = nowTime
    else
        my.informPluginByName({pluginName = 'TipPlugin',params = {tipString = "点击太频繁，请2秒后再操作", removeTime = 3}})
        return true
    end
    return false
end

function WeekMonthSuperCardCtrl:AppType()
    local Def = WeekMonthSuperCardDef
    local type = Def.WEEK_CARD_APPTYPE_AN_TCY
    if device.platform == 'android' then
        if MCAgent:getInstance().getLaunchSubMode and MCAgent:getInstance().getLaunchMode then
            local launchMode = MCAgent:getInstance():getLaunchMode()
            local launchSubMode = MCAgent:getInstance():getLaunchSubMode()
            if launchSubMode == cc.exports.LaunchSubMode.PLATFORMSET then
                type = Def.WEEK_MONTH_SUPER_CARD_APPTYPE_AN_SET
            elseif launchMode == cc.exports.LaunchMode.PLATFORM then
                type = Def.WEEK_MONTH_SUPER_CARD_APPTYPE_AN_TCY
            else
                type = Def.WEEK_MONTH_SUPER_CARD_APPTYPE_AN_SINGLE
            end
        elseif MCAgent:getInstance().getLaunchMode then
            local launchMode = MCAgent:getInstance():getLaunchMode()
            if launchMode == cc.exports.LaunchMode.PLATFORM then
                type = Def.WEEK_MONTH_SUPER_CARD_APPTYPE_AN_TCY
            else
                type = Def.WEEK_MONTH_SUPER_CARD_APPTYPE_AN_SINGLE
            end
        else 
            type = Def.WEEK_MONTH_SUPER_CARD_APPTYPE_AN_TCY
        end
    elseif device.platform == 'ios' then
        local launchMode = MCAgent:getInstance():getLaunchMode()
        if launchMode == cc.exports.LaunchMode.PLATFORM then
            type = Def.WEEK_MONTH_SUPER_CARD_APPTYPE_IOS_TCY
        else
            type = Def.WEEK_MONTH_SUPER_CARD_APPTYPE_IOS_SINGLE
        end
    else
        --other os
    end

    return type
end

function WeekMonthSuperCardCtrl:payForProduct(excahngeID, price)
    if self._waitingPayResult then 
        my.informPluginByName({pluginName='TipPlugin',params={tipString="操作太频繁，请稍后再试！",removeTime=2}})
        return 
    end
    local Def = WeekMonthSuperCardDef
 
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

    param["Product_Name"] = "周月至尊卡充值"

    param["Product_Id"] = ""  --sid
    
    local apptype = self:AppType()
    print("----------------------------------apptype = ",apptype)

    local price,exchangeid = price, excahngeID
    print("------ price and exchangeid:",price,exchangeid)
    if apptype == Def.WEEK_CARD_APPTYPE_AN_TCY then
        print("WEEK_CARD_APPTYPE_AN_TCY")
    elseif apptype == Def.WEEK_CARD_APPTYPE_AN_SINGLE then
        print("WEEK_CARD_APPTYPE_AN_SINGLE")
    elseif apptype == Def.WEEK_CARD_APPTYPE_AN_SET then
        print("WEEK_CARD_APPTYPE_AN_SET")
        param["Product_Id"] = "com.uc108.mobile.gamecenter.tongbao" .. price
    elseif apptype == Def.WEEK_CARD_APPTYPE_IOS_TCY then
        print("WEEK_CARD_APPTYPE_IOS_TCY")
        param["Product_Id"] = "com.uc108.mobile.gamecenter.tongbao" .. price
    elseif apptype == Def.WEEK_CARD_APPTYPE_IOS_SINGLE then
        print("WEEK_CARD_APPTYPE_IOS_SINGLE")
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
        dump(param, "WeekMonthSuperCardCtrl:payForProduct param")
        iapPlugin:payForProduct(param)
        self._waitingPayResult = true
    end
end

function WeekMonthSuperCardCtrl:onKeyBack()
    local PluginProcessModel = mymodel('hallext.PluginProcessModel'):getInstance()
    
    PluginProcessModel:stopPluginProcess()
    WeekMonthSuperCardCtrl.super.onKeyBack(self)
end

function WeekMonthSuperCardCtrl:onClose( )
    printf("WeekMonthSuperCardCtrl onkeyBack")
    self:playEffectOnPress()
    my.scheduleOnce(function()
--        self._toDestroySelf=true
--        self:respondDestroyEvent()
        if(self:informPluginByName(nil,nil))then
            self:removeSelfInstance()
        end
    end)
end

return WeekMonthSuperCardCtrl