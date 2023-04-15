
local BaseGameClock = class("BaseGameClock")

function BaseGameClock:create(clockPanel, gameController)
    return BaseGameClock.new(clockPanel, gameController)
end

function BaseGameClock:ctor(clockPanel, gameController)
    if not gameController then printError("gameController is nil!!!") return end
    self._gameController    = gameController

    self._clockPanel        = clockPanel
    self._digit             = 0
    self._gameZeroCount     = 0

    self:init()
end

function BaseGameClock:init()
    self:setVisible(false)
end

function BaseGameClock:start(digit)
    if not digit or digit <= 0 then return end

    self:stop()
    self:setVisible(true)

    self._digit = digit

    local clockDigit = self._clockPanel:getChildByName("Clock_num_clock")
    if clockDigit then
        clockDigit:setString(tostring(self._digit))
    end

    local function onTimeInterval(dt)
        self:step(dt)
    end
    self:stop()
    self.clockTimerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(onTimeInterval, 1.0, false)
end

function BaseGameClock:stop()
    if self.clockTimerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.clockTimerID)
        self.clockTimerID = nil
    end
end

function BaseGameClock:step(dt)
    if not self._clockPanel then return end

    local clockDigit = self._clockPanel:getChildByName("Clock_num_clock")
    if clockDigit then
        if self._digit >= 1 then
            self._gameZeroCount = 0
            self._digit = self._digit - 1
            clockDigit:setString(tostring(self._digit))
        elseif self._digit == 0 then
            self:zeroClock()
            self._gameZeroCount = self._gameZeroCount + 1
        end
    end
    self._gameController:clockStep(dt)
end

function BaseGameClock:zeroClock()
end

function BaseGameClock:onGameExit()
    self:stop()
end

function BaseGameClock:setVisible(visible)
    if self._clockPanel then
        self._clockPanel:setVisible(visible)
    end
end

function BaseGameClock:setPosition(x, y)
    if self._clockPanel then
        self._clockPanel:setPosition(x, y)
    end
end

function BaseGameClock:resetClock()
    self:stop()
    self:setVisible(false)
    self._gameZeroCount = 0
end

function BaseGameClock:hideClock()
    self:setVisible(false)
end

function BaseGameClock:getDigit()
    return self._digit
end

return BaseGameClock
