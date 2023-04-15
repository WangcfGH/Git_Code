local viewCreator=cc.load('ViewAdapter'):create()

viewCreator.bResetSize = true
viewCreator.viewConfig = {
    'res/hallcocosstudio/Bankruptcy/Bankruptcy.csb',
    {
    	panelMain='Panel_Main',
    	{
			_option = {prefix='Panel_Main.'},
			panelAnimation = 'Panel_Animation',
	        {
				_option={prefix='Panel_Animation.'},
				imgBg = 'Img_Bg',
	            txtTip ='Text_Tip',
				panelItem1 ='Panel_Item1',
				{
					_option={prefix='Panel_Item1.'},
					imgDeposit1 = 'Img_Deposit',
					txtCount1 = 'Text_Count',
				},
				panelItem2 ='Panel_Item2',
				{
					_option={prefix='Panel_Item2.'},
					imgDeposit2 = 'Img_Deposit',
					txtCount2 = 'Text_Count',
				},
	            btnBuy ='Btn_Buy',
	            txtDesc ='Btn_Buy.Text_Desc',
	            btnClose ='Btn_Close',
			},
    	}
    }
}

function viewCreator:onCreateView(viewNode,...)
    if not viewNode then return end
end

return viewCreator