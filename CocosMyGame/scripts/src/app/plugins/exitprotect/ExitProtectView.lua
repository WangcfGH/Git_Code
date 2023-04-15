
local TabView=cc.load('myccui').TabView
local viewCreator=cc.load('ViewAdapter'):create()

viewCreator.viewConfig={
	'res/hallcocosstudio/protcet/protcet.csb',
	{
		_option={prefix='Img_MainBox.'},
		closeBt='Btn_Close',
		continueBt='Btn_Continue',
		exitBt='Btn_End',
		checkinBt='Btn_Checkin',
        {
			_option={prefix='Btn_Checkin.'},
			checkinEndImage='Img_End',
			silverNumText='Text_SilverNum',
		},
		lotteryBt='Btn_Lottery',
        {
			_option={prefix='Btn_Lottery.'},
			lotteryEndImage='Img_End',
			lotteryNumText='Text_SilverNum',
		},
		reliefBt='Btn_Relief',
        {
			_option={prefix='Btn_Relief.'},
			reliefEndImage='Img_End',
			reliefNumText='Text_Label',
			reliefMoneyText='Text_SilverNum',
		},
		--GetMoneyText='Text_Num',
	},
    ["popupAni"] = {
        ["aniName"] = "scaleandshake",
        ["aniNode"] = "Img_MainBox",
        ["isPlayAni"] = true
    }
}

function viewCreator:onCreateView(viewNode)
	viewNode:setPosition( 0, 0 )
end

return viewCreator
