
local gamemodel=mymodel('GameModel'):getInstance()
local SettingsModel=class('SettingsModel',import('src.app.GameHall.models.BaseModel'))

my.addInstance(SettingsModel)
                           
local SETTINGDATA_FILENAME = "SettingsData.xml" 

local function getSettingsData()
    local SettingsData

    local filename = SETTINGDATA_FILENAME
    if(my.isCacheExist(filename))then
        SettingsData=my.readCache(filename)
        SettingsData=checktable(SettingsData)
        if not (SettingsData.soundsVolume and SettingsData.musicVolume) then
            SettingsData=require('src.app.HallConfig.DefaultSettingsData')
            my.saveCache(filename,SettingsData)
        end
    else
        SettingsData=require('src.app.HallConfig.DefaultSettingsData')
        my.saveCache(filename,SettingsData)
    end
    return SettingsData
end 

local SettingsData = getSettingsData()
audio.setSoundsVolume(SettingsData.soundsVolume / 100)
audio.setMusicVolume(SettingsData.musicVolume / 100)

function SettingsModel:ctor(parameters)
    SettingsModel.super.ctor(self)

    self._isForbiddenRoomTips   = SettingsData.isCharteredRoomTipsForbbiden
    self._isForbidden           = SettingsData.isSoundForbbiden
    self._is3DEnable            = SettingsData.is3DEnable
    self._musicVolume           = SettingsData.musicVolume    
    self._soundsVolume          = SettingsData.soundsVolume
    self._isVibrateClose        = SettingsData.isVibrateClose
    self._isSwitch2DGameDialog  = SettingsData.isSwitch2DGameDialog

    self._isShakeable = SettingsData.isShakeable
	self._isSavemode = SettingsData.isSavemode
end

 function SettingsModel:getSettingsDataFilename()
	return SETTINGDATA_FILENAME
end

function SettingsModel:InitVoiceEnvironment()
    local SettingsData
	local filename=self:getSettingsDataFilename()
	if(my.isCacheExist(filename))then
		SettingsData=my.readCache(filename)
		SettingsData=checktable(SettingsData)
	else
		SettingsData=require('src.app.HallConfig.DefaultSettingsData')
	end

	local userPlugin = require('src.app.GameHall.models.PluginEventHandler.UserPlugin'):getInstance()
    if userPlugin:isFunctionSupported("isMusicEnabled") then 
	    if(false == userPlugin:isMusicEnabled())then
			printf("~~~~~~~~~~~~not MusicEnabled~~~~~~~~~~")
			SettingsData.isSoundForbbiden = true
	    else
			printf("~~~~~~~~~~~~MusicEnabled~~~~~~~~~~")
	    end
    end
	my.saveCache(filename,SettingsData)

	if(SettingsData.isSoundForbbiden == true)then
		audio.setSoundsVolume(0)
		audio.setMusicVolume(0)
	else
		audio.setSoundsVolume(SettingsData.soundsVolume/100)
		audio.setMusicVolume(SettingsData.musicVolume/100)
	end
end

function SettingsModel:saveData()
    local SettingsData=checktable(getSettingsData())
    SettingsData.musicVolume=self._musicVolume
    SettingsData.soundsVolume=self._soundsVolume
    SettingsData.isSoundForbbiden=self._isForbidden
    SettingsData.isCharteredRoomTipsForbbiden=self._isForbiddenRoomTips
    SettingsData.isVibrateClose=self._isVibrateClose
    SettingsData.is3DEnable=self._is3DEnable
    SettingsData.isSwitch2DGameDialog=self._isSwitch2DGameDialog

    SettingsData.isShakeable = self._isShakeable
	SettingsData.isSavemode = self._isSavemode
    my.saveCache('SettingsData.xml',SettingsData)

end

--[Comment]
--有间歇地保存音效数据，防止因为频繁io访问带来的卡顿
function SettingsModel:saveDataWithPause(pause)
    if self._savingData then
        self._waitingForSaveData = true
    else
        self:saveData()
        self._savingData = true
        my.scheduleOnce(function()
            self._savingData = false
            if self._waitingForSaveData then
                self._waitingForSaveData = false
                self:saveData()
            end
        end, pause or 0.3)
    end
end

function SettingsModel:reloadSaveData()
    SettingsData=getSettingsData()
    self._isForbiddenRoomTips = SettingsData.isCharteredRoomTipsForbbiden
    self._isForbidden         = SettingsData.isSoundForbbiden
    self._musicVolume         = SettingsData.musicVolume
    self._soundsVolume        = SettingsData.soundsVolume    
    self._isVibrateClose      = SettingsData.isVibrateClose

    self._is3DEnable = SettingsData.is3DEnable
    self._isSwitch2DGameDialog=SettingsData.isSwitch2DGameDialog
    self._isShakeable = SettingsData.isShakeable
	self._isSavemode = SettingsData.isSavemode

    self:setSoundsVolume(self._soundsVolume)
    self:setMusicVolume(self._musicVolume)
end

function SettingsModel:setSoundsVolume(volume)
    if not self._isForbidden then
        audio.setSoundsVolume(volume/100) 
    end  
     
    self._soundsVolume=volume
    self:saveDataWithPause()
end

function SettingsModel:getSoundsVolume()
    --return audio.getSoundsVolume()*100
    return self._soundsVolume 
end

function SettingsModel:setMusicVolume(volume)
    if not self._isForbidden then
        audio.setMusicVolume(volume/100)
    end
    self._musicVolume=volume
end

function SettingsModel:getMusicVolume()
    --return audio.getMusicVolume()*100
    return self._musicVolume 
end

function SettingsModel:setForbiddenVoice(forbidden)
    self._isForbidden = forbidden

    if(forbidden)then
        audio.setSoundsVolume(0)
        audio.setMusicVolume(0)
    else
        self:setSoundsVolume(self._soundsVolume)
        self:setMusicVolume(self._musicVolume)
    end
    self:saveDataWithPause()
end

function SettingsModel:isForbidden()
    return self._isForbidden
end

function SettingsModel:isForbiddenRoomTips()
    return self._isForbiddenRoomTips
end

function SettingsModel:setForbiddenRoomTips(forbbiden)
    self._isForbiddenRoomTips = forbbiden
end

function SettingsModel:is3DEnable()
    return self._is3DEnable
end

function SettingsModel:set3DEnable(bEnable)
    if bEnable and self._is3DEnable ~= bEnable then
        self._isSwitch2DGameDialog = true
    end
    self._is3DEnable = bEnable
    self:saveDataWithPause()
end

function SettingsModel:setVibrateClose(bVibrateClose)
    self._isVibrateClose = bVibrateClose
    self:saveDataWithPause()
end

function SettingsModel:isVibrateClose()
    if self._isVibrateClose then
        return true
    else
        return false
    end
end

function SettingsModel:isSavemode()
	return self._isSavemode
end

function SettingsModel:isShakeable()
	return self._isShakeable
end

function SettingsModel:enableMusic()
    self:setMusicVolume(100)
end

function SettingsModel:disableMusic( )
	self:setMusicVolume(0)
end

function SettingsModel:enableSounds( ... )
	self:setSoundsVolume(100)
end

function SettingsModel:disableSounds( ... )
	self:setSoundsVolume(0)
end

return SettingsModel
