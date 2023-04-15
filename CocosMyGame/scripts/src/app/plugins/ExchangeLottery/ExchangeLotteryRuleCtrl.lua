local ExchangeLotteryRuleCtrl  = class('ExchangeLotteryRuleCtrl', cc.load('BaseCtrl'))
local viewCreater       = import("src.app.plugins.ExchangeLottery.ExchangeLotteryRuleView")

my.addInstance(ExchangeLotteryRuleCtrl)

function ExchangeLotteryRuleCtrl:onCreate(params)
	local viewNode = self:setViewIndexer(viewCreater:createViewIndexer())
    self:bindDestroyButton(viewNode.btnConfirm)
    local bindList={
        'btnConfirm',
	}
	self:bindUserEventHandler(viewNode,bindList)
    self._viewNode = viewNode
end

function ExchangeLotteryRuleCtrl:onEnter( ... )

end

function ExchangeLotteryRuleCtrl:onExit()

end


return ExchangeLotteryRuleCtrl