
local SKShownCards = import("src.app.Game.mSKGame.SKShownCards")
local NetlessShownCards = class("SKShownCards", SKShownCards)

local SKCardHand                = import("src.app.Game.mSKGame.SKCardHand")

function NetlessShownCards:init()
    for i = 1, self._gameController:getChairCardsCount() do
        self._cards[i] = SKCardHand:create(self._drawIndex, self, i)
        self._cards[i]._SKCardSprite:setScale(0.65)
    end
    
    self:setVisible(false)
end

function NetlessShownCards:getOtherHandCardsPosition(index)
    return cc.p(-1000, -1000)
end

function NetlessShownCards:getRightCard()
    for i = self._cardsCount, 1, -1 do
        local card = self._cards[i]
        if card then
            return card
        end
    end
end

function NetlessShownCards:ope_ThrowCards(cardIDs, cardsCount)
    self:removeHandCards(cardIDs, cardsCount)

    self:sortHandCards()
    self:updateHandCards()
end


function NetlessShownCards:sortHandCards()
    local CardID, count2 = self:getHandCardIDs()

    self:RUL_SortCard(CardID)
 
    local count = 0
    for i = 1, self._gameController:getChairCardsCount() do
        self._cards[i]:unSelectCard()   --惯蛋添加
        if count > self._cardsCount then
            self._cards[i]:clearSKID()
        else
            self._cards[i]:setSKID(CardID[i])
            count = count + 1
        end
    end
end

function NetlessShownCards:setHandCardsWin(handCards)
    for i = 1, self._cardsCount do
        if not self._cards[i] or not handCards[i] then break end
        if i > self._gameController:getChairCardsCount() then break end

        self._cards[i]:setSKID(handCards[i])
        self._cards[i]:setPositionNoAciton(self:getGameWinHandCardsPosition(i))
    end
end

function NetlessShownCards:getGameWinHandCardsPosition(index)
    local startX, startY = self:getStartPoint()

    if self:isMiddlePlayer() then       --居中
        --startX = startX - (self:getCardSize().width + (self._cardsCount - 1) * SKGameDef.SK_CARD_THROWN_INTERVAL)/2
        if SKGameDef.SK_CARD_SHOWN_PER_LINE > self._cardsCount then
            startX = startX - (self:getCardSize().width + (self._cardsCount - 1) * SKGameDef.SK_CARD_THROWN_INTERVAL)/2
        else
        startX = startX - (self:getCardSize().width + (SKGameDef.SK_CARD_SHOWN_PER_LINE - 1) * SKGameDef.SK_CARD_THROWN_INTERVAL)/2
        end
    elseif self:isRightPlayer() then    --右对齐
        if SKGameDef.SK_CARD_SHOWN_PER_LINE > self._cardsCount then
            startX = startX - self:getCardSize().width - SKGameDef.SK_CARD_THROWN_INTERVAL * (self._cardsCount - 1)
        else
            startX = startX - self:getCardSize().width - SKGameDef.SK_CARD_THROWN_INTERVAL * (SKGameDef.SK_CARD_SHOWN_PER_LINE - 1)
        end
        --startX = startX - self:getCardSize().width - (self._cardsCount - 1) * SKGameDef.SK_CARD_THROWN_INTERVAL
    end
    startX = startX + ((index - 1) % SKGameDef.SK_CARD_SHOWN_PER_LINE)  * SKGameDef.SK_CARD_THROWN_INTERVAL

    startY = startY - SKGameDef.SK_CARD_SHOWN_LINE_INTERVAL * math.floor((index - 1) / SKGameDef.SK_CARD_SHOWN_PER_LINE)

    return cc.p(startX, startY)
end


return NetlessShownCards