local TimingGameModel         = class('TimingGameModel', require('src.app.GameHall.models.BaseModel'))
local TimingGameDef           = require('src.app.plugins.TimingGame.TimingGameDef')
local AssistModel             = mymodel('assist.AssistModel'):getInstance()
local user                    = mymodel('UserModel'):getInstance()
local deviceModel             = mymodel('DeviceModel'):getInstance()
local MyTimeStamp             = import('src.app.mycommon.mytimestamp.MyTimeStamp'):getInstance()
local json                    = cc.load("json").json
local RoomListModel           = import("src.app.GameHall.room.model.RoomListModel"):getInstance()

my.addInstance(TimingGameModel)

protobuf.register_file('src/app/plugins/TimingGame/pbTimingGame.pb')

TimingGameModel.EVENT_MAP = {
    ["timinggame_gotoGameByRoomID"] = "timinggame_gotoGameByRoomID",
    ["timinggame_getConfigFromSvr"] = "timinggame_getConfigFromSvr",
    ["timinggame_getInfoDataFromSvr"] = "timinggame_getInfoDataFromSvr",
    ["timinggame_getRobotInfoDataFromSvr"] = "timinggame_getRobotInfoDataFromSvr",
    ["timinggame_getSeasonRecordFromSvr"] = "timinggame_getSeasonRecordFromSvr",
    ["timinggame_getApplySucceedFromSvr"] = "timinggame_getApplySucceedFromSvr",
    ["timinggame_restartGame"] = "timinggame_restartGame",
    ["timinggame_refresh_shop_item"] = "timinggame_refresh_shop_item",
    ["timinggame_addGameBout"] = "timinggame_addGameBout",
}

function TimingGameModel:onCreate()
    self._config = nil
    self._infoData = nil --{applyStartTime = 20201119131201,applyEndTime = 20201119161201}
    self._applyInfo = nil 
    self._seasonRecord = {}
    self._reqRecordTime = {}

    self:initAssistResponse()
end

function TimingGameModel:showTips(str, time)
    local t = time or 2
    my.informPluginByName({pluginName='TipPlugin',params={tipString=str,removeTime=t}})
end

function TimingGameModel:initAssistResponse()
    self._assistResponseMap = {
        [TimingGameDef.GR_TIMING_GAME_QUERY_CONFIG] = handler(self, self.onTimingGameConfig),
        [TimingGameDef.GR_TIMING_GAME_QUERY_INFO] = handler(self, self.onTimingGameInfoData),
        [TimingGameDef.GR_TIMING_GAME_QUERY_RECORD] = handler(self, self.onTimingGameRecord),
        [TimingGameDef.GR_TIMING_GAME_PAY_SUCCESS] = handler(self, self.onPlayerPayOK),
        [TimingGameDef.GR_TIMING_GAME_APPLY_MATCH] = handler(self, self.onApplyMatchRet),
        [TimingGameDef.GR_TIMING_GAME_QUERY_ROBOT_CUR_SCORE] = handler(self, self.onTimingGameRobotInfoData),
    }

    AssistModel:registCtrl(self, self.dealAssistResponse)
end

function TimingGameModel:reqTimingGameConfig()
    print("TimingGameModel:reqTimingGameConfig")
    if not cc.exports.isTimingGameSupported()  then
        return
    end

    if user.nUserID == nil or user.nUserID < 0 then
        print("userinfo is not ok")
        return
    end

    local data = {
        userid = user.nUserID,
    }
    local pdata = protobuf.encode('pbTimingGame.ReqConfig', data)
    AssistModel:sendData(TimingGameDef.GR_TIMING_GAME_QUERY_CONFIG, pdata, false)
end

function TimingGameModel:onTimingGameConfig(data)
    if string.len(data) == nil then return nil end
    if not cc.exports.isTimingGameSupported() then return end

    local pdata = json.decode(data)

    dump(pdata, "TimingGameModel:onTimingGameConfig")

    self._config = pdata

    self:dispatchEvent({name = self.EVENT_MAP["timinggame_getConfigFromSvr"]})

    self:addConfigToShopModel()
end

function TimingGameModel:reqTimingGameInfoData()
    print("TimingGameModel:reqTimingGameInfoData")
    if not cc.exports.isTimingGameSupported()  then
        return
    end

    if user.nUserID == nil or user.nUserID < 0 then
        print("userinfo is not ok")
        return
    end

    local data = {
        userid = user.nUserID,
    }
    local pdata = protobuf.encode('pbTimingGame.QueryInfoDataReq', data)
    AssistModel:sendData(TimingGameDef.GR_TIMING_GAME_QUERY_INFO, pdata, false)
end

function TimingGameModel:onTimingGameInfoData(data)
    if string.len(data) == nil then return nil end
    if not cc.exports.isTimingGameSupported() then return end

    local pdata = protobuf.decode('pbTimingGame.QueryInfoDataResp', data)
    protobuf.extract(pdata)
    dump(pdata, "TimingGameModel:onTimingGameInfoData")

    -- 首次购买状态由0转1：首次购买成功，发布通知，刷新商城Item
    if self._infoData and self._infoData.firstBuyState and toint(self._infoData.firstBuyState) == 0
    and pdata and pdata.firstBuyState and toint(pdata.firstBuyState) >= 1 then
        local ShopModel = mymodel("ShopModel"):getInstance()
        ShopModel:removeShopItemFromConfig("prop_timinggame_ticket_rmb_first", 3)
        self:dispatchEvent({name = self.EVENT_MAP["timinggame_refresh_shop_item"]})
    end

    self._infoData = pdata
    self._infoDataSt = os.time()
    self:checkTimingGameTicketTaskExpire()

    self:addConfigToShopModel()
    
    self:dispatchEvent({name = self.EVENT_MAP["timinggame_getInfoDataFromSvr"]})
