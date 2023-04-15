local RechargeFlopCardModel = class("RechargeFlopCardModel", require('src.app.GameHall.models.BaseModel'))
local AssistModel = mymodel('assist.AssistModel'):getInstance()
local user = mymodel('UserModel'):getInstance()
local Def = import("src.app.plugins.RewardTip.RewardTipDef")

my.addInstance(RechargeFlopCardModel)
protobuf.register_file("src/app/plugins/RechargeFlopCard/pbRechargeFlopCard.pb")

local PropNumbers = {
    GR_RECHARGE_FLOP_CARD_STATUS = 500301,
    GR_RECHARGE_FLOP_CARD_FLOP = 500302,
    GR_RECHARGE_FLOP_CARD_OPEN_BOX = 500303,
    GR_RECHARGE_FLOP_CARD_PAY_OK = 500304,
    GR_RECHARGE_FLOP_CARD_TAKE_SILVER = 500306
}

RechargeFlopCardModel.Events = {
    RECHARGE_FLOP_CARD_HALL_STATUS_UPDATE = "RECHARGE_FLOP_CARD_HALL_STATUS_UPDATE",
    RECHARGE_FLOP_CARD_CTRL_STATUS_UPDATE = "RECHARGE_FLOP_CARD_CTRL_STATUS_UPDATE",
    RECHARGE_FLOP_CARD_CTRL_RSP_FLOP = "RECHARGE_FLOP_CARD_CTRL_RSP_FLOP",
    RECHARGE_FLOP_CARD_CTRL_RSP_OPEN_BOX = "RECHARGE_FLOP_CARD_CTRL_RSP_OPEN_BOX",
    RECHARGE_FLOP_CARD_CTRL_RSP_PAY_OK = "RECHARGE_FLOP_CARD_CTRL_RSP_PAY_OK",
    RECHARGE_FLOP_CARD_CTRL_RSP_TAKE_SILVER = "RECHARGE_FLOP_CARD_CTRL_RSP_TAKE_SILVER"
}

RechargeFlopCardModel.Def = {
    CARD_COUNT = 5,
	BOX_COUNT = 3,

    CARD_TYPE_COUNT = 6,
    CARD_VALUE_COUNT = 5,
    SHOP_ITEM_CONFIG_COUNT = 3,

    RECHARGE_FLOP_CARD_APPTYPE_AN_TCY = 1,
	RECHARGE_FLOP_CARD_APPTYPE_AN_SINGLE = 2,
	RECHARGE_FLOP_CARD_APPTYPE_AN_SET = 3,
	RECHARGE_FLOP_CARD_APPTYPE_IOS_TCY = 4,
    RECHARGE_FLOP_CARD_APPTYPE_IOS_SINGLE = 5,

    CAN_NOT_UNLOCK = -2,
    CAN_UNLOCK = -1,
    CARD_10 = 0,
    CARD_J = 1,
    CARD_Q = 2,
    CARD_K = 3,
    CARD_A = 4,

    STATUS_TAKE_FAIL = 0,
	STATUS_TAKE_SUCCEED = 1,

    STATUS_CAN_NOT_TAKE = 0,
    STATUS_CAN_TAKE = 1,
    STATUS_HAS_TAKEN = 2,
}

function RechargeFlopCardModel:ctor()
    RechargeFlopCardModel.super.ctor(self)
    self:initHandlers()
    AssistModel:registCtrl(self, self._onReceivedData)
    AssistModel:addEventListener(AssistModel.ASSIST_CONNECT_OK, handler(self, self._onAssistConOk))
    self._lastLoginUserID   = nil       -- 最后登陆用户ID
end

function RechargeFlopCardModel:isOpen()
    if not cc.exports.isRechargeFlopCardSupport() then
        return false
    end
    if not self._status or self._status.status ~= "ServiceOK" then
        return false
    end
    return true
end

function RechargeFlopCardModel:loginUserChange()
    if self._lastLoginUserID and self._lastLoginUserID ~= user.nUserID then
        self:reqStatus(0)
    end

    self._lastLoginUserID   = user.nUserID      -- 最后登陆用户ID
