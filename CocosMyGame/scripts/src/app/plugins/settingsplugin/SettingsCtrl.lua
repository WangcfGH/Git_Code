
local viewCreater=import('src.app.plugins.settingsplugin.SettingsView')
local user=mymodel('UserModel'):getInstance()
local player=mymodel('hallext.PlayerModel'):getInstance()
local settingsModel=mymodel('hallext.SettingsModel'):getInstance()
local SettingsCtrl=class('SettingsCtrl',cc.load('BaseCtrl'))
local userPlugin = plugin.AgentManager:getInstance():getUserPlugin()

my.addInstance(SettingsCtrl)

function SettingsCtrl:onCreate(host)
	self._settingsModel=settingsModel
    self._settingsModel:reloadSaveData()
    local viewNode=self:setViewIndexer(
        viewCreater:createViewIndexer(
            (settingsModel:isShakeable() and 1) or 2,
            (settingsModel:isSavemode() and 1) or 2)
    )

    self:getEventHostList()[settingsModel]=true
    self:listenTo(player,player.PLAYER_KICKED_OFF,handler(self,self.onUserKickedOff))

    self._musicSlider=viewNode.musicSlider
    self._musicSlider:setPercent(self._settingsModel:getMusicVolume())
    self._effectSlider=viewNode.effectSlider
    self._effectSlider:setPercent(self._settingsModel:getSoundsVolume())
    self._backImage=viewNode.backImage

    self:bindUserEventHandler(viewNode,{
        'musicSlider',
        'effectSlider',
        'musicEnableBt',
        'musicDisableBt',
        'effectDisableBt',
        'effectEnableBt',
        'loginBt',
    })

    self:bindUserEventHandler({
        shakeRadio=viewNode.shakeRadio,
        savemodeRadio=viewNode.savemodeRadio
    })

    self:bindDestroyButton(viewNode.closeBt)

    --	self:setOnExitCallback(handler(self,self.onMyExit))
    self:bindProperty(player,'PlayerData',self,'PlayerData')

    self:setOnExitCallback(function()
        settingsModel:saveData()
    end)

    self._musicEn = viewNode.musicEnableBt
    self._musicDis = viewNode.musicDisableBt
    self._effectEn = viewNode.effectEnableBt
    self._effectDis = viewNode.effectDisableBt

    viewNode.forbiddenBt:addEventListenerCheckBox( handler(self,self.selectedEvent) )
    if(self._settingsModel:isForbidden())then
        viewNode.forbiddenBt:setSelected(true)

--        self._musicSlider:setBright(false)
--        self._effectSlider:setBright(false)
        self._musicSlider:setColor( cc.c3b(150,150,150) )
        self._effectSlider:setColor( cc.c3b(150,150,150) )

        self._musicSlider:setTouchEnabled(false)
        self._effectSlider:setTouchEnabled(false)

        self._musicEn:setColor( cc.c3b(150,150,150) )
        self._musicDis:setColor( cc.c3b(150,150,150) )
        self._effectEn:setColor( cc.c3b(150,150,150) )
        self._effectDis:setColor( cc.c3b(150,150,150) )
        self._musicEn:setTouchEnabled(false)
        self._musicDis:setTouchEnabled(false)
        self._effectEn:setTouchEnabled(false)
        self._effectDis:setTouchEnabled(false)

        self._settingsModel:setForbiddenVoice(true)
    else
        viewNode.forbiddenBt:setSelected(false)

