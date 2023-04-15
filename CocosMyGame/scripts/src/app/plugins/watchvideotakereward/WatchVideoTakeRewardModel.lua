local WatchVideoTakeRewardModel = class("WatchVideoTakeRewardModel", require('src.app.GameHall.models.BaseModel'))
local AssistModel                = mymodel('assist.AssistModel'):getInstance()
local user = mymodel('UserModel'):getInstance()
local Def               = import("src.app.plugins.RewardTip.RewardTipDef")

my.addInstance(WatchVideoTakeRewardModel)
protobuf.register_file("src/app/plugins/watchvideotakereward/watchVideoTakeReward.pb")

local PropNumbers = {
    WATCH_VIDEO_TAKE_REWARD_CONFIG_DATA = 500010,
    WATCH_VIDEO_TAKE_REWARD_LOTTERY = 500011
}

WatchVideoTakeRewardModel.Events = {
    CONFIG_DATA_UPDATED = "WVTR_CONFIG_DATA_UPDATED",
    WVTR_RSP_RESULT = "WVTR_RSP_RESULT"
}

function WatchVideoTakeRewardModel:ctor()
    WatchVideoTakeRewardModel.super.ctor(self)
    self:initHandlers()
    AssistModel:registCtrl(self, self._onReceivedData)
    AssistModel:addEventListener(AssistModel.ASSIST_CONNECT_OK, handler(self, self._onAssistConOk))
    self:setDoing(false)
end

function WatchVideoTakeRewardModel:isOpen()
    if not cc.exports.isWatchVideoTakeRewardSupport() then
        return false
    end
    if not self:isSupportVideo() then
        return false
    end
    if self._configAndData then
        return self._configAndData.enable ~= 0
    end
    return false
end

function WatchVideoTakeRewardModel:isDoing()
    return self._isDoing 
end
function WatchVideoTakeRewardModel:setDoing(bFlag)
    self._isDoing = bFlag
    if bFlag then
        self:startDoingTimer()
    else
        self:stopDoingTimer()
    end
end

function WatchVideoTakeRewardModel:startDoingTimer()
    self:stopDoingTimer()
    local scheduler=cc.Director:getInstance():getScheduler()
    self._isDoingTimerId = scheduler:scheduleScriptFunc(function ()
        self:stopDoingTimer()
        self:setDoing(false)
    end, 15, false)
end
function WatchVideoTakeRewardModel:stopDoingTimer()
    if self._isDoingTimerId then
        local scheduler=cc.Director:getInstance():getScheduler()
        scheduler:unscheduleScriptEntry(self._isDoingTimerId)
        self._isDoingTimerId = nil
    end
end 

function WatchVideoTakeRewardModel:getHitBoxProcessInfo()
    local info = {
        hitboxcount = 0,
        processtext = "0/0",
        precesspercent = 0
    }
    if not self._configAndData then 
        return info
    end
    if self._configAndData.hitboxcount == 0 then
        return info
    end
    info.hitboxcount = self._configAndData.hitboxcount
    local v = math.floor(self._configAndData.watchvideocount % self._configAndData.hitboxcount)
    info.processtext = "" .. v .. "/" .. self._configAndData.hitboxcount
    info.precesspercent = v * 100.0 / self._configAndData.hitboxcount
    if info.precesspercent >= 100 then
        info.precesspercent = 100
    end
    return info
end

function WatchVideoTakeRewardModel:getWatchVideoBtnProcessInfo()
    if not self._configAndData then 
        return "", false
    end
    local videocount = self._configAndData.watchvideocount 
    local maxvideocount = self._configAndData.maxvideocount
    if videocount > maxvideocount then
        videocount = maxvideocount
    end
    local str = "当日仅限" .. videocount .. "/" .. maxvideocount
    return str, videocount < maxvideocount
end

function WatchVideoTakeRewardModel:getLeftCountStr()
    local str = ""
    if not self._configAndData then
        return str
    end
    local videocount = self._configAndData.watchvideocount 
    local maxvideocount = self._configAndData.maxvideocount
    local leftCount = maxvideocount - videocount
    if leftCount < 0 then
        leftCount = 0
    end
    return "剩余" .. leftCount .. "次"