end

function RechargeFlopCardModel:isNeedShowRedDot()
    if not cc.exports.isRechargeFlopCardSupport() or not self:isOpen() then
        return false
    end
    local bNeed = false
    for i = 1, self.Def.CARD_COUNT do
        if self._status.flop_cards and self._status.flop_cards[i] == self.Def.CAN_UNLOCK then
            bNeed = true
        end
    end
    for i = 1, self.Def.BOX_COUNT do
        if self._status.box_status and self._status.box_status[i] == self.Def.STATUS_CAN_TAKE then
            bNeed = true
        end
    end

    local collectedRewardSilver = self:getCollectedRewardSilver()                              -- 已领取银两数量
    local toBeCollectedRewardSilver = self:getCurRewardSilver() - collectedRewardSilver        -- 待领取银两数量   

    if toBeCollectedRewardSilver > 0 then
        bNeed = true
    end
    return bNeed
end

function RechargeFlopCardModel:showRewards(items)
    local list = {}
    for _, v in pairs(items or {}) do
        if v.rewardtype and v.rewardcount then
            table.insert(list, { nType = v.rewardtype, nCount = v.rewardcount })
        end
    end
    if #list > 0 then
        my.informPluginByName({pluginName = "RewardTipCtrl", params = {data = list}})
        -- 更新奖励数据
        self:update(false, list)
    end
end

function RechargeFlopCardModel:update(forceUpdate, rewardList)
    if type(rewardList) ~= 'table' then
        rewardList = {}
    end
    local bHasDeposit = false
    local bHasVoucher = false
    local bHasProp = false
    local bHasTimingTicket = false
    local bHasCardMaker = false
    if not forceUpdate then
        for _, v in pairs(rewardList) do
            local t = v.nType
            if t == Def.TYPE_ROSE or t == Def.TYPE_LIGHTING or t == Def.TYPE_PROP_LIANSHENG or t == Def.TYPE_PROP_BAOXIAN then
                bHasProp = true
            elseif t == Def.TYPE_CARDMARKER_1D or t ==  Def.TYPE_CARDMARKER_7D or t == Def.TYPE_CARDMARKER_30D or t == Def.TYPE_CARDMARKER then
                bHasCardMaker = true
            elseif t == Def.TYPE_REWARDTYPE_TIMINGGAME_TICKET then
                bHasTimingTicket = true
            elseif t == Def.TYPE_SILVER then
                bHasDeposit = true
            elseif t == Def.TYPE_TICKET then
                bHasVoucher = true
            end
        end
    end
    if forceUpdate or bHasDeposit then
        mymodel('hallext.PlayerModel'):getInstance():update( { 'UserGameInfo' })
    end
    if forceUpdate or bHasVoucher then
        local ExchangeCenterModel = import("src.app.plugins.ExchangeCenter.ExchangeCenterModel"):getInstance()
        ExchangeCenterModel:getTicketNum()
    end
    if forceUpdate or bHasProp then
        local PropModel = require('src.app.plugins.shop.prop.PropModel'):getInstance()
        PropModel:updatePropByReq(rewardList)
    end
    if forceUpdate or bHasCardMaker then
        local CardRecorderModel = import("src.app.plugins.shop.cardrecorder.CardRecorderModel"):getInstance()
        CardRecorderModel:updateByReq(rewardList)
    end
    if forceUpdate or bHasTimingTicket then 
        local TimingGameModel = import('src.app.plugins.TimingGame.TimingGameModel'):getInstance()
        TimingGameModel:reqTimingGameInfoData()
    end
end

function RechargeFlopCardModel:_onAssistConOk()
    self:reqStatus(0)
end

function RechargeFlopCardModel:isResponseID(responseId)
    if self._handlers[responseId] then
        return true
    end
    return false
end

function RechargeFlopCardModel:_onReceivedData(dataMap)
    local responseId, rawdata = unpack(dataMap.value)
    if type(self._handlers[responseId]) == 'function' then
        self._handlers[responseId](rawdata)
    end
