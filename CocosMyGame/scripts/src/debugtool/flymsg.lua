local FlyMsg = class("FlyMsg")

FlyMsg.RES_PATH                = "res/gmtool/msg.csb"

function FlyMsg:ctor(szText, color)
    self:createResNode()

    local panel = self._resNode:getChildByName("Panel")
    panel:setSwallowTouches(false)
    local txtMsg = panel:getChildByName("Text_Msg")
    txtMsg:setString(szText)
    color = color or display.COLOR_WHITE
    txtMsg:setColor(color)

    local function timeout_remove()
        self:remove()
    end
    local action = cc.Sequence:create(
        cc.MoveBy:create(1,cc.p(0, 40)), 
        cc.FadeOut:create(1), 
        cc.CallFunc:create(timeout_remove))
    panel:runAction(action)
end

function FlyMsg:createResNode()
    local node = cc.CSLoader:createNode(self.RES_PATH)    
    node:setAnchorPoint(0.5, 0.5)
    node:setPosition(cc.p(display.cx, display.height/6*5))
    node:setLocalZOrder(1001)
    local curScene = display.getRunningScene()
    curScene:addChild(node)
    self._resNode = node
end

function FlyMsg:remove()
    if self._resNode then
        self._resNode:removeFromParent()
        self._resNode = nil
    end
end

return FlyMsg
