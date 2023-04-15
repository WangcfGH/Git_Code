local ScrollBar = class("ScrollBar")

--滚动条   更新滚动的进度  更新滚动条在父节点的位置实现
function ScrollBar:ctor(barImage, scrollView, defaultUp, defaultDown)
    self._barImage = barImage
    self._barParent = barImage:getParent()
    local ParentHeight = self._barParent:getContentSize().height
    local barHeight = self._barImage:getContentSize().height
    self._moveRange = ParentHeight - barHeight
    self._maxPosY = ParentHeight - barHeight/2
    self._minPosY = barHeight/2

    self:updateScrollBarPos(scrollView)
end

function ScrollBar:resetForScrollView(scrollView)
    self:updateScrollBarPos(scrollView)
end

function ScrollBar:updateScrollBarPos(scrollView)
    local posY = math.abs(scrollView:getInnerContainer():getPositionY())
    local innerHeight = scrollView:getInnerContainerSize().height
    local visibleHeight = scrollView:getContentSize().height 
    local invisibleHeight = innerHeight - visibleHeight

    local moveLength =  invisibleHeight - posY --滚动距离
    local progress = posY / invisibleHeight

    self._barImage:setPositionY(self._minPosY + self._moveRange * progress)
end

return ScrollBar