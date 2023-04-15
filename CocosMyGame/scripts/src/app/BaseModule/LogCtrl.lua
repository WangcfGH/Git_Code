local LogCtrl           = class('LogCtrl')
local playerModel       = mymodel('hallext.PlayerModel'):getInstance()
local initTime          = socket.gettime() 
--local RoomManager       = import("src.app.GameHall.room.ctrl.RoomManager"):getInstance()

my.addInstance(LogCtrl)
my.setmethods(LogCtrl, require('src.packages.coms.PropertyBinder'))

function LogCtrl:ctor()
    self:init()
end

function LogCtrl:init()
    local implement = plugin.AgentManager:getInstance():getAnalyticsPlugin()
    if implement then
        self:listenEvent()
    end
    self._netLogTrail = {
        [NR_ProcessType.kLoginProcess] = {},
        [NR_ProcessType.kReconnection] = {},
        [NR_ProcessType.kEnterRoom] = {},
        [NR_ProcessType.kOperate] = {},
    }
    self._implement = implement
end

function LogCtrl:listenEvent()
    self:listenTo(playerModel, playerModel.PLAYER_LOGIN_SUCCEEDED, handler(self, self.onPlayerLoginSucceeded))
    self:listenTo(playerModel, playerModel.PLAYER_LOGIN_OFF, handler(self, self.onPlayerLoginOff))
end


function LogCtrl:onPlayerLoginSucceeded(event)
    local userID = event.value.nUserID
    self._curLogUserID = userID
    self._implement:setUserID(userID)
end

function LogCtrl:onPlayerLoginOff()
    self._curLogUserID = nil
end

function LogCtrl:getNetworkTypeString()
    if not self._netWorkStringLock then
        local networkString = { '2G', '3G', 'Wifi', '4G', 'Unknow' }
        local typeString = networkString[DeviceUtils:getInstance():getNetworkType()]
        if typeString == 'Wifi' then
            local wifiInfo = DeviceUtils:getInstance():getGameWifiInfo()
            if wifiInfo then
                typeString = typeString .. '_' .. wifiInfo.wifiLevel
            end
        end
        self._networkTypeString = typeString
        self._netWorkStringLock = true
        my.scheduleOnce(function ()
            self._netWorkStringLock = false
        end, 30)
    end

    return self._networkTypeString
end

function LogCtrl:logForNetResearch(timeStampType, operateType, processType, ping, requestID, port, session, respondID)
    if not isLogNetStatusSupported() then return end

    if  device.platform == "ios" and (not cc.exports.isIOSLogSDKSupported()) and not my.dealEngineVersion() then return end
    printLog("logForNetResearch", "timeStampType:%s, operateType:%s, processType:%s, ping:%s, requestID:%s, port:%s, session:%s, respondID:%s", tostring(timeStampType), tostring(operateType), tostring(processType), tostring(ping), tostring(requestID), tostring(port), tostring(session), tostring(respondID))

    local log = {
        logTime     = os.date('%c',os.time()),                                  --时间
        operaNO     = self:generateOperateNO(),                                 --uniqid 其实是为了辨别logsdk的bug 自植入时间用户id 游戏缩写
        requestID   = tostring(requestID or 0),                                 --消息号
        r_s         = -1,                                                       --收到-发送 
        r_s_p       = -1,                                                       --收到-发送-延迟
        d_s         = -1,                                                       --处理-发送
        d_s_p       = -1,                                                       --处理-发送-延迟
        d_r         = -1,                                                       --处理-收到	
        respondID   = tostring(respondID or 0),                                 --respondID(回应号)
        processType = tostring(processType),                                    --操作类型 
        connectStatus = tostring(self:getNetworkTypeString()),                  --连接状态
        ping        = tostring(ping),                                           --延迟
        processCost = -1,                                                       --总耗时
        pingMsg     = self:getPingMessage(),
        session     = tostring(session or -1),                                  --session
        timeStamp   = tostring(timeStampType),                                  --操作类型（1发送2收到3处理）
        port        = tostring(port or NR_PortType.kClient),                    --端口（1客户端 6sdk）
        exist       = socket.gettime() - initTime,
        status      = NR_STATUS.kSuccess,                                       --异常状态
    }
    self:pushMessageIntoLogTrail(processType, timeStampType, log)
