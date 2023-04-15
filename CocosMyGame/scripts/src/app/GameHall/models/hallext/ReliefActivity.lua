--�ͱ�ҵ����UserModel��ӵͱ�����û���Ϣ

local SyncSender = cc.load("asynsender").SyncSender
local user = mymodel("UserModel"):getInstance()
local player = mymodel("hallext.PlayerModel"):getInstance()

local ReliefActivity = class("ReliefActivity", import("src.app.GameHall.models.hallext.ActivityModel"))

my.addInstance(ReliefActivity)

ReliefActivity.NOT_OPENED = "NOT_OPEN"
ReliefActivity.SATISFIED = "SATISFIED"
ReliefActivity.UNSATISFIED = "UNSATISFIED"
ReliefActivity.USED_UP = "USED_UP"
ReliefActivity.NOT_LOGINED = "NOT_LOGINED"

ReliefActivity.RELIEF_STATE_UPDATED = "STATE_UPDATED"
ReliefActivity.RELIEF_DATA_UPDATED = "DATA_UPDATED"
ReliefActivity.RELIEF_TAKE_FAILED = "TAKEFAILED_UPDATED"

ReliefActivity.TakeFailed = {
    act_NotExist = -1,
    act_Forbidden = -2,
    act_Expired = -3,
    sum_over_today = -4,
    times_over_today = -5,
    not_broken = -6,
    operate_failed = -7,
    device_totalTimes_over_today = -8,
    user_totalTimes_over_today = -9,
    net_error = -10
}
ReliefActivity.ActivityStatus = {
    on = 1,
    off = 2
}

function ReliefActivity:queryConfig()
    if (true == self:updateReliefData()) then
        if self:canQueryVideoAdRelief() then
            self:queryUserVideoAdReliefState()
        end
        return
    end
    self:queryUserState()
    if self:canQueryVideoAdRelief() then
        self:queryUserVideoAdReliefState()
    end
end

function ReliefActivity:queryUserState()
    local client = my.jhttp:create()
    SyncSender.run(
        client,
        function()
            --添加会员信息
            local us_sender, us_dataMap
            --贵族低保信息
            local NobilityPrivilegeModel = import("src.app.plugins.NobilityPrivilege.NobilityPrivilegeModel"):getInstance()
            local status, reliefCount = NobilityPrivilegeModel:TakeNobilityPrivilegeReliefInfo()
            if status then
                if cc.exports.isSafeBoxSupported() then
                    us_sender, us_dataMap = SyncSender.send("queryNobilityPrivilegeReliefUserState")
                else
                    us_sender, us_dataMap = SyncSender.send("queryNPNoSafeboxReliefUserState")
                end
            else
                if cc.exports.isSafeBoxSupported() then
                    us_sender, us_dataMap = SyncSender.send("queryReliefUserState")
                else
                    us_sender, us_dataMap = SyncSender.send("queryNoSafeboxReliefUserState")
                end
            end

            --获取一下会员配置信息，为了显示会员低保次数
            local rc_sender, rc_dataMap
            if status then
                if cc.exports.isSafeBoxSupported() then
                    rc_sender, rc_dataMap = SyncSender.send("queryNobilityPrivilegeReliefConfig")
                else
                    rc_sender, rc_dataMap = SyncSender.send("queryNPNoSafeboxReliefConfig")
                end
            else
                if cc.exports.isSafeBoxSupported() then
                    rc_sender, cc.exports.reliefConfig = SyncSender.send("queryReliefConfig")
                else
                    rc_sender, cc.exports.reliefConfig = SyncSender.send("queryNoSafeboxReliefConfig")
                end
                rc_dataMap = cc.exports.reliefConfig
            end

            if  rc_dataMap and rc_dataMap.Limit then 
                -- 修改下低保线
                rc_dataMap.Limit.LowerLimit = cc.exports.getReliefLowLimit()
            end
          
            if not (self:myCheckTable(us_dataMap) and self:myCheckTable(rc_dataMap)) then
                print("failed to get reliefState")
                return
            end
         
            self.state = self:getReliefState(us_dataMap, rc_dataMap)

            local reliefUsedCount = tonumber(CacheModel:getCacheByKey("NobilityPrivilegeRelief" .. user.nUserID .. os.date("%Y%m%d", os.time())))
            if not reliefUsedCount then
                reliefUsedCount = 0
            end

            if status and reliefUsedCount and reliefUsedCount >= reliefCount then --当天升级使用低保超过了缓存，则返回
                self.state = self.USED_UP
            end

            self:mergeReliefState(us_dataMap)
            self.config = rc_dataMap
            local saveData = {
                state = us_dataMap,
                config = rc_dataMap
            }

            cc.exports.gameReliefData = saveData
            self:dispatchEvent({name = self.RELIEF_STATE_UPDATED, value = self})
        end
    )
