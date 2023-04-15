local RoomServer = class('RoomServer')

local logMap = {
    mc.MR_YQW_ALLOC_ROOM,
    mc.MR_YQW_JOIN_ROOM,
    mc.MR_ENTER_ROOM,
    CUSTOM_REQUESTID.SOCKET_ROOM
}

function RoomServer:ctor()
    self._treepack = cc.load('treepack')
    self._respondConfig = import('src.app.GameHall.models.mcsocket.MCSocketRespondConfig')
    self._requestConfig = import('src.app.GameHall.models.mcsocket.MCSocketDataStruct')
    self._requestList = {}
    self._waitingForResponse = false
    self._notifyList = {}
    self:_registConnectionEvent()
    self._isConnectted = false
    self._scheduler = cc.Director:getInstance():getScheduler()
    self._respondTimer = nil

    -- common proxy begin
    self._proxyConnect = false
    self._connectSvrStr = ""
    -- common proxy end
end

function RoomServer:getInstance()
    RoomServer._instance = RoomServer._instance or RoomServer:create()
    return RoomServer._instance
end

function RoomServer:send(requestID, params, needResponse, callback)

    if ((not self._isConnectted) or (not self._client)) then --触发连接的消息改成必须时需要回应的，否则要是leaveRoom和心跳也触发一下就会导致同时在多个房间内从而被房间提出
        if needResponse then
            self:_pushRequest(requestID, params, needResponse, callback)
            self:connect()
        else
            print("unexpected request to send", requestID)
        end
        return 
    end

    if needResponse and self._waitingForResponse then
        self:_pushRequest(requestID, params, needResponse, callback)
        return
    end

    self._callback = callback
    self._requestID = requestID
    printLog("roomserver send", "requestID:%d, needResponse:%s", requestID, tostring(needResponse))

    local exchangeMap = self._requestConfig.getExchMap(requestID, "room")
    local data = self._treepack.alignpack(params, exchangeMap)
    local sessionId = self._client:sendRequest(requestID, data, data:len(), needResponse)
    self:logNetDelay(NR_TimeStampType.kSent, requestID, sessionId)

    if needResponse then 
        self._waitingForResponse = true
        self:_startRequestTimer()
    end

end

function RoomServer:registRespondHandler(respondType, handler)
    self._notifyList[respondType] = handler
end

function RoomServer:unregistRespondHandler(respondType)
    self._notifyList[respondType] = nil
end

function RoomServer:connect()
    if self._isConnectted and  self._client then return end
    if self._client then 
        self:disconnect()
    end
    self:logNetDelay(NR_TimeStampType.kSent, CUSTOM_REQUESTID.SOCKET_ROOM, 0, 0)

    -- self._client = require('src.app.GameHall.models.mcsocket.MCServerCreator').createClient("room")
    -- common proxy begin
    self._client, self._proxyConnect, self._connectSvrStr = require('src.app.GameHall.models.mcsocket.MCServerCreator').createClient("room") 
    -- common proxy end
    self._client:setCallback(handler(self, self._rsCallback))
    self._client:connect()
    self:_startRequestTimer()
end

function RoomServer:disconnect()
    if self._client then 
        self._client:disconnect()
        self._client:destroy()
    end
    self._client = nil
    require('src.app.GameHall.models.mcsocket.MCServerCreator').removeClient("room")
    self._isConnectted = false
    self:_clearRequest()
    self._waitingForResponse = false
    self:_stopRequestTimer()

    -- common proxy begin
    self._connectSvrStr = ""
    self._proxyConnect = false
    -- common proxy end
end

-- setCallback exist for 'syncsender'
function RoomServer:setCallback(callback)
    self._callback_co = callback
end

function RoomServer:setConnectionCallback(callback)
    self._connectionCallback = callback
end

function RoomServer:_rsCallback(clientId, msgType, sessionId, respondType, data, delay)

    printLog("roomserver callback", "msgType:%d, respondType:%d", msgType, respondType)
    if self:_isRequest(msgType) then
        self:_dealWithNotification(respondType, data)
        return
    end
    self._netDelay = delay
    local curRequestID = self._requestID
    self:logNetDelay(NR_TimeStampType.kRecieved, curRequestID, sessionId, respondType)

    -- my.scheduleOnce(function()
    --     if self:_isResponse(msgType) then
    --         local dataMap = self:_resolveData(curRequestID, respondType, data) 
    --         self._waitingForResponse = false
    --         self:_stopRequestTimer()
    --         self:_noticeSender(respondType, dataMap)
    --         self:logNetDelay(NR_TimeStampType.kDealed, curRequestID, sessionId, respondType)
    --     end
    -- end, 0.1)
    local status, msg = my.mxpcall(
        function()
            if self:_isResponse(msgType) then
                local dataMap = self:_resolveData(curRequestID, respondType, data) 
                self._waitingForResponse = false
                self:_stopRequestTimer()
                self:_noticeSender(respondType, dataMap)
                self:logNetDelay(NR_TimeStampType.kDealed, curRequestID, sessionId, respondType)
            end
        end, __G__TRACKBACK__)

    if not status then print(msg) end

    --self._callback = nil
    self:_sendRequestInTrail()

end

