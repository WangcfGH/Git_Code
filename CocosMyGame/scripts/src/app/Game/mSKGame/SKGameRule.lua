local SKGameRule                = class("SKGameRule")
local SKGameDef                 = import("src.app.Game.mSKGame.SKGameDef")

function SKGameRule:ctor(rulePanel, gameController)
    if not gameController then printError("gameController is nil!!!") return end
    self._gameController        = gameController

    self._rulePanel             = rulePanel
    self._btnLeft               = nil
    self._btnRight              = nil
    self._pageIndex             = 1
    
    self:init()
end

function SKGameRule:init()
    if not self._rulePanel then return end

    self._rulePanel:setLocalZOrder(SKGameDef.SK_ZORDER_RULE)

    self:setVisible(false)

    local function onLeft()
        self:onLeft()
    end
    
    local btnLeft = self._rulePanel:getChildByName("Button_left")   
    if btnLeft then
        self._btnLeft = btnLeft
        btnLeft:addClickEventListener(onLeft)
    end
    
    local function onRight()
        self:onRight()
    end

    local btnRight = self._rulePanel:getChildByName("Button_right")   
    if btnRight then
        self._btnRight = btnRight
        btnRight:addClickEventListener(onRight)
    end
    
    local function onClose()
        self:onClose()
    end
    local btnClose = self._rulePanel:getChildByName("Button_close")
    if btnClose then
        btnClose:addClickEventListener(onClose)
    end
    
end

function SKGameRule:setVisible(bVisible)
    if self._rulePanel then
        self._rulePanel:setVisible(bVisible)
    end
end

function SKGameRule:isVisible()
    if self._rulePanel then
        return self._rulePanel:isVisible()
    end
    return false
end

local pageIndex = 1
function SKGameRule:showRule(bShow)
    pageIndex = 1
    self:setVisible(bShow)
end

function SKGameRule:onLeft()
    self._gameController:playBtnPressedEffect()
    if self._rulePanel then
        local page = self._rulePanel:getChildByName("Image_page")
        if page then
            pageIndex = pageIndex + 1
            if pageIndex % 2 == 0 then
                page:loadTexture("res/GameCocosStudio/png/rule/rule_page2.png")
            else
                page:loadTexture("res/GameCocosStudio/png/rule/rule_page1.png")
            end
        end
    end
end

function SKGameRule:onRight()
    self._gameController:playBtnPressedEffect()
    if self._rulePanel then
        local page = self._rulePanel:getChildByName("Image_page")
        if page then
            pageIndex = pageIndex + 1
            if pageIndex % 2 == 0 then
                page:loadTexture("res/GameCocosStudio/png/rule/rule_page2.png")
            else
                page:loadTexture("res/GameCocosStudio/png/rule/rule_page1.png")
            end
        end
    end
end

function SKGameRule:onClose()
    self._gameController:playBtnPressedEffect()
    self:showRule(false)
end


return SKGameRule
