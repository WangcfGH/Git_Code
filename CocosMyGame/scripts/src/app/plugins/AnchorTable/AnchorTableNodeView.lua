
local AchorPosterNodeView = {
	Width  = 400,
    CsbPath = 'res/hallcocosstudio/AnchorRoom/AnchorRoomTableNode.csb',

	ViewConfig = {
		imgNoneBg="Img_NoneBg",
		imgBg="Img_Bg",
		{
			_option={prefix='Img_Bg.'},
			imgTableLock = 'Img_Table_Lock',
			player1 = 'player_1',
			{
				_option={prefix='player_1.'},
				btnWaitJoin1 = 'Btn_Wait_Join',
				imgBoyHead1 = 'Img_Boy_Head',
				imgGirlHead1 = 'Img_Girl_Head',
				txtNickName1 = 'Img_NickNameBg.Text_NickName',
			},
			player2 = 'player_2',
			{
				_option={prefix='player_2.'},
				btnWaitJoin2 = 'Btn_Wait_Join',
				imgBoyHead2 = 'Img_Boy_Head',
				imgGirlHead2 = 'Img_Girl_Head',
				txtNickName2 = 'Img_NickNameBg.Text_NickName',
			},
			player3 = 'player_3',
			{
				_option={prefix='player_3.'},
				btnWaitJoin3 = 'Btn_Wait_Join',
				imgBoyHead3 = 'Img_Boy_Head',
				imgGirlHead3 = 'Img_Girl_Head',
				txtNickName3 = 'Img_NickNameBg.Text_NickName',
			},
			player4 = 'player_4',
			{
				_option={prefix='player_4.'},
				btnWaitJoin4 = 'Btn_Wait_Join',
				imgBoyHead4 = 'Img_Boy_Head',
				imgGirlHead4 = 'Img_Girl_Head',
				txtNickName4 = 'Img_NickNameBg.Text_NickName',
			}
		}
	}
}

return AchorPosterNodeView