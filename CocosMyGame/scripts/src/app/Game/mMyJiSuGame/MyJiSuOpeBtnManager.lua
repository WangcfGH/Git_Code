local MyJiSuOpeBtnManager = class("MyJiSuOpeBtnManager", import("src.app.Game.mMyGame.MyOpeBtnManager"))

local MY_JISU_OPEBTNS_INDEX = {                  --前面3个和SK模板保持一致
    MY_JISU_OPEBTNS_INDEX_THROW      = 1,     -- 要不起按钮
    MY_JISU_OPEBTNS_INDEX_HINT       = 3,
}

function MyJiSuOpeBtnManager:ctor(nodeOpeBtns, gameController)
    if not gameController then printError("gameController is nil!!!") return end
    self._gameController        = gameController

    self._nodeOpeBtns           = nodeOpeBtns
    self._opeBtns               = {}

    self:init()
end

function MyJiSuOpeBtnManager:init()
    self:setOpeBtns()
    self:hideAllChildren()
end

function MyJiSuOpeBtnManager:setOpeBtns()
    if not self._nodeOpeBtns then return end
    
    local function onThrow()
        self:onThrow()
    end
    local buttonThrow = self._nodeOpeBtns:getChildByName("Btn_PlayCards")--ccui.Helper:seekWidgetByName(self._nodeOpeBtns, "Btn_PlayCards")
    if buttonThrow then
        buttonThrow:onTouch(function(e)end) --将touch事件监听置空，防止和选牌混在一起时按钮状态混乱
        buttonThrow:addClickEventListener(onThrow)
        buttonThrow:setPositionX(-43.54) --出牌按钮居中
        local index = MY_JISU_OPEBTNS_INDEX.MY_JISU_OPEBTNS_INDEX_THROW
        self._opeBtns[index] = buttonThrow
    end

    -- local function onHint()
    --     self:onHint()
    -- end
    -- local buttonHint = self._nodeOpeBtns:getChildByName("Btn_Hint")
    -- if buttonHint then
    --     buttonHint:onTouch(function(e)end) --将touch事件监听置空，防止和选牌混在一起时按钮状态混乱
    --     buttonHint:addClickEventListener(onHint)

    --     local index = MY_JISU_OPEBTNS_INDEX.MY_JISU_OPEBTNS_INDEX_HINT
    --     self._opeBtns[index] = buttonHint
    -- end
end

function MyJiSuOpeBtnManager:hideAllChildren()
    if not self._nodeOpeBtns then return end

    local opeBtnChildren = self._nodeOpeBtns:getChildren()
    for i = 1, self._nodeOpeBtns:getChildrenCount() do
        local child = opeBtnChildren[i]
        if child then
            child:setVisible(false)
        end
    end
end

function MyJiSuOpeBtnManager:setTributeVisible(bVisible)
end

function MyJiSuOpeBtnManager:setTributeEnable(bEnable)
end

function MyJiSuOpeBtnManager:containsTouchLocation(x, y)
    if not self._nodeOpeBtns then return false end

    local opeBtnChildren = self._nodeOpeBtns:getChildren()
    for i = 1, self._nodeOpeBtns:getChildrenCount() do
        local child = opeBtnChildren[i]
        if child and child:isVisible() and child:isTouchEnabled() then
            --local position = self._opeBtnPanel:convertToWorldSpace(cc.p(child:getPosition()))
            local btnPosWorld = child:getParent():convertToWorldSpace(cc.p(child:getPosition()))
            local operatePanel = child:getParent():getParent():getParent()
            local btnPosLocalInOperatePanel = operatePanel:convertToNodeSpace(btnPosWorld)
            local position = btnPosLocalInOperatePanel

            local s = child:getContentSize()
            local touchRect = cc.rect(position.x - s.width/2, position.y - s.height/2, s.width, s.height) --AnchorPoint 0.5,0.5
            local b = cc.rectContainsPoint(touchRect, cc.p(x, y))
            if b then
                return b
            end
        end
    end

    return false
end

return MyJiSuOpeBtnManager