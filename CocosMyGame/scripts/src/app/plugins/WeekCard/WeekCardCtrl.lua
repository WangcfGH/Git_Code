local WeekCardCtrl = class('WeekCardCtrl', cc.load('SceneCtrl'))
local viewCreater = import('src.app.plugins.WeekCard.WeekCardView')
local WeekCardModel = import('src.app.plugins.WeekCard.WeekCardModel'):getInstance()
local WeekCardDef = require('src.app.plugins.WeekCard.WeekCardDef')
local json = cc.load("json").json
local DeviceModel = require("src.app.GameHall.models.DeviceModel"):getInstance()

local MonthCardCtrl = require("src.app.plugins.monthcard.MonthCardCtrl")
local MonthCardConn = require("src.app.plugins.monthcard.MonthCardConn"):getInstance()

function WeekCardCtrl:onCreate( ... )
    local viewNode = self:setViewIndexer(viewCreater:createViewIndexer())

    local params = {...}
    local isInGame = params[1].isInGame
    if isInGame then
        local bShowWeek = cc.exports.isWeekCardSupported()
        if bShowWeek then
            self:selectTab("week")
            self._viewNode.btnWeek:setVisible(false)
        end
    else
        local bShowWeek = cc.exports.isWeekCardSupported()
        local bShowMonth = cc.exports.isMonthCardSupported()
        --标签tab显示
        if bShowWeek then
            self:selectTab("week")
            self._viewNode.btnWeek:setVisible(false)
        end
        if bShowMonth and not bShowWeek then
            self:selectTab("month")
            self._viewNode.btnMonth:setVisible(false)
        end
        if bShowWeek and bShowMonth then --两者都显示才显示切换标签
            self._viewNode.btnWeek:setVisible(true)
            self._viewNode.btnMonth:setVisible(true)
        end
    end
    

    self:initialListenTo()
    self:initialBtnClick()
    self:updateUI()

    WeekCardModel:gc_GetWeekCardInfo()
    MonthCardConn:QueryMonthCardReq()
end

function WeekCardCtrl:initialListenTo( )
    self:listenTo(WeekCardModel, WeekCardDef.WEEK_CARD_STATUS_RSP, handler(self,self.updateUI))
    --self:listenTo(WeekCardModel, WeekCardDef.WEEK_CARD_UPDATE_REDDOT, handler(self,self.updateUI))
    self:listenTo(MonthCardConn, MonthCardConn.EVENT_MODULESTATUS_CHANGED, handler(self, self.onRefreshMonthCardDot))
    self:listenTo(MonthCardCtrl, MonthCardCtrl.EVENT_START_PAY, handler(self, self.onStartPayMonth))
end

function WeekCardCtrl:onRefreshMonthCardDot()
    local bShowMonthDot = (MonthCardConn:getStatusDataExtended("isNeedReddot") == true)
    if bShowMonthDot then
        self._viewNode.dotMonth:setVisible(true)
    else
        self._viewNode.dotMonth:setVisible(false)
    end
    WeekCardModel:refreshRedDot()
end

function WeekCardCtrl:onStartPayMonth()
    -- if device.platform == 'windows' or cc.exports.isHSoxRaySupported() then
    --     my.scheduleOnce(function()
    --         self:onClose()
    --     end, 0.2)
    -- end  
end

