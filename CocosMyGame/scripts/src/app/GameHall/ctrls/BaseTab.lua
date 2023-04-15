local BaseTab = class("BaseTab")

function BaseTab:ctor(panelTab, nTabNum, nDefaultShow, pCallBackList)
    self._panelTab      = panelTab
    self._nTabNum       = nTabNum
    self._pCallBackList = pCallBackList
    self._nDefaultShow  = nDefaultShow
    self._tabs          = {}
    self:initTabs()
end

function BaseTab:initTabs()
    for _, pTab in pairs(self._panelTab:getChildren()) do
        --代码评审 杨美玲 资源里的pTab必须连续 0202:使用count顺序无法保证  
        local tabName = pTab:getName()
        local count = tonumber(string.sub(tabName, -1)) 
        --local count = #self._tabs + 1
        if count <= self._nTabNum and self._pCallBackList[count] then
            self:setTabStatus(pTab, count == self._nDefaultShow)
            table.insert(self._tabs, pTab)
            pTab:addClickEventListener( function()
                self:setTabsStatus(count)
                self._pCallBackList[count]()
            end )
        else
            pTab:removeSelf()
        end
    end

    self._panelTab:sortAllChildren()
end

function BaseTab:setTabsStatus(nIndex)
    for i, tab in pairs(self._tabs) do
        self:setTabStatus(tab, i == nIndex)
    end
end

--[Comment]
--被选中触发的是灰态并且无法选中
function BaseTab:setTabStatus(pTab, status)
    if pTab then
        pTab:setEnabled(not status)
        pTab:setBright(not status)
    end
end

return BaseTab