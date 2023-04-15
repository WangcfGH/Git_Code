--显示滚动数字动画的标签；可设置标签背景随数字长度自动扩展、滚动结束回调等
--可自动扩展收缩的背景需要是ImageView等支持缩放的控件，如果是Sprite会出现变形
local NumberScroller = class("NumberScroller")

NumberScroller.DEFAULT_SCROLL_TIME_STEP = 0.05
NumberScroller.DEFAULT_SCROLL_NUM_STEP = 30
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
    self.__rightAlignElements = nil --需要右对齐的元素列表
    self._srollSoundPath = nil --滚动音效
    self._scrollSoundPlayMode = "PlaySound" --滚动音效以PlayMusic还是PlaySound播放
    self._isFormatThousand = false --是否每3位添加分隔符
    self._numberPrefixes = {
        ["negative"] = nil,
        ["zero"] = "+",
        ["positive"] = "+"
    }
    self._numberSuffix = nil
end

function NumberScroller:setNumberPrefixes(numberPrefixes)
    self._numberPrefixes = numberPrefixes
end

function NumberScroller:setNumberSuffix(numberSuffix)
    self._numberSuffix = numberSuffix
end

--numberBg: 标签背景
--minBgWidthByDigit: 背景最小宽度，以数字的位数表示;如果设置一个较大的数值，则可以让背景宽度不变
function NumberScroller:setNumberBackground(numberBg, minBgWidthByDigit)
    self._numberBg = numberBg
    self._minBgWidthByDigit = minBgWidthByDigit
end

--需要右对齐的元素列表
function NumberScroller:setRightAlignElements(elements)
    self._rightAlignElements = elements
end

function NumberScroller:setScrollSound(soundPath, playMode)
    self._scrollSoundPath = soundPath
    self._scrollSoundPlayMode = playMode
end

--设置是否每3位添加分隔符
function NumberScroller:setFormatThousand(isFormatThousand)
    self._isFormatThousand = isFormatThousand
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

function NumberScroller:getCurValue()
    return self._numValue
end

function NumberScroller:setLabelNumber(labelNumber)
    self._labelNumber = labelNumber
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

--设置标签处于可使用状态
function NumberScroller:onEnter()
    if audio.isMusicPlaying() then
        audio.stopMusic(true)
    end
    self._isExited = false
end

--此标签所属场景退出时，必须主动调用一次此标签的onExit，以避免在滚动执行中的时候，父场景退出导致标签被释放的风险
function NumberScroller:onExit()
    if self._isExited == true then return end --退出处理只执行1次
    self:_stopScrollTimer()
    self._isExited = true
end

--直接填值，不播放滚动动画
function NumberScroller:setValueWithoutAnim(num)
    if num == nil then return end
    if self._labelNumber == nil then return end
    if self._isExited == true then return end

    --停止滚动动画
    self:_stopScrollTimer()
    --对控件设置新值
    local originStr = self._labelNumber:getString()
    local newStr = self:_getStringToShow(num)
    local diffLen = string.len(newStr) - string.len(originStr)
    if diffLen > 0 then
        self:stretchBk(originStr, newStr)
    end
    self._labelNumber:setString(newStr)
    if diffLen < 0 then
        self:stretchBk(originStr, newStr)
    end
    self._numValue = num --设置数据
end

--赋值并播放滚动动画
function NumberScroller:setValueWithAnim(num)
    if num == nil then return end
    if self._labelNumber == nil then return end
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

function NumberScroller:stretchBk(originStr, newNumStr)
    if originStr == nil or newNumStr == nil then return end
    if self._numberBg == nil then return end

    local numBg = self._numberBg
    local originalWidth = numBg:getContentSize().width
    local originalStrLen = string.len(originStr)
    local newStrLen = string.len(newNumStr)
    local digitDiff = newStrLen - originalStrLen
    --保证背景的最小长度
    if self._minBgWidthByDigit ~= nil and self._minBgWidthByDigit > 0 then
        if originalStrLen < self._minBgWidthByDigit then originalStrLen = self._minBgWidthByDigit end
        if newStrLen < self._minBgWidthByDigit then newStrLen = self._minBgWidthByDigit end
        digitDiff = newStrLen - originalStrLen
    end
    local widthDiff = digitDiff * self._digitWidth
    numBg:setContentSize(cc.size(originalWidth + widthDiff, numBg:getContentSize().height))

    --右对齐元素需要随背景扩展而扩展
    if self._rightAlignElements ~= nil then
        for _, element in pairs(self._rightAlignElements) do
            element:setPositionX(element:getPositionX() + widthDiff)
        end
    end

    --如果是居中对齐，则需要移动标签位置
    if self._labelNumber ~= nil then
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
        self:_setValue(endNum) --保证标签显示和数据同步
        self:_onScrollEnded()
        return 
    end

    --timeStep = 0, 
    if timeStep <= 0 or numStep <= 0 then
        self:_onScrollEnded()
        return 
    end

    --滚动中
    if self._scrollTimer ~= nil then
        beginNum = self._scrollTempValue
    end

    local diffNum = endNum - beginNum

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
    end


    --播放音效
    if self._scrollSoundPath ~= nil and type(self._scrollSoundPath) == "string" then
        if self._scrollSoundPlayMode == "PlayMusic" then
            audio.playMusic(cc.FileUtils:getInstance():fullPathForFilename(self._scrollSoundPath), false)
        else
            audio.playSound(cc.FileUtils:getInstance():fullPathForFilename(self._scrollSoundPath), false)
        end
    end
   
    self:_stopScrollTimer()
    self._scrollTimer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(callback, timeStep, false)
end

--滚动结束
function NumberScroller:_onScrollEnded()
    if self._isExited == true then return end
    if self._scrollEndCallback ~= nil and type(self._scrollEndCallback) == "function" then
        self._scrollEndCallback()
    end
end

--设置滚动结束的回调函数
function NumberScroller:setScrollEndCallback(callbackFunc)
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

    local originStr = self._labelNumber:getString()
    local newStr = self:_getStringToShow(num)
    local diffLen = string.len(newStr) - string.len(originStr)
    if diffLen > 0 then
        self:stretchBk(originStr, newStr)
    end
    self._labelNumber:setString(newStr)
    if diffLen < 0 then
        self:stretchBk(originStr, newStr)
    end
    self._scrollTempValue = num
end

function NumberScroller:_getStringToShow(numValue)
    local numStr = numValue..""
    if self._isFormatThousand then
        numStr = string.formatnumberthousands(numValue)
    end
    if self._numberPrefixes then
        if numValue < 0 then
            if self._numberPrefixes["negative"] then
                numStr = self._numberPrefixes["negative"]..numStr
            end
        elseif numValue == 0 then
            if self._numberPrefixes["zero"] then
                numStr = self._numberPrefixes["zero"]..numStr
            end
        else
            if self._numberPrefixes["positive"] then
                numStr = self._numberPrefixes["positive"]..numStr
            end
        end
    end
    if self._numberSuffix then
        numStr = numStr..self._numberSuffix
    end
    return numStr
end

return NumberScroller
