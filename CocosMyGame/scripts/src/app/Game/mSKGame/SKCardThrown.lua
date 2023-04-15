
local SKCardBase = import("src.app.Game.mSKGame.SKCardBase")
local SKCardThrown = class("SKCardThrown", SKCardBase)

local SKGameDef                 = import("src.app.Game.mSKGame.SKGameDef")

function SKCardThrown:ctor(drawIndex, cardDelegate, index)
    SKCardThrown.super.ctor(self, drawIndex, cardDelegate, index)
end

function SKCardThrown:init(index)
    SKCardThrown.super.init(self, index)

    if not self._SKCardSprite then return end
    local resName               = "res/Game/GamePic/Num/num_black_1.png"
    self._cardNumSprite         = cc.Sprite:create(resName)
    if self._cardNumSprite then
        self._SKCardSprite:addChild(self._cardNumSprite)
        self._cardNumSprite:setAnchorPoint(cc.p(0.5, 1))
        self._cardNumSprite:setPosition(cc.p(21, 118.60))
        self._cardNumSprite:setScale(0.8)
    end

    resName                     = "res/Game/GamePic/Num/colour_s_1.png"
    self._cardSmallShapeSprite  = cc.Sprite:create(resName)
    if self._cardSmallShapeSprite then
        self._SKCardSprite:addChild(self._cardSmallShapeSprite)
        self._cardSmallShapeSprite:setAnchorPoint(cc.p(0.5, 0.5))
        self._cardSmallShapeSprite:setPosition(cc.p(21, 70))
        self._cardSmallShapeSprite:setScale(0.8)
    end

    resName                     = "res/Game/GamePic/Num/colour_1.png"
    self._cardBigShapeSprite    = cc.Sprite:create(resName)
    if self._cardBigShapeSprite then
        self._SKCardSprite:addChild(self._cardBigShapeSprite)
        self._cardBigShapeSprite:setAnchorPoint(cc.p(1, 0))
        self._cardBigShapeSprite:setPosition(cc.p(83.00, 15.00))
        self._cardBigShapeSprite:setScale(0.7)
    end
end

function SKCardThrown:getBaseZOrder()
    if self._drawIndex == 5 then 
        return SKGameDef.SK_ZORDER_CARD_THROWN - SKGameDef.SK_CHAIR_CARDS
    end
    return SKGameDef.SK_ZORDER_CARD_THROWN
end

function SKCardThrown:getCardFaceResName(cardID)
    return "res/Game/GamePic/card/card_thrown.png"
end

return SKCardThrown