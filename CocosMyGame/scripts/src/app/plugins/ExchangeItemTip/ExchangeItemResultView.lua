local viewCreator = cc.load('ViewAdapter'):create()

viewCreator.viewConfig = {
	'res/hallcocosstudio/ExchangeItemTip/ExchangeItemResult.csb',
	{
        bottomPanel = "Panel_Shade",
        panelMain = 'Panel_Main',
        {
		    _option = {prefix = 'Panel_Main.'},
            --textTitle = 'Text_Title',
            spriteTitle = 'Sprite_Title',
            textInfo = 'Text_Info',
		    closeBtn = 'Button_Close',
		    iKnowBtn = 'Button_I_Know'
        }
	}
}

return viewCreator