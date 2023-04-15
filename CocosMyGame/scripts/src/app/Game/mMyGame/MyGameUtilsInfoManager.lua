
local SKGameUtilsInfoManager = import("src.app.Game.mSKGame.SKGameUtilsInfoManager")
local MyGameUtilsInfoManager = class("MyGameUtilsInfoManager", SKGameUtilsInfoManager)

local SKGameDef                                 = import("src.app.Game.mSKGame.SKGameDef")
local MyGameDef                                 = import("src.app.Game.mMyGame.MyGameDef")
local SKCalculator                              = import("src.app.Game.mSKGame.SKCalculator")

function MyGameUtilsInfoManager:ctor()
    MyGameUtilsInfoManager.super.ctor(self)
    self._utilsStartInfo.TributeMoveNum = 0
    self._utilsStartInfo.GameStarCards = false
    
    self._utilsPlayInfo                 = {}
    for i = 1, 4 do
        self._utilsPlayInfo[i] = {}
        self._utilsPlayInfo[i].nBombCount = {}
        for j = 1, 4 do
            self._utilsPlayInfo[i].nBombCount[j] = 0
        end
    end

    self.bEndedExit = 1
end

function MyGameUtilsInfoManager:getCurrentRank()    
    if self._utilsStartInfo and self._utilsStartInfo.nCurrentRank then 
        return self._utilsStartInfo.nCurrentRank
    else
        print('MyGameUtilsInfoManager:getCurrentRank() self._utilsStartInfo or nCurrentRank nil')
        dump(self._utilsStartInfo)
        return SKGameDef.SK_DEFAULT_RANK
    end 
end

function MyGameUtilsInfoManager:RUL_GetNextChairNO(chairNO)
    return (chairNO+(MyGameDef.MY_TOTAL_PLAYERS - 1))%MyGameDef.MY_TOTAL_PLAYERS
end

function MyGameUtilsInfoManager:RUL_GetPrevChairNO(chairNO)
    return (chairNO+1)%MyGameDef.MY_TOTAL_PLAYERS
end

function MyGameUtilsInfoManager:RUL_GetDuiJiaChairNO(chairNO)
    return (chairNO+2)%MyGameDef.MY_TOTAL_PLAYERS
end


function MyGameUtilsInfoManager:setStatus(dwStatus)
    self._utilsStartInfo.dwStatus = dwStatus
end

function MyGameUtilsInfoManager:getStatus()
    if self._utilsStartInfo then
        return self._utilsStartInfo.dwStatus
    end
end

function MyGameUtilsInfoManager:getCardsCount()
    if self._utilsPublicInfo and self._utilsPublicInfo.nPlayerCardsCount and not self._utilsStartInfo.GameStarCards then
        return self._utilsPublicInfo.nPlayerCardsCount
    else 
        return {self._utilsStartInfo.nInHandCount,self._utilsStartInfo.nInHandCount,self._utilsStartInfo.nInHandCount,self._utilsStartInfo.nInHandCount}
    end
end

function MyGameUtilsInfoManager:getChairCards(chairNO)
    if self._utilsTableInfo then
        return self._utilsTableInfo.nChairCards
    end
end

function MyGameUtilsInfoManager:getWaitChair()
    --[[if self._utilsTableInfo then
        return self._utilsTableInfo.nWaitingChair
    end--]]
    if self._utilsPublicInfo then
        return self._utilsPublicInfo.nWaitChair
    end
end

function MyGameUtilsInfoManager:setWaitChair(chairNO)
    --self._utilsTableInfo.nWaitingChair = chairNO
    if self._utilsPublicInfo then
        self._utilsPublicInfo.nWaitChair = chairNO
    end
end

function MyGameUtilsInfoManager:getShownCards(chairNO)
    --[[if self._utilsTableInfo then
        return self._utilsTableInfo.nShowCards[chairNO]
    end--]]
    if self._utilsTableInfo then
        return self._utilsTableInfo['nInHandCount'..(chairNO+1)]
    end
end

function MyGameUtilsInfoManager:getFriendChair()
    if self._utilsTableInfo then
        return self._utilsTableInfo.nFriendChair
    end
end

function MyGameUtilsInfoManager:getBonus(chairno)
    if self._utilsTableInfo then
        return self._utilsTableInfo.nBonus[chairno]
    end
end

function MyGameUtilsInfoManager:getSelfStartCards()
    if self._utilsStartInfo then
        return self._utilsStartInfo.nHandID
    end
end

function MyGameUtilsInfoManager:getSelfDXXWCards()
    if self._utilsPublicInfo then
        return self._utilsPublicInfo.SelfDXXWCards
    end
