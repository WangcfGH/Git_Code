
local BaseGameSelfInfo = class("BaseGameSelfInfo")

function BaseGameSelfInfo:create(selfInfoPanel)
    return BaseGameSelfInfo.new(selfInfoPanel)
end

function BaseGameSelfInfo:ctor(selfInfoPanel)
    self._selfInfoPanel         = selfInfoPanel

    self._selfInfoName          = nil
    self._selfInfoMoneyIcon     = nil
    self._selfInfoMoney         = nil
    self._selfInfoBanker        = nil
    self._selfInfoReady         = nil
    self._bottomWidgets         = {}

    self:init()
end

function BaseGameSelfInfo:init()
    if not self._selfInfoPanel then return end

    self._selfInfoName          = self._selfInfoPanel:getChildByName("SelfInfo_text_name")
    self._selfInfoMoneyIcon     = self._selfInfoPanel:getChildByName("SelfInfo_sp_money")
    self._selfInfoMoney         = self._selfInfoPanel:getChildByName("SelfInfo_text_money")
    self._selfInfoBanker        = self._selfInfoPanel:getChildByName("SelfInfo_sp_banker")
    self._selfInfoReady         = self._selfInfoPanel:getChildByName("SelfInfo_sp_ready")

    self:hideAllChildren()
end

function BaseGameSelfInfo:hideAllChildren()
    if not self._selfInfoPanel then return end

    local selfInfoChildren = self._selfInfoPanel:getChildren()
    for i = 1, self._selfInfoPanel:getChildrenCount() do
        local child = selfInfoChildren[i]
        if child then
            child:setVisible(false)
        end
    end
end

function BaseGameSelfInfo:hideBottom()
    if not self._selfInfoPanel then return end

    for _, widget in pairs(self._selfInfoPanel:getChildren()) do
        if widget.setVisible and widget:isVisible() then 
            local localPosition = cc.p(widget:getPosition())
            local worldPosition = self._selfInfoPanel:convertToWorldSpace(localPosition)
            if worldPosition.y <= display.height/6 then 
                widget:setVisible(false) 
                table.insert(self._bottomWidgets, widget)
            end
        end
    end
end

function BaseGameSelfInfo:showBottom()
    if type(self._bottomWidgets) ~= 'table' then return end
    for _, widget in pairs(self._bottomWidgets) do
        widget:show()
    end
end

function BaseGameSelfInfo:setSelfUserName(szUserName)
    if "string" ~= type(szUserName) then return end

    if self._selfInfoName then
        self._selfInfoName:setVisible(true)
        local utf8name = MCCharset:getInstance():gb2Utf8String(szUserName, string.len(szUserName))
        self._selfInfoName:setString(utf8name)
    end
end

function BaseGameSelfInfo:setSelfMoney(nDeposit)
    if "number" ~= type(nDeposit) then return end

    if self._selfInfoMoney then
        self._selfInfoMoney:setVisible(true)
        self._selfInfoMoney:setString(nDeposit)
    end

    if self._selfInfoMoneyIcon then
        self._selfInfoMoneyIcon:setVisible(true)
    end
end

function BaseGameSelfInfo:showSelfBanker(bBanker)
    if self._selfInfoBanker then
        self._selfInfoBanker:setVisible(bBanker)
    end
end

function BaseGameSelfInfo:showSelfReady(bReady)
    if self._selfInfoReady then
        self._selfInfoReady:setVisible(bReady)
    end
end

function BaseGameSelfInfo:isSelfReadyShow()
    if self._selfInfoReady then
        return self._selfInfoReady:isVisible()
    end
    return false
end

function BaseGameSelfInfo:onGameStart()
    self:showSelfReady(false)
end

function BaseGameSelfInfo:onGameExit()
end

return BaseGameSelfInfo
