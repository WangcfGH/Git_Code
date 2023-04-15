
local MyGameClock = import("src.app.Game.mMyGame.MyGameClock")
local NetlessGameClock = class("NetlessGameClock", MyGameClock)

function NetlessGameClock:ctor(clockPanel, gameController)
    NetlessGameClock.super.ctor(self, clockPanel, gameController)
    self._clockPanel:getChildByName("Value_Time"):setVisible(false)
end

function NetlessGameClock:zeroClock()
    
end

function NetlessGameClock:step(dt)
    if not self._clockPanel then return end

    local clockDigit = self._clockPanel:getChildByName("Value_Time")
    if clockDigit then
        if self._digit >= 1 then
            self._gameZeroCount = 0
            self._digit = self._digit - 1
            clockDigit:setString(string.format("%02d", self._digit))--tostring(self._digit))
--[[            if self._digit == 6 then
                self._gameController:playGamePublicSound("alert.mp3")
            end
            if self._digit <= 5 and self._digit >= 0 then
                self._gameController:playGamePublicSound(string.format("clock%d", self._digit)..".mp3")
            end]]

            self._gameController:clockStep(dt)
        elseif self._digit == 0 then
            self:zeroClock()
            self._gameZeroCount = self._gameZeroCount + 1
        end
    end
end

return NetlessGameClock