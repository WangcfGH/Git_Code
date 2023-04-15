local ServerConfig = require('src.app.HallConfig.ServerConfig')
local dataCollector = cc.load('datacollector'):getInstance()

local TreePack = cc.load('treepack')
local RequestConfig = import('src.app.GameHall.models.mcsocket.MCSocketDataStruct')
local ReqDataManual = import('src.app.GameHall.models.mcsocket.MCSocketDataStructManual')

local RespondConfig = import('src.app.GameHall.models.mcsocket.MCSocketRespondConfig')
local REQUEST = import('src.app.GameHall.models.mcsocket.RequestIdList')
local ClientAgent = require('src.app.GameHall.models.mcsocket.MCServerCreator')
local RequestID = REQUEST.RequestIdList
local scheduler = cc.Director:getInstance():getScheduler()

if mc == nil then cc.exports.mc = { } end

local TO_PRINT_MEANING = type(DEBUG) == 'number' and DEBUG >= 0
if TO_PRINT_MEANING then
	mc.RespondIdReflact = REQUEST.RespondIdReflact
    function mc.getIdMeaning(id)
        if id==nil then return 'nil' end

        return  REQUEST.RespondIdReflact[id] or 
                REQUEST.RequestIdReflact[id] or('not existed id #' .. tostring(id))
    end
else
    function mc.getIdMeaning(id)
        return ''
    end
end

setmetatable(mc, { __index = REQUEST.RequestIdList })

local handlersMap = { }
--在该字典中的内容会被埋点记录
local logMap = { 
    mc.CHECK_VERSION,
    mc.GET_SERVERS,
    mc.LOGON_USER,
    mc.QUERY_USER_GAMEINFO,
    mc.QUERY_MEMBER,
    mc.MR_YQW_GET_HAPPY_COIN,
    mc.QUERY_BACKDEPOSIT,
    mc.QUERY_SAFE_DEPOSIT,
    mc.GET_AREAS,
    mc.GET_ROOMS,
    mc.MR_GET_ASSISTSVR,
    -- mc.MR_GET_YQWROOMINFO,
    -- mc.MR_GET_YQWPLAYERINFO,
    mc.MR_QUERY_DXXW_INFO,
    mc.MR_CHECK_NETWORK
}
--在该字典中的消息如果发送超时会重发，重发失败会断网
local lockMap = {
    mc.GET_ROOMS,	            --获取房间列表
    mc.GET_AREAS,	            --获取区列表
    mc.CHECK_VERSION,           --版本校验（不发了）
    mc.QUERY_USER_GAMEINFO,	    --查询用户积分银两
    mc.GET_ASSISTSVR,           --获取assist节点
    mc.MR_QUERY_DXXW_INFO,      --查询经典断线续玩  
    mc.MR_GET_ROOM,             --获取指定房间的房间数据  
    mc.MR_GET_YQWROOMINFO,      --获取指定**房房间数据    
    mc.MR_GET_YQWPLAYERINFO,    --获取自己**房数据（断线续玩）  
    mc.MR_YQW_DON_HAPPY_COIN,   --转赠***    
    mc.MR_LOGON_USER_V2,	    --登录v2  
    --KPI start
    mc.PB_LOGON_USER,	        --登录pb  
    --KPI end
    mc.MR_REQUEST_PULSE,        --心跳等待回应（可以用来检测网络是否断开）？
}
--在该字典中的消息如果发送超时会分发通知，ui界面可监听改通知进行提示
local noticeMap = {
    mc.TRANSFER_DEPOSIT,	    --存保险箱
    mc.MOVE_SAFE_DEPOSIT,	    --取保险箱
    mc.TAKE_BACKDEPOSIT,        --取后备箱
    mc.SAVE_BACKDEPOSIT,	    --存后备箱
    mc.EXCHANGE_WEALTH,	        --兑换通宝
    mc.MR_CLUB_APPLY_JOINCLUB,  --申请加入俱乐部
    mc.MR_CLUB_APPLY_EXITCLUB,  --申请退出俱乐部
    mc.MR_CLUB_GET_PLAYERMSGS,  --获取俱乐部消息
    mc.MR_GET_YQWGAMEWIN,       --获取**房轮战绩X         
    mc.MR_GET_YQWROUNDWIN,      --获取**房战绩X 
    mc.MR_GET_CLUBROUNDWIN,     --获取俱乐部**房战绩X 
    mc.MR_CLUB_GET_CLUBLIST,    --获取俱乐部列表X 	
    mc.MR_CLUB_GET_ALLINFO,     --获取俱乐部信息X
    mc.MR_LOGON_CLUB, 	        --登录俱乐部X
    mc.MR_CLUB_ENTERCLUB, 	    --进入某个俱乐部X
}

