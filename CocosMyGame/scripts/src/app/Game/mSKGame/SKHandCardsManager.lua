
local SKHandCardsManager = class("SKHandCardsManager")

local SKGameDef                                 = import("src.app.Game.mSKGame.SKGameDef")
local SKGameUtilsInfoManager                    = import("src.app.Game.mSKGame.SKGameUtilsInfoManager")

local SKCalculator                              = import("src.app.Game.mSKGame.SKCalculator")

local GamePublicInterface                       = import("src.app.Game.mMyGame.GamePublicInterface")

function SKHandCardsManager:IS_BIT_SET(flag, mybit)
    if not flag or not mybit then
        return false
    end
    return (mybit == bit._and(mybit, flag))
end

function SKHandCardsManager:ctor(SKHandCards, gameController)
    if not gameController then printError("gameController is nil!!!") return end
    self._gameController        = gameController

    self._SKHandCards           = SKHandCards
    self._dealCounts            = 1
    self._firstHand             = 1
    self._dealCardTimerID       = nil

    self._remindUniteType       = SKCalculator:initUniteType()
    self._bestRemindUniteType   = SKCalculator:initUniteType()

    self:init()
end

function SKHandCardsManager:init()
    if not self._SKHandCards then return end

    self:resetHandCardsManager()
end

function SKHandCardsManager:resetHandCardsManager()
    if not self._SKHandCards then return end

    self._dealCounts            = 1
    self._firstHand             = 1

    if self._dealCardTimerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._dealCardTimerID)
        self._dealCardTimerID = nil
    end

    for i = 1, self._gameController:getTableChairCount() do
        local SKHandCards = self._SKHandCards[i]
        if SKHandCards then
            SKHandCards:resetSKHandCards()
        end
    end

    self:setEnableTouch(false)

    self:resetRemind()
end

function SKHandCardsManager:resetRemind()
    self._remindUniteType       = SKCalculator:initUniteType()
    self._bestRemindUniteType   = SKCalculator:initUniteType()
end

function SKHandCardsManager:getSKHandCards(drawIndex)
    return self._SKHandCards[drawIndex]
end

function SKHandCardsManager:setHandCardsCount(drawIndex, cardsCount)
    if self._SKHandCards[drawIndex] then
        self._SKHandCards[drawIndex]:setHandCardsCount(cardsCount)
    end
end

function SKHandCardsManager:setSelfHandCards(handCards)
    if self._SKHandCards[self._gameController:getMyDrawIndex()] then
        self._SKHandCards[self._gameController:getMyDrawIndex()]:setHandCards(handCards)
    end
end

function SKHandCardsManager:hideSelfHandCards()
    if self._SKHandCards[self._gameController:getMyDrawIndex()] then
        self._SKHandCards[self._gameController:getMyDrawIndex()]:hideHandCards()
    end
end

function SKHandCardsManager:hideHandCards(drawIndex)
    if self._SKHandCards[drawIndex] then
        self._SKHandCards[drawIndex]:hideHandCards()
    end
end

function SKHandCardsManager:moveHandCards(drawIndex, bMoveOut)
    if self._SKHandCards[drawIndex] then
        self._SKHandCards[drawIndex]:moveHandCards(bMoveOut)
    end
end

function SKHandCardsManager:setHandCards(drawIndex, handCards)
    if self._SKHandCards[drawIndex] then
        self._SKHandCards[drawIndex]:setHandCards(handCards)
    end
end

function SKHandCardsManager:setHandCardsWin(drawIndex, handCards)
    if self._SKHandCards[drawIndex] then
        self._SKHandCards[drawIndex]:setHandCardsWin(handCards)
    end
end

function SKHandCardsManager:updateHandCards(drawIndex)
    if self._SKHandCards[drawIndex] then
        self._SKHandCards[drawIndex]:updateHandCards()
    end
end

function SKHandCardsManager:ope_DealCard()
    if self._dealCardTimerID then return end

    local function onDealCard()
        self:onDealCard()
    end

    self._dealCardTimerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(onDealCard, SKGameDef.SK_DEAL_CARDS_INTERVAL, false)
end

