--[[
    Example:
    local TestCtrl  = class('TestCtrl')

    function TestCtrl:ctor()
        self._assitModel = require('src.app.GameHall.models.assist.AssitModel'):getInstance()

        -- regist callback
        self._assitModel:registCtrl(self, self.dealwithResponse)

        -- regist event
        -- "listenTo" func need to "my.setmethods(TestCtrl, cc.load('coms').WidgetEventBinder)"
        self:listenTo(self._assitMode, AssitMode.ASSIT_RESPONSE_TIMEOUT, handler(self, self.dealwithAssitEvent))

    end

    function TestCtrl:removeSelf()
        -- unregist
        self._assitModel:unRegistCtrl(self)

        TestCtrl.super.removeSelf(self)
    end

    function TestCtrl:dealwithResponse(dataMap)
        local response, data = unpack(dataMap.value)
        print('dealwith data')
    end

    -- send data
    function TestCtrl:onSomething()
        -- do request
        local testData = {
            nUserID = 1,
            dwAveDelay = 0
        }
        -- send request
        self._assitModel:sendRequest(TestReq.MessageMap.GR_TEST_REQ, TestReq.GAME_TEST, testData)

        -- send data
        local data = string.pack("<i",1)
        self._assitModel:sendData(TestReq.MessageMap.GR_TEST_REQ, data)

        -- send request with echo true
        -- timeout nil default TIMEOUT in AssitModel define.
        self._assitModel:sendRequest(TestReq.MessageMap.GR_TEST_REQ, TestReq.GAME_TEST, testData, true, timeout)
    end

    function TestCtrl:dealwithAssitEvent(data)
        print('dealwith event')
    end

    -- option
    function TestCtrl:isResponseID(id)
        return true or false
    end

    return TestCtrl
]]

local AssistModel = class('AssistModel', require('src.app.GameHall.models.BaseModel'))

local Queue = import('src.app.Utility.tools.Queue')

local AssistBaseRequest = import('src.app.GameHall.models.assist.AssistBaseRequest')
local AssistModelConfig = import('src.app.HallConfig.AssistModelConfig')
local treepack = cc.load('treepack')

my.addInstance(AssistModel)

-- event
AssistModel.ASSIST_CONNECT_OK = 'ASSIST_CONNECT_OK'
AssistModel.ASSIST_CONNECT_ERROR = 'ASSIST_CONNECT_ERROR'
AssistModel.ASSIST_GETSERVERFAILED = 'ASSIST_GETSERVERFAILED'
AssistModel.ASSIST_DISCONNECT = 'ASSIST_DISCONNECT'
AssistModel.ASSIST_RESPONSE_TIMEOUT = 'ASSIST_RESPONSE_TIMEOUT'


-- local rawInstance = AssistModel.getInstance
local rawRemoveInstance = AssistModel.removeInstance

-- AssistModel Defualt Config
local RETRY_TIMES = AssistModelConfig.RETRY_TIMES or 3
local KEEPALIVE = AssistModelConfig.KEEPALIVE
local PULSETIME = AssistModelConfig.PULSETIME or 30
local TIMEOUT = AssistModelConfig.TIMEOUT or 15 -- default
local WAITTIME = AssistModelConfig.WAITTIME or 5 -- second

AssistModel.ASSISTSERVER_TYPE = AssistModelConfig.ASSISTSERVER_TYPE or 0

-- if echowait = true
local WAITING_NOTHING = 0
-- 登录信息中增加userid，用于assistSvr给具体玩家分发消息 begin
local NtfLogon={
		lengthMap = {
			-- [1] = nGameID( int )	: maxsize = 4,
			-- [2] = nUserID( int )	: maxsize = 4,
			-- [3] = nStatus( int )	: maxsize = 4,
													-- nReserve	: maxsize = 128	=	4 * 32 * 1,
			[4] = { maxlen = 32 },
			maxlen = 4
		},
		nameMap = {
			'nGameID',		-- [1] ( int )
			'nUserID',		-- [2] ( int )
			'nStatus',		-- [3] ( int )
			'nReserve',		-- [4] ( int )
		},
		formatKey = '<i35',
		deformatKey = '<i35',
		maxsize = 140
    }
    
local ERROR_INFO={
    lengthMap = {
        [5] = 64,
        [6] = 8,
        maxlen = 6
    },
    nameMap = {
        'nUserID',
        'nRoomID',
        'nTableNO',
        'nChairNO',
        'szMsg',
        'nReserved',
    },
    formatKey = '<iiiiAiiiiiiii',
    deformatKey = '<iiiiA64iiiiiiii',
    maxsize = 112
}
local GR_NTF_MYPLAYERLOGON = 401111
local GR_NTF_ERROR_INFO = 403530
-- end

-- for short
local function getDirector()
    return cc.Director:getInstance()
