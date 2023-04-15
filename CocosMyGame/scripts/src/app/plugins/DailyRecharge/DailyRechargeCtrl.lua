local DailyRechargeCtrl = class('DailyRechargeCtrl', cc.load('SceneCtrl'))
local viewCreater = import('src.app.plugins.DailyRecharge.DailyRechargeView')
local DailyRechargeModel = import('src.app.plugins.DailyRecharge.DailyRechargeModel'):getInstance()
local DailyRechargeDef = require('src.app.plugins.DailyRecharge.DailyRechargeDef')
local json = cc.load("json").json
local DeviceModel = require("src.app.GameHall.models.DeviceModel"):getInstance()
local RewardTipDef = import("src.app.plugins.RewardTip.RewardTipDef")

function DailyRechargeCtrl:onCreate( ... )
    local viewNode = self:setViewIndexer(viewCreater:createViewIndexer())

    self._bHasLog = false

    self:initialListenTo()
    self:initialBtnClick()
    self:updateUI()
    self:playAnimation()
end

function DailyRechargeCtrl:onEnter()
    DailyRechargeCtrl.super.onEnter(self)
    DailyRechargeModel:initLogInfoOnEnter()
end

function DailyRechargeCtrl:onExit()
    DailyRechargeCtrl.super.onExit(self)
    DailyRechargeModel:onClickCloseBtn()
end

function DailyRechargeCtrl:initialListenTo( )
    self:listenTo(DailyRechargeModel, DailyRechargeDef.DAILY_RECHARGE_STATUS_RSP, handler(self,self.updateUI))
end

function DailyRechargeCtrl:isInClickGap()
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

function DailyRechargeCtrl:initialBtnClick()
    local viewNode = self._viewNode
    if not viewNode then return end
    
    local btnList = {"btnTake1","btnTake2","btnTake3","btnTake4","btnTotalItme"}
    for i in ipairs(btnList) do
        if viewNode[btnList[i]] then
            viewNode[btnList[i]]:addClickEventListener(function ()
                print("click DailyRechargeCtrl btn ",i)
                if self:isInClickGap() then return end
                local data = DailyRechargeModel:getJsonData()
                local status = DailyRechargeModel:getRspStatus()                
                if not status or not data then 
                    print("initialBtnClick date error")
                    return 
                end
                
                local tempI = i
                if i == 4 then
                    tempI = tempI + 1
                end
                local awardstatus = DailyRechargeModel:getTaskStatus(status.awardstatus, tempI)
                if i ~= 5 then
                    local taskID = i
                    if i > 4 then
                        taskID = i - 1
                    end
                    local award = data.PerRechargeTaskList[taskID]
                    if not award then 
                        print("initialBtnClick award error")
                        return 
                    end
                    if awardstatus == DailyRechargeDef.REWARD_CANNOT_GET then
                        local exchangeID, price = award.ExchangeID, award.Price
                        self:onClickBuy(exchangeID, price)
                    elseif awardstatus == DailyRechargeDef.REWARD_CAN_GET then                        
                        DailyRechargeModel:gc_TakeRechargeAward(tempI)
                    else
                    end
                else
                    local totalItemState = status.totalItemStatus
                    if totalItemState == DailyRechargeDef.REWARD_CANNOT_GET then
                        local exchangeID, price = data.TotalItem.ExchangeID, data.TotalItem.SpecialPrice
                        self:onClickBuy(exchangeID, price)
                    elseif totalItemState == DailyRechargeDef.REWARD_CAN_GET then
                        DailyRechargeModel:gc_TakeRechargeAward(i + 1)
                    else                        
                    end
                end
            end)
        end
    end
end

