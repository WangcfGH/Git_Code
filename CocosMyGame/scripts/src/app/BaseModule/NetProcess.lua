local NetProcess = class("NetProcess")

NetProcess.NetStatus = {
    HALL_CONNECT            = 0x00000001,
    HALL_CHECK_VERSION      = 0x00000010,
    HALL_GET_SERVER         = 0x00000100,
    USERPLUGIN_LOGIN        = 0x00001000,
    HALL_LOGIN              = 0x00010000,
    HALL_GET_USERINFO       = 0x00100000,
    HALL_GET_ROOMLIST       = 0x01000000,
    HALL_GET_ASSITSERVER    = 0x10000000,

    PROCESS_PRELOGIN        = 0x00001001,
    PROCESS_LOGIN           = 0x00010000,
    PROCESS_POSTLOGIN       = 0x11100000,
    PROCESS_DXXW            = 0x01110001,
    PROCESS_SDKRELOGIN      = 0x00111000,
    PROCESS_ALLFINISHED     = 0x11111101,
    PROCESS_SOCKETRELY      = 0x11110101
}

NetProcess.SupervisionEvents = {
    READYFTO_CHECKVERSION   = 0x00000001,
    READYFTO_GETSERVER      = 0x00000001,
    READYFTO_RUN_LOGIN      = 0x00001001,
    READYFTO_RUN_POSTLOGIN  = 0x00011001,
    PROCESS_ALLFINISHED     = 0x11111101
}

NetProcess.EventEnum   = {
    SoketError          = 'SoketError',             --套接字断开
    PreLoginFinished    = 'PreLoginFinished',       --第一阶段完成
    LoginFinished       = 'LoginFinished',          --第二阶段完成
    NetProcessFinished  = 'NetProcessFinished',     --第三阶段完成
    NeedRestart         = 'NeedRestart',            --需要从更新开始重跑流程
    PreLoginFailed      = 'PreLoginFailed',         --第一阶段失败
    NetWorkError        = 'NetWorkError',           --网络异常
    FixingNetWork       = 'FixingNetWork',          --修复网络状态中
    CheckVersionFailed  = 'CheckVersionFailed',     --大厅校验版本失败
    ProcessBlocked      = 'ProcessBlocked',         --流程阻塞
    KickedOff           = 'KickedOff',              --帐号挤退
    LoginLocked         = 'LoginLocked',            --第二阶段上锁
    AssistServerGot     = 'AssistServerGot',        --成功获取AssistServer
}

function NetProcess:ctor()
    self:init()
end

function NetProcess:getInstance()
    NetProcess._instance = NetProcess._instance or NetProcess:create()
    return NetProcess._instance
end

function NetProcess:init()
    self._netStatus         = 0x00000000
    self._runningProcess    = 0x00000000
    self._currentReconnectTimes   = 0
    self._defaultSocketErrorRetry = 3
    self._supervisionEventHandler = {}
    self._userPlugin        = require('src.app.GameHall.models.PluginEventHandler.UserPlugin'):getInstance()

    local event=cc.load('event')
    event:create():bind(self)

    self:_registSocketEvents()
    self:_registUserPluginEvents()
    self:_registSupervisionEvents()
    self:_registHallKickEvents()
    self:_registNetWorkEvents()
end

function NetProcess:run()
    self:runPreLoginProcess()
end

function NetProcess:lockLoginProcess()
    self._loginProcessLocked = true
end

function NetProcess:unLockLoginProcess()
    self._loginProcessLocked = false
end

function NetProcess:runPreLoginProcess()
    self:_registNetWorkEvents()
    self:connectHall()
    self:userPluginLogin()
end

function NetProcess:connectHall()
    local client = mc.createClient()
    client:reconnect('hall')
    self:logNetDelay(NR_TimeStampType.kSent, CUSTOM_REQUESTID.SOCKET_HALL)
    self:_onRunningProcessChange(true, self.NetStatus.HALL_CONNECT)
end

