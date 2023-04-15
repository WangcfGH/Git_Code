
if nil == cc or nil == cc.exports then
    return
end

local BaseGameDef                               = import("src.app.Game.mBaseGame.BaseGameDef")
local SKGameDef                                 = import("src.app.Game.mSKGame.SKGameDef")
local BaseGameController                        = import("src.app.Game.mBaseGame.BaseGameController")

cc.exports.SKGameController                     = {}
local SKGameController                          = cc.exports.SKGameController

local SKGameData                                = import("src.app.Game.mSKGame.SKGameData")
local SKGameUtilsInfoManager                    = import("src.app.Game.mSKGame.SKGameUtilsInfoManager")
local SKGamePlayerManager                       = import("src.app.Game.mSKGame.SKGamePlayerManager")
local SKGamePlayerInfoManager                   = import("src.app.Game.mSKGame.SKGamePlayerInfoManager")
local SKGameConnect                             = import("src.app.Game.mSKGame.SKGameConnect")
local SKGameNotify                              = import("src.app.Game.mSKGame.SKGameNotify")

local SKCalculator                              = import("src.app.Game.mSKGame.SKCalculator")

local GamePublicInterface                       = import("src.app.Game.mMyGame.GamePublicInterface")

local SKGameShare                               = import("src.app.Game.mSKGame.SKGameShare")
local SKGameOverShare                           = import("src.app.Game.mSKGame.SKGameOverShare")

SKGameController.super = BaseGameController
setmetatable(SKGameController, {__index = SKGameController.super})

SKGameController._sendChatTime  = 0
--SKGameController._autoQuitTimer = nil

function SKGameController:IS_BIT_SET(flag, mybit)
    if not flag or not mybit then
        return false
    end
    return (mybit == bit._and(mybit, flag))
end

function SKGameController:createGameData()
    self._baseGameData = SKGameData:create()
end

function SKGameController:createUtilsInfoManager()
    self._baseGameUtilsInfoManager = SKGameUtilsInfoManager:create()
    self:setUtilsInfo()
end

function SKGameController:createPlayerInfoManager()
    self._baseGamePlayerInfoManager = SKGamePlayerInfoManager:create(self)
    self:setSelfInfo()
end

function SKGameController:initManagerAboveBaseGame()
    self:initManagerAboveSKGame()
end

function SKGameController:initManagerAboveSKGame() end

function SKGameController:setConnect()
    self._baseGameConnect = SKGameConnect:create(self)
end

function SKGameController:setNotify()
    self._baseGameNotify = SKGameNotify:create(self)
end

function SKGameController:getSKTotalCards()
    return SKGameDef.SK_TOTAL_CARDS
end

--这里和basegame里面的顺序反过来了 原来那个太反直觉
function SKGameController:rul_GetDrawIndexByChairNO(chairNO)
    if not self:isValidateChairNO(chairNO) then return 0 end

    local index = 0

    local playerInfoManager = self:getPlayerInfoManager()
    if playerInfoManager then
        local selfChairNO = playerInfoManager:getSelfChairNO()
        local tableChairCount = self:getTableChairCount()
        index = self:getMyDrawIndex()

        for i = 1, tableChairCount do
            if selfChairNO == chairNO then
                return index
            else
                index = index + 1
                selfChairNO = (selfChairNO - 1) % tableChairCount
            end
        end
    end

    return index
end

function SKGameController:rul_GetChairNOByDrawIndex(drawIndex)
    local index = 0

    local playerInfoManager = self:getPlayerInfoManager()
    if playerInfoManager then
        local selfChairNO = playerInfoManager:getSelfChairNO()
        local tableChairCount = self:getTableChairCount()
        index = self:getMyDrawIndex()

        for i = 1, tableChairCount do
            if index == drawIndex then
                return selfChairNO
            else
                index = index + 1
                selfChairNO = (selfChairNO - 1) % tableChairCount
            end
        end
    end

    return index
end

function SKGameController:getNextIndex(index)
    if self:getTableChairCount() - 1 == index then
        return self:getTableChairCount()
    else
        return (index + 1) % self:getTableChairCount()
    end
    return 0
end

function SKGameController:getNextChair(chair)
    return self:getNextIndex(chair + 1) - 1
end

function SKGameController:getPreIndex(index)
    if 1 == index then
        return self:getTableChairCount()
    else
        return index - 1
    end
    return 0
end

function SKGameController:getPreChair(chair)
    return self:getPreIndex(chair + 1) - 1
end

function SKGameController:showBanker()
    local drawIndex = self:getBankerDrawIndex()
    local playerManager = self._baseGameScene:getPlayerManager()
    if playerManager and 0 < drawIndex then
        playerManager:showBanker(drawIndex)
    end
end

function SKGameController:clearPlayerBanker()
    local playerManager = self._baseGameScene:getPlayerManager()
    for i = 1, self:getTableChairCount() do
        if playerManager then
            playerManager:clearBanker()
        end
    end
end

function SKGameController:setPlayerFlower(drawIndex, count)
    local playerManager = self._baseGameScene:getPlayerManager()
    if playerManager then
        playerManager:setPlayerFlower(drawIndex, count)
    end
end

function SKGameController:addPlayerFlower(drawIndex, count)
    local playerManager = self._baseGameScene:getPlayerManager()
    if playerManager then
        playerManager:addPlayerFlower(drawIndex, count)
    end
end

function SKGameController:clearPlayerFlower()
    local playerManager = self._baseGameScene:getPlayerManager()
    if playerManager then
        playerManager:clearPlayerFlower()
    end
end

function SKGameController:addPlayerScore(drawIndex, score)
    local currentScore = 0
    if self._baseGamePlayerInfoManager then
        currentScore = self._baseGamePlayerInfoManager:getPlayerScore(drawIndex)
        currentScore = currentScore + score
        self:setPlayerScore(drawIndex, currentScore)
    end
end

function SKGameController:setPlayerScore(drawIndex, score)
    if self._baseGamePlayerInfoManager then
        self._baseGamePlayerInfoManager:setPlayerScore(drawIndex, score)
    end

    if self:getMyDrawIndex() == drawIndex then
        self:syncPlayerScore(score)
    end
end

