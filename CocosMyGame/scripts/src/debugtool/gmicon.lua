local GMIcon = class("GMIcon")

GMIcon.RES_PATH                = "res/gmtool/gmicon.csb"

function GMIcon:ctor()
    self:createResNode()

    self:registEvent()
end

function GMIcon:createResNode()
    local node = cc.CSLoader:createNode(self.RES_PATH)    
    node:setAnchorPoint(0.5, 0.5)
    node:setPosition(30, 300)
    node:setLocalZOrder(999)
    local curScene = display.getRunningScene()
    curScene:addChild(node)
    self._resNode = node
end

function GMIcon:registEvent()
    self.pnlMain = self._resNode:getChildByName("Panel")
    self.btnOpen = self.pnlMain:getChildByName("Button_Open")
    self.sprRotate = self.pnlMain:getChildByName("Sprite_Rotate")
    self.sprRotate:hide()

    local staX, staY
    local btn = self.btnOpen
    local function onTouchEvent(sender, eventType)
        if eventType == TOUCH_EVENT_BEGAN then
            btn:setScale(1.1, 1.1)
            btn._ok = true
            btn._startTime = os.clock()
            self:startAction()
        elseif eventType == TOUCH_EVENT_MOVED then
            local begin_p = btn:getTouchBeganPosition()
            local end_p = btn:getTouchMovePosition()
            if math.abs(end_p.y - begin_p.y) > 20 or math.abs(end_p.x - begin_p.x) > 20 then
                btn._ok = false
            end
            local new_x = math.min(math.max(display.left+25, end_p.x), display.right-25)
            local new_y = math.min(math.max(display.bottom+25, end_p.y), display.top-25)
            self._resNode:setPosition(cc.p(new_x, new_y))
        elseif eventType == TOUCH_EVENT_ENDED then
            btn:setScale(1, 1)
            self:stopAction()
            local endx, endy = self._resNode:getPosition()
            if endx < display.cx then
                self._resNode:setPosition(cc.p(display.left+25, endy))
            else
                self._resNode:setPosition(cc.p(display.right-25, endy))
            end
            if btn._ok then
                if os.clock() - btn._startTime > 2 then
                    DbgInterface:disableGMIconInCurrentScene()
                else
                    DbgInterface:showGMLayer()
                end
            end
        elseif eventType == TOUCH_EVENT_CANCELED then
           local endx, endy = self._resNode:getPosition()
            if endx < display.cx then
                self._resNode:setPosition(cc.p(display.left+25, endy))
            else
                self._resNode:setPosition(cc.p(display.right-25, endy))
            end
            btn:setScale(1, 1)
            self:stopAction()
        end
    end
    self.btnOpen:addTouchEventListener(onTouchEvent)
end

function GMIcon:startAction()
    self.sprRotate:show()
    self.sprRotate:runAction(cc.RepeatForever:create(cc.RotateBy:create(0.75, 360)))
end

function GMIcon:stopAction()
    self.sprRotate:hide()
    self.sprRotate:stopAllActions()
end

function GMIcon:remove()
    if self._resNode then
        self._resNode:removeFromParent()
    end
end

return GMIcon
