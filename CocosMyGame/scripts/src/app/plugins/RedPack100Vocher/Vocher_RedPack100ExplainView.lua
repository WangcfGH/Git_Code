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

function viewCreator:onCreateView(viewNode)
    if not viewNode then return end
    -- tips.png在RedPack100Vocher.plist 里面
    viewNode.imgExplain:loadTexture("hallcocosstudio/images/plist/RedPack100Vocher/tips.png", 1)

end


return viewCreator