end

function RechargeFlopCardModel:initHandlers()
    self._handlers = {}
    self._handlers[PropNumbers.GR_RECHARGE_FLOP_CARD_STATUS] = function (rawdata)
        self:OnRspStatus(rawdata)
    end
    self._handlers[PropNumbers.GR_RECHARGE_FLOP_CARD_FLOP] = function (rawdata)
        self:OnRspFlop(rawdata)
    end
    self._handlers[PropNumbers.GR_RECHARGE_FLOP_CARD_OPEN_BOX] = function (rawdata)
        self:OnRspOpenBox(rawdata)
    end
    self._handlers[PropNumbers.GR_RECHARGE_FLOP_CARD_PAY_OK] = function (rawdata)
        self:OnRspPayOK(rawdata)
    end
    self._handlers[PropNumbers.GR_RECHARGE_FLOP_CARD_TAKE_SILVER] = function (rawdata)
        self:OnRspTakeSilver(rawdata)
    end
end

function RechargeFlopCardModel:saveTodayRechargePackagePop()
    local CacheModel = cc.exports.CacheModel
    if not CacheModel then return end
    if user.nUserID == nil or user.nUserID < 0 then return end

    local info = {
        timeStamp = self:getCurrentDayStamp() or 0
    }
    CacheModel:saveInfoToCache("RechargeFlopCardModel_recharge_package"..user.nUserID, info)
end

function RechargeFlopCardModel:getCurrentDayStamp()
    local data = os.date("*t", os.time())
    data.hour = 0
    data.min = 0
    data.sec = 0

    local day = data.day
    local month = data.month * 100
    local year = data.year * 10000

    local stamp = year + month + day
    return stamp
end

--每日首次点击去充值、锁弹出礼包购买，其他时候弹出商城
function RechargeFlopCardModel:isNeedPopRechargePackage()
    if self:isOpen() then
        local CacheModel = cc.exports.CacheModel
        if not CacheModel then return false end
        if user.nUserID == nil or user.nUserID < 0 then return false end

        local info = CacheModel:getCacheByKey("RechargeFlopCardModel_recharge_package"..user.nUserID)
        local curStamp = self:getCurrentDayStamp()
        if info.timeStamp == curStamp then
            return false
        else
            return true
        end
    end

    return false
end

function RechargeFlopCardModel:saveOneKeyCache()
    local CacheModel = cc.exports.CacheModel
    if not CacheModel then return end
    if user.nUserID == nil or user.nUserID < 0 then return end

    local info = {
        timeStamp = self:getCurrentDayStamp() or 0
    }
    CacheModel:saveInfoToCache("RechargeFlopCardModel_one_key_recharge"..user.nUserID, info)
end

--一键充值每天只能充一次 如果五张牌都解锁了也不可点
function RechargeFlopCardModel:isOneKeyRechargeEnable()
    if self:isOpen() then
        local CacheModel = cc.exports.CacheModel
        if not CacheModel then return false end
        if user.nUserID == nil or user.nUserID < 0 then return false end

        local info = CacheModel:getCacheByKey("RechargeFlopCardModel_one_key_recharge"..user.nUserID)
        local curStamp = self:getCurrentDayStamp()
        if info.timeStamp == curStamp then
            return false
        else
            local bRet = false
            for  i = 1, self.Def.CARD_COUNT do
                local cardStatus = self:getCardStatusByIndex(i)
                if cardStatus and cardStatus == self.Def.CAN_NOT_UNLOCK then
                   bRet = true 
                end
            end
            return bRet
        end
    end

    return false
end

function RechargeFlopCardModel:getStatus()
    return self._status
end

function RechargeFlopCardModel:getConfig()
    return (self._status or {}).config
end

--获取当前玩家充值配置 基础银、充值所需、一键充值商品配置、宝箱奖励
function RechargeFlopCardModel:getRechargeConfig()
    local config = self:getConfig()
    if not config then return nil end
    local rechargeConfig = (config.recharge_config or {})[1]
    return rechargeConfig
