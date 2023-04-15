local RedPack100ExplainCtrl = class('RedPack100ExplainCtrl', cc.load('BaseCtrl'))
local viewCreater       = import("src.app.plugins.RedPack100.RedPack100ExplainView")

my.addInstance(RedPack100ExplainCtrl)

function RedPack100ExplainCtrl:onCreate(params)
	local viewNode = self:setViewIndexer(viewCreater:createViewIndexer())
    self:bindDestroyButton(viewNode.btnConfirm)
    local bindList={
        'btnConfirm',
	}
	self:bindUserEventHandler(viewNode,bindList)
    self._viewNode = viewNode
end

function RedPack100ExplainCtrl:onEnter( ... )

end

function RedPack100ExplainCtrl:onExit()

end


return RedPack100ExplainCtrl