function NetProcess:userPluginLogin()
    if self:_isProcessRunning(self.NetStatus.USERPLUGIN_LOGIN) then return end
    --不调用sdk登录会导致后台统计数据丢失，速度方面sdk后续再想办法优化
--    if self._userPlugin:isLoggedIn() then
--        self:_onNetStatusProgressing(self.NetStatus.USERPLUGIN_LOGIN)
--    else
        self:logNetDelay(NR_TimeStampType.kSent, CUSTOM_REQUESTID.SDK_LOGIN, true)
        self._userPlugin:login()
        self:_onRunningProcessChange(true, self.NetStatus.USERPLUGIN_LOGIN)
--    end
end

function NetProcess:runLoginProcess()
    if not self:_isProcessReadyToRun(self.NetStatus.PROCESS_LOGIN) then return end
    if self._loginProcessLocked then
        print('loginPrcoess not called, since locked by app')
        self:dispatchEvent({name = self.EventEnum.LoginLocked})
    else
        if self:_isProcessFinished(self.NetStatus.PROCESS_PRELOGIN) then
            self:dispatchEvent({name = self.EventEnum.PreLoginFinished})
            self:_login()
        end
    end
end

function NetProcess:runPostLoginProcess()
    if not self:_isProcessReadyToRun(self.NetStatus.PROCESS_POSTLOGIN) then return end
    self:dispatchEvent({name = self.EventEnum.LoginFinished})
    self:_getUserInfo()
    self:_getRoomList()
    self:_getAssistServer()
end

function NetProcess:checkNetStatus()
    if self._netStatus == self.NetStatus.PROCESS_ALLFINISHED then
        return true
    elseif self._processLock then
        print('checkNetStatus not called, since locked by smallgame')
    else
        if self._checkVersionFailed then
            print('NetProcess:checkNetStatus, checkVersionFailed')
            if DeviceUtils:getInstance():isNetworkConnected() then
                self:userPluginLogin()
            end
            self:dispatchEvent({name = self.EventEnum.CheckVersionFailed})
            return false
        elseif DeviceUtils:getInstance():isNetworkConnected() then
            self:dispatchEvent({name = self.EventEnum.FixingNetWork})
            if not my.isInGame() then
                self:switchToNormalMode() --游戏中断网状态切回大厅 此时不可是精简模式
            end
            self:_checkSupervisionEvents()
        else
            print('NetProcess:checkNetStatus, NetWorkError')
            self:dispatchEvent({name = self.EventEnum.NetWorkError})
        end
        return false
    end
end

function NetProcess:_getUserInfo()
    local statusCode = self.NetStatus.HALL_GET_USERINFO
    if not self:_isProcessReadyToRun(statusCode) then return end

    local playerModel = require('src.app.GameHall.models.hallext.PlayerModel'):getInstance()
    local function onUserInfoGot(code)
        if code == 'succeed' then
            self:_onNetStatusProgressing(statusCode)
        else            
            self:_onNetStatusBackWard(statusCode)
            self:_onProcessBlocked()
        end
    end
    self:_onRunningProcessChange(true, statusCode)
    playerModel:queryAllUserInfo(onUserInfoGot)
end

function NetProcess:_getRoomList()
    local statusCode = self.NetStatus.HALL_GET_ROOMLIST
    if not self:_isProcessReadyToRun(statusCode) then return end

    --local roomManager = require("src.app.GameHall.room.ctrl.RoomManager"):getInstance()
    local RoomListModel = require("src.app.GameHall.room.model.RoomListModel"):getInstance()
    local function onRoomlistGot(code)
        if code == 'succeed' then
            self:_onNetStatusProgressing(statusCode)
        else
            self:_onNetStatusBackWard(statusCode)
            self:_onProcessBlocked()
        end
    end
    self:_onRunningProcessChange(true, statusCode)
    --roomManager:aquireRoomInfo(onRoomlistGot)
    print("start get all roomInfo")
    RoomListModel:getAllRoomInfo(false, function(areasInfo, roomsInfo) onRoomlistGot('succeed') end)
