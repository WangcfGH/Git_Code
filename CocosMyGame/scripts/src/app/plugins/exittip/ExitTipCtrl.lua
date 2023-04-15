local ExitTipCtrl=class('ExitTipCtrl',myctrl('BaseTipCtrl'))
local viewCreater=import('src.app.plugins.exittip.ExitTipView')

my.addInstance(ExitTipCtrl)

function ExitTipCtrl:onCreate(params)
	local viewNode=self:setViewIndexer(viewCreater:createViewIndexer())
	ExitTipCtrl.super.onCreate(self,params)
end

return ExitTipCtrl
