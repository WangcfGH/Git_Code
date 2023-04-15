local viewCreator 	=cc.load('ViewAdapter'):create()

viewCreator.viewConfig={
    'res/hallcocosstudio/activitycenter/exchangelotteryrule.csb',
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