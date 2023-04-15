-- InviteGiftAwardView

local viewCreator=cc.load('ViewAdapter'):create()

viewCreator.viewConfig={
    'res/hallcocosstudio/invitegiftactive/olduser/invitegiftpanel.csb',
	{
		_option={prefix='Panel_Main.'},
		rootNode = "Panel_Animation",
		{
			_option={prefix='Panel_Animation.'},
			closeBt='Btn_Close',
			helpBt='Btn_help',
			inviteBt = "Btn_invite",
			imageQipao = "Image_qipao",
			panelHelp = "Panel_help",
			textActiveTime = "Text_active_time",
			panelClick = "Panel_click",
			imageListContent = "ImageListContent",
			userlistBt='Btn_user_list', 
			textTipContents = "Text_TipContents",
			titleAni = "ProjectNode_1",
			{
				_option={prefix='Panel_help.'},
				btnHelpclose = "Btn_helpclose",
				{
					_option={prefix='ScrollView_1.'},
            		textHelp='Text_help',
				}
				
			},

			{
				_option={prefix='ImageListContent.'}, 
				listUser='List_User', 
			},
			
		}
	}
}

return viewCreator
