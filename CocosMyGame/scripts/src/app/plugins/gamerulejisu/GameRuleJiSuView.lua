
local TabView=cc.load('myccui').TabView
local viewCreator=cc.load('ViewAdapter'):create()

viewCreator.viewConfig={
	'res/GameCocosStudio/csb/Node_RuleJiSuScore.csb',
	{
		_option={prefix='Panel_Rule.'},
		closeBt='Btn_Close',
	}
}

function viewCreator:onCreateView(viewNode)
    viewNode:getChildByName("Panel_Rule"):setScale(1.0)
end

return viewCreator
