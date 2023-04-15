
local viewCreator=cc.load('ViewAdapter'):create()

viewCreator.viewConfig={
    'res/hallcocosstudio/dailyactivity/daliyactivity.csb',
	{
		_option={prefix='Img_MainBox.'},
		closeBt='Btn_Close',
		{
			_option={prefix='Img_ItemsBG1.'},
			checkinStartGameBt='Btn_PlayGame',
			checkinBt='Btn_CheckIn',
            {
                _option={prefix='Btn_CheckIn.'},
                checkinRedDot='Img_RedDot',
            }
		},
		{
			_option={prefix='Img_ItemsBG2.'},
			reliefStartGameBt='Btn_PlayGame',
			reliefBt='Btn_Reward',
			reliefText = "Text_ItemName",
            reliefTextDetail = "Text_ItemDetail",
		},
		{
			_option={prefix='Img_ItemsBG3.'},
			shareStartGameBt='Btn_PlayGame',
			shareBt='Btn_Share',
		},
		reliefPanel='Img_ItemsBG2',
		sharePanel='Img_ItemsBG3',
		checkinPanel='Img_ItemsBG1',
		title='Img_Title'
	},
    ["popupAni"] = {
        ["aniName"] = "scale",
        ["aniNode"] = "Img_MainBox",
        ["isPlayAni"] = true
    }
}

return viewCreator
