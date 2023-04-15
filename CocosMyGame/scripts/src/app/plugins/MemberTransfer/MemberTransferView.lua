
local TabView=cc.load('myccui').TabView
local viewCreator=cc.load('ViewAdapter'):create()

viewCreator.viewConfig={
	'res/hallcocosstudio/NobilityPrivilege/MemberTransfer.csb',
	{
		_option={
			prefix='Panel_Main.Panel_Animation.'
		},
        PanelMemberTransfer='Panel_MemberTransfer',
        PanelTransferSuccess = 'Panel_TransferSuccess',
		okBt='Panel_MemberTransfer.Btn_Confirm',
		cancelBt='Panel_MemberTransfer.Btn_Cancel',
        sureBt = 'Panel_TransferSuccess.Btn_Confirm',
		closeBt='Btn_Close',
	}
}

return viewCreator
