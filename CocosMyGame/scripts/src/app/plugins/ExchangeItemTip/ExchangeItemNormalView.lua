local viewCreator = cc.load('ViewAdapter'):create()

viewCreator.viewConfig = {
	'res/hallcocosstudio/ExchangeItemTip/ExchangeItemNormal.csb',
	{
        bottomPanel = "Panel_Shade",
        panelMain = 'Panel_Main',
        {
	    _option = {prefix = 'Panel_Main.'},
            text = 'Text_Tip',
            textCountTip = 'Text_Count_Tip',
            closeBtn = 'Button_Close',
            okCancelBtn = 'Button_OK_1',
            okBtn = 'Button_OK',
            cancelBtn = 'Button_Cancel'
        },
	}
}

return viewCreator