function WeekCardCtrl:updateUI( )
    if not self._viewNode then return end
    if not WeekCardModel:isWeekCardShow() then
        if MonthCardConn:getStatusDataExtended("isPluginAvail") then
            self:selectTab("month")
        end
        self._viewNode.btnWeek:setVisible(false)
        self._viewNode.btnMonth:setVisible(false)
    end
    local data = WeekCardModel:getJsonData()
    local rspStatus = WeekCardModel:getRspStatus()
    if not data or not rspStatus then return end

    --设置数值
    local firstNum = data.Rewards[1].RewardCount .. "银两"
    local secondNum = data.Rewards[2].RewardCount .. "银两"
    self._viewNode.txtBuyCount1:setString(firstNum)
    self._viewNode.txtTitle:setString(firstNum)
    self._viewNode.txtBuyCount2:setString(secondNum)
    self._viewNode.txtTakeCount:setString(secondNum)
    self._viewNode.txtBtnBuy:setString("充值" .. data.Price .. "元")

    self._price = data.Price
    self._exchangeID = data.ExchangeID

    if WeekCardModel:canTakeAward() then
        self._viewNode.btnTake:setTouchEnabled(true)
        self._viewNode.btnTake:setBright(true)
        self._viewNode.dotWeek:setVisible(true)
        self._viewNode.txtBtnTake:setString("立即领取")
        self._viewNode.txtBtnTake:setColor(cc.c3b(41,107,8)) 
    else
        self._viewNode.btnTake:setTouchEnabled(false)
        self._viewNode.btnTake:setBright(false)
        self._viewNode.dotWeek:setVisible(false)
        self._viewNode.txtBtnTake:setColor(cc.c3b(58,58,58)) 
        if rspStatus.current_day == 6 then
            self._viewNode.txtBtnTake:setString("明日再来")
        else
            self._viewNode.txtBtnTake:setString("明日可领取")
        end
    end

    local leftday = rspStatus.current_day
    if leftday > 6 then leftday = 6 end
    self._viewNode.txtDay:setString("活动剩余天数：" .. 6 - leftday .. "天")

    self:onRefreshMonthCardDot()

    if WeekCardModel:canBuyWeekCard() then
        self._viewNode.btnBuy:setTouchEnabled(true)
        self._viewNode.btnBuy:setBright(true)
        self._viewNode.txtBtnCannot:setVisible(false)
        self._viewNode.txtBtnBuy:setVisible(true)
    else
        self._viewNode.btnBuy:setTouchEnabled(false)
        self._viewNode.btnBuy:setBright(false)
        self._viewNode.txtBtnCannot:setVisible(true)
        if rspStatus.current_day == 6 then
            self._viewNode.txtBtnCannot:setString("明日再来")
        else
            self._viewNode.txtBtnCannot:setString("明日可领取")
        end
        self._viewNode.txtBtnBuy:setVisible(false)
    end

    self:showWeekCardPanel()
end

function WeekCardCtrl:showWeekCardPanel()
    local rspStatus = WeekCardModel:getRspStatus()
    if not rspStatus then return end

    if WeekCardModel:canTakeAward() or (rspStatus.current_day >= 0 and rspStatus.current_day <= 6) then
        self._viewNode.panelWeek:setVisible(false)
        self._viewNode.panelWeekDaily:setVisible(true)
    else
        self._viewNode.panelWeek:setVisible(true)
        self._viewNode.panelWeekDaily:setVisible(false)
    end
end

function WeekCardCtrl:selectTab(tab)
    if tab == "week" then
        self._viewNode.btnWeek:setSelected(true)
        self._viewNode.btnMonth:setSelected(false)

        self._viewNode.panelMonth:setVisible(false)
        self._viewNode.panelMonthDaily:setVisible(false)
        
        self._viewNode.imgBg:loadTexture("hallcocosstudio/images/plist/WeekCard/Img_bg2.png",1)
        self:showWeekCardPanel()
    elseif tab == "month" then
        self._viewNode.btnWeek:setSelected(false)
        self._viewNode.btnMonth:setSelected(true)

        self._viewNode.panelWeek:setVisible(false)
        self._viewNode.panelWeekDaily:setVisible(false)

        self._viewNode.imgBg:loadTexture("hallcocosstudio/images/plist/WeekCard/Img_bg.png",1)
        MonthCardCtrl:showView(self._viewNode)
    end
end

function WeekCardCtrl:isInClickGap()
    local GAP_SCHEDULE = 2 --间隔时间2秒
    local nowTime = os.time()
    self._lastTime = self._lastTime or 0
    if nowTime - self._lastTime > GAP_SCHEDULE then
        self._lastTime = nowTime
    else
        my.informPluginByName({pluginName = 'TipPlugin',params = {tipString = "点击太频繁，请2秒后再操作", removeTime = 3}})
        return true
    end
    return false
end

function WeekCardCtrl:initialBtnClick()
    self._viewNode.btnWeek:addEventListener(function(sender, eventType) 
        self:selectTab("week")
    end)

    self._viewNode.btnMonth:addEventListener(function(sender, eventType) 
        self:selectTab("month")
    end)

    self._viewNode.btnClose:addClickEventListener(function() 
        local PluginProcessModel = mymodel('hallext.PluginProcessModel'):getInstance()
        PluginProcessModel:PopNextPlugin()
        self:onClose()
    end)

    self._viewNode.btnBuy:addClickEventListener(function() 
        self:onClickBuy(self._exchangeID, self._price)
    end)

    self._viewNode.btnTake:addClickEventListener(function() 
        if self:isInClickGap() then return end
        WeekCardModel:gc_TakeDailyAward()
    end)
