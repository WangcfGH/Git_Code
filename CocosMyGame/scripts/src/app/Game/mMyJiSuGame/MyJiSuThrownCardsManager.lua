local MyJiSuThrownCardsManager = class("MyJiSuThrownCardsManager", import("src.app.Game.mMyGame.MyThrownCardsManager"))

function MyJiSuThrownCardsManager:ctor(SKThrownCards, gameController)
    self._throwCount = 1 --用于设置出牌时的zorder

    MyJiSuThrownCardsManager.super.ctor(self, SKThrownCards, gameController)
end

function MyJiSuThrownCardsManager:resetThrownCardsManager()
    self._throwCount = 1 --用于设置出牌时的zorder
    MyJiSuThrownCardsManager.super.resetThrownCardsManager(self)
    for i = 1, self._gameController:getTableChairCount() do
        local SKThrownCards = self._SKThrownCards[i]
        if SKThrownCards then
            SKThrownCards:hideCardType()
        end
    end
end

function MyJiSuThrownCardsManager:ope_ThrowCards(drawIndex, cardIDs, cardsCount, dwCardType)
    local SKThrownCards = self._SKThrownCards[drawIndex]
    if SKThrownCards then
        SKThrownCards:ope_ThrowCards(cardIDs, cardsCount, dwCardType, self._throwCount)
        self._throwCount = self._throwCount + 1
    end
end


return MyJiSuThrownCardsManager