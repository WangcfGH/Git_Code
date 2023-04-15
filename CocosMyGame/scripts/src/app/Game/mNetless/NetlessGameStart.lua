local MyGameStart = import("src.app.Game.mMyGame.MyGameStart")
local NetlessGameStart = class("NetlessGameStart", MyGameStart)

local windowSize = cc.Director:getInstance():getWinSize()

function NetlessGameStart:init()
    NetlessGameStart.super.init(self)
    if self._btnStart then
        self._btnStart:setPositionX((self._btnRandom:getPositionX() + self._btnStart:getPositionX()) / 2)
    end
end

function NetlessGameStart:ope_ShowStart(bShow)
    if bShow then
        if self._btnRandom then
            self._btnRandom:setVisible(false)
        end
        if self._btnChange then
            self._btnChange:setVisible(false)
        end
        if self._waitingTip then
            self._waitingTip:setVisible(false)
        end
        if self._btnStart then
            self._btnStart:setVisible(true)
            self._btnStart:setTouchEnabled(true)
            self._btnStart:setBright(true)
        end

        self:setVisible(true)
    else
        self:setVisible(false)
    end
end


return NetlessGameStart