function SKGameController:syncPlayerScore(score)
    local playerInfo = mymodel("hallext.PlayerModel"):getInstance()
    if playerInfo then
        local dataMap = {
            nScore = score
        }
        playerInfo:mergeUserData(dataMap)
    end
end

function SKGameController:setPlayerCurrentGains(drawIndex, gains)
    local playerManager = self._baseGameScene:getPlayerManager()
    if playerManager then
        playerManager:setPlayerCurrentGains(drawIndex, gains)
    end
end

function SKGameController:addPlayerCurrentGains(drawIndex, gains)
    local playerManager = self._baseGameScene:getPlayerManager()
    if playerManager then
        playerManager:addPlayerCurrentGains(drawIndex, gains)
    end
end

function SKGameController:clearPlayerCurrentGains()
    local playerManager = self._baseGameScene:getPlayerManager()
    if playerManager then
        playerManager:clearPlayerCurrentGains()
    end
end

function SKGameController:getBaseScore()
    local baseScore = 0
    if self._baseGameUtilsInfoManager then
        baseScore = self._baseGameUtilsInfoManager:getBaseScore()
    end
    return baseScore
end

function SKGameController:getBaseDeposit()
    local baseDeposit = 0
    if self._baseGameUtilsInfoManager then
        baseDeposit = self._baseGameUtilsInfoManager:getBaseDeposit()
    end
    return baseDeposit
end

function SKGameController:getBanker()
    local banker = 1
    if self._baseGameUtilsInfoManager then
        banker = self._baseGameUtilsInfoManager:getBanker()
    end
    return banker
end

function SKGameController:getBankerDrawIndex()
    return self:rul_GetDrawIndexByChairNO(self:getBanker())
end

function SKGameController:getGameFlags()
    if GamePublicInterface and GamePublicInterface:getGameFlags() then
        return GamePublicInterface:getGameFlags()
    end

    return 0
end

function SKGameController:ope_GameStart()
    self:hideOperationBtns()
    self:hideGameTools()
    self:ope_DealCard()

    SKGameController.super.ope_GameStart(self)
end

function SKGameController:showOperationBtns()
    local clock = self._baseGameScene:getClock()
    if clock then
        if clock:getDrawIndex() ~= self:getMyDrawIndex() then
            return
        end
    end

    local SKHandCardsManager        = self._baseGameScene:getSKHandCardsManager()
    if not self._baseGameUtilsInfoManager or not SKHandCardsManager then
        return
    end

    local status        = self._baseGameUtilsInfoManager:getStatus()
    local bFirstHand    = SKHandCardsManager:isFirstHand()

    local SKOpeBtnManager = self._baseGameScene:getSKOpeBtnManager()
    if SKOpeBtnManager then
        SKOpeBtnManager:showOperationBtns(status, bFirstHand)
    end

    if self:IS_BIT_SET(status, BaseGameDef.BASEGAME_TS_WAITING_THROW) then
        self:ope_CheckSelect()
    end
end

function SKGameController:hideOperationBtns()
    local SKOpeBtnManager = self._baseGameScene:getSKOpeBtnManager()
    if SKOpeBtnManager then
        SKOpeBtnManager:hideOperationBtns()
    end
end

function SKGameController:hideGameTools()
    local gameTools = self._baseGameScene:getTools()
    if gameTools then
        gameTools:hideTools()
    end
end

function SKGameController:ope_DealCard()
	local SKHandCardsManager = self._baseGameScene:getSKHandCardsManager()
    if SKHandCardsManager then
        SKHandCardsManager:ope_DealCard()
        SKHandCardsManager:setFirstHand(1)
    end
end

function SKGameController:onDealCardOver()
    self:ope_SortCards()
end

function SKGameController:ope_SortCards()
    local SKHandCardsManager = self._baseGameScene:getSKHandCardsManager()
    if SKHandCardsManager then
        SKHandCardsManager:ope_SortCards()
        self:playGamePublicSound("Snd_Sort")
    end
end

function SKGameController:ope_SortSelfHandCards()
    local SKHandCardsManager = self._baseGameScene:getSKHandCardsManager()
    if SKHandCardsManager then
        SKHandCardsManager:ope_SortSelfHandCards()
    end
end

function SKGameController:onSortCardsFinished(bFirstSort)
    if bFirstSort then
        self:ope_StartPlay()
    end
end

function SKGameController:ope_StartPlay()
    local drawIndex = self:getMyDrawIndex()
    local throwWait = 0
    if self._baseGameUtilsInfoManager then
        drawIndex = self:getBankerDrawIndex()
        throwWait = self._baseGameUtilsInfoManager:getThrowWait()

        self._baseGameUtilsInfoManager:setStatus(BaseGameDef.BASEGAME_TS_WAITING_THROW)
    end
    local clock = self._baseGameScene:getClock()
    if clock then
        if 0 < drawIndex then
            clock:moveClockHandTo(drawIndex)
        end
        if throwWait then
            clock:start(throwWait)
        end
    end

    if drawIndex == self:getMyDrawIndex() then
        self:showOperationBtns()
    end

    local SKHandCardsManager = self._baseGameScene:getSKHandCardsManager()
    if SKHandCardsManager then
        SKHandCardsManager:setEnableTouch(true)
    end

    self:ope_ShowGameInfo(true)
    self:showBanker(drawIndex)
end

function SKGameController:onGameExit()
    local SKHandCardsManager = self._baseGameScene:getSKHandCardsManager()
    if SKHandCardsManager then
        SKHandCardsManager:onGameExit()
    end

    local SKGameInfo = self._baseGameScene:getGameInfo()
    if SKGameInfo then
        SKGameInfo:onGameExit()
    end

    self:disconnect()

    self:stopResponseTimer()
    self:stopGamePluse()

    AppUtils:getInstance():removePauseCallback("Game_BaseGameController_setBackgroundCallback")
    AppUtils:getInstance():removeResumeCallback("Game_BaseGameController_setForegroundCallback")

    local clock = self._baseGameScene:getClock()
    if clock then
        clock:onGameExit()
    end

    local sysInfoNode = self._baseGameScene:getSysInfoNode()
    if sysInfoNode then
        sysInfoNode:onGameExit()
    end

    local gameStart = self._baseGameScene:getStart()
    if gameStart then
        gameStart:onGameExit()
    end

    local gameTools = self._baseGameScene:getTools()
    if gameTools then
        gameTools:onGameExit()
    end

    local playerManager = self._baseGameScene:getPlayerManager()
    if playerManager then
        playerManager:onGameExit()
    end

    local playerManager = self._baseGameScene:getPlayerManager()
    if playerManager then
        playerManager:onGameExit()
    end

    local loadingNode = self._baseGameScene:getLoadingNode()
    if loadingNode then
        loadingNode:onGameExit()
    end

    local selfInfo = self._baseGameScene:getSelfInfo()
    if selfInfo then
        selfInfo:onGameExit()
    end

    local arenaInfo = self._baseGameScene:getArenaInfo()
    if arenaInfo then
        arenaInfo:onGameExit()
    end

    self:stopBGM()

    self:resetController()

    self:stopAutoQuitTimer()

    self._baseGameScene = nil
