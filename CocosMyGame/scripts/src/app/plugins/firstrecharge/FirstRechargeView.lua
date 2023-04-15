local FirstRechargeView = cc.load('ViewAdapter'):create()

FirstRechargeView.viewConfig={
	"res/hallcocosstudio/FirstRecharge/FirstRecharge.csb",
    {
        PanelMain = "Panel_Main",
        PanelAnimation = "Panel_Main.Panel_Animation",
        {
            _option		= {prefix ='Panel_Main.Panel_Animation.'},
		    closeBtn = "Image_Title.Button_Close",
            Fnt_Price = "Image_Title.Fnt_Price",
            Img_Title = "Image_Title", --首充标题
            BtnBuy = "Button_Buy",
        }
    }
}

function FirstRechargeView:onCreateView(viewNode)
    
end

return FirstRechargeView

