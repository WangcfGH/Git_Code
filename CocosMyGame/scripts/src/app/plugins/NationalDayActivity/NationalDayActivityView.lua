
local TabView=cc.load('myccui').TabView
local viewCreator=cc.load('ViewAdapter'):create()

viewCreator.viewConfig={
	'res/hallcocosstudio/NationalDayActivity/NationalDayActivity.csb',
	{
        mainPanel = "Panel",
        {
            _option={prefix='Panel.'},
            closeBt = 'Btn_Back',
            {
    		    _option={prefix='Panel_Area.'},
    		    BtnToday='Button_today',
    		    BtnTotal='Button_total',
    		    BtnYesterday='Button_yesterday',
            },
            ScrollView = 'ScrollView',
            warning = "warning",
            warning2 = "warning2",
            BtnRule = "Button_Rule",
            BtnStartGame = "Button_StartGame",
            NodeSelfNo = "Node_SelfNo",
            avtivityInfo = "avtivityInfo",
            {
                _option={prefix='avtivityInfo.'},
                dateTime = "time"
            }

        }
        
    },
    ["popupAni"] = {
        ["aniName"] = "scaleandshake",
        ["aniNode"] = "Panel",
        ["isPlayAni"] = true
    }
}

return viewCreator
