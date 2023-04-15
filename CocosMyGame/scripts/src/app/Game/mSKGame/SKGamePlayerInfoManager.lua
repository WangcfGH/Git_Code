
local BaseGamePlayerInfoManager = import("src.app.Game.mBaseGame.BaseGamePlayerInfoManager")
local SKGamePlayerInfoManager = class("SKGamePlayerInfoManager", BaseGamePlayerInfoManager)

function SKGamePlayerInfoManager:ctor(gameController)
    SKGamePlayerInfoManager.super.ctor(self, gameController)
end

function SKGamePlayerInfoManager:setPlayerScore(drawIndex, score)
    if self._playersInfo[drawIndex] then
        self._playersInfo[drawIndex].nScore = score
    end
    if self._gameController:getMyDrawIndex() == drawIndex then
        if self._selfInfo then
            self._selfInfo.nScore = score
        end
    end
end

function SKGamePlayerInfoManager:getPlayerScore(drawIndex)
    if self._playersInfo[drawIndex] then
        return self._playersInfo[drawIndex].nScore
    end
end

function SKGamePlayerInfoManager:containsTouchLocation(x, y)
    for i = 1, self._gameController:getTableChairCount() do
        if self._players[i] and self._players[i]:containsTouchLocation(x, y) then
            return true
        end
    end

    return false
end

function SKGamePlayerInfoManager:getPlayerTimingScore(drawIndex)
    if self._playersInfo[drawIndex] then
        return self._playersInfo[drawIndex].nReserved[3]
    end
end

function SKGamePlayerInfoManager:setPlayerTimingScore(drawIndex, score)
    if self._playersInfo[drawIndex] and self._playersInfo[drawIndex].nReserved then
        self._playersInfo[drawIndex].nReserved[3] = score
    end
end

return SKGamePlayerInfoManager