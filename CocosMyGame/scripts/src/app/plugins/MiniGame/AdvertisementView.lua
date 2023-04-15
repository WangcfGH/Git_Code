
local TabView=cc.load('myccui').TabView
local viewCreator=cc.load('ViewAdapter'):create()

viewCreator.viewConfig={
	'res/hallcocosstudio/MiniGame/Layer_Advertisement.csb',
	{
		_option={prefix='Img_MainBox.'},
		closeBt='Btn_Close',
		downloadBt='Btn_DownLoad',
		downloadText='Text_Loading',
        tcyIcon='Img_Advertisement',
        tcyLoadingPanel='Panel_Loading',
        tcyLoadingBar='Panel_Loading.LoadingBar_Advertisement',
        iconDown1='Btn_Icon1',
        iconDown2='Btn_Icon2',
        iconDown3='Btn_Icon3',
        iconDown4='Btn_Icon4',
	}
}

function viewCreator:onCreateView(viewNode)
	viewNode:setPosition( 0, 0 )
end

return viewCreator
