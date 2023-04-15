--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local viewCreater=import('src.app.plugins.SignUp.SignUpView')
local signUpCtrl=class('signUpCtrl',cc.load('BaseCtrl'))
local mySignUpStatus = require("src.app.plugins.SignUp.SignUpStatus"):getInstance()

function signUpCtrl:onCreate(params)

    self._arenaRoomInfo = params.arenaRoomsData
    self._arenaData = params.arenaData

	local viewNode=self:setViewIndexer(viewCreater:createViewIndexer())
    --viewNode.bottomPanel:addTouchEventListener(handler(self, self.removeSelfInstance))


    self:bindDestroyButton(viewNode.closeBt)
    --viewNode.signUpBt:addTouchEventListener(handler(self, self.onSignUpToRank))
  
    --viewNode.closeBt:addTouchEventListener(handler(self,self.removeSelfInstance))
    --viewNode.continueBk:addTouchEventListener(handler(self,self.onSignUpToArena))

    local bindList={
		'signUpBt',
		'continueBk',
	}
	
	self:bindUserEventHandler(viewNode,bindList)
    
    self._isPopUpFinished = false

    local function popUpFinish()
        self._isPopUpFinished = true
    end

    local popUpFinishAction = cc.CallFunc:create(popUpFinish)

    viewNode.imageBk:setScale(0.7)
    viewNode.imageBk:setVisible(false)
    viewNode.imageBk:runAction(cc.Sequence:create(cc.Show:create(), cc.ScaleTo:create(0.1, 1), popUpFinishAction, nil))

    --viewNode.bottomPanel:setVisible(false)
    --viewNode.bottomPanel:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.Show:create(), nil))  
    --相对布局以适应不同屏幕尺寸比例
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    viewNode.imageBk:setPositionY(visibleSize.height / 2)  
end

function signUpCtrl:signUpBtClicked()
    if  my.IsLoginOff then
        local config = cc.exports.GetRoomConfig()
        my.informPluginByName({pluginName = 'TipPlugin', params = {tipString = config['USER_NOT_LOGIN'], removeTime = 1}})
        self:removeSelfInstance() 
        return
    end 
    my.playClickBtnSound()
    local ArenaModel = import("src.app.plugins.arena.ArenaModel"):getInstance()
    ArenaModel:sendSignUpArenaRank()
    self:removeSelfInstance()
end

function signUpCtrl:continueBkClicked()
    if  my.IsLoginOff then
        local config = cc.exports.GetRoomConfig()
        my.informPluginByName({pluginName = 'TipPlugin', params = {tipString = config['USER_NOT_LOGIN'], removeTime = 1}})
        self:removeSelfInstance() 
        return
    end 
    my.playClickBtnSound()
    local RoomModel =  require("src.app.plugins.roomspanel.RoomListModel"):getInstance()
    RoomModel:signUp(self._arenaRoomInfo, self._arenaData)
    self:removeSelfInstance()
end

function signUpCtrl:onKeyboardReleased(keyCode, event)
	if keyCode == cc.KeyCode.KEY_BACK then
        event:stopPropagation()
		if(self.onKeyBack)then
			return self:onKeyBack()
		end
	end
end

function signUpCtrl:onKeyBack()    
	if self:informPluginByName(nil,nil) and self._isPopUpFinished  then
		self:removeSelfInstance()
	end
end

return signUpCtrl



--endregion
