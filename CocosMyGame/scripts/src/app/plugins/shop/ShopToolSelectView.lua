local viewCreator=cc.load('ViewAdapter'):create()

viewCreator.viewConfig={
    'res/hallcocosstudio/shop/Layer_tools_buy.csb',
    {
        mainPanel = "Panel_bg",
        {
            _option={prefix='Panel_bg.'},
            closeBt = 'Button_Close',  
        }
    }
}

return viewCreator
