
local SKGameSelfInfo = import("src.app.Game.mSKGame.SKGameSelfInfo")
local MyGameSelfInfo = class("MyGameSelfInfo", SKGameSelfInfo)

function MyGameSelfInfo:ctor(selfInfoPanel, ...)
    self._selfInfoWaittingShow  = nil

    MyGameSelfInfo.super.ctor(self, selfInfoPanel, ...)
end

function MyGameSelfInfo:init()
    if not self._selfInfoPanel then return end

    self._selfInfoWaittingShow  = self._selfInfoPanel:getChildByName("Node_waitingshown")

    MyGameSelfInfo.super.init(self)
end

function MyGameSelfInfo:showWaittingShow(bShow)
    if self._selfInfoWaittingShow then
        self._selfInfoWaittingShow:setVisible(bShow)

        if bShow then
            local csbPath = "res/GameCocosStudio/csb/game_scene_animation/Node_WaitingShown.csb"
            local action = cc.CSLoader:createTimeline(csbPath)
            if action then
                self._selfInfoWaittingShow:runAction(action)
                action:gotoFrameAndPlay(0, 21, true)
            end
        end
    end
end

return MyGameSelfInfo