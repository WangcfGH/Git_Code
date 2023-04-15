
local SKCardBase = import("src.app.Game.mSKGame.SKCardBase")
local SKCardHand = class("SKCardHand", SKCardBase)

local SKGameDef                 = import("src.app.Game.mSKGame.SKGameDef")

function SKCardHand:ctor(drawIndex, cardDelegate, index)
    self._SKMask                = nil
    self._bMask                 = false
    self._SKOffsetY             = 30
    self._bEnableTouch          = false
    self._bSelected             = false

    --惯蛋添加
    self._pPoint                = cc.p(0,0)
    self._ArrageNo              = 0
    self._bArraged              = false
    self._bBomb                 = false
    self._SKArrageMask1         = nil
    self._SKArrageMask2         = nil

    SKCardHand.super.ctor(self, drawIndex, cardDelegate, index)
end

function SKCardHand:init(index)
    SKCardHand.super.init(self, index)

    if not self._SKCardSprite then return end

    local resName               = "res/Game/GamePic/Num/num_black_1.png"
    self._cardNumSprite         = cc.Sprite:create(resName)
    if self._cardNumSprite then
        self._SKCardSprite:addChild(self._cardNumSprite)
        self._cardNumSprite:setAnchorPoint(cc.p(0.5, 1))
        self._cardNumSprite:setPosition(cc.p(31.00, 182.00))
    end

    resName                     = "res/Game/GamePic/Num/colour_s_1.png"
    self._cardSmallShapeSprite  = cc.Sprite:create(resName)
    if self._cardSmallShapeSprite then
        self._SKCardSprite:addChild(self._cardSmallShapeSprite)
        self._cardSmallShapeSprite:setPosition(cc.p(31.00, 120.00))
    end

    resName                     = "res/Game/GamePic/Num/colour_1.png"
    self._cardBigShapeSprite    = cc.Sprite:create(resName)
    if self._cardBigShapeSprite then
        self._SKCardSprite:addChild(self._cardBigShapeSprite)
        self._cardBigShapeSprite:setAnchorPoint(cc.p(1, 0))
        self._cardBigShapeSprite:setPosition(cc.p(128.00, 20.00))
    end

    resName                     = "res/Game/GamePic/card/card_hand_shadow.png"
    self._SKMask                = cc.Sprite:create(resName)
    if self._SKMask then
        self._SKCardSprite:addChild(self._SKMask)
        self._SKMask:setPosition(cc.p(72.5, 97.5))
    end

    --惯蛋添加
    resName                     = "res/Game/GamePic/card/card_hand_shadow2.png"
    self._SKArrageMask1                = cc.Sprite:create(resName)
    if self._SKArrageMask1 then
        self._SKCardSprite:addChild(self._SKArrageMask1)
        self._SKArrageMask1:setPosition(cc.p(72.5, 97.5))
    end
    resName                     = "res/Game/GamePic/card/card_hand_shadow3.png"
    self._SKArrageMask2                = cc.Sprite:create(resName)
    if self._SKArrageMask2 then
        self._SKCardSprite:addChild(self._SKArrageMask2)
        self._SKArrageMask2:setPosition(cc.p(72.5, 97.5))
    end
end

function SKCardHand:getBaseZOrder()
    return SKGameDef.SK_ZORDER_CARD_HAND
end

function SKCardHand:containsTouchLocation(x, y)
    if not self:isVisible() then return false end
    if not self._bEnableTouch then return false end
    
    --[[local position = cc.p(self._SKCardSprite:getPosition())
    local s = self._SKCardSprite:getContentSize()
    local touchRect = cc.rect(position.x, position.y, s.width, s.height) --AnchorPoint 0,0
    local b = cc.rectContainsPoint(touchRect, cc.p(x, y))

    return b]]--

    --FixedHeight模式下，牌被放大，需要使用getBoundingBox()判定选中
    local touchObj = self._SKCardSprite
    local touchPoint = cc.p(x, y)
    local isObjTouched = cc.rectContainsPoint(touchObj:getBoundingBox(), touchPoint) 
    
    return isObjTouched
end

function SKCardHand:initSelState()
    self._bSelected = false
end

function SKCardHand:resetCardPos()
    self._cardDelegate:resetOneCardPos(self._index)
    self._bSelected = false
end

