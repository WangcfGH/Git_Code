local viewCreator = cc.load('ViewAdapter'):create()

viewCreator.viewConfig = {
    'res/hallcocosstudio/PeakRank/Layer_PeakRankRule.csb',
    {
        panelShade = 'Panel_Shade',
        panelMain = 'Panel_Main',
        {
            _option = {
                prefix = 'Panel_Main.'
            },
            panelAnimation = 'Panel_Animation',
            btnClose = 'Panel_Animation.Btn_Close',
            listView = 'Panel_Animation.ListView'
        }
    }
}

function viewCreator:onCreateView(viewNode)
end

return viewCreator
