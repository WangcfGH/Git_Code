local GameUpdateModel   = import(".GameUpdateModel"):getInstance()
local XYXZConfig        = import(".XYXZConfig")
local XYXZView          = import(".XYXZView")
local XYXZDeals         = import(".XYXZDeals")

local XYXZCtrl          = class("XYXZCtrl")

XYXZCtrl.PROGRESS_INIT       = 30
XYXZCtrl.PROGRESS_DOWNLOAD   = 60
XYXZCtrl.PROGRESS_FINISHED   = 100
XYXZCtrl.ACTION_TIME         = 0.5
XYXZCtrl.ACTION_MINPERCENT   = 2

function XYXZCtrl:ctor(params)
    self._scheduleIDs = {}
    self._lastSpeed = 0
    self._startDownload = false
    self._actionParams = {startTick = 0, tartgetPercent = 0}
    self:initViewNode()
    self:initEventListeners()
    self:startPercentTimer()
    self:startByAppConfig()
end

function XYXZCtrl:getInstance()
    if not XYXZCtrl.__instance then
        XYXZCtrl.__instance = XYXZCtrl:create()
    end
    return XYXZCtrl.__instance
end

function XYXZCtrl:removeInstance()
    XYXZCtrl.__instance = nil
end

function XYXZCtrl:initViewNode()
    self._viewNode = XYXZView:getViewNode()
    self._viewNode:onNodeEvent("exit", handler(self, self.onExit))
end

function XYXZCtrl:onExit()
    self:unscheduleAll()
    self:removeInstance()
    self:stopPercentAction()
    GameUpdateModel:removeEventListenersByTag(self.__cname)
end

function XYXZCtrl:createViewNode(...)
    return XYXZCtrl:getInstance(...)._viewNode
end

function XYXZCtrl:initEventListeners()
    GameUpdateModel:addEventListener(GameUpdateModel.EVENT_UPDATE_OK,       handler(self, self.onUpdateOK), self.__cname)
    GameUpdateModel:addEventListener(GameUpdateModel.EVENT_UPDATE_CANCEL,   handler(self, self.onUpdateCancel), self.__cname)
    GameUpdateModel:addEventListener(GameUpdateModel.EVENT_UPDATE_FAILED,   handler(self, self.onUpdateFailed), self.__cname)
    GameUpdateModel:addEventListener(GameUpdateModel.EVENT_UPDATE_PROGRESS, handler(self, self.onUpdateProgress), self.__cname)
    GameUpdateModel:addEventListener(GameUpdateModel.EVENT_UPDATE_UNZIP,    handler(self, self.onUpdateUnZip), self.__cname)
    GameUpdateModel:addEventListener(GameUpdateModel.EVENT_UPDATE_START,    handler(self, self.onUpdateStart), self.__cname)
    GameUpdateModel:addEventListener(GameUpdateModel.EVENT_UPDATE_PAUSED,   handler(self, self.onUpdatePaused), self.__cname)
    GameUpdateModel:addEventListener(GameUpdateModel.EVENT_UPDATE_DOWNLOAD, handler(self, self.onUpdateDownload), self.__cname)
end

function XYXZCtrl:startByAppConfig()
    GameUpdateModel:startUpdate(XYXZConfig.AppConfig, XYXZConfig.ChannelConfig.recommander_id, true)
end

function XYXZCtrl:onUpdateOK(data)    
    if self._startDownload then 
        self:setProgress(self.PROGRESS_FINISHED)
    end
    self:scheduleOnce(function()
        cc.SpriteFrameCache:getInstance():removeSpriteFrames()
        cc.Director:getInstance():getTextureCache():removeAllTextures()
        ccs.ArmatureDataManager:destroyInstance()
        self:clearXyxz()

        self:enterXyxz()
    end, 0.1)
end

function XYXZCtrl:onUpdateCancel(data)
    print("取消")
    -- self:removeSelfInstance()
    my.informPluginByName({params={message='remove'}})
    -- my.informPluginByName(params)
