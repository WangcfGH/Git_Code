local SKCardThrown = import("src.app.Game.mSKGame.SKCardThrown")
local MyCardThrown = class("MyCardThrown", SKCardThrown)
local MyCalculator = import("src.app.Game.mMyGame.MyCalculator")

function MyCardThrown:getCardSmallShapeResName(cardID)
    if self:isHelperCard(cardID) then
        return "res/Game/GamePic/Num/colour_lagt_s.png"
    end

    if self:isJoker(cardID) then
        return nil             --王牌不用小的花色标记
    end
    if self:isRealJoker(cardID) then
        return "res/Game/GamePic/Num/color_joker.png"
    end

    return "res/Game/GamePic/Num/colour_s_"..self:getCardShapeName(cardID)..".png"
end

function MyCardThrown:isRealJoker(cardID)
    return MyCalculator:isJoker(cardID)
end

function MyCardThrown:getBaseZOrder()
    if self._drawIndex == 5 then 
        return SKGameDef.SK_ZORDER_CARD_THROWN - SKGameDef.SK_CHAIR_CARDS
    end

    -- 为了使扔出的牌层级比 玩家手牌小
    return SKGameDef.SK_ZORDER_CARD_HAND - 100

end

return MyCardThrown