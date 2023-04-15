local ContinueRechargeModel  = class("ContinueRechargeModel", require('src.app.GameHall.models.BaseModel'))
local AssistModel = mymodel('assist.AssistModel'):getInstance()
local user = mymodel('UserModel'):getInstance()
local RewardTipDef = import("src.app.plugins.RewardTip.RewardTipDef")
local MyTimeStampCtrl = import("src.app.mycommon.mytimestamp.MyTimeStamp"):getInstance()

my.addInstance(ContinueRechargeModel)

local coms=cc.load('coms')
local PropertyBinder=coms.PropertyBinder
local WidgetEventBinder=coms.WidgetEventBinder
my.setmethods(ContinueRechargeModel,PropertyBinder)
my.setmethods(ContinueRechargeModel,WidgetEventBinder)

protobuf.register_file("src/app/plugins/continuerecharge/ContinueRecharge.pb")

ContinueRechargeModel.MsgNumbers = {
    GR_CONTINUERECHARGE_CONFIG_STATUS_REQ = 400000 + 2501,
    GR_CONTINUERECHARGE_EXCHANGE_REQ = 400000 + 2502,
    GR_CONTINUERECHARGE_PAYRESULT = 400000 + 2503,
    GR_CONTINUERECHARGE_RECHARGEOK_NTF = 400000 + 2504
}

ContinueRechargeModel.EVENT_UPDATE_DATA = 'EVENT_UPDATE_DATA'       
ContinueRechargeModel.EVENT_INIT_DATA = 'EVENT_INIT_DATA'           -- 界面全部刷新事件
ContinueRechargeModel.EVENT_ON_HUAFEI_RSP = 'EVENT_ON_HUAFEI_RSP'   -- 话费到账
ContinueRechargeModel.EVENT_CLOSE_CONTINUE_RECHARGE = 'EVENT_CLOSE_CONTINUE_RECHARGE'   -- 关闭界面

function ContinueRechargeModel:ctor()
    ContinueRechargeModel.super.ctor(self)
    self:initHandlers()
    AssistModel:registCtrl(self, self.onReceivedData)
    AssistModel:addEventListener(AssistModel.ASSIST_CONNECT_OK, handler(self, self.onAssistConOk))

    self._needPop = false

    self:listenTo(MyTimeStampCtrl, MyTimeStampCtrl.UPDATE_DAY,  handler(self,self.updateDay))
end

function ContinueRechargeModel:updateDay()
    self:reqConfigAndData()
end

function ContinueRechargeModel:isResponseID(responseId)
    if self._handlers == nil then
        print("no ContinueRechargeModel _handlers defined!!!")
        return false
    end

    if self._handlers[responseId] then
        return true
    end

    return false
end


function ContinueRechargeModel:initHandlers()
    self._handlers = {}
    self._handlers[ContinueRechargeModel.MsgNumbers.GR_CONTINUERECHARGE_CONFIG_STATUS_REQ] = function (rawdata)
        self:OnRspConfigAndStatus(rawdata)
    end

    self._handlers[ContinueRechargeModel.MsgNumbers.GR_CONTINUERECHARGE_EXCHANGE_REQ] = function (rawdata)
        self:onExchangeResult(rawdata)
    end

    self._handlers[ContinueRechargeModel.MsgNumbers.GR_CONTINUERECHARGE_PAYRESULT] = function (rawdata)
        self:OnRechargeOkNtf(rawdata)
    end
end

function ContinueRechargeModel:isOpen()
    local supportData = cc.exports.getContinueRechargeSupport()
    if not supportData.support then
        print("[INFO] The ContinueRecharge is not supported.")
        return false
    end

    if not self._enable then
        return false
    end

    if supportData.support ~= 1 then
       return false 
    end

    if not supportData.weak then
        if self._enable == 1 then
            return true
        end

        return false
    end

    return true
end

