local ActivityCenterModel 		        = class('ActivityCenterModel', require('src.app.GameHall.models.BaseModel'))

local PropertyBinder                = cc.load('coms').PropertyBinder
local WidgetEventBinder             = cc.load('coms').WidgetEventBinder
local AssistModel                   = mymodel('assist.AssistModel'):getInstance()
local ActivityCenterStruct          = import('src.app.plugins.activitycenter.ActivityCenterStruct')
local ActivityCenterConfig          = import('src.app.plugins.activitycenter.ActivityCenterConfig')
local ActivityCenterStatus          = import('src.app.plugins.activitycenter.ActivityCenterStatus'):getInstance()
local TimeCalculator                = import("src.app.plugins.timecalc.TimeCalculator")

local player         	            = mymodel('hallext.PlayerModel'):getInstance()
local User                          = mymodel('UserModel'):getInstance()

local treepack                      = cc.load('treepack')
local ChannelConfig                 = cc.load("json").json.decode(cc.FileUtils:getInstance():getStringFromFile("ChannelConfig.json"))
local AppConfig                     = cc.load("json").json.decode(cc.FileUtils:getInstance():getStringFromFile("AppConfig.json"))
-- 活动模块
local PhoneFeeGiftModel = require('src.app.plugins.PhoneFeeGift.PhoneFeeGiftModel'):getInstance()
local ExchangeLotteryModel = require('src.app.plugins.ExchangeLottery.ExchangeLotteryModel'):getInstance()
local UserModel = mymodel('UserModel'):getInstance()
local RedPack100Model = require('src.app.plugins.RedPack100.RedPack100Model'):getInstance()
local WinningStreakModel = require('src.app.plugins.WinningStreak.WinningStreakModel'):getInstance()
local DailyRechargeModel = import('src.app.plugins.DailyRecharge.DailyRechargeModel'):getInstance()

my.addInstance(ActivityCenterModel)

-- 通讯消息
local ActivityCenterDef = {
    GR_GET_ACTIVITY_MATRIC_INFO       = 401501,
    GR_GET_ACTIVITY_TASK_CONFIG       = 401503,
    GR_GET_ACTIVITY_TASK_DATA         = 401504,
    GR_GET_ACTIVITY_TASK_REWERD       = 401505,
    GR_GET_ACTIVITY_TASK_REDDOT       = 401508,
}

my.setmethods(ActivityCenterModel, PropertyBinder)
my.setmethods(ActivityCenterModel, WidgetEventBinder)


ActivityCenterModel.AC_LOTTERY = "AC_LOTTERY"
ActivityCenterModel.AC_TREASURE_BOX = "AC_TREASURE_BOX"

ActivityCenterModel.AC_TREASURE_BOX_TYPE = 101
ActivityCenterModel.AC_LOTTERY_TYPE = 102


ActivityCenterModel.ACTIVITY_IFNO_UPDATED = "ACTIVITY_IFNO_UPDATED"
--ActivityCenterModel.ACTIVITY_REDDOT_UPDATED = "ACTIVITY_REDDOT_UPDATED"

ActivityCenterModel.ACTIVITY_SHOW = "ACTIVITY_SHOW"
ActivityCenterModel.ACTIVITY_CLOSE = "ACTIVITY_CLOSE"
ActivityCenterModel.CLOSE_SEND_AGAIN = "CLOSE_SEND_AGAIN"
ActivityCenterModel.ACTIVITY_TASK_UPDATE = "ACTIVITY_TASK_UPDATE"
ActivityCenterModel.ACTIVITY_TASK_REWARD = "ACTIVITY_TASK_REWARD"
ActivityCenterModel.ACTIVITY_SHOW_REWARD = "ACTIVITY_SHOW_REWARD"

ActivityCenterModel.UNKNOWN_TYPE = 0
ActivityCenterModel.ACTIVITY_TYPE = 1            --活动类型
ActivityCenterModel.NOTICE_TYPE = 2              --公告类型
ActivityCenterModel.TEXT_TYPE = 1                --文字类型
ActivityCenterModel.LINK_TYPE = 2                --链接类型
ActivityCenterModel.PAGE_TYPE = {ActivityCenterModel.ACTIVITY_TYPE, ActivityCenterModel.NOTICE_TYPE}
ActivityCenterModel.LOWWESTPRIORITY = 1000

ActivityCenterModel.ACTIVITY_START = 100
ActivityCenterModel.ACTIVITY_END   = 199
ActivityCenterModel.NOTICE_START   = 200
ActivityCenterModel.HSOX_START       = 300
ActivityCenterModel.NOTICE_END     = 10000
ActivityCenterModel.HSOXACTVER       = 20180423

ActivityCenterModel.TASK_ID    = 106


ActivityCenterModel.AC_LOTTERY = "OA_LOTTERY"
ActivityCenterModel.AC_TREASURE_BOX = "OA_TREASURE_BOX"


-- wuym 收到数据通知各模块
function ActivityCenterModel:GetActivity101()
    return PhoneFeeGiftModel:gc_PhoneFeeGiftReq()
end

function ActivityCenterModel:GetActivity102()
    ExchangeLotteryModel:SetChannelOpen(true)
    return ExchangeLotteryModel:gc_GetExchangeLotteryInfo()
