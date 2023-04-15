local viewCreator=cc.load('ViewAdapter'):create()

viewCreator.bResetSize = true
viewCreator.viewConfig = {
    'res/hallcocosstudio/TimingGame/TimingGameRule.csb',
    {
    	panelMain='Img_MainBox',
    	{
			_option = {prefix='Img_MainBox.'},
			btnConfirm ='Btn_Confirm',
			listview ='ListView',
    	}
    }
}

function viewCreator:onCreateView(viewNode,...)
	if not viewNode then return end
	viewNode.listview:removeAllItems()
end

return viewCreator