local viewCreator = cc.load('ViewAdapter'):create()

viewCreator.viewConfig = {
    'res/hallcocosstudio/AnchorLuckyBag/Layer_CheckTiktokAccount.csb',
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
            }
        }
    }
}

return viewCreator
