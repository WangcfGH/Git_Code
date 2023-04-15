local MyJiSuSetCard = class("MyJiSuSetCard", import("src.app.Game.mSKGame.SKCardBase"))

function MyJiSuSetCard:ctor(nodeCard, cardDelegate, index)
    self._nodeCard = nodeCard
    MyJiSuSetCard.super.ctor(self, 1, cardDelegate, index)
end

function MyJiSuSetCard:init(index) 
    -- 由于单墩重置按钮，牌节点不能放在cardMountLayer下
    local resName               = self:getCardFaceResName(self._SKID)
    self._SKCardSprite          = cc.Sprite:create(resName)
    if self._SKCardSprite then
        self._SKCardSprite:setAnchorPoint(cc.p(0, 0))
        if not self._nodeCard then 
            self._SKCardSprite = nil
            return 
        end

        self._nodeCard:addChild(self._SKCardSprite)
    end

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

    local ppos = cc.p(0,0)
    local cardSize = self._SKCardSprite:getContentSize()
    local realPos = cc.p(ppos.x - cardSize.width /2, ppos.y - cardSize.height / 2)
    self:setPosition(realPos)
end

function MyJiSuSetCard:getCardFaceResName(cardID)
    return "res/Game/GamePic/card/card_thrown.png"
end

return MyJiSuSetCard
