local viewCreator=cc.load('ViewAdapter'):create()

viewCreator.bResetSize = true
viewCreator.viewConfig = {
    'res/hallcocosstudio/TimingGame/TimingGameRank.csb',
    {
    	panelMain='Img_MainBox',
    	{
			_option = {prefix='Img_MainBox.'},
			btnClose ='Btn_Close',
			{
				_option = {prefix='Panel_Records.'},
				panelScroller = 'Panel_Scrollbar',
				sroller = 'Panel_Scrollbar.Img_Dot',
				listRankView = 'ListView_Item',
				listTabView = 'ListView_Tab',
				panelSelfItem = 'Panel_SelfRankItem',
				{
					_option = {prefix='Panel_SelfRankItem.'},
					selfRankIcon = 'Img_RankIcon',
					selfTextRank = 'Text_Rank',
					selfTextUserName = 'Text_UserName',
					selfTextScore = 'Text_Score',
					selfRewardIcon1 = 'Img_RewardIcon1',
					selfRewardIcon2 = 'Img_RewardIcon2',
					selfTextRewardNum1 = 'Text_RewardNum1',
					selfTextRewardNum2 = 'Text_RewardNum2',
					selfTextNoReward = 'Text_NoReward',
				}
			},
			panelNoRecord = 'Panel_NoRecord',
			panelRecords = 'Panel_Records',
    	}
    }
}
function viewCreator:onCreateView(viewNode,...)
	if not viewNode then return end

	viewNode.listRankView:removeAllItems()
	viewNode.listTabView:removeAllItems()
	
    viewNode.scrollBar = cc.load("myccui").ScrollBar:create(viewNode.panelScroller, viewNode.sroller, viewNode.listRankView)
end

return viewCreator