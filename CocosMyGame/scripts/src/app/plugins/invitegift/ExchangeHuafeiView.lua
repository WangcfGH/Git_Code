

local viewCreator=cc.load('ViewAdapter'):create()

viewCreator.viewConfig={
    'res/hallcocosstudio/invitegiftactive/exchangehuafei.csb',
	{
		_option={prefix='Panel_Main.Panel_Animation.'},
        closeBt = "Btn_Close",
        btnGet = "Btn_get",
        textPhoneNum = "TextPhoneNum",
        imgEditBoxBg = "Img_editBox_bg",
		
	}
}

return viewCreator
