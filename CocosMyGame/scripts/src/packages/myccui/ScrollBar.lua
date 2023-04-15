--滚动条工具
-- 功能包括：
-- 1. 拖动滑块滑动tab页
-- 2. 滑动tab页滑块跟随
-- 3. 滑块大小适应内容屏幕的比例

local ScrollBar = class(ScrollBar)

ScrollBar.ScrollDir = {
    Down = 1,
    Up = 2,
    Left = 3,
    Right = 4
}

--[Comment]
--输入滑块的适应容器，滑块，滚动容器作为构造入参
function ScrollBar:ctor(panel, slider, listView)
    self._panel = panel
    self._slider = slider
    self._listView = listView
    self._panelSize = self._panel:getContentSize()
    self._sliderSize = self._slider:getContentSize()
    self:setScrollDir(self.ScrollDir.Down)
    self:enableSliderEvent()
end    

--[Comment]
--设置窗口和内部容器比例
function ScrollBar:setWindowZonePercent(percent)
    local handlerName = self:isVertical() and "setSliderHeight" or "setSliderWidth"
    local buffer = self:isVertical() and self._panelSize.height or self._panelSize.width
    buffer = type(percent) == "number" and percent < 1 and buffer or buffer / percent
    self[handlerName](self, buffer)
end

function ScrollBar:setSliderHeight(height)
    self._sliderSize.height = height
    self._scrollSize = self._panelSize.height - self._sliderSize.height
    self._slider:setContentSize(self._sliderSize)
    self:scrollToPercent(0)
end

function ScrollBar:setSliderWidth(width)
    self._sliderSize.width = width
    self._scrollSize = self._panelSize.width - self._sliderSize.width
    self._slider:setContentSize(self._sliderSize)
    self:scrollToPercent(0)
end

function ScrollBar:scrollToPercent(percent, event)
    if not (type(percent) == "number" and percent <= 1 and percent >= 0) then return end
    self._percent = percent
    local position = cc.p(self._slider:getPosition())
    if self._scrollDir == self.ScrollDir.Down then
        self._slider:setPosition(cc.p(position.x, self._scrollSize * (1 - percent) + self._sliderSize.height))
    elseif self._scrollDir == self.ScrollDir.Up then
        self._slider:setPosition(cc.p(position.x, self._scrollSize * percent))
    elseif self._scrollDir == self.ScrollDir.Left then
        self._slider:setPosition(cc.p(self._scrollSize * percent, position.y))
    elseif self._scrollDir == self.ScrollDir.Right then
        self._slider:setPosition(cc.p(self._scrollSize * (1 - percent) + self._sliderSize.width, position.y))
    end

    if type(self._slideCallback) == "function" then
        self._slideCallback(self._percent, event)
    end
    self:scrollListViewToPercent(percent)
end

function ScrollBar:scrollOnlySliderToPercent(percent)
    if not (type(percent) == "number" and percent <= 1 and percent >= 0) then return end
    self._percent = percent
    local position = cc.p(self._slider:getPosition())
    if self._scrollDir == self.ScrollDir.Down then
        self._slider:setPosition(cc.p(position.x, self._scrollSize * (1 - percent) + self._sliderSize.height))
    elseif self._scrollDir == self.ScrollDir.Up then
        self._slider:setPosition(cc.p(position.x, self._scrollSize * percent))
    elseif self._scrollDir == self.ScrollDir.Left then
        self._slider:setPosition(cc.p(self._scrollSize * percent, position.y))
    elseif self._scrollDir == self.ScrollDir.Right then
        self._slider:setPosition(cc.p(self._scrollSize * (1 - percent) + self._sliderSize.width, position.y))
    end
end

function ScrollBar:scrollByPercent(percent)
    self:scrollToPercent(self._percent + percent)
end

function ScrollBar:scrollByMove(move)
    local moveLen = self:isVertical() and move.y or move.x
    self:scrollByPercent(-moveLen/self._scrollSize)
end

function ScrollBar:setScrollDir(dir)
    self._scrollDir = dir
    self._scrollSize = self:isVertical() and self._panelSize.height - self._sliderSize.height or self._panelSize.width - self._sliderSize.width
    self._scrollBarSize = self:isVertical() and self._panelSize.height or self._panelSize.width
    self:scrollToPercent(0)
end

function ScrollBar:getCurrentPercent()
    return self._percent
end

function ScrollBar:isHorizontal()
    return self._scrollDir == self.ScrollDir.Left or self._scrollDir == self.ScrollDir.Right
end

function ScrollBar:isVertical()
    return self._scrollDir == self.ScrollDir.Up or self._scrollDir == self.ScrollDir.Down
end

function ScrollBar:setSlideCallback( callback )
    self._slideCallback = callback
end

function ScrollBar:enableSliderEvent()
    self._slider:setTouchEnabled(true)
    local latestPos
    self._slider:onTouch(function(event)
        if event.name == "moved" then
            local movePos = self._slider:getTouchMovePosition()
            self:scrollByMove(cc.p(movePos.x - latestPos.x, movePos.y - latestPos.y))
            latestPos = movePos
        elseif event.name == "began" then
            latestPos = self._slider:getTouchBeganPosition()
        end
    end)
    if self._listView.onScroll then
        self._listView:onScroll(handler(self, self.onScroll))
    elseif self._listView.addScrollViewEventListener then
        self._listView:addScrollViewEventListener(handler(self, self.onScroll))
    else
        self._listView:onTouch(handler(self, self.onScroll))
        self._listView:setBounceEnabled(false)
        self._listView:setInertiaScrollEnabled(false)	
    end

end

function ScrollBar:onScroll(event)
    local innerContainer = self._listView:getInnerContainer()
    local innerPos = innerContainer:getPositionY()
    if innerPos == 0 and event.name ~= "SCROLL_TO_BOTTOM" then return end
    local windowHeight = self._listView:getContentSize().height
    local innerHeight =  innerContainer:getContentSize().height
    self:scrollToPercent((innerPos + innerHeight - windowHeight) / (innerHeight - windowHeight), event)
end

function ScrollBar:scrollListViewToPercent(percent)
    local innerContainer = self._listView:getInnerContainer()
    local innerPos = innerContainer:getPositionY()
    local windowHeight = self._listView:getContentSize().height
    local innerHeight =  innerContainer:getContentSize().height
    
    innerContainer:setPositionY((windowHeight - innerHeight) * (1 - percent))
end

return ScrollBar
