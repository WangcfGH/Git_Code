local viewCreator = cc.load('ViewAdapter'):create()

viewCreator.viewConfig = {
    'res/hallcocosstudio/PeakRank/Layer_PeakRank.csb',
    {
        panelShade = 'Panel_Shade',
        panelMain = 'Panel_Main',
        {
            _option = {
                prefix = 'Panel_Main.'
            },
            panelAnimation = 'Panel_Animation',
            {
                _option = {
                    prefix = 'Panel_Animation.',
                },
                btnClose = 'Btn_Close',
                btnRule = 'Btn_Rule',
                textRankDate = 'Text_RankDate',
                textRankTip = 'Text_RankTip',
                titleMyRankNO = 'Title_MyRankNO',
                textMyRankNO = 'Text_MyRankNO',
                titleMyRankValue = 'Title_MyRankValue',
                textMyRankValue = 'Text_MyRankValue',
                panelRankTypeRadios = 'Panel_RankTypeRadios',
                imgTotalReward = 'Img_TotalReward',
                {
                    _option = {
                        prefix = 'Img_TotalReward.'
                    },
                    titleTotalReward = 'Title_TotalReward',
                    textTotalRewardTip = 'Text_TotalRewardTip',
                    panelRollReward = 'Panel_RollReward'
                },
                panelDayTypeRadios = 'Panel_DayTypeRadios',
                panelAreaType = 'Panel_AreaType',
                {
                    _option = {
                        prefix = 'Panel_AreaType.'
                    },
                    panelAreaTypeRadios = 'Panel_AreaTypeRadios',
                },

                panelRankList = 'Panel_RankList',
                {
                    _option = {
                        prefix = 'Panel_RankList.'
                    },
                    titleRankValue = 'Title_RankValue',
                    titleThumbsUp = 'Title_ThumbsUp',
                    titleTotalThumbsUp = 'Title_TotalThumbsUp',
                    textNoData = 'Text_NOData',
                    listViewRank = 'ListView_Rank',
                    panelLoading = 'Panel_Loading',
                    imgLoading = 'Panel_Loading.Img_Loading',
                },

                nodeRewardPoolAni = 'Node_RewardPoolAni',
                nodeGotoPlayBtnAni = 'Node_GotoPlayBtnAni',
                textFirstUserName = 'Text_FirstUserName',
            }
        }
    }
}

function viewCreator:onCreateView(viewNode)
end

return viewCreator