end

local function schedule(callback, time)
    return getDirector():getScheduler():scheduleScriptFunc(callback, time, false)
end

local function unschedule(timerID)
    if not timerID then
        return
    end

    getDirector():getScheduler():unscheduleScriptEntry(timerID)
end

-- @init and uninit
function AssistModel.removeInstance(...)
    local arg = { ...}
    arg[1]:_onDestory()
    rawRemoveInstance(...)
end

function AssistModel:onCreate()
    self:_init()
end

function AssistModel:_init()
    self._refCount = 0
    self._isConnected = false
    self._requestQueue = Queue:create()

    --    self._connectTimerID
    --    self._echowaitTimerID

    self._autoReconnectTimes = 0

    -- common proxy begin
    self._proxyConnect = false
    self._connectSvrStr = ""
    -- common proxy end

    if KEEPALIVE then
        self:_createKeepAliveTimer()
    end
end

function AssistModel:_onDestory()
    self:_closeNetwork()
    self:_destoryKeepAliveTimer()
    self:_destoryTimeoutTimer()
end

function AssistModel:setServerIPPort(ip, port)
    self._ip = ip
    self._port = port

    --测试代码
    --self._ip = "192.168.9.216"
    -- self._ip = "192.168.9.64"  -- gc
    --self._ip = "192.168.9.54"
    -- self._port = 60322
end

-- @connect
--function AssistModel:connectToServer(ip, port)
function AssistModel:connectToServer()
    if type(self._ip) == 'string' and type(self._port) == 'number' then
        self:_tryCreateConnect()
    else
        print('AssistModel:connectToServer invaild ip or port')
    end
end

function AssistModel:isConnected()
    return self._isConnected
end

function AssistModel:_rebuildConnect()
    if not self._ip or not self._port then
        -- do nothing
    else
        self:_tryCreateConnect()
    end
end

function AssistModel:_tryCreateConnect(retryTimes)

    if self._isConnected then
        print('AssistModel:_tryCreateConnect is already connect.')
        return
    end

    if self._connectTimerID then
        print('AssistModel:_tryCreateConnect is trying...')
        return
    end

    self._autoReconnectTimes = retryTimes or RETRY_TIMES
    self._connectTimerID = schedule( function()
        self._autoReconnectTimes = self._autoReconnectTimes - 1

        if self._autoReconnectTimes < 0 then
            print('AssistModel:_createConnect auto retry times is 0.')
            unschedule(self._connectTimerID)
            self._connectTimerID = nil
            self:dispatchEvent( { name = AssistModel.ASSIST_CONNECT_ERROR })
            self._requestQueue:reset()
        else
            self:_createConnect()
        end
    end , WAITTIME)

    --重连时先执行一遍重连的代码begin
    self._autoReconnectTimes = self._autoReconnectTimes - 1
    self:_createConnect()
    --重连时先执行一遍重连的代码end
end

function AssistModel:_createConnect()
    self:_closeNetwork()

    -- common proxy begin
    local bProxy, client, connectStr = my.commonMPConnect(self._ip, self._port, 6)
    self._proxyConnect = bProxy
    self._client = client
    self._connectSvrStr = connectStr
    -- common proxy end
    
    local function _onDataReceived(clientid, msgtype, session, request, data)
        self:_onDataReceived(clientid, msgtype, session, request, data)
    end
    self._client:setCallback(_onDataReceived)

    print('connect return = ' .. self._client:connect())
end

function AssistModel:_closeNetwork()
    self._isConnected = false
    -- common proxy begin
    self._proxyConnect = false
    self._connectSvrStr = ""
    -- common proxy end
    if self._client then
        self._client:setCallback(function()end)
        self._client:disconnect()
        self._client = nil
    end
end

-- @ondata
function AssistModel:_onDataReceived(clientid, msgtype, session, response, data)
    local switchAction = {
        [UrSocket.UR_SOCKET_CONNECT] = function()
            self:_onAssistConnectOK()
            self:_onNTFAssistLogon()
        end,

        [UrSocket.UR_SOCKET_CLOSE] = function()
            self:_closeNetwork()
            self:dispatchEvent( { name = AssistModel.ASSIST_CONNECT_ERROR, value = clientid })
            self._requestQueue:reset()
        end,

        [UrSocket.UR_SOCKET_ERROR] = function()
            self:_onSocketError()
        end,

        [UrSocket.UR_SOCKET_GRACEFULLY_ERROR] = function()
            self:_onGacefullyError()
        end,
        
        [GR_NTF_ERROR_INFO] = function(data)
            local errInfo = AssistModel:deserialize(data, ERROR_INFO)
            data = errInfo.szMsg
            local str = MCCharset:getInstance():gb2Utf8String(data, string.len(data))
            my.informPluginByName({pluginName='ToastPlugin',params={tipString=str,removeTime=2}})
        end,
    }
    
    local status, msg = my.mxpcall( function()
        if self._waitSession == session and msgtype == MsgType.MSG_RESPONSE  then
            self:stopResponseTimer()
            self:_setWaitSession()
            if type(self._echoWaitData[4]) == "function" then
                self._echoWaitData[4](response, data)
            else
                self:_cleanEchoWaitData()
            end
        end

        if switchAction[response] then
            switchAction[response](data)
        else
            self:_dispatchResponseToCtrl(response, data)
        end
    end, __G__TRACKBACK__)

    if not status then print(msg) end