function SKHandCardsManager:onDealCard()
    if not self._SKHandCards then return end

    for i = 1, self._gameController:getTableChairCount() do
        local nBanker       = self._gameController:getBankerDrawIndex()
        local count         = self._gameController:getChairCardsCount()
        if i ~= nBanker then
            count = self._gameController:getChairCardsCount() - self._gameController:getTopCardsCount()
        end
        local SKHandCards   = self._SKHandCards[i]
        if SKHandCards and self._dealCounts <= count then
            SKHandCards:onDealCard(self._dealCounts)

            self._gameController:playDealCardEffect()
        end
    end

    self._dealCounts = self._dealCounts + 1
    if self._dealCounts > self._gameController:getChairCardsCount() then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._dealCardTimerID)
        self._dealCardTimerID = nil
        self._dealCounts     = 1

        self._gameController:onDealCardOver()
    end
end

function SKHandCardsManager:setFirstHand(firstHand)
    self._firstHand = firstHand
end

function SKHandCardsManager:isFirstHand()
    if 1 == self._firstHand then
        return true
    else
        return false
    end
end

function SKHandCardsManager:ope_SortCards() --开局第一次排序 回调正式开始游戏
    self:ope_SortSelfHandCards()
    self._gameController:ope_StartPlay()
end

function SKHandCardsManager:ope_SortSelfHandCards()
    if self._SKHandCards[self._gameController:getMyDrawIndex()] then
        self._SKHandCards[self._gameController:getMyDrawIndex()]:sortHandCards()
    end
end

function SKHandCardsManager:sortHandCards(drawIndex)
    self._SKHandCards[drawIndex]:sortHandCards()
end

function SKHandCardsManager:getHandCardIDs(drawIndex)
    return self._SKHandCards[drawIndex]:getHandCardIDs()
end

function SKHandCardsManager:ope_UnselectSelfCards()
    self:ope_resetSelfCardsPos()
    self:ope_resetSelfCardsState()
end

function SKHandCardsManager:ope_resetSelfCardsPos()
    if self._SKHandCards[self._gameController:getMyDrawIndex()] then
        self._SKHandCards[self._gameController:getMyDrawIndex()]:resetCardsPos()
    end
end

function SKHandCardsManager:ope_resetSelfCardsState()
    if self._SKHandCards[self._gameController:getMyDrawIndex()] then
        self._SKHandCards[self._gameController:getMyDrawIndex()]:resetCardsState()
    end
end

function SKHandCardsManager:ope_maskSelfCards(bMask)
    if self._SKHandCards[self._gameController:getMyDrawIndex()] then
        self._SKHandCards[self._gameController:getMyDrawIndex()]:maskAllHandCards(bMask)
    end
end

function SKHandCardsManager:ope_ThrowCards(drawIndex, cardIDs, cardsCount)
    if self._SKHandCards[drawIndex] then
        self._SKHandCards[drawIndex]:ope_ThrowCards(cardIDs, cardsCount)
    end

    self:resetRemind()
end

function SKHandCardsManager:getMySelectCardIDs()
    if self._SKHandCards[self._gameController:getMyDrawIndex()] then
        return self._SKHandCards[self._gameController:getMyDrawIndex()]:getSelectCardIDs()
    end
end

function SKHandCardsManager:containsTouchLocation(x, y)
    local b = false
    if self._SKHandCards[self._gameController:getMyDrawIndex()] then
        b = self._SKHandCards[self._gameController:getMyDrawIndex()]:containsTouchLocation(x, y)
    end
    return b
end

function SKHandCardsManager:touchBegan(x, y)
    if self._SKHandCards[self._gameController:getMyDrawIndex()] then
        self._SKHandCards[self._gameController:getMyDrawIndex()]:touchBegan(x, y)
    end
end

function SKHandCardsManager:touchMove(x, y)
    if self._SKHandCards[self._gameController:getMyDrawIndex()] then
        self._SKHandCards[self._gameController:getMyDrawIndex()]:touchMove(x, y)
    end
end

function SKHandCardsManager:touchEnd(x, y)
    if self._SKHandCards[self._gameController:getMyDrawIndex()] then
        self._SKHandCards[self._gameController:getMyDrawIndex()]:touchEnd(x, y)
    end
end

function SKHandCardsManager:setEnableTouch(enableTouch)
    if self._SKHandCards[self._gameController:getMyDrawIndex()] then
        self._SKHandCards[self._gameController:getMyDrawIndex()]:setEnableTouch(enableTouch)
    end
end

function SKHandCardsManager:onGameExit()
    if self._dealCardTimerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._dealCardTimerID)
        self._dealCardTimerID = nil
    end
end

