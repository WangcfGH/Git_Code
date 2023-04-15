local viewCreator=cc.load('ViewAdapter'):create()

viewCreator.bResetSize = true
viewCreator.viewConfig = {
    'res/hallcocosstudio/AnchorRoom/AnchorRoomList.csb',
    {
    	panelMain='Panel_Main',
    	{
			_option = {prefix='Panel_Main.'},
			panelAnimation = 'Panel_Animation',
	        {
				_option={prefix='Panel_Animation.'},
                scrollTalbe = 'ScrollView_AnchorNodes',
				imgEmpty = 'Img_Empty',
				txtUseTime = 'Txt_UseTime',
				txtWarning = 'Txt_Warning',
				btnCreateTable = 'Btn_CreateRoom',
                btnClose ='Btn_Close',
			},
    	}
    }
}

function viewCreator:onCreateView(viewNode,...)
    if not viewNode then return end
end

return viewCreator