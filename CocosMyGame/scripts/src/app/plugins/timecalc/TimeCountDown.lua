local TimeCountDown = class("TimeCountDown")
local TimeCalculator = require("src.app.plugins.timecalc.TimeCalculator")
local MyTimeStamp = import('src.app.mycommon.mytimestamp.MyTimeStamp'):getInstance()

function TimeCountDown:ctor(textlab, startdate, enddate, starttime, endtime, callback)
    self._textlab = textlab
    self._startdate = startdate
    self._enddate = enddate
    self._starttime = starttime
    self._endtime = endtime
    self._callback = callback
    self:updatetime()
end

function TimeCountDown:updatetime()
    if self._textlab.getRealNode and tolua.isnull(self._textlab:getRealNode()) then
        self:stopcountdown()
        return
    end

    local strDate = os.date("%Y%m%d")
    local nDate = tonumber(strDate)
    local strTime = os.date("%H%M%S")
    local nTime = tonumber(strTime)
    local sysTime = MyTimeStamp:getLatestTimeStamp()
    if sysTime then
        if self._sysTime then
            local strDay1 = os.date("%d", self._sysTime)
            local strDay2 = os.date("%d", sysTime)
            if strDay1~=strDay2 and self._callback then
                self._callback()
            end
            self._sysTime = sysTime
        else
            self._sysTime = sysTime
        end
        strDate = os.date("%Y%m%d", sysTime)
        nDate = tonumber(strDate)
        strTime = os.date("%H%M%S", sysTime)
        nTime = tonumber(strTime)
    end

    if nDate < self._startdate then
        self._textlab:setString("活动未开启")
    elseif nDate > self._enddate then
        self._textlab:setString("活动已结束")
    elseif nDate == self._enddate and nTime >= self._endtime then
        self._textlab:setString("活动已结束")
    else 
        local leftString = self:calcLefttime(nDate, nTime, self._enddate, self._endtime)
        self._textlab:setString(leftString)
    end
end

function TimeCountDown:calcLefttime(nDate, nTime, nEndDate, nEndTime)
    local leftdays, lefthours, leftminutes, leftseconds = TimeCalculator:getCountDownTimer(nDate, nTime, nEndDate, nEndTime)
    if leftdays >= 1 then
        return string.format("剩余%d天", leftdays)
    else
        return string.format("%02d:%02d:%02d", lefthours, leftminutes, leftseconds)
    end
end

function TimeCountDown:startcountdown()
    if self._countdown == nil then
        self._countdown = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self,self.updatetime),1,false)
    end
end

function TimeCountDown:stopcountdown()
    if self._countdown then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._countdown)
        self._countdown = nil
    end
end

function TimeCountDown:resettime(startdate, enddate, starttime, endtime,callback)
    self._startdate = startdate
    self._enddate = enddate
    self._starttime = starttime
    self._endtime = endtime
    self._callback = callback
    self:updatetime()
end

return TimeCountDown



