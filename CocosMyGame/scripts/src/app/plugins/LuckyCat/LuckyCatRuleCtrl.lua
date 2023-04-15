local LuckyCatRuleCtrl  = class('LuckyCatRuleCtrl', cc.load('BaseCtrl'))
local viewCreater       = import("src.app.plugins.LuckyCat.LuckyCatRuleView")
local LuckyCatModel     = import("src.app.plugins.LuckyCat.LuckyCatModel"):getInstance()

my.addInstance(LuckyCatRuleCtrl)

function LuckyCatRuleCtrl:onCreate(params)
	local viewNode = self:setViewIndexer(viewCreater:createViewIndexer())
    self:bindDestroyButton(viewNode.btnConfirm)
    local bindList={
        'btnConfirm',
	}
	self:bindUserEventHandler(viewNode,bindList)
    self._viewNode = viewNode

    local bufferData = LuckyCatModel:getBufferDate()
    self._viewNode.imgMainBox:getChildByName("ScrollView"):getChildByName("Text_Rule6"):setString("5. 活动结束后，您有"..bufferData.."天领取奖励的时间，记得来领奖哦")
end

function LuckyCatRuleCtrl:onEnter( ... )

end

function LuckyCatRuleCtrl:onExit()

end


return LuckyCatRuleCtrl