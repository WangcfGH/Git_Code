
local MyJiSuGameClock = class("MyJiSuGameClock", import("src.app.Game.mMyGame.MyGameClock"))

function MyJiSuGameClock:moveClockToSetCard()
    local MyGameScene = self._gameController._baseGameScene
    if MyGameScene and MyGameScene._gameNode then
        local clockPosition = MyGameScene._gameNode:getChildByName("Panel_Clock"):getChildByName("Node_Clock_SetCard")
        if clockPosition then
            self:setPosition(cc.p(clockPosition:getPosition()))
            self:setVisible(true)
            self:setDrawIndex(index)
        end
    end
end

return MyJiSuGameClock