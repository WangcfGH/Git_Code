local TimeCalculator = class("TimeCalculator")
local daysInOneMonth = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}

function TimeCalculator:isLeapYear(year)
    if year % 400 == 0 or (year % 4 == 0 and year % 100 ~= 0) then
        return true
    end
    return false
end

function TimeCalculator:translateTimeToDaysWithoutYear(year, month, day)    
    local days = day
    for i, n in ipairs(daysInOneMonth) do
        if month > i then
            days = days + n
        else
            break
        end
    end

    if month > 2 and self:isLeapYear(year) then            
        days = days + 1
    end       

    return days
end

function TimeCalculator:getDaysBetweenTwoYears(beginYear, endYear)
    local isBeginYearBiggerThenEndYear = false
    if beginYear > endYear then
        isBeginYearBiggerThenEndYear = true

        local tSwap = beginYear
        beginYear = endYear
        endYear = tSwap
    end

    local days = 0
    for i = 1, endYear - beginYear do
        if self:isLeapYear(beginYear + i -1) then
            days = days + 366
        else
            days = days + 365
        end
    end
	
    if isBeginYearBiggerThenEndYear then
        days = days * -1
    end

	return days
end

function TimeCalculator:getDaysBetweenTwoTime(beginYear, beginMonth, beginDay, endYear, endMonth, endDay)
    local yDays = self:getDaysBetweenTwoYears(beginYear, endYear)
 
    local bDays = self:translateTimeToDaysWithoutYear(beginYear, beginMonth, beginDay)
    local eDays = self:translateTimeToDaysWithoutYear(endYear, endMonth, endDay)

    return yDays - bDays + eDays
end

function TimeCalculator:getDaysBetweenTwoDate(beginDate, endDate)--date必须有year, month, day  
    return self:getDaysBetweenTwoTime(beginDate.year, beginDate.month, beginDate.day, endDate.year, endDate.month, endDate.day)
end

function TimeCalculator:getHoursBetweenTwoDate(beginDate, endDate)--date必须有year, month, day, hour
    local days = self:getDaysBetweenTwoDate(beginDate, endDate)
    return self:getHours(days, beginDate.hour, endDate.hour)
end

function TimeCalculator:getMinutesBetweenTwoDate(beginDate, endDate)--date必须有year, month, day, hour, min
    local hours = self:getHoursBetweenTwoDate(beginDate, endDate)
    return self:getMinutes(hours, beginDate.min, endDate.min)
end

function TimeCalculator:getHours(totalDays, beginHour, endHour)
    return totalDays*24 + endHour - beginHour
end

function TimeCalculator:getMinutes(totalHour, beginMinute, endMinute)
    return totalHour*60 + endMinute - beginMinute
end

function TimeCalculator:getDaysLeftInThisMonth(date)--date必须有year, month, day 
    local curMonth = date.month
    local endDate = {}
    endDate.year = date.year
    endDate.month = date.month
    endDate.day = daysInOneMonth[date.month]    

    return self:getDaysBetweenTwoDate(date, endDate) + 1 --1月31日离这个月底还有1天 
end

function TimeCalculator:getCountDownTimer(beginDate, beginTime, endDate, endTime)
    local leftDays = 0

    local startHour = math.floor(beginTime/10000)
    local startMinute = math.floor(beginTime/100)%100
    local startSecond = beginTime%100

    local endHour = math.floor(endTime/10000)
    local endMinute = math.floor(endTime/100)%100
    local endSecond = endTime%100

    if beginDate == 0 or endDate == 0 then
        leftDays = 0
    else
        local startYear = math.floor(beginDate/10000)
        local startMonth = math.floor(beginDate/100)%100
        local startDay = beginDate%100
        
        local endYear = math.floor(endDate/10000)
        local endMonth = math.floor(endDate/100)%100
        local endDay = endDate%100
        
        leftDays = self:getDaysBetweenTwoTime(startYear, startMonth, startDay, endYear, endMonth, endDay)       
    end

    local leftHour = endHour - startHour
    local leftMinute = endMinute - startMinute
    local leftSecond = endSecond - startSecond 

    if leftSecond < 0 then
        leftSecond = 60 + leftSecond
        leftMinute = leftMinute - 1
    end
    if leftMinute < 0 then
        leftMinute = 60 + leftMinute
        leftHour = leftHour - 1
    end
    if leftHour < 0 then
        leftHour = 24 + leftHour
        leftDays = leftDays - 1
    end

    return leftDays, leftHour, leftMinute, leftSecond
end

return TimeCalculator