end

function TimingGameModel:reqTimingGameRobotInfoData(userID)
    print("TimingGameModel:reqTimingGameInfoData")
    if not cc.exports.isTimingGameSupported()  then
        return
    end

    if user.nUserID == nil or user.nUserID < 0 then
        print("userinfo is not ok")
        return
    end

    local data = {
        userid = userID,
    }
    local pdata = protobuf.encode('pbTimingGame.QueryRobotCurScoreReq', data)
    AssistModel:sendData(TimingGameDef.GR_TIMING_GAME_QUERY_ROBOT_CUR_SCORE, pdata, false)
end

function TimingGameModel:onTimingGameRobotInfoData(data)
    if string.len(data) == nil then return nil end
    if not cc.exports.isTimingGameSupported() then return end

    local pdata = protobuf.decode('pbTimingGame.QueryRobotCurScoreResp', data)
    protobuf.extract(pdata)
    dump(pdata, "TimingGameModel:onTimingGameRobotInfoData")

    self:dispatchEvent({name = self.EVENT_MAP["timinggame_getRobotInfoDataFromSvr"],
         value = pdata})
end

function TimingGameModel:resetLast2ReqRecordTime()
    local tbl = table.keys(self._reqRecordTime)
    table.sort(tbl, function(l, r)
        return l > r
    end)
    for i = 1, 2 do
        if #tbl >= i then
            self._reqRecordTime[tbl[i]] = 0
        end
    end
end

function TimingGameModel:reqTimingGameRecord(seasonStartTime, seasonEndTime)
    print("TimingGameModel:reqTimingGameRecord")
    if not cc.exports.isTimingGameSupported()  then
        return
    end

    if user.nUserID == nil or user.nUserID < 0 then
        print("userinfo is not ok")
        return
    end

    --间隔一段时间再刷新
    if not self._reqRecordTime[seasonStartTime] then
        self._reqRecordTime[seasonStartTime] = os.time()
    else
        local refreshTime = 5 * 60
        if self._config and self._config.HallRefreshTime then
            refreshTime = self._config.HallRefreshTime
        end
        if os.time() - self._reqRecordTime[seasonStartTime] < refreshTime then
            return
        else
            self._reqRecordTime[seasonStartTime] = os.time()
        end
    end

    local data = {
        userid = user.nUserID,
        seasonStartTime = seasonStartTime,
        seasonEndTime = seasonEndTime,
        topNumber = 100,
    }
    local pdata = protobuf.encode('pbTimingGame.QuerySeasonRecordReq', data)
    AssistModel:sendData(TimingGameDef.GR_TIMING_GAME_QUERY_RECORD, pdata, false)
end

function TimingGameModel:onTimingGameRecord(data)
    if string.len(data) == nil then return nil end
    if not cc.exports.isTimingGameSupported() then return end

    local pdata = protobuf.decode('pbTimingGame.QuerySeasonRecordResp', data)
    protobuf.extract(pdata)
    -- dump(pdata, "TimingGameModel:onTimingGameRecord")

    if next(pdata.seasonReacords) and pdata.seasonReacords[1].seasonStartTime then
        self._seasonRecord[pdata.seasonReacords[1].seasonStartTime] = {
            pdata.seasonReacords, --上榜数据
            --pdata.selfRecord --自己数据 只显示上榜数据
        }
        self:dispatchEvent({name = self.EVENT_MAP["timinggame_getSeasonRecordFromSvr"],
         value = {seasonStartTime = pdata.seasonReacords[1].seasonStartTime}})
    else
    end
end

function TimingGameModel:onPlayerPayOK(data)
    if string.len(data) == nil then return nil end
    if not cc.exports.isTimingGameSupported() then return end

    local pdata = protobuf.decode('pbTimingGame.BuyTicketBuyRmbResp', data)
    protobuf.extract(pdata)
    dump(pdata, "TimingGameModel:onPlayerPayOK")

    local playerModel = mymodel("hallext.PlayerModel"):getInstance()
    playerModel:update({'SafeboxInfo','MemberInfo','UserGameInfo'})

    local rewardList = {}
    local RewardTipDef = import("src.app.plugins.RewardTip.RewardTipDef")
    table.insert( rewardList,{nType = RewardTipDef.TYPE_REWARDTYPE_TIMINGGAME_TICKET, nCount = pdata.ticketNum})
    if type(pdata.sliverNum) == "number" and pdata.sliverNum > 0 then
        table.insert( rewardList,{nType = RewardTipDef.TYPE_SILVER, nCount = pdata.sliverNum})
    end
    my.informPluginByName({pluginName = 'RewardTipCtrl', params = {data = rewardList,showOkOnly = true}})

    self:reqTimingGameInfoData()
end

