
local TabView=cc.load('myccui').TabView
local viewCreator=cc.load('ViewAdapter'):create()

viewCreator.viewConfig={
	'res/hallcocosstudio/hallcommon/toasttip.csb',
	{
		sprite='Panel_Main.Panel_Animation',
		tipLb='Panel_Main.Panel_Animation.Text_Deatail',
	}
}

function viewCreator:onCreateView(viewNode)

end

return viewCreator