function DailyRechargeCtrl:updateUI( )
    local viewNode = self._viewNode
    if not viewNode then return end

    if not viewNode then return end
    local data = DailyRechargeModel:getJsonData()
    local status = DailyRechargeModel:getRspStatus()
    
    if not data or not status then return end

    if not self._bHasLog then
        local logData = DailyRechargeModel:getGiftBagClickLogData(0, 0, true)
        my.dataLink(cc.exports.DataLinkCodeDef.GIFT_BAG_CLICK, logData) --礼包点击事件埋点

        self._bHasLog = true
    end

    local totalItemState = status.totalItemStatus
    local totalItemEnable = true

    if viewNode.txtOriginalPrice and data.TotalItem then
        viewNode.txtOriginalPrice:setString(tostring(data.TotalItem.OriginalPrice))
    end

    if viewNode.txtSpecialPrice and data.TotalItem then
        viewNode.txtSpecialPrice:setString(tostring(data.TotalItem.SpecialPrice))
    end

    if viewNode.imgTotalItemTip and viewNode.txtTotalIip and data.TotalItem then
        if totalItemState > DailyRechargeDef.REWARD_CANNOT_GET then
            viewNode.imgTotalItemTip:setVisible(false)
        else
            viewNode.imgTotalItemTip:setVisible(true)
            local discountPrice = data.TotalItem.OriginalPrice - data.TotalItem.SpecialPrice
            viewNode.txtTotalIip:setString(string.format( "立减%d元", discountPrice))
        end        
    end    

    for i = 1, 4 do
        local award = data.PerRechargeTaskList[i]
        if not award then return end

        if viewNode["txtTip" .. i] then
            viewNode["txtTip" .. i]:setString(string.format("单笔充值%d元", award.Price))
        end
        for j = 1,2 do
            local path = RewardTipDef:getItemImgPath(award.Rewards[j].RewardType, award.Rewards[j].RewardCount)
            local imgAward = viewNode["imgAward" .. i .. "_" .. j]
            if imgAward and path then
                imgAward:loadTexture(path, ccui.TextureResType.plistType)
            end
            
            local txtCount = viewNode["txtCount" .. i .. "_" .. j]
            if txtCount then
                txtCount:setString(string.format("x%d", award.Rewards[j].RewardCount))
            end
        end

        local btnTake = viewNode["btnTake" .. i]
        local txtDesc = viewNode["txtDescTake" .. i]
        if btnTake and txtDesc then
            local index = i
            if i >= 4 then
                index = index + 1
            end
            if totalItemState > DailyRechargeDef.REWARD_CANNOT_GET then
                txtDesc:setString(string.format("%d元领取", award.Price))
                txtDesc:setTextColor(cc.c3b(169,43,9)) 
                btnTake:setTouchEnabled(false)
                btnTake:setBright(false)
                totalItemEnable = true
            else
                local awardstatus = DailyRechargeModel:getTaskStatus(status.awardstatus, index)
                if awardstatus == DailyRechargeDef.REWARD_CANNOT_GET then
                    txtDesc:setString(string.format("%d元领取", award.Price))
                    txtDesc:setTextColor(cc.c3b(169,43,9)) 
                    btnTake:setTouchEnabled(true)
                    btnTake:setBright(true)
                elseif awardstatus == DailyRechargeDef.REWARD_CAN_GET then
                    txtDesc:setString(string.format("可领取"))
                    txtDesc:setTextColor(cc.c3b(169,43,9)) 
                    btnTake:setTouchEnabled(true)
                    btnTake:setBright(true)
                    totalItemEnable = false
                else
                    txtDesc:setString(string.format("已领取"))
                    txtDesc:setTextColor(cc.c3b(58,58,58)) 
                    btnTake:setTouchEnabled(false)
                    btnTake:setBright(false)
                    totalItemEnable = false
                end
            end
        end
    end

    if totalItemEnable then
        if viewNode.txtTotalItem and viewNode.btnTotalItme and status.totalItemStatus then        
            if totalItemState == DailyRechargeDef.REWARD_CANNOT_GET then
                viewNode.txtTotalItem:setString(string.format("一键购买"))
                viewNode.btnTotalItme:setTouchEnabled(true)
                viewNode.btnTotalItme:setBright(true)
            elseif totalItemState == DailyRechargeDef.REWARD_CAN_GET then
                viewNode.txtTotalItem:setString(string.format("可领取"))
                viewNode.btnTotalItme:setTouchEnabled(true)
                viewNode.btnTotalItme:setBright(true)
            else
                viewNode.txtTotalItem:setString(string.format("已领取"))
                viewNode.btnTotalItme:setTouchEnabled(false)
                viewNode.btnTotalItme:setBright(false)
            end
        end
    else
        viewNode.txtTotalItem:setString(string.format("一键购买"))
        viewNode.btnTotalItme:setTouchEnabled(false)
        viewNode.btnTotalItme:setBright(false)
    end
end

function DailyRechargeCtrl:playAnimation()
    local action = cc.CSLoader:createTimeline("res/hallcocosstudio/activitycenter/dailyrecharge.csb")
    if action and self._viewNode.btnTotalItme then
        self._viewNode.btnTotalItme:runAction(action)
        action:play("BtnAnimation", true)
    end
end

function DailyRechargeCtrl:onClickBuy(nExchangeID, nPrice)
    my.playClickBtnSound()

    DailyRechargeModel:onClickBuyBtn(nExchangeID, nPrice)

    if not nExchangeID or not nPrice then
        print("DailyRechargeCtrl:onClickBuy date error")
        my.informPluginByName({pluginName='TipPlugin',params={tipString="服务器繁忙，请稍后再试！",removeTime=1}})
        return 
    end
    self:payForProduct(nExchangeID, nPrice)
end