--        self._musicSlider:setBright(true)
--        self._effectSlider:setBright(true)
        self._musicSlider:setColor( cc.c3b(255,255,255) )
        self._effectSlider:setColor( cc.c3b(255,255,255) )

        self._musicSlider:setTouchEnabled(true)
        self._effectSlider:setTouchEnabled(true)

        self._musicEn:setColor( cc.c3b(255,255,255) )
        self._musicDis:setColor( cc.c3b(255,255,255) )
        self._effectEn:setColor( cc.c3b(255,255,255) )
        self._effectDis:setColor( cc.c3b(255,255,255) )
        self._musicEn:setTouchEnabled(true)
        self._musicDis:setTouchEnabled(true)
        self._effectEn:setTouchEnabled(true)
        self._effectDis:setTouchEnabled(true)

        self._settingsModel:setForbiddenVoice(false)
    end
    self._musicSlider:setPercent(settingsModel._musicVolume)
    self._effectSlider:setPercent(settingsModel._soundsVolume)

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(handler(self,self.onMusicTouchBegan),cc.Handler.EVENT_TOUCH_BEGAN )
    local eventDispatcher = self._musicSlider:getRealNode():getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self._musicSlider:getRealNode())

    local listenerE = cc.EventListenerTouchOneByOne:create()
    listenerE:registerScriptHandler(handler(self,self.onEffectTouchBegan),cc.Handler.EVENT_TOUCH_BEGAN )
    local eventDispatcherE = self._effectSlider:getRealNode():getEventDispatcher()
    eventDispatcherE:addEventListenerWithSceneGraphPriority(listenerE, self._effectSlider:getRealNode())

    local left = false

    --if(not userPlugin:isFunctionSupported('realNameRegister'))then
    if viewNode.realNameBt then
        if cc.exports.isRealNameSupported() then
            left = true
            viewNode.realNameBt:setVisible(true)
            --[[viewNode.realNameBt:onTouch( function(e)
                if(e.name=='began')then
                    e.target:setScale(cc.exports.GetButtonScale(e.target))
                    my.playClickBtnSound()
                elseif(e.name=='ended')then
                    e.target:setScale(1.0)
                    printf("~~~~~~~~~~~~realNameRegister~~~~~~~~~~~~~~")
                    userPlugin:realNameRegister()
                elseif(e.name=='cancelled')then
                    e.target:setScale(1.0)
                end
            end)]]--
            viewNode.realNameBt:addClickEventListener(function()
                printf("~~~~~~~~~~~~realNameRegister~~~~~~~~~~~~~~")
                userPlugin:realNameRegister()
            end)
        else
            viewNode.realNameBt:setVisible(false)
            left = false
        end
    end

    local middle = false

    if viewNode.fangChengmiBt then
        if cc.exports.isAntiAddictionSupported() then
            middle=true
            viewNode.fangChengmiBt:setVisible(true)
            --[[viewNode.fangChengmiBt:onTouch( function(e)
                if(e.name=='began')then
                    e.target:setScale(cc.exports.GetButtonScale(e.target))
                    my.playClickBtnSound()
                elseif(e.name=='ended')then
                    e.target:setScale(1.0)
                    printf("~~~~~~~~~~~~antiAddictionQuery~~~~~~~~~~~~~~")
                    userPlugin:antiAddictionQuery()
                elseif(e.name=='cancelled')then
                    e.target:setScale(1.0)
                end
            end)]]--
            viewNode.fangChengmiBt:addClickEventListener(function()
                printf("~~~~~~~~~~~~antiAddictionQuery~~~~~~~~~~~~~~")
                userPlugin:antiAddictionQuery()
            end)
        else
            middle = false
            viewNode.fangChengmiBt:setVisible(false)
        end
    end

    local right = false

    if viewNode.moreGameBt then
        if cc.exports.isMoreGameSupported() then
            viewNode.moreGameBt:setVisible(true)
            right = true
            --[[viewNode.moreGameBt:onTouch( function(e)
                if(e.name=='began')then
                    e.target:setScale(cc.exports.GetButtonScale(e.target))
                    my.playClickBtnSound()
                elseif(e.name=='ended')then
                    e.target:setScale(1.0)
                    printf("~~~~~~~~~~~~moreGame~~~~~~~~~~~~~~")
                    userPlugin:moreGame()
                elseif(e.name=='cancelled')then
                    e.target:setScale(1.0)
                end
            end)]]--
            viewNode.moreGameBt:addClickEventListener(function()
                printf("~~~~~~~~~~~~moreGame~~~~~~~~~~~~~~")
                userPlugin:moreGame()
            end)
        else
            viewNode.moreGameBt:setVisible(false)
            right = false
        end
    end
    

    if( (middle == false)and(right == false) )then
        if viewNode.realNameBt then
            local x = viewNode.realNameBt:getPositionX()
            local y = viewNode.realNameBt:getPositionY()
            viewNode.realNameBt:setPosition(x+200,y)
        end
    elseif( (middle == false)or(right == false) )then
        if viewNode.realNameBt then
            local x = viewNode.realNameBt:getPositionX()
            local y = viewNode.realNameBt:getPositionY()
            viewNode.realNameBt:setPosition(x+100,y)
        end
    end

    if( (left == false)and(middle == false) )then
        if viewNode.moreGameBt then
            local x = viewNode.moreGameBt:getPositionX()
            local y = viewNode.moreGameBt:getPositionY()
            viewNode.moreGameBt:setPosition(x-200,y)
        end
    elseif( (left == false)or(middle == false) )then
        if viewNode.moreGameBt then
            local x = viewNode.moreGameBt:getPositionX()
            local y = viewNode.moreGameBt:getPositionY()
            viewNode.moreGameBt:setPosition(x-100,y)
        end
    end


    if( (left == false)and(right == false) )then

    elseif( (left == false)and(right == true) )then
        if viewNode.fangChengmiBt then
            local x = viewNode.fangChengmiBt:getPositionX()
            local y = viewNode.fangChengmiBt:getPositionY()
            viewNode.fangChengmiBt:setPosition(x-100,y)
        end
    elseif( (left == true)and(right == false) )then
        if viewNode.fangChengmiBt then
            local x = viewNode.fangChengmiBt:getPositionX()
            local y = viewNode.fangChengmiBt:getPositionY()
            viewNode.fangChengmiBt:setPosition(x+100,y)
        end
    end
    
    if not cc.exports.isSwitchAccountSupported() then
        if viewNode.loginBt then
            viewNode.loginBt:setVisible(false)
        end
        if viewNode.usernameBkImg then
            viewNode.usernameBkImg:setVisible(false)
        end
        if viewNode.usernameTxt then
            viewNode.usernameTxt:setVisible(false)
        end
    end

    viewNode.forbiddenCheck:addEventListenerCheckBox( handler(self,self.roomTipsSelectedEvent) )
    if(self._settingsModel:isForbiddenRoomTips())then
        if viewNode.forbiddenCheck then 
            viewNode.forbiddenCheck:setSelected(true)
        end
    end

    -- 初始化显示版本信息按钮
    if viewNode.versionBt then
        local function clickShowVersion()
            self:clickVersion()
        end
        viewNode.versionBt:addClickEventListener(clickShowVersion)
    end

    if viewNode.clearCacheBt then
        viewNode.clearCacheBt:addClickEventListener(function(e)
            self:clickClearCache()
        end)
    end

    if viewNode.showDbgBt then
        viewNode.showDbgBt:addClickEventListener(function(e)
            self:clickShowDbg()
        end)
    end

    -- if viewNode.textClearCache then
    --     viewNode.textClearCache:setTouchEnabled(true)
    --     viewNode.textClearCache:addClickEventListener(function ()
    --         self:showClearCache()
    --     end)
    -- end
