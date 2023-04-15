local NobilityPrivilegeGiftView = cc.load('ViewAdapter'):create()

NobilityPrivilegeGiftView.viewConfig={
	"res/hallcocosstudio/NobilityPrivilege/NobilityPrivilegeGift.csb",
    {
        PanelMain = "Panel_Main",
        PanelAnimation = "Panel_Main.Panel_Animation",
        {
            _option		= {prefix ='Panel_Main.Panel_Animation.'},
            PanelSilver = "Panel_Silver",
            PanelNobility = "Panel_Nobility",
            ListViewTip   = "ListView_Tip",
		    closeBtn = "Button_Close",
            Txt_RemainTime = "Text_RemainTime",
            BtnBuy = "Button_Buy",
        }
    }
}
return NobilityPrivilegeGiftView

