
local BaseGamePlayerManager = class("BaseGamePlayerManager")

function BaseGamePlayerManager:create(players, gameController)
    return BaseGamePlayerManager.new(players, gameController)
end

function BaseGamePlayerManager:ctor(players, gameController)
    self._gameController    = gameController
    self._players           = players
end

function BaseGamePlayerManager:setSoloPlayer(drawIndex, soloPlayer)
    if self._players[drawIndex] then
        self._players[drawIndex]:setSoloPlayer(soloPlayer)
    end
end

function BaseGamePlayerManager:setLbs(nUserID, lbs)
    if self._players[1] then
        self._players[1]:setLbs(nUserID,lbs)
    end
end

function BaseGamePlayerManager:setPlayerHead(nUserID, path)
    if self._players[1] then
        self._players[1]:setPlayerHead(nUserID,path)
    end
end

function BaseGamePlayerManager:isPlayerEnter(drawIndex)
    return (self._players[drawIndex] and self._players[drawIndex]:isPlayerEnter())
end

function BaseGamePlayerManager:playerAbort(drawIndex)
    if self._players[drawIndex] then
        self._players[drawIndex]:playerAbort()
    end
end

function BaseGamePlayerManager:clearPlayers()
    if not self._gameController then return end

    local player = nil
    for i = 1, self._gameController:getTableChairCount() do
        player = self._players[i]
        if player then
            player:initPlayer()
        end
    end
end

function BaseGamePlayerManager:setReady(drawIndex, bReady)
    if self._players[drawIndex] then
        self._players[drawIndex]:setReady(bReady)
    end
end

function BaseGamePlayerManager:setMoney(drawIndex, nDeposit)
    if self._players[drawIndex] then
        self._players[drawIndex]:setMoney(nDeposit)
    end
end

function BaseGamePlayerManager:tipChatContent(drawIndex, content)
    if self._players[drawIndex] then
        self._players[drawIndex]:tipChatContent(content)
    end
end

function BaseGamePlayerManager:onGameStart()
    local player = nil
    for i = 1, self._gameController:getTableChairCount() do
        player = self._players[i]
        if player then
            player:setReady(false)
        end
    end
end

function BaseGamePlayerManager:onGameExit()
    self:clearPlayers()
end

function BaseGamePlayerManager:onClickPlayerHead(drawIndex)
    local player = nil
    for i = 1, self._gameController:getTableChairCount() do
        player = self._players[i]
        if player then
            if drawIndex == i then
                player:showPlayerInfo(not player:isPlayerInfoShow())
            else
                player:showPlayerInfo(false)
            end
        end
    end
end

function BaseGamePlayerManager:onTouchBegin(x,y)
    local player = nil
    for i = 1, self._gameController:getTableChairCount() do
        player = self._players[i]
        if player then
            player:onTouchBegin(x,y)
        end
    end
end

function BaseGamePlayerManager:onHidePlayerInfo()
    local player = nil
    for i = 1, self._gameController:getTableChairCount() do
        player = self._players[i]
        if player then
            player:showPlayerInfo(false)
        end
    end
end

function BaseGamePlayerManager:clearPlayerReady()
    local player = nil
    for i = 1, self._gameController:getTableChairCount() do
        player = self._players[i]
        if player then
            player:setReady(false)
        end
    end
end

function BaseGamePlayerManager:hidePlayer1Bottom()
    local player = self._players[1]
    player:hideBottom()
end

function BaseGamePlayerManager:showPlayer1Bottom()
    local player = self._players[1]
    player:showBottom()
end

return BaseGamePlayerManager
