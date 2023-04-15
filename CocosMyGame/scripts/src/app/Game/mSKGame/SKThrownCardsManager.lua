
local SKThrownCardsManager = class("SKThrownCardsManager")

function SKThrownCardsManager:create(SKThrownCards, gameController)
    return SKThrownCardsManager.new(SKThrownCards, gameController)
end

function SKThrownCardsManager:ctor(SKThrownCards, gameController)
    if not gameController then printError("gameController is nil!!!") return end
    self._gameController        = gameController

    self._SKThrownCards          = SKThrownCards

    self:init()
end

function SKThrownCardsManager:init()
    if not self._SKThrownCards then return end

    self:resetThrownCardsManager()
end

function SKThrownCardsManager:resetThrownCardsManager()
    if not self._SKThrownCards then return end

    for i = 1, self._gameController:getTableChairCount() do
        local SKThrownCards = self._SKThrownCards[i]
        if SKThrownCards then
            SKThrownCards:resetSKThrownCards()
        end

        local playerManager = self._gameController._baseGameScene:getPlayerManager()
        if playerManager then
            playerManager:showPass(i, false)
        end
    end
end

function SKThrownCardsManager:ope_ThrowCards(drawIndex, cardIDs, cardsCount, dwCardType)
    local SKThrownCards = self._SKThrownCards[drawIndex]
    if SKThrownCards then
        SKThrownCards:ope_ThrowCards(cardIDs, cardsCount, dwCardType)
    end
end

function SKThrownCardsManager:moveAllThrow()
    if not self._SKThrownCards then return end
    
    local playerManager = self._gameController._baseGameScene:getPlayerManager()
    for i = 1, self._gameController:getTableChairCount() do
        local SKThrownCards = self._SKThrownCards[i]
        if SKThrownCards then
            SKThrownCards:moveThrow()
        end

        if playerManager then
            playerManager:showPass(i, false)
        end
    end
end

function SKThrownCardsManager:moveThrow(drawIndex)
    local SKThrownCards = self._SKThrownCards[drawIndex]
    if SKThrownCards then
        SKThrownCards:moveThrow()
    end

    local playerManager = self._gameController._baseGameScene:getPlayerManager()
    if playerManager then
        playerManager:showPass(drawIndex, false)
    end
end

function SKThrownCardsManager:showPassTip(drawIndex)
    local playerManager = self._gameController._baseGameScene:getPlayerManager()
    if playerManager then
        playerManager:showPass(drawIndex, true)
    end
end

function SKThrownCardsManager:hidePassTip(drawIndex)
    local playerManager = self._gameController._baseGameScene:getPlayerManager()
    if playerManager then
        playerManager:showPass(drawIndex, false)
    end
end

return SKThrownCardsManager