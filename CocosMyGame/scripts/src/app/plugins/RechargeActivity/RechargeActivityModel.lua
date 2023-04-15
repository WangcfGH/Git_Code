local RechargeActivityModel =class('RechargeActivityModel',require('src.app.GameHall.models.BaseModel'))
-- local AssistConnect         = import('src.app.plugins.AssistModel.AssistConnect')
local Req                   = import('src.app.plugins.RechargeActivity.RechargeActivityReq')
local Def                   = import('src.app.plugins.RechargeActivity.RechargeActivityDef')
local treepack              = cc.load('treepack')
local json                  = cc.load("json").json
local user = mymodel('UserModel'):getInstance()
local AssistModel = mymodel('assist.AssistModel'):getInstance()

-- my.addInstance(RechargeActivityModel)

-- RechargeActivityModel.EVENT_RECHARGE_INFO_UPDATE = "EVENT_RECHARGE_INFO_UPDATE"
-- RechargeActivityModel.EVENT_GET_LOTTERY_RESULT = "EVENT_GET_LOTTERY_RESULT"
-- RechargeActivityModel.EVENT_GET_LOTTERY_FAILED = "EVENT_GET_LOTTERY_FAILED"

-- RechargeActivityModel.TYPE_SILVER = 0       --银子
-- RechargeActivityModel.TYPE_TICKET = 1       --礼券
-- RechargeActivityModel.COLOR_PURPLE = 0      --紫色
-- RechargeActivityModel.COLOR_RED = 1         --红色
-- function RechargeActivityModel:ctor()
--     local event = cc.load('event')
--     event:create():bind(self)
--     self._info = nil
--     self._config = nil
-- end

RechargeActivityModel.EVENT_MAP = {
    ["rechargeAct_rewardAvailChanged"] = "rechargeAct_rewardAvailChanged"
}

function RechargeActivityModel:onCreate()
    self._info = nil
    self._config = nil
    self._newGear = 2
    self._savedLotteryInfo = {}
    self._savedLotteryInfo.specialPrice = nil
    self._savedLotteryInfo.exchangeID = nil


    self._assistResponseMap = {
        [Def.GR_RECHARGE_INFO_RESP] = handler(self, self.rechargeInfoResp),
        [Def.GR_RECHARGE_LOTTERY_RESP] = handler(self, self.rechargeLotteryResp),
        [Def.GR_RECHARGE_LOTTERY_FAILED] = handler(self, self.rechargeLotteryFailed)
    }
    AssistModel:registCtrl(self, self.dealAssistResponse)
end

function RechargeActivityModel:setspecialPrice(vaule)
    self._savedLotteryInfo.specialPrice = vaule
end

function RechargeActivityModel:setexchangeID(value)
    self._savedLotteryInfo.exchangeID = value
end

-- 获取抽奖信息
function RechargeActivityModel:getLotteryInfo()
    return self._savedLotteryInfo
end

function RechargeActivityModel:reset()
    self._info = nil
    self._config = nil
end

-- --------------------------------------------------------------------------------------------------------
-- --消息接口
-- --充值活动信息请求
function RechargeActivityModel:rechargeInfoReq()
    if self._isWaitingInfo then return end
    self._isWaitingInfo = true
    my.scheduleOnce(function()
        self._isWaitingInfo = false
    end, 2)

    if user.nUserID == nil or user.nUserID < 0 then
        print("userinfo is not ok")
        return
    end

    local data      = {
        nUserID     = user.nUserID,
    }

    AssistModel:sendRequest(Def.GR_RECHARGE_INFO_REQ, Req.RECHARGE_INFO_REQ, data, false)
end

