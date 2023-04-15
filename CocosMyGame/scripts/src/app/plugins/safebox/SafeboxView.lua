
local viewCreator=cc.load('ViewAdapter'):create()

viewCreator.viewConfig={
    'res/hallcocosstudio/safebox/safebox.csb',
	{
		_option={prefix='Img_MainBox.'},
		closeBt='Btn_Close',
		goShoppingBt='Btn_Goshopping',
		saveDepositBt='Btn_Save',
		takeDepositBt='Btn_Take',
		depositAmoutInp='TextField_EditDeposit',
		safeboxDepositAmountLb='Value_DepositSaveBox',
		gameDepositAmountLb='Value_DepositGame',
        safeBoxTexture="Text_TitleIcon",
		imgEditBox='Img_EditBox',
		addBtn1 = 'Btn_1',
		addBtn2 = 'Btn_2',
		addBtn3 = 'Btn_3',
		allBtn = 'Btn_all',
		clearBtn = 'Btn_clear',

		textNPLevel = 'Text_NPLevel',
		valueNPLevel = 'Value_NPLevel',
		textSaveCount = 'Text_SaveCount',
		valueSaveCount = 'Value_SaveCount'
	},
    ["popupAni"] = {
        ["aniName"] = "scaleandshake",
        ["aniNode"] = "Img_MainBox",
        ["isPlayAni"] = true
    }
}

function viewCreator:onCreateView(viewNode)
	--viewNode.depositAmoutInp:setPlaceHolderColor(cc.c4b(163,163,163,64))
	viewNode.depositAmoutInp:setTouchAreaEnabled(false)
	local depositAmoutInp=viewNode.depositAmoutInp
	local imageView=viewNode.imgEditBox
	local image='./images/Hall_Box_EditBox.png'
	self:fixTextField(viewNode,'depositAmoutInp',imageView,image)
    if cc.exports.isSafeBoxSupported() then
    else
        if cc.exports.isBackBoxSupported() then
            viewNode.safeBoxTexture:loadTexture("res/hallcocosstudio/images/plist/Savebox_Img/back_box_title.png", 1)
            --viewNode.safeBoxTexture:setContentSize({width = 92,height = 36})
        end
    end
end

function viewCreator:fixTextField(viewNode,objName,imageView,image,fontColor)
	local depositAmoutInp=viewNode[objName]
	depositAmoutInp:setVisible(false)
	local editBox=ccui.EditBox:create(imageView:getContentSize(),image)

    editBox.getString=editBox.getText
	editBox.setString=editBox.setText
	editBox.setTextColor=editBox.setFontColor

	editBox:setPosition(imageView:getPosition())
	editBox:setAnchorPoint(depositAmoutInp:getAnchorPoint())

    local fontName = depositAmoutInp:getFontName() == '' and 'Arial' or depositAmoutInp:getFontName()
	editBox:setFontName(fontName)
	editBox:setFontColor(fontColor or cc.c3b(212, 102, 4))--display.COLOR_BLACK)--cc.c3b(0x33, 0x33, 0x33)是美术的建议
	editBox:setFontSize(24)

    editBox:setPlaceholderFontName(fontName)
	editBox:setPlaceHolder(depositAmoutInp:getPlaceHolder())
	editBox:setPlaceholderFontSize(24)
	editBox:setPlaceholderFontColor(cc.c3b(212, 102, 4))
    
	editBox:setMaxLength(depositAmoutInp:getMaxLength())
	editBox:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)

	local parent=(depositAmoutInp:getParent()~=imageView and depositAmoutInp:getParent()) or depositAmoutInp:getParent():getParent()
	parent:addChild(editBox)

	viewNode[objName]=editBox

	editBox:setLocalZOrder(imageView:getLocalZOrder()+1)
end

return viewCreator
