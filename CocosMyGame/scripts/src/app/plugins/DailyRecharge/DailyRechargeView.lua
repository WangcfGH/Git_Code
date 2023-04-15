local viewCreator=cc.load('ViewAdapter'):create()

viewCreator.bResetSize = true
viewCreator.viewConfig = {
    'res/hallcocosstudio/activitycenter/dailyrecharge.csb',
    {
    	panelMain='Panel_Main',
    	{
			_option = {prefix='Panel_Main.'},
			txtTotalPrice = 'Text_Tip_Price',
			txtTotalRewardCount = 'Text_Tip_Count',
			txtTodayRecharge = 'Text_Tip_TodayRecharge',
			btnTotal = 'Btn_Total',
			txtBtnTotalDesc = 'Btn_Total.Text_Desc',
			txtOriginalPrice = 'Text_before.fnt_1',
			txtSpecialPrice = 'Text_now.fnt_2',
			btnTotalItme = 'Btn_yijian_buy',
			txtTotalItem = 'Btn_yijian_buy.Text_Desc',
			imgTotalItemTip = 'Btn_yijian_buy.Image_Tip',			
			txtTotalIip = 'Btn_yijian_buy.Image_Tip.Text_jm',
			panelTask1 = 'ListView.Panel_Task1',
			{
				_option = {prefix='ListView.Panel_Task1.'},
				txtTip1 = 'Text_Tip',
				imgAward1_1 = 'Panel_Award1.Img_Award',
				txtCount1_1 = 'Panel_Award1.Text_Count',
				imgAward1_2 = 'Panel_Award2.Img_Award',
				txtCount1_2 = 'Panel_Award2.Text_Count',
				btnTake1 = 'Btn_Take',
				txtDescTake1 = 'Btn_Take.Text_Desc',
			},
			panelTask2 = 'ListView.Panel_Task2',
			{
				_option = {prefix='ListView.Panel_Task2.'},
				txtTip2 = 'Text_Tip',
				imgAward2_1 = 'Panel_Award1.Img_Award',
				txtCount2_1 = 'Panel_Award1.Text_Count',
				imgAward2_2 = 'Panel_Award2.Img_Award',
				txtCount2_2 = 'Panel_Award2.Text_Count',
				btnTake2 = 'Btn_Take',
				txtDescTake2 = 'Btn_Take.Text_Desc',
			},
			panelTask3 = 'ListView.Panel_Task3',
			{
				_option = {prefix='ListView.Panel_Task3.'},
				txtTip3 = 'Text_Tip',
				imgAward3_1 = 'Panel_Award1.Img_Award',
				txtCount3_1 = 'Panel_Award1.Text_Count',
				imgAward3_2 = 'Panel_Award2.Img_Award',
				txtCount3_2 = 'Panel_Award2.Text_Count',
				btnTake3 = 'Btn_Take',
				txtDescTake3 = 'Btn_Take.Text_Desc',
			},
			panelTask4 = 'ListView.Panel_Task4',
			{
				_option = {prefix='ListView.Panel_Task4.'},
				txtTip4 = 'Text_Tip',
				imgAward4_1 = 'Panel_Award1.Img_Award',
				txtCount4_1 = 'Panel_Award1.Text_Count',
				imgAward4_2 = 'Panel_Award2.Img_Award',
				txtCount4_2 = 'Panel_Award2.Text_Count',
				btnTake4 = 'Btn_Take',
				txtDescTake4 = 'Btn_Take.Text_Desc',
			}
    	}
    }
}

function viewCreator:onCreateView(viewNode,...)
    if not viewNode then return end
end

return viewCreator