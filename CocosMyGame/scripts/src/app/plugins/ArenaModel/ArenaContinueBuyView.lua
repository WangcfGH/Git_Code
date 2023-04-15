--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local viewCreator=cc.load('ViewAdapter'):create()

viewCreator.viewConfig={
    'res/hallcocosstudio/ArenaRank/Arena_ContinueBuy.csb',
	{
		{
			_option={prefix='Img_MainBox.'},
            closeBt='Btn_Close',
            sliverNumText='Text_SliverNum',
            signUpText='Text_Title3',
            buyBt='Btn_Continue',
        },
	}
}
return viewCreator


--endregion