end


function MyGameUtilsInfoManager:setStartInfoFromTableInfo(tableInfo)
    self:setStartInfo(tableInfo)
    
    self._utilsPublicInfo.nWaitChair        = tableInfo.nWaitChair
    self._utilsPublicInfo.dwCardType        = tableInfo.dwCardType
    self._utilsPublicInfo.dwComPareType        = tableInfo.dwComPareType
    self._utilsPublicInfo.nMainValue        = tableInfo.nMainValue
    self._utilsPublicInfo.nCardsCount        = tableInfo.nCardCount
    self._utilsPublicInfo.nCardIDs        = tableInfo.nCardIDs

    self:setCardInfo(tableInfo)

    self._utilsPublicInfo.bnChairWin    = tableInfo.bnChairWin


    self._utilsPlayInfo[1].nBombCount = tableInfo.nBombCount
    for i=2, 4 do
        self._utilsPlayInfo[i].nBombCount = tableInfo['nBombCount'..(i-1)]
    end
end

function MyGameUtilsInfoManager:setStartInfo(gameStart)
    self._utilsStartInfo.nBoutCount     = gameStart.nBoutCount
    self._utilsStartInfo.nBaseDeposit   = gameStart.nBaseDeposit
    self._utilsStartInfo.nBaseScore     = gameStart.nBaseScore
    self._utilsStartInfo.bNeedDeposit   = gameStart.bNeedDeposit
    self._utilsStartInfo.bForbidDesert   = gameStart.bForbidDesert
    self._utilsStartInfo.nCurrentChair  = gameStart.nCurrentChair
    self._utilsStartInfo.nBanker        = gameStart.nBanker

    self._utilsStartInfo.nFirstCatch    = gameStart.nCurrentChair
    self._utilsStartInfo.dwStatus       = gameStart.dwStatus
    self._utilsStartInfo.nThrowWait     = gameStart.nThrowWait
    self._utilsStartInfo.nAutoGiveUp    = gameStart.nAutoGiveUp
    self._utilsStartInfo.nOffline       = gameStart.nOffline
    self._utilsStartInfo.nInHandCount   = gameStart.nInHandCount
    self._utilsStartInfo.nThrowWaitEx   = gameStart.nThrowWaitEx
    self._utilsStartInfo.nRank          = gameStart.nRank
    self._utilsStartInfo.nRound         = gameStart.nRound
    self._utilsStartInfo.nCurrentRank   = gameStart.nCurrentRank
      
    self:setTributeInfo(gameStart)
    
    self._utilsStartInfo.nPlace         = gameStart.nPlace
    self._utilsStartInfo.bnShowRank     = gameStart.bnShowRank
    self._utilsStartInfo.bnResetGame    = gameStart.bnResetGame

    self._utilsStartInfo.nHandID        = gameStart.nHandID
   
    self._utilsStartInfo.nFriendID      = gameStart.nFriendID
    self._utilsStartInfo.nFaceID        = gameStart.nFaceID
    self._utilsStartInfo.nLastScoreDiffs        = gameStart.nLastScoreDiffs
    self._utilsStartInfo.nTotalScoreDiffs        = gameStart.nTotalScoreDiffs
    self._utilsStartInfo.bnCardMasterChairUse        = gameStart.bnCardMasterChairUse
    self._utilsStartInfo.nObjectGains        = gameStart.nObjectGains
    self._utilsStartInfo.nFanPaiCardID        = gameStart.nFanPaiCardID
    self._utilsStartInfo.nRanker        = gameStart.nRanker
    self._utilsStartInfo.nReserved      = gameStart.nReserved
    self._utilsStartInfo.nGuideUser     = gameStart.nReserved[2]
    self._utilsStartInfo.nQuickAdjust   = gameStart.nReserved[3]
    self._utilsStartInfo.nGuideBout     = gameStart.nReserved[4]
end