end

function ActivityCenterModel:GetActivity104()
    return RedPack100Model:gc_GetRedPackInfo()
end

function ActivityCenterModel:GetActivity105()
    return WinningStreakModel:gc_GetWinningStreakInfo()
end

function ActivityCenterModel:GetActivity106()
    return DailyRechargeModel:gc_GetDailyRechargeInfo()
end

ActivityCenterModel.DispatchActivityList = {
    [101] = ActivityCenterModel.GetActivity101,
    [102] = ActivityCenterModel.GetActivity102,
    [104] = ActivityCenterModel.GetActivity104,
    [105] = ActivityCenterModel.GetActivity105,
    [106] = ActivityCenterModel.GetActivity106,
}

-- 先默认不显示，等活动本身获取到数据后再刷新界面的列表
ActivityCenterModel.DefaultActivityShow = {
    [101] = false,
    [102] = false,
    [104] = false,           -- wuymDebug
    [105] = false,           
    [106] = false,
}

-- 不关心渠道是否配置，都要让活动本身自己去获取数据的列表
ActivityCenterModel.IgnoreChannelID = {
    [104] = true,
}



ActivityCenterModel.EVENT_MAP = {
    ["activity_newContentAvail"] = "activity_newContentAvail"
}

function ActivityCenterModel:onCreate()
    self._matrix = {}
    self._matrixInfo = {}
    self._matrixInfoSearchKey = {} 
    self._matrixAllInfo = {}
    self._matrixAllInfoSearchKey = {}

    self._activityInfo = {}
    self._activityInfoSearchKey = {}

    self._noticeInfo = {}
    self._noticeInfoSearchKey = {}

    self._redDotTypeCount = {}

    self._curDate = nil
    self._activityTaskConfig = nil
    self._activityTaskGroup = nil
    self._activityTaskData = nil
    self._activityTaskReddot = nil
    self._activityLoginLock = false

    --self._userID = nil
    self:init()
end

function ActivityCenterModel:init()

    --用户登录成功以后，获取抽奖模块数据
    self:bindProperty(player, 'PlayerLoginedData', self, 'OnLoginSuccessEvent')
end

function ActivityCenterModel:clearMemData()
    self._matrix = {}
    self._matrixInfo = {}
    self._matrixInfoSearchKey = {} 
    self._matrixAllInfo = {}
    self._matrixAllInfoSearchKey = {}

    self._activityInfo = {}
    self._activityInfoSearchKey = {}

    self._noticeInfo = {}
    self._noticeInfoSearchKey = {}

    self._redDotTypeCount = {}

    self._curDate = nil
    self._activityTaskConfig = nil
    self._activityTaskGroup = nil
    self._activityTaskData = nil
    self._activityTaskReddot = nil
    self._activityLoginLock = false

    --self._userID = nil
end

function ActivityCenterModel:setOnLoginSuccessEvent(data)
    if data.nUserID then
        self:clearMemData() -- 单包切换账号的时，可能出现内存数据没清理
        --self._userID = data.nUserID
        
        self:initResponseID()
    end
end


function ActivityCenterModel:initResponseID()
    self._assistResponseMap = {
        [ActivityCenterDef.GR_GET_ACTIVITY_MATRIC_INFO] = handler(self, self.onActivityMaxtrixInfo),
        [ActivityCenterDef.GR_GET_ACTIVITY_TASK_CONFIG] = handler(self, self.onActivityTaskConfig),
        [ActivityCenterDef.GR_GET_ACTIVITY_TASK_DATA] = handler(self, self.onActivityTaskData),
        [ActivityCenterDef.GR_GET_ACTIVITY_TASK_REWERD] = handler(self, self.onActivityTaskReward),
        [ActivityCenterDef.GR_GET_ACTIVITY_TASK_REDDOT] = handler(self, self.onActivityTaskRedDot)
    }
    AssistModel:registCtrl(self, self.dealAssistResponse)
end

function ActivityCenterModel:getActivityMaxtrixInfo()
    if not UserModel.nUserID then return false end
    local data      = {
        nUserID     = UserModel.nUserID,
        nReserved = {0, 1, 0, 0}
    }
    
    AssistModel:sendRequest(ActivityCenterDef.GR_GET_ACTIVITY_MATRIC_INFO, ActivityCenterStruct["GET_JSON_HEAD_INFO"], data, false)
end

