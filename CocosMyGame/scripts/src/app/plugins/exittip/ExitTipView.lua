
local TabView=cc.load('myccui').TabView
local viewCreator=cc.load('ViewAdapter'):create()

viewCreator.viewConfig={
	'res/hallcocosstudio/tips/exittip.csb',
	{
		_option={prefix='Img_MainBox.'},
        labelTip = 'Text_TipContents',
		gobackBt='Btn_Close',
		closeBt='Btn_Continue',
		exitBt='Btn_Exit',
	},
    ["popupAni"] = {
        ["aniName"] = "scaleandshake",
        ["aniNode"] = "Img_MainBox",
        ["isPlayAni"] = true
    }
}

function viewCreator:onCreateView(viewNode)
    viewNode.labelTip:setString("明天记得回来领取银两和礼券奖励哦！")
end

return viewCreator
