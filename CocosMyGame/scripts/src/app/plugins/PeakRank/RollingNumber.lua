local RollingNumber = class('RollingNumber')

function RollingNumber:ctor(parent, digits)
    self._textNumbers = {}
    self._textNumbers2 = {}
    self._number = 0
    self._numbers = {}
    self._nodeRoot = parent
    self._digits = digits
    self._startY = 0
    self._startY2 = 0
    self:initNumbers()
end

function RollingNumber:initNumbers()
    for i = 1, self._digits do
        local txtNumber = self._nodeRoot:getChildByName('Text_Number_' .. i)
        local txtNumber2 = self._nodeRoot:getChildByName('Text_Number_' .. i .. '_2')
        table.insert(self._textNumbers, txtNumber)

        table.insert(self._textNumbers2, txtNumber2)
        table.insert(self._numbers, 0)
    end
    self._startY = self._textNumbers[1]:getPositionY()
    self._startY2 = self._textNumbers2[1]:getPositionY()
end

function RollingNumber:getNumber()
    return self._number
end

-- number:数值，seconds:时长，degree有效位数
function RollingNumber:rollingTo(number, interval, degree, rollEndCallback)
    local diff = number - self._number
    if diff <= 0 then
        if rollEndCallback then
            rollEndCallback()
        end
        return
    end

    self:setTo(self._number)

    self._number = number

    local difflen = 1
    local num = diff
    while math.floor(num / 10) ~= 0 do
        difflen = difflen + 1
        num = math.floor(num / 10)
    end

    local function rollEnd()
        self:setTo(self._number)
        if rollEndCallback then
            rollEndCallback()
        end
    end

    if difflen <= degree then
        local oneInterval = interval / diff
        if oneInterval > 1 then
            oneInterval = 1
        elseif oneInterval < 0.02 then
            oneInterval = 0.02
        end
        self:rollSingleNumber(1, diff, true, oneInterval, rollEnd)
    else
        diff = math.floor(diff / math.pow(10, difflen - degree))
        local oneInterval = interval / diff
        if oneInterval > 1 then
            oneInterval = 1
        elseif oneInterval < 0.02 then
            oneInterval = 0.02
        end
        for i = 1, difflen - degree do
            self:rollSingleNumber(i, diff, false, oneInterval)
        end
        self:rollSingleNumber(difflen - degree + 1, diff, true, oneInterval, rollEnd)
    end
end

function RollingNumber:setTo(number)
    if type(number) ~= 'number' then
        return
    end

    self._number = number
    self._numbers = {}

    for i, textNumber in ipairs(self._textNumbers) do
        self._textNumbers[i]:stopAllActions()
        self._textNumbers2[i]:stopAllActions()
        self._textNumbers[i]:setPositionY(self._startY)
        self._textNumbers2[i]:setPositionY(self._startY2)
        if number <= 0 then
            self._numbers[i] = 0
            self._textNumbers[i]:setString('0')
        else
            local n = math.floor(number % 10)
            number = math.floor(number / 10)
            self._numbers[i] = n
            self._textNumbers[i]:setString(tostring(n))
        end
    end
end

function RollingNumber:rollSingleNumber(index, count, needCarry, interval, rollEndCallback)
    if count > 0 then
        count = count - 1
        
        local carry = false
        local number = self._numbers[index]
        local number2 = number + 1
        if number2 == 10 then
            number2 = 0
            if needCarry then
                carry = true
            end
        end

        if interval > 1 then
            interval = 1
        end

        local actions = {}
        local actions2 = {}

        self._textNumbers[index]:setString(tostring(number))
        self._textNumbers2[index]:setString(tostring(number2))
        table.insert(actions, cc.MoveBy:create(interval, cc.p(0, 30)))
        table.insert(actions2, cc.MoveBy:create(interval, cc.p(0, 30)))
        table.insert(actions, cc.CallFunc:create(function()
            self._numbers[index] = number2
            self._textNumbers[index]:setString(tostring(number2))
            self._textNumbers[index]:setPositionY(self._startY)
            self:rollSingleNumber(index, count, needCarry, interval, rollEndCallback)
        end))
        table.insert(actions2, cc.CallFunc:create(function()
            self._textNumbers2[index]:setPositionY(self._startY2)
        end))
        
        if carry then
            if index < self._digits then
                self:rollSingleNumber(index + 1, 1, needCarry, interval * 1.2)
            end
        end

        self._textNumbers[index]:runAction(cc.Sequence:create(unpack(actions)))
        self._textNumbers2[index]:runAction(cc.Sequence:create(unpack(actions2)))
    else
        if rollEndCallback then
            rollEndCallback()
        end
    end
end

return RollingNumber