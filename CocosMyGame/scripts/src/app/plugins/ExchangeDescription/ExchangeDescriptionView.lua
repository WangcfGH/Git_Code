local viewCreator = cc.load('ViewAdapter'):create()

viewCreator.viewConfig={
	'res/hallcocosstudio/ExchangeDescription/ExchangeDescription.csb',
	{
        bottomPanel = "Panel_Bottom",
        theBkList = 'Image_Bk',
        {
		    _option = {prefix='Image_Bk.'},
		    closeBtn = 'Button_Close',
		    goToGameBtn = 'Button_GoToGame',
            textTipLeft = 'Text_Tip_Left',
            textTipRight = 'Text_Tip_Right'
        },
	}
}

return viewCreator