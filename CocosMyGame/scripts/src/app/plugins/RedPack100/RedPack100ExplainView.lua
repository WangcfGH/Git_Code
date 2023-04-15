local viewCreator 	=cc.load('ViewAdapter'):create()

viewCreator.viewConfig={
    'res/hallcocosstudio/redpack100/redpack100activityexplain.csb',
    {
        imgMainBox  = 'Img_MainBox',
        {
            _option={prefix='Img_MainBox.'},
            {
                imgExplain = 'Img_Explain',
                btnConfirm = "Btn_Confirm",
            },
        },
    }
}



return viewCreator