
local WinningStreakRuleCtrl      = class('WinningStreakRuleCtrl', cc.load('SceneCtrl'))
local viewCreater            = import('src.app.plugins.WinningStreak.WinningStreakRuleView')

WinningStreakRuleCtrl.RUN_ENTERACTION = true

function WinningStreakRuleCtrl:onCreate( ... )
    local viewNode      = self:setViewIndexer(viewCreater:createViewIndexer())
    cc.exports.zeroBezelNodeAutoAdapt(viewNode:getChildByName("Operate_Panel"))
    self:bindUserEventHandler(viewNode, {'closeBt'})
end

function WinningStreakRuleCtrl:goBack()
    WinningStreakRuleCtrl.super.removeSelf(self)
end

function WinningStreakRuleCtrl:closeBtClicked()
    self:goBack()
end

function WinningStreakRuleCtrl:onKeyBack()
    self:goBack()
end

return WinningStreakRuleCtrl