end

function SKGameController:onClockStop()
    if self._baseGameConnect then
        self._baseGameConnect:sendMsgToServer(SKGameDef.SK_SYSMSG_GAME_CLOCK_STOP)
    end
end

function SKGameController:onNoBiggerPass()
    local selfInfo = self._baseGameScene:getSelfInfo()
    if selfInfo then
        selfInfo:showNoBigger(true)
    end
end

function SKGameController:onAutoPlay(bnAuto)
    self._bAutoPlay = bnAuto

    local playerManager = self._baseGameScene:getPlayerManager()
    if playerManager then
        playerManager:showRobot(self._bAutoPlay, self:getMyDrawIndex())
    end

    local selfInfo = self._baseGameScene:getSelfInfo()
    if selfInfo then
        selfInfo:showCancelAuto(self._bAutoPlay)
    end

    local SKHandCardsManager        = self._baseGameScene:getSKHandCardsManager()
    if SKHandCardsManager then
        SKHandCardsManager:ope_maskSelfCards(bnAuto)
    end
end

function SKGameController:onGameClockZero()
    local SKHandCardsManager        = self._baseGameScene:getSKHandCardsManager()
    if not self._baseGameUtilsInfoManager or not SKHandCardsManager then
        return
    end

    if self:isClockPointToSelf() then
        local status = self._baseGameUtilsInfoManager:getStatus()
        if self:IS_BIT_SET(status, BaseGameDef.BASEGAME_TS_WAITING_THROW) then
            if SKHandCardsManager:isFirstHand() then
                self:onHint()
                if self:ope_CheckSelect() then
                    self:onThrow()
                else
                    self:onThrowCard(self:getAutoThrowCardIDs())
                end
            else
                self:onPassCard()
            end
        end

        self:onAutoPlay(true)
    end
end

function SKGameController:isClockPointToSelf()
    local bClockPointToSelf = false

    local clock = self._baseGameScene:getClock()
    if clock then
        bClockPointToSelf = (clock:getDrawIndex() == self:getMyDrawIndex())
    end

    return bClockPointToSelf
end

function SKGameController:getTableChairCount()
    return SKGameDef.SK_TOTAL_PLAYERS
end

function SKGameController:getChairCardsCount()
    return SKGameDef.SK_CHAIR_CARDS
end

function SKGameController:getScoreCardsCount()
    return SKGameDef.SK_MAX_SCORE_CARD
end

function SKGameController:getTopCardsCount()
    return SKGameDef.SK_TOP_CARD
end

function SKGameController:getBottomCardsCount()
    return SKGameDef.SK_BOTTOM_CARD
end

function SKGameController:getAutoThrowCardIDs()
    local autoThrowCardIDs = {}
    local SKHandCardsManager = self._baseGameScene:getSKHandCardsManager()
    if SKHandCardsManager then
        local myHandCards = SKHandCardsManager:getSKHandCards(self:getMyDrawIndex())
        if myHandCards then
            local card = myHandCards:getSKCardHand(1)
            if card then
                autoThrowCardIDs[1] = card:getSKID()
            end
        end
    end
    return autoThrowCardIDs, 1
end

function SKGameController:onThrow()
    local SKHandCardsManager        = self._baseGameScene:getSKHandCardsManager()
    if not SKHandCardsManager then return end

    self:onThrowCard(SKHandCardsManager:getMySelectCardIDs())
end

function SKGameController:onThrowCard(cardIDs, cardsLen)
    if not cardIDs or not cardsLen or 0 == cardsLen then return end

    local SKHandCardsManager        = self._baseGameScene:getSKHandCardsManager()
    if not self._baseGameUtilsInfoManager or not SKHandCardsManager or not self._baseGameConnect then
        return
    end

    self:hideOperationBtns()

    if GamePublicInterface and GamePublicInterface:IS_FRAME_1() then
        local cardsDetails = {}
        self._baseGameConnect:reqThrowCards_1(cardIDs, cardsLen, SKCalculator:isValidCardsEx(cardsLen, cardIDs, cardsDetails))
    else
        local unitDetails = SKCalculator:initCardUnite()
        if not SKCalculator:getUniteDetails(cardIDs, cardsLen, unitDetails, SKGameDef.SK_CARD_UNITE_TYPE_TOTAL) then
            return
        end
        if SKHandCardsManager:isFirstHand() then
            SKCalculator:getBestUnitType1(unitDetails)
        else
            SKCalculator:getBestUnitType2(self._baseGameUtilsInfoManager:getWaitUniteInfo(), unitDetails)
        end

        self._baseGameConnect:reqThrowCards(unitDetails.uniteType[1])
    end
end

function SKGameController:onPassCard()
    if not self._baseGameConnect then
        return
    end

    local SKHandCardsManager = self._baseGameScene:getSKHandCardsManager()
    if SKHandCardsManager then
        SKHandCardsManager:ope_UnselectSelfCards()
    end

    self:hideOperationBtns()

    self._baseGameConnect:reqPassCards()
end

function SKGameController:onHint()
    local SKHandCardsManager        = self._baseGameScene:getSKHandCardsManager()
    if not SKHandCardsManager then return end

    SKHandCardsManager:onHint()
end

function SKGameController:isSameGroup(chairNO)
    --TODO
    return false
end

