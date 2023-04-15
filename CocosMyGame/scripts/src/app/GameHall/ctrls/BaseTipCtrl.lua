local BaseTipCtrl=class('BaseTipCtrl',cc.load('BaseCtrl'))

my.addInstance(BaseTipCtrl)

function BaseTipCtrl:onCreate(params)
	--	local viewNode=self:setViewIndexer(viewCreater:createViewIndexer())
	local viewNode=self._viewNode

	if(not viewNode)then
		return
	end
	
	local bindList={
		'gobackBt',
		'closeBt',
		'exitBt',
		'okBt',
		'cancelBt',
	}
	
	self:bindUserEventHandler(viewNode,bindList)

	self:bindSomeDestroyButtons(viewNode,bindList)

end

function BaseTipCtrl:onKeyBack()
    printf("BaseTipCtrl onkeyBack")
    self:playEffectOnPress()
	self:removeInstance()
	if(self._onExit)then
		self:_onExit()
	end
	self._viewNode:removeSelf()
end

function BaseTipCtrl:exitBtClicked(e)
	my.finish()
end

cc.register(BaseTipCtrl,'BaseTipCtrl')

return BaseTipCtrl