local function getRespondHandlerList(respondId)
    assert(respondId, '')
    local respondHandlerList = handlersMap[respondId]
    if (type(respondHandlerList) ~= 'table') then
        respondHandlerList = {
            hall = { },
            room = { }
        }
        handlersMap[respondId] = respondHandlerList
    end
    return respondHandlerList
end

local function registResponseHandler(client, respondId, handler, mcName)
    local respondHandlerList = getRespondHandlerList(respondId)

    respondHandlerList[mcName][client] = handler
end

local function unregistResponseHandler(client, respondId, mcName)
    local respondHandlerList = getRespondHandlerList(respondId)

    respondHandlerList[mcName][client] = nil
end

local function isNotification(mtype)
	return mtype == MsgType.MSG_REQUEST
end
local function isResponse(mtype)
	return mtype == MsgType.MSG_RESPONSE
end
local function isConnectionBroken(respondType, mtype)
	local function typeFilter( respondType )
		return  mc.UR_SOCKET_CLOSE ==  respondType or
			    mc.UR_SOCKET_ERROR ==  respondType or
			    mc.UR_SOCKET_GRACEFULLY_ERROR ==  respondType
	end
	return isNotification(mtype) and typeFilter(respondType)
end

local function handleResponse(respondType, data, dataMap, msgType, mcName)
    --if not isNotification(msgType) then return end
    --event notify handling
    local respondHandlerList = getRespondHandlerList(respondType)

    for _, handler in pairs(respondHandlerList[mcName]) do
        local status, msg = my.mxpcall(
            function()
                handler(respondType, data, msgType, dataMap)
            end, __G__TRACKBACK__)

        if not status then print(msg) end
    end
end

local MyMCServer = class('MyMCServer')

function MyMCServer:ctor(mcclient, mcName)
    self.client = mcclient
    -- bes基础流程优化 跟微信小程序端保持一致,超时时间改成10秒
    self._waitingTime = 10
    self.mcName = mcName
    self._lastDelay = 0
    self._requestMap = {}
    self._timeoutMap = {}
    mcclient:setCallback(handler(self, self.mcCallback))
end

function MyMCServer:destroy()
    if  self.client then 
        self.client:destroy()
        self.client = nil
        ClientAgent.removeClient(self.mcName)
    end
end

function MyMCServer:reconnect()
    self:stopAllTimeOutScheduler()
    self.client:reconnection()
    self:startSocketTimer()
end

function MyMCServer:getData(exchMap, params) 
    dataCollector:addIndex(params)
    local dataList = dataCollector:convert(exchMap.nameMap)
    dataCollector:removeIndex(params)
    if (DEBUG and DEBUG > 1) then dump(dataList) end

    local data
    if (type(exchMap.lengthMap) == 'function') then
        data = exchMap.lengthMap(dataList)
    else
        data = TreePack.alignpack(dataList, exchMap)
    end
    return data
end 