function SKGameController:clearGameTable()
    local handCardsManager = self._baseGameScene:getSKHandCardsManager()
    if handCardsManager then
        handCardsManager:resetHandCardsManager()
    end

    local thrownCardsManager = self._baseGameScene:getSKThrownCardsManager()
    if thrownCardsManager then
        thrownCardsManager:resetThrownCardsManager()
    end

    local playerManager = self._baseGameScene:getPlayerManager()
    if playerManager then
        playerManager:resetPlayerManager()
    end

--    self:clearPlayerCurrentGains()
--    self:clearPlayerFlower()
--    self:clearPlayerBanker()
    self:hideOperationBtns()

    self:ope_ShowGameInfo(false)

    SKGameController.super.clearGameTable(self)
end

function SKGameController:onGameStartSolo(data)
    self:onGameStart(data)
end

function SKGameController:onEnterGameDXXW(data)
    self:parseGameTableInfoData(data)

    SKGameController.super.onEnterGameDXXW(self, data)
end

function SKGameController:isTouchEnable()
    local chat = self._baseGameScene:getChat()
    if chat and chat:isVisible() then
        return false
    end

    local setting = self._baseGameScene:getSetting()
    if setting and setting:isVisible() then
        return false
    end

    local task = self._baseGameScene:getGameTask()
    if task and task:isVisible() then
        return false
    end

    local share = self._baseGameScene:getGameShare()
    if share and share:isVisible() then
        return false
    end

    local rule = self._baseGameScene:getGameRule()
    if rule and rule:isVisible() then
        return false
    end

    return true
end

function SKGameController:onTouchBegan(x, y)
    local SKGameTools = self._baseGameScene:getTools()
    if SKGameTools then
        if SKGameTools:containsTouchLocation(x, y) then
            return
        else
            self:onCancelRobot()
        end
    end

    local SKOpeBtnManager = self._baseGameScene:getSKOpeBtnManager()
    if SKOpeBtnManager then
        if SKOpeBtnManager:containsTouchLocation(x, y) then
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
        if not SKHandCardsManager:containsTouchLocation(x, y) then
            SKHandCardsManager:ope_UnselectSelfCards()
        else
            SKHandCardsManager:touchBegan(x, y)
        end
    end
end

function SKGameController:onTouchMoved(x, y)
    local SKHandCardsManager = self._baseGameScene:getSKHandCardsManager()
    if SKHandCardsManager then
        if SKHandCardsManager:containsTouchLocation(x, y) then
            SKHandCardsManager:touchMove(x, y)
        end
    end
end

function SKGameController:onTouchEnded(x, y)
    if self:isAutoPlay() then
        return
    end

    local SKHandCardsManager = self._baseGameScene:getSKHandCardsManager()
    if SKHandCardsManager then
        SKHandCardsManager:touchEnd(x, y)
    end
end

function SKGameController:onGetTableInfo(data)
    self:parseGameTableInfoData(data)

    self:setResume(false)
    --self:onDXXW()
end

function SKGameController:parseGameTableInfoData(data)
    local startInfo = nil
    local publicInfo = nil
    local playInfo = nil
    local tableInfo = nil
    local soloPlayers = nil
    if self._baseGameData then
        startInfo, publicInfo, playInfo, tableInfo, soloPlayers = self._baseGameData:getTableInfo(data)
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
    end
    if startInfo then
        self._baseGameUtilsInfoManager:setStartInfo(startInfo)
        if tableInfo then
            self._baseGameUtilsInfoManager:setStartInfoFromTableInfo(tableInfo)
        end
    end
    if playInfo then
        self._baseGameUtilsInfoManager:setPlayInfo(playInfo)
    end
end

function SKGameController:onDXXW()
    if self._baseGameConnect then
        self._baseGameConnect:sendMsgToServer(SKGameDef.SK_SYSMSG_PLAYER_ONLINE)
    end

    self:onCancelRobot()

    if not self._baseGameUtilsInfoManager then
        return
    end

    local status = self._baseGameUtilsInfoManager:getStatus()
    if not status or 0 == status then
        self:gameStop()
        self:clearGameTable()
    else
        if self:IS_BIT_SET(status, BaseGameDef.BASEGAME_TS_PLAYING_GAME) then
            self:gameRun()
        end

        local gameTools = self._baseGameScene:getTools()
        if gameTools then
            gameTools:onGameStart()
        end

        local gameInfo = self._baseGameScene:getGameInfo()
        if gameInfo then
            gameInfo:setBaseScore(tostring(self:getBaseScore()))
        end

        if self:isGameRunning() and self._baseGameUtilsInfoManager then
            local waitChair = self._baseGameUtilsInfoManager:getWaitChair()

            local SKHandCardsManager = self._baseGameScene:getSKHandCardsManager()
            if SKHandCardsManager then
                SKHandCardsManager:resetHandCardsManager()

                local cardsCounts = self._baseGameUtilsInfoManager:getCardsCount()

                for i = 1, self:getTableChairCount() do
                    local drawIndex = self:rul_GetDrawIndexByChairNO(i - 1)
                    if 0 < drawIndex then
                        SKHandCardsManager:setHandCardsCount(drawIndex, cardsCounts[i])
                        local chairCards = self._baseGameUtilsInfoManager:getChairCards(i)
                        SKHandCardsManager:setHandCards(drawIndex, chairCards)
                        SKHandCardsManager:updateHandCards(drawIndex)
                        SKHandCardsManager:sortHandCards(drawIndex)

                        self:setCardsCount(drawIndex, cardsCounts, false)
                    end
                end

                SKHandCardsManager:setEnableTouch(true)
                if waitChair == -1 then
                    SKHandCardsManager:setFirstHand(1)
                else
                    SKHandCardsManager:setFirstHand(0)
                end
            end

            local SKThownCardsManager = self._baseGameScene:getSKThrownCardsManager()
            if SKThownCardsManager then
                local drawIndex = self:rul_GetDrawIndexByChairNO(waitChair)
                local cardsThrow = self._baseGameUtilsInfoManager:getWaitUniteInfo()
                SKThownCardsManager:ope_ThrowCards(drawIndex, cardsThrow.nCardIDs, cardsThrow.nCardsCount)
            end

            local clock = self._baseGameScene:getClock()
            local currentIndex = self:rul_GetDrawIndexByChairNO(self._baseGameUtilsInfoManager:getCurrentChair())
            if clock and 0 < currentIndex then
                local throwWait = self._baseGameUtilsInfoManager:getThrowWait()
                clock:start(throwWait)
                clock:moveClockHandTo(currentIndex)
            end

            if currentIndex == self:getMyDrawIndex() then
                self:showOperationBtns()
            end

            self:ope_ShowGameInfo(true)
        end
    end

    SKGameController.super.onDXXW(self)
