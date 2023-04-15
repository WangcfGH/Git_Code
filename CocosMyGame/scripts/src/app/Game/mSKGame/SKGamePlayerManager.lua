
local BaseGamePlayerManager = import("src.app.Game.mBaseGame.BaseGamePlayerManager")
local SKGamePlayerManager = class("SKGamePlayerManager", BaseGamePlayerManager)

function SKGamePlayerManager:ctor(players, gameController)
    SKGamePlayerManager.super.ctor(self, players, gameController)
end

function SKGamePlayerManager:resetPlayerManager()
    for i = 1, self._gameController:getTableChairCount() do
        if self._players[i] then
            self._players[i]:resetPlayer()
        end
    end
end

function SKGamePlayerManager:addPlayerFlower(drawIndex)
    if self._players[drawIndex] then
        self._players[drawIndex]:addPlayerFlower()
    end
end

function SKGamePlayerManager:setPlayerFlower(drawIndex, count)
    if self._players[drawIndex] then
        self._players[drawIndex]:setPlayerFlower(count)
    end
end

function SKGamePlayerManager:clearPlayerFlower()
    for i = 1, self._gameController:getTableChairCount() do
        if self._players[i] then
            self._players[i]:setPlayerFlower(0)
        end
    end
end

function SKGamePlayerManager:addPlayerCurrentGains(drawIndex, gains)
    if self._players[drawIndex] then
        self._players[drawIndex]:addPlayerCurrentGains(gains)
    end
end

function SKGamePlayerManager:setPlayerCurrentGains(drawIndex, gains)
    if self._players[drawIndex] then
        self._players[drawIndex]:setPlayerCurrentGains(gains)
    end
end

function SKGamePlayerManager:clearPlayerCurrentGains()
    for i = 1, self._gameController:getTableChairCount() do
        if self._players[i] then
            self._players[i]:setPlayerCurrentGains(0)
        end
    end
end

function SKGamePlayerManager:showBanker(drawIndex)
    if self._players[drawIndex] then
        self._players[drawIndex]:showBanker(true)
    end
end

function SKGamePlayerManager:clearBanker()
    for i = 1, self._gameController:getTableChairCount() do
        if self._players[i] then
            self._players[i]:showBanker(false)
        end
    end
end

function SKGamePlayerManager:showHelper(drawIndex)
    if self._players[drawIndex] then
        self._players[drawIndex]:showHelper(true)
    end
end

function SKGamePlayerManager:clearHelper()
    for i = 1, self._gameController:getTableChairCount() do
        if self._players[i] then
            self._players[i]:showHelper(false)
        end
    end
end

function SKGamePlayerManager:showRobot(bShow, drawIndex)
    if self._players[drawIndex] then
        self._players[drawIndex]:showRobot(bShow)
    end
end

function SKGamePlayerManager:onRestart()
    for i = 1, self._gameController:getTableChairCount() do
        if self._players[i] then
            self._players[i]:reStart()
        end
    end
end

function SKGamePlayerManager:setCardsCount(drawIndex, cardsCount, bSound)
    if self._players[drawIndex] then
        self._players[drawIndex]:setCardsCount(cardsCount, bSound)
    end
end

function SKGamePlayerManager:containsTouchLocation(x, y)
    for i = 1, self._gameController:getTableChairCount() do
        if self._players[i] and self._players[i]:containsTouchLocation(x, y) then
            return true
        end
    end

    return false
end

function SKGamePlayerManager:containsTouchInfoLocation(x, y)
    for i = 1, self._gameController:getTableChairCount() do
        if self._players[i] and self._players[i]:containsTouchInfoLocation(x, y) then
            return true
        end
    end

    return false
end

function SKGamePlayerManager:setWaitingAnimation(drawIndex, bShow)
    for i = 1, self._gameController:getTableChairCount() do
        if self._players[i] then
            self._players[i]:setWaitingAnimation(false)
        end
    end

    if self._players[drawIndex] then
        self._players[drawIndex]:setWaitingAnimation(bShow)
    end
end

function SKGamePlayerManager:showPass(drawIndex, bShow)
    if bShow then
        for i = 1, self._gameController:getTableChairCount() do
            if self._players[i] then
                self._players[i]:showPass(false)
            end
        end
    end

    if self._players[drawIndex] then
        self._players[drawIndex]:showPass(bShow)
    end
