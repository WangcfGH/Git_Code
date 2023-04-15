local SKThrownCards = import("src.app.Game.mSKGame.SKThrownCards")
local MyThrownCards = class("MyThrownCards", SKThrownCards)
local MyCardThrown  = import("src.app.Game.mMyGame.MyCardThrown")

function MyThrownCards:init()
    for i = 1, self._gameController:getChairCardsCount() do
        self._cards[i] = MyCardThrown:create(self._drawIndex, self, i)
    end

    self:resetSKThrownCards()
end

return MyThrownCards

