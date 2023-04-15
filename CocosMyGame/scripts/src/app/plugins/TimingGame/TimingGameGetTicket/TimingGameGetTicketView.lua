local viewCreator=cc.load('ViewAdapter'):create()

viewCreator.bResetSize = true
viewCreator.viewConfig = {
    'res/hallcocosstudio/TimingGame/TimingGameGetTicket.csb',
    {
    	panelMain='Panel_Main',
    	{
			_option = {prefix='Panel_Main.'},
			panelAnimation = 'Panel_Animation',
	        {
				_option={prefix='Panel_Animation.'},
				imgBg = 'Img_Bg',
				panelItem1 = 'Panel_Item1',
				{
					_option={prefix='Panel_Item1.'},
					txtTicket1 = 'Text_Ticket1',
					txtTicket1_0 = 'Text_Ticket1_0',
					btnTask = 'Btn_Task',
					txtTaskDesc1 = 'Btn_Task.Text_Desc',
					txtTaskDesc2 = 'Btn_Task.Text_Desc2',
					txtTaskDesc3 = 'Btn_Task.Text_Desc3',
				},
				panelItem2 = 'Panel_Item2',
				{
					_option={prefix='Panel_Item2.'},
					txtTicket2 = 'Text_Ticket2',
					btnTicketDeposit = 'Btn_TicketDeposit',
					txtDepositDesc = 'Btn_TicketDeposit.Text_Desc',
				},
				panelItem3 = 'Panel_Item3',
				{
					_option={prefix='Panel_Item3.'},
					txtTicket3 = 'Text_Ticket3',
					txtTicket3_0 = 'Text_Ticket3_0',
					btnTicketRMB = 'Btn_TicketRMB',
					txtRMBDesc = 'Btn_TicketRMB.Text_Desc',
					imgMark2 = 'Img_Mark2',
					imgMark2onlyone = 'Img_Mark2_onlyone',

				},
				
	            btnClose ='Btn_Close',
			},
    	}
    }
}

function viewCreator:onCreateView(viewNode,...)
	if not viewNode then return end
	
	viewNode.btnTicketRMB:setTouchEnabled(false)
	viewNode.btnTicketRMB:setBright(false)
	
	viewNode.btnTicketDeposit:setTouchEnabled(false)
	viewNode.btnTicketDeposit:setBright(false)
	
	viewNode.btnTask:setTouchEnabled(false)
    viewNode.btnTask:setBright(false)
end

return viewCreator