
local BaseGameInfo = import("src.app.Game.mBaseGame.BaseGameInfo")
local SKGameInfo = class("SKGameInfo", BaseGameInfo)

function SKGameInfo:ctor(gameInfo, gameController)
    if not gameController then printError("gameController is nil!!!") return end

    self._doubleWord    = nil
    self._double        = nil

    self._updateTimerID = nil
    self._timeLabel     = nil
    --self._wifiInfo      = nil
    --self._batteryInfo   = nil

    SKGameInfo.super.ctor(self, gameInfo, gameController)
end

function SKGameInfo:init()
    if not self._gameInfo then return end

    self._baseScoreWord = ccui.Helper:seekWidgetByName(self._gameInfo, "fnt_score")
    self._baseScore     = ccui.Helper:seekWidgetByName(self._gameInfo, "fnt_value_score")
    self._baseScoreBack = ccui.Helper:seekWidgetByName(self._gameInfo, "basic_icon_BG")

    self._doubleWord    = ccui.Helper:seekWidgetByName(self._gameInfo, "fnt_times")
    self._double        = ccui.Helper:seekWidgetByName(self._gameInfo, "fnt_value_times")

    self._timeLabel     = ccui.Helper:seekWidgetByName(self._gameInfo, "time")

    self:showTimeInfo()
end

function SKGameInfo:onGameExit()
    if self._updateTimerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._updateTimerID)
        self._updateTimerID = nil
    end
end

function SKGameInfo:setBaseScore(score)
    if "string" ~= type(score) then return end

    if self._baseScore then
        self._baseScore:setVisible(true)
        self._baseScore:setString(score)
    end

    if self._baseScoreWord then
        self._baseScoreWord:setVisible(true)
    end

    if self._baseScoreBack then
        self._baseScoreBack:setVisible(true)
    end
end

function SKGameInfo:hideBaseScore()
    if self._baseScore then
        self._baseScore:setVisible(false)
    end

    if self._baseScoreWord then
        self._baseScoreWord:setVisible(false)
    end

    if self._baseScoreBack then
        self._baseScoreBack:setVisible(false)
    end
end

function SKGameInfo:setDouble(double)
    if "string" ~= type(double) then return end

    if self._double then
        self._double:setVisible(true)
        self._double:setString(double)
    end

    if self._doubleWord then
        self._doubleWord:setVisible(true)
    end
end

function SKGameInfo:showTimeInfo()
    if self._timeLabel then
        self._timeLabel:setVisible(true)
    end

    self:updateTime()
    --self:updateWifi()
    --self:updateBattery()

    local function updateTime()
        self:updateTime()
    end

    if not self._updateTimerID then
        self._updateTimerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(updateTime, 60, false)
    end
end

function SKGameInfo:hideTimeInfo()
    if self._timeLabel then
        self._timeLabel:setVisible(false)
    end
end

function SKGameInfo:updateTime()
    local currentTime = os.date("%H:%M", os.time())
    if self._timeLabel then
        self._timeLabel:setString(currentTime)
    end
end

function SKGameInfo:updateWifi()
    --暂时不支持lua调用java层 接口开放后再实现
end

function SKGameInfo:updateBattery()
    --暂时不支持lua调用java层 接口开放后再实现
end

function SKGameInfo:restartGame()
    self:ope_ShowGameInfo(false)
end

function SKGameInfo:ope_ShowGameInfo(bShow)
    if not bShow then
        self:hideBaseScore()
        self:showTimeInfo()
    end
end

return SKGameInfo
