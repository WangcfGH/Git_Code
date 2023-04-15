--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local viewCreator=cc.load('ViewAdapter'):create()

viewCreator.viewConfig={
    'res/hallcocosstudio/arena/Layer_arenareward.csb',
	{
		_option={prefix='Panel_Reward.'},
        closeBt='Btn_Close',
        scoreCheck="CheckBox_ScoreReward",
        rankCheck="CheckBox_RankReward",
        scorePanel="Panel_ScoreReward",
        rankPanel="Panel_RankReward",
		{
			_option={prefix='Panel_ScoreReward.'},
            scoreScorllView="ScrollView_ScoreReward",
        },
        {
			_option={prefix='Panel_RankReward.'},
            rankScorllView="ScrollView_RankReward",
        },
        scrollBar="Img_ScrollbarBG.Img_Scrollbar",
    },
    ["popupAni"] = {
        ["aniName"] = "scaleandshake",
        ["aniNode"] = "Panel_Reward",
        ["isPlayAni"] = true
    }
}
return viewCreator


--endregion
