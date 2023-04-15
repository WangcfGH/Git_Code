local SKThrownCardsManager = import("src.app.Game.mSKGame.SKThrownCardsManager")
local MyThrownCardsManager = class("MyThrownCardsManager", SKThrownCardsManager)

-- 横竖牌切换的时候，需要调整player1玩家的出牌区域
function MyThrownCardsManager:sortThrownCards(myDrawIndex)
    local SKThrownCards = self._SKThrownCards[myDrawIndex]
    if SKThrownCards then
        SKThrownCards:sortThrownCards()
    end
end



return MyThrownCardsManager