function DailyRechargeCtrl:AppType()
    local Def = DailyRechargeDef
    local type = Def.DAILY_RECHARGE_APPTYPE_AN_TCY
    if device.platform == 'android' then
        if MCAgent:getInstance().getLaunchSubMode and MCAgent:getInstance().getLaunchMode then
            local launchMode = MCAgent:getInstance():getLaunchMode()
            local launchSubMode = MCAgent:getInstance():getLaunchSubMode()
            if launchSubMode == cc.exports.LaunchSubMode.PLATFORMSET then
                type = Def.DAILY_RECHARGE_APPTYPE_AN_SET
            elseif launchMode == cc.exports.LaunchMode.PLATFORM then
                type = Def.DAILY_RECHARGE_APPTYPE_AN_TCY
            else
                type = Def.DAILY_RECHARGE_APPTYPE_AN_SINGLE
            end
        elseif MCAgent:getInstance().getLaunchMode then
            local launchMode = MCAgent:getInstance():getLaunchMode()
            if launchMode == cc.exports.LaunchMode.PLATFORM then
                type = Def.DAILY_RECHARGE_APPTYPE_AN_TCY
            else
                type = Def.DAILY_RECHARGE_APPTYPE_AN_SINGLE
            end
        else 
            type = Def.DAILY_RECHARGE_APPTYPE_AN_TCY
        end
    elseif device.platform == 'ios' then
        local launchMode = MCAgent:getInstance():getLaunchMode()
        if launchMode == cc.exports.LaunchMode.PLATFORM then
            type = Def.DAILY_RECHARGE_APPTYPE_IOS_TCY
        else
            type = Def.DAILY_RECHARGE_APPTYPE_IOS_SINGLE
        end
    else
        --other os
    end

    return type
end

function DailyRechargeCtrl:payForProduct(excahngeID, price)
    if self._waitingPayResult then 
        my.informPluginByName({pluginName='TipPlugin',params={tipString="操作太频繁，请稍后再试！",removeTime=2}})
        return 
    end
    local Def = DailyRechargeDef
 
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
            print("DailyRechargeCtrl single app")
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

        print("DailyRechargeCtrl pay_ext_args:", strPayExtArgs)
        return strPayExtArgs
        
    end

    local paymodel = mymodel("PayModel"):getInstance()
    local param = clone(paymodel:getPayMetaTable())

    param["Product_Name"] = "每日充值"

    param["Product_Id"] = ""  --sid
    
    local apptype = self:AppType()
    print("----------------------------------apptype = ",apptype)

    local price,exchangeid = price, excahngeID
    print("------ price and exchangeid:",price,exchangeid)
    if apptype == Def.DAILY_RECHARGE_APPTYPE_AN_TCY then
        print("DAILY_RECHARGE_APPTYPE_AN_TCY")
    elseif apptype == Def.DAILY_RECHARGE_APPTYPE_AN_SINGLE then
        print("DAILY_RECHARGE_APPTYPE_AN_SINGLE")
    elseif apptype == Def.DAILY_RECHARGE_APPTYPE_AN_SET then
        print("DAILY_RECHARGE_APPTYPE_AN_SET")
        param["Product_Id"] = "com.uc108.mobile.gamecenter.tongbao" .. price
    elseif apptype == Def.DAILY_RECHARGE_APPTYPE_IOS_TCY then
        print("DAILY_RECHARGE_APPTYPE_IOS_TCY")
        param["Product_Id"] = "com.uc108.mobile.gamecenter.tongbao" .. price
    elseif apptype == Def.DAILY_RECHARGE_APPTYPE_IOS_SINGLE then
        print("DAILY_RECHARGE_APPTYPE_IOS_SINGLE")
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

    local logData = DailyRechargeModel:getGiftBagClickLogData(excahngeID, price, false)

    if device.platform == 'windows' or cc.exports.isHSoxRaySupported() then
        print("To Create ActivityRechargeHSoxCtrl")
        dump(param, "DailyRechargeCtrl:payForProduct param")
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
                if type(logData) == "table" then
                    logData.PayStatus = 1
                    local user = mymodel('UserModel'):getInstance()
                    logData.NowDeposit = user.nDeposit
                end
            else
                if string.len(msg) ~= 0 then
                    my.informPluginByName({pluginName='TipPlugin',params={tipString=msg,removeTime=2}})
                end
                if( code == PayResultCode.kPayFail )then

                elseif( code == PayResultCode.kPayTimeOut )then

                elseif( code == PayResultCode.kPayProductionInforIncomplete )then

                end
            end
            my.dataLink(cc.exports.DataLinkCodeDef.GIFT_BAG_CLICK, logData) --礼包点击事件埋点
        end
        iapPlugin:setCallback(payCallBack)
        dump(param, "DailyRechargeCtrl:payForProduct param")        
        iapPlugin:payForProduct(param)
        self._waitingPayResult = true
    end
end

return DailyRechargeCtrl