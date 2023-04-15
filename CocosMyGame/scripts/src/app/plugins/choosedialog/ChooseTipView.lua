
local TabView=cc.load('myccui').TabView
local viewCreator=cc.load('ViewAdapter'):create()

viewCreator.viewConfig={
	'res/hallcocosstudio/tips/choosedialog.csb',
	{
		_option={
			prefix='Panel_Main.Panel_Animation.'
		},
		okBt='Btn_Confirm',
		{
			_option = { prefix = 'Btn_Confirm.'},
			imgSure = "Image_2"
		},
		cancelBt='Btn_Cancel',
		{
			_option = { prefix = 'Btn_Cancel.'},
			imgCancel = 'Image_1'
		},
		closeBt='Btn_Close',
		tipTitle='Text_Title',
		imgTitle='Img_Title',
		tipContent='Text_TipContents',
		networkCheckTxt='Text_TipContents2',
		networkCheckBtn='Text_TipContents2.Btn_Exam',
		checkBoxPanel='Panel_Check',
		checkBoxText='Panel_Check.Text_Show',
		checkBox='Panel_Check.CheckBox',
	}
}

return viewCreator
