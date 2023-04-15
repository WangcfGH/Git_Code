--定时管理，用于单次定时或循环定时
local TimerManager = class("TimerManager", import(".UniqueObject"))

local timerScheduler = cc.Director:getInstance():getScheduler()

function TimerManager:ctor()
    self._timers = {
        --["xxxx"] = {["timerId"] = nil}
    }
end

--设定唯一单次定时；重复设定会执行“取消旧定时，新建新定时”
function TimerManager:scheduleOnceUnique(timerName, timerFunc, execDelay)
    if timerName == nil or timerFunc == nil then return end
    if type(timerFunc) ~= "function" then return end
    if execDelay == nil then execDelay = 0 end

    --取消已存在的定时
    self:stopTimer(timerName)

    --建立新的定时
    local timerId = nil
    local tempFunc = function()
        timerScheduler:unscheduleScriptEntry(timerId)
        timerFunc()
    end
    timerId = timerScheduler:scheduleScriptFunc(tempFunc, execDelay, false)
    self._timers[timerName] = {["timerId"] = timerId}
end

--设定独立单次定时；由于不给它命名，所以不存在重复定时，每次会新建一个新定时
function TimerManager:scheduleOnceIndependent(timerFunc, execDelay)
    if timerFunc == nil then return end
    if type(timerFunc) ~= "function" then return end
    if execDelay == nil then execDelay = 0 end

    --建立新的定时
    local timerId = nil
    local tempFunc = function()
        timerScheduler:unscheduleScriptEntry(timerId)
        timerFunc()
    end
    timerId = timerScheduler:scheduleScriptFunc(tempFunc, execDelay, false)
end

--立即停止定时，不论它是单次还是循环
function TimerManager:stopTimer(timerName)
    local timerExisted = self._timers[timerName]
    if timerExisted ~= nil then
        timerScheduler:unscheduleScriptEntry(timerExisted["timerId"])
        self._timers[timerName] = nil
    end
end

--循环定时,默认唯一存在;重复设定会执行“取消旧定时，新建新定时”
function TimerManager:scheduleLoop(timerName, timerFunc, execLoop)
    if timerName == nil or timerFunc == nil then return end
    if type(timerFunc) ~= "function" then return end
    if execLoop == nil then execLoop = 1 end

    self:stopTimer(timerName)
    local timerId = timerScheduler:scheduleScriptFunc(timerFunc, execLoop, false)
    self._timers[timerName] = {["timerId"] = timerId}
end

--等待checkFunc()返回true，才执行doFunc；否则使用定时器持续校验执行条件，最多校验maxCheckTimes
function TimerManager:waitUntil(timerName, checkFunc, doFunc, checkStep, maxCheckTimes, doFinalFunc)
    print("TimerManager:waitUntil, timerName "..(timerName or "nil"))
    if timerName == nil or checkFunc == nil or doFunc == nil then
        print("timer param is nil")
        return false
    end

    self:stopTimer(timerName)
    checkStep = checkStep or 0.1
    maxCheckTimes = maxCheckTimes or 5

    local curCheckTimes = 0
    self:scheduleLoop(timerName, function()
        curCheckTimes = curCheckTimes + 1
        if checkFunc() == true then
            printf("checkFunc return true and execute doFunc, curCheckTimes %d, timerName %s", curCheckTimes, timerName)
            self:stopTimer(timerName)
            doFunc()
        else
            printf("checkFunc return false, curCheckTimes %d, timerName %s", curCheckTimes, timerName)
        end

        if curCheckTimes > maxCheckTimes then
            printf("checkFunc timeout and not execute doFunc, curCheckTimes %d, timerName %s", curCheckTimes, timerName)
            self:stopTimer(timerName)
            if doFinalFunc ~= nil then
                doFinalFunc()
            end
        end
    end, checkStep)
end

return TimerManager