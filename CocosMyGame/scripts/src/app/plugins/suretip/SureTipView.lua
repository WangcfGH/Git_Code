local viewCreator=cc.load('ViewAdapter'):create()

viewCreator.viewConfig={
	'res/hallcocosstudio/tips/suredialog.csb',
	{
		_option={prefix='Panel_Main.Panel_Animation.'},
		okBt='Btn_Confirm',
		closeBt='Btn_Close',
        scrollView = 'Scroll_Contents',
		tipContent='Text_TipContents',
		tipTitle='Text_Title',
	}
}

function viewCreator:onCreateView(viewNode)

end

return viewCreator
