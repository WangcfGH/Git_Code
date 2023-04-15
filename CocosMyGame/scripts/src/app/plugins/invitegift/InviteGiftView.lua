
local viewCreator=cc.load('ViewAdapter'):create()

viewCreator.viewConfig={
    'res/hallcocosstudio/invite/invitegift.csb',
	{
		_option={prefix='Panel_Main.Panel_Animation.'},
		closeBt='Btn_Close',
		{
			_option={prefix='Panel_YourGift.'},
			yourGiftList='Scroll_ItemsList',
		},
		{
			_option={prefix='Panel_FriendGift.'},
			friendGiftList='Scroll_ItemsList',
		},
		shareToWechat='Btn_Wechat',
		shareToFriendsCorner='Btn_Friend',
	}
}

return viewCreator