function TimingGameModel:reqApplyMatch()
    if not cc.exports.isTimingGameSupported()  then
        return
    end
      
    if user.nUserID == nil or user.nUserID < 0 then
        print("userinfo is not ok")
        return
    end

    local data = {
        userid = user.nUserID,
        versionNO = 1, --新版本
    }
    local pdata = protobuf.encode('pbTimingGame.ApplyMacthReq', data)
    AssistModel:sendData(TimingGameDef.GR_TIMING_GAME_APPLY_MATCH, pdata, false)
end

function TimingGameModel:onApplyMatchRet(data)
    if string.len(data) == nil then return nil end
    if not cc.exports.isTimingGameSupported() then return end

    local pdata = protobuf.decode('pbTimingGame.ApplyMacthResp', data)
    protobuf.extract(pdata)
    dump(pdata, "TimingGameModel:onApplyMatchRet")

    if pdata.errorReason ~= TimingGameDef.TIMING_GAME_APPLY_SUCCESS then
        local str = "操作失败，请稍后再试！"
        if pdata.errorReason == TimingGameDef.TIMING_GAME_NO_OPEN then
            str = "定时赛未开启！"
        elseif pdata.errorReason == TimingGameDef.TIMING_GAME_NO_MATCH_DATE then
            str = "定时赛今日未开启！"
        elseif pdata.errorReason == TimingGameDef.TIMING_GAME_MATCH_OVER_TIME then
            str = "定时赛今日已结束！"
        elseif pdata.errorReason == TimingGameDef.TIMING_GAME_SEASON_OVER_TIME then
            str = "已过当前赛季报名期限！"
        elseif pdata.errorReason == TimingGameDef.TIMING_GAME_APPLY_REGISTERED then
            str = "已报名!"
        elseif pdata.errorReason == TimingGameDef.TIMING_GAME_APPLY_OVER_LIMIT then
            str = "报名次数超过限制！"
        elseif pdata.errorReason == TimingGameDef.TIMING_GAME_TICKET_NOT_ENOUGH then
            str = "定时赛门票不足！"
        end
        self:showTips(str, 1)
        return
    else
        if self._infoData then
            self._infoData.applyState = 1
            self._infoData.applyDate = pdata.matchDate
            self._infoData.applyStartTime = pdata.matchStartTime
            self._infoData.applyEndTime = pdata.matchEndTime
            self._infoData.applyedTime = self._infoData.applyedTime + 1
            self._infoData.seasonBoutNum = 0
            self._infoData.seasonScore = pdata.initialScore
        end
        self._applyInfo = pdata
        self:reqTimingGameInfoData()
        my.informPluginByName({pluginName='TimingGameApplySucceed'})
        self:dispatchEvent({name = self.EVENT_MAP["timinggame_getApplySucceedFromSvr"]})
    end
end

function TimingGameModel:getConfig()
    return self._config
end

function TimingGameModel:getInfoData()
    return self._infoData
end

--查询获取到infodata的版本
function TimingGameModel:getInfoDataStamp()
    return self._infoDataSt
end

function TimingGameModel:getApplyInfo()
    return self._applyInfo
end

function TimingGameModel:getSeasonRecord()
    return self._seasonRecord
end

function TimingGameModel:getStartEndTimeStr()
    if not self._config or self._config.Enable ~= 1 then
        return "--:-- - --:--"
    end
    local str = string.format("%02d:%02d-%02d:%02d", self._config.StartHour,
     self._config.StartMinute, self._config.EndHour, self._config.EndMinute)

    return str
end

function TimingGameModel:getContinueTimeStr()
    if not self._config or self._config.Enable ~= 1 then
        return "-----"
    end
    local minutes = self._config.SeasonContinueMinutes
    local str
    if minutes % 60 == 0 then
        str = string.format("每场%d小时", minutes / 60)
    else 
        str = string.format("每场%d分钟", minutes)
    end

    return str
end

--目前只支持一个房间
function TimingGameModel:getTimingGameRoomID()
    if not self._config or self._config.Enable ~= 1 then
        return nil
    end
    local rooms = self._config.TimingGameRooms
    if not next(rooms) then
        return
    end
    return rooms[1]
end

function TimingGameModel:gotoTimingGameRoom()
    local roomID = self:getTimingGameRoomID()
    local roomInfo = cc.exports.PUBLIC_INTERFACE.GetCurrentRoomInfo()
    if my.isInGame() and roomInfo and roomInfo.nRoomID ~= roomID then
        if GamePublicInterface._gameController and GamePublicInterface._gameController._baseGameConnect then
            GamePublicInterface._gameController._gotoTimingGameRoom = true
            GamePublicInterface._gameController._baseGameConnect:gc_LeaveGame()
        end
    else
        self:dispatchEvent({name = self.EVENT_MAP["timinggame_gotoGameByRoomID"], value = {["nRoomID"] = roomID}})
    end
end

function TimingGameModel:dispatchRestartGame()
    self:dispatchEvent({name = self.EVENT_MAP["timinggame_restartGame"]})
end

function TimingGameModel:getSelfTicketCount()
    if not self._infoData then return 0 end

    local buyTicketCount = self._infoData.buyTicketNum
    local taskTicketCount = self:getTaskTicketCount()
    return buyTicketCount + taskTicketCount
end

function TimingGameModel:getTaskTicketCount()
    if not self._infoData or not self:isTicketTaskEnable() then return 0 end

    local count = 0
    local date = tonumber(os.date("%Y%m%d", self:getCurrentTime()))
    if date == self._infoData.boutTicketDate then
        for i = 1, TimingGameDef.TIMING_GAME_TICKET_TASK_NUM do
            if self._infoData.gradeBoutTicketStates[i] == 1 then
                count = count + self._infoData.gradeBoutTicketNums[i]
            end
        end
    end
    return count
