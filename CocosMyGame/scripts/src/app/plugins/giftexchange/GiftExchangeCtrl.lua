local GiftExchangeCtrl = class('GiftExchangeCtrl', cc.load('BaseCtrl'))
local GiftExchangeView = require("src.app.plugins.giftexchange.GiftExchangeView")
local GiftExchangeModel = require("src.app.plugins.giftexchange.GiftExchangeModel"):getInstance()

local CodeType = {
    PROMOTE_CODE        = 1,
    GIFT_CODE           = 2
}

local CodeTypeByLen = {
    PROMOTE_CODE_LEN    = 8,
    GIFT_CODE_LEN       = 12
}

function GiftExchangeCtrl:onCreate( ... )
    self:setViewIndexer(GiftExchangeView:createViewIndexer())
    local viewNode = self:getViewNode();
    if not viewNode then return end

    --
    viewNode.textResult:setString("");
    self._editBox = viewNode.textInput--self:_createEditBoxByTextFieldNode(viewNode.textInput, cc.c3b(0x33, 0x33, 0x33))

    --
    if viewNode.btnExchange then
        self:bindUserEventHandler(viewNode, {'btnExchange'})
    end
    if viewNode.btnClose then
        self:bindDestroyButton(viewNode.btnClose)
    end

    --
    self:listenTo(GiftExchangeModel, GiftExchangeModel.UPDATE_RESULT, handler(self, self.updateResult))
end

function GiftExchangeCtrl:btnExchangeClicked()
    local editBox = self._editBox
    if not editBox then return end
    local viewNode = self:getViewNode()
    if not viewNode then return end
    
    local exchangeCode = editBox:getString() 
    if not exchangeCode then 
        viewNode.textResult:setString("请输入礼包码");
        return
    end
    if exchangeCode and string.len(exchangeCode) <= 0 then
        viewNode.textResult:setString("礼包码不能为空");
        return
    end

    local exchangeCodeLen = string.len(exchangeCode)
    local exchangeCodeType = CodeType.GIFT_CODE
    if exchangeCodeLen <= CodeTypeByLen.PROMOTE_CODE_LEN then
        exchangeCodeType = CodeType.PROMOTE_CODE
    end

    --校验非cps包却要领取推广礼包
    if exchangeCodeType == CodeType.PROMOTE_CODE then
        if device.platform ~= 'ios' and not cc.exports.isCpsAppSupport() then
            viewNode.textResult:setString("礼包码无效");
            return
        end
    end

    -- 防玩家狂点
    self._lastBtnExchangeClicked = self._lastBtnExchangeClicked or 0
    if os.time() - self._lastBtnExchangeClicked < 2 then
        print('click too fast...')
        return
    end
    self._lastBtnExchangeClicked = os.time()

    GiftExchangeModel:sendReqGift(exchangeCode, exchangeCodeType)
end

function GiftExchangeCtrl:updateResult(event)
    if not event then return end
    if not event.value then return end
    if type(event.value) ~= 'string' then return end
    local viewNode = self:getViewNode()
    if not viewNode then return end
    viewNode.textResult:setString(event.value)
end

function GiftExchangeCtrl:_createEditBoxByTextFieldNode(textFieldNode, fontColor)
    textFieldNode:setVisible(false)
    
	local editBox = ccui.EditBox:create(textFieldNode:getContentSize(), cc.Scale9Sprite:create('hallcocosstudio/images/plist/Common/Hall_Box_EditBox.png'))

    editBox.getString=editBox.getText
	editBox.setString=editBox.setText
	editBox.setTextColor=editBox.setFontColor

	editBox:setPosition(textFieldNode:getPosition())
	editBox:setAnchorPoint(textFieldNode:getAnchorPoint())

    local fontName = textFieldNode:getFontName()
	editBox:setFontName(fontName)
	editBox:setFontColor(fontColor or cc.c3b(0x33, 0x33, 0x33))
	editBox:setFontSize(textFieldNode:getFontSize())

    editBox:setPlaceholderFontName(fontName)
	editBox:setPlaceHolder(textFieldNode:getPlaceHolder())
	editBox:setPlaceholderFontSize(textFieldNode:getFontSize())
	editBox:setPlaceholderFontColor(textFieldNode:getPlaceHolderColor())

	editBox:setMaxLength(textFieldNode:getMaxLength())
	editBox:setInputMode(cc.EDITBOX_INPUT_MODE_ANY)
    
    local parentNode = textFieldNode:getParent()
	parentNode:addChild(editBox)

    editBox:setLocalZOrder(textFieldNode:getLocalZOrder() + 1)
    
    return editBox
end

return GiftExchangeCtrl