function ActivityCenterModel:onActivityMaxtrixInfo(data)
    UIHelper:recordRuntime("ShowRedPackOnLaunch", "ActivityCenterModel:onActivityMaxtrixInfo")
    if data == nil then return    end
    local getJsonHeadInfo = AssistModel:deserialize(data, ActivityCenterStruct["GET_JSON_HEAD_INFO"])

    getJsonHeadInfo.matrixList = {}
    getJsonHeadInfo.noticeInfoList = {}
    getJsonHeadInfo.activityInfoList = {}

    if getJsonHeadInfo.nJsonLen>0 then
        local jsonBodyTemplate = clone(ActivityCenterStruct["JSON_BODY_TEMPLATE"])  
        jsonBodyTemplate.lengthMap[1] = getJsonHeadInfo.nJsonLen 
        jsonBodyTemplate.formatKey = string.format(jsonBodyTemplate.formatKey, getJsonHeadInfo.nJsonLen)
        jsonBodyTemplate.deformatKey = string.format(jsonBodyTemplate.deformatKey, getJsonHeadInfo.nJsonLen)
        jsonBodyTemplate.maxsize = getJsonHeadInfo.nJsonLen   

       local jsonBody = treepack.unpack(string.sub(data, ActivityCenterStruct["GET_JSON_HEAD_INFO"].maxsize + 1), jsonBodyTemplate)
        getJsonHeadInfo.matrixList = cc.load("json").json.decode(jsonBody.szJson) 
        --dump(getJsonHeadInfo.matrixList)         
    end

    if getJsonHeadInfo.nReserved[1]>0 then
        local jsonBodyTemplate = clone(ActivityCenterStruct["JSON_BODY_TEMPLATE"])  
        jsonBodyTemplate.lengthMap[1] = getJsonHeadInfo.nReserved[1]  
        jsonBodyTemplate.formatKey = string.format(jsonBodyTemplate.formatKey, getJsonHeadInfo.nReserved[1])
        jsonBodyTemplate.deformatKey = string.format(jsonBodyTemplate.deformatKey, getJsonHeadInfo.nReserved[1])
        jsonBodyTemplate.maxsize = getJsonHeadInfo.nReserved[1]    

        local jsonBody = treepack.unpack(string.sub(data, ActivityCenterStruct["GET_JSON_HEAD_INFO"].maxsize + getJsonHeadInfo.nJsonLen + 1), jsonBodyTemplate)

        getJsonHeadInfo.noticeInfoList = cc.load("json").json.decode(jsonBody.szJson) 
        --dump(getJsonHeadInfo.noticeInfoList)       
    end

    if getJsonHeadInfo.nReserved[2]>0 then
        local jsonBodyTemplate = clone(ActivityCenterStruct["JSON_BODY_TEMPLATE"])  
        jsonBodyTemplate.lengthMap[1] = getJsonHeadInfo.nReserved[2]  
        jsonBodyTemplate.formatKey = string.format(jsonBodyTemplate.formatKey, getJsonHeadInfo.nReserved[2])
        jsonBodyTemplate.deformatKey = string.format(jsonBodyTemplate.deformatKey, getJsonHeadInfo.nReserved[2])
        jsonBodyTemplate.maxsize = getJsonHeadInfo.nReserved[2]   

        local jsonBody = treepack.unpack(string.sub(data, ActivityCenterStruct["GET_JSON_HEAD_INFO"].maxsize + getJsonHeadInfo.nJsonLen + getJsonHeadInfo.nReserved[1] + 1), jsonBodyTemplate)

        getJsonHeadInfo.activityInfoList = cc.load("json").json.decode(jsonBody.szJson) 
        --dump(getJsonHeadInfo.activityInfoList)         
    end

    self:dealMatrix(getJsonHeadInfo.matrixList) 
    self:dealActivityInfo(getJsonHeadInfo.activityInfoList) 
    self:dealNoticeInfo(getJsonHeadInfo.noticeInfoList)  
    self:judegePriorityIndex()

    --登录弹窗模块
    local PluginProcessModel = mymodel("hallext.PluginProcessModel"):getInstance()
    PluginProcessModel:setPluginReadyStatus("ActivityCenterCtrl", true)
    PluginProcessModel:startPluginProcess()   
    
    self:dispatchEvent({name=self.CLOSE_SEND_AGAIN})
    --self:showActivityCenter()
end

-- 需求： 其他插件关闭的时候触发，显示独立，其他插件调用
function ActivityCenterModel:showActivityCenter()
    local propType = self:getPriority(self.UNKNOWN_TYPE)
    if propType and propType > self.UNKNOWN_TYPE then
        if my.isInGame() then
        elseif User.nBout and User.nBout > 0 then
            my.informPluginByName({pluginName='ActivityCenterCtrl', params={auto=true}})       
            local info = self:getMatrixPageInfo(propType)
            local activeActivityIndex = self:getPriority(propType)
            ActivityCenterStatus:addActivityCount(info[activeActivityIndex]["activity"])
        end
    end
end

