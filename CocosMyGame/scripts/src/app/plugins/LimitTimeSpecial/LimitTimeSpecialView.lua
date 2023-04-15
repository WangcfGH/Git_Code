local LimitTimeSpecialView = cc.load('ViewAdapter'):create()

LimitTimeSpecialView.viewConfig={
	"res/hallcocosstudio/LimitTimeSpecial/limitTimeSpecial.csb",
    {
        PanelMain = "Panel_Main",
        PanelAnimation = "Panel_Main.Panel_Animation",
        {
            _option		= {prefix ='Panel_Main.Panel_Animation.'},
		    closeBtn = "Image_Title2.Button_Close",
            Fnt_Price = "Image_Title2.Fnt_Price",
            Img_Title = "Image_Title2", --限时礼包标题
            Txt_RemainTime = "Text_RemainTime",
            BtnBuy = "Button_Buy",
        }
    }
}

return LimitTimeSpecialView