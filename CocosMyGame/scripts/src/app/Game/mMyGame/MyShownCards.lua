local SKShownCards = import("src.app.Game.mSKGame.SKShownCards")
local MyShownCards = class("MyShownCards", SKShownCards)

local MyCardShown               = import("src.app.Game.mMyGame.MyCardShown")
function MyShownCards:init()
    for i = 1, self._gameController:getChairCardsCount() do
        self._cards[i] = MyCardShown:create(self._drawIndex, self, i)
    end

    self:setVisible(false)
end

return MyShownCards