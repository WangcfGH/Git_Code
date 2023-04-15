
local viewCreator=cc.load('ViewAdapter'):create()

viewCreator.viewConfig={
    'res/hallcocosstudio/activitycenter/giftvoucher.csb',
	{
		Panel_Main = 'Panel_Main',
        {
            _option={prefix='Panel_Main.'},
            Button_go = "Button_go"
        }
	}
}

return viewCreator