end

function TimingGameModel:getSelfBuyCount()
    if not self._infoData then return 0 end

    local count = 0
    local date = tonumber(os.date("%Y%m%d", self:getCurrentTime()))
    if self._infoData.activityRmbBuyDate and date == self._infoData.activityRmbBuyDate then
        count = self._infoData.activityRmbBuyCount
    end
    return count
end

function TimingGameModel:getTodayBoutCount()
    if not self._infoData then return 0 end

    local count = 0
    local date = tonumber(os.date("%Y%m%d", self:getCurrentTime()))
    if date == self._infoData.boutTicketDate then
        for i = 1, TimingGameDef.TIMING_GAME_TICKET_TASK_NUM do
            count = count + self._infoData.gradeBoutNums[i]
        end
    end
    return count
end

function TimingGameModel:getPlatform()
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

function TimingGameModel:getActivityBuyConfig()
    if not self._config then return nil end
    local platform = self:getPlatform()
    for i,item in ipairs(self._config.ActivityBuyObtainTickets) do
        if platform == item.Platform then
            return item
        end
    end

    return nil
end

function TimingGameModel:getShopBuyConfig()
    if not self._config then return nil end
    local platform = self:getPlatform()
    for i,item in ipairs(self._config.ShopBuyObtainTickets) do
        if platform == item.Platform then
            return item
        end
    end

    return nil
end

function TimingGameModel:getTimeTable(time)
    local tmp = math.floor(time / 100)
    local second = time - (tmp) * 100
    time = tmp
    tmp = math.floor(time / 100)
    local minute = time - (tmp) * 100
    time = tmp
    tmp = math.floor(time / 100)
    local hour = time - (tmp) * 100
    time = tmp
    tmp = math.floor(time / 100)
    local day = time - (tmp) * 100
    time = tmp
    tmp = math.floor(time / 100)
    local month = time - (tmp) * 100
    time = tmp
    local year = tmp

    return {
        year = year,
        month = month,
        day = day,
        hour = hour,
        min = minute,
        sec = second,
    }
end

function TimingGameModel:getRankReward(ranking)
    if not self._config or type(ranking) ~= "number" then return {} end

    for i,item in ipairs(self._config.RewardDescription) do
        if ranking >= item.StartPlace and ranking <= item.EndPlace then
            return item.Reward
        end
    end
    return {}
end

function TimingGameModel:getCurrentTime()
    local nowtimestamp = MyTimeStamp:getLatestTimeStamp()
    if nowtimestamp == 0 then
        nowtimestamp = os.time()
    end
    return nowtimestamp
end

--返回赛季开始结束时间的时间戳
function TimingGameModel:getCurrentSeasonTime()
    if not self._config then return 0,0 end

    local retStartTime, retEndTime = 0, 0
    local startTime = os.date("*t", self:getCurrentTime())
    startTime.hour = self._config.StartHour
    startTime.min = self._config.StartMinute
    startTime.sec = 0
    local endTime = clone(startTime)
    endTime.hour = self._config.EndHour
    endTime.min = self._config.EndMinute
    endTime.sec = 0
    local stStartTime = os.time(startTime)
    local stEndTime = os.time(endTime)

    local stCurTime = self:getCurrentTime()
    if stCurTime > stEndTime then
        return retStartTime, retEndTime
    end
    if stCurTime < stStartTime then --还未到第一场比赛开始时间
        retStartTime = stStartTime
        retEndTime = stStartTime + self._config.SeasonContinueMinutes * 60
        return retStartTime, retEndTime
    end

    for i = 1, self._config.SeasonRunNum do
        local tmpStart = stStartTime + (i - 1) * self._config.SeasonContinueMinutes * 60
        local tmpEnd = tmpStart + self._config.SeasonContinueMinutes * 60
        if stCurTime >= tmpStart and stCurTime <= tmpEnd then
            retStartTime = tmpStart
            retEndTime = tmpEnd
            return retStartTime, retEndTime
        end
    end

    return retStartTime, retEndTime
end

function TimingGameModel:isEnable()
    if not self._config then return false end
    return (self._config.Enable ~= 0)
end

function TimingGameModel:isMatchDay()
    if not self._config then return false end
    local time = os.date("*t", self:getCurrentTime())
    time.wday = time.wday == 1 and 8 or time.wday --wday星期天是1
    local weekday = time.wday - 1
    return (self._config.Week[weekday] ~= 0)
end

function TimingGameModel:isOverTimeMatchPeriod()
    if not self._config then return false end
    local stCur = self:getCurrentTime()
    local endtime = os.date("*t", self:getCurrentTime())
    endtime.hour = self._config.EndHour
    endtime.min = self._config.EndMinute
    endtime.sec = 0
    local stEnd = os.time(endtime)
    return (stCur > stEnd)
end

function TimingGameModel:isInTimeMatchPeriod()
    if not self._config then return false end
    local stCur = self:getCurrentTime()
    local endtime = os.date("*t", self:getCurrentTime())
    endtime.hour = self._config.EndHour
    endtime.min = self._config.EndMinute
    endtime.sec = 0
    local stEnd = os.time(endtime)

    local starttime = os.date("*t", self:getCurrentTime())
    starttime.hour = self._config.StartHour
    starttime.min = self._config.StartMinute
    starttime.sec = 0
    local stStart = os.time(starttime)
    return (stCur < stEnd and stCur >= stStart)
