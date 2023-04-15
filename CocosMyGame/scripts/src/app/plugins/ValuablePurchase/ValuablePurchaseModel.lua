
local ValuablePurchaseModel = class('ValuablePurchaseModel', require('src.app.GameHall.models.BaseModel'))
local ValuablePurchaseDef   = import('src.app.plugins.ValuablePurchase.ValuablePurchaseDef')
local AssistModel           = mymodel('assist.AssistModel'):getInstance()
local RewardTipDef          = import("src.app.plugins.RewardTip.RewardTipDef")

my.addInstance(ValuablePurchaseModel)
protobuf.register_file('src/app/plugins/ValuablePurchase/pbValuablePurchase.pb')

ValuablePurchaseModel.EVENT_QUERY_INFO_OK = 'EVENT_QUERY_INFO_OK'
ValuablePurchaseModel.EVENT_START_PAY_OK = 'EVENT_START_PAY_OK'
ValuablePurchaseModel.EVENT_BUY_PURCHASE_OK = 'EVENT_BUY_PURCHASE_OK'

function ValuablePurchaseModel:onCreate()
    self:initData()
    self:initScheduleTimer()
    -- 注册回调
    self:initAssistResponse()
end

function ValuablePurchaseModel:initData()
    self._enable = false
    self._purchaseItemList = {}
    self._timerWaitingPay = nil
end

function ValuablePurchaseModel:initScheduleTimer()
    self._curDate = self:getTodayDate()
    my.createSchedule(function()
        local date = self:getTodayDate()
        if self._curDate ~= date then
            self:queryInfo()
        end
    end, 10)
end

-- 注册回调
function ValuablePurchaseModel:initAssistResponse()
    self._assistResponseMap = {
        [ValuablePurchaseDef.GR_VALUABLE_PURCHASE_QUERY_INFO] = handler(self, self.onQueryInfoOK),
        [ValuablePurchaseDef.GR_VALUABLE_PURCHASE_START_PAY] = handler(self, self.onStartPayRsp),
        [ValuablePurchaseDef.GR_VALUABLE_PURCHASE_PAY_RESULT] = handler(self, self.onPayResult),
    }

    AssistModel:registCtrl(self, self.dealAssistResponse)
end

function ValuablePurchaseModel:getPlatformType()
    local platFormType = 1
    if MCAgent:getInstance().getLaunchSubMode and MCAgent:getInstance():getLaunchSubMode() == 1 then
        platFormType = 3
    elseif cc.exports.LaunchMode["PLATFORM"] == MCAgent:getInstance():getLaunchMode() then
        if device.platform == 'ios' then
            platFormType = 2
        else
            platFormType = 1
        end
    end

    return platFormType
end

function ValuablePurchaseModel:queryInfo()
    if not cc.exports.isValuablePurchaseSupported() then
        self:startPluginProcess()
        return
    end

    local UserModel = mymodel('UserModel'):getInstance()
    if UserModel.nUserID == nil or UserModel.nUserID < 0 then
        self:startPluginProcess()
        return
    end

    local data = {
        userid = UserModel.nUserID,
        platform = self:getPlatformType(),
    }
    local pdata = protobuf.encode('pbValuablePurchase.QueryInfoReq', data)
    AssistModel:sendData(ValuablePurchaseDef.GR_VALUABLE_PURCHASE_QUERY_INFO, pdata, false)
end

function ValuablePurchaseModel:startPay(purchaseId)
    if not cc.exports.isValuablePurchaseSupported() then
        return
    end

    if self._timerWaitingPay then
        my.informPluginByName({pluginName = "ToastPlugin", params = {tipString = "点击频繁，请稍后再试~", removeTime = 3}})
        return
    end
    
    local todayDate = tonumber(os.date('%Y%m%d', os.time()))
    if not self:validatePurchaseItem(todayDate, purchaseId) then
        my.informPluginByName({pluginName = "ToastPlugin", params = {tipString = "该礼包不能购买，请稍后再试~", removeTime = 3}})
        return
    end
    
    self:startWaitingPayTimer()

    local UserModel = mymodel('UserModel'):getInstance()
    local data = {
        userid = UserModel.nUserID,
        platform = self:getPlatformType(),
        purchaseid = purchaseId,
        clientdate = todayDate
    }

    local pdata = protobuf.encode('pbValuablePurchase.StartPayReq', data)
    AssistModel:sendData(ValuablePurchaseDef.GR_VALUABLE_PURCHASE_START_PAY, pdata, false)
