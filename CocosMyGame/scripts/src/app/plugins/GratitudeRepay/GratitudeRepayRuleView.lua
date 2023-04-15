local viewCreator   =cc.load('ViewAdapter'):create()

viewCreator.viewConfig={
    'res/hallcocosstudio/GratitudeRepay/GratitudeRepayRule.csb',
    {
        imgMainBox  = 'Img_MainBox',
        {
            _option={prefix='Img_MainBox.'},
            {
                ScrollView = 'ScrollView',
                {
                    _option={prefix='ScrollView.'},
                    Imgform = 'Img_form',
                    {
                        _option={prefix='Img_form.'},
                        NodeTxt = 'Node_left_58',
                        {
                            _option={prefix='Node_left_58.'},
                            txt1_1 = "Text_Rule_1_1",
                            txt1_2 = "Text_Rule_1_2",
                            txt1_3 = "Text_Rule_1_3",
                            txt1_4 = "Text_Rule_1_4",
                            txt1_5 = "Text_Rule_1_5",
                            txt1_6 = "Text_Rule_1_6",
                            txt2_1 = "Text_Rule_2_1",
                            txt2_2 = "Text_Rule_2_2",
                            txt2_3 = "Text_Rule_2_3",
                            txt2_4 = "Text_Rule_2_4",
                            txt2_5 = "Text_Rule_2_5",
                            txt2_6 = "Text_Rule_2_6",
                        },
                    }
                },
                ImgTop = 'Img_Top',
                {
                    _option={prefix='Img_Top.'},
                    ImgTitle = "Img_Title",
                    btnConfirm = "Btn_Confirm",
                    ImgTitleUnder = "Img_Title_Under",
                }
            }
        }
    }
}



return viewCreator