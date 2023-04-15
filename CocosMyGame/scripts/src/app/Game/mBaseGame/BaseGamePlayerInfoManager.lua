
local BaseGamePlayerInfoManager = class("BaseGamePlayerInfoManager")

function BaseGamePlayerInfoManager:create(gameController)
    return BaseGamePlayerInfoManager.new(gameController)
end

function BaseGamePlayerInfoManager:ctor(gameController)
    if not gameController then printError("gameController is nil!!!") return end
    self._gameController                = gameController

    self._selfInfo                      = {}
    self._playersInfo                   = {}
end

function BaseGamePlayerInfoManager:setPlayerInfo(drawIndex, playerInfo)
    self._playersInfo[drawIndex] = playerInfo
end

function BaseGamePlayerInfoManager:getPlayerInfoByUserID(userID)
    local playInfo = nil
    for i = 1, self._gameController:getTableChairCount() do
        if self._playersInfo[i] and self._playersInfo[i].nUserID == userID then
            playInfo = self._playersInfo[i]
            break
        end
    end
    return playInfo
end

function BaseGamePlayerInfoManager:getPlayerInfo(drawIndex)
    local playInfo = nil
    if self._playersInfo[drawIndex] then
        playInfo = self._playersInfo[drawIndex]
    end
    return playInfo
end

function BaseGamePlayerInfoManager:playerAbort(drawIndex)
    if self._playersInfo[drawIndex] then
        self._playersInfo[drawIndex] = nil
    end
end

function BaseGamePlayerInfoManager:setSelfInfo(selfInfo)
    self._selfInfo = selfInfo

    if self._selfInfo then
        local UserModel = mymodel('UserModel'):getInstance()
        local sexWithCheck = UserModel:getNickSexWithCheckSelf(self._selfInfo.nUserID, self._selfInfo.nNickSex)
        self._selfInfo.nNickSex = sexWithCheck
    end
end

function BaseGamePlayerInfoManager:getSelfInfo()
    return self._selfInfo
end

function BaseGamePlayerInfoManager:setSelfTableNO(tableNO)  if self._selfInfo then self._selfInfo.nTableNO = tableNO    end end
function BaseGamePlayerInfoManager:setSelfChairNO(chairNO)  if self._selfInfo then self._selfInfo.nChairNO = chairNO    end end

function BaseGamePlayerInfoManager:getSelfUserID()          if self._selfInfo then return self._selfInfo.nUserID        end end
function BaseGamePlayerInfoManager:getSelfUserType()        if self._selfInfo then return self._selfInfo.nUserType      end end
function BaseGamePlayerInfoManager:getSelfStatus()          if self._selfInfo then return self._selfInfo.nStatus        end end
function BaseGamePlayerInfoManager:getSelfTableNO()         if self._selfInfo then return self._selfInfo.nTableNO       end end
function BaseGamePlayerInfoManager:getSelfChairNO()         if self._selfInfo then return self._selfInfo.nChairNO       end end
function BaseGamePlayerInfoManager:getSelfNickSex()         if self._selfInfo then return self._selfInfo.nNickSex       end end
function BaseGamePlayerInfoManager:getSelfPortrait()        if self._selfInfo then return self._selfInfo.nPortrait      end end
function BaseGamePlayerInfoManager:getSelfNetSpeed()        if self._selfInfo then return self._selfInfo.nNetSpeed      end end
function BaseGamePlayerInfoManager:getSelfClothingID()      if self._selfInfo then return self._selfInfo.nClothingID    end end
function BaseGamePlayerInfoManager:getSelfUserName()        if self._selfInfo then return self._selfInfo.szUserName     end end
function BaseGamePlayerInfoManager:getSelfNickName()        if self._selfInfo then return self._selfInfo.szNickName     end end
function BaseGamePlayerInfoManager:getSelfDeposit()         if self._selfInfo then return self._selfInfo.nDeposit       end end
function BaseGamePlayerInfoManager:getSelfPlayerLevel()     if self._selfInfo then return self._selfInfo.nPlayerLevel   end end
function BaseGamePlayerInfoManager:getSelfScore()           if self._selfInfo then return self._selfInfo.nScore         end end
function BaseGamePlayerInfoManager:getSelfBreakOff()        if self._selfInfo then return self._selfInfo.nBreakOff      end end
function BaseGamePlayerInfoManager:getSelfWin()             if self._selfInfo then return self._selfInfo.nWin           end end
function BaseGamePlayerInfoManager:getSelfLoss()            if self._selfInfo then return self._selfInfo.nLoss          end end
function BaseGamePlayerInfoManager:getSelfStandOff()        if self._selfInfo then return self._selfInfo.nStandOff      end end
function BaseGamePlayerInfoManager:getSelfBout()            if self._selfInfo then return self._selfInfo.nBout          end end
function BaseGamePlayerInfoManager:getSelfTimeCost()        if self._selfInfo then return self._selfInfo.nTimeCost      end end
function BaseGamePlayerInfoManager:getSelfGrowthLevel()     if self._selfInfo then return self._selfInfo.nGrowthLevel   end end