end

function SettingsCtrl:clickVersion()
    -- 两个变量 self._showVersionTimer是否在点击计时中，self._showVersionCount点击计数
    if self._showVersionTimer then
        -- 在两秒内点击，则增加计数
        if self._showVersionCount then
            if self._showVersionCount > 2 then
                --增加上传日志功能  20200110
                if DbgInterface then
                    my.scheduleOnce(function()
                        DbgInterface:updateLogPaintedEggshell()
                    end, 2)
                end

                -- 计数4次，显示版本信息
                self._showVersionCount = nil
                -- 获取打包信息
                local json = cc.load("json").json
                if (false == cc.FileUtils:getInstance():isFileExist("AppConfig.json")) then return end
                local appConfig = json.decode(cc.FileUtils:getInstance():getStringFromFile("AppConfig.json"))
                if not appConfig then return end
                local packInfo = appConfig["buildtime"]
                local versionInfo = appConfig["version"]
                if not versionInfo then versionInfo = "No versionInfo." end
                if not packInfo then packInfo = "No build info." end
                my.informPluginByName({pluginName='ToastPlugin',params={tipString=(versionInfo.."  "..packInfo), removeTime=3}})
            else
                self._showVersionCount = self._showVersionCount + 1
            end
        end
    else
        self._showVersionTimer = 1
        self._showVersionCount = 1
        my.scheduleOnce(function()
            self._showVersionTimer = nil
            self._showVersionCount = nil
        end, 2)
    end
