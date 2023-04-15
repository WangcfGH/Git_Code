local SKCardHand   = import("src.app.Game.mSKGame.SKCardHand")
local MyCardHand   = class("MyCardHand", SKCardHand)
local MyCalculator = import("src.app.Game.mMyGame.MyCalculator")

function MyCardHand:getCardSmallShapeResName(cardID)
    if self:isHelperCard(cardID) then
        return "res/Game/GamePic/Num/colour_lagt_s.png"
    end

    if self:isJoker(cardID) then
        return nil           --王牌不用小的花色标记
    end
    if self:isRealJoker(cardID) then
        return "res/Game/GamePic/Num/color_joker.png"
    end
    return "res/Game/GamePic/Num/colour_s_"..self:getCardShapeName(cardID)..".png"
end

function MyCardHand:isRealJoker(cardID)
    local GameUtilsImfoManager = self._cardDelegate._gameController._baseGameUtilsInfoManager
    if GameUtilsImfoManager then
        local SKGameDef = import("src.app.Game.mSKGame.SKGameDef")
        if MyCalculator:getCardIndex(cardID, 0) == GameUtilsImfoManager:getCurrentRank()
            and MyCalculator:getCardShape(cardID,0) == SKGameDef.SK_CS_HEART then
            return true
        end
    end
    return false
    -- return MyCalculator:isJoker(cardID)
end

function MyCardHand:getBaseZOrder()
    return MyGameDef.MY_ZORDER_CARD_HAND
end

function MyCardHand:containsTouchLocation(x, y)
    if self._cardDelegate._gameController._baseGameScene._ExpressionOpened then
        local nodeExpression = self._cardDelegate._gameController._baseGameScene._MyNodeExpression
        if nodeExpression then
            local expressionBgImg = nodeExpression:getChildByName("Image_bg")
            if expressionBgImg then
                local isNodeExpressionTouched = false
                local offsetWidth = 0
                local framesize = cc.Director:getInstance():getOpenGLView():getFrameSize()
                local ratio = framesize.width / framesize.height
                if ratio >= 2 then
                    offsetWidth = display.size.width * (80 / 2) / 1280
                end
                
                local tPoint = cc.p(x, y)
                local expressionBgImgRec = expressionBgImg:getBoundingBox()
                local worldPointBgImg = nodeExpression:convertToWorldSpace(cc.p(expressionBgImgRec.x, expressionBgImgRec.y))
                local minX = worldPointBgImg.x - offsetWidth
                local maxX = worldPointBgImg.x + expressionBgImgRec.width - offsetWidth
                local minY = worldPointBgImg.y
                local maxY = worldPointBgImg.y + expressionBgImgRec.height
                if minX < x and x < maxX and minY < y and y < maxY then
                    isNodeExpressionTouched = true                    
                end
                if isNodeExpressionTouched then return false end
            end
        end
    end    

    return MyCardHand.super.containsTouchLocation(self, x, y)
end

return MyCardHand