function BaseGamePlayerInfoManager:clearPlayersInfo()
    self._playersInfo = {}
end

function BaseGamePlayerInfoManager:getPlayerUserNameByDrawIndex(drawIndex)
    if self._playersInfo[drawIndex] then
        return self._playersInfo[drawIndex].szUserName
    end
end

function BaseGamePlayerInfoManager:getPlayerUserNameByUserID(userID)
    local playerInfo = self:getPlayerInfoByUserID(userID)
    if playerInfo then
        return playerInfo.szUserName
    end
end

function BaseGamePlayerInfoManager:setPlayerDeposit(drawIndex, deposit)
    if self._playersInfo[drawIndex] then
        self._playersInfo[drawIndex].nDeposit = deposit
    end
    if self._gameController:getMyDrawIndex() == drawIndex then
        if self._selfInfo then
            self._selfInfo.nDeposit = deposit
        end
    end
end

function BaseGamePlayerInfoManager:getPlayerDeposit(drawIndex)
    if self._playersInfo[drawIndex] then
        return self._playersInfo[drawIndex].nDeposit
    end
end

function BaseGamePlayerInfoManager:setPlayerScore(drawIndex, score)
    if self._playersInfo[drawIndex] then
        self._playersInfo[drawIndex].nScore = score
    end
    if self._gameController:getMyDrawIndex() == drawIndex then
        if self._selfInfo then
            self._selfInfo.nScore = score
        end
    end
end

function BaseGamePlayerInfoManager:getPlayerScore(drawIndex)
    if self._playersInfo[drawIndex] then
        return self._playersInfo[drawIndex].nScore
    end
end

function BaseGamePlayerInfoManager:getPlayerNickSexByUserID(userID)
    local playerInfo = self:getPlayerInfoByUserID(userID)
    if playerInfo then
        return playerInfo.nNickSex
    end
    return 0
end

function BaseGamePlayerInfoManager:getPlayerNickSexByIndex(drawIndex)
    if self._playersInfo[drawIndex] then
        --return self._playersInfo[drawIndex].nNickSex
        local UserModel = mymodel('UserModel'):getInstance()
        local sexWithCheck = UserModel:getNickSexWithCheckSelf(self._playersInfo[drawIndex].nUserID, self._playersInfo[drawIndex].nNickSex)
        return sexWithCheck
    end
    return 0
end

function BaseGamePlayerInfoManager:addPlayerWinBout(drawIndex)
    if self._playersInfo[drawIndex] then
        self._playersInfo[drawIndex].nWin = self._playersInfo[drawIndex].nWin + 1
    end
    if self._gameController:getMyDrawIndex() == drawIndex then
        if self._selfInfo then
            self._selfInfo.nWin = self._selfInfo.nWin + 1
        end
    end
end

function BaseGamePlayerInfoManager:addPlayerLossBout(drawIndex)
    if self._playersInfo[drawIndex] then
        self._playersInfo[drawIndex].nLoss = self._playersInfo[drawIndex].nLoss + 1
    end
    if self._gameController:getMyDrawIndex() == drawIndex then
        if self._selfInfo then
            self._selfInfo.nLoss = self._selfInfo.nLoss + 1
        end
    end
end

function BaseGamePlayerInfoManager:addPlayerStandOffBout(drawIndex)
    if self._playersInfo[drawIndex] then
        self._playersInfo[drawIndex].nStandOff = self._playersInfo[drawIndex].nStandOff + 1
    end
    if self._gameController:getMyDrawIndex() == drawIndex then
        if self._selfInfo then
            self._selfInfo.nStandOff = self._selfInfo.nStandOff + 1
        end
    end
end

function BaseGamePlayerInfoManager:addPlayerScore(drawIndex, score)
    if self._playersInfo[drawIndex] then
        self._playersInfo[drawIndex].nScore  = self._playersInfo[drawIndex].nScore  + score
    end
    if self._gameController:getMyDrawIndex() == drawIndex then
        if self._selfInfo then
            self._selfInfo.nScore = self._selfInfo.nScore + score
        end
    end
end

function BaseGamePlayerInfoManager:getCurrentPlayerCount()
    if(self._playersInfo)then
        local count=0
        for i,v in pairs(self._playersInfo)do
            if(v.nUserID~="")then
                count=count+1
            end
        end
        return count
    end
    return 0
end

return BaseGamePlayerInfoManager
