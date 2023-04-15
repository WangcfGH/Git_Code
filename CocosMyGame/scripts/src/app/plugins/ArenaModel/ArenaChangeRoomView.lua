--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local viewCreator=cc.load('ViewAdapter'):create()

viewCreator.viewConfig={
    'res/hallcocosstudio/arena/layer_changescene.csb',
	{
        changePanel="Panel_ChangeBG",
		{
			_option={prefix='Panel_ChangeBG.'},
            closeBt='Btn_Close',
        },
	}
}

return viewCreator


--endregion
