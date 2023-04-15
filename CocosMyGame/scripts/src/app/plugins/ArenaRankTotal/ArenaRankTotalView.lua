local viewCreator = cc.load('ViewAdapter'):create()

viewCreator.viewConfig={
	'res/hallcocosstudio/arena/layer_celebrity.csb',
	{
        theBkList = 'Panel_Celebrity',
        {
		    _option = {prefix='Panel_Celebrity.'},
            rankList = "Panel_ScoreCelebrity.ScrollView_ScoreCelebrity",
            selfRankPanel = "Panel_ScoerSelf",
            {
                _option = {prefix='Panel_ScoerSelf.'},
                selfRankFnt = "Fnt_RankNum",
                selfNameFnt = "Text_SelfName",
                selfScoreFnt = "Img_MaxScore.Text_MaxScoreValue_3",
            },
            closeBtn = "Btn_Close",
            scrollBar="Img_ScrollbarBG.Img_Scrollbar",
        }
	}
}

return viewCreator