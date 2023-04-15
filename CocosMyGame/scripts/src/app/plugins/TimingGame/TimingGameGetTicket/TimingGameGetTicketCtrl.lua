local TimingGameGetTicketCtrl = class('TimingGameGetTicketCtrl', cc.load('BaseCtrl'))
local viewCreater = import('src.app.plugins.TimingGame.TimingGameGetTicket.TimingGameGetTicketView')
local TimingGameModel = import('src.app.plugins.TimingGame.TimingGameModel'):getInstance()
local TimingGameDef = import('src.app.plugins.TimingGame.TimingGameDef')
local DeviceModel = require("src.app.GameHall.models.DeviceModel"):getInstance()
local user = mymodel('UserModel'):getInstance()
local RoomListModel = import("src.app.GameHall.room.model.RoomListModel"):getInstance()

function TimingGameGetTicketCtrl:onCreate( ... )
    local viewNode = self:setViewIndexer(viewCreater:createViewIndexer())

    local params = {...}

    self:initUI()
    self:initialListenTo()
    self:initialBtnClick()
    self:updateUI()
    TimingGameModel:reqTimingGameInfoData()
end

function TimingGameGetTicketCtrl:initUI()
    local config = cc.exports.getTimmingGameGetTicketWay()
    if not config then return end
    local count = 0
    for i,v in pairs(config) do
        if i == "task" then
            if TimingGameModel:isTicketTaskItemShow() then
                count = count + 1
            end
        else
            if v == 1 then
                count = count + 1
            end
        end
    end
    if count == 3 then return end
    
    for i = 1, 3 do
        self._viewNode["panelItem" .. i]:setVisible(false)
    end

    local tbl = { ["task"] = 1, ["deposit"] = 2, ["rmb"] = 3}

    local postions
    if count == 2 then
        postions = {
            (self._viewNode.panelItem1:getPositionX() + self._viewNode.panelItem2:getPositionX()) / 2,
            (self._viewNode.panelItem2:getPositionX() + self._viewNode.panelItem3:getPositionX()) /2,
        }
        
    elseif count == 1 then
        postions = {
            self._viewNode.panelItem2:getPositionX()
        }
    end
    if not postions then return end
    local index = 1
    for i,v in pairs(config) do
        if i == "task" then
            if TimingGameModel:isTicketTaskItemShow() then
                self._viewNode["panelItem" .. tbl[i]]:setVisible(true)
                self._viewNode["panelItem" .. tbl[i]]:setPositionX(postions[index])
                index = index + 1
            end
        else
            if v == 1 then
                self._viewNode["panelItem" .. tbl[i]]:setVisible(true)
                self._viewNode["panelItem" .. tbl[i]]:setPositionX(postions[index])
                index = index + 1
            end
        end
    end
end

function TimingGameGetTicketCtrl:initialListenTo()
    self:listenTo(TimingGameModel, TimingGameModel.EVENT_MAP["timinggame_getConfigFromSvr"], handler(self, self.updateUI))
    self:listenTo(TimingGameModel, TimingGameModel.EVENT_MAP["timinggame_getInfoDataFromSvr"], handler(self, self.updateUI))
end

function TimingGameGetTicketCtrl:initialBtnClick()
    self:bindSomeDestroyButtons(self._viewNode,{
		'btnClose',
    })
    local bindList={
		'btnTicketRMB',
		'btnTicketDeposit',
		'btnTask',
	}
	
    self:bindUserEventHandler(self._viewNode,bindList)
end

function TimingGameGetTicketCtrl:updateUI()
    local config = TimingGameModel:getConfig()
    local infoData = TimingGameModel:getInfoData()

    if not config or not infoData then
        TimingGameModel:showTips("获取数据中，请稍后再试!")
        return
    end

    local totalExchangeTicketsNum = 0
    for i = 1, TimingGameDef.TIMING_GAME_TICKET_TASK_NUM do
        totalExchangeTicketsNum = totalExchangeTicketsNum + config.GradeBoutObtainTickets[i].BoutExchangeTicketsNum
    end
    self._viewNode.txtTicket1:setString(string.format("门票x%d", totalExchangeTicketsNum))
    self._viewNode.txtTicket1_0:setString("(仅限当天使用)")
    local activityConfig = TimingGameModel:getActivityBuyConfig()
    
    self._viewNode.txtTicket2:setString(string.format("门票x%d", activityConfig.SliverBuyTicketsNum))
    self._viewNode.txtDepositDesc:setString(string.format("%d两", activityConfig.BuyTicketsSliverNum))
    
    local ticketCount, rmbNum, silverNum = self:getRMBConfig(infoData, activityConfig)

    self._viewNode.txtTicket3:setString(string.format("%d两", silverNum))
    self._viewNode.txtRMBDesc:setString(string.format("%d元购买", rmbNum))
    if silverNum and toint(silverNum) > 0 then
        self._viewNode.txtTicket3_0:setString(string.format("加赠门票x%d", ticketCount))
        self._viewNode.txtTicket3_0:setVisible(true)
    else
        self._viewNode.txtTicket3_0:setVisible(false)
    end    

    local date = tonumber(os.date("%Y%m%d", TimingGameModel:getCurrentTime()))
    local bout = 0
    if date == infoData.boutTicketDate then
        bout = infoData.boutNum
    end

    self._viewNode.btnTask:setTouchEnabled(true)
    self._viewNode.btnTask:setBright(true)

    self._viewNode.btnTicketRMB:setTouchEnabled(true)
    self._viewNode.btnTicketRMB:setBright(true)

    self._viewNode.btnTicketDeposit:setTouchEnabled(true)
    self._viewNode.btnTicketDeposit:setBright(true)