end

function NetProcess:_getServer()
    local statusCode = self.NetStatus.HALL_GET_SERVER
    if not self:_isProcessReadyToRun(statusCode) then return end

    local function onGetServer(respondType, data, msgType, dataMap)
        if respondType == mc.UR_OPERATE_SUCCEED or respondType == mc.GET_SERVERS_OK then
            local utils = HslUtils:create(my.getAbbrName())
            utils:saveHallSvr(data,string.len(data))
        end
        self:_onNetStatusProgressing(statusCode)
    end
    self:_onRunningProcessChange(true, statusCode)
    HallRequests:GET_SERVERS(ServerType.SERVER_TYPE_HALL, onGetServer, false)
end

function NetProcess:_checkVersion()
    local statusCode = self.NetStatus.HALL_CHECK_VERSION
    if not self:_isProcessReadyToRun(statusCode) then return end

    local function onCheckVersion(respondType, data, msgType, dataMap)
        if respondType == mc.UR_OPERATE_SUCCEED 
        and (dataMap.nCheckReturn == CheckReturn.SAME
        or dataMap.nCheckReturn == CheckReturn.MINOR_EXCEED
        or dataMap.nCheckReturn == CheckReturn.MONOR_EXCEED) then
            self:_onNetStatusProgressing(statusCode)
        else
            self:_onNetStatusBackWard(statusCode)
            self:_onCheckVersionFailed()
            self:_onProcessBlocked()
        end
    end
    self:_onRunningProcessChange(true, statusCode)
    HallRequests:CHECK_VERSION(onCheckVersion)
end

function NetProcess:_login()
    local statusCode = self.NetStatus.HALL_LOGIN
    if not self:_isProcessReadyToRun(statusCode) then return end

    local function onHallLogin(respondType)
        if respondType == mc.LOGON_SUCCEED  or respondType==mc.GR_LOGON_SUCCEEDED_V2 or respondType==mc.PB_LOGON_SUCCEEDED then
            self:_onNetStatusProgressing(statusCode)
        else
            if respondType == mc.UR_PASSWORD_WRONG then
                --on password wrong, require sdk login again for new account info
                self:_onNetStatusBackWard(self.NetStatus.PROCESS_SDKRELOGIN)
            end
            self:_onNetStatusBackWard(statusCode)
            self:_onProcessBlocked()
        end
    end
    self:_onRunningProcessChange(true, statusCode)
    local playerModel = mymodel('hallext.PlayerModel'):getInstance()
    playerModel:login(onHallLogin)
end

function NetProcess:_getAssistServer()
    local statusCode = self.NetStatus.HALL_GET_ASSITSERVER
    if not self:_isProcessReadyToRun(statusCode) then return end

    local function onGetAssistServer(respondType, data, msgType, dataMap)
        if respondType == mc.UR_OPERATE_SUCCEED then
            self:_onNetStatusProgressing(statusCode)
            self:dispatchEvent({name = self.EventEnum.AssistServerGot, value = dataMap})
        else
            self:_onNetStatusBackWard(statusCode)
            self:_onProcessBlocked()
        end
    end
    self:_onRunningProcessChange(true, statusCode)
    HallRequests:MR_GET_ASSISTSVR(onGetAssistServer)
end

