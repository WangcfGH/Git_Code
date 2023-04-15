
local TabView=cc.load('myccui').TabView
local viewCreator=cc.load('ViewAdapter'):create()

viewCreator.viewConfig={
	'res/hallcocosstudio/invitegiftactive/newuser/newusersure_panel.csb',
	{
		_option={prefix='Panel_Main.Panel_Animation.'},
		closeBt='Btn_Close',
		sureBt='Btn_Continue',
        cancelBt='Btn_Exit',
		textPhone = "Text_phone",
		textItem = "Text_item",
		knowBt = "Btn_know",
	    tipContent = "Text_TipContents",
		Text_1 = "Text_1",
		Text_2 = "Text_2"

	}
}

function viewCreator:onCreateView(viewNode)
	viewNode:setPosition( 0, 0 )
end

return viewCreator
