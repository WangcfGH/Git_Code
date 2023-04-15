
local viewCreator=cc.load('ViewAdapter'):create()

viewCreator.viewConfig={
     'res/hallcocosstudio/activitycenter/WinningStreakRule.csb',
    {
        Operate_Panel = "Operate_Panel",
		{
            _option = {prefix = 'Operate_Panel.'},
		    Panel_Rule = "Panel_Rule",
            {
                _option = {prefix = 'Panel_Rule.'},
                Img_RuleBG = "Img_RuleBG",
                { 
                    _option = {prefix = 'Img_RuleBG.'},
                    closeBt = "Btn_Close",
                }
            }
        }
    }
}

return viewCreator

