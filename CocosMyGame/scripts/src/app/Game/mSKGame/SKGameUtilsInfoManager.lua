
local BaseGameUtilsInfoManager = import("src.app.Game.mBaseGame.BaseGameUtilsInfoManager")
local SKGameUtilsInfoManager = class("BaseGameUtilsInfoManager", BaseGameUtilsInfoManager)

local SKGameDef                                 = import("src.app.Game.mSKGame.SKGameDef")

local GamePublicInterface                       = import("src.app.Game.mMyGame.GamePublicInterface")

function SKGameUtilsInfoManager:ctor()
    self._utilsStartInfo                = {}
    self._utilsPublicInfo               = {}
    self._utilsPlayInfo                 = {}
    self._utilsTableInfo                = {}
    self._utilsWinInfo                  = nil
    self._utilsThrowInfo                = nil
    self._utilsPassInfo                 = nil
    self._utilsWaitInfo                 = {}
    self._utilsCurrentScore             = 0            

    SKGameUtilsInfoManager.super.ctor(self)
end

function SKGameUtilsInfoManager:getBaseScore()      if self._utilsStartInfo then return self._utilsStartInfo.nBaseScore         end end
function SKGameUtilsInfoManager:getBaseDeposit()    if self._utilsStartInfo then return self._utilsStartInfo.nBaseDeposit       end end
function SKGameUtilsInfoManager:getBoutCount()      if self._utilsStartInfo then return self._utilsStartInfo.nBoutCount         end end
function SKGameUtilsInfoManager:getCurrentChair()   if self._utilsStartInfo then return self._utilsStartInfo.nCurrentChair      end end
function SKGameUtilsInfoManager:getStatus()         if self._utilsStartInfo then return self._utilsStartInfo.dwStatus           end end
function SKGameUtilsInfoManager:getThrowWait()      if self._utilsStartInfo then return self._utilsStartInfo.nThrowWait         end end
function SKGameUtilsInfoManager:getBanker()         if self._utilsStartInfo then return self._utilsStartInfo.nBanker            end end

function SKGameUtilsInfoManager:getCurrentRank()    
    if self._utilsPublicInfo and self._utilsPublicInfo.nCurrentRank then 
        return self._utilsPublicInfo.nCurrentRank
    else
        return SKGameDef.SK_DEFAULT_RANK     
    end 
end

function SKGameUtilsInfoManager:setStatus(dwStatus)
    self._utilsStartInfo.dwStatus = dwStatus
end

function SKGameUtilsInfoManager:setStartInfo(gameStart)
    self._utilsStartInfo = gameStart
end

function SKGameUtilsInfoManager:clearTableInfo()
    self._utilsTableInfo = {}
end

function SKGameUtilsInfoManager:getStartInfo()
    if self._utilsStartInfo then
        return self._utilsStartInfo
    end
end

function SKGameUtilsInfoManager:setPublicInfo(publicInfo)
    self._utilsPublicInfo = publicInfo
end

function SKGameUtilsInfoManager:getPublicInfo()
    if self._utilsPublicInfo then
        return self._utilsPublicInfo
    end
end

function SKGameUtilsInfoManager:setStartInfoFromTableInfo(tableInfo)

end

function SKGameUtilsInfoManager:setTableInfo(tableInfo)
    self._utilsTableInfo = tableInfo
end

function SKGameUtilsInfoManager:getTableInfo()
    if self._utilsTableInfo then
        return self._utilsTableInfo
    end
end

function SKGameUtilsInfoManager:setPlayInfo(playInfo)
    local nWaitTime = {playInfo.nWaitTime1,
        playInfo.nWaitTime2,
        playInfo.nWaitTime3,
        playInfo.nWaitTime4,
        playInfo.nWaitTime5,
        playInfo.nWaitTime6,
        playInfo.nWaitTime7,
        playInfo.nWaitTime8}
        
    local nThrowTime = {playInfo.nThrowTime1,
        playInfo.nThrowTime2,
        playInfo.nThrowTime3,
        playInfo.nThrowTime4,
        playInfo.nThrowTime5,
        playInfo.nThrowTime6,
        playInfo.nThrowTime7,
        playInfo.nThrowTime8}
        
    local nTotalThrowCost = {playInfo.nTotalThrowCost1,
        playInfo.nTotalThrowCost2,
        playInfo.nTotalThrowCost3,
        playInfo.nTotalThrowCost4,
        playInfo.nTotalThrowCost5,
        playInfo.nTotalThrowCost6,
        playInfo.nTotalThrowCost7,
        playInfo.nTotalThrowCost8}
        
    local nInHandCount = {playInfo.nInHandCount1,
        playInfo.nInHandCount2,
        playInfo.nInHandCount3,
        playInfo.nInHandCount4,
        playInfo.nInHandCount5,
        playInfo.nInHandCount6,
        playInfo.nInHandCount7,
        playInfo.nInHandCount8}
        
    local nAutoThrowCount = {playInfo.nAutoThrowCount1,
        playInfo.nAutoThrowCount2,
        playInfo.nAutoThrowCount3,
        playInfo.nAutoThrowCount4,
        playInfo.nAutoThrowCount5,
        playInfo.nAutoThrowCount6,
        playInfo.nAutoThrowCount7,
        playInfo.nAutoThrowCount8}
        
    self._utilsPlayInfo.nWaitTime       = nWaitTime
    self._utilsPlayInfo.nThrowTime      = nThrowTime
    self._utilsPlayInfo.nTotalThrowCost = nTotalThrowCost
    self._utilsPlayInfo.nInHandCount    = nInHandCount
    self._utilsPlayInfo.nAutoThrowCount = nAutoThrowCount