end

--ticketCount, rmbNum, silverNum, exchangeID
function TimingGameGetTicketCtrl:getRMBConfig(infoData, activityConfig)
    if not TimingGameModel:getTimingGameFirstBuyState() then        
        self._viewNode.imgMark2onlyone:setVisible(true)
        self._viewNode.imgMark2:setVisible(false)
        return activityConfig.FirstRMBBuyTicketsNum, 
        activityConfig.FirstBuyTicketsRMBNum, 
        activityConfig.FirstRMBBuyTicketsSliverNum,
        activityConfig.FirstRMBBuyTicketsExchangeID
    else
        local activityRmbBuyCount = TimingGameModel:getSelfBuyCount()
        local index = activityRmbBuyCount + 1
        self._viewNode.imgMark2onlyone:setVisible(false)
        self._viewNode.imgMark2:setVisible(true)
        if index > #activityConfig.BuyTicketsRMBNum then -- 显示商城物品
            local shopConfig = TimingGameModel:getShopBuyConfig()
            if shopConfig then
                self._viewNode.imgMark2:setVisible(false)

                return shopConfig.RMBBuyTicketsNum, 
                shopConfig.BuyTicketsRMBNum, 
                shopConfig.RMBBuyTicketsSliverNum,
                shopConfig.RMBBuyTicketsExchangeID
            else
                index = #activityConfig.BuyTicketsRMBNum
            end
        end
        return activityConfig.RMBBuyTicketsNum[index], 
        activityConfig.BuyTicketsRMBNum[index], 
        activityConfig.RMBBuyTicketsSliverNum[index],
        activityConfig.RMBBuyTicketsExchangeID[index]
    end    
end

function TimingGameGetTicketCtrl:isInClickGap()
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

function TimingGameGetTicketCtrl:btnTicketRMBClicked()
    if self:isInClickGap() then return end

    local activityConfig = TimingGameModel:getActivityBuyConfig()
    local infoData = TimingGameModel:getInfoData()
    if not activityConfig or not infoData then return end

    local ticketCount, rmbNum, silverNum, exchangeID = self:getRMBConfig(infoData, activityConfig)

    local nExchangeID, nPrice = exchangeID, rmbNum
    if not nExchangeID or not nPrice then
        print("TimingGameGetTicketCtrl:onClickBuy date error")
        my.informPluginByName({pluginName='TipPlugin',params={tipString="服务器繁忙，请稍后再试！",removeTime=1}})
        return 
    end
    TimingGameModel:setExchangeID(nExchangeID)
    self:payForProduct(nExchangeID, nPrice)
end

function TimingGameGetTicketCtrl:AppType()
    local Def = TimingGameDef
    local type = Def.TIMINGGAME_APPTYPE_AN_TCY
    if device.platform == 'android' then
        if MCAgent:getInstance().getLaunchSubMode and MCAgent:getInstance().getLaunchMode then
            local launchMode = MCAgent:getInstance():getLaunchMode()
            local launchSubMode = MCAgent:getInstance():getLaunchSubMode()
            if launchSubMode == cc.exports.LaunchSubMode.PLATFORMSET then
                type = Def.TIMINGGAME_APPTYPE_AN_SET
            elseif launchMode == cc.exports.LaunchMode.PLATFORM then
                type = Def.TIMINGGAME_APPTYPE_AN_TCY
            else
                type = Def.TIMINGGAME_APPTYPE_AN_SINGLE
            end
        elseif MCAgent:getInstance().getLaunchMode then
            local launchMode = MCAgent:getInstance():getLaunchMode()
            if launchMode == cc.exports.LaunchMode.PLATFORM then
                type = Def.TIMINGGAME_APPTYPE_AN_TCY
            else
                type = Def.TIMINGGAME_APPTYPE_AN_SINGLE
            end
        else 
            type = Def.TIMINGGAME_APPTYPE_AN_TCY
        end
    elseif device.platform == 'ios' then
        local launchMode = MCAgent:getInstance():getLaunchMode()
        if launchMode == cc.exports.LaunchMode.PLATFORM then
            type = Def.TIMINGGAME_APPTYPE_IOS_TCY
        else
            type = Def.TIMINGGAME_APPTYPE_IOS_SINGLE
        end
    else
        --other os
    end

    return type
