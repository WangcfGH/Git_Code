
local PlayerInfoCtrl = class('PlayerInfoView',cc.load('BaseCtrl'))

function PlayerInfoCtrl:onCreate(viewNode)
	self._viewNode=viewNode
end

function PlayerInfoCtrl:setVisible(visible)
    --[[if self._viewNode.panelHead then
	     self._viewNode.panelHead:setVisible(visible)
    end]]--

    if self._viewNode.infoBox then
	    self._viewNode.infoBox:setVisible(visible)
    end

    --[[if self._viewNode.userIdTxt then
         self._viewNode.userIdTxt:setVisible(visible)
    end

    if self._viewNode.button_xiugaimima and cc.exports.isModifyPasswordSupported() then
        self._viewNode.button_xiugaimima:setVisible(visible)
    end]]--
end

function PlayerInfoCtrl:onKeyBack()

end

return PlayerInfoCtrl
