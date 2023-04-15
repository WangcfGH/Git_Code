local NationalDayActivityRuleCtrl=class('NationalDayActivityRuleCtrl',cc.load('BaseCtrl'))
local viewCreater=import('src.app.plugins.NationalDayActivity.NationalDayActivityRuleView')

function NationalDayActivityRuleCtrl:onCreate(...)
	local viewNode=self:setViewIndexer(viewCreater:createViewIndexer())
    self:init()
end

function NationalDayActivityRuleCtrl:init()
    local viewNode = self._viewNode
    local btn = viewNode.closeBt
	self:bindDestroyButton(viewNode.closeBt)

    if not cc.exports._gameJsonConfig.NationalDaysActivity then
        return
    end

    local rule_introduceImg = viewNode.Bg:getChildByName("rule_introduce")

    for i=2,5 do
        local name = "class"..i
        rule_introduceImg:getChildByName("classBaseScore"..i):setString(cc.exports._gameJsonConfig.NationalDaysActivity["RoomRuleBaseScore"][name])

        name = "noWash"..i
        rule_introduceImg:getChildByName("noWashBaseScore"..i):setString(cc.exports._gameJsonConfig.NationalDaysActivity["RoomRuleBaseScore"][name])
    end

    rule_introduceImg:getChildByName("winLoseScore1"):setString(cc.exports._gameJsonConfig.NationalDaysActivity["multiplier"]["loser"])
    rule_introduceImg:getChildByName("winLoseScore2"):setString(cc.exports._gameJsonConfig.NationalDaysActivity["multiplier"]["equality"])
    rule_introduceImg:getChildByName("winLoseScore3"):setString(cc.exports._gameJsonConfig.NationalDaysActivity["multiplier"]["oneWin"])
    rule_introduceImg:getChildByName("winLoseScore4"):setString(cc.exports._gameJsonConfig.NationalDaysActivity["multiplier"]["doubleWin"])
    rule_introduceImg:getChildByName("score"):setString(cc.exports._gameJsonConfig.NationalDaysActivity["multiplier"]["doubleWin"]*cc.exports._gameJsonConfig.NationalDaysActivity["RoomRuleBaseScore"]["class5"])
end

return NationalDayActivityRuleCtrl