function NetProcess:_onConnection(respondType, data, msgType, dataMap)
    self:logNetDelay(NR_TimeStampType.kRecieved, CUSTOM_REQUESTID.SOCKET_HALL, false, respondType)
    self:_onRunningProcessChange(false, self.NetStatus.HALL_CONNECT)
    if     respondType == mc.UR_SOCKET_CONNECT then
        self._currentReconnectTimes = 0
        HallRequests:UR_SOCKET_CONFIG()
        self:_onNetStatusProgressing(self.NetStatus.HALL_CONNECT)
    elseif respondType == mc.UR_SOCKET_GRACEFULLY_ERROR
        or respondType == mc.UR_SOCKET_ERROR then
        self:_onNetStatusBackWard(self.NetStatus.PROCESS_DXXW)
        self:_onRunningProcessChange(false, self.NetStatus.PROCESS_SOCKETRELY)
        self:_onPreLoginFailed()
        --游戏中不需要重连 因为超时而触发的手动断开也不需要重连，防止陷入重连循环
        if my.isInGame() or (type(dataMap) == "table" and dataMap.bManual) then 
            self:_onProcessBlocked()
            self:dispatchEvent({name = self.EventEnum.SoketError})
            self:logNetDelay(NR_TimeStampType.kDealed, CUSTOM_REQUESTID.SOCKET_HALL, false, respondType)
            return
        end
        if self._currentReconnectTimes >= self._defaultSocketErrorRetry then
            self:_onProcessBlocked()
            self:dispatchEvent({name = self.EventEnum.SoketError})
        end
        self:_autoCheckNetWrok()
    end
    self:logNetDelay(NR_TimeStampType.kDealed, CUSTOM_REQUESTID.SOCKET_HALL, false, respondType)
end

function NetProcess:_onSdkLoginResult(code)
    self:logNetDelay(NR_TimeStampType.kRecieved, CUSTOM_REQUESTID.SDK_LOGIN, true, code)
    if code == UserActionResultCode.kLoginSuccess 
    or code == UserActionResultCode.kAccountSwitchSuccess 
    or code == UserActionResultCode.kSilentLoginSucceed then
        self:_onNetStatusBackWard(self.NetStatus.PROCESS_SDKRELOGIN)
        self:_onNetStatusProgressing(self.NetStatus.USERPLUGIN_LOGIN)
    elseif code == UserActionResultCode.kLoginCancel then
        self:_onProcessBlocked()
    else
        self:_onPreLoginFailed()
        self:_onNetStatusBackWard(self.NetStatus.PROCESS_SDKRELOGIN)
        self:_onProcessBlocked()
    end
    self:_onRunningProcessChange(false, self.NetStatus.USERPLUGIN_LOGIN)
    self:logNetDelay(NR_TimeStampType.kDealed, CUSTOM_REQUESTID.SDK_LOGIN, true, code)
end

function NetProcess:_registSocketEvents()
    local client = mc.createClient()
    client:registHandler(mc.UR_SOCKET_CONNECT,          handler(self, self._onConnection), 'hall')
    client:registHandler(mc.UR_SOCKET_ERROR,            handler(self, self._onConnection), 'hall')
    client:registHandler(mc.UR_SOCKET_GRACEFULLY_ERROR, handler(self, self._onConnection), 'hall')
end

function NetProcess:_registUserPluginEvents()
    local userPluginEvents = {
        UserActionResultCode.kLoginSuccess,
        UserActionResultCode.kAccountSwitchSuccess,
        UserActionResultCode.kLoginTimeOut,
        UserActionResultCode.kLoginFail,
        UserActionResultCode.kLogout,
        UserActionResultCode.kSilentLoginSucceed,
        UserActionResultCode.kSilentLoginFailed,
        UserActionResultCode.kLoginCancel
    }
    for _, code in pairs(userPluginEvents) do 
        self._userPlugin:registCallbackEvent(code, handler(self, self._onSdkLoginResult))
    end
end

function NetProcess:_onNetStatusProgressing(statusCode)
    printLog('NetProcess', '_onNetStatusProgressing:%08X. Current netStatus:%08X ', statusCode, self._netStatus)
    self._netStatus = bit.bor(self._netStatus, statusCode)
    self:_onRunningProcessChange(false, statusCode)
    self:_checkSupervisionEvents()
end

function NetProcess:_onNetStatusBackWard(statusCode)
    printLog('NetProcess', '_onNetStatusBackWard:%08X. Current netStatus:%08X ', statusCode, self._netStatus)
    self._netStatus = bit.band(self._netStatus, bit.bnot(statusCode))
    self:_onRunningProcessChange(false, statusCode)
end

