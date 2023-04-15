
local SKCardBase = class("SKCardBase")

local SKGameDef                 = import("src.app.Game.mSKGame.SKGameDef")
local SKGameUtilsInfoManager    = import("src.app.Game.mSKGame.SKGameUtilsInfoManager")

local SKCalculator              = import("src.app.Game.mSKGame.SKCalculator")

local GamePublicInterface       = import("src.app.Game.mMyGame.GamePublicInterface")

function SKCardBase:isFrame_1()
    if GamePublicInterface and GamePublicInterface:IS_FRAME_1() then
        return true
    else
        return false
    end
end

function SKCardBase:create(drawIndex, cardDelegate, index)
    return SKCardBase.new(drawIndex, cardDelegate, index)
end

function SKCardBase:ctor(drawIndex, cardDelegate, index)
    if not cardDelegate then printError("cardDelegate is nil!!!") return end
    self._cardDelegate          = cardDelegate

    self._SKCardSprite          = nil

    self._drawIndex             = drawIndex

    self._SKID                  = -1    
    self._priIndex              = -1
    self._index                 = index

    self._cardNumSprite         = nil       --点数
    self._cardSmallShapeSprite  = nil       --小的花色
    self._cardBigShapeSprite    = nil       --大的花色

    self:init(index)
end

function SKCardBase:init(index)
    local resName               = self:getCardFaceResName(self._SKID)
    self._SKCardSprite          = cc.Sprite:create(resName)
    if self._SKCardSprite then
        self._SKCardSprite:setAnchorPoint(cc.p(0, 0))

        local node = self._cardDelegate._gameController._baseGameScene._gameNode:getChildByName("Operate_Panel")
        if not node then
            self._SKCardSprite = nil
            return
        end

        --node:addChild(self._SKCardSprite)
        --所有卡牌共用一个父节点，可以大大降低addChild时间，从1.0s降低到0.1~0.2s左右，降低0.8s
        local cardMountLayer = node:getChildByName("cardMountLayer")
        if cardMountLayer == nil then
            cardMountLayer = cc.Layer:create()
            cardMountLayer:setName("cardMountLayer")
            cardMountLayer:setContentSize(node:getContentSize())
            local baseZOrder = self:getBaseZOrder()
            cardMountLayer:setLocalZOrder(self:getBaseZOrder())
            node:addChild(cardMountLayer)
        end
        cardMountLayer:addChild(self._SKCardSprite)

        --在FixedHeight模式下保持牌足够大
        local properScalVal = UIHelper:getProperScaleOnFixedHeight()
        if properScalVal > 1.0 then
            self._SKCardSprite:setScale(properScalVal)
        end

        --index越小越下层
        if index then
            self._SKCardSprite:setLocalZOrder(self:getBaseZOrder() + index)
        end
    end
end

function SKCardBase:getBaseZOrder()
    return 0
end

function SKCardBase:resetCard()
    self:setVisible(false)
    self._SKID = -1
    self._priIndex = -1
end

function SKCardBase:setVisible(visible)
    if visible then
        self:setSKID(self._SKID)
    else
        self:hideAllChildren()
    end
end

function SKCardBase:hideAllChildren()
    if not self._SKCardSprite then return end

    self._SKCardSprite:setVisible(false)

    local cardSpriteChildren = self._SKCardSprite:getChildren()
    for i = 1, self._SKCardSprite:getChildrenCount() do
        local child = cardSpriteChildren[i]
        if child then
            child:setVisible(false)
        end
    end
end

function SKCardBase:setPosition(point)
    if not self._SKCardSprite then return end
    
    self._SKCardSprite:setPosition(point)
end

function SKCardBase:isValidateID(id)
    return SKCalculator:isValidCard(id)
end

function SKCardBase:isHelperCard(cardID)
    if self:isValidateID(cardID) then
        local nFriendCard = self._cardDelegate._gameController._baseGameUtilsInfoManager:getFriendCard()
        if nFriendCard and nFriendCard == cardID then
            return true
        end
    end

    return false
end

