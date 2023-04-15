
local BaseGameArenaInfoManager = class("BaseGameArenaInfoManager")


function BaseGameArenaInfoManager:ctor(gameController)
    if not gameController then printError("gameController is nil!!!") return end
    self._gameController                = gameController

    self._arenaInfo                     = {}
    self._isArenaPlayer                 = nil
end

function BaseGameArenaInfoManager:setArenaInfo(arenaInfo)
    table.merge(self._arenaInfo, arenaInfo)
end

function BaseGameArenaInfoManager:addBoutScore(diff)
    self._arenaInfo.nBoutScore = self._arenaInfo.nBoutScore or 0
    self._arenaInfo.nBoutScore = self._arenaInfo.nBoutScore + diff
end

function BaseGameArenaInfoManager:addBout(num)
    local boutPlus = type(num) == 'number' or 1
    self._arenaInfo.nBout = self._arenaInfo.nBout and self._arenaInfo.nBout+boutPlus or boutPlus
end

function BaseGameArenaInfoManager:getArenaInfo()
    return self._arenaInfo
end

function BaseGameArenaInfoManager:setIsArenaPlayer(isArenaPlayer)
    self._isArenaPlayer = isArenaPlayer
end

function BaseGameArenaInfoManager:isArenaPlayer()
    return self._isArenaPlayer
end

function BaseGameArenaInfoManager:getMatchID()          if self._arenaInfo then return self._arenaInfo.nMatchID         end end
function BaseGameArenaInfoManager:getHP()               if self._arenaInfo then return self._arenaInfo.nHP              end end
function BaseGameArenaInfoManager:getInitHP()           if self._arenaInfo then return self._arenaInfo.nInitHP          end end
function BaseGameArenaInfoManager:getAddition()         if self._arenaInfo then return self._arenaInfo.nAddition        end end
function BaseGameArenaInfoManager:getLastRoundAddition()if self._arenaInfo then return self._arenaInfo.nBoutAddition    end end
function BaseGameArenaInfoManager:getAdditionDetail()   if self._arenaInfo then return self._arenaInfo.nAdditionDetail  end end
function BaseGameArenaInfoManager:getBout()             if self._arenaInfo then return self._arenaInfo.nBout            end end
function BaseGameArenaInfoManager:getStreaking()        if self._arenaInfo then return self._arenaInfo.nStreaking       end end
function BaseGameArenaInfoManager:getTopStreaking()     if self._arenaInfo then return self._arenaInfo.nTopStreaking    end end
function BaseGameArenaInfoManager:getWinBout()          if self._arenaInfo then return self._arenaInfo.nWinBout         end end
function BaseGameArenaInfoManager:getMatchScore()       if self._arenaInfo then return self._arenaInfo.nMatchScore      end end
function BaseGameArenaInfoManager:getLevel()            if self._arenaInfo then return self._arenaInfo.nLevel           end end
function BaseGameArenaInfoManager:getAwardInfoNumber()  if self._arenaInfo then return self._arenaInfo.nAwardInfoNumber end end
function BaseGameArenaInfoManager:getMatchName()        if self._arenaInfo then return self._arenaInfo.szMatchName      end end
function BaseGameArenaInfoManager:getAwardInfo()        if self._arenaInfo then return self._arenaInfo.awardInfo        end end
function BaseGameArenaInfoManager:getBoutScore()        if self._arenaInfo then return self._arenaInfo.nBoutScore       end end
function BaseGameArenaInfoManager:getDiffHP()           if self._arenaInfo then return self._arenaInfo.nDiffHP          end end
function BaseGameArenaInfoManager:isForceQuit()         if self._arenaInfo then return self._arenaInfo.IsForceQuit == 1 end end

return BaseGameArenaInfoManager