function NetProcess:_onRunningProcessChange(isStart, statusCode)
    if isStart then
        self._runningProcess = bit.bor(self._runningProcess, statusCode)
    else
        self._runningProcess = bit.band(self._runningProcess, bit.bnot(statusCode))
    end
end

function NetProcess:_onCheckVersionFailed()
    self._checkVersionFailed = true
    self:dispatchEvent({name = self.EventEnum.CheckVersionFailed})
    self:_onPreLoginFailed()
end

function NetProcess:_onProcessBlocked()
    self:dispatchEvent({name = self.EventEnum.ProcessBlocked})
end

function NetProcess:_onPreLoginFailed()
    self:dispatchEvent({name = self.EventEnum.PreLoginFailed})
end

function NetProcess:_onNetProcessFinished() 
    self:dispatchEvent({name = self.EventEnum.NetProcessFinished})
end

function NetProcess:_isProcessRunning(statusCode)
    return bit.band(self._runningProcess, statusCode) ~= 0
end

function NetProcess:_isProcessFinished(statusCode)
    return bit.band(self._netStatus, statusCode) == statusCode
end

function NetProcess:_checkSupervisionEvents()

    if self._checkVersionFailed then return end
    if self:_isProcessReadyToRun(self.NetStatus.HALL_CONNECT) or self:_isProcessReadyToRun(self.NetStatus.USERPLUGIN_LOGIN) then 
        if self:_isProcessReadyToRun(self.NetStatus.HALL_CONNECT) then
            -- if my.isInGame() then
            --     self:switchToDelicateMode()
            --     self:connectHall()
            -- else
            self:dispatchEvent({name = self.EventEnum.NeedRestart})
            return
            -- end
        end
        if self:_isProcessReadyToRun(self.NetStatus.USERPLUGIN_LOGIN) then
            self:userPluginLogin()
        end
    end
    for statusCode, handler in pairs(self._supervisionEventHandler) do
        if bit.band(statusCode, self._netStatus) == statusCode then
            handler()
        end
    end
end

function NetProcess:_registSupervisionEvents()
    local supervisionEvents = self.SupervisionEvents
    self._supervisionEventHandler = {
        -- [supervisionEvents.READYFTO_CHECKVERSION]   = handler(self, self._checkVersion),
        [supervisionEvents.READYFTO_GETSERVER]      = handler(self, self._getServer),
        [supervisionEvents.READYFTO_RUN_LOGIN]      = handler(self, self.runLoginProcess),
        [supervisionEvents.READYFTO_RUN_POSTLOGIN]  = handler(self, self.runPostLoginProcess),
        [supervisionEvents.PROCESS_ALLFINISHED]     = handler(self, self._onNetProcessFinished),
    }

end

function NetProcess:_isProcessReadyToRun(statusCode)
    printLog('NetProcess', '_isProcessReadyToRun, statusCode:%08X, isRunning:%s, isFinished:%s', statusCode, tostring(self:_isProcessRunning(statusCode)), tostring(self:_isProcessFinished(statusCode)))
    return not (self:_isProcessRunning(statusCode) or self:_isProcessFinished(statusCode))
end

function NetProcess:_autoCheckNetWrok()
    --if netStatus == NetworkType.kNetworkTypeDisconnection then
    if (not self._processLock) and self:_isProcessReadyToRun(self.NetStatus.HALL_CONNECT) then
        if self._currentReconnectTimes < self._defaultSocketErrorRetry then
            print('_currentReconnectTimes', self._currentReconnectTimes)
            self._currentReconnectTimes = self._currentReconnectTimes + 1
            self:connectHall()
        else
            self._currentReconnectTimes = 0
        end
        return 
    end
    --end
end

function NetProcess:_registHallKickEvents()
    local client = mc.createClient()
    client:registHandler(mc.KICKEDOFF_BYADMIN,          handler(self,self._onKickedOff), 'hall')
    client:registHandler(mc.KICKEDOFF_LOGONAGAIN,       handler(self,self._onKickedOff), 'hall')
    client:registHandler(mc.GR_KICKEDOFF_FORBIDTWOHALL, handler(self,self._onKickedOff),'hall')