end

function SKGameController:onGameStart(data)
    self:gameRun()
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
                    end
                end
            end
        end
    end

    if gameStart then
        self:ope_GameStart()
    end
end

function SKGameController:isCardsThrowResponse(data)
    local bCardsThrowResponse = false

    local cardsThrow = nil
    if self._baseGameData then
        cardsThrow = self._baseGameData:getCardsThrowInfo(data)
    end

    if cardsThrow then
        local playerInfoManager = self:getPlayerInfoManager()
        if playerInfoManager then
            bCardsThrowResponse = (playerInfoManager:getSelfChairNO() == cardsThrow.nChairNO)
        end
    end

    return bCardsThrowResponse
end

function SKGameController:isCardsPassResponse(data)
    local bCardCaughtResponse = false

    local cardsPass = nil
    if self._baseGameData then
        cardsPass = self._baseGameData:getCardsPassInfo(data)
    end

    if cardsPass then
        local playerInfoManager = self:getPlayerInfoManager()
        if playerInfoManager then
            bCardCaughtResponse = (playerInfoManager:getSelfChairNO() == cardsPass.nChairNO)
        end
    end

    return bCardCaughtResponse
end

function SKGameController:ope_showThrowAnimation(cardsThrow)
    if not cardsThrow then return end

    local drawIndex     = self:rul_GetDrawIndexByChairNO(cardsThrow.nChairNO)
    local cardsCount    = cardsThrow.nCardsCount
    local dwType        = cardsThrow.dwCardType
    if GamePublicInterface and GamePublicInterface:IS_FRAME_1() then
        dwType          = cardsThrow.dwCardsType
    end

    self:playThrowAnimation(drawIndex, dwType, cardsCount)
end

function SKGameController:playThrowAnimation(drawIndex, dwType, cardsCount)
    self._baseGameScene:getThrowAnimation(dwType, cardsCount, drawIndex)
    --[[if dwType == SKGameDef.SK_CARD_UNITE_TYPE_ABT_SINGLE then
        self:playBonesArmature("res/GameCocosStudio/guandan.ExportJson", "guandan", 0)
        return
    end
    if dwType == SKGameDef.SK_CARD_UNITE_TYPE_ABT_THREE then
        self:playBonesArmature("res/GameCocosStudio/guandan.ExportJson", "guandan", 1)
        return
    end

    local animation, csbPath    = self._baseGameScene:getThrowAnimation(dwType, cardsCount)
    local position              = self:getThrowAnimationPosition(drawIndex, dwType)

    if animation and csbPath then
        animation:setPosition(position)

        local action = cc.CSLoader:createTimeline(csbPath)
        if action then
            animation:runAction(action)
            action:gotoFrameAndPlay(0, 120, false)
        end
    end--]]
end

function SKGameController:getThrowAnimationPosition(drawIndex)
    local aa = display.center
    if dwType == SKGameDef.SK_CARD_UNITE_TYPE_4KING or dwType == SKGameDef.SK_CARD_UNITE_TYPE_SUPER_BOMB then
        return display.center
    end

    --local SKHandCardsManager = self._baseGameScene:getSKHandCardsManager()
    --return cc.p(SKHandCardsManager:getStartPoint(drawIndex))
    local node = self._baseGameScene._gameNode
    if node then
        local player = node:getChildByName("Panel_Player"..tostring(drawIndex))
        if player then
            local skip = player:getChildByName("Node_Skip")
            if skip then
                return skip:getParent():convertToWorldSpace(cc.p(skip:getPosition()))
            end
        end
    end

    return cc.p(0, 0)
end

function SKGameController:ope_ThrowCards(cardsThrow)     --这里要同时适应1.0和2.0的结构
    if not cardsThrow then return end

    local SKHandCardsManager        = self._baseGameScene:getSKHandCardsManager()
    local SKThownCardsManager       = self._baseGameScene:getSKThrownCardsManager()
    if not self._baseGameUtilsInfoManager or not SKHandCardsManager or not SKThownCardsManager then
        return
    end

    self._baseGameUtilsInfoManager:setWaitUniteInfo(cardsThrow)
    self._baseGameUtilsInfoManager:setWaitChair(cardsThrow.nChairNO)

    self:playCardsEffect(cardsThrow)
    self:ope_showThrowAnimation(cardsThrow)

    local drawIndex = self:rul_GetDrawIndexByChairNO(cardsThrow.nChairNO)
    SKHandCardsManager:ope_ThrowCards(drawIndex, cardsThrow.nCardIDs, cardsThrow.nCardsCount)
    SKHandCardsManager:sortHandCards(drawIndex)
    SKHandCardsManager:setFirstHand(0)
    if drawIndex ~= self:getMyDrawIndex() then
        SKHandCardsManager:moveHandCards(drawIndex, false)
    end

    SKThownCardsManager:ope_ThrowCards(drawIndex, cardsThrow.nCardIDs, cardsThrow.nCardsCount)

    local nextIndex = self:rul_GetDrawIndexByChairNO(cardsThrow.nNextChair)
    SKThownCardsManager:moveThrow(nextIndex)

    local clock = self._baseGameScene:getClock()
    local throwWait =  self._baseGameUtilsInfoManager:getThrowWait()
    if clock then
        clock:start(throwWait)
        clock:moveClockHandTo(nextIndex)
    end

    if nextIndex == self:getMyDrawIndex() and self:isGameRunning() then
        self:showOperationBtns()
		local cardIDs, cardsCount = SKHandCardsManager:getHandCardIDs(nextIndex)
         if drawIndex ~= self:getMyDrawIndex() and cardsCount < 3 and cardsCount < cardsThrow.nCardsCount then
            self:onPassCard()
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
end

function SKGameController:addCurrentScore(score)
    if self._baseGameUtilsInfoManager then
        self._baseGameUtilsInfoManager:addCurrentScore(score)
    end

    --TODO self._baseGameScene:addCurrentScore(score)
