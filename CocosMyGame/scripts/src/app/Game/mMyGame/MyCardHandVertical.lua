--/*************** MyCardHand **************************/
--  继承自 MyCardHand, 竖向单张手牌类
local MyCardHand = import("src.app.Game.mMyGame.MyCardHand")
local MyCardHandVertical = class("MyCardHandVertical", MyCardHand)
local SKGameDef                 = import("src.app.Game.mSKGame.SKGameDef")

--[[  
--/*139x139像素牌的坐标*/
local g_smallShapePos = cc.p(50, 117)
local g_cardShadowPos = cc.p(69.5,69.5) 
local g_friendShapePos = cc.p(22.00, 70.00)
local g_cardNumSprite = cc.p(22.00, 133.00)
local g_cardBigShapeSprite = cc.p(120.00, 23.00)
]]--

--
--/*120x120像素牌的坐标*/
local g_smallShapePos = cc.p(50, 95)
local g_cardShadowPos = cc.p(60,60) 
local g_friendShapePos = cc.p(22.00, 70.00)
local g_cardNumSprite = cc.p(22.00, 114.00)
local g_cardBigShapeSprite = cc.p(110.00, 10.00)

function MyCardHandVertical:init(index)
    MyCardHandVertical.super.init(self, index)
    self._smallShapePos = g_smallShapePos             -- 小花色图标 位置
    self._cardShadowPos = g_cardShadowPos             -- 阴影部分位置
    self._friendShapePos = g_friendShapePos          -- 对家手牌显示的时候 小花色图标位置

    if not self._SKCardSprite then return end
    -- 数字图标 2 - 10 J Q K A
    local resName               = "res/Game/GamePic/Num/num_black_1.png"
    self._cardNumSprite         = cc.Sprite:create(resName)
    if self._cardNumSprite then
        self._SKCardSprite:addChild(self._cardNumSprite)
        self._cardNumSprite:setAnchorPoint(cc.p(0.5, 1))
        self._cardNumSprite:setPosition(g_cardNumSprite)
        self._cardNumSprite:setScale(0.95)
    end

    -- 花色图标 黑、红、梅、方 小图标
    resName                     = "res/Game/GamePic/Num/colour_s_1.png"
    self._cardSmallShapeSprite  = cc.Sprite:create(resName)
    if self._cardSmallShapeSprite then
        self._SKCardSprite:addChild(self._cardSmallShapeSprite)
        self._cardSmallShapeSprite:setPosition( self._smallShapePos )
        --self._cardSmallShapeSprite:setScale(0.9)
    end

    -- 花色图标 黑、红、梅、方 大图标
    resName                     = "res/Game/GamePic/Num/colour_1.png"
    self._cardBigShapeSprite    = cc.Sprite:create(resName)
    if self._cardBigShapeSprite then
        self._SKCardSprite:addChild(self._cardBigShapeSprite)
        self._cardBigShapeSprite:setAnchorPoint(cc.p(1, 0))
        self._cardBigShapeSprite:setPosition(g_cardBigShapeSprite)
        self._cardBigShapeSprite:setScale(0.9)
    end

    resName                     = "res/Game/GamePic/card/vertical_card_hand_shadow.png"
    self._SKMask                = cc.Sprite:create(resName)
    if self._SKMask then
        self._SKCardSprite:addChild(self._SKMask)
        self._SKMask:setPosition(self._cardShadowPos)
    end

    --惯蛋添加
    resName                     = "res/Game/GamePic/card/vertical_card_hand_shadow2.png"
    self._SKArrageMask1                = cc.Sprite:create(resName)
    if self._SKArrageMask1 then
        self._SKCardSprite:addChild(self._SKArrageMask1)
        self._SKArrageMask1:setPosition(self._cardShadowPos)
    end
    resName                     = "res/Game/GamePic/card/vertical_card_hand_shadow3.png"
    self._SKArrageMask2                = cc.Sprite:create(resName)
    if self._SKArrageMask2 then
        self._SKCardSprite:addChild(self._SKArrageMask2)
        self._SKArrageMask2:setPosition(self._cardShadowPos)
    end
end

function MyCardHandVertical:selectCard()
    if not self._SKCardSprite then return end

    self:setMask(true)
    self._bSelected = true
end

function MyCardHandVertical:unSelectCard()
    if not self._SKCardSprite then return end

    self:setMask(false)
    self._bSelected = false
end

function  MyCardHandVertical:setHandCardsSmallShapePosition(isFriendCards)
    -- 小花色图标位置调整
    if self._cardSmallShapeSprite then
        if isFriendCards == true then
            self._cardSmallShapeSprite:setPosition(self._friendShapePos)
        else
            self._cardSmallShapeSprite:setPosition( self._smallShapePos )
        end
    end
end

function MyCardHandVertical:getCardFaceResName(cardID)
    return "res/Game/GamePic/card/vertical_card_hand.png"
end

return MyCardHandVertical