end

function TimingGameModel:isAbortBoutTimeNotEnough()
    local stStartTime, stEndTime = self:getCurrentSeasonTime()
    local stCurTime = self:getCurrentTime()
    if stStartTime == 0 or stEndTime == 0 
    or (stEndTime - stCurTime) < self._config.SeasonAbortBoutMinutes * 60 then
        return true
    end

    return false
end

function TimingGameModel:canApplyReason()
    if not self._config or not self._infoData then return TimingGameDef.TIMING_GAME_NO_OPEN end
    if not self:isEnable() then return TimingGameDef.TIMING_GAME_NO_OPEN end
    if not self:isMatchDay() then return TimingGameDef.TIMING_GAME_NO_MATCH_DATE end
    if self:isOverTimeMatchPeriod() then return TimingGameDef.TIMING_GAME_MATCH_OVER_TIME end
    local stStartTime, stEndTime = self:getCurrentSeasonTime()
    local stCurTime = self:getCurrentTime()
    if stStartTime == 0 or stEndTime == 0 
    or (stEndTime - stCurTime) < self._config.SeasonAbortApplyMinutes * 60 then
        return TimingGameDef.TIMING_GAME_SEASON_OVER_TIME
    end

    local date = tonumber(os.date("%Y%m%d", self:getCurrentTime()))
    local applyStartTime = self:getTimeTable(self._infoData.applyStartTime)
    local applyEndTime = self:getTimeTable(self._infoData.applyEndTime)
    local stApplyStartTime = os.time(applyStartTime)
    local stApplyEndTime = os.time(applyEndTime)

    local selfTicketCount = self:getSelfTicketCount()
    if date == self._infoData.applyDate and 
    stApplyStartTime == stStartTime and
    stApplyEndTime == stEndTime then
        if  self._infoData.applyState == 1
        and self._infoData.seasonBoutNum < self._config.SeasonMaxBout
        and self._infoData.seasonScore >= self._config.MinScore then
            return TimingGameDef.TIMING_GAME_APPLY_REGISTERED
        end

        if self._infoData.applyedTime >= self._config.SeasonMaxApply then
            return TimingGameDef.TIMING_GAME_APPLY_OVER_LIMIT
        end

        local applyedTime = self._infoData.applyedTime + 1
        applyedTime = applyedTime <= 0 and 1 or applyedTime

        if applyedTime <= #self._config.ApplyTicketsNum and 
        selfTicketCount < self._config.ApplyTicketsNum[applyedTime] then
            return TimingGameDef.TIMING_GAME_TICKET_NOT_ENOUGH
        end
    else
        if selfTicketCount < self._config.ApplyTicketsNum[1] then
            return TimingGameDef.TIMING_GAME_TICKET_NOT_ENOUGH
        end
    end

    return TimingGameDef.TIMING_GAME_APPLY_SUCCESS
end

function TimingGameModel:canStartMatch()
    if not self._config or not self._infoData then return TimingGameDef.TIMING_GAME_NOT_IN_MATCH_PERIOD end
    if not self:isEnable() then return TimingGameDef.TIMING_GAME_NOT_IN_MATCH_PERIOD end
    if not self:isMatchDay() then return TimingGameDef.TIMING_GAME_NOT_IN_MATCH_PERIOD end
    if self:isOverTimeMatchPeriod() then return TimingGameDef.TIMING_GAME_NOT_IN_MATCH_PERIOD end
    local stStartTime, stEndTime = self:getCurrentSeasonTime()
    local stCurTime = self:getCurrentTime()
    if stStartTime == 0 or stEndTime == 0 
    or (stEndTime - stCurTime) < 0 or stCurTime < stStartTime then
        return TimingGameDef.TIMING_GAME_NOT_IN_MATCH_PERIOD
    end
    local applyStartTime = self:getTimeTable(self._infoData.applyStartTime)
    local applyEndTime = self:getTimeTable(self._infoData.applyEndTime)
    local stApplyStartTime = os.time(applyStartTime)
    local stApplyEndTime = os.time(applyEndTime)
    if stApplyStartTime ~= stStartTime or
    stApplyEndTime ~= stEndTime then
        return TimingGameDef.TIMING_GAME_NOT_IN_MATCH_PERIOD
    end

    if self._infoData.applyState ~= 1 then return TimingGameDef.TIMING_GAME_NOT_APPLY end
    if self._infoData.seasonBoutNum >= self._config.SeasonMaxBout then 
        return TimingGameDef.TIMING_GAME_BOUT_NUM_OVER_LIMIT 
    end
    if self._infoData.seasonScore < self._config.MinScore then 
        return TimingGameDef.TIMING_GAME_SCORE_NOT_ENOUGH 
    end

    return TimingGameDef.TIMING_GAME_CAN_START_MATCH
end

