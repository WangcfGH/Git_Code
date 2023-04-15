local RechargePoolModel 		    = class('RechargePoolModel', require('src.app.GameHall.models.BaseModel'))
local AssistModel                   = mymodel('assist.AssistModel'):getInstance()
local PropertyBinder                = cc.load('coms').PropertyBinder
local WidgetEventBinder             = cc.load('coms').WidgetEventBinder
local agent                         = MCAgent:getInstance()
local player                        = mymodel('hallext.PlayerModel'):getInstance()
local UserModel                     = mymodel('UserModel'):getInstance()

import("src.packages.pb.protobuf")
protobuf.register_file('src/app/plugins/rechargepool/RecharPool.pb')

my.addInstance(RechargePoolModel)

my.setmethods(RechargePoolModel, PropertyBinder)
my.setmethods(RechargePoolModel, WidgetEventBinder)

-- 事件
RechargePoolModel.EVENT_UPDATE_DATA      = "EVENT_UPDATE_DATA"     -- 获取到活动信息，通知刷新界面
RechargePoolModel.EVENT_UPDATE_RANK      = "EVENT_UPDATE_RANK"     -- 获取到排行数据，通知刷新界面

local RechargePoolDefine = {
    GR_RECHARGE_POOL_QUERY_INFO     = 402601,   -- 获取活动信息
    GR_RECHARGE_POOL_QUERY_RANK     = 402602,   -- 获取排行榜数据
    GR_RECHARGE_POOL_AFTER_BUY      = 402603,   -- 充值成功
    GR_RECHARGE_POOL_TAKE_AWARD     = 402604,   -- 领奖
}

function RechargePoolModel:onCreate()
    self._activityInfo = nil
    self._rankList = {}
    self._lastReqRankListTime = 0   -- 上次请求排行数据的时间
    self._lastLoginUserId = 0
    self:clearAfterReward()

    -- regist
    AssistModel:registCtrl(self, self.dealwithResponse)
    
    -- 登录消息监听，登录成功获取全部任务
    self:bindProperty(player, 'PlayerLoginedData', self, 'OnLoginSuccessEvent')
end

function RechargePoolModel:setOnLoginSuccessEvent(data)
     if data.nUserID and cc.exports.isRechargePoolSupported() then
        if 0 == self._lastLoginUserId or self._lastLoginUserId ~= data.nUserID then
            self:reqRechargeActivityInfo()
            if self._lastLoginUserId ~= data.nUserID then -- 不是相同的玩家
                self._lastReqRankListTime = 0
                self._rankList = {}
            end
        end
        self._lastLoginUserId = data.nUserID
     end
end

function RechargePoolModel:onDestory()
    AssistModel:unRegistCtrl(self)
end

function RechargePoolModel:onResumeApp()
    print("[" .. (self.__cname or "") .. "] onResumeBack...")
    if (not UserModel.nUserID) or (not cc.exports.isRechargePoolSupported()) then
        return
    end
    self:reqRechargeActivityInfo()
end

--[服务端通信] start
function RechargePoolModel:isResponseID(response)
    if response == RechargePoolDefine.GR_RECHARGE_POOL_QUERY_INFO then
        return true
    elseif response == RechargePoolDefine.GR_RECHARGE_POOL_QUERY_RANK then
        return true
    elseif response == RechargePoolDefine.GR_RECHARGE_POOL_TAKE_AWARD then
        return true
    end

    return false
end

-- data response
function RechargePoolModel:dealwithResponse(dataMap)
    local response, data = unpack(dataMap.value)

    if response == cc.exports.UrSocket.UR_SOCKET_ERROR 
        or response == cc.exports.UrSocket.UR_SOCKET_GRACEFULLY_ERROR then
        print('connect error')
    else
        self:onNotifyReceived(response, data)
    end
end

function RechargePoolModel:onNotifyReceived(response, data)
    if response == RechargePoolDefine.GR_RECHARGE_POOL_QUERY_INFO then
        print('GR_RECHARGE_POOL_QUERY_INFO response')
        self:dealRechargeActivityInfoResp(data)
    elseif response == RechargePoolDefine.GR_RECHARGE_POOL_QUERY_RANK then
        print('GR_RECHARGE_POOL_QUERY_RANK response')
        self:dealRechargeRankInfoResp(data)
    elseif response == RechargePoolDefine.GR_RECHARGE_POOL_TAKE_AWARD then
        print('GR_RECHARGE_POOL_TAKE_AWARD response')
        self:dealRechargeTakeAwardResp(data)
    else
        printf('onDataReceived other = '..response)
    end
end

-- 查询活动信息
function RechargePoolModel:reqRechargeActivityInfo()
    local userNickName = ""
    local NickNameInterface = cc.exports.NickNameInterface
    if NickNameInterface then
        userNickName = NickNameInterface.getNickName()
        if type(userNickName) ~= 'string' then
            userNickName = UserModel.szUtf8Username
        end
    end

    local data          = {
        userid         = UserModel.nUserID,
        nickname       = userNickName or ""
    }
    local pdata = protobuf.encode('RechargePool.ReqActivityInfo', data)
    AssistModel:sendData(RechargePoolDefine.GR_RECHARGE_POOL_QUERY_INFO, pdata)
