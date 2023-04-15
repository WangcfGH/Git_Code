
if nil == cc or nil == cc.exports then
    return
end
local SKGameController                          = import("src.app.Game.mSKGame.SKGameController")

cc.exports.MyGameController                     = {}
local MyGameController                          = cc.exports.MyGameController

local BaseGameDef                               = import("src.app.Game.mBaseGame.BaseGameDef")
local SKGameDef                                 = import("src.app.Game.mSKGame.SKGameDef")

local MyGameDef                                 = import("src.app.Game.mMyGame.MyGameDef")
local MyGameData                                = import("src.app.Game.mMyGame.MyGameData")
local MyGameUtilsInfoManager                    = import("src.app.Game.mMyGame.MyGameUtilsInfoManager")
local MyGameConnect                             = import("src.app.Game.mMyGame.MyGameConnect")
local MyGameNotify                              = import("src.app.Game.mMyGame.MyGameNotify")

local MyCalculator                              = import("src.app.Game.mMyGame.MyCalculator")

local MyGameShare                               = import("src.app.Game.mMyGame.MyGameShare")

local MyGameArenaInfoManager                              = import("src.app.Game.mMyGame.MyGameArena.MyGameArenaInfoManager")
local ArenaDataSet                              = require("src.app.plugins.arena.ArenaDataSet"):getInstance()
local ArenaModel = require("src.app.plugins.arena.ArenaModel"):getInstance()
local RoomListModel = import("src.app.GameHall.room.model.RoomListModel"):getInstance()
local TaskModel = import("src.app.plugins.MyTaskPlugin.TaskModel"):getInstance()
local LoginLotteryModel = import("src.app.plugins.loginlottery.LoginLotteryModel"):getInstance()
local ExchangeCenterModel = require("src.app.plugins.ExchangeCenter.ExchangeCenterModel"):getInstance()
local CardRecorderModel = require("src.app.plugins.shop.cardrecorder.CardRecorderModel"):getInstance()
local UserLevelModel = import("src.app.plugins.personalinfo.UserLevelModel"):getInstance()
local ShopModel = mymodel("ShopModel"):getInstance()
local verticalCardsMode = require("src.app.Game.mMyGame.GamePublicInterface"):GetGameControllerConfig("verticalArrangement")
local player=mymodel('hallext.PlayerModel'):getInstance()
require("src.app.GameHall.PublicInterface")
local RichText              = require("src.app.mycommon.myrichtext.MyRichText")

local MyGameCardMakerInfo = require("src.app.Game.mMyGame.MyGameCardMaker.MyGameCardMakerInfo"):getInstance()

local WeakenScoreRoomModel = require('src.app.plugins.weakenscoreroom.WeakenScoreRoomModel'):getInstance()

local WinningStreakModel      = import("src.app.plugins.WinningStreak.WinningStreakModel"):getInstance()

local FirstRechargeModel      = import("src.app.plugins.firstrecharge.FirstRechargeModel"):getInstance()

local AutoSupplyModel      = import("src.app.plugins.AutoSupply.AutoSupplyModel"):getInstance()
local AdvertModel          = import('src.app.plugins.advert.AdvertModel'):getInstance()
local AdvertDefine         = import('src.app.plugins.advert.AdvertDefine')

local BankruptcyModel = import('src.app.plugins.Bankruptcy.BankruptcyModel'):getInstance()
local BankruptcyDef = require('src.app.plugins.Bankruptcy.BankruptcyDef')

local TimingGameModel = import('src.app.plugins.TimingGame.TimingGameModel'):getInstance()

local Team2V2Model = import('src.app.plugins.Team2V2Model.Team2V2Model'):getInstance()

local OldUserInviteGiftModel = require('src.app.plugins.invitegift.oldusergift.OldUserInviteGiftModel'):getInstance()

local user=mymodel('UserModel'):getInstance()

local PublicInterFace                           = cc.exports.PUBLIC_INTERFACE

MyGameController.super = SKGameController
setmetatable(MyGameController, {__index = MyGameController.super})

MyGameController._sortFlag = SKGameDef.SORT_CARD_BY_ORDER--SKGameDef.SORT_CARD_BY_BOME--SKGameDef.SORT_CARD_BY_ORDER

MyGameController._needReturnRoomID = nil

MyGameController._CARD_STATUS = {
    AUTO_PASS = 0,  -- 已触发自动过牌
    NO_BIGGER = 1,  -- 已触发只显示要不起按钮
    NORMAL = 2,     -- 没有触发自动过牌和要不起
}
MyGameController.NoBiggerWaitTime = 10
MyGameController._MyGameCardMakerInfo = MyGameCardMakerInfo

function MyGameController:onShare()
    if MyGameShare then
        self._baseGameScene._SKGameShare = MyGameShare:share()
    end

end

-- 游戏场内选桌
--[[function MyGameController:onSelectTable(groupId)
    PUBLIC_INTERFACE.GetEnterGameInfo():SelectSectionInGame(groupId)
end]]--

function MyGameController:createGameData()
    self._baseGameData = MyGameData:create()
    cc.exports.oneRoundGameWinData={}
end

function MyGameController:createUtilsInfoManager()
    self._baseGameUtilsInfoManager = MyGameUtilsInfoManager:create()
    self:setUtilsInfo()
end

function MyGameController:initManagerAboveSKGame() end

function MyGameController:setConnect()
    self._baseGameConnect = MyGameConnect:create(self)
end

function MyGameController:setNotify()
    self._baseGameNotify = MyGameNotify:create(self)
end

function MyGameController:parseGameTableInfoData(data)
    local tableInfo = nil
    local soloPlayers = nil
    if self._baseGameData then
        tableInfo, soloPlayers = self._baseGameData:getGameTableInfo(data)
    end

    if soloPlayers and 0 < #soloPlayers then
        if self._baseGamePlayerInfoManager then
            self._baseGamePlayerInfoManager:clearPlayersInfo()
        end
        local playerManager = self._baseGameScene:getPlayerManager()
        if playerManager then
            playerManager:clearPlayers()
        end

        for i = 1, #soloPlayers do
            self:setSoloPlayer(soloPlayers[i])
        end
    end

    if not self._baseGameUtilsInfoManager then
        return
    end

    if tableInfo then
        self._baseGameUtilsInfoManager:setTableInfo(tableInfo)
        self._baseGameUtilsInfoManager:setStartInfoFromTableInfo(tableInfo)
    end
end

function MyGameController:isAllowUpdateOnlineNum()
    local selectTableConfig = cc.exports._gameJsonConfig.RoomSectionConfig
    if selectTableConfig then
        if self._isAllowUpdateOnlineNum == nil then
            self._isAllowUpdateOnlineNum = true
            return true
        elseif self._isAllowUpdateOnlineNum then
            self._isAllowUpdateOnlineNum = false
            my.scheduleOnce(function()
                self._isAllowUpdateOnlineNum = true
                end, selectTableConfig.nMinUpdateTime)
            return true
        else
            return false
        end
    end
       
end

function MyGameController:onCallFriend(data)
    local callFriend = nil
    if self._baseGameData then
        callFriend = self._baseGameData:getCallFriendInfo(data)
    end
    
    self:ope_CallFriend(callFriend)
end

function MyGameController:ope_CallFriend(callFriend)
    local gameInfo = self._baseGameScene:getGameInfo()
    if gameInfo and callFriend then
        gameInfo:ope_SetFriendCard(callFriend.nCardID)
    end

    if self._baseGameUtilsInfoManager then
        self._baseGameUtilsInfoManager:setStatus(MyGameDef.MYGAME_TS_WAITING_BANKSHOW)
        self._baseGameUtilsInfoManager:setFriendCard(callFriend.nCardID)
    end

    local playerManager = self._baseGameScene:getPlayerManager()
    if playerManager and callFriend then
        local SKHandCardsManager = self._baseGameScene:getSKHandCardsManager()
        if SKHandCardsManager then
            SKHandCardsManager:updateHandCards(self:getMyDrawIndex())
            local cardIDs, cardsCount = SKHandCardsManager:getHandCardIDs(self:getMyDrawIndex())
            if self:getBankerDrawIndex() ~= self:getMyDrawIndex() and MyCalculator:xygHaveCard(cardIDs, cardsCount, callFriend.nCardID) then
                playerManager:showHelper(self:getMyDrawIndex())
            end
        end
    end

    self:hideOperationBtns()
    
    --local setData = self._baseGameScene:getSetting()
    --local langauge = setData._selectedLangauge
    local drawIndex = self:rul_GetDrawIndexByChairNO(callFriend.nChairNO) 
    local sex = self._baseGamePlayerInfoManager:getPlayerNickSexByIndex(drawIndex)
    local path
    if sex == 1 then   
        path = "res/Game/GameSound/ThrowCards/Female/"
    else
        path = "res/Game/GameSound/ThrowCards/Male/"
    end

    local content
    if callFriend.nCardID == -1 then
        content = self:getGameStringByKey("G_CHAT_1V4")
        audio.playSound(path.."1da4.ogg", false)
    else
        content = self:getGameStringByKey("G_CHAT_2V3")
        audio.playSound(path.."2da3.ogg", false)
    end
    self:tipChatContent(drawIndex, content)

    local clock = self._baseGameScene:getClock()
    if clock then
        clock:moveClockHandTo(self:getBankerDrawIndex())

        if self:getMyDrawIndex() == self:getBankerDrawIndex() then
            self:showOperationBtns()
        end

        if 0 == clock:getDigit() then
            self:onGameClockZero()
        end
    end
end

function MyGameController:onGameClockZero()
    local SKHandCardsManager        = self._baseGameScene:getSKHandCardsManager()
    if not self._baseGameUtilsInfoManager or not SKHandCardsManager then
        return
    end

    local SKOpeBtnManager = self._baseGameScene:getSKOpeBtnManager()
    if SKOpeBtnManager then
        if SKOpeBtnManager:isTributeVisible() then
            self:OPE_GETTributeCard()
            self:onTribute()
            return
        end
        if SKOpeBtnManager:isReturnVisible() then
            self:OPE_GETReturnCard()
            self:onReturn()
            return
        end
    end

    if self:isClockPointToSelf() then
        local status = self._baseGameUtilsInfoManager:getStatus()
        if self:IS_BIT_SET(status, BaseGameDef.BASEGAME_TS_WAITING_THROW) then
        
            local waitChair = self._baseGameUtilsInfoManager:getWaitChair()
            if waitChair and waitChair ~= -1 and self:isSameGroup(waitChair) then
                local myHandCards = SKHandCardsManager:getSKHandCards(self:getMyDrawIndex())
                if not myHandCards then 
                    self:onPassCard()
                    self:onAutoPlay(true)
                    return 
                end
                local inhandCards, cardsCount = myHandCards:getHandCardIDs()
                SKHandCardsManager:selectMyCardsByIDs(inhandCards, cardsCount)
                if self:ope_CheckSelect() then
                    self:onThrow()
                    self:onAutoPlay(true)
                    return
                end
                SKHandCardsManager:ope_UnselectSelfCards()

                self:onPassCard()
                self:onAutoPlay(true)
                return
            end
            SKHandCardsManager:resetRemind()
            self:onHint()
            if self:ope_CheckSelect() then
                self:onThrow()
                self:onAutoPlay(true)
                return
            end

            if SKHandCardsManager:isFirstHand() then
                self:onThrowCard(self:getAutoThrowCardIDs())
            else
                self:onPassCard()
            end
            self:onAutoPlay(true)
        elseif self:IS_BIT_SET(status, MyGameDef.MYGAME_TS_WAITING_TRIBUTE) then
            self:OPE_GETTributeCard()
            self:onTribute()
        elseif self:IS_BIT_SET(status, MyGameDef.MYGAME_TS_WAITING_RETURN) then
            self:OPE_GETReturnCard()
            self:onReturn()
        end
    end
end

function MyGameController:OPE_GETTributeCard()
    local SKHandCardsManager        = self._baseGameScene:getSKHandCardsManager()
    if not SKHandCardsManager then return false end
    
    SKHandCardsManager._SKHandCards[self:getMyDrawIndex()]:unSelectCards()

    local nInhandCard, nInHandCardCount = SKHandCardsManager:getHandCardIDs(self:getMyDrawIndex())
    local temp, m = 0, -1
    
    for i=1, nInHandCardCount do
        if nInhandCard[i]~=-1 and not MyCalculator:isJoker(nInhandCard[i]) 
            and MyCalculator:getCardPriEx(nInhandCard[i], self._baseGameUtilsInfoManager:getCurrentRank(), 0) > m then
            m = MyCalculator:getCardPriEx(nInhandCard[i], self._baseGameUtilsInfoManager:getCurrentRank(), 0)
            temp = nInhandCard[i]
        end
    end
    SKHandCardsManager:selectMyCardsByIDs({temp}, 1)
end


function MyGameController:OPE_GETReturnCard()
    local SKHandCardsManager        = self._baseGameScene:getSKHandCardsManager()
    if not SKHandCardsManager then return false end

    SKHandCardsManager._SKHandCards[self:getMyDrawIndex()]:unSelectCards()

    local nInhandCard, nInHandCardCount = SKHandCardsManager:getHandCardIDs(self:getMyDrawIndex())
    local temp, m = 0, 13 -- m从A开始, 而不是10
    
    for i=1, nInHandCardCount do
        if nInhandCard[i]~=-1 and not MyCalculator:isJoker(nInhandCard[i]) 
            and MyCalculator:getCardPriEx(nInhandCard[i], self._baseGameUtilsInfoManager:getCurrentRank(), 0) < m then
            m = MyCalculator:getCardPriEx(nInhandCard[i], self._baseGameUtilsInfoManager:getCurrentRank(), 0)
            temp = nInhandCard[i]
        end
    end

    SKHandCardsManager:selectMyCardsByIDs({temp}, 1)
end

function MyGameController:onShowCards(data)     --传过来的消息结构实际上是CARDS_INFO
    self:onCardsInfo(data)

    --[[local cardsInfo = nil
    if self._baseGameData then
        cardsInfo = self._baseGameData:getCardsInfo(data)
    end

    self:ope_ShowCards(cardsInfo)--]]
end

function MyGameController:onGameMsg(data)     

    local MsgInfo = nil
    if self._baseGameData then
        MsgInfo = self._baseGameData:getGameMsg(data)
    end

    if MsgInfo.nMsgID == MyGameDef.HAGD_GAME_MSG_TRIBUTE then
       local Msg_TributeCard = nil
       if self._baseGameData then
          Msg_TributeCard = self._baseGameData:getGameMsgTributeCard(data)
       end
       self:ope_CardsTribute(Msg_TributeCard)
    elseif MsgInfo.nMsgID == MyGameDef.HAGD_GAME_MSG_TRIBUTEOVER then
       local Msg_TributeOver = nil
       if self._baseGameData then
          Msg_TributeOver = self._baseGameData:getGameMsgTributeCardOver(data)
       end
       self:ope_CardsTributeOver(Msg_TributeOver)
    elseif MsgInfo.nMsgID == MyGameDef.HAGD_GAME_MSG_RETURN then
        local delayTime = 0
        if self._opeCardTributeOver and PUBLIC_INTERFACE.IsStartAsTeam2V2() then
            delayTime = 3.5
        end
        my.scheduleOnce(function()
            local Msg_TributeReturn = nil
            if self._baseGameData then
                Msg_TributeReturn = self._baseGameData:getGameMsgReturnCard(data)
            end
            self:ope_CardsReturn(Msg_TributeReturn)
            if PUBLIC_INTERFACE.IsStartAsTeam2V2() then
                local delayTimeGetTableInfo = 3.5
                my.scheduleOnce(function()
                    if self._baseGameConnect then
                        self._baseGameConnect:gc_GetTableInfo()
                    end
                end, delayTimeGetTableInfo)
            end
        end, delayTime)
    elseif MsgInfo.nMsgID == MyGameDef.HAGD_GAME_MOVECARD_OVER then
        self:NTF_MoveOver()
    end

    --self:ope_ShowCards(cardsInfo)
end

function MyGameController:GameMsgDataOut(data)     

    local MsgInfo = nil
    if self._baseGameData then
        MsgInfo = self._baseGameData:getGameMsg(data)
    end

    if MsgInfo.nMsgID == MyGameDef.HAGD_GAME_MSG_RETURN then
        self._havemovedcard = self._havemovedcard + 1
    end
end

function MyGameController:ope_CheckSelect()

    local SKHandCardsManager        = self._baseGameScene:getSKHandCardsManager()
    local SKOpeBtnManager           = self._baseGameScene:getSKOpeBtnManager()
    if not SKHandCardsManager or not SKOpeBtnManager then return false end

    local cardsWaiting              = self._baseGameUtilsInfoManager:getWaitUniteInfo()
    local cardsThrow, cardsCount    = SKHandCardsManager:getMySelectCardIDs()
    local bFirstHand                = SKHandCardsManager:isFirstHand()

    if not cardsThrow or not cardsCount then return false end
    if not bFirstHand and not cardsWaiting then return false end

    local status        = self._baseGameUtilsInfoManager:getStatus()
        
    --SKHandCardsManager:setHandCardsCount(self:getMyDrawIndex(), cardid)
    --SKHandCardsManager:ope_AddTributeAndReturnCard(self:getMyDrawIndex(), cardid)
    --cardid = cardid+1
    --SKOpeBtnManager:setReturnEnable(false)
    --SKOpeBtnManager:setTributeEnable(false)

    if self:IS_BIT_SET(status, MyGameDef.MYGAME_TS_WAITING_RETURN) then
        if SKOpeBtnManager:isReturnVisible() then
            if cardsCount ~= 1 then
                SKOpeBtnManager:setReturnEnable(false)
                return false
            end

            local handCards = SKHandCardsManager._SKHandCards[self:getMyDrawIndex()]
            local minPri = handCards:getMinHandCardsPriForReturn()
            
            if MyCalculator:getCardPriEx(cardsThrow[1], self._baseGameUtilsInfoManager:getCurrentRank(), 0) > minPri then
                SKOpeBtnManager:setReturnEnable(false)
                return
            end
            SKOpeBtnManager:setReturnEnable(true)
        end
    end

    if self:IS_BIT_SET(status, MyGameDef.MYGAME_TS_WAITING_TRIBUTE) then
        if SKOpeBtnManager:isTributeVisible() then
            if cardsCount ~= 1 then
                SKOpeBtnManager:setTributeEnable(false)
                return false
            end
            if MyCalculator:isJoker(cardsThrow[1]) then
                SKOpeBtnManager:setTributeEnable(false)
                return false
            end
            local m = MyCalculator:getCardPriEx(cardsThrow[1], self._baseGameUtilsInfoManager:getCurrentRank(), 0)
            --local nInhandCard = {}
            
            local nInhandCard, nInHandCardCount = SKHandCardsManager:getHandCardIDs(self:getMyDrawIndex())
    
            --self:xygInitChairCards(cardIDs,SKGameDef.SK_MAX_CARDS_PER_CHAIR)
            --nInhandCard = SKHandCardsManager:getSKHandCards(self:getMyDrawIndex())
            for i=1, nInHandCardCount do
                if nInhandCard[i]~=-1 and not MyCalculator:isJoker(nInhandCard[i]) 
                    and MyCalculator:getCardPriEx(nInhandCard[i], self._baseGameUtilsInfoManager:getCurrentRank(), 0) > m then
                    SKOpeBtnManager:setTributeEnable(false)
                    return false
                end
            end
            SKOpeBtnManager:setTributeEnable(true)
        end
    end

    if not self:IS_BIT_SET(status, BaseGameDef.BASEGAME_TS_WAITING_THROW) then return false end

    self:ResetArrageButton()
    --[[if cardsCount > 0 then -- 理牌按钮
        self._baseGameScene._MyResetBtn:setVisible(false)
        self._baseGameScene._MyArrageBtn:setVisible(true)
        self._baseGameScene._MyArrageBtn:setBright(true)
        self._baseGameScene._MyArrageBtn:setEnabled(true)
    else        
        self:ResetArrageButton()
    end--]]
    
    if not SKOpeBtnManager:isThrowVisible()  then return false end    

    local bEnableThrow = self:isEnableThrow(bFirstHand, cardsThrow, cardsCount, cardsWaiting)
    SKOpeBtnManager:setThrowEnable(bEnableThrow)

    return bEnableThrow
end

function MyGameController:ope_ShowCards(cardsInfo)
    if cardsInfo.nCardsCount > 0 then
        self:playGamePublicSound("Snd_showhand.ogg")
    end

    local showWait = 0
    if self._baseGameUtilsInfoManager then
        self._baseGameUtilsInfoManager:setStatus(MyGameDef.MYGAME_TS_WAITING_SHOW)
        showWait = self._baseGameUtilsInfoManager:getShowWait()
    end

    local clock = self._baseGameScene:getClock()
    if clock then
        local drawIndex = self:rul_GetDrawIndexByChairNO(cardsInfo.nChairNO)

        if self:getMyDrawIndex() ~= self:getBankerDrawIndex() and drawIndex == self:getBankerDrawIndex() then
            clock:start(showWait)
            clock:moveClockHandTo(self:getMyDrawIndex())
            self:showOperationBtns()
        end

        if drawIndex == self:getMyDrawIndex() and cardsInfo.nCardsCount > 0 then
            local playerManager = self._baseGameScene:getPlayerManager()
            if playerManager then
                playerManager:setShowCards(drawIndex)
            end
        end
    end
end

function MyGameController:ope_ThrowReady()
    self:hideOperationBtns()

    local throwWait         = 0
    local throwIndex        = 0
    if self._baseGameUtilsInfoManager then
        self._baseGameUtilsInfoManager:setStatus(BaseGameDef.BASEGAME_TS_WAITING_THROW)
        throwWait           = self._baseGameUtilsInfoManager:getThrowWait()
        local fisrtchair    = self._baseGameUtilsInfoManager:getFirstThrow()
        throwIndex          = self:rul_GetDrawIndexByChairNO(fisrtchair)
    end

    local selfInfo = self._baseGameScene:getSelfInfo()
    if selfInfo then
        selfInfo:showWaittingShow(false)
    end

    local clock = self._baseGameScene:getClock()
    if clock then
        clock:start(throwWait)
        clock:moveClockHandTo(throwIndex)

        if self:getMyDrawIndex() == throwIndex then
            self:showOperationBtns()
        end
    end
end

function MyGameController:onTribute()
    local SKHandCardsManager        = self._baseGameScene:getSKHandCardsManager()
    if not SKHandCardsManager then return end
    
    local cardsThrow, cardsCount    = SKHandCardsManager:getMySelectCardIDs()

    local status        = self._baseGameUtilsInfoManager:getStatus()
    if cardsCount ~= 1 or not self:IS_BIT_SET(status, MyGameDef.MYGAME_TS_WAITING_TRIBUTE) then
        return
    end   

    local TributeCard = {}
    TributeCard.chairno = self:getMyChairNO()
    TributeCard.nCardID = cardsThrow[1]

    self._baseGameConnect:sendHagdMsgToServer(MyGameDef.HAGD_GAME_MSG_TRIBUTE, TributeCard)
    
    SKHandCardsManager:maskAllHandCardsEX(true)
end

function MyGameController:ope_CardsTribute(CardsTribute)
    if not self._baseGameUtilsInfoManager then return end

    local status        = self._baseGameUtilsInfoManager:getStatus()
    if not self:IS_BIT_SET(status, MyGameDef.MYGAME_TS_WAITING_TRIBUTE) then
        return
    end

    local drawIndex = self:rul_GetDrawIndexByChairNO(CardsTribute.chairno)
    
    local SKHandCardsManager        = self._baseGameScene:getSKHandCardsManager()
    local SKThownCardsManager       = self._baseGameScene:getSKThrownCardsManager()
    if not SKHandCardsManager or not SKThownCardsManager then
        return
    end

    self:playGamePublicSound("Snd_Throw.mp3")
    SKHandCardsManager:CreateTributeCard(CardsTribute.nCardID, drawIndex)

    local cardIDs = {}
    cardIDs[1] = CardsTribute.nCardID
    if CardsTribute.chairno == self:getMyChairNO() then
        SKHandCardsManager:ope_ThrowCards(drawIndex, cardIDs, 1)
        --SKHandCardsManager:sortHandCards(drawIndex)
        self:hideOperationBtns()
        --SKThownCardsManager:ope_ThrowCards(drawIndex, CardsTribute.nCardID, 1)
        MyGameCardMakerInfo:ope_CardsSub(CardsTribute.chairno, CardsTribute.nCardID) --cardmaker
        self._baseGameScene._cardMakerTool:onRefreshCardMaker()
    else
        SKHandCardsManager:getSKHandCards(drawIndex):cardsCountDecrease(1)
        if DEBUG > 0 then
            printf("ope_CardsTribute")
            dump(self._baseGameUtilsInfoManager._utilsStartInfo)
        end
        for i = 1 , self:getTableChairCount() do
            if self._baseGameUtilsInfoManager._utilsStartInfo and self._baseGameUtilsInfoManager._utilsStartInfo.Tribute[i] and self._baseGameUtilsInfoManager._utilsStartInfo.Tribute[i].winner == self:getMyChairNO() then
                MyGameCardMakerInfo:ope_CardsAdd(self:getMyChairNO(), cardIDs[1]) --cardmaker
                self._baseGameScene._cardMakerTool:onRefreshCardMaker()
                break
            end
        end
        
    end
end

function MyGameController:ope_CardsTributeOver(CardsTributeOver)
    self._opeCardTributeOver = true
    self:hideOperationBtns()

    if not self._baseGameUtilsInfoManager then 
        self._opeCardTributeOver = false
        return 
    end

    local status        = self._baseGameUtilsInfoManager:getStatus()
    if not self:IS_BIT_SET(status, MyGameDef.MYGAME_TS_WAITING_TRIBUTE) then
        self._opeCardTributeOver = false
        return
    end

    local SKHandCardsManager        = self._baseGameScene:getSKHandCardsManager()
    if not SKHandCardsManager then
        self._opeCardTributeOver = false
        return 
    end

    self._tributeIndexTime = 0
    
    self._baseGameUtilsInfoManager._utilsStartInfo.nBanker = CardsTributeOver.nBanker
    self._baseGameUtilsInfoManager:setTributeInfo(CardsTributeOver)

    for i = 1 , self:getTableChairCount() do
        if self._baseGameUtilsInfoManager._utilsStartInfo.Tribute[i].bnTribute > 0 then
            local nindex = self:rul_GetDrawIndexByChairNO(i -1)
            if SKHandCardsManager._tributeCard[1] == nil or 
               SKHandCardsManager._tributeCard[1]:getSKID() ~= self._baseGameUtilsInfoManager._utilsStartInfo.Tribute[i].nCardID then
                self:playGamePublicSound("Snd_Throw.mp3")
                SKHandCardsManager:CreateTributeCard(self._baseGameUtilsInfoManager._utilsStartInfo.Tribute[i].nCardID, nindex)
                
                local cardIDs = {}
                cardIDs[1] = self._baseGameUtilsInfoManager._utilsStartInfo.Tribute[i].nCardID
                if (i - 1) == self:getMyChairNO() then
                    SKHandCardsManager:ope_ThrowCards(nindex,cardIDs , 1)
                    SKHandCardsManager:sortHandCards(nindex)
                    MyGameCardMakerInfo:ope_CardsSub(self:getMyChairNO(), cardIDs[1]) --cardmaker
                    self._baseGameScene._cardMakerTool:onRefreshCardMaker()
                else
                    SKHandCardsManager:getSKHandCards(nindex):cardsCountDecrease(1)

                    if self._baseGameUtilsInfoManager._utilsStartInfo.Tribute[i].winner == self:getMyChairNO() then
                        MyGameCardMakerInfo:ope_CardsAdd(self:getMyChairNO(), cardIDs[1]) --cardmaker
                        self._baseGameScene._cardMakerTool:onRefreshCardMaker()
                    end
                end
            end
        end
    end
    
    self._tributeCardnum = 0
    for i = 1, self:getTableChairCount() do
        if self._baseGameUtilsInfoManager._utilsStartInfo.Tribute[i].bnTribute > 0 then
            local chairno = i
            local nWinChair = self._baseGameUtilsInfoManager._utilsStartInfo.Tribute[i].winner
            local nCardID = self._baseGameUtilsInfoManager._utilsStartInfo.Tribute[i].nCardID

            local card
            for j = 1, 2 do
                if SKHandCardsManager._tributeCard[j] ~= nil and 
                   SKHandCardsManager._tributeCard[j]:getSKID() == self._baseGameUtilsInfoManager._utilsStartInfo.Tribute[i].nCardID then
                    card = SKHandCardsManager._tributeCard[j]
                end
            end
            card.nDestChair = nWinChair
            card:setVisible(true)

            local delay = cc.DelayTime:create(2.0)
            local function callbackMoveTrCard(node, table)
                self:callbackMoveTrCard(node, table)
            end
            self._tributeCardnum = self._tributeCardnum + 1
            local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callbackMoveTrCard, {nWinChair = nWinChair, cardInfo = card }))
            card._SKCardSprite:runAction(sequence)
        end
    end

    local selfInfo = self._baseGameScene:getSelfInfo()
    if selfInfo then
        selfInfo:showTribute(false)
    end
end

function MyGameController:callbackMoveTrCard(card, table)
    local nDestChair = table.nWinChair
    local nindex = self:rul_GetDrawIndexByChairNO(nDestChair)

    local playerManager = self._baseGameScene:getPlayerManager()
    local moveTo
    if nDestChair == self:getMyChairNO() then
        --moveTo = cc.MoveTo:create(1.0,cc.p(640, playerManager._players[nindex]._playerNode:getPositionY()-114/2))
        moveTo = cc.MoveTo:create(1.0, cc.p(display.center.x, playerManager._players[nindex]._playerNode:getPositionY()-114/2))
    else
        moveTo = cc.MoveTo:create(1.0, cc.p(playerManager._players[nindex]._playerNode:getPositionX() - 85/2, playerManager._players[nindex]._playerNode:getPositionY() - 114 /2))
    end

    local function callbackMoveTribute(node, table)
        self:callbackMoveTribute(node, table)
    end

    local sequence = cc.Sequence:create(moveTo, cc.CallFunc:create(callbackMoveTribute, table))
    card:runAction(sequence)
    
    self:playGamePublicSound("Snd_MoveCard.mp3")
end

function MyGameController:callbackMoveTribute(card, table)
    local status        = self._baseGameUtilsInfoManager:getStatus()
    --增加状态判断是为了ios，在进还贡之前切后台，进还贡之后切回来，会停留在等待进还贡的状态
    if self:IS_BIT_SET(status, BaseGameDef.BASEGAME_TS_WAITING_THROW) then
        self._opeCardTributeOver = false
        print("MyGameController:callbackMoveTribute BASEGAME_TS_WAITING_THROW")
        return
    end
    --if not self:IS_BIT_SET(status, MyGameDef.MYGAME_TS_WAITING_TRIBUTE) then
    --    return
    --end 
    -- 因为BASEGAME_WAITING_GET_TABLE_INFO消息会把dwStatus置成20000001，导致上述条件满足，从而进攻动画卡住
    local cardInfo = table.cardInfo
    local SKHandCardsManager        = self._baseGameScene:getSKHandCardsManager()
    if not self._baseGameUtilsInfoManager or not SKHandCardsManager then
        self._opeCardTributeOver = false
        return
    end
    cardInfo:setVisible(false)
 
    local nDestChair = cardInfo.nDestChair
    local nindex = self:rul_GetDrawIndexByChairNO(nDestChair)
    if nindex ~= 1 then
        SKHandCardsManager:getSKHandCards(nindex):cardsCountIncrease(1)
    end

    local playerManager = self._baseGameScene:getPlayerManager()
    if nDestChair == self:getMyChairNO() then
        SKHandCardsManager:getSKHandCards(self:getMyDrawIndex()):cardsCountIncrease(1)
        SKHandCardsManager:ope_AddTributeAndReturnCard(self:getMyDrawIndex(), cardInfo:getSKID())

        local SKOpeBtnManager = self._baseGameScene:getSKOpeBtnManager()
        if SKOpeBtnManager then
            SKOpeBtnManager:setReturnVisible(true)
            SKOpeBtnManager:setReturnEnable(false)
        end
        
        SKHandCardsManager:OPE_MaskCardForTributeAndReturn()
    end

    self._tributeIndexTime = self._tributeIndexTime + 1

    if self._tributeIndexTime < self._tributeCardnum then
        self._opeCardTributeOver = false
        return
    end

    local WaitTime = self._baseGameUtilsInfoManager:getReturnWait()
    self._baseGameUtilsInfoManager:setStatus(MyGameDef.MYGAME_TS_WAITING_RETURN)
    local clock = self._baseGameScene:getClock()
    if clock then
        if 0 < self:getMyDrawIndex() then
            clock:moveClockHandTo(-1)
        end
        if WaitTime then
            clock:start(WaitTime)
        end
    end
    local selfInfo = self._baseGameScene:getSelfInfo()
    if selfInfo then
        selfInfo:showReturn(true)
    end
    self._opeCardTributeOver = false
end

function MyGameController:onReturn()
    local SKHandCardsManager        = self._baseGameScene:getSKHandCardsManager()
    if not SKHandCardsManager then return false end
    local cardsThrow, cardsCount    = SKHandCardsManager:getMySelectCardIDs()

    local status        = self._baseGameUtilsInfoManager:getStatus()
    if cardsCount ~= 1 or not self:IS_BIT_SET(status, MyGameDef.MYGAME_TS_WAITING_RETURN) then
        return
    end

    local ReturnCard = {}
    ReturnCard.chairno = self:getMyChairNO()
    ReturnCard.nCardID = cardsThrow[1]
    ReturnCard.nTributeChair = -1
    ReturnCard.nThrowChair = -1

    self._baseGameConnect:sendHagdMsgToServer(MyGameDef.HAGD_GAME_MSG_RETURN, ReturnCard)
end

function MyGameController:ope_CardsReturn(CardsReturn)

    local status        = self._baseGameUtilsInfoManager:getStatus()
    if not self:IS_BIT_SET(status, MyGameDef.MYGAME_TS_WAITING_RETURN) then
        return
    end
    local drawIndex = self:rul_GetDrawIndexByChairNO(CardsReturn.chairno)
    
    local SKHandCardsManager        = self._baseGameScene:getSKHandCardsManager()
    local SKThownCardsManager       = self._baseGameScene:getSKThrownCardsManager()
    if not self._baseGameUtilsInfoManager or not SKHandCardsManager or not SKThownCardsManager then
        return
    end

    self:playGamePublicSound("Snd_Throw.mp3")
    SKHandCardsManager:CreateReturnCard(CardsReturn.nCardID, drawIndex)

    local cardIDs = {}
    cardIDs[1] = CardsReturn.nCardID
    if CardsReturn.chairno == self:getMyChairNO() then
        SKHandCardsManager:ope_ThrowCards(drawIndex, cardIDs, 1)
        self:hideOperationBtns()
        --SKHandCardsManager:sortHandCards(drawIndex)
        --SKThownCardsManager:ope_ThrowCards(drawIndex, CardsReturn.nCardID, 1)
        MyGameCardMakerInfo:ope_CardsSub(CardsReturn.chairno, CardsReturn.nCardID) --cardmaker
        self._baseGameScene._cardMakerTool:onRefreshCardMaker()
    else
        SKHandCardsManager:getSKHandCards(drawIndex):cardsCountDecrease(1)
        if CardsReturn.nTributeChair == self:getMyChairNO() then
            MyGameCardMakerInfo:ope_CardsAdd(CardsReturn.chairno, CardsReturn.nCardID) --cardmaker
            self._baseGameScene._cardMakerTool:onRefreshCardMaker()
        end
    end

    local card
    for j = 1 , 2 do
        if SKHandCardsManager._returnCard[j] ~= nil 
            and SKHandCardsManager._returnCard[j]:getSKID() == CardsReturn.nCardID then
            card = SKHandCardsManager._returnCard[j]
        end
    end
    card.nDestChair = CardsReturn.nTributeChair
    card:setVisible(true)

    local delay = cc.DelayTime:create(2.0)
    local function callbackMoveReCard(node, table)
        self:callbackMoveReCard(node, table)
    end
    local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callbackMoveReCard, {nDestChair = CardsReturn.nTributeChair, cardInfo = card}))
    card._SKCardSprite:runAction(sequence)
end

function MyGameController:callbackMoveReCard(card, table)
    local nDestChair = table.nDestChair
    local nindex = self:rul_GetDrawIndexByChairNO(nDestChair)

    local playerManager = self._baseGameScene:getPlayerManager()
    local moveTo
    if nDestChair == self:getMyChairNO() then
        --moveTo = cc.MoveTo:create(1.0,cc.p(640, playerManager._players[nindex]._playerNode:getPositionY()-114/2))
        moveTo = cc.MoveTo:create(1.0,cc.p(display.center.x, playerManager._players[nindex]._playerNode:getPositionY()-114/2))
    else
        moveTo = cc.MoveTo:create(1.0,cc.p(playerManager._players[nindex]._playerNode:getPositionX() - 85/2, playerManager._players[nindex]._playerNode:getPositionY() - 114 /2))
    end

    local function callbackMoveReturn(node, table)
        self:callbackMoveReturn(node, table)
    end

    local sequence = cc.Sequence:create(moveTo, cc.CallFunc:create(callbackMoveReturn, table))
    card:runAction(sequence)

    
    self:playGamePublicSound("Snd_MoveCard.mp3")
end

function MyGameController:callbackMoveReturn(card, table)
    local cardInfo = table.cardInfo
    local SKHandCardsManager        = self._baseGameScene:getSKHandCardsManager()
    if not self._baseGameUtilsInfoManager or not SKHandCardsManager then
        return
    end
    cardInfo:setVisible(false)
 
    local nDestChair = cardInfo.nDestChair
    local nindex = self:rul_GetDrawIndexByChairNO(nDestChair)
    if nindex ~= 1 then
        SKHandCardsManager:getSKHandCards(nindex):cardsCountIncrease(1)
    end

    local playerManager = self._baseGameScene:getPlayerManager()
    if nDestChair == self:getMyChairNO() then
        SKHandCardsManager:getSKHandCards(self:getMyDrawIndex()):cardsCountIncrease(1)
        SKHandCardsManager:ope_AddTributeAndReturnCard(self:getMyDrawIndex(), cardInfo:getSKID())
        
        SKHandCardsManager:maskAllHandCardsEX(true)
        --移动完显示界面按钮
    end

    if self._havemovedcard == nil then self._havemovedcard = 0 end
    self._havemovedcard = self._havemovedcard + 1
    --[[local nTribute = 0
    for i = 1, self:getTableChairCount()  do
        if self._baseGameUtilsInfoManager._utilsStartInfo.Tribute[i].bnTribute > 0 then
            nTribute = nTribute + 1
        end
    end--]]
    
    
    if self._havemovedcard == self._baseGameUtilsInfoManager._utilsStartInfo.TributeMoveNum then
        --移除提示      
        self:NTF_MoveOver()
    end
end

function MyGameController:NTF_MoveOver()
    local SKHandCardsManager        = self._baseGameScene:getSKHandCardsManager()
    if not self._baseGameUtilsInfoManager or not SKHandCardsManager then
        return
    end

    SKHandCardsManager:OPE_MaskCardForTributeAndReturn()

    local WaitTime = self._baseGameUtilsInfoManager:getThrowWait()
    self._baseGameUtilsInfoManager:setStatus(BaseGameDef.BASEGAME_TS_WAITING_THROW)
    local clock = self._baseGameScene:getClock()
    if clock then
        if 0 < self:getBankerDrawIndex() then
            clock:moveClockHandTo(self:getBankerDrawIndex())
        end
        if WaitTime then
            clock:start(WaitTime)
        end
    end
    
    local gameTools = self._baseGameScene:getTools()
    if gameTools then
        gameTools:ope_StartPlay()
    end

    if self:getBankerDrawIndex() == self:getMyDrawIndex() then
        self:showOperationBtns()

        self:ope_ShowGameInfo(true)
    end
    --隐藏掉标记
    local selfInfo = self._baseGameScene:getSelfInfo()
    if selfInfo then
        selfInfo:showReturn(false)
    end

    self._baseGameScene:doSomethingForVerticalCard() -- 为了覆盖还贡结束，gameTools:ope_StartPlay里面把炸弹排序按钮又显示出来的问题
end

function MyGameController:ope_ShowFight(chairno, nCardID1, nCardID2)
    if nCardID1 == -1 then
        return
    end
    local count = 1
    if nCardID2 ~= -1 then
        count = 2
    end

    local SKHandCardsManager        = self._baseGameScene:getSKHandCardsManager()
    local SKThownCardsManager       = self._baseGameScene:getSKThrownCardsManager()
    if not self._baseGameUtilsInfoManager or not SKHandCardsManager or not SKThownCardsManager then
        return
    end

    SKHandCardsManager:CreateFightCard(nCardID1, nCardID2, self:rul_GetDrawIndexByChairNO(chairno))

    local card = nil
    if nCardID1 >=0 then
        for j=1,2 do
            if SKHandCardsManager._FightCard[j] ~= nil and 
               SKHandCardsManager._FightCard[j]:getSKID() == nCardID1 then
                card=SKHandCardsManager._FightCard[j]
            end
        end    

        card:setVisible(true)

        local delay = cc.DelayTime:create(3.0)
        local function callbackMoveFight(node, table)
            self:callbackMoveFight(node, table)
        end
        local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callbackMoveFight, {cardInfo = card}))
        card._SKCardSprite:runAction(sequence)
    end
    if nCardID2 >0 then
        for j=1,2 do
            if SKHandCardsManager._FightCard[j] ~= nil 
                and SKHandCardsManager._FightCard[j]:getSKID() == nCardID2 then
                card=SKHandCardsManager._FightCard[j]
            end
        end    

        card:setVisible(true)

        local delay = cc.DelayTime:create(3.0)
        local function callbackMoveFight(node, table)
            self:callbackMoveFight(node, table)
        end
        local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callbackMoveFight, {cardInfo = card}))
        card._SKCardSprite:runAction(sequence)
    end
end

function MyGameController:callbackMoveFight(card, table)
    local cardInfo = table.cardInfo
    cardInfo:setVisible(false)
    --隐藏掉名次标记

    local WaitTime = self._baseGameUtilsInfoManager:getThrowWait()
    self._baseGameUtilsInfoManager:setStatus(BaseGameDef.BASEGAME_TS_WAITING_THROW)
    local clock = self._baseGameScene:getClock()
    if clock then
        if 0 < self:getBankerDrawIndex() then
            clock:moveClockHandTo(self:getBankerDrawIndex())
        end
        if WaitTime then
            clock:start(WaitTime)
        end
    end

    local gameTools = self._baseGameScene:getTools()
    if gameTools then
        gameTools:ope_StartPlay()
    end

    if self:getBankerDrawIndex() == self:getMyDrawIndex() then
        self:showOperationBtns()

        self:ope_ShowGameInfo(true)     
    end
    self._baseGameScene:doSomethingForVerticalCard()    -- 抗贡的情况，需要隐藏炸弹理牌
end

function MyGameController:onShown(bShow)
    local clock = self._baseGameScene:getClock()
    if clock then
        clock:setVisible(false)
    end

    self:hideOperationBtns()

    self._baseGameConnect:reqShowCards(bShow)

    local selfInfo = self._baseGameScene:getSelfInfo()
    if selfInfo then
        selfInfo:showWaittingShow(true)
    end
end

function MyGameController:onGameStart(data)    
    if PUBLIC_INTERFACE.IsStartAsTeam2V2() then
        self._onGameStart = true
        my.scheduleOnce(function()
            self._onGameStart = false
        end, 3.0)
        if self._baseGameScene._resultLayer ~= nil then
            self:onCloseResultLayerEx()
        end

        if TimerManager and TimerManager._timers and TimerManager._timers["Timer_GameScene_DelayedNormalGameResultOnGameWin"] then
            self:onRestart()
            self.bGameToRestart = false
            TimerManager:stopTimer("Timer_GameScene_DelayedNormalGameResultOnGameWin")
        end
    end

    print("MyGameController:onGameStart")
    self:hideBannerAdvert()
    
    self._canReturnChartered = false

    self._playerInfo = {}
    local playerInfoManager = self:getPlayerInfoManager()
    if playerInfoManager then
        for i= 1,self:getTableChairCount() do
            local info = playerInfoManager:getPlayerInfo(i)
            self._playerInfo[i] = clone(info)
        end
    end

    self._selfChairNO = self:getMyChairNO()

    self._havemovedcard = 0
    self._baseGameUtilsInfoManager._utilsStartInfo.TributeMoveNum = 0
    self._baseGameUtilsInfoManager._utilsStartInfo.GameStarCards = true
       
    self._baseGameUtilsInfoManager:setWaitChair(-1)
--    MyGameController.super.onGameStart(self, data)

    for i = 0 , 3 do
        for j = 1, 4 do
            self._baseGameUtilsInfoManager:getPlayInfoByChairNo(i).nBombCount[j] = 0
        end
    end

    for i = 1, 4 do
        local playerManager = self._baseGameScene:getPlayerManager()
        if playerManager then
            playerManager:FreshPlace(drawIndex, 0)
        end
    end  
    
    self:gameRun()

    if self:isArenaPlayer() then 
        local arenaInfoManager = self:getArenaInfoManager()
        arenaInfoManager:addBout()
        local bout = arenaInfoManager:getBout()
        local arenaInfo = self._baseGameScene:getArenaInfo()
        arenaInfo:runStartAction(bout)
        self:showArenaInfo()
    end

    if self._dispatch then
        self._dispatch:setStartMatch(false)
    end
    self:onGameStartForCharteredRoom(data)

    self:playGamePublicSound("Snd_ArrageTable.mp3")

    self:showWaitArrangeTable(false)

    local playerManager = self._baseGameScene:getPlayerManager()
    if playerManager then
        playerManager:onGameStart()
    end

    local gameTools = self._baseGameScene:getTools()
    if gameTools then
        gameTools:onGameStart()
    end

    local gameStart = nil
    if self._baseGameData then
        gameStart = self._baseGameData:getGameStartInfo(data)
    end

    if gameStart then
        if self._baseGameUtilsInfoManager then
            self._baseGameUtilsInfoManager:setStartInfo(gameStart)
            self._baseGameUtilsInfoManager:clearTableInfo()
        end
    end

    local gameInfo = self._baseGameScene:getGameInfo()
    if gameInfo then
        gameInfo:setBaseScore(tostring(self:getBaseScore()))
    end

    if self._baseGameUtilsInfoManager then
        local SKHandCardsManager = self._baseGameScene:getSKHandCardsManager()
        if SKHandCardsManager then
            local cardsCounts = self._baseGameUtilsInfoManager:getCardsCount()

            for i = 1, self:getTableChairCount() do
                local drawIndex = self:rul_GetDrawIndexByChairNO(i - 1)
                if 0 < drawIndex then
                    SKHandCardsManager:setHandCardsCount(drawIndex, cardsCounts[i])
                    if drawIndex == self:getMyDrawIndex() then
                        local chairCards = self._baseGameUtilsInfoManager:getSelfStartCards()
                        SKHandCardsManager:setSelfHandCards(chairCards) 
                        SKHandCardsManager:hideSelfHandCards()      --暂时隐藏
                        MyGameCardMakerInfo:resert()
                        MyGameCardMakerInfo:onPutInMyselfCards(chairCards, i - 1)  --cardMaker
                        self._baseGameScene._cardMakerTool:onRefreshCardMaker()  --cardMaker
                    end
                end
            end
        end
    end

    if gameStart then
        self:ope_GameInfoShow(true)
        self:ope_GameStart()
    end

    self._baseGameScene:showRankCard(self._baseGameUtilsInfoManager._utilsStartInfo.nRank[self._baseGameUtilsInfoManager._utilsStartInfo.nRanker+1])
    self._baseGameScene:setMyRuleBtnVisible(false)
    if gameStart.nBoutCount == 1 then --只在打第一局时显示
        self._baseGameScene:GameStartTip()
    end
    self:stopCheckOffline()

    self:stopJumpOtherRoomSchedule()

    if self._baseGameScene._JumpRoomPrompt then
        self._baseGameScene._JumpRoomPrompt:removePrompt()
        self._baseGameScene._JumpRoomPrompt = nil
    end

    if self._ExchangeQuitPrompt then    -- 开局的时候，如果有兑换券弹窗，关闭它
        self._ExchangeQuitPrompt:onClose() -- 释放定时器，关闭窗口等
        self._ExchangeQuitPrompt = nil
    end

    if self._baseGameConnect then
        self._baseGameConnect:sendSDKInfo()
    end

    --检查其他玩家的定时赛积分，不足下限的就是重新报名的玩家，重新设置值
    if PublicInterFace.IsStartAsTimingGame() and self._baseGamePlayerInfoManager then
        local config = TimingGameModel:getConfig()
        if config then
            for i = 1, self:getTableChairCount() do
                if self:getMyDrawIndex() ~= drawIndex then
                    local score = self._baseGamePlayerInfoManager:getPlayerTimingScore(drawIndex)
                    if type(score) == "number" 
                    and score < config.MinScore then
                        self._baseGamePlayerInfoManager:setPlayerTimingScore(drawIndex, config.InitialScore)
                        local playerManager = self._baseGameScene:getPlayerManager()
                        if playerManager then
                            playerManager:setTimingScore(drawIndex, config.InitialScore)
                        end
                    end
                end
            end
        end
    end

    if self:isNeedDeposit() or PublicInterFace.IsStartAsTimingGame() or PUBLIC_INTERFACE.IsStartAsAnchorMatchGame() then
        --tools cardmaker
        self._baseGameScene._cardMakerTool:updateCardMakerCount()
        self._baseGameScene._cardMakerTool:onShowCardMakerRank()
        self._baseGameScene._cardMakerTool:OnShowCardMakerInfo(true)
    end

    --self:ShowExpressionGuide()
end

function MyGameController:ope_GameStart()
    MyGameController.super.ope_GameStart(self)
  
    if self._baseGameScene then
        self._baseGameScene:startEnterRedBagAct()
    end
end

function MyGameController:GameStartDataOut(data)
    self._canReturnChartered = false

    self._playerInfo = {}
    local playerInfoManager = self:getPlayerInfoManager()
    if playerInfoManager then
        for i= 1,self:getTableChairCount() do
            local info = playerInfoManager:getPlayerInfo(i)
            self._playerInfo[i] = clone(info)
        end
    end
    self._selfChairNO = self:getMyChairNO()

    self:gameRun()

    self:onGameStartForCharteredRoom(data)

    self:stopCheckOffline()
  
    self._havemovedcard = 0   
    self._baseGameUtilsInfoManager._utilsStartInfo.TributeMoveNum = 0

    local gameStart = nil
    if self._baseGameData then
        gameStart = self._baseGameData:getGameStartInfo(data)
    end

    if gameStart then
        if self._baseGameUtilsInfoManager then
            self._baseGameUtilsInfoManager:setStartInfo(gameStart)
            self._baseGameUtilsInfoManager:clearTableInfo()
        end
    end
    self._baseGameScene:setMyRuleBtnVisible(false)

    self:stopJumpOtherRoomSchedule()
end

function MyGameController:ope_StartPlay()
    if not PUBLIC_INTERFACE.IsStartAsAnchorMatchGame() then
        self:OPE_FreshBomgRecord()
    end
    self._baseGameScene:hideRankCard()

    local drawIndex = self:getMyDrawIndex()
    local WaitTime = 0
    if self._baseGameUtilsInfoManager then
        drawIndex = self:getBankerDrawIndex()
        WaitTime = self._baseGameUtilsInfoManager:getThrowWait()

        self._baseGameUtilsInfoManager:setStatus(BaseGameDef.BASEGAME_TS_WAITING_THROW)
    end
   
    local SKHandCardsManager = self._baseGameScene:getSKHandCardsManager()
    
    local clock = self._baseGameScene:getClock()

    if SKHandCardsManager then
        SKHandCardsManager:setEnableTouch(true)
    end

    local playerManager = self._baseGameScene:getPlayerManager()
    if playerManager then
        playerManager:onStartPlayToShrinkAnimation()
        playerManager:onStartPlayToShowLevelAnimation()
    end

    if self._baseGameUtilsInfoManager then
        if self._baseGameUtilsInfoManager:getBoutCount() ~= 1 and self._baseGameUtilsInfoManager._utilsStartInfo.bnResetGame == 0 then
            local bnFight = false
            local nTribute = 0
            for i = 1, MyGameDef.MY_TOTAL_PLAYERS do
                if self._baseGameUtilsInfoManager._utilsStartInfo.Tribute[i].bnTribute ~= 0 then
                    nTribute = nTribute + 1
                    if self._baseGameUtilsInfoManager._utilsStartInfo.Tribute[i].bnFight == 0 then --没有抗贡
                        if self:getMyChairNO() == (i-1) --[[and self._baseGameUtilsInfoManager.getLookOn() == 0--]] then
                        
                           self._baseGameUtilsInfoManager:setStatus(MyGameDef.MYGAME_TS_WAITING_TRIBUTE)
                           WaitTime = self._baseGameUtilsInfoManager:getTributeWait()
                           --SKHandCardsManager
                           local SKOpeBtnManager = self._baseGameScene:getSKOpeBtnManager()
                           if SKOpeBtnManager then
                                SKOpeBtnManager:setTributeVisible(true)
                                SKOpeBtnManager:setTributeEnable(false)
                           end
                           SKHandCardsManager:OPE_MaskCardForTributeAndReturn()
                        end
                    else--抗贡
                        bnFight = true
                        self:ope_ShowFight(i-1, self._baseGameUtilsInfoManager._utilsStartInfo.Tribute[i].nFightID[1], self._baseGameUtilsInfoManager._utilsStartInfo.Tribute[i].nFightID[2])
                        clock:setVisible(false)
                    end
                end
            end
            
            if not bnFight then--没有抗贡
                WaitTime = self._baseGameUtilsInfoManager:getTributeWait()
                self._baseGameUtilsInfoManager:setStatus(MyGameDef.MYGAME_TS_WAITING_TRIBUTE)
                if clock then
                    if 0 < self:getMyDrawIndex() then
                        clock:moveClockHandTo(-1)
                    end
                    if WaitTime then
                        clock:start(WaitTime)
                    end
                end

                local selfInfo = self._baseGameScene:getSelfInfo()
                if selfInfo then
                    selfInfo:showTribute(true)
                end
            else 
                self._baseGameScene:showFightEffect()
            end

            self:ResetArrageButton()
        else
            self._baseGameUtilsInfoManager:setStatus(BaseGameDef.BASEGAME_TS_WAITING_THROW)
            WaitTime = self._baseGameUtilsInfoManager:getThrowWait()

             --没有进贡，等待出牌
            if clock then
                if 0 < drawIndex then
                    clock:moveClockHandTo(drawIndex)
                end
                if WaitTime then
                    clock:start(WaitTime)
                end
            end
           
            if drawIndex == self:getMyDrawIndex() then
                self:showOperationBtns()
            end

            self:ope_ShowGameInfo(true)

            local gameTools = self._baseGameScene:getTools()
            if gameTools then
                gameTools:ope_StartPlay()
            end
            --self:showBanker(drawIndex)
        end             
    end

    self._baseGameUtilsInfoManager._utilsStartInfo.GameStarCards = false

    self._baseGameScene:doSomethingForVerticalCard()    -- 发完牌开局
end

function MyGameController:ope_ThrowCards(cardsThrow)
    if not cardsThrow then return end

    local SKHandCardsManager        = self._baseGameScene:getSKHandCardsManager()
    local SKThownCardsManager       = self._baseGameScene:getSKThrownCardsManager()
    local MyPlayerManager           = self._baseGameScene:getMyPlayerManager()
    if not self._baseGameUtilsInfoManager or not SKHandCardsManager or not SKThownCardsManager then
        return
    end

    local drawIndex = self:rul_GetDrawIndexByChairNO(cardsThrow.nChairNO)
    if drawIndex == self:getMyDrawIndex() then
        SKHandCardsManager:ope_UnselectSelfCards()
    end

    --倒计时结束关闭新手引导
    if self._guideStatus ~= MyGameDef.NEWUSERGUIDE_NOT_OPEN then
        local nGuideBout = self._baseGameUtilsInfoManager._utilsStartInfo.nGuideBout
        if nGuideBout == 1 and self._guideStatus ~= MyGameDef.NEWUSERGUIDE_BOUTONE_FINISHED then
            self:playNewUserGuideBoutOneFinished()
        elseif nGuideBout == 2 and self._guideSatus ~= MyGameDef.NEWUSERGUIDE_BOUTTWO_FINISHED then
            self:playNewUserGuideBoutTwoFinished()
        end
    end

    if not PUBLIC_INTERFACE.IsStartAsAnchorMatchGame() then
        self:OPE_AddBomb(cardsThrow)
    end
    
    self:OPE_HideNoBiggerTip()

    self._baseGameUtilsInfoManager:setWaitUniteInfo(cardsThrow)
    self._baseGameUtilsInfoManager:setWaitChair(cardsThrow.nChairNO)

    self:playCardsEffect(cardsThrow)
    self:ope_showThrowAnimation(cardsThrow)

    if cardsThrow.nWinPlayce ~= 0 then
        self:RobScoreStart(cardsThrow.nWinPlayce, cardsThrow.nChairNO)
        local playerManager = self._baseGameScene:getPlayerManager()
        if playerManager then
            playerManager:FreshPlace(drawIndex, cardsThrow.nWinPlayce)
        end
    end

    SKHandCardsManager:ope_ThrowCards(drawIndex, cardsThrow.nCardIDs, cardsThrow.nCardsCount)
--    SKHandCardsManager:sortHandCards(drawIndex) --ope_ThrowCards已经有排序。。  
    SKHandCardsManager:setFirstHand(0)
    if drawIndex ~= self:getMyDrawIndex() then
        SKHandCardsManager:moveHandCards(drawIndex, false)

        --自己牌已出完，更新玩家手牌
        if SKHandCardsManager:getSKHandCards(self:getMyDrawIndex()):getHandCardsCount() <= 0 then
            if drawIndex == self:getOppositeIndex() then
                SKHandCardsManager:updataFriendCards(cardsThrow.nCardIDs, cardsThrow.nCardsCount)                
            end
        end
    else  --自己手上没牌了
        if SKHandCardsManager:getSKHandCards(self:getMyDrawIndex()):getHandCardsCount() <= 0 then
            self._baseGameScene:setMyRuleBtnVisible(true)
        end
    end

    SKThownCardsManager:ope_ThrowCards(drawIndex, cardsThrow.nCardIDs, cardsThrow.nCardsCount, cardsThrow.dwCardType)

    local nextIndex = self:rul_GetDrawIndexByChairNO(cardsThrow.nNextChair)

    if cardsThrow.nChairNO ~= cardsThrow.nNextChair then   --PS:惯蛋最后手牌下一个玩家会是自己 不移除牌
        SKThownCardsManager:moveThrow(nextIndex)
    end   

    --提示警报
    local SKHandCard = SKHandCardsManager:getSKHandCards(drawIndex)
    local cardsCount = SKHandCard:getHandCardsCount()
    if cardsCount > 0 and cardsCount <= 10 then
        MyPlayerManager:tipJingBao(drawIndex)
    end
    -- 判断自动过牌
    self._cardStatus = MyGameController._CARD_STATUS.NORMAL
    if nextIndex == self:getMyDrawIndex() and self:isGameRunning() then
        self:autoPass()
    end

    local clock = self._baseGameScene:getClock()
    local throwWait =  cardsThrow.nWaitTime--self._baseGameUtilsInfoManager:getThrowWait()

    -- 若触发自动过牌则不显示时钟
    if self._cardStatus and self._cardStatus == MyGameController._CARD_STATUS.AUTO_PASS then
        clock:setVisible(false)
    elseif self._cardStatus and self._cardStatus == MyGameController._CARD_STATUS.NO_BIGGER then -- 若显示要不起始终倒计时变为10秒
        clock:setVisible(true)
        throwWait = cc.exports._gameJsonConfig.NoBiggerWaitTime or MyGameController.NoBiggerWaitTime --要不起暂定
    else
        clock:setVisible(true)
    end

    if clock then
        clock:start(throwWait)
        clock:moveClockHandTo(nextIndex)
    end

    if nextIndex == self:getMyDrawIndex() and self:isGameRunning() then
        self:OPE_ShowNoBiggerTip()
        -- 若当前没有触发自动过牌和要不起按钮则显示操作按钮（这里在ope_ThrowCards判断：出牌消息后）
        if (not self._cardStatus) or self._cardStatus == MyGameController._CARD_STATUS.NORMAL then
            self:showOperationBtns()
        end
              local cardIDs, cardsCount = SKHandCardsManager:getHandCardIDs(nextIndex)
        if drawIndex ~= self:getMyDrawIndex() and cardsCount < 3 and cardsCount < cardsThrow.nCardsCount then
            --self:onPassCard()
        end
    else
        self:hideOperationBtns()        
    end

    local score = self:getScoresGain(cardsThrow.nCardIDs, cardsThrow.nCardsCount)
    if 0 < score then
        self:addCurrentScore(score)
    end

    local flower = self:getFlowersGain(cardsThrow.nCardIDs, cardsThrow.nCardsCount)
    if 0 < score then
        self:addPlayerFlower(drawIndex,flower)
    end
  
    self:ResetArrageButton()

    --cardMaker
    if drawIndex ~= self:getMyDrawIndex() then
        MyGameCardMakerInfo:onThrowCards(cardsThrow.nCardIDs, cardsThrow.nChairNO)
        self._baseGameScene._cardMakerTool:onRefreshCardMaker()
    end

    self:onRefreshTableInfoWhenGameStartLost()

    -- 广告模块 start
    print("AdvertModel:MyGameController:ope_ThrowCards")
    print("self._hasShowBanner: ", self._hasShowBanner)
    if self:isShowBanner() and not self._hasShowBanner then
        AdvertModel:showBannerAdvert()
        self._hasShowBanner = true
    end
    -- 广告模块 end
end


--[[
    重载：
        1. 小于4张，自动过牌
        2. 不能要牌时只显示“要不起”
]]
function MyGameController:autoPass()
    print("MyGameController:autoPass()")
    
    self._cardStatus = MyGameController._CARD_STATUS.NORMAL
    local status = self._baseGameUtilsInfoManager:getStatus()
    repeat
        local bIsWaitingThrow = self:IS_BIT_SET(status, BaseGameDef.BASEGAME_TS_WAITING_THROW)
        if not bIsWaitingThrow then break end       -- 确认出牌状态

        local SKHandCardsManager = self._baseGameScene:getSKHandCardsManager()
        if not SKHandCardsManager then break end    -- 确认不为nil

        local bFirstHand = SKHandCardsManager:isFirstHand()
        if bFirstHand then break end                -- 确认不是先手

        local bHaveNoBigger = SKHandCardsManager:havenoBigger()
        if not bHaveNoBigger then break end         -- 确认不能压牌

        local myDrawIndex = self:getMyDrawIndex()
        local _, cardsCount = SKHandCardsManager:getHandCardIDs(myDrawIndex)
        local cardsWaiting = self._baseGameUtilsInfoManager:getWaitUniteInfo()
        local waitChairNo = self._baseGameUtilsInfoManager:getWaitChair()
        local throwIndex = self:rul_GetDrawIndexByChairNO(waitChairNo)

        if throwIndex == myDrawIndex then break end -- 确认上一手牌不是自己出的
        
        print("is waiting throw && not first hand && have no bigger && throwindex ~= mydrawindex")

        if cardsCount < 4 then
            -- 上一手牌是否有大王
            local isWaitingCardsHasBigKing = false
            for i = 1, cardsWaiting.nCardsCount do
                if MyCalculator:getCardIndex(cardsWaiting.nCardIDs[i]) == 15 then
                    isWaitingCardsHasBigKing = true
                    break
                end
            end
            -- 上一手牌数量比当前手牌数量多，或者上一手牌有大王，则自动过牌
            if cardsCount < cardsWaiting.nCardsCount or isWaitingCardsHasBigKing then
                self._autoPassID = my.scheduleOnce(function()
                    if self:isInGameScene() == false then return end
                    self:onPassCard()
                    self._autoPassID = nil
                end, 0.5) -- 稍加延时
                self._cardStatus = MyGameController._CARD_STATUS.AUTO_PASS -- 自动过牌状态
            end
        end

        -- 若要不起，且没有自动过牌时，显示“要不起”按钮
        if self._cardStatus and self._cardStatus == MyGameController._CARD_STATUS.NORMAL then
            self:showNoBiggerBtn()
            self._cardStatus = MyGameController._CARD_STATUS.NO_BIGGER
        end
    until(true)
end

function MyGameController:onPressNoBigger()
    self:onPassCard()
end

function MyGameController:showNoBiggerBtn()
    print("show no bigger button")
    local SKOpeBtnManager = self._baseGameScene:getSKOpeBtnManager()
    if SKOpeBtnManager then
        SKOpeBtnManager:showNoBiggerBtn()
    end
end

function MyGameController:onCardsInfo(data)
    local cardsInfo = nil
    if self._baseGameData then
        cardsInfo = self._baseGameData:getCardsInfo(data)
    end

    if not cardsInfo or 0 == cardsInfo.nCardsCount then return end

    local SKHandCardsManager = self._baseGameScene:getSKHandCardsManager()
    if not SKHandCardsManager then return end

    local drawIndex = self:rul_GetDrawIndexByChairNO(cardsInfo.nChairNO)
    if drawIndex == self:getOppositeIndex() then       
        self:onCancelRobot()
      
        local gameTools = self._baseGameScene:getTools()
        if gameTools then
            gameTools:onHideOtherButton()   -- 隐藏炸弹、花色排序等按钮
        end

        --MyGameController._sortFlag = SKGameDef.SORT_CARD_BY_ORDER

        SKHandCardsManager:showFriendCards(cardsInfo.nCardIDs, cardsInfo.nCardsCount)

        local selfInfo = self._baseGameScene:getSelfInfo()
        if selfInfo then
            selfInfo:showDuiJiaShouPai(true)
            self._baseGameScene:setSortTypeBtnEnabled(false)
            if true == self._baseGameScene:isVerticalCardsMode() then
                -- 显示对家手牌的时候，强制换成横排( 针对头游倒计时0瞬间切换问题)
                self._baseGameScene:onClickSortTypeBtn()
            end
        end
    end
    --[[
    if drawIndex ~= self:getMyDrawIndex() then
        SKHandCardsManager:setHandCardsCount(drawIndex, cardsInfo.nCardsCount)
        SKHandCardsManager:setHandCards(drawIndex, cardsInfo.nCardIDs)
        SKHandCardsManager:sortHandCards(drawIndex)
    end--]]

    --[[if self._baseGameUtilsInfoManager then
        local nFriendCard = self._baseGameUtilsInfoManager:getFriendCard()
        if nFriendCard and nFriendCard ~= -1 and MyCalculator:xygHaveCard(cardsInfo.nCardIDs, cardsInfo.nCardsCount, nFriendCard) then
            local playerManager = self._baseGameScene:getPlayerManager()
            if playerManager then
                local drawIndex = self:rul_GetDrawIndexByChairNO(cardsInfo.nChairNO)
                if drawIndex > 0 then
                    playerManager:showHelper(drawIndex)
                end
            end
        end
    end--]]
end

function MyGameController:ope_PassCards(cardsPass)
    --MyGameController.super.ope_PassCards(self, cardsPass)

    if not cardsPass then return end

    local SKHandCardsManager        = self._baseGameScene:getSKHandCardsManager()
    local SKThownCardsManager       = self._baseGameScene:getSKThrownCardsManager()
    if not self._baseGameUtilsInfoManager or not SKHandCardsManager or not SKThownCardsManager then
        return
    end

    self:ResetArrageButton()

    self:playPassEffect(cardsPass)
    self:OPE_HideNoBiggerTip()

    local drawIndex = self:rul_GetDrawIndexByChairNO(cardsPass.nChairNO)

    SKHandCardsManager:setFirstHand(cardsPass.bNextFirst)
    SKHandCardsManager:moveHandCards(drawIndex, false)

    local waitChairNo = self._baseGameUtilsInfoManager:getWaitChair()
    local nextIndex = self:rul_GetDrawIndexByChairNO(cardsPass.nNextChair)
   
    if 1 == cardsPass.bNextFirst then
        SKThownCardsManager:moveAllThrow()
        self._baseGameUtilsInfoManager:setWaitChair(-1)
    else
        SKThownCardsManager:moveThrow(nextIndex)
    end
    
    if nextIndex ~= drawIndex then      
        SKThownCardsManager:showPassTip(drawIndex)
    end
    
    -- 判断自动过牌
    self._cardStatus = MyGameController._CARD_STATUS.NORMAL
    if nextIndex == self:getMyDrawIndex() then
        self:autoPass()
    end

    local clock = self._baseGameScene:getClock()
    local throwWait =  cardsPass.nWaitTime--self._baseGameUtilsInfoManager:getThrowWait()

    -- 若触发自动过牌则不显示时钟
    if self._cardStatus and self._cardStatus == MyGameController._CARD_STATUS.AUTO_PASS then
        clock:setVisible(false)
    elseif self._cardStatus and self._cardStatus == MyGameController._CARD_STATUS.NO_BIGGER then -- 若显示要不起始终倒计时变为10秒
        clock:setVisible(true)
        throwWait = cc.exports._gameJsonConfig.NoBiggerWaitTime or MyGameController.NoBiggerWaitTime
    else
        clock:setVisible(true)
    end

    if clock then
        clock:start(throwWait)
        clock:moveClockHandTo(nextIndex)
    end

    if nextIndex == self:getMyDrawIndex() then
        self:OPE_ShowNoBiggerTip()
        -- 若当前没有触发自动过牌和要不起按钮则显示操作按钮（这里在ope_PassCards判断：过牌消息后）
        if (not self._cardStatus) or self._cardStatus == MyGameController._CARD_STATUS.NORMAL then
            self:showOperationBtns()
        end
        local cardIDs, cardsCount = SKHandCardsManager:getHandCardIDs(nextIndex)
        local cardsWaiting = self._baseGameUtilsInfoManager:getWaitUniteInfo()
        local throwIndex = self:rul_GetDrawIndexByChairNO(waitChairNo)
        if throwIndex ~= self:getMyDrawIndex() and cardsCount < 3 and cardsCount < cardsWaiting.nCardsCount then
            --self:onPassCard() --这个判断修改。。。不直接过牌
        end
    else
        self:hideOperationBtns()
    end
end

function MyGameController:onThrowCard(cardIDs, cardsLen)
    --在出牌时记录理牌的情况
    self:LogSortCard()
    --理牌埋点end
    if not cardIDs or not cardsLen or cardsLen == 0 then return end

    local SKHandCardsManager        = self._baseGameScene:getSKHandCardsManager()
    if not self._baseGameUtilsInfoManager or not SKHandCardsManager or not self._baseGameConnect then
        return
    end

    self:hideOperationBtns()

    local unitDetails = MyCalculator:initCardUnite()
    if not MyCalculator:getUniteDetails(cardIDs, cardsLen, unitDetails, MyGameDef.MY_CARD_UNITE_TYPE_TOTAL) then
        return
    end
    if SKHandCardsManager:isFirstHand() then
        MyCalculator:getBestUnitType1(unitDetails)
    else
        MyCalculator:getBestUnitType2(self._baseGameUtilsInfoManager:getWaitUniteInfo(), unitDetails)
    end

--    --出牌时让理牌中提示可以从头开始找
    SKHandCardsManager:resetRemind()
    self._baseGameConnect:reqThrowCards(unitDetails.uniteType[1],self._bAutoPlay)
end

function MyGameController:isEnableThrow(bFirstHand, cardsThrow, cardsCount, cardsWaiting)
    if GamePublicInterface and GamePublicInterface:IS_FRAME_1() then
        return self:isEnableThrow_1(bFirstHand, cardsThrow, cardsCount, cardsWaiting)
    end

    if not cardsCount or not cardsThrow or 0 == cardsCount then return false end

    local throwDetails   = MyCalculator:initCardUnite()
    if not MyCalculator:getUniteDetails(cardsThrow, cardsCount, throwDetails, SKGameDef.SK_CARD_UNITE_TYPE_TOTAL) then
        return false
    end

    if bFirstHand then return true end     --第一手就可以直接出了

    if MyCalculator:getBestUnitType2(cardsWaiting, throwDetails) then
        return true
    else
        return false
    end
end

function MyGameController:onGainsBonus(data)
    local gainsInfo = nil
    if self._baseGameData then
        gainsInfo = self._baseGameData:getGainsInfo(data)
    end

    for i = 1, self:getTableChairCount() do
        local drawIndex = self:rul_GetDrawIndexByChairNO(i - 1)
        local bonus     = gainsInfo.nBonus[i]
        if bonus then
            self:setPlayerFlower(drawIndex, bonus)
        end
    end
end

function MyGameController:onSystemMsg(data)
    local systemMsg = nil
    if self._baseGameData then
        systemMsg = self._baseGameData:getSystemMsg(data)
    end

    --TODO
end

function MyGameController:onGetTaskData(data)
    --local taskData = nil
    local taskList = require('src.app.plugins.MyTaskPlugin.TaskListConfig')
    if self._baseGameData then
        local taskData = self._baseGameData:getTaskData(data)
        
        local index
        if cc.exports.LaunchMode["PLATFORM"] ~= MCAgent:getInstance():getLaunchMode() then
            index = 1
        else
            index = 2
        end
          
        for i=index, taskData.nTaskCount do
            if taskData[string.format("task%dFinished", i)] == 0 and 
            taskData[string.format("nTask%dCount", i)] >= taskList[string.format("task%dNum", i)] then
                self:showTaskAnimation(true)
                break
            end
        end
    end

    --TODO
end

function MyGameController:showTaskAnimation(bShow)
    self._baseGameScene:showTaskAnimation(bShow)
end


function MyGameController:onClockStop()
    if self._baseGameConnect then
        self._baseGameConnect:sendMsgToServer(SKGameDef.SK_SYSMSG_GAME_CLOCK_STOP)
    end
end

function MyGameController:onGetTableInfo(data)
    print("22222222222222")
    self:stopGetTableDataResponseTimer()

    self:parseGameTableInfoData(data)

    self:setResume(false)
    if device.platform ~= "windows" then   
        local SKHandCardsManager = self._baseGameScene:getSKHandCardsManager() 
        local myhandCards = SKHandCardsManager:getSKHandCards(self:getMyDrawIndex())
        local arrageCardsGroup = {}
        local arrageCardsGroup, nGroupCount = myhandCards:getArrageCardIDsAllGroup()    -- 取出之前理的所有牌，按组划分
    
        if PUBLIC_INTERFACE.IsStartAsTeam2V2() then
            if self._baseGameScene._resultLayer ~= nil then
                self:onCloseResultLayerEx()
            end
        end

        self:onDXXW(true)

        if not self._guideStatus
            or self._guideStatus == MyGameDef.NEWUSERGUIDE_NOT_OPEN
            or self._guideStatus == MyGameDef.NEWUSERGUIDE_BOUTONE_FINISHED
            or self._guideStatus == MyGameDef.NEWUSERGUIDE_BOUTTWO_FINISHED then
            if nGroupCount > 0 then
                for g=nGroupCount, 1, -1 do -- 逐个组重新设置理牌，因为在onDXXW中，会clearGameTable引起理牌呗撤销
                    SKHandCardsManager:selectMyCardsByIDs(arrageCardsGroup[g], table.maxn(arrageCardsGroup[g]))
                    SKHandCardsManager:OnArrageHandCard()
                end
            end
        end
    else
        if self._baseGameConnect then
            self._baseGameConnect:sendMsgToServer(SKGameDef.SK_SYSMSG_PLAYER_ONLINE)
        end
    end  
    --self:onCancelRobot()
end

function MyGameController:onDXXW(IsReturnBack)
    --第一局屏蔽跑马灯
    local BroadcastModel = mymodel("hallext.BroadcastModel"):getInstance()
    local user = mymodel("UserModel"):getInstance()
    if user.nBout and user.nBout == 0 then
        BroadcastModel:stopInsertMessage()
    end

    self:readLogCache()
    if(self._dispatch)then      
        local data = {}
        local no = self:getTableChairCount()
        for i=1,no do
            local info = self._baseGamePlayerInfoManager:getPlayerInfo(i)
            if(info==nil)then
                break
            else
                table.insert(data,info)
            end
        end
        self._dispatch:onDXXW(data)
    end

    self:reqExchangeRoundTask() --获取兑换任务
--    AssistConnect:SendGetTaskForEnterGame(self)
    self:IsHaveTaskFinish()

    if self._baseGameConnect then
        self._baseGameConnect:sendMsgToServer(SKGameDef.SK_SYSMSG_PLAYER_ONLINE)
    end
    
    self:onCancelRobot()
    self:OPE_HideNoBiggerTip()

    cc.exports.isQuickStart = false
--    self:stopCheckOffline()

    if not self._baseGameUtilsInfoManager then
        return
    end

    if IsReturnBack then
        self:gameStop()
        self:clearGameTable()
    end
    
    self._baseGameScene:setMyRuleBtnVisible(false)

    local status = self._baseGameUtilsInfoManager:getStatus()
    if not status or 0 == status then
        self:gameStop()
        self:clearGameTable()
    else
        if self:IS_BIT_SET(status, BaseGameDef.BASEGAME_TS_PLAYING_GAME) then
            self:gameRun()
        end
        --清理桌面信息
        self._canReturnChartered = false
      
        if self._dispatch then
            self._dispatch:setStartMatch(false)
        end

        self:showWaitArrangeTable(false)
        
        self:ope_ShowStart(false)

        local playerManager = self._baseGameScene:getPlayerManager()
        if playerManager then
            playerManager:onGameStart()
        end    
        --清理桌面信息

        local gameTools = self._baseGameScene:getTools()
        if gameTools then
            gameTools:onGameStart()
        end

        local gameInfo = self._baseGameScene:getGameInfo()
        if gameInfo then
            gameInfo:setBaseScore(tostring(self:getBaseScore()))
        end

        for i = 1, 4 do
            local playerManager = self._baseGameScene:getPlayerManager()
            local drawIndex = self:rul_GetDrawIndexByChairNO(i - 1)
            if playerManager then
                playerManager:FreshPlace(drawIndex, 0)
                playerManager:FreshPlace(drawIndex, self._baseGameUtilsInfoManager._utilsStartInfo.nPlace[i])
            end
        end

        --cardMaker
        MyGameCardMakerInfo:resert()

        if self:isGameRunning() and self._baseGameUtilsInfoManager then
            local waitChair = self._baseGameUtilsInfoManager:getWaitChair()

            local SKHandCardsManager = self._baseGameScene:getSKHandCardsManager()
            if SKHandCardsManager then

                SKHandCardsManager:getSKHandCards(self:getMyDrawIndex()):setVisible(true)

                SKHandCardsManager:resetHandCardsManager()

                local cardsCounts = self._baseGameUtilsInfoManager:getCardsCount()

                for i = 1, self:getTableChairCount() do
                    local drawIndex = self:rul_GetDrawIndexByChairNO(i - 1)
                    if 0 < drawIndex then
                        SKHandCardsManager:setHandCardsCount(drawIndex, cardsCounts[drawIndex])

                        if drawIndex == self:getMyDrawIndex() then
                            local chairCards = self._baseGameUtilsInfoManager:getSelfDXXWCards()
                            SKHandCardsManager:setSelfHandCards(chairCards, true)
                            MyGameCardMakerInfo:onPutInMyselfCards(chairCards, i - 1) --cardMaker
                            SKHandCardsManager:ope_SortSelfHandCards()
                        end
                        self:setCardsCount(drawIndex, cardsCounts[drawIndex], false)
                    end
                end

                SKHandCardsManager:setEnableTouch(true)
                if waitChair == -1 then
                    SKHandCardsManager:setFirstHand(1)
                else
                    SKHandCardsManager:setFirstHand(0)
                end
            end

            --cardMaker
            local tableInfo = self._baseGameUtilsInfoManager:getTableInfo()
            MyGameCardMakerInfo:onThrowCards(tableInfo.nThrowID, tableInfo.nChairNO)
            MyGameCardMakerInfo:onThrowCards(tableInfo.nThrowID1, tableInfo.nChairNO1)
            MyGameCardMakerInfo:onThrowCards(tableInfo.nThrowID2, tableInfo.nChairNO2)
            MyGameCardMakerInfo:onThrowCards(tableInfo.nThrowID3, tableInfo.nChairNO3)
            self._baseGameScene._cardMakerTool:onRefreshCardMaker()
            if self:isNeedDeposit() or PublicInterFace.IsStartAsTimingGame() or PUBLIC_INTERFACE.IsStartAsAnchorMatchGame() then
                self._baseGameScene._cardMakerTool:updateCardMakerCount()
                self._baseGameScene._cardMakerTool:onShowCardMakerRank()

                CardRecorderModel:sendGetCardMakerInfo()
                --[[
                if my.isCacheExist("CardMaker.xml") then
                    local dateInfo = my.readCache("CardMaker.xml")
                    dateInfo=checktable(dateInfo)
                    self._baseGameScene._cardMakerTool:OnShowCardMakerInfo(dateInfo.isVisible)
                else
                    self._baseGameScene._cardMakerTool:OnShowCardMakerInfo(true)
                end
                --]]
            end
            

            --断线重连设置报警状态
            self:setPlayerAlarm()

            local SKThownCardsManager = self._baseGameScene:getSKThrownCardsManager()
            if SKThownCardsManager then
                local drawIndex = self:rul_GetDrawIndexByChairNO(waitChair)
                local cardsThrow = self._baseGameUtilsInfoManager:getWaitUniteInfo()
                if waitChair and -1 ~= waitChair and cardsThrow then
                    SKThownCardsManager:ope_ThrowCards(drawIndex, cardsThrow.nCardIDs, cardsThrow.nCardsCount)
                end
            end

            local SKOpeBtnManager = self._baseGameScene:getSKOpeBtnManager()
            SKOpeBtnManager:setTributeVisible(false)
            SKOpeBtnManager:setReturnVisible(false)

            local clock = self._baseGameScene:getClock()
            local currentIndex = self:rul_GetDrawIndexByChairNO(self._baseGameUtilsInfoManager:getCurrentChair())
            --[[if clock and 0 < currentIndex then
                local throwWait = self._baseGameUtilsInfoManager:getThrowWait()
                clock:start(throwWait)
                clock:moveClockHandTo(currentIndex)
            end--]]

            local hideToolsBut = false
            
            if self:IS_BIT_SET(status, MyGameDef.MYGAME_TS_WAITING_RETURN) then                
                local returnWait = self._baseGameUtilsInfoManager:getReturnWait() + 3 - self._baseGameUtilsInfoManager._utilsStartInfo.nReserved[1]
                clock:start(returnWait)
                clock:moveClockHandTo(-1)

                local selfInfo = self._baseGameScene:getSelfInfo()
                if selfInfo then
                    selfInfo:showReturn(true)
                end
                for i = 1, MyGameDef.MY_TOTAL_PLAYERS do
                    if self._baseGameUtilsInfoManager._utilsStartInfo.Tribute[i].bnTribute > 0
                        and self:getMyChairNO() == self._baseGameUtilsInfoManager._utilsStartInfo.Tribute[i].winner then
                        
                        if SKOpeBtnManager then
                            SKOpeBtnManager:setReturnVisible(true)
                            SKOpeBtnManager:setReturnEnable(false)
                        end                       
                        SKHandCardsManager:OPE_MaskCardForTributeAndReturn()
                    end
                    local playerManager = self._baseGameScene:getPlayerManager()
                    local drawIndex = self:rul_GetDrawIndexByChairNO(i-1)
                    if playerManager then
                        playerManager:FreshPlace(drawIndex, 0)
                    end
                end
            elseif self:IS_BIT_SET(status, MyGameDef.MYGAME_TS_WAITING_TRIBUTE) then
                local tributeWait = self._baseGameUtilsInfoManager:getTributeWait() + 3 - self._baseGameUtilsInfoManager._utilsStartInfo.nReserved[1]
                clock:start(tributeWait)
                clock:moveClockHandTo(-1)
                
                local selfInfo = self._baseGameScene:getSelfInfo()
                if selfInfo then
                    selfInfo:showTribute(true)
                end
                for i = 1, MyGameDef.MY_TOTAL_PLAYERS do
                    if self._baseGameUtilsInfoManager._utilsStartInfo.Tribute[i].bnTribute > 0
                        and self:getMyChairNO() == (i-1) then
                        
                        if SKOpeBtnManager then
                            SKOpeBtnManager:setTributeVisible(true)
                            SKOpeBtnManager:setTributeEnable(false)
                        end
                        SKHandCardsManager:OPE_MaskCardForTributeAndReturn()
                    end
                    local playerManager = self._baseGameScene:getPlayerManager()
                    local drawIndex = self:rul_GetDrawIndexByChairNO(i-1)
                    if playerManager then
                        playerManager:FreshPlace(drawIndex, 0)
                    end
                end
            elseif self:IS_BIT_SET(status, BaseGameDef.BASEGAME_TS_WAITING_THROW) then
                local nTime = self._baseGameUtilsInfoManager:getThrowWait() - self._baseGameUtilsInfoManager._utilsStartInfo.nReserved[1]

                -- 判断自动过牌
                self._cardStatus = MyGameController._CARD_STATUS.NORMAL
                if currentIndex == self:getMyDrawIndex() then
                    self:autoPass()
                end

                -- 若触发自动过牌则不显示时钟
                if self._cardStatus and self._cardStatus == MyGameController._CARD_STATUS.AUTO_PASS then
                    clock:setVisible(false)
                elseif self._cardStatus and self._cardStatus == MyGameController._CARD_STATUS.NO_BIGGER then -- 若显示要不起始终倒计时变为10秒
                    clock:setVisible(true)
                    local waittime = cc.exports._gameJsonConfig.NoBiggerWaitTime or MyGameController.NoBiggerWaitTime
                    nTime = waittime - self._baseGameUtilsInfoManager._utilsStartInfo.nReserved[1] -- 要不起暂定
                else
                    clock:setVisible(true)
                end

                if nTime <= 0 then
                    nTime = 3
                end

                if clock then
                    clock:start(nTime)
                    clock:moveClockHandTo(currentIndex)
                end
                
                if currentIndex == self:getMyDrawIndex() then
                    self:OPE_ShowNoBiggerTip()
                    -- 若当前没有触发自动过牌和要不起按钮则显示操作按钮（这里在onDXXW判断：断线重连后）
                    if (not self._cardStatus) or self._cardStatus == MyGameController._CARD_STATUS.NORMAL then
                        self:showOperationBtns()
                    end
                end

                local myFriendchair= self._baseGameUtilsInfoManager:RUL_GetDuiJiaChairNO(self:getMyChairNO())
                if self._baseGameUtilsInfoManager._utilsTableInfo._nFriendCardCount > 0 then
                    SKHandCardsManager:showFriendCards(self._baseGameUtilsInfoManager:getFriendCard(), self._baseGameUtilsInfoManager._utilsTableInfo._nFriendCardCount)
                    hideToolsBut = true

                    local selfInfo = self._baseGameScene:getSelfInfo()
                    if selfInfo then
                        selfInfo:showDuiJiaShouPai(true)
                    end
                    self._baseGameScene:setMyRuleBtnVisible(true)
                end
            end

            self:ope_ShowGameInfo(true)
            local gameTools = self._baseGameScene:getTools()
            if gameTools then
                gameTools:ope_StartPlay()
            end

            if hideToolsBut then
                if gameTools then
                    gameTools:onHideOtherButton()
                end
            end

            if not PUBLIC_INTERFACE.IsStartAsAnchorMatchGame() then
                self:OPE_FreshBomgRecord()
            end

            self:ope_GameInfoShow(true)

            self._baseGameScene:doSomethingForVerticalCard()    -- 短线重连后的竖排相关的处理
            -- if not self:IS_BIT_SET(status, BaseGameDef.BASEGAME_TS_WAITING_THROW) 
            --     and not self:IS_BIT_SET(status, MyGameDef.MYGAME_TS_WAITING_TRIBUTE)
            --     and not self:IS_BIT_SET(status, MyGameDef.MYGAME_TS_WAITING_RETURN) then
            --     if self._baseGameUtilsInfoManager._utilsTableInfo._nFriendCardCount <= 0 then   --如果牌已出完则不显示新手引导
            --         self:checkGameGuideOnDXXW()
            --     end
            -- end
            self:checkNewUserGuideOnDXXW()
        end
    end

    if PUBLIC_INTERFACE.IsStartAsTeam2V2() then
        self:checkTeam2V2ReadyState()
    end
end

function MyGameController:isSameGroup(chairNO)
    local drawIndex = self:rul_GetDrawIndexByChairNO(chairNO)
    local myDrawIndex = self:getMyDrawIndex()

    local playerManager = self._baseGameScene:getPlayerManager()
    if playerManager then
        return playerManager._players[drawIndex]:isFarmer() == playerManager._players[myDrawIndex]:isFarmer()
    end

    return false
end

function MyGameController:GetSoundsPath(data)

    local setData = self._baseGameScene:getSetting()
    local langauge = setData._selectedLangauge
    local drawIndex = self:rul_GetDrawIndexByChairNO(data.nChairNO) 
    local sex = self._baseGamePlayerInfoManager:getPlayerNickSexByIndex(drawIndex)
    local path =""
    if sex == 1 then
        if langauge == 0 then
            path = "res/Game/GameSound/CardType/Mandarin/Female/"
        else
            path = "res/Game/GameSound/CardType/Dialect/Female/"
        end
    else
        if langauge == 0 then
            path = "res/Game/GameSound/CardType/Mandarin/Male/"
        else
            path = "res/Game/GameSound/CardType/Dialect/Male/"
        end
    end

    return path
end

function MyGameController:playPassEffect(cardsPass)
    --self:playGamePublicSound("Snd_Pass")
    --local setData = self._baseGameScene:getSetting()
    --local langauge = setData._selectedLangauge
    local drawIndex = self:rul_GetDrawIndexByChairNO(cardsPass.nChairNO) 
    local sex  = self._baseGamePlayerInfoManager:getPlayerNickSexByIndex(drawIndex)
    local path = ""
    if sex == 1 then
        path = "res/Game/GameSound/CardType/Mandarin/Female/female_pass"
    else
        path = "res/Game/GameSound/CardType/Mandarin/Male/pass"
    end
    
    math.randomseed(os.time())
    local num = math.random(0,2)
    audio.playSound(path..tostring(num)..".mp3")
end

function MyGameController:playCardsEffect(cardsThrow)
    self:playGamePublicSound("Snd_Throw.mp3")
    --local setData = self._baseGameScene:getSetting()
    --local langauge = setData._selectedLangauge
    local drawIndex = self:rul_GetDrawIndexByChairNO(cardsThrow.nChairNO) 
    local sex = self._baseGamePlayerInfoManager:getPlayerNickSexByIndex(drawIndex)
    
    --local path = self:GetSoundsPath(cardsThrow)
    local SKHandCardsManager        = self._baseGameScene:getSKHandCardsManager()
    local bFirstHand = SKHandCardsManager:isFirstHand()
    
    local strPath = ""
    if sex == 1 then
        strPath = "res/Game/GameSound/CardType/Mandarin/Female/female_"
    else
        strPath = "res/Game/GameSound/CardType/Mandarin/Male/"
    end
   
    local fileName = nil
   
    local dwType        = cardsThrow.dwCardType
    
    math.randomseed(os.time())

    local num = math.random(0,5)
    if dwType == SKGameDef.SK_CARD_UNITE_TYPE_BOMB then          
        fileName = "zhadan"..tostring(num)
        if cardsThrow.nCardsCount < 5 then
            self:playGamePublicSound("Snd_Bomb.mp3")
        else
            self:playGamePublicSound("Snd_Bomb5.mp3")
        end
    elseif dwType == SKGameDef.SK_CARD_UNITE_TYPE_TONGHUASHUN then
        fileName = "tonghuashun"
        self:playGamePublicSound("tonghuashun.mp3")
    elseif dwType == SKGameDef.SK_CARD_UNITE_TYPE_SUPER_BOMB then
        fileName = "superbomb"
        self:playGamePublicSound("chaojidazhadan.mp3")
    elseif dwType == SKGameDef.SK_CARD_UNITE_TYPE_4KING then
        fileName = "siwangzha"
        self:playGamePublicSound("Snd_4King.mp3")
    elseif dwType == SKGameDef.SK_CARD_UNITE_TYPE_ABT_THREE then
        self:playGamePublicSound("Snd_feiji.mp3")
    elseif dwType == SKGameDef.SK_CARD_UNITE_TYPE_ABT_SINGLE then
        --预留
    end

    if not bFirstHand then   
        if fileName == nil then           
            local num = 0
            if dwType == SKGameDef.SK_CARD_UNITE_TYPE_THREE_COUPLE or dwType == SKGameDef.SK_CARD_UNITE_TYPE_ABT_SINGLE
                or dwType == SKGameDef.SK_CARD_UNITE_TYPE_ABT_COUPLE or dwType == SKGameDef.SK_CARD_UNITE_TYPE_ABT_THREE then                
                num = math.random(0,5)
            else               
                num = math.random(0,3)
            end
            fileName = "yasi"..tostring(num)
        end

        local pathName = strPath .. fileName.. ".mp3"
        audio.playSound(pathName, false)
        return 
    end    

    if fileName ~= nil then
        local pathName = strPath .. fileName.. ".mp3"
        audio.playSound(pathName, false)
        return
    end
   
    local cardindex = MyCalculator:getCardIndex(cardsThrow.nCardIDs[1])+1

    if dwType == SKGameDef.SK_CARD_UNITE_TYPE_SINGLE then
        if cardindex < 11 then
            fileName = tostring(cardindex)
        elseif cardindex == 11 then
            fileName = "J"
        elseif cardindex == 12 then
            fileName = "Q"
        elseif cardindex == 13 then
            fileName = "K"
        elseif cardindex == 14 then
            fileName = "A"
        elseif cardindex == 15 then
            fileName = "Joke_s"
        elseif cardindex == 16 then
            fileName = "Joke"
        end
    elseif dwType == SKGameDef.SK_CARD_UNITE_TYPE_COUPLE then
        if MyCalculator:isJoker(cardsThrow.nCardIDs[1]) then
            cardindex = MyCalculator:getCardIndex(cardsThrow.nCardIDs[2])+1
        end
        if cardindex < 10 then
            fileName = tostring(cardindex*11)
        elseif cardindex == 10 then
            fileName = "1010"
        elseif cardindex == 11 then
            fileName = "JJ"
        elseif cardindex == 12 then
            fileName = "QQ"
        elseif cardindex == 13 then
            fileName = "KK"
        elseif cardindex == 14 then
            fileName = "AA"
        elseif cardindex == 15 then
            fileName = "Joke_sJoke_s"
        elseif cardindex == 16 then
            fileName = "JokeJoke"
        end
    elseif dwType == SKGameDef.SK_CARD_UNITE_TYPE_THREE then
        if MyCalculator:isJoker(cardsThrow.nCardIDs[1]) then
            if MyCalculator:isJoker(cardsThrow.nCardIDs[2]) then
                cardindex = MyCalculator:getCardIndex(cardsThrow.nCardIDs[3])+1
            else
                cardindex = MyCalculator:getCardIndex(cardsThrow.nCardIDs[2])+1
            end
        end
        if cardindex < 10 then
            fileName = tostring(cardindex*111)
        elseif cardindex == 10 then
            fileName = "101010"
        elseif cardindex == 11 then
            fileName = "JJJ"
        elseif cardindex == 12 then
            fileName = "QQQ"
        elseif cardindex == 13 then
            fileName = "KKK"
        elseif cardindex == 14 then
            fileName = "AAA"
        end
    elseif dwType == SKGameDef.SK_CARD_UNITE_TYPE_THREE_COUPLE then
        fileName = "sandaier"
    elseif dwType == SKGameDef.SK_CARD_UNITE_TYPE_ABT_SINGLE then
        fileName = "Shunzi"
    elseif dwType == SKGameDef.SK_CARD_UNITE_TYPE_ABT_COUPLE then
        fileName = "sanliandui"
    elseif dwType == SKGameDef.SK_CARD_UNITE_TYPE_ABT_THREE then
        fileName = "gangban"
    end
    if fileName == nil then
        return
    end

    local pathName = strPath .. fileName..".mp3"
    audio.playSound(pathName, false)
end

function MyGameController:playGamePublicSound(soundName)
    if not self._baseGameScene or tolua.isnull(self._baseGameScene) then
        return
    end

    local loadingNode = self._baseGameScene:getLoadingNode()
    if loadingNode then
        return
    end
    if self._isShieldVoice then
        return
    end

    local soundPath = "res/Game/GameSound/PublicSound/"
    audio.playSound(soundPath..soundName, false)
end

function MyGameController:playBtnPressedEffect()
    self:playGamePublicSound("Snd_pu.mp3")
end

function MyGameController:playCardsBtnPressedEffect()
    self:playGamePublicSound("KeypressStandard.mp3")
end

function MyGameController:getBGMPath()
    return "res/Game/GameSound/BGMusic/BG.mp3"
end

function MyGameController:gotoHallScene()
    if(cc.exports.inTickoff==true)then
        return
    end

    if cc.exports.jumpHighRoom == true then
        return
    end

    if self._ExchangeQuitPrompt then    -- 兑换券退出弹窗，在异常退出的时候需要关闭下
        self._ExchangeQuitPrompt:onClose() 
        self._ExchangeQuitPrompt = nil
    end

    self:resetNewUserGuide()
    -- self:ResetGameGuide()
    self:setResume(false)
    self:gameStop()
    self:onCancelRobot()
    self:OPE_HideNoBiggerTip()
    self:stopBGM()
    self:stopCheckOffline()
    cc.exports.hasStartGame = false
    TimerManager:stopTimer("Timer_GameScene_WaitGameNodeCreated")
    TimerManager:stopTimer("Timer_GameScene_DelayedNormalGameResultOnGameWin")
    TimerManager:stopTimer("Timer_GameScene_DelayedArenaGameResultOnGameWin")
    print("GoBackToMainScene")

    --退出时，查询校验一下，用于抽奖校验次数
    WeakenScoreRoomModel:sendGetBoutInfoForLottery()

    PublicInterFace.GoBackToMainScene()

    if self._baseGameScene then
        self._baseGameScene:removeListen()
    end
    
    --退出恢复跑马灯
    local BroadcastModel = mymodel("hallext.BroadcastModel"):getInstance()
    BroadcastModel:ReStartInsertMessageEx()

    -- 广告模块 start
    local roomInfo = cc.exports.PUBLIC_INTERFACE.GetCurrentRoomInfo()
    local utf8Name = roomInfo.szRoomName
    if self:isNeedDeposit() and utf8Name == "初级房" then
        if AdvertModel:isNeedShowInterstitial(AdvertDefine.INTERSTITIAL_GAME_TO_HALL_PRIMARY_DEPOSIT) then
            AdvertModel:showInterstitialAdvert(AdvertDefine.INTERSTITIAL_GAME_TO_HALL_PRIMARY_DEPOSIT)
            AdvertModel:addInterVdShowCount(AdvertDefine.INTERSTITIAL_GAME_TO_HALL_PRIMARY_DEPOSIT, 1)
        end
    elseif not self:isNeedDeposit() and not PublicInterFace.IsStartAsTimingGame() then
        if AdvertModel:isNeedShowInterstitial(AdvertDefine.INTERSTITIAL_GAME_TO_HALL_SCORE) then
            AdvertModel:showInterstitialAdvert(AdvertDefine.INTERSTITIAL_GAME_TO_HALL_SCORE)
        end
    end
    -- 广告模块 end
end

function MyGameController:onUpPlayer(drawIndex)
    self._baseGameConnect:reqUpPlayer(drawIndex)
end

function MyGameController:onBuyPropsThrow(drawIndex)
    self._baseGameConnect:reqBuyPropsThrow(drawIndex)
end

function MyGameController:stopDownExpressionBtnTimer()
    if self._downExpressionTimer then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._downExpressionTimer)
        self._downExpressionTimer = nil
    end
end

function MyGameController:ExpressionThrow(expressionIndex)
    local function dealDownExpressionBtn()
        self:stopDownExpressionBtnTimer()

        self._canDownExpessionBtn = true
    end

    if not self._canDownExpessionBtn then
        self:tipMessageByKey("G_GAME_EXPRESSION_TIME_TIP")
        return
    end

    self._canDownExpessionBtn = false
    self:stopDownExpressionBtnTimer()
    self._downExpressionTimer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(dealDownExpressionBtn, 3, false)

    self._baseGameConnect:reqExpressionThrow(self:getMyDrawIndex(), expressionIndex)
end
function MyGameController:onGetUpPlayer(data)
    if self._baseGameData then
        local contentKey
        local upData = self._baseGameData:getUpPlayerData(data)
        if upData.bUpSucceed == SKGameDef.SK_UP_SUCCESS then
            local destIndex = self:rul_GetDrawIndexByChairNO(upData.nDestChairNO)
            local sourceIndex = self:rul_GetDrawIndexByChairNO(upData.nSourceChairNO)
            self:playDirectionAni(upData)
            self:playUpAnimation(destIndex, true)
            self:playUpSelfTip(upData, true)
            local content = self:getGameStringByKey("G_UPPLAYER_OK")          
            self:tipChatContent(destIndex, content)
            
            my.scheduleOnce(function()
                if self:isInGameScene() == false then return end
                local playerManager = self._baseGameScene:getPlayerManager()
                if playerManager then
                    playerManager:getGamePlayerByIndex(destIndex):playFacial("Node_Facial_pf.csb","animation_facial")
                end               
            end, 0.6)

            self:playGamePublicSound("Snd_dianzan.mp3")
            
            local playerManager = self._baseGameScene:getPlayerManager()
            if playerManager then
                playerManager:updataUpInfo(upData)
            end
            
            if sourceIndex == self:getMyDrawIndex() then
                if upData.nCurUpCount == 5 then
                    my.dataLink(cc.exports.DataLinkCodeDef.GAME_UP_OVER_5)
                end
            end
            if destIndex == self:getMyDrawIndex() then
                if cc.exports.oneRoundGameWinData.getUpNum == nil then
                    cc.exports.oneRoundGameWinData.getUpNum = 0      -- 点赞
                end
                cc.exports.oneRoundGameWinData.getUpNum = cc.exports.oneRoundGameWinData.getUpNum + 1
            end

            --17期客户端埋点
            my.dataLink(cc.exports.DataLinkCodeDef.GAME_ACCEPT_UP_PLAYER_MSG)

            if tonumber(upData.nCurUpCount) == tonumber(upData.nMaxUpCount) then
	    	    player:update({'SafeboxInfo'})
            end
        elseif upData.bUpSucceed == SKGameDef.SK_UP_FULL then
            contentKey = "G_UPPLAYER_FULL"
            self:showUpFaidTip(contentKey)
        elseif upData.bUpSucceed == SKGameDef.SK_UP_SELF_FULL then
            contentKey = "G_UPPLAYER_SELF_FULL"
            self:showUpFaidTip(contentKey)
        elseif upData.bUpSucceed == SKGameDef.SK_UP_OTHER_FULL then
            contentKey = "G_UPPLAYER_OTHER_FULL"
            self:showUpFaidTip(contentKey)
        elseif upData.bUpSucceed == SKGameDef.SK_UP_SAME_ROUND then
            contentKey = "G_UPPLAYER_SAME_ROUND"
            self:showUpFaidTip(contentKey)
        else
            contentKey = "G_UPPLAYER_FAILED"
            self:showUpFaidTip(contentKey)
        end
    end
    --TODO
end

function MyGameController:showUpFaidTip(contentKey)   
    self:tipMessageByKey(contentKey)   
end

function MyGameController:getPlayerPosition(drawIndex)
    local node = self._baseGameScene._gameNode
    if node then
        local playerManager = self._baseGameScene:getPlayerManager()
        local playerNode = playerManager._players[drawIndex]._playerNode
        local point = cc.p(playerNode:getPosition())

        --由于加了Operate_Panel适配层，player节点在Operate_Panel下，而动画节点是addChild到_baseGameScene根节点，所以需要将player节点位置坐标转换到世界坐标
        point = playerNode:getParent():convertToWorldSpace(point)

        return point
    end
    
    return cc.p(0,0)
end

function MyGameController:playDirectionAni(data)
    local orgIndex = self:rul_GetDrawIndexByChairNO(data.nSourceChairNO)
    local desIndex = self:rul_GetDrawIndexByChairNO(data.nDestChairNO)
    
    local orgPoint = self:getPlayerPosition(orgIndex)
    local desPoint = self:getPlayerPosition(desIndex)
    
--    local orgPoint = cc.p(100, 100)
--    local desPoint = cc.p(800, 500)
    local emitter = cc.ParticleFlower:create()
    emitter:retain()    
    self._baseGameScene:addChild(emitter)
    emitter:setTexture(cc.TextureCache:sharedTextureCache():addImage("res/Game/GamePic/GameContents/animation_lightstar.png"))
    
    emitter:setEmitterMode(cc.PARTICLE_MODE_GRAVITY)
    
    local size = cc.Director:getInstance():getWinSize()
    emitter:setPosition(size.width/2, size.height/2)
    emitter:setPosVar(cc.p(0, 0))
    emitter:setDuration(1.0)
    emitter:setLife(0.3)
    emitter:setLifeVar(0)
    
    emitter:setEmissionRate(emitter:getTotalParticles()/emitter:getLife())
    emitter:setPosition(orgPoint)
    emitter:setPosVar(cc.p(0,0))
    
    local moveto = cc.MoveTo:create(0.6, desPoint)
    emitter:runAction(moveto)
end

function MyGameController:playUpAnimation(drawIndex, bShow)
    local playerManager = self._baseGameScene:getPlayerManager()
    if playerManager then
        playerManager:playUpAnimation(drawIndex, bShow)
    end
end

function MyGameController:playUpSelfTip(upData, bShow)
    local upInfoPanel = self._baseGameScene:getUpInfoPanel()
    local selfIndex = self:getMyDrawIndex()
    local destIndex = self:rul_GetDrawIndexByChairNO(upData.nDestChairNO)
    local sourceIndex = self:rul_GetDrawIndexByChairNO(upData.nSourceChairNO)
    if selfIndex == destIndex and selfIndex == sourceIndex and upInfoPanel then
        local upText = upInfoPanel:getChildByName("Text_attention_words")
        if upText then
            upText:setOpacity(255)
            upText:setVisible(true)
            upText:setLocalZOrder(SKGameDef.SK_ZORDER_UP_TIP)
            upText:runAction(cc.FadeOut:create(5))            
        end
    end
end

function MyGameController:OnUpInfo(soloPlayer)
    if self._baseGameConnect then
        self._baseGameConnect:reqUpInfo(soloPlayer)
    end
end

function MyGameController:onGetUpInfo(data)
    if self._baseGameData then
        local upInfo = self._baseGameData:getUpInfo(data)       
        
        local playerManager = self._baseGameScene:getPlayerManager()
        if playerManager then
            playerManager:setShowUpInfo(upInfo)
        end
    end
end

function MyGameController:onGameWin(data)
    print("onGameWin:hideBannerAdvert")
    self:hideBannerAdvert()

    self:onGameOneSetEnd(data)
    
    if self:isBoutGuide() then
        self._baseGameConnect:reqFinishGuideBout()
    end

    self._havemovedcard = 0
    self._n5BombDouble  = nil

    if self._needReturnRoomID then  --跳转后需要玩一把才能跳回原来房间
        self._canGobackRoom = true
    end

    self:setResume(false)
    self:gameStop()
    self:startAutoQuitTimer()

    if not self:isResume() then
        self:setResponse(self:getResWaitingNothing())
    end

    local clock = self._baseGameScene:getClock()
    if clock then
        clock:resetClock()
    end

    local gameTools = self._baseGameScene:getTools()
    if gameTools then
        gameTools:onGameWin()
    end

    local playerManager = self._baseGameScene:getPlayerManager()
    if playerManager then
        playerManager:onHidePlayerInfo()
        playerManager:onGameWin()
    end

    local safeBox = self._baseGameScene:getSafeBox()
    if safeBox then
        safeBox:showSafeBox(false)
    end

    local CenterCtrl = require('src.app.BaseModule.CenterCtrl'):getInstance()
    CenterCtrl:notifyPluginByName("AutoSupplyCtrl") --隐藏自动存取银界面

    local chat = self._baseGameScene:getChat()
    if chat and chat:isVisible() then
        chat:showChat(false)
    end

    local setting = self._baseGameScene:getSetting()
    if setting and setting:isVisible() then
        setting:showSetting(false)
    end

    local selfInfo = self._baseGameScene:getSelfInfo()
    if selfInfo then
        selfInfo:showDuiJiaShouPai(false)
    end
    self._baseGameScene:setSortTypeBtnEnabled(false)
    self:onCancelRobot()
   
    MyGameController._sortFlag = SKGameDef.SORT_CARD_BY_ORDER

    local gameWin = nil
    if self._baseGameData then
        gameWin = self._baseGameData:getGameWinInfo(data)
        self.gameWinBnResetGame = gameWin.bnResetGame
    end

    if PUBLIC_INTERFACE.IsStartAsTeam2V2() then
        gameTools:showQuitBtn(self.gameWinBnResetGame)
        if gameWin.bnResetGame == 1 then
            -- 组队连局结束
            if Team2V2Model:isSelfMate() then
                Team2V2Model:reqCancelReady()
            end
        end
    end

    if gameWin then
        print("------------------------------function MyGameController:onGameWin(data)------------------------------------")
        dump(gameWin)
        self._baseGameUtilsInfoManager.bEndedExit = gameWin.bEnableLeave

        if not PUBLIC_INTERFACE.IsStartAsAnchorMatchGame() then
            self:onUpdateScoreInfo(gameWin)
        end
      
        self:startTimeResultClose()

        local SKThownCardsManager       = self._baseGameScene:getSKThrownCardsManager()
        local SKHandCardsManager = self._baseGameScene:getSKHandCardsManager()
        if not SKHandCardsManager or not SKThownCardsManager then return end

        for i = 1, self:getTableChairCount() do
            local score = gameWin.nScoreDiffs[i]
            local deposit = gameWin.nDepositDiffs[i]
            local drawIndex = self:rul_GetDrawIndexByChairNO(i - 1)
            if 0 < drawIndex then
                self:addPlayerScore(drawIndex, score)
                self:addPlayerDeposit(drawIndex, deposit)
                self:addPlayerBoutInfo(drawIndex, score)
                if PublicInterFace.IsStartAsTimingGame() then
                    self:addTimingScore(drawIndex, score)
                end
            end

            if self:getMyDrawIndex() == drawIndex then
                self:hideOperationBtns()

                local nFriendCardIDs = {}
                local nFriendCardsCount = 0
                local myHandCards = SKHandCardsManager:getSKHandCards(drawIndex)
                if myHandCards and  myHandCards.getFriendCardsCount then
                    if myHandCards:getFriendCardsCount() > 0 then  -- 结算时，如果显示的是对家手牌
                        myHandCards:zeroFriendCardsCount()
                    end
                end
            end

            if 0 < drawIndex and 0 < gameWin.nCardCount[i] and drawIndex ~= self:getMyDrawIndex() then
                SKHandCardsManager:setHandCardsCount(drawIndex, gameWin.nCardCount[i])
                SKHandCardsManager:setHandCardsWin(drawIndex, gameWin.nCardID[i])
                SKHandCardsManager:sortHandCards(drawIndex)
            end

            playerManager:FreshPlace(drawIndex, gameWin.nPlace[i])

            self._baseGameUtilsInfoManager._utilsStartInfo.nPlace[i] = 0 --重置下数据看看

            SKThownCardsManager:hidePassTip(drawIndex)
        end

        local BomeCount = gameWin.nBombCount[1] + gameWin.nBombCount[2]

        local nFan = 1
        nFan = nFan * (2 ^ BomeCount)
        if gameWin.nBombCount[3] > 0 then
            nFan = nFan * 3
        end
        gameWin.BomeRate = nFan

        gameWin.upRankEx = 1
        if gameWin.nUpRank[self:getMyChairNO()+1] == 4 or gameWin.nUpRank[self:getNextChair(self:getMyChairNO())+1] == 4 then
            gameWin.upRankEx = 4
        elseif gameWin.nUpRank[self:getMyChairNO()+1] == 3 or gameWin.nUpRank[self:getNextChair(self:getMyChairNO())+1] == 3 then
            gameWin.upRankEx = 4
        elseif gameWin.nUpRank[self:getMyChairNO()+1] == 2 or gameWin.nUpRank[self:getNextChair(self:getMyChairNO())+1] == 2 then
            gameWin.upRankEx = 2
        end

        local uitleInfoManager  = self:getUtilsInfoManager()
        local nRoomID = uitleInfoManager:getRoomID()
        if TimingGameModel:isTicketTaskEnable() and TimingGameModel:isRoomIDCanAddBout(nRoomID) then --用于显示对局获得的定时赛门票
            dump(TimingGameModel:getInfoData(), "isRoomIDCanAddBout infodata")
            TimingGameModel:addBoutCount(nRoomID)
            local bShow, nCount = TimingGameModel:isShowTimingGameBoutReward()
            if bShow then
                local rewardList = {}
                local RewardTipDef = import("src.app.plugins.RewardTip.RewardTipDef")
                table.insert( rewardList,{nType = RewardTipDef.TYPE_REWARDTYPE_TIMINGGAME_TICKET, nCount = nCount})
                my.informPluginByName({pluginName = 'RewardTipCtrl', params = {data = rewardList, showApply = true}})
                my.scheduleOnce(function()
                    local TimingGameModel = import('src.app.plugins.TimingGame.TimingGameModel'):getInstance()
                    TimingGameModel:reqTimingGameInfoData()
                end, 1)
            end
        end
        
        if self:isArenaPlayer() then --竞技场不跳原来的结算界面
            self._baseGameScene:setArenaGameResult(gameWin)
            TimerManager:scheduleOnceUnique("Timer_GameScene_DelayedNormalGameResultOnGameWin", function()
                if self:isInGameScene() == false then return end
                self:UpgradeLevelForArenaPlayer(gameWin)
            end, 2.0)
            --[[my.scheduleOnce(function()
                if self:isInGameScene() == false then return end
                self:UpgradeLevelForArenaPlayer(gameWin)
            end, 2)]]--
        elseif PublicInterFace.IsStartAsTimingGame() then --定时赛不跳原来的结算界面
            TimerManager:scheduleOnceUnique("Timer_GameScene_DelayedNormalGameResultOnGameWin", function()
                if PUBLIC_INTERFACE.IsStartAsTeam2V2() then
                    if not self._onGameStart then
                        self._oldTimingGameData = {clone(TimingGameModel:getInfoData()), TimingGameModel:getInfoDataStamp()}
                        TimingGameModel:reqTimingGameInfoData()
                        self:showGameResultInfo(gameWin)
                    end
                else
                    self._oldTimingGameData = {clone(TimingGameModel:getInfoData()), TimingGameModel:getInfoDataStamp()}
                    TimingGameModel:reqTimingGameInfoData()
                    self:showGameResultInfo(gameWin)
                end
            end, 2.0)
        elseif PUBLIC_INTERFACE.IsStartAsAnchorMatchGame() then -- 主播建房
            self._baseGameScene:setAnchorMatchGameResult(gameWin)
        else
            -- 延时2s播放结算界面
            TimerManager:scheduleOnceUnique("Timer_GameScene_DelayedNormalGameResultOnGameWin", function()
                if PUBLIC_INTERFACE.IsStartAsTeam2V2() then
                    if not self._onGameStart then
                        self:showGameResultInfo(gameWin)
                        if gameWin.nExchangeVouNum[self:getMyChairNO() + 1] > 0 then   
                            --播放获得兑换券或银子动画
                            self._baseGameScene:showBreakEggsAnimation(8,  gameWin.nExchangeVouNum[self:getMyChairNO() + 1])
                        end
                    end                    
                else
                    self:showGameResultInfo(gameWin)
                    if gameWin.nExchangeVouNum[self:getMyChairNO() + 1] > 0 then   
                        --播放获得兑换券或银子动画
                        self._baseGameScene:showBreakEggsAnimation(8,  gameWin.nExchangeVouNum[self:getMyChairNO() + 1])
                    end
                end
            end, 2.0)
            --[[my.scheduleOnce(function()
                if self:isInGameScene() == false then return end
                -- 延时2s播放结算界面
                self:showGameResultInfo(gameWin)
                if gameWin.nExchangeVouNum[self:getMyChairNO() + 1] > 0 then   
                    --播放获得兑换券或银子动画
                    self._baseGameScene:showBreakEggsAnimation(8,  gameWin.nExchangeVouNum[self:getMyChairNO() + 1])
                end
            end, 2)]]--
        end

        local playerInfoManager = self:getPlayerInfoManager()

        local selfInfo = {}
        selfInfo.nUserID = playerInfoManager:getSelfUserID()
        selfInfo.nChairNO = playerInfoManager:getSelfChairNO()

        --游戏结束不发送请求点赞的消息
        -- my.scheduleOnce(function()
        --     if self:isInGameScene() == false then return end
        --     self:OnUpInfo(selfInfo)
        -- end, 0.5)
             
        for i = 0 ,3 do
            self._baseGameUtilsInfoManager:getPlayInfoByChairNo(i).nBombCount[4] = 0
        end   
        
        --是否更新下其他玩家等级数据
        my.scheduleOnce(function()
            if self:isInGameScene() == false then return end
            for i = 0, 3 do
                if i ~= self:getMyChairNO() then
                    local drawIndexLevel = self:rul_GetDrawIndexByChairNO(i)
                    if playerManager:getGamePlayerByIndex(drawIndexLevel) then 
                        local levelData = playerManager:getGamePlayerByIndex(drawIndexLevel)._playerLevelData
                        local playerInfo = playerInfoManager:getPlayerInfo(drawIndexLevel)
                        if levelData and levelData.nLevelExp < levelData.nNextExp and playerInfo then
                            if levelData.nLevelExp + gameWin.nLevelExpUp[i+1] >= levelData.nNextExp then
                                UserLevelModel:sendGetUserLevelReq(playerInfo.nUserID)
                            end
                        end
                    end
                end
            end
        end, 0.5)
        
        if not PUBLIC_INTERFACE.IsStartAsAnchorMatchGame() then
            self:ChangeParamTask(1,1)
            if gameWin.nPlace[self:getMyChairNO()+1] == 1 then
                self:ChangeParamTask(3,1)
            end
            if gameWin.nPlace[self:getMyChairNO()+1] == 1
                or gameWin.nPlace[(self:getMyChairNO()+3)%MyGameDef.MY_TOTAL_PLAYERS] == 1 then
                self:ChangeParamTask(2,1)
            end
        end


        if self:isNeedDeposit() then
            local GameWinYinzi = gameWin.nDepositDiffs[self:getMyChairNO() + 1]
            if cc.exports.oneRoundGameWinData.gameNum == nil then
                cc.exports.oneRoundGameWinData.gameNum = 0      -- 局数
                cc.exports.oneRoundGameWinData.gameWinNum = 0   -- 胜利局数
                cc.exports.oneRoundGameWinData.gameWinMoney = 0 -- 输赢银子数
                cc.exports.oneRoundGameWinData.getUpNum = 0      -- 点赞
            end
            cc.exports.oneRoundGameWinData.gameNum = cc.exports.oneRoundGameWinData.gameNum + 1
            cc.exports.oneRoundGameWinData.gameWinMoney = cc.exports.oneRoundGameWinData.gameWinMoney + GameWinYinzi

            local winChairNo = -1
            for i = 1, 4 do
                if gameWin.nPlace[i] == 1 then
                    winChairNo = i
                    break
                end
            end
            winChairNo = winChairNo - 1
            if winChairNo == self:getMyChairNO() or winChairNo == self._baseGameUtilsInfoManager:RUL_GetNextChairNO(self._baseGameUtilsInfoManager:RUL_GetNextChairNO(self:getMyChairNO())) then
                cc.exports.oneRoundGameWinData.gameWinNum = cc.exports.oneRoundGameWinData.gameWinNum + 1
            end

            --当前局数加1
            WeakenScoreRoomModel:onAddBoutInfo()
        end
        if cc.exports.oneRoundGameWinData.getVoucherNum == nil then -- 兑换券数
            cc.exports.oneRoundGameWinData.getVoucherNum = 0
        end
        cc.exports.oneRoundGameWinData.getVoucherNum = cc.exports.oneRoundGameWinData.getVoucherNum + gameWin.nExchangeVouNum[self:getMyChairNO() + 1]

        ExchangeCenterModel:addTicketNum(gameWin.nExchangeVouNum[self:getMyChairNO() + 1])

        if self._GoldeEggTaskData then  --更新金蛋的任务数
            if self._GoldeEggTaskData.nExchangeRoundNum >= self._GoldeEggTaskData.nMaxRoundNum then
            else
                self._GoldeEggTaskData.nExchangeRoundNum = self._GoldeEggTaskData.nExchangeRoundNum + 1
                self._baseGameScene:updateGoldeEggData(self._GoldeEggTaskData)
            end
        end

        self._baseGameScene:setMyRuleBtnVisible(true)        
    end
    --发送理牌日志
    self:sendSortCardLog()

    -- 打完一局，若每日转盘是缺少对局状态，则更新状态
    LoginLotteryModel:checkGameBoutEnough()

    local player=mymodel('hallext.PlayerModel'):getInstance()
    player:update({'UserGameInfo'})

    --判断是否提示开启惊喜夺宝
    local ExchangeLotteryModel = require("src.app.plugins.ExchangeLottery.ExchangeLotteryModel"):getInstance()
    local user = mymodel("UserModel"):getInstance()
    local channelOpen = ExchangeLotteryModel:GetChannelOpen()
    local activityOpen = ExchangeLotteryModel:GetActivityOpen()

    if channelOpen and not activityOpen then
        local limit = ExchangeLotteryModel:GetBoutLimit()
        if limit then
            if user.nBout + 1 >= limit then
                ExchangeLotteryModel:gc_GetExchangeLotteryInfo(true)
            end
        end
    end

    local BroadcastModel = mymodel("hallext.BroadcastModel"):getInstance()
    BroadcastModel:ReStartInsertMessageEx()

    my.scheduleOnce(function()
        WinningStreakModel:gc_GetWinningStreakInfo()  --请求连胜挑战数据
    end, 2)

    --自动补银
    --刷新银两
    player:update({'SafeboxInfo','MemberInfo','UserGameInfo'})
    print("before do autosupply")
    my.scheduleOnce(function()
        if self:isSupportAutoSupply() then
            self:doSupply()
        end
    end, 2)

    --刷新表情按钮
    self._baseGameScene:UpdateExpressionBtnStatus()

    -- 更新邀请有礼老玩家对局缓存
    if OldUserInviteGiftModel:isRedPacketEnable() and OldUserInviteGiftModel:isQualificationJudgeCache() then
        OldUserInviteGiftModel:addBoutCache()
    end 
end

function MyGameController:onContinualWinInfo(data)
    local ContinualWinInfo = nil
    if self._baseGameData then
        ContinualWinInfo = self._baseGameData:getContinualWinInfo(data)
    end
    if ContinualWinInfo then
        my.scheduleOnce(function()
            if self:isInGameScene() == false then return end
            self._baseGameScene:addContinualWinInfo(ContinualWinInfo)
        end, 2.1)
    end
end

function MyGameController:onRobot()
    if self:isGameRunning() then
        local status = self._baseGameUtilsInfoManager:getStatus()
        if self:IS_BIT_SET(status, BaseGameDef.BASEGAME_TS_WAITING_THROW) then         
            self:onAutoPlay(not self._bAutoPlay)
        end
    end
end

function MyGameController:isSameGroup(chairNO)
    --TODO
    if chairNO == self:getNextChair(self:getNextChair(self:getMyChairNO())) then       
        return true
    end
    return false
end

function MyGameController:autoPlay()
    local SKHandCardsManager        = self._baseGameScene:getSKHandCardsManager()
    if not self._baseGameUtilsInfoManager or not SKHandCardsManager then
        return
    end

    -- 出牌阶段更智能一点
    if self:isClockPointToSelf() then
        local status = self._baseGameUtilsInfoManager:getStatus()
        if self:IS_BIT_SET(status, BaseGameDef.BASEGAME_TS_WAITING_THROW) then
            local waitChair = self._baseGameUtilsInfoManager:getWaitChair()
            if waitChair and waitChair ~= -1 and self:isSameGroup(waitChair) then
                
                local myHandCards = SKHandCardsManager:getSKHandCards(self:getMyDrawIndex())
                if not myHandCards then 
                    self:onPassCard()
                    return 
                end
                local inhandCards, cardsCount = myHandCards:getHandCardIDs()
                SKHandCardsManager:selectMyCardsByIDs(inhandCards, cardsCount)
                if self:ope_CheckSelect() then
                    self:onThrow()
                    return
                end
                SKHandCardsManager:ope_UnselectSelfCards()

                self:onPassCard()
                return
            end
            SKHandCardsManager:resetRemind()
            self:onHint()
            if self:ope_CheckSelect() then
                self:onThrow()
                return
            end

            if SKHandCardsManager:isFirstHand() then
                self:onThrowCard(self:getAutoThrowCardIDs())
            else
                self:onPassCard()
            end

            return
        end
    end

    self:onGameClockZero()
end

function MyGameController:GetSortCardFlag()
    return self._sortFlag
end

function MyGameController:getArrageCardMode()
    if self._baseGameScene:isVerticalCardsMode() == true then
        return MyGameDef.SORT_CARD_BY_VERTICAL
    else
        return MyGameDef.SORT_CARD_BY_CROSS
    end
end

function MyGameController:SetSortCardFlag(flag)
    self._sortFlag = flag
end

function MyGameController:onRule()
    local rule = self._baseGameScene:getGameRule()
    if rule then
        rule:showRule(true)
    end
end

function MyGameController:getTableChairCount()
    return MyGameDef.MY_TOTAL_PLAYERS
end

function MyGameController:getSKTotalCards()
    return MyGameDef.MY_TOTAL_CARDS
end

function MyGameController:getChairCardsCount()
    return MyGameDef.MY_CHAIR_CARDS --一个座位最大牌数
end

function MyGameController:getStartChairCardsCount()
    return SKGameDef.SK_CHAIR_CARDS --发牌时初始手牌数
end

function MyGameController:getTopCardsCount()
    return MyGameDef.MY_TOP_CARD
end

function MyGameController:containsTouchLocation_GameRule(gameRule, x, y)
    local bResult = false
    if gameRule then
        local panel = gameRule:getChildByName("Panel_Rule")
        if panel then
            local pos = cc.p(panel:getPosition())
            local ppos = panel:getParent():convertToWorldSpace(pos)
            local node = self._baseGameScene._gameNode:getChildByName("Operate_Panel")
            local position = node:convertToNodeSpace(ppos)
            local s = panel:getBoundingBox()
            local touchRect = cc.rect(position.x - s.width / 2, position.y - s.height / 2, s.width, s.height)
            bResult = cc.rectContainsPoint(touchRect, cc.p(x, y))
        end
    end
    return bResult
end

function MyGameController:onTouchBegan(x, y)

    local SKGameTools = self._baseGameScene:getTools()
    if SKGameTools then
        if SKGameTools:containsTouchLocation(x, y) then
            return
        else
            self:onCancelRobot()
        end
    end

    local curScene = cc.Director:getInstance():getRunningScene()
    local gameRule = curScene:getChildByName("GameRulePlugin")
    if gameRule and gameRule:isVisible() then
        if self:containsTouchLocation_GameRule(gameRule, x,y) then
            return
        end
    end

    local SKOpeBtnManager = self._baseGameScene:getSKOpeBtnManager()
    if SKOpeBtnManager then
        if SKOpeBtnManager:containsTouchLocation(x, y) then
            self._touchBeginInOpeBtn = true
            return
        end
    end

    local SKGameScene = self._baseGameScene
    if SKGameScene then
        if SKGameScene:containsTouchLocation(x, y) then
            return
        end
    end

    local playerManager = self._baseGameScene:getPlayerManager()
    if playerManager then
        if playerManager:containsTouchInfoLocation(x, y) then
            return
        end
        if not playerManager:containsTouchLocation(x, y) then
            playerManager:onHidePlayerInfo()
        else
            return
        end
    end

    --临时调整卡牌和操作按钮触摸层级
    self:_adjustTouchPriBetweenCardAndOperateBtn()

    local SKHandCardsManager = self._baseGameScene:getSKHandCardsManager()
    if SKHandCardsManager then
        if not SKHandCardsManager:containsTouchLocation(x, y) then
            SKHandCardsManager:ope_UnselectSelfCards()
            --要不起时点击空白区域直接pass
            if self._cardStatus == MyGameController._CARD_STATUS.NO_BIGGER then 
                self:onPassCard()
                self._cardStatus = MyGameController._CARD_STATUS.NORMAL
            end
            SKHandCardsManager:resetSelectShapeIndex()
        else
            SKHandCardsManager:touchBegan(x, y)
        end
    end
end

function MyGameController:onTouchMoved(x, y)

    local SKOpeBtnManager = self._baseGameScene:getSKOpeBtnManager()
    if SKOpeBtnManager then
        if SKOpeBtnManager:containsTouchLocation(x, y) then
            if self._touchBeginInOpeBtn ==  true then
                return
            end
        end
    end

    local curScene = cc.Director:getInstance():getRunningScene()
    local gameRule = curScene:getChildByName("GameRulePlugin")
    if gameRule and gameRule:isVisible() then
        if self:containsTouchLocation_GameRule(gameRule, x,y) then
            return
        end
    end
    
    local playerManager = self._baseGameScene:getPlayerManager()
    if playerManager then
        if playerManager:containsTouchInfoLocation(x, y) then
            return
        end
        if not playerManager:containsTouchLocation(x, y) then
            playerManager:onHidePlayerInfo()
        else
            return
        end
    end

    local SKHandCardsManager = self._baseGameScene:getSKHandCardsManager()
    if SKHandCardsManager then
        if SKHandCardsManager:containsTouchLocation(x, y) then
            SKHandCardsManager:touchMove(x, y)
        end
    end
end

function MyGameController:onTouchEnded(x, y)
    --恢复卡牌和操作按钮触摸层级
    self:_recoverTouchPriBetweenCardAndOperateBtn()

    if self:isAutoPlay() then
        return
    end

    local SKOpeBtnManager = self._baseGameScene:getSKOpeBtnManager()
    if SKOpeBtnManager then
        if SKOpeBtnManager:containsTouchLocation(x, y) then
            if self._touchBeginInOpeBtn ==  true then
                self._touchBeginInOpeBtn = false
                return
            end
        end
    end

    --[[local SKGameScene = self._baseGameScene
    if SKGameScene then
        if SKGameScene:containsTouchLocation(x, y) then
            return
        end
    end]]

    local SKHandCardsManager = self._baseGameScene:getSKHandCardsManager()
    if SKHandCardsManager then
        SKHandCardsManager:touchEnd(x, y)
    end
end

function MyGameController:_adjustTouchPriBetweenCardAndOperateBtn()
    if true == self._baseGameScene:isVerticalCardsMode() then
        local SceneNode = self._baseGameScene._gameNode

        local nodeOpeBtn = SceneNode:getChildByName("Node_OperationBtn")
        if nodeOpeBtn._isAdjustedTouchPriBetweenCardAndOpeBtn ~= true then
            nodeOpeBtn._touchPriRaw = nodeOpeBtn:getLocalZOrder()
            nodeOpeBtn:setLocalZOrder(MyGameDef.MY_ZORDER_CARD_HAND - 1)
            nodeOpeBtn._isAdjustedTouchPriBetweenCardAndOpeBtn = true
        
            local clock = self._baseGameScene:getClock()
            clock._touchPriRaw = clock:getMyClockZorder()
            clock:setMyClockZorder(MyGameDef.MY_ZORDER_CARD_HAND - 1)
        end
    end
end

function MyGameController:_recoverTouchPriBetweenCardAndOperateBtn()
    local SceneNode = self._baseGameScene._gameNode
    local nodeOpeBtn = SceneNode:getChildByName("Node_OperationBtn")

    if nodeOpeBtn._isAdjustedTouchPriBetweenCardAndOpeBtn == true then
        nodeOpeBtn._isAdjustedTouchPriBetweenCardAndOpeBtn = false

        if nodeOpeBtn._touchPriRaw then
            if nodeOpeBtn._touchPriRaw <= 0 then nodeOpeBtn._touchPriRaw = MyGameDef.MY_ZORDER_ARENAINFO end
            nodeOpeBtn:setLocalZOrder(nodeOpeBtn._touchPriRaw)   
        end

        local clock = self._baseGameScene:getClock()
        if clock._touchPriRaw then
            if clock._touchPriRaw < 0 then clock._touchPriRaw = MyGameDef.MY_ZORDER_ARENAINFO end
            clock:setMyClockZorder(clock._touchPriRaw)
        end
    end
end

function MyGameController:OPE_AddBomb(cardsThrow)
    --if self._baseGameUtilsInfoManager._utilsStartInfo.nBaseDeposit <= 0 then return end
    local Deposit = self._baseGameUtilsInfoManager._utilsStartInfo.nBaseDeposit
    if PublicInterFace.IsStartAsTimingGame() then --定时赛使用底分
        Deposit = self._baseGameUtilsInfoManager._utilsStartInfo.nBaseScore
    end

    if cardsThrow.dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_TONGHUASHUN then
        self._baseGameUtilsInfoManager:getPlayInfoByChairNo(cardsThrow.nChairNO).nBombCount[1] = self._baseGameUtilsInfoManager:getPlayInfoByChairNo(cardsThrow.nChairNO).nBombCount[1] + 1
        
        if cardsThrow.nChairNO == self:getMyChairNO() then
            self:ChangeParamTask(4,1)
        end
    elseif cardsThrow.dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_SUPER_BOMB then
        self._baseGameUtilsInfoManager:getPlayInfoByChairNo(cardsThrow.nChairNO).nBombCount[2] = self._baseGameUtilsInfoManager:getPlayInfoByChairNo(cardsThrow.nChairNO).nBombCount[2] + 1
        --这里做炸弹额外积分处理
        if Deposit > 0 then
            for i = 0, 3 do
                if i == cardsThrow.nChairNO then
                    self:OPE_ShowBombBonu(i, Deposit*3)
                elseif i == (cardsThrow.nChairNO+2)%4 then
                    self:OPE_ShowBombBonu(i, Deposit)
                else 
                    self:OPE_ShowBombBonu(i, -Deposit*2)
                end
            end
        end       
    elseif cardsThrow.dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_4KING then
        self._baseGameUtilsInfoManager:getPlayInfoByChairNo(cardsThrow.nChairNO).nBombCount[3] = self._baseGameUtilsInfoManager:getPlayInfoByChairNo(cardsThrow.nChairNO).nBombCount[3] + 1
        --这里做炸弹额外积分处理
        if Deposit > 0 then
            for i = 0, 3 do
                if i == cardsThrow.nChairNO then
                    self:OPE_ShowBombBonu(i, Deposit*6)
                elseif i == (cardsThrow.nChairNO+2)%4 then
                    self:OPE_ShowBombBonu(i, Deposit*2)
                else 
                    self:OPE_ShowBombBonu(i, -Deposit*4)
                end
            end
        end     
   elseif cardsThrow.dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_BOMB and cardsThrow.nCardsCount == 5 then      
        -- TODO: 五炸翻倍的变量控制
        local isSupportDouble = self:isSupport5BombDouble()
        if isSupportDouble == true then
            self._baseGameUtilsInfoManager:getPlayInfoByChairNo(cardsThrow.nChairNO).nBombCount[1] = self._baseGameUtilsInfoManager:getPlayInfoByChairNo(cardsThrow.nChairNO).nBombCount[1] + 1
        
            if cardsThrow.nChairNO == self:getMyChairNO() then
                self:ChangeParamTask(4,1)
            end
        end
    end
        
    self:OPE_FreshBomgRecord()
end

function MyGameController:OPE_ShowBombBonu(nChairno, nBoun)
    local gameplayer = self._baseGameScene:getPlayerManager()
    gameplayer:showBomeSilverValue(self:rul_GetDrawIndexByChairNO(nChairno) , nBoun)
end

function MyGameController:OPE_FreshBomgRecord()
    local nMyChair = self:getMyChairNO()
    local nMyFriend = self:rul_GetChairNOByDrawIndex(3)
    local nEnmey = self:rul_GetChairNOByDrawIndex(2)
    local nEnmeyFriend = self:rul_GetChairNOByDrawIndex(4)

    local BomeCount = self._baseGameUtilsInfoManager:getPlayInfoByChairNo(nMyChair).nBombCount[1] + self._baseGameUtilsInfoManager:getPlayInfoByChairNo(nMyChair).nBombCount[2]
                        + self._baseGameUtilsInfoManager:getPlayInfoByChairNo(nMyFriend).nBombCount[1] + self._baseGameUtilsInfoManager:getPlayInfoByChairNo(nMyFriend).nBombCount[2]
    local nFan = 1
    nFan = nFan * (2 ^ BomeCount)
    if self._baseGameUtilsInfoManager:getPlayInfoByChairNo(nMyChair).nBombCount[3] > 0 then
        nFan = nFan * 3
    elseif self._baseGameUtilsInfoManager:getPlayInfoByChairNo(nMyFriend).nBombCount[3] > 0 then
        nFan = nFan * 3
    end

    self._baseGameScene._MyPanel_Odds:getChildByName("Font_Win"):setString(tostring(nFan))

    BomeCount = self._baseGameUtilsInfoManager:getPlayInfoByChairNo(nEnmey).nBombCount[1] + self._baseGameUtilsInfoManager:getPlayInfoByChairNo(nEnmey).nBombCount[2]
                    + self._baseGameUtilsInfoManager:getPlayInfoByChairNo(nEnmeyFriend).nBombCount[1] + self._baseGameUtilsInfoManager:getPlayInfoByChairNo(nEnmeyFriend).nBombCount[2]
    nFan = 1
    nFan = nFan * (2 ^ BomeCount)
    if self._baseGameUtilsInfoManager:getPlayInfoByChairNo(nEnmey).nBombCount[3] > 0 then
        nFan = nFan * 3
    elseif self._baseGameUtilsInfoManager:getPlayInfoByChairNo(nEnmeyFriend).nBombCount[3] > 0 then
        nFan = nFan * 3
    end
    
    self._baseGameScene._MyPanel_Odds:getChildByName("Font_Lost"):setString(tostring(nFan))

    my.scheduleOnce(function()
        if self:isInGameScene() == false then return end
        if self._baseGameScene and self._baseGameScene._MyPanel_Odds then
            self._baseGameScene._MyPanel_Odds:setVisible(self.haveBombDouble)
        end
    end)
end

function MyGameController:selfHeadcallbackFuc(code,path,imageStatus)
    print('selfHeadcallbackFuc')

    local show=false
    if code == cc.exports.ImageLoadActionResultCode.kImageLoadGetLocalSuccess then
        show=true
    elseif code ==cc.exports.ImageLoadActionResultCode.kImageLoadOnlineSuccess then 
        show=true
    end
    
    if(show==false)then
        printf("~~~~~~~~~~~~not show self head~~~~~~~~~~~~~~~~~~~~")
        --return
    end

    local user = mymodel('UserModel'):getInstance()
    self:setPlayerHead(user.nUserID, path)

end

function MyGameController:getSelfHeadImage()
    local imageCtrl = require('src.app.BaseModule.ImageCtrl')
    printf("MyGameController:getSelfHeadImage")
    imageCtrl:getSelfImage('400-400', handler(self,self.selfHeadcallbackFuc))
end

function MyGameController:onEnterGameOK(data)
    UIHelper:recordRuntime("EnterGameScene", "MyGameController:onEnterGameOK begin")

    --房间跳转变量更新下
    cc.exports._isEnterRoomForGameScene = false
    --self._leaveGameOk = false
    self:stopJumpOtherRoomSchedule() --进入成功清理下数据

    local gameEnterInfo, soloPlayers = MyGameController.super.onEnterGameOK(self, data)

    self:stopAutoQuitTimer()
    
    self._canReturnChartered = false

    self:getSelfHeadImage()

    self:reqExchangeRoundTask() --获取兑换任务
    --AssistConnect:SendGetTaskForEnterGame(self)
    self:IsHaveTaskFinish()

    if not self._baseGameUtilsInfoManager then
        return
    end

    self._baseGameUtilsInfoManager._utilsStartInfo.nRank = {1,1,1,1}
    self:ope_GameInfoShow(false)

    -- 进入房间也需要，主要是跳转房间的时候确保 按钮状态正常（中级放不显示，高级房显示）
    self._baseGameScene:initSelectTableBtn()
    --[[--测试结束界面的牌展示
    local nCardID = {}
    for i = 1, 27 do
        nCardID[i] = i
    end
    
    local SKHandCardsManager = self._baseGameScene:getSKHandCardsManager()
    for drawIndex = 1, 4 do
        if 0 < drawIndex  and drawIndex ~= self:getMyDrawIndex() then
            SKHandCardsManager:setHandCardsCount(drawIndex, #nCardID)
            SKHandCardsManager:setHandCardsWin(drawIndex, nCardID)
            SKHandCardsManager:sortHandCards(drawIndex)
        end
    end--]]
    --[[local gameWin = {}
    gameWin.nPlace = {4,1,2,3}
    gameWin.nDepositDiffs = {-100,-100,100,-100,0,0,0,0}
    gameWin.nScoreDiffs = {100,-100,100,-100,0,0,0,0}
    gameWin.nWinFees = {25,25,25,25,25,25,25,25}
    gameWin.nNextRank = {4,2,4,2}
    gameWin.BomeRate = 2
    gameWin.upRankEx = 2
    gameWin.nLevelExpUp = {1000,1000,1000,1000}
    self._selfChairNO = 1
    self:showGameResultInfo(gameWin)]]
    --self:onTakeDeposit(100, 0)

    --测试代码
    --[[my.scheduleOnce(function()
        self:setPlayerDeposit(self:getMyDrawIndex(), 199)
        my.scheduleOnce(function()
            self:onSafeBoxFailed(BaseGameDef.BASEGAME_GR_SAFEBOX_DEPOSIT_DIFFER, 0, {})
        end, 3.0)
    end, 5)]]--

    UIHelper:recordRuntime("EnterGameScene", "MyGameController:onEnterGameOK end")
    UIHelper:printRuntime("EnterGameScene")

    --第一局屏蔽跑马灯
    local BroadcastModel = mymodel("hallext.BroadcastModel"):getInstance()
    local user = mymodel("UserModel"):getInstance()
    if user.nBout and user.nBout == 0 then
        BroadcastModel:stopInsertMessage()
    end

    UIHelper:sendGameLoadingLog(1)

    if PUBLIC_INTERFACE.IsStartAsAnchorMatchGame() then
        local AnchorTableModel = import('src.app.plugins.AnchorTable.AnchorTableModel'):getInstance()    
        local tableRule = AnchorTableModel:getTableRule()
        if tableRule and tableRule.AnchorUserID == user.nUserID then
            -- 上报规则
            self._baseGameConnect:reqSetGameRuleInfo(tableRule)
            self:setRuleString(tableRule)
        else
            -- 获取规则
            self._baseGameConnect:reqGetGameRuleInfo()
        end
    elseif PUBLIC_INTERFACE.IsStartAsTeam2V2() then
        if Team2V2Model:getTeamMateCount() == 1 then
            self:onStartGame()
        elseif Team2V2Model:getTeamMateCount() == 2 then
            if #soloPlayers == 2 then
                self:onStartGame()
            end
        end
    end

    --test new kpi start
    local analyticsPlugin = plugin.AgentManager:getInstance():getAnalyticsPlugin()
    if analyticsPlugin then
        if analyticsPlugin.setCommonInfoMap then
            local uitleInfoManager  = self:getUtilsInfoManager()
            local roomID = uitleInfoManager:getRoomID()
            local params =
            {
                gameId    = tostring(my.getGameID()),   --客户端游戏id
                gameCode  = my.getGameShortName(),      --客户端游戏缩写(不是游戏服务端的缩写，要真实客户端的缩写）
                gameVers  = my.getGameVersion(),        --客户端游戏版本
                roomNo    = tostring(roomID),
            }
            analyticsPlugin:setCommonInfoMap(params)

            local deviceInfo = analyticsPlugin:getDisdkDeviceInfo()
            print("new kpi--- deviceInfo")
            dump(deviceInfo)
        end
    end
    --test new kpi end
end

function MyGameController:initGameController(baseGameScene)
    MyGameController.super.initGameController(self, baseGameScene)

    local roomInfo = PublicInterFace.GetCurrentRoomInfo()
    local roomType = nil
    if roomInfo then
        roomType = roomInfo["type"]
    end
    
    self.haveBombDouble = true
    if (roomType == 1) then
        self.haveBombDouble = false
    end

    self._downExpressionTimer = nil
    self._canDownExpessionBtn = true
    self.gameWinBnResetGame = 0
    self:stopDownExpressionBtnTimer()
end

function MyGameController:onRestart()
    local uitleInfoManager  = self:getUtilsInfoManager()
    local nCurRoomID        = uitleInfoManager:getRoomID()
    local timingGameRoomID  = TimingGameModel:getTimingGameRoomID()
    if nCurRoomID == timingGameRoomID and TimingGameModel:isAbortBoutTimeNotEnough() then
        TimingGameModel:showTips("因结算需要，最后5分钟停止比赛!")
        return
    end    
    
    --MyGameController.super.onRestart(self)
    self:onCloseResultLayer()
    self:clearGameTable()
    self:ResetArrageButton()
    self:resetPlayer()
    if self._canReturnChartered then    
        if self:isTeamGameRoom() and self:isHallEntery() then
            if not PUBLIC_INTERFACE.IsStartAsTeam2V2() then
                self:tipMessageByKey("G_GAME_RETURN_TEAMROOM_TIP")
                self:showCharteredRoom(true)
            end
            if self:isNeedDeposit() then
                self:LookSafeDeposit()
                self.bGameToRestart = false
            end
            return
        end
    end
    self._canReturnChartered = true
    if self:isNeedDeposit() then
        self:LookSafeDeposit()
        self.bGameToRestart = true
    else
        --玩家当前积分
        local result = self:onOutScoreRoom()
        print("MyGameController:onRestart result", result)
        if not result then
            self:onStartGame()
        end
    end
end

function MyGameController:onCloseResultLayerEx()
    self:onCloseResultLayer()
    self:ResetArrageButton()

    if self._canReturnChartered then    
        if self:isTeamGameRoom() and self:isHallEntery() then
            if not PUBLIC_INTERFACE.IsStartAsTeam2V2() then
                self:tipMessageByKey("G_GAME_RETURN_TEAMROOM_TIP")
                self:showCharteredRoom(true)
            end
--            return
        end
    end
    self._canReturnChartered = true


    if PUBLIC_INTERFACE.IsStartAsAnchorMatchGame() then
        if self:canLeaveAnchorMatchGame() then
            self:onQuit()
            return
        end
    end

    if PublicInterFace.IsStartAsTimingGame() then --是定时赛房间
        local btnType, status = TimingGameModel:getBtnStatus()
        if btnType ~= 1 or self._TimingGame_onQuit then
            self._TimingGame_onQuit = nil
            self:onQuit()
            return 
        end
    end

    if not PUBLIC_INTERFACE.IsStartAsTeam2V2() then -- 不是组队2V2房间
        if self:isNeedDeposit() then
            self:LookSafeDeposit()
            self.bGameToRestart = false
            --积分场弱化
            self:onJumpToScoreRoom()
        else
            self:onOutScoreRoom()
        end
    end
end

function MyGameController:LookSafeDeposit()
    print("LookSafeDeposit begin")
    if not self:isNeedDeposit() then return end

    self:onUpdateSafeBox()  --查询保险箱
    self:setResponse(MyGameDef.MY_WAITING_JUDGE_WELFARE)
    print("MyGameController:LookSafeDeposit setResponse")
end

function MyGameController:JudgeWelfare(data)

    if cc.exports.isSafeBoxSupported() then
        local safeBoxDeposit = nil
        if self._baseGameData then
            safeBoxDeposit = self._baseGameData:getSafeBoxDepositInfo(data)
        end
        if not safeBoxDeposit then  return end
        
        self.m_nSalfDespoit = safeBoxDeposit.nDeposit
        self.m_nHaveSecurePwd = safeBoxDeposit.bHaveSecurePwd
    else
        self.m_nSalfDespoit = 0
        self.m_nHaveSecurePwd = false
    end

    local ReliefData = import("src.app.Game.mMyGame.ReliefData")
    ReliefData._gameController = self
    ReliefData:create()
end

function MyGameController:setReliefState(data, reliefData)
    assert(data,'') 
    local ReliefData     = import("src.app.Game.mMyGame.ReliefData")
    ReliefData._gameController = nil

    local config=data.config
    local state=data.state

    local bCanGetWelfare = true
    --[[local nWelfareID = self:GetWelfareID()
    if nWelfareID <= 0 then
        bCanGetWelfare = false
    end
    local gameplayer = self._gameController:getPlayerInfoManager()
    local nDeposit = gameplayer:getSelfDeposit() + self.m_nSalfDespoit
   
    if (reliefData.timesLeft or 0) <= 0 then --已经领完
        bCanGetWelfare = false
    end--]]

    if state ~= 'SATISFIED' then
        bCanGetWelfare = false
    end

    local gameplayer = self:getPlayerInfoManager()
    local nDeposit = gameplayer:getSelfDeposit() + self.m_nSalfDespoit
    
    if state == 'UNSATISFIED' and nDeposit < config.Limit.LowerLimit then
        bCanGetWelfare = true
    end

    if bCanGetWelfare then
        print("takeRelief")
        --注释了直接弹出低保界面的逻辑
        --展示界面  --2019-04-29
        local user=mymodel('UserModel'):getInstance()
        local nBout = user.nBout
        local nBoutLimit = 100
        if cc.exports._gameJsonConfig and cc.exports._gameJsonConfig.ReliefPopUpBout then
            nBoutLimit = cc.exports._gameJsonConfig.ReliefPopUpBout
        end
        if nBout + 1 >= nBoutLimit then
            --弹首充框
            if FirstRechargeModel:isInGameAlive()  then
                my.informPluginByName({pluginName='FirstRecharge'})
                self.m_nSalfDespoit = nil
                return 
            end
            if BankruptcyModel:isBankruptcyBagShow() then
                local tag = self._baseGameScene:showBankruptcyGiftResult(function()
                    my.informPluginByName({
                        pluginName = "ReliefCtrl",
                        params = {
                            fromSence = ReliefDef.FROM_SCENE_GAMECONTROLLER,
                            promptParentNode = self._baseGameScene,
                            leftTime = reliefData.timesLeft,
                            limit = config.Limit
                        }})
                end)
                if tag == 1 then
                    self.m_nSalfDespoit = nil
                    return
                end
            end
            --先展示充值界面,不充值则弹出低保界面
            self:OnGetItemInfoEx(reliefData.timesLeft,config.Limit)
        else
            my.informPluginByName({pluginName='ReliefCtrl',params={fromSence = ReliefDef.FROM_SCENE_GAMECONTROLLER, promptParentNode = self._baseGameScene, leftTime = reliefData.timesLeft, limit = config.Limit}})
        end

        self.m_nSalfDespoit = nil
    else
        local relief = mymodel('hallext.ReliefActivity'):getInstance()
        if relief:isVideoAdReliefValid() then
            -- 视频低保
            my.informPluginByName({pluginName='ReliefCtrl',params={fromSence = ReliefDef.FROM_SCENE_GAMECONTROLLER, promptParentNode = self._baseGameScene, VideoAdRelief = true}})
        else
            if self.bGameToRestart then
                self:onStartGame()
            end
        end
    end
end

function MyGameController:onChooseRechargeType(showJumpBtn)
    --触发限时礼包
    local relief = mymodel('hallext.ReliefActivity'):getInstance()
    if relief then
        -- 已经触发限时或者没有低保次数，先弹限时，没有限时，普通充值；如果有低保次数，直接弹普通充值
        local bankruptcy = import('src.app.plugins.Bankruptcy.BankruptcyModel'):getInstance()
        if bankruptcy:isBankruptcyBagShow() or (relief.state == relief.USED_UP) then
            local tag = self._baseGameScene:showBankruptcyGiftResult(function ()
                local limit = ((relief.config or {}).Limit or {}).LowerLimit or 0
                if relief.state == 'SATISFIED' 
                and user.nDeposit < limit then
                    my.informPluginByName({pluginName='ReliefCtrl',params={
                        fromSence = ReliefDef.FROM_SCENE_GAMESCENE, 
                        promptParentNode = self, 
                        leftTime = user.reliefData.timesLeft, 
                        limit = relief.config.Limit}
                    })
                elseif relief:isVideoAdReliefValid() then
                    -- 视频低保
                    my.informPluginByName({pluginName='ReliefCtrl',params={
                        fromSence = ReliefDef.FROM_SCENE_GAMESCENE, 
                        promptParentNode = self, 
                        VideoAdRelief = true}
                    })
                end
            end)
            if tag == 0 then
                if showJumpBtn then
                    self:OnGetItemInfo(nil,showJumpBtn)
                else
                    self:OnGetItemInfo()
                end
            end
        else
            if showJumpBtn then
                self:OnGetItemInfo(nil,showJumpBtn)
            else
                self:OnGetItemInfo()
            end
        end

        --积分场弱化
        self:onJumpToScoreRoom()
    else
        if showJumpBtn then
            self:OnGetItemInfo(nil,showJumpBtn)
        else
            self:OnGetItemInfo()
        end
    end
    
end

-- [jfcrh] 弱化积分场
function MyGameController:onJumpToScoreRoom()
    local playerInfoManager = self:getPlayerInfoManager()
    if not playerInfoManager then return end

    local weakOpen = WeakenScoreRoomModel:onGetWeakOpen()
    if not weakOpen then --没开限制活动
        return
    end

    local dataMap = my.readCache("JumpToScoreRoomTag.xml")
    dataMap = checktable(dataMap)
    local currentTime = os.date("%Y-%m-%d", os.time())
    local cacheTime = dataMap.queryDate

    if dataMap and currentTime == cacheTime and dataMap.nUserID == playerInfoManager:getSelfUserID() then
        return
    end

    local silverStatus = WeakenScoreRoomModel:onCheckSliverStatus()

    print("MyGameController onJumpToScoreRoom  silverStatus is ", silverStatus)
    if not silverStatus then
        return
    end

    local function onJump()
        local config = cc.exports.GetRoomConfig()

        local function okCallback()
            self._gotoScoreRoom = true
            self._baseGameConnect:gc_LeaveGame()
        end
        my.informPluginByName({
            pluginName="ChooseDialog",
            params={
                tipContent=config['RELIEF_USERD_UP_FOR_SCORE_INFO'],
                onOk=okCallback,
            }})

        local data = {}
        data.nUserID = playerInfoManager:getSelfUserID()
        data.queryDate = os.date("%Y-%m-%d", os.time())
        data = checktable(data)
        my.saveCache("JumpToScoreRoomTag.xml",data)

        print("MyGameController onJumpToScoreRoom")
    end

    if silverStatus then  --已经破产
        if WeakenScoreRoomModel:onCheckJumpStatus() then --已经触发，或者达到触发条件
            print("onJumpToScoreRoom 1")
            onJump()
        elseif WeakenScoreRoomModel:onCheckStatusFromServer() then --触发信息已经过期，重新获取
            print("onJumpToScoreRoom 2")
            cc.exports.nScoreInfoNeedResponse = 0
            WeakenScoreRoomModel:sendGetTriggerInfo()
            my.scheduleOnce(function()
                if cc.exports.nScoreInfoNeedResponse == 0 then  --防止客户端跟服务器之间连接有问题
                    print("onJumpToScoreRoom 3")
                    onJump()
                elseif cc.exports.nScoreInfoNeedResponse == 1 then
                    print("onJumpToScoreRoom 4")
                    if WeakenScoreRoomModel:onCheckTriggerLimitStatusAgain() then
                        print("onJumpToScoreRoom 5")
                        onJump()
                    end
                end
                cc.exports.nScoreInfoNeedResponse = -1
            end, 1)
        end
    end
end

-- nLackDeposit:缺少的银两数量
function MyGameController:onSectionDespositNotEnough(nLackDeposit)
    if not self._baseGameScene then return end

    local playerInfoManager = self:getPlayerInfoManager()
    if not playerInfoManager then return end

    local playerInfo = playerInfoManager:getPlayerInfo(self:getMyDrawIndex())
    if not playerInfo then return end

    --[[local mainCtrl = cc.load('MainCtrl'):getInstance()
    if not mainCtrl then return end]]--
    local user = mymodel('UserModel'):getInstance()
    if nLackDeposit > 0 and user:getSafeboxDeposit() >= nLackDeposit then
    --if nLackDeposit > 0 and mainCtrl._nSafeboxDeposit >= nLackDeposit then
        --取银
        local takeDepositNum = nLackDeposit
        self.m_takeDepositNum = nLackDeposit

        self._baseGameScene:addTakeSilverPrompt(takeDepositNum)
    else
        --触发限时礼包
        self:onChooseRechargeType()
    end
end

function MyGameController:onStartFailedNotEnough(data)
    if not self._baseGameScene then return end

    if self.m_nSalfDespoit == nil then
        if self:isNeedDeposit() then
            self:LookSafeDeposit()
            self.bGameToRestart = true
        end
        return
    end

    local startFailedNotEnough = nil
    if self._baseGameData then
        startFailedNotEnough = self._baseGameData:getStartFailedNotEnoughInfo(data)
    end

    local lackDeposit = startFailedNotEnough.nMinDeposit - startFailedNotEnough.nDeposit
    self._lackDeposit = lackDeposit
    if startFailedNotEnough then     
        local msg = string.format(self:getGameStringByKey("G_MOVEDEPOSIT_NOTENOUGH"), lackDeposit)

        if self.m_nSalfDespoit >= lackDeposit then
            --取银
            --local utf8Msg = MCCharset:getInstance():gb2Utf8String(msg, string.len(msg))
            local takeDepositNum = self.m_nSalfDespoit
            local uitleInfoManager  = self:getUtilsInfoManager()
            local nRoomID         = uitleInfoManager:getRoomID()
            local depositeLimit = cc.exports.getTakeDepositeLimit(nRoomID, startFailedNotEnough.nMinDeposit)
            if self.m_nSalfDespoit >= depositeLimit then
                takeDepositNum = depositeLimit
                takeDepositNum = takeDepositNum - startFailedNotEnough.nDeposit
            end
            self.m_takeDepositNum = takeDepositNum   

            self._baseGameScene:addTakeSilverPrompt(takeDepositNum)
        else
            --充值
            --[[local utf8Msg = MCCharset:getInstance():gb2Utf8String(msg, string.len(msg))
            local okCallback = function()
                self:onSafeBox()
            end
            self:popSureDialog(utf8Msg, "", "", okCallback, false)--]]
            --触发限时礼包
            -- local uitleInfoManager  = self:getUtilsInfoManager()
            -- local nRoomID         = uitleInfoManager:getRoomID()

            local roomInfo = cc.exports.PUBLIC_INTERFACE.GetCurrentRoomInfo()
            --local utf8Name = MCCharset:getInstance():gb2Utf8String(roomInfo.szRoomName, string.len(roomInfo.szRoomName)) -- 房间名称
            local utf8Name = roomInfo.szRoomName

            local limit = ((cc.exports.gameReliefData or {}).config or {}).Limit
            local lineRelief = 2000
            if limit and limit.LowerLimit then
                lineRelief = limit.LowerLimit
            end
            

            if utf8Name == "新手房" or self:isArenaPlayer() then
                self:onChooseRechargeType()
            elseif startFailedNotEnough.nDeposit>lineRelief then
                self:onChooseRechargeType(true)
            else
                self:onChooseRechargeType()
            end
            --低级房不弹取低级房提示
        end
    end
    self.m_nSalfDespoit = nil
end

function MyGameController:onStartFailedTooHigh(data)
    if not self._baseGameScene then return end
    
    local startFailedTooHigh = nil
    if self._baseGameData then
        startFailedTooHigh = self._baseGameData:getStartFailedTooHighInfo(data)
    end

    if startFailedTooHigh then
        local uitleInfoManager  = self:getUtilsInfoManager()
        local nRoomID         = uitleInfoManager:getRoomID()
        local roomImpl = RoomListModel.roomsInfo[nRoomID]
        --[[local bFind=false
        for i,v in ipairs( cc.exports.RoomModelList )do
            for j,k in ipairs(v.RoomList)do
                local Impl = k.original
                if Impl then
                    if Impl.nRoomID == nRoomID then
                        roomImpl = Impl
                        bFind = true
                        break
                    end
                end
            end
            if bFind then
                break
            end
        end]]--

        --local saveDepositNum = startFailedTooHigh.nDeposit - startFailedTooHigh.nMaxDeposit
        --local saveDepositNum = startFailedTooHigh.nDeposit - roomImpl.nMinDeposit*5
        local saveDepositNum = startFailedTooHigh.nDeposit - roomImpl.nMaxDeposit
        if saveDepositNum < 0 then  saveDepositNum = 0 end --避免异常出现负数的情况

        if self:isTeamGameRoom() and self:isHallEntery() and roomImpl.nMinDeposit <= 500 then
            saveDepositNum = 2000
        end
        self.m_SaveDepositNum = saveDepositNum
        self._baseGameScene:addSaveSilverPrompt(saveDepositNum)
    end
end

function MyGameController:onTakeSafeDeposit(value)
    self.m_takeDepositNum = value or self.m_takeDepositNum
    if self.m_takeDepositNum then       
        self:addPlayerDeposit(self:getMyDrawIndex(), self.m_takeDepositNum)

        local msg = string.format(self:getGameStringByKey("G_SAFEBOX_TAKESUCCEED"), self.m_takeDepositNum)
        self:tipMessageByGBStr(msg)
        --self:tipMessageByKey("G_SAFEBOX_TAKESUCCEED")
        if self._dispatch then
            self._dispatch:updateGameDataForMoney()
        end

        local user=mymodel('UserModel'):getInstance()
        if cc.exports.isSafeBoxSupported() then
            user.nSafeboxDeposit=user.nSafeboxDeposit-self.m_takeDepositNum
        else
            if cc.exports.isBackBoxSupported() then
                user.nBackDeposit=user.nBackDeposit-self.m_takeDepositNum
            end
        end

        if self._safeCallbackParam and not self:isGameRunning() then
            self._needReturnRoomID = self._safeCallbackParam._needReturnRoomID
            cc.exports._isEnterRoomForGameScene = self._safeCallbackParam._isEnterRoomForGameScene
            self._safeCallbackParam = nil
            self:GoBackRoom(cc.exports._isEnterRoomForGameScene)
        end
    end
end

function MyGameController:onSaveSafeDeposit(value)
    local SafeboxModel = import('src.app.plugins.safebox.SafeboxModel'):getInstance()
    SafeboxModel:saveDepositOK(value)

    self.m_SaveDepositNum = value or self.m_SaveDepositNum
    if self.m_SaveDepositNum then
        self:addPlayerDeposit(self:getMyDrawIndex(), -self.m_SaveDepositNum)

        local msg = string.format(self:getGameStringByKey("G_SAFEBOX_SAVESUCCEED"), self.m_SaveDepositNum)
        self:tipMessageByGBStr(msg)
        --self:tipMessageByKey("G_SAFEBOX_SAVESUCCEED")
        if self._dispatch then
            self._dispatch:updateGameDataForMoney()
        end

        local user=mymodel('UserModel'):getInstance()
        if cc.exports.isSafeBoxSupported() then
            user.nSafeboxDeposit=user.nSafeboxDeposit+self.m_SaveDepositNum
        else
            if cc.exports.isBackBoxSupported() then
                user.nBackDeposit=user.nBackDeposit+self.m_SaveDepositNum
            end
        end
     
        if self._safeCallbackParam and not self:isGameRunning() then
            self._needReturnRoomID = self._safeCallbackParam._needReturnRoomID
            cc.exports._isEnterRoomForGameScene = self._safeCallbackParam._isEnterRoomForGameScene
            self._safeCallbackParam = nil
            self:GoBackRoom(cc.exports._isEnterRoomForGameScene)
        end
    end
end

--[[function MyGameController:rechagreInGame(index)   
    local ShopExModel = require("src.app.plugins.shopcenterex.ShopExModel")
    --ShopExModel.Ctrl = self
    ShopExModel:OnPayItemClick(index)
    --local quickRecharge=require("src.app.plugins.QuickRecharge.QuickRechargeCtrl")
    --quickRecharge:createViewNode()
end]]--

function MyGameController:onUpdateRich() --充值成功回调
    --local shopConfig = ShopModel:GetShopTipsConfig()
    --local showText=shopConfig["AccountDepositOK"]
    --my.informPluginByName({pluginName='ToastPlugin',params={tipString=showText,removeTime=2}})
    local user=mymodel('UserModel'):getInstance()
    if(user.nDeposit)then
        self:setPlayerDeposit(self:getMyDrawIndex(), user.nDeposit)
        self._baseGameConnect:TablePlayerForUpdateDeposit(user.nDeposit)
    end

    if self._dispatch then
        self._dispatch:updateGameDataForMoney()
    end

    if self._PayCallbackNeedGobackRoomID then
        self:GoBackRoom(self._PayCallbackNeedGobackRoomID)
        self._PayCallbackNeedGobackRoomID = nil
        if self._baseGameScene._GoBackRoomPrompt then
            self._baseGameScene._GoBackRoomPrompt:removeEventHosts()
            self._baseGameScene._GoBackRoomPrompt:removeFromParentAndCleanup()
            self._baseGameScene._GoBackRoomPrompt = nil
        end

        if self._baseGameScene._mainTakeSilverPrompt then
            self._baseGameScene._mainTakeSilverPrompt:removeEventHosts()
            self._baseGameScene._mainTakeSilverPrompt:removeFromParentAndCleanup()
            self._baseGameScene._mainTakeSilverPrompt = nil
        end
    end
end

function MyGameController:onTakeReliefSuccess(data) --领取低保成功回调
    local user=mymodel('UserModel'):getInstance()
    if(user.nDeposit)then
        self:setPlayerDeposit(self:getMyDrawIndex(), user.nDeposit)

        if self._baseGameConnect then
            self._baseGameConnect:TablePlayerForUpdateDeposit(user.nDeposit)
        end
    end
    if self._dispatch then
        self._dispatch:updateGameDataForMoney()
    end

    if self._PayCallbackNeedGobackRoomID then
        self:GoBackRoom(self._PayCallbackNeedGobackRoomID)
        self._PayCallbackNeedGobackRoomID = nil
    end
end

function MyGameController:onTakeReliefFailed(data) --领取低保失败回调
    local user=mymodel('UserModel'):getInstance()
    if(user.nDeposit)then
        self:setPlayerDeposit(self:getMyDrawIndex(), user.nDeposit)
    end
    local constReliefStrings=cc.load('json').loader.loadFile('ReliefStrings.json')
    local key = data['value']['status']
    local ss = constReliefStrings[tostring(key)]
    my.informPluginByName({pluginName='TipPlugin',params={tipString = ss, removeTime = 2}})
    --self:informPluginByName('TipPlugin',{tipString=ss})
    if self._dispatch then
        self._dispatch:updateGameDataForMoney()
    end

    if self._PayCallbackNeedGobackRoomID then
        self:onExitGameClicked()
    end
end

function MyGameController:OnGetItemInfo(roomID,showJumpBtn) --获取充值信息
    local uitleInfoManager  = self:getUtilsInfoManager()
    local nRoomID         = roomID or uitleInfoManager:getRoomID()
    local roomImpl = RoomListModel.roomsInfo[nRoomID]
    
    --弹首充框
    if FirstRechargeModel:isInGameAlive()  then
        my.informPluginByName({pluginName='FirstRecharge'})
        return 
    end

    local RechargeData = ShopModel:getQuickChargeItemDataForRoom(roomImpl.nMinDeposit, self._lackDeposit)
    if showJumpBtn then
        self._baseGameScene:addRechargePrompt(RechargeData["itemData"]["First_Support"] == 1, RechargeData, nil, showJumpBtn)
    else
        self._baseGameScene:addRechargePrompt(RechargeData["itemData"]["First_Support"] == 1, RechargeData)
    end
end

function MyGameController:OnGetItemInfoEx(timesLeft, limit, roomID) --获取充值信息
    local uitleInfoManager  = self:getUtilsInfoManager()
    local nRoomID         = roomID or uitleInfoManager:getRoomID()
    local roomImpl = RoomListModel.roomsInfo[nRoomID]

    local RechargeData = ShopModel:getQuickChargeItemDataForRoom(roomImpl.nMinDeposit, self._lackDeposit)
    self._baseGameScene:addRechargePromptEx(timesLeft, limit, RechargeData["itemData"]["First_Support"] == 1, RechargeData)
end

function MyGameController:playBonesArmature(ArmaturePath, key)
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(ArmaturePath)
    local armature = ccs.Armature:create(key)
    armature:getAnimation():playWithIndex(0)
    armature:setPosition(display.center)

    local function animationEvent(armatureBack,movementType,movementID)
        local id = movementID
        if movementType == ccs.MovementEventType.loopComplete then
            armature:removeFromParentAndCleanup()
        elseif eventType == ccs. MovementEventType.complete then
            armature:removeFromParentAndCleanup()
        elseif eventType == ccs. MovementEventType.start then
            
        end
    end

    armature:getAnimation():setMovementEventCallFunc(animationEvent)

    local function onFrameEvent( bone,evt,originFrameIndex,currentFrameIndex)
        --[[if (not gridNode:getActionByTag(frameEventActionTag)) or (not gridNode:getActionByTag(frameEventActionTag):isDone()) then
            gridNode:stopAllActions()

            local action =  cc.ShatteredTiles3D:create(0.2, cc.size(16,12), 5, false)
            action:setTag(frameEventActionTag)
            gridNode:runAction(action)
        end--]]
    end

    armature:getAnimation():setFrameEventCallFunc(onFrameEvent)

    
    self._baseGameScene:addChild(armature)
end

function MyGameController:getTaskList()
    local FileNameString = "src/app/plugins/MyTaskPlugin/TaskConfig.json"
    if not cc.exports.isShareSupported() then
        FileNameString = "src/app/plugins/MyTaskPlugin/TaskConfig_noShare.json"
    end
    local content = cc.FileUtils:getInstance():getStringFromFile(FileNameString)
    self._taskConfig = cc.load("json").json.decode(content)
    if not self._taskConfig  then return {} end

    --更新下服务端的配置
    if cc.exports._gameJsonConfig and cc.exports._gameJsonConfig.PhoneGameTaskConfig then
        for i, v in pairs(self._taskConfig.Task) do
            for j, w in pairs(cc.exports._gameJsonConfig.PhoneGameTaskConfig) do
                if v.GroupID == w.nGroupID and v.TaskList[1].ID == w.nTaskID then
                    v.TaskList[1].Condition[1].ConValue = w.nCondition
                    v.TaskList[1].Reward[1].RewardValueMin = w.nReward
                    v.TaskList[1].Reward[1].RewardValueMax = w.nReward
                end
            end
        end
    end

    self._taskData      = clone(TaskModel._TaskData)
    self._taskParamData = clone(TaskModel._TaskParamData)

    local list = {}
    local imagePath = self._taskConfig.ImagePath
    for i, v in pairs(self._taskConfig.Task) do
        local nGroupID  = tonumber(v.GroupID)
        local nData     = self:getFlagByGroupID(nGroupID)
        if not nData then
            nData       = {
                nID     = v.BeginID,
                nFlag   = TaskModel.TaskDef.TASKDATA_FLAG_DOING
            }
        end
        local config = nil
        for j, w in pairs(v.TaskList) do
            if nData.nID == w.ID then
                config = w
                break
            end
        end
        if v.Active == 1 and nData and TaskModel.TaskDef.TASKDATA_FLAG_FINISHED_HIDE ~= nData.nFlag and config then
            local task          = {
                _groupID        = nGroupID,
                _taskID         = nData.nID,
                _title          = v.Title,
                _image          = imagePath..v.Image,
                _description    = config.Name,
                _btnState       = nData.nFlag,
                _reward         = {},
                _progress       = {}
            }

            for j , w in pairs(config.Reward) do
                local reward    = {}
                local image     = self._taskConfig.Reward[w.RewardType].Image
                local text      = self._taskConfig.Reward[w.RewardType].Text
                reward._image   = imagePath..image
                reward._text    = text
                reward._value   = w.RewardValueMin
                table.insert(task._reward, reward)
            end

            local bFinished = true
            for j , w in pairs(config.Condition) do
                local nAmount   = 0 -- 任务完成量
                local nConType  = tonumber(w.ConType)
                local nParam    = self._taskParamData.nParam
                if TaskModel.TaskDef.TASK_CONDITION_COM_GAME_COUNT == nConType then
                    nAmount     = nParam[1] + nParam[2] + nParam[3]
                else
                    nAmount     = nParam[nConType]
                end
                task._nConType = nConType

                local progress  = {}
                local nValue    = tonumber(w.ConValue)
                if nAmount >= nValue then
                    progress._value = 100
                    progress._text  = tostring(nValue).."/"..tostring(nValue)
                else
                    bFinished   = false
                    progress._value = 100 * (nAmount / nValue)
                    progress._text  = tostring(nAmount).."/"..tostring(nValue)
                end
                table.insert(task._progress, progress)
                
                task._Amount = nAmount
                task._value = nValue
            end
            if TaskModel.TaskDef.TASKDATA_FLAG_DOING == nData.nFlag and bFinished then
                task._btnState  = TaskModel.TaskDef.TASKDATA_FLAG_CANGET_REWARD
            end

            table.insert(list, task)
        end
    end
    self.GameTaskList = list
    print("---------------------getTaskList IsHaveTaskFinish")
    self:IsHaveTaskFinish()

    return list
end

function MyGameController:getFlagByGroupID(nGroupID)
    for i = 1, self._taskData.nTaskNum do
        if self._taskData['nGroupID'..i] == nGroupID then
            local nFlag = self._taskData['nFlag'..i]
            local nID   = self._taskData['nID'..i]
            return {
                nFlag   = nFlag,
                nID     = nID
            }
        end
    end

    return nil
end

function MyGameController:IsHaveTaskFinish()
    --self._baseGameScene:showFinishTaskNode()
    local isHave = TaskModel:IsHaveTaskFinishForGlobal()
    if isHave then
        --self._baseGameScene:showFinishTaskNode()
        self._baseGameScene:ShowTakeRedDot(true)
    else
        self._baseGameScene:ShowTakeRedDot(false)
    end
    return isHave
end

function MyGameController:ChangeParamTask(id, param)
    if not cc.exports._GameTaskList or #cc.exports._GameTaskList < id then
        return
    end
    if cc.exports._GameTaskList[id]._btnState ~= TaskModel.TaskDef.TASKDATA_FLAG_DOING then
        return
    end
    cc.exports._GameTaskList[id]._Amount = cc.exports._GameTaskList[id]._Amount+param
    if cc.exports._GameTaskList[id]._Amount >= cc.exports._GameTaskList[id]._value then
        cc.exports._GameTaskList[id]._btnState = TaskModel.TaskDef.TASKDATA_FLAG_CANGET_REWARD
    end   
    
    --cc.load('MainCtrl'):getInstance():ShowTaskTip()
    TaskModel._myStatusDataExtended["isNeedReddot"] = TaskModel:isRewardAvail()
    TaskModel:dispatchModuleStatusChanged("task", TaskModel.EVENT_MAP["taskModel_rewardAvailChanged"])
end

function MyGameController:OPE_HideNoBiggerTip()
    --返回大厅时，有几率出现_baseGameScene为nil
    if not self._baseGameScene then return end
    --隐藏图片
    local selfInfo = self._baseGameScene:getSelfInfo()
    if selfInfo then
        selfInfo:showNoBigger(false)
    end
    local SKHandCardsManager        = self._baseGameScene:getSKHandCardsManager()
    if not SKHandCardsManager then return false end

    if SKHandCardsManager:getSKHandCards(self:getMyDrawIndex()):getHandCardsCount() <= 0 then
        return
    end
    if not self._bAutoPlay then       
        SKHandCardsManager:maskAllHandCardsEX(false)
    end
end

function MyGameController:OPE_ShowNoBiggerTip()
    local waitChairNo = self._baseGameUtilsInfoManager:getWaitChair()
    if waitChairNo == -1 then
        return
    end
    local SKHandCardsManager        = self._baseGameScene:getSKHandCardsManager()
    if not self._baseGameUtilsInfoManager or not SKHandCardsManager then
        return
    end
    if not SKHandCardsManager:havenoBigger() then 
        return
    end
    --显示图片
    local selfInfo = self._baseGameScene:getSelfInfo()
    if selfInfo then
        selfInfo:showNoBigger(true)
    end
    
    SKHandCardsManager:maskAllHandCardsEX(true)
end

function MyGameController:ope_GameInfoShow(showFocus)
    if not self._baseGameUtilsInfoManager then
        return
    end
    if not self._baseGameScene then return end

    local SceneNode = self._baseGameScene._gameNode
    if not SceneNode then 
        print("error SceneNode is nil")
        return 
    end
    local panelBoutInfo = SceneNode:getChildByName("Panel_BoutInfo")
    local value = panelBoutInfo:getChildByName("Value_ScoreSilver")
    local PlayerSilver = panelBoutInfo:getChildByName("PlayerSilver_lab")
    local PlayerScore = panelBoutInfo:getChildByName("PlayerScore_lab")
    
    if cc.exports.isGameMarkSupport() then 
        SceneNode:getChildByName("Img_Mark"):setVisible(true) 
    else
        SceneNode:getChildByName("Img_Mark"):setVisible(false) 
    end

    if PUBLIC_INTERFACE.IsStartAsAnchorMatchGame() then
        PlayerScore:setVisible(false)
        PlayerSilver:setVisible(false)
        value:setVisible(false)
        local labelRoomName = panelBoutInfo:getChildByName("room_info")
        labelRoomName:setString("主播房")
        labelRoomName:setAnchorPoint(cc.p(0.5, 0.5))
        labelRoomName:setPositionX(panelBoutInfo:getContentSize().width / 2)

        local panelDeposit = SceneNode:getChildByName("Panel_ArenaBar"):getChildByName("Panel_Deposit")
        panelDeposit:setVisible(false)
        
    elseif self:isNeedDeposit() or PublicInterFace.IsStartAsTimingGame() then
        if PublicInterFace.IsStartAsTimingGame() then
            if self._baseGameUtilsInfoManager._utilsStartInfo.nBaseScore == nil then
                self._baseGameUtilsInfoManager._utilsStartInfo.nBaseScore = 0
            end
            value:setString(tostring(self._baseGameUtilsInfoManager._utilsStartInfo.nBaseScore))
        else
            if self._baseGameUtilsInfoManager._utilsStartInfo.nBaseDeposit == nil then
                self._baseGameUtilsInfoManager._utilsStartInfo.nBaseDeposit = 0
            end
            value:setString(tostring(self._baseGameUtilsInfoManager._utilsStartInfo.nBaseDeposit))
        end

        PlayerScore:setVisible(false)
        PlayerSilver:setVisible(true)

        local roomInfo = cc.exports.PUBLIC_INTERFACE.GetCurrentRoomInfo()
        local utf8Name = roomInfo.szRoomName     -- 房间名称
        if string.find(utf8Name, "2") then
            utf8Name = string.gsub(utf8Name,"2","");
        end
        
        local utf8RankName = ""
        if PUBLIC_INTERFACE.IsStartAsTeam2V2() then
            utf8RankName = Team2V2Model:getRuleStringByRoomInfo(roomInfo)
        end

        if string.find(utf8Name, "新手房") then
            utf8Name = '新手房'
        end

        if PUBLIC_INTERFACE.IsStartAsArenaPlayer() then--竞技场
            utf8Name = self:getGameStringToUTF8ByKey("G_GAME_ROOMNAME_COMPETITION")..utf8Name
        elseif PUBLIC_INTERFACE.IsStartAsNoShuffle() then --"不洗牌"
            utf8Name = self:getGameStringToUTF8ByKey("G_GAME_ROOMNAME_NOSHUFFLE")..utf8Name..utf8RankName
        elseif PUBLIC_INTERFACE.IsStartAsJiSu() then --"极速掼蛋"
            utf8Name = self:getGameStringToUTF8ByKey("G_GAME_ROOMNAME_JISU")..utf8Name
        elseif PUBLIC_INTERFACE.IsStartAsFriendRoom() then --"好友场"
            utf8Name = self:getGameStringToUTF8ByKey("G_GAME_ROOMNAME_FRIEND")..utf8Name
        elseif  PublicInterFace.IsStartAsTimingGame() then --"定时赛"
            utf8Name = self:getGameStringToUTF8ByKey("G_GAME_ROOMNAME_TIMING")
        else
            utf8Name = self:getGameStringToUTF8ByKey("G_GAME_ROOMNAME_CLASS")..utf8Name..utf8RankName    --"经典场"
        end
        panelBoutInfo:getChildByName("room_info"):setString(utf8Name)
        SceneNode:getChildByName("Node_CardMaker"):setVisible(true)

        if PublicInterFace.IsStartAsTimingGame() then
            local panelDeposit = SceneNode:getChildByName("Panel_ArenaBar"):getChildByName("Panel_Deposit")
            panelDeposit:setVisible(false)
            local panelTimingScore = SceneNode:getChildByName("Panel_ArenaBar"):getChildByName("Panel_TimingScore")
            panelTimingScore:setVisible(true)
        end
    else
        if self._baseGameUtilsInfoManager._utilsStartInfo.nBaseScore == nil then
            self._baseGameUtilsInfoManager._utilsStartInfo.nBaseScore = 0
        end
        value:setString(tostring(self._baseGameUtilsInfoManager._utilsStartInfo.nBaseScore))

        PlayerScore:setVisible(true)
        PlayerSilver:setVisible(false)

        local nRoomID       =  self._baseGameUtilsInfoManager:getRoomID()
        if nRoomID ~= RoomListModel.OFFLINE_ROOMINFO["nRoomID"]  then
            local roomInfo = cc.exports.PUBLIC_INTERFACE.GetCurrentRoomInfo()
            local utf8Name = ""
            if roomInfo then
                utf8Name = roomInfo.szRoomName     -- 房间名称
            end
            utf8Name = self:getGameStringToUTF8ByKey("G_GAME_ROOMNAME_FUN")..utf8Name    --"娱乐场"
            panelBoutInfo:getChildByName("room_info"):setString(utf8Name) 

            --玩家当前积分
            if cc.exports._gameJsonConfig.WeakenScoreRoom and cc.exports._gameJsonConfig.WeakenScoreRoom.Open and cc.exports._gameJsonConfig.WeakenScoreRoom.Open == 1 then
                if cc.exports.nScoreInfo.nScore and cc.exports._gameJsonConfig.WeakenScoreRoom.Score and cc.exports._gameJsonConfig.WeakenScoreRoom.Score > 0 
		            and cc.exports.nScoreInfo.nScore < cc.exports._gameJsonConfig.WeakenScoreRoom.Score and cc.exports.nScoreInfo.nReward == 0 then
                    local str = "（" .. cc.exports.nScoreInfo.nScore .. "/" .. cc.exports._gameJsonConfig.WeakenScoreRoom.Score .. "）"
                    SceneNode:getChildByName("Panel__Score"):getChildByName("Score"):setString(str)
                    SceneNode:getChildByName("Panel__Score"):setVisible(true)
                end
            end
        end
        SceneNode:getChildByName("Node_CardMaker"):setVisible(false)
    end

    local chairno=self:getMyChairNO()
    local enemy= self._baseGameUtilsInfoManager:RUL_GetNextChairNO(chairno)
    local our_rank = self._baseGameUtilsInfoManager._utilsStartInfo.nRank[chairno+1]
    local enemy_rank = self._baseGameUtilsInfoManager._utilsStartInfo.nRank[enemy+1]

    local Img_ScoreSelf = SceneNode:getChildByName("Panel_GameScore"):getChildByName("Img_ScoreSelf")
    local Img_ScoreOpponent = SceneNode:getChildByName("Panel_GameScore"):getChildByName("Img_ScoreOpponent")

    if our_rank == 13 then
        our_rank = 0
    end
    if enemy_rank == 13 then
        enemy_rank = 0
    end
    Img_ScoreSelf:loadTexture("res/Game/GamePic/Num/num_black_"..tostring(our_rank+1)..".png")  
    Img_ScoreOpponent:loadTexture("res/Game/GamePic/Num/num_red_"..tostring(enemy_rank+1)..".png")

    local CardLight_L = SceneNode:getChildByName("Panel_GameScore"):getChildByName("Img_CardLight_L")
    local CardLight_R = SceneNode:getChildByName("Panel_GameScore"):getChildByName("Img_CardLight_R")
    CardLight_L:setVisible(false)
    CardLight_R:setVisible(false)
    if showFocus then
        if self._baseGameUtilsInfoManager._utilsStartInfo.nRanker == chairno
            or self._baseGameUtilsInfoManager._utilsStartInfo.nRanker == self._baseGameUtilsInfoManager:RUL_GetNextChairNO(self._baseGameUtilsInfoManager:RUL_GetNextChairNO(chairno)) then
            CardLight_L:setVisible(true)
        else
            CardLight_R:setVisible(true)
        end
    end
end

function MyGameController:playerAbort(drawIndex)
    MyGameController.super.playerAbort(self, drawIndex)

    if not self._baseGameUtilsInfoManager then
        return
    end
    self._baseGameUtilsInfoManager._utilsStartInfo.nRank = {1,1,1,1}
    self:ope_GameInfoShow(false)

    for i = 1, 4 do
        local playerManager = self._baseGameScene:getPlayerManager()
        if playerManager then
            playerManager:FreshPlace(drawIndex, 0)
        end
    end  
end

function MyGameController:onChangeTable()
    MyGameController.super.onChangeTable(self)

    if not self._baseGameUtilsInfoManager then return end

    self._baseGameUtilsInfoManager._utilsStartInfo.nRank = {1,1,1,1}
    self:ope_GameInfoShow(false)

    for i = 1, 4 do
        local playerManager = self._baseGameScene:getPlayerManager()
        if playerManager then
            playerManager:FreshPlace(drawIndex, 0)
        end
    end
end

function MyGameController:getGameStringToUTF8ByKey(stringKey)
    local content = self:getGameStringByKey(stringKey)
    local utf8Content = MCCharset:getInstance():gb2Utf8String(content, string.len(content))
    return utf8Content
end

function MyGameController:ResetArrageButton()
    local SKHandCardsManager        = self._baseGameScene:getSKHandCardsManager()
    if not SKHandCardsManager then return false end

    local status = self._baseGameUtilsInfoManager:getStatus()

    if SKHandCardsManager:getSKHandCards(self:getMyDrawIndex()):getHandCardsCount() <= 0  or not self:IS_BIT_SET(status, BaseGameDef.BASEGAME_TS_WAITING_THROW) then
        self._baseGameScene._MyResetBtn:setVisible(false)
        self._baseGameScene._MyArrageBtn:setVisible(false)
        return
    end

    -- 选中牌后，根据是否选中理牌来决定 按钮撤销or理牌
    self._baseGameScene._MyResetBtn:setVisible(false)
    self._baseGameScene._MyArrageBtn:setVisible(false)
    local nSelectIDs, nSelectCount, bAllArrage = SKHandCardsManager:getMySelectCardIDsEx()
    if nSelectCount > 0 then
        if true == bAllArrage then
            self._baseGameScene._MyResetBtn:setVisible(true)    -- 显示恢复
        else
            self._baseGameScene._MyArrageBtn:setVisible(true)   -- 显示理牌
        end

        return
    else
        -- 没有选中牌时候
        -- 非炸弹模式下没选中牌，整幅牌中是否由理牌决定显示 理牌or撤销
        local arrageCards = {}
        local nCount = SKHandCardsManager._SKHandCards[self:getMyDrawIndex()]:RUL_GetInHandArrageCards(arrageCards)
            
        if nCount <= 0 then           
            self._baseGameScene._MyArrageBtn:setVisible(true)       -- 显示理牌
        else
            self._baseGameScene._MyResetBtn:setVisible(true)        -- 显示恢复
        end
    end
end

function MyGameController:onRemoveLoadingLayer()
    MyGameController.super.onRemoveLoadingLayer(self)

    --self:IsHaveTaskFinish()
end

function MyGameController:saveMyGameDataXml(gameData)
    local playerInfoManager = self:getPlayerInfoManager()
    local nUserID         = playerInfoManager:getSelfUserID()
    my.saveCache("MyGameData"..nUserID..".xml", gameData)
end

function MyGameController:getMyGameDataXml()
    local playerInfoManager = self:getPlayerInfoManager()
    local nUserID         = playerInfoManager:getSelfUserID()
    return my.readCache("MyGameData"..nUserID..".xml")
end

function MyGameController:onCheckVersion()
    UIHelper:recordRuntime("EnterGameScene", "MyGameController:onCheckVersion")
    local function onEnterGameTime(dt)
        self:onEnterGameTime()
    end
    --self.onEnterGameTimerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(onEnterGameTime, 0.5, false)
    --减小检查间隔，和减小loadingInterval配合可以减少进入游戏时间0.5s左右
    self.onEnterGameTimerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(onEnterGameTime, 0.2, false)
end

function MyGameController:onEnterGameTime()
    UIHelper:recordRuntime("EnterGameScene", "MyGameController:onEnterGameTime")
    if not self._baseGameScene then
        return
    end
    local loadingNode = self._baseGameScene:getLoadingNode()
    if (loadingNode and not loadingNode._bLoading) or cc.exports._isEnterRoomForGameScene or cc.exports.EnterGameFromGame then
        if self.onEnterGameTimerID then       
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.onEnterGameTimerID)
            self.onEnterGameTimerID = nil
            if self._baseGameConnect then
                UIHelper:recordRuntime("EnterGameScene", "MyGameController gc_EnterGame")
                self._baseGameConnect:gc_EnterGame()
            end
        end
        cc.exports.EnterGameFromGame = nil
    end
end

function MyGameController:onAutoPlay(bnAuto)
    self._bAutoPlay = bnAuto

    local playerManager = self._baseGameScene:getPlayerManager()
    if playerManager then
        playerManager:showRobot(self._bAutoPlay, self:getMyDrawIndex())
    end

    local selfInfo = self._baseGameScene:getSelfInfo()
    if selfInfo then
        selfInfo:showCancelAuto(self._bAutoPlay)
    end

    local SKHandCardsManager = self._baseGameScene:getSKHandCardsManager()
    if SKHandCardsManager then
        SKHandCardsManager:maskAllHandCardsEX(bnAuto)
    end

    if bnAuto and self:isBoutGuide() then
        self._baseGameConnect:reqAutoPlay()
    end
end

--[[function MyGameController:onQuit()
    if not self._baseGameUtilsInfoManager then
        return
    end
    if self._baseGameUtilsInfoManager.bEndedExit > 0 then
        MyGameController.super.onQuit(self)
    else
        if self._baseGameUtilsInfoManager._utilsStartInfo ~= nil then
            if self._baseGameUtilsInfoManager._utilsStartInfo.nBaseDeposit == nil then
                self._baseGameUtilsInfoManager._utilsStartInfo.nBaseDeposit = 0
            end
        else
            self._baseGameUtilsInfoManager._utilsStartInfo = {}
            self._baseGameUtilsInfoManager._utilsStartInfo.nBaseDeposit = 0
        end        
        self._baseGameScene:addExitRoomPrompt(self._baseGameUtilsInfoManager._utilsStartInfo.nBaseDeposit)
    end  
end--]]

function MyGameController:showExchangeExitPrompt()
    if PUBLIC_INTERFACE.IsStartAsArenaPlayer() or PUBLIC_INTERFACE.IsStartAsFriendRoom() then
        -- 竞技场，好友房 不用弹窗口
        print("start as Arena Room or Friend Room")
        return false
    end

    local gameTools = self._baseGameScene:getTools()
    if gameTools and false == gameTools:isQuitBtnEnabled() then
        print("Game is Running, can not exit !!!")
        return false
    end

    -- 获取奖励兑换券数量
    local RoomExchangeConfig = cc.exports._gameJsonConfig.ExchangeRoomConfig
    if RoomExchangeConfig then
        local nRoomID       =  self._baseGameUtilsInfoManager:getRoomID()
        local oneConfig = RoomExchangeConfig[tostring(nRoomID)]    
        local RewardVochersNum = 0
        local nContinueBout = 0
        if oneConfig ~= nil and type(oneConfig.RewardNum )=="number" then
            RewardVochersNum = oneConfig.RewardNum
            nContinueBout = oneConfig.BoutCount
            if RewardVochersNum > 0 and nContinueBout > 0  then
                -- 获取当前房间的对局情况
                local BoutInfo  = self:getCurrentExchangeBoutInfo()
                if BoutInfo then
                    nContinueBout = BoutInfo.nTargetBout - math.mod(BoutInfo.nCurrentBount,BoutInfo.nTargetBout) 
                else
                    nContinueBout = oneConfig.BoutCount
                end

                if self.isExitRoomPlaneSure == true then
                    -- 说明窗口已经弹出，则不用继续弹窗
                    -- 这个对象应该不是控件，乱用方法
                    if self._ExchangeQuitPrompt and not tolua.isnull(self._ExchangeQuitPrompt) then
                        if self._ExchangeQuitPrompt:isVisible() then
                            return true
                        end
                    else 
                        -- 异常情况
                        self.isExitRoomPlaneSure    = false   
                        self._ExchangeQuitPrompt = nil
                    end
                end
                self._ExchangeQuitPrompt = self._baseGameScene:addExitRoomExchangePrompt(nContinueBout, RewardVochersNum)

                local time = 10
                local function ExchangePromptQuitCallFunc()
                    self:stopExchangeQuitTimer()
                    self:ExchangePromptQuitCallFunc()
                end
                self._ExchangeQuitTimerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(ExchangePromptQuitCallFunc, time, false) 
                return true
            end  -- end if RewardVochersNum > 0 ...
        end -- end if oneConfig ~= nil ...
    end -- if RoomExchangeConfig ...

    return false
end

function MyGameController:stopExchangeQuitTimer()
    if self._ExchangeQuitTimerID then     
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._ExchangeQuitTimerID)
        self._ExchangeQuitTimerID = nil
    end
end

function MyGameController:ExchangePromptQuitCallFunc()
    if self.isExitRoomPlaneSure == true then -- 防止二次调用
        if self._ExchangeQuitPrompt then
            self._ExchangeQuitPrompt:onClose() 
            self._ExchangeQuitPrompt = nil
        end

        if self:isConnected() and self._baseGameConnect then
            local gameTools = self._baseGameScene:getTools()
            if gameTools and gameTools:isQuitBtnEnabled() then
                if self:isTeamGameRoom() and self:isHallEntery() and not self:isVisibleCharteredRoom() and not PUBLIC_INTERFACE.IsStartAsTeam2V2() then
                    self._baseGameConnect:TeamGameRoom_LeaveGame()
                else
                    self._baseGameConnect:gc_LeaveGame()
                end
            else
                self:tipMessageByKey("G_GAME_GAMERUNING_CANT_QUIT")
            end
        else
            if(self._dispatch)then
                self._dispatch:quit()
            end
            if (self:isTeamGameRoom() and self:isHallEntery()) or
            (self:isCharteredRoom() and not self:isRandomRoom()) then
                cc.exports.isAutogotoCharteredRoom = true
            end
            self:gotoHallScene()
        end
    end
end

function MyGameController:onTeam2V2Leave()
    self:onQuit()
    my.scheduleOnce(function()
        self:onQuit()
    end, 0.3)
end

function MyGameController:onQuit()
    self:stopAutoQuitTimer()

    if cc.exports.isQuickStart then
        PUBLIC_INTERFACE.SetStartAsNoShuffle(false)
        cc.exports.isQuickStart = false
    end
    if (cc.exports.inTickoff == true) then
        cc.exports.inTickoff = false
        self:gotoHallScene()
        return
    end
    if self._leaveGameOk then
        self:gotoHallScene()
        return
    end

    --[[if self:isUserConvertSupported() then
        local userConvert = self:getUserConvertCtrl()
        if userConvert:isDlgShow() then
            return
        end
    end]]-- 用户转化已废弃

    if not self._baseGameScene then
        return
    end
    
    if self._baseGameScene then
        self._baseGameScene:removeListen()
    end

    local safeBox = self._baseGameScene:getSafeBox()
    if safeBox and safeBox:isVisible() then
        safeBox:showSafeBox(false)
        return
    end

    local setting = self._baseGameScene:getSetting()
    if setting and setting:isVisible() then
        setting:showSetting(false)
        return
    end

    local chat = self._baseGameScene:getChat()
    if chat and chat:isVisible() then
        chat:showChat(false)
        return
    end

    if self._baseGameScene._resultLayer ~= nil then
        self:onCloseResultLayerEx()
        return
    end

    if not PUBLIC_INTERFACE.IsStartAsTeam2V2() then
        if self._dispatch and ((self:isCharteredRoom() and not self:isRandomRoom()) or (self:isTeamGameRoom() and self:isHallEntery())) then
            if self._dispatch:isStartMatch() and self:isVisibleCharteredRoom() then
                return
            end
    
            if self._dispatch:isNeedShow() then
                 if cc.exports.hasStartGame then
                    self._dispatch:show(false)
                 else
                    self._baseGameConnect:TeamGameRoom_LeaveGame()
                    --self._dispatch:show(true)
                 end
                 return
            end
        end
    end    

    if not self._baseGameUtilsInfoManager then
        return
    end
    if self._baseGameUtilsInfoManager.bEndedExit <= 0 then
        if self.isExitRoomPlaneSure then
            return
        end
        if self:isConnected() and self._baseGameConnect then
            local gameTools = self._baseGameScene:getTools()
            if gameTools and gameTools:isQuitBtnEnabled() then
            else
                self:tipMessageByKey("G_GAME_GAMERUNING_CANT_QUIT")
                return
            end
        end
        if self._baseGameUtilsInfoManager._utilsStartInfo ~= nil then
            if self._baseGameUtilsInfoManager._utilsStartInfo.nBaseDeposit == nil then
                self._baseGameUtilsInfoManager._utilsStartInfo.nBaseDeposit = 0
            end
        else
            self._baseGameUtilsInfoManager._utilsStartInfo = {}
            self._baseGameUtilsInfoManager._utilsStartInfo.nBaseDeposit = 0
        end
        
        if not PUBLIC_INTERFACE.IsStartAsTeam2V2() then
            self._baseGameScene:addExitRoomPrompt(self._baseGameUtilsInfoManager._utilsStartInfo.nBaseDeposit)
            return
        end        
    end  

    -- 对局兑换券退出弹窗提示
    if true == self:showExchangeExitPrompt() then
        -- 如果窗口弹出，则不需要执行下面的退出，等待玩家选择即可
        return
    end

    if self:isConnected() and self._baseGameConnect then
        local gameTools = self._baseGameScene:getTools()
        if gameTools and gameTools:isQuitBtnEnabled() then
            if self:isTeamGameRoom() and self:isHallEntery() and not self:isVisibleCharteredRoom() and not PUBLIC_INTERFACE.IsStartAsTeam2V2() then
                self._baseGameConnect:TeamGameRoom_LeaveGame()
            else
                if PUBLIC_INTERFACE.IsStartAsAnchorMatchGame() then
                    local AnchorTableModel = import('src.app.plugins.AnchorTable.AnchorTableModel'):getInstance()    
                    local tableRule = AnchorTableModel:getTableRule()
                    if tableRule and tableRule.AnchorUserID == user.nUserID then
                        self._baseGameConnect:gc_AnchorLeaveGame()
                    else
                        self._baseGameConnect:gc_LeaveGame()
                    end
                else
                    self._baseGameConnect:gc_LeaveGame()
                end
                --好友房返回的时候有点慢，加一个loading更友好
                if self:isTeamGameRoom() and self:isHallEntery() and self:isVisibleCharteredRoom() then
                    my.startProcessing()
                end
            end
        else
            self:tipMessageByKey("G_GAME_GAMERUNING_CANT_QUIT")
        end
    else
        if(self._dispatch)then
            self._dispatch:quit()
        end

        if (self:isTeamGameRoom() and self:isHallEntery()) or
        (self:isCharteredRoom() and not self:isRandomRoom()) then
            cc.exports.isAutogotoCharteredRoom = true
        end

        self:gotoHallScene()
    end
end

function MyGameController:startTimeResultClose()
    if self.startTimeResultCloseID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.startTimeResultCloseID)
        self.startTimeResultCloseID = nil
    end
    local function startTimeResultCloseCallFunc(dt)        
        self:startTimeResultCloseCallFunc()
        -- 组队房
        if PUBLIC_INTERFACE.IsStartAsTeam2V2() then
            if self.gameWinBnResetGame and self.gameWinBnResetGame == 1 then
                self:onTeam2V2Leave()
            else
                self:onRestart()
            end
        end
    end
    local time = 50   --其他普通房50秒关闭结算界面 比自动退出短
    if self._baseGameUtilsInfoManager.bEndedExit <= 0 then  --连局房10秒就好
        time = 10
    end

    if PUBLIC_INTERFACE.IsStartAsTeam2V2() then     -- 组队2V2房结算停留10秒后自动准备或离开
        time = 13
    end
    
    self.startTimeResultCloseID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(startTimeResultCloseCallFunc, time, false) 
end

function MyGameController:startTimeResultCloseCallFunc()
    if self.startTimeResultCloseID then     
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.startTimeResultCloseID)
        self.startTimeResultCloseID = nil
        --关闭结算界面时，隐藏桌面翻倍倍数
        if self._baseGameScene and self._baseGameScene._MyPanel_Odds then
            self._baseGameScene._MyPanel_Odds:setVisible(false)
        end
            
        if self._baseGameUtilsInfoManager.bEndedExit <= 0 then
            
            --关闭竞技场的结算界面等begin
            if self._baseGameScene._arenaOverStatement then
                self._baseGameScene._arenaOverStatement:onExit()
                self._baseGameScene._arenaOverStatement = nil
                self:onExitGameClicked() --直接强退
                return
            end

            if self._baseGameScene._arenaNewStatement then
                self._baseGameScene._arenaNewStatement:onExit()
                self._baseGameScene._arenaNewStatement = nil
            end
            --关闭竞技场的结算界面等end

            if self._baseGameScene._resultLayer == nil then               
                local playerManager = self._baseGameScene:getPlayerManager()              
                if not playerManager._players[self:getMyDrawIndex()]._playerReady:isVisible() then                   
                    self:onStartGame()
                end
            else
                self:onRestart()
            end

            local function startTimeCheckOfflineallFunc(dt)
                self:startTimeCheckOfflineallFunc()
            end

            self.startTimeCheckOfflineID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(startTimeCheckOfflineallFunc, 20, false) 
        else
            if self._baseGameScene._resultLayer ~= nil then
                self:onCloseResultLayerEx()
            end
        end        
    end
end

function MyGameController:startTimeCheckOfflineallFunc()
    if self.startTimeCheckOfflineID then  
        if self._baseGameConnect then
            self._baseGameConnect:reqCheckOffline()
        end   
    end
end

function MyGameController:stopCheckOffline()
    if self.startTimeResultCloseID then     
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.startTimeResultCloseID)
        self.startTimeResultCloseID = nil
    end
        
    if self.startTimeCheckOfflineID then     
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.startTimeCheckOfflineID)
        self.startTimeCheckOfflineID = nil
    end
end

function MyGameController:onServerKickingPlayer(data)
    local checkOfflineInfo = nil
    if self._baseGameData then
        checkOfflineInfo = self._baseGameData:getCheckOfflineInfo(data)
    end
    if checkOfflineInfo then
        local content = ""
        local userName = self:getPlayerUserNameByUserID(checkOfflineInfo.nUserID)

        if not self._baseGameUtilsInfoManager then
            self._baseGameUtilsInfoManager = {}
            self._baseGameUtilsInfoManager._utilsStartInfo = {}
            self._baseGameUtilsInfoManager._utilsStartInfo.nBaseDeposit = 0
        end
        content = string.format(self:getGameStringByKey("G_SELFEXIT_GAMEABORT"), self._baseGameUtilsInfoManager._utilsStartInfo.nBaseDeposit)

        local okCallback = function()
            if(self._dispatch)then
                cc.exports.hasStartGame=false
                if self:isTeamGameRoom() then
                    self:gotoHallScene()
                else
                    self._dispatch:ResetInterfaceAfterGameEnd()
                end
            else
                --self:gotoHallScene()
                self:restartCurrentRoom()
            end
        end
        local cancelCallback = function()
            self:gotoHallScene()
        end
        local utf8Content = MCCharset:getInstance():gb2Utf8String(content, string.len(content))
        --self:popSureDialog(utf8Content, "", "", okCallback, false)
        if PUBLIC_INTERFACE.IsStartAsTeam2V2() then
            self:gotoHallScene()
        else
            self:popChoseDialog(utf8Content, "", MCCharset:getInstance():gb2Utf8String(self:getGameStringByKey("G_GAME_GOTO_HALL"), string.len(self:getGameStringByKey("G_GAME_GOTO_HALL"))), cancelCallback
                        , MCCharset:getInstance():gb2Utf8String(self:getGameStringByKey("G_GAME_RESTART_ROOM"), string.len(self:getGameStringByKey("G_GAME_RESTART_ROOM"))),  okCallback, false)
        end
    end
end

function MyGameController:onGameAbort(data)
    local gameAbortInfo = nil
    if self._baseGameData then
        gameAbortInfo = self._baseGameData:getGameAbortInfo(data)
    end
    if gameAbortInfo then
        if self:getMyDrawIndex() ~= self:rul_GetDrawIndexByChairNO(gameAbortInfo.nChairNO) then
            self:gameStop()
            self:disconnect()

            if gameAbortInfo.nAbortFlag == MyGameDef.ANCHORMATCH_ABORT_FLAG_ANCHOR_EXIT then
                my.informPluginByName({
                    pluginName = "SureDialog", 
                    params = {
                        tipContent = "主播已退出，房间自动解散",
                        forbidKeyBack = true,
                        onOk = function()
                            self:gotoHallScene()
                        end
                    }
                })
            elseif gameAbortInfo.nAbortFlag == MyGameDef.TEAM2V2GAME_ABORT_FLAG_PLAYER_EXIT then
                if self.gameWinBnResetGame ~= 1 then
                    my.informPluginByName({
                        pluginName = "SureDialog", 
                        params = {
                            tipContent = "有人已退出，回到组队~",
                            forbidKeyBack = true,
                            onOk = function()
                                self:gotoHallScene()
                            end
                        }
                    })
                end
            elseif gameAbortInfo.nAbortFlag == MyGameDef.ANCHORMATCH_ABORT_FLAG_PLAYER_EXIT then
                local userName = self:getPlayerUserNameByUserID(gameAbortInfo.nUserID)
                my.informPluginByName({
                    pluginName = "SureDialog", 
                    params = {
                        tipContent = "玩家" .. userName .. "已退出，游戏已结束",
                        forbidKeyBack = true,
                        onOk = function()
                            self:gotoHallScene()
                        end
                    }
                })
            else
                local content = ""
                local userName = self:getPlayerUserNameByUserID(gameAbortInfo.nUserID)
                if gameAbortInfo.bForce then
                    content = string.format(self:getGameStringByKey("G_GAMEABORT_FORCE_DEPOSIT"), userName, gameAbortInfo.nDepositDfif)
                    if self._baseGameScene and self._baseGameScene._cardMakerTool then
                        self._baseGameScene._cardMakerTool:AddCardMakerCount()
                    end
                else
                    content = string.format(self:getGameStringByKey("G_GAMEABORT"), userName)
                end
                local okCallback = function()
                    if(self._dispatch)then
                        cc.exports.hasStartGame=false
                        if self:isTeamGameRoom() then
                            self:gotoHallScene()
                        else
                            self._dispatch:ResetInterfaceAfterGameEnd()
                        end
                    else
                        --self:gotoHallScene()
                        self:restartCurrentRoom()
                    end
                end
                local cancelCallback = function()
                    self:gotoHallScene()
                end
                if PUBLIC_INTERFACE.IsStartAsTeam2V2() then
                    self:gotoHallScene()
                else
                    local utf8Content = MCCharset:getInstance():gb2Utf8String(content, string.len(content))
                    self:popChoseDialog(utf8Content, "", MCCharset:getInstance():gb2Utf8String(self:getGameStringByKey("G_GAME_GOTO_HALL"), string.len(self:getGameStringByKey("G_GAME_GOTO_HALL"))), cancelCallback
                            , MCCharset:getInstance():gb2Utf8String(self:getGameStringByKey("G_GAME_RESTART_ROOM"), string.len(self:getGameStringByKey("G_GAME_RESTART_ROOM"))),  okCallback, false)
                end
            end
        end
    end
end

function MyGameController:clearGameTable()
    self:OPE_HideNoBiggerTip()
    local selfInfo = self._baseGameScene:getSelfInfo()
    if selfInfo then
        selfInfo:showTribute(false)
        selfInfo:showReturn(false)
    end
    local gameScene = self._baseGameScene
    if gameScene.cardBg then
        gameScene.cardBg:stopAllActions()
        gameScene.cardBg:removeFromParentAndCleanup()
        gameScene.cardBg = nil
    end
    if gameScene.cardft then
        gameScene.cardft:stopAllActions()
        gameScene.cardft:removeFromParentAndCleanup()
        gameScene.cardft = nil
    end

    --cardMaker
    self._MyGameCardMakerInfo:resert()
    self._baseGameScene._cardMakerTool:setCardMakerInfo()
    self._baseGameScene._cardMakerTool:OnShowCardMakerInfo(false)
    --self._baseGameScene._cardMakerTool:onRefreshCardMaker()

    MyGameController.super.clearGameTable(self)
end

function MyGameController:onPause()
    if self._leaveGameOk then
        return
    end

    MyGameController.super.onPause(self)
end

-- 切后台恢复执行onResume
function MyGameController:onResume()
    if device.platform ~= "windows" then    
        local SKHandCardsManager = self._baseGameScene:getSKHandCardsManager()
        if self:isGameRunning() then
            if SKHandCardsManager and SKHandCardsManager._dealCardTimerID then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(SKHandCardsManager._dealCardTimerID)
                SKHandCardsManager._dealCardTimerID = nil
                self:ope_StartPlay()
            end
        else
            if SKHandCardsManager and SKHandCardsManager._dealCardTimerID then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(SKHandCardsManager._dealCardTimerID)
                SKHandCardsManager._dealCardTimerID = nil
            end
        end  
    end

    if self._leaveGameOk then
        return
    end

    MyGameController.super.onResume(self)
end

function MyGameController:onGetSyncInfo(data)
    printf("onGetSyncInfo")
    local sync = self._baseGameData:getSyncInfo(data)
    self:setPlayerHeadImg(sync)
    self:setPlayerLbsInfo(sync)

    if self:isTeamGameRoom() and self._isHallEntery then
        local charteredRoom = require("src.app.Game.mBaseGame.BaseGameCharteredRoom.CharteredRoom")
        charteredRoom:onGetSyncInfo(sync)
    end
end

function MyGameController:setPlayerLbsInfo(sync)
    dump(sync)
    for i,v in pairs(sync)do
        self:showLBS(v.nUserID,v.szLBSInfo)
    end
end

function MyGameController:setPlayerHeadImg(sync)
    printf("setPlayerHeadImg")
    local data={}
    for i,v in pairs(sync)do
        local d={}
        d.userID=v.nUserID
        d.url=v.szHeadUrl
        table.insert(data,d)
    end

    local imageCtrl = require('src.app.BaseModule.ImageCtrl')
    imageCtrl:getImageForGameScene(data, '400-400', handler(self,self.ondownloadHead))
end

function MyGameController:ondownloadHead(list)
    printf("ondownloadHead")
    printf(list)
    if(not my.isInGame())then
        return
    end

    for i,v in pairs(list)do
        self:setPlayerHead(v.userID, v.path)
    end
end

function MyGameController:showLBS(nUserID,lbsJson)
    if (lbsJson == nil) then
        return
    end
    if (lbsJson == "") then
        return
    end
    printf("~~~~~~~~~~start showLBS~~~~~~~~~~~~")
    printf("~~~~~~~~~~lbsJson is %s~~~~~~~~~~~~",lbsJson)
    local json = cc.load("json").json
    local lbsJ = json.decode(lbsJson)
    if(lbsJ["la"]=="")then
        return
    end
    if(lbsJ["lo"]=="")then
        return
    end

    local lbsDes
    local tcyFriendPlugin = plugin.AgentManager:getInstance():getTcyFriendPlugin()
    if tcyFriendPlugin==nil then
        lbsDes=lbsJ["ci"]
        if(lbsDes==nil)then
            return
        end
        printf("~~~~~~~nUserID [%d]  lbsDes is[%s]~~~~~~~~~~~~~~~~~~~",nUserID,lbsDes)
        self:setPlayerLbs(nUserID,lbsDes)
        return
    end

    if(tcyFriendPlugin.getPositionInfo==nil)then
        printf("~~~~~~~~~~~no getPositionInfo~~~~~~~~~~~~~~~~~~~~~~~`")      
        return
    end

    local lengthTable={}
    lengthTable.letters = 0
    lengthTable.words = 0
    local positionInfo = tcyFriendPlugin:getPositionInfo()
    if positionInfo then
        local latitude=positionInfo.latitude
        local longitude=positionInfo.longitude
        local la = lbsJ["la"]
        local lo = lbsJ["lo"]
        local distance = math.floor( tcyFriendPlugin:getDistance(latitude,longitude,la,lo) )
        --distance = distance *1000000
        local kmDistance=math.ceil(distance/1000-0.5)
        
        if type(distance) == "number" then 
            if (distance >= 1000) then
                if(kmDistance>10)then
                    if (lbsJ["ci"] and lbsJ["ci"] ~= "") then

                        lengthTable.letters = string.len(tostring(kmDistance).."km".." ")
                        lengthTable.words = string.len(lbsJ["ci"])
                        lbsDes = tostring(kmDistance).."km".." "..lbsJ["ci"]

                    else

                        lbsDes = tostring(kmDistance).."km"
                        lengthTable.letters = string.len(tostring(kmDistance).."km")
                        printf("~~~~~~~~~showLBS no city~~~~~~~~~~~~~~~~~~~~~~~~")

                    end
                elseif(kmDistance<=10 and kmDistance>=1)then
                    if     (lbsJ["di"] and lbsJ["di"] ~= "") then

                        lengthTable.letters = string.len(tostring(kmDistance).."km".." ")
                        lengthTable.words = string.len(lbsJ["di"])
                        lbsDes = tostring(kmDistance).."km".." "..lbsJ["di"]

                    elseif (lbsJ["ci"] and lbsJ["ci"] ~= "") then 

                        lbsDes = tostring(kmDistance).."km".." "..lbsJ["ci"]
                        lengthTable.letters = string.len(tostring(kmDistance).."km".." ")
                        lengthTable.words = string.len(lbsJ["ci"])
                        printf("~~~~~~~~~showLBS no districtName~~~~~~~~~~~~~~~~~~~~~~~~")

                    else

                        lbsDes = tostring(kmDistance).."km"
                        lengthTable.letters = string.len(tostring(kmDistance).."km")
                        printf("~~~~~~~~~showLBS no city~~~~~~~~~~~~~~~~~~~~~~~~")

                    end
                else
                    if     (lbsJ["bu"] ~= "" and lbsJ["bu"])then

                        lengthTable.letters = string.len(tostring(kmDistance).."km".." ")
                        lengthTable.words = string.len(lbsJ["bu"])
                        lbsDes = tostring(kmDistance).."km".." "..lbsJ["bu"]

                    elseif (lbsJ["st"] ~= "" and lbsJ["st"])then

                        lengthTable.letters = string.len(tostring(kmDistance).."km".." ")
                        lengthTable.words = string.len(lbsJ["st"])
                        lbsDes = tostring(kmDistance).."km".." "..lbsJ["st"]

                    elseif (lbsJ["di"] ~= "" and lbsJ["di"])then

                        lengthTable.letters = string.len(tostring(kmDistance).."km".." ")
                        lengthTable.words = string.len(lbsJ["di"])
                        lbsDes = tostring(kmDistance).."km".." "..lbsJ["di"]

                    elseif (lbsJ["ci"] ~= "" and lbsJ["ci"]) then 

                        lengthTable.letters = string.len(tostring(kmDistance).."km".." ")
                        lengthTable.words = string.len(lbsJ["ci"])
                        lbsDes = tostring(kmDistance).."km".." "..lbsJ["ci"]

                    else

                        lengthTable.letters = string.len(tostring(kmDistance).."km")
                        lbsDes = tostring(kmDistance).."km"
                        printf("~~~~~~~~~showLBS no city~~~~~~~~~~~~~~~~~~~~~~~~")

                    end
                end
            elseif distance >= 0 then
                distance = math.ceil(distance-0.5)
                if    (lbsJ["bu"] ~= "" and lbsJ["bu"])then
                    lengthTable.letters = string.len(tostring(kmDistance).."km".." ")
                    lengthTable.words = string.len(lbsJ["bu"])
                    lbsDes = distance.."m".." "..lbsJ["bu"]
                elseif(lbsJ["st"] ~= "" and lbsJ["st"])then
                    lengthTable.letters = string.len(tostring(kmDistance).."km".." ")
                    lengthTable.words = string.len(lbsJ["st"])
                    lbsDes = distance.."m".." "..lbsJ["st"]
                elseif(lbsJ["di"] ~= "" and lbsJ["di"])then
                    lengthTable.letters = string.len(tostring(kmDistance).."km".." ")
                    lengthTable.words = string.len(lbsJ["di"])
                    lbsDes = distance.."m".." "..lbsJ["di"]
                elseif(lbsJ["ci"] ~= "" and lbsJ["ci"])then
                    lengthTable.letters = string.len(tostring(kmDistance).."km".." ")
                    lengthTable.words = string.len(lbsJ["ci"])
                    lbsDes = distance.."m".." "..lbsJ["ci"]
                end
            else
                print("unexpected distance number value")
                lengthTable.words = string.len(lbsJ["ci"])
                lbsDes=lbsJ["ci"]
            end
        else
            print("wrong value type of distance, type:"..type(distance))
            lengthTable.words = string.len(lbsJ["ci"])
            lbsDes=lbsJ["ci"]
        end
        dump(distance)
    else
        printf("showLBS positionInfo is nil")
        lengthTable.words = string.len(lbsJ["ci"])
        lbsDes=lbsJ["ci"]
    end  

    if(lbsDes == nil)then
        return
    end

    local function getLabelWidth()
        local length = lengthTable.words/3*2 +lengthTable.letters 
        print("getLableWidth:"..length)
        return length 
    end
    if getLabelWidth() >16 then 
        local lengthOverflow = getLabelWidth() - 16
        print("lengthOverflow:"..lengthOverflow)
        dump(lengthTable)
        if math.ceil((lengthOverflow + 2)/2)*3 <= lengthTable.words then 
            lbsDes = string.sub(lbsDes, 1, string.len(lbsDes)-math.ceil((lengthOverflow+2)/2)*3)..".."
        elseif lengthOverflow + 2 <= lengthTable.word/3*2 +lengthTable.letters then
            lbsDes = string.sub(lbsDes, 1, string.len(lbsDes)-lengthTable.words/3-lengthOverflow-2)..".."
        else
            print("lengthOverflow out of range")
        end
        
    end

    printf("~~~~~~~nUserID [%d]  lbsDes is[%s]~~~~~~~~~~~~~~~~~~~",nUserID,lbsDes)
    
    self:setPlayerLbs(nUserID,lbsDes)

    local tcyFriendPlugin = plugin.AgentManager:getInstance():getTcyFriendPlugin()
    if tcyFriendPlugin then
        if(cc.exports.sdkSession)then
            tcyFriendPlugin:onAgreeToBeInvitedBack(cc.exports.sdkSession, cc.exports.AgreeToBeInvitedType.kAgreeToBeInvitedSuccess,"")
            printf("~~~~~~~~~~~~~onAgreeToBeInvitedBack ok dxxw~~~~~~~~~~~~~~")
            dump(cc.exports.sdkSession)
            cc.exports.sdkSession=nil
        end
    end
end

function MyGameController:onBuyPropsThow(data)
    if self._baseGameData then
        local contentKey
        local PropData = self._baseGameData:getBuyPropRespInfo(data)
        if PropData.nState == 0 then
            local destIndex = self:rul_GetDrawIndexByChairNO(PropData.nDestChairNO)
            local sourceIndex = self:rul_GetDrawIndexByChairNO(PropData.nSourceChairNO)
            self:playDownBombAni(PropData)
            --local content = self:getGameStringByKey("G_UPPLAYER_OK")          
            --self:tipChatContent(destIndex, content)
            
            --[[my.scheduleOnce(function()
                local playerManager = self._baseGameScene:getPlayerManager()
                if playerManager then
                    playerManager:getGamePlayerByIndex(destIndex):playFacial("Node_Facial_pf.csb","animation_facial")
                end               
            end, 0.6)]]

            --self:playGamePublicSound("Snd_dianzan.mp3")
            
            local playerManager = self._baseGameScene:getPlayerManager()
            if playerManager then
                playerManager:updataDownInfo(PropData)
            end

            if tonumber(PropData.nCurrentCount) == tonumber(PropData.nMaxCount) then
                player:update({'SafeboxInfo'})
            end
        else
            contentKey = "G_GAME_BUY_PROP_FAIL_ANDROID"
            if device.platform == "ios" and cc.exports.LaunchMode["ALONE"] == MCAgent:getInstance():getLaunchMode() then
                contentKey = "G_GAME_BUY_PROP_FAIL_IOS"
            end
            self:showUpFaidTip(contentKey)
        end
    end
    --TODO
end

function MyGameController:onExpressionThow(data)
    if self._baseGameData then
        local contentKey
        local ExpressionThrowResp = self._baseGameData:getExpressionThrowRespInfo(data)
        self._baseGameScene:PlayExpressionAni(ExpressionThrowResp.nExpressionIndex)
        --self._baseGameScene:PlayExpressionSound(ExpressionThrowResp.nExpressionIndex)
    end
end

function MyGameController:playDownBombAni(data)
    local orgIndex = self:rul_GetDrawIndexByChairNO(data.nSourceChairNO)
    local desIndex = self:rul_GetDrawIndexByChairNO(data.nDestChairNO)
    
    local orgPoint = self:getPlayerPosition(orgIndex)
    local desPoint = self:getPlayerPosition(desIndex)
    
    local FixedDis = 688
    local FixedTime = 0.6
    --local dis = ccpDistance(orgPoint, desPoint)
    --local time = FixedTime*dis/FixedDis
    local time = FixedTime
    if (orgIndex == 2 and desIndex == 4) or (orgIndex == 1 and desIndex == 2)
        or (orgIndex == 2 and desIndex == 1) or (orgIndex == 4 and desIndex == 2) then
        time = 0.8
    end
    --local orgPoint = cc.p(100, 100)
    --local desPoint = cc.p(800, 500)
    local emitter = cc.Sprite:create("res/Game/GamePic/GameContents/bombDown.png")
    emitter:setPosition(orgPoint)
    local moveto = cc.MoveTo:create(time, desPoint)
    local rotateto = cc.RotateBy:create(time, 360)
    local Spawn = cc.Spawn:create(moveto, rotateto)
    self._baseGameScene:addChild(emitter)
    local function callback()
        emitter:setVisible(false)
        emitter:removeFromParentAndCleanup()
    end
    local action = cc.Sequence:create(Spawn, cc.CallFunc:create(callback)) 
    emitter:runAction(action)

    my.scheduleOnce(function()  
        if self:isInGameScene() == false then return end
        local playerManager = self._baseGameScene:getPlayerManager()
        if playerManager then
            playerManager:getGamePlayerByIndex(orgIndex):playFacial("Node_Facial_bishi.csb","animation_facial")
            playerManager:getGamePlayerByIndex(desIndex):playFacial("Node_Facial_heise.csb","animation_facial")
        end  
    end, time+0.2)
    my.scheduleOnce(function()  
        if self:isInGameScene() == false then return end
        local animationNode = cc.CSLoader:createNode("res/GameCocosStudio/csb/card_animation/Node_Bomb.csb")
        local action = cc.CSLoader:createTimeline("res/GameCocosStudio/csb/card_animation/Node_Bomb.csb")
        action:play("animation_SuperBomb", false)
        animationNode:setPosition(desPoint)
        self._baseGameScene:addChild(animationNode)  

        
        self:playGamePublicSound("Snd_Bomb.mp3")

        animationNode:setLocalZOrder(SKGameDef.SK_ZORDER_THROWN_ANIMATION)

        local callback = cc.CallFunc:create( function(sender)  
            animationNode:setVisible(false)
            animationNode:removeFromParentAndCleanup()
                      
        end )  
 
        self._baseGameScene:animationCallback(animationNode, action, callback)   
    end, time)

    --17期客户端埋点
    my.dataLink(cc.exports.DataLinkCodeDef.GAME_ACCEPT_DOWN_BOMB_PLAYER_MSG)
end


function MyGameController:onHostChanged(data)
    MyGameController.super.onHostChanged(self, data)

    if self._canReturnChartered then    
        if self:isTeamGameRoom() and self:isHallEntery() then
            if not PUBLIC_INTERFACE.IsStartAsTeam2V2() then
                self:tipMessageByKey("G_GAME_RETURN_TEAMROOM_TIP")
                self:showCharteredRoom(true)
            end
            return
        end
    end
    self._canReturnChartered = true
end

function MyGameController:onEnterGameDXXW(data)
    MyGameController.super.onEnterGameDXXW(self, data)
    self._canReturnChartered = false

    self._playerInfo = {}
    local playerInfoManager = self:getPlayerInfoManager()
    if playerInfoManager then
        for i= 1,self:getTableChairCount() do
            local info = playerInfoManager:getPlayerInfo(i)
            self._playerInfo[i] = clone(info)
        end
    end

    self._selfChairNO = self:getMyChairNO()

    if PUBLIC_INTERFACE.IsStartAsAnchorMatchGame() then
        self._baseGameConnect:reqGetGameRuleInfo()
    end
end

function MyGameController:onAutoQuit()
    self:stopAutoQuitTimer()

    if not self:isGameRunning() and 
       self:isTeamGameRoom() and 
       self:isHallEntery() and 
       self._canReturnChartered and 
       not self:isVisibleCharteredRoom() and
       not PUBLIC_INTERFACE.IsStartAsTeam2V2() and
       self._baseGameScene._resultLayer ~= nil then --返回拼桌界面
        self:onCloseResultLayerEx()
        self:tipMessageByKey("G_GAME_RETURN_TEAMROOM_TIP")
        self:showCharteredRoom(true)
        return
    end
    
    if not self:isGameRunning() and not self:isVisibleCharteredRoom() and not PUBLIC_INTERFACE.IsStartAsTeam2V2() then
        if self._baseGameScene == nil then
            return
        end
        local safeBox = self._baseGameScene:getSafeBox()
        if safeBox and safeBox:isVisible() then
            safeBox:showSafeBox(false)
        end

        local setting = self._baseGameScene:getSetting()
        if setting and setting:isVisible() then
            setting:showSetting(false)
        end

        local chat = self._baseGameScene:getChat()
        if chat and chat:isVisible() then
            chat:showChat(false)
        end

        if self._baseGameScene._resultLayer ~= nil then
            self:onCloseResultLayerEx()
        end
        self:onQuit()
    end
end

function MyGameController:onGameExit()
    -- print(debug.traceback("onExit"))
    local selfInfo = self._baseGameScene:getSelfInfo()
    if selfInfo then
        selfInfo:stopMatchingTimeTimerID()
    end

    print("onGameExit:hideBannerAdvert")
    self:hideBannerAdvert()

    MyGameController.super.onGameExit(self)

    self:stopGetTableDataResponseTimer()

    self:stopShieldVoiceTimer()
    self._isShieldVoice = false

    self:stopPlayerAbortTimer()

    self:stopCheckOffline()
    cc.exports.hasStartGame = false
    self:setResume(false)

    if self._NewPlayerTipsTipsTimerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._NewPlayerTipsTipsTimerID)
        self._NewPlayerTipsTipsTimerID = nil
    end

    self:stopJumpOtherRoomSchedule()

    cc.exports._isEnterRoomForGameScene = false
    self._needReturnRoomID = nil
    self._canGobackRoom = false

    self._arenaRankUpInfo = nil

    self.haveBombDouble = false
    self.m_nSalfDespoit = nil

    audio.playMusic(cc.FileUtils:getInstance():fullPathForFilename('res/Game/GameSound/BGMusic/BG.mp3'),true)
end

function MyGameController:startNewPlayerTips()
    if cc.exports.isGameNewPlayer then
        cc.exports.isGameNewPlayer = false

        local playerInfo = self._baseGamePlayerInfoManager:getPlayerInfo(self:getMyDrawIndex())
        if playerInfo and (playerInfo.nBout + playerInfo.nStandOff + playerInfo.nLoss + playerInfo.nWin) > 0 then
            return
        end

        self._baseGameScene._newPlayerTips:setVisible(true)
        local action = cc.CSLoader:createTimeline('res/GameCocosStudio/csb/Node_Playingcards.csb')
        action:play('animation_light', true)
        self._baseGameScene._newPlayerTips:runAction(action)
        self._baseGameScene._newPlayerTips:setLocalZOrder(SKGameDef.SK_ZORDER_RANK_CARD)
        local nodeTipBg = self._baseGameScene._newPlayerTips:getChildByName("PlayingcardsTipBG")
        nodeTipBg:getChildByName("Sprite_Playingcardslight2"):setVisible(false)
		nodeTipBg:getChildByName("Sprite_Playingcardslight3"):setVisible(false)
        self._NewPlayerTipsTipsTimerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
            if self:isInGameScene() == false then return end 
            if self._baseGameScene._newPlayerTipsPos then
				if true == self._baseGameScene:isVerticalCardsMode() then
					-- 竖排下不用提示炸弹理牌 的新手引导
					self._baseGameScene._newPlayerTipsPos = nil
					return
				end
				self._baseGameScene._newPlayerTips:setPosition(self._baseGameScene._newPlayerTipsPos)
				self._baseGameScene._newPlayerTipsPos = nil
                --local nodeTipBg = self._baseGameScene._newPlayerTips:getChildByName("PlayingcardsTipBG")
				nodeTipBg:getChildByName("PlayingcardsTip1"):setVisible(false)
				nodeTipBg:getChildByName("PlayingcardsTip2"):setVisible(true)
				--nodeTipBg:getChildByName("Sprite_Playingcardslight2"):setVisible(false)
				--nodeTipBg:getChildByName("Sprite_Playingcardslight3"):setVisible(true)
			else
				self._baseGameScene._newPlayerTips:setVisible(false)
				if self._NewPlayerTipsTipsTimerID then
					cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._NewPlayerTipsTipsTimerID)
					self._NewPlayerTipsTipsTimerID = nil
				end
			end
	    end, 3.0, false)
    end
end

function MyGameController:OnUserLevelData(soloPlayer)
    UserLevelModel:sendGetUserLevelReq(soloPlayer.nUserID, soloPlayer.nBout)
end

function MyGameController:OnUserLevelDataForSelf()
    local playerInfoManager = self:getPlayerInfoManager()
    if playerInfoManager then
        local nUserID         = playerInfoManager:getSelfUserID()
        UserLevelModel:sendGetUserLevelReq(nUserID)
    end
end

function MyGameController:ShowOtherUserLevel(msgLevelData)
    local playerManager = self._baseGameScene:getPlayerManager()
    if playerManager then
        playerManager:updataUserLevelInfo(msgLevelData)
    end
end

function MyGameController:onUpdateSelfLevel()
    local playerManager = self._baseGameScene:getPlayerManager()
    if playerManager then
        playerManager:updataUserLevelInfoForSelf(self:getMyDrawIndex(), cc.exports._userLevelData)
    end
end

function MyGameController:reqExchangeRoundTask()
    if self._baseGameConnect then
        self._baseGameConnect:reqExchangeRoundTask()
    end
end

function MyGameController:reqFinishExchangeRoundTask()
    if self._baseGameConnect then
        self._baseGameConnect:reqFinishExchangeRoundTask()
    end
end

function MyGameController:onExchangeRoundTask(data)
    if self._baseGameData then
        local taskData = self._baseGameData:getExchangeTaskInfo(data)
        self._GoldeEggTaskData = clone(taskData)
        self._baseGameScene:updateGoldeEggData(taskData)

        if self._GoldeEggTaskData and self._GoldeEggTaskData.nExchangeRoundNum >= self._GoldeEggTaskData.nMaxRoundNum then
            if self._baseGameConnect then   -- 砸金蛋的时候下发玩家昵称信息，主要针对进房间后，开局前的操作。
                self._baseGameConnect:sendSDKInfo()
            end
        end
    end
end

function MyGameController:onFinishExchangeRoundTask(data)
    if self._baseGameData then
        local taskData = self._baseGameData:getFinishExchangeTaskInfo(data)
        if self._GoldeEggTaskData then
            self._GoldeEggTaskData.nExchangeRoundNum = 0
            self._baseGameScene:updateGoldeEggData(self._GoldeEggTaskData)
        end
        --播放获得兑换券或银子动画
        self._baseGameScene:showBreakEggsAnimation(taskData.nPrizeType, taskData.nPrizeNum)
        if taskData.nPrizeType == 8 and taskData.nPrizeNum > 0 then 
            if cc.exports.oneRoundGameWinData.getVoucherNum == nil then -- 兑换券数
                cc.exports.oneRoundGameWinData.getVoucherNum = 0
            end
            cc.exports.oneRoundGameWinData.getVoucherNum = cc.exports.oneRoundGameWinData.getVoucherNum + taskData.nPrizeNum

            ExchangeCenterModel:addTicketNum(taskData.nPrizeNum)
        elseif taskData.nPrizeType == 1 and taskData.nPrizeNum > 0 then
            local drawIndex = self:getMyDrawIndex()
            self:addPlayerDeposit(drawIndex, taskData.nPrizeNum)
            local user=mymodel('UserModel'):getInstance()
            self._baseGameConnect:TablePlayerForUpdateDeposit(user.nDeposit)
        end
    end
end

function MyGameController:onUpdateExchangeNum()
    local playerManager = self._baseGameScene:getPlayerManager()
    if playerManager then
        playerManager:onUpdateExchangeNum()
    end
end

function MyGameController:onKickedOffClose()
    my.scheduleOnce(function()
        if self:isInGameScene() == false then return end
        if(self._dispatch)then
            self._dispatch:quit()
        end

        if (self:isTeamGameRoom() and self:isHallEntery()) or
        (self:isCharteredRoom() and not self:isRandomRoom()) then
            cc.exports.isAutogotoCharteredRoom = true
        end

        self:gotoHallScene()
    end, 0.3)
end

function MyGameController:onUpgradeUserLevel(data)
    if self._baseGameConnect then
        self._baseGameConnect:reqUpgradeUserLevel(data)
    end
end

function MyGameController:onGameWinExchange(data)
    if self._baseGameConnect then
        self._baseGameConnect:reqGameWinExchange(data)
    end
end

function MyGameController:onGameWinGetRoomExchange()
    if self._baseGameConnect then
        self._baseGameConnect:reqGameWinGetRoomExchange()
    end
end

function MyGameController:onGameUnableToContinue(data)
    print("onGameUnableToContinue")
    local okCallback = function()
        self:gotoHallScene()
    end
    local msg = self:getGameStringByKey("G_CANNOTCONNECT")
    local utf8Msg = MCCharset:getInstance():gb2Utf8String(msg, string.len(msg))
    self:popSureDialog(utf8Msg, "", "", okCallback, false)
end

function MyGameController:onLeaveGameOK()
    local charteredRoom = self._baseGameScene:getCharteredRoom()
    if charteredRoom then
        charteredRoom:quit()
    end

    local isFriendRoomMode = false
    local isArenaRoomMode = false
    if (self:isTeamGameRoom() and self:isHallEntery()) or
        (self:isCharteredRoom() and not self:isRandomRoom()) then
        cc.exports.isAutogotoCharteredRoom = true
        isFriendRoomMode = true
    end
    if self:isArenaPlayer() then
        isArenaRoomMode = true
    end

    --cc.exports._isEnterRoomForGameScene = true --测试代码
    if cc.exports._isEnterRoomForGameScene and isFriendRoomMode == false and isArenaRoomMode == false then
        --[[if type(cc.exports._isEnterRoomForGameScene) == "number" then
            local area, room = cc.exports.searchRoomForNotChartered(cc.exports._isEnterRoomForGameScene)
            local groupID = cc.exports._isEnterRoomUseGroupID 
            if groupID and groupID == 1 then
                self:onSelectTable(groupID)
            end
            PUBLIC_INTERFACE.EnterRoom(area.id, room.id, room, false)
        else]]--
        if self._safeCallbackParam then
            my.scheduleOnce(function()
                if self:isInGameScene() == false then return end
                player:transferSafeDeposit(self.m_SaveDepositNum)
            end, 0.3)
            self._leaveGameOk = true
            return
        else
            --self._needReturnRoomID = 10034 --测试代码
            --self.m_takeDepositNum = 100 --测试代码
            if self._needReturnRoomID ~= nil and self.m_takeDepositNum ~= nil then
                --弹出返回上级房间的对话框
                self:stopAutoQuitTimer()
                self._baseGameScene:addGoBackRoomPrompt(self._needReturnRoomID, self.m_takeDepositNum)
                self._needReturnRoomID = nil

                self._leaveGameOk = true
                return
            end
        end
    end

    self:gotoHallScene()

    if self._gotoHighRoom then
        dump(self._gotoHighRoom,"gotoHighRoom")
        self._gotoHighRoom = false
        --[[local MainCtrl          = require('src.app.plugins.mainpanel.MainCtrl')
        MainCtrl:quickStartBtClicked(nil)]]--
        local HallContext = import('src.app.plugins.mainpanel.HallContext'):getInstance()
        HallContext:dispatchEvent({name = HallContext.EVENT_MAP["hall_gotoGameByQuickStart"], value = {["autoDecideRoomScope"] = true}})
    end

    if self._gotoTimingGameRoom then
        dump(self._gotoTimingGameRoom,"_gotoTimingGameRoom")
        self._gotoTimingGameRoom = false
        local roomID = TimingGameModel:getTimingGameRoomID()

        local HallContext = import('src.app.plugins.mainpanel.HallContext'):getInstance()
        HallContext:dispatchEvent({name = HallContext.EVENT_MAP["gameScene_gotoGameByRoomId"], value = {["targetRoomId"] = roomID}})
    end

    if self._gotoTimingGameTicketRoom then
        dump(self._gotoTimingGameTicketRoom,"_gotoTimingGameTicketRoom")
        self._gotoTimingGameTicketRoom = false
        local room, bAllDone = TimingGameModel:getTimingGameTicketRoom()

        if room then
            local HallContext = import('src.app.plugins.mainpanel.HallContext'):getInstance()
            HallContext:dispatchEvent({name = HallContext.EVENT_MAP["gameScene_gotoGameByRoomId"], value = {["targetRoomId"] = room.nRoomID}})
        end
    end

    self._CurrentExchangeData = nil -- 离开要清空对局送兑换券数据，用于再次进入时候，退出提示正常显示
    --进阶提示房
    if self._promptRoom  and self._promptRoom.jumpNewRoom == true then
        dump(self._promptRoom,"jumpNewRoom")
        --require("src.app.plugins.roomspanel.RoomListModel"):getInstance():enterRoom(self._promptRoom)
        local HallContext = import('src.app.plugins.mainpanel.HallContext'):getInstance()
        HallContext:dispatchEvent({name = HallContext.EVENT_MAP["gameScene_gotoGameByRoomId"], value = {["targetRoomId"] = self._promptRoom["targetRoomInfo"]["nRoomID"]}})
        self._promptRoom = nil
    end

    print("MyGameController:onLeaveGameOK onLeaveGameOK", self._gotoScoreRoom)
    if self._gotoScoreRoom then
        self._gotoScoreRoom = false
        --cc.load('MainCtrl'):getInstance():onScoreRoomBtn(true)
        local HallContext = import('src.app.plugins.mainpanel.HallContext'):getInstance()
        HallContext:dispatchEvent({name = HallContext.EVENT_MAP["gameScene_gotoScoreGame"]})
    end

    if cc.exports.jumpHighRoom == true then
        local HallContext = import('src.app.plugins.mainpanel.HallContext'):getInstance()
        HallContext:dispatchEvent({name = HallContext.EVENT_MAP["hall_gotoGameByQuickStart"], value = {["autoDecideRoomScope"] = true}})
    end

    --cardmaker
    if self._MyGameCardMakerInfo then
        self._MyGameCardMakerInfo:resert()
    end
    --测试代码
    --[[if cc.exports.test_switchRoom == true then
        local HallContext = import('src.app.plugins.mainpanel.HallContext'):getInstance()
        HallContext:dispatchEvent({name = HallContext.EVENT_MAP["gameScene_gotoScoreGame"]})
    end]]--
end

function MyGameController:onSocketConnect()
    UIHelper:recordRuntime("EnterGameScene", "MyGameController:onSocketConnect")
    
    -- common proxy begin
    if self._proxyConnect then
        local UR_CONNECT_SERVER = 0 + 110
        self._baseGameConnect:sendRequest(UR_CONNECT_SERVER, self._connectSvrStr, self._connectSvrStr:len(), false)
    end
    -- common proxy end

    self._isResume = false
    self._session = -1
    self._connectTimes = 0
    self:setResponse(self:getResWaitingNothing())
    self._isConnected = true

    self:sendGamePulse()

    --[[if self:isRandomRoom() and cc.exports._isEnterRoomForGameScene == false then
        --[[my.scheduleOnce(function()
            if self._baseGameConnect then
                self._baseGameConnect:gc_CheckVersion()
            end
        end,3.0)]]--
        --不确定原来为什么延时3s，会让进入游戏时间凭空增加3s；换成0.5s试试
        --[[my.scheduleOnce(function()
            if self._baseGameConnect then
                 UIHelper:recordRuntime("EnterGameScene", "MyGameController gc_CheckVersion")
                self._baseGameConnect:gc_CheckVersion()
            end
        end, 0.5)
    else
        if self._baseGameConnect then
            UIHelper:recordRuntime("EnterGameScene", "MyGameController gc_CheckVersion")
            self._baseGameConnect:gc_CheckVersion()
        end    
    end]]--

    --从大厅进入游戏，等待gameNode创建完毕后再走消息流程
    local checkFunc = function()
        if self:isInGameScene() == false then
            return false
        end
        local gameSceneNode = self._baseGameScene and self._baseGameScene._gameNode
        if gameSceneNode ~= nil and not tolua.isnull(gameSceneNode) then
            return true
        end
        return false
    end
    local doFunc = function()
        if self:isInGameScene() == false then
            return
        end
        if self._baseGameConnect then
            UIHelper:recordRuntime("EnterGameScene", "MyGameController gc_CheckVersion")
            self._baseGameConnect:gc_CheckVersion()
        end
    end
    TimerManager:waitUntil("Timer_GameScene_WaitGameNodeCreated", checkFunc, doFunc, 0.2, 30)
end

function MyGameController:onEnterRoomOKForGameScene()
    self._baseGameNetworkClient:disconnect()
    --清除下桌面信息
    local roomInfo = PublicInterFace.GetCurrentRoomInfo()
    local roomType = nil
    if roomInfo then
        roomType = roomInfo["type"]
    end
    
    self.haveBombDouble = true
    if (roomType == 1) then
        self.haveBombDouble = false
    end

    local clock = self._baseGameScene:getClock()
    if clock then
        clock:resetClock()
    end

    local gameTools = self._baseGameScene:getTools()
    if gameTools then
        gameTools:onGameWin()
    end

    self._baseGameUtilsInfoManager.bEndedExit = 1
    --关闭竞技场的结算界面等begin
    if self._baseGameScene._arenaOverStatement then
        self._baseGameScene._arenaOverStatement:onExit()
        self._baseGameScene._arenaOverStatement = nil
    end

    if self._baseGameScene._arenaNewStatement then
        self._baseGameScene._arenaNewStatement:onExit()
        self._baseGameScene._arenaNewStatement = nil
    end
    --关闭竞技场的结算界面等end
    --关闭结算 和 定时器
    if self._baseGameScene._resultLayer ~= nil then               
        self:onCloseResultLayer()
    end
    self:stopCheckOffline()

    if self:isArenaPlayer() then 
        if self._baseGameArenaInfoManager:getBoutScore() then
            self._baseGameArenaInfoManager._arenaInfo.nBoutScore = 0
        end
        self:setArenaScore(0)
        --self:setArenaTotalScore(0)
    end

    self:clearGameTable()
    if self._baseGamePlayerInfoManager then
        self._baseGamePlayerInfoManager:clearPlayersInfo()
    end
    local playerManager = self._baseGameScene:getPlayerManager()
    if playerManager then
        playerManager:clearPlayers(true)
        playerManager:clearPlayerReady()
    end
    local selfInfo = self._baseGameScene:getSelfInfo()
    if selfInfo then
        selfInfo:showMatching(false)
    end

    self:setSelfInfo()
    self:setUtilsInfo()

    my.scheduleOnce(function()
        self._baseGameNetworkClient = MCAgent:getInstance():createClient(PublicInterFace.GetGameServerIp(), PublicInterFace.GetGameServerPort())

        local function onDataReceived(clientid, msgtype, session, request, data)
            self:onDataReceived(clientid, msgtype, session, request, data)
        end
        if self._baseGameNetworkClient then
            self._baseGameNetworkClient:setCallback(onDataReceived)

            if not self._baseGameConnect then
                self:setConnect()
            end
            if not self._baseGameNotify then
                self:setNotify()
            end
            -- Connect socket after setting connecttion and setting notification
            self._baseGameNetworkClient:connect()
        end
    end)
end

function MyGameController:showWaitArrangeTable(bShow)
    MyGameController.super.showWaitArrangeTable(self, bShow)

    local selfInfo = self._baseGameScene:getSelfInfo()
    if selfInfo then
        selfInfo:showMatchingJumpend(false)
    end

    if bShow then --在显示匹配的地方添加定时器（跳转房间用）
        if self._needReturnRoomID and not self:isGameRunning() and self._canGobackRoom then
            self._canGobackRoom = false
            local playerInfoManager = self:getPlayerInfoManager()
            local playerDeposit = 0
            if playerInfoManager then
                local playerInfo = playerInfoManager:getPlayerInfo(self:getMyDrawIndex())
                playerDeposit = playerInfo.nDeposit
            end
            --local returnRoomInfo = cc.exports.getRoomInfoForRoomID(self._needReturnRoomID)
            local returnRoomInfo = RoomListModel.roomsInfo[self._needReturnRoomID]
            if playerDeposit < returnRoomInfo.nMinDeposit then
                cc.exports._isEnterRoomForGameScene = true
                self._baseGameConnect:gc_LeaveGameEx()
                --self.m_takeDepositNum = returnRoomInfo.nMinDeposit * 5 - playerDeposit

                local safeDeposit = 0
                local user=mymodel('UserModel'):getInstance()
                if cc.exports.isSafeBoxSupported() then
                    safeDeposit = user.nSafeboxDeposit
                else
                    if cc.exports.isBackBoxSupported() then
                        safeDeposit = user.nBackDeposit
                    end
                end
                if safeDeposit >= returnRoomInfo.nMinDeposit - playerDeposit then
                    self.m_takeDepositNum = safeDeposit
                    if safeDeposit >= returnRoomInfo.nMinDeposit * 8 - playerDeposit then
                        self.m_takeDepositNum = returnRoomInfo.nMinDeposit * 8 - playerDeposit
                    end
                else
                    self.m_takeDepositNum = -1
                end
            else
                cc.exports._isEnterRoomForGameScene = self._needReturnRoomID
                self._needReturnRoomID = nil
                self._baseGameConnect:gc_LeaveGameEx()
            end
            
            return
        end
        if self._needReturnRoomID then
            if selfInfo then
                selfInfo:showMatchingJumpend(true)
                selfInfo:showMatching(false)
            end
        end
    end
end

function MyGameController:stopJumpOtherRoomSchedule()
    if self._JumpOtherRoomTimerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._JumpOtherRoomTimerID)
        self._JumpOtherRoomTimerID = nil
    end
    --顺便重置下变量
    self._safeCallbackParam = nil
    self._leaveGameOk = false
    self._PayCallbackNeedGobackRoomID = nil
end

function MyGameController:JumpOtherRoom()
    local roomInfo = PublicInterFace.GetCurrentRoomInfo()
    local RoomJumpForGameScene = cc.exports._gameJsonConfig.RoomJumpForGameScene
    if RoomJumpForGameScene and not self:isGameRunning() then
        local roomInfo = PublicInterFace.GetCurrentRoomInfo()
        for i = 1, table.maxn(RoomJumpForGameScene) do
            local toRoomData = RoomJumpForGameScene[i][tostring(roomInfo.id)]
            if toRoomData ~= nil and type(toRoomData.ToRoom)=="number" and type(toRoomData.WaitTime) == "number"
                and type(toRoomData.PlayerCount) == "number" and type(toRoomData.ToRoomPlayerCount) == "number" then

                local playerInfoManager = self:getPlayerInfoManager()
                local playerDeposit = 0
                if playerInfoManager then
                    local playerInfo = playerInfoManager:getPlayerInfo(self:getMyDrawIndex())
                    playerDeposit = playerInfo.nDeposit
                end
                --local otherRoomInfo = cc.exports.getRoomInfoForRoomID(toRoomData.ToRoom)
                local otherRoomInfo = RoomListModel.roomsInfo[toRoomData.ToRoom]

                --[[if roomInfo.nGroupId == 2 and roomInfo.JumpToSubRoom == true then
                    roomInfo.nGroupId =  1
                    local destRoom = roomInfo.nRoomID
                    if playerDeposit > otherRoomInfo.max then
                        self._safeCallbackParam = {}
                        self._safeCallbackParam._needReturnRoomID = destRoom
                        self._safeCallbackParam._isEnterRoomForGameScene = destRoom
                        self.m_SaveDepositNum = playerDeposit - otherRoomInfo.max
                        --self:onSaveDeposit(self.m_SaveDepositNum)
                        cc.exports._isEnterRoomForGameScene = true
                        cc.exports._isEnterRoomUseGroupID= 1
                        self._baseGameConnect:gc_LeaveGameEx()
                    else
                        self._needReturnRoomID = destRoom
                        cc.exports._isEnterRoomForGameScene = destRoom
                        cc.exports._isEnterRoomUseGroupID= 1
                        self._baseGameConnect:gc_LeaveGameEx()
                    end
                else]]--
                    if playerDeposit > otherRoomInfo.nMaxDeposit then
                        self._safeCallbackParam = {}
                        self._safeCallbackParam._needReturnRoomID = roomInfo.nRoomID
                        self._safeCallbackParam._isEnterRoomForGameScene = toRoomData.ToRoom
                        self.m_SaveDepositNum = playerDeposit - otherRoomInfo.nMaxDeposit
                        --self:onSaveDeposit(self.m_SaveDepositNum)
                        cc.exports._isEnterRoomForGameScene = true
                        self._baseGameConnect:gc_LeaveGameEx()
                    else
                        self._needReturnRoomID = roomInfo.nRoomID
                        cc.exports._isEnterRoomForGameScene = toRoomData.ToRoom
                        self._baseGameConnect:gc_LeaveGameEx()
                    end
                    --cc.exports._isEnterRoomUseGroupID= nil
                --end
            end
        end
    end
end

function MyGameController:KeepCurrentRoom()
    --[[local roomInfo = PublicInterFace.GetCurrentRoomInfo()

    local area, room = cc.exports.searchRoomForNotChartered(roomInfo.nRoomID)
    PUBLIC_INTERFACE.EnterRoom(area.id, room.id, room, false)]]--

    local roomInfo = PublicInterFace.GetCurrentRoomInfo()
    if roomInfo == nil then return end

    local HallContext = import('src.app.plugins.mainpanel.HallContext'):getInstance()
    HallContext:dispatchEvent({name = HallContext.EVENT_MAP["gameScene_gotoGameByRoomId"], value = {["targetRoomId"] = roomInfo["nRoomID"]}})
end

function MyGameController:GoBackRoom(roomID)
    --[[local area, room = cc.exports.searchRoomForNotChartered(roomID)
    PUBLIC_INTERFACE.EnterRoom(area.id, room.id, room, false)]]--

    if roomID == nil then return end

    local HallContext = import('src.app.plugins.mainpanel.HallContext'):getInstance()
    HallContext:dispatchEvent({name = HallContext.EVENT_MAP["gameScene_gotoGameByRoomId"], value = {["targetRoomId"] = roomID}})
end

function MyGameController:onKeyBack()
    if self._baseGameScene._JumpRoomPrompt then
        self._baseGameScene._JumpRoomPrompt:removePrompt()
        self._baseGameScene._JumpRoomPrompt = nil
        return
    end

    --[[if self._baseGameScene._GoBackRoomPrompt then
        self._baseGameScene._GoBackRoomPrompt:removeEventHosts()
        self._baseGameScene._GoBackRoomPrompt:removeFromParentAndCleanup()
        self._baseGameScene._GoBackRoomPrompt = nil
        return
    end]]--

    if self._baseGameScene._arenaGameResult then
        self._baseGameScene._arenaGameResult:onKeyboardReleased()
        self._baseGameScene._arenaGameResult = nil
        return
    end

    if self._baseGameScene._anchorMatchGameResult then
        self._baseGameScene._anchorMatchGameResult:onKeyBack()
        self._baseGameScene._anchorMatchGameResult = nil
        return
    end

    local loadingLayer = self._baseGameScene:getLoadingLayer()
    if loadingLayer and loadingLayer:isVisible() then
        return
    end
    if self._arenaStatement and self._arenaStatement.isAlive and self._arenaStatement:isAlive() then
        self._arenaStatement:onKeyBack()
        return
    end

    --任务
    local gameTask = self._baseGameScene:getGameTask()
    if gameTask and gameTask:isVisible() == true then
        if gameTask.ctrl and  gameTask.ctrl.onClose then
            gameTask.ctrl:onClose()
            return
        end
    end

    self:onQuit()
end

function MyGameController:createArenaInfoManager()
    self._baseGameArenaInfoManager = MyGameArenaInfoManager:create(self)
    self:setArenaInfo()
end

function MyGameController:showArenaResult()
    TimerManager:scheduleOnceUnique("Timer_GameScene_DelayedArenaGameResultOnGameWin", function()
    --my.scheduleOnce(function()
        if self:isInGameScene() == false then return end
        if not self._baseGameScene then return end

        local totalScore        = self._baseGameArenaInfoManager:getMatchScore()
        local roundScore        = self._baseGameArenaInfoManager:getBoutScore()
        local lastAddition      = self._baseGameArenaInfoManager:getLastRoundAddition()
        local nextAddition      = self._baseGameArenaInfoManager:getAddition()
        local additionDetail    = self._baseGameArenaInfoManager:getAdditionDetail()
        local initHP            = self._baseGameArenaInfoManager:getInitHP() 
        local diffHP            = self._baseGameArenaInfoManager:getDiffHP()
        local leftHP            = self._baseGameArenaInfoManager:getHP()
        local awardCount, awardList = self._baseGameArenaInfoManager:getAwardInfoNumber(), self._baseGameArenaInfoManager:getAwardInfo()

        --结算界面的数据
        local arenaInfo = self._baseGameArenaInfoManager:getArenaInfo()
        roundScore = roundScore or 0
        --totalScore = 15000
        --roundScore = 8000
        --diffHP = 0
        local statementData = {
            nTotalScore      = totalScore,
            nTotalScorePrev      = totalScore - roundScore,
            nArenaRoomGrade = 1,
        }
        statementData.boutInfo = {}
        local boutInfo = statementData.boutInfo
        boutInfo.nWinBout = arenaInfo.nWinBout
        boutInfo.nMaxStreaking = arenaInfo.nMaxStreaking
        boutInfo.nTotalBout = arenaInfo.nTotalBout
        statementData.levelData = {}
        local levelData = statementData.levelData
        levelData.levelScoreList = {}
        levelData.levelRewardsList = {}

        --奖励数据
        local rewardList = {}
        for i = 1, awardCount do
            rewardList[i] = {}
            rewardList[i].levelScoreList = awardList[i].nMatchScore
            rewardList[i].levelRewardsList={}
            for j = 1, awardList[i].nAwardNumber do
                table.insert(rewardList[i].levelRewardsList, awardList[i].awardType[j])
            end
        end
        table.sort(rewardList, function ( item, item2 )
            return item.levelScoreList < item2.levelScoreList
        end)

        for i = 1, #rewardList do
            levelData.levelScoreList[i] = rewardList[i].levelScoreList
            levelData.levelRewardsList[i] = {}
            for j = 1, #rewardList[i].levelRewardsList do
                table.insert(levelData.levelRewardsList[i], rewardList[i].levelRewardsList[j])
            end
        end

        levelData.nScoreMax = rewardList[#rewardList].levelScoreList

        statementData.nLevel = self:calLevelByScore(totalScore, statementData)

        self:receiveLevelUpRewards(totalScore, statementData.nTotalScorePrev, levelData.levelRewardsList, statementData) --直接把奖励加上去先
        --additionDetail = {0,10,1,5,0}
        if additionDetail then
            local bonusItems = {}
            for i = 1, 5 do  --加成最多5种类型
                bonusItems[i] = {}
                bonusItems[i].nType = i
                bonusItems[i].nValue = additionDetail[i]
            end
            statementData.bonusItems = bonusItems
        end
        local uitleInfoManager  = self:getUtilsInfoManager()
        local nRoomID         = uitleInfoManager:getRoomID()
        --local roomGrade = PublicInterface.GetCurrRoomGrade(nRoomID)
        local roomInfo = RoomListModel.roomsInfo[nRoomID]
        local roomGradeIndex = roomInfo and roomInfo["gradeIndex"] or 1
        statementData.nArenaRoomGrade = math.max(roomGradeIndex - 1, 1)

        if leftHP > 0 then
            self._baseGameScene:setArenaStatement(statementData, diffHP >= 0) --根据有无扣血判断输赢
        else
            self._baseGameScene:setArenaOverStatement(statementData)
        end

    --end, 2)
    end, 2.0)
end

function MyGameController:receiveLevelUpRewards(totalScore, totalScorePrev, rewardsList, statementData)
    local curLevel = self:calLevelByScore(totalScore, statementData)
    local prevLevel = self:calLevelByScore(totalScorePrev, statementData)
    if curLevel <= 0 or curLevel <= prevLevel then
        return
    end
    for i = prevLevel + 1, curLevel do
        local rewardData = rewardsList[i]
        for j = 1, 3 do
            if rewardData[j] and rewardData[j].nCount ~= nil and rewardData[j].nCount > 0 then
                self:updateArenaPlayerRewardData(rewardData[j].nType, rewardData[j].nCount)
            end
        end
    end
end

function MyGameController:calLevelByScore(score, data)
    if score == nil or score < 0 then return 0 end

    if data == nil then return 0 end

    local levelItemsData = data.levelData
    if levelItemsData == nil then return 0 end

    local level = 0
    local levelScoreList = levelItemsData.levelScoreList
    for i = 1, #levelScoreList do
        if score >= levelScoreList[i] then
            level = i
        else
            break
        end
    end
    local MyGameArenaProgress       = import("src.app.Game.mMyGame.MyGameArena.MyGameArenaProgress")

    if level < 0 then level = 0 end
    if level > MyGameArenaProgress.MAX_LEVEL_COUNT then level = MyGameArenaProgress.MAX_LEVEL_COUNT end
    return level
end


function MyGameController:onExitGameClicked()
    if self:isConnected() and self._baseGameConnect then
        local gameTools = self._baseGameScene:getTools()
        if gameTools and gameTools:isQuitBtnEnabled() then
            if self:isTeamGameRoom() and self:isHallEntery() and not self:isVisibleCharteredRoom() and not PUBLIC_INTERFACE.IsStartAsTeam2V2() then
                self._baseGameConnect:TeamGameRoom_LeaveGame()
            else
                self._baseGameConnect:gc_LeaveGameEx()
            end
        else
            self:tipMessageByKey("G_GAME_GAMERUNING_CANT_QUIT")
        end
    else
        if(self._dispatch)then
            self._dispatch:quit()
        end

        if (self:isTeamGameRoom() and self:isHallEntery()) or
        (self:isCharteredRoom() and not self:isRandomRoom()) then
            cc.exports.isAutogotoCharteredRoom = true
        end

        self:gotoHallScene()
    end
end

function MyGameController:UpgradeLevelForArenaPlayer(gameWin)
    if cc.exports._userLevelData.nLevelExp == nil or cc.exports._userLevelData.nNextExp == nil then
        return
    end
    local nextLevel = cc.exports._userLevelData.nLevel
    local isMax = true --是否满级
    if cc.exports._userLevelData.nLevelExp < cc.exports._userLevelData.nNextExp then
        nextLevel = nextLevel + 1
        isMax = false
    else
        isMax = true
        gameWin.nLevelExpUp[self:getMyChairNO()+1] = 0
    end
    cc.exports._userLevelData.nLevelExp = cc.exports._userLevelData.nLevelExp + gameWin.nLevelExpUp[self:getMyChairNO()+1]

    if not isMax and cc.exports._userLevelData.nLevelExp >= cc.exports._userLevelData.nNextExp then --升级
        --播动画 重新请求下自己的等级
        if self._baseGameScene then
            self._baseGameScene:ShowLevelUpgrade(nextLevel, cc.exports._userLevelData.nUpgradeExchange, cc.exports._userLevelData.nUpgradeDeposit)
            self:OnUserLevelDataForSelf()
            if cc.exports.oneRoundGameWinData.getVoucherNum == nil then -- 兑换券数
                cc.exports.oneRoundGameWinData.getVoucherNum = 0
            end
            cc.exports.oneRoundGameWinData.getVoucherNum = cc.exports.oneRoundGameWinData.getVoucherNum + cc.exports._userLevelData.nUpgradeExchange

            require("src.app.plugins.ExchangeCenter.ExchangeCenterModel"):getInstance():addTicketNum(cc.exports._userLevelData.nUpgradeExchange)

            if cc.exports._userLevelData.nUpgradeDeposit then
                local drawIndex = self:getMyDrawIndex()
                self:addPlayerDeposit(drawIndex, cc.exports._userLevelData.nUpgradeDeposit)
                local user=mymodel('UserModel'):getInstance()
                self._baseGameConnect:TablePlayerForUpdateDeposit(user.nDeposit)
            end
        end
    end
    cc.exports._userLevelData.nLevel = nextLevel
    if self._arenaNewStatement ~= nil then
        self._arenaNewStatement:updateLevel()
    end
end

function MyGameController:onArenaUserRankUp(data)
    if data == nil or data.value == nil then return end
    if self:isArenaPlayer() ~= true then return end

    self._arenaRankUpInfo = {}
    self._arenaRankUpInfo.data = data.value
end

function MyGameController:getRankUpData()
    if self._arenaRankUpInfo == nil then
        return
    end
    local rankUpDataRaw = self._arenaRankUpInfo.data
    if rankUpDataRaw == nil then return end

    local myUserName = self._baseGamePlayerInfoManager:getPlayerUserNameByDrawIndex(self:getMyDrawIndex())
    local utf8MyUserName = MCCharset:getInstance():gb2Utf8String(myUserName, string.len(myUserName))
    local myNickSex = self._baseGamePlayerInfoManager:getPlayerNickSexByIndex(self:getMyDrawIndex())

    --测试数据
    --[[local rankUpData = {
        {
            ["userName"] = utf8MyUserName, 
            ["userGender"] = myNickSex, 
            ["userScore"] = 32000, 
            ["userScorePrev"] = 21000, 
            ["userRank"] = 3, 
            ["userRankPrev"] = 9
        },
        {
            ["userName"] = "hezhen001",
            ["userGender"] = 0, 
            ["userScore"] = 25000, 
            ["userRank"] = 4
        }
    }]]
    
    local szAnotherUserName = rankUpDataRaw.szUsername
    local utf8AnotherUserName = ""
    if szAnotherUserName ~= nil then
        utf8AnotherUserName = MCCharset:getInstance():gb2Utf8String(szAnotherUserName, string.len(szAnotherUserName))
    end
    local rankUpData = {
        {
            ["userName"] = utf8MyUserName, 
            ["userGender"] = myNickSex, 
            ["userScore"] = rankUpDataRaw.nCurScore, 
            ["userScorePrev"] = rankUpDataRaw.nLastScore, 
            ["userRank"] = rankUpDataRaw.nCurRank, 
            ["userRankPrev"] = rankUpDataRaw.nLastRank
        },
        {
            ["userName"] = utf8AnotherUserName, 
            ["userGender"] = rankUpDataRaw.nSexSupportRule, 
            ["userScore"] = rankUpDataRaw.nScoreSupportRule, 
            --["userRank"] = rankUpDataRaw.nRankSupportRule
            ["userRank"] = rankUpDataRaw.nCurRank + 1
        }
    }

    return rankUpData
end


function MyGameController:setArenaInfo(onGetArenaInfo)
    if not self._baseGameArenaInfoManager then return end

    if PUBLIC_INTERFACE.IsStartAsArenaPlayer() then
        self._baseGameArenaInfoManager:setIsArenaPlayer(true)
        local arenaUserInfo = ArenaDataSet:getData("ArenaUserInfo")
        local arenaMatchInfo = ArenaDataSet:getData("ArenaMatchInfo")
        if arenaUserInfo ~= nil and arenaMatchInfo ~= nil then
            self._baseGameArenaInfoManager:setArenaInfo(arenaUserInfo)
            self._baseGameArenaInfoManager:setArenaInfo(arenaMatchInfo)
            if type(onGetArenaInfo) == 'function' then onGetArenaInfo() end
        else
            ArenaModel:getCurrentArenaDetail(function(dataMap, respondType)
                if      respondType == 'userArena' then
                    local arenaInfo = {
                        nMatchID        = dataMap.nMatchID,
                        nHP             = dataMap.nHP,
                        nAddition       = dataMap.nAddition,
                        nBout           = dataMap.nBout,
                        nStreaking      = dataMap.nStreaking,
                        nTopStreaking   = dataMap.nTopStreaking,
                        nWinBout        = dataMap.nWinBout,
                        nMatchScore     = dataMap.nMatchScore,
                        nLevel          = dataMap.nLevel
                    }
                    self._baseGameArenaInfoManager:setArenaInfo(arenaInfo)
                elseif  respondType == 'arenaInfo' then
                    local arenaInfo = {
                        nInitHP             = dataMap.nInitHP,
                        nAwardInfoNumber    = dataMap.nAwardInfoNumber,
                        szMatchName         = dataMap.szMatchName,
                        awardInfo           = dataMap.awardInfo,
                        IsForceQuit         = dataMap.IsForceQuit,
                    }
                    self._baseGameArenaInfoManager:setArenaInfo(arenaInfo)
                    if type(onGetArenaInfo) == 'function' then onGetArenaInfo() end
                end
            end, false)
        end
    else
        self._baseGameArenaInfoManager:setIsArenaPlayer(false)
    end
    self._baseGameScene:refreshWinningStreakBtn()
end

function MyGameController:RobScoreStart(WinPlayce, ChairNO)
    if self:isArenaPlayer() and WinPlayce == 1 then
        local isWin = false
        if ChairNO == self:getMyChairNO() or ChairNO == self._baseGameUtilsInfoManager:RUL_GetNextChairNO(self._baseGameUtilsInfoManager:RUL_GetNextChairNO(self:getMyChairNO())) then
            isWin = true
        end
        if isWin then
            self:playGamePublicSound("Arena_win.mp3")
        else
            self:playGamePublicSound("Arena_lose.mp3")
        end
        self._baseGameScene:showRobScorePanel(isWin)
    end
end

function MyGameController:onRecieveArenaEvents(data) 
    local info = nil
    if self._baseGameData then
        info = self._baseGameData:onRecieveArenaEvents(data)
    end
    if not info then return end

    if  info.nEventType == BaseGameDef.BASEGAME_EAET_SCORE_CHANGED  then
        self._baseGameArenaInfoManager:addBoutScore(info.nEventValue)
        local arenaInfo = self._baseGameScene:getArenaInfo()
        if arenaInfo then
            arenaInfo:addArenaScore(info.nEventValue, info.nReserved[1])
        end
    elseif  info.nEventType == BaseGameDef.BASEGAME_EAET_STOPED_HP          then
    elseif  info.nEventType == BaseGameDef.BASEGAME_EAET_STOPED_SCOREMAX    then
    elseif  info.nEventType == BaseGameDef.BASEGAME_EAET_REWARD_NOTIFY      then
    end
end

function MyGameController:onRecieveArenaResult(data) 
    local info = nil
    if self._baseGameData then
        info = self._baseGameData:onRecieveArenaResult(data)
    end
    if not info then return end

    self._baseGameArenaInfoManager:setArenaInfo({
        nHP             = info.nHP,
        nDiffHP         = info.nDiffHP,
        nMatchScore     = info.nMatchScore,
        nBoutScore      = info.nMatchDiffScore,
        nMatchID        = info.nMatchID,
        nStreaking      = info.nStreaking,
        nMaxStreaking   = info.nMaxStreaking,
        nTotalBout      = info.nTotalBout,
        nWinBout        = info.nWinBout,
        nBoutAddition   = info.nBoutAddition,
        nAddition       = info.nAddition,
        nRewardLevelOld = info.nRewardLevelOld,
        nRewardLevelNew = info.nRewardLevelNew,
        nAdditionDetail = info.nAdditionDetail
    })
    self:refreshArenaDataInHall(info)
    
    local arenaInfo = self._baseGameScene:getArenaInfo()
    arenaInfo:onArenaResult(info)

    self:showArenaResult()
end

function MyGameController:updateArenaPlayerRewardData(nType, nValue)
    if nType == 1 then --银两
        self:addPlayerDeposit(self:getMyDrawIndex(), nValue)
    elseif nType == 3 then
        ExchangeCenterModel:addTicketNum(nValue)
    end
end

function MyGameController:refreshArenaDataInHall(info)
    if info == nil then return end

    local userArenaData = {
        nLevel = info.nRewardLevelNew,
        nStreaking = info.nStreaking,
        nWinBout = info.nWinBout,
        nAddition = info.nAddition,
        nUserID = info.nUserID,
        nMatchID = info.nMatchID,
        nMatchScore = info.nMatchScore,
        nBout = info.nTotalBout,
        nTopStreaking = info.nMaxStreaking,
        nDaySignUpCount = self._baseGameArenaInfoManager:getDaySignUpCount(),
        nGameID = info.nGameID,
        nHP = info.nHP
    }
    if userArenaData.nHP <= 0 then
        userArenaData.nMatchID = 0
    end
    ArenaModel:setMyArenaData(userArenaData)
end

--一局结算页面关闭
function MyGameController:onArenaStatementClosed()
    if self:isArenaPlayer() ~= true then return end

    --准备界面
    self:onCloseResultLayer()
    --刷新积分
    --[[local arenaInfo = self._baseGameScene:getArenaInfo()
    if arenaInfo ~= nil then
        arenaInfo:setTotalScoreWithoutAnim(self._baseGameArenaInfoManager:getMatchScore())
        arenaInfo:setArenaScoreWithoutAnim(0)
    end]]
    --self._isNeedBgmOn = true
    --self:playBGM() --重新打开背景音乐
end

function MyGameController:onArenaPlayerDXXW(data)   
    local info = nil
    if self._baseGameData then
        info = self._baseGameData:onArenaPlayerDXXW(data)
    end
    if not info then return end

    PublicInterFace.OnArenaDXXW()
    local arenaDXXWInfo = {
        nMatchID    = info.nMatchID,
        nHP         = info.nHP,
        nBoutScore  = info.nBoutScore,
    }
    self._baseGameArenaInfoManager:setArenaInfo(arenaDXXWInfo)
    self._baseGameScene:setArenaInfo()
    local SKHandCardsManager = self._baseGameScene:getSKHandCardsManager()
    if SKHandCardsManager then
        SKHandCardsManager:ope_SortSelfHandCards()
    end
    self:setArenaInfo(handler(self, self.setArenaInfoView))
end

function MyGameController:onGetHomeInfoOnDXXW(data)
    local info = nil
    if self._baseGameData then
        info = self._baseGameData:onGetHomeInfoOnDXXW(data)
    end

    if self:IS_BIT_SET(info.nEnterFlag, BaseGameDef.BASEGAME_TELLONDXXW_RandomTeam) then
        self:setHallEntery(true)
        PublicInterFace.onFriendRoomDXXW()

        if not self._dispatch then
            self._baseGameScene:createChartredRoom()
        end
    else
        self:setHallEntery(false)
    end

    if(self._dispatch)then
        self._dispatch:onGetHomeInfoOnDXXW(info)
    end
end

function MyGameController:restartCurrentRoom()
    local roomInfo = PublicInterFace.GetCurrentRoomInfo()
    if not self:isGameRunning() then
        local roomInfo = PublicInterFace.GetCurrentRoomInfo()

        local playerInfoManager = self:getPlayerInfoManager()
        local playerDeposit = 0
        if playerInfoManager then
            local playerInfo = playerInfoManager:getPlayerInfo(self:getMyDrawIndex())
            playerDeposit = playerInfo.nDeposit
        end
        --if playerDeposit > roomInfo.nMaxDeposit or playerDeposit < roomInfo.nMinDeposit then
            self._safeCallbackParam = {}
            self._safeCallbackParam._needReturnRoomID = nil
            self._safeCallbackParam._isEnterRoomForGameScene = roomInfo.nRoomID
            self._PayCallbackNeedGobackRoomID = roomInfo.nRoomID
            self._needReturnRoomID = nil
            cc.exports._isEnterRoomForGameScene = true
            self._leaveGameOk = true
            self:GoBackRoom(roomInfo.nRoomID)
        --[[else
            self._needReturnRoomID = nil
            cc.exports._isEnterRoomForGameScene = true
            self._leaveGameOk = true
            self:GoBackRoom(roomInfo.nRoomID)
        end]]
    end
end

function MyGameController:isSupport5BombDouble()
    -- 如果服务器 开局没有通知设置self._n5BombDouble， 那就从GameConfig.json配置获取
    if self._n5BombDouble and self._n5BombDouble == true then
        return true
    else
        local gameJsonConfig = cc.exports._gameJsonConfig
        if gameJsonConfig.NoShuffleRoom ~= nil then
            local roomInfo = PublicInterFace.GetCurrentRoomInfo()
            if roomInfo then
                --local isSupportDouble = gameJsonConfig.NoShuffleRoom[tostring(roomInfo.nRoomID)] and gameJsonConfig.NoShuffleRoom.FiveDoubleOpen
                local isSupportDouble = gameJsonConfig.NoShuffleRoom.FiveDoubleOpen
                if isSupportDouble == true then
                    return true
                end
            end
        end       
    end
    return false
end

function MyGameController:onGame5BombDouble(data)
    if self._baseGameData then
        local openTagTab = self._baseGameData:get5BombDoubleOpenData(data)
        if openTagTab and tonumber(openTagTab.nFiveBoomDoubleOpen) == 1 then
            self._n5BombDouble = true
        end
    end
end

function MyGameController:onGameResultExchangeInfo(data)
    if self._baseGameData then
        local exchangeData= self._baseGameData:getGameReusltExchangeInfo(data)
        self._CurrentExchangeData = clone(exchangeData)

        -- 根据服务器传来的nNeedReward值判断是否需要领兑换券奖励
        if self._CurrentExchangeData and 1 == self._CurrentExchangeData.nNeedReward then
            local prizeNum = 0
            if self._CurrentExchangeData and self._CurrentExchangeData.nRewardNums then
                prizeNum = self._CurrentExchangeData.nRewardNums
            end
            ExchangeCenterModel:addTicketNum(prizeNum)
            -- 发送领取消息
            self:onGameWinGetRoomExchange()
        end
    end
end

function MyGameController:onGameResultActivityScore(data)
    if self._baseGameData then
        local scoreData= self._baseGameData:getGameResultActivityData(data)
        self._ActBaseScoreData = clone(scoreData)
    end
end

function MyGameController:getGameResultActivityScore()
    return self._ActBaseScoreData
end

function MyGameController:clearGameResultActivityScore()
    self._ActBaseScoreData = nil
end

function MyGameController:getCurrentExchangeBoutInfo()
    if self._CurrentExchangeData then
        return self._CurrentExchangeData
    end
    return nil
end

function MyGameController:isSupportVerticalCardMode()
    if 1 == verticalCardsMode then
        return true
    end
    return false
end


function MyGameController:isSupportLogSortCard()
    if not cc.exports._gameJsonConfig.LogSortCard then return end
    local LogSortCardMode = cc.exports._gameJsonConfig.LogSortCard
    if 1 == LogSortCardMode then
        return true
    end
    return false
end

--出牌时记录理牌信息并写入缓存
function MyGameController:LogSortCard()
    if not self:isSupportLogSortCard() then
        return
    end

    local data = cc.exports.LogSortCardData

    if self:getArrageCardMode() == MyGameDef.SORT_CARD_BY_CROSS then
        data.nCross = data.nCross and (data.nCross + 1) or 1
    else
        data.nVertical = data.nVertical and (data.nVertical + 1) or 1
    end

    local flag = self:GetSortCardFlag()
    if flag == SKGameDef.SORT_CARD_BY_ORDER then
        data.nOrderSort = data.nOrderSort and (data.nOrderSort + 1) or 1
    elseif flag == SKGameDef.SORT_CARD_BY_NUM then
        data.nNumSort = data.nNumSort and (data.nNumSort + 1) or 1
    elseif flag == SKGameDef.SORT_CARD_BY_SHPAE then
        data.nColorSort = data.nColorSort and (data.nColorSort + 1) or 1
    else
        data.nBoomSort = data.nBoomSort and (data.nBoomSort + 1) or 1
    end

    self:saveLogCache()
end

--发送理牌日志
function MyGameController:sendSortCardLog()
    if not self:isSupportLogSortCard() then
        return
    end
     
    local data = cc.exports.LogSortCardData
    local playerInfoManager = self:getPlayerInfoManager()

    data.nUserID        = playerInfoManager:getSelfUserID()
    data.nRoomID        = self._baseGameUtilsInfoManager:getRoomID()
    data.nCross         = data.nCross or 0
    data.nVertical      = data.nVertical or 0
    data.nOrderSort     = data.nOrderSort or 0
    data.nNumSort       = data.nNumSort or 0
    data.nColorSort     = data.nColorSort or 0
    data.nBoomSort      = data.nBoomSort or 0
    data.nClickFlush    = data.nClickFlush or 0
    local AssistCommon = require('src.app.GameHall.models.assist.common.AssistCommon'):getInstance()
    AssistCommon:onSortCardLogReq(cc.exports.LogSortCardData)
    cc.exports.LogSortCardData = {}
    self:deleteLogCache()
end

--自己玩家的银子数量显示
function MyGameController:setSoloPlayer(soloPlayer)
    MyGameController.super.setSoloPlayer(self, soloPlayer)
    if self:getMyDrawIndex() == self:rul_GetDrawIndexByChairNO(soloPlayer.nChairNO) then
        if PublicInterFace.IsStartAsTimingGame() then
            local infoData = TimingGameModel:getInfoData()
            local timingScore = soloPlayer.nReserved[3]
            if infoData and infoData.seasonScore then
                timingScore = infoData.seasonScore
            end
            if "number" ~= type(timingScore) then return end
            self:setPlayerTimingScore(self:getMyDrawIndex(), timingScore)
        else
            if "number" ~= type(soloPlayer.nDeposit) then return end
            if self._baseGameScene:getSelfDepositText() then
                self._baseGameScene:getSelfDepositText():setMoney(soloPlayer.nDeposit)
            end
        end
    end
end

--出牌提示
function MyGameController:onHint()
    --提示时，关闭切牌特效
    local nodeEffect = self._baseGameScene._gameNode:getChildByTag(MyGameDef.MY_TAG_EFFECT_SORT)
    if nodeEffect then
        nodeEffect:removeFromParent()
        nodeEffect = nil
    end
    MyGameController.super.onHint(self)
end

--打完一局后刷新银子
function MyGameController:setPlayerDeposit(drawIndex, deposit)
    print("-------------------------function MyGameController:setPlayerDeposit(drawIndex, deposit)------------------------------------------",drawIndex, deposit)
    MyGameController.super.setPlayerDeposit(self, drawIndex, deposit)
    if self:getMyDrawIndex() == drawIndex then
        if "number" ~= type(deposit) then return end
        if self._baseGameScene and self._baseGameScene:getSelfDepositText() then
            self._baseGameScene:getSelfDepositText():setMoney(deposit)
        end
    else
        local playerManager = self._baseGameScene:getPlayerManager()
        if playerManager then
           playerManager:setPlayerDeposit(drawIndex, deposit)
        end
    end
end

--出牌时更新理牌缓存
function MyGameController:saveLogCache()
    local user = mymodel('UserModel'):getInstance()
    local filename ="SortCardLogCache_" .. user.nUserID .. ".xml"
    local data = checktable(cc.exports.LogSortCardData)

    my.saveCache(filename,data)
end

--断线重连读理牌缓存
function MyGameController:readLogCache()
    local user = mymodel('UserModel'):getInstance()
    local filename ="SortCardLogCache_" .. user.nUserID .. ".xml"

    cc.exports.LogSortCardData = my.readCache(filename) or {}
end

--发送理牌日志后删除日志缓存
function MyGameController:deleteLogCache()
    local user = mymodel('UserModel'):getInstance()
    local filename ="SortCardLogCache_" .. user.nUserID .. ".xml"
    local fullpath=my.getFullCachePath(filename)
    cc.FileUtils:getInstance():removeFile(fullpath)
end

--过牌记录理牌日志
function MyGameController:onPassCard()
    if not self._baseGameConnect then
        return
    end

    local SKHandCardsManager = self._baseGameScene:getSKHandCardsManager()
    if SKHandCardsManager then
        SKHandCardsManager:ope_UnselectSelfCards()
    end

    self:hideOperationBtns()

    self._baseGameConnect:reqPassCards(self._bAutoPlay)
    --过牌记录理牌日志
    self:LogSortCard()
--    --出牌时让理牌中提示可以从头开始找
    local SKHandCardsManager        = self._baseGameScene:getSKHandCardsManager()
    SKHandCardsManager:resetRemind()
end

--继续游戏重新设置玩家信息
function MyGameController:resetPlayer()
    local playerManager = self._baseGameScene:getPlayerManager()
    playerManager:resetPlayerManager()
end

--断线重连设置报警状态
function MyGameController:setPlayerAlarm()
    local playerManager = self._baseGameScene:getPlayerManager()
    local cardsCounts = self._baseGameUtilsInfoManager:getCardsCount()
    for i = 1, self:getTableChairCount() do
        if cardsCounts[i]>10 then
            playerManager:setPlayerAlarm(i,false)
        else
            playerManager:setPlayerAlarm(i,true)
        end
    end
end

-- 设置游戏场景里，一些按钮的点击使能
function MyGameController:btnsSetEnableTouch(status)
    if self._baseGameScene._MyArrageBtn and self._baseGameScene._MyArrageBtn:isVisible() then
        self._baseGameScene._MyArrageBtn:setEnabled(status)
        --self._baseGameScene._MyArrageBtn:setVisible(status)
    end

    if self._baseGameScene._MyResetBtn and self._baseGameScene._MyResetBtn:isVisible() then
        self._baseGameScene._MyArrageBtn:setEnabled(status)
        --self._baseGameScene._MyArrageBtn:setVisible(status)
    end
    
end

function MyGameController:getConvertBtnShowNode()
    if self._baseGameScene and self._baseGameScene._gameNode then
        local gameNode = self._baseGameScene._gameNode
        if gameNode:getChildByName('Panel_BG') then
            return gameNode:getChildByName('Panel_BG')
        end
    end

    return false
end

--仅仅为了--17期客户端埋点
function MyGameController:onQuitFromRoom()
    local okCallback = function()
        if(self._dispatch)then
            self._dispatch:quit()
        end

        --17期客户端埋点
        my.dataLink(cc.exports.DataLinkCodeDef.GAME_TIPS_VIEW_RELOGIN_BTN)
        
        self:gotoHallScene()
    end
    local msg = self:getGameStringByKey("G_DISCONNECTION")
    local utf8Msg = MCCharset:getInstance():gb2Utf8String(msg, string.len(msg))
    self:popSureDialog(utf8Msg, "", "", okCallback, false)
end

function MyGameController:onUpdateScoreInfo(gameWin)
    if not self:isNeedDeposit() and cc.exports.nScoreInfo.nScore 
    and not PublicInterFace.IsStartAsTimingGame() then
        --现在判断胜局处理，跑得快则赢  20200304 by taoqiang
        local winChairNo = -1
        for i = 1, 4 do
            if gameWin.nPlace[i] == 1 then
                winChairNo = i
                break
            end
        end
        winChairNo = winChairNo - 1
        if winChairNo == self:getMyChairNO() or winChairNo == self._baseGameUtilsInfoManager:RUL_GetNextChairNO(self._baseGameUtilsInfoManager:RUL_GetNextChairNO(self:getMyChairNO())) then
--        local nScore = gameWin.nScoreDiffs[self:getMyChairNO()+1]
--        if nScore > 0 then
            cc.exports.nScoreInfo.nScore = cc.exports.nScoreInfo.nScore + 1
            --玩家当前积分
            if cc.exports._gameJsonConfig.WeakenScoreRoom and cc.exports._gameJsonConfig.WeakenScoreRoom.Open and cc.exports._gameJsonConfig.WeakenScoreRoom.Open == 1 then
                if cc.exports.nScoreInfo.nScore and cc.exports._gameJsonConfig.WeakenScoreRoom.Score then

                    local str = "（" .. cc.exports.nScoreInfo.nScore .. "/" .. cc.exports._gameJsonConfig.WeakenScoreRoom.Score .. "）"
                    local SceneNode = self._baseGameScene._gameNode
                    my.scheduleOnce(function()
                        --用了定时器，就必须校验节点有效性，因为定时器内容执行时，可能已经退出了游戏场景
                        if self:isInGameScene() == false then
                            print("MyGameController:onUpdateScoreInfo, set score, but not in gamescene already!!!")
                            return
                        end
                        SceneNode:getChildByName("Panel__Score"):getChildByName("Score"):setString(str)
                    end, 2)
                    if cc.exports.nScoreInfo.nScore >= cc.exports._gameJsonConfig.WeakenScoreRoom.Score or cc.exports.nScoreInfo.nReward == 1 then 
                    else
                        SceneNode:getChildByName("Panel__Score"):setVisible(true)
                    end
                end
            end
        end
    end
end

function MyGameController:onOutScoreRoom()
    local result = false
    if self:isNeedDeposit() or PublicInterFace.IsStartAsTimingGame() or PUBLIC_INTERFACE.IsStartAsAnchorMatchGame() then
    else
        --玩家当前积分
        if cc.exports._gameJsonConfig.WeakenScoreRoom and cc.exports._gameJsonConfig.WeakenScoreRoom.Open and cc.exports._gameJsonConfig.WeakenScoreRoom.Open == 1 then
            if cc.exports.nScoreInfo.nScore and cc.exports._gameJsonConfig.WeakenScoreRoom.Score then
                if  (cc.exports.nScoreInfo.nScore and cc.exports.nScoreInfo.nScore >= cc.exports._gameJsonConfig.WeakenScoreRoom.Score) or cc.exports.nScoreInfo.nReward == 1 then
                    local config = cc.exports.GetRoomConfig()

  
                    local sureDialog = cc.CSLoader:createNode( "res/hallcocosstudio/tips/suredialog.csb" )
                    local size = cc.Director:getInstance():getWinSize()
                    sureDialog:getChildByName("Panel_Main"):setPosition(size.width/2, size.height/2)
                    local mainBg = sureDialog:getChildByName("Panel_Main"):getChildByName("Panel_Animation")
                    mainBg:getChildByName("Btn_Close"):setVisible(false)
                    local str = string.format(config['SCORE_ROOM_SCORE_OUT_RESULT'], cc.exports._gameJsonConfig.WeakenScoreRoom.ScoreRoomSilver)
                    mainBg:getChildByName("Text_TipContents"):setString(str)
                    mainBg:getChildByName("Btn_Confirm"):onTouch(function(e)
                        if(e.name=='ended')then
                            self:onQuit()
                        end
                    end)
                    cc.Director:getInstance():getRunningScene():addChild(sureDialog)

                    result = true
                end
            end
        end
    end
    return result
end

function MyGameController:onThrowCardFailed()
    print("MyGameController:onThrowCardFailed")

    self:showOperationBtns()
end
function MyGameController:onBuyExpression(drawIndex, propID)
    print("MyGameController:onBuyExpression")

    local playerInfoManager = self:getPlayerInfoManager()
    local uitleInfoManager  = self:getUtilsInfoManager()
    if not playerInfoManager or not uitleInfoManager then return end
    local playerInfo = playerInfoManager:getPlayerInfo(drawIndex)
    if not playerInfo then return end

    local realProp = propID
    local count = 0
    local silverType = 2  --1 - 游戏, 2 - 保险箱, 3 - 后备箱

    if propID == 1 then  --闪电
        if cc.exports.ExpressionInfo.nLightingNum and cc.exports.ExpressionInfo.nLightingNum > 0 then
            realProp = 5
            count = 1
        else
            if device.platform == "ios" then
                if cc.exports.LaunchMode["ALONE"] == MCAgent:getInstance():getLaunchMode() then
                    silverType = 3
                end
            end
        end
    
    elseif propID == 2 then  --玫瑰
        if cc.exports.ExpressionInfo.nRoseNum and cc.exports.ExpressionInfo.nRoseNum > 0 then
            realProp = 7
            count = 1
        else
            if device.platform == "ios" then
                if cc.exports.LaunchMode["ALONE"] == MCAgent:getInstance():getLaunchMode() then
                    silverType = 3
                end
            end
        end
    end

    local nPlatform = 0
    -- 0表示安卓 1表示IOS 2表示同城游IOS
    if device.platform == "ios" then
        if cc.exports.LaunchMode["ALONE"] == MCAgent:getInstance():getLaunchMode() then
            nPlatform = 1
        else
            nPlatform = 2
        end
    end

    --local ExchangeLotteryModel = require('src.app.plugins.ExchangeLottery.ExchangeLotteryModel'):getInstance()
    local nOpen = 0
    if cc.exports.isExchangeLotterySupported() then
        nOpen = 1
    end
    
    local data              = {
        nUserID             = playerInfoManager:getSelfUserID(),
        nRoomID             = uitleInfoManager:getRoomID(),
        nTableNO            = playerInfoManager:getSelfTableNO(),
        nChairNO            = playerInfoManager:getSelfChairNO(),
            
        nDestUserID         = playerInfo.nUserID,
        nDestChairNO        = playerInfo.nChairNO,
        nPropID             = realProp,
        nCurrentCount       = count,
        nSilverType         = silverType,
        nOpen               = nOpen, --预留接口
        nOSType             = nPlatform,
    }

    local PropModel = require('src.app.plugins.shop.prop.PropModel'):getInstance()
    PropModel:onBuyExpression(data)
end

function MyGameController:onExpressionThrow(data)
    local PropModel = require('src.app.plugins.shop.prop.PropModel'):getInstance()
    local expressionThrow = PropModel:DealExpression(data)
    
    if expressionThrow.nPropID == 7 then --使用玫瑰
        if expressionThrow.nChairNO == self:getMyChairNO() then
            PropModel:updateRoseNum(expressionThrow.nCurrentCount)
        end
        self:playExpressionRoseAni(expressionThrow)
    elseif expressionThrow.nPropID == 5 then --使用闪电
        if expressionThrow.nChairNO == self:getMyChairNO() then
            PropModel:updateLightingNum(expressionThrow.nCurrentCount)
        end
        self:playExpressionLightingAni(expressionThrow)
    elseif expressionThrow.nPropID == 2 then --购买玫瑰
        self:playExpressionRoseAni(expressionThrow)
        player:update({'SafeboxInfo'})
    elseif expressionThrow.nPropID == 1 then --购买闪电
        self:playExpressionLightingAni(expressionThrow)
        player:update({'SafeboxInfo'})
    end

    local playerManager = self._baseGameScene:getPlayerManager()
    if playerManager and expressionThrow.nPropID > 3 then --使用道具
        if expressionThrow.nChairNO == self:getMyChairNO() then
            playerManager:updataExpressionInfo(expressionThrow)
        end
    elseif expressionThrow.nOpen == 1 and expressionThrow.nPropID == 1 and expressionThrow.nChairNO == self:getMyChairNO() then
        local ExchangeLotteryModel = require("src.app.plugins.ExchangeLottery.ExchangeLotteryModel"):getInstance()
        if ExchangeLotteryModel:GetActivityOpen() then
            self:tipMessageByKey("GAME_EXPRESSION_BUY_LOTTERY")
        end
    end
end

function MyGameController:playExpressionRoseAni(data)
    local orgIndex = self:rul_GetDrawIndexByChairNO(data.nChairNO)
    local desIndex = self:rul_GetDrawIndexByChairNO(data.nDestChairNO)
    
    local orgPoint = self:getPlayerPosition(orgIndex)
    local desPoint = self:getPlayerPosition(desIndex)
    
    local FixedDis = 688
    local FixedTime = 0.6
    --local dis = ccpDistance(orgPoint, desPoint)
    --local time = FixedTime*dis/FixedDis
    local time = FixedTime
    if (orgIndex == 2 and desIndex == 4) or (orgIndex == 1 and desIndex == 2)
        or (orgIndex == 2 and desIndex == 1) or (orgIndex == 4 and desIndex == 2) then
        time = 0.8
    end
    --local orgPoint = cc.p(100, 100)
    --local desPoint = cc.p(800, 500)
    local emitter = cc.Sprite:create("res/Game/GamePic/GameContents/meigui.png")
    emitter:setPosition(orgPoint)
    local moveto = cc.MoveTo:create(time, desPoint)
    local rotateto = cc.RotateBy:create(time, 360)
    local Spawn = cc.Spawn:create(moveto, rotateto)
    self._baseGameScene:addChild(emitter)
    local function callback()
        emitter:setVisible(false)
        emitter:removeFromParentAndCleanup()
    end
    local action = cc.Sequence:create(Spawn, cc.CallFunc:create(callback)) 
    emitter:runAction(action)

    my.scheduleOnce(function()
        if self:isInGameScene() == false then return end

        self:playGamePublicSound("Rose.mp3") 
        local actionName = "meigui"    
        local spMeigui = sp.SkeletonAnimation:create("res/Game/Skeleton/meigui.json", "res/Game/Skeleton/meigui.atlas",1)  
        spMeigui:setAnimation(0, actionName, false) 
        --spMeigui:setDebugBonesEnabled(false) 
        spMeigui:setPosition(desPoint)

        self._baseGameScene:addChild(spMeigui)

        my.scheduleOnce(function()
            if self:isInGameScene() == false then return end
            if spMeigui then
                spMeigui:setVisible(false)
                spMeigui:removeFromParentAndCleanup()
            end
            end, 1.15)
    end, time)

end

function MyGameController:playExpressionLightingAni(data)
    local orgIndex = self:rul_GetDrawIndexByChairNO(data.nChairNO)
    local desIndex = self:rul_GetDrawIndexByChairNO(data.nDestChairNO)
    
    local orgPoint = self:getPlayerPosition(orgIndex)
    local desPoint = self:getPlayerPosition(desIndex)

    if desIndex == 3 then --是对家
        desPoint.y= desPoint.y - 40
    end

    local orgPointOfYun = cc.p(desPoint.x, desPoint.y+70)
    
    local FixedDis = 688
    local FixedTime = 0.6
    --local dis = ccpDistance(orgPoint, desPoint)
    --local time = FixedTime*dis/FixedDis
    local time = FixedTime
    if (orgIndex == 2 and desIndex == 4) or (orgIndex == 1 and desIndex == 2)
        or (orgIndex == 2 and desIndex == 1) or (orgIndex == 4 and desIndex == 2) then
        time = 0.8
    end
    --local orgPoint = cc.p(100, 100)
    --local desPoint = cc.p(800, 500)
    local emitter = cc.Sprite:create("res/Game/GamePic/GameContents/yun.png")
    emitter:setPosition(orgPoint)
    local moveto = cc.MoveTo:create(time, orgPointOfYun)
    --local rotateto = cc.RotateBy:create(time, 360)
    emitter:setScale(0.4)
    local scaleto = cc.ScaleTo:create(time, 1.0, 1.0)
    local Spawn = cc.Spawn:create(moveto, scaleto)
    self._baseGameScene:addChild(emitter)
    local function callback()
        emitter:setVisible(false)
        emitter:removeFromParentAndCleanup()
    end
    local action = cc.Sequence:create(Spawn, cc.CallFunc:create(callback)) 
    emitter:runAction(action)

    my.scheduleOnce(function()
        if self:isInGameScene() == false then return end

        local actionName = "shandian"    
        local spShandian = sp.SkeletonAnimation:create("res/Game/Skeleton/shandian.json", "res/Game/Skeleton/shandian.atlas",1)  
        spShandian:setAnimation(0, actionName, false) 
        --spMeigui:setDebugBonesEnabled(false) 
        spShandian:setPosition(desPoint)

        self._baseGameScene:addChild(spShandian)

        my.scheduleOnce(function()
            if self:isInGameScene() == false then return end
            self:playGamePublicSound("Lighting.mp3")  
            end, 0.1)

        my.scheduleOnce(function()
            if self:isInGameScene() == false then return end
            if spShandian then
                spShandian:setVisible(false)
                spShandian:removeFromParentAndCleanup()
            end
            end, 1)
    end, time)

end

-- 开局发牌阶段禁用托管
function MyGameController:ope_DealCard()
    local gameTools = self._baseGameScene:getTools()
    if gameTools then
        gameTools:setBtnRobotStatus(false)
    end

    MyGameController.super.ope_DealCard(self)
end

-- 发牌结束后再使能托管
function MyGameController:onDealCardOver()
    MyGameController.super.onDealCardOver(self)
    local gameTools = self._baseGameScene:getTools()
    if gameTools then
        gameTools:setBtnRobotStatus(true)
    end

    local SKHandCardsManager        = self._baseGameScene:getSKHandCardsManager()
    SKHandCardsManager:setShapeButtonsStatus()

    
    local nGuideUser = self._baseGameUtilsInfoManager._utilsStartInfo.nGuideUser
    local nGuideBout = self._baseGameUtilsInfoManager._utilsStartInfo.nGuideBout
    self._guideStatus = MyGameDef.NEWUSERGUIDE_NOT_OPEN

    local UserModel = mymodel('UserModel'):getInstance()
    local nUserID = UserModel.nUserID
    if nUserID and nUserID == nGuideUser then
        if nGuideBout == 1 then
            self:startNewUserGuideBoutOne()
        elseif nGuideBout == 2 then
            self:startNewUserGuideBoutTwo()
        end
    end

end

function MyGameController:onSafeBoxFailed(request, response, data)
    MyGameController.super.onSafeBoxFailed(self, request, response, data)

    if request == BaseGameDef.BASEGAME_GR_SAFEBOX_DEPOSIT_DIFFER then
        self:refreshDepositByHall() 
    end
end

--使用大厅接口刷新银两
function MyGameController:refreshDepositByHall()
    print("MyGameController:refreshDepositByHall")
    --my.startProcessing("检测到用户银两与服务端不一致，正在尝试刷新...", 3.0)
    player:update({'UserGameInfo'}, function() 
        if self:isInGameScene() == false then
            print("MyGameController:refreshDepositByHall, UserGameInfo updated but not in gamescene!!!")
            return
        end
        local user = mymodel('UserModel'):getInstance()
        if user.nDeposit then
            self:setPlayerDeposit(self:getMyDrawIndex(), user.nDeposit)
        end
    end)
end
function MyGameController:onStartSoloTable(data)
    MyGameController.super.onStartSoloTable(self, data)

    my.scheduleOnce(function()
        if self:isInGameScene() then
            self:onRefreshTableInfoWhenGameStartLost()
        end
    end,3.0)
    
end
function MyGameController:onRefreshTableInfoWhenGameStartLost()
    if self:isWaitArrangeTableShow() then
        self:onResume()
        self._selfChairNO = self:getMyChairNO()
        self._playerInfo = {}
        local playerInfoManager = self:getPlayerInfoManager()
        if playerInfoManager then
            for i= 1,self:getTableChairCount() do
                local info = playerInfoManager:getPlayerInfo(i)
                self._playerInfo[i] = clone(info)
            end
        end
    end
end

function MyGameController:isTouchEnable()
    if self._guideStatus 
        and self._guideStatus ~= MyGameDef.NEWUSERGUIDE_NOT_OPEN
        and self._guideStatus ~= MyGameDef.NEWUSERGUIDE_BOUTONE_FINISHED 
        and self._guideStatus ~= MyGameDef.NEWUSERGUIDE_BOUTTWO_FINISHED then
        return true
    end

    if AutoSupplyModel:isAlive() then
        return false
    end

    return MyGameController.super.isTouchEnable(self)
end

function MyGameController:PlayPopAni(node)
    if not tolua.isnull(node) then
        node:setScale(0.1)
        node:setOpacity(255)
        local actScaleTo1 = cc.ScaleTo:create(0.3, 2.5)
        local actScaleTo2 = cc.ScaleTo:create(0.1, 1.85)
        local actPop = cc.Sequence:create(actScaleTo1,actScaleTo2)
        node:runAction(actPop)
    end
end

function MyGameController:closePliginOnstartGuide()
    local chat = self._baseGameScene:getChat()
    if chat and chat:isVisible() and chat.onClose then
        chat:onClose()
    end

    local setting = self._baseGameScene:getSetting()
    if setting and setting:isVisible() and setting.onClose then
        setting:onClose()
    end

    local task = self._baseGameScene:getGameTask()
    if task and task:isVisible() and task.ctrl and task.ctrl.onClose then
        task.ctrl:onClose()
    end

    local share = self._baseGameScene:getGameShare()
    if share and share:isVisible() and share.ctrl and share.ctrl.onClose then
        share.ctrl:closeShare()
    end

    local rule = self._baseGameScene:getGameRule()
    if rule and rule:isVisible() and rule and rule.onClose then
        rule:onClose()
    end

    local PluginProcessModel = mymodel('hallext.PluginProcessModel'):getInstance() 
    PluginProcessModel:closePluginOnGuide()

    self._baseGameScene._playerManager:onHidePlayerInfo()
end

function MyGameController:refreshAwardRetDeposit() --连胜挑战刷新银两
    local user=mymodel('UserModel'):getInstance()
    if(user.nDeposit)then
        self:setPlayerDeposit(self:getMyDrawIndex(), user.nDeposit)
        self._baseGameConnect:TablePlayerForUpdateDeposit(user.nDeposit)
    end
    if self._dispatch then
        self._dispatch:updateGameDataForMoney()
    end
end

--广告模块 start
function MyGameController:isShowBanner()
    if not AdvertModel:isNeedShowBanner() then return false end 

    local user=mymodel('UserModel'):getInstance()
    local SKHandCardsManager = self._baseGameScene:getSKHandCardsManager()
    if not SKHandCardsManager then return false end 
    local uitleInfoManager  = self:getUtilsInfoManager()
    local nRoomID         = uitleInfoManager:getRoomID()
    local adverRoom = cc.exports.getAdverRoomValue()
    local adverBout = cc.exports.getAdverBoutValue()
    print("MyGameController:isShowBanner:adverRoom")
    dump(adverRoom)
    print("MyGameController:isShowBanner:adverBout")
    dump(adverBout)
    local adverStatus = false
    --1、对局数超过XX的用户，积分场内，玩家出完手牌，一直到结算就不显示
    --2、对局数超过XX的用户，不洗牌和经典，玩家出完手牌，一直到结算就不显示（不同房间，是否显示也需要做分别开关）
    --3、对局数超过XX的用户，积分场的结算界面
    local nHandCount = SKHandCardsManager:getSKHandCards(self:getMyDrawIndex()):getHandCardsCount()
    if self:isGameRunning() then print("GameRunning:") end
    if self:isNeedDeposit() then print("isNeedDeposit:") end  
    print("nHandCount:"..nHandCount.."user.nBout:"..user.nBout)
    if nHandCount <= 0 and self:isGameRunning() then
    --if  self:isGameRunning() then
        if not self:isNeedDeposit() and user.nBout and adverBout and adverBout["1"] and user.nBout >= adverBout["1"] then
            adverStatus = true
        end

        if self:isNeedDeposit() and user.nBout and adverBout and adverBout["2"] and user.nBout >= adverBout["2"] 
            and adverRoom and adverRoom[tostring(nRoomID)] and adverRoom[tostring(nRoomID)] > 0 then
            adverStatus = true
        end
    end

    if not self:isGameRunning() then --游戏结束了
        if not self:isNeedDeposit() and user.nBout and adverBout and adverBout["3"] and user.nBout >= adverBout["3"] then
            adverStatus = true
        end
    end
    print("isShowBanner return ", adverStatus)
    return adverStatus
end
-- 广告模块 end

--自动补银
function MyGameController:onAutoSupply()
    local roomInfo = PublicInterFace.GetCurrentRoomInfo()
    my.informPluginByName({pluginName = 'AutoSupplyCtrl', params = {data = roomInfo}})
end

function MyGameController:isSupportAutoSupply()
    print("isSupportAutoSupply")

    if not cc.exports.isSafeBoxSupported() then
        return false
    end

    local autoSupplyRoom = cc.exports.getAutoSupplyRoomValue()
    local roomInfo = PublicInterFace.GetCurrentRoomInfo()
    dump(autoSupplyRoom)
    dump(roomInfo)
    if (autoSupplyRoom and autoSupplyRoom[tostring(roomInfo.nRoomID)] == 0) or not autoSupplyRoom[tostring(roomInfo.nRoomID)] then
        print("return false 1")
        return false
    end

    if not cc.exports.isAutoSupplySupported() then
        print("return false 2")
        return false
    end

    local NobilityPrivilegeModel      = import("src.app.plugins.NobilityPrivilege.NobilityPrivilegeModel"):getInstance()
    local bOpen, bUnlock, nLevel = NobilityPrivilegeModel:isAutoSupply()
    if bOpen and not bUnlock then
        print("return false 3", bOpen, bUnlock, nLevel)
        return false
    end

    return true
end

function MyGameController:doSupply()
    local user = mymodel("UserModel"):getInstance()
    local roomInfo = PublicInterFace.GetCurrentRoomInfo()
    local bStartSupply = CacheModel:getCacheByKey("StartSupply" .. tostring(user.nUserID))
    if type(bStartSupply) ~= "boolean" then
        bStartSupply = false
    end
    print("MyGameController:doSupply begin")
    if not bStartSupply then return end

    local ratioInfo = cc.exports.getAutoSupplyRatioValue()
    local supplyCount = CacheModel:getCacheByKey("SupplyCount" .. roomInfo.nRoomID .. tostring(user.nUserID))
    if type(supplyCount) == "string" and tonumber(supplyCount) > 0 then
        
    else
        supplyCount =  roomInfo.nMinDeposit * ratioInfo[tostring(roomInfo.nRoomID)]
    end

    if not self._baseGamePlayerInfoManager then
        return
    end
    local gameDeposit = self._baseGamePlayerInfoManager:getPlayerDeposit(1)
    local safeboxDeposit = user.nSafeboxDeposit

    print("MyGameController:doSupply  gameDeposit:"..gameDeposit.."safeboxDeposit:"..safeboxDeposit.."supplyCount:"..supplyCount)

    -- 需取出银两数
    local transDeposit = tonumber(supplyCount) - gameDeposit

    if transDeposit == 0 then 
        return 
    elseif transDeposit > 0 then   --需要补银
        if safeboxDeposit > 0  then
            -- 保险箱银两不足
            if safeboxDeposit < transDeposit then
                transDeposit = 0
                my.informPluginByName({pluginName = 'TipPlugin', params = {tipString = "保险箱银子不足，自动取银失败", removeTime = 2}})
                return
            end
        else
            my.informPluginByName({pluginName = 'TipPlugin', params = {tipString = "保险箱银子不足，自动取银失败", removeTime = 2}})
            return
        end

        if(player:isSafeboxHasSecurePwd() and not player:hasSafeboxGotRndKey())then
            my.informPluginByName({pluginName = 'TipPlugin', params = {tipString = "保险箱有密码，请手动取银", removeTime = 2}})
            return
        else
            self.m_takeDepositNum = transDeposit
            self:onTakeDeposit(transDeposit, 0)
        end

    elseif transDeposit < 0 then   --需要存银  不能超过存银线
        if not cc.exports.isAutoSupplySaveSupported() then --没有设置
            return
        end
        transDeposit = 0 - transDeposit
        local depositLimit = tonumber(cc.exports.getAutoSupplyDepositLimit())
        if tonumber(supplyCount) > depositLimit then
            self.m_SaveDepositNum = transDeposit
            self:onSaveDeposit(transDeposit)
        else
            if (gameDeposit - depositLimit) > 0 then
                self.m_SaveDepositNum = gameDeposit - depositLimit
                self:onSaveDeposit(gameDeposit - depositLimit)
            end
        end
    end
        
end

--自动补银

--banner广告 start
function MyGameController:hideBannerAdvert()
    print("MyGameController:hideBannerAdvert")
    
    AdvertModel:hideBannerAdvert()
    self._hasShowBanner = false
end
--banner 广告 end

function MyGameController:autoJumpRoom()
    local carrySilverOver = false
    local safeSilverOver = false

    if cc.exports.isAutoJumpRoomSupported() and self:isNeedDeposit() and not self:isArenaPlayer() and not PUBLIC_INTERFACE.IsStartAsTeam2V2() then
        local userDeposit       = user.nDeposit
        local safeDeposit       = user.nSafeboxDeposit
        local uitleInfoManager  = self:getUtilsInfoManager()
        local curRoomID         = uitleInfoManager:getRoomID()
        local normalRoomMD      = cc.exports.getJumpRoomDSRMDValue()
        local jumpNormalRoomLine= cc.exports.getJumpNormalRoomValue()
        
        if jumpNormalRoomLine and jumpNormalRoomLine[tostring(curRoomID)] and userDeposit then
            if toint(userDeposit) > toint(jumpNormalRoomLine[tostring(curRoomID)]) and toint(userDeposit) < toint(normalRoomMD) then
                carrySilverOver = true
            end
        end

        local nowashRoomMD      = cc.exports.getJumpRoomNWDSRMDValue()
        local jumpNoWashRoomLine= cc.exports.getJumpNoWashRoomValue()
        if jumpNoWashRoomLine and jumpNoWashRoomLine[tostring(curRoomID)] and userDeposit then
            if toint(userDeposit) > toint(jumpNoWashRoomLine[tostring(curRoomID)])  and toint(userDeposit) < toint(nowashRoomMD) then
                carrySilverOver = true
            end
        end

        if cc.exports.isSafeBoxSupported() then
            local jumpNormalRoomSafeLine= cc.exports.getJumpNormalRoomSafeValue()
            if jumpNormalRoomSafeLine and jumpNormalRoomSafeLine[tostring(curRoomID)] and safeDeposit then
                if toint(safeDeposit) > toint(jumpNormalRoomSafeLine[tostring(curRoomID)]) then
                    safeSilverOver = true
                end
            end
    
            local jumpNoWashRoomSafeLine= cc.exports.getJumpNoWashRoomSafeValue()
            if jumpNoWashRoomSafeLine and jumpNoWashRoomSafeLine[tostring(curRoomID)] and safeDeposit then
                if toint(safeDeposit) > toint(jumpNoWashRoomSafeLine[tostring(curRoomID)]) then
                    safeSilverOver = true
                end
            end
        else
            safeSilverOver = true
        end

        if carrySilverOver and safeSilverOver then
            local HallContext = import('src.app.plugins.mainpanel.HallContext'):getInstance()
            local findScope = HallContext.context["roomContext"] and HallContext.context["roomContext"]['areaEntry']
            local fitroom = RoomListModel:findFitRoomByDeposit(user.nDeposit, findScope, user.nSafeboxDeposit)
            if fitroom == nil then
                return false
            end

            cc.exports.jumpHighRoom = true
            cc.exports.fromRoomID = curRoomID
            self._baseGameConnect:gc_LeaveGame()
            local gameStart = self._baseGameScene:getStart()
            if gameStart then
                gameStart:setVisible(false)
            end
            self._baseGameScene:playShangShengAni()
        end
    end

    return false
end

function MyGameController:onStartGame()
    if self:newUserJumpRoom() then return end

    if self:autoJumpRoom() then return end

    MyGameController.super.onStartGame(self, data)
end

function MyGameController:onRandomTable()
    if self:newUserJumpRoom() then return end

    if self:autoJumpRoom() then return end
    
    MyGameController.super.onRandomTable(self, data)
end

function MyGameController:SetExpressionGuided(ExpressionGuided, userid)
    CacheModel:saveInfoToCache("ExpressionGuided"..userid, ExpressionGuided)
end

function MyGameController:GetExpressionGuided()
    local ExpressionGuided = tonumber(CacheModel:getCacheByKey("ExpressionGuided" .. tostring(user.nUserID)))
    if ExpressionGuided and ExpressionGuided > 0 then
        return true
    else
        return false
    end
end

function MyGameController:ShowExpressionGuide()
    local user = mymodel('UserModel'):getInstance()
    local expressionGuidedStatus = self:GetExpressionGuided()
    if not expressionGuidedStatus then
        self._baseGameScene:ShowExpressionGuide()
        self:SetExpressionGuided(1, user.nUserID)
    end
end

function MyGameController:addTimingScore(drawIndex, score)
    local currentScore = 0
    if self._baseGamePlayerInfoManager then
        currentScore = self._baseGamePlayerInfoManager:getPlayerTimingScore(drawIndex)
        if(currentScore==nil)then
            return
        end
        currentScore = currentScore + score
        self:setPlayerTimingScore(drawIndex, currentScore)
    end
end

function MyGameController:setPlayerTimingScore(drawIndex, score)
    if self._baseGamePlayerInfoManager then
        self._baseGamePlayerInfoManager:setPlayerTimingScore(drawIndex, score)
    end

    if self:getMyDrawIndex() == drawIndex then
        if "number" ~= type(score) then return end
        if self._baseGameScene and self._baseGameScene:getSelfTimingScoreText() then
            self._baseGameScene:getSelfTimingScoreText():setString(score)
        end
    else
        local playerManager = self._baseGameScene:getPlayerManager()
        if playerManager then
            playerManager:setTimingScore(drawIndex, score)
        end
    end
end

function MyGameController:onUpdateTimingGame(data)
    if self._baseGameData then
        local tblData= self._baseGameData:getTimingGameTable(data)
        if not tblData then return end
        local playerManager = self._baseGameScene:getMyPlayerManager()
        if playerManager then
            for i = 1, self:getTableChairCount() do
                local player = playerManager:getGamePlayerByIndex(i)
                if player and player._playerUserID == tblData.nUserID
                and i ~= self:getMyDrawIndex() then
                    self:setPlayerTimingScore(i, tblData.nScore)
                end
            end
        end
    end
end

--判断当前是否可以准备
function MyGameController:canRestart()
    local selfInfo = self._baseGameScene:getSelfInfo()
    if not self:isGameRunning() and not selfInfo:isWaitArrangeTableShow() then
        return true
    end
    return false
end

function MyGameController:getRuleString(tableRule)
    -- todo 组装规则文本
    local ruleString = '局数:%s    玩法:%s    属性:%s'
    local playType = ''
    if tableRule.PlayType == 1 then
        playType = '不洗牌'
    elseif tableRule.PlayType == 2 then
        playType = '经典'
    else
        playType = '未知' .. tostring(tableRule.PlayType)
    end

    local boutType = ''
    if tableRule.BoutType  == 1 then
        boutType = '单局'
    elseif tableRule.BoutType == 2 then
        boutType = '过8'
    elseif tableRule.BoutType == 3 then
        boutType = '过A'
    else
        boutType = '未知' .. tostring(tableRule.BoutType)
    end

    local encryption
    if tableRule.EncryptionType == 0 then
        encryption = '未加密'
    elseif tableRule.EncryptionType == 1 then
        encryption = '加密'
    else
        encryption = '未知' .. tostring(tableRule.EncryptionType)
    end

    ruleString = string.format(ruleString, boutType, playType, encryption)
    return ruleString
end

function MyGameController:onGetGameRuleInfo(data)
    local ruleInfo = protobuf.decode('pbAnchorMatch.GetGameRuleInfo', data)
    protobuf.extract(ruleInfo)
    -- 更新规则
    local tableRule = {
        BoutType = ruleInfo.bouttype,
        PlayType = ruleInfo.playtype,
        EncryptionType = ruleInfo.encryption,
        AnchorUserID = ruleInfo.anchoruserid,
    }
    local AnchorTableModel = import('src.app.plugins.AnchorTable.AnchorTableModel'):getInstance()
    AnchorTableModel:setTableRule(tableRule)

    self:setRuleString(tableRule)
end

function MyGameController:setRuleString(tableRule)
    -- 显示规则
    local ruleString = self:getRuleString(tableRule)
    self._baseGameScene:setRuleString(ruleString)
end

function MyGameController:canLeaveAnchorMatchGame()
    if PUBLIC_INTERFACE.IsStartAsAnchorMatchGame() then
        local AnchorTableModel = import('src.app.plugins.AnchorTable.AnchorTableModel'):getInstance()
        local tableRule = AnchorTableModel:getTableRule()
        if tableRule then
            if tableRule.BoutType == 1 then
                return true
            elseif tableRule.BoutType == 2 or tableRule.BoutType == 3 then
                return self._baseGameUtilsInfoManager:isAnchorMatchGameRankOver()
            end
        end
        return true
    end
    return true
end

function MyGameController:onUpdatePlayerData()
    local UserModel = mymodel('UserModel'):getInstance()
    if self._baseGamePlayerInfoManager then
        self._baseGamePlayerInfoManager:setPlayerDeposit(self:getMyDrawIndex(), UserModel.nDeposit)
    end
    if self._baseGameScene then
        local text = self._baseGameScene:getSelfDepositText();
        if text then
            self._baseGameScene:getSelfDepositText():setMoney(UserModel.nDeposit)
        end
    end
    if self._baseGameConnect then
        self._baseGameConnect:TablePlayerForUpdateDeposit(UserModel.nDeposit)
    end
end


function MyGameController:checkNewUserGuide()
    if self._guideStatus == MyGameDef.NEWUSERGUIDE_BOUTONE_START then
        self:playNewUserGuideBoutOneStep1()
    elseif self._guideStatus == MyGameDef.NEWUSERGUIDE_BOUTONE_STEP_1 then
        self:playNewUserGuideBoutOneFinished()
    elseif self._guideStatus == MyGameDef.NEWUSERGUIDE_BOUTTWO_START then
        self:playNewUserGuideBoutTwoStep1()
    elseif self._guideStatus == MyGameDef.NEWUSERGUIDE_BOUTTWO_STEP_1 then
        self:playNewUserGuideBoutTwoStep2()
    elseif self._guideStatus == MyGameDef.NEWUSERGUIDE_BOUTTWO_STEP_2 then
        self:playNewUserGuideBoutTwoFinished()
    end
end

function MyGameController:startNewUserGuideBoutOne()
    self:closePliginOnstartGuide()
    self._guideStatus = MyGameDef.NEWUSERGUIDE_BOUTONE_START
    self:saveNewUserGuideCache(self._guideStatus)
    self._forbidTouchCard = true
    
    local csbPath = "res/GameCocosStudio/csb/Node_NewPlayerGuide.csb"
    local Operate_Panel = self._baseGameScene._gameNode:getChildByName("Operate_Panel")
    if not self._guideLayout then
        self._guideLayout = cc.CSLoader:createNode(csbPath)
        self._guideLayout:setContentSize(cc.Director:getInstance():getVisibleSize())
        ccui.Helper:doLayout(self._guideLayout)
        Operate_Panel:addChild(self._guideLayout)
        self._guideLayout:setLocalZOrder(MyGameDef.NEWUSERGUIDE_BASE_ZORDER)
        local shade = self._guideLayout:getChildByName("Panel_Shade")
        shade:setSwallowTouches(true)
        shade:addClickEventListener(function()
            if self._guideStatus == MyGameDef.NEWUSERGUIDE_BOUTONE_STEP_1 then
                self:checkNewUserGuide()
            end
        end)
    end

    local shade = self._guideLayout:getChildByName("Panel_Shade")
    local btnQuickBomb = Operate_Panel:getChildByName("Btn_QuickBoom")

    if not self._nodeFinger then
        self._nodeFinger = cc.CSLoader:createNode("res/GameCocosStudio/csb/Node_Finger.csb")
        self._nodeFinger:setLocalZOrder(btnQuickBomb:getLocalZOrder() + 105000)
        self._nodeFinger:setPosition(btnQuickBomb:getPositionX() - 140, btnQuickBomb:getPositionY() + 20)
        self._nodeFinger:setRotation(90)
        Operate_Panel:addChild(self._nodeFinger)
        self._nodeFinger:setVisible(false)
    end

    if not self._guideTip then
        local oriText = shade:getChildByName("Panel_Center"):getChildByName("Img_Bubble"):getChildByName("Text_Bubble")
        oriText:setVisible(false)
        self._guideTip = RichText:create()
        self._guideTip:setTextColor(oriText:getTextColor())
        self._guideTip:setFontSize(oriText:getFontSize())
        self._guideTip:setPosition(oriText:getPosition())
        self._guideTip:setAnchorPoint(oriText:getAnchorPoint())
        self._guideTip:setContentSize(oriText:getContentSize())
        shade:getChildByName("Panel_Center"):getChildByName("Img_Bubble"):addChild(self._guideTip)
    end

    self._guideTip:setStringEx("<#915530>首先，点击<#DF1839>【炸弹理牌】<#915530>按钮，理出手上的炸弹")

    local panelCenter = shade:getChildByName("Panel_Center")
    local panelTip = panelCenter:getChildByName("Img_Bubble")
    local posX,posY = panelCenter:getPosition()
    panelCenter:setPosition(posX,posY+300)
    panelTip:setOpacity(0)
    local actMoveTo = cc.MoveTo:create(2, cc.p(posX, posY))
    local rotateBy1 = cc.RotateBy:create(0.5, -20)
    local rotateBy2 = cc.RotateBy:create(1, 40)
    local rotateBy3 = cc.RotateBy:create(0.5, -20)
    local sway = cc.Sequence:create(rotateBy1,rotateBy2,rotateBy3)

    local function callfunc2()
        btnQuickBomb:setLocalZOrder(btnQuickBomb:getLocalZOrder() + MyGameDef.NEWUSERGUIDE_BASE_ZORDER)

        if self._nodeFinger then
            self._nodeFinger:setVisible(true)
            self._nodeFinger:stopAllActions()
            local sequence = cc.Sequence:create(cc.DelayTime:create(0),cc.MoveBy:create(0.2, cc.p(10, 0)),cc.DelayTime:create(0),cc.MoveBy:create(0.2, cc.p(-10, 0)))
            local reAction = cc.Repeat:create(sequence,2)
    
            local finalSequence = cc.Sequence:create(reAction,cc.DelayTime:create(0),cc.CallFunc:create(function()
                self._nodeFinger:stopAllActions()
                local actMoveBy1 = cc.MoveBy:create(0.5, cc.p(20, 0))
                local actMoveBy2 = cc.MoveBy:create(0.5, cc.p(-20, 0))
                local sequenceAction = cc.Sequence:create(actMoveBy1, actMoveBy2)
                --重复
                local repeatForever = cc.RepeatForever:create(sequenceAction)
                self._nodeFinger:runAction(repeatForever)
            end))
            self._nodeFinger:runAction(finalSequence) 
        end
    end

    local function callfunc1()
        panelTip:setScale(0.1)
        panelTip:setOpacity(255)
        local actScaleTo1 = cc.ScaleTo:create(0.3, 2.5)
        local actScaleTo2 = cc.ScaleTo:create(0.1, 1.85)
        local actPop = cc.Sequence:create(actScaleTo1,actScaleTo2)
        panelTip:runAction(cc.Sequence:create(actPop,cc.CallFunc:create(callfunc2)))
    end

    local sequenceAction = cc.Sequence:create(actMoveTo,cc.CallFunc:create(callfunc1))
    panelCenter:runAction(sequenceAction)
    panelCenter:runAction(cc.Repeat:create(sway,1))
    self._baseGameConnect:reqStartGuide(1)
end

function MyGameController:playNewUserGuideBoutOneStep1()
    --文字提示
    if self._guideTip then
        self._guideTip:setStringEx("<#915530>很好，左边几列就是<#4C9221>理出的炸弹<#C51892>(点击任意位置可继续)")
        self:PlayPopAni(self._guideTip:getParent())
    end

    --隐藏手指图片
    if self._nodeFinger then
        self._nodeFinger:setVisible(false)
    end

    local Operate_Panel = self._baseGameScene._gameNode:getChildByName("Operate_Panel")
    local btnQuickBomb = Operate_Panel:getChildByName("Btn_QuickBoom")
    btnQuickBomb:setLocalZOrder(btnQuickBomb:getLocalZOrder() - MyGameDef.NEWUSERGUIDE_BASE_ZORDER)

    if self._guideStatus == MyGameDef.NEWUSERGUIDE_BOUTONE_START then
        self._guideStatus = MyGameDef.NEWUSERGUIDE_BOUTONE_STEP_1
        self:saveNewUserGuideCache(self._guideStatus)
    end
    
    local Panel_Card_Hand = Operate_Panel:getChildByName("cardMountLayer")
    if Panel_Card_Hand then
        Panel_Card_Hand:setLocalZOrder(Panel_Card_Hand:getLocalZOrder()+MyGameDef.NEWUSERGUIDE_BASE_ZORDER)
    end
end

function MyGameController:playNewUserGuideBoutOneFinished()
    self._guideStatus = MyGameDef.NEWUSERGUIDE_BOUTONE_FINISHED
    self:saveNewUserGuideCache(self._guideStatus)
    self:resetNewUserGuide()
    self._baseGameConnect:reqFinishGuide()
end

-- 第二局引导
function MyGameController:startNewUserGuideBoutTwo()
    self:closePliginOnstartGuide()
    self._guideStatus = MyGameDef.NEWUSERGUIDE_BOUTTWO_START
    self:saveNewUserGuideCache(self._guideStatus)
    self._forbidTouchCard = true
    
    local csbPath = "res/GameCocosStudio/csb/Node_NewPlayerGuide.csb"
    local Operate_Panel = self._baseGameScene._gameNode:getChildByName("Operate_Panel")
    if not self._guideLayout then
        self._guideLayout = cc.CSLoader:createNode(csbPath)
        self._guideLayout:setContentSize(cc.Director:getInstance():getVisibleSize())
        ccui.Helper:doLayout(self._guideLayout)
        Operate_Panel:addChild(self._guideLayout)
        self._guideLayout:setLocalZOrder(MyGameDef.NEWUSERGUIDE_BASE_ZORDER)
        local shade = self._guideLayout:getChildByName("Panel_Shade")
        shade:setSwallowTouches(true)
        shade:addClickEventListener(function()
            if self._guideStatus == MyGameDef.NEWUSERGUIDE_BOUTTWO_STEP_2 then
                self:checkNewUserGuide()
            end
        end)
    end

    local shade = self._guideLayout:getChildByName("Panel_Shade")

    if not self._nodeFinger then
        self._nodeFinger = cc.CSLoader:createNode("res/GameCocosStudio/csb/Node_Finger.csb")
        local btnShape = Operate_Panel:getChildByName("Button_Shape1")
        self._nodeFinger:setLocalZOrder(btnShape:getLocalZOrder() + 105000)
        self._nodeFinger:setRotation(180)
        Operate_Panel:addChild(self._nodeFinger)
        self._nodeFinger:setVisible(false)
    end

    if not self._guideTip then
        local oriText = shade:getChildByName("Panel_Center"):getChildByName("Img_Bubble"):getChildByName("Text_Bubble")
        oriText:setVisible(false)
        self._guideTip = RichText:create()
        self._guideTip:setTextColor(oriText:getTextColor())
        self._guideTip:setFontSize(oriText:getFontSize())
        self._guideTip:setPosition(oriText:getPosition())
        self._guideTip:setAnchorPoint(oriText:getAnchorPoint())
        self._guideTip:setContentSize(oriText:getContentSize())
        shade:getChildByName("Panel_Center"):getChildByName("Img_Bubble"):addChild(self._guideTip)
    end

    self._guideTip:setStringEx("<#915530>首先，点击<#DF1839>选出同花顺")

    local panelCenter = shade:getChildByName("Panel_Center")
    local panelTip = panelCenter:getChildByName("Img_Bubble")
    local posX,posY = panelCenter:getPosition()
    panelCenter:setPosition(posX,posY+300)
    panelTip:setOpacity(0)
    local actMoveTo = cc.MoveTo:create(2, cc.p(posX, posY))
    local rotateBy1 = cc.RotateBy:create(0.5, -20)
    local rotateBy2 = cc.RotateBy:create(1, 40)
    local rotateBy3 = cc.RotateBy:create(0.5, -20)
    local sway = cc.Sequence:create(rotateBy1,rotateBy2,rotateBy3)
    local function callfunc2()
        for i = 1,4 do
            local btnShape = Operate_Panel:getChildByName("Button_Shape" .. i)
            if btnShape:isBright() then
                btnShape:setLocalZOrder(btnShape:getLocalZOrder() + MyGameDef.NEWUSERGUIDE_BASE_ZORDER)
                if self._nodeFinger then
                    self._nodeFinger:setPosition(btnShape:getPositionX() + 10, btnShape:getPositionY() + 100)
                    self._nodeFinger:setVisible(true)
                    self._nodeFinger:stopAllActions()
                    local acMoveBy3 = cc.MoveBy:create(0.3, cc.p(0, 20))
                    local acMoveBy4 = cc.MoveBy:create(0.3, cc.p(0, -20))
                    local sequence = cc.Sequence:create(cc.DelayTime:create(0),cc.MoveBy:create(0.2, cc.p(0, 10)),cc.DelayTime:create(0),cc.MoveBy:create(0.2, cc.p(0, -10)))
                    local reAction = cc.Repeat:create(sequence,2)
            
                    local finalSequence = cc.Sequence:create(reAction,cc.DelayTime:create(0),cc.CallFunc:create(function()
                        self._nodeFinger:stopAllActions()
                        local actMoveBy1 = cc.MoveBy:create(0.5, cc.p(0, 20))
                        local actMoveBy2 = cc.MoveBy:create(0.5, cc.p(0, -20))
                        local sequenceAction = cc.Sequence:create(actMoveBy1, actMoveBy2)
                        --重复
                        local repeatForever = cc.RepeatForever:create(sequenceAction)
                        self._nodeFinger:runAction(repeatForever)
                    end))
                    self._nodeFinger:runAction(finalSequence) 
                    break
                end
            end
        end
    end

    local function callfunc1()
        panelTip:setScale(0.1)
        panelTip:setOpacity(255)
        local actScaleTo1 = cc.ScaleTo:create(0.3, 2.5)
        local actScaleTo2 = cc.ScaleTo:create(0.1, 1.85)
        local actPop = cc.Sequence:create(actScaleTo1,actScaleTo2)
        panelTip:runAction(cc.Sequence:create(actPop,cc.CallFunc:create(callfunc2)))
    end

    local sequenceAction = cc.Sequence:create(actMoveTo,cc.CallFunc:create(callfunc1))
    panelCenter:runAction(sequenceAction)
    panelCenter:runAction(cc.Repeat:create(sway,1))

    self._baseGameConnect:reqStartGuide(2)
end

function MyGameController:playNewUserGuideBoutTwoStep1()
    --文字提示
    if self._guideTip then
        self._guideTip:setStringEx("<#915530>很好，暗色牌型代表<#4C9221>选出的同花顺牌型<#C51892>此时，我们需要<#4C9221>点击【理牌】按钮")
        self:PlayPopAni(self._guideTip:getParent())
    end

    --隐藏手指图片
    if self._nodeFinger then
        self._nodeFinger:setVisible(false)
    end

    local node = self._baseGameScene._gameNode:getChildByName("Operate_Panel")
    for i = 1, 4 do
        local btnShape = node:getChildByName("Button_Shape" .. tostring(i))
        if btnShape then
            local zorder = btnShape:getLocalZOrder()
            if zorder > MyGameDef.NEWUSERGUIDE_BASE_ZORDER then
                btnShape:setLocalZOrder(zorder - MyGameDef.NEWUSERGUIDE_BASE_ZORDER)
            end
        end
    end

    --理牌按钮后，播放理牌闪烁动画
    local SKHandCardsManager        = self._baseGameScene:getSKHandCardsManager()
    local myHandCards = SKHandCardsManager:getSKHandCards(self:getMyDrawIndex())

    local function callback()
        if self._guideStatus == MyGameDef.NEWUSERGUIDE_BOUTTWO_START then
            self:playNewUserGuideArrangeThs()
        end
    end
    local bPreNode = {}
    for i = 1,self:getChairCardsCount() do
        if myHandCards._cards[i] and myHandCards._cards[i]:isSelectCard() then
            local sequence = cc.Sequence:create(cc.DelayTime:create(0.12),cc.FadeOut:create(0.3),cc.DelayTime:create(0.12),cc.FadeIn:create(0.3))
            local reAction = cc.Repeat:create(sequence,3)
            myHandCards._cards[i]._SKMask:runAction(cc.Sequence:create(reAction,cc.CallFunc:create(function() 
                callback() 
            end)))
        end
    end

    --调整个手牌区域层级
    local Panel_Card_Hand = node:getChildByName("cardMountLayer")
    if Panel_Card_Hand then
        Panel_Card_Hand:setLocalZOrder(Panel_Card_Hand:getLocalZOrder()+MyGameDef.NEWUSERGUIDE_BASE_ZORDER)
    end
end

function MyGameController:playNewUserGuideArrangeThs()
    self._guideStatus = MyGameDef.NEWUSERGUIDE_BOUTTWO_STEP_1
    self:saveNewUserGuideCache(self._guideStatus)
    local node = self._baseGameScene._gameNode:getChildByName("Operate_Panel")
    local btnArrange = node:getChildByName("Btn_Tird")
    btnArrange:setLocalZOrder(btnArrange:getLocalZOrder() + MyGameDef.NEWUSERGUIDE_BASE_ZORDER)

    if self._nodeFinger then
        self._nodeFinger:setVisible(true)
        self._nodeFinger:setPosition(btnArrange:getPositionX() + 10, btnArrange:getPositionY() + 100)
        local acMoveBy3 = cc.MoveBy:create(0.3, cc.p(0, 20))
        local acMoveBy4 = cc.MoveBy:create(0.3, cc.p(0, -20))
        local sequence = cc.Sequence:create(cc.DelayTime:create(0),cc.MoveBy:create(0.2, cc.p(0, 10)),cc.DelayTime:create(0),cc.MoveBy:create(0.2, cc.p(0, -10)))
        local reAction = cc.Repeat:create(sequence,2)

        local finalSequence = cc.Sequence:create(reAction,cc.DelayTime:create(0),cc.CallFunc:create(function()
            self._nodeFinger:stopAllActions()
            local actMoveBy1 = cc.MoveBy:create(0.5, cc.p(0, 20))
            local actMoveBy2 = cc.MoveBy:create(0.5, cc.p(0, -20))
            local sequenceAction = cc.Sequence:create(actMoveBy1, actMoveBy2)
            --重复
            local repeatForever = cc.RepeatForever:create(sequenceAction)
            self._nodeFinger:runAction(repeatForever)
        end))
        self._nodeFinger:stopAllActions()
        self._nodeFinger:runAction(finalSequence) 
    end
end

function MyGameController:playNewUserGuideBoutTwoStep2()
    --文字提示
    if self._guideTip then
        self._guideTip:setStringEx("<#915530>很好，这一列就是<#DF7618>理出的同花顺<#C51892>(点击任意位置可继续)")
        self:PlayPopAni(self._guideTip:getParent())
    end

    --隐藏手指图片
    if self._nodeFinger then
        self._nodeFinger:setVisible(false)
    end

    local SKHandCardsManager = self._baseGameScene:getSKHandCardsManager()
    local myHandCards = SKHandCardsManager:getSKHandCards(self:getMyDrawIndex())

    local node = self._baseGameScene._gameNode:getChildByName("Operate_Panel")

    --播放动效
    for i = 1,self:getChairCardsCount() do
        if myHandCards._cards[i] and myHandCards._cards[i]._ArrageNo==1 then
            local sequence = cc.Sequence:create(cc.DelayTime:create(0.12),cc.FadeOut:create(0.3),cc.DelayTime:create(0.12),cc.FadeIn:create(0.3))
            local reAction = cc.Repeat:create(sequence,3)
            myHandCards._cards[i]._SKArrageMask1:runAction(cc.Sequence:create(reAction, cc.CallFunc:create(function()
                if self._guideStatus == MyGameDef.NEWUSERGUIDE_BOUTTWO_STEP_1 then
                    self._guideStatus = MyGameDef.NEWUSERGUIDE_BOUTTWO_STEP_2
                    self:saveNewUserGuideCache(self._guideStatus)
                end
            end)))
        end
    end

    --隐藏理牌
    node:getChildByName("Btn_Tird"):setLocalZOrder(node:getChildByName("Btn_Tird"):getLocalZOrder()-MyGameDef.NEWUSERGUIDE_BASE_ZORDER)
end

function MyGameController:playNewUserGuideBoutTwoFinished()
    self._guideStatus = MyGameDef.NEWUSERGUIDE_BOUTTWO_FINISHED
    self:saveNewUserGuideCache(self._guideStatus)
    self:resetNewUserGuide()
    self._baseGameConnect:reqFinishGuide()
end

function MyGameController:checkNewUserGuideOnDXXW()
    local SKHandCardsManager = self._baseGameScene:getSKHandCardsManager()
    if SKHandCardsManager._SKHandCards[self:getMyDrawIndex()] and 
       SKHandCardsManager._SKHandCards[self:getMyDrawIndex()]._cardsCount and 
       SKHandCardsManager._SKHandCards[self:getMyDrawIndex()]._cardsCount > 0 then
        SKHandCardsManager:OnResetArrageHandCard()
    end

    self:resetNewUserGuide()

    local nLeftTime = self._baseGameUtilsInfoManager:getThrowWait() - self._baseGameUtilsInfoManager._utilsStartInfo.nReserved[1]

    if SKHandCardsManager:getSKHandCards(self:getMyDrawIndex()):getHandCardsCount() ~= 27 or nLeftTime < 15 then
        self._guideStatus = MyGameDef.NEWPLAYERGUIDE_FINISHED
        self:saveNewUserGuideCache(self._guideStatus)
        return
    end

    local data = self:getNewUserGuideCache()
    data = checktable(data)
    if not data.guideState then
        self._guideStatus = MyGameDef.NEWUSERGUIDE_NOT_OPEN
    else
        self._guideStatus = data.guideState
    end

    local nGuideUser = self._baseGameUtilsInfoManager._utilsStartInfo.nGuideUser
    local nGuideBout = self._baseGameUtilsInfoManager._utilsStartInfo.nGuideBout
    local UserModel = mymodel('UserModel'):getInstance()
    if nGuideUser == UserModel.nUserID then
        if nGuideBout == 1 and self._guideStatus ~= MyGameDef.NEWUSERGUIDE_BOUTONE_FINISHED then
            self:startNewUserGuideBoutOne()
        elseif nGuideBout == 2 and self._guideStatus ~= MyGameDef.NEWUSERGUIDE_BOUTTWO_FINISHED then
            self:startNewUserGuideBoutTwo()
        end
    end
end

function MyGameController:resetNewUserGuide()
    --恢复手牌可点击
    self._forbidTouchCard = false
    local SKHandCardsManager        = self._baseGameScene:getSKHandCardsManager()
    local myHandCards = SKHandCardsManager:getSKHandCards(self:getMyDrawIndex())
    if SKHandCardsManager._SKHandCards[self:getMyDrawIndex()] and 
       SKHandCardsManager._SKHandCards[self:getMyDrawIndex()]._cardsCount and 
       SKHandCardsManager._SKHandCards[self:getMyDrawIndex()]._cardsCount > 0 then
        myHandCards:setAllCardsEnable(true)
    end

    for i = 1,self:getChairCardsCount() do
        if myHandCards._cards[i] then
            myHandCards._cards[i]._SKMask:stopAllActions()
            myHandCards._cards[i]._SKArrageMask1:stopAllActions()
        end
    end   

    --
    if self._nodeFinger then
        self._nodeFinger:removeFromParent()
        self._nodeFinger  = nil
    end

    if self._guideLayout then
        self._guideLayout:removeFromParent()
        self._guideLayout  = nil
        self._guideTip = nil
    end

    if self._spFinger then
        self._spFinger:stopAllActions()
        self._spFinger:removeFromParent()
        self._spFinger = nil
    end

    local opePanel = self._baseGameScene._gameNode:getChildByName("Operate_Panel")
    local panelCards = opePanel:getChildByName("cardMountLayer")
    local btnArrange = opePanel:getChildByName("Btn_Tird")
    local btnReset = opePanel:getChildByName("Btn_Reset")
    for i = 1,4 do
        local btnShape = opePanel:getChildByName("Button_Shape" .. i)
        local btnZorder = btnShape:getLocalZOrder()
        if btnZorder>=MyGameDef.NEWUSERGUIDE_BASE_ZORDER then
            btnShape:setLocalZOrder(btnShape:getLocalZOrder()-MyGameDef.NEWUSERGUIDE_BASE_ZORDER)
        end
    end
    if panelCards:getLocalZOrder()>=MyGameDef.NEWUSERGUIDE_BASE_ZORDER then
        panelCards:setLocalZOrder(panelCards:getLocalZOrder()-MyGameDef.NEWUSERGUIDE_BASE_ZORDER)
    end
    if btnArrange:getLocalZOrder()>=MyGameDef.NEWUSERGUIDE_BASE_ZORDER then
        btnArrange:setLocalZOrder(btnArrange:getLocalZOrder()-MyGameDef.NEWUSERGUIDE_BASE_ZORDER)
    end
    if btnReset:getLocalZOrder()>=MyGameDef.NEWUSERGUIDE_BASE_ZORDER then
        btnReset:setLocalZOrder(btnReset:getLocalZOrder()-MyGameDef.NEWUSERGUIDE_BASE_ZORDER)
    end
end

function MyGameController:saveNewUserGuideCache(status)
    if status then
        local user = mymodel('UserModel'):getInstance()
        if user.nUserID then
            my.saveCache("MyGameGuide_" .. user.nUserID .. ".xml", {guideState = status})
        end
    end
end

function MyGameController:getNewUserGuideCache()
    local user = mymodel('UserModel'):getInstance()
    if user.nUserID then
        return my.readCache("MyGameGuide_".. user.nUserID ..".xml")
    else
        return {}
    end
end

function MyGameController:newUserJumpRoom()    
    local uitleInfoManager  = self:getUtilsInfoManager()
    local curRoomID         = uitleInfoManager:getRoomID()
    local guideRoom = RoomListModel:getNewUserGuideRoom()
    if curRoomID == guideRoom.nRoomID then
        local fitRoom = RoomListModel:findFitRoomInGame()
        if fitRoom and fitRoom.nRoomID ~= curRoomID then
            local NewInviteGiftModel = require('src.app.plugins.invitegift.NewInviteGiftModel'):getInstance()
            NewInviteGiftModel:reqBindInfo()
            
            -- 邀请有礼相关的icon
            my.scheduleOnce(function()    
                self._baseGameScene:createNewUserRedbag()
            end, 2.0)

            cc.exports.jumpHighRoom = true
            cc.exports.fromRoomID = fitRoom.nRoomID
            self._baseGameConnect:gc_LeaveGame()
            local gameStart = self._baseGameScene:getStart()
            if gameStart then
                gameStart:setVisible(false)
            end
            return true
        end
    end
    return false
end

function MyGameController:isBoutGuide()
    local nGuideUser = self._baseGameUtilsInfoManager._utilsStartInfo.nGuideUser
    local nGuideBout = self._baseGameUtilsInfoManager._utilsStartInfo.nGuideBout
    local UserModel = mymodel('UserModel'):getInstance()
    local nUserID = UserModel.nUserID
    if nUserID and nUserID == nGuideUser and nGuideBout <= cc.exports.getNewUserGuideBoutCount() then
        return true
    end
    return false
end

function MyGameController:checkTeam2V2ReadyState()
    if self:isGameRunning() then
        return
    end

    local tableInfo = self._baseGameUtilsInfoManager:getTableInfo()
    if not tableInfo then
        return
    end

    -- local dwUserStatus = tableInfo.dwUserStatus
    -- if not dwUserStatus then
    --     return
    -- end

    -- local myChairNO = self:getMyChairNO()
    -- local myStatus = dwUserStatus[myChairNO]
    -- if self:IS_BIT_SET(dwUserStatus[myChairNO + 1], BaseGameDef.BASEGAME_US_GAME_STARTED) then
    --     return
    -- end

    -- if Team2V2Model:isSelfMate() or Team2V2Model:getTeamMateCount() == 1 then
        self:onStartGame()
    -- elseif Team2V2Model:isSelfLeader() and Team2V2Model:getTeamMateCount() == 2 then
    --     for i = 1, self:getTableChairCount() do
    --         if i - 1 ~= myChairNO then
    --             if self:IS_BIT_SET(dwUserStatus[i], BaseGameDef.BASEGAME_US_GAME_STARTED) then
    --                 local drawIndex = self:rul_GetDrawIndexByChairNO(i - 1)
    --                 if 0 < drawIndex then
    --                     self:onStartGame()
    --                     break
    --                 end
    --             end
    --         end
    --     end
    -- end
end

function MyGameController:reqUpdateReward(requestId)
    
end

return MyGameController