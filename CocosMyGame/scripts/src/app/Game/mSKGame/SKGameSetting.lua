
local SKGameSetting = class("SKGameSetting")

local SpringFestivalModel = import('src.app.BaseModule.SpringFestivalModel'):getInstance()

local SKGameDef                                 = import("src.app.Game.mSKGame.SKGameDef")

local SK_LANGAUGE_SETTING = {
    SK_LANGAUGE_MANDARIN    = 0,
    SK_LANGAUGE_DIALECT     = 1,
}

local SpringFestivalBGIndex = 5

function SKGameSetting:ctor(settingPanel, gameController)
    if not gameController then printError("gameController is nil!!!") return end
    self._gameController        = gameController

    self._settingPanel          = settingPanel

    self._musicSlider           = nil
    self._effectSlider          = nil

    self._btnMusicDisable       = nil
    self._btnEffectDisable      = nil

    self._btnMusicEnable        = nil
    self._btnEffectEnable       = nil

    self._btnSelectMandarinClk  = nil
    self._btnSelectDialectClk   = nil

    self._initMusicVolume       = 0
    self._initEffectVolume      = 0

    self._selectedLangauge      = 0

    self._btnSoundForbbiden     = nil
    self._bSoundForbbiden       = false

    self._settingData           = nil

    
    self._initGameBgImageIndex  = 1

    self:init()
end