function SKCardHand:selectCard()
    if not self._SKCardSprite then return end

    local position = cc.p(self._SKCardSprite:getPosition())
    --self._SKCardSprite:setPosition(cc.p(position.x, position.y + self._SKOffsetY))    --惯蛋注释

    --self._SKCardSprite:setPosition(cc.p(self._pPoint.x, position.y + self._SKOffsetY))
    --self._pPoint.y = 2 + self._SKOffsetY
    --惯蛋注释
    if not self._bSelected then
        self._SKCardSprite:stopActionByTag(SKGameDef.CardKTagActionY)
        self._SKCardSprite:stopAllActions()
        --y坐标初始都是2
        local ActionY = cc.MoveTo:create(0.1,cc.p(self._pPoint.x, SKGameDef.SK_CARD_START_POS_Y + self._SKOffsetY))
        ActionY:setTag(SKGameDef.CardKTagActionY)
        self._SKCardSprite:runAction(ActionY)
        self._pPoint.y = SKGameDef.SK_CARD_START_POS_Y + self._SKOffsetY
    end

    self._bSelected = true
    
end

function SKCardHand:unSelectCard()
    if not self._SKCardSprite then return end

    --self._cardDelegate:resetOneCardPos(self._index)   --惯蛋实现散牌注释

    --local position = cc.p(self._SKCardSprite:getPosition())
    --self._SKCardSprite:setPosition(cc.p(position.x, position.y - self._SKOffsetY))

    if self._bSelected then        
        local position = cc.p(self._SKCardSprite:getPosition())
        --self._SKCardSprite:setPosition(cc.p(position.x, position.y - self._SKOffsetY))
        self._SKCardSprite:stopActionByTag(SKGameDef.CardKTagActionY)
        self._SKCardSprite:stopAllActions()
        --y坐标初始都是2
        local ActionY = cc.MoveTo:create(0.1,cc.p(self._pPoint.x, SKGameDef.SK_CARD_START_POS_Y))
        ActionY:setTag(SKGameDef.CardKTagActionY)
        self._SKCardSprite:runAction(ActionY)
        self._pPoint.y = SKGameDef.SK_CARD_START_POS_Y
    end
    self._bSelected = false
end

function SKCardHand:isSelectCard()
    return self._bSelected
end

function SKCardHand:resetCard()
    self:setEnableTouch(false)
    self:setMask(false)
    self._bSelected = false
    self:resetCardPos()
   
    --惯蛋添加
    self._ArrageNo              = 0
    self._bArraged              = false
    self._bBomb                 = false
    --惯蛋添加end
    SKCardHand.super.resetCard(self)
end

function SKCardHand:setSKID(id)
    SKCardHand.super.setSKID(self, id)

    self:setMask(self._bMask)
end

function SKCardHand:setMask(bMask)
    self._bMask = bMask
    if self._SKMask then
        self._SKMask:setVisible(bMask)
    end
end

function SKCardHand:isMask()
    return self._bMask
end

function SKCardHand:dealCard()
    if not self._SKCardSprite then return end

    if not self:isValidateID(self._SKID) then return end

    self:setVisible(true)
end

function SKCardHand:setEnableTouch(enableTouch)
    self._bEnableTouch = enableTouch
end

function SKCardHand:isEnableTouch()
    return self._bEnableTouch
end

function SKCardHand:getCardFaceResName(cardID)
    return "res/Game/GamePic/card/card_hand.png"
end

--惯蛋添加
function SKCardHand:setPosition(point)
    if not self._SKCardSprite then return end
    
    self._pPoint = point

    --self._SKCardSprite:setPosition(point)
    self._SKCardSprite:stopAllActions()
    local ActionMove = cc.MoveTo:create(0.1,point)
    self._SKCardSprite:runAction(ActionMove)
end

function SKCardHand:MaskCardForArrage()
    if not self._SKArrageMask1 or not self._SKArrageMask2 then       
        return
    end
    self._SKArrageMask1:setVisible(false)
    self._SKArrageMask2:setVisible(false)
    if self._ArrageNo > 0 then
        if self._ArrageNo % 2 == 1 then
            self._SKArrageMask1:setVisible(true)
        else
            self._SKArrageMask2:setVisible(true)
        end
    end
end

function SKCardHand:setCardZOrder(order)
    if self._SKCardSprite then
        local baseZOrder = self:getBaseZOrder()    
        self._SKCardSprite:setLocalZOrder(baseZOrder + order)
    end
end


return SKCardHand
