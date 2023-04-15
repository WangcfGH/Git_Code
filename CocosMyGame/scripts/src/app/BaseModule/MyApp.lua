local MyApp = class("MyApp")
audio.preloadMusic(cc.FileUtils:getInstance():fullPathForFilename('res/Game/GameSound/BGMusic/BG.mp3'))


function MyApp:ctor()

    if CC_SHOW_FPS then
        cc.Director:getInstance():setDisplayStats(true)
    end

    if CC_DEFAULT_ANIMATIONINTERVAL then
        if CC_DEFAULT_ANIMATIONINTERVAL <= 1 / 25 and CC_DEFAULT_ANIMATIONINTERVAL > 1 / 60 then
            cc.Director:getInstance():setAnimationInterval(CC_DEFAULT_ANIMATIONINTERVAL)
        end
    end

    if CC_GLOBAL_TOUCH_ONE_BY_ONE and DeviceUtils:getInstance().setMaxTouches then
        DeviceUtils:getInstance():setMaxTouches(1)
    end

    collectgarbage('setpause', 250)
    math.randomseed(os.time())

    self:onCreate()
end

function MyApp:onCreate()
    local updateInterface = require('src.app.update.UpdateInterface')
    updateInterface:setCallback(handler(self, self.onUpdateEvents), self.__cname)
end

function MyApp:run()
    local loading = import('src.app.loading.Loading.lua'):create()
    loading:setCallback(handler(self, self.onLoadingEvents))
    loading:run()
    --DeviceUtils:getInstance():copyToClipboard("")
end

function MyApp:initRequirement()
    require('src.app.BaseModule.init')
    -- my.loadHallPlist("Hallmain_Btn")
    -- my.loadHallPlist("Hallmain_Img")
    local centerCtrl = require('src.app.BaseModule.CenterCtrl'):getInstance( self )
end

function MyApp:runUpdate()
    local updateInterface = require('src.app.update.UpdateInterface')
    updateInterface:startUpdate()
end

function MyApp:runUpdateWithScene()
    local updateInterface = require('src.app.update.UpdateInterface')
    require('src.app.BaseModule.CocosDataRevert').doBackUp()
    updateInterface:startUpdateWithScene()
end

function MyApp:onLoadingEvents(event)
    self:runUpdateWithScene()
end

--[Comment]
--update event
--update finish
--EVENT_UPDATE_NEEDLESS
--EVENT_UPDATE_OK
--EVENT_UPDATE_CANCEL
--EVENT_UPDATE_FAILED
--EVENT_UPDATE_ANIMATIONOVER
--EVENT_UPDATE_ENTERSCENE
function MyApp:onUpdateEvents(event)
    printLog('MyApp', 'onUpdateEvents:%s', tostring(event))
    self._updateEvent = event
    if event == 'EVENT_UPDATE_ANIMATIONOVER' then
        self:onUpdateAnimationFinished()
    elseif event == 'EVENT_UPDATE_ENTERSCENE' then
        self:onUpdateSwitchScene()
    else
        self:onUpdateFinished(event)
    end
end 

function MyApp:onUpdateFinished(event)
    if event == 'EVENT_UPDATE_OK' then
        self:clearCache()
    end
    self._hasInitNetProcess    = false
    self:initRequirement()
    if self._silentCheckUpdate then
        self._silentCheckUpdate = false
    else
        self:runNetProcess()
    end
end

function MyApp:onUpdateSwitchScene()
    local userPlugin = require('src.app.GameHall.models.PluginEventHandler.UserPlugin'):getInstance()
    userPlugin:setLoginWithDialog(false)
    self._hallSceneInitialized  = false
end

function MyApp:onUpdateAnimationFinished()
    self._updateAnimationFinished = true
    if self._readyForSwitchScene then
        self:onReadyToLoginInHall()
    end
end

function MyApp:runNetProcess()
    local netProcess = require('src.app.BaseModule.NetProcess'):getInstance()
    if not self._hasInitNetProcess then
        self._hasInitNetProcess = true
        self:addNetProcessListener()
        netProcess:lockLoginProcess()
    end
    netProcess:run()
end

function MyApp:onReadyToLoginInHall()
    local netProcess = require('src.app.BaseModule.NetProcess'):getInstance()
    netProcess:unLockLoginProcess()
    netProcess:runLoginProcess()
    self:initializeHallScene()
