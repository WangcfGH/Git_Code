local viewCreator = cc.load('ViewAdapter'):create()

viewCreator.viewConfig = {
	'res/hallcocosstudio/ExchangeItemTip/ExchangeItemNeedInput.csb',
	{
        bottomPanel = "Panel_Shade",
        panelMain = 'Panel_Main',
        {
		    _option = {prefix = 'Panel_Main.'},
            panelTitle = 'Panel_Title',
            {
                _option = {prefix = 'Panel_Title.'},
                textTitle = 'Text_Title',
                textCountTip = 'Text_Count_Tip',
                spriteItemIcon = 'Sprite_ItemIcon',
            },
            
		    closeBtn = 'Button_Close',
            submitBtn = 'Button_Submit',
            okBtn = 'Button_OK',
            namePanel = 'Panel_Name',
            cellphonePanel = 'Panel_Cellphone',
            cellphoneSurePanel = 'Panel_Cellphone_Sure',
            addressPanel = 'Panel_Address',
            {
                _option = {prefix = 'Panel_Name.'},
                {
                    _option = {prefix = 'Panel_Content.'},
                    nameInfo = 'Text_Content',
                    nameInfoClearBtn = 'Button_Clear'
                }
            },
            {
                _option = {prefix = 'Panel_Cellphone.'},
                {
                    _option = {prefix = 'Panel_Content.'},
                    cellphoneInfo = 'Text_Content',
                    cellphoneInfoClearBtn = 'Button_Clear'
                }
            },
            {
                _option = {prefix = 'Panel_Cellphone_Sure.'},
                {
                    _option = {prefix = 'Panel_Content.'},
                    cellphoneSureInfo = 'Text_Content',
                    cellphoneSureInfoClearBtn = 'Button_Clear'
                }
            },
            {
                _option = {prefix = 'Panel_Address.'},
                {
                    _option = {prefix = 'Panel_Content.'},
                    addressInfo = 'Text_Content',
                    addressInfoClearBtn = 'Button_Clear'
                }
            }
        },
	}
}

return viewCreator
