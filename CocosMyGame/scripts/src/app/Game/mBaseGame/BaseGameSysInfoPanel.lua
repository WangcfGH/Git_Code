
local BaseGameSysInfoPanel = class("BaseGameSysInfoPanel", ccui.Layout)

function BaseGameSysInfoPanel:ctor()
    if self.onCreate then self:onCreate() end
end

function BaseGameSysInfoPanel:onCreate()
    self:init()
end

function BaseGameSysInfoPanel:init()
    local currentTime = os.date("%H:%M:%S", os.time())

    local labelTime = cc.Label:create()
    if labelTime then
        labelTime:setString(currentTime)
        labelTime:setSystemFontSize(30)
        labelTime:setAnchorPoint(cc.p(0, 0))
        labelTime:setTextColor(cc.c4b(255, 255, 255, 255))
        self:addChild(labelTime)
    end

    self:setContentSize(labelTime:getContentSize())

    local function onTimeInterval(dt)
        local tempTime = os.date("%H:%M:%S", os.time())
        if labelTime then
            labelTime:setString(tempTime)
        end
    end
    self._sysTimeTimer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(onTimeInterval, 1.0, false)
end

function BaseGameSysInfoPanel:onGameExit()
    if self._sysTimeTimer then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._sysTimeTimer)
        self._sysTimeTimer = nil
    end
end

return BaseGameSysInfoPanel