function ContinueRechargeModel:isNeedPop()
    if self._needPop then
        local CacheModel = cc.exports.CacheModel
        if not CacheModel then return false end
        if user.nUserID == nil or user.nUserID < 0 then return false end

        local info = CacheModel:getCacheByKey("ContinueRechargeModel"..user.nUserID)
        if info.timeStamp == self:getCurrentDayStamp() then
            return false
        else
            return true
        end
    end

    return false
end

function ContinueRechargeModel:isTodayClicked()
    return true
end

function ContinueRechargeModel:saveTodayPop()
    local CacheModel = cc.exports.CacheModel
    if not CacheModel then return end
    if user.nUserID == nil or user.nUserID < 0 then return end

    local info = {
        timeStamp = self:getCurrentDayStamp() or 0
    }
    CacheModel:saveInfoToCache("ContinueRechargeModel"..user.nUserID, info)
end

function ContinueRechargeModel:reqConfigAndData()
    local supportInfo = cc.exports.getContinueRechargeSupport()
    if supportInfo.support ~= 1 then
        print("ContinueRecharge not support")
        return
    end
    local data = {
        userid = user.nUserID or 0,
        packagetype = self:_getPackageType(),
        hardid = DeviceUtils:getInstance():getMacAddress(),
        weaksupport = (supportInfo.weak == 1)
    }

    local pdata = protobuf.encode("ContinueRecharge.ReqConfigAndStatus", data)
    AssistModel:sendData(ContinueRechargeModel.MsgNumbers.GR_CONTINUERECHARGE_CONFIG_STATUS_REQ, pdata)
end

function ContinueRechargeModel:reqExchange(exchangeInfo)
    local data = {
        userid = user.nUserID or 0,
        packagetype = self:_getPackageType(),
        type = tonumber(exchangeInfo.type),
        telphone = exchangeInfo.number,
        hardid = DeviceUtils:getInstance():getMacAddress(),
    }

    local pdata = protobuf.encode("ContinueRecharge.ReqExchange", data)
    AssistModel:sendData(ContinueRechargeModel.MsgNumbers.GR_CONTINUERECHARGE_EXCHANGE_REQ, pdata)
end

function ContinueRechargeModel:OnRspConfigAndStatus(rawdata)
    print("ContinueRecharge RspConfigAndStatus")
    self._enable = false
    self._needPop = false
    local data = cc.exports.pb_decode("ContinueRecharge.RspConfigAndStatus", rawdata) 
    if not data then
        print("[ERROR] pb-parse error, the package name is ContinueRecharge.RspConfigAndStatus.")
        return
    end
    dump(data)

    if data.enable and data.enable ~= 0 then
        self._enable = true
    else
        self:dispatchEvent( { name = self.EVENT_INIT_DATA })
        self:dispatchEvent( { name = self.EVENT_CLOSE_CONTINUE_RECHARGE })
        return
    end

    if not self:isOpen() then
        return
    end

    self._config = data.config
    self._status = data.status
    
    -- 初始化是否需要弹窗************
    local res = self:getCheckedByDayNumber(self:currentDayNum(self._status.startdate))
    if not res and self._enable then
        -- 在判断今天是否已经弹出过了
        self._needPop = true
    else
        self._needPop = false
    end
    if self:isNeedPop() then
        local PluginProcessModel = mymodel("hallext.PluginProcessModel"):getInstance()
        PluginProcessModel:setPluginReadyStatus("ContinueRechargeCtrl", true)
        PluginProcessModel:startPluginProcess()
    end
    self:dispatchEvent({name = ContinueRechargeModel.EVENT_UPDATE_DATA})
    self:dispatchEvent( { name = self.EVENT_INIT_DATA }) --刷新红点
end