function MyMCServer:sendRequest(requestId, params, sender, needResponse, enableTimeOuts, enableResend, waitingTime)
    local exchMap = RequestConfig.getExchMap(requestId)
    local data
    if exchMap then
        data = self:getData(exchMap, params)
    end

    if not my.isEngineSupportVersion("v1.3.20170401") then --该版本支持了发送空数据
        data = data or " "
    end

    local sessionId  = self.client:sendRequest(requestId, data, data and data:len() or 0, needResponse)

    if needResponse then
        self:setTimeOuts(requestId, params, sender, needResponse, enableTimeOuts, enableResend, waitingTime, sessionId)
        self:keepSession(sessionId, requestId, sender)
    end

    if (TO_PRINT_MEANING) then
        print('MyMCServer:sendRequest()##request[' .. requestId .. ']: ' .. mc.getIdMeaning(requestId))
    end
end

--KPI start
function MyMCServer:sendData(requestId, data, sender, needResponse, enableTimeOuts, enableResend, waitingTime)
    if not my.isEngineSupportVersion("v1.3.20170401") then --该版本支持了发送空数据
        data = data or " "
    end

    local sessionId  = self.client:sendRequest(requestId, data, data and data:len() or 0, needResponse)

    if needResponse then
        self:setTimeOuts(requestId, params, sender, needResponse, enableTimeOuts, enableResend, waitingTime, sessionId)
        self:keepSession(sessionId, requestId, sender)
    end

    if (TO_PRINT_MEANING) then
        print('MyMCServer:sendData()##request[' .. requestId .. ']: ' .. mc.getIdMeaning(requestId))
    end
end
--KPI end

function MyMCServer:dispatchSocketError()
    -- disconnect会导致引擎bug
    -- self.client:disconnect()
    handleResponse(2, nil, {bManual = true}, 1, self.mcName)
    self:stopSocketTimer()
end

function MyMCServer:setTimeOuts(requestId, params, sender, needResponse, enableTimeOuts, enableResend, waitingTime, sessionId)
    printLog('MyMCServer', 'setTimeOuts')
    print(requestId, params, sender, needResponse, enableTimeOuts, enableResend, waitingTime)
    if sessionId < 0 then
        self:dispatchSocketError()
    end

    local waitingTime = waitingTime or self._waitingTime
    local function onTimeOut()
        print('onTimeOut')
        local sender =  self.sender
        self:dropSession(sessionId)
        if not enableTimeOuts then
            print('disconect')
            self:dispatchSocketError()
        elseif enableResend then
            print('resend')
            --只重发一次，第二次断开
            self:sendRequest(requestId, params, sender, needResponse, false, false, waitingTime)
        else
            print('deprecated')
            if sender then
                sender:_handleCallback(mc.CLIENT_LOCAL_TIMEOUT, '', nil, {})
            end
            if table.indexof(noticeMap, requestId) then
                handleResponse(mc.CLIENT_LOCAL_TIMEOUT, nil, {
                    requestId   = requestId,
                    params      = params,
                    sender      = sender,
                    needResponse= needResponse,
                }, 1, self.mcName)
            end
        end
    end
    if self._timeoutMap[sessionId] then
        self:stopTimeOutScheduler(sessionId)
    end
    self._timeoutMap[sessionId] = scheduler:scheduleScriptFunc(onTimeOut, waitingTime, false)
    -- self._timeOutID = scheduler:scheduleScriptFunc(onTimeOut, waitingTime, false)
end

function MyMCServer:stopAllTimeOutScheduler()
    for sessionId, schedule in pairs(self._timeoutMap) do
      scheduler:unscheduleScriptEntry(schedule)
    end
    self._timeoutMap = {}
end

function MyMCServer:stopTimeOutScheduler(sessionId)
    printLog('MyMCServer', 'stopTimeOutScheduler')
    if self._timeoutMap[sessionId] then
        scheduler:unscheduleScriptEntry( self._timeoutMap[sessionId])
        self._timeoutMap[sessionId] = nil
    end
end

function MyMCServer:keepSession(sessionId, requestId, sender)
    self._requestMap[sessionId] = {sessionId = sessionId, requestId = requestId, sender = sender}
    self:logNetDelay(NR_TimeStampType.kSent, requestId, sessionId)
