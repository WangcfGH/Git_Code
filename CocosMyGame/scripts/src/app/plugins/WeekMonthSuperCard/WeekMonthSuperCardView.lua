local viewCreator=cc.load('ViewAdapter'):create()

viewCreator.bResetSize = true
viewCreator.viewConfig = {
    'res/hallcocosstudio/WeekMonthSuperCard/WeekMonthSuperCard.csb',
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
					nodeWeekAni = 'week_card_bg_ani',
					txtWeekValidDate = 'Fnt_ValidDate',
					txtWeekTotalValue = 'Fnt_TotalValue',
					txtWeekOnceSliver = 'Text_Once',
					txtWeekDailySliver = 'Text_Daily',
					btnWeekBuy = 'Button_Buy',
					txtWeekPrice = 'Fnt_Price',					
				},
				--月卡购买界面
				PanelMonth ='Panel_Month',
				{
					_option={prefix='Panel_Month.'},
					nodeMonthAni = 'month_card_bg_ani',
					txtMonthValidDate = 'Fnt_ValidDate',
					txtMonthTotalValue = 'Fnt_TotalValue',
					txtMonthOnceSliver = 'Text_Once',
					txtMonthDailySliver = 'Text_Daily',
					btnMonthBuy = 'Button_Buy',
					txtMonthPrice = 'Fnt_Price',	
				},
				--至尊卡购买界面
				PanelSuper ='Panel_Super',
				{
					_option={prefix='Panel_Super.'},
					nodeSuperAni = 'super_card_bg_ani',
					txtSuperValidDate = 'Fnt_ValidDate',
					txtSuperTotalValue = 'Fnt_TotalValue',
					txtSuperOnceSliver = 'Text_Once',
					txtSuperDailySliver = 'Text_Daily',
					btnSuperBuy = 'Button_Buy',
					txtSuperPrice = 'Fnt_Price',	
				},					
				btnClose ='Btn_Close',
			},
    	}
    }
}

function viewCreator:onCreateView(viewNode,...)
	if not viewNode then return end
end

return viewCreator