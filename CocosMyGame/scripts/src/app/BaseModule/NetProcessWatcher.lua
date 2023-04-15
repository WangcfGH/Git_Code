--[[
    NetProcessWatcher文件的存在是为了降低代码的耦合性。
    NetProcess负责分发事件，不会主动调用业务（比如请求签到），需要签到文件自行监听事件。
    这样保证了NetProcess的独立性，不要在NetProcess调用业务，但是每个文件需要自行调用监听其实是让具体的业务和NetProcess耦合在了一起。
    这里提供一个中间文件可供修改，业务方直接在NetProcessWatcher修改对应的函数，不再必须自行监听。
    当然如果业务方愿意自行监听NetProcess的事件，也是合理并且可以接受的
]]

--[Comment]
--套接字断开
local function onSocketError(...)
    local playerModel = mymodel('hallext.PlayerModel'):getInstance()
    playerModel:stopPulse()
end

--[Comment]
--第一阶段完成
--包括sdk登录，大厅连接套接字，获取服务器节点，校验大厅版本
local function onPreLoginFinished(...)
    local additionCtrl = import('src.app.GameHall.config.AdditionConfigCtrl'):getInstance()
    additionCtrl:reqLatestConfig()

    if isSocialSupported() then
        local tcyFriendPlugin = import('src.app.GameHall.models.PluginEventHandler.TcyFriendPlugin'):getInstance()
        if tcyFriendPlugin then
            tcyFriendPlugin:init()
        end
    end

    mymodel('hallext.DataRecord.DataRecordModel'):getInstance()
    mymodel('hallext.LbsModel'):getInstance()
end

--[Comment]
--第二阶段完成
--登录大厅
local function onLoginFinished(...)
    if cc.exports.isShopSupported() then
        local shopModel = import('src.app.GameHall.models.ShopModel'):getInstance()
        shopModel:loadShopVersionConfig()
        shopModel:queryShopConfigUpdate()
    end

    local feedback = import('src.app.GameHall.models.hallext.FeedbackModel'):getInstance()
    feedback:queryState()

    if cc.exports.isCheckinSupported() then
        local checkin = import('src.app.GameHall.models.hallext.CheckinActivity'):getInstance()
        checkin:queryConfig()
    end
end

--[Comment]
--第三阶段完成
--获取用户信息，获取房间列表，获取assistserverIPPort
local function onNetProcessFinished(...)
    --玩家断线状态检测完毕回调
    local function checkPlayertatusFinishedCallback()
        local AssistModel = require('src.app.GameHall.models.assist.AssistModel'):getInstance()
        AssistModel:connectToServer()
    end
    local playerModel = mymodel('hallext.PlayerModel'):getInstance()
    playerModel:checkPlayerGameStatus(function()
        PluginTrailMonitor:popPluginInTrail()
    end, checkPlayertatusFinishedCallback)

    local HallContext = import('src.app.plugins.mainpanel.HallContext'):getInstance()
    HallContext:dispatchEvent({name = HallContext.EVENT_MAP["netProcessWatcher_netProcessFinished"]})

    -- if cc.exports.isReliefSupported() then
    --     local relief = mymodel('hallext.ReliefActivity'):getInstance()
    --     relief:queryConfig()
    -- else
    --     print("Activity 'Relief' is not supported")
    -- end

    -- 跑马灯
    local BroadcastModel = mymodel("hallext.BroadcastModel"):getInstance()
    if BroadcastModel then
        BroadcastModel:queryConfig()
    end

    playerModel:startPulse()

    --PluginTrailMonitor:popPluginInTrail()

    mymodel("hallext.EmailModel"):getInstance():updateEmailList()
end

--[Comment]
--需要从更新开始重跑流程
local function onNeedRestart(...)

end

--[Comment]
--第一阶段失败
local function onPreLoginFailed(...)

end

--[Comment]
--网络异常
--没有联网
local function onNetWorkError(...)

end

--[Comment]
--修复网络状态中
--开始调用大厅重连加载页
local function onFixingNetWork(...)

end

--[Comment]
--大厅校验版本失败
local function onCheckVersionFailed(...)

end

--[Comment]
--流程阻塞
--此时大厅的正在重连的loading会停止
local function onProcessBlocked(...)

end

--[Comment]
--帐号挤退
local function onKickedOff(...)

end

--[Comment]
--第二阶段上锁
--第一阶段完成后阻止用户向大厅服务器进行登录
local function onLoginLocked(...)

end

--[Comment]
--成功获取到AssistServer的服务器节点
local function onAssistServerGot(event)
    local dataMap = event.value
    local AssistModel = require('src.app.GameHall.models.assist.AssistModel'):getInstance()

    local function parseIPPort(serverData)
        local count, assistData = serverData[1].nCount, serverData[2]
        for index = 1, count do
            if AssistModel.ASSISTSERVER_TYPE == assistData[index].nType then
                return assistData[index].szIP, assistData[index].nPort
            end
        end
    end

    AssistModel:setServerIPPort(parseIPPort(dataMap))
end

local netProcess = require('src.app.BaseModule.NetProcess'):getInstance()
netProcess:addEventListener(netProcess.EventEnum.SoketError,            onSocketError)
netProcess:addEventListener(netProcess.EventEnum.PreLoginFinished,      onPreLoginFinished)
netProcess:addEventListener(netProcess.EventEnum.LoginFinished,         onLoginFinished)
netProcess:addEventListener(netProcess.EventEnum.NetProcessFinished,    onNetProcessFinished)
netProcess:addEventListener(netProcess.EventEnum.NeedRestart,           onNeedRestart)
netProcess:addEventListener(netProcess.EventEnum.PreLoginFailed,        onPreLoginFailed)
netProcess:addEventListener(netProcess.EventEnum.NetWorkError,          onNetWorkError)
netProcess:addEventListener(netProcess.EventEnum.FixingNetWork,         onFixingNetWork)
netProcess:addEventListener(netProcess.EventEnum.CheckVersionFailed,    onCheckVersionFailed)
netProcess:addEventListener(netProcess.EventEnum.ProcessBlocked,        onProcessBlocked)
netProcess:addEventListener(netProcess.EventEnum.KickedOff,             onKickedOff)
netProcess:addEventListener(netProcess.EventEnum.LoginLocked,           onLoginLocked)
netProcess:addEventListener(netProcess.EventEnum.AssistServerGot,       onAssistServerGot)