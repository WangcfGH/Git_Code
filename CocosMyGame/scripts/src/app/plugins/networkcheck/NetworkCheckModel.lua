--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local NetworkCheckModel 		    = class('NetworkCheckModel', require('src.app.GameHall.models.BaseModel'))

local SyncSender=cc.load('asynsender').SyncSender
local user=mymodel('UserModel'):getInstance()
local player                        = mymodel('hallext.PlayerModel'):getInstance()
local PropertyBinder                = cc.load('coms').PropertyBinder
local deviceUtils                   = DeviceUtils:getInstance()

my.addInstance(NetworkCheckModel)

my.setmethods(NetworkCheckModel, PropertyBinder)

NetworkCheckModel.TIME_OUT_CODE             = -1    --超时错误码
NetworkCheckModel.CONNECT_NO_PROT_ERRON     = -2    --没有端口错误
NetworkCheckModel.TIME_OUT_TIME             = 3     --超时时间
NetworkCheckModel.CHECK_COUNT               = 5     --连接尝试次数
NetworkCheckModel.DELAY_ERROR_VALUE         = 500   --延迟错误临界值
NetworkCheckModel.PACKETLOSS_ERROR_VALUE    = 5     --丢包错误临界值
NetworkCheckModel.THIRD_CHECK_HOST          = "www.baidu.com"     --第三方网址

NetworkCheckModel.NetworrkEnum  = {
    HallNet             = 'HallNet',                --大厅
    RoomNet             = 'RoomNet',                --房间
    GameNet             = 'GameNet',                --游戏
    ThirdNet            = 'ThirdNet',               --第三方
}

NetworkCheckModel.EVENT_START               = 'EVENT_START'
NetworkCheckModel.EVENT_PING_FINSIH         = 'EVENT_PING_FINSIH'
NetworkCheckModel.EVENT_CONNECT_FINSIH      = 'EVENT_CONNECT_FINSIH'
NetworkCheckModel.EVENT_OVER                = 'EVENT_OVER'
NetworkCheckModel.EVENT_IP_ERROR            = 'EVENT_IP_ERROR'

function NetworkCheckModel:onCreate()
    self._timeOutID = nil
    self._scheduler = cc.Director:getInstance():getScheduler()

    self._checkIndex = 0
    self._CheckList = {
        {enum = NetworkCheckModel.NetworrkEnum.HallNet, func = handler(self, self.checkHall)}, 
        {enum = NetworkCheckModel.NetworrkEnum.RoomNet, func = handler(self, self.checkRoom)}, 
        {enum = NetworkCheckModel.NetworrkEnum.GameNet, func = handler(self, self.checkGame)}, 
        {enum = NetworkCheckModel.NetworrkEnum.ThirdNet, func = handler(self, self.checkThird)}, 
    }

    self._CheckRelustLog = {}
    self._CheckRelust = {}
    --状态标识位
    self._isRunCheck = false
    self._isRestartCheck = false
    self._isStopCheck = false
end

function NetworkCheckModel:startCheckNetwork()
    if not deviceUtils.ping then
        return
    end
    if self._isRunCheck then
        self._isRestartCheck = true
        return
    end
    self._checkIndex = 0
    self._isRunCheck = true
    self._isRestartCheck = false
    self._isStopCheck = false
    self._CheckRelust = {}
    self._CheckRelustLog = {}
    self:nextCheckNetwork()
end

function NetworkCheckModel:stopCheckNetwork()
    if self._isRunCheck then
        self._isStopCheck = true
        self._isRestartCheck = false
    end
end

function NetworkCheckModel:nextCheckNetwork()
    self._checkIndex = self._checkIndex + 1
    if self._checkIndex <= #self._CheckList then
        self:dispatchEvent({name=NetworkCheckModel.EVENT_START, value={enum = self._CheckList[self._checkIndex].enum}})
        self._CheckList[self._checkIndex].func()
    else
        self:dispatchEvent({name=NetworkCheckModel.EVENT_OVER, value={}})
        self._isRunCheck = false
    end
end

function NetworkCheckModel:checkHall()
    local serverConfig = require('src.app.HallConfig.ServerConfig')
    if not serverConfig or not serverConfig["hall"] or not serverConfig["hall"][1] or not serverConfig["hall"][2] then
        self:dispatchEvent({name=NetworkCheckModel.EVENT_IP_ERROR, value={enum = self._CheckList[self._checkIndex].enum}})
        self:nextCheckNetwork()
        return
    end
    self:checkNetwork(serverConfig["hall"][1], serverConfig["hall"][2])
end

function NetworkCheckModel:checkRoom()
    local RoomListModel = require("src.app.GameHall.room.model.RoomListModel"):getInstance()
    local roomsInfo = RoomListModel.roomsInfo
    if not roomsInfo or not next(roomsInfo) then
        self:dispatchEvent({name=NetworkCheckModel.EVENT_IP_ERROR, value={enum = self._CheckList[self._checkIndex].enum}})
        self:nextCheckNetwork()
        return
    end

    for roomid, info in pairs(roomsInfo) do
        local host, port = info.szGameIP, info.nPort == 0 and 31629 or info.nPort + 1000
        if host and port then
            self._gameIp = host
            self._gamePort = info.nGamePort
            self:checkNetwork(host, port)
            return
        end
    end
end

function NetworkCheckModel:checkGame()
    if not self._gameIp or not self._gamePort then
        self:dispatchEvent({name=NetworkCheckModel.EVENT_IP_ERROR, value={enum = self._CheckList[self._checkIndex].enum}})
        self:nextCheckNetwork()
        return
    end
    --self:checkNetwork(self._gameIp, self._gamePort+ 20000)
    self:checkNetworkConnect(self._gameIp, self._gamePort+ 20000)
