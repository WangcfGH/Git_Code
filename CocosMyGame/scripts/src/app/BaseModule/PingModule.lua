local PingModeule = {}

cc.exports.PingModeule = PingModeule

local utils = DeviceUtils:getInstance()
-- local ctDomainMap = {
--     "m1.108uc.com",
--     "m2.108uc.com",
--     "m3.108uc.com",
--     "m4.108uc.com",
--     "m5.108uc.com",
-- }
local latestCtIndex     = 0
local resultMap         = {}
local scheduleHandler   = {}
local respondListener   = {}
local NORMAL_SCHEDULE   = 3 --正常状态3sping一次减少消耗
local RUSHHOUR_SCHEDULE = 1 --异常状态增加ping的速度
local bBackGroud        = false

local function onPingRespond(host)
    if bBackGroud then return end
    
    my.scheduleOnce(function ()
        local result = resultMap[host]
        if result.delay > 300 then
            --ping值较高时玩家对ping的关注度更高，希望能快速看到变化，日志中也可以更明确地看到网络状态变迁
            PingModeule:startPingBoth(RUSHHOUR_SCHEDULE)
        else
            PingModeule:startPingBoth(NORMAL_SCHEDULE)
        end

        if type(respondListener[host]) == "table" then
            for _, handler in pairs(respondListener[host]) do
                handler(result)
            end
        end
        if type(respondListener["all"]) == "table" then
            for _, handler in pairs(respondListener["host"]) do
                handler(result)
            end
        end
    end)    
end

local function ping(host, count, packetsize, timeout)
    if not host then 
        printError("ping require host as input") --host是必填参数， 其他是选参
        return
    end
    local params = {host = host, count = count, packetsize = packetsize, timeout = timeout}
    if not PingModeule:isPingSupported() then return end
    
    utils:ping(json.encode(params), function (ip, delay, packetloss, msg)
        --print("PingLog:",host, ip, delay, packetloss, msg)
        resultMap[host] = resultMap[host] or {}
        resultMap[host] = {ip = ip, delay = delay, packetloss = packetloss, msg = msg}
        onPingRespond(host)
    end)
end

local function pingCt108()
    -- --顺序ping5个域名
    -- latestCtIndex = latestCtIndex%5
    local hallIp = require('src.app.HallConfig.ServerConfig').hall[1]
    ping(hallIp)
    -- latestCtIndex = latestCtIndex + 1
end

local function pingBaidu()
    ping("baidu.com")
end

local function _onForegroundCallback()
    local schedueID
    schedueID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(schedueID)
        bBackGroud = false
        PingModeule:stopPingBoth()
        PingModeule:startPingBoth()
    end, 0.1, false)
end

local function _onBackgroundCallback()
    bBackGroud = true
    PingModeule:stopPingBoth()
end

function PingModeule:startPingBaidu(dt) 
    self:stopPingBaidu()
    scheduleHandler["baidu"] = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function ( ... )
        pingBaidu()
    end, dt, false)
end

function PingModeule:stopPingBaidu()
    if scheduleHandler["baidu"] then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleHandler["baidu"])
        scheduleHandler["baidu"] = nil
    end
end

function PingModeule:startPingCt108(dt)
    self:stopPingCt108()
    scheduleHandler["ct108"] = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function ()
        pingCt108()
    end, dt, false)
end

function PingModeule:stopPingCt108()
    if scheduleHandler["ct108"] then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(scheduleHandler["ct108"])
        scheduleHandler["ct108"] = nil
    end
end

function PingModeule:startPingBoth(dt)
    self:startPingBaidu(dt or NORMAL_SCHEDULE)
    self:startPingCt108(dt or NORMAL_SCHEDULE)
end

function PingModeule:stopPingBoth()
    self:stopPingBaidu()
    self:stopPingCt108()
end

function PingModeule:getPingResult()
    return resultMap
end

function PingModeule:getBaiduPingResult()
    return resultMap["baidu.com"]
end

function PingModeule:getCt108PingResult()
    local hallIp = require('src.app.HallConfig.ServerConfig').hall[1]
    return resultMap[hallIp]
end

function PingModeule:addPingRespondListenr(host, handler)
    if host then
        respondListener[host] = respondListener[host] or {}
        table.insert(respondListener[host], handler)
    else
        respondListener["all"] = respondListener["all"] or {}
        table.insert(respondListener["all"], handler)
    end
end

function PingModeule:addPingRespondListenr(host, handler, tag)
    if host then
        respondListener[host] = respondListener[host] or {}
        if tag then
            respondListener[host][tag] = handler
        else
            table.insert(respondListener[host], handler)
        end 
    else
        respondListener["all"] = respondListener["all"] or {}
        if tag then
            respondListener["all"][tag] = handler
        else
            table.insert(respondListener["all"], handler)
        end 
    end
end

function PingModeule:removeListenerByTag(tag)
    for host, handlers in pairs(respondListener) do
        for tag, handler in pairs(handlers) do
            if handlers[tag] then
                handlers[tag] = function ( ... ) end
            end
        end
    end
end

function PingModeule:isPingSupported()
    if utils.ping then return true end
    return false
end

function PingModeule:initListener()
    AppUtils:getInstance():removePauseCallback("PingModeule_setBackgroundCallback")
    AppUtils:getInstance():addPauseCallback(_onBackgroundCallback, "PingModeule_setBackgroundCallback")
    AppUtils:getInstance():removeResumeCallback("PingModeule_ForegroundCallback")
    AppUtils:getInstance():addResumeCallback(_onForegroundCallback, "PingModeule_ForegroundCallback")
end

function PingModeule:init()
    PingModeule:initListener()
    PingModeule:startPingBoth()
end

return PingModeule