end

function ReliefActivity:getState()
    return self
end

function ReliefActivity:getData()
    return self.data
end

local tipTimer
function ReliefActivity:ShowTip()
    if (tipTimer ~= nil) then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(tipTimer)
        tipTimer = nil
        self:dispatchEvent({name = self.RELIEF_DATA_UPDATED})
    end
end

function ReliefActivity:takeRelief()
    --增加低保领取CD功能,5秒
    if self._isTakeReliefCD then
        return
    end
    self._isTakeReliefCD = true
    my.scheduleOnce(
        function()
            self._isTakeReliefCD = false
        end,
        5
    )

    local NobilityPrivilegeModel = import("src.app.plugins.NobilityPrivilege.NobilityPrivilegeModel"):getInstance()
    local status, reliefCount = NobilityPrivilegeModel:TakeNobilityPrivilegeReliefInfo()
    local reliefUsedCount = tonumber(CacheModel:getCacheByKey("NobilityPrivilegeRelief" .. user.nUserID .. os.date("%Y%m%d", os.time())))
    if not reliefUsedCount then
        reliefUsedCount = 0
    end
    if status and reliefUsedCount and reliefUsedCount >= reliefCount then --当天升级使用低保超过了缓存，则返回
        return
    end

    local client = my.jhttp:create()
    SyncSender.run(
        client,
        function()
            local sender, dataMap

            if status then
                if cc.exports.isSafeBoxSupported() then
                    sender, dataMap = SyncSender.send("takeNobilityPrivilegeRelief")
                else
                    sender, dataMap = SyncSender.send("takeNPNoSafeboxRelief")
                end
            else
                if cc.exports.isSafeBoxSupported() then
                    sender, dataMap = SyncSender.send("takeRelief")
                else
                    sender, dataMap = SyncSender.send("takeNoSafeboxRelief")
                end
            end
            --local sender,dataMap=SyncSender.send('takeRelief')
            dump(dataMap)
            if not dataMap or not dataMap.status or type(dataMap) ~= "table" then
                print("failed to SyncSender send ")
                self:dispatchEvent({name = self.RELIEF_TAKE_FAILED, value = dataMap})
                return
            end

            if ((dataMap.status > 0) and (dataMap.status ~= 10)) then 
                local reliefCount1 = tonumber(CacheModel:getCacheByKey("NobilityPrivilegeRelief" .. user.nUserID .. os.date("%Y%m%d", os.time())))
                if not reliefCount1 then
                    reliefCount1 = 0
                end
                print("999999999999" .. reliefCount1)
                CacheModel:saveInfoToCache("NobilityPrivilegeRelief" .. user.nUserID .. os.date("%Y%m%d", os.time()), reliefCount1 + 1)
                player:setGameDeposit(user.nDeposit + dataMap.status)
                self:UpdateStateAfterOK()
                tipTimer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, self.ShowTip), 0.2, false)

                --发送日志到chunklog
                self:sendLog()
            else
                self:updateStateAfterFailed(dataMap.status)
                self:dispatchEvent({name = self.RELIEF_TAKE_FAILED, value = dataMap})
            end
        end
    )
end

