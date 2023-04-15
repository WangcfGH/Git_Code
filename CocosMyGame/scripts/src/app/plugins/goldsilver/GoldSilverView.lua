local GoldSilverView = cc.load("ViewAdapter"):create()

GoldSilverView.PATH_NODE_AWARDITEM = "res/hallcocosstudio/goldsilver/goldsilveritem.csb"

GoldSilverView.viewConfig = {
    "res/hallcocosstudio/goldsilver/goldsilver.csb",
    {
        Panel_Main = "Panel_Main",
        Operate_Panel = "Operate_Panel",
        {
            _option = {prefix = 'Operate_Panel.'},
            Panel_TopBar ="Panel_TopBar",
            {
                _option = {prefix = 'Panel_TopBar.'},
                Btn_Back = "Btn_Back",
                Panel_Deposit = "Panel_Deposit",
                {
                    _option = {prefix = 'Panel_Deposit.'},
                    Fnt_UserSilver = "Fnt_Value",
                    Btn_Add = "Btn_Add"
                },
                Panel_Clock = "Panel_Clock",
                {
                    _option = {prefix = 'Panel_Clock.'},
                    Text_Days = "Text_2",
                    Text_DuringTime = "Text_3",
                },
                Btn_Rule = "Btn_Rule"
            },
            Panel_Center = "Panel_Center",
            {
                _option = {prefix = 'Panel_Center.'},
                Panel_CenterLeft = "Panel_CenterLeft",
                {
                    _option = {prefix = 'Panel_CenterLeft.'},
                    Img_LevelBG = "Img_LevelBG",
                    {
                        _option = {prefix = 'Img_LevelBG.'},
                        Fnt_Level = "Fnt_Level"
                    },
                    Fnt_Score = "Fnt_Score",
                    LoadingBar_Process = "LoadingBar_Process",
                    Img_SilverCup = "Img_SilverCup",
                    Img_GoldCup = "Img_GoldCup",
                    Img_BG1 = "Img_BG1",
                    {
                        _option = {prefix = 'Img_BG1.'},
                        Text_SilverReward = "Text_SilverReward"
                    },
                    Img_BG2 = "Img_BG2",
                    {
                        _option = {prefix = 'Img_BG2.'},
                        Text_GoldReward = "Text_GoldReward"
                    },
                    Text_SilverCup = "Text_SilverCup",
                    Text_GoldCup = "Text_GoldCup",
                    Img_SilverCover = "Img_SilverCover",
                    Img_SilverLock = "Img_SilverCover.Img_Lock",
                    Img_GoldCover = "Img_GoldCover",
                    Img_GoldLock = "Img_GoldCover.Img_Lock",
                    Panel_UnLock = "Panel_UnLock",
                    {
                        _option = {prefix = 'Panel_UnLock.'},
                        Btn_UnLock = "Btn_UnLock"
                    },
                    Scroll_Reward = "Scroll_Reward",
                    Btn_Arrow = "Btn_Arrow",
                    Btn_GetScore = "Btn_GetScore"
                },
                Btn_OneKeyGet2 = "Btn_OneKeyGet2",
                Panel_OneKetGet = "Panel_OneKetGet",
                {
                    _option = {prefix = 'Panel_OneKetGet.'},
                    Btn_OneKeyGet = "Btn_OneKeyGet"
                },
                Img_Season = "Img_Season",
                {
                    _option = {prefix = 'Img_Season.'},
                    Fnt_Season = "Fnt_Season",
                    Img_ItemBG = "Img_ItemBG",
                    {
                        _option = {prefix = 'Img_ItemBG.'},
                        Img_FreeItem = "Img_Item",
                        Fnt_FreeCount = "Fnt_Num",
                        Img_FreeCover = "Img_Cover"
                    },
                    Img_Tip = "Img_Tip",
                    {
                        _option = {prefix = 'Img_Tip.'},
                        Text_Tip = "Text_Tip"
                    },
                    Img_FreeComplete = "Img_Complete",
                    Btn_Play = "Btn_Play",
                    Btn_FreeTake = "Btn_FreeTake"
                }
            },
            Panel_Rule = "Panel_Rule",
            {
                _option = {prefix = 'Panel_Rule.'},
                Img_RuleBG = "Img_RuleBG",
                {
                    _option = {prefix = 'Img_RuleBG.'},
                    Scroll_Rule = "Scroll_Rule",
                    {
                        _option = {prefix = 'Scroll_Rule.'},
                        Img_Title = "Img_Title",
                        Img_Rule = "Img_Rule",
                        {
                            _option = {prefix = 'Img_Rule.'},
                            Text_DailyScore = "Text_DailyScore"
                        }
                    },                
                    Btn_Close = "Btn_Close"
                }
            }
        }
    }
}

return GoldSilverView