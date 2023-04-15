local viewCreater = import('src.app.plugins.ExchangeItemTip.ExchangeItemResultView')
local ExchangeItemResultCtrl = class('ExchangeItemResultCtrl', cc.load('BaseCtrl'))

function ExchangeItemResultCtrl:onCreate(...)
	self:setViewIndexer(viewCreater:createViewIndexer())

	local viewNode = self._viewNode

    local param = ...
    local title = param.title
    local msg = param.message
    local isSuccess = param.isSuccess

    --viewNode.textTitle:setString(title) 
    local spriteFramePath = "hallcocosstudio/images/plist/exchange_img_new/img_text_exchange_failed.png"
    if isSuccess == true then
        spriteFramePath = "hallcocosstudio/images/plist/exchange_img_new/img_text_exchange_ok.png"
    end
    viewNode.spriteTitle:setSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame(spriteFramePath))
    viewNode.textInfo:setString(msg)
    
    self:bindDestroyButton(viewNode.closeBtn)
    viewNode.bottomPanel:addClickEventListener(handler(self, self.removeSelfInstance))
    viewNode.iKnowBtn:addClickEventListener(function()
        my.playClickBtnSound()
        self:removeSelfInstance()
    end)    

    viewNode.panelMain:setScale(0.7)
    viewNode.panelMain:setVisible(false)
    viewNode.panelMain:runAction(cc.Sequence:create(cc.Show:create(), cc.ScaleTo:create(0.1, 1), nil))

    --viewNode.bottomPanel:setVisible(false)
    --viewNode.bottomPanel:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.Show:create(), nil)) 
end

return ExchangeItemResultCtrl