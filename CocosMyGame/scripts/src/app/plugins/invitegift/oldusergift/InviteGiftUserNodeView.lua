local InviteGiftUserNodeView = {
	Height  = 56,
    CsbPath = 'res/hallcocosstudio/invitegiftactive/olduser/node_info_unit.csb',

	ViewConfig =
	{
		backUnit = "Panel_InfoUnit",
		{
			_option={prefix='Panel_InfoUnit.'},
			imgIcon="Img_Icon",
            textName="Text_Name",
			valueScore="Value_Score",
		}
	}
}

return InviteGiftUserNodeView