local SKCardShown = import("src.app.Game.mSKGame.SKCardShown")
local MyCardShown = class("MyCardShown", SKCardShown)
local MyCalculator              = import("src.app.Game.mMyGame.MyCalculator")

function MyCardShown:getCardSmallShapeResName(cardID)
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

function MyCardShown:isRealJoker(cardID)
    return MyCalculator:isJoker(cardID)
end

return MyCardShown