function SKHandCardsManager:onHint()
    self:ope_UnselectSelfCards()

    local myHandCards = self:getSKHandCards(self._gameController:getMyDrawIndex())
    if not myHandCards then return end

    local waitChair = self._gameController._baseGameUtilsInfoManager:getWaitChair()
    if not waitChair or waitChair == -1 then
        local inhandCards, cardsCount = myHandCards:getHandCardIDs()
        self:selectMyCardsByIDs(inhandCards, cardsCount)
        if self._gameController:ope_CheckSelect() then
            return
        end

        self:ope_UnselectSelfCards()
        self:selectMinUnite()
        if self._gameController:ope_CheckSelect() then
            return
        end

        return
    end

    local waitCardUnite = {}
    SKCalculator:copyTable(waitCardUnite, self._gameController._baseGameUtilsInfoManager:getWaitUniteInfo()) -- 1.0这里只是简单的出牌消息
    if GamePublicInterface and GamePublicInterface:IS_FRAME_1() then
        local waitDetails   = SKCalculator:initCardUnite()
        if not SKCalculator:getUniteDetails(waitCardUnite.nCardIDs, waitCardUnite.nCardsCount, waitDetails, SKGameDef.SK_CARD_UNITE_TYPE_TOTAL) then
            return
        end
        SKCalculator:getBestUnitType1(waitDetails)
        if not waitDetails or not waitDetails.uniteType[1] then return end
        SKCalculator:copyTable(waitCardUnite, waitDetails.uniteType[1])
    end

    local remindCards = self:onRemind(waitCardUnite)
    if not remindCards then
        self._gameController:onPassCard()
        return
    end

    self:selectMyCardsByIDs(remindCards, SKGameDef.SK_CHAIR_CARDS)
    if not self._gameController:ope_CheckSelect() then
        self._gameController:onPassCard()
    end
end

function SKHandCardsManager:selectMyCardsByIDs(cardsID, cardsCount)
    local myHandCards = self:getSKHandCards(self._gameController:getMyDrawIndex())
    if myHandCards then
        myHandCards:selectCardsByIDs(cardsID, cardsCount)
    end
end

function SKHandCardsManager:selectMinUnite()
    local myHandCards = self:getSKHandCards(self._gameController:getMyDrawIndex())
    if not myHandCards then return end

    local inhandLay     = {}
    SKCalculator:xygZeroLays(inhandLay, SKGameDef.SK_LAYOUT_NUM)
    local gameFlags = GamePublicInterface:getGameFlags()
    local inhandCards, cardsCount = myHandCards:getHandCardIDs()
    SKCalculator:skLayCards(inhandCards, cardsCount, inhandLay, gameFlags)

    local index = SKCalculator:getCardIndex(inhandCards[cardsCount], gameFlags)
    if inhandLay[index] <= 3 then
        myHandCards:selectCardsByIndex(index)
    else
        local pri = 10000
        for i = 1, 3 do
            for j = 1, SKGameDef.SK_LAYOUT_NUM do
                local rank = self._gameController._baseGameUtilsInfoManager:getCurrentRank()
                if inhandLay[j] == i and SKCalculator:getCardIndexPri(j, rank, gameFlags) < pri then
                    index   = j
                    pri     = SKCalculator:getCardIndexPri(j, rank, gameFlags)
                end
            end
        end

        myHandCards:selectCardsByIndex(index)
    end
end

function SKHandCardsManager:onRemind(waitCardUnite)
    local myHandCards = self:getSKHandCards(self._gameController:getMyDrawIndex())
    if not myHandCards then return nil end

    local bestRemindCards = self:onBestRemind(waitCardUnite)
    if bestRemindCards then
        return bestRemindCards
    end

    local remindCards   = {}
    SKCalculator:xygInitChairCards(remindCards, SKGameDef.SK_MAX_CARDS_PER_CHAIR)
    local gameFlags = GamePublicInterface:getGameFlags()
    local inhandCards, cardsCount = myHandCards:getHandCardIDs()

    if self._remindUniteType.dwCardType and self._remindUniteType.dwCardType ~= 0 then
        if self:ope_BuildCard(inhandCards, cardsCount, remindCards, cardsCount, self._remindUniteType, self._remindUniteType, SKGameDef.SK_CARD_UNITE_TYPE_TOTAL) then
            return remindCards
        else
            self._bestRemindUniteType = SKCalculator:initUniteType()
            bestRemindCards = self:onBestRemind(waitCardUnite)
            if bestRemindCards then
                self._remindUniteType = SKCalculator:initUniteType()
                return bestRemindCards
            end

            if self:ope_BuildCard(inhandCards, cardsCount, remindCards, cardsCount, waitCardUnite, self._remindUniteType, SKGameDef.SK_CARD_UNITE_TYPE_TOTAL) then
                return remindCards
            end
        end
    else
        if self:ope_BuildCard(inhandCards, cardsCount, remindCards, cardsCount, waitCardUnite, self._remindUniteType, SKGameDef.SK_CARD_UNITE_TYPE_TOTAL) then
            return remindCards
        end
    end