end

function SKGameController:getScoresGain(cardIDs, cardsCount) --自行计算或者接收服务器通知
    return 0
end

function SKGameController:getFlowersGain(cardIDs, cardsCount)
    return 0
end

function SKGameController:playCardsEffect(cardsThrow)
    self:playGamePublicSound("Snd_Throw")
end

function SKGameController:playPassEffect(cardsPass)
    self:playGamePublicSound("Snd_Pass")
end

function SKGameController:onCardsThrow(data)
    local cardsThrow = nil
    if self._baseGameData then
        cardsThrow = self._baseGameData:getCardsThrowInfo(data)
    end

    self:ope_ThrowCards(cardsThrow)
end

function SKGameController:rspThrowCards(data)
    local cardsThrow = nil
    if self._baseGameUtilsInfoManager then
        cardsThrow = self._baseGameUtilsInfoManager:getThrowInfo()
    end

    local throwOK = nil
    if self._baseGameData then
        throwOK = self._baseGameData:getThrowOKInfo(data)
        if cardsThrow then
            cardsThrow.nNextChair = throwOK.nNextChair  --插入的字段 和2.0结构一样
        end
    end

    self:ope_ThrowCards(cardsThrow)
end

function SKGameController:ope_PassCards(cardsPass)
    if not cardsPass then return end

    local SKHandCardsManager        = self._baseGameScene:getSKHandCardsManager()
    local SKThownCardsManager       = self._baseGameScene:getSKThrownCardsManager()
    if not self._baseGameUtilsInfoManager or not SKHandCardsManager or not SKThownCardsManager then
        return
    end

    self:playPassEffect(cardsPass)

    local drawIndex = self:rul_GetDrawIndexByChairNO(cardsPass.nChairNO)

    SKHandCardsManager:setFirstHand(cardsPass.bNextFirst)
    SKHandCardsManager:moveHandCards(drawIndex, false)

    local nextIndex = self:rul_GetDrawIndexByChairNO(cardsPass.nNextChair)
    if 1 == cardsPass.bNextFirst then
        SKThownCardsManager:moveAllThrow()
        self._baseGameUtilsInfoManager:setWaitChair(-1)
    else
        SKThownCardsManager:moveThrow(nextIndex)
    end

    SKThownCardsManager:showPassTip(drawIndex)

    local clock = self._baseGameScene:getClock()
    local throwWait =  self._baseGameUtilsInfoManager:getThrowWait()
    if clock then
        clock:start(throwWait)
        clock:moveClockHandTo(nextIndex)
    end

    if nextIndex == self:getMyDrawIndex() then
        self:showOperationBtns()
		local cardIDs, cardsCount = SKHandCardsManager:getHandCardIDs(nextIndex)
        local cardsWaiting = self._baseGameUtilsInfoManager:getWaitUniteInfo()
		local throwIndex = self:rul_GetDrawIndexByChairNO(cardsWaiting.nChairNO)
		if throwIndex ~= self:getMyDrawIndex() and cardsCount < 3 and cardsCount < cardsWaiting.nCardsCount then
            self:onPassCard()
        end
    else
        self:hideOperationBtns()
    end
end

function SKGameController:onCardsPass(data)
    local cardsPass = nil
    if self._baseGameData then
        cardsPass = self._baseGameData:getCardsPassInfo(data)
    end

    self:ope_PassCards(cardsPass)
end

function SKGameController:rspPassCards(data)
    local cardsPass = nil
    if self._baseGameData then
        cardsPass = self._baseGameUtilsInfoManager:getPassInfo()
    end

    local passOK = nil
    if self._baseGameData then
        passOK = self._baseGameData:getPassOKInfo(data)
        if passOK then
            cardsPass.nNextChair = passOK.nNextChair
            cardsPass.bNextFirst = passOK.bNextFirst
        end
    end

    self:ope_PassCards(cardsPass)
end

function SKGameController:onBankerAuction(data)
    local bankerAuction = nil
    if self._baseGameData then
        bankerAuction = self._baseGameData:getBankerAuctionInfo(data)
    end

    self:ope_BankerAuction(bankerAuction)
end

function SKGameController:ope_BankerAuction(bankerAuction)
    --TODO
end

function SKGameController:onAuctionFinished(data)
    local auctionFinished = nil
    if self._baseGameData then
        auctionFinished = self._baseGameData:getAuctionFinishedInfo(data)
    end

    self:ope_AuctionFinished(auctionFinished)
end

function SKGameController:ope_AuctionFinished(auctionFinished)
    --TODO
end

function SKGameController:onInvalidThrow(data)
    --TODO
end

function SKGameController:onCardsInfo(data)
    local cardsInfo = nil
    if self._baseGameData then
        cardsInfo = self._baseGameData:getCardsInfo(data)
    end

    if not cardsInfo or 0 == cardsInfo.nCardsCount then return end

    local SKHandCardsManager = self._baseGameScene:getSKHandCardsManager()
    if not SKHandCardsManager then return end

    local drawIndex = self:rul_GetDrawIndexByChairNO(cardsInfo.nChairNO)
    if drawIndex ~= self:getMyDrawIndex() then
        SKHandCardsManager:setHandCardsCount(drawIndex, cardsInfo.nCardsCount)
        SKHandCardsManager:setHandCards(drawIndex, cardsInfo.nCardIDs)
        SKHandCardsManager:sortHandCards(drawIndex)
    end
end

function SKGameController:onThrowAgain(data)
    --TODO
end

function SKGameController:onGainsBonus(data)
    local gainsInfo = nil
    if self._baseGameData then
        gainsInfo = self._baseGameData:getGainsInfo(data)
    end

    --TODO
end

