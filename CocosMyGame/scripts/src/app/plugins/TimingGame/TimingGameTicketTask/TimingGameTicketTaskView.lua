local viewCreator=cc.load('ViewAdapter'):create()

viewCreator.bResetSize = true
viewCreator.viewConfig = {
    'res/hallcocosstudio/TimingGame/TimingGameTicketTask.csb',
    {
    	panelMain='Panel_Main',
    	{
			_option = {prefix='Panel_Main.'},
			btnClose ='Btn_Close',
			btnToPlay = 'Btn_ToPlay',
			txtTodayBout = 'Text_TodayBoutDesc.Text_TodayBout',
			txtTotalBout = 'Text_TodayBoutDesc.Text_TotalBout',
			

			{
				_option = {prefix='LoadingBarBg.'},
				loadingBar = 'LoadingBar',
				loadingBarItem1 = 'LoadingBar.Item_Reward1',
				loadingBarItem2 = 'LoadingBar.Item_Reward2',
				loadingBarItem3 = 'LoadingBar.Item_Reward3',
				loadingBarItem4 = 'LoadingBar.Item_Reward4',
			},


			panelItem1 = 'Panel_Item1',
			panelItem2 = 'Panel_Item2',
			panelItem3 = 'Panel_Item3',
			panelItem4 = 'Panel_Item4',
    	}
    }
}

function viewCreator:onCreateView(viewNode,...)
	if not viewNode then return end
end

return viewCreator