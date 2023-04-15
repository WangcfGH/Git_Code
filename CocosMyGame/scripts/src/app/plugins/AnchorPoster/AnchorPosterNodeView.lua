
local AchorPosterNodeView = {
	Width  = 400,
    CsbPath = 'res/hallcocosstudio/AnchorPoster/AnchorNode.csb',

	ViewConfig = {
		imgBg="ImgBg",
		{
			_option={prefix='ImgBg.'},
			txtAnchorName	= "Txt_AnchorName",
			imgPoster		= "Img_Poster",
            txtAnchorTime	= "Panel_Time.Text_AnchorTime",
            txtAchorID 		= "Img_AnchorIDBg.Value_AnchorID",
			btnCopyAnchorID = "Btn_CopyAnchorID",		
			txtWechatID 	= "Img_WechatID.Value_WechatID",
			btnCopyWechatID = "Btn_CopyWechatID"
		}
	}
}

return AchorPosterNodeView