end

function NetProcess:_onKickedOff()
    self:_onNetStatusBackWard(self.NetStatus.PROCESS_SDKRELOGIN)
    self:_onProcessBlocked()
    self:dispatchEvent({name = self.EventEnum.KickedOff})
end

function NetProcess:_registNetWorkEvents()
    DeviceUtils:getInstance():setGameNetworkInfoCallback(handler(self, self._onNetworkChange))
end

function NetProcess:_onNetworkChange( ... )
    if not my.isInGame then return end
    local netStatus = DeviceUtils:getInstance():getNetworkType()
    printLog('NetStatusChange', 'currentNetStatus:%s', tostring(netStatus))
    if my.isInGame() then--launchParamsManager:isTCYAppReplay() then
        --print("inTcyAppReplay, do not operate")
        print("inGameNetStatus change, do not operate auto")
    elseif netStatus == NetworkType.kNetworkTypeDisconnection then
        if self._netStatus == self.NetStatus.PROCESS_ALLFINISHED then
            local client = mc.createClient()
            client:dispatchSocketError("hall")
        end
    else
        if self:isFixNetWorkRequired() then
            --由于ios引擎会在启动的时候回调该函数导致一处代码崩溃，所以先判断一下是否需要修复网络状态再进一步处理
            self:checkNetStatus()
        end
    end
end

function NetProcess:isNetStatusFinished()
    return self._netStatus == self.NetStatus.PROCESS_ALLFINISHED
end

function NetProcess:logNetDelay(timeStampType, requestId, isSdk, respondID)
    my.logForNetResearch_Hall(timeStampType, requestId, isSdk and NR_PortType.kTcySdk, 0, respondID)
end

function NetProcess:getCurrentNetStatus()
    return self._netStatus
end

--[Comment]
--[为了游戏中能快速重连，切换到精简模式，流程完成之后切换回常用模式]
function NetProcess:switchToDelicateMode()
    self._supervisionEventHandler = {
        [self.NetStatus.HALL_CONNECT]                             = handler(self, self.runLoginProcess),
        [self.NetStatus.HALL_CONNECT + self.NetStatus.HALL_LOGIN] = function()
            self:_getUserInfo()
        end,
        [self.NetStatus.HALL_CONNECT + self.NetStatus.HALL_LOGIN + self.NetStatus.HALL_GET_USERINFO] = function()
            self:_onDelegateModeFinished()
            self:switchToNormalMode()
        end
    }

end

function NetProcess:switchToNormalMode()
    self:_registSupervisionEvents()
end

function NetProcess:_onDelegateModeFinished()
    if self._inGameHallLoginCallback then
        self._inGameHallLoginCallback()
        self._inGameHallLoginCallback = nil
    end
end

function NetProcess:isFixNetWorkRequired()
    if self:isNetStatusFinished() or self:isFixingNetWork() then
        return false
    end
    return true
end

function NetProcess:isFixingNetWork()
    return self:_isProcessRunning(self.NetStatus.PROCESS_ALLFINISHED)
end

function NetProcess:checkHallLoginInGame(callback)
    assert(type(callback) == "function", "need function as input")
    self._inGameHallLoginCallback = callback
    if self:_isProcessFinished(self.NetStatus.HALL_CONNECT + self.NetStatus.HALL_LOGIN) then
        callback()
        self._inGameHallLoginCallback = nil
    else
        self:switchToDelicateMode()
        if self:_isProcessFinished(self.NetStatus.HALL_CONNECT) then
            self:runLoginProcess()
        else
            if self:_isProcessReadyToRun(self.NetStatus.HALL_CONNECT) then
                self:connectHall()
            end  
        end
    end
end

function NetProcess:lockProcess()
    self._processLock = true
end
function NetProcess:unLockProcess()
    self._processLock = false
end
return NetProcess
 