end

function AssistModel:_onAssistConnectOK()
    -- common proxy begin
    self._isConnected = true
    if self._proxyConnect then
        local UR_CONNECT_SERVER = 0 + 110
        self:sendData(UR_CONNECT_SERVER, self._connectSvrStr)
    end
    -- common proxy end

    self:dispatchEvent( { name = AssistModel.ASSIST_CONNECT_OK })

    unschedule(self._connectTimerID)
    self._connectTimerID = nil

    --配置请求
    local AssistCommon = import("src.app.GameHall.models.assist.common.AssistCommon"):getInstance()
    AssistCommon:onAssistConnectOK()

    self:sendAllRequest()
end

function AssistModel:_onNTFAssistLogon()
    local struct        = NtfLogon
    local UserModel = mymodel('UserModel'):getInstance()

    local data          = {
        nUserID         = UserModel.nUserID,
        nGameID         = tonumber(my.getGameID()),
        nStatus         = nil,
        nReserve        = nil,
    }

    local Data = cc.load('treepack').alignpack(data, struct)
    self:sendData(GR_NTF_MYPLAYERLOGON, Data)
end

function AssistModel:_onSocketError()
    print('AssistModel:_onSocketError ...')

    self:_closeNetwork()
    self:dispatchEvent( { name = AssistModel.ASSIST_CONNECT_ERROR })
    self._requestQueue:reset()

    if KEEPALIVE then
        self:_rebuildConnect()
    end
end

function AssistModel:_onGacefullyError()
    print('AssistModel:_onGacefullyError ...')

    self:_closeNetwork()
    self:dispatchEvent( { name = AssistModel.ASSIST_DISCONNECT })
    self._requestQueue:reset()
end

-- @request
--[Comment] 发送请求
--@requestID 请求号
--@formatStruct 要序列化的数据
--@struct 用于格式化的结构体
--@echoWait[option] 是否等待回应
--@timeOut[option] 等待回应超时
--@callback[option] 发送消息通过callback来回调，不要registxxxxxxxxxxxxxxxxxxxx
function AssistModel:sendRequest(requestID, formatStruct, struct, echoWait, timeOut, callback)
    assert(requestID or formatStruct or struct, 'AssistModel:sendRequest params is invalid.')

    local data = treepack.alignpack(struct, formatStruct)
    return self:sendData(requestID, data, echoWait, timeOut, callback)
end

function AssistModel:sendData(requestID, data, echoWait, timeOut, callback)
    assert(requestID, 'AssistModel:sendRequest params is invalid.')

    if not self:isConnected() then
        print('AssistModel is not connectd, request will push in request queue.', tostring(requestID))
        local params = { [1] = requestID, [2] = data, [3] = echoWait, [4] = timeOut, [5] = callback }
        self._requestQueue:pushBack(params)
        self:_rebuildConnect()
        return false
    elseif echoWait and self:_isWaitingSomething() then
        print('AssistModel:sendData is waiting a response, this reuqest will be send after waiting over.', tostring(requestID))
        local params = { [1] = requestID, [2] = data, [3] = echoWait, [4] = timeOut, [5] = callback }
        self._requestQueue:pushBack(params)
        return false
    end

    local session = self._client:sendRequest(requestID, data, data and data:len() or 0, echoWait)

    if echoWait then
        self:_setWaitSession(session)
        self:_startResponseTimer(timeOut)
        self:_saveEchoWaitData(requestID, data, timeOut, callback)
    end

    return session ~= -1
end

-- @echo wait
function AssistModel:_isWaitingSomething()
    return self._waitSession ~= nil
end

function AssistModel:_setWaitSession(session)
    self._waitSession = session
end

function AssistModel:_startResponseTimer(timeOut)
    local _timeOut = timeOut or TIMEOUT
    self._echowaitTimerID = schedule( function()
        print('AssistModel request Time out...')

        self:stopResponseTimer()
        self:dispatchEvent( { name = AssistModel.ASSIST_RESPONSE_TIMEOUT, value = self._echoWaitData })
        self:_cleanEchoWaitData()
        self:_setWaitSession()

        self:sendAllRequest()
    end , _timeOut)