function RechargeActivityModel:rechargeInfoResp(data)
    print("RechargeActivityModel:rechargeInfoResp")
    local info,strJson = AssistModel:convertDataToStruct(data,Req["RECHARGE_LOTTERY_INFO_RESP"])
    if not info then return end
    dump(info)

    if info.open == 0 then
        --登录弹窗模块
        local PluginProcessModel = mymodel('hallext.PluginProcessModel'):getInstance()
        PluginProcessModel:setPluginReadyStatus("RechargeActivityCtrl",false)
        PluginProcessModel:startPluginProcess()
    else
        self._info = info
        if string.len(strJson) ~= 0 then
            self._config = cc.load("json").json.decode(strJson)
            dump(self._config)
        end

        -- local mainCtrl = cc.load('MainCtrl'):getInstance()
        -- mainCtrl:updateBtnRechargeActivity(true)
        self:notifyRewardStatus()

        --登录弹窗模块
        local PluginProcessModel = mymodel('hallext.PluginProcessModel'):getInstance()
        PluginProcessModel:setPluginReadyStatus("RechargeActivityCtrl",true)
        PluginProcessModel:startPluginProcess()
    end
    self:dispatchEvent({name = Def.EVENT_RECHARGE_INFO_UPDATE})
end

--充值抽奖请求
function RechargeActivityModel:rechargeLotteryReq()
    if self._isWaitingLotteryResult then return end
    self._isWaitingLotteryResult = true
    my.scheduleOnce(function()
        self._isWaitingLotteryResult = false
    end, 2)
    
    local data      = {
        nUserID     = user.nUserID,
        szUserName  = user.szUsername
    }

    AssistModel:sendRequest(Def.GR_RECHARGE_LOTTERY_REQ, Req.RECHARGE_LOTTERY_REQ, data, false)
end

--充值抽奖回应
function RechargeActivityModel:rechargeLotteryResp(data)
    print("RechargeActivityModel:rechargeLotteryResp")
    if not self._config then return end

    local lotteryResult = AssistModel:convertDataToStruct(data,Req["RECHARGE_LOTTERY_DRAW_RESP"])
    if not lotteryResult then return end
    dump(lotteryResult)

    if lotteryResult.nResult == 0 then
        local index = lotteryResult.nIndex
        local status = self:GetAwardStatus()
        self:dispatchEvent({name = Def.EVENT_GET_LOTTERY_RESULT,value = {nIndex = index,nStatus = status}})
        self:decDrawCount()
        self:SetAwardStatus(index)
    else
        local tipString = "抽奖失败"
        my.informPluginByName({pluginName='TipPlugin',params={tipString=tipString,removeTime=2.0}})
    end
end

--抽奖失败
function RechargeActivityModel:rechargeLotteryFailed(data)
    print("RechargeActivityModel:rechargeLotteryFailed")
    local tipString = "抽奖失败"
    --抽奖失败同步银子、礼券信息
    my.informPluginByName({pluginName='TipPlugin',params={tipString=tipString,removeTime=2.0}})
    local ExchangeCenterModel   = import("src.app.plugins.ExchangeCenter.ExchangeCenterModel"):getInstance()
    if ExchangeCenterModel then
        ExchangeCenterModel:getTicketNum()
    end
    local PlayerModel           = mymodel('hallext.PlayerModel'):getInstance()
    PlayerModel:update({'SafeboxInfo','MemberInfo','UserGameInfo'})
    --
    local info,strJson = AssistModel:convertDataToStruct(data,Req["RECHARGE_LOTTERY_INFO_RESP"])
    if not info then return end
    dump(info)

    if info.open == 0 then
    else
        self._info = info
        if string.len(strJson) ~= 0 then
            self._config = cc.load("json").json.decode(strJson)
            dump(self._config)
        end

        -- local mainCtrl = cc.load('MainCtrl'):getInstance()
        -- mainCtrl:updateBtnRechargeActivity(true)
        self:notifyRewardStatus()
    end
    self:dispatchEvent({name = Def.EVENT_GET_LOTTERY_FAILED})
end
-- --------------------------------------------------------------------------------------------------------
-- --[Comment]
-- --数据解析成table,并返回剩余的数据
-- function RechargeActivityModel:convertDataToStruct(data,struct_name)
--     if data == nil then return nil, nil end

