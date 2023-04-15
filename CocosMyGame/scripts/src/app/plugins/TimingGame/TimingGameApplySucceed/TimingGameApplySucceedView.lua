local viewCreator=cc.load('ViewAdapter'):create()

viewCreator.bResetSize = true
viewCreator.viewConfig = {
    'res/hallcocosstudio/TimingGame/TimingGameApplySucceed.csb',
    {
    	panelMain='Img_MainBox',
    	{
			_option = {prefix='Img_MainBox.'},
			btnConfirm ='Btn_Confirm',
			btnClose ='Btn_Close',
			txtScore ='Text_Score',
			txtUserName = 'Img_Ji.Text_UserName',
    	}
    }
}

function viewCreator:onCreateView(viewNode,...)
    if not viewNode then return end
end

return viewCreator