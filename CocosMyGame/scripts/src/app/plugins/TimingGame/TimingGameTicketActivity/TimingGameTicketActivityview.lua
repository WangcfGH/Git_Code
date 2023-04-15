
local viewCreator=cc.load('ViewAdapter'):create()

viewCreator.viewConfig={
    'res/hallcocosstudio/activitycenter/TimingGameTicketActivity.csb',
	{
		Panel_Main = 'Panel_Main',
        {
            _option={prefix='Panel_Main.'},
            Button_go = "Button_go",
            --经典房和非洗牌区
            txt1_1 = "Text_1_1",
            txt1_2 = "Text_1_2",
            txt1_3 = "Text_1_3",
            txt1_4 = "Text_1_4",
            --对局数
            txt2_1 = "Text_2_1",
            txt2_2 = "Text_2_2",
            txt2_3 = "Text_2_3",
            txt2_4 = "Text_2_4",
            --获取的奖励
            txt3_1 = "Text_3_1",
            txt3_2 = "Text_3_2",
            txt3_3 = "Text_3_3",
            txt3_4 = "Text_3_4",
        }
	}
}

return viewCreator
