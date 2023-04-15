local viewCreator 	=cc.load('ViewAdapter'):create()

viewCreator.viewConfig={
    'res/hallcocosstudio/loginlottery/LotinLotteryRule.csb',
    {
        imgMainBox  = 'Img_MainBox',
        {
            _option={prefix='Img_MainBox.'},
            {
                btnConfirm = "Btn_Confirm",
            },
        },
    }
}



return viewCreator