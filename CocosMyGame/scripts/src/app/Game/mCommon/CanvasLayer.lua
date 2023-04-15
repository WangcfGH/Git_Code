
local CanvasLayer = class("CanvasLayer", cc.Layer)

function CanvasLayer:ctor(color, width, height)
    if self.onCreate then self:onCreate(color, width, height) end
end

function CanvasLayer:onCreate(color, width, height)
    self:init(color, width, height)
end

function CanvasLayer:init(color, width, height)
    local colorNode = cc.LayerColor:create(color, width, height)
    if colorNode then
        self:addChild(colorNode)
    end

    local function onTouchEvent(eventType, x, y)
        if eventType == "began" then
            return true
        elseif eventType == "moved" then
        elseif eventType == "ended" then
        end
    end
    self:setTouchEnabled(true)
    self:registerScriptTouchHandler(onTouchEvent, false, 0, true)
end

return CanvasLayer
