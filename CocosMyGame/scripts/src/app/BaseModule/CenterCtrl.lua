local CenterCtrl = class('CenterCtrl', require('src.app.BaseModule.ViewCtrl'))

function CenterCtrl:onCreate( app )
    self._sceneTrail = {}
    self._retainedView = {}
    self._defaultPluginName = 'MainScene'
    self._app = app
    self._pluginConfig = require('src.app.HallConfig.PluginConfig').PluginsConfig
    self._pluginBlockSeconds = require('src.app.HallConfig.PluginConfig').PluginBlock
    self:_registUserPluginEvents()
    self:_registNetProcessEvents()
    self:registSocketEvent()
end

function CenterCtrl:getInstance( ... )
    CenterCtrl._instance = CenterCtrl._instance or CenterCtrl:create( ... )
    return CenterCtrl._instance
end

function CenterCtrl:run(params)
    self._sceneTrail = {}
    self:showPluginByName(self._defaultPluginName, params)
end

function CenterCtrl:pluginInterface(params)
    local sender, pluginName, extrapParams = params.sender, params.pluginName, params.params or {}
    printLog('CenterCtrl', 'pluginInterface, sender:%s, pluginName:%s', tostring(sender), tostring(pluginName))
    dump(self._sceneTrail)
    dump(extrapParams, "pluginInterface extrapParams")
    if extrapParams.message == 'remove' then
        return self:popSceneAndShow()
    elseif pluginName == nil then
        print('please input pluginName')
        return true
    elseif pluginName == self._sceneTrail[#self._sceneTrail] then
        print(pluginName..'is already on')
        return true
    else  
        return self:showPluginByName(pluginName, extrapParams)
    end
end

function CenterCtrl:showBroadcast(newScene, targetPluginInfo)
    if not newScene then return end

    local function callback()
        local BroadcastModel = mymodel("hallext.BroadcastModel"):getInstance()
        BroadcastModel:resetHttpNotice()
    end
    newScene.ShowBroadcast = targetPluginInfo.ShowBroadcast
    if newScene.ShowBroadcast then
        newScene:runAction(cc.Sequence:create(cc.DelayTime:create(2.0), cc.CallFunc:create(callback)))
    end
end

function CenterCtrl:showPluginByName(pluginName, params)
    if not self:_isPluginReadyToShow(pluginName) then return true end

    local targetPluginInfo = self:_getPluginInfoByName(pluginName)
    if not targetPluginInfo['DisableBlock'] then self:pluginBlock(self._pluginBlockSeconds or 0.3) end

    local params = params or {}
    params.centerCtrl = self
    params.retain = targetPluginInfo['retain']
    params.pluginName = pluginName
    if targetPluginInfo['needWaiting'] then
        params.onReady = function(view)
            my.stopLoading()
            self:showOnScreen(targetPluginInfo, pluginName, view)
        end
        my.startLoading()
    else
        my.stopLoading()
    end
    local timetick = socket.gettime()
    local view, ctrlInstance = self:_getPluginViewByPath(targetPluginInfo['PluginMainViewFullPath'], params)
    printf("CenterCtrl:showPluginByName:%s, use:%s", pluginName, tostring(socket.gettime() - timetick))

    LogCtrl:logSpecialProcess("plugincall"..pluginName, socket.gettime() - timetick)

    if (not view) or (view.getParent and view:getParent()) then
        print("got no view or view have been added")
        return true 
    end

    --自定义功能
    if ctrlInstance and targetPluginInfo["LoginRely"] == true then
        if targetPluginInfo["LoginoffEvent"] == true then
            --使用自己监听的loginoff事件
        else
            if ctrlInstance.addListenerOfAutoCloseOnLogoff then
                ctrlInstance:addListenerOfAutoCloseOnLogoff()
            end
        end
    end

    if not targetPluginInfo['needWaiting'] then
        self:showOnScreen(targetPluginInfo, pluginName, view)
    end

    return view, ctrlInstance
end

function CenterCtrl:showOnScreen(targetPluginInfo, pluginName, view)
    if targetPluginInfo['retain'] then
        view:retain()
        table.insert(self._retainedView, view)
    end
    if targetPluginInfo['EnterPluginActionType']:sub(-5,-1) == 'Scene' then
        local newScene = display.newScene(pluginName, {physics = targetPluginInfo['CreateWithPhysics']})
        newScene:addChild(view)
        self:showAsScene(newScene, targetPluginInfo.EnterSceneType, targetPluginInfo.EnterSceneTime)
        self:_pushScene(pluginName)
        self:showBroadcast(newScene, targetPluginInfo)
    else
        self:showOnScene(view)
        view:setName(pluginName)
        if targetPluginInfo['ZOrder'] then
            view:setLocalZOrder(targetPluginInfo['ZOrder'])
        end
    end
end

function CenterCtrl:popSceneAndShow() 
    local sceneName = self:getSceneReadyToShow()

    local targetPluginInfo = self:_getPluginInfoByName(sceneName)
    local view, ctrlInstance = self:_getPluginViewByPath(targetPluginInfo['PluginMainViewFullPath'], params or {})
    if ctrlInstance._viewNode and (not ctrlInstance.alive) and (not targetPluginInfo.retain) then
        ctrlInstance:removeInstance()
        ctrlInstance:removeEventHosts()
        view, ctrlInstance = self:_getPluginViewByPath(targetPluginInfo['PluginMainViewFullPath'], params or {})
    end
    if view.getParent and view:getParent() then return true end

    local newScene = display.newScene(sceneName, {physics = targetPluginInfo['CreateWithPhysics']})
    newScene:addChild(view)
    self:showAsScene(newScene, targetPluginInfo.EnterSceneType, targetPluginInfo.EnterSceneTime)
    if sceneName:sub(-5,-1) == 'Scene' then
        self:showBroadcast(newScene, targetPluginInfo)
    end

    return newScene
end

function CenterCtrl:getSceneReadyToShow()
    while true do
        self:_popScene()
        local sceneName = self:getTopScene() or self._defaultPluginName
    
        if self:_isPluginReadyToShow(sceneName) then 
            return sceneName
        else
            print("sceneName:", sceneName, "not ready to show, pop next scene")
        end 
    end
end

function CenterCtrl:notifyPluginByName(pluginName, params)  
    local targetPluginInfo = self:_getPluginInfoByName(pluginName)

    if not self:_isPluginInstanceExist(targetPluginInfo['PluginMainViewFullPath']) then
        return
    end

    local view, ctrlInstance = self:_getPluginViewByPath(targetPluginInfo['PluginMainViewFullPath'])
    if not (view.getParent and view:getParent()) then
        print('attempt to inform plugin not exist')
        if type(ctrlInstance.removeInstance) == 'function' then
            ctrlInstance:removeInstance()
        end
        return 
    end

    ctrlInstance:onGetCenterCtrlNotify(params)
end

function CenterCtrl:_isPluginReadyToShow(pluginName)
    local targetPluginInfo = self:_getPluginInfoByName(pluginName)
    if not targetPluginInfo then return false end

    if targetPluginInfo['LoginRely'] and self:checkNetStatus() == false then
        printf('plugin %s returned, since LoginRely, and unexpected NetStatus not ready', tostring(pluginName))
        if pluginName == 'PersonalInfoCtrl' then
            my.dataLink(cc.exports.DataLinkCodeDef.HALL_HEAD_RELOGIN)
        end
        return false
    elseif targetPluginInfo['HallRely'] and self:isInGame() then 
        printf('plugin %s returned, since HallRely, and self:isInGame():%s', tostring(pluginName), tostring(self:isInGame()))
        return false
    elseif not targetPluginInfo['DisableBlock'] and self:isBlocked() then 
        printf('plugin %s returned, since not DisableBlock, and self:isBlocked():%s', tostring(pluginName), tostring(self:isBlocked()))
        return false
    end

    return true
end

function CenterCtrl:showAsScene(scene, transition, time, more)
    CenterCtrl.super.showAsScene(self, scene, transition, time, more)
    self._currentScene = scene
end

function CenterCtrl:isInGame()
    --return self._sceneTrail[#self._sceneTrail] == 'Game' or  my.isPluginInTrail("ReplayGame")
    return self._sceneTrail[#self._sceneTrail] == 'QuickStartCtrl' 
        or self._sceneTrail[#self._sceneTrail] == 'JiSuQuickStartCtrl' 
        or  my.isPluginInTrail("OfflineGamePlugin")
        or  my.isPluginInTrail("xyxz")
end

function CenterCtrl:isInOfflineGame()
    return my.isPluginInTrail("NetlessScene")
end

function CenterCtrl:isInMainScene()
    return self._sceneTrail[#self._sceneTrail] == 'MainScene' 
end

function CenterCtrl:isInWebViewScene()
    local curSceneName  = self._sceneTrail[#self._sceneTrail]
    local targetPluginInfo = self:_getPluginInfoByName(curSceneName)
    if targetPluginInfo and targetPluginInfo.WebView then
        return true
    else
        return false
    end
end

function CenterCtrl:_getPluginInfoByName(pluginName)
    return self._pluginConfig and self._pluginConfig[pluginName]
end

function CenterCtrl:_getPluginViewByPath(pluginPath, params)
    local targetClass = require(pluginPath)
    local ctrlInstance = targetClass.getInstance and targetClass:getInstance(params)
    local view = targetClass.createViewNode and targetClass:createViewNode(params)
    view = view or targetClass:create()
    return view, ctrlInstance
end

function CenterCtrl:_isPluginInstanceExist(pluginPath)
    local targetClass = require(pluginPath)
    return targetClass.isInstanceExist and targetClass:isInstanceExist()
end

function CenterCtrl:pluginBlock(sec)
    self._isPluginBlocked     = true
    my.scheduleOnce(function()
        self._isPluginBlocked = false
    end, sec)
end

function CenterCtrl:isBlocked() 
    return self._isPluginBlocked
end

function CenterCtrl:checkNetStatus()
    return self._app:checkNetStatus()
end

function CenterCtrl:_pushScene(sceneName)
    table.insert(self._sceneTrail, sceneName)
end

function CenterCtrl:_popScene()
    local lastScene = self._sceneTrail[#self._sceneTrail]
    table.remove(self._sceneTrail)
end

function CenterCtrl:getTopScene()
    return self._sceneTrail[#self._sceneTrail]
end

function CenterCtrl:_registUserPluginEvents()
    local userPlugin = require('src.app.GameHall.models.PluginEventHandler.UserPlugin'):getInstance()
    local eventMap = {
        [UserActionResultCode.kExitSuccess]     = function(code)
            my.finish()
        end,
        [UserActionResultCode.kExitNothing]      =  function(code)
            --self:showPluginByName('ExitTipPlugin')
            self:showExitTipPlugin()
        end
    }
    for code, handler in pairs(eventMap) do
        userPlugin:registCallbackEvent(code, handler)
    end
end

function CenterCtrl:showExitTipPlugin()
    print("MainCtrl:_showExitTipPlugin")
    local LoginLotteryModel = import("src.app.plugins.loginlottery.LoginLotteryModel"):getInstance()
    local relief = mymodel('hallext.ReliefActivity'):getInstance()

    local isLotteryRewardAvail = LoginLotteryModel:getStatusDataExtended("isNeedReddot")
    local isNetworkAvail = self:checkNetStatus()
    print("isLotteryRewardAvail "..tostring(isLotteryRewardAvail))
    print("isNetworkAvail "..tostring(isNetworkAvail))
    print("isReliefRewardNotUsedUp "..tostring(relief:isReliefRewardNotUsedUp()))
    if isNetworkAvail == true and (isLotteryRewardAvail == true or relief:isReliefRewardNotUsedUp() == true) then
        my.informPluginByName({pluginName='ExitProtectPlugin'})
    else
        my.informPluginByName({pluginName='ExitTipPlugin'})
    end
end

function CenterCtrl:_registNetProcessEvents()
    local netProcess = require('src.app.BaseModule.NetProcess'):getInstance()
    local eventMap = {
        [netProcess.EventEnum.NetWorkError]       = handler(self, self._showNetErrorTip), 
        [netProcess.EventEnum.FixingNetWork]      = handler(self, self._showFixingNetWorkLayer),
        [netProcess.EventEnum.NetProcessFinished] = handler(self, self._onNetWorkFixFinished),
        -- [netProcess.EventEnum.SoketError]         = handler(self, self._onSocketError),
        [netProcess.EventEnum.KickedOff]          = handler(self, self._onKickedOff),
        [netProcess.EventEnum.ProcessBlocked]     = handler(self, self._onProcessBlocked)
    }
    for event, handler in pairs(eventMap) do
        netProcess:addEventListener(event, handler)
    end
end

function CenterCtrl:registSocketEvent()
    local client = mc.createClient()
    client:registHandler(mc.UR_SOCKET_ERROR,            handler(self, self._onSocketError), 'hall')
    client:registHandler(mc.UR_SOCKET_GRACEFULLY_ERROR, handler(self, self._onSocketError), 'hall')
end

function CenterCtrl:_showNetErrorTip(value)
    self._fixingNetWrok = false
    local str = cc.load('json').loader.loadFile('NetworkError')["NET_NOT_CONNECTED"]
    self:showPluginByName('TipPlugin', {
        tipString = str,
        removeTime = 1
    })
end

function CenterCtrl:_showFixingNetWorkLayer()
    self._fixingNetWrok = true
    self:showPluginByName('LoadingPlugin')
end

function CenterCtrl:_onProcessBlocked()
    if not self._fixingNetWrok then
        return 
    end
    self._fixingNetWrok = false
    self:notifyPluginByName('LoadingPlugin', {message = 'stopLoading'})
end

function CenterCtrl:_onNetWorkFixFinished()
    self:_onProcessBlocked()
end

function CenterCtrl:_onSocketError()
    if not self:isInGame() then
        self:run()
    end
end

function CenterCtrl:_onKickedOff()
    if not self:isInGame() then
        self:run()
    end
end

function CenterCtrl:getPluginViewByName( pluginName, params )
    local targetPluginInfo = self:_getPluginInfoByName(pluginName)

    local params = params or {}
    params.centerCtrl = self
    params.retain = targetPluginInfo['retain']
    local view = self:_getPluginViewByPath(targetPluginInfo['PluginMainViewFullPath'], params)
    return view
end

function CenterCtrl:informPluginsByTrail( paramsArray )
    local array = clone(paramsArray)
    local function _informPlugin()
        if #array == 0 then return end
        local view, ctrlInstance = my.informPluginByName(array[1])
        table.remove(array, 1)
        if ctrlInstance and ctrlInstance.setOnExitCallback then
            ctrlInstance:setOnExitCallback(_informPlugin)
        else
            view:onNodeEvent("exit", _informPlugin)
        end
    end
    _informPlugin()
end

function CenterCtrl:isPluginInTrail(pluginName)
    for k, v in pairs(self._sceneTrail) do
        if v == pluginName then return true end
    end
    return false
end

function CenterCtrl:runUpdate()
    self._app:runUpdate()
end

function CenterCtrl:silentCheckUpdate()
    self._app:silentCheckUpdate()
end

function CenterCtrl:insertSceneByName(sceneName)
    table.insert(self._sceneTrail, sceneName)
end

function CenterCtrl:isPluginVisible(pluginName)
    local curScene = display.getRunningScene()
    if curScene and pluginName then
        local child = curScene:getChildByName(pluginName)
        if child and child.isVisible then
            return child:isVisible()
        end
    end
    return false
end

function CenterCtrl:closeLayerPlugins()
    local curScene = display.getRunningScene()
    if curScene then
        if string.find(curScene.name_, 'MyTaskPlugin') then
            local pluginPath = self._pluginConfig['MyTaskPlugin']['PluginMainViewFullPath']
            local targetClass = require(pluginPath)
            local ctrlInstance = targetClass.getInstance and targetClass:getInstance()
            ctrlInstance:goBack()
        end

        if string.find(curScene.name_, 'PersonalInfoCtrl') then
            local pluginPath = self._pluginConfig['PersonalInfoCtrl']['PluginMainViewFullPath']
            local targetClass = require(pluginPath)
            local ctrlInstance = targetClass.getInstance and targetClass:getInstance()
            if ctrlInstance then
                ctrlInstance:onKeyBack()
            end
        end


        if string.find(curScene.name_, 'HelpCtrl') then
            local pluginPath = self._pluginConfig['HelpCtrl']['PluginMainViewFullPath']
            local targetClass = require(pluginPath)
            local ctrlInstance = targetClass.getInstance and targetClass:getInstance()
            if ctrlInstance then
                ctrlInstance:onKeyBack()
            end
        end

        for pluginName, pluginInfo in pairs(self._pluginConfig) do

            if pluginName ~= 'TipPlugin'
                and pluginName ~= 'ToastPlugin'
                and pluginName ~= 'SureDialog' then
                local child = curScene:getChildByName(pluginName)
                if child and child.isVisible and child:isVisible()
                    and pluginInfo['EnterPluginActionType'] ~= 'PushScene' then
    
                    local pluginPath = self._pluginConfig[pluginName]['PluginMainViewFullPath']
                    local targetClass = require(pluginPath)
                    local ctrlInstance = targetClass.getInstance and targetClass:getInstance()
                    if ctrlInstance then
                        ctrlInstance:removeSelfInstance()
                    end
                end
            end
        end
    end
end

my.informPluginByName   = function(params) return CenterCtrl:getInstance():pluginInterface(params)  end
my.isInGame             = function()       return CenterCtrl:getInstance():isInGame()               end
my.getPluginViewByName  = function(...)    return CenterCtrl:getInstance():getPluginViewByName(...) end
my.informPluginsByTrail = function(...)    return CenterCtrl:getInstance():informPluginsByTrail(...)end
my.isPluginInTrail      = function(...)    return CenterCtrl:getInstance():isPluginInTrail(...)     end
my.notifyPluginByName   = function(...)    return CenterCtrl:getInstance():notifyPluginByName(...)  end
my.getTopScene          = function(...)    return CenterCtrl:getInstance():getTopScene(...)         end
my.isPluginBlocked      = function(...)    return CenterCtrl:getInstance():isBlocked(...)           end
my.pluginBlock          = function(...)    return CenterCtrl:getInstance():pluginBlock(...)         end
my.insertSceneByName    = function(...)    return CenterCtrl:getInstance():insertSceneByName(...)   end
my.isPluginVisible      = function(...)    return CenterCtrl:getInstance():isPluginVisible(...)   end
my.closeLayerPlugins    = function(...)    return CenterCtrl:getInstance():closeLayerPlugins(...)   end

return CenterCtrl
