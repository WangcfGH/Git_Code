local viewCreator=cc.load('ViewAdapter'):create()

viewCreator.viewConfig = {
    'res/hallcocosstudio/giftexchange/giftexchange.csb',
    {
    	Panel_main='Panel_Main',
    	{
    		_option = {prefix='Panel_Main.'},
           {
              _option = { prefix = 'Panel_MainInside.'},
              textResult = 'Text_Result',
              btnExchange = 'Button_Exchange',
              btnClose = 'Button_Close',
              imgEditBox = 'Image_TextField_Bg',
              {
                _option = { prefix = "Image_TextField_Bg." },
                textInput = 'TextField_Input'
              }
           }
    	}
    }
}

function viewCreator:onCreateView(viewNode)
	local editBox=ccui.EditBox:create(viewNode.textInput:getContentSize(),'res/hallcocosstudio/imagesbox5_shuru_pic.png')
    editBox:setPosition(viewNode.textInput:getPosition())
    editBox.getString=editBox.getText
    editBox.setString=editBox.setText
    editBox:setLocalZOrder(viewNode.imgEditBox:getLocalZOrder()+1)
    editBox:setInputMode(cc.EDITBOX_INPUT_MODE_ANY)
    editBox:setFontColor(display.COLOR_BLACK)
    --viewNode.clearBt:setLocalZOrder(2)
    local parent=(viewNode.textInput:getParent()~=imageView and viewNode.textInput:getParent()) or viewNode.textInput:getParent():getParent()
    parent:addChild(editBox)
    editBox:setPlaceHolder(viewNode.textInput:getPlaceHolder())
    viewNode.textInput:setVisible(false)
    viewNode.textInput = editBox
end

return viewCreator