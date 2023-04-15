local LoginLotteryRuleCtrl  = class('LoginLotteryRuleCtrl', cc.load('BaseCtrl'))
local viewCreater       = import("src.app.plugins.loginlottery.LoginLotteryRuleView")

my.addInstance(LoginLotteryRuleCtrl)

function LoginLotteryRuleCtrl:onCreate(params)
	local viewNode = self:setViewIndexer(viewCreater:createViewIndexer())
    self:bindDestroyButton(viewNode.btnConfirm)
    local bindList={
        'btnConfirm',
	}
	self:bindUserEventHandler(viewNode,bindList)
    self._viewNode = viewNode
end

function LoginLotteryRuleCtrl:onEnter( ... )

end

function LoginLotteryRuleCtrl:onExit()

end


return LoginLotteryRuleCtrl