function SKGameSetting:init()
    if not self._settingPanel then return end

    self._settingPanel:setLocalZOrder(SKGameDef.SK_ZORDER_SETTING)

    local settingImage = self._settingPanel:getChildByName("Panel_Main"):getChildByName("Panel_Animation")
    if not settingImage then return end

    self:setVisible(false)

    self._settingData = self:getSetting()

    if self._settingData.nLangauge and SK_LANGAUGE_SETTING.SK_LANGAUGE_DIALECT == self._settingData.nLangauge then
        self._selectedLangauge = SK_LANGAUGE_SETTING.SK_LANGAUGE_DIALECT
    else
        self._selectedLangauge = SK_LANGAUGE_SETTING.SK_LANGAUGE_MANDARIN
    end

    if self._settingData.musicVolume then
        self._initMusicVolume = self._settingData.musicVolume / 100
    end
    if self._settingData.soundsVolume then
        self._initEffectVolume = self._settingData.soundsVolume / 100
    end

    audio.setMusicVolume(self._initMusicVolume)
    audio.setSoundsVolume(self._initEffectVolume)

    --����ͼ���
    if self._settingData.gameBgImageIndex then
        self._initGameBgImageIndex = self._settingData.gameBgImageIndex
        if SpringFestivalModel:showSpringFestivalView() then
            if SpringFestivalModel:gameSceneDefaultShow() then
                SpringFestivalModel:setGameSceneDefaultShow(false)
                self._initGameBgImageIndex = SpringFestivalBGIndex
            end
        else
            if self._initGameBgImageIndex == SpringFestivalBGIndex then
                self._initGameBgImageIndex = 1
                self._settingData.gameBgImageIndex = 1
                self:saveSetting()
            end
        end
    end

    local function onClose()
        self:onClose()
    end
    local buttonClose = settingImage:getChildByName("Panel_Setting"):getChildByName("Btn_Close")
    if buttonClose then
        buttonClose:addClickEventListener(onClose)
    end

    --[[local function onSelectMandarin()
        self:onSelectMandarin()
    end
    self._btnSelectMandarinClk = settingImage:getChildByName("CheckBox_mandarin")
    if self._btnSelectMandarinClk then
        self._btnSelectMandarinClk:addClickEventListener(onSelectMandarin)

        self._btnSelectMandarinClk:setSelected(SK_LANGAUGE_SETTING.SK_LANGAUGE_MANDARIN == self._selectedLangauge)
    end--]]

    --[[local function onSelectDialect()
        self:onSelectDialect()
    end
    self._btnSelectDialectClk = settingImage:getChildByName("CheckBox_dialect")
    if self._btnSelectDialectClk then
        self._btnSelectDialectClk:addClickEventListener(onSelectDialect)

        self._btnSelectDialectClk:setSelected(SK_LANGAUGE_SETTING.SK_LANGAUGE_DIALECT == self._selectedLangauge)
    end--]]

    local function onMusicVolumeChanged()
        self:onMusicVolumeChanged()
    end
    self._musicSlider = settingImage:getChildByName("Panel_BGM"):getChildByName("Slider_BGM")
    if self._musicSlider then
        self._musicSlider:addEventListener(onMusicVolumeChanged)

        self:updateMusicSlider()
    end

    local function onEffectVolumeChanged()
        self:onEffectVolumeChanged()
    end
    self._effectSlider = settingImage:getChildByName("Panel_Sound"):getChildByName("Slider_Sound")
    if self._effectSlider then
        self._effectSlider:addEventListener(onEffectVolumeChanged)

        self:updateEffectSlider()
    end

    local function onMusicDisable()
        self:onMusicDisable()
    end
    self._btnMusicDisable = settingImage:getChildByName("Panel_BGM"):getChildByName("Btn_DisableBGM")
    if self._btnMusicDisable then
        self._btnMusicDisable:addClickEventListener(onMusicDisable)
    end

    local function onEffectDisable()
        self:onEffectDisable()
    end
    self._btnEffectDisable = settingImage:getChildByName("Panel_Sound"):getChildByName("Btn_DisableSound")
    if self._btnEffectDisable then
        self._btnEffectDisable:addClickEventListener(onEffectDisable)
    end

    local function onMusicEnable()
        self:onMusicEnable()
    end
    self._btnMusicEnable = settingImage:getChildByName("Panel_BGM"):getChildByName("Btn_EnableBGM")
    if self._btnMusicEnable then
        self._btnMusicEnable:addClickEventListener(onMusicEnable)
    end

    local function onEffectEnable()
        self:onEffectEnable()
    end
    self._btnEffectEnable = settingImage:getChildByName("Panel_Sound"):getChildByName("Btn_EnableSound")
    if self._btnEffectEnable then
        self._btnEffectEnable:addClickEventListener(onEffectEnable)
    end

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(function(touch, event)
        if self._bSoundForbbiden then
            return false
        end
        if self:musicContainsTouchLocation(touch:getLocation().x, touch:getLocation().y) then
            self:changeMusic(touch:getLocation().x, touch:getLocation().y)
        elseif self:effectContainsTouchLocation(touch:getLocation().x, touch:getLocation().y) then
            self:changeEffect(touch:getLocation().x, touch:getLocation().y)
        end
        return true
    end, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(function(touch, event)
        if self:musicContainsTouchLocation(touch:getLocation().x, touch:getLocation().y) then
            self:changeMusic(touch:getLocation().x, touch:getLocation().y)
        elseif self:effectContainsTouchLocation(touch:getLocation().x, touch:getLocation().y) then
            self:changeEffect(touch:getLocation().x, touch:getLocation().y)
        end
        return true
    end, cc.Handler.EVENT_TOUCH_MOVED)

    local panelShade = self._settingPanel:getChildByName("Panel_Main")
    if panelShade then
        local eventDispatcher = panelShade:getEventDispatcher()
        eventDispatcher:addEventListenerWithSceneGraphPriority(listener, panelShade)
    end

    local function onClickForbbidenBtn()
        self:onClickForbbidenBtn()
    end
    self._btnSoundForbbiden = settingImage:getChildByName("Panel_Mute"):getChildByName("CheckBox_Mute")
    if self._btnSoundForbbiden then
        self._btnSoundForbbiden:addClickEventListener(onClickForbbidenBtn)
        self._btnSoundForbbiden:setSelected(self._settingData.isSoundForbbiden)
    end

    self:onForbbidenSound(self._settingData.isSoundForbbiden)


    self._BgSwitch = settingImage:getChildByName("ScrollView_Switch")
    if self._BgSwitch then
        local bgSwitchChildren = self._BgSwitch:getChildren()
        local bgListWithoutMark = { --正常背景图
            "Game/MainBG/Game_MainBG.jpg",
            "Game/MainBG/Game_MainBG.jpg", 
            "Game/MainBG/Game_MainBG_Night.jpg", 
            "Game/MainBG/Game_MainBG_Plane.JPG",
            "Game/MainBG/Game_MainBG_SpringFestival.jpg",
            "Game/MainBG/Game_MainBG_Ocean.jpg",
            "Game/MainBG/Game_MainBG_Red.jpg",
        }
        local bgListWithMark = {    --带同城游水印背景图
            "Game/MainBG/Game_MainBG_Mark.jpg",
            "Game/MainBG/Game_MainBG_Mark.jpg", 
            "Game/MainBG/Game_MainBG_Night_Mark.jpg", 
            "Game/MainBG/Game_MainBG_Plane_Mark.JPG",
            "Game/MainBG/Game_MainBG_SpringFestival_Mark.jpg",
            "Game/MainBG/Game_MainBG_Ocean.jpg",
            "Game/MainBG/Game_MainBG_Red.jpg",
        }
        local bgListWithIcon = {    --带金鼎水印背景图
            "Game/MainBG/Game_MainBG_Icon.jpg",
            "Game/MainBG/Game_MainBG_Icon.jpg", 
            "Game/MainBG/Game_MainBG_Night_Icon.jpg", 
            "Game/MainBG/Game_MainBG_Plane_Icon.jpg",
            "Game/MainBG/Game_MainBG_SpringFestival_Icon.jpg",
            "Game/MainBG/Game_MainBG_Ocean.jpg",
            "Game/MainBG/Game_MainBG_Red.jpg",
        }

        local childrenCount = self._BgSwitch:getChildrenCount()
        
        self._BgSwitch:setInnerContainerSize(cc.size(213 * childrenCount + 10, 150))

        local bgList = bgListWithMark
        if cc.exports.isUseMarkWithoutSupported() then
            bgList = bgListWithoutMark
        end
        if cc.exports.isUseMarkJdSupported() then
            bgList = bgListWithIcon
        end
        
        for i = 1, self._BgSwitch:getChildrenCount() do
            bgSwitchChildren[i]:setPosition(cc.p(113 + 213 * (i - 1), 60))

            bgSwitchChildren[i]:addClickEventListener(handler(self, self.onSwitchGameBg))
            local selectedImage = bgSwitchChildren[i]:getChildByName("Img_Selected")
            if selectedImage then
                selectedImage:setVisible(false)
            end
            
            bgSwitchChildren[i]:loadTextureNormal(bgList[i])
            bgSwitchChildren[i]:loadTexturePressed(bgList[i])
            
            if self._initGameBgImageIndex == i and selectedImage then
                selectedImage:setVisible(true)
                self._gameController._baseGameScene:SwitchGameBgImage(bgSwitchChildren[i], self._initGameBgImageIndex)
                self._gameController._baseGameScene:setBoutInfoLabelColor(self._initGameBgImageIndex)
            end
        end
    end

    local imgTitle = settingImage:getChildByName("Panel_Setting"):getChildByName("Img_Title")
    if imgTitle then
        imgTitle:setTouchEnabled(true)
        imgTitle:addTouchEventListener(function(sender, eventType) 
            if eventType == TOUCH_EVENT_ENDED then
                self:clickUpdateLog()
            end
        end)
    end
end

function SKGameSetting:clickUpdateLog()
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

function SKGameSetting:onSwitchGameBg(node)
    if self._BgSwitch then
        local bgSwitchChildren = self._BgSwitch:getChildren()
        for i = 1, self._BgSwitch:getChildrenCount() do
            local selectedImage = bgSwitchChildren[i]:getChildByName("Img_Selected")
            if selectedImage then
                selectedImage:setVisible(false)
            end
            if node == bgSwitchChildren[i] then
                self._initGameBgImageIndex = i
            end
        end
    end
    node:getChildByName("Img_Selected"):setVisible(true)

    self._gameController._baseGameScene:SwitchGameBgImage(node, self._initGameBgImageIndex)
    self._gameController._baseGameScene:setBoutInfoLabelColor(self._initGameBgImageIndex)
    self:saveSetting()
end

function SKGameSetting:musicContainsTouchLocation(x, y)
    if not self._settingPanel or not self:isVisible() then
        return false
    end

    local position = self._musicSlider:getParent():convertToWorldSpace(cc.p(self._musicSlider:getPosition()))
    local s = self._musicSlider:getContentSize()
    local touchRect = cc.rect(position.x - s.width/2, position.y - s.height/2, s.width, s.height) --AnchorPoint 0.5,0.5
    local b = cc.rectContainsPoint(touchRect, cc.p(x, y))
    return b
end

function SKGameSetting:effectContainsTouchLocation(x, y)
    if not self._settingPanel or not self:isVisible() then
        return false
    end

    local position = self._effectSlider:getParent():convertToWorldSpace(cc.p(self._effectSlider:getPosition()))
    local s = self._effectSlider:getContentSize()
    local touchRect = cc.rect(position.x - s.width/2, position.y - s.height/2, s.width, s.height) --AnchorPoint 0.5,0.5
    local b = cc.rectContainsPoint(touchRect, cc.p(x, y))
    return b
end

function SKGameSetting:changeMusic(x, y)
    local position = self._musicSlider:getParent():convertToWorldSpace(cc.p(self._musicSlider:getPosition()))
    local s = self._musicSlider:getContentSize()
    local startX = position.x - s.width/2
    local percent = (x - startX) / s.width * 100
    if percent < 0 then percent = 0 end
    if percent > 100 then percent = 100 end

    self._musicSlider:setPercent(percent)

    self:onMusicVolumeChanged()
end

function SKGameSetting:changeEffect(x, y)
    local position = self._effectSlider:getParent():convertToWorldSpace(cc.p(self._effectSlider:getPosition()))
    local s = self._effectSlider:getContentSize()
    local startX = position.x - s.width/2
    local percent = (x - startX) / s.width * 100
    if percent < 0 then percent = 0 end
    if percent > 100 then percent = 100 end

    self._effectSlider:setPercent(percent)

    self:onEffectVolumeChanged()
end

function SKGameSetting:getSetting()
    return my.readCache("SettingsData.xml")
end

function SKGameSetting:saveSetting()
    self._settingData.musicVolume       = self._initMusicVolume * 100
    self._settingData.soundsVolume      = self._initEffectVolume * 100

    self._settingData.nLangauge         = self._selectedLangauge

    self._settingData.isSoundForbbiden  = self._bSoundForbbiden

    self._settingData.gameBgImageIndex  = self._initGameBgImageIndex

    my.saveCache("SettingsData.xml", self._settingData)
end

function SKGameSetting:onClickForbbidenBtn()
    self:onForbbidenSound(not self._bSoundForbbiden)
end

function SKGameSetting:onForbbidenSound(bForbbiden)
    self._bSoundForbbiden = bForbbiden

    self:setSliderAndButtons(not bForbbiden)
    self:setVolume(bForbbiden)

    self:saveSetting()
end

function SKGameSetting:setVolume(bForbbiden)
    if not bForbbiden then
        audio.setMusicVolume(self._initMusicVolume)
        audio.setSoundsVolume(self._initEffectVolume)
    else
        audio.setMusicVolume(0)
        audio.setSoundsVolume(0)
    end
end

function SKGameSetting:setSliderAndButtons(bEnable)
    if self._musicSlider then
        self._musicSlider:setTouchEnabled(bEnable)
        if bEnable then
            self._musicSlider:setColor( cc.c3b(255,255,255) )
        else
            self._musicSlider:setColor( cc.c3b(150,150,150) )
        end
    end

    if self._effectSlider then
        self._effectSlider:setTouchEnabled(bEnable)
        if bEnable then
            self._effectSlider:setColor( cc.c3b(255,255,255) )
        else
            self._effectSlider:setColor( cc.c3b(150,150,150) )
        end
    end

    if self._btnMusicDisable then
        self._btnMusicDisable:setTouchEnabled(bEnable)
        if bEnable then
            self._btnMusicDisable:setColor( cc.c3b(255,255,255) )
        else
            self._btnMusicDisable:setColor( cc.c3b(150,150,150) )
        end
    end

    if self._btnEffectDisable then
        self._btnEffectDisable:setTouchEnabled(bEnable)
        if bEnable then
            self._btnEffectDisable:setColor( cc.c3b(255,255,255) )
        else
            self._btnEffectDisable:setColor( cc.c3b(150,150,150) )
        end
    end

    if self._btnMusicEnable then
        self._btnMusicEnable:setTouchEnabled(bEnable)
        if bEnable then
            self._btnMusicEnable:setColor( cc.c3b(255,255,255) )
        else
            self._btnMusicEnable:setColor( cc.c3b(150,150,150) )
        end
    end

    if self._btnEffectEnable then
        self._btnEffectEnable:setTouchEnabled(bEnable)
        if bEnable then
            self._btnEffectEnable:setColor( cc.c3b(255,255,255) )
        else
            self._btnEffectEnable:setColor( cc.c3b(150,150,150) )
        end
    end
end

function SKGameSetting:onClose()
    self._gameController:playBtnPressedEffect()
    print("onClose")
    self:setVisible(false)
end

function SKGameSetting:setVisible(bVisible)
    if bVisible then
        if not tolua.isnull(self._settingPanel) then
            local panelContent = self._settingPanel:getChildByName("Panel_Main"):getChildByName("Panel_Animation")
            panelContent:setVisible(true)
            panelContent:setScale(0.6)
            panelContent:setOpacity(255)
            local scaleTo1 = cc.EaseSineOut:create(cc.ScaleTo:create(0.16, 1.1))
            local scaleTo2 = cc.ScaleTo:create(0.09, 1)

            local ani = cc.Sequence:create(scaleTo1, scaleTo2)
            panelContent:runAction(ani)
        end
    end
    if self._settingPanel then
        self._settingPanel:setVisible(bVisible)
    end
end

function SKGameSetting:isVisible()
    if self._settingPanel then
        return self._settingPanel:isVisible()
    end
    return false
end

function SKGameSetting:showSetting(bShow)
    self:setVisible(bShow)
end

function SKGameSetting:onSelectMandarin()
    self._selectedLangauge = SK_LANGAUGE_SETTING.SK_LANGAUGE_MANDARIN

    self._btnSelectMandarinClk:setSelected(false)
    self._btnSelectDialectClk:setSelected(false)

    self:saveSetting()
end

function SKGameSetting:onSelectDialect()
    self._selectedLangauge = SK_LANGAUGE_SETTING.SK_LANGAUGE_DIALECT

    self._btnSelectMandarinClk:setSelected(false)
    self._btnSelectDialectClk:setSelected(false)

    self:saveSetting()
end

function SKGameSetting:updateMusicSlider()
    self._musicSlider:setPercent(self._initMusicVolume * 100)
end

function SKGameSetting:updateEffectSlider()
    self._effectSlider:setPercent(self._initEffectVolume * 100)
end

function SKGameSetting:onMusicVolumeChanged()
    self._initMusicVolume = self._musicSlider:getPercent() / 100

    audio.setMusicVolume(self._initMusicVolume)

    self:saveSetting()
end

function SKGameSetting:onEffectVolumeChanged()
    self._initEffectVolume = self._effectSlider:getPercent() / 100

    audio.setSoundsVolume(self._initEffectVolume)

    self:saveSetting()
end

function SKGameSetting:onMusicDisable()
    self._gameController:playBtnPressedEffect()

    self._initMusicVolume = 0

    self:updateMusicSlider()

    audio.setMusicVolume(self._initMusicVolume)

    self:saveSetting()
end

function SKGameSetting:onEffectDisable()
    self._gameController:playBtnPressedEffect()

    self._initEffectVolume = 0

    self:updateEffectSlider()

    audio.setSoundsVolume(self._initEffectVolume)

    self:saveSetting()
end

function SKGameSetting:onMusicEnable()
    self._gameController:playBtnPressedEffect()

    self._initMusicVolume = 1

    self:updateMusicSlider()

    audio.setMusicVolume(self._initMusicVolume)

    self:saveSetting()
end

function SKGameSetting:onEffectEnable()
    self._gameController:playBtnPressedEffect()
    
    self._initEffectVolume = 1

    self:updateEffectSlider()

    audio.setSoundsVolume(self._initEffectVolume)

    self:saveSetting()
end

return SKGameSetting