end

function MyMCServer:dropSession(sessionId)
    self:stopTimeOutScheduler(sessionId)
    self._requestMap[sessionId] = nil
end

function MyMCServer:DetectSession(msgType, sessionId, respondId)
    if (TO_PRINT_MEANING) then
        print('##session['..sessionId..'],respond[' ..respondId ..']:'.. mc.getIdMeaning(respondId))
    end
    local good = isNotification(msgType) or self._requestMap[sessionId]
    if not good then
        dump(self._requestMap)
        --printError('waiting session no matched')
        print('waiting session no matched')
    end
    return self._requestMap[sessionId] or {}, good
end

function MyMCServer:updateDelay(delay)
    delay = math.min(delay or 0, 9999)
    if delay > 0 then
        self._lastDelay = delay
        -- todo aveDelay
    end
end

function MyMCServer:getNetDelay()
    return math.floor(self._lastDelay)
end

function MyMCServer:mcCallback(clientId, msgType, sessionId, respondId, data, delay)

    printf('MyMCServer[%s]:mcCallback(client[%d], msgType[%d], session[%d], respond[%d], data, delay[%d])...',
        self.mcName, clientId, msgType, sessionId, respondId, delay or 0)
        
    self:updateDelay(delay)

    local requestInfo, good = self:DetectSession(msgType, sessionId, respondId)

    if not good then return end

    local requestId = requestInfo.requestId

    local function _DataMap(respID, reqID, data)
        local dataMap = {}
        local exchMap = RespondConfig.getExchMap(respID, reqID)
        if exchMap ~= nil then
            if (type(exchMap) == 'function') then
                dataMap = exchMap(data)
            else
                if not data then
                    dump(exchMap)
                else
                    dataMap = TreePack.unpack(data, exchMap)
                end
            end
        end
        return dataMap
    end
    local respondType = respondId
    local dataMap = _DataMap(respondId, requestId, data)
    local sender =  requestInfo.sender
    if (sender and --(isConnectionBroken(respondType, msgType)) or 
        isResponse(msgType) and requestInfo.requestId)
    then
        self:logNetDelay(NR_TimeStampType.kRecieved, requestInfo.requestId, sessionId, respondId)
        self:dropSession(sessionId)
        local status, msg = my.mxpcall(
            function()
                sender:_handleCallback(respondType, data, msgType, dataMap)
                self:logNetDelay(NR_TimeStampType.kDealed, requestId, sessionId, respondId)
            end, __G__TRACKBACK__)
        if not status then print(msg) end
    end
    handleResponse(respondType, data, dataMap, msgType, self.mcName)
    
    if isConnectionBroken(respondType, msgType) or respondType == mc.UR_SOCKET_CONNECT then
        self:stopSocketTimer()
    end
end

function MyMCServer:logNetDelay(timeStampType, requestID, session, respondId)
    if table.indexof(logMap, requestID) then
        my.logForNetResearch_Hall(timeStampType, requestID, nil, session, respondId)
    end
end

function MyMCServer:startSocketTimer()
    self:stopSocketTimer()
    local function _onTimeOut( ... )
        self:stopSocketTimer()
        if DbgInterface then  
            DbgInterface:autoUpdateLogToSever(true)
        end
    end
    self._socketTimer =  scheduler:scheduleScriptFunc(_onTimeOut, getHallReconnectTimeDBGLog() or 5, false)
end

function MyMCServer:stopSocketTimer()
    if self._socketTimer then
        scheduler:unscheduleScriptEntry(self._socketTimer)
        self._socketTimer = nil
    end
end

local MCServers = { 
    ["hall"] = nil,
    ["room"] = nil
}

function MCServers.exist(name)
    return MCServers[name] ~= nil
end

function MCServers.instance(name)

	local inst = MCServers[name]
	if inst == nil then
	    local client = ClientAgent.createClient(name)
	    assert(client, 'MCServers.instance()#'..name)
		inst = MyMCServer:create(client, name)
		MCServers[name] = inst
	end
    inst.client:setCallback(handler(inst, inst.mcCallback))
    return inst