end

function ValuablePurchaseModel:onQueryInfoOK(data)
    if string.len(data) == nil then return nil end

    local pdata = protobuf.decode('pbValuablePurchase.QueryInfoRsp', data)
    protobuf.extract(pdata)

    if pdata.resultcode == ValuablePurchaseDef.VALUABLE_PURCHASE_QUERY_INFO_OK then
        self._enable = true
        self._purchaseItemList = clone(pdata.purchaseitemlist)
        -- 按价格大小排个序
        table.sort(
            self._purchaseItemList,
            function(a, b)
                return a.price < b.price
            end
        )
        self._curDate = self:getTodayDate()
    else
        self._enable = false
        self._purchaseItemList = {}
    end
    self:startPluginProcess()
    self:dispatchEvent({name = ValuablePurchaseModel.EVENT_QUERY_INFO_OK})
end

function ValuablePurchaseModel:onStartPayRsp(data)
    if string.len(data) == nil then return nil end

    local pdata = protobuf.decode('pbValuablePurchase.StartPayRsp', data)
    protobuf.extract(pdata)

    local continuePay = false
    local purchaseId = pdata.purchaseid
    if pdata.resultcode == ValuablePurchaseDef.VALUABLE_PURCHASE_START_PAY_ALLREADY_PAYED then
        my.informPluginByName({pluginName = "ToastPlugin", params = {tipString = "今日已购买，请明天再来~", remiveTime = 2}})
    elseif pdata.resultcode == ValuablePurchaseDef.VALUABLE_PURCHASE_START_PAY_PLATFORM_ERROR then
        -- 不提示
    elseif pdata.resultcode == ValuablePurchaseDef.VALUABLE_PURCHASE_START_PAY_NO_THIS_PURCHASE then
        -- 不提示
    elseif pdata.resultcode == ValuablePurchaseDef.VALUABLE_PURCHASE_START_PAY_CLIENT_DATE_ERROR then
        my.informPluginByName({pluginName = "ToastPlugin", params = {tipString = "客户端日期不正确，请检查系统设置~", remiveTime = 2}})
        self:queryInfo()
    elseif pdata.resultcode == ValuablePurchaseDef.VALUABLE_PURCHASE_START_PAY_SYSTEM_ERROR then
        -- 不提示
    elseif pdata.resultcode == ValuablePurchaseDef.VALUABLE_PURCHASE_START_PAY_OK then
        continuePay = true
    end

    self:dispatchEvent({name = ValuablePurchaseModel.EVENT_START_PAY_OK, value = {continuePay = continuePay, purchaseId = purchaseId}})
end

function ValuablePurchaseModel:onPayResult(data)
    if string.len(data) == nil then return nil end

    local pdata = protobuf.decode('pbValuablePurchase.PurchaseResult', data)
    protobuf.extract(pdata)

    if pdata.resultcode == ValuablePurchaseDef.VALUABLE_PURCHASE_PAY_RESULT_OK then
        self:onPurchaseSuccess(pdata)
    else
        -- 不提示
    end

    dump(pdata)
end

function ValuablePurchaseModel:getRewardTipType(rewardType, propID)
    if rewardType == ValuablePurchaseDef.VALUABLE_PURCHASE_ITEMTYPE_SILVER then
        return RewardTipDef.TYPE_SILVER
    elseif rewardType == ValuablePurchaseDef.VALUABLE_PURCHASE_ITEMTYPE_EXCHANGE then
        return RewardTipDef.TYPE_TICKET
    else
        if propID == ValuablePurchaseDef.REWARD_PROP_ID_EXPRESSION_ROSE then
            return RewardTipDef.TYPE_ROSE
        elseif propID == ValuablePurchaseDef.REWARD_PROP_ID_EXPRESSION_LIGHTNING then
            return RewardTipDef.TYPE_LIGHTING
        elseif propID == ValuablePurchaseDef.REWARD_PROP_ID_ONEBOUT_CARDMARKER then
            return RewardTipDef.TYPE_CARDMARKER
        elseif propID == ValuablePurchaseDef.REWARD_PROP_ID_TIMING_GAME_TICKET then
            return RewardTipDef.TYPE_REWARDTYPE_TIMINGGAME_TICKET
        elseif propID == ValuablePurchaseDef.REWARD_PROP_ID_ONEDAY_CARD_MARKER then
            return RewardTipDef.TYPE_CARDMARKER_1D
        end
    end
end

