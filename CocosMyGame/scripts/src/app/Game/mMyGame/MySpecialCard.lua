
local SKCardShown = import("src.app.Game.mSKGame.SKCardShown")
local MySpecialCard = class("MySpecialCard", SKCardShown)

function MySpecialCard:ctor(drawIndex, cardDelegate, index)
    MySpecialCard.super.ctor(self, drawIndex, cardDelegate, index)
end

function MySpecialCard:init(index)
    local resName               = self:getCardFaceResName(self._SKID)
    self._SKCardSprite          = cc.Sprite:create(resName)
    if self._SKCardSprite then
        self._SKCardSprite:setAnchorPoint(cc.p(0, 0))

        local node = self._cardDelegate._specialTitle
        if not node then
            self._SKCardSprite = nil
            return
        end

        node:addChild(self._SKCardSprite)
    end

    if not self._SKCardSprite then return end

    local resName               = "res/Game/GamePic/Num/num_black_1.png"
    self._cardNumSprite         = cc.Sprite:create(resName)
    if self._cardNumSprite then
        self._SKCardSprite:addChild(self._cardNumSprite)
        self._cardNumSprite:setAnchorPoint(cc.p(0.5, 1))
        self._cardNumSprite:setPosition(cc.p(15, 41))
        self._cardNumSprite:setScale(0.6)
    end

    resName                     = "res/Game/GamePic/Num/colour_s_1.png"
    self._cardSmallShapeSprite  = cc.Sprite:create(resName)
    if self._cardSmallShapeSprite then
        self._SKCardSprite:addChild(self._cardSmallShapeSprite)
        self._cardSmallShapeSprite:setAnchorPoint(cc.p(0.5, 1))
        self._cardSmallShapeSprite:setPosition(cc.p(15, 19))
        self._cardSmallShapeSprite:setScale(0.6)
    end
end

function MySpecialCard:isHelperCard(cardID)
    return false
end

return MySpecialCard