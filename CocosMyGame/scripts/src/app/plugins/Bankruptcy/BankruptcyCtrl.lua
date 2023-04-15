local BankruptcyCtrl = class('BankruptcyCtrl', cc.load('SceneCtrl'))
local viewCreater = import('src.app.plugins.Bankruptcy.BankruptcyView')
local BankruptcyModel = import('src.app.plugins.Bankruptcy.BankruptcyModel'):getInstance()
local BankruptcyDef = require('src.app.plugins.Bankruptcy.BankruptcyDef')
local json = cc.load("json").json
local DeviceModel = require("src.app.GameHall.models.DeviceModel"):getInstance()

function BankruptcyCtrl:onCreate( ... )
    local viewNode = self:setViewIndexer(viewCreater:createViewIndexer())

    local params = {...}
    self._isTriggerSinceEnterRoomInHall = false -- 是否是在大厅尝试进入房间时触发
    if params[1].enterRoomFailedInfo then
        self._isTriggerSinceEnterRoomInHall = true
    end
    self._callback = params[1].callback
    self._bHasLog = false --用于判断这次弹出是否已经埋点了

    self:initialListenTo()
    self:initialBtnClick()
    self:updateUI()

    BankruptcyModel:reqBankruptcyStatus()
end

function BankruptcyCtrl:onEnter()
    BankruptcyCtrl.super.onEnter(self)
    BankruptcyModel:initLogInfoOnEnter(self._isTriggerSinceEnterRoomInHall)
end

function BankruptcyCtrl:initialListenTo( )
    self:listenTo(BankruptcyModel, BankruptcyDef.BANKRUPTCY_STATUS_RSP, handler(self,self.updateUI))
    self:listenTo(BankruptcyModel, BankruptcyDef.BANKRUPTCY_APPLY_BAG_RSP, handler(self,self.updateUI))
end

function BankruptcyCtrl:initialBtnClick( )
    local viewNode = self._viewNode
    viewNode.btnBuy:addClickEventListener(handler(self, self.onClickBuy))
    viewNode.btnClose:addClickEventListener(handler(self, self.onClickClose))

    local panelShade = viewNode:getChildByName("Panel_Shade")
    viewNode.panelMain:setTouchEnabled(false)
    viewNode.panelAnimation:setTouchEnabled(false)
    viewNode.imgBg:setTouchEnabled(true)
    panelShade:addClickEventListener(function ()
        my.playClickBtnSound()
        self:goBack()
    end)
end

function BankruptcyCtrl:updateUI( )
    if not self._viewNode then return end

    local rspStatus = BankruptcyModel:getRspStatus()
    if not rspStatus or type(rspStatus.jsonstr) ~= "string" or string.len(rspStatus.jsonstr) <= 0 then
        print("BankruptcyCtrl:updateUI get json error")
        return
    end 
    local date = json.decode(rspStatus.jsonstr)
    self._date = date
    if date == nil or not date.Rewards or #date.Rewards ~= 2 then
        print("BankruptcyCtrl:updateUI parse json error")
        return
    end

    if not self._bHasLog and self._date.ExchangeID and self._date.Price then
        local logData = BankruptcyModel:getGiftBagClickLogData(self._date.ExchangeID, self._date.Price, true)
        my.dataLink(cc.exports.DataLinkCodeDef.GIFT_BAG_CLICK, logData) --礼包点击事件埋点

        self._bHasLog = true
    end

    for i = 1,2 do
        local name = "txtCount" .. i
        if self._viewNode[name] then
            self._viewNode[name]:setString("银子x" .. date.Rewards[i].RewardCount)
        end
    end
    if self._viewNode["txtDesc"] then
        self._viewNode["txtDesc"]:setString("充值" .. date.Price .. "元领取")
    end
end

function BankruptcyCtrl:onClickBuy()
    my.playClickBtnSound()
    
    if not self._date or not self._date.ExchangeID or not self._date.Price then
        print("BankruptcyCtrl:onClickBuy date error")
        dump(self._date)
        my.informPluginByName({pluginName='TipPlugin',params={tipString="服务器繁忙，请稍后再试！",removeTime=1}})
        self:goBack()
        return 
    end

    BankruptcyModel:setExchangeID(self._date.ExchangeID)
    
    self:payForProduct(self._date.ExchangeID, self._date.Price)
    self:goBack()
    -- 埋点
    BankruptcyModel:onClickBuyBtn(self._date.ExchangeID, self._date.Price)
end

