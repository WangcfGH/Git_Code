

local viewCreator=cc.load('ViewAdapter'):create()

viewCreator.viewConfig={
    'res/hallcocosstudio/invitegiftactive/olduser/activehelppanel.csb',
	{
        panelShade          = "Panel_Shade",
        panelMain          = "Panel_Main",
        {
            _option={prefix='Panel_Main.Panel_Animation.Panel_help.'},
            ScrollView = "ScrollView", 
            Text_help = "ScrollView.Text_help",
            Text_help_t = "Text_help_t",
            closeBt = "Btn_helpclose",
        }
		
	}
}

return viewCreator