function ActivityCenterModel:dealMatrix(matrix)
    local matrixInfo = {}
    local matrixInfoSearchKey = {}
    local matrixAllInfo = {}
    local matrixAllInfoSearchKey = {}
    local delayExcuteFunction = {}

    if matrix ~= nil then
        table.sort(matrix, function(a, b) return a.id < b.id end)
    end

    for m, n in ipairs(ActivityCenterModel.PAGE_TYPE) do
        matrixInfo[n] = {}
        matrixInfoSearchKey[n] = {}
    end

    for k, v in pairs(matrix) do
        self:judgeNeedPresent(v)
        
        if v.needShow then
            --if (v.type == self.ACTIVITY_TYPE and ActivityCenterConfig.ActivityList[v.activity]) or v.type == self.NOTICE_TYPE then

            local bShowEx = true
            if ActivityCenterModel.DefaultActivityShow[v.activity] ~= nil  then
                bShowEx = ActivityCenterModel.DefaultActivityShow[v.activity]
            end
            v.showByActivityReturn = bShowEx    -- DefaultActivityShow 列表中的默认一开始不显示，需要等各活动自行判断结果

            if v.type == self.ACTIVITY_TYPE or v.type == self.NOTICE_TYPE then 
                table.insert(matrixInfo[v.type], v)
                table.insert(matrixAllInfo, v)
                matrixInfoSearchKey[v.type][v.activity] = table.maxn(matrixInfo[v.type])
                matrixAllInfoSearchKey[v.activity] = table.maxn(matrixAllInfo)
                local getCount, getData, getRedDot = ActivityCenterStatus:getUserStatus(v.activity)
                if v.reddot == 1 and not getRedDot then
                    if v.showByActivityReturn == true then -- 过滤掉需要活动本身来设置的
                        self:addRedDotTypeCount(v.type, v.activity)
                        v.reddotShow = true
                    end
                else
                    self:subRedDotTypeCount(v.type, v.activity, false)
                    v.reddotShow = false
                end
            end
            --self:dispatchEvent({name=self.ACTIVITY_REDDOT_UPDATED})
            self._myStatusDataExtended["isNeedReddot"] = self:isNeedReddot()
            self:dispatchModuleStatusChanged("activity", ActivityCenterModel.EVENT_MAP["activity_newContentAvail"])

            if (v.type == self.ACTIVITY_TYPE and ActivityCenterConfig.ActivityList[v.activity]) then
                local func = ActivityCenterModel.DispatchActivityList[v.activity] or ""
                if func ~= "" then
                    table.insert(delayExcuteFunction, func) -- 这里先插入，放最后执行，避免self_matrixInfoserchkey等还没赋值，子活动就回馈给activitycenter处理了
                end
            end
           
        end
    end

    self._matrix = matrix
    self._matrixInfo = matrixInfo
    self._matrixInfoSearchKey = matrixInfoSearchKey 
    self._matrixAllInfo = matrixAllInfo
    self._matrixAllInfoSearchKey = matrixAllInfoSearchKey

    for k, v in pairs(delayExcuteFunction) do
        if v then
            v()
        end
    end

end

function ActivityCenterModel:judgeNeedPresent(data)
    if data.activity and ActivityCenterModel.IgnoreChannelID[data.activity] == true then
        return self:judgeNeedShowIgnoreChannelID(data)
    end

    local channelID = BusinessUtils:getInstance():getTcyChannel() --ChannelConfig["recommander_id"]
    local version = AppConfig["version"]
 
    local bNeedShow = true
    if string.find(data["openchannel"], channelID) ~= nil then
        bNeedShow = true
    elseif string.len(data["openchannel"]) == 0 then
        if string.find(data["closechannel"], channelID) ~= nil then
            bNeedShow = false
        elseif data["closechannel"] == "-1" then
            bNeedShow = false                                                                                                                                                                                            
        else
            bNeedShow = true
        end
    else
        bNeedShow = false
    end

    if bNeedShow then
        if data["version"] == "-1" then
            bNeedShow = true
        elseif string.find(data["version"], version) then
            bNeedShow = true
        else
            bNeedShow = false
        end
    end
    if bNeedShow and data.displaydate ~= ""  and data.displaytime ~= "" then -- 配置了日期就要配置时间段
        local beginDate, endDate = self:praseTimeRegion(data.displaydate)
        local beginTime, endTime = self:praseTimeRegion(data.displaytime)
        local nCurDate = tonumber(os.date("%Y%m%d"))
        local nCurTime = tonumber(os.date("%H%M%S"))

        bNeedShow = ((beginDate == 0 and endDate == 0 ) or (nCurDate >= beginDate and nCurDate <= endDate)) and
            (nCurTime >= beginTime and nCurTime <= endTime)

    end
    data["needShow"] = bNeedShow

    return bNeedShow
end

function ActivityCenterModel:judgeNeedShowIgnoreChannelID(data)
    local continueDays = {
        [104] = 7,      -- 百红包延续天数： 配置的结束天数 + 延续天数内都允许显示。

    }
    local bNeedShow = true
    if bNeedShow and data.displaydate ~= ""  and data.displaytime ~= "" then -- 配置了日期就要配置时间段
        local beginDate, endDate = self:praseTimeRegion(data.displaydate)
        local beginTime, endTime = self:praseTimeRegion(data.displaytime)
        local nCurDate = tonumber(os.date("%Y%m%d"))
        local nCurTime = tonumber(os.date("%H%M%S"))

        local endDateTime = string.format("%s000000", endDate)
        local nDay = continueDays[data.activity] or 0
        local strFinalDate = cc.exports.getNewDate(endDateTime, nDay, "Day") -- 往后加x天,
        local nFinalDate = tonumber(strFinalDate)
        bNeedShow = ((beginDate == 0 and endDate == 0 ) or (nCurDate >= beginDate and nCurDate <= nFinalDate)) and
            (nCurTime >= beginTime and nCurTime <= endTime)

    end
    data["needShow"] = bNeedShow
    return bNeedShow
end

function ActivityCenterModel:dealActivityInfo(activityInfo)
    self._activityInfo = activityInfo
    self._activityInfoSearchKey = {}
    for k, v in ipairs(activityInfo) do
        self._activityInfoSearchKey[v.activityId] = k 
    end
end

