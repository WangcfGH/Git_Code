
local SKGameClock = import("src.app.Game.mSKGame.SKGameClock")
local MyGameClock = class("MyGameClock", SKGameClock)

local BaseGameDef = import("src.app.Game.mBaseGame.BaseGameDef")

function MyGameClock:IS_BIT_SET(flag, mybit)
    if not flag or not mybit then
        return false
    end
    return (mybit == bit._and(mybit, flag))
end

function MyGameClock:ctor(clockPanel, gameController)
    MyGameClock.super.ctor(self, clockPanel, gameController)

    local MyGameScene = gameController._baseGameScene
    local clockPosition = MyGameScene._gameNode:getChildByName("Panel_Clock"):getChildByName("Node_Clock1")
    self._clockPosition = cc.p(clockPosition:getPosition())
end

function MyGameClock:updateClockPositionForArena()
    local MyGameScene = self._gameController._baseGameScene
    local clockPosition = MyGameScene._gameNode:getChildByName("Panel_Clock"):getChildByName("Node_Clock1")
    self._clockPosition = cc.p(clockPosition:getPosition())
end

function MyGameClock:getPosition(index)

    if index == self._gameController:getMyDrawIndex() then
        local MyGameScene = self._gameController._baseGameScene
        local opeBtnsNode = MyGameScene._gameNode:getChildByName("Node_OperationBtn")
        local posY = opeBtnsNode:getPositionY()+10
        local posX = self._clockPosition.x
        return cc.p(posX, posY)

        --[[local MyGameUtilsInfoManager = self._gameController._baseGameUtilsInfoManager
        local SKHandCardsManager     = self._gameController._baseGameScene:getSKHandCardsManager()
        if MyGameUtilsInfoManager  and SKHandCardsManager then
            return cc.p(self._clockPosition)
        end]]--
    end

    local MyGameScene = self._gameController._baseGameScene
    if MyGameScene and MyGameScene._gameNode then
        local clockPosition = MyGameScene._gameNode:getChildByName("Panel_Clock"):getChildByName("Node_Clock"..tostring(index))
        if clockPosition then
            return cc.p(clockPosition:getPosition())
        end
    end

    return cc.p(0, 0)
end

function MyGameClock:moveClockHandTo(index)
    if index == -1 then
        self:setVisible(true)

        self:setDrawIndex(index)

        self:setPosition(self:getPosition(5))

        local playerManager = self._gameController._baseGameScene:getPlayerManager()
        if playerManager then
            playerManager:setWaitingAnimation(1, true)
        end
    end
    if 0 >= index or self._gameController:getTableChairCount() < index then return end

    self:setVisible(true)

    self:setDrawIndex(index)

    self:setPosition(self:getPosition(index))

    local playerManager = self._gameController._baseGameScene:getPlayerManager()
    if playerManager then
        playerManager:setWaitingAnimation(index, true)
    end
end

function MyGameClock:zeroClock()
    local index = self:getDrawIndex()-- 倒计时到0 理牌按钮禁用，执行结束后恢复
    if index == self._gameController:getMyDrawIndex() then
        self._gameController:btnsSetEnableTouch(false)
    end

    MyGameClock.super.zeroClock(self)

    if index == self._gameController:getMyDrawIndex() then
        self._gameController:btnsSetEnableTouch(true)
    end
end

function MyGameClock:setMyClockZorder(zorder)
    local MyGameScene = self._gameController._baseGameScene
    if MyGameScene and MyGameScene._gameNode then
        local myclock = MyGameScene._gameNode:getChildByName("Panel_Clock")
        if myclock then
            myclock:setLocalZOrder(zorder)
        end
    end
end

function MyGameClock:getMyClockZorder()
    local MyGameScene = self._gameController._baseGameScene
    if MyGameScene and MyGameScene._gameNode then
        local myclock = MyGameScene._gameNode:getChildByName("Panel_Clock")
        if myclock then
            return myclock:getLocalZOrder()
        end
    end
    return MyGameDef.MY_ZORDER_CARD_HAND
end

return MyGameClock