--获取按钮状态（开始比赛、报名、比赛截止的状态）
--返回 type, status
function TimingGameModel:getBtnStatus()
    local canStart = self:canStartMatch()
    local canApply = self:canApplyReason() 
    if canStart == TimingGameDef.TIMING_GAME_CAN_START_MATCH then
        return 1, canStart
    elseif canStart == TimingGameDef.TIMING_GAME_BOUT_NUM_OVER_LIMIT 
    or canStart == TimingGameDef.TIMING_GAME_SCORE_NOT_ENOUGH then
        -- local remindAgain = CacheModel:getCacheByKey("TimingGame_CanNotStartTip")
        -- if not remindAgain or remindAgain ~= 1 then
        --     return 1, canStart
        -- else
            -- return 2, canApply 
        -- end
    end
    
    
    if canApply == TimingGameDef.TIMING_GAME_APPLY_SUCCESS
    or canApply == TimingGameDef.TIMING_GAME_TICKET_NOT_ENOUGH then
        return 2, canApply 
    end
    
    if canStart == TimingGameDef.TIMING_GAME_NOT_IN_MATCH_PERIOD 
    and canApply == TimingGameDef.TIMING_GAME_APPLY_REGISTERED then --显示已报名
        return 4, canApply 
    end

    return 3, canApply
end

--判断是否显示对局门票赠送
function TimingGameModel:isShowTimingGameBoutReward()
    if not cc.exports.isTimingGameSupported() 
    or not self:isEnable()
    or not self:isMatchDay() then
        return false, 0
    end
    if not self._config or not self._infoData then return false, 0 end
    local date = tonumber(os.date("%Y%m%d", self:getCurrentTime()))
    if date == self._infoData.boutTicketDate then 
        local index = -1
        for i = 1, TimingGameDef.TIMING_GAME_TICKET_TASK_NUM do
            if self._infoData.gradeBoutTicketStates[i] == 0 then
                index = i
                break
            end
        end
        if index == -1 then return false, 0 end
        if self._infoData.gradeBoutNums[index] >= self._config.GradeBoutObtainTickets[index].MinBoutNum then
            self._infoData.gradeBoutTicketStates[index] = 1
            self._infoData.gradeBoutTicketNums[index] = self._config.GradeBoutObtainTickets[index].BoutExchangeTicketsNum
            return true, self._infoData.gradeBoutTicketNums[index]
        end
    end
    return false, 0 
end

function TimingGameModel:addBoutCount(roomID)
    if not cc.exports.isTimingGameSupported() 
    or not self:isEnable()
    or not self:isMatchDay() then
        return
    end
    if not self._config or not self._infoData then return end
    local date = tonumber(os.date("%Y%m%d", self:getCurrentTime()))

    if date == self._infoData.boutTicketDate then
        local index = -1
        for i = 1, TimingGameDef.TIMING_GAME_TICKET_TASK_NUM do
            if self._infoData.gradeBoutTicketStates[i] == 0 then
                index = i
                break
            end
        end
        if index == -1 then return end
        if self:isRoomIDCanAddBoutByGrade(roomID, index) then
            self._infoData.gradeBoutNums[index] = self._infoData.gradeBoutNums[index] + 1
        end
    else
        for i = 1, TimingGameDef.TIMING_GAME_TICKET_TASK_NUM do
            self._infoData.gradeBoutNums[i] = 0
            self._infoData.gradeBoutTicketStates[i] = 0
            self._infoData.gradeBoutTicketNums[i] = 0
        end
        self._infoData.gradeBoutNums[1] = 1
        self._infoData.boutTicketDate = data
    end
    self:dispatchEvent({name = self.EVENT_MAP["timinggame_addGameBout"]})
    return
end

function TimingGameModel:isRoomIDCanAddBout(roomID)
    if not self._config or not roomID then return false end
    for j = 1, TimingGameDef.TIMING_GAME_TICKET_TASK_NUM do
        for i = 1, #self._config.GradeBoutObtainTickets[j].TicketsRooms do
            if roomID == self._config.GradeBoutObtainTickets[j].TicketsRooms[i] then
                return true
            end
        end
    end
    return false
end

function TimingGameModel:isRoomIDCanAddBoutByGrade(roomID, gradeIndex)
    if not self._config or not roomID then return false end
    if gradeIndex <= 0 or gradeIndex > TimingGameDef.TIMING_GAME_TICKET_TASK_NUM then return end
    for i = 1, #self._config.GradeBoutObtainTickets[gradeIndex].TicketsRooms do
        if roomID == self._config.GradeBoutObtainTickets[gradeIndex].TicketsRooms[i] then
            return true
        end
    end
    return false
end

function TimingGameModel:getShopItem()
    local item = {
        id= 20,
        sid="",
        exchangeid= 12554,

        producttype= 1,
        producttypeex= "deposit",
        paytype=2,

        price= 270000,
        productnum= 1,
        limit= 0,
        notetip= "比赛券购买成功！",

        icontype= 8,
        proptype= "prop_timinggame_ticket_deposit",

        labeltype= 0,
        title= "闪电（100个）",
        description= "",
    
        productname= "闪电（100个）",
        product_subject="闪电（100个）",
        product_body="闪电（100个）",
        app_currency_name="",
        app_currency_rate="",

        productid = ""
    }
    return clone(item)
end

