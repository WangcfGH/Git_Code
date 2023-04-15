--道具、银子类
local viewCreater = import('src.app.plugins.ExchangeItemTip.ExchangeItemNormalView')
local ExchangeItemNormalCtrl = class('ExchangeItemNormalCtrl', cc.load('BaseCtrl'))
local ExchangeCenterModel = require("src.app.plugins.ExchangeCenter.ExchangeCenterModel"):getInstance()

--与ExchangeCenterConfig.json中的nType一致.
ExchangeItemNormalCtrl.EXCHANGE_ITEM_SILVER = 1 --银子

function ExchangeItemNormalCtrl:onCreate(...)
	self:setViewIndexer(viewCreater:createViewIndexer())

	local viewNode = self._viewNode

    local param = ...
    self._itemPrice = param.price 
    self._itemName = param.prizeName  
    self._itemType = param.nType 
    self._prizeID = param.prizeID
    self._remainCount = ExchangeCenterModel:getRemainExchangeCount(self._prizeID)
    viewNode.text:setString(string.format(viewNode.text:getString(), self._itemPrice, self._itemName))
    viewNode.textCountTip:setString(string.format(viewNode.textCountTip:getString(), self._remainCount))

    self:bindDestroyButton(viewNode.closeBtn)
    viewNode.bottomPanel:addClickEventListener(handler(self, self.removeSelfInstance))
    viewNode.cancelBtn:addClickEventListener(function()
        my.playClickBtnSound()
        self:removeSelfInstance()
    end)
    viewNode.okCancelBtn:addClickEventListener(function()
        my.playClickBtnSound()
        self:removeSelfInstance()
        my.scheduleOnce(function()
            my.informPluginByName({pluginName='ToastPlugin',params={tipString="该商品已达到今日可兑换上限",removeTime=1}})
        end)
    end)
    viewNode.okBtn:addClickEventListener(handler(self, self.exchangeItem))

    viewNode.panelMain:setScale(0.7)
    viewNode.panelMain:setVisible(false)
    viewNode.panelMain:runAction(cc.Sequence:create(cc.Show:create(), cc.ScaleTo:create(0.1, 1), nil))

    --viewNode.bottomPanel:setVisible(false)
    --viewNode.bottomPanel:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.Show:create(), nil)) 

    if self._remainCount > 0 then
        viewNode.okCancelBtn:setVisible(false)
        viewNode.cancelBtn:setVisible(true)
        viewNode.okBtn:setVisible(true)
    else
        viewNode.okCancelBtn:setVisible(true)
        viewNode.cancelBtn:setVisible(false)
        viewNode.okBtn:setVisible(false)
    end
end

function ExchangeItemNormalCtrl:exchangeItem()
    my.playClickBtnSound()

    self:removeSelfInstance()
    if self._itemType == ExchangeItemNormalCtrl.EXCHANGE_ITEM_SILVER then  
        ExchangeCenterModel:exchangeSilver(self._prizeID, 1)
    elseif self._itemType == ExchangeCenterModel.EXCHANGEITEM_TYPE_CUSTOMPROP then
        ExchangeCenterModel:reqExchangePropOfCardRecorder(self._prizeID)             
    end
end

return ExchangeItemNormalCtrl