end

function TimingGameGetTicketCtrl:payForProduct(excahngeID, price)
    if self._waitingPayResult then 
        my.informPluginByName({pluginName='TipPlugin',params={tipString="操作太频繁，请稍后再试！",removeTime=2}})
        return 
    end
    local Def = TimingGameDef
 
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
            print("TimingGameGetTicketCtrl single app")
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

        print("TimingGameGetTicketCtrl pay_ext_args:", strPayExtArgs)
        return strPayExtArgs
        
    end

    local paymodel = mymodel("PayModel"):getInstance()
    local param = clone(paymodel:getPayMetaTable())

    param["Product_Name"] = "定时赛门票"

    param["Product_Id"] = ""  --sid
    
    local apptype = self:AppType()
    print("----------------------------------apptype = ",apptype)

    local price,exchangeid = price, excahngeID
    print("------ price and exchangeid:",price,exchangeid)
    if apptype == Def.TIMINGGAME_APPTYPE_AN_TCY then
        print("TIMINGGAME_APPTYPE_AN_TCY")
    elseif apptype == Def.TIMINGGAME_APPTYPE_AN_SINGLE then
        print("TIMINGGAME_APPTYPE_AN_SINGLE")
    elseif apptype == Def.TIMINGGAME_APPTYPE_AN_SET then
        print("TIMINGGAME_APPTYPE_AN_SET")
        param["Product_Id"] = "com.uc108.mobile.gamecenter.tongbao" .. price
    elseif apptype == Def.TIMINGGAME_APPTYPE_IOS_TCY then
        print("TIMINGGAME_APPTYPE_IOS_TCY")
        param["Product_Id"] = "com.uc108.mobile.gamecenter.tongbao" .. price
    elseif apptype == Def.TIMINGGAME_APPTYPE_IOS_SINGLE then
        print("TIMINGGAME_APPTYPE_IOS_SINGLE")
        param["Product_Id"] = "com.uc108.mobile.hagd.deposit6.add45000"
    end

    --local through_data = string.format("{\"GameCode\":\"%s\",\"DeviceId\":\"%s\",\"RewardToGame\":%d,\"ExchangeId\":%d}", gamecode, deviceId, 0, exchangeid)
    local through_data = string.format("{\"RewardToGame\":%d,\"ExchangeId\":%d}", 0, exchangeid)
    local firstExchangeIDs = cc.exports.getTimmingGameFirstExchangeIDs()

    param["pay_point_num"]  = 0
    param["Product_Price"] = tostring(price)     --价格
    param["Exchange_Id"]  = tostring(1)      --物品ID  1是银子 2是会员 3是积分 4是钻石
    --if firstExchangeIDs[tostring(excahngeID)] and firstExchangeIDs[tostring(excahngeID)] == 4 then
        --param["Exchange_Id"]  = tostring(4)      --物品ID  1是银子 2是会员 3是积分 4是钻石
    --end
    param["through_data"] = through_data;
    param["ext_args"] = getPayExtArgs();

    local kpiData = my.getKPIClientData()
    param["RecomGameId"]   = tostring(kpiData.RecomGameId)
    param["RecomGameCode"] = kpiData.RecomGameCode
    param["RecomGameVers"] = ""

    if device.platform == 'windows' or cc.exports.isHSoxRaySupported() then
        print("To Create ActivityRechargeHSoxCtrl")
        dump(param, "TimingGameGetTicketCtrl:payForProduct param")
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
        dump(param, "TimingGameGetTicketCtrl:payForProduct param")
        iapPlugin:payForProduct(param)
        self._waitingPayResult = true
    end
end

function TimingGameGetTicketCtrl:btnTicketDepositClicked()
    if self:isInClickGap() then return end
    
    local activityConfig = TimingGameModel:getActivityBuyConfig()
    if not activityConfig then return end
    if user.nDeposit and user.nDeposit < activityConfig.BuyTicketsSliverNum then
        my.informPluginByName({pluginName ='TipPlugin',params = {tipString = "银两不足!", removeTime = 1}})
        return
    end

    local PropModel = require('src.app.plugins.shop.prop.PropModel'):getInstance()
    PropModel:sendBuyUserProp(activityConfig.SliverBuyTicketsPropID)
end

function TimingGameGetTicketCtrl:btnTaskClicked()
    if self:isInClickGap() then return end
    my.informPluginByName({pluginName = 'TimingGameTicketTask'})
end

function TimingGameGetTicketCtrl:goBack()
    TimingGameGetTicketCtrl.super.removeSelf(self)
end

return TimingGameGetTicketCtrl