end

-- 查询信息返回
function RechargePoolModel:dealRechargeActivityInfoResp(data)
    local pbData = cc.exports.pb_decode('RechargePool.RspActivityInfo', data)

    -- 日期变了
    local update = 'update_part'
    if self:getTodayDate() ~= pbData.today then
        self._lastReqRankListTime = 0
        self._rankList = {}
        update = 'update_all'
    end

    self._activityInfo = pbData

    if self:isVisible() then
        self:dispatchEvent({name = self.EVENT_UPDATE_DATA, value=update})
    else
        self:clearAfterReward()

        if self:isShowEntry() then
            --一天只弹一次
            local key = "RechargePoolCacheKey"
            if UserModel.nUserID and UserModel.nUserID > 0  then
                key = "RechargePoolCacheKey"..UserModel.nUserID
            end
            local value = CacheModel:getCacheByKey(key)
            local today = os.date('%Y%m%d', os.time())
            if not (value and value.tag == today) then
                CacheModel:saveInfoToCache(key, {tag = today})
                if self:isInClearDay() then -- 如果在展示期
                    if self:isHasAward() then
                        local PluginProcessModel = mymodel("hallext.PluginProcessModel"):getInstance()
                        PluginProcessModel:setPluginReadyStatus("RechargePool", true)
                        PluginProcessModel:startPluginProcess()
                    end
                else
                    local PluginProcessModel = mymodel("hallext.PluginProcessModel"):getInstance()
                    PluginProcessModel:setPluginReadyStatus("RechargePool", true)
                    PluginProcessModel:startPluginProcess()
                end
            end
            self:dispatchEvent({name = self.EVENT_UPDATE_DATA, value=update})
        end
    end
end


-- 查询排行信息 bForce强制请求数据
function RechargePoolModel:reqRechargeRankInfo(nDate, bForce)
    local info = self:getActivityInfo()
    if not info then return end
    if not nDate then   -- 不指定日期就默认今日
        nDate = self:getTodayDate()
    end

    -- 昨日信息只查一次
    if nDate ~= self:getTodayDate() then
        if not bForce and self._rankList[nDate] then
            self:dispatchEvent({name = self.EVENT_UPDATE_RANK})
            return
        end
    else -- 今日信息间隔一定时间刷新
        local current = os.time()
        local seconds = cc.exports.getRechargePoolRankUpdateInverval() or 300
        if not bForce and self._rankList[nDate] and current - self._lastReqRankListTime < seconds then
            self:dispatchEvent({name = self.EVENT_UPDATE_RANK})
            return
        end
        self._lastReqRankListTime = current
    end

    local data          = {
        userid         = UserModel.nUserID,
        day           = nDate,
    }
    local pdata = protobuf.encode('RechargePool.ReqRankInfo', data)
    AssistModel:sendData(RechargePoolDefine.GR_RECHARGE_POOL_QUERY_RANK, pdata)
end

-- 查询排行返回
function RechargePoolModel:dealRechargeRankInfoResp(data)
    local pbData = cc.exports.pb_decode('RechargePool.RspRankInfo', data)

    if not pbData.ok then
        if self:isVisible() then
            my.informPluginByName({pluginName='ToastPlugin',params={tipString="排名信息获取失败，请稍后重试",removeTime=3}})
        end
        return
    end

    local date = pbData.day

    -- 填充今日排行奖励（百分比）
    if date == self:getTodayDate() then
        local users = pbData.users or {}
        for i = 1, #users do
            local user = pbData.users[i]
            user.nReward = self:getRewardRateForRank(i)
            if UserModel.nUserID == user.nUserID then
                pbData.selfdata.nRank = user.nRank
            end
        end

        pbData.selfdata.nReward = self:getRewardRateForRank(pbData.selfdata.nRank)
    end

    self._rankList[date] = pbData

    self:dispatchEvent({name = self.EVENT_UPDATE_RANK})
end

-- 请求领奖
function RechargePoolModel:reqTakeAward(date)
    local data          = {
        userid         = UserModel.nUserID,
        day           = date,
    }
    local pdata = protobuf.encode('RechargePool.ReqDoAward', data)
    AssistModel:sendData(RechargePoolDefine.GR_RECHARGE_POOL_TAKE_AWARD, pdata)
end

-- 领奖返回
function RechargePoolModel:dealRechargeTakeAwardResp(data)
    local pbData = cc.exports.pb_decode('RechargePool.RspAward', data)

    self:showAward(pbData)
    self:setAfterReward()

    -- 刷新数据
    self:reqRechargeActivityInfo()
end

--[服务端通信] end

--[数据接口] start
function RechargePoolModel:getActivityInfo()
    return self._activityInfo
end

-- 当前日期
function RechargePoolModel:getTodayDate()
    return self._activityInfo and self._activityInfo.today or 0
end