function SKGameController:onGameWin(data)
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
    end

    local safeBox = self._baseGameScene:getSafeBox()
    if safeBox then
        safeBox:showSafeBox(false)
    end

    local chat = self._baseGameScene:getChat()
    if chat and chat:isVisible() then
        chat:showChat(false)
    end

    local setting = self._baseGameScene:getSetting()
    if setting and setting:isVisible() then
        setting:showSetting(false)
    end

    self:onCancelRobot()

    local gameWin = nil
    if self._baseGameData then
        gameWin = self._baseGameData:getGameWinInfo(data)
    end
    if gameWin then
		local SKHandCardsManager = self._baseGameScene:getSKHandCardsManager()
		if not SKHandCardsManager then return end

		for i = 1, self:getTableChairCount() do
			local score = gameWin.nScoreDiffs[i]
			local drawIndex = self:rul_GetDrawIndexByChairNO(i - 1)
			if 0 < drawIndex then
				self:addPlayerScore(drawIndex, score)
				self:addPlayerBoutInfo(drawIndex, score)
			end

		    if self:getMyDrawIndex() == drawIndex then
                self:hideOperationBtns()
            end

			local cardsCount = 0
			while gameWin.nChairCards[i][cardsCount+1] ~= -1 do
				cardsCount = cardsCount + 1
			end
			if 0 < drawIndex and 0 < cardsCount and drawIndex ~= self:getMyDrawIndex() then
				SKHandCardsManager:setHandCardsCount(drawIndex, cardsCount)
				SKHandCardsManager:setHandCardsWin(drawIndex, gameWin.nChairCards[i])
				SKHandCardsManager:sortHandCards(drawIndex)
			end
		end

		my.scheduleOnce(function()
            if self:isInGameScene() == false then return end
			self:showGameResultInfo(gameWin)
		end, 3)

		local playerInfoManager = self:getPlayerInfoManager()

		local selfInfo = {}
		selfInfo.nUserID = playerInfoManager:getSelfUserID()
		selfInfo.nChairNO = playerInfoManager:getSelfChairNO()
    end
end

function SKGameController:showGameResultInfo(gameWin)
    if self._baseGameScene then 
        self._baseGameScene:showResultLayer(gameWin)
    end
end

function SKGameController:hideGameResultInfo()
    self._baseGameScene:closeResultLayer()
end

function SKGameController:onCloseResultLayer()
    self:hideGameResultInfo()
    self:ope_ShowStart(true)
    self:clearGameTable()

    local playerManager = self._baseGameScene:getPlayerManager()
    if playerManager then
        playerManager:onRestart()
    end
end

function SKGameController:onRestart()
    self:onCloseResultLayer()
    self:onStartGame()
    self:clearGameTable()
end

function SKGameController:startAutoQuitTimer()
    self:stopAutoQuitTimer()

    local function onAutoQuit()
        self:onAutoQuit()
    end
    self._autoQuitTimer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(onAutoQuit, SKGameDef.SK_AUTO_QUIT_INTERVAL, false)
    CacheModel:saveInfoToCache("AutoQuitTimerID", self._autoQuitTimer)

    print("Enter startAutoQuitTimer self._autoQuitTimer="..tostring(self._autoQuitTimer))
end

function SKGameController:onAutoQuit()
    print("onAutoQuit")
    self:stopAutoQuitTimer()

    if not self:isGameRunning() then
        self:onQuit()
    end
end

function SKGameController:stopAutoQuitTimer()
    --print(debug.traceback("stopAutoQuitTimer"))
    if self._autoQuitTimer then
        print("Enter stopAutoQuitTimer self._autoQuitTimer="..tostring(self._autoQuitTimer))
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._autoQuitTimer)
        self._autoQuitTimer = nil
    else
        print("Enter stopAutoQuitTimer self._autoQuitTimer is nil")
        local autoQuitTimerId = tonumber(CacheModel:getCacheByKey("AutoQuitTimerID"))
        if autoQuitTimerId and autoQuitTimerId > 0 then
            print("Enter stopAutoQuitTimer autoQuitTimerId="..tostring(autoQuitTimerId))
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(autoQuitTimerId)
        end
    end

    CacheModel:saveInfoToCache("AutoQuitTimerID", 0)
end

function SKGameController:onStartGame()
    self:stopAutoQuitTimer()

    SKGameController.super.onStartGame(self)
end

function SKGameController:getPlayerNickSexByUserID(userID)
    local nickSex = 0
    local playerInfoManager = self:getPlayerInfoManager()
    if playerInfoManager then
        nickSex = playerInfoManager:getPlayerNickSexByUserID(userID)
    end
    return nickSex
end

function SKGameController:getPlayerNickSexByIndex(drawIndex)
    local nickSex = 0
    local playerInfoManager = self:getPlayerInfoManager()
    if playerInfoManager then
        nickSex = playerInfoManager:getPlayerNickSexByIndex(drawIndex)
    end
    return nickSex
end

function SKGameController:playDealCardEffect()
    self:playGamePublicSound("Special_Dispatch.mp3")
end

function SKGameController:setCardsCount(drawIndex, cardsCount, bSound)
    local playerManager = self._baseGameScene:getPlayerManager()
    if playerManager then
        playerManager:setCardsCount(drawIndex, cardsCount, bSound)
    end
end

function SKGameController:getScoreLevel(score)
    local nlevel = 0
    if score >= 433200 then
        nlevel = 20
    elseif score >= 343200 then
        nlevel = 19
    elseif score >= 258200 then
        nlevel = 18
    elseif score >= 178200 then
        nlevel = 17
    elseif score >= 103200 then
        nlevel = 16
    elseif score >= 68200 then
        nlevel = 15
    elseif score >= 51950 then
        nlevel = 14
    elseif score >= 36950 then
        nlevel = 13
    elseif score >= 23200 then
        nlevel = 12
    elseif score >= 10700 then
        nlevel = 11
    elseif score >= 6200 then
        nlevel = 10
    elseif score >= 4600 then
        nlevel = 9
    elseif score >= 3200 then
        nlevel = 8
    elseif score >= 2000 then
        nlevel = 7
    elseif score >= 1000 then
        nlevel = 6
    elseif score >= 500 then
        nlevel = 5
    elseif score >= 300 then
        nlevel = 4
    elseif score >= 150 then
        nlevel = 3
    elseif score >= 50 then
        nlevel = 2
    elseif score >= 0 then
        nlevel = 1
    end

    return self:getGameStringByKey("G_POINT_LEVEL_" .. tostring(nlevel))
end

