
local BaseGameClock = import("src.app.Game.mBaseGame.BaseGameClock")
local SKGameClock = class("SKGameClock", BaseGameClock)

function SKGameClock:ctor(clockPanel, gameController)
    self._drawIndex     = 0

    SKGameClock.super.ctor(self, clockPanel, gameController)
end

function SKGameClock:start(digit)
    if not digit or digit <= 0 then return end

    self:stop()
    self:setVisible(true)

    self._digit = digit

    local clockDigit = self._clockPanel:getChildByName("Value_Time")
    if clockDigit then
        clockDigit:setString(tostring(self._digit))
    end

    local function onTimeInterval(dt)
        self:step(dt)
    end
    self:stop()
    self.clockTimerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(onTimeInterval, 1.0, false)
end

function SKGameClock:step(dt)
    if not self._clockPanel then return end

    local clockDigit = self._clockPanel:getChildByName("Value_Time")
    if clockDigit then
        if self._digit >= 1 then
            self._gameZeroCount = 0
            self._digit = self._digit - 1
            clockDigit:setString(string.format("%02d", self._digit))--tostring(self._digit))
            if self._digit == 6 then
                self._gameController:playGamePublicSound("alert.mp3")
            end
            if self._digit <= 5 and self._digit >= 0 then
                self._gameController:playGamePublicSound(string.format("clock%d", self._digit)..".mp3")
            end

            self._gameController:clockStep(dt)
        elseif self._digit == 0 then
            self:zeroClock()
            self._gameZeroCount = self._gameZeroCount + 1
        end
    end
end

function SKGameClock:setDrawIndex(drawIndex)
    self._drawIndex = drawIndex
end

function SKGameClock:getDrawIndex()
    return self._drawIndex
end

function SKGameClock:moveClockHandTo(index)
    if 0 >= index or self._gameController:getTableChairCount() < index then return end

    self:setVisible(true)

    self:setDrawIndex(index)

    self:setPosition(self:getPosition(index))

    local playerManager = self._gameController._baseGameScene:getPlayerManager()
    if playerManager then
        playerManager:setWaitingAnimation(index, true)
    end
end

function SKGameClock:getPosition(index)
    local SKGameScene = self._gameController._baseGameScene
    if SKGameScene and SKGameScene._gameNode then
        local clockPosition = SKGameScene._gameNode:getChildByName("Panel_Clock"):getChildByName("Node_Clock"..tostring(index))
        if clockPosition then
            return cc.p(clockPosition:getPosition())
        end
    end
    
    return cc.p(0, 0)
end

function SKGameClock:setVisible(visible)
    if self._clockPanel then
        self._clockPanel:setVisible(visible)
    end

    if not visible then
        local playerManager = self._gameController._baseGameScene:getPlayerManager()
        if playerManager then
            playerManager:setWaitingAnimation(1, false)
        end
    end
end

function SKGameClock:setPosition(point)
    if self._clockPanel then
        self._clockPanel:setPosition(point)
    end
end

function SKGameClock:zeroClock()
    if 0 == self._gameZeroCount then
        self._gameController:onGameClockZero()
    end
    if self._gameZeroCount > 0 and self._gameZeroCount % 3 == 0 then
        self._gameController:onClockStop()
    end
    if self._gameZeroCount >= 30 then
        self._gameController:reconnectionFailed()
    end
end

return SKGameClock
