local MyJiSuHandCardsManager = class("MyJiSuHandCardsManager", import("src.app.Game.mMyGame.MyHandCardsManager"))
local GamePublicInterface = import("src.app.Game.mMyGame.GamePublicInterface")
local MyJiSuGameDef = import("src.app.Game.mMyJiSuGame.MyJiSuGameDef")
local MyJiSuCalculator = import("src.app.Game.mMyJiSuGame.MyJiSuCalculator")

function MyJiSuHandCardsManager:ctor(SKHandCards, HandCardsWhenThrow, gameController)
    MyJiSuHandCardsManager.super.ctor(self, SKHandCards, gameController)
    --急速掼蛋扔牌时所用的类
    self._handCardWhenThrow = HandCardsWhenThrow
end

function MyJiSuHandCardsManager:resetDunCards(cardIDs)
    local drawIndex = self._gameController:getMyDrawIndex()
    self:getSKHandCards(drawIndex):cardsCountIncrease(#cardIDs)
    
    self:ope_UnselectSelfCards()
    if self._SKHandCards[drawIndex] then
        self._SKHandCards[drawIndex]:addDunCards(cardIDs)
    end

    if drawIndex == self._gameController:getMyDrawIndex() then
        -- 进还贡后，重新计算同花顺选择器
        self._allTHSCardsArr = self:buildAllTonghuaShun()
        self:setShapeButtonsStatus()
    end
end

function MyJiSuHandCardsManager:ope_BuildCard(nInCards, nInCardLen, nOutCards, nOutCardLen, in_type, out_type, dwUniteSupport, bnUseJoker)
    local gameFlags = GamePublicInterface:getGameFlags()

    local lay = {}
    MyJiSuCalculator:xygZeroLays(lay, MyJiSuGameDef.SK_LAYOUT_NUM)

    local jokerCount = MyJiSuCalculator:preDealCards(nInCards, nInCardLen, lay, MyJiSuGameDef.SK_LAYOUT_NUM, MyJiSuGameDef.SK_GF_USE_JOKER)
    if not bnUseJoker then
        jokerCount = 0
    end

    MyJiSuCalculator:copyTable(out_type, in_type)

    local flags = MyJiSuGameDef.SK_COMPARE_UNITE_TYPE_SINGLE
    if self:IS_BIT_SET(dwUniteSupport, MyJiSuGameDef.SK_CARD_UNITE_TYPE_SINGLE)
            and self:IS_BIT_SET(flags, in_type.dwCardType)
            and MyJiSuCalculator:getCardType_Single(nInCards, nInCardLen, out_type) then
        MyJiSuCalculator:copyCardIDs(nOutCards, out_type.nCardIDs)
        return true
    end

    flags = MyJiSuGameDef.SK_COMPARE_UNITE_TYPE_COUPLE
    if self:IS_BIT_SET(dwUniteSupport, MyJiSuGameDef.SK_CARD_UNITE_TYPE_COUPLE)
            and self:IS_BIT_SET(flags, in_type.dwCardType)
            and MyJiSuCalculator:getCardType_Couple(nInCards, nInCardLen, lay, MyJiSuGameDef.SK_LAYOUT_NUM, jokerCount, out_type) then
        MyJiSuCalculator:copyCardIDs(nOutCards, out_type.nCardIDs)
        return true
    end

    flags = MyJiSuGameDef.SK_COMPARE_UNITE_TYPE_THREE
    if self:IS_BIT_SET(dwUniteSupport, MyJiSuGameDef.SK_CARD_UNITE_TYPE_THREE)
            and self:IS_BIT_SET(flags, in_type.dwCardType)
            and MyJiSuCalculator:getCardType_Three(nInCards, nInCardLen, lay, MyJiSuGameDef.SK_LAYOUT_NUM, jokerCount, out_type) then
        MyJiSuCalculator:copyCardIDs(nOutCards, out_type.nCardIDs)
        return true
    end

    flags = MyJiSuGameDef.SK_COMPARE_UNITE_TYPE_THREE_COUPLE
    if self:IS_BIT_SET(dwUniteSupport, MyJiSuGameDef.SK_CARD_UNITE_TYPE_THREE_COUPLE)
            and self:IS_BIT_SET(flags, in_type.dwCardType)
            and MyJiSuCalculator:getCardType_Three_CoupleEx(nInCards, nInCardLen, lay, MyJiSuGameDef.SK_LAYOUT_NUM, jokerCount, out_type, self._gameController._baseGameUtilsInfoManager:getWaitUniteInfo()) then
        MyJiSuCalculator:copyCardIDs(nOutCards, out_type.nCardIDs)
        return true
    end
    
    flags = MyJiSuGameDef.SK_COMPARE_UNITE_TYPE_ABT_SINGLE
    if self:IS_BIT_SET(dwUniteSupport, MyJiSuGameDef.SK_CARD_UNITE_TYPE_ABT_SINGLE)
            and self:IS_BIT_SET(flags, in_type.dwCardType)
            and MyJiSuCalculator:getCardType_ABT_Single(nInCards, nInCardLen, lay, MyJiSuGameDef.SK_LAYOUT_NUM, jokerCount, out_type, 5) then
        MyJiSuCalculator:copyCardIDs(nOutCards, out_type.nCardIDs)
        return true
    end

    flags = MyJiSuGameDef.SK_COMPARE_UNITE_TYPE_ABT_COUPLE
    if self:IS_BIT_SET(dwUniteSupport, MyJiSuGameDef.SK_CARD_UNITE_TYPE_ABT_COUPLE)
            and self:IS_BIT_SET(flags, in_type.dwCardType)
            and MyJiSuCalculator:getCardType_ABT_Couple(nInCards, nInCardLen, lay, MyJiSuGameDef.SK_LAYOUT_NUM, jokerCount, out_type, 3) then
        MyJiSuCalculator:copyCardIDs(nOutCards, out_type.nCardIDs)
        return true
    end   

    flags = MyJiSuGameDef.SK_COMPARE_UNITE_TYPE_ABT_THREE
    if self:IS_BIT_SET(dwUniteSupport, MyJiSuGameDef.SK_CARD_UNITE_TYPE_ABT_THREE)
            and self:IS_BIT_SET(flags, in_type.dwCardType)
            and MyJiSuCalculator:getCardType_ABT_Three(nInCards, nInCardLen, lay, MyJiSuGameDef.SK_LAYOUT_NUM, jokerCount, out_type, 2) then
        MyJiSuCalculator:copyCardIDs(nOutCards, out_type.nCardIDs)
        return true
    end

    flags = MyJiSuGameDef.MY_COMPARE_UNITE_TYPE_BOMB
    if self:IS_BIT_SET(dwUniteSupport, MyJiSuGameDef.SK_CARD_UNITE_TYPE_BOMB)
                and self:IS_BIT_SET(flags, in_type.dwCardType) then
        for i = 4, 5 do        
            if MyJiSuCalculator:getCardType_Bomb(nInCards, nInCardLen, lay, MyJiSuGameDef.SK_LAYOUT_NUM, jokerCount, out_type, i) then
                MyJiSuCalculator:copyCardIDs(nOutCards, out_type.nCardIDs)
                return true
            end
        end
    end
    
    flags = MyJiSuGameDef.MY_COMPARE_UNITE_TYPE_TONGHUASHUN
    if self:IS_BIT_SET(dwUniteSupport, MyJiSuGameDef.SK_CARD_UNITE_TYPE_TONGHUASHUN)
            and self:IS_BIT_SET(flags, in_type.dwCardType)
            and MyJiSuCalculator:getCardType_TongHuaShun(nInCards, nInCardLen, lay, MyJiSuGameDef.SK_LAYOUT_NUM, jokerCount, out_type, 5) then
        MyJiSuCalculator:copyCardIDs(nOutCards, out_type.nCardIDs)
        return true
    end

    flags = MyJiSuGameDef.MY_COMPARE_UNITE_TYPE_SUPER_BOMB
    if self:IS_BIT_SET(dwUniteSupport, MyJiSuGameDef.SK_CARD_UNITE_TYPE_SUPER_BOMB)
                and self:IS_BIT_SET(flags, in_type.dwCardType) then
        for i = 6, (8+jokerCount)--[[10--]] do       
            if MyJiSuCalculator:getCardType_SuperBomb(nInCards, nInCardLen, lay, MyJiSuGameDef.SK_LAYOUT_NUM, jokerCount, out_type, i) then
                MyJiSuCalculator:copyCardIDs(nOutCards, out_type.nCardIDs)
                return true
            end
        end
    end

    flags = MyJiSuGameDef.MY_COMPARE_UNITE_TYPE_4KING
    if self:IS_BIT_SET(dwUniteSupport, MyJiSuGameDef.SK_CARD_UNITE_TYPE_4KING)
            and self:IS_BIT_SET(flags, in_type.dwCardType)
            and MyJiSuCalculator:getCardType_4King(nInCards, nInCardLen, lay, MyJiSuGameDef.SK_LAYOUT_NUM ,jokerCount , out_type, 4) then
        MyJiSuCalculator:copyCardIDs(nOutCards, out_type.nCardIDs)
        return true
    end

    return false
end

--增加炸弹张数的参数
function MyJiSuHandCardsManager:ope_BuildCardBomb(nInCards, nInCardLen, nOutCards, nOutCardLen, in_type, out_type, dwUniteSupport, bnUseJoker, nCount)
    local gameFlags = GamePublicInterface:getGameFlags()

    local lay = {}
    MyJiSuCalculator:xygZeroLays(lay, MyJiSuGameDef.SK_LAYOUT_NUM)

    local jokerCount = MyJiSuCalculator:preDealCards(nInCards, nInCardLen, lay, MyJiSuGameDef.SK_LAYOUT_NUM, MyJiSuGameDef.SK_GF_USE_JOKER)
    if not bnUseJoker then
        jokerCount = 0
    end

    MyJiSuCalculator:copyTable(out_type, in_type)

    local flags = MyJiSuGameDef.MY_COMPARE_UNITE_TYPE_BOMB
    if self:IS_BIT_SET(dwUniteSupport, MyJiSuGameDef.SK_CARD_UNITE_TYPE_BOMB)
                and self:IS_BIT_SET(flags, in_type.dwCardType) then
        if MyJiSuCalculator:getCardType_Bomb(nInCards, nInCardLen, lay, MyJiSuGameDef.SK_LAYOUT_NUM, jokerCount, out_type, nCount) then
            MyJiSuCalculator:copyCardIDs(nOutCards, out_type.nCardIDs)
            return true
        end
    end

    return false
end

function MyJiSuHandCardsManager:setHandCardsWhenThrow(dunCardIDs, nRound)     
    print("MyJiSuHandCardsManager:setHandCardsWhenThrow")
    if not dunCardIDs then
        print("error setHandCardsWhenThrow dunCardIDs is nil")
        return
    end
    dump(dunCardIDs, "dunCardIDs")
    for i = nRound,3 do 
        local cardsCtrl = (self._handCardWhenThrow or {})[i]
        if cardsCtrl and dunCardIDs[i] then
            cardsCtrl:setHandCardsCount(#dunCardIDs[i])
            cardsCtrl:setHandCards(dunCardIDs[i])
            cardsCtrl:sortHandCardsByBombAndArrange(dunCardIDs[i])
        end
    end
end

function MyJiSuHandCardsManager:touchBegan(x, y)
    local status = self._gameController._baseGameUtilsInfoManager:getStatus()
    if self:IS_BIT_SET(status, MyJiSuGameDef.MYJISUGAME_TS_WAITING_ADJUST) then
        if self._SKHandCards[self._gameController:getMyDrawIndex()] then
            self._SKHandCards[self._gameController:getMyDrawIndex()]:touchBegan(x, y)
        end
    elseif self:IS_BIT_SET(status, MyJiSuGameDef.BASEGAME_TS_WAITING_THROW) then
        for i = 1,3 do
            self._handCardWhenThrow[i]:touchBegan(x,y)
        end
    end
end


function MyJiSuHandCardsManager:touchMove(x, y)
    local status = self._gameController._baseGameUtilsInfoManager:getStatus()
    if self:IS_BIT_SET(status, MyJiSuGameDef.MYJISUGAME_TS_WAITING_ADJUST) then
        if self._SKHandCards[self._gameController:getMyDrawIndex()] then
            self._SKHandCards[self._gameController:getMyDrawIndex()]:touchMove(x, y)
        end
    elseif self:IS_BIT_SET(status, MyJiSuGameDef.BASEGAME_TS_WAITING_THROW) then
        for i = 1,3 do
            self._handCardWhenThrow[i]:touchMove(x,y)
        end
    end
end

function MyJiSuHandCardsManager:touchEnd(x, y)
    local status = self._gameController._baseGameUtilsInfoManager:getStatus()
    if self:IS_BIT_SET(status, MyJiSuGameDef.MYJISUGAME_TS_WAITING_ADJUST) then
        if self._SKHandCards[self._gameController:getMyDrawIndex()] then
            self._SKHandCards[self._gameController:getMyDrawIndex()]:touchEnd(x, y)
        end
    elseif self:IS_BIT_SET(status, MyJiSuGameDef.BASEGAME_TS_WAITING_THROW) then
        for i = 1,3 do
            self._handCardWhenThrow[i]:touchEnd(x,y)
        end
    end
end

function MyJiSuHandCardsManager:containsTouchLocation(x, y)
    local status = self._gameController._baseGameUtilsInfoManager:getStatus()
    if self:IS_BIT_SET(status, MyJiSuGameDef.MYJISUGAME_TS_WAITING_ADJUST) then
        local b = false
        if self._SKHandCards[self._gameController:getMyDrawIndex()] then
            b = self._SKHandCards[self._gameController:getMyDrawIndex()]:containsTouchLocation(x, y)
        end
        return b
    elseif self:IS_BIT_SET(status, MyJiSuGameDef.BASEGAME_TS_WAITING_THROW) then
        local b = false
        for i = 1,3 do
            b = self._handCardWhenThrow[i]:containsTouchLocation(x,y)
            if b then
                return b
            end
        end
        return b
    end
end

function MyJiSuHandCardsManager:setEnableTouch(enableTouch)
    local status = self._gameController._baseGameUtilsInfoManager:getStatus()
    if self:IS_BIT_SET(status, MyJiSuGameDef.MYJISUGAME_TS_WAITING_ADJUST) then
        if self._SKHandCards[self._gameController:getMyDrawIndex()] then
            self._SKHandCards[self._gameController:getMyDrawIndex()]:setEnableTouch(enableTouch)
        end
    elseif self:IS_BIT_SET(status, MyJiSuGameDef.BASEGAME_TS_WAITING_THROW) then
        for i = 1,3 do
            self._handCardWhenThrow[i]:setEnableTouch(enableTouch)
        end
    end
end

function MyJiSuHandCardsManager:ope_UnselectSelfCards()
    local status = self._gameController._baseGameUtilsInfoManager:getStatus()
    if self:IS_BIT_SET(status, MyJiSuGameDef.MYJISUGAME_TS_WAITING_ADJUST) then
        if self._SKHandCards[self._gameController:getMyDrawIndex()]:getHandCardsCount() <= 0 then
            return
        end
    elseif self:IS_BIT_SET(status, MyJiSuGameDef.BASEGAME_TS_WAITING_THROW) then
    end
    self._gameController:playGamePublicSound("SpecSelectCard.mp3")
    self:ope_resetSelfCardsPos()
    self:ope_resetSelfCardsState()
end

function MyJiSuHandCardsManager:ope_resetSelfCardsPos()
    local status = self._gameController._baseGameUtilsInfoManager:getStatus()
    if self:IS_BIT_SET(status, MyJiSuGameDef.MYJISUGAME_TS_WAITING_ADJUST) then
        if self._SKHandCards[self._gameController:getMyDrawIndex()] then
            self._SKHandCards[self._gameController:getMyDrawIndex()]:resetCardsPos()
        end
    elseif self:IS_BIT_SET(status, MyJiSuGameDef.BASEGAME_TS_WAITING_THROW) then
        for i = 1,3 do
            self._handCardWhenThrow[i]:resetCardsPos()
        end
    end 
end

function MyJiSuHandCardsManager:ope_resetSelfCardsState()
    local status = self._gameController._baseGameUtilsInfoManager:getStatus()
    if self:IS_BIT_SET(status, MyJiSuGameDef.MYJISUGAME_TS_WAITING_ADJUST) then
        if self._SKHandCards[self._gameController:getMyDrawIndex()] then
            self._SKHandCards[self._gameController:getMyDrawIndex()]:resetCardsState()
        end
    elseif self:IS_BIT_SET(status, MyJiSuGameDef.BASEGAME_TS_WAITING_THROW) then
        for i = 1,3 do
            self._handCardWhenThrow[i]:resetCardsState()
        end
    end
end

function MyJiSuHandCardsManager:getHandCardIDs(drawIndex, nRound)
    local status = self._gameController._baseGameUtilsInfoManager:getStatus()
    if self:IS_BIT_SET(status, MyJiSuGameDef.MYJISUGAME_TS_WAITING_ADJUST) then
        return self._SKHandCards[drawIndex]:getHandCardIDs()
    elseif self:IS_BIT_SET(status, MyJiSuGameDef.BASEGAME_TS_WAITING_THROW) then
        if not self._handCardWhenThrow or not self._handCardWhenThrow[nRound] then 
            return 
        end
        return self._handCardWhenThrow[nRound]:getHandCardIDs()
    end
end

function MyJiSuHandCardsManager:getMySelectCardIDs()
    local status = self._gameController._baseGameUtilsInfoManager:getStatus()
    if self:IS_BIT_SET(status, MyJiSuGameDef.MYJISUGAME_TS_WAITING_ADJUST) then
        if self._SKHandCards[self._gameController:getMyDrawIndex()] then
            return self._SKHandCards[self._gameController:getMyDrawIndex()]:getSelectCardIDs()
        end
    elseif self:IS_BIT_SET(status, MyJiSuGameDef.BASEGAME_TS_WAITING_THROW) then
        local retCards, cardCount = {}, 0
        for i = 1,3 do
            local inhandCards, inhandCardsCount = self._handCardWhenThrow[i]:getSelectCardIDs()
            table.merge(retCards, inhandCards)
            cardCount = cardCount + (inhandCardsCount or 0)
        end
        return retCards, cardCount
    end
end

-- 每次出完牌需要重新计算 有几个同花顺
function MyJiSuHandCardsManager:ope_ThrowCards(drawIndex, cardIDs, cardsCount, nRound)
    local status = self._gameController._baseGameUtilsInfoManager:getStatus()
    if self:IS_BIT_SET(status, MyJiSuGameDef.MYJISUGAME_TS_WAITING_ADJUST) then
        if self._SKHandCards[drawIndex] then
            self._SKHandCards[drawIndex]:ope_ThrowCards(cardIDs, cardsCount)
        end
    
        self:resetRemind()
        self._allTHSCardsArr = self:buildAllTonghuaShun()
        self:setShapeButtonsStatus()
    elseif self:IS_BIT_SET(status, MyJiSuGameDef.BASEGAME_TS_WAITING_THROW) then
        if drawIndex ==  self._gameController:getMyDrawIndex() then
            self._handCardWhenThrow[nRound]:ope_ThrowCards(cardIDs, cardsCount)
        end
    end
end

--出牌提示
function MyJiSuHandCardsManager:onHint()
    self:ope_UnselectSelfCards()

    local status = self._gameController._baseGameUtilsInfoManager:getStatus()
    if self:IS_BIT_SET(status, MyJiSuGameDef.BASEGAME_TS_WAITING_THROW) then
        local nRound = self._gameController._baseGameUtilsInfoManager:getRoundInfo()
        local inhandCards, inhandCardsCount = self:getHandCardIDs(self._gameController:getMyDrawIndex(), nRound)
        self:selectMyCardsByIDs(inhandCards, SKGameDef.SK_CHAIR_CARDS)

        self._gameController:ope_CheckSelect()
    end
end

function MyJiSuHandCardsManager:selectMyCardsByIDs(cardsID, cardsCount)
    local status = self._gameController._baseGameUtilsInfoManager:getStatus()
    if self:IS_BIT_SET(status, MyJiSuGameDef.MYJISUGAME_TS_WAITING_ADJUST) then
        local myHandCards = self:getSKHandCards(self._gameController:getMyDrawIndex())
        if myHandCards then
            myHandCards:selectCardsByIDs(cardsID, cardsCount)
        end
    elseif self:IS_BIT_SET(status, MyJiSuGameDef.BASEGAME_TS_WAITING_THROW) then
        for i = 1,3 do
            self._handCardWhenThrow[i]:selectCardsByIDs(cardsID, cardsCount)
        end
    end
    
end

function MyJiSuHandCardsManager:resetHandCardsManager()
    MyJiSuHandCardsManager.super.resetHandCardsManager(self)

    if not self._handCardWhenThrow then return end
    
    for i = 1,3 do
        self._handCardWhenThrow[i]:resetSKHandCards()
    end
end

return MyJiSuHandCardsManager