end

function AssistModel:stopResponseTimer()
    unschedule(self._echowaitTimerID)
    self._echowaitTimerID = nil
end

function AssistModel:_saveEchoWaitData(...)
    self._echoWaitData = { ...}
end

function AssistModel:_cleanEchoWaitData()
    self._echoWaitData = nil
--    self:_setWaitResponse()
end

-- @regist&unregist
function AssistModel:registCtrl(ctrl, func)
    local bRegist
    local tab = self:_getRegistCtrlTable()
    for ctrlIndex, _ in pairs(tab) do
        if tab[ctrl] then
            bRegist = true
            break
        end
    end

    if not bRegist then
        tab[ctrl] = func
    end
end

function AssistModel:unRegistCtrl(ctrl)
    local tab = self:_getRegistCtrlTable()
    if tab[ctrl] then
        tab[ctrl] = nil
    end
end

function AssistModel:_getRegistCtrlTable()
    if not self._tableCtrlRegist then
        self._tableCtrlRegist = { }
        setmetatable(self._tableCtrlRegist, { __mode = 'k' })
    end

    return self._tableCtrlRegist
end

function AssistModel:_dispatchResponseToCtrl(response, data)
    local tab = self:_getRegistCtrlTable()

    for ctrl, func in pairs(tab) do
        if type(ctrl.isResponseID) == "function" and ctrl:isResponseID(response) then
            if func == nil then
                print("aaaa")
            end
            func(ctrl, { name = ctrl.__cname, value = { response, data }})
        elseif not (type(ctrl.isResponseID) == "function") then
            func(ctrl, { name = ctrl.__cname, value = { response, data }})
        end
    end
end

-- @dealwith data
function AssistModel:deserialize(data, formatStruct)
    if not data or not formatStruct then
        print('AssistModel:deserialize invaild params.')
        return nil
    end

    local msgInfo = treepack.unpack(data, formatStruct)
    return msgInfo
end

function AssistModel:sendAllRequest()
    print('AssistModel:sendAllRequest connect ok send all request left in queue.')
    local requestCount = self._requestQueue:size()

    for index = 1, requestCount do
        local params = unpack(self._requestQueue:pop())
        if not params then
            break
        elseif not self:sendData(unpack(params)) then
            break
        end
    end
end

-- @keepalive
function AssistModel:_createKeepAliveTimer()
    local function keepAliveFunc()
        if not self._isConnected then
            return
        end

        local PULSEDATA = {
            nUserID     = mymodel('UserModel'):getInstance().nUserID,
            dwAveDelay  = 0,
            dwMaxDelay  = 0,
        }
        print('send assist pulse packet...')
        self:sendRequest(AssistBaseRequest.MessageMap.GR_GAME_PULSE, AssistBaseRequest.GAME_PULSE, PULSEDATA, false)
    end

    self._keepAliveTimeID = schedule(keepAliveFunc, PULSETIME)

end

function AssistModel:_destoryKeepAliveTimer()
    unschedule(self._keepAliveTimeID)
    self._keepAliveTimeID = nil
end

function AssistModel:_destoryTimeoutTimer()
    unschedule(self._connectTimerID)
    self._connectTimerID = nil
end







--自定义功能
--获取KPI上报的数据
function AssistModel:getKPIClientData()
    local clientData = my.getKPIClientData()
    local playerInfo = cc.exports.PUBLIC_INTERFACE.GetPlayerInfo()

    local gameVersion   = clientData.GameVers
    local splitArray    = string.split(gameVersion, ".")
    local majorVer          = 0
    local minorVer          = 0
    local buildno           = 0
    if #splitArray == 3 then
        majorVer        = tonumber(splitArray[1])
        minorVer        = tonumber(splitArray[2])
        buildno         = tonumber(splitArray[3])
    end

    local data  = {
        UserId  = playerInfo.nUserID,
        GameId  = clientData.GameId,
        GameCode = clientData.GameCode,
        ExeMajorVer = majorVer,
        ExeMinorVer = minorVer,
        ExeBuildno = buildno,
        RecomGameId = tonumber(clientData.RecomGameId),
        RecomGameCode = tonumber(clientData.RecomGameCode),
        GroupId = clientData.GroupId,
        Channel = clientData.Channel,
        HardId = clientData.HardId,
        MobileHardInfo = clientData.MobileHardInfo,
        PkgType = clientData.PkgType,
        CUID    = clientData.CUID
    }
    return data
end

--数据解析成table,并返回剩余的数据
function AssistModel:convertDataToStruct(data,structDesc)
    if data == nil then return nil, nil end

    if structDesc then
        return cc.load('treepack').unpack(data, structDesc), string.sub(data, structDesc.maxsize + 1)
    else
        return nil, nil
    end
end

return AssistModel