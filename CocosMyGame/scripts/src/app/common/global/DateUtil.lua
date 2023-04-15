local DateUtil = class("DateUtil", import(".UniqueObject"))

function DateUtil:ctor()
    self:_testCase1()
end

function DateUtil:_testCase1()

end

--确认lua的os.time()时间是否是今天
function DateUtil:isTodayTime(timeVal)
    if timeVal == nil then return false end

    local timeDate = os.date("*t", timeVal)
    local curDate = os.date("*t", os.time())
    if timeDate["day"] ~= nil and timeDate["day"] == curDate["day"] then
        return true
    end

    return false
end

--2018-09-10 12:12:12.000这样的格式字符串，转换为20180910
function DateUtil:dateStrToInterger(dateStr)
    local yearStr = string.sub(dateStr, 1, 4)
    local monthStr = string.sub(dateStr, 6, 7)
    local dayStr = string.sub(dateStr, 9, 10)
    return tonumber(yearStr..monthStr..dayStr)
end

--18:00到第二天6:00为晚上时间
function DateUtil:isNightTime()
    local curDate = os.date("*t", os.time())

    if curDate["hour"] >= 18 and curDate["hour"] <= 23 then
        return true
    end

    if curDate["hour"] >= 0 and curDate["hour"] <= 5 then
        return true
    end

    --测试代码，测试白天晚上大厅背景切换
    --[[if cc.exports.testDaySwitch == true then
        return true
    else
        return false
    end]]--

    return false
end

function DateUtil:getCurTimeSecond()
    local curTimeSec = 0
    local curDate = os.date("*t", os.time())
    curTimeSec = curDate["hour"] * 3600 + curDate["min"] * 60 + curDate["sec"]
    return curTimeSec
end

--获得当前的年月日数字
function DateUtil:getCurYMDNum()
    local curDate = os.date("%Y%m%d",os.time())
    local curYMDNum = tonumber(curDate) or -1
    return curYMDNum
end

return DateUtil