function ContinueRechargeModel:onExchangeResult(rawdata)
    print("ContinueRechargeModel:onExchangeResult result rsp")
    local data = cc.exports.pb_decode("ContinueRecharge.RspExchange", rawdata)
    if not data then
        print("[ERROR] pb-parse error, the package name is ContinueRecharge.RspExchange.")
        return
    end
    dump(data)

    if not data.ok then
        print("exchange failed")
        my.informPluginByName({pluginName='TipPlugin',params={tipString="服务器正忙，请稍后再试！",removeTime=1}})
        return
    end

    self._status.count = 1

    if data.type == 0 then
        -- 兑换的是话费
        self:dispatchEvent({name = ContinueRechargeModel.EVENT_ON_HUAFEI_RSP})
    else
        -- 兑换其它物品
        local rewardList = {}
        table.insert( rewardList,{nType = RewardTipDef.TYPE_SILVER,nCount = data.deposit})
        
        if #rewardList > 0 then
            my.informPluginByName({pluginName = 'RewardTipCtrl', params = {data = rewardList,showOkOnly = true}})

            my.scheduleOnce(function ()
                local playerModel = mymodel("hallext.PlayerModel"):getInstance()
                playerModel:update({'SafeboxInfo','MemberInfo','UserGameInfo'})
            end, 2)
        end
    end

    self:dispatchEvent({name = ContinueRechargeModel.EVENT_UPDATE_DATA})
    self:dispatchEvent( { name = self.EVENT_INIT_DATA }) --刷新红点
end

function ContinueRechargeModel:OnRechargeOkNtf(rawdata)
    print("pay result rsp")
    local data = cc.exports.pb_decode("ContinueRecharge.RspPayResult", rawdata)
    if not data then
        print("[ERROR] pb-parse error, the package name is ContinueRecharge.RspPayResult.")
        return
    end
    dump(data)

    self:setStatus(data.dayNum)
    self._status.current = data.current
    self._status.startdate = data.startdate
    self._status.buydate = data.buydate

    local rewards = self:getDayRewardsByDayNum(data.dayNum)
    local addGoods = self:getDayAddGoodsByDayNum(data.dayNum)
    local normalGoods = self:getNormalGoodsByDayNum(data.dayNum)
    local productnum
    if data.type == 0 then
        productnum = normalGoods.param.productnum
    else
        productnum = addGoods.param.productnum
    end
    local key = "ContinueRechargeCacheKey".. user.nUserID .. data.buydate
    local value = CacheModel:getCacheByKey(key)
    value[tostring(data.dayNum)] = data.type
    CacheModel:saveInfoToCache(key, value)
    
    local totalRewards = {}
    table.insert(totalRewards, {nType = RewardTipDef.TYPE_SILVER, nCount = productnum})

    for _, v in pairs(rewards) do
        table.insert(totalRewards, {nType = v.itemid,nCount = v.count})
    end
    
    if #totalRewards > 0 then
        my.informPluginByName({pluginName = 'RewardTipCtrl', params = {data = totalRewards,showOkOnly = true}})

        my.scheduleOnce(function ()
            local playerModel = mymodel("hallext.PlayerModel"):getInstance()
            playerModel:update({'SafeboxInfo','MemberInfo','UserGameInfo'})
        end, 2)

        local CardRecorderModel = import("src.app.plugins.shop.cardrecorder.CardRecorderModel"):getInstance()
        CardRecorderModel:sendGetCardMakerInfo() --查询记牌器信息

        for i,v in pairs(totalRewards) do
            if v.nType == RewardTipDef.TYPE_REWARDTYPE_NOBILITY_EXP then
                local NobilityPrivilegeModel = import("src.app.plugins.NobilityPrivilege.NobilityPrivilegeModel"):getInstance()
                NobilityPrivilegeModel:gc_GetNobilityPrivilegeInfo() --查询贵族信息
            elseif v.nType == RewardTipDef.TYPE_REWARDTYPE_TIMINGGAME_TICKET then
                local TimingGameModel = import('src.app.plugins.TimingGame.TimingGameModel'):getInstance()
                TimingGameModel:reqTimingGameInfoData()
            end
        end
    end

    self:dispatchEvent({name = ContinueRechargeModel.EVENT_UPDATE_DATA})
    self:dispatchEvent( { name = self.EVENT_INIT_DATA }) --刷新红点
end