function BankruptcyCtrl:AppType()
    local Def = BankruptcyDef
    local type = Def.BANKRUPTCY_APPTYPE_AN_TCY
    if device.platform == 'android' then
        if MCAgent:getInstance().getLaunchSubMode and MCAgent:getInstance().getLaunchMode then
            local launchMode = MCAgent:getInstance():getLaunchMode()
            local launchSubMode = MCAgent:getInstance():getLaunchSubMode()
            if launchSubMode == cc.exports.LaunchSubMode.PLATFORMSET then
                type = Def.BANKRUPTCY_APPTYPE_AN_SET
            elseif launchMode == cc.exports.LaunchMode.PLATFORM then
                type = Def.BANKRUPTCY_APPTYPE_AN_TCY
            else
                type = Def.BANKRUPTCY_APPTYPE_AN_SINGLE
            end
        elseif MCAgent:getInstance().getLaunchMode then
            local launchMode = MCAgent:getInstance():getLaunchMode()
            if launchMode == cc.exports.LaunchMode.PLATFORM then
                type = Def.BANKRUPTCY_APPTYPE_AN_TCY
            else
                type = Def.BANKRUPTCY_APPTYPE_AN_SINGLE
            end
        else 
            type = Def.BANKRUPTCY_APPTYPE_AN_TCY
        end
    elseif device.platform == 'ios' then
        local launchMode = MCAgent:getInstance():getLaunchMode()
        if launchMode == cc.exports.LaunchMode.PLATFORM then
            type = Def.BANKRUPTCY_APPTYPE_IOS_TCY
        else
            type = Def.BANKRUPTCY_APPTYPE_IOS_SINGLE
        end
    else
        --other os
    end

    return type
end

function BankruptcyCtrl:payForProduct(excahngeID, price)
    if self._waitingPayResult then 
        my.informPluginByName({pluginName='TipPlugin',params={tipString="操作太频繁，请稍后再试！",removeTime=2}})
        return 
    end
    local Def = BankruptcyDef
 
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
            print("BankruptcyCtrl single app")
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

        print("BankruptcyCtrl pay_ext_args:", strPayExtArgs)
        return strPayExtArgs
        
    end

    local paymodel = mymodel("PayModel"):getInstance()
    local param = clone(paymodel:getPayMetaTable())

    param["Product_Name"] = "破产礼包"

    param["Product_Id"] = ""  --sid
    
    local apptype = self:AppType()
    print("----------------------------------apptype = ",apptype)

    local price,exchangeid = price, excahngeID
    print("------ price and exchangeid:",price,exchangeid)
    if apptype == Def.BANKRUPTCY_APPTYPE_AN_TCY then
        print("BANKRUPTCY_APPTYPE_AN_TCY")
    elseif apptype == Def.BANKRUPTCY_APPTYPE_AN_SINGLE then
        print("BANKRUPTCY_APPTYPE_AN_SINGLE")
    elseif apptype == Def.BANKRUPTCY_APPTYPE_AN_SET then
        print("BANKRUPTCY_APPTYPE_AN_SET")
        param["Product_Id"] = "com.uc108.mobile.gamecenter.tongbao" .. price
    elseif apptype == Def.BANKRUPTCY_APPTYPE_IOS_TCY then
        print("BANKRUPTCY_APPTYPE_IOS_TCY")
        param["Product_Id"] = "com.uc108.mobile.gamecenter.tongbao" .. price
    elseif apptype == Def.BANKRUPTCY_APPTYPE_IOS_SINGLE then
        print("BANKRUPTCY_APPTYPE_IOS_SINGLE")
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

    local logData = BankruptcyModel:getGiftBagClickLogData(excahngeID, price, false)

    if device.platform == 'windows' or cc.exports.isHSoxRaySupported() then
        print("To Create ActivityRechargeHSoxCtrl")
        dump(param, "BankruptcyCtrl:payForProduct param")
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
                if type(logData) == 'table' then
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
        dump(param, "BankruptcyCtrl:payForProduct param")
        iapPlugin:payForProduct(param)
        self._waitingPayResult = true
    end
end

function BankruptcyCtrl:onClickClose( )
    my.playClickBtnSound()
    self:goBack()
    -- 埋点
    BankruptcyModel:onClickCloseBtn()
end

function BankruptcyCtrl:goBack()
    if type(self._callback) == 'function' then
        self._callback()
    end
    BankruptcyCtrl.super.removeSelf(self)
    if self._params and self._params.closeCallback and type(self._params.closeCallback) == "function" then
        self._params.closeCallback()
    end
end

return BankruptcyCtrl