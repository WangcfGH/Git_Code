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

return TimeCalculator