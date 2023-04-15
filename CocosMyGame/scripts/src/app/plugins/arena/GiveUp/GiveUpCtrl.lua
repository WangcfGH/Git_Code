local viewCreater=import('src.app.plugins.arena.GiveUp.GiveUpView')
local giveUpCtrl=class('giveUpCtrl',cc.load('BaseCtrl'))
local ArenaModel = import("src.app.plugins.arena.ArenaModel"):getInstance()

function giveUpCtrl:onCreate(params)
    self._launchParams = params
	local viewNode=self:setViewIndexer(viewCreater:createViewIndexer())
    viewNode.bottomPanel:addClickEventListener(handler(self, self.removeSelfInstance))

    self:bindDestroyButton(viewNode.closeBt)

    viewNode.giveUpBt:addClickEventListener(handler(self, self.onGiveUp))
    viewNode.continueBt:addClickEventListener(handler(self, self.onContinue))

    self._isPopUpFinished = false
    local function popUpFinish()
        self._isPopUpFinished = true
    end

    local popUpFinishAction = cc.CallFunc:create(popUpFinish)

    local panelAni = viewNode:getChildByName("Image_Bk")
    if not tolua.isnull(panelAni) then
        panelAni:setVisible(true)
        panelAni:setScale(0.6)
        panelAni:setOpacity(255)
        local scaleTo1 = cc.EaseSineOut:create(cc.ScaleTo:create(0.16, 1.1))
        local scaleTo2 = cc.ScaleTo:create(0.09, 1)

        local ani = cc.Sequence:create(scaleTo1, scaleTo2,popUpFinishAction,nil)
        panelAni:runAction(ani)
    end
    -- viewNode.imageBk:setScale(0.7)
    -- viewNode.imageBk:setVisible(false)
    -- viewNode.imageBk:runAction(cc.Sequence:create(cc.Show:create(), cc.ScaleTo:create(0.1, 1), popUpFinishAction, nil))

    --viewNode.bottomPanel:setVisible(false)
    --viewNode.bottomPanel:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.Show:create(), nil))  

    --相对布局以适应不同屏幕尺寸比例
    local visibleSize = cc.Director:getInstance():getVisibleSize()
    viewNode.imageBk:setPositionY(visibleSize.height / 2)
end

function giveUpCtrl:onGiveUp()  
    if  my.IsLoginOff then
        local config = cc.exports.GetRoomConfig()
        my.informPluginByName({pluginName = 'TipPlugin', params = {tipString = config['USER_NOT_LOGIN'], removeTime = 1}})
        self:removeSelfInstance() 
        return
    end 
    my.playClickBtnSound()

    if not UIHelper:checkOpeCycle("giveUpCtrl_opeGiveup") then
        return
    end
    UIHelper:refreshOpeBegin("giveUpCtrl_opeGiveup")
    my.startProcessing()

    ArenaModel:giveUp(self._launchParams["userArenaData"]) 
    self:removeSelfInstance()
end

function giveUpCtrl:onContinue() 
    if  my.IsLoginOff then
        local config = cc.exports.GetRoomConfig()
        my.informPluginByName({pluginName = 'TipPlugin', params = {tipString = config['USER_NOT_LOGIN'], removeTime = 1}})
        self:removeSelfInstance() 
        return
    end 
    my.playClickBtnSound()
    if self._launchParams["callbackContinue"] then
        self._launchParams["callbackContinue"](self._launchParams["userArenaData"])
     end 
    self:removeSelfInstance() 
end

function giveUpCtrl:onKeyboardReleased(keyCode, event)
	if keyCode == cc.KeyCode.KEY_BACK then
        event:stopPropagation()
		if(self.onKeyBack)then
			return self:onKeyBack()
		end
	end
end

function giveUpCtrl:onKeyBack()    
	if self:informPluginByName(nil,nil) and self._isPopUpFinished  then
		self:removeSelfInstance()
	end
end

return giveUpCtrl