end

function WatchVideoTakeRewardModel:getSortedRewardInfo()
    if not self._configAndData then
        return {}
    end
    table.sort(self._configAndData.items, function (lhs, rhs)
        return lhs.idx < rhs.idx
    end)
    local sorted = {}
    for _, v in pairs(self._configAndData.items) do
        table.insert(sorted, {  nType = v.type, nCount = v.count })
    end
    return sorted
end

function WatchVideoTakeRewardModel:OnRspConfigAndData(rawdata)
    local data = cc.exports.pb_decode("pbWatchVideoTakeReward.RspConfigAndData", rawdata)
    if not data then
        return
    end
    self._configAndData = data
    self:dispatchEvent({ name = self.Events.CONFIG_DATA_UPDATED, value = data})
end

function WatchVideoTakeRewardModel:OnRspLottery(rawdata)
    self:setDoing(false)
    local data = cc.exports.pb_decode("pbWatchVideoTakeReward.RspLottery", rawdata)
    if not data then 
        return
    end
    if not (data.errorno == 0) then
        my.informPluginByName({pluginName='TipPlugin', params={tipString = "抽奖失败",removeTime = 2}})
        return
    end
    -- 更新数据
    if self._configAndData then
        self._configAndData.watchvideocount = data.watchvideocount
    end
    self:dispatchEvent({name = self.Events.CONFIG_DATA_UPDATED })
    if self:isViewVisible() then
        self:dispatchEvent( { name = self.Events.WVTR_RSP_RESULT, value = data})
    else
        self:showRewards(data.items, data.extraitems)
    end
end

function WatchVideoTakeRewardModel:showRewards(items, extraItems)
    local list = {}
    for _, v in pairs(items or {}) do
        if v.type and v.count then
            table.insert(list, { nType = v.type, nCount = v.count })
        end
    end
    for _, v in pairs(extraItems or {}) do
        if v.type and v.count then
            table.insert(list, { nType = v.type, nCount = v.count, extra = true })
        end
    end
    if #list > 0 then
        my.informPluginByName({pluginName = "RewardTipCtrl", params = {data = list}})
        -- 更新奖励数据
        self:update(false, list)
    end
end

function WatchVideoTakeRewardModel:update(forceUpdate, rewardList)
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

function WatchVideoTakeRewardModel:reqConfigAndData()
    local data = {
        userid = user.nUserID or 0
    }
    local pbdata = protobuf.encode("pbWatchVideoTakeReward.ReqConfigAndData", data)
    AssistModel:sendData(PropNumbers.WATCH_VIDEO_TAKE_REWARD_CONFIG_DATA, pbdata)
end

function WatchVideoTakeRewardModel:reqLottery()
    self:setDoing(true)
    local data = {
        userid = user.nUserID or 0
    }
    local pbdata = protobuf.encode("pbWatchVideoTakeReward.Lottery", data)
    AssistModel:sendData(PropNumbers.WATCH_VIDEO_TAKE_REWARD_LOTTERY, pbdata)
end

function WatchVideoTakeRewardModel:_onAssistConOk()
    if cc.exports.isWatchVideoTakeRewardSupport() and self:isSupportVideo() then
        self:reqConfigAndData()
    end
end

function WatchVideoTakeRewardModel:isSupportVideo()
    local AdPlugin = plugin.AgentManager:getInstance():getAdsPlugin()
    if not AdPlugin then 
        return false
    end
    if not (AdPlugin.loadChannelAd and AdPlugin.showChannelAd) then
        return false
    end  
    return true 
end

function WatchVideoTakeRewardModel:initHandlers()
    self._handlers = {}
    self._handlers[PropNumbers.WATCH_VIDEO_TAKE_REWARD_CONFIG_DATA] = function (rawdata)
        self:OnRspConfigAndData(rawdata)
    end
    self._handlers[PropNumbers.WATCH_VIDEO_TAKE_REWARD_LOTTERY] = function (rawdata)
        self:OnRspLottery(rawdata)
    end