end

function WeekCardCtrl:onClickBuy(nExchangeID, nPrice)
    my.playClickBtnSound()
    
    if not nExchangeID or not nPrice then
        print("WeekCardCtrl:onClickBuy date error")
        my.informPluginByName({pluginName='TipPlugin',params={tipString="服务器繁忙，请稍后再试！",removeTime=1}})
        return 
    end
    WeekCardModel:setExchangeID(nExchangeID)
    self:payForProduct(nExchangeID, nPrice)
end

function WeekCardCtrl:AppType()
    local Def = WeekCardDef
    local type = Def.WEEK_CARD_APPTYPE_AN_TCY
    if device.platform == 'android' then
        if MCAgent:getInstance().getLaunchSubMode and MCAgent:getInstance().getLaunchMode then
            local launchMode = MCAgent:getInstance():getLaunchMode()
            local launchSubMode = MCAgent:getInstance():getLaunchSubMode()
            if launchSubMode == cc.exports.LaunchSubMode.PLATFORMSET then
                type = Def.WEEK_CARD_APPTYPE_AN_SET
            elseif launchMode == cc.exports.LaunchMode.PLATFORM then
                type = Def.WEEK_CARD_APPTYPE_AN_TCY
            else
                type = Def.WEEK_CARD_APPTYPE_AN_SINGLE
            end
        elseif MCAgent:getInstance().getLaunchMode then
            local launchMode = MCAgent:getInstance():getLaunchMode()
            if launchMode == cc.exports.LaunchMode.PLATFORM then
                type = Def.WEEK_CARD_APPTYPE_AN_TCY
            else
                type = Def.WEEK_CARD_APPTYPE_AN_SINGLE
            end
        else 
            type = Def.WEEK_CARD_APPTYPE_AN_TCY
        end
    elseif device.platform == 'ios' then
        local launchMode = MCAgent:getInstance():getLaunchMode()
        if launchMode == cc.exports.LaunchMode.PLATFORM then
            type = Def.WEEK_CARD_APPTYPE_IOS_TCY
        else
            type = Def.WEEK_CARD_APPTYPE_IOS_SINGLE
        end
    else
        --other os
    end

    return type
end

function WeekCardCtrl:payForProduct(excahngeID, price)
    if self._waitingPayResult then 
        my.informPluginByName({pluginName='TipPlugin',params={tipString="操作太频繁，请稍后再试！",removeTime=2}})
        return 
    end
    local Def = WeekCardDef
 
    local szWifiID,szImeiID,szSystemID=DeviceModel.szWifiID,DeviceModel.szImeiID,DeviceModel.szSystemID
    local deviceId=string.format('%s,%s,%s',szWifiID,szImeiID,szSystemID)

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
            print("WeekCardCtrl single app")
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

        print("WeekCardCtrl pay_ext_args:", strPayExtArgs)
        return strPayExtArgs
        
    end

    local paymodel = mymodel("PayModel"):getInstance()
    local param = clone(paymodel:getPayMetaTable())

    param["Product_Name"] = "周卡充值"

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
        dump(param, "WeekCardCtrl:payForProduct param")
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
        dump(param, "WeekCardCtrl:payForProduct param")
        iapPlugin:payForProduct(param)
        self._waitingPayResult = true
    end
end

function WeekCardCtrl:onKeyBack()
    local PluginProcessModel = mymodel('hallext.PluginProcessModel'):getInstance()
    
    PluginProcessModel:stopPluginProcess()
    WeekCardCtrl.super.onKeyBack(self)
end

function WeekCardCtrl:onClose( )
    printf("WeekCardCtrl onkeyBack")
    self:playEffectOnPress()
    my.scheduleOnce(function()
--        self._toDestroySelf=true
--        self:respondDestroyEvent()
        if(self:informPluginByName(nil,nil))then
            self:removeSelfInstance()
        end
    end)
end

return WeekCardCtrl