function ActivityCenterModel:dealNoticeInfo(noticeInfo)
    self._noticeInfo = noticeInfo
    self._noticeInfoSearchKey = {}
    for  k, v in ipairs(noticeInfo) do
        self._noticeInfoSearchKey[v.id] = k
    end
end

function ActivityCenterModel:judegePriorityIndex()
    self._activeActivityIndex = 0
    self._activeNoticeIndex = 0
    self._priorityType = nil
    

    local activeActivityIndex, activeActivityData = self:judgeActivePresent(self._matrixInfo[self.ACTIVITY_TYPE])
    local activeNoticeIndex, activeNoticeData = self:judgeActivePresent(self._matrixInfo[self.NOTICE_TYPE])

    if activeActivityIndex == 0 then
        activeActivityIndex = 1
    end
    if activeNoticeIndex == 0 then
        activeNoticeIndex = 1
    end

    if activeActivityData and activeNoticeData then
        if activeActivityData["priority"] < activeNoticeData["priority"] then
            self._priorityType = activeActivityData["type"]
        elseif activeActivityData["priority"] > activeNoticeData["priority"] then
            self._priorityType = activeNoticeData["type"]
        elseif activeActivityData["id"] < activeNoticeData["id"] then
            self._priorityType = activeActivityData["type"] 
        else
            self._priorityType = activeNoticeData["type"]
        end 
    else
        if activeActivityData then
            self._priorityType = activeActivityData["type"]
        elseif activeNoticeData then
            self._priorityType = activeNoticeData["type"]
        end
    end

    self._activeActivityIndex = activeActivityIndex
    self._activeNoticeIndex   = activeNoticeIndex

end

function ActivityCenterModel:judgeActivePresent(pageInfo)
    local priority = self.LOWWESTPRIORITY
    local leftcount = 0 
    local priorityIndex = 0
    local priorityData = nil
    for k, v in pairs(pageInfo) do
        leftcount = self:calcLeftCount(v)
        if leftcount > 0 then
            if v["priority"] < priority then
                priorityIndex = k
                priorityData = v
                priority = v["priority"]
            end
        end
    end

    return priorityIndex, priorityData
end

function ActivityCenterModel:calcLeftCount(data)
    local user = mymodel('UserModel'):getInstance()
    if user == nil or user.nUserID == nil then
        return 0
    end
    local count, date = ActivityCenterStatus:getUserStatus(data.activity)
    local tempdate = {}
    local leftcount = 0
    local nowTime = os.time()
    tempdate.year = tonumber(string.sub(date, 1, 4))
    tempdate.month = tonumber(string.sub(date, 5, 6))
    tempdate.day = tonumber(string.sub(date, 7, 8))
    local diffdays = TimeCalculator:getDaysBetweenTwoDate(tempdate, os.date("*t", nowTime))
    if data.cycle > 0 then
        if diffdays >= data.cycle then
            leftcount = data.count
            if data.count == -1 then
                leftcount = 1
            end
            ActivityCenterStatus:updateActivity(data.activity, os.date("%Y%m%d"), 0, false)
        else
            leftcount = data.count - count
            if data.count == -1 then
                leftcount = 1 
            end
        end
    elseif data.cycle == -1 then
        leftcount = data.count - count
        if data.count == -1 then
            leftcount = 1
        end
    end

    return leftcount
end

function ActivityCenterModel:onDestory()
    printf("ActivityCenterModel removeSelf()")
    AssistModel:unRegistCtrl(self)
    ActivityCenterModel.super.removeSelf(self)
end

function ActivityCenterModel:getMatrixPageInfo(pageType)
    return self._matrixInfo and self._matrixInfo[pageType] or nil
end

function ActivityCenterModel:getMatrixInfoByKey(pageType, activityId)
    if not self._matrixInfoSearchKey or not self._matrixInfoSearchKey[pageType] or not self._matrixInfoSearchKey[pageType][activityId] then
        return nil
    end
    return self._matrixInfo[pageType][self._matrixInfoSearchKey[pageType][activityId]]
end

-- 外部模块调用，设置活动页签是否显示
function ActivityCenterModel:isNeedRefresh(activityId, bShow)
    local bRet = true

    local pageInfo = self:getMatrixInfoByKey(ActivityCenterModel.ACTIVITY_TYPE, activityId)
    if not pageInfo then
        return false  -- 数据都没准备好，就不去更新公告界面红点以及显示
    end
    if pageInfo.showByActivityReturn == bShow then
        bRet = false
    end
    return bRet
end

