cc.exports.csdbg = function(...)
	local s = string.format(...)
	print(string.format( "---------------------------------%s----------------------------",s ))
end

local MyDeviceUtils={}


function MyDeviceUtils:copyToClipboard()
    print("copyToClipboard")
end
function MyDeviceUtils:getClipboardContent()
end

function MyDeviceUtils:vibrate()
end
function MyDeviceUtils:autoRotate()
end


function MyDeviceUtils:setGameNetworkInfoCallback()
end

local MyBusinessUtils={}

function MyBusinessUtils:cleanLaunchParam()
end


function MyBusinessUtils:GetAppConfigInfo()
	if( self.AppJsonObj == nil ) then

		local json = cc.load("json").json
		local s = cc.FileUtils:getInstance():getStringFromFile("AppConfig.json")
		self.AppJsonObj = json.decode(s)
	end

	return self.AppJsonObj
end

function MyBusinessUtils:getAbbr()
	local info = self:GetAppConfigInfo()
    return info and info.abbr
end
function MyBusinessUtils:getAppVersion()
	local info = self:GetAppConfigInfo()
    return info and info.version
end
function MyBusinessUtils:getAppName()
	local info = self:GetAppConfigInfo()
    return info and info.name
end
function MyBusinessUtils:getEngineVersionMin()
	local info = self:GetAppConfigInfo()
    return info and info.engineVersionMin
end
function MyBusinessUtils:getEngineVersionMax()
	local info = self:GetAppConfigInfo()
    return info and info.engineVersionMax
end
function MyBusinessUtils:getPackageName()
	local info = self:GetAppConfigInfo()
    return info and info.packageName
end
function MyBusinessUtils:getGameID()
	local info = self:GetAppConfigInfo()
    return info and info.gameID
end


function MyBusinessUtils:setPlatformListener()end

function MyBusinessUtils:removePlatformListener()end
function MyBusinessUtils:setMlinkListener()end
function MyBusinessUtils:removeMlinkListener() end
--function businessUtils:BusinessUtils:getInstance():removeMlinkListener ()destroyLoadingDialog	31
function MyBusinessUtils:encodeShareUrl()
end
function MyBusinessUtils:decodeShareUrl()
end
function MyBusinessUtils:destroyLoadingDialog()
end
function MyBusinessUtils:notifyPlatform()
end
function MyBusinessUtils:updateConfigs()
end
function MyBusinessUtils:getTimeOfDay()
end

function MyBusinessUtils:encryptAES()
end
function MyBusinessUtils:decryptAES()
end
--[[
function MyPlugin:getInstantVoicePlugin()
end
function MyPlugin:getTcyPlatformPlugin()
end]]


--[[6.4.39.	getAuthInfo	56
6.4.40.	verifyThirdInfo	57
6.4.41.	bindThirdAccount	57
6.4.42.	queryThirdAccountBindState	57
6.4.43.	queryThirdInfo	58
6.4.44.	thirdPartyLogin	59
6.4.45.	isLocalAccountExist	59
6.6.26.	setPlayerLevel	74
6.9.4.	loginFriend	81

6.9.24.	speak	93
6.9.25.	speakDone	94
6.9.26.	onVoicePlay	94
6.9.27.	setVoiceVolume	94
6.9.28.	playVoice	95
6.9.29.	stopPlayVoice	95
6.9.30.	uploadFile	95
6.9.31.	downloadFile	96
6.9.32.	getFriendInfoById	96
6.9.33.	getFriendList	97
6.9.34.	addFriend	97
6.9.35.	deleteFriend	97
6.9.36.	searchFriend	98
6.9.37.	getFriendAppliedList	99
6.9.38.	agreenApplicant	99
6.9.39.	refuseApplicant	100

8.8.	getLogPath	113]]


local BusinessUtils_getInstance=BusinessUtils.getInstance
BusinessUtils.getInstance=function(self)
	local bus=BusinessUtils_getInstance(BusinessUtils)
	for k,v in pairs(MyBusinessUtils) do
		if not bus[k] then
			bus[k] = function(temp,...)
				return MyBusinessUtils[k](MyBusinessUtils,...)
			end
		end
	end
	bus["isGameDebugMode"] = function() 
		return DEBUG > 0
	end
	return bus
end


local DeviceUtils_getInstance=DeviceUtils.getInstance
DeviceUtils.getInstance=function(self)
	local bus=DeviceUtils_getInstance(DeviceUtils)
	for k,v in pairs(MyDeviceUtils) do
		if not bus[k] then
			bus[k] = function(temp,...)
					return MyDeviceUtils[k](MyDeviceUtils,...)
				end
		end
	end
	return bus
end



local AgentManager_getInstance=plugin.AgentManager.getInstance
local _getTcyFriendPlugin     = plugin.AgentManager:getInstance().getTcyFriendPlugin


local _oldMCRuntime = function()
    local version = BusinessUtils:getInstance():getEngineVersion()
    local MaxVersion,minVersion,buildNO = string.match(version, [[(%d+).(%d+).(%d+)]])
    return ((tonumber(MaxVersion) * 1000 + tonumber(minVersion)) * 100000000 + tonumber(buildNO)) <= 1003 * 100000000 + 20170401
end

cc.exports.mixAPI = {
    canVoice = true,
	oldMCRuntime = _oldMCRuntime(),
	msgdelay = 0
}

local MyAgentManager={}
function MyAgentManager:getTcyFriendPlugin(bus)
    local tcyFriendPlugin = _getTcyFriendPlugin(bus)

    local emptyfunc = function() end

    local ft = {
        "speak","speakDone","onVoicePlay","setVoiceVolume","playVoice",
        "stopPlayVoice", "uploadFile", "downloadFile"
    }

    for _,v in pairs(ft) do
        if not tcyFriendPlugin[v] then
            tcyFriendPlugin[v] = emptyfunc
            mixAPI.canVoice = false
        end
    end
    return tcyFriendPlugin
end

plugin.AgentManager.getInstance=function(self)
	local bus=AgentManager_getInstance(plugin.AgentManager)
	bus["getTcyFriendPlugin"] = function(temp,...)
				return MyAgentManager:getTcyFriendPlugin(bus)
			end
	return bus
end

csdbg("old mc runtime:"..tostring(mixAPI.oldMCRuntime))
--PluginTcyFriend