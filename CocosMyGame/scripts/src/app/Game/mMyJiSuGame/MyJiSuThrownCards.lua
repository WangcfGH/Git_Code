local MyJiSuThrownCards = class("MyJiSuThrownCards", import("src.app.Game.mMyGame.MyThrownCards"))
local SKGameDef = import("src.app.Game.mSKGame.SKGameDef")
local MyJiSuCalculator = import("src.app.Game.mMyJiSuGame.MyJiSuCalculator")

function MyJiSuThrownCards:ope_ThrowCards(cardIDs, cardsCount, dwCardType, throwCount)
    --self:moveThrow()

    self.ThrowCardType = dwCardType

    local validCardIDs = {}
    for i = 1, #cardIDs do
        if MyJiSuCalculator:isValidCard(cardIDs[i]) then
            table.insert(validCardIDs, cardIDs[i])
        end
    end
    if #validCardIDs ~= cardsCount then
        printError("cardnums not equal cardsCount:", cardsCount)
        dump(cardIDs)
    end
    local uniteTypes = MyJiSuCalculator:getDunUniteType(validCardIDs)
    local tmpCardIDs = {}
    for i = 1, #uniteTypes do
        for j = 1, uniteTypes[i].nCardsCount do
            table.insert(tmpCardIDs, uniteTypes[i].nCardIDs[j])
        end
    end
    self:setThrownCardsCount(cardsCount)
    self:setThrownCards(tmpCardIDs, throwCount)
    self:sortThrownCards()
    self:showCardType(dwCardType, uniteTypes[1].nCardsCount)
end

function MyJiSuThrownCards:setThrownCards(thrownCards, throwCount)
    for i = 1, self._cardsCount do
        if not self._cards[i] then break end
        if i > self._gameController:getChairCardsCount() then break end

        self._cards[i]:setSKID(thrownCards[i])
        self._cards[i]:setPosition(self:getThrowCardsPosition(i))
        local zorder = self._cards[i]:getBaseZOrder() + self._cards[i]._index
        self._cards[i]._SKCardSprite:setLocalZOrder(zorder + throwCount * 1000)
    end
end

function MyJiSuThrownCards:moveThrow()
    MyJiSuThrownCards.super.moveThrow(self)
    self:hideCardType()
end

function MyJiSuThrownCards:getCardType(dwCardType, throwCount)
    if dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_SINGLE then
        return "单牌"
    elseif dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_COUPLE then
        return "单对"
    elseif dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_THREE then
        return "三条"
    elseif dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_THREE_1 then
        return "三带单"
    elseif dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_THREE_2 then
        return "三带二"
    elseif dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_THREE_COUPLE then
        return "三带对"
    elseif dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_ABT_SINGLE then
        return "顺子"
    elseif dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_ABT_COUPLE then
        return "三连对"
    elseif dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_ABT_THREE then
        return "钢板"
    elseif dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_ABT_THREE_COUPLE then
        return "三连对带二连对"
    elseif dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_BOMB and throwCount == 4 then
        return "四炸"
    elseif dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_BOMB and throwCount == 5 then
        return "五炸"
    elseif dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_ABT_BOMB then
        return "连炸"
    elseif dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_TONGHUASHUN then
        return "同花顺"
    elseif dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_SUPER_BOMB then
        return "超级炸弹"
    elseif dwCardType == SKGameDef.SK_CARD_UNITE_TYPE_4KING then
        return "四大天王"
    end
end

function MyJiSuThrownCards:showCardType(dwCardType, throwCount)
    local node = self._gameController._baseGameScene._gameNode
    if node then
        local panelThrown = node:getChildByName("Panel_Card_thrown"..tostring(self._drawIndex))
        if panelThrown then
            local imgPaiXing = panelThrown:getChildByName("Img_PaiXing")
            local fntPaiXing = imgPaiXing:getChildByName("Fnt_PaiXing")
            local strCardType = self:getCardType(dwCardType, throwCount)
            imgPaiXing:setVisible(true)
            fntPaiXing:setString(strCardType)

            local x = 0
            local cardWidth = self._gameController._baseGameScene:getCardSize().width
            if self:isMiddlePlayer() then       --居中玩家
                -- nothing
            elseif self:isRightPlayer() then    --靠右玩家
                local cardsRealWidth = cardWidth + (self._cardsCount - 1) * SKGameDef.SK_CARD_THROWN_INTERVAL
                local panelWidth = panelThrown:getContentSize().width
                x = panelWidth - cardsRealWidth / 2
                imgPaiXing:setPositionX(x)
            else                                --靠左玩家
                x = (cardWidth + (self._cardsCount - 1) * SKGameDef.SK_CARD_THROWN_INTERVAL) / 2
                imgPaiXing:setPositionX(x)
            end
        end
    end
end

function MyJiSuThrownCards:hideCardType()
    local node = self._gameController._baseGameScene._gameNode
    if node then
        local panelThrown = node:getChildByName("Panel_Card_thrown"..tostring(self._drawIndex))
        if panelThrown then
            local imgPaiXing = panelThrown:getChildByName("Img_PaiXing")
            imgPaiXing:setVisible(false)
        end
    end
end

function MyJiSuThrownCards:sortThrownCards()
    if not self:isCardsFaceShow() then return end

    local tableCards = {}
 
    for i = 1, self._gameController:getChairCardsCount() do
        table.insert(tableCards, i, self._cards[i])
    end

    --local function comps(a, b) return a:getPriIndex() > b:getPriIndex() end
    --table.sort(tableCards, comps)

    local tableCardIDs = {}
    for i = 1, self._gameController:getChairCardsCount() do
        table.insert(tableCardIDs, i, tableCards[i]:getSKID())
    end

    local count = 0
    for i = 1, self._gameController:getChairCardsCount() do
        if count > self._cardsCount then
            self._cards[i]:clearSKID()
        else
            self._cards[i]:setSKID(tableCardIDs[i])
            self._cards[i]:setPosition(self:getThrowCardsPosition(i))
            count = count + 1
        end
    end
end

return MyJiSuThrownCards