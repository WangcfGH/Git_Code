local viewCreator 	=cc.load('ViewAdapter'):create()

viewCreator.viewConfig={
    'res/hallcocosstudio/redpack100/redpack100simple.csb',
    {
        panelBreak = 'Panel_RedPackBreak',
        {
            _option={prefix='Panel_RedPackBreak.'},
            imgBoxMain = 'Img_BoxMain',
            {
                _option={prefix='Img_BoxMain.'},
                panelMoney='Panel_Money',
                {
                    _option={prefix='Panel_Money.'},    
                    txtBmFontMoney='TextBmFont_Money',
                    imgBestShouQi='Img_Shouqi',
                    txtTommorow = 'Text_Tommrow',
                },
                btnTixian='Btn_Tixian',
            },
        },
    }

}


return viewCreator