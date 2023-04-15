local viewCreator 	=cc.load('ViewAdapter'):create()

viewCreator.viewConfig={
    'res/hallcocosstudio/room/room_secondlayer_team2v2_rule.csb',
    {
        imgMainBox  = 'Img_MainBox',
        {
            _option={prefix='Img_MainBox.'},
            {
                btnConfirm = "Btn_Confirm",
                listview ='RuleList',
            },
        },
    }
}

function viewCreator:onCreateView(viewNode,...)
    if not viewNode then return end
	viewNode.listview:removeAllItems()
end

return viewCreator