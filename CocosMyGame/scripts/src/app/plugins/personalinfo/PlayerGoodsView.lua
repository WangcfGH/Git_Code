
local PlayerGoodsCtrl=class('PlayerGoodsView',cc.load('BaseCtrl'))

function PlayerGoodsCtrl:onCreate(viewNode)
	self._viewNode=viewNode
end

function PlayerGoodsCtrl:setVisible(visible)
	self._viewNode.goodsScroll:setVisible(visible)

end

function PlayerGoodsCtrl:onKeyBack()

end

return PlayerGoodsCtrl
