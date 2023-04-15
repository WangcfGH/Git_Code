local LuckyCatView = cc.load('ViewAdapter'):create()

LuckyCatView.PATH_NODE_LUCKYCATITEM = "res/hallcocosstudio/LuckyCat/LuckyCatNode.csb"

LuckyCatView.viewConfig={
	"res/hallcocosstudio/LuckyCat/LuckyCat.csb",
    {
        PanelMain = "Panel_Main",
        PanelAnimation = "Panel_Main.Panel_Animation",
        {
            _option		= {prefix ='Panel_Main.Panel_Animation.'},
            tabList		= 'Panel_Tab',
            TextTips  = "Text_Tips",
		    BtnClose = "Button_Close",
            BtnHelp = "Button_Help",
            PanelDayTask = "Panel_DayTask",
            PanelDayTaskTips    = "Panel_DayTask.Panel_Tips",
            PanelProgress    = "Panel_DayTask.Panel_Progress",
            DayScrollInfo = "Panel_DayTask.ScrollView",
            PanelWelfareTask = "Panel_WelfareTask",
            WelfareScrollInfo = "Panel_WelfareTask.ScrollView",
            PanelInfo = "Panel_Info",
            {
                _option		    = {prefix ='Panel_Info.'},
                ImgIcon         = "Image_Icon",
                PanelFishBtn    = "Panel_FishBtn",
                {
                    _option		    = {prefix ='Panel_FishBtn.'},
                    BtnUpdate       = "Image_Btn",
                    ImgFish         = "Image_Fish",
                    TxtSelfNum      = "Text_SelfNum",
                    TxtTotalNum     = "Text_TotalNum",
                    TxtMultip       = "Text_Multip",
                    BtnUnlock       = "Button_Unlock",
                    TxtMultipFish   = "Text_Multip_Finish",
                },
                TxtLockCount    = "Text_LockCount",
                TextFishTips    = "Text_Tips",
                PanelBubble     = "Panel_Bubble",
                {
                    _option		    = {prefix ='Panel_Bubble.'},
                    TextFishTips2   = "Text_Tips2",
                }
            }
        },
        aniCap = "Ani_Cap",
    }
}

function LuckyCatView:onCreateView(viewNode)
    function viewNode:initTabs(nTabsNum, nDefaultIndex, pCallBackList)
        local pPanel = viewNode.tabList
        pPanel:setVisible(true)
        local baseTabs = import("src.app.GameHall.ctrls.BaseTab")
        baseTabs:create(pPanel, nTabsNum, nDefaultIndex, pCallBackList)
    end
end

return LuckyCatView