end

function SKHandCardsManager:onBestRemind(waitCardUnite)
    local myHandCards = self:getSKHandCards(self._gameController:getMyDrawIndex())
    if not myHandCards then return nil end

    local remindCards   = {}
    local inhandLay     = {}
    SKCalculator:xygInitChairCards(remindCards, SKGameDef.SK_MAX_CARDS_PER_CHAIR)
    SKCalculator:xygZeroLays(inhandLay, SKGameDef.SK_LAYOUT_NUM)

    local gameFlags = GamePublicInterface:getGameFlags()
    local inhandCards, cardsCount = myHandCards:getHandCardIDs()
    SKCalculator:skLayCards(inhandCards, cardsCount, inhandLay, gameFlags)

    local perfectUnite  = SKCalculator:initUniteType()
    if self._bestRemindUniteType.dwCardType and self._bestRemindUniteType.dwCardType ~= 0 then
        SKCalculator:copyTable(perfectUnite, self._bestRemindUniteType)
    else
        SKCalculator:copyTable(perfectUnite, waitCardUnite)
    end

    local remindLay     = {}
    while self:ope_BuildCard(inhandCards, cardsCount, remindCards, cardsCount, perfectUnite, perfectUnite, SKGameDef.SK_CARD_UNITE_TYPE_TOTAL) do
        SKCalculator:xygZeroLays(remindLay, SKGameDef.SK_LAYOUT_NUM)
        SKCalculator:skLayCards(remindCards, cardsCount, remindLay, gameFlags)

        local bMatch = true
        for i = 1, SKGameDef.SK_LAYOUT_NUM do
            if remindLay[i] ~= 0 and remindLay[i] ~= inhandLay[i] then
                bMatch = false
                break
            end
        end

        if bMatch then
            SKCalculator:copyTable(self._bestRemindUniteType, perfectUnite)
            return remindCards
        else
            SKCalculator:xygInitChairCards(remindCards, SKGameDef.SK_MAX_CARDS_PER_CHAIR)
        end
    end

    return nil
end

