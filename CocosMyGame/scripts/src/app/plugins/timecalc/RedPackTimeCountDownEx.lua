-- 继承TimeCountDownEx, 重载显示等函数
local TimeCountDownEx = require("src.app.plugins.timecalc.TimeCountDownEx");
local RedPackTimeCountDownEx = class("RedPackTimeCountDownEx", TimeCountDownEx)
local TimeCalculator = require("src.app.plugins.timecalc.TimeCalculator")
local RedPack100Model = require("src.app.plugins.RedPack100.RedPack100Model"):getInstance()

function RedPackTimeCountDownEx:updatetime()
    if self._textlab.getRealNode and tolua.isnull(self._textlab:getRealNode()) then
        self:stopcountdown()
        return
    end

    local strDate = os.date("%Y%m%d", self._nowTimeStamp)
    local nDate = tonumber(strDate)
    local strTime = os.date("%H%M%S", self._nowTimeStamp)
    local nTime = tonumber(strTime)

    if nDate < self._startdate then
        self._textlab:setString("活动未开启")
    elseif nDate > self._enddate then
        self._textlab:setString("活动已结束")
        self:stopcountdown()
        RedPack100Model:onCountDownZero()
    elseif nDate == self._enddate and nTime >= self._endtime then
        self._textlab:setString("活动已结束")
        self:stopcountdown()
        RedPack100Model:onCountDownZero()
    else 
        local leftString = self:calcLefttime(nDate, nTime, self._enddate, self._endtime)
        self._textlab:setString(leftString)
        local leftStrTrim = string.trim(leftString)
        if leftString == "00:00:00" then
        --if leftStrTrim == "13:32:00" then
            self:stopcountdown()
            RedPack100Model:onCountDownZero()
        end
    end
    self._nowTimeStamp = self._nowTimeStamp + 1
end

function RedPackTimeCountDownEx:calcLefttime(nDate, nTime, nEndDate, nEndTime)
    local leftdays, lefthours, leftminutes, leftseconds = TimeCalculator:getCountDownTimer(nDate, nTime, nEndDate, nEndTime)
    if leftdays >= 1 then
        return string.format("%d天%02d时%02d分%02d秒", leftdays, lefthours, leftminutes, leftseconds)
    else
        if leftdays < 0 then
            return string.format("%02d:%02d:%02d ", 0, 0, 0)
        else
            return string.format("%02d:%02d:%02d ", lefthours, leftminutes, leftseconds)
        end
    end
end


return RedPackTimeCountDownEx
