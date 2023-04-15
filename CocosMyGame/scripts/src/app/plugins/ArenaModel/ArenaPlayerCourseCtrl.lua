local viewCreater=import('src.app.plugins.ArenaModel.ArenaPlayerCourseView')

local ArenaPlayerCourseCtrl=class('ArenaPlayerCourseCtrl',cc.load('BaseCtrl'))
ArenaPlayerCourseCtrl.MAX_COURSE_COUNT = 4
local PluginProcessModel = mymodel('hallext.PluginProcessModel'):getInstance() 

function ArenaPlayerCourseCtrl:onCreate(params)
    local viewNode=self:setViewIndexer(viewCreater:createViewIndexer())
    self:bindDestroyButton(viewNode.closeBt)
    
    self._index = 1
    self:showPanelByIndex()

    self:bindUserEventHandler(viewNode, { "leftBt", "rightBt"})
    self:listenTo(PluginProcessModel, PluginProcessModel.CLOSE_PLUGIN_ON_GUIDE,handler(self,self.onClose))
end

function ArenaPlayerCourseCtrl:onExit()
end

function ArenaPlayerCourseCtrl:leftBtClicked( ... )
    self._index = self._index - 1
    if self._index < 1 then
        self._index = 1
    end
    self:showPanelByIndex()
end

function ArenaPlayerCourseCtrl:rightBtClicked( ... )
    self._index = self._index + 1
    if self._index > self.MAX_COURSE_COUNT then
        self._index = self.MAX_COURSE_COUNT
    end
    self:showPanelByIndex()
end

function ArenaPlayerCourseCtrl:showPanelByIndex()
    local viewNode = self._viewNode
    for i = 1, 4 do
        viewNode["rulePanel"..i]:setVisible(false)
    end
    viewNode["rulePanel"..self._index]:setVisible(true)
end

function ArenaPlayerCourseCtrl:onClose()
    self:removeSelfInstance()
end
return ArenaPlayerCourseCtrl