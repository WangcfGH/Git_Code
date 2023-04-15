--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local viewCreator=cc.load('ViewAdapter'):create()

viewCreator.viewConfig={
    'res/hallcocosstudio/ArenaRank/SignUpToArena.csb',
	{
        bottomPanel="Panel_Bottom",
        imageBk='Image_Bk',
		{
			_option={prefix='Image_Bk.'},
            signUpBt='Button_GiveUp',
            closeBt='Button_Close',
            continueBk = 'Button_Continue',
        },
	}
}
return viewCreator


--endregion
