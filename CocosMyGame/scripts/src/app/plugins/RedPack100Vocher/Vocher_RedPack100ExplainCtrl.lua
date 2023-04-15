local RedPack100ExplainCtrl = import("src.app.plugins.RedPack100.RedPack100ExplainCtrl")
local Vocher_RedPack100ExplainCtrl = class("Vocher_RedPack100ExplainCtrl", RedPack100ExplainCtrl)
local viewCreater       = import("src.app.plugins.RedPack100Vocher.Vocher_RedPack100ExplainView")

my.addInstance(Vocher_RedPack100ExplainCtrl)

function Vocher_RedPack100ExplainCtrl:onCreate(params)
	local viewNode = self:setViewIndexer(viewCreater:createViewIndexer())
    self:bindDestroyButton(viewNode.btnConfirm)
    local bindList={
        'btnConfirm',
	}
	self:bindUserEventHandler(viewNode,bindList)
    self._viewNode = viewNode
end


return Vocher_RedPack100ExplainCtrl