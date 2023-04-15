local GameRuleJiSuCtrl=class('GameRuleJiSuCtrl', cc.load('BaseCtrl'))
local viewCreater=import('src.app.plugins.gamerulejisu.GameRuleJiSuView')

GameRuleJiSuCtrl.RUN_ENTERACTION = true

function GameRuleJiSuCtrl:onCreate(...)
    local viewNode=self:setViewIndexer(viewCreater:createViewIndexer())
    self:bindDestroyButton(viewNode.closeBt)
end

function GameRuleJiSuCtrl:runEnterAction()
    self._viewNode:runTimelineAction("ani_show", false)
end

function GameRuleJiSuCtrl:onClose()
    self:removeSelfInstance()
end

return GameRuleJiSuCtrl