function ActivityCenterModel:setMatrixActivityNeedShow(activityId, bShow)
    local pageInfo = self:getMatrixInfoByKey(ActivityCenterModel.ACTIVITY_TYPE, activityId)
    if not pageInfo then
        return  -- 数据都没准备好，就不去更新公告界面红点以及显示
    end
    pageInfo.showByActivityReturn = bShow
    if activityId == ActivityCenterConfig.ActivityExplain["exchangelottery"] then
        if ExchangeLotteryModel:NeedShowRedDot() == true then
            self:addRedDotTypeCount(self.ACTIVITY_TYPE, activityId, true)
        end
    elseif activityId == ActivityCenterConfig.ActivityExplain["phonefeegift"] then
        if PhoneFeeGiftModel:NeedShowRedDot() == true then
            self:addRedDotTypeCount(self.ACTIVITY_TYPE, activityId, true)
        end
    elseif activityId == ActivityCenterConfig.ActivityExplain["redpack100"] then
        if RedPack100Model:NeedShowRedDot() == true then
            self:addRedDotTypeCount(self.ACTIVITY_TYPE, activityId, true)
        end
    elseif activityId == ActivityCenterConfig.ActivityExplain["winningstreak"] then
        if WinningStreakModel:NeedShowRedDot() == true then
            self:addRedDotTypeCount(self.ACTIVITY_TYPE, activityId, true)
        end
    elseif activityId == ActivityCenterConfig.ActivityExplain["dailyrecharge"] then
        if DailyRechargeModel:NeedShowRedDot() == true then
            self:addRedDotTypeCount(self.ACTIVITY_TYPE, activityId, true)
        end
    end
    self:dispatchEvent({name=self.ACTIVITY_SHOW})
end


function ActivityCenterModel:getActivityInfoByKey(activityId)
    if self._activityInfoSearchKey and self._activityInfoSearchKey[activityId] then
        return self._activityInfo[self._activityInfoSearchKey[activityId]]
    else
        return nil
    end
end

function ActivityCenterModel:getNoticeInfoByKey(activityId)
    return self._noticeInfo[self._noticeInfoSearchKey[activityId]]
end

function ActivityCenterModel:addRedDotTypeCount(redDotType, activityId, needUpdate)
    self._redDotTypeCount[redDotType] = self._redDotTypeCount[redDotType] or {}
    self._redDotTypeCount[redDotType][activityId] = true
    if needUpdate then
        --self:dispatchEvent({name=self.ACTIVITY_REDDOT_UPDATED})
        self._myStatusDataExtended["isNeedReddot"] = self:isNeedReddot()
        self:dispatchModuleStatusChanged("activity", ActivityCenterModel.EVENT_MAP["activity_newContentAvail"])
    end
end

function ActivityCenterModel:subRedDotTypeCount(redDotType, activityId, needUpdate)
    self._redDotTypeCount[redDotType] = self._redDotTypeCount[redDotType] or {}
    self._redDotTypeCount[redDotType][activityId] = false
    if needUpdate then
        --self:dispatchEvent({name=self.ACTIVITY_REDDOT_UPDATED})
        self._myStatusDataExtended["isNeedReddot"] = self:isNeedReddot()
        self:dispatchModuleStatusChanged("activity", ActivityCenterModel.EVENT_MAP["activity_newContentAvail"])
    end
end

function ActivityCenterModel:getRedDotTypeCount(redDotType)
    if self._redDotTypeCount == nil then
        return 0
    end
    self._redDotTypeCount[redDotType] = self._redDotTypeCount[redDotType] or {}
    local redDotCount = 0
    for k, v in pairs(self._redDotTypeCount[redDotType]) do
        if v then 
            redDotCount = redDotCount + 1
        end
    end

    return redDotCount
end

function ActivityCenterModel:getAllRedDotCount()
    if self._redDotTypeCount == nil then
        return 0
    end
    self._redDotTypeCount = self._redDotTypeCount or {}
    self._redDotTypeCount[self.ACTIVITY_TYPE] = self._redDotTypeCount[self.ACTIVITY_TYPE] or {}
    self._redDotTypeCount[self.NOTICE_TYPE] = self._redDotTypeCount[self.NOTICE_TYPE] or {}
    local redDotCount = 0
    for k, v in pairs(self._redDotTypeCount) do
        for m, n in pairs(v) do
            if math.floor(m / 10000) == self.TASK_ID then
                if self._activityTaskReddot then
                    for p, q in pairs(self._activityTaskReddot) do
                        if rawget(q, "nTaskGID") == m then
                            n = (rawget(q, "nRedDotCnt") > 0) and true or false
                        end
                    end
                else
                    n = false
                end
            end
            if n then 
                redDotCount = redDotCount + 1
            end
        end
    end
    return redDotCount
end

function ActivityCenterModel:getPriority(pageType)
    if pageType == self.UNKNOWN_TYPE then
        return self._priorityType
    elseif pageType == self.ACTIVITY_TYPE then
        return self._activeActivityIndex
    elseif pageType == self.NOTICE_TYPE then
        return self._activeNoticeIndex
    else
        return self._priorityType
    end
end

