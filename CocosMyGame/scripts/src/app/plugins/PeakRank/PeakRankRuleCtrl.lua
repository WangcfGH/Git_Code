local viewCreater = import('src.app.plugins.PeakRank.PeakRankRuleView')
local PeakRankHelpCtrl = class('PeakRankHelpCtrl', cc.load('BaseCtrl'))

function PeakRankHelpCtrl:onCreate(params)
    local viewNode = self:setViewIndexer(viewCreater:createViewIndexer())

    self:bindDestroyButton(viewNode.btnClose)

    self:initRuleStrings()

    my.runPopupAction(viewNode.panelAnimation:getRealNode())
end

function PeakRankHelpCtrl:initRuleStrings()
    local ruleStrings = cc.exports.getPeakRankRuleStrings()
    if ruleStrings and #ruleStrings > 0 then
        for i, ruleString in ipairs(ruleStrings) do
            local nodeRule = self:createRuleStringNode(i, ruleString)
            self._viewNode.listView:insertCustomItem(nodeRule, i - 1)
        end
    end
end

function PeakRankHelpCtrl:createRuleStringNode(index, ruleString)
    local nodeRuleString = cc.CSLoader:createNode('res/hallcocosstudio/PeakRank/Node_RuleItem.csb')
    if nodeRuleString then
        local panelMain = nodeRuleString:getChildByName('Panel_Main')
        panelMain:retain()
        panelMain:removeFromParent()
        panelMain:setAnchorPoint(cc.p(0, 1))
        local textNO = panelMain:getChildByName('Text_NO')
        textNO:setString(tostring(index) .. '.')
        local textRule = panelMain:getChildByName('Text_Rule')
        textRule:setString(ruleString)
        local panelSize = panelMain:getContentSize()
        local textSize = textRule:getContentSize()
        local fontSize = textRule:getFontSize()
        local row = math.ceil(textSize.width / 650)
        
        if row > 1 then
            textRule:ignoreContentAdaptWithSize(false)
            textRule:setContentSize(cc.size(640, row * fontSize))
            panelMain:setContentSize(cc.size(panelSize.width, row * fontSize))
            ccui.Helper:doLayout(panelMain)
        end

        return panelMain
    end
    return nil
end

return PeakRankHelpCtrl