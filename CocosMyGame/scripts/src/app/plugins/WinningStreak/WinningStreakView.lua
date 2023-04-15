local viewCreator 	=cc.load('ViewAdapter'):create()

viewCreator.viewConfig={
    'res/hallcocosstudio/activitycenter/WinningStreak.csb',
    {
        Panel_Main = 'Panel_Main',
        {
            _option={prefix='Panel_Main.'},
            Panel_Shade = 'Panel_Shade',
            Img_GameBg = "Img_GameBg",
            Img_BottomBg = "Img_BottomBg",
            Fnt_FanBei = 'Fnt_FanBei',
            tabList		= 'Panel_Tab',
            Panel_Progress = 'Panel_Progress',
            Btn_Open = "Button_Open",
            {
                _option={prefix='Button_Open.'},
                Fnt_StartChallenge = "Fnt_StartChallenge",
                Fnt_StartChallenge_Middle = "Fnt_StartChallenge_Middle",
                Img_Silver = "Image_Silver",
                Txt_RemainingCount = "Text_RemainingCount",
            },
            Btn_Open_NotTime = "Button_Open_NotTime",
            Panel_NoChallenge = "Panel_NoChallenge",
            Img_NineStreak = "Img_NineStreak",
            Fnt_Silver = "Img_NineStreak.Fnt_Silver",

            Btn_Help = "Button_Help",
            Panel_Challenge = "Panel_Challenge",
            {
                _option={prefix='Panel_Challenge.'},
                Txt_WinBout = "Text_WinBout",
                Fnt_JackpotDeposit = "Fnt_JackpotDeposit",
            },
            Btn_Play = "Button_Play",
            Btn_Award = "Button_Award",
            Ani_Award = "Button_Award.Ani_Award",
            Btn_Award_Middle = "Button_Award_Middle",
            Btn_Award_Double = "Button_Award_Double",
            Ani_Award_Double = "Button_Award_Double.Ani_Award_Double",
            Fnt_Award_Double = "Button_Award_Double.Fnt_Award_Double",
            Txt_Award_Double = "Button_Award_Double.Text_Award_Double",
            Btn_Close = "Btn_Close",
        }
    }
}

function viewCreator:onCreateView(viewNode)
    function viewNode:initTabs(nTabsNum, nDefaultIndex, pCallBackList)
        local pPanel = viewNode.tabList
        pPanel:setVisible(true)
        local baseTabs = import("src.app.GameHall.ctrls.BaseTab")
        baseTabs:create(pPanel, nTabsNum, nDefaultIndex, pCallBackList)
    end
end

return viewCreator