end

function SKGamePlayerManager:setShowCards(drawIndex)
    if self._players[drawIndex] then
        self._players[drawIndex]:setShowCards(true)
    end
end

function SKGamePlayerManager:playUpAnimation(drawIndex, bShow)
    if self._players[drawIndex] then
        self._players[drawIndex]:playUpAnimation(bShow)
    end
end

function SKGamePlayerManager:setShowUpInfo(upInfo)
    if upInfo.nUserID == upInfo.nDestID then 
        for i = 1, 4 do 
            if self._players[i] then
                self._players[i]:setShowUpInfo(upInfo)
            end  
        end
    else
        local drawIndex = self._gameController:rul_GetDrawIndexByChairNO(upInfo.nDestChairNO)
        if self._players[drawIndex] then
            self._players[drawIndex]:setShowUpInfo(upInfo)
        end 
    end
end

function SKGamePlayerManager:updataUpInfo(upData)
    local drawIndex = self._gameController:rul_GetDrawIndexByChairNO(upData.nDestChairNO)
     if self._players[drawIndex] then
            self._players[drawIndex]:updataUpInfo(upData)
     end
     
    local sourceIndex = self._gameController:rul_GetDrawIndexByChairNO(upData.nSourceChairNO)
    local selfIndex = self._gameController:getMyDrawIndex()
    if sourceIndex == selfIndex then
        for i = 1, 4 do
            if self._players[i] then
                self._players[i]:updataOtherUpInfo(upData, i)
            end    
        end
    end
end

--惯蛋添加
function SKGamePlayerManager:getGamePlayerByIndex(index)
    return self._players[index]
end

function SKGamePlayerManager:FreshPlace(drawIndex, nPlace)
    if self._players[drawIndex] then
        self._players[drawIndex]:FreshPlace(nPlace)
    end
end

function SKGamePlayerManager:showBomeSilverValue(drawIndex, value)
    if self._players[drawIndex] then
        self._players[drawIndex]:showBomeSilverValue(value)
    end
end

function SKGamePlayerManager:updataDownInfo(upData)
    local sourceIndex = self._gameController:rul_GetDrawIndexByChairNO(upData.nSourceChairNO)
    local selfIndex = self._gameController:getMyDrawIndex()
    if sourceIndex == selfIndex then
        for i = 1, 4 do
            if self._players[i] then
                self._players[i]:updataOtherDownInfo(upData, i)
            end    
        end
    end
end

function SKGamePlayerManager:updataUserLevelInfo(msgLevelData)
    for i = 1, 4 do
        if self._players[i]._playerUserID ~= nil and self._players[i]._playerUserID == msgLevelData.nUserID then
            self._players[i]:updataUserLevelInfo(msgLevelData)
        end    
    end
end

function SKGamePlayerManager:updataUserLevelInfoForSelf(drawIndex, msgLevelData)
    if self._players[drawIndex] then
        self._players[drawIndex]:updataUserLevelInfo(msgLevelData)
    end
end

function SKGamePlayerManager:onStartPlayToShrinkAnimation()
    if self._players[1] then
        self._players[1]:onStartPlayToShrinkAnimation()
    end
end

function SKGamePlayerManager:onStartPlayToShowLevelAnimation()
    for i = 1, 4 do
        if self._players[i] then
            self._players[i]:onStartPlayToShowLevelAnimation()
        end    
    end
end

function SKGamePlayerManager:onGameWin()
    for i = 1, 4 do
        if self._players[i] then
            self._players[i]._gameStart = false
        end    
    end
end

function SKGamePlayerManager:onUpdateExchangeNum()
    local selfIndex = self._gameController:getMyDrawIndex()
    if self._players[selfIndex] then
        self._players[selfIndex]:onUpdateExchangeNum()
    end
end

function SKGamePlayerManager:clearPlayers(notClearSelf)  --notClearSelf默认为nil
    if not self._gameController then return end
    local selfIndex = self._gameController:getMyDrawIndex()

    local player = nil
    for i = 1, self._gameController:getTableChairCount() do
        player = self._players[i]
        if player and (selfIndex ~= i or not notClearSelf) then
            player:initPlayer()
        end
    end
end

return SKGamePlayerManager