function SKCardBase:setSKID(id)
    self:setVisible(false)

    if self:isValidateID(id) then
        self._SKID = id
        self._priIndex = self:getCardPriIndex(id)

        if self._SKCardSprite then
            local resName   = self:getCardFaceResName(id)
            if resName then
                local resSprite = cc.Sprite:create(resName)
                if resSprite then
                    local rect = cc.rect(0, 0, resSprite:getContentSize().width, resSprite:getContentSize().height)
                    local cardFaceFrame = cc.SpriteFrame:create(resName, rect)
                    if cardFaceFrame then
                        self._SKCardSprite:setSpriteFrame(cardFaceFrame)
                        self._SKCardSprite:setVisible(true)
                    end
                end
            end
        end
        
        if self._cardNumSprite then
            local resName   = self:getCardNumResName(id)
            if resName then
                local resSprite = cc.Sprite:create(resName)
                if resSprite then
                    local rect = cc.rect(0, 0, resSprite:getContentSize().width, resSprite:getContentSize().height)
                    local cardNumFrame = cc.SpriteFrame:create(resName, rect)
                    if cardNumFrame then
                        self._cardNumSprite:setSpriteFrame(cardNumFrame)
                        self._cardNumSprite:setVisible(true)
                    end
                end
            end
        end
        
        if self._cardSmallShapeSprite then
            local resName   = self:getCardSmallShapeResName(id)
            if resName then
                local resSprite = cc.Sprite:create(resName)
                if resSprite then
                    local rect = cc.rect(0, 0, resSprite:getContentSize().width, resSprite:getContentSize().height)
                    local cardSmallShapeFrame = cc.SpriteFrame:create(resName, rect)
                    if cardSmallShapeFrame then
                        self._cardSmallShapeSprite:setSpriteFrame(cardSmallShapeFrame)
                        self._cardSmallShapeSprite:setVisible(true)
                    end
                end
            end
        end
        
        if self._cardBigShapeSprite then
            local resName   = self:getCardBigShapeResName(id)
            if resName then
                local resSprite = cc.Sprite:create(resName)
                if resSprite then
                    local rect = cc.rect(0, 0, resSprite:getContentSize().width, resSprite:getContentSize().height)
                    local cardBigShapeFrame = cc.SpriteFrame:create(resName, rect)
                    if cardBigShapeFrame then
                        self._cardBigShapeSprite:setSpriteFrame(cardBigShapeFrame)
                        self._cardBigShapeSprite:setVisible(true)
                    end
                end
            end
        end
    elseif SKGameDef.SK_CARD_BACK_ID == id then
        self._SKID = id
        self._priIndex = SKGameDef.SK_CARD_BACK_ID
        
        --可以用来显示牌背
        if self._SKCardSprite then
            local resName   = self:getCardFaceResName(id)
            local resSprite = cc.Sprite:create(resName)
            if resSprite then
                local rect = cc.rect(0, 0, resSprite:getContentSize().width, resSprite:getContentSize().height)
                local cardFaceFrame = cc.SpriteFrame:create(resName, rect)
                if cardFaceFrame then
                    self._SKCardSprite:setSpriteFrame(cardFaceFrame)
                    self._SKCardSprite:setVisible(true)
                end
            end
        end
    else
        self._SKID = -1
        self._priIndex = -1
    end
end

function SKCardBase:clearSKID()
    self:setSKID(-1)
end

function SKCardBase:getCardColorName(cardID)
    if self:isFrame_1() then
        return self:getCardColorName_1(cardID)
    end
    
    local cardShape = SKCalculator:getCardShape(cardID, 0)
    local cardIndex = SKCalculator:getCardIndex(cardID, 0)
    
    if (0 == cardShape % 2 and SKGameDef.SK_CS_KING ~= cardShape) or (SKGameDef.SK_CS_KING == cardShape and 15 == cardIndex) then
        return "red_"       --方块 红心 大王
    else
        return "black_"
    end
end

function SKCardBase:getCardColorName_1(cardID)
    local cardShape = SKCalculator:getCardShape(cardID, 0)
    local cardIndex = SKCalculator:getCardIndex(cardID, 0)

    if (0 == cardShape % 2 and SKGameDef.SK_CS_KING ~= cardShape) or (SKGameDef.SK_CS_KING == cardShape and 16 == cardIndex) then
        return "red_"       --方块 红心 大王
    else
        return "black_"
    end