end

function SettingsCtrl:roomTipsSelectedEvent(sender,eventType)
    if eventType == ccui.CheckBoxEventType.selected then
        self._settingsModel:setForbiddenRoomTips(true)
    elseif eventType == ccui.CheckBoxEventType.unselected then
        self._settingsModel:setForbiddenRoomTips(false)
    end
end


function SettingsCtrl:selectedEvent(sender,eventType)
    if eventType == ccui.CheckBoxEventType.selected then

        --        self._musicSlider:setBright(false)
        --        self._effectSlider:setBright(false)
        self._musicSlider:setColor( cc.c3b(150,150,150) )
        self._effectSlider:setColor( cc.c3b(150,150,150) )

        self._musicSlider:setTouchEnabled(false)
        self._effectSlider:setTouchEnabled(false)

        self._musicEn:setColor( cc.c3b(150,150,150) )
        self._musicDis:setColor( cc.c3b(150,150,150) )
        self._effectEn:setColor( cc.c3b(150,150,150) )
        self._effectDis:setColor( cc.c3b(150,150,150) )
        self._musicEn:setTouchEnabled(false)
        self._musicDis:setTouchEnabled(false)
        self._effectEn:setTouchEnabled(false)
        self._effectDis:setTouchEnabled(false)

        self._settingsModel:setForbiddenVoice(true)

    elseif eventType == ccui.CheckBoxEventType.unselected then
        --        self._musicSlider:setBright(false)
        --        self._effectSlider:setBright(false)
        self._musicSlider:setColor( cc.c3b(255,255,255) )
        self._effectSlider:setColor( cc.c3b(255,255,255) )

        self._musicSlider:setTouchEnabled(true)
        self._effectSlider:setTouchEnabled(true)

        self._musicEn:setColor( cc.c3b(255,255,255) )
        self._musicDis:setColor( cc.c3b(255,255,255) )
        self._effectEn:setColor( cc.c3b(255,255,255) )
        self._effectDis:setColor( cc.c3b(255,255,255) )
        self._musicEn:setTouchEnabled(true)
        self._musicDis:setTouchEnabled(true)
        self._effectEn:setTouchEnabled(true)
        self._effectDis:setTouchEnabled(true)

        self._settingsModel:setForbiddenVoice(false)

    end
end

function SettingsCtrl:getDiffXFromContrl(pos,node)
    local nX = node:getPositionX()
    local nY = node:getPositionY()
    local nodeSize = node:getContentSize()

    local x = pos.x
    local y = pos.y
    if( ((nY-nodeSize.height/2-5) <= y) and ((nY+nodeSize.height/2+5) >= y)  )then
        if(  ((nX-nodeSize.width/2) <= x) and  ((nX+nodeSize.width/2) >= x)   )then
            local diffX = ( x - (nX-nodeSize.width/2) ) / nodeSize.width
            return diffX
        end
    end

    return 0
end