function ReliefActivity:UpdateStateAfterOK()
    --直接通过后台的数据更新
    if next(cc.exports.gameReliefData) == nil then
        return false
    end
    cc.exports.gameReliefData["state"].Count = cc.exports.gameReliefData["state"].Count - 1
    self:mergeReliefState(cc.exports.gameReliefData["state"])

    self.state = self:getReliefState(cc.exports.gameReliefData["state"], cc.exports.gameReliefData["config"])

    --所有用到低保的地方都处理一下
    local NobilityPrivilegeModel = import("src.app.plugins.NobilityPrivilege.NobilityPrivilegeModel"):getInstance()
    local status, reliefCount = NobilityPrivilegeModel:TakeNobilityPrivilegeReliefInfo()
    local reliefUsedCount = tonumber(CacheModel:getCacheByKey("NobilityPrivilegeRelief" .. user.nUserID .. os.date("%Y%m%d", os.time())))
    if not reliefUsedCount then
        reliefUsedCount = 0
    end
    if status and reliefUsedCount and reliefUsedCount >= reliefCount then --当天升级使用低保超过了缓存，则返回
        self.state = self.USED_UP
    end

    self:dispatchEvent({name = self.RELIEF_STATE_UPDATED, value = self})
end

function ReliefActivity:updateStateAfterFailed(status)
    --直接通过后台数据刷新
    if next(cc.exports.gameReliefData) == nil then
        return false
    end
    local TakeFailed = self.TakeFailed
    if status == TakeFailed.act_Expired or status == TakeFailed.act_Forbidden or status == TakeFailed.act_NotExist then
        cc.exports.gameReliefData["state"].status = false
        cc.exports.gameReliefData["config"].Status = self.ActivityStatus.off
    elseif status == TakeFailed.sum_over_today or status == TakeFailed.times_over_today or status == TakeFailed.device_totalTimes_over_today or status == TakeFailed.user_totalTimes_over_today then
        cc.exports.gameReliefData["state"].status = false
    else
        return false
    end
    self:mergeReliefState(cc.exports.gameReliefData["state"])

    self.state = self:getReliefState(cc.exports.gameReliefData["state"], cc.exports.gameReliefData["config"])

    --所有用到低保的地方都处理一下
    local NobilityPrivilegeModel = import("src.app.plugins.NobilityPrivilege.NobilityPrivilegeModel"):getInstance()
    local status, reliefCount = NobilityPrivilegeModel:TakeNobilityPrivilegeReliefInfo()
    local reliefUsedCount = tonumber(CacheModel:getCacheByKey("NobilityPrivilegeRelief" .. user.nUserID .. os.date("%Y%m%d", os.time())))
    if not reliefUsedCount then
        reliefUsedCount = 0
    end
    if status and reliefUsedCount and reliefUsedCount >= reliefCount then --当天升级使用低保超过了缓存，则返回
        self.state = self.USED_UP
    end

    self:dispatchEvent({name = self.RELIEF_STATE_UPDATED, value = self})
end

function ReliefActivity:getCacheDataName()
    local cacheFile = "RelieState.xml"
    local id = user:acountUserUtf8Name()
    local isMember = "NoVip_"
    cacheFile = id .. "_" .. isMember .. cacheFile
    return cacheFile
end

function ReliefActivity:readFromCacheData()
    local dataMap
    local filename = ReliefActivity:getCacheDataName()
    if (false == my.isCacheExist(filename)) then
        return false
    end

    dataMap = my.readCache(filename)
    dataMap = checktable(dataMap)
    local date = ReliefActivity:getTodayDate()
    if (date ~= dataMap.queryDate) then
        return false
    end

    self.state = self:getReliefState(dataMap["state"], dataMap["config"])

    self:mergeReliefState(dataMap["state"])
    self.config = dataMap["config"]

    self:dispatchEvent({name = self.RELIEF_STATE_UPDATED, value = self})

    return true
end

function ReliefActivity:getTodayDate()
    local tmYear = os.date("%Y", os.time())
    local tmMon = os.date("%m", os.time())
    local tmMday = os.date("%d", os.time())
    return tmYear .. "_" .. tmMon .. "_" .. tmMday