function ActivityCenterModel:resetActivityRedDot(activityType)
    self._redDotTypeCount[self.ACTIVITY_TYPE] = self._redDotTypeCount[self.ACTIVITY_TYPE] or {}

    if activityType == self.AC_LOTTERY then
        local bRed =  self._redDotTypeCount[self.ACTIVITY_TYPE][self.AC_LOTTERY_TYPE]
        --local LotteryModel = require("src.app.plugins.lottery.LotteryModel"):getInstance()    -- 为了脱离LotteryModel，先屏蔽
        local chance = 0 --LotteryModel:getLotteryRelease() or 0
        if chance>0 then
             self._redDotTypeCount[self.ACTIVITY_TYPE][self.AC_LOTTERY_TYPE] = true
        else
             self._redDotTypeCount[self.ACTIVITY_TYPE][self.AC_LOTTERY_TYPE] = false
        end 
        if bRed ~= self._redDotTypeCount[self.ACTIVITY_TYPE][self.AC_LOTTERY_TYPE]  then
            ActivityCenterStatus:resetActivityRedDot(self.AC_LOTTERY_TYPE, not bRed)
        end
    elseif activityType == self.AC_TREASURE_BOX_TYPE then
        local bRed =  self._redDotTypeCount[self.ACTIVITY_TYPE][self.AC_TREASURE_BOX_TYPE]
        --local TreasureBoxModel = require("src.app.plugins.treasurebox.TreasureBoxModel"):getInstance() -- 为了脱离TreasureBoxModel，先屏蔽
        local chance = 0 --TreasureBoxModel:isTreasureAvailable()
        if chance then
             self._redDotTypeCount[self.ACTIVITY_TYPE][self.AC_TREASURE_BOX_TYPE] = true
        else
             self._redDotTypeCount[self.ACTIVITY_TYPE][self.AC_TREASURE_BOX_TYPE] = false
        end 
        if bRed ~= self._redDotTypeCount[self.ACTIVITY_TYPE][self.AC_TREASURE_BOX_TYPE]  then
            ActivityCenterStatus:resetActivityRedDot(self.AC_TREASURE_BOX_TYPE, not bRed)
        end
    end
end

function ActivityCenterModel:getActivityTaskConfig()
    if not UserModel.nUserID then return false end
    local data      = {
        nUserID     = UserModel.nUserID
    }
    
    AssistModel:sendRequest(ActivityCenterDef.GR_GET_ACTIVITY_TASK_CONFIG, ActivityCenterStruct["REQ_TASK_CONFIG"], data, false)
end

function ActivityCenterModel:reqActivityTaskRedDot()
    if not UserModel.nUserID then return false end

    local versionStr = BusinessUtils:getInstance():getAppVersion()

    local data = {
        nUserID = UserModel.nUserID,
        nVersion = versionStr
    }
    AssistModel:sendRequest(ActivityCenterDef.GR_GET_ACTIVITY_TASK_REDDOT, ActivityCenterStruct["REQ_TASK_REDDOT"], data, false)
end

function ActivityCenterModel:onActivityTaskConfig(data)
    if not data then return end

    local curDateInfo = treepack.unpack(data, ActivityCenterStruct["RET_TASK_CURDATE"])
    self._curDate = rawget(curDateInfo, "nCurDate")
    local configdata = string.sub(data, ActivityCenterStruct["RET_TASK_CURDATE"].maxsize + 1)

    local json = cc.load("json").json
	self._activityTaskConfig = json.decode(configdata)
    --dump(self._activityTaskConfig)

    --self:dispatchEvent({name=self.ACTIVITY_SHOW})
end

function ActivityCenterModel:onActivityTaskData(data)
    if not data then return end

    self._activityTaskGroup = treepack.unpack(data, ActivityCenterStruct["RET_TASK_GROUP"])
    local taskinfos = string.sub(data, ActivityCenterStruct["RET_TASK_GROUP"].maxsize + 1)

    self._activityTaskData = {}
    for i = 1, self._activityTaskGroup.nTaskCnt do
        local singletask = treepack.unpack(taskinfos, ActivityCenterStruct["RET_TASK_DATA"])
        table.insert(self._activityTaskData, i, singletask)
        taskinfos = string.sub(taskinfos, ActivityCenterStruct["RET_TASK_DATA"].maxsize + 1)
    end

    
    self:dispatchEvent({name=self.ACTIVITY_TASK_UPDATE, value={_taskgroup = self._activityTaskGroup, _taskdata = self._activityTaskData}})
end

function ActivityCenterModel:onActivityTaskRedDot(data)
    if not data then return end

    local cnt = treepack.unpack(data, ActivityCenterStruct["RET_TASK_REDDOT_CNT"])
    if "number" ~= type(rawget(cnt, "nCount")) then return end

    local reddotinfo = string.sub(data, ActivityCenterStruct["RET_TASK_REDDOT_CNT"].maxsize + 1)

    self._activityTaskReddot = {}
    for i = 1, rawget(cnt, "nCount") do
        local reddot = treepack.unpack(reddotinfo, ActivityCenterStruct["RET_TASK_REDDOT"])
        table.insert(self._activityTaskReddot, reddot)
        reddotinfo = string.sub(reddotinfo, ActivityCenterStruct["RET_TASK_REDDOT"].maxsize + 1)
    end

    --dump(self._activityTaskReddot)
    --self:dispatchEvent({name=self.ACTIVITY_REDDOT_UPDATED})
    self._myStatusDataExtended["isNeedReddot"] = self:isNeedReddot()
    self:dispatchModuleStatusChanged("activity", ActivityCenterModel.EVENT_MAP["activity_newContentAvail"])
end