end


local MyClient = class('MyClient')

-- bind handler for specific request id
function MyClient:registHandler(respondId, handler, mcName)
    registResponseHandler(self, respondId, handler, mcName)
    return self
end

function MyClient:unregistHandler(respondId, mcName)
    unregistResponseHandler(self, respondId, mcName)
    return self
end

--[Coment]
--消息发送方式被分为
function MyClient:sendRequest(requestId, params, mcName, needResponse)--, enableTimeOuts, enableResend, waitingTime)
    if not needResponse then
        self:sendRequest_custom(requestId, params, mcName, needResponse)
    elseif table.indexof(lockMap, requestId) then
        --在表中的内容超时重发并且再次重发失败的话就断开
        self:sendRequest_custom(requestId, params, mcName, needResponse, true, true, 5)
    else
        --不在表中的内容超时抛弃
        self:sendRequest_custom(requestId, params, mcName, needResponse, true, false, 5)
    end
    return self
end
--KPI start
--[Coment]
--消息发送方式被分为
function MyClient:sendData(requestId, data, mcName, needResponse)--, enableTimeOuts, enableResend, waitingTime)
    if not needResponse then
        self:sendData_custom(requestId, data, mcName, needResponse)
    elseif table.indexof(lockMap, requestId) then
        --在表中的内容超时重发并且再次重发失败的话就断开
        self:sendData_custom(requestId, data, mcName, needResponse, true, true, 5)
    else
        --不在表中的内容超时抛弃
        self:sendData_custom(requestId, data, mcName, needResponse, true, false, 5)
    end
    return self
end

function MyClient:sendData_custom(requestId, data, mcName, needResponse, enableTimeOuts, enableResend, waitingTime)
    local exchMap, typeName, name = RequestConfig.getExchMap(requestId)
    typeName = mcName or typeName

    printf('MyClient:send('..name..', '..typeName..')')
    MCServers.instance(typeName):sendData(requestId, data, self, needResponse, enableTimeOuts, enableResend, waitingTime)
    return self
end

--KPI end
--[Comment]
--在syncsender里用到了 先保留接口
function MyClient:send(...)
    return self:sendRequest(...)
end

function MyClient:sendRequest_custom(requestId, params, mcName, needResponse, enableTimeOuts, enableResend, waitingTime)
    params = checktable(params)

    local exchMap, typeName, name = RequestConfig.getExchMap(requestId)
    typeName = mcName or typeName

    printf('MyClient:send('..name..', '..typeName..')')
    MCServers.instance(typeName):sendRequest(requestId, params, self, needResponse, enableTimeOuts, enableResend, waitingTime)
    return self
end

---------------------------------------
-- set callback handler for request sent
-- @param handler function
-- @usage type of handler is function(respondType,data,msgType,dataMap) ... end
-- @usage respondType is respondId in callback
-- @usage data is original data in callback
-- @usage msgType is msgType in callback
-- @usage dataMap comes from unpacking data
function MyClient:setCallback(handler)
    self.callback = handler
    return self
end

function MyClient:_handleCallback(...)
    if (self.callback) then
        self.callback(...)
    end
    return self
end

function MyClient:destroy(name)
	local myserver = MCServers[name]
    if  myserver then 
        myserver:destroy()
        MCServers[name] = nil
    end
end

function MyClient:reconnect(name)
    MCServers.instance(name):reconnect()
end

function MyClient:dispatchSocketError(name)
    MCServers.instance(name):dispatchSocketError()
end

------------
-- public interface to create client
function mc.createClient()
    return MyClient:create()
end

--------------------
function mc.getNetDelay()
    return MCServers.instance("hall"):getNetDelay()
end

mc.existMCServer = MCServers.exist
mc.instMCServer  = MCServers.instance
mc.isConnectionBroken = isConnectionBroken
mc.isResponse = isResponse

return mc
