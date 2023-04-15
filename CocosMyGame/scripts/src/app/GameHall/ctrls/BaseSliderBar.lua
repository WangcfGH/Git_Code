local BaseSliderBar = class("BaseSliderBar")


function BaseSliderBar:ctor(panelSliderBar, nDefaultValue, minValue, maxValue, callBackFunc)
	if not panelSliderBar then return nil end
	if type(callBackFunc) ~= "function" then return nil end

    if not minValue or not maxValue or (minValue>=maxValue) or (maxValue==0) or (minValue <0)
        or (nDefaultValue < minValue) or (nDefaultValue > maxValue) then

        print("On Creat BaseSliderBar Value is Wrong!!")
        return
    end

	self._panelSliderBar    = panelSliderBar
	self._pCallBack         = callBackFunc
    self._currentValue      = nDefaultValue
    self._minValue          = minValue
    self._maxValue          = maxValue

	if self:initSliderBar() then
		return self
	end

	return nil
end

function BaseSliderBar:initSliderBar()
    self._sliderBar = self._panelSliderBar:getChildByName("SliderBar")
    if not self._sliderBar then return false end
    self._txtValue = self._sliderBar:getChildByName("Text_Value")
    self._sliderBar:setPercent(((self._currentValue - self._minValue)/(self._maxValue - self._minValue))*100)
    self._txtValue:setString(tostring(self._currentValue))
    self._btnIncrease = self._panelSliderBar:getChildByName("Btn_Increase")
    self._btnDecrease = self._panelSliderBar:getChildByName("Btn_Decrease")

    self:initEvent()



    if pSliderBar and self._pCallBackList[i] then
        pSliderBar:addEventListenerSliderBar( function(sender, eventType)
            if eventType == ccui.SliderBarEventType.selected then
                self._pCallBackList[i](true)
            elseif eventType == ccui.SliderBarEventType.unselected then
                self._pCallBackList[i](false)
            end
        end )
    end

    if pSliderBar then
        pSliderBar:setSelected(false)
        for j = 1, #self._nChooseTable do
            if i == self._nChooseTable[j] then
                pSliderBar:setSelected(true)
                break
            end
        end
    end


    return true
end

function BaseSliderBar:initEvent()
    if self._sliderBar then
        local listener = cc.EventListenerTouchOneByOne:create()
        listener:registerScriptHandler(handler(self,self.onTouchSlidBar),cc.Handler.EVENT_TOUCH_BEGAN )
        local eventDispatcher = self._sliderBar:getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self._sliderBar)

        self._sliderBar:addEventListener(handler(self, self.onSliderBarChanged))

        self._sliderBarPosX = self._sliderBar:getPositionX()
        self._sliderBarPosY = self._sliderBar:getPositionY()
        self._sliderBarSize = self._sliderBar:getContentSize()
    end

    if self._btnIncrease then
        self._btnIncrease:addClickEventListener(handler(self, self.onClickBtnIncrease))
    end

    if self._btnDecrease then
        self._btnDecrease:addClickEventListener(handler(self, self.onClickBtnDecrease))
    end
end

function BaseSliderBar:onTouchSlidBar(touch,event)
    local touchLocation = touch:getLocationInView()
    touchLocation = cc.Director:getInstance():sharedDirector():convertToGL(touchLocation)
    touchLocation = self._panelSliderBar:convertToNodeSpace(touchLocation)

    local touchRect = cc.rect(self._sliderBarPosX, self._sliderBarPosY, self._sliderBarSize.width, self._sliderBarSize.height)
    if not cc.rectContainsPoint(touchRect, touchLocation) then return end

    local percent = (touchLocation.x - self._sliderBarPosX)/self._sliderBarSize.width
    if percent > 1 or percent < 0 then return end
    self._sliderBar:setPercent(percent*100)
    self:onSliderBarChanged()
end

function BaseSliderBar:onSliderBarChanged()
    if self._sliderBar then
        local percent = self._sliderBar:getPercent()/100
        local value = self._minValue + percent*(self._maxValue - self._minValue)
        value = math.round(value)
        self:onValueChange(value)
    end
end

function BaseSliderBar:onValueChange(value)
    if self._currentValue and value == self._currentValue then return end

    self._currentValue = value
    if self._txtValue then
        self._txtValue:setString(tostring(value))
    end

    self._btnIncrease:setTouchEnabled(self._currentValue < self._maxValue)
    self._btnIncrease:setBright(self._currentValue < self._maxValue)

    self._btnDecrease:setTouchEnabled(self._currentValue > self._minValue)
    self._btnDecrease:setBright(self._currentValue > self._minValue)

    if self._pCallBack and type(self._pCallBack) == "function" then
        self._pCallBack(value)
    end
end

function BaseSliderBar:onClickBtnIncrease()
    if self._currentValue >= self._maxValue then return end

    local value = self._currentValue + 1    --默认以1个单位累加
    if value > self._maxValue then return end

    if self._sliderBar then
        self._sliderBar:setPercent(((value-self._minValue)/(self._maxValue-self._minValue))*100)
        self:onValueChange(value)
    end
end

function BaseSliderBar:onClickBtnDecrease()
    if self._currentValue <= self._minValue then return end

    local value = self._currentValue - 1
    if value < self._minValue then return end

    if self._sliderBar then
        self._sliderBar:setPercent(((value-self._minValue)/(self._maxValue-self._minValue))*100)
        self:onValueChange(value)
    end
end

return BaseSliderBar