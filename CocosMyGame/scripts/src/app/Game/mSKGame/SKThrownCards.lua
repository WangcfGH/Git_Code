
local SKThrownCards = class("SKThrownCards")

local SKCardThrown                  = import("src.app.Game.mSKGame.SKCardThrown")
local SKGameDef                     = import("src.app.Game.mSKGame.SKGameDef")

function SKThrownCards:create(drawIndex, gameController)
    return SKThrownCards.new(drawIndex, gameController)
end

function SKThrownCards:ctor(drawIndex, gameController)
    if not gameController then printError("gameController is nil!!!") return end
    self._gameController        = gameController

    self._drawIndex             = drawIndex
    self._cards                 = {}
    self._cardsCount            = 0

    self:init()
end

function SKThrownCards:init()
    for i = 1, self._gameController:getChairCardsCount() do
        self._cards[i] = SKCardThrown:create(self._drawIndex, self, i)
    end

    self:resetSKThrownCards()
end

function SKThrownCards:resetSKThrownCards()
    if not self._cards then return end

    for i = 1, self._gameController:getChairCardsCount() do
        local card = self._cards[i]
        if card then
            card:resetCard()
        end
    end
end

function SKThrownCards:ope_ThrowCards(cardIDs, cardsCount, dwCardType)
    self:moveThrow()

    self.ThrowCardType = dwCardType
    self:setThrownCardsCount(cardsCount)
    self:setThrownCards(cardIDs)
    self:sortThrownCards()
end

function SKThrownCards:moveThrow()
    self:resetSKThrownCards()
end

function SKThrownCards:sortThrownCards()
    if not self:isCardsFaceShow() then return end

    local tableCards = {}
 
    for i = 1, self._gameController:getChairCardsCount() do
        table.insert(tableCards, i, self._cards[i])
    end

    if self.ThrowCardType ~= nil and (self.ThrowCardType == SKGameDef.SK_CARD_UNITE_TYPE_TONGHUASHUN 
        or self.ThrowCardType == SKGameDef.SK_CARD_UNITE_TYPE_ABT_COUPLE  or self.ThrowCardType == SKGameDef.SK_CARD_UNITE_TYPE_ABT_THREE  
        or self.ThrowCardType == SKGameDef.SK_CARD_UNITE_TYPE_ABT_SINGLE) then        
        for i = 1, self._cardsCount do
            tableCards[i] = self._cards[self._cardsCount-i+1]
        end
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

function SKThrownCards:isCardsFaceShow()
    for i = 1, self._gameController:getChairCardsCount() do
        if self._cards[i] and self._cards[i]:isVisible() then
            return true
        end
    end

    return false
end

function SKThrownCards:getThrowCardsPosition(index)
    local startX, startY = self:getStartPoint()

    if self:isMiddlePlayer() then       --居中
        startX = startX - (self:getCardSize().width + (self._cardsCount - 1) * SKGameDef.SK_CARD_THROWN_INTERVAL)/2
    elseif self:isRightPlayer() then    --右对齐
        startX = startX - self:getCardSize().width - (self._cardsCount - 1) * SKGameDef.SK_CARD_THROWN_INTERVAL
    end
    startX = startX + (index - 1) * SKGameDef.SK_CARD_THROWN_INTERVAL

    return cc.p(startX, startY)
end

function SKThrownCards:getCardSize()
    if self._cards[1] then
        return self._cards[1]:getContentSize()
    end

    return cc.size(0, 0)
end

function SKThrownCards:getStartPoint()
    local node = self._gameController._baseGameScene._gameNode
    if node then
        local thrownPosition = node:getChildByName("Panel_Card_thrown"..tostring(self._drawIndex))
        if thrownPosition then
            local startX, startY = thrownPosition:getPosition()
            if self:isRightPlayer() then
                startX = startX + thrownPosition:getContentSize().width
            end
            return startX, startY
        end
    end
    return 0, 0
end

function SKThrownCards:isMiddlePlayer()
    return self._gameController:isMiddlePlayer(self._drawIndex)
end

function SKThrownCards:isRightPlayer()
    return self._gameController:isRightPlayer(self._drawIndex)
end

function SKThrownCards:getMyDrawIndex()
    return self._gameController:getMyDrawIndex()
end

function SKThrownCards:setThrownCardsCount(cardsCount)
    self._cardsCount = cardsCount
end

function SKThrownCards:setThrownCards(thrownCards)
    for i = 1, self._cardsCount do
        if not self._cards[i] then break end
        if i > self._gameController:getChairCardsCount() then break end

        self._cards[i]:setSKID(thrownCards[i])
        self._cards[i]:setPosition(self:getThrowCardsPosition(i))
    end
end

return SKThrownCards