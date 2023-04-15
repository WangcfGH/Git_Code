local MyJiSuGamePlayer = class("MyJiSuGamePlayer", import("src.app.Game.mMyGame.MyGamePlayer.MyGamePlayer"))

--不显示牌张数
function MyJiSuGamePlayer:setCardsCount(cardsCount, bSound)
    self._playerCards:setVisible(false)
end

function MyJiSuGamePlayer:showBomeSilverValue(value)
    if self._playerSilverValue then
        self._playerSilverValue:getParent():setVisible(true)
        self._playerSilverValue:setVisible(true)
        local Value_SilverAdd = self._playerSilverValue:getChildByName("Value_SilverAdd")
        local Value_SilverMinus = self._playerSilverValue:getChildByName("Value_SilverMinus")
        Value_SilverMinus:setVisible(false)
        Value_SilverAdd:setVisible(false)

        local csbPath = "res/GameCocosStudio/csb/Node_SilverValue.csb"
        local action = cc.CSLoader:createTimeline(csbPath)
        if value >= 0 then
            Value_SilverAdd:setVisible(true)
            Value_SilverAdd:setString("+"..tostring(value) .. "积分")
            action:play("animation_SilverAdd", false)
            self._playerSilverValue:runAction(action)
        else
            Value_SilverMinus:setVisible(true)           
            Value_SilverMinus:setString(tostring(value) .. "积分")
            action:play("animation_SilverMinus", false)
            self._playerSilverValue:runAction(action)
        end       
        local speed = action:getTimeSpeed()  

        local startFrame = action:getStartFrame()  
        local endFrame = action:getEndFrame()  
        local frameNum = endFrame - startFrame 
        local duration = 1.0 /(speed * 60.0) * frameNum

        local block = cc.CallFunc:create( function(sender)  
            Value_SilverMinus:setVisible(false)
            Value_SilverAdd:setVisible(false)
        end )  
 
        self._playerSilverValue:runAction(cc.Sequence:create(cc.DelayTime:create(duration+1), block))  
    end
end

return MyJiSuGamePlayer