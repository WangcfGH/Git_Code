local ScrollNumberNode = class("ScrollNumberNode", cc.Node)

local DIRECTIONS = {
    TOP_TO_BOTTOM = 1, -- 从上往下
    BOTTOM_TO_TOP = 2  -- 从下往上
}

function ScrollNumberNode:ctor(to, direction)
    if type(direction) ~= 'number' then
        direction = DIRECTIONS.BOTTOM_TO_TOP
    end
    self._direction = direction
    --
    local fntFile = 'res/hallcocosstudio/images/font/gundong_number.fnt'
    local layer = ccui.Layout:create()
    local y = 0
    local width = 0
    local height = 0
    for _, i in pairs({0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 0}) do
        local node = ccui.TextBMFont:create()
        node:setFntFile(fntFile)
        node:setText(tostring(i))
        node:setAnchorPoint(cc.p(0, 0))
        node:setPositionX(0)
        node:setPositionY(y)
        layer:addChild(node)
        if self._direction == DIRECTIONS.BOTTOM_TO_TOP then
            y = y - node:getContentSize().height
        else
            y = y + node:getContentSize().height
        end
        width = node:getContentSize().width
        height = node:getContentSize().height
    end
    layer:setContentSize(cc.size(width, math.abs(y)))
    layer:setPosition(cc.p(0, 0))
    local clippingNode = cc.ClippingRectangleNode:create(cc.rect(0, 0, width, height))
    clippingNode:addChild(layer)
    self:addChild(clippingNode)
    self._layer = layer
    self._oneNumberWidth = width
    self._oneNumberHeight = height
    -- 设定初始数字
    self._from = to
    local move = (to - 0) * self._oneNumberHeight
    local pos = cc.p(self._layer:getPosition())
    local newPos = cc.p(pos.x, pos.y)
    if self._direction == DIRECTIONS.BOTTOM_TO_TOP then
        newPos = cc.p(pos.x, pos.y + move)
    else
        newPos = cc.p(pos.x, pos.y - move)
    end
    self._layer:setPosition(newPos)
end

function ScrollNumberNode:gotoNumber(to, seconds)
    local oldFrom = self._from
    if oldFrom <= to then 
        self._from = to
        local move = (to - oldFrom) * self._oneNumberHeight
        local pos = cc.p(self._layer:getPosition())
        local newPos = cc.p(pos.x, pos.y)
        if self._direction == DIRECTIONS.BOTTOM_TO_TOP then
            newPos = cc.p(pos.x, pos.y + move)
        else
            newPos = cc.p(pos.x, pos.y - move)
        end
        local action = cc.MoveTo:create(seconds, newPos)
        self._layer:runAction(action)
    else
        local step1Move = (10 - oldFrom) * self._oneNumberHeight
        local step2Move = to * self._oneNumberHeight
        local step1Seconds = seconds * step1Move / (step1Move + step2Move)
        local step2Seconds = seconds * step2Move / (step1Move + step2Move)
        local actions = {}
        local pos = cc.p(self._layer:getPosition())
        local newPos = cc.p(pos.x, pos.y) 
        if self._direction == DIRECTIONS.BOTTOM_TO_TOP then
            newPos = cc.p(pos.x, pos.y + step1Move)
        else
            newPos = cc.p(pos.x, pos.y - step1Move)
        end
        table.insert(actions, cc.MoveTo:create(step1Seconds, newPos))
        table.insert(actions, cc.CallFunc:create(function () 
            self._from = 0
            self._layer:setPosition(cc.p(0, 0))
            self:gotoNumber(to, step2Seconds) 
        end))
        self._layer:runAction(cc.Sequence:create(unpack(actions)))
    end
end

function ScrollNumberNode:getVisibleSize()
    return cc.size(self._oneNumberWidth or 0, self._oneNumberHeight or 0)
end

return ScrollNumberNode