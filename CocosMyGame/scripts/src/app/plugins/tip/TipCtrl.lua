local TipCtrl=class('TipCtrl',cc.load('BaseCtrl'))
local viewCreater=import('src.app.plugins.tip.TipView')

my.addInstance(TipCtrl)

-----------------
--@param removeTime:@type number
--@param tipString:@type string
--

TipCtrl.init=false
local viewNode

function TipCtrl:createViewNode(params)

    if(TipCtrl.init == false)then
        viewNode=self:setViewIndexer(viewCreater:createViewIndexer())
        TipCtrl.init=true
    end

    viewNode.tipLb:setString(params.tipString)

    viewNode.sprite:setVisible(params.tipString and params.tipString ~= '')

    if params.tipString and params.tipString ~= '' then 
        viewNode.sprite:stopAllActions()
        local removeTime = params.removeTime or 1.5
        local a1 = cc.CallFunc:create(function() self:runEnterAction() end)
        local a2 = cc.DelayTime:create( removeTime)
        local a3 = cc.CallFunc:create(function() self:runExitAction() end)
        --延迟之后remove是为了重置节点running状态 否则在华为mate9会出现不播动画的情况
        local a4 = cc.DelayTime:create(1)
        local a5 = cc.CallFunc:create(function()
            if self._viewNode:getParent() then
                self._viewNode:removeSelf()
            end
        end)
        local a6 = cc.Sequence:create(a1,a2,a3,a4, a5, nil)
        viewNode.sprite:runAction(a6)
        -- 如果running属性为false的话，需要主动激活该结点动作
        if not viewNode.sprite:isRunning() then
            viewNode.sprite:resume()
        end
    end

    viewNode:setPosition(display.cx, display.cy)
    viewNode:setLocalZOrder(ZORDER_ENUM.kTipString)

    return viewNode:getRealNode()
end

return TipCtrl