-- 昨天，如果昨天没有开放就返回nil
function RechargePoolModel:getLastDate()
    local activityInfo = self:getActivityInfo()
    if not activityInfo then return end
    local today = activityInfo.today
    if today > 1 then
        return today - 1 
    end
    return nil
end

-- 我的排名信息
function RechargePoolModel:getMyRankInfo(nDate)
    local defaultInfo = {
        nRank = -1,
        nValue = 0,
        nReward = self:getRewardRateForRank(-1),
    }

    if not nDate or not self._rankList[nDate] then return defaultInfo end

    return self._rankList[nDate].selfdata or defaultInfo
end

-- 排行榜
function RechargePoolModel:getRankList(nDate)
    if not nDate or not self._rankList[nDate] then return {} end

    return self._rankList[nDate].users or {}
end

-- 排名对应的瓜分比例
function RechargePoolModel:getRewardRateForRank(rank)
    if not rank or rank < 0 then return "--" end
    local activityInfo = self:getActivityInfo()
    if not activityInfo or not activityInfo.config or not activityInfo.config.rewardrange then return "--" end

    if rank > activityInfo.config.ranknum then
        return '--'
    end

    -- 格式为:排名1(<=)，万分比，排名2，万分比，……
    local rangeList = activityInfo.config.rewardrange
    local rankinfo = nil
    for i = 1, #rangeList do
        local one = rangeList[i]
        if rank >= one.rankno then
            rankinfo = one
        elseif rank < one.rankno then
            break
        end
    end

    if rankinfo then
        local activityInfo = self:getActivityInfo()
        if activityInfo and activityInfo.poolprize then
            local value = math.floor(rankinfo.rate / 100 * activityInfo.poolprize / 100)
            if value >= 100000 then
                value = value / 10000
                return string.format( "%.1f%%\n(%.1f万两)", rankinfo.rate/100, value)
            else
                return string.format( "%.1f%%\n(%d两)", rankinfo.rate/100, value)
            end
        else
            return string.format("%.1f%%",rankinfo.rate/100)
        end
    end

    return "--"
end

-- 获取剩余时间
function RechargePoolModel:getTodayLeftTime()
    local activityInfo = self:getActivityInfo()
    if not activityInfo or not activityInfo.daylefttime then return 0 end

    return activityInfo.daylefttime
end

function RechargePoolModel:getPlayerInfo(day)
    local activityInfo = self:getActivityInfo()
    if not activityInfo or not activityInfo.predayinfos then
        return nil
    end

    for i, v in pairs(activityInfo.predayinfos) do
        if v.day == day then
            return v
        end
    end
    return nil
end

-- 入口是否展示
function RechargePoolModel:isShowEntry()
    if not cc.exports.isRechargePoolSupported() then return false end

    local activityInfo = self:getActivityInfo()
    if not activityInfo then
        return false
    end
    if activityInfo.status ~= "OPEN" then
        return false
    end

    -- 还没到活动日期
    if not activityInfo or not activityInfo.config then return false end

    local closeDate = activityInfo.config.closeday
    local today = self:getTodayDate()

    return today >= 1 and today <= closeDate
end

-- 活动是否进行中
function RechargePoolModel:isRankOpen()
    local activityInfo = self:getActivityInfo()
    if not activityInfo or not activityInfo.config then return false end

    local openday = activityInfo.config.openday
    local today = self:getTodayDate()

    return today >= 1 and today <= openday
end
--[数据接口] end

-- 展示领取到的奖品
function RechargePoolModel:showAward(pData)
    if not pData.ok then
        return
    end
    local Def = import("src.app.plugins.RewardTip.RewardTipDef")
    local rewardList = {}
    table.insert(rewardList, {nType = Def.TYPE_SILVER, nCount = pData.count})
    my.informPluginByName({pluginName = "RewardTipCtrl", params = {data = rewardList}})
end

function RechargePoolModel:isHasAward()
    if not self:isShowEntry() then
        return false
    end

    local tbl = self._activityInfo.predayinfos
    if not tbl then
        return false
    end
    for i,v in pairs(tbl) do
        if v.nReward > 0 and v.bAward == false then
            return true
        end
    end
    return false
end

function RechargePoolModel:isInClearDay()
    if not self._activityInfo then
        return false
    end

    if not self._activityInfo.config then
        return false
    end

    local today = self:getTodayDate()
    local openday = self._activityInfo.config.openday

    if today > openday then
        return true
    end
    return false
end

function RechargePoolModel:isOpenDayNextDay()
    if not self._activityInfo then
        return false
    end

    if not self._activityInfo.config then
        return false
    end
    local openday = self._activityInfo.config.openday
    local today = self._activityInfo.today
    if openday and today then 
        return (today - 1) == openday
    else
        return false
    end
end

function RechargePoolModel:isVisible()
    return self._panelVisible
end
function RechargePoolModel:setVisible(bl)
    self._panelVisible = bl
end

function RechargePoolModel:isAfterReward()
    return self._isAfterReward
end
function RechargePoolModel:clearAfterReward()
    self._isAfterReward = false
end
function RechargePoolModel:setAfterReward()
    self._isAfterReward = true
end

return RechargePoolModel