end

function LogCtrl:logForNetResearch_Hall(timeStampType, requestID, port, session, respondID)
    return self:logForNetResearch(
        timeStampType,
        nil,
        self._netProcessFinishedOnece and NR_ProcessType.kReconnection or NR_ProcessType.kLoginProcess,
        mc.getNetDelay(),
        requestID,
        port,
        session, 
        respondID
    )
end

function LogCtrl:pushMessageIntoLogTrail(processType, timeStampType, message)
    if processType == NR_ProcessType.kReconnection then
        local netProcess = import('src.app.BaseModule.NetProcess'):getInstance()
        if (netProcess:isNetStatusFinished() or message.respondID == tostring(mc.UR_SOCKET_ERROR) or message.respondID == tostring(mc.UR_SOCKET_GRACEFULLY_ERROR)) and #self._netLogTrail[processType] == 0 then
            --1. 网络正常的时候不把通勤消息送进队列
            --2. 网络异常的时候不把无意义的套接字断开放进队列
            --必须是网络异常时，非套接字断开的消息才能开启重连队列
            print("do not log reconnection since isNetStatusFinished or socketError")
            return 
        end
    end

    if timeStampType == NR_TimeStampType.kSent then
        message.status = bit.bor(NR_STATUS.kNotRecieved, NR_STATUS.kNotDealed)
    elseif timeStampType == NR_TimeStampType.kRecieved then
        message.status = NR_STATUS.kNotDealed
        local messageSent = self:findMessage(message.requestID, message.session, NR_TimeStampType.kSent, processType)
        if messageSent then
            messageSent.status = bit.band(messageSent.status, bit.bnot(NR_STATUS.kNotRecieved))
            message.r_s =( message.exist - messageSent.exist) * 1000
            message.r_s_p = message.r_s - message.ping
        else
            message.status = bit.bor(message.status, NR_STATUS.kSendNotFound)
        end
    elseif timeStampType == NR_TimeStampType.kDealed or timeStampType == NR_TimeStampType.kEnded or timeStampType == NR_TimeStampType.kError then
        local messageSent = self:findMessage(message.requestID, message.session, NR_TimeStampType.kSent, processType)
        local messageRecieved = self:findMessage(message.requestID, message.session, NR_TimeStampType.kRecieved, processType)
        if messageSent then
            messageSent.status = bit.band(messageSent.status, bit.bnot(NR_STATUS.kNotDealed))
            message.d_s = (message.exist - messageSent.exist) * 1000        --处理-发送
            message.d_s_p = message.d_s - message.ping              --处理-发送-延迟
        else
            message.status = bit.bor(message.status, NR_STATUS.kSendNotFound)
        end
        if messageRecieved then
            messageRecieved.status = bit.band(messageRecieved.status, bit.bnot(NR_STATUS.kNotDealed))
            if messageSent then
                message.r_s = (messageRecieved.exist - messageSent.exist) * 1000 --收到-发送 
                message.r_s_p = message.r_s - message.ping              --收到-发送-延迟
            end
            message.d_r = (message.exist - messageRecieved.exist) * 1000     --处理-收到 
        else
            message.status = bit.bor(message.status, NR_STATUS.kRecieveNotFound)
        end
    end
    table.insert(self._netLogTrail[processType], message)
    self:checkTrailFinished(processType)
end

function LogCtrl:findMessage( requestID, session, timeStampType, processType )
    -- for i, message in pairs(self._netLogTrail[processType]) do
    for i = #self._netLogTrail[processType], 1, -1 do
        --倒序遍历1可以加快速度 2可以准确匹配比如连接套接字等无session操作
        local message = self._netLogTrail[processType][i]
        if message.requestID == tostring(requestID) and message.session == tostring(session) and message.processType == tostring(processType) and message.timeStamp == tostring(timeStampType) then
            return message
        end
    end
    return false
end

