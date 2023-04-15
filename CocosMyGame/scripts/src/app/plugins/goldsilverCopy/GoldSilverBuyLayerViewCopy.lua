local GoldSilverBuyLayerViewCopy = cc.load("ViewAdapter"):create()

GoldSilverBuyLayerViewCopy.viewConfig = {
    "res/hallcocosstudio/goldsilverCopy/goldsilverbuylayerCopy.csb",
    {
        Panel_Shade = "Panel_Shade",
        Operate_Panel = "Operate_Panel",
        {
            _option = {prefix = 'Operate_Panel.'},
            Img_SilverCup = "Img_SilverCup",
            {
                _option = {prefix = 'Img_SilverCup.'},
                Text_Silver = "Text_Silver",
                Img_SilverUnlocked = "Img_SilverUnlocked",
                Btn_UnLockSilver = "Btn_UnLockSilver"
            },
            Img_GoldCup = "Img_GoldCup",
            {
                _option = {prefix = 'Img_GoldCup.'},
                Text_Gold = "Text_Gold",
                Img_GoldUnlocked = "Img_GoldUnlocked",
                Btn_UnLockGold = "Btn_UnLockGold"
            },
            Btn_Close = "Btn_Close"
        }
    }
}

return GoldSilverBuyLayerViewCopy