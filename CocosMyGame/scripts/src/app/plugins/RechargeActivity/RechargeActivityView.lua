local viewCreator 	=cc.load('ViewAdapter'):create()
-- local RechargeActivityModel    = import("src.app.plugins.RechargeActivity.RechargeActivityModel"):getInstance()

viewCreator.viewConfig={
    'res/hallcocosstudio/RechargeActivity/layer_rechargeactivity.csb',
    {
        panelShade = "Panel_Shade",
        panelMain = "Panel_Main",
        {
            _option={prefix='Panel_Main.'},
            aniTitle = 'Ani_Title',
            btnClose = 'Btn_Close',
            imgMain = 'Img_Main',
            {
                _option={prefix='Img_Main.'},
                imgTile = 'Img_Title',
                aniRechargeFont = 'Ani_RechargeFont',
                aniLight = 'Ani_Light',
                btnDraw = 'Btn_Draw',
                btnDrawImmditely = 'Btn_Draw_Immeditely',
                {
                    _option={prefix='Btn_Draw.'},
                    imgHot = 'Img_Hot',
                    textRecharge = "Text_NeedRecharge",
                    textLeftCount = "Text_LeftCount"
                },
                aniBtn = 'Ani_Btn',
                aniChick = 'Ani_Chick',
                imgBubble = 'Img_Bubble',
                {
                    _option={prefix='Img_Bubble.'},
                    textTip = 'Text_Tip',
                },
                textTime = 'Text_Time',
                node1 = 'Node_1',
                node2 = 'Node_2',
                node3 = 'Node_3',
                node4 = 'Node_4',
                node5 = 'Node_5',
                node6 = 'Node_6'
            }
        }
    },
    ["popupAni"] = {
        ["aniName"] = "scaleandshake",
        ["aniNode"] = "Panel_Main",
        ["isPlayAni"] = true
    }
}

function viewCreator:onCreateView(viewNode)
    local aniLightFile = "res/hallcocosstudio/RechargeActivity/gd_paomadeng.csb"
    local aniTitleFile = "res/hallcocosstudio/RechargeActivity/gd_shandian.csb"
    local aniChickFile = "res/hallcocosstudio/RechargeActivity/gd_xiaoji.csb"
    local aniFontFile  = "res/hallcocosstudio/RechargeActivity/gd_chongzhi_sweet.csb"
    local aniBtnFile   = "res/hallcocosstudio/RechargeActivity/gd_anniu.csb"
    
    if viewNode.aniLight then
        local lightAni = cc.CSLoader:createTimeline(aniLightFile)
        viewNode.aniLight:runAction(lightAni)
        lightAni:play("animation0", true)
    end
    if viewNode.aniTitle then
        local titleAni = cc.CSLoader:createTimeline(aniTitleFile)
        viewNode.aniTitle:runAction(titleAni)
        titleAni:play("animation0", true)
    end
    if viewNode.aniChick then
        local chickAni = cc.CSLoader:createTimeline(aniChickFile)
        viewNode.aniChick:runAction(chickAni)
        chickAni:play("animation0", true)
    end
    if viewNode.aniRechargeFont then
        local fontAni = cc.CSLoader:createTimeline(aniFontFile)
        viewNode.aniRechargeFont:runAction(fontAni)
        fontAni:play("animation0", true)
    end
    if viewNode.aniBtn then
        local btnAni = cc.CSLoader:createTimeline(aniBtnFile)
        if not tolua.isnull(btnAni) then
            self._viewNode.aniBtn:stopAllActions()
            viewNode.aniBtn:runAction(btnAni)
            btnAni:play("animation0", true)
        end
    end

    if viewNode.btnDraw then
        viewNode.btnDraw:setEnabled(false)
    end
end

return viewCreator