end

function MyApp:addNetProcessListener()
    local netProcess = require('src.app.BaseModule.NetProcess'):getInstance()
    local eventMap = {
        [netProcess.EventEnum.NeedRestart] = function()
            self:onNetProcess('NeedRestart')
        end,
        [netProcess.EventEnum.LoginLocked] = function()
            self:onNetProcess('LoginLocked')
        end,
        [netProcess.EventEnum.PreLoginFailed] = function()
            self:onNetProcess('PreLoginFailed')
        end,
        [netProcess.EventEnum.NetProcessFinished] = function()
            self:onNetProcess('NetProcessFinished')
        end,
        [netProcess.EventEnum.CheckVersionFailed] = function()
            self:onNetProcess('CheckVersionFailed')
        end,
    }
    for event, handler in pairs(eventMap) do
        netProcess:addEventListener(event, handler)
    end
end

function MyApp:onNetProcess(event)
    printLog('MyApp', 'onNetProcess:%s', tostring(event))

    if     event == 'NetProcessFinished'    then
    elseif event == 'LoginLocked'      then
        self:onPreLoginFinished()
    elseif event == 'PreLoginFailed'        then
        self:onPreLoginFinished()
    elseif event == 'NeedRestart'           then
        if self._checkVersionFailed then 
            print('hallVersion old, restart blocked')
            return
        end
        if my.isInGame() then
            local netProcess = require('src.app.BaseModule.NetProcess'):getInstance()
            self:runNetProcess()
            netProcess:unLockLoginProcess()
        else
            self:runUpdate()
            self._readyForSwitchScene   = false
        end
    elseif event == 'CheckVersionFailed'    then
        self._checkVersionFailed = true
    else
    end
end

function MyApp:onPreLoginFinished()
    print(self._updateAnimationFinished, self._readyForSwitchScene)
    self._readyForSwitchScene = true
    if self._updateAnimationFinished then
        self:onReadyToLoginInHall()
    end
end

function MyApp:initializeHallScene()
    if self._hallSceneInitialized then 
        return 
    else
        self._hallSceneInitialized = true
    end
    audio.playMusic(cc.FileUtils:getInstance():fullPathForFilename('res/Game/GameSound/BGMusic/BG.mp3'),true)
    local centerCtrl = require('src.app.BaseModule.CenterCtrl'):getInstance( self )
    centerCtrl:run({checkVersionFailed = self._checkVersionFailed})
end

function MyApp:checkNetStatus() 
    local netProcess = require('src.app.BaseModule.NetProcess'):getInstance()
    return netProcess:checkNetStatus()
end

function MyApp:clearCache()
    cc.SpriteFrameCache:getInstance():removeSpriteFrames()
    cc.Director:getInstance():getTextureCache():removeAllTextures()
    cc.FileUtils:getInstance():purgeCachedEntries()
    require('src.app.BaseModule.CocosDataRevert').doRecover()
    require('src.app.BaseModule.CocosDataRevert').doBackUp()
end

function MyApp:getUpdateEvent()
    return self._updateEvent
end

--[[function MyApp:directToHall()
    self._hallSceneInitialized = false
    self._hasInitNetProcess    = false
    self._updateAnimationFinished = true
    self:initRequirement()
    local netProcess = require('src.app.BaseModule.NetProcess'):getInstance()
    self:runNetProcess()
    netProcess:unLockLoginProcess()
    self:initializeHallScene()
    BusinessUtils:getInstance():destroyLoadingDialog()
end

function MyApp:directToReplay()
    self._updateAnimationFinished = true
    self:initRequirement()
    local content = launchParamsManager:getContent()
    import('src.app.BaseModule.CacheManager'):saveCache(content.replayurl, content.replaylocalpath,  FileType.kFile, -1)
    import('src.app.BaseModule.CacheManager'):cleanDueCache()
    local centerCtrl = require('src.app.BaseModule.CenterCtrl'):getInstance( self )
    my.informPluginByName({sender = self, pluginName = 'ReplayGame', params = {enterGameType = EnterGameType.kReplay, filePath = content.replaylocalpath}})
    BusinessUtils:getInstance():destroyLoadingDialog()
end]]--

function MyApp:silentCheckUpdate()
    self._silentCheckUpdate = true
    self:runUpdate()
end

return MyApp
