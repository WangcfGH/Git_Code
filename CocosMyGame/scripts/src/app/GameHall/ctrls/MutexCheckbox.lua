--[[
    使用MutexCheckBox可以帮你实现下列效果：
    1.所有checkbox互不兼容，触发一个其他关闭
    2.所有checkbox互相兼容，触发其中一个不会影响其他
    3.a与b互斥, a,b 与c兼容， c与d，e互斥, e和c，a互斥
]]

local MutexCheckBox = class("MutexCheckBox")

--[Comment]
--    checkBoxArray checkbox数据组成的数组
--        数组中单个元素包含以下数据：
--        widget : 控件对象,必填
--        callback : 回调函数,选参
--        mutexFlag : 互斥码，同码的开关会互斥,选参
--        bChooseOnly : 是否只能选中不能关闭，选参
--        tipsContext ：点击选项，冒泡的提示语
--     default：默认选项
--     groupCallback：选择框的批量回调
function MutexCheckBox:ctor(checkBoxArray, default, groupCallback)
    self._checkBoxArray = checkBoxArray
    self._groupCallback = groupCallback
    self._default       = default
    self._bEnabled      = true
    self._tipsNode      = nil
    self:initCheckBoxs()
--    self:initDefaultSelection()
end

function MutexCheckBox:setRuleTipsString(str, node)
    if not str or type(str) ~= "string" then return end
    if not node and not self._tipsNode then return end
    if not self._tipsNode then
        self._tipsNode = cc.CSLoader:createNode("res/hallcocosstudio/enterroom_yqw/rule_tips.csb")
        node:getParent():getParent():addChild(self._tipsNode)
        self._tipsNode:setVisible(false)
    end
    if self._tipsNode then
        if node then
            local panelBG = self._tipsNode:getChildByName("Panel_Main"):getChildByName("Panel_Bg")
            local tipsText = panelBG:getChildByName("Text_RuleTips")
            local strTable = my.subContentToTableByNum(str, 10)
            local content = table.concat(strTable, "\n")
            tipsText:setString(content)
            local size = tipsText:getAutoRenderSize()
            if not self._panelHeight then
                self._panelHeight = panelBG:getContentSize().height
            end
            panelBG:setContentSize(cc.size(size.width + 35,self._panelHeight + (#strTable-1) * tipsText:getFontSize()))
            self._tipsNode:setVisible(true)

            local pos = cc.p(node:getPosition())
            local posWors = node:getParent():convertToWorldSpace(pos)
            local viewPos = node:getParent():getParent():convertToNodeSpace(posWors)
            self._tipsNode:setPosition(cc.p(viewPos.x - node:getContentSize().width / 2, viewPos.y + node:getContentSize().height / 2 - 20))
        else
            self._tipsNode:setVisible(false)
        end
    end
end

function MutexCheckBox:initCheckBoxs()
    for index, info in pairs(self._checkBoxArray) do
        local function touchEvent(target, eventType)
            if eventType == TOUCH_EVENT_BEGAN then
                self:setRuleTipsString(info.tipsContext, info.widget)
            elseif eventType == TOUCH_EVENT_ENDED then
                local select = info.widget:isSelected()  --原来的状态
                self:setRuleTipsString(info.tipsContext, nil)
                --必须延迟设置状态，要不然会被顶掉
                my.scheduleOnce(function ()
                    if select and info.bChooseOnly then
                        info.widget:setSelected(select)
                        return
                    end
                    if type(info.callback) == "function" then
                        info.callback({name = select and "unselected" or "selected", target = info.widget}) 
                    end
                    self:selectCheckBoxByIndex(index, not select)
                end)
            elseif eventType == TOUCH_EVENT_CANCELED then
                self:setRuleTipsString(info.tipsContext, nil)
                print(22222222222222222)
            end
        end

        info.widget:addTouchEventListener(touchEvent)
        if info.subWidget then
            info.subWidget:setTouchEnabled(true)
            info.subWidget:addTouchEventListener(touchEvent)
        end
    end
end

function MutexCheckBox:selectCheckBoxByIndex(index, bSelected)
    if not self._bEnabled then return end
    if self._mode == "display" then return end
    if self._checkBoxArray[index] then--and bSelected ~= self._checkBoxArray[index].widget:isSelected() then 
        self._checkBoxArray[index].widget:setSelected(bSelected)
        self:_onEvent(index, {name = bSelected and "selected" or "unselected", target = self._checkBoxArray[index].widget})
    end
end

function MutexCheckBox:initDefaultSelection()
    if type(self._default) ~= "table" then return end
    -- for _, index in pairs(self._default) do
    --     self:selectCheckBoxByIndex(index, true)
    -- end
    for index, info in pairs(self._checkBoxArray) do
        if table.indexof(self._default, index) then
            self:selectCheckBoxByIndex(index, true)
        else
            self:selectCheckBoxByIndex(index, false)
        end
    end
end

function MutexCheckBox:_onEvent(index, event)
    if event.name == "selected" then
        self:_resetMutexWidget(index)
    end

    if type(self._groupCallback) == "function" then
        self._groupCallback(index, event.name == "selected")
    end
end

function MutexCheckBox:_resetMutexWidget(index)
    local target = self._checkBoxArray[index]
    --target.widget:setEnabled(not self._checkBoxArray[index].bChooseOnly)
    for k, info in pairs(self._checkBoxArray) do
        if index ~= k and bit.band(info.mutexFlag or 0, target.mutexFlag or 0) ~= 0 then
--                遍历互斥关系
            info.widget:setSelected(false)
            info.widget:setEnabled(true)
            self:_onEvent(k, {name = "unselected" , target = self._checkBoxArray[index].widget})
        end
    end
end

--[Comment]
--禁用之后所有选项全部回退
--启用之后所有初始化为默认选项
function MutexCheckBox:setGroupEnabled(bEnabled)
    if self._bEnabled == bEnabled then
        return
    end
    for index, info in pairs(self._checkBoxArray) do
        self:selectCheckBoxByIndex(index, false)
    end

    self._bEnabled = bEnabled
    if bEnabled then
        self:initDefaultSelection()
    end
end

function MutexCheckBox:setCheckBoxEnabled(index, bEnabled)
    if self._checkBoxArray[index] then
        local target = self._checkBoxArray[index].widget
        if not bEnabled then
            if target:isSelected() then                       --禁用时取消选中态
                if self._checkBoxArray[index].mutexFlag then  --存在互斥开关时默认至少需要有一个是选中的
                    for i, checkBoxInfo in pairs(self._checkBoxArray) do --找到其中一个与之互斥的开关置为select
                        if checkBoxInfo.mutexFlag == self._checkBoxArray[index].mutexFlag and checkBoxInfo.widget:isTouchEnabled() and i ~= index then
                            self:selectCheckBoxByIndex(i, true)
                            break
                        end
                    end
                end
                self:selectCheckBoxByIndex(index, false)
            end
        end
        target:setTouchEnabled(bEnabled)
        target:setBright(bEnabled)
        self._checkBoxArray[index].subWidget:setTouchEnabled(bEnabled)
    end
end

--扣玩家币start--
function MutexCheckBox:switchToDisplayMode()
    self._mode = "display"
    for index, info in pairs(self._checkBoxArray) do
        if info then
            info.widget:setTouchEnabled(false)
            if info.subWidget then
                info.subWidget:setTouchEnabled(false)
            end
        end
    end
end

function MutexCheckBox:switchToNormalMode()
    self._mode = "normal"
    self:initDefaultSelection()
end
--扣玩家币end--

return MutexCheckBox
