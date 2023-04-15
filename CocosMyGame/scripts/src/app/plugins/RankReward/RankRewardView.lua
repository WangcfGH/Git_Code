local viewCreator 	=cc.load('ViewAdapter'):create()

viewCreator.viewConfig={
    'res/hallcocosstudio/RankReward/layer_rankreward.csb',
    {
        panelShade = "Panel_Shade",
        panelMain = "Panel_Main",
        {
            _option={prefix='Panel_Main.'},
            aniLight = 'Sprite_1',
            imgCup = 'Image_1',
            {
                _option={prefix='Image_1.'},
                imgRank = 'Image_2',
                {
                    _option={prefix='Image_2.'},
                    fntRank = 'Fnt_1',
                },
                aniStar1 = 'Sprite_2',
            },
            listReward = 'Panel_RewardList',
            fntTip = 'BitmapFontLabel_7',
            btnOk = 'Btn_Ok',
        }
    }
}


function viewCreator:onCreateView(viewNode)
    local action = cc.CSLoader:createTimeline("res/hallcocosstudio/RankReward/layer_rankreward.csb")
    viewNode:runAction(action)
    action:play("animation0", true)

    local zorder = 10000
    viewNode:setLocalZOrder(zorder)
end

return viewCreator