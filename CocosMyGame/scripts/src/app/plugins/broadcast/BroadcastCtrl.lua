--数据view分层存在不合理 需要梳理（考虑重构） jj
local BroadcastCtrl     = class('BroadcastCtrl', cc.load('BaseCtrl'))
local viewCreater       = import('src.app.plugins.broadcast.BroadcastView')

function BroadcastCtrl:createViewNode(params)
    if not self._viewNode then
        self._viewNode = self:setViewIndexer(viewCreater:createViewIndexer())
        self._viewNode:setZOrder(10000)
        self._viewNode:setVisible(false)
        self._viewNode:retain()
    end

    if gameController and (true == gameController:isGameRunning() or gameController:getBoutCount()>0) then 
        self._viewNode:setVisible(false)
    else
        self._viewNode:setVisible(true)
    end

    local parent = self._viewNode:getRealNode():getParent()
    if not parent or not viewCreater._bBroadcasting then
        viewCreater:resetMembers()
        viewCreater:broadcastBegin()
    end

    return self._viewNode:getRealNode()
end

function BroadcastCtrl:speakerPlay()
    local csbPath = viewCreater.viewConfig[1]
    if self._viewNode then
        local action = cc.CSLoader:createTimeline(csbPath)
        if action then
            self._viewNode:stopAllActions()
            self._viewNode:runAction(action)
            action:gotoFrameAndPlay(0, 60, true)
        end
    end
end

return BroadcastCtrl