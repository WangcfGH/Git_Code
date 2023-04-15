local MyJiSuGameSelfPlayer = class("MyJiSuGameSelfPlayer", import("src.app.Game.mMyGame.MyGamePlayer.MyGameSelfPlayer"))

function MyJiSuGameSelfPlayer:init()
    MyJiSuGameSelfPlayer.super.init(self)

    local playerName = self._playerPanel:getChildByName("Node_PlayerName")
    if playerName then
        playerName:setPositionY(0)
        self._playerUserName = playerName:getChildByName("Panel_PlayerName"):getChildByName("Text_PlayerName")
    end
end

function MyJiSuGameSelfPlayer:showBomeSilverValue(value)
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

function MyJiSuGameSelfPlayer:setUserName(szUserName)
    if self._playerUserName then
        self._playerUserName:setVisible(true)

        local userPlugin = plugin.AgentManager:getInstance():getUserPlugin()
       local utf8nickname = userPlugin:getNickName()
        my.fitStringInWidget(utf8nickname, self._playerUserName, 115)

        local playerName = self._playerPanel:getChildByName("Node_PlayerName")
        playerName:setVisible(true)
    end
end

return MyJiSuGameSelfPlayer
