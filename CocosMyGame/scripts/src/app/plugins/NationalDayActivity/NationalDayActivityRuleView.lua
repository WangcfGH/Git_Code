local viewCreator=cc.load('ViewAdapter'):create()

viewCreator.viewConfig={
    'res/hallcocosstudio/NationalDayActivity/NationalDayActivityRule.csb',
    {
        mainPanel = "Panel",
        _option={prefix='Panel.'},
        Bg='Img_BG',
        {
            _option={prefix='Img_BG.'},
            closeBt = 'Btn_Back',
        },
    }
}

return viewCreator
