--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local viewCreator=cc.load('ViewAdapter'):create()

viewCreator.viewConfig={
    'res/hallcocosstudio/ArenaRank/ArenaTutorial.csb',
	{
		_option={prefix='Panel_Tutorial.'},
        closeBt='Btn_Close',
        leftBt="Btn_Left",
        rightBt="Btn_Right",
        rulePanel1="Panel_Rule1",
        rulePanel2="Panel_Rule2",
        rulePanel3="Panel_Rule3",
        rulePanel4="Panel_Rule4",
	}
}
return viewCreator


--endregion