function RoomServer:_noticeSender(respondType, dataMap)
    if self._callback then
        local callback = self._callback
        my.scheduleOnce(function()
            callback(respondType, dataMap)
        end)
    elseif self._callback_co then
        self._callback_co(respondType, dataMap)
    end
end

function RoomServer:_sendRequestInTrail()
    
    if #self._requestList > 0 then
        local request = self:_popRequest() 
        self:send(request.requestID, request.params, request.needResponse, request.callback)
    end

end

function RoomServer:_registConnectionEvent()

    self:registRespondHandler(mc.UR_SOCKET_CONNECT, handler(self, self._onConnection))
    self:registRespondHandler(mc.UR_SOCKET_ERROR, handler(self, self._onConnection))
    self:registRespondHandler(mc.UR_SOCKET_GRACEFULLY_ERROR, handler(self, self._onConnection))
    self:registRespondHandler(mc.ADMINMSG_TO_ROOM, handler(self, self._onAdminmsgToRoom))
end

function RoomServer:_onConnection(respondType)
    self:logNetDelay(NR_TimeStampType.kRecieved, CUSTOM_REQUESTID.SOCKET_ROOM, 0, respondType)
    self:_stopRequestTimer()
    if respondType == mc.UR_SOCKET_CONNECT then 
        self._isConnectted = true
        
        -- common proxy begin
        if self._proxyConnect then
            local UR_CONNECT_SERVER = 0 + 110
            self._client:sendRequest(UR_CONNECT_SERVER, self._connectSvrStr, self._connectSvrStr:len(), false)
        end
        -- common proxy end
        
        self:_sendRequestInTrail()
    elseif respondType == mc.UR_SOCKET_ERROR
       or  respondType == mc.UR_SOCKET_GRACEFULLY_ERROR then
        self:disconnect()
    end
    self._connectionCallback(respondType)
    self:logNetDelay(NR_TimeStampType.kDealed, CUSTOM_REQUESTID.SOCKET_ROOM, 0, respondType)
end

function RoomServer:_dealWithNotification(respondType, data)

    local dataMap = self:_resolveData(nil, respondType, data)
    local callback = self._notifyList[respondType]    
    if callback then 
        if respondType == mc.ADMINMSG_TO_ROOM then
            callback(respondType, dataMap, data)
        else
            callback(respondType, dataMap)
        end
    end

end

function RoomServer:_popRequest()
    local request = self._requestList[#self._requestList]
    table.remove(self._requestList)
    return request
end

function RoomServer:_pushRequest(requestID, params, needResponse, callback)
    local request = {
        requestID       = requestID,
        params          = params,
        callback        = callback,
        needResponse = needResponse
    }
    table.insert(self._requestList, request)
end

function RoomServer:_clearRequest()
    self._requestList = {}
end

function RoomServer:_isResponse(msgType)
    return msgType == MsgType.MSG_RESPONSE
end

function RoomServer:_isRequest(msgType)
    return msgType == MsgType.MSG_REQUEST
end

function RoomServer:_resolveData(requestID, respondType, data)
    local exchangeMap = self._respondConfig.getExchMap(respondType, requestID)
    if type(exchangeMap) == "function" then
        return exchangeMap(data)
    elseif exchangeMap and data then
        return self._treepack.unpack(data, exchangeMap)
    end
end

function RoomServer:isConnectted()
    return self._client and self._isConnectted
end

function RoomServer:_startRequestTimer()
    self:_stopRequestTimer()
    local function _onTimeOut()
        print('RoomServer onTimeOut')
        self:_stopRequestTimer()
        print('disconect')
        self:dispatchSocketError()
    end
    self._timeOutID = self._scheduler:scheduleScriptFunc(_onTimeOut, 5, false)
end

function RoomServer:_stopRequestTimer()
    if self._timeOutID then
        self._scheduler:unscheduleScriptEntry(self._timeOutID)
        self._timeOutID = nil
    end
end

function RoomServer:dispatchSocketError()
    self:disconnect()
    self:logNetDelay(timeStampType, CUSTOM_REQUESTID.SOCKET_ROOM, 0, mc.UR_SOCKET_ERROR)
    self:_onConnection(mc.UR_SOCKET_ERROR)
end

function RoomServer:logNetDelay(timeStampType, requestId, session, respondId)
    if table.indexof(logMap, requestId) then
         my.logForNetResearch_EnterRoom(timeStampType, self._netDelay or 0, requestId, session, respondId)
    end
end

function RoomServer:_onAdminmsgToRoom(respondType, adminData, data)  
    --72是SYSTEM_MSG除最后一个字段的前面的大小 
    local str = string.sub(data, 73, -1)
    local utf8Str = MCCharset:getInstance():gb2Utf8String(str, string.len(str))    
    local pos = string.find(utf8Str, ">") or 0     
    local notifyMsg = string.sub(utf8Str, pos + 1)
    my.informPluginByName({
        pluginName = "NoticeDialog",
        params = {
            tipContent  = notifyMsg,                  
        }
    })
    local BroadcastModel = mymodel("hallext.BroadcastModel"):getInstance()
    --策划需求是2分钟一次，播半个小时
    local notifyTable = { 
        MessageInfo = {},       
        nRepeatTimes = 15,
        nInterval = 120
    } 
    notifyTable.MessageInfo.szMsg = notifyMsg
    BroadcastModel:insertBroadcastMsg(notifyTable)
end

return RoomServer