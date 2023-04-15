local viewCreator=cc.load('ViewAdapter'):create()

viewCreator.viewConfig={
	'res/hallcocosstudio/tips/notice.csb',
	{
		_option={prefix='Panel_Main.Panel_Animation.'},
		okBt='Btn_Confirm',
		closeBt='Btn_Close',
        listContent = 'List_Contents',
		tipContent='Text_TipContents',
		tipTitle='Text_Title',
	}
}

function viewCreator:onCreateView(viewNode)

end

return viewCreator
