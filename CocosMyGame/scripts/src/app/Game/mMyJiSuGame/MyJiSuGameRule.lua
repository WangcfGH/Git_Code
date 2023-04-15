local MyJiSuGameRule = class("MyJiSuGameRule", import("src.app.plugins.gamerule.GameRuleCtrl"))
local viewCreater=import('src.app.plugins.gamerule.GameRuleView')
local PluginProcessModel = mymodel('hallext.PluginProcessModel'):getInstance() 

local MainTabEventMap = {
        NeedHideNode                   = {    --tab切换时需要隐藏的控件 于TabButtons.showNode配合
            ["gameRuleScroll"]             = {}, 
            ["resultRuleScroll"]            = {},
            ["levelRuleScroll"]           = {},

            ["resultRuleCheck"]           = {},
            ["levelRuleCheck"]           = {},
        },
        TabButtons                                 = {
            [1]      = {checkBtn = "levelRuleCheck", showNode = {["levelRuleScroll"]={}} },
            [2]      = {checkBtn = "resultRuleCheck", showNode = {["resultRuleScroll"]={}} },
            [3]      = {
                defaultShow = true, 
                checkBtn = "gameRuleCheck", 
                showNode = {
                    ["gameRuleScroll"]={
                        imgPath = "res/hall/hallpic/rule/Image_JiSuGame.png",
                        imgNode = "Image_Game", 
                    }
                }  
            },
        }
    }

function MyJiSuGameRule:onCreate(...)
	local viewNode=self:setViewIndexer(viewCreater:createViewIndexer())
    self:bindDestroyButton(viewNode.closeBt)
    viewNode:getChildByName("Panel_Rule"):setScaleX(1.2)
    viewNode:getChildByName("Panel_Rule"):setScaleY(1.2)
    
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

function MyJiSuGameRule:onTabEvent(widgt, TabEventMap, callfunc)
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
    for widgtName, tbl in pairs(TabEventMap.TabButtons[selectIndex].showNode) do
        viewNode[widgtName]:setVisible(true)
        if tbl.imgPath and tbl.imgNode then
            local img = viewNode[widgtName]:getChildByName(tbl.imgNode)
            if img then
                img:loadTexture(tbl.imgPath)
                local size = img:getContentSize()
                viewNode[widgtName]:setAnchorPoint(cc.p(0.5, 1))
                viewNode[widgtName]:setPosition(cc.p(310, 343))
                viewNode[widgtName]:setInnerContainerSize(cc.size(550,1250))
                img:setPosition(cc.p(275, 615))
                img:ignoreContentAdaptWithSize(true)
            end
        end
    end

    if callfunc then
        callfunc(selectIndex)
    end
end

function MyJiSuGameRule:onClose()
    self:removeSelfInstance()
end

return MyJiSuGameRule