function MyGameUtilsInfoManager:setTributeInfo(tributeTable)
    self._utilsStartInfo.Tribute = {}
    for i=1, MyGameDef.MY_TOTAL_PLAYERS do 
        self._utilsStartInfo.Tribute[i] = {}
    end
    self._utilsStartInfo.Tribute[1].bnTribute = tributeTable['bnTribute']
    self._utilsStartInfo.Tribute[1].winner = tributeTable['winner']
    self._utilsStartInfo.Tribute[1].nCardID = tributeTable['nCardID']
    self._utilsStartInfo.Tribute[1].bnFight = tributeTable['bnFight']
    self._utilsStartInfo.Tribute[1].nFightID = tributeTable['nFightID']
    for i=2, MyGameDef.MY_TOTAL_PLAYERS do   
        self._utilsStartInfo.Tribute[i].bnTribute = tributeTable['bnTribute'..(i-1)]
        self._utilsStartInfo.Tribute[i].winner = tributeTable['winner'..(i-1)]
        self._utilsStartInfo.Tribute[i].nCardID = tributeTable['nCardID'..(i-1)]
        self._utilsStartInfo.Tribute[i].bnFight = tributeTable['bnFight'..(i-1)]
        self._utilsStartInfo.Tribute[i].nFightID = tributeTable['nFightID'..(i-1)]    
    end   

    if self._utilsStartInfo.TributeMoveNum == 0 then      
        for i = 1, MyGameDef.MY_TOTAL_PLAYERS  do
            if self._utilsStartInfo.Tribute[i].bnTribute > 0 then            
                self._utilsStartInfo.TributeMoveNum = self._utilsStartInfo.TributeMoveNum + 1
            end
        end
    end
end

function MyGameUtilsInfoManager:setCardInfo(CardTable)
    self._utilsPublicInfo.nPlayerCardsCount = {}   
    for i = 1, MyGameDef.MY_TOTAL_PLAYERS do
        self._utilsPublicInfo.nPlayerCardsCount[i] = 0
    end

    local nCount = 1
    local nFirendCount = 1
    self._utilsTableInfo.nFriendCards = {}
    SKCalculator:xygInitChairCards(self._utilsTableInfo.nFriendCards, MyGameDef.MY_CHAIR_CARDS)
    self._utilsPublicInfo.SelfDXXWCards = {}
    SKCalculator:xygInitChairCards(self._utilsPublicInfo.SelfDXXWCards, MyGameDef.MY_CHAIR_CARDS)
    
    local GameController = GamePublicInterface._gameController
    local MyChairNo = GamePublicInterface._gameController:getMyChairNO()
    self._utilsPublicInfo.GameCard = {}
    self._utilsPublicInfo.GameCard[1] = {}

    self._utilsPublicInfo.GameCard[1].nCardID = CardTable['nCardID4']
    self._utilsPublicInfo.GameCard[1].nCardIndex = CardTable['nCardIndex']
    self._utilsPublicInfo.GameCard[1].nShape = CardTable['nShape']
    self._utilsPublicInfo.GameCard[1].nValue = CardTable['nValue']
    self._utilsPublicInfo.GameCard[1].nCardStatus = CardTable['nCardStatus']
    self._utilsPublicInfo.GameCard[1].nChairNO = CardTable['nChairNO']
    self._utilsPublicInfo.GameCard[1].nPositionIndex = CardTable['nPositionIndex']
    self._utilsPublicInfo.GameCard[1].nUniteCount = CardTable['nUniteCount']

    local ChairNo = self._utilsPublicInfo.GameCard[1].nChairNO
    if self._utilsPublicInfo.GameCard[1].nCardStatus == SKGameDef.SK_CARD_STATUS_INHAND then
        self._utilsPublicInfo.nPlayerCardsCount[GameController:rul_GetDrawIndexByChairNO(ChairNo)] = self._utilsPublicInfo.nPlayerCardsCount[GameController:rul_GetDrawIndexByChairNO(ChairNo)] + 1
        if ChairNo == MyChairNo then
            self._utilsPublicInfo.SelfDXXWCards[nCount] = self._utilsPublicInfo.GameCard[1].nCardID
            nCount=nCount+1
        elseif self:RUL_GetDuiJiaChairNO(MyChairNo) == ChairNo and self._utilsPublicInfo.GameCard[1].nCardID~=-1 then
            self._utilsTableInfo.nFriendCards[nFirendCount] = self._utilsPublicInfo.GameCard[1].nCardID
            nFirendCount = nFirendCount + 1
        end
    end
    
    for i=2, MyGameDef.MY_TOTAL_CARDS do
        self._utilsPublicInfo.GameCard[i] = {}
        self._utilsPublicInfo.GameCard[i].nCardID = CardTable['nCardID'..(i+3)]
        self._utilsPublicInfo.GameCard[i].nCardIndex = CardTable['nCardIndex'..(i-1)]
        self._utilsPublicInfo.GameCard[i].nShape = CardTable['nShape'..(i-1)]
        self._utilsPublicInfo.GameCard[i].nValue = CardTable['nValue'..(i-1)]
        self._utilsPublicInfo.GameCard[i].nCardStatus = CardTable['nCardStatus'..(i-1)]
        self._utilsPublicInfo.GameCard[i].nChairNO = CardTable['nChairNO'..(i-1)]
        self._utilsPublicInfo.GameCard[i].nPositionIndex = CardTable['nPositionIndex'..(i-1)]
        self._utilsPublicInfo.GameCard[i].nUniteCount = CardTable['nUniteCount'..(i-1)]

        if self._utilsPublicInfo.GameCard[i].nCardStatus == SKGameDef.SK_CARD_STATUS_INHAND then
            local ChairNo = self._utilsPublicInfo.GameCard[i].nChairNO
            self._utilsPublicInfo.nPlayerCardsCount[GameController:rul_GetDrawIndexByChairNO(ChairNo)] = self._utilsPublicInfo.nPlayerCardsCount[GameController:rul_GetDrawIndexByChairNO(ChairNo)] + 1
            if ChairNo == MyChairNo then
                self._utilsPublicInfo.SelfDXXWCards[nCount] = self._utilsPublicInfo.GameCard[i].nCardID
                nCount=nCount+1
            elseif self:RUL_GetDuiJiaChairNO(MyChairNo) == ChairNo and self._utilsPublicInfo.GameCard[i].nCardID~=-1 then
                self._utilsTableInfo.nFriendCards[nFirendCount] = self._utilsPublicInfo.GameCard[i].nCardID
                nFirendCount = nFirendCount + 1
            end
        end
    end
    self._utilsTableInfo._nFriendCardCount = nFirendCount-1
