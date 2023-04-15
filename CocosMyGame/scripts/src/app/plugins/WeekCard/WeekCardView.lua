local viewCreator=cc.load('ViewAdapter'):create()

viewCreator.bResetSize = true
viewCreator.viewConfig = {
    'res/hallcocosstudio/WeekCard/WeekCard.csb',
    {
    	panelMain='Panel_Main',
    	{
			_option = {prefix='Panel_Main.'},
			panelAnimation = 'Panel_Animation',
	        {
				_option={prefix='Panel_Animation.'},

				--周卡购买界面
				panelWeek ='Panel_Week',
				{
					_option={prefix='Panel_Week.'},
					txtBuyCount1 = 'Panel_Silver1.Text_Count',
					txtBuyCount2 = 'Panel_Silver2.Text_Count',
					btnBuy = 'Btn_Get',
					txtBtnCannot = 'Btn_Get.Text_1',
					txtBtnBuy = 'Btn_Get.Text_Desc',
					txtTitle = 'Text_Title2',
				},
				--周卡每日领取界面
				panelWeekDaily ='Panel_WeekDaily',
				{
					_option={prefix='Panel_WeekDaily.'},
					txtDay = 'Img_Ribbon.Text_3',
					txtTakeCount = 'Panel_Silver.Text_Count',
					btnTake = 'Btn_Get',
					txtBtnTake = 'Btn_Get.Text_Desc',
				},
				--月卡购买界面
				panelMonth ='Panel_Month',
				{
					_option={prefix='Panel_Month.'},
				},
				--月卡每日领取界面
				panelMonthDaily ='Panel_MonthDaily',
				{
					_option={prefix='Panel_MonthDaily.'},
				},
				
				imgBg ='Img_Background',
				btnMonth ='Btn_Month',
				dotMonth = 'Btn_Month.Img_Dot',
				btnWeek ='Btn_Week',
				dotWeek = 'Btn_Week.Img_Dot',
				btnClose ='Btn_Close',
			},
    	}
    }
}

function viewCreator:onCreateView(viewNode,...)
	if not viewNode then return end
	self:init(viewNode)
end

function viewCreator:init(viewNode)
	viewNode.panelWeek:setVisible(false)
	viewNode.panelWeekDaily:setVisible(false)
	viewNode.panelMonth:setVisible(false)
	viewNode.panelMonthDaily:setVisible(false)
	viewNode.btnMonth:setVisible(false)
	viewNode.btnWeek:setVisible(false)
	viewNode.dotMonth:setVisible(false)
	viewNode.dotWeek:setVisible(false)
end


return viewCreator