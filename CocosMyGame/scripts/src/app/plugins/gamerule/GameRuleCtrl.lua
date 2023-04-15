local GameRuleCtrl=class('GameRuleCtrl', cc.load('BaseCtrl'))
local viewCreater=import('src.app.plugins.gamerule.GameRuleView')
local PluginProcessModel = mymodel('hallext.PluginProcessModel'):getInstance() 

GameRuleCtrl.RUN_ENTERACTION = true

local MainTabEventMap = {
        NeedHideNode                   = {    --tab切换时需要隐藏的控件 于TabButtons.showNode配合
            ["gameRuleScroll"]             = {}, 
            ["resultRuleScroll"]            = {},
            ["levelRuleScroll"]           = {},
        },
        TabButtons                                 = {
            [1]      = {checkBtn = "levelRuleCheck", showNode = {["levelRuleScroll"]={}} },
            [2]      = {defaultShow = true, checkBtn = "resultRuleCheck", showNode = {["resultRuleScroll"]={}} },
            [3]      = {checkBtn = "gameRuleCheck", showNode = {["gameRuleScroll"]={}}  },
        }
    }

function GameRuleCtrl:onCreate(...)
	local viewNode=self:setViewIndexer(viewCreater:createViewIndexer())
    self:bindDestroyButton(viewNode.closeBt)

    local function onTabEvent(widget)
		self:onTabEvent(widget, MainTabEventMap)
	end
    for index, table in pairs(MainTabEventMap.TabButtons) do
        if viewNode[table.checkBtn] then
            viewNode[table.checkBtn]:addClickEventListener(onTabEvent)
            if table.defaultShow then
                self:onTabEvent(viewNode[table.checkBtn]._realnode[1], MainTabEventMap)
                viewNode[table.checkBtn]:setSelected(true)
            end
        end
    end
    self:listenTo(PluginProcessModel, PluginProcessModel.CLOSE_PLUGIN_ON_GUIDE,handler(self,self.onClose))
end

function GameRuleCtrl:runEnterAction()
    local panelRule = self._viewNode:getChildByName('Panel_Rule')
    my.runPopupAction(panelRule)
end

function GameRuleCtrl:onTabEvent(widgt, TabEventMap, callfunc)
    my.playClickBtnSound()
    local viewNode = self._viewNode
    local selectIndex = -1
    for index, table in pairs(TabEventMap.TabButtons) do
        viewNode[table.checkBtn]:setSelected(false)
        viewNode[table.checkBtn]:setLocalZOrder(0)
        if viewNode[table.checkBtn]._realnode[1] == widgt then
            viewNode[table.checkBtn]:setLocalZOrder(1)
            selectIndex = index
        end
    end
    if selectIndex < 0  then
        return
    end
    for widgtName, func in pairs(TabEventMap.NeedHideNode) do
        viewNode[widgtName]:setVisible(false)
    end
    for widgtName, func in pairs(TabEventMap.TabButtons[selectIndex].showNode) do
        viewNode[widgtName]:setVisible(true)
    end

    if callfunc then
        callfunc(selectIndex)
    end
end

function GameRuleCtrl:onClose()
    self:removeSelfInstance()
end



return GameRuleCtrl
