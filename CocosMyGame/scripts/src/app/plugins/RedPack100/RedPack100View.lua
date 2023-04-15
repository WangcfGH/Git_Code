local viewCreator 	=cc.load('ViewAdapter'):create()

viewCreator.viewConfig={
    'res/hallcocosstudio/redpack100/redpack100.csb',
    {
        panelRedPack  = 'Panel_RedPack',
        {
            _option={prefix='Panel_RedPack.'},
            {
                imgRedPack = 'Img_RedPack',
                {
                     _option={prefix='Img_RedPack.'},
                    btnChai='Btn_Chai',
                },
                aniBreak = 'NodeBreakAni',
            },
        },
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
                btnReward='Btn_Reward',
                panelOtherUsers='Panel_OtherUsers',
                {
                    _option={prefix='Panel_OtherUsers.'},
                    panelUser1='PanelUser1',
                    {
                        _option={prefix='PanelUser1.'},
                        txtUser1='Text_User1',
                        txtMoney1='Text_Money1',
                    },
                    panelUser2='PanelUser2',
                    {
                        _option={prefix='PanelUser2.'},
                        txtUser2='Text_User2',
                        txtMoney2='Text_Money2',
                    },
                    panelUser3='PanelUser3',
                    {
                        _option={prefix='PanelUser3.'},
                        txtUser3='Text_User3',
                        txtMoney3='Text_Money3',
                    },
                    panelUser4='PanelUser4',
                    {
                        _option={prefix='PanelUser4.'},
                        txtUser4='Text_User4',
                        txtMoney4='Text_Money4',
                    },
                },
                btnClose = 'Btn_Close',
            },
        },
    }
}



return viewCreator