local MyJiSuCardHand = class("MyJiSuCardHand", import("src.app.Game.mMyGame.MyCardHand"))
local MyJiSuGameDef = import("src.app.Game.mMyJiSuGame.MyJiSuGameDef")

function MyJiSuCardHand:selectCard()
    if not self._SKCardSprite then return end

    local position = cc.p(self._SKCardSprite:getPosition())

    --惯蛋注释
    if not self._bSelected then
        self._SKCardSprite:stopActionByTag(MyJiSuGameDef.CardKTagActionY)
        self._SKCardSprite:stopAllActions()
        --y坐标初始都是2
        local ActionY = cc.MoveTo:create(0.1,cc.p(self._pPoint.x, MyJiSuGameDef.SK_CARD_START_POS_Y + self._SKOffsetY))
        ActionY:setTag(MyJiSuGameDef.CardKTagActionY)
        self._SKCardSprite:runAction(ActionY)
        self._pPoint.y = MyJiSuGameDef.SK_CARD_START_POS_Y + self._SKOffsetY
    end

    self._bSelected = true
    
end

function MyJiSuCardHand:unSelectCard()
    if not self._SKCardSprite then return end

    if self._bSelected then        
        local position = cc.p(self._SKCardSprite:getPosition())
        --self._SKCardSprite:setPosition(cc.p(position.x, position.y - self._SKOffsetY))
        self._SKCardSprite:stopActionByTag(MyJiSuGameDef.CardKTagActionY)
        self._SKCardSprite:stopAllActions()
        --y坐标初始都是2
        local ActionY = cc.MoveTo:create(0.1,cc.p(self._pPoint.x, MyJiSuGameDef.SK_CARD_START_POS_Y))
        ActionY:setTag(MyJiSuGameDef.CardKTagActionY)
        self._SKCardSprite:runAction(ActionY)
        self._pPoint.y = MyJiSuGameDef.SK_CARD_START_POS_Y
    end
    self._bSelected = false
end


return MyJiSuCardHand