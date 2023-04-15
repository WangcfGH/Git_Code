
local TabView=cc.load('myccui').TabView
local viewCreator=cc.load('ViewAdapter'):create()

viewCreator.viewConfig={
	'res/hallcocosstudio/personalinfo/Layer_rule.csb',
	{
		_option={prefix='Panel_Rule.'},
		closeBt='Btn_Close',
		gameRuleCheck='CheckBox_Game',
		resultRuleCheck='CheckBox_Result',
		levelRuleCheck='CheckBox_Level',
		levelRuleScroll='ScrollView_Level',
		resultRuleScroll='ScrollView_Result',
		gameRuleScroll='ScrollView_Game',

		imgGameRule = 'ScrollView_Game.Image_Game',
	}
}

--[[function viewCreator:onCreateView(viewNode)
	viewNode:setPosition( 0, 0 )
end]]--

function viewCreator:onCreateView(viewNode)
    viewNode:getChildByName("Panel_Rule"):setScale(1.2)
end

return viewCreator
