

local viewCreator=cc.load('ViewAdapter'):create()

viewCreator.viewConfig={
    'res/hallcocosstudio/invitegiftactive/newuser/newusergift.csb',
	{
		_option={prefix='Panel_Main.Panel_Animation.'},
		panelInitStatus='Panel_InitStatus',
        {
            _option={prefix='Panel_InitStatus.'},
            ProjectNode1 = "NodeInitStatus",
       
        },
        panelCountStatus = 'Panel_CountStatus',
        {
            _option={prefix='Panel_CountStatus.'},
            ProjectNode2 = "NodeCountStatus",
           
        },
        panelClick = "Panel_click",
        panelHelp = "Panel_help",
        {
            _option={prefix='Panel_help.'},
            BtnHelpclose = "Btn_helpclose",
            {
                _option={prefix='ScrollView.'},
                textHelp = "Text_help",
            }
            
            
        },
        ButtonClose = "Button_close",
	}
}

return viewCreator
