local BroadcastModel            = mymodel("hallext.BroadcastModel"):getInstance()
local viewCreator               = cc.load('ViewAdapter'):create()
local RichColorLabel            = import("src.app.plugins.broadcast.RichColorLabel")

viewCreator.viewConfig = {
    'res/hallcocosstudio/hallcommon/broadcast.csb',
    {
        _option =
        {
            prefix = 'Panel_Notice.'
        },
        spriteSpeaker = 'Sprite_Speaker',
        NodeNobilityPrivilege = 'Node_NobilityPrivilege',
        ImgBk = 'Image_BK',
        _touch = 'Panel_touch',
        _panelText = 'Panel_Text',
        {
            _option =
            {
                prefix = 'Panel_Text.'
            },
            _label1 = 'Text_Notice1',
            _label2 = 'Text_Notice2',
        },
    }
}

function viewCreator:onCreateView(viewNode)
    self:resetMembers()

    viewNode.spriteSpeaker:setVisible(false)
end

function viewCreator:resetMembers()
    local viewNode = self._viewNode
    if viewNode._label1 then
        viewNode._label1:setVisible(false)
        viewNode._label1:stopAllActions()
    end

    if viewNode._label2 then
        viewNode._label2:setVisible(false)
        viewNode._label2:stopAllActions()
    end
end

function viewCreator:playAnimationNobilityPrivilege(data)
    local dataMap = data
    if dataMap == nil then
        print("dataMap is nil")
        return
    end

    local nBegin = string.find(dataMap.szMsg, "<")
    local nEnd = string.find(dataMap.szMsg, ">")

    local nLevel = dataMap.nReserved[1]
    local name   = dataMap.szMsg
    if nBegin and nEnd then
        name  = string.sub(dataMap.szMsg,nBegin+1,nEnd-1)
    end

    local aniFile = "res/hallcocosstudio/NobilityPrivilege/guizu.csb"
    local aniNode = self._viewNode.NodeNobilityPrivilege
    aniNode:stopAllActions()
    aniNode:removeAllChildren()
    aniNode:setVisible(true)
    local node = cc.CSLoader:createNode(aniFile)
    local action = cc.CSLoader:createTimeline(aniFile)

    node:getChildByName("Panel_1"):getChildByName("Fnt_gzsx"):setString(nLevel)
    node:getChildByName("Panel_1"):getChildByName("Text_nicheng"):setString(name)
    aniNode:addChild(node)
    if not tolua.isnull(action) then
        node:runAction(action)
        action:play("animation0", false)
    end

    local function callBack(frame)
        if frame and frame:getEvent() == "Over" then
            action:clearFrameEventCallFunc()
            aniNode:runAction(cc.Sequence:create(cc.DelayTime:create(5), cc.Hide:create(), cc.CallFunc:create(function ()
                self:broadcastBegin()
            end)))
        end
    end
    action:setFrameEventCallFunc(callBack)
end

function viewCreator:broadcastBegin()
    local viewNode = self._viewNode
    if not BroadcastModel._broadcastConfig then 
        self:broadcastEnd()
        return
    end

    if not viewNode._panelText or not viewNode._label1 or not viewNode._label2 then
        self:broadcastEnd()
        return
    end

    self._bBroadcasting = true
    self._centerY       = self._centerY or viewNode._label1:getPositionY()

    local messageInfo = BroadcastModel:getFirstMsg(true)
    if not messageInfo then
        self:broadcastEnd()
        return
    end
    viewNode.ImgBk:setVisible(true)
    if messageInfo.enMsgType == BroadcastDef.enMsgTypeNobilityShow then -- 贵族消息
        --分发消息播放登录动画
        viewNode.ImgBk:setVisible(false)
        self:playAnimationNobilityPrivilege(messageInfo)
        return 
    end

    --不该播放贵族动画时隐藏节点
    self._viewNode.NodeNobilityPrivilege:setVisible(false)

    local label = viewNode._label1
    if viewNode._label1:isVisible() then -- 如果第一条字体在滚动, 则用第二条字体
        label = viewNode._label2
    end
    ----------------------------------------------	
    local RichColorLabel = RichColorLabel:create(label:getTextColor(), label:getFontSize())
    RichColorLabel:setColorString(messageInfo.szMsg)

    label:setString("")
    label:removeChildByTag(123)
    label:addChild(RichColorLabel, 0, 123)
    -----------------------------------------------------
    if gameController and (true == gameController:isGameRunning() or gameController:getBoutCount()>0) then 
        viewNode:setVisible(false)
    else
        viewNode:setVisible(true)
    end

    label:setVisible(true)

    local szFont    = RichColorLabel:getContentSize()
    local szPanel   = viewNode._panelText:getContentSize()
    local moveSpeed = 70 -- 移动速度 像素/秒
    if BroadcastModel._broadcastConfig.nMoveSpeed and BroadcastModel._broadcastConfig.nMoveSpeed > 0 then
        moveSpeed   = BroadcastModel._broadcastConfig.nMoveSpeed
    end
    label:stopAllActions()
    -- 从右向左滚动
    if BroadcastModel._broadcastConfig.nRunType == 0 then
        label:setPosition(szPanel.width + 10, self._centerY)

        local duration      = (szPanel.width + szFont.width + 40) / moveSpeed
        local actionLeft    = cc.MoveTo:create(duration, { x = - szFont.width, y = self._centerY })

        label:runAction(cc.Sequence:create(
                            actionLeft,
                            cc.Hide:create(),
                            cc.CallFunc:create(handler(self, self.broadcastNext)),
                            cc.CallFunc:create(handler(self, self.broadcastEnd))
                        ))
        -- 从下往上滚动
    else
        label:setPosition(10, self._centerY - szPanel.height)

        local duration = szPanel.height / moveSpeed
        local actionMoveBy = cc.MoveBy:create(duration, { x = 0, y = szPanel.height })
        local actionLeft = nil
        if szFont.width + 20 > szPanel.width then
            local offsetX = szFont.width - szPanel.width + 20
            actionLeft = cc.MoveBy:create(offsetX / moveSpeed, { x = - offsetX, y = 0 })
        end

        label:runAction(cc.Sequence:create(
                            actionMoveBy,           -- 上移到跑到中间
                            actionLeft,             -- 如果消息过长, 则往左移
                            cc.DelayTime:create(1), -- 停留片刻
                            cc.CallFunc:create(handler(self, self.broadcastNext)),  -- 触发播放下一条消息
                            actionMoveBy,           -- 上移到跑到顶部
                            cc.Hide:create(),       -- 隐藏
                            cc.CallFunc:create(handler(self, self.broadcastEnd))    -- 调用播放结束
                        ))
    end
end

function viewCreator:broadcastNext()
    local messageInfo = BroadcastModel:getFirstMsg(false)
    if messageInfo then
        self:broadcastBegin()
    end
end

function viewCreator:broadcastEnd()
    local viewNode = self._viewNode

    local messageInfo = BroadcastModel:getFirstMsg(false)
    if messageInfo then
        return
    end

    if viewNode._label1 and viewNode._label1:isVisible() then
        return
    end
    if viewNode._label2 and viewNode._label2:isVisible() then
        return
    end

    self._bBroadcasting = false
    if viewNode then
        viewNode:setVisible(false)
        viewNode:removeFromParent()
    end

    self:resetMembers()
end

return viewCreator