function ActivityCenterModel:onActivityTaskReward(data)
    if not data then return end
    if not self._activityTaskGroup then return end
    if not self._activityTaskData then return end

    local taskrewardret = treepack.unpack(data, ActivityCenterStruct["RET_TASK_REWARD"])

    if rawget(taskrewardret, "nRewardFlag") == -1 then
        my.informPluginByName({pluginName='TipPlugin',params={tipString="奖励领取失败！请稍后再试！", removeTime=2}})
        return
    end

    for k, v in pairs(self._activityTaskData) do
        if rawget(v, "nTaskID") == rawget(taskrewardret, "nTaskId") then
            v["nRewardFlag"] = rawget(taskrewardret, "nRewardFlag")
            break
        end
    end

    print("reward success")
    self:dispatchEvent({name=self.ACTIVITY_TASK_REWARD, value={_taskgroup = self._activityTaskGroup, _taskdata = self._activityTaskData}})

    local rewardlist = self:getRewardInfoByTaskID(rawget(taskrewardret, "nTaskGId"), rawget(taskrewardret, "nTaskId"))
    self:dispatchEvent({name=self.ACTIVITY_SHOW_REWARD, value=rewardlist})
end

function ActivityCenterModel:getTabTitleByTaskID(activityid)
    if not self._activityTaskConfig then
        print("task config is nil")
        return
    end

    for k, v in pairs(self._activityTaskConfig["config"]) do
        if rawget(v, "TaskGroupID") == activityid then
            return rawget(v, "TabTitle")
        end
    end
end

function ActivityCenterModel:getTaskInfosByActivityId(activityid)
    if not self._activityTaskConfig then
        print("task config is nil")
        return
    end

    for k, v in pairs(self._activityTaskConfig["config"]) do
        if rawget(v, "TaskGroupID") == activityid then
            return rawget(v, "Task")
        end
    end
end

function ActivityCenterModel:getRewardInfoByTaskID(taskgid, taskid)
    if not self._activityTaskConfig then
        print("task config is nil")
        return
    end

    local tasklist = nil

    for k, v in pairs(self._activityTaskConfig["config"]) do
        if rawget(v, "TaskGroupID") == taskgid then
            tasklist = rawget(v, "Task")
        end
    end

    if tasklist ~= nil and next(tasklist) ~= nil then
        for k, v in pairs(tasklist) do
            if rawget(v, "TaskID") == taskid then
                return rawget(v, "Reward")
            end
        end
    end
end

function ActivityCenterModel:onTabTaskData(activityid)
    if not activityid or not UserModel.nUserID then return end

    self._activityTaskGroup = nil
    self._activityTaskData = nil

    local versionStr = BusinessUtils:getInstance():getAppVersion()

    local data = {
        nUserID = UserModel.nUserID,
        nTaskGId = activityid,
        nVersion = versionStr
    }

    --dump(data)
    AssistModel:sendRequest(ActivityCenterDef.GR_GET_ACTIVITY_TASK_DATA, ActivityCenterStruct["REQ_TASK_DATA"], data, false)
end

function ActivityCenterModel:activityTaskTakeReward(taskinfo)
    if not taskinfo then return end

    --dump(taskinfo)

    local data = {
        nUserID = UserModel.nUserID,
        nTaskGId = taskinfo.taskGId,
        nTaskId = taskinfo.taskId
    }

    AssistModel:sendRequest(ActivityCenterDef.GR_GET_ACTIVITY_TASK_REWERD, ActivityCenterStruct["REQ_TASK_REWARD"], data, false)
end

function ActivityCenterModel:getActivityValidDate(activityid)
    if not self._activityTaskConfig then
        print("task config is nil")
        return
    end

    for k, v in pairs(self._activityTaskConfig["config"]) do
        if rawget(v, "TaskGroupID") == activityid then
            return rawget(v, "Begin"), rawget(v, "End")
        end
    end
end

function ActivityCenterModel:getActivityDescription(activityid)
    if not self._activityTaskConfig then
        print("task config is nil")
        return
    end

    for k, v in pairs(self._activityTaskConfig["config"]) do
        if rawget(v, "TaskGroupID") == activityid then
            return rawget(v, "DescriptionImgUrl"), rawget(v, "DescriptionText")
        end
    end
end

function ActivityCenterModel:praseTimeRegion(timeRegion)
    local tempTimeRegion = timeRegion
    if type(timeRegion) == "string" and string.find(timeRegion, ':')~= nil then
        tempTimeRegion = string.gsub(timeRegion, ':', '') -- 00:00:00|23:59:59 转成000000|235959
    end
    local beginTime, endTime = 0, 0
    if type(tempTimeRegion) == "string" and string.len(tempTimeRegion) > 0 then
        local startpos, endpos = string.find(tempTimeRegion, "%d+")
        beginTime = tonumber(string.sub(tempTimeRegion, startpos, endpos)) or 0
        startpos, endpos = string.find(tempTimeRegion, "%d+", endpos+1)
        endTime = tonumber(string.sub(tempTimeRegion, startpos, endpos))  or 0
    end
    return beginTime, endTime
end

function ActivityCenterModel:onNotifyCloseCtrl()
    self:dispatchEvent({name=self.ACTIVITY_CLOSE})
end

function ActivityCenterModel:isNeedReddot()
    local redCount = self:getAllRedDotCount()

    return redCount > 0
end

function ActivityCenterModel:savePluginParams(params)
    self._pluginParams = params
end

function  ActivityCenterModel:pluginNameInParams(name)
    if not name then 
        return false
    end
    if not self._pluginParams then
        return false
    end
    if self._pluginParams.moudleName == name then
        return true
    end
    return false
end

return ActivityCenterModel