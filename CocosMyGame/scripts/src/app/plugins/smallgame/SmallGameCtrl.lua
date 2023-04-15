local SmallGameCtrl   = class('SmallGameCtrl', cc.load('BaseCtrl'))
local player=mymodel('hallext.PlayerModel'):getInstance()
local settingsModel = mymodel('hallext.SettingsModel'):getInstance()
local RoomListModel = import("src.app.GameHall.room.model.RoomListModel"):getInstance()

my.addInstance(SmallGameCtrl)

SmallGameCtrl.LOGUI   = 'SmallGameCtrl'

function SmallGameCtrl:onCreate()
    self._viewNode = self:initViewNode()
    self._interface = import('src.app.plugins.smallgame.SmallGameInterface')
end

function SmallGameCtrl:initViewNode()
    local viewNode = import('src.app.plugins.smallgame.SmallGameView').new()
    self._webView = viewNode:getWebView()
    local webView  = self._webView
    webView:setOnShouldStartLoading(function(wv,url)
        print('url setOnShouldStartLoading', url)
    	my.stopLoading()
        return true
    end)
    webView:setOnDidFinishLoading(function(wv, url)
        print('url setOnDidFinishLoading', url)
        self._finishedLoading = true
        return true
	end)
	webView:setOnDidFailLoading(function(wv, url)
        print('url setOnDidFailLoading', url)
        return true
	end)
    webView:setOnJSCallback(handler(self, self.jsCallback))

    local url = (self._params and self._params.url )or self:getDefaultUrl()
    webView:loadURL(url)

    return viewNode
end

function SmallGameCtrl:decodeUrl(url)
    local body = string.match(url, 'lua://(.+)')
    if not (body and string.len(body) > 0) then
        return
    end

    local funcName, paramListStr = string.match(body, '([^?]+)%??(.*)')
    local paramStrList = string.split(paramListStr, '&')
    local params = {}
    if type(paramStrList) == 'table' and #paramStrList > 0 then
        for _, paramStr in ipairs(paramStrList) do
            if string.len(paramStr) > 0 then
                local key, value = string.match(paramStr, '(.+)%=(.+)')
                key = key or string.match(paramStr, '(.+)%=')
                value = value or ''
                value = key == 'through_data' and value or string.urldecode(value)
                params[key] = value
            end
        end
    end

    return funcName, params
end

function SmallGameCtrl:encodeUrl(head, params)
    local url = head..'?'
    for key, value in pairs(params) do
        local _value = key == 'token' and value or string.urlencode(value)
        if (string.sub(url, '-1')) == '?' then
            url = url..key..'='.._value
        else
            url = url..'&'..key..'='.._value
        end
    end
    return url
end

function SmallGameCtrl:jsCallback(webView, url)
    print('jsCallbackUrl', url)
    local funcName, param = self:decodeUrl(url)
    print(funcName)
    if param then
        dump(param)
    end

    if funcName == 'exit' then
        -- self:removeSelfInstance()
        self._needAutoRelogin = param.bNeedAutoRelogin == 'true'
        local PluginProcessModel = mymodel('hallext.PluginProcessModel'):getInstance()
        PluginProcessModel:closeRewardTipCtrl()
        self:runExitAction()
        audio.playMusic(cc.FileUtils:getInstance():fullPathForFilename('res/Game/GameSound/BGMusic/BG.mp3'),true)
    elseif funcName == 'refresh' then
        if DeviceUtils:getInstance():isNetworkConnected() then
            self._webView:reload()
        end
    elseif funcName == 'openBrowser' then
        local url = param['url']
        if url then
            DeviceUtils:getInstance():openBrowser(url)
        end
    elseif funcName == 'copyToClipboard' then
        local copystr = param['copystr']
        if copystr then
            DeviceUtils:getInstance():copyToClipboard(copystr)
        end
    elseif funcName == 'pay' then
        self._interface:quickCharge({
            Product_Type = 1,   --只认银子
            Product_Price = tonumber(param.nPrice)
        }, function(code, msg)
            self:callbackToJs({code = code, msg = msg, tag = 'pay'})
        end)
    elseif funcName == 'shopItemList' then
        self:callbackToJs({itemList = self._interface:getShopItems(), firstItems = self._interface:getCacheFirstItems(), tag = 'shopItemList'})
    elseif funcName == 'customPay' then        
        if device.platform == 'windows' or cc.exports.isHSoxRaySupported() then
            print("To Create ActivityRechargeHSoxCtrl")
            dump(param, "SmallGameCtrl:payForProduct param")
            my.informPluginByName({pluginName='ActivityRechargeHSoxCtrl',params = param})
        else
            local iapPlugin = plugin.AgentManager:getInstance():getIAPPlugin()
            iapPlugin:setCallback(function (code, msg)
                self:callbackToJs({code = code, msg = msg, tag = 'customPay'})
            end)
            iapPlugin:payForProduct(param)
        end
    elseif funcName == 'setting' then
        self._settingData = param
    elseif funcName == 'entered' then
        audio.stopMusic(DEBUG == 0)
        self:stopLoadingScheduler()
        self:initListener()
        self._interface:getNetProcess():lockProcess()
    elseif funcName == 'triker' then
        if (param.handler) then
            loadstring(param.handler)
        end
    end
end

function SmallGameCtrl:callbackToJs(params)
    local jsonParam = json.encode(params)
    print("callback", jsonParam)
    if self._webView then
        self._webView:evaluateJS('lua.callback' .. '(\'' .. jsonParam .. '\')')
    end
