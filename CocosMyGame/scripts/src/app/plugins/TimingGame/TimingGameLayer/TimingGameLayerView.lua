local viewCreator=cc.load('ViewAdapter'):create()

viewCreator.bResetSize = true
viewCreator.viewConfig = {
    'res/hallcocosstudio/TimingGame/TimingGameLayer.csb',
    {
    	panelMain='Img_MainBox',
    	{
			_option = {prefix='Img_MainBox.'},
			btnRule ='Btn_Rule',
			btnRewardDesc ='Btn_RewardDesc',
			btnRankList ='Btn_RankList',
			btnConfirm ='Btn_Confirm',
			btnClose ='Btn_Close',
			txtRule1 ='Text_RuleDetail1',
			txtRule2 ='Text_RuleDetail2',
			txtRule3 ='Text_RuleDetail3',
			txtRule4 ='Text_RuleDetail4',
			txtRule5 ='Text_RuleDetail5',
			panelReward1 ='Panel_Reward1',
			imgIcon1 ='Panel_Reward1.Img_Icon',
			txtReward1 ='Panel_Reward1.Text_Value',
			panelReward2 ='Panel_Reward2',
			imgIcon2 ='Panel_Reward2.Img_Icon',
			txtReward2 ='Panel_Reward2.Text_Value',
			txtDesc1 ='Text_Desc1',
			txtDesc2 ='Text_Desc2',
			imgCloseTip = 'qipao_2',
    	}
    }
}

function viewCreator:onCreateView(viewNode,...)
	if not viewNode then return end
	
	viewNode.btnRule:setTouchEnabled(false)
	viewNode.btnRewardDesc:setTouchEnabled(false)
	viewNode.btnRankList:setTouchEnabled(false)
	viewNode.btnConfirm:setTouchEnabled(false)
end

return viewCreator