--     local structDesc = AssistReq[struct_name]
--     if structDesc then
--         return treepack.unpack(data, structDesc), string.sub(data, structDesc.maxsize + 1)
--     else
--         return nil,nil
--     end
-- end

function RechargeActivityModel:GetConfig()
    return self._config
end

function RechargeActivityModel:GetInfo()
    return self._info
end


--[Comment]
--更新玩家银子和礼券的信息
function RechargeActivityModel:updateUserInfo(ItemInfo)
    if not ItemInfo then return end

    if ItemInfo.type == Def.TYPE_SILVER then
        local playerModel = mymodel("hallext.PlayerModel"):getInstance()
        playerModel:addGameDeposit(ItemInfo.count)
    elseif ItemInfo.type == Def.TYPE_TICKET then
        my.scheduleOnce( function()
            require("src.app.plugins.ExchangeCenter.ExchangeCenterModel"):getInstance():getTicketNum()
        end,0.8)
    end
end

--[Comment]
function RechargeActivityModel:GetItemInfoByIndex(nIndex)
    if not self._config then return end
    if nIndex<1 or nIndex>6 then return end
    local itemInfo = self._config["Gift"][nIndex]
    return itemInfo
end

--[Comment]
function RechargeActivityModel:SetAwardStatus(nIndex)
    if not self._info then return end

    local status = self._info.AwardStatus
    self._info.AwardStatus = bit._or(status,bit.lshift(1,4*(nIndex-1)))
end

--[Comment]
function RechargeActivityModel:GetAwardStatus()
    if self._info and self._info.AwardStatus then
        return self._info.AwardStatus
    end
end

--[Comment]
function RechargeActivityModel:decDrawCount( )
    if self._info and self._info.nDraw then
        self._info.nDraw = math.max(self._info.nDraw - 1,0)
    end
end

--[Comment]
function RechargeActivityModel:GetDrawCount()
    if self._info and self._info.nDraw then
        return self._info.nDraw
    end
end

--[Comment]
function RechargeActivityModel:isRewardedAll()
    if self._info and self._info.AwardStatus then
        if 0x00111111 == self._info.AwardStatus then
            return true
        end
    end
    return false
end

function RechargeActivityModel:notifyRewardStatus()
    self._myStatusDataExtended["isPluginAvail"] = true
    self._myStatusDataExtended["isNeedReddot"] = self:isRewardAvail()
    self._myStatusDataExtended["isNeedBtnAni"] = self:isRewardNotUsedUp()
    self:dispatchModuleStatusChanged("rechargeAct", RechargeActivityModel.EVENT_MAP["rechargeAct_rewardAvailChanged"])
end

--有抽奖次数并且当前即可抽奖
function RechargeActivityModel:isRewardAvail()
    local nDrawCount = self:GetDrawCount()
	if nDrawCount and nDrawCount > 0 then
		return true
	end
    return false
end

--有抽奖次数未用完（当前可抽奖或不可抽奖）
function RechargeActivityModel:isRewardNotUsedUp()
    local nDrawCount = self:GetDrawCount()
	if nDrawCount and nDrawCount > 0 then
		return true
	elseif nDrawCount == 0 then
		if self:isRewardedAll() then
			return false
		else
			return true
		end
	end
    return false
end

--收到充值服务器发出的消息，若成功则需要刷新客户端的界面
--读取配置文件中计费点的值
function RechargeActivityModel:isRechargeActivityPayResult(exchangeid)
    if self._config and self._config.LotteryConfig  then
        for i=1, #self._config.LotteryConfig do
            if self._config.LotteryConfig[i] == exchangeid then
                --充值成功后触发充值成功的事件，并记录充值的是第几档
                self._newGear = self._config.Gear[i]
                return true
            end
        end
    end
    return false
end

 return RechargeActivityModel