
local viewCreater=import('src.app.plugins.kickedout.KickedOutView')
local KickedOffCtrl = class('KickedOutCtrl',cc.load('BaseCtrl'))
local user=mymodel('UserModel'):getInstance()

KickedOffCtrl.RUN_ENTERACTION = true
function KickedOffCtrl:onCreate(params)
	--KickedOffCtrl.super.ctor(self)

	self:setViewIndexer(viewCreater:createViewIndexer())

	local viewNode=self._viewNode

	self:bindSomeDestroyButtons(viewNode,{'closeBt','reloginBt','modifyPassword'})

	self:bindUserEventHandler(viewNode,{'reloginBt','modifyPassword'})

	local userPlugin = cc.exports.UserPlugin--require('src.app.GameHall.models.PluginEventHandler.UserPlugin'):getInstance()
	if not isModifyPasswordSupported() then
		viewNode.modifyPassword:hide()
	end

end

function KickedOffCtrl:reloginBtClicked(e)
    self._params.centerCtrl:checkNetStatus()
end

function KickedOffCtrl:modifyPasswordClicked(e)
    if not isModifyPasswordSupported() then return end
    local userPlugin = cc.exports.UserPlugin--require('src.app.GameHall.models.PluginEventHandler.UserPlugin'):getInstance()
    if userPlugin:isFunctionSupported("isForbidTcyUser")
    and userPlugin:isForbidTcyUser()
    and userPlugin:isFunctionSupported("enterPlatform") then
        userPlugin:enterPlatform()
    else
        userPlugin:modifyPassword()
    end
end

return KickedOffCtrl