end

function NetworkCheckModel:checkThird()
    self:checkNetwork(NetworkCheckModel.THIRD_CHECK_HOST)
end

function NetworkCheckModel:checkNetwork(host, port)
    if host == nil then 
        return 
    end

    --local json = string.format( '{"host":"%s", "count":%d, "packetsize":64, "timeout":3}', host, NetworkCheckModel.CHECK_COUNT)
    local params = {host = host, count = NetworkCheckModel.CHECK_COUNT}
    deviceUtils:ping(json.encode(params), function ( ip, delay, packetloss, msg )
        if self._isRestartCheck then
            self._isRunCheck = false
            self._isRestartCheck = false
            self:startCheckNetwork()
            return
        end
        if self._isStopCheck then
            self._isRunCheck = false
            self._isStopCheck = false
            return
        end
        packetloss = packetloss * 100
        self._CheckRelust[self._CheckList[self._checkIndex].enum] = self._CheckRelust[self._CheckList[self._checkIndex].enum] or {}
        self._CheckRelust[self._CheckList[self._checkIndex].enum].pingDelay = delay
        self._CheckRelust[self._CheckList[self._checkIndex].enum].packetloss = packetloss
        table.insert(self._CheckRelustLog, self._CheckList[self._checkIndex].enum .. " ip: "..ip .." 平均延迟：" .. delay .. " 丢包率：" .. packetloss .. " 详情：" .. msg)
        self:dispatchEvent({name=NetworkCheckModel.EVENT_PING_FINSIH, value={enum = self._CheckList[self._checkIndex].enum, delay = delay, packetloss = packetloss}})
        self:checkNetworkConnect(host, port, callback, delay, packetloss )
    end)
end

function NetworkCheckModel:checkNetworkConnect(host, port)
    local function connectCallback( delay )
        self:stopClientTimer()
        if self._isRestartCheck then
            self._isRunCheck = false
            self._isRestartCheck = false
            self:startCheckNetwork()
            return
        end
        if self._isStopCheck then
            self._isRunCheck = false
            self._isStopCheck = false
            return
        end
        self._CheckRelust[self._CheckList[self._checkIndex].enum] = self._CheckRelust[self._CheckList[self._checkIndex].enum] or {}
        self._CheckRelust[self._CheckList[self._checkIndex].enum].connectDelay = delay
        table.insert(self._CheckRelustLog, self._CheckList[self._checkIndex].enum .. " 连接尝试: ".. host .." 平均延迟：" .. delay )
        if delay == NetworkCheckModel.CONNECT_NO_PROT_ERRON then  -- no connect
            self:dispatchEvent({name=NetworkCheckModel.EVENT_CONNECT_FINSIH, value={enum = self._CheckList[self._checkIndex].enum}})
        else
            self:dispatchEvent({name=NetworkCheckModel.EVENT_CONNECT_FINSIH, value={enum = self._CheckList[self._checkIndex].enum, delay = delay}})
        end
        self:nextCheckNetwork()
    end
    if not port then
        connectCallback(NetworkCheckModel.CONNECT_NO_PROT_ERRON)
        return
    end
    local client = MCAgent:getInstance():createClient(host, port)
    local delayTime = socket.gettime()
    local function networkCallback( clientid, msgtype, session, request, data, delay ) 
        if request == mc.UR_SOCKET_CONNECT then
            client:disconnect()
            client:destroy()
            delayTime = socket.gettime() - delayTime
            connectCallback(math.floor(delayTime * 1000))
        end
    end
    client:setCallback(networkCallback)
    client:connect()

    self:stopClientTimer()
    local function timeOutCallback()
        client:disconnect()
        client:destroy()
        connectCallback(NetworkCheckModel.TIME_OUT_CODE)
    end
    self._timeOutID = self._scheduler:scheduleScriptFunc(timeOutCallback, NetworkCheckModel.TIME_OUT_TIME, false)
end

function NetworkCheckModel:stopClientTimer()
    if self._timeOutID then
        self._scheduler:unscheduleScriptEntry(self._timeOutID)
        self._timeOutID = nil
    end
end

function NetworkCheckModel:getLogInfo()
    local logInfo = "设备信息：手机型号 "
    logInfo = logInfo .. deviceUtils:getPhoneModel() .. " "
    if DeviceUtils:getInstance().getSPN then
        local simOperator, simOperatorName = DeviceUtils:getInstance():getSPN()
        if simOperatorName then
            logInfo = logInfo .. "运营商 "
            logInfo = logInfo .. simOperatorName .. " "
        end
    end
    logInfo = logInfo .. "系统版本号 "
    logInfo = logInfo .. deviceUtils:getSystemVersion() .. " "
    logInfo = logInfo .. "网络类型 "
    logInfo = logInfo .. deviceUtils:getNetworkType()
    logInfo = logInfo .. "\n客户端信息：游戏ID "
    logInfo = logInfo .. my.getGameID() .. " "
    logInfo = logInfo .. "游戏版本号 "
    logInfo = logInfo .. my.getGameVersion() .. " "
    logInfo = logInfo .. "游戏渠道号 "
    logInfo = logInfo .. BusinessUtils:getInstance():getClientChannelId() .. " "
    logInfo = logInfo .. "玩家ID "
    if user.nUserID then
        logInfo = logInfo .. user.nUserID .. "\n"
    end
    
    for i, v in pairs(self._CheckRelustLog) do
        logInfo = logInfo .. v .. "\n"
    end

    return logInfo
end

return NetworkCheckModel
--endregion