--[Comment]
--检查消息队列是否准备好发送，其中211080，210200是游戏中结算的消息和进入游戏成功的消息
function LogCtrl:checkTrailFinished(processType)
    local processTrail = self._netLogTrail[processType]
    local lastMessage = processTrail[#processTrail]
    if lastMessage.timeStamp == tostring(NR_TimeStampType.kDealed)
        and(lastMessage.requestID == tostring(mc.MR_QUERY_DXXW_INFO)
        or ((lastMessage.respondID == tostring(mc.UR_SOCKET_ERROR) or lastMessage.respondID == tostring(mc.UR_SOCKET_GRACEFULLY_ERROR)) and lastMessage.port == NR_PortType.kClient)
        or lastMessage.respondID == tostring(211080) or lastMessage.respondID == tostring(211081)
        or lastMessage.respondID == tostring(210200) or lastMessage.respondID == tostring(210210)) 
        or lastMessage.timeStamp == tostring(NR_TimeStampType.kEnded) 
        or lastMessage.timeStamp == tostring(NR_TimeStampType.kError) then

        lastMessage.isSuccess = tostring(not (lastMessage.respondID == tostring(mc.UR_SOCKET_ERROR) or lastMessage.respondID == tostring(mc.UR_SOCKET_GRACEFULLY_ERROR)))
        lastMessage.processCost = (lastMessage.exist - processTrail[1].exist) * 1000
        self:sendMessagesInTrail(processTrail)
        self._netLogTrail[processType] = {}
        self._netProcessFinishedOnece = true
    end
end

function LogCtrl:sendMessagesInTrail( trail )
    local eventName = BusinessUtils:getInstance():isGameDebugMode() and "NetResearch4.0.1" or "NetResearch4.0.0"
    local buffer = {}
    for _, message in pairs(trail) do
        table.insert(buffer, self:transferMessageToString(message))
    end
    self._implement:logEvent(eventName,  {netdata = table.concat( buffer, "\n"), appcode = my.getAbbrName()})
end

--[Comment]
--用table.value是乱序的
function LogCtrl:transferMessageToString(message)
    --直接声明所需大小的数组，效率是最高的
    local buffer = {
        message["logTime"],
        message["operaNO"],
        message["requestID"],
        message["r_s"],
        message["r_s_p"],
        message["d_s"],
        message["d_s_p"],
        message["d_r"],
        message["respondID"],
        message["processType"],
        message["connectStatus"],
        message["ping"],
        message["processCost"],
        message["pingMsg"],
    }
    return table.concat( buffer, ",")
end

function LogCtrl:getPingMessage()
    local baiduResult = PingModeule:getBaiduPingResult() or {}
    local ctResult = PingModeule:getCt108PingResult() or {}
    local buffer = {
        baiduResult.delay or -1,
        baiduResult.packetloss or -1,
        ctResult.ip or -1,
        ctResult.delay or -1,
        ctResult.packetloss or -1
    }
    return table.concat(buffer, ",")
end

function LogCtrl:generateOperateNO()
    local num = 0
    for i = 1, 4 do
        num = bit.lshift(num, 8) + math.random(0, 127)
    end
    return table.concat({
        math.ceil(socket.gettime() * 1000),
        UserPlugin:getUserID(),
        my.getAbbrName(),
        string.format( "%08X",  num)
    }, ".")
end

function LogCtrl:logSpecialProcess(timeStamp, costTime)
    print("LogCtrl:logSpecialProcess", timeStamp, costTime)
    if not isLogNetStatusSupported() then return end
    if device.platform == "ios" and (not cc.exports.isIOSLogSDKSupported()) and not my.dealEngineVersion() then return end
    local memoryInfo = DeviceUtils:getInstance():getRuntimeMemoryInfo()
    local content = {
        self:generateOperateNO(),
        timeStamp,
        costTime,
        memoryInfo.totalbytes and memoryInfo.totalbytes/(1024*1024) or -1,      --总内存
        memoryInfo.availbytes and memoryInfo.availbytes/(1024*1024) or -1,      --可用内存,
    }
    local eventName = BusinessUtils:getInstance():isGameDebugMode() and "ProcessStudy4.0.1" or "ProcessStudy4.0.0"
    self._implement:logEvent(eventName,  {studydata = table.concat( content, ","), appcode = my.getAbbrName()})
end

cc.exports.LogCtrl = LogCtrl:getInstance()

return LogCtrl