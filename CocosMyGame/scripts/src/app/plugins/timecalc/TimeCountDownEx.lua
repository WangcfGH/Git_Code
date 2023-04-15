local TimeCountDownEx = class("TimeCountDownEx")
local TimeCalculator = require("src.app.plugins.timecalc.TimeCalculator")

-- 对TimeCountDown类的扩展，用外部传进来的时间戳来倒计时
function TimeCountDownEx:ctor(textlab, startdate, enddate, starttime, endtime, nowTimeStamp)
    self._textlab = textlab
    self._startdate = startdate
    self._enddate = enddate
    self._starttime = starttime
    self._endtime = endtime
    self._nowTimeStamp = nowTimeStamp

    self:updatetime()
end

function TimeCountDownEx:updatetime()
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
    elseif nDate == self._enddate and nTime >= self._endtime then
        self._textlab:setString("活动已结束")
    else 
        local leftString = self:calcLefttime(nDate, nTime, self._enddate, self._endtime)
        self._textlab:setString(leftString)
        local PhoneFeeGiftModel = import("src.app.plugins.PhoneFeeGift.PhoneFeeGiftModel"):getInstance()
        if leftString == "00:00:00" then
            self:stopcountdown()
            PhoneFeeGiftModel:onCountDownZero()
        elseif leftString == "23:59:59" then
            PhoneFeeGiftModel:onCountDownNewDay()
        end
    end
    self._nowTimeStamp = self._nowTimeStamp + 1
end

function TimeCountDownEx:calcLefttime(nDate, nTime, nEndDate, nEndTime)
    local leftdays, lefthours, leftminutes, leftseconds = TimeCalculator:getCountDownTimer(nDate, nTime, nEndDate, nEndTime)
    if leftdays >= 1 then
        return string.format("%02d:%02d:%02d", (leftdays-1)*24 + lefthours, leftminutes, leftseconds)
    else
        return string.format("%02d:%02d:%02d", 0, 0, 0)
    end
end


function TimeCountDownEx:startcountdown()
    if self._countdown == nil then
        self._countdown = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self,self.updatetime),1,false)
    end
end

function TimeCountDownEx:stopcountdown()
    if self._countdown then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._countdown)
        self._countdown = nil
    end
end

function TimeCountDownEx:resettime(startdate, enddate, starttime, endtime, nowTimeStamp)
    self._startdate = startdate
    self._enddate = enddate
    self._starttime = starttime
    self._endtime = endtime
    self._nowTimeStamp = nowTimeStamp
    self:updatetime()
end

return TimeCountDownEx