function ContinueRechargeModel:onReceivedData(dataMap)
    local responseId, rawdata = unpack(dataMap.value)
    if type(self._handlers[responseId]) == 'function' then
        self._handlers[responseId](rawdata)
    end
end

function ContinueRechargeModel:onAssistConOk()
    -- my.scheduleOnce(function ()
    --     self:OnRechargeOkNtf({})
    -- end, 6)
end

function ContinueRechargeModel:_getPackageType()
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
    return platFormType - 1
end

-- 查询指定天数的签到状态
function ContinueRechargeModel:getCheckedByDayNumber(num)
    local myStatus = self._status.state
    local target = bit.lshift(1, num - 1)
    local res = (bit.band(target, myStatus) ~= 0)
    return res
end

-- 获取一共充值了几天
function ContinueRechargeModel:getCheckedTotalDay()
    local count = 0
    for i = 1, self:getTotalDay() do
        if self:getCheckedByDayNumber(i) then
            count = count + 1
        end
    end
    return count
end

function ContinueRechargeModel:getDayRewardsByDayNum(num)
    return self._config.dayRewards[num].iteminfos
end

-- 获取没有签到的第一天日期
function ContinueRechargeModel:getFirstAddCheckDayNum()
    local num = 0
    for i = 1, self:getTotalDay() do
        if not self:getCheckedByDayNumber(i) then
            num = i
            break
        end
    end
    return num
end

-- 根据日期获取正常签到商品的信息
function ContinueRechargeModel:getNormalGoodsByDayNum(num)
    local res
    for i, v in ipairs(self._config.normalGoods) do
        if i == num then
            res = v
        end
    end
    return res
end

-- 根据日期获取补签商品的信息
function ContinueRechargeModel:getAddGoodsByDayNum(num)
    local res
    for i, v in ipairs(self._config.addGoods) do
        if i == num then
            res = v
        end
    end
    return res
end

-- 根据日期获取补签商品信息
function ContinueRechargeModel:getDayAddGoodsByDayNum(num)
    local res
    for i, v in ipairs(self._config.addGoods) do
        if i == num then
            res = v
        end
    end
    return res
end

function ContinueRechargeModel:setStatus(dayNum)
    local target = bit.lshift(1, dayNum - 1)
    self._status.state = bit.bor(self._status.state, target)
end

function ContinueRechargeModel:getCurrentDayStamp()
    local time = os.time()
    local data = {
        year = tonumber(os.date(os.date("%Y", time))),
        month = tonumber(os.date(os.date("%m", time))),
        day = tonumber(os.date(os.date("%d", time))),
        hour = 0,
        minute = 0,
        second = 0
    }

    local day = data.day
    local month = data.month * 100
    local year = data.year * 10000

    local stamp = year + month + day
    return stamp
end

function ContinueRechargeModel:currentDayNum(startDay)
    local data = {
        year = math.floor(startDay / 10000),
        month = math.floor((startDay % 10000) / 100),
        day = startDay % 100,
        hour = 0,
        minute = 0,
        second = 0
    }

    local startTime = os.time(data)
    local currentTime = os.time()
    local diff = currentTime - startTime
    local diffNum = math.floor(diff / (24 * 60 * 60)) + 1
    return diffNum
end

-- 获取一共签到几天
function ContinueRechargeModel:getTotalDay()
    return #self._config.dayRewards
end

-- 是否全部都签到过了
function ContinueRechargeModel:isAllChecked()
    return (self:getCheckedTotalDay() == self:getTotalDay())
end

function ContinueRechargeModel:canExchange()
    return (self:getCheckedTotalDay() == self:getTotalDay() and self._status.count ~= 1)  
end

function ContinueRechargeModel:getConfig()
    return self._config
end

function ContinueRechargeModel:getStatus()
    return self._status
end

function ContinueRechargeModel:setExchangeID(exchangeID)
    self._exchangeID = exchangeID
end

function ContinueRechargeModel:isContinueRechargeResult(goodID)
    if type(self._exchangeID) == 'number' and self._exchangeID == goodID then
        return true
    end
    return false
end


return ContinueRechargeModel