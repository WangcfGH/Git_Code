local viewCreator 	=cc.load('ViewAdapter'):create()

viewCreator.viewConfig={
    'res/hallcocosstudio/activitycenter/exchangelottery.csb',
    {
        Panel_Main = 'Panel_Main',
        {
            _option={prefix='Panel_Main.'},
            Img_BottomBg = "Img_BottomBg",
            Btn_DrawOne = "Btn_DrawOne",
            {
                _option={prefix='Btn_DrawOne.'},
                Ani_DrawOne = "Ani_DrawOne",
            },
            Btn_DrawTen = "Btn_DrawTen",
            {
                _option={prefix='Btn_DrawTen.'},
                Ani_DrawTen = "Ani_DrawTen",
            },
            Btn_Buy = "Btn_Buy",
            Btn_Help = "Btn_Help",
            Img_Center = "Img_Center",
            {
                _option={prefix='Img_Center.'},
                Text_1 = "Text_1",
                Text_Count = "Text_Count"
            },
            Img_Bubble1 = "Img_Bubble1",
            Img_Bubble2 = "Img_Bubble2",
        }
    }
}

function viewCreator:onCreateView(viewNode)

end

return viewCreator