function ValuablePurchaseModel:onPurchaseSuccess(purchaseResult)
    local purchaseItem = self:getPurchaseItemByPurchaseId(purchaseResult.purchaseid)
    if purchaseItem then
        purchaseItem.purchasedate = purchaseResult.purchasedate
        purchaseItem.continuedays = purchaseResult.continuedays

        local rewardList = {}
        local RewardTipDef = import("src.app.plugins.RewardTip.RewardTipDef")
        -- 计费点部分 银子
        table.insert(rewardList, {nType = RewardTipDef.TYPE_SILVER, nCount = purchaseResult.rewardcount})
        -- 额外部分
        local extraReward = purchaseResult.dayextrareward
        for i = 1, #extraReward.rewardtypelist do
            local rewardType = self:getRewardTipType(extraReward.rewardtypelist[i], extraReward.propidlist[i])
            table.insert(rewardList, {nType = rewardType, nCount = extraReward.rewardcountlist[i]})
        end
        
        my.informPluginByName({pluginName = 'RewardTipCtrl', params = {data = rewardList}})
        -- 道具
        local PropModel = require("src.app.plugins.shop.prop.PropModel"):getInstance()
        PropModel:updatePropByReq(rewardList)
        -- 记牌器
        local CardRecorderModel = import("src.app.plugins.shop.cardrecorder.CardRecorderModel"):getInstance()
        CardRecorderModel:updateByReq(rewardList)
        -- 定时赛门票
        local TimingGameModel = import('src.app.plugins.TimingGame.TimingGameModel'):getInstance()
        TimingGameModel:reqTimingGameInfoData()

        self:dispatchEvent({name = ValuablePurchaseModel.EVENT_BUY_PURCHASE_OK, value = {purchaseId = purchaseResult.purchaseid}})
    end
end

function ValuablePurchaseModel:startPluginProcess()
    local PluginProcessModel = mymodel("hallext.PluginProcessModel"):getInstance()
    if self._enable then
        PluginProcessModel:setPluginReadyStatus("ValuablePurchase", true)
        PluginProcessModel:startPluginProcess()
    else
        PluginProcessModel:setPluginReadyStatus("ValuablePurchase", false)
        PluginProcessModel:startPluginProcess()
    end
end

function ValuablePurchaseModel:onLoginOff()
    self:initData()
end

function ValuablePurchaseModel:stopWaitingTimer()
    if self._timerWaitingPay then
        local scheduler = cc.Director:getInstance():getScheduler()
        scheduler:unscheduleScriptEntry(self._timerWaitingPay)
        self._timerWaitingPay = nil
    end
end

function ValuablePurchaseModel:startWaitingPayTimer()
    self:stopWaitingTimer()
    local scheduler = cc.Director:getInstance():getScheduler()
    self._timerWaitingPay = scheduler:scheduleScriptFunc(function()
        self:stopWaitingTimer()
    end, 3, false)
end

function ValuablePurchaseModel:isEnable()
    return self._enable
end

function ValuablePurchaseModel:getPurchaseItemList()
    return self._purchaseItemList
end

function ValuablePurchaseModel:validatePurchaseItem(todayDate, purchaseId)
    for i = 1, #self._purchaseItemList do
        local purchaseItem = self._purchaseItemList[i]
        if purchaseItem.id == purchaseId then
            if todayDate > purchaseItem.purchasedate then
                return true
            end
        end
    end
    return false
end

function ValuablePurchaseModel:getPurchaseItemByPurchaseId(purchaseId)
    for i = 1, #self._purchaseItemList do
        local purchaseItem = self._purchaseItemList[i]
        if purchaseItem.id == purchaseId then
            return purchaseItem
        end
    end
    return nil
end

function ValuablePurchaseModel:isValuablePurchasePayResult(exchangeid)
    for i = 1, #self._purchaseItemList do
        local purchaseItem = self._purchaseItemList[i]
        if purchaseItem.exchangeid == exchangeid then
            return true
        end
    end
    return false
end

function ValuablePurchaseModel:isNeedRedDot()
    local todayDate = tonumber(self:getTodayDate())
    for i = 1, #self._purchaseItemList do
        local purchaseItem = self._purchaseItemList[i]
        if purchaseItem.continuedays > 0 and purchaseItem.purchasedate < todayDate then
            return true
        end
    end

    return false
end

function ValuablePurchaseModel:getTodayDate()
    return os.date("%Y%m%d", os.time())
end

return ValuablePurchaseModel