end

function MyGameUtilsInfoManager:setFriendCard(nCardID)
    self._utilsTableInfo.nFriendCards = nCardID
end

function MyGameUtilsInfoManager:getFriendCard()
    if self._utilsTableInfo then
        return self._utilsTableInfo.nFriendCards
    end
end

function MyGameUtilsInfoManager:getFinishShow(chairno)
    if self._utilsTableInfo and self._utilsTableInfo.bFinishShow then
        return self._utilsTableInfo.bFinishShow[chairno]
    end
end

function MyGameUtilsInfoManager:getMyUserStaus()
    if self._utilsTableInfo and self._utilsTableInfo.nReserved then
        return self._utilsTableInfo.nReserved[1]
    end
end

function MyGameUtilsInfoManager:getFirstThrow()    if self._utilsStartInfo then return self._utilsStartInfo.nFirstThrow       end end
function MyGameUtilsInfoManager:getCallWait()      if self._utilsStartInfo then return self._utilsStartInfo.nCallWait         end end
function MyGameUtilsInfoManager:getShowWait()      if self._utilsStartInfo then return self._utilsStartInfo.nShowWait         end end
function MyGameUtilsInfoManager:getTributeWait()      if self._utilsStartInfo then return self._utilsStartInfo.nThrowWaitEx[3]         end end
function MyGameUtilsInfoManager:getReturnWait()      if self._utilsStartInfo then return self._utilsStartInfo.nThrowWaitEx[2]         end end
function MyGameUtilsInfoManager:getThrowWait()
    if self._utilsStartInfo then
        --if self._utilsStartInfo.nTotalOpe >= --[[SKGameDef.SK_TOTAL_PLAYERS--]]MyGameDef.MY_TOTAL_PLAYERS then
        if self._utilsStartInfo then
            if self._utilsStartInfo.nThrowWaitEx[1] then
                return self._utilsStartInfo.nThrowWaitEx[1]
            else
                return 50
            end
        else 
            return 50
        end
         
        --[[if false then
            return self._utilsStartInfo.nThrowWaitEx[1]
        else
            return self._utilsStartInfo.nThrowWait
        end--]]
    end
end

function MyGameUtilsInfoManager:getWaitUniteInfo()
    if GamePublicInterface and GamePublicInterface:IS_FRAME_1() then
        return self:getWaitInfo()
    end
    
    local waitUnite = {}

    
    if self._utilsPublicInfo.dwCardType == nil then
        self._utilsPublicInfo.dwCardType        = 0
        self._utilsPublicInfo.dwComPareType    = 0
        self._utilsPublicInfo.nMainValue      = 0
        self._utilsPublicInfo.nCardsCount      = 0
        self._utilsPublicInfo.nCardIDs          = {}
    end
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

function MyGameUtilsInfoManager:getPlayInfoByChairNo(chairNO)
    return self._utilsPlayInfo[chairNO+1]
end

function MyGameUtilsInfoManager:isAnchorMatchGameRankOver()
    if self._utilsStartInfo and self._utilsStartInfo.nRound then
        return self._utilsStartInfo.nRound[1] == 1
    end
    return true
end

return MyGameUtilsInfoManager