end

function ReliefActivity:saveCacheData(dataMap)
    local data = checktable(dataMap)
    data.queryDate = ReliefActivity:getTodayDate()
    my.saveCache(ReliefActivity:getCacheDataName(), data)
end

local visibleSize = cc.Director:getInstance():getVisibleSize()
local origin = cc.Director:getInstance():getVisibleOrigin()

function ReliefActivity:showDepositeGain()
    local newScene = cc.Director:getInstance():getRunningScene()
    local physicLayer = cc.Layer:create()
    newScene:addChild(physicLayer, 100)

    local csbPath = "res/hallcocosstudio/checkin/node_animation_score.csb"
    local node = cc.CSLoader:createNode(csbPath)
    if node then
        physicLayer:addChild(node)
        node:setPosition(cc.p(visibleSize.width / 2 - 100, origin.y + visibleSize.height / 2))
        local action = cc.CSLoader:createTimeline(csbPath)
        if action then
            node:runAction(action)
            action:gotoFrameAndPlay(0, 45, false)
        end
    end
end

function ReliefActivity:mergeReliefState(userState)
    user.reliefData = {
        timesLeft = userState.Count,
        floorRewardUserCount = userState.floorRewardUserCount
    }
    self.floorRewardDeviceCount = userState.floorRewardCount
    self.activityBegan = userState.status
end

function ReliefActivity:getReliefState(us_dataMap, rc_dataMap)
    local gameDeposit = user.nDeposit
    local boxDeposit = 0

    if cc.exports.isSafeBoxSupported() then
        boxDeposit = user.nSafeboxDeposit
    elseif cc.exports.isBackBoxSupported() then
        boxDeposit = user.nBackDeposit
    end

    if (not user.nDeposit or not boxDeposit) then
        player.bNeedRelief = false
        return self.NOT_LOGINED
    else
        if not (self:myCheckTable(us_dataMap) and self:myCheckTable(rc_dataMap)) then
            player.bNeedRelief = false
            return self.NOT_OPENED
        elseif us_dataMap.status then
            cc.exports.gameProtectData.reliefCount = us_dataMap.Count
            cc.exports.gameProtectData.reliefMoney = rc_dataMap.Limit.UpperLimit
            cc.exports.gameProtectData.reliefDailyNum = rc_dataMap.Limit.DailyLimitNum
            printf("set gameProtectData reliefCount %d", cc.exports.gameProtectData.reliefCount)
            if us_dataMap.Count <= 0 then
                player.bNeedRelief = false
                return self.USED_UP
            elseif gameDeposit + boxDeposit < rc_dataMap.Limit.LowerLimit then
            -- elseif gameDeposit + boxDeposit < cc.exports.getReliefLowLimit() then
                player.bNeedRelief = true
                return self.SATISFIED
            else
                player.bNeedRelief = false
                return self.UNSATISFIED
            end
        else
            cc.exports.gameProtectData.reliefCount = us_dataMap.Count
            if rc_dataMap.Limit then
                cc.exports.gameProtectData.reliefMoney = rc_dataMap.Limit.UpperLimit
                cc.exports.gameProtectData.reliefDailyNum = rc_dataMap.Limit.DailyLimitNum
            end
            if rc_dataMap.Status == self.ActivityStatus.on and rc_dataMap.StartDate / 1000 < os.time() and rc_dataMap.EndDate / 1000 > os.time() then
                player.bNeedRelief = false
                return self.USED_UP
            else
                player.bNeedRelief = false
                return self.NOT_OPENED
            end
        end
    end
end

function ReliefActivity:myCheckTable(input)
    return type(input) == "table" and #table.keys(input) > 0
end