--默认逮狗腿牌型 其他游戏请自行修改
function SKHandCardsManager:ope_BuildCard(nInCards, nInCardLen, nOutCards, nOutCardLen, in_type, out_type, dwUniteSupport)
    local gameFlags = GamePublicInterface:getGameFlags()

    local lay = {}
    SKCalculator:xygZeroLays(lay, SKGameDef.SK_LAYOUT_NUM)
    local jokerCount = SKCalculator:preDealCards(nInCards, nInCardLen, lay, SKGameDef.SK_LAYOUT_NUM, gameFlags)

    SKCalculator:copyTable(out_type, in_type)

    local flags = SKGameDef.SK_COMPARE_UNITE_TYPE_SINGLE
    if self:IS_BIT_SET(dwUniteSupport, SKGameDef.SK_CARD_UNITE_TYPE_SINGLE)
        and self:IS_BIT_SET(flags, in_type.dwCardType)
        and SKCalculator:getCardType_Single(nInCards, nInCardLen, out_type) then
        SKCalculator:copyCardIDs(nOutCards, out_type.nCardIDs)
        return true
    end

    flags = SKGameDef.SK_COMPARE_UNITE_TYPE_COUPLE
    if self:IS_BIT_SET(dwUniteSupport, SKGameDef.SK_CARD_UNITE_TYPE_COUPLE)
            and self:IS_BIT_SET(flags, in_type.dwCardType)
            and SKCalculator:getCardType_Couple(nInCards, nInCardLen, lay, SKGameDef.SK_LAYOUT_NUM, jokerCount, out_type) then
        SKCalculator:copyCardIDs(nOutCards, out_type.nCardIDs)
        return true
    end

    flags = SKGameDef.SK_COMPARE_UNITE_TYPE_THREE
    if self:IS_BIT_SET(dwUniteSupport, SKGameDef.SK_CARD_UNITE_TYPE_THREE)
            and self:IS_BIT_SET(flags, in_type.dwCardType)
            and SKCalculator:getCardType_Three(nInCards, nInCardLen, lay, SKGameDef.SK_LAYOUT_NUM, jokerCount, out_type) then
        SKCalculator:copyCardIDs(nOutCards, out_type.nCardIDs)
        return true
    end

    flags = SKGameDef.SK_COMPARE_UNITE_TYPE_THREE_COUPLE
    if self:IS_BIT_SET(dwUniteSupport, SKGameDef.SK_CARD_UNITE_TYPE_THREE_COUPLE)
            and self:IS_BIT_SET(flags, in_type.dwCardType)
            and SKCalculator:getCardType_Three_Couple(nInCards, nInCardLen, lay, SKGameDef.SK_LAYOUT_NUM, jokerCount, out_type) then
        SKCalculator:copyCardIDs(nOutCards, out_type.nCardIDs)
        return true
    end

    flags = SKGameDef.SK_COMPARE_UNITE_TYPE_ABT_COUPLE
    for i = 3, 12 do
        if self:IS_BIT_SET(dwUniteSupport, SKGameDef.SK_CARD_UNITE_TYPE_ABT_COUPLE)
                and self:IS_BIT_SET(flags, in_type.dwCardType)
                and SKCalculator:getCardType_ABT_Couple(nInCards, nInCardLen, lay, SKGameDef.SK_LAYOUT_NUM, jokerCount, out_type, i) then
            SKCalculator:copyCardIDs(nOutCards, out_type.nCardIDs)
            return true
        end
    end

    flags = SKGameDef.SK_COMPARE_UNITE_TYPE_ABT_THREE
    for i = 2, 12 do
        if self:IS_BIT_SET(dwUniteSupport, SKGameDef.SK_CARD_UNITE_TYPE_ABT_THREE)
                and self:IS_BIT_SET(flags, in_type.dwCardType)
                and SKCalculator:getCardType_ABT_Three(nInCards, nInCardLen, lay, SKGameDef.SK_LAYOUT_NUM, jokerCount, out_type, i) then
            SKCalculator:copyCardIDs(nOutCards, out_type.nCardIDs)
            return true
        end
    end

    flags = SKGameDef.SK_COMPARE_UNITE_TYPE_ABT_THREE_COUPLE
    for i = 2, 12 do
        if self:IS_BIT_SET(dwUniteSupport, SKGameDef.SK_CARD_UNITE_TYPE_ABT_THREE_COUPLE)
                and self:IS_BIT_SET(flags, in_type.dwCardType)
                and SKCalculator:getCardType_ABT_Three_Couple(nInCards, nInCardLen, lay, SKGameDef.SK_LAYOUT_NUM, jokerCount, out_type, i) then
            SKCalculator:copyCardIDs(nOutCards, out_type.nCardIDs)
            return true
        end
    end

    flags = SKGameDef.SK_COMPARE_UNITE_TYPE_BOMB
    for i = 4, SKGameDef.SK_TOTAL_PACK * 4 do
        if self:IS_BIT_SET(dwUniteSupport, SKGameDef.SK_CARD_UNITE_TYPE_BOMB)
                and self:IS_BIT_SET(flags, in_type.dwCardType)
                and SKCalculator:getCardType_Bomb(nInCards, nInCardLen, lay, SKGameDef.SK_LAYOUT_NUM, jokerCount, out_type, i) then
            SKCalculator:copyCardIDs(nOutCards, out_type.nCardIDs)
            return true
        end
    end

    flags = SKGameDef.SK_COMPARE_UNITE_TYPE_BOMB
    if self:IS_BIT_SET(dwUniteSupport, SKGameDef.SK_CARD_UNITE_TYPE_BOMB)
            and self:IS_BIT_SET(flags, in_type.dwCardType)
            and SKCalculator:getCardType_Kings(nInCards, nInCardLen, lay, SKGameDef.SK_LAYOUT_NUM, out_type, lay[15]+lay[16]) then
        SKCalculator:copyCardIDs(nOutCards, out_type.nCardIDs)
        return true
    end

    return false
end

return SKHandCardsManager