end

function WatchVideoTakeRewardModel:isResponseID(responseId)
    if self._handlers[responseId] then
        return true
    end
    return false
end
function WatchVideoTakeRewardModel:_onReceivedData(dataMap)
    local responseId, rawdata = unpack(dataMap.value)
    if type(self._handlers[responseId]) == 'function' then
        self._handlers[responseId](rawdata)
    end
end

function WatchVideoTakeRewardModel:setViewVisibleFlag(flag)
    self._viewVisibleFlag = flag
end
function WatchVideoTakeRewardModel:isViewVisible()
    return self._viewVisibleFlag
end

function WatchVideoTakeRewardModel:GetItemFilePathAndDes(item)
    local dir = "hallcocosstudio/images/plist/RewardCtrl/"
    local path = nil

    local nType = item.nType
    local nCount = item.nCount
    local des = "" .. nCount

    if nType == Def.TYPE_SILVER then --银子
        if nCount>=2000 then 
            path = dir .. "Img_Silver4.png"
        elseif nCount>=1000 then
            path = dir .. "Img_Silver3.png"
        elseif nCount>=500 then
            path = dir .. "Img_Silver2.png"
        else
            path = dir .. "Img_Silver1.png"
        end
        des = des .. "两"
    elseif nType == Def.TYPE_TICKET then --礼券
        if nCount>=100 then 
            path = dir .. "Img_Ticket4.png"
        elseif nCount>=50 then
            path = dir .. "Img_Ticket3.png"
        elseif nCount>=20 then
            path = dir .. "Img_Ticket2.png"
        else
            path = dir .. "Img_Ticket1.png"
        end
        des = des .. "张"
    elseif nType == Def.TYPE_CARDMARKER_1D then --1d记牌器
        path = dir .. "1tian.png"
        des = "1天"
    elseif nType == Def.TYPE_CARDMARKER_7D then --7d记牌器
        path = dir .. "7tian.png"
        des = "7天"
    elseif nType == Def.TYPE_CARDMARKER_30D then --30d记牌器
        path = dir .. "30tian.png"
        des = "30天"
    elseif nType == Def.TYPE_ROSE then --玫瑰
        path = dir .. "Img_Rose.png"
    elseif nType == Def.TYPE_LIGHTING then --闪电
        path = dir .. "Img_Lighting.png"
    elseif nType == Def.TYPE_CARDMARKER then
        path = dir .. "Img_CardMarker.png"
    elseif nType == Def.TYPE_PROP_LIANSHENG then
        path = dir .. "Img_Prop_Liansheng.png"
    elseif nType == Def.TYPE_PROP_JIACHENG then
        path = dir .. "Img_Prop_Jiacheng.png"
    elseif nType == Def.TYPE_PROP_BAOXIAN then
        path = dir .. "Img_Prop_Baoxian.png"
    elseif nType == Def.TYPE_RED_PACKET then --红包
        path = dir .. "Img_RedPacket_100.png"
    elseif nType == Def.TYPE_RED_PACKET_VOCHER then --红包礼券
        path = dir .. "Img_RedPacket_Vocher.png"
    elseif nType == Def.TYPE_REWARDTYPE_LOTTERY_TIME then --惊喜夺宝
        path = dir .. "Img_RewardType_Lottery.png"
    elseif nType == Def.TYPE_REWARDTYPE_LUCKY_CAT then --小鱼干
        path = dir .. "Img_RewardType_LuckyCat.png"
    elseif nType == Def.TYPE_REWARDTYPE_NOBILITY_EXP then --贵族经验
        path = dir .. "Img_Prop_Jiacheng.png"
    elseif nType == Def.TYPE_REWARDTYPE_TIMINGGAME_TICKET then --定时赛门票
        path = dir .. "Img_TimingTicket1.png"
    end
    return path, des
end

return WatchVideoTakeRewardModel