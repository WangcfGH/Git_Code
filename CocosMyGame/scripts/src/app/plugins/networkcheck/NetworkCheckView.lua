
local viewCreator=cc.load('ViewAdapter'):create()

viewCreator.viewConfig={
    'res/hallcocosstudio/exam/examdialog.csb',
	{
		_option={prefix='Panel_Main.Panel_Animation.'},
		closeBt='Btn_Close',
		{
			_option={prefix='Panel_ExamDetail.'},
			operatorTxt='Text_Basic1',
			networkTypeTxt='Text_Basic2',
			gameVersionTxt='Text_Basic3',
			systemTimeTxt='Text_Basic4',
			
			hallCheckTxt='Text_Internet1',
			roomCheckTxt='Text_Internet2',
			gameCheckTxt='Text_Internet3',
			thiredCheckTxt='Text_Internet4',

			resultTxt='Text_Result1',		
		}
	}
}

function viewCreator:onCreateView(viewNode)
	if not viewNode then return end

end

return viewCreator