end

function SKCardBase:getCardNumName(cardID)
    if self:isFrame_1() then
        return self:getCardNumName_1(cardID)
    end
    
    local cardIndex = SKCalculator:getCardIndex(cardID, 0)
    if 14 == cardIndex or 15 == cardIndex then
        return "14"                                         --大小王都命名成14了
    end
    local num = cardIndex % SKGameDef.SK_LAYOUT_MOD + 1     --"2,3,4,5,6,7,8,9,10,J,Q,K,A"
    return tostring(num)
end

function SKCardBase:getCardNumName_1(cardID)
    local cardIndex = SKCalculator:getCardIndex(cardID, 0)
    if 15 == cardIndex or 16 == cardIndex then
        return "14"                                         --大小王都命名成14了
    end
    local num = (cardIndex + 1) % SKGameDef.SK_LAYOUT_MOD + 1     --"3,4,5,6,7,8,9,10,J,Q,K,A,2"
    return tostring(num)
end

function SKCardBase:getCardShapeName(cardID)
    if self:isFrame_1() then
        return self:getCardShapeName_1(cardID)
    end
    
    local cardShape = SKCalculator:getCardShape(cardID, 0)
    local cardIndex = SKCalculator:getCardIndex(cardID, 0)
    
    if SKGameDef.SK_CS_KING == cardShape then
        return tostring(cardIndex - 9)      --小王5 大王6
    else
        return tostring(4 - cardShape)      --命名顺序反过来了。。
    end
end

function SKCardBase:getCardShapeName_1(cardID)
    local cardShape = SKCalculator:getCardShape(cardID, 0)
    local cardIndex = SKCalculator:getCardIndex(cardID, 0)

    if SKGameDef.SK_CS_KING == cardShape then
        return tostring(cardIndex - 10)      --小王5 大王6
    else
        return tostring(4 - cardShape)      --命名顺序反过来了。。
    end
end

function SKCardBase:getCardFaceResName(cardID)
    return ""
end

function SKCardBase:getCardNumResName(cardID)
    return "res/Game/GamePic/Num/num_"..self:getCardColorName(cardID)..self:getCardNumName(cardID)..".png"
end

function SKCardBase:isJoker(cardID)
    local cardIndex = SKCalculator:getCardIndex(cardID, 0)
    if 13 < cardIndex then
        return true
    end

    return false
end

function SKCardBase:getCardSmallShapeResName(cardID)
    if self:isHelperCard(cardID) then
        return "res/Game/GamePic/Num/colour_lagt_s.png"
    end

    if self:isJoker(cardID) then
        return nil             --王牌不用小的花色标记
    end
    
    return "res/Game/GamePic/Num/colour_s_"..self:getCardShapeName(cardID)..".png"
end

function SKCardBase:getCardBigShapeResName(cardID)
    if self:isHelperCard(cardID) then
        return "res/Game/GamePic/Num/colour_lagt.png"
    end

    return "res/Game/GamePic/Num/colour_"..self:getCardShapeName(cardID)..".png"
end

function SKCardBase:getSKID()
    return self._SKID
end

function SKCardBase:getPriIndex()
    return self._priIndex
end

function SKCardBase:getCardPriIndex(cardID)
    local rank      = self._cardDelegate._gameController._baseGameUtilsInfoManager:getCurrentRank()
    local cardPri   = SKCalculator:getCardPri(cardID, rank, 0)

    return cardPri
end

function SKCardBase:isVisible()
    return self._SKCardSprite and self._SKCardSprite:isVisible()
end

function SKCardBase:getContentSize()
    if self._SKCardSprite then
        return self._SKCardSprite:getContentSize()
    end
    return cc.size(0, 0)
end

--惯蛋添加

function SKCardBase:setPositionNoAciton(point)
    if not self._SKCardSprite then return end
    
    self._SKCardSprite:stopAllActions()
    self._pPoint = point
    self._SKCardSprite:setPosition(point)
end

return SKCardBase
