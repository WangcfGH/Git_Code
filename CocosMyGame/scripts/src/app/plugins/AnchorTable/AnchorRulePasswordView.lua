local viewCreator=cc.load('ViewAdapter'):create()

viewCreator.bResetSize = true
viewCreator.viewConfig = {
    'res/hallcocosstudio/AnchorRoom/AnchorRoomRulePassword.csb',
    {
    	panelMain='Panel_Main',
    	{
			_option = {prefix='Panel_Main.'},
			panelAnimation = 'Panel_Animation',
	        {
				_option={prefix='Panel_Animation.'},
                panelSetRule = 'Panel_SetRule',
				{
					_option={prefix='Panel_SetRule.'},
					panelRuleBout = 'Panel_Rule_Bout',
					{
						_option={prefix='Panel_Rule_Bout.'},
						checkBoxOneBout = 'CheckBox_OneBout',
						checkBoxPassEight = 'CheckBox_PassEight',
						checkBoxPassA = 'CheckBox_PassA',
					},
					panelRulePlay = 'Panel_Rule_PlayeRule',
					{
						_option={prefix='Panel_Rule_PlayeRule.'},
						checkBoxNoShuffle = 'CheckBox_NoShuffle',
						checkBoxClassic = 'CheckBox_Classic',
					},
					panelRuleEncryption = 'Panel_Rule_Encryption',
					{
						_option={prefix='Panel_Rule_Encryption.'},
						checkBoxEncryption = 'CheckBox_Encryption',
						btnSetPassword = 'Btn_SetPassword',	
						txtTipClick = 'Btn_SetPassword.Txt_Tip_Click',
						txtTipFormat = 'Btn_SetPassword.Txt_Tip_Format',
					},
					btnSure = 'Btn_Sure',
					btnClose = 'Btn_Close',
				},
				panelSetPassword = 'Panel_SetPassword',
				{
					_option={prefix='Panel_SetPassword.'},
					imgTitleSetPs = 'Img_Title_SetPassword',
					imgTitleJoinPs = 'Img_Title_JoinPassword',
					txtPsValue1 = 'Img_PS_Value_Bg.Txt_PS_Vule_1',
					txtPsValue2 = 'Img_PS_Value_Bg.Txt_PS_Vule_2',
					txtPsValue3 = 'Img_PS_Value_Bg.Txt_PS_Vule_3',
					txtPsValue4 = 'Img_PS_Value_Bg.Txt_PS_Vule_4',
					scrollViewPassword = 'ScrollView_Password',
					{
						_option={prefix='ScrollView_Password.'},
						btnNum1 = 'Num_1',
						btnNum2 = 'Num_2',
						btnNum3 = 'Num_3',
						btnNum4 = 'Num_4',
						btnNum5 = 'Num_5',
						btnNum6 = 'Num_6',
						btnNum7 = 'Num_7',
						btnNum8 = 'Num_8',
						btnNum9 = 'Num_9',
						btnNum0 = 'Num_0',
						btnNumReset = 'Num_Reset',
						btnNumBack = 'Num_Back',
					},					
					btnClosePs = 'Btn_Colse',
				},
			},
    	},
		panelDisOpe='Panel_ShadeDisOpe',
    }
}

function viewCreator:onCreateView(viewNode,...)
    if not viewNode then return end
end

return viewCreator