function SettingsCtrl:onMusicTouchBegan(touch, event)

    if(self._settingsModel:isForbidden())then
        return
    end

    local pos = touch:getLocationInView()
    pos = cc.Director:getInstance():sharedDirector():convertToGL(pos)

    local layerPosX = self._musicSlider:getRealNode():getParent():getPositionX()
    local layerPosY = self._musicSlider:getRealNode():getParent():getPositionY()
    local layerSize = self._musicSlider:getRealNode():getParent():getContentSize()

    pos.x = pos.x - (layerPosX-layerSize.width/2)
    pos.y = pos.y - (layerPosY-layerSize.height/2)

    local diffX = SettingsCtrl:getDiffXFromContrl(pos ,self._musicSlider:getRealNode())
    if(diffX ~= 0)then
        self._settingsModel:setMusicVolume(diffX*100)
    end

    return true
end

function SettingsCtrl:onEffectTouchBegan(touch, event)

    if(self._settingsModel:isForbidden())then
        return
    end

    local pos = touch:getLocationInView()
    pos = cc.Director:getInstance():sharedDirector():convertToGL(pos)

    local layerPosX = self._effectSlider:getRealNode():getParent():getPositionX()
    local layerPosY = self._effectSlider:getRealNode():getParent():getPositionY()
    local layerSize = self._effectSlider:getRealNode():getParent():getContentSize()

    pos.x = pos.x - (layerPosX-layerSize.width/2)
    pos.y = pos.y - (layerPosY-layerSize.height/2)

    local diffX = SettingsCtrl:getDiffXFromContrl(pos ,self._effectSlider:getRealNode())
    if(diffX ~= 0)then
        self._settingsModel:setSoundsVolume(diffX*100)
    end

    return true
end


function SettingsCtrl:setPlayerData(data)
    local viewNode=self._viewNode
    if data.szUtf8UsernameRaw == nil then
        viewNode.usernameTxt:setString('')
        return
    end
    my.fixUtf8Width(data.szUtf8UsernameRaw, viewNode.usernameTxt, 168)
    --viewNode.usernameTxt:setString(data.szUtf8Username)
end

function SettingsCtrl:onUserKickedOff()
    local viewNode=self._viewNode
    local usernameTxt=viewNode.usernameTxt
    if(usernameTxt:isVisible())then
        usernameTxt:setString('')
    end
end

function SettingsCtrl:refreshSoundVolumeSlider(volume)
    local effectSlider=self._viewNode.effectSlider
    if effectSlider:getPercent() ~= volume then
        effectSlider:setPercent(volume)
    end
end

function SettingsCtrl:refreshMusicVolumeSlider(volume)
    local musicSlider = self._viewNode.musicSlider
    if musicSlider:getPercent() ~= volume then
        musicSlider:setPercent(volume)
    end
end

function SettingsCtrl:musicSliderUpdated(e)
    self._settingsModel:setMusicVolume(e.target:getPercent())
end

function SettingsCtrl:effectSliderUpdated(e)
    self._settingsModel:setSoundsVolume(e.target:getPercent())
end

function SettingsCtrl:musicEnableBtClicked(e)
    self._settingsModel:enableMusic()
    self:refreshMusicVolumeSlider(100)
end

function SettingsCtrl:musicDisableBtClicked( )
    self._settingsModel:disableMusic()
    self:refreshMusicVolumeSlider(0)
end

function SettingsCtrl:effectEnableBtClicked( ... )
    self._settingsModel:enableSounds()
    self:refreshSoundVolumeSlider(100)
end

function SettingsCtrl:effectDisableBtClicked( ... )
    self._settingsModel:disableSounds()
    self:refreshSoundVolumeSlider(0)
end

function SettingsCtrl:shakeRadioClicked(e)
    if(e.index==1)then
        print('shake open')
    elseif(e.index==2)then
        print('shake close')
    end
end

function SettingsCtrl:savemodeRadioClicked(e)
    if(e.index==1)then
        print('save mode open')
    elseif(e.index==2)then
        print('save mode close')
    end
