--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local viewCreator=cc.load('ViewAdapter'):create()

viewCreator.viewConfig={
    'res/hallcocosstudio/ArenaRank/GiveUpToArena.csb',
	{
        bottomPanel="Panel_Bottom",
        imageBk='Image_Bk',
		{
			_option={prefix='Image_Bk.'},
            giveUpBt='Button_GiveUp',
            continueBt='Button_Continue',
            closeBt='Button_Close',
        },
	}
}
return viewCreator


--endregion