function TimingGameModel:addConfigToShopModel()
    local config = self:getShopBuyConfig()
    local itemDeposit = self:getShopItem()
    local itemRMB = self:getShopItem()
    local itemRMBFirstBuyItem = self:getShopItem()
    if config and itemDeposit and itemRMB then
        itemDeposit.price = config.BuyTicketsSliverNum
        itemDeposit.exchangeid = config.SliverBuyTicketsExchangeID
        itemDeposit.propid = config.SliverBuyTicketsPropID
        local title = string.format("比赛券（%d个）", config.SliverBuyTicketsNum)
        itemDeposit.title = title
        itemDeposit.productname = title
        itemDeposit.product_subject = title
        itemDeposit.product_body = title
        itemDeposit.proptype = "prop_timinggame_ticket_deposit"
        itemDeposit["producttype"] = 4
        itemDeposit["producttypeex"] = "prop"
        
        itemRMB.price = config.BuyTicketsRMBNum
        itemRMB.exchangeid = config.RMBBuyTicketsExchangeID
        local title2 = string.format("比赛券（%d个）", config.RMBBuyTicketsNum)
        itemRMB.title = title2
        itemRMB.productname = title2
        itemRMB.product_subject = title2
        itemRMB.product_body = title2
        --itemRMB.exchangeid = config.RMBBuyTicketsSliverNum
        itemRMB.proptype = "prop_timinggame_ticket_rmb"
        local ex = string.format("{\"RewardToGame\":%d,\"ExchangeId\":%d}",0, itemRMB.exchangeid)
        itemRMB["through_data"] = ex
        itemRMB["producttype"] = 1
        itemRMB["producttypeex"] = "prop_timinggame_ticket_rmb"
        itemRMB["description"] = string.format("送%d两", config.RMBBuyTicketsSliverNum)
        
        itemRMBFirstBuyItem.price = config.FirstBuyTicketsRMBNum
        itemRMBFirstBuyItem.exchangeid = config.FirstRMBBuyTicketsExchangeID
        local title2 = string.format("比赛券（%d个）", config.FirstRMBBuyTicketsNum)
        itemRMBFirstBuyItem.title = title2
        itemRMBFirstBuyItem.productname = title2
        itemRMBFirstBuyItem.product_subject = title2
        itemRMBFirstBuyItem.product_body = title2
        --itemRMBFirstBuyItem.exchangeid = config.FirstRMBBuyTicketsSliverNum
        itemRMBFirstBuyItem.proptype = "prop_timinggame_ticket_rmb_first"
        local ex = string.format("{\"RewardToGame\":%d,\"ExchangeId\":%d}",0, itemRMBFirstBuyItem.exchangeid)
        itemRMBFirstBuyItem["through_data"] = ex
        itemRMBFirstBuyItem["producttype"] = 1
        itemRMBFirstBuyItem["producttypeex"] = "prop_timinggame_ticket_rmb_first"
        itemRMBFirstBuyItem["labeltype"] = 3 

        local ShopModel = mymodel("ShopModel"):getInstance()
        if cc.exports.canTimmingGameGetTicketByWay("deposit") and cc.exports.getTimmingGameTicketEntranceSwitch() ~= 0 then --判断配置中是否开启了支持银子购买门票
            ShopModel:addShopItemToConfig(itemDeposit, 3)            
        end
        
        if not cc.exports.canTimmingGameGetTicketByWay("rmb") or cc.exports.getTimmingGameTicketEntranceSwitch() == 0 then --判断配置中是否开启了支持rmb购买门票
            return
        end
        if self._infoData then
            if not self:getTimingGameFirstBuyState() then
                --ShopModel:addShopItemToConfig(itemRMBFirstBuyItem, 3)
            end
            --ShopModel:addShopItemToConfig(itemRMB, 3)            
        end
    end
end

--需要csd中使用了hallcocosstudio/images/plist/TimingGame合图或者手动加载下
function TimingGameModel:getRewardPathCount(reward)
    local path, count
    if reward.RewardType == 4 then --话费
        if reward.RewardNum == 10 then
            path = "hallcocosstudio/images/plist/TimingGame/huafei_1.png"
        elseif reward.RewardNum == 30 then
            path = "hallcocosstudio/images/plist/TimingGame/huafei_3.png"
        elseif reward.RewardNum == 50 then
            path = "hallcocosstudio/images/plist/TimingGame/huafei_2.png"
        elseif reward.RewardNum == 100 then
            path = "hallcocosstudio/images/plist/TimingGame/huafei_4.png"
        elseif reward.RewardNum == 500 then
            path = "hallcocosstudio/images/plist/TimingGame/huafei_5.png"
        end
        count = 1
    elseif reward.RewardType == 1 then --银子
        path = "hallcocosstudio/images/plist/TimingGame/img_silver.png"
        count = reward.RewardNum
    elseif reward.RewardType == 2 then --礼券
        path = "hallcocosstudio/images/plist/TimingGame/img_exchticket_icon.png"
        count = reward.RewardNum
    end
    if path == nil then path = "hallcocosstudio/images/plist/TimingGame/img_silver.png" end
    if count == nil then count = 1 end
    return path, count
end

function TimingGameModel:setExchangeID(exchangeID)
    self._exchangeID = exchangeID
end

function TimingGameModel:isTimingGameRechargeResult(goodID)
    if type(self._exchangeID) == 'number' and self._exchangeID == goodID then
        return true
    end
    return false
end

function TimingGameModel:getTimingGameLowestBoutTicketRoom()
    local lowRoom
    local config = self._config 
    if not config then return nil end
    for i = 1, #config.BoutObtainTickets[1].TicketsRooms do
        local roomID = config.BoutObtainTickets[1].TicketsRooms[i]
        local roomInfo = RoomListModel.roomsInfo[roomID]
        if roomInfo and roomInfo.gradeIndex and (not lowRoom or lowRoom.gradeIndex > roomInfo.gradeIndex) then
            lowRoom = roomInfo
        end
    end

    return lowRoom