function ReliefActivity:updateReliefData()
    if next(cc.exports.gameReliefData) == nil then
        return false
    end
    local dataMap = cc.exports.gameReliefData
    self.state = self:getReliefState(dataMap["state"], dataMap["config"])

    --所有用到低保的地方都处理一下
    local NobilityPrivilegeModel = import("src.app.plugins.NobilityPrivilege.NobilityPrivilegeModel"):getInstance()
    local status, reliefCount = NobilityPrivilegeModel:TakeNobilityPrivilegeReliefInfo()
    local reliefUsedCount = tonumber(CacheModel:getCacheByKey("NobilityPrivilegeRelief" .. user.nUserID .. os.date("%Y%m%d", os.time())))
    if not reliefUsedCount then
        reliefUsedCount = 0
    end
    if status and reliefUsedCount and reliefUsedCount >= reliefCount then --当天升级使用低保超过了缓存，则返回
        self.state = self.USED_UP
    end

    self:mergeReliefState(dataMap["state"])
    self.config = dataMap["config"]

    self:dispatchEvent({name = self.RELIEF_STATE_UPDATED, value = self})
    return true
end

--当日低保奖励是否领取完（条件：有未领取奖励并且未领取完）
function ReliefActivity:isReliefRewardNotUsedUp()
    if self.state == ReliefActivity.USED_UP then
        return false
    end

    if self.state == ReliefActivity.SATISFIED or self.state == ReliefActivity.UNSATISFIED then
        return true
    end

    return false
end

function ReliefActivity:checkAndUpdateReliefProtectData()
    local protectData = cc.exports.gameProtectData
    if protectData == nil or protectData.reliefCount == nil or protectData.reliefCount < 0 then
        if cc.exports.gameReliefData == nil then
            return
        end

        print("checkAndUpdateReliefProtectData, reliefCount illegal " .. tostring(protectData.reliefCount))
        local reliefData = cc.exports.gameReliefData
        if reliefData.state then
            protectData.reliefCount = reliefData.state.Count or 0
        end
        if reliefData.config and reliefData.config.Limit then
            protectData.reliefMoney = reliefData.config.Limit.UpperLimit
            protectData.reliefDailyNum = reliefData.config.Limit.DailyLimitNum
        end
    end
end

function ReliefActivity:sendLog()
    local myGameData = user:getMyGameDataXml(user.nUserID)
    if myGameData then
        myGameData.nTakeReliefCount = (myGameData.nTakeReliefCount or 0) + 1
        user:saveMyGameDataXml(myGameData)
    else
        return
    end

    local ExchangeCenterModel = require("src.app.plugins.ExchangeCenter.ExchangeCenterModel"):getInstance()

    local data = {
        nUserID = user.nUserID,
        nTodayBouts = myGameData.nTodayBouts or 0,
        nTakeCount = myGameData.nTakeReliefCount or 0,
        nExchangeNum = ExchangeCenterModel:getTicketNumData() or 0,
        nDeposit = user.nDeposit or 0,
        nSafeboxDeposit = user.nSafeboxDeposit or 0
    }

    local AssistCommon = require("src.app.GameHall.models.assist.common.AssistCommon"):getInstance()
    AssistCommon:onTakeReliefLogReq(data)
end

function ReliefActivity:getGiftBagClickLogData(excahngeID, price, bCreate)
    local ret = {}
    local t = os.time()
    local user = mymodel("UserModel"):getInstance()
    local clientData = my.getKPIClientData()
    local nRoomID = 0
    if my.isInGame() then
        local PublicInterface = cc.exports.PUBLIC_INTERFACE
        local RoomInfo = PublicInterface.GetCurrentRoomInfo()
        if RoomInfo then
            nRoomID = RoomInfo.nRoomID
        end
    end

    local nScenesID = 1 --福利礼包

    ret.Date = os.date("%Y/%m/%d", t)
    ret.Time = os.date("%H:%M:%S", t)
    ret.UserID = user.nUserID
    ret.Create = bCreate and "true" or "false"
    ret.Channel = clientData.Channel
    ret.RoomID = nRoomID
    ret.SelfDeposit = user.nDeposit
    ret.SafeBoxDeposit = user.nSafeboxDeposit
    ret.ScenesID = nScenesID
    ret.ClickBuyGift = price
    ret.PayStatus = 0
    ret.NowDeposit = user.nDeposit

    return ret
    --my.dataLink(cc.exports.DataLinkCodeDef.GIFT_BAG_CLICK, GiftBagClick) --礼包点击事件埋点