end

function SettingsCtrl:initClickTimer()
    local function onClickTimer(dt)
        self:onClickTimer()
    end
    self.clickTimerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(onClickTimer, 0.5, false)
end

function SettingsCtrl:onClickTimer()
     if self.clickTimerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.clickTimerID)
        self.clickTimerID = nil
    end
    self._enBlockClick = false
end

function SettingsCtrl:loginBtClicked(e)
    if self._enBlockClick  then
        return
    end
    print("click!!!!")
    self._enBlockClick = true
    self:initClickTimer()
    if(userPlugin:isFunctionSupported('accountSwitch'))then
        userPlugin:userAccountSwitch(my.getGameID(), cc.exports.GetLoginExtra())
    end
end

function SettingsCtrl:onMyExit()
end

function SettingsCtrl:isShowClearCache()
    if not self._clearCacheClickNum then
        self._clearCacheClickNum = 0
        self._firstClearCacheClickTime = os.time()
    end 
    
    self._clearCacheClickNum = self._clearCacheClickNum + 1
    if (os.time() - self._firstClearCacheClickTime) >= 2 then
        self._clearCacheClickNum = 1
        self._firstClearCacheClickTime = os.time()
    end
    if self._clearCacheClickNum == 5 then
        self._clearCacheClickNum = nil 
        return true
    end
    return false
end

function SettingsCtrl:showClearCache()
    if DEBUG > 0 and self:isShowClearCache() then
        local function okCallback(  )
            local fileUtils = cc.FileUtils:getInstance()
            local writablePath = fileUtils:getGameWritablePath()
            fileUtils:removeDirectory(writablePath)
            my.scheduleOnce(function(  )
                local agent = MCAgent:getInstance()
                agent:endToLua()
            end)
        end

        my.informPluginByName( {
            pluginName = "SureDialog",
            params = {
                tipContent  = "清理缓存？（点击确定将关闭游戏）",
                tipTitle    = nil,
                okBtTitle   = nil,
                onOk        = okCallback,
                closeBtVisible = true,
                forbidKeyBack  = true
            }
        } )
    end
end
function SettingsCtrl:clickClearCache()
    if self._clickClearCacheTimer then
        if self._clickClearCacheCount then
            self._clickClearCacheCount = self._clickClearCacheCount + 1
            if self._clickClearCacheCount > 4 then

                local function okCallback(  )
                    local fileUtils = cc.FileUtils:getInstance()
                    local writablePath = fileUtils:getGameWritablePath()

                    fileUtils:removeDirectory(writablePath)
                    my.scheduleOnce(function(  )
                        local agent = MCAgent:getInstance()
                        agent:endToLua()
                    end)
                end

                my.informPluginByName( {
                    pluginName = "SureDialog",
                    params = {
                        tipContent  = "清理缓存？（点击确定将关闭游戏）",
                        tipTitle    = nil,
                        okBtTitle   = nil,
                        onOk        = okCallback,
                        closeBtVisible = true,
                        forbidKeyBack  = true
                    }
                } )

                self._clickClearCacheCount = nil
            end
        end
    else
        self._clickClearCacheTimer = 1
        self._clickClearCacheCount = 1
        my.scheduleOnce(function()
            self._clickClearCacheTimer = nil
            self._clickClearCacheCount = nil
        end, 2)
    end
end

function SettingsCtrl:clickShowDbg()
    if self._showDbgTimer then
        if self._clickTitleCount then
            self._clickTitleCount = self._clickTitleCount + 1
            if self._clickTitleCount > 4 then
                DbgInterface:run()
                self._clickTitleCount = nil
            end
        end
    else
        self._showDbgTimer = 1
        self._clickTitleCount = 1
        my.scheduleOnce(function()
            self._showDbgTimer = nil
            self._clickTitleCount = nil
        end, 2)
    end
end

return SettingsCtrl
