
local viewCreator=cc.load('ViewAdapter'):create()

viewCreator.viewConfig={
    'res/hallcocosstudio/share/share.csb',
	{
		_option={prefix='Img_MainBox.'},
		closeBt='Btn_Close',
		shareToMicroBlogBt='Btn_Weibo',
		shareToWechat='Btn_SNS',
		shareToFriendsCorner='Btn_Wechat',
        qrCodeBg='Img_QRCodeBG',
        codeBg='Img_QRCode'
	},
    ["popupAni"] = {
        ["aniName"] = "scale",
        ["aniNode"] = "Img_MainBox",
        ["isPlayAni"] = true
    }
}

return viewCreator
