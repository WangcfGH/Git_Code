local viewCreater=import('src.app.plugins.ExchangeDescription.ExchangeDescriptionView')
local ExchangeDescriptionCtrl = class('ExchangeDescriptionCtrl', cc.load('BaseCtrl'))
local ExchangeCenterCtrl = require("src.app.plugins.ExchangeCenter.ExchangeCenterCtrl")

function ExchangeDescriptionCtrl:onCreate(...)
    self:setViewIndexer(viewCreater:createViewIndexer())

	local viewNode = self._viewNode

    self:bindDestroyButton(viewNode.closeBtn)
    viewNode.bottomPanel:addClickEventListener(handler(self, self.removeSelfInstance))
    viewNode.goToGameBtn:addClickEventListener(handler(self, self.onGoToGameClicked))

    --每日宝箱说明信息
    viewNode.textTipLeft:setString(string.format(viewNode.textTipLeft:getString(), 10))

    viewNode.textTipRight:setString(string.format(viewNode.textTipRight:getString(), 3))

    viewNode.theBkList:setScale(0.7)
    viewNode.theBkList:setVisible(false)
    viewNode.theBkList:runAction(cc.Sequence:create(cc.Show:create(), cc.ScaleTo:create(0.1, 1), nil))

    --viewNode.bottomPanel:setVisible(false)
    --viewNode.bottomPanel:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.Show:create(), nil)) 

end

function ExchangeDescriptionCtrl:onGoToGameClicked()
    my.playClickBtnSound()
    self:removeSelfInstance()
 
    if not ExchangeCenterCtrl:isExit() then
        ExchangeCenterCtrl:onExit()
        ExchangeCenterCtrl:setCallBackAfterExit(function()
            
        end)
    end
end

return ExchangeDescriptionCtrl