local viewCreator = cc.load('ViewAdapter'):create()

viewCreator.viewConfig = {
    'res/hallcocosstudio/ValuablePurchase/Layer_ValuablePurchase.csb',
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
                nodeMainAni = 'Node_MainAni',
                listViewPurchaseItem = 'ListView_PurchaseItem',
                listViewDayPurchase = 'ListView_DayPurchase',
                btnClose = 'Btn_Close',
                btnStartPay = 'Btn_StartPay',
            }
        }
    }
}

function viewCreator:onCreateView(viewNode)
end

return viewCreator