end

function SKGameUtilsInfoManager:getPlayInfo()
    if self._utilsPlayInfo then
        return self._utilsPlayInfo
    end
end

function SKGameUtilsInfoManager:getCardsCount()
    if self._utilsPlayInfo then
        return self._utilsPlayInfo.nInHandCount
    end
end

function SKGameUtilsInfoManager:getChairCards(chairNO)     --TODO
    return {}               
end

function SKGameUtilsInfoManager:getSelfStartCards()     --TODO
    return {}               
end

function SKGameUtilsInfoManager:addCurrentScore(score)
    self._utilsCurrentScore = self._utilsCurrentScore + score
end

function SKGameUtilsInfoManager:setCurrentScore(score)
    self._utilsCurrentScore = score
end

function SKGameUtilsInfoManager:getWaitChair()
    if self._utilsPublicInfo then
        return self._utilsPublicInfo.nWaitChair
    end
end

function SKGameUtilsInfoManager:setWaitChair(chairNO)
    self._utilsPublicInfo.nWaitChair = chairNO
end

function SKGameUtilsInfoManager:setWinInfo(winInfo)
    self._utilsWinInfo = winInfo
end

function SKGameUtilsInfoManager:getWinInfo()
    if self._utilsWinInfo then
        return self._utilsWinInfo
    end
end

function SKGameUtilsInfoManager:setThrowInfo(throwInfo)
    self._utilsThrowInfo = throwInfo
end

function SKGameUtilsInfoManager:getThrowInfo()
    if self._utilsThrowInfo then
        return self._utilsThrowInfo
    end
end

function SKGameUtilsInfoManager:setPassInfo(passInfo)
    self._utilsPassInfo = passInfo
end

function SKGameUtilsInfoManager:getPassInfo()
    if self._utilsPassInfo then
        return self._utilsPassInfo
    end
end

function SKGameUtilsInfoManager:setWaitInfo(waitInfo)
    self._utilsWaitInfo = waitInfo
end

function SKGameUtilsInfoManager:getWaitInfo()
    if self._utilsWaitInfo then
        return self._utilsWaitInfo
    end
end

function SKGameUtilsInfoManager:setWaitUniteInfo(waitUnite)
    if GamePublicInterface and GamePublicInterface:IS_FRAME_1() then
        self:setWaitInfo(waitUnite)
        return
    end
    
    if self._utilsPublicInfo then
        self._utilsPublicInfo.dwCardType        = waitUnite.dwCardType
        self._utilsPublicInfo.dwComPareType     = waitUnite.dwComPareType
        self._utilsPublicInfo.nMainValue        = waitUnite.nMainValue
        self._utilsPublicInfo.nCardsCount        = waitUnite.nCardsCount
        self._utilsPublicInfo.nCardIDs          = {}
        for i = 1, waitUnite.nCardsCount do
            self._utilsPublicInfo.nCardIDs[i]   = waitUnite.nCardIDs[i]
        end
    end
end

function SKGameUtilsInfoManager:getWaitUniteInfo()
    if GamePublicInterface and GamePublicInterface:IS_FRAME_1() then
        return self:getWaitInfo()
    end
    
    local waitUnite = {}
    if self._utilsPublicInfo then
        waitUnite.dwCardType        = self._utilsPublicInfo.dwCardType
        waitUnite.dwComPareType     = self._utilsPublicInfo.dwComPareType
        waitUnite.nMainValue        = self._utilsPublicInfo.nMainValue
        waitUnite.nCardsCount       = self._utilsPublicInfo.nCardsCount
        waitUnite.nCardIDs          = {}
        for i = 1, waitUnite.nCardsCount do
            waitUnite.nCardIDs[i]   = self._utilsPublicInfo.nCardIDs[i]
        end
    end
    return waitUnite
end

return SKGameUtilsInfoManager