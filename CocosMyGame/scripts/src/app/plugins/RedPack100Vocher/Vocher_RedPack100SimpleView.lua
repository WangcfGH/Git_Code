local viewCreator 	=cc.load('ViewAdapter'):create()

viewCreator.viewConfig={
    'res/hallcocosstudio/redpack100Vocher/redpack100Vocher.csb',
    {
        panelRedPack  = 'Panel_RedPack',
        {
            _option={prefix='Panel_RedPack.'},
            {
                btnChai='Btn_Chai',
                aniBreak = 'NodeBreakAni',
            },
        },
        panelBreak = 'Panel_RedPackBreak',
        {
            _option={prefix='Panel_RedPackBreak.'},
            imgBoxMain = 'Img_BoxMain',
            {
                _option={prefix='Img_BoxMain.'},
                panelVocher='Panel_Vocher',
                {
                    _option={prefix='Panel_Vocher.'},
                    txtFontVocher='TextBmFont_Vocher',
                    imgVocher='Img_Vocher',
                    txtTip1='Text_Tip1',
                    txtTip2='Text_Tip2',
                },
                txtTommorow = 'Text_Tommrow',
                btnTixian='Btn_Reward',
                btnClose = 'Btn_Close',
            },
        },
    }
}

function viewCreator:onCreateView(viewNode)
    if not viewNode then return end
    viewNode.panelRedPack:setVisible(false)
    viewNode.txtTip1:setPositionY(viewNode.txtTip1:getPositionY() - 10)
    viewNode.txtTip2:setVisible(false)
end

return viewCreator