end

function ReliefActivity:isReliefRechargeResult(goodID)
    local items = {
        {12965, 2},
        {12958, 2},
        {12951, 6}
    }
    for i = 1, 3 do
        if goodID == items[i][1] then
            return true
        end
    end
    return false
end

function ReliefActivity:ctor()
    ReliefActivity.super.ctor(self)
    self:initMembers()
end

function ReliefActivity:initMembers()
    self.videoad_us_datamap = nil
    self.videoad_rc_datamap = nil
    self.videoad_take_state = self.NOT_OPENED
end

function ReliefActivity:queryUserVideoAdReliefState()
    local client = my.jhttp:create()
    SyncSender.run(
        client,
        function()
            local us_sender, rc_sender
            us_sender, self.videoad_us_datamap = SyncSender.send("queryVideoAdReliefUserState")
            rc_sender, self.videoad_rc_datamap = SyncSender.send("queryVideoAdReliefConfig")
            dump(self.videoad_us_datamap)
            dump(self.videoad_rc_datamap)
        end
    )
end

function ReliefActivity:canQueryVideoAdRelief()
    return (not self.videoad_rc_datamap or not self.videoad_us_datamap)
end

function ReliefActivity:isVideoAdReliefValid()
    if not cc.exports.isVideoAdReliefSupported() then
        return false
    end

    if self.state ~= self.USED_UP then
        return false
    end

    local gameDeposit = user.nDeposit
    local boxDeposit = 0

    if cc.exports.isSafeBoxSupported() then
        boxDeposit = user.nSafeboxDeposit
    elseif cc.exports.isBackBoxSupported() then
        boxDeposit = user.nBackDeposit
    end

    if (not user.nDeposit or not boxDeposit) then
        return false
    end

    if not (self:myCheckTable(self.videoad_us_datamap) and self:myCheckTable(self.videoad_rc_datamap)) then
        return false
    end

    if not self.videoad_us_datamap.status then
        return false
    end

    if self.videoad_us_datamap.Count <= 0 then
        return false
    end

    if gameDeposit + boxDeposit >= cc.exports.getReliefLowLimit() then
        return false
    end

    return true
end

function ReliefActivity:getVideoAdReliefLeftCount()
    return self.videoad_us_datamap.Count
end

function ReliefActivity:getVideoAdReliefLimitConfig()
    return self.videoad_rc_datamap.Limit
end

function ReliefActivity:takeVideoAdRelief()
    local client = my.jhttp:create()
    SyncSender.run(
        client,
        function()
            local sender, dataMap
            sender, dataMap = SyncSender.send("takeVideoAdRelief")
            if ((dataMap.status > 0) and (dataMap.status ~= 10)) then
                self:updateVideoAdReliefStateAfterOK()
                player:setGameDeposit(user.nDeposit + dataMap.status)
            else
                self:updateVideoAdReliefStateAfterFailed(dataMap.status)
                self:dispatchEvent({name = self.RELIEF_TAKE_FAILED, value = dataMap})
            end
        end
    )
end

function ReliefActivity:updateVideoAdReliefStateAfterOK()
    self.videoad_us_datamap.Count = self.videoad_us_datamap.Count - 1
end

function ReliefActivity:updateVideoAdReliefStateAfterFailed(status)
    local TakeFailed = self.TakeFailed
    if status == TakeFailed.act_Expired or status == TakeFailed.act_Forbidden or status == TakeFailed.act_NotExist then
        self.videoad_us_datamap.status = false
        self.videoad_rc_datamap.Status = self.ActivityStatus.off
    elseif status == TakeFailed.sum_over_today or status == TakeFailed.times_over_today or status == TakeFailed.device_totalTimes_over_today or status == TakeFailed.user_totalTimes_over_today then
        self.videoad_us_datamap.status = false
    end
end

return ReliefActivity
