--显示滚动数字动画的标签；可设置标签背景随数字长度自动扩展、滚动结束回调等
--可自动扩展收缩的背景需要是ImageView等支持缩放的控件，如果是Sprite会出现变形
local NumberScroller = class("NumberScroller")

NumberScroller.DEFAULT_SCROLL_TIME_STEP = 0.05
NumberScroller.DEFAULT_SCROLL_NUM_STEP = 20
NumberScroller.DEFAULT_DIGIT_WIDTH = 15

function NumberScroller:ctor(labelNumber)
    self._labelNumber = labelNumber
    self._isExited = false

    self._numValue = 0 --记录最终值
    self._scrollTempValue = 0
    self._scrollNumStep = NumberScroller.DEFAULT_SCROLL_NUM_STEP --滚动数值间隔
    self._scrollTimeStep = NumberScroller.DEFAULT_SCROLL_TIME_STEP --滚动时间间隔
    self._digitWidth = NumberScroller.DEFAULT_DIGIT_WIDTH   --数字宽度
    self._scrollTimer = nil --滚动动画循环定时器
    self._isFirstTimeScroll = true --第一次赋值是否滚动
    self._numberBg = nil --背景
    self._minBgWidthByDigit = nil --背景最小长度
end

--numberBg: 标签背景
--minBgWidthByDigit: 背景最小宽度，以数字的位数表示;如果设置一个较大的数值，则可以让背景宽度不变
function NumberScroller:setNumberBackground(numberBg, minBgWidthByDigit)
    self._numberBg = numberBg
    self._minBgWidthByDigit = minBgWidthByDigit
end

function NumberScroller:setFirstTimeScroll(isFirstTimeScroll)
    self._isFirstTimeScroll = isFirstTimeScroll
    if self._isFirstTimeScroll ~= false then
        self._isFirstTimeScroll = true
    end
end

function NumberScroller:getNumberBg()
    return self._numberBg
end

function NumberScroller:getLabelNumber()
    return self._labelNumber
end

--动画每次滚动的数值间隔
function NumberScroller:setScrollNumStep(numStep)
    if numStep == nil or numStep <=0 then return end

    self._scrollNumStep = numStep
end

--动画每次滚动的时间间隔
function NumberScroller:setScrollTimeStep(timeStep)
    if timeStep == nil or timeStep <=0 then return end

    self._scrollTimeStep = timeStep
end

--设置数字的每一位的宽度
function NumberScroller:setDigitWidth(digitWidth)
    if digitWidth == nil or digitWidth <=0 then return end

    self._digitWidth = digitWidth
end

--此标签所属场景退出时，必须主动调用一次此标签的onExit，否则滚动动画会执行到滚动结束，而此时父场景又退出了，很可能会出现问题
function NumberScroller:onExit()
    if self._isExited == true then return end --退出处理只执行1次
    self:_stopScrollTimer()
    self._isExited = true
end

--直接填值，不播放滚动动画
function NumberScroller:setValueWithoutAnim(num)
    if num == nil then return end
    if tolua.isnull(self._labelNumber) then return end
    if self._isExited == true then return end

    --停止滚动动画
    self:_stopScrollTimer()

    --对控件设置新值
    local originStr = self._labelNumber:getString()
    local diffLen = string.len(num.."") - string.len(originStr)
    if diffLen > 0 then
        self:stretchBk(originStr, num)
    end
    self._labelNumber:setString(num)
    if diffLen < 0 then
        self:stretchBk(originStr, num)
    end
    self._numValue = num --设置数据
end

--赋值并播放滚动动画
function NumberScroller:setValueWithAnim(num)
    if num == nil then return end
    if tolua.isnull(self._labelNumber) then return end
    if self._isExited == true then return end

    if self._isFirstTimeScroll == false then
        if self._isFirstTimeSetValue == nil or self._isFirstTimeSetValue == true then
            self._isFirstTimeSetValue = false
            self:setValueWithoutAnim(num)
        else
            self._isFirstTimeSetValue = false
            self:_startScrollNum(self._numValue, num, self._scrollTimeStep, self._scrollNumStep)
        end
    else
        self._isFirstTimeSetValue = false
        self:_startScrollNum(self._numValue, num, self._scrollTimeStep, self._scrollNumStep)
    end
    self._numValue = num --设置数据
end