end

--获取基础银配置
function RechargeFlopCardModel:getBaseSilver()
    local config = self:getRechargeConfig()
    if not config or not config.base_silver then return 0 end
    return config.base_silver
end

--获取翻牌所需充值额度配置
function RechargeFlopCardModel:getRechargeNeed()
    local config = self:getRechargeConfig()
    if not config or not config.recharge_need or #config.recharge_need ~= self.Def.CARD_COUNT then return nil end
    return config.recharge_need
end

--当前倍数，默认-1
function RechargeFlopCardModel:getCurMultiply()
    local status = self:getStatus()
    if not status 
    or not status.card_type_multiply 
    or not status.card_value_multiply 
    or not status.final_multiply then return -1,-1,-1 end
    return status.card_type_multiply, status.card_value_multiply, status.final_multiply
end

--获取当前奖励银子数量
function RechargeFlopCardModel:getCurRewardSilver()
    local status = self:getStatus()
    if not status then return 0 end
    return status.total_reward_value
end

--获取已经银子数量
function RechargeFlopCardModel:getCollectedRewardSilver()
    local status = self:getStatus()
    if not status then return 0 end
    return status.collected_reward_value
end

--获取当前充值金额
function RechargeFlopCardModel:getCurRecharge()
    local status = self:getStatus()
    if not status or not status.current_recharge then return 0 end
    return status.current_recharge
end

--获取牌型倍数规则 依次是2张、3张、3带2、4炸、5炸、同花顺倍数
function RechargeFlopCardModel:getTypeMultiplyRule()
    local config = self:getConfig()
    if not config or not config.card_type_multiply or #config.card_type_multiply < self.Def.CARD_TYPE_COUNT then return nil end
    return config.card_type_multiply
end

--获取最终倍数规则
function RechargeFlopCardModel:getFinalMultiplyRule()
    local config = self:getConfig()
    if not config or not config.final_multiply then return nil end
    return config.final_multiply
end

