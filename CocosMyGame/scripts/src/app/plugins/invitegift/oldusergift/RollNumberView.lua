local RollNumberView = cc.load('ViewAdapter'):create()

RollNumberView.viewConfig = {
    'res/hallcocosstudio/invitegiftactive/olduser/rollnumber.csb',
    {
        panelMain = 'Panel_Main',
        {
            _option = { prefix = 'Panel_Main.' },
            panelAnimation = 'Panel_Animation',
            {
                _option = { prefix = 'Panel_Animation.' },
                panelRollArea = 'Panel_RollArea',
                {
                    _option = { prefix = 'Panel_RollArea.' },
        
                },
                nodeFirstFuzzyPos = 'Node_FirstFuzzyPos',
                nodeAniTextShow = 'Node_AniTextShow',
            }
        }
    }
}

return RollNumberView