end

function TimingGameModel:getTimingGameFirstBuyState()
    if self._infoData and self._infoData.firstBuyState then
        if toint(self._infoData.firstBuyState) >= 1 then
            return true
        end
    end

    return false
end

--获取各个等级可完成任务的最低房间
function TimingGameModel:getTimingGameLowestGradeBoutTicketRoom()
    local lowRoom
    local config = self._config 
    if not config then return nil end
    local tblRoom = {}
    for j = 1, 4 do
        for i = 1, #config.GradeBoutObtainTickets[j].TicketsRooms do
            local roomID = config.GradeBoutObtainTickets[j].TicketsRooms[i]
            local roomInfo = RoomListModel.roomsInfo[roomID]
            if roomInfo and roomInfo.gradeIndex and (not lowRoom or lowRoom.gradeIndex > roomInfo.gradeIndex) then
                lowRoom = roomInfo
            end
        end
        if lowRoom then
            table.insert(tblRoom, lowRoom)
        end
        lowRoom = nil
    end
    local areaEntry = PUBLIC_INTERFACE.GetCurrentAreaEntry()
    local isNoSuffle = false
    if RoomListModel:checkAreaEntryAvail("noshuffle") == true and (not areaEntry or areaEntry == "noshuffle") then
        isNoSuffle = true
    end
    for j = 1, 4 do
        for i = 1, #config.GradeBoutObtainTickets[j].TicketsRooms do
            local roomID = config.GradeBoutObtainTickets[j].TicketsRooms[i]
            local roomInfo = RoomListModel.roomsInfo[roomID]
            if roomInfo and (tblRoom[j].gradeIndex == roomInfo.gradeIndex)
            and (isNoSuffle == roomInfo.isNoShuffleRoom) then
                tblRoom[j] = roomInfo
            end
        end
    end

    return tblRoom
end

--门票限时抢购每天弹出一次
function TimingGameModel:saveTodayGetTicketPop()
    local CacheModel = cc.exports.CacheModel
    if not CacheModel then return end
    if user.nUserID == nil or user.nUserID < 0 then return end

    local info = {
        timeStamp = self:getCurrentDayStamp() or 0
    }
    CacheModel:saveInfoToCache("TimingGameModel_getticket"..user.nUserID, info)
end

function TimingGameModel:getCurrentDayStamp()
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

function TimingGameModel:isNeedPopGetTicketCtrl()
    if cc.exports.isTimingGameSupported() and self:isEnable() and cc.exports.getTimmingGameTicketEntranceSwitch() == 1 then
        local CacheModel = cc.exports.CacheModel
        if not CacheModel then return false end
        if user.nUserID == nil or user.nUserID < 0 then return false end

        local info = CacheModel:getCacheByKey("TimingGameModel_getticket"..user.nUserID)
        local curStamp = self:getCurrentDayStamp()
        if info.timeStamp == curStamp then
            return false
        else
            return true
        end
    end

    return false
end

--获取当前可完成门票任务的房间
function TimingGameModel:getTimingGameTicketRoom()
    if not self._infoData or not self._config then return end
    local index = -1
    local bAllDone = true
    for i = 1, TimingGameDef.TIMING_GAME_TICKET_TASK_NUM do
        index = i
        if self._infoData.gradeBoutNums[i] < self._config.GradeBoutObtainTickets[i].MinBoutNum then
            bAllDone = false
            break
        end
    end
    local tblRooms = self:getTimingGameLowestGradeBoutTicketRoom()
    return tblRooms[index], bAllDone
end

function TimingGameModel:checkTimingGameTicketTaskExpire()
    if not self._infoData then return end

    local date = tonumber(os.date("%Y%m%d", self:getCurrentTime()))
    if date and date ~= self._infoData.boutTicketDate then
        for i = 1, TimingGameDef.TIMING_GAME_TICKET_TASK_NUM do
            self._infoData.gradeBoutNums[i] = 0
            self._infoData.gradeBoutTicketStates[i] = 0
            self._infoData.gradeBoutTicketNums[i] = 0
        end
        self._infoData.boutTicketDate = date
    end
end

--是否显示门票任务
function TimingGameModel:isTicketTaskEnable()
    if cc.exports.isTimingGameSupported() and self:isEnable() then
        return self._config.TaskEnable ~= 0
    end
    return false
end

--是否显示门票任务入口
function TimingGameModel:isTicketTaskEntryShow()
    if self:isTicketTaskEnable() then
        return cc.exports.getTimmingGameTicketTaskEntranceSwitch() == 1
    end
    return false
end

--是否显示门票任务item
function TimingGameModel:isTicketTaskItemShow()
    if self:isTicketTaskEntryShow() then
        return cc.exports.canTimmingGameGetTicketByWay("task")
    end
    return false
end

function TimingGameModel:updateTicketByReq(rewardList)
    if type(rewardList) ~= 'table' then
        return
    end
    local Def = import("src.app.plugins.RewardTip.RewardTipDef")
    local bHasTimingTicket = false
    for _, v in pairs(rewardList) do
        if v.nType == Def.TYPE_REWARDTYPE_TIMINGGAME_TICKET then
            bHasTimingTicket = true
            break
        end
    end
    if bHasTimingTicket then
        self:reqTimingGameInfoData()
    end
end

return TimingGameModel