--获取最终倍数范围
function RechargeFlopCardModel:getFinalMultiplyRange()
    local finalMulRule = self:getFinalMultiplyRule()
    if not finalMulRule then return 1, 9 end
    table.sort(finalMulRule)
    local maxMul = finalMulRule[#finalMulRule]
    local minMul = finalMulRule[1]
    return minMul, maxMul
end

--获取牌值倍数规则 依次是10JQKA倍数
function RechargeFlopCardModel:getValueMultiplyRule()
    local config = self:getConfig()
    if not config or not config.card_value_multiply or #config.card_value_multiply < self.Def.CARD_VALUE_COUNT then return nil end
    return config.card_value_multiply
end

--获取一键购买的商品配置 依次是价格、银子、ExchangeID
function RechargeFlopCardModel:getShopItemConfig()
    local config = self:getRechargeConfig()
    if not config or #config.one_key_recharge ~= self.Def.SHOP_ITEM_CONFIG_COUNT then return nil end
    return config.one_key_recharge
end

function RechargeFlopCardModel:getCurCardIndex()
    local index = 1
    for i = 1, self.Def.CARD_COUNT + 1 do 
        if self._status.flop_cards[index] ~= -2 then
            index = index + 1
        else
            break
        end
    end
    return index
end

--获取单次购买的商品配置
function RechargeFlopCardModel:getSingleItemConfig()
    local config = self:getRechargeConfig()
    local index = self:getCurCardIndex()

    if not config or index > self.Def.CARD_COUNT then return config.card_rewards[self.Def.CARD_COUNT] end
    return config.card_rewards[index]
end

--根据Index获取单次购买的商品配置
function RechargeFlopCardModel:getSingleItemConfigByIndex(index)
    local config = self:getRechargeConfig()

    if not config or index > self.Def.CARD_COUNT then return config.card_rewards[self.Def.CARD_COUNT] end
    return config.card_rewards[index]
end

--获取宝箱奖励
function RechargeFlopCardModel:getBoxRewardConfig(index)
    if index > self.Def.BOX_COUNT or index <= 0 then return nil end
    local config = self:getRechargeConfig()
    if not config then return nil end
    if index == 1 then
        return config.normal_box_reward
    elseif index == 2 then 
        return config.big_box_reward 
    elseif index == 3 then
        return config.super_box_reward 
    end
    return nil
end

--获取牌张状态 分别是未解锁、可翻牌、10、J、Q、K、A
function RechargeFlopCardModel:getCardStatusByIndex(index)
    if index > self.Def.CARD_COUNT or index <= 0 then return nil end
    local status = self:getStatus()
    if not status or not status.flop_cards then return nil end
    return status.flop_cards[index]
end

--获取宝箱状态 分别是不可领、可领取、已领取
function RechargeFlopCardModel:getBoxStatusByIndex(index)
    if index > self.Def.BOX_COUNT or index <= 0 then return nil end
    local status = self:getStatus()
    if not status or not status.box_status then return nil end
    if status.box_status[index] == self.Def.STATUS_CAN_TAKE then --判断是否翻开了N张牌
        local count = 0
        for i = 1, self.Def.CARD_COUNT do
            local cardStatus = self:getCardStatusByIndex(i)
            if cardStatus and cardStatus >= self.Def.CARD_10 then
                count = count + 1
            end
        end
        if index == 1 and count >= 2 then
            return self.Def.STATUS_CAN_TAKE
        elseif index == 2 and count >= 3 then
            return self.Def.STATUS_CAN_TAKE
        elseif index == 3 and count >= 5 then
            return self.Def.STATUS_CAN_TAKE
        else
            return self.Def.STATUS_CAN_NOT_TAKE
        end
    end
    return status.box_status[index]
end

--获取最大奖励数量 max(同花顺倍数, 五个A倍数)
function RechargeFlopCardModel:getMaxRewardNum()
    local num = 0; 
    local typeMul = self:getTypeMultiplyRule()
    local valueMul = self:getValueMultiplyRule()
    local finalMul = self:getFinalMultiplyRule()
    local base = self:getBaseSilver()
    if base > 0 and typeMul and valueMul and finalMul then
        local finNum = 0
        for i = 1, #finalMul do
            if finalMul[i] > finNum then
                finNum = finalMul[i]
            end
        end
        local valueSum = 0
        for i = 1, self.Def.CARD_COUNT do
            valueSum = valueSum + valueMul[i]
        end
        local tonghua = typeMul[self.Def.CARD_TYPE_COUNT] * valueSum * finNum
        local wuzha = typeMul[self.Def.CARD_TYPE_COUNT - 1] * (valueMul[self.Def.CARD_COUNT] * self.Def.CARD_COUNT) *finNum
        num = math.max(tonghua, wuzha) * base
    end
    return num
end

--翻牌时显示倍数所需 返回牌值倍数字体路径、牌值倍数
function RechargeFlopCardModel:getValueMulFontPathAndMul(index, cardStatus)
    local rule = self:getValueMultiplyRule()
    if not cardStatus or cardStatus < self.Def.CARD_10 
    or cardStatus > self.Def.CARD_A  or not rule then return nil, nil end
    
    local path = {
        "hallcocosstudio/images/font/RechargeFlopCard/fnt_beishu_1.fnt",
        "hallcocosstudio/images/font/RechargeFlopCard/fnt_beishu_2.fnt",
        "hallcocosstudio/images/font/RechargeFlopCard/fnt_beishu_3.fnt",
        "hallcocosstudio/images/font/RechargeFlopCard/fnt_beishu_4.fnt",
        "hallcocosstudio/images/font/RechargeFlopCard/fnt_beishu_5.fnt",
    }

    return path[cardStatus + 1], rule[cardStatus + 1]
end

function RechargeFlopCardModel:reqStatus(isNeed)
    print("RechargeFlopCardModel:reqStatus")
    if not cc.exports.isRechargeFlopCardSupport()  then
        return
    end
      
    if user.nUserID == nil or user.nUserID < 0 then
        print("userinfo is not ok")
        return
    end

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

    local data = {
        userid = user.nUserID,
        platform = platFormType,
        isNeedLevel = isNeed
    }
    local pbdata = protobuf.encode("pbRechargeFlopCard.ReqStatus", data)
    AssistModel:sendData(PropNumbers.GR_RECHARGE_FLOP_CARD_STATUS, pbdata)
end

function RechargeFlopCardModel:OnRspStatus(data)
    if string.len(data) == nil then return nil end
    if not cc.exports.isRechargeFlopCardSupport()  then return end

    local pdata = protobuf.decode('pbRechargeFlopCard.RspStatus', data)
    protobuf.extract(pdata)
    dump(pdata, "RechargeFlopCardModel:OnRspStatus")

    self._status = pdata
    self:dispatchEvent({name = self.Events.RECHARGE_FLOP_CARD_HALL_STATUS_UPDATE})
    self:dispatchEvent({name = self.Events.RECHARGE_FLOP_CARD_CTRL_STATUS_UPDATE})
end

function RechargeFlopCardModel:reqFlop(index)
    local data = {
        userid = user.nUserID,
        index = index,
        channel_id = BusinessUtils:getInstance():getTcyChannel(),
    }
    local pbdata = protobuf.encode("pbRechargeFlopCard.ReqFlop", data)
    AssistModel:sendData(PropNumbers.GR_RECHARGE_FLOP_CARD_FLOP, pbdata)
end

function RechargeFlopCardModel:OnRspFlop(data)
    if string.len(data) == nil then return nil end
    if not cc.exports.isRechargeFlopCardSupport()  then return end

    local pdata = protobuf.decode('pbRechargeFlopCard.RspFlop', data)
    protobuf.extract(pdata)
    dump(pdata, "RechargeFlopCardModel:OnRspFlop")
    local index = pdata.index
    local bNeedRequest = false
    if pdata.status.status == "ServiceClose" or index > self.Def.CARD_COUNT or index <= 0 then
        my.informPluginByName({pluginName = 'TipPlugin',params = {tipString = "服务器繁忙，请稍后再试!", removeTime = 3}})
        bNeedRequest = true
    else
        if pdata.status.flop_cards[index] <= self.Def.CAN_UNLOCK then
            my.informPluginByName({pluginName = 'TipPlugin',params = {tipString = "翻牌失败，请稍后再试!", removeTime = 3}})
            bNeedRequest = true
        end
        self._status = pdata.status
        self:dispatchEvent({name = self.Events.RECHARGE_FLOP_CARD_HALL_STATUS_UPDATE})
        self:dispatchEvent({name = self.Events.RECHARGE_FLOP_CARD_CTRL_RSP_FLOP, value = {index = index, card = pdata.status.flop_cards[index], final = pdata.status.final_multiply}})
    end
    if bNeedRequest then
        self:reqStatus(1)
    end
end

function RechargeFlopCardModel:reqTakeSilver()
    local data = {
        userid = user.nUserID,
    }
    local pbdata = protobuf.encode("pbRechargeFlopCard.ReqTakeSilver", data)
    AssistModel:sendData(PropNumbers.GR_RECHARGE_FLOP_CARD_TAKE_SILVER, pbdata)
    my.scheduleOnce(function()
        self:reqStatus(1)
    end, 0.5)  
end

function RechargeFlopCardModel:OnRspTakeSilver(data)
    if string.len(data) == nil then return nil end
    if not cc.exports.isRechargeFlopCardSupport()  then return end

    local pdata = protobuf.decode('pbRechargeFlopCard.RepTakeSilver', data)
    protobuf.extract(pdata)
    dump(pdata, "RechargeFlopCardModel:OnRspTakeSilver")

     --刷新银两
    local playerModel = mymodel("hallext.PlayerModel"):getInstance()
    playerModel:update({'SafeboxInfo','MemberInfo','UserGameInfo'})

    if pdata.silverCount >0 then
        -- local rewardList = {}
        -- table.insert( rewardList,{nType = 1,nCount = pdata.silverCount})
        -- my.informPluginByName({pluginName = 'RewardTipCtrl', params = {data = rewardList,showOkOnly = true}})

        self._status.collected_reward_value = self._status.collected_reward_value + pdata.silverCount

        self:dispatchEvent({name = self.Events.RECHARGE_FLOP_CARD_CTRL_RSP_TAKE_SILVER})
        self:dispatchEvent({name = self.Events.RECHARGE_FLOP_CARD_HALL_STATUS_UPDATE})
    end

end

function RechargeFlopCardModel:reqOpenBox(index)
    local data = {
        userid = user.nUserID,
        index = index,
    }
    local pbdata = protobuf.encode("pbRechargeFlopCard.ReqOpenBox", data)
    AssistModel:sendData(PropNumbers.GR_RECHARGE_FLOP_CARD_OPEN_BOX, pbdata)
end

function RechargeFlopCardModel:OnRspOpenBox(data)
    if string.len(data) == nil then return nil end
    if not cc.exports.isRechargeFlopCardSupport()  then return end

    local pdata = protobuf.decode('pbRechargeFlopCard.RspOpenBox', data)
    protobuf.extract(pdata)
    dump(pdata, "RechargeFlopCardModel:OnRspOpenBox")
    local index = pdata.index
    local bNeedRequest = false
    if pdata.status.status == "ServiceClose" or not pdata.awards_status or pdata.awards_status == self.Def.STATUS_TAKE_FAIL then
        my.informPluginByName({pluginName = 'TipPlugin',params = {tipString = "服务器繁忙，请稍后再试!", removeTime = 3}})
        bNeedRequest = true
    else
        if pdata.status.box_status[index] <= self.Def.STATUS_CAN_TAKE then
            my.informPluginByName({pluginName = 'TipPlugin',params = {tipString = "服务器繁忙，请稍后再试!", removeTime = 3}})
            bNeedRequest = true
        end
        self._status = pdata.status
        self:dispatchEvent({name = self.Events.RECHARGE_FLOP_CARD_HALL_STATUS_UPDATE})
        -- if my.isPluginVisible() then
            self:dispatchEvent({name = self.Events.RECHARGE_FLOP_CARD_CTRL_RSP_OPEN_BOX}) --交给ctrl显示奖励
        -- else
            --手动显示下奖励
            local config = self:getBoxRewardConfig(index)
            if config then
                self:showRewards(config)
            end
        -- end
    end
    if bNeedRequest then
        self:reqStatus(1)
    end
end

function RechargeFlopCardModel:OnRspPayOK(data)
    if string.len(data) == nil then return nil end
    if not cc.exports.isRechargeFlopCardSupport()  then return end

    local pdata = protobuf.decode('pbRechargeFlopCard.RspRecharge', data)
    protobuf.extract(pdata)
    dump(pdata, "RechargeFlopCardModel:OnRspPayOK")

    if pdata.status.status == "ServiceClose" then
        bNeedRequest = true
    else
        local rechargeConfig = self:getShopItemConfig()
        if rechargeConfig[3] == pdata.exchange_id then
            self:saveOneKeyCache()
        end
        self._status = pdata.status

        local config = self._status.config
        local index = self:getCurCardIndex()
        local rewards = pdata.silverCount

        --刷新银两
        local playerModel = mymodel("hallext.PlayerModel"):getInstance()
        playerModel:update({'SafeboxInfo','MemberInfo','UserGameInfo'})
    
        if rewards > 0 then
            local rewardList = {}
            table.insert( rewardList,{nType = 1,nCount = rewards})
            my.informPluginByName({pluginName = 'RewardTipCtrl', params = {data = rewardList,showOkOnly = true}})
        end

        self:dispatchEvent({name = self.Events.RECHARGE_FLOP_CARD_HALL_STATUS_UPDATE})
        self:dispatchEvent({name = self.Events.RECHARGE_FLOP_CARD_CTRL_RSP_PAY_OK})
    end
end

return RechargeFlopCardModel