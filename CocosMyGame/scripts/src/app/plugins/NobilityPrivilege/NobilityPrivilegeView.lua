local NobilityPrivilegeView = cc.load('ViewAdapter'):create()

NobilityPrivilegeView.PATH_NODE_NOBILITYPRIVILEGEITEM = "res/hallcocosstudio/NobilityPrivilege/NobilityPrivilegeItem.csb"

NobilityPrivilegeView.viewConfig={
	"res/hallcocosstudio/NobilityPrivilege/NobilityPrivilege.csb",
    {
        PanelMain = "Panel_Main",
        PanelAnimation = "Panel_Main.Panel_Animation",
        {
            _option		= {prefix ='Panel_Main.Panel_Animation.'},
            PanelNobilityInfo = "Panel_NobilityInfo",
            ScrollInfo       = "Panel_NobilityInfo.ScrollView",
            PanelNobilityInfoNext = "Panel_NobilityInfoNext",
            ScrollInfoNext       = "Panel_NobilityInfoNext.ScrollView",
            PanelDayGift = "Panel_DayGift",
            AniDayGift = "Panel_DayGift.Ani_TakeDaily",
            BtnDayGift = "Panel_DayGift.Button_Box",
            PanelWeeklyGift = "Panel_WeeklyGift",
            AniWeeklyGift = "Panel_WeeklyGift.Ani_TakeWeekly",
            BtnWeekGift = "Panel_WeeklyGift.Button_Box",
            PanelMonthGift = "Panel_MonthGift",
            AniMonthGift = "Panel_MonthGift.Ani_TakeMonth",
            BtnMonthGift = "Panel_MonthGift.Button_Box",
            PanelUpgradeGift = "Panel_UpgradeGift",
            AniUpgradeGift = "Panel_UpgradeGift.Ani_TakeUpgrade",
            BtnUpgradeTake = "Panel_UpgradeGift.Button_UpgradeTake",
            BtnUpgradeGift = "Panel_UpgradeGift.Button_Gift",
            FntUpgradeGiftLevel    = "Panel_UpgradeGift.Fnt_Level",
            FntLevel1    = "Fnt_Level1",
            FntLevel2    = "Fnt_Level2",
            FntLevel3    = "Fnt_Level3",
            FntLevel4    = "Fnt_Level4",
            BtnShop = "Button_Shop",
            BtnLeft = "Button_Left",
            BtnRight = "Button_Right",
		    closeBtn = "Button_Close",
        }
    }
}

return NobilityPrivilegeView

