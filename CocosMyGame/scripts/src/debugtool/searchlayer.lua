local SearchLayer = class("SearchLayer")

SearchLayer.FIND_DIR_UP     = 1
SearchLayer.FIND_DIR_DOWN   = 2

function SearchLayer:ctor(resNode, gmLayer)
    resNode:setLocalZOrder(1)
    self._resNode = resNode
    self._gmLayer = gmLayer

    self:initChildName()
    self:registEvent()

    self:setMatchCase(false)
    self:setFindDir(self.FIND_DIR_DOWN)

    self._nNowLineIdx = nil
end

function SearchLayer:initChildName()
    local panel         = self._resNode:getChildByName("Panel")
    self.nodes = {
        panel           = panel,
        btnFind         = panel:getChildByName("Btn_Find"),
        btnCancel       = panel:getChildByName("Btn_Cancel"),
        cbMatchCase     = panel:getChildByName("CB_MatchCase"),
        cbUp            = panel:getChildByName("CB_Up"),
        cbDown          = panel:getChildByName("CB_Down"),
        tfSearch        = panel:getChildByName("TF_Search"),
    }
end

function SearchLayer:registEvent()
    self.nodes.btnFind:addClickEventListener(function()
        self:onBtnFind()
    end) 

    self.nodes.btnCancel:addClickEventListener(function()
        self._gmLayer:closeSearch()
    end) 

    self.nodes.cbMatchCase:addEventListener(function(sender, eventType)
        if eventType == ccui.CheckBoxEventType.selected then
            self:setMatchCase(true)
        elseif eventType == ccui.CheckBoxEventType.unselected then
            self:setMatchCase(false)
        end
    end)

    self.nodes.cbUp:addEventListener(function(sender, eventType)
        if eventType == ccui.CheckBoxEventType.selected then
            self:setFindDir(self.FIND_DIR_UP)
        elseif eventType == ccui.CheckBoxEventType.unselected then
            sender:setSelected(true)
        end
    end)

    self.nodes.cbDown:addEventListener(function(sender, eventType)
        if eventType == ccui.CheckBoxEventType.selected then
            self:setFindDir(self.FIND_DIR_DOWN)
        elseif eventType == ccui.CheckBoxEventType.unselected then
            sender:setSelected(true)
        end
    end)       
end

function SearchLayer:setMatchCase(bCase)
    self.bMatchCase = bCase
    self.nodes.cbMatchCase:setSelected(bCase)
end

function SearchLayer:setFindDir(nDir)
    self._findDir = nDir
    self.nodes.cbUp:setSelected(nDir == self.FIND_DIR_UP)
    self.nodes.cbDown:setSelected(nDir == self.FIND_DIR_DOWN)
end

function SearchLayer:isMatch(szOrg, szPattern)
    if not self.bMatchCase then
        szOrg = string.lower(szOrg)
        szPattern = string.lower(szPattern)
    end
    return string.find(szOrg, szPattern)
end

function SearchLayer:onBtnFind()
    self._nNowLineIdx = self._nNowLineIdx or 1

    local szPattern = self.nodes.tfSearch:getString()
    if not szPattern or szPattern == "" then
        self._gmLayer:tipMsg("Please Input The Text For Search!!!", display.COLOR_RED)
        return
    end

    local nDelt = self._findDir == self.FIND_DIR_UP and -1 or 1

    local nCount = 1
    local bFind = false
    local lines = self._gmLayer.tbTextLines

    local function nextIdx(nOldIdx)
        local nNextIdx = nOldIdx + nDelt
        if nNextIdx <= 0 then
            nNextIdx = #lines
        elseif nNextIdx > #lines then
            nNextIdx = 1
        end
        return nNextIdx
    end

    while nCount <= #lines do
        if self:isMatch(lines[self._nNowLineIdx], szPattern) then
            bFind = true
            self._gmLayer:locateToLineForSearch(self._nNowLineIdx)
            self._nNowLineIdx = nextIdx(self._nNowLineIdx)
            break
        end
        self._nNowLineIdx = nextIdx(self._nNowLineIdx)
        nCount = nCount + 1
    end

    if not bFind then
        local szMsg = string.format("Cannot Find string \"%s\"!!!", szPattern)
        self._gmLayer:tipMsg(szMsg, display.COLOR_RED)
    end
end

return SearchLayer