function NumberScroller:stretchBk(originStr, newNum)
    if originStr == nil or newNum == nil then return end
    if self._numberBg == nil then return end

    local numBg = self._numberBg
    local originalWidth = numBg:getContentSize().width
    local originalStrLen = string.len(originStr)
    local newStrLen = string.len(newNum.."")
    local digitDiff = newStrLen - originalStrLen
    --保证背景的最小长度
    if self._minBgWidthByDigit ~= nil and self._minBgWidthByDigit > 0 then
        if originalStrLen < self._minBgWidthByDigit then originalStrLen = self._minBgWidthByDigit end
        if newStrLen < self._minBgWidthByDigit then newStrLen = self._minBgWidthByDigit end
        digitDiff = newStrLen - originalStrLen
    end
    local widthDiff = digitDiff * self._digitWidth
    numBg:setContentSize(cc.size(originalWidth + widthDiff, numBg:getContentSize().height))

    if not tolua.isnull(self._labelNumber) then
        local labelAnchorPoint = self._labelNumber:getAnchorPoint()
        if labelAnchorPoint[1] == 0.5 then
            self._labelNumber:setPositionX(self._labelNumber:getPositionX() + widthDiff / 2)
        end
    end
end

--播放滚动动画
function NumberScroller:_startScrollNum(beginNum, endNum, timeStep, numStep)
    if beginNum == nil or endNum == nil or timeStep == nil or numStep == nil then return end
    if beginNum == endNum then
        self:_onScrollEnded()
        return 
    end
    if timeStep <= 0 or numStep <= 0 then
        self:_onScrollEnded()
        return 
    end

    --滚动中
    if self._scrollTimer ~= nil then
        beginNum = self._scrollTempValue
    end

    local diffNum = endNum - beginNum
    local originStr = self._labelNumber:getString()
    local function callback()
        local number = 0
        if diffNum <=  numStep and diffNum > 0 then
            number = beginNum + 1
        elseif diffNum < 0 and diffNum >= -numStep then
            number = beginNum - 1
        else
            number = beginNum +  math.floor(diffNum / numStep)
        end

        if diffNum > 0 then --add
		    if number >= endNum then
                self:_setValue(endNum)
			    self:_stopScrollTimer()
                self:_onScrollEnded()
		    else
                beginNum = number
                self:_setValue(number)
		    end
	    else                --less
		    if number <= endNum then
                self:_setValue(endNum)
			    self:_stopScrollTimer()
                self:_onScrollEnded()
		    else
			    beginNum = number
                self:_setValue(beginNum)
		    end
        end
        self:_onScrollIng()
    end
    self:_stopScrollTimer()
    self._scrollTimer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(callback, timeStep, false)
end

--滚动结束
function NumberScroller:_onScrollEnded()
    if self._isExited == true then return end
    if self._scrollEndCallbackOwner ~= nil then
        if self._scrollEndCallback ~= nil and type(self._scrollEndCallback) == "function" then
            self._scrollEndCallback(self._scrollEndCallbackOwner)
        end
    end
end

--设置滚动结束的回调函数
function NumberScroller:setScrollEndCallback(callbackOwner, callbackFunc)
    self._scrollEndCallbackOwner = callbackOwner
    self._scrollEndCallback = callbackFunc
end

function NumberScroller:_stopScrollTimer()
    if self._scrollTimer ~= nil then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._scrollTimer)
        self._scrollTimer = nil
    end
end

--随着滚动动画设置滚动到的值
function NumberScroller:_setValue(num)
    if num == nil then return end
    if self._isExited == true then return end

    if tolua.isnull(self._labelNumber) then
        return
    end

    local originStr = self._labelNumber:getString()
    local diffLen = string.len(num.."") - originStr
    if diffLen > 0 then
        self:stretchBk(originStr, num)
    end
    self._labelNumber:setString(num)
    if diffLen < 0 then
        self:stretchBk(originStr, num)
    end
    self._scrollTempValue = num
end

--滚动过程回调
function NumberScroller:_onScrollIng()
    if self._isExited == true then return end
    if self._scrollingCallbackOwner ~= nil then
        if self._scrollingCallback ~= nil and type(self._scrollingCallback) == "function" and not tolua.isnull(self._labelNumber) then
            self._scrollingCallback(self._scrollingCallbackOwner, self._labelNumber, self._scrollTempValue)
        end
    end
end

--设置滚动过程的回调函数
function NumberScroller:setScrollIngCallback(callbackOwner, callbackFunc)
    self._scrollingCallbackOwner = callbackOwner
    self._scrollingCallback = callbackFunc
end

return NumberScroller
