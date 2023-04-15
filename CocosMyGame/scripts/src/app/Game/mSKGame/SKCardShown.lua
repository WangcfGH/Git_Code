
local SKCardBase = import("src.app.Game.mSKGame.SKCardBase")
local SKCardShown = class("SKCardShown", SKCardBase)

local SKGameDef                 = import("src.app.Game.mSKGame.SKGameDef")

function SKCardShown:ctor(drawIndex, cardDelegate, index)
    SKCardShown.super.ctor(self, drawIndex, cardDelegate, index)
end

function SKCardShown:init(index)
    --[[local resName               = self:getCardFaceResName(self._SKID)
    self._SKCardSprite          = cc.Sprite:create(resName)
    if self._SKCardSprite then
        self._SKCardSprite:setAnchorPoint(cc.p(0, 0))

        local panel = self._cardDelegate._panelBackGroud
        if not panel then
            self._SKCardSprite = nil
            return
        end

        panel:addChild(self._SKCardSprite)

        --index越小越下层
        if index then
            self._SKCardSprite:setLocalZOrder(self:getBaseZOrder() + index)
        end
    end--]]
    SKCardShown.super.init(self, index)

    if not self._SKCardSprite then return end

    local resName               = "res/Game/GamePic/Num/num_black_1.png"
    self._cardNumSprite         = cc.Sprite:create(resName)
    if self._cardNumSprite then
        self._SKCardSprite:addChild(self._cardNumSprite)
        self._cardNumSprite:setAnchorPoint(cc.p(0.5, 1))
        self._cardNumSprite:setPosition(cc.p(21, 118.60))
        self._cardNumSprite:setScale(0.65)
    end

    resName                     = "res/Game/GamePic/Num/colour_s_1.png"
    self._cardSmallShapeSprite  = cc.Sprite:create(resName)
    if self._cardSmallShapeSprite then
        self._SKCardSprite:addChild(self._cardSmallShapeSprite)
        self._cardSmallShapeSprite:setAnchorPoint(cc.p(0.5, 0.5))
        self._cardSmallShapeSprite:setPosition(cc.p(21, 79.61))
        self._cardSmallShapeSprite:setScale(0.65)
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

function SKCardShown:getBaseZOrder()
    return SKGameDef.SK_ZORDER_CARD_SHOWN
end

function SKCardShown:dealCard()

end

function SKCardShown:resetCardPos()

end

function SKCardShown:getCardFaceResName(cardID)
    --return "res/Game/GamePic/card/card_shown.png"
    return "res/Game/GamePic/card/card_thrown.png"
end

function SKCardShown:getCardNumResName(cardID)
    --[[if self:isJoker(cardID) then
        return "res/Game/GamePic/Num/colour_s_"..self:getCardShapeName(cardID)..".png"
    end]]

    return "res/Game/GamePic/Num/num_"..self:getCardColorName(cardID)..self:getCardNumName(cardID)..".png"
end

return SKCardShown