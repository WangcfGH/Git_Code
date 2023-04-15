

local viewCreater=require('src.app.plugins.safeboxpasswordplane.SafeboxPasswordPlaneView')
local SafeboxPasswordPlaneCtrl=class('SafeboxPasswordPlaneCtrl',cc.load('BaseCtrl'))

local user=mymodel('UserModel'):getInstance()
local player=mymodel('hallext.PlayerModel'):getInstance()

my.addInstance(SafeboxPasswordPlaneCtrl)

function SafeboxPasswordPlaneCtrl:onCreate()

	local viewNode=self:setViewIndexer(viewCreater:createViewIndexer())

	self:bindDestroyButton(viewNode.cancelBt)
	self:bindDestroyButton(viewNode.sureBt)
	self:bindUserEventHandler(viewNode,{'sureBt'})

end

function SafeboxPasswordPlaneCtrl:sureBtClicked()
	local viewNode=self._viewNode
	printInfo('sureBtClicked, psw is : %s',viewNode.pswInp:getString())
	
	user.lpszSecurePwd=viewNode.pswInp:getString()
	player:update({'RndKey'})

end

return SafeboxPasswordPlaneCtrl
