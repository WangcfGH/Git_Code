local viewCreator = cc.load('ViewAdapter'):create()

viewCreator.viewConfig = {
    'res/hallcocosstudio/AnchorLuckyBag/Layer_LuckyBagRewardList.csb',
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
                listViewRewardInfo = 'ListView_RewardInfo',
                imgEmpty = 'Img_Empty',
                panelLoading = 'Panel_Loading',
                {
                    _option = {
                        prefix = 'Panel_Loading.'
                    },
                    imgLoading = 'Img_Loading',
                }
            }
        }
    }
}

return viewCreator