end

function XYXZCtrl:onUpdateFailed(data)
    print("失败")
    my.informPluginByName({pluginName = "TipPlugin", params = {tipString = "对不起，更新失败，请稍候重试"}})
    self:scheduleOnce(function()
        -- self:removeSelfInstance()
        my.informPluginByName({params={message='remove'}})
    end, 0.1)
end

function XYXZCtrl:onUpdateProgress(data)
    local total         = data.params.total or 1
    local download      = data.params.downloaded or 0
    local percent = self.PROGRESS_INIT + download / total * self.PROGRESS_DOWNLOAD
    self:setProgress(percent)
end

function XYXZCtrl:onUpdateUnZip(data)
    print("onUpdateUnZip")
end

function XYXZCtrl:onUpdateStart(data)
end

function XYXZCtrl:onUpdatePaused(data)
    print("onUpdatePaused")
end

function XYXZCtrl:onUpdateDownload(data)
    self._startDownload = true
    self:setProgress(self.PROGRESS_INIT)
end

function XYXZCtrl:setProgress(percent)
    -- printLog(self.__cname, "percent:%d", percent)
    self._actionParams = {startTick = socket.gettime(), tartgetPercent = percent}
end

function XYXZCtrl:startPercentTimer()
    local function onAction()
        local startTick         = self._actionParams.startTick
        local tartgetPercent    = self._actionParams.tartgetPercent
        local currentPercent    = self._viewNode:getPercent()
        if currentPercent < tartgetPercent then
            if tartgetPercent - currentPercent <= self.ACTION_MINPERCENT then
                self._viewNode:setPercent(tartgetPercent)
            else
                local speed = (tartgetPercent - currentPercent) / self.ACTION_TIME
                if speed > self._lastSpeed then
                    self._lastSpeed = speed
                else
                    speed = self._lastSpeed
                end
                local target = (socket.gettime() - startTick) * speed + self._viewNode:getPercent()
                target = target > tartgetPercent and tartgetPercent or target
                -- print("startPercentTimer", target)
                self._viewNode:setPercent(target)
            end
        end
    end
    self._actionScheduleID = self:scehdule(onAction, 0)
end

function XYXZCtrl:stopPercentAction()
    if self._actionScheduleID then
        self:unschedule(self._actionScheduleID)
        self._actionScheduleID = nil
    end
end

function XYXZCtrl:scheduleOnce(f, delay)
    local scheduleID 
    scheduleID = self:scehdule(function(...)
        self:unschedule(scheduleID)
        f()
    end, delay)
    table.insert(self._scheduleIDs, scheduleID)
    return scheduleID
end

function XYXZCtrl:scehdule(f, dt)
    local scheduleID 
    scheduleID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(...)
        if tolua.isnull(self._viewNode) then
            self:unschedule(scheduleID)
        else
            f()
        end
    end, dt, false)
    table.insert(self._scheduleIDs, scheduleID)
    return scheduleID
end

function XYXZCtrl:unschedule(scheduleID)
    table.removebyvalue(self._scheduleIDs, scheduleID)
    return cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleID)
end

function XYXZCtrl:unscheduleAll()
    for nIndex = #self._scheduleIDs, 1, -1 do
        self:unschedule(self._scheduleIDs[nIndex])
    end
end

function XYXZCtrl:clearXyxz()
    for path, value in pairs(package.loaded) do
        if string.match(path, "^src%.+xyxz" ) or string.match(path, "^%.*xyxz" ) then 
            package.loaded[path] = nil
        end
    end
end

function XYXZCtrl:enterXyxz()
    my.freezeKeyboardListener()
    cc.exports.xyxzDeals = XYXZDeals:getXYXZDeals()
    require("src.xyxz.MyAppSubGame"):create():run()
end

function XYXZCtrl:removeSelfInstance()
    self:removeInstance()
    if self._viewNode then
        self._viewNode:removeSelf()
        self._viewNode = nil
    end
end

return XYXZCtrl