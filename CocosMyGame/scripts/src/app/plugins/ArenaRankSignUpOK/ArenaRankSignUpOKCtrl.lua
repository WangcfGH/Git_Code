local ArenaRankSignUpOKCtrl = class('ArenaRankSignUpOKCtrl', cc.load('BaseCtrl'))
local viewCreater = import('src.app.plugins.ArenaRankSignUpOK.ArenaRankSignUpOKView')

function ArenaRankSignUpOKCtrl:onCreate(...)
	local viewNode = self:setViewIndexer(viewCreater:createViewIndexer())

    viewNode.bottomPanel:addClickEventListener(handler(self, self.removeSelfInstance))

    self._isPopUpFinished = false
    local function popUpFinish()
        self._isPopUpFinished = true
    end

    local popUpFinishAction = cc.CallFunc:create(popUpFinish)

    viewNode.theBkList:setScale(0.7)
    viewNode.theBkList:setVisible(false)
    viewNode.theBkList:runAction(cc.Sequence:create(cc.Show:create(), cc.ScaleTo:create(0.1, 1), popUpFinishAction, nil))

    --viewNode.bottomPanel:setVisible(false)
    --viewNode.bottomPanel:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.Show:create(), nil))
end

function ArenaRankSignUpOKCtrl:onKeyboardReleased(keyCode, event)
	if keyCode == cc.KeyCode.KEY_BACK then
        event:stopPropagation()
		if(self.onKeyBack)then
			return self:onKeyBack()
		end
	end
end

function ArenaRankSignUpOKCtrl:onKeyBack()    
	if self:informPluginByName(nil,nil) and self._isPopUpFinished  then
		self:removeSelfInstance()
	end
end

return ArenaRankSignUpOKCtrl
