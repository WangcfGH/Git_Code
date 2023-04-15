local viewCreator=cc.load('ViewAdapter'):create()

viewCreator.bResetSize = true
viewCreator.viewConfig = {
    'res/hallcocosstudio/vivoPrivilegeStartUp/VivoPrivilegeStartUp.csb',
    {
    	panelMain='Panel_Main',
    	{
			_option = {prefix='Panel_Main.'},
			panelAnimation = 'Panel_Animation',
	        {
				_option={prefix='Panel_Animation.'},
				panelVivo ='Panel_VivoPrivilegeStartUp',
				{
					_option={prefix='Panel_VivoPrivilegeStartUp.'},										
					panelAnimation = 'Panel_Item1',
	        		{
						_option={prefix='Panel_Item1.'},
						itemImg1 = 'Img_Item',
						itemText1 = 'Text_Count',
					},
					panelAnimation = 'Panel_Item2',
	        		{
						_option={prefix='Panel_Item2.'},
						itemImg2 = 'Img_Item',
						itemText2 = 'Text_Count',
					},
					panelAnimation = 'Panel_Item3',
	        		{
						_option={prefix='Panel_Item3.'},
						itemImg3 = 'Img_Item',
						itemText3 = 'Text_Count',
					},
					btnStartUp = 'Btn_StartUp',
					btnReceive = 'Btn_Receive',
					btnReceived = 'Btn_Received',
				},
				btnClose ='Btn_Close',
			},
    	}
    }
}

function viewCreator:onCreateView(viewNode,...)
    if not viewNode then return end
end

return viewCreator