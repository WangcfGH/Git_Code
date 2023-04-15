local viewCreator=cc.load('ViewAdapter'):create()

viewCreator.bResetSize = true
viewCreator.viewConfig = {
    'res/hallcocosstudio/AnchorPoster/AnchorPoster.csb',
    {
    	panelMain='Panel_Main',
    	{
			_option = {prefix='Panel_Main.'},
			panelAnimation = 'Panel_Animation',
	        {
				_option={prefix='Panel_Animation.'},
                scrollAnchors ='ScrollView_AnchorNodes',
                btnClose ='Btn_Close',
			},
    	}
    }
}

function viewCreator:onCreateView(viewNode,...)
    if not viewNode then return end
end

return viewCreator