function SKGameController:ope_CheckSelect()
    local status        = self._baseGameUtilsInfoManager:getStatus()
    if not self:IS_BIT_SET(status, BaseGameDef.BASEGAME_TS_WAITING_THROW) then return false end

    local SKHandCardsManager        = self._baseGameScene:getSKHandCardsManager()
    local SKOpeBtnManager           = self._baseGameScene:getSKOpeBtnManager()
    if not SKHandCardsManager or not SKOpeBtnManager then return false end

    local cardsWaiting              = self._baseGameUtilsInfoManager:getWaitUniteInfo()
    local cardsThrow, cardsCount    = SKHandCardsManager:getMySelectCardIDs()
    local bFirstHand                = SKHandCardsManager:isFirstHand()
    if not cardsThrow or not cardsCount then return false end
    if not bFirstHand and not cardsWaiting then return false end

    local bEnableThrow = self:isEnableThrow(bFirstHand, cardsThrow, cardsCount, cardsWaiting)
    SKOpeBtnManager:setThrowEnable(bEnableThrow)

    return bEnableThrow
end

function SKGameController:isEnableThrow(bFirstHand, cardsThrow, cardsCount, cardsWaiting)
    if GamePublicInterface and GamePublicInterface:IS_FRAME_1() then
        return self:isEnableThrow_1(bFirstHand, cardsThrow, cardsCount, cardsWaiting)
    end

    if not cardsCount or not cardsThrow or 0 == cardsCount then return false end

    local throwDetails   = SKCalculator:initCardUnite()
    if not SKCalculator:getUniteDetails(cardsThrow, cardsCount, throwDetails, SKGameDef.SK_CARD_UNITE_TYPE_TOTAL) then
        return false
    end

    if bFirstHand then return true end     --第一手就可以直接出了

    if SKCalculator:getBestUnitType2(cardsWaiting, throwDetails) then
        return true
    else
        return false
    end
end

function SKGameController:isEnableThrow_1(bFirstHand, cardsThrow, cardsCount, cardsWaiting)
    if not cardsCount or not cardsThrow or 0 == cardsCount then return false end

    local throwDetails   = {}
    local dwThrowType    = SKCalculator:isValidCardsEx(cardsCount, cardsThrow, throwDetails)
    if 0 == dwThrowType then return false end

    if bFirstHand then return true end     --第一手就可以直接出了

    if not cardsWaiting or not cardsWaiting.nCardsCount or not cardsWaiting.nCardIDs then return false end

    local waitingDetails = {}
    local dwWaitingType  = SKCalculator:isValidCardsEx(cardsWaiting.nCardsCount, cardsWaiting.nCardIDs, waitingDetails)

    local nCompare       = SKCalculator:compareCardsEx(SKGameDef.SK_MAX_CARDS_PER_CHAIR, cardsThrow, throwDetails,
                                                        cardsWaiting.nCardIDs, waitingDetails)
    if 0 < nCompare then return true end

    return false
end

function SKGameController:clockStep(dt)
    if self:isAutoPlay() then
        self:autoPlay()
    end
end

function SKGameController:autoPlay()
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
                self:onPassCard()
                return
            end

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

function SKGameController:onCancelRobot()
    if self:isAutoPlay() then
        self:onAutoPlay(false)
    end
end

function SKGameController:onRobot()
    if self:isGameRunning() then
        self:onAutoPlay(not self._bAutoPlay)
    end
end

function SKGameController:onShare()
    if SKGameShare then
        self._baseGameScene._SKGameShare = SKGameShare:share()
    end

end

function SKGameController:onShareResult()
    if SKGameOverShare then
        SKGameOverShare:share()
    end
end

function SKGameController:getOppositeIndex()
    return self:getMyDrawIndex() + self:getTableChairCount() / 2    --总玩家为奇数则没有对家
end

function SKGameController:isMiddlePlayer(drawIndex)
    return drawIndex == self:getMyDrawIndex() or drawIndex == self:getOppositeIndex()
end

function SKGameController:isLeftPlayer(drawIndex)
    return drawIndex > self:getOppositeIndex()
end

function SKGameController:isRightPlayer(drawIndex)
    return drawIndex > self:getMyDrawIndex() and drawIndex < self:getOppositeIndex()
end

function SKGameController:showWaitArrangeTable(bShow)
    local gameStart = self._baseGameScene:getStart()
    if gameStart then
        gameStart:showWaitArrangeTable(bShow)
    end

    local selfInfo = self._baseGameScene:getSelfInfo()
    if selfInfo then
        selfInfo:showMatching(bShow)
    end
end

function SKGameController:onChatSend(content)
    local time = os.time()
    if time - self._sendChatTime < 3 then
        self:tipMessageByKey("G_CHAT_TIPS")
        return
    end
    self._sendChatTime = time

    SKGameController.super.onChatSend(self, content)
end

--[[function SKGameController:onGameAbort(data)
    local gameAbortInfo = nil
    if self._baseGameData then
        gameAbortInfo = self._baseGameData:getGameAbortInfo(data)
    end
    if gameAbortInfo then
        if self:getMyDrawIndex() ~= self:rul_GetDrawIndexByChairNO(gameAbortInfo.nChairNO) then
            self:gameStop()
            self:disconnect()

            local content = ""
            local userName = self:getPlayerUserNameByUserID(gameAbortInfo.nUserID)
            if gameAbortInfo.bForce then
                content = string.format(self:getGameStringByKey("G_GAMEABORT_FORCE_DEPOSIT"), userName, gameAbortInfo.nDepositDfif)
            else
                content = string.format(self:getGameStringByKey("G_GAMEABORT"), userName)
            end
            local okCallback = function()
                self:gotoHallScene()
            end
            local utf8Content = MCCharset:getInstance():gb2Utf8String(content, string.len(content))
            self:popSureDialog(utf8Content, "", "", okCallback, false)
        end
    end
end]]

function SKGameController:onOfflineInfo(data)
    local offlineData = nil
    if self._baseGameData then
        offlineData = self._baseGameData:getOfflineInfo(data)
    end
    local playerInfoManager = self:getPlayerInfoManager()

    if playerInfoManager then
        local userid = playerInfoManager:getSelfUserID()
        if userid and userid == offlineData.nUserID then
            if self._baseGameConnect then
                self._baseGameConnect:sendMsgToServer(SKGameDef.SK_SYSMSG_PLAYER_ONLINE)
            end
        end
    end
end

return SKGameController
