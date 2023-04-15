local viewCreator = cc.load('ViewAdapter'):create()

viewCreator.viewConfig={
	'res/hallcocosstudio/ArenaRank/ArenaRankTakeReward.csb',
	{
        bottomPanel = "Panel_Bottom",
        theBkList = 'Image_Bk',
        {
            _option = {prefix='Image_Bk.'},
            rankText = "Text_RankNum",
            scoreText = "Text_ScoreNum",
            rewardNode1 = "Node_SliverReward",
            rewardNode2 = "Node_ExchangeReward",
            closeBtn = "Button_Close"
        }
	}
}

return viewCreator