end

function SmallGameCtrl:getDefaultUrl()
    local roomList = RoomListModel.roomsInfo
    if not roomList or next(roomList) == nil then return end
    local nRoomID
    for i,v in pairs( roomList )do
        if v.nRoomID then
            nRoomID = v.nRoomID
            break
        end
    end
    if not nRoomID then return end
    local head = self:getHostUrl()
    local params = {
        appversion  = DeviceUtils:getInstance():getAppVersion('com.uc108.mobile.gamecenter'),
        imei        = DeviceUtils:getInstance():getIMEI(),
        token       = plugin.AgentManager:getInstance():getUserPlugin():getAccessToken(),
        userid      = plugin.AgentManager:getInstance():getUserPlugin():getUserID(),
        username    = plugin.AgentManager:getInstance():getUserPlugin():getUserName(),
        sourcecode  = BusinessUtils:getInstance():getAbbr(),
        sourceid    = BusinessUtils:getInstance():getGameID(),
        sourcever   = BusinessUtils:getInstance():getAppVersion(),
        usegamedeposit = isDepositSupported(),
        childid     = 0,
        childcode   = '',
        sound       = settingsModel:getSoundsVolume(),
        music       = settingsModel:getMusicVolume(),

        roomid      = nRoomID,--table.keys(import("src.app.GameHall.room.ctrl.RoomManager"):getInstance()._roomList)[1],
        nickname    = plugin.AgentManager:getInstance():getUserPlugin():getNickName(),--NickNameInterface.getNickName(),
        hardid      = mymodel('DeviceModel'):getInstance().szHardID,
        machineid   = mymodel('DeviceModel'):getInstance().szMachineID,
        uniqueid    = mymodel('UserModel'):getInstance().szUniqueID,
        wifiid      = mymodel('DeviceModel'):getInstance().szWifiID,
        imeiid      = mymodel('DeviceModel'):getInstance().szImeiID,
        volumeid    = mymodel('DeviceModel'):getInstance().szVolumeID,
        imsi        = mymodel('DeviceModel'):getInstance().szIMSI,
        simid       = mymodel('DeviceModel'):getInstance().szSimID,
        tcychannel  = BusinessUtils:getInstance():getTcyChannel(),
    }
    return self:encodeUrl(head, params)
end

function SmallGameCtrl:getHostUrl()
    if (DEBUG > 0) then
        return 'http://192.168.9.137:8000/jjdw/test/index.html'
    else
        -- return 'http://192.168.5.147:8000/jjdw/preview/index.html'  -- 预发
        return 'https://h5game.youxi8848.com/H5/jjdw/index.html'
    end
end

function SmallGameCtrl:onKeyBack()
    self:playEffectOnPress()
    if self._webView and self._finishedLoading then
        print('lua.onKeyback()')
        self._webView:evaluateJS('lua.onKeyback()')
    else
        self:stopLoadingScheduler()
        self:removeSelfInstance()
    end
end

function SmallGameCtrl:onEnter()
    SmallGameCtrl.super.onEnter(self)
    self._interface:stopBGM()
    self:startLoadingScheduler()
    my.startLoading()
end

function SmallGameCtrl:onExit()
    SmallGameCtrl.super.onExit(self)
    self._interface:startBGM()
    self._webView = nil
    self:syncSettingData()
    my.stopLoading()
    self._interface:getNetProcess():unLockProcess()
    self._interface:getNetProcess():removeEventListenersByTag(self.__cname)
    if self._needAutoRelogin then
        if self._params.centerCtrl:checkNetStatus() then
            local player = mymodel('hallext.PlayerModel'):getInstance()
            player:update({'UserGameInfo', 'SafeboxInfo'})
        end
    end
    player.removeEventListenersByTag(self.__cname)

	--require("src.app.plugins.roomspanel.RoomsCtrl"):playTipAni()
end

function SmallGameCtrl:runExitAction()
    self:stopLoadingScheduler()
    if self._viewNode and not tolua.isnull(self._viewNode:getRealNode()) then
        local moveTo =  cc.MoveTo:create(0.3, cc.p(display.width, 0))
        local callback = cc.CallFunc:create(function ()
            self:removeSelfInstance()
        end)
        local ani = cc.Sequence:create(moveTo, callback, nil)
        self._viewNode:runAction(ani)
    end
end

function SmallGameCtrl:syncSettingData()
    if not self._settingData then return end

    if self._settingData.sound then
        settingsModel:setSoundsVolume(tonumber(self._settingData.sound))
    end

    if self._settingData.music then
        settingsModel:setMusicVolume(tonumber(self._settingData.music))
    end
    settingsModel:saveData()
end

function SmallGameCtrl:startLoadingScheduler()
    self._loadingTimer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
        self:stopLoadingScheduler()
        self:runExitAction()
    end, 10, false)
end

function SmallGameCtrl:stopLoadingScheduler()
    if self._loadingTimer then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._loadingTimer)
        self._loadingTimer = nil
    end
end

function SmallGameCtrl:initListener()
    local netProcess = self._interface:getNetProcess()
    netProcess:addEventListener(netProcess.EventEnum.KickedOff, function ()
        if self._loadingTimer then
            self:runExitAction()
        else 
            self._webView:evaluateJS('lua.onKickedOff()')
        end
    end, self.__cname)

end


return SmallGameCtrl