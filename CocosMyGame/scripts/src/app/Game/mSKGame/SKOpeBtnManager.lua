
local SKOpeBtnManager = class("SKOpeBtnManager")

local BaseGameDef                               = import("src.app.Game.mBaseGame.BaseGameDef")

local SK_OPEBTNS_INDEX = {
    SK_OPEBTNS_INDEX_THROW      = 1,
    SK_OPEBTNS_INDEX_PASS       = 2,
    SK_OPEBTNS_INDEX_HINT       = 3,
}

function SKOpeBtnManager:IS_BIT_SET(flag, mybit)
    if not flag or not mybit then
        return false
    end
    return (mybit == bit._and(mybit, flag))
end

function SKOpeBtnManager:ctor(opeBtnPanel, gameController)
    if not gameController then printError("gameController is nil!!!") return end
    self._gameController        = gameController

    self._opeBtnPanel           = opeBtnPanel
    self._opeBtns               = {}

    self:init()
end

function SKOpeBtnManager:init()
    if self._opeBtnPanel then
        self._opeBtnPanel:setSwallowTouches(false)
    end
    
    self:setOpeBtns()
    self:hideAllChildren()
end

function SKOpeBtnManager:setOpeBtns()
    if not self._opeBtnPanel then return end
    
    local function onThrow()
        self:onThrow()
    end
    local buttonThrow = ccui.Helper:seekWidgetByName(self._opeBtnPanel, "Btn_PlayCards")
    if buttonThrow then
        buttonThrow:onTouch(function(e)end) --将touch事件监听置空，防止和选牌混在一起时按钮状态混乱
        buttonThrow:addClickEventListener(onThrow)
        
        local index = SK_OPEBTNS_INDEX.SK_OPEBTNS_INDEX_THROW
        self._opeBtns[index] = buttonThrow
    end
    
    local function onPass()
        self:onPass()
    end
    local buttonPass = ccui.Helper:seekWidgetByName(self._opeBtnPanel, "Btn_Skip")
    if buttonPass then
        buttonPass:onTouch(function(e)end) --将touch事件监听置空，防止和选牌混在一起时按钮状态混乱
        buttonPass:addClickEventListener(onPass)

        local index = SK_OPEBTNS_INDEX.SK_OPEBTNS_INDEX_PASS
        self._opeBtns[index] = buttonPass
    end
    
    local function onHint()
        self:onHint()
    end
    local buttonHint = ccui.Helper:seekWidgetByName(self._opeBtnPanel, "Btn_Hint")
    if buttonHint then
        buttonHint:onTouch(function(e)end) --将touch事件监听置空，防止和选牌混在一起时按钮状态混乱
        buttonHint:addClickEventListener(onHint)

        local index = SK_OPEBTNS_INDEX.SK_OPEBTNS_INDEX_HINT
        self._opeBtns[index] = buttonHint
    end
end

function SKOpeBtnManager:onThrow()
    self._gameController:playCardsBtnPressedEffect()
    
    if self._gameController then
        self._gameController:onThrow()
    end
end

function SKOpeBtnManager:onPass()
    self._gameController:playCardsBtnPressedEffect()

    if self._gameController then
        self._gameController:onPassCard()
    end
end

function SKOpeBtnManager:onHint()
    self._gameController:playCardsBtnPressedEffect()

    if self._gameController then
        self._gameController:onHint()
    end
end

function SKOpeBtnManager:hideAllChildren()
    if not self._opeBtnPanel then return end

    local opeBtnChildren = self._opeBtnPanel:getChildren()
    for i = 1, self._opeBtnPanel:getChildrenCount() do
        local child = opeBtnChildren[i]
        if child then
            child:setVisible(false)
        end
    end
end

function SKOpeBtnManager:containsTouchLocation(x, y)
    if not self._opeBtnPanel then return false end

    local opeBtnChildren = self._opeBtnPanel:getChildren()
    for i = 1, self._opeBtnPanel:getChildrenCount() do
        local child = opeBtnChildren[i]
        if child and child:isVisible() then
            local position = self._opeBtnPanel:convertToWorldSpace(cc.p(child:getPosition()))
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

function SKOpeBtnManager:setThrowEnable(bEnable)
    if self._opeBtns[SK_OPEBTNS_INDEX.SK_OPEBTNS_INDEX_THROW] then
        self._opeBtns[SK_OPEBTNS_INDEX.SK_OPEBTNS_INDEX_THROW]:setTouchEnabled(bEnable)
        self._opeBtns[SK_OPEBTNS_INDEX.SK_OPEBTNS_INDEX_THROW]:setBright(bEnable)
    end
end

function SKOpeBtnManager:showOperationBtns(status, bFirstHand)
    if self:IS_BIT_SET(status, BaseGameDef.BASEGAME_TS_WAITING_THROW) then
        if self._opeBtns[SK_OPEBTNS_INDEX.SK_OPEBTNS_INDEX_THROW] then
            self._opeBtns[SK_OPEBTNS_INDEX.SK_OPEBTNS_INDEX_THROW]:setVisible(true)
        end
        if self._opeBtns[SK_OPEBTNS_INDEX.SK_OPEBTNS_INDEX_HINT] then
            self._opeBtns[SK_OPEBTNS_INDEX.SK_OPEBTNS_INDEX_HINT]:setVisible(true)
        end
        if self._opeBtns[SK_OPEBTNS_INDEX.SK_OPEBTNS_INDEX_PASS] then
            self._opeBtns[SK_OPEBTNS_INDEX.SK_OPEBTNS_INDEX_PASS]:setVisible(true)
            self._opeBtns[SK_OPEBTNS_INDEX.SK_OPEBTNS_INDEX_PASS]:setTouchEnabled(not bFirstHand)
            self._opeBtns[SK_OPEBTNS_INDEX.SK_OPEBTNS_INDEX_PASS]:setBright(not bFirstHand)
        end
    end
end

function SKOpeBtnManager:hideOperationBtns()
    self:hideAllChildren()
end

return SKOpeBtnManager