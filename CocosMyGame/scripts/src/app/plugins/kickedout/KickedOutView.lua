
local viewCreator=cc.load('ViewAdapter'):create()

viewCreator.viewConfig={
	'res/hallcocosstudio/tips/kickedout.csb',
	{
		_option={prefix='Panel_Main.Panel_Animation.'},
		closeBt='Btn_Close',
		reloginBt='Btn_ReLogin',
		modifyPassword='Btn_ChangePW',
	}
}

return viewCreator
