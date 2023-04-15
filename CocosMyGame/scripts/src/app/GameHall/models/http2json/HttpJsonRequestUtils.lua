
cc.exports.myhttp = {}

local user=mymodel('UserModel'):getInstance()
local device=mymodel('DeviceModel'):getInstance()
local activitysConfig=require('src.app.HallConfig.ActivitysConfig')

local dataCollector=cc.load('datacollector'):getInstance()

dataCollector:addIndex(activitysConfig)

local acs=activitysConfig

local protocol='httpjson'

local continuousVars={
	time=os.time()
}

local function updateContinuousVars()
	continuousVars.time=os.time()
end

local function getTime()
	return continuousVars.time*1000
end

local function countKeyString(acs)
	local actID=acs.ActId
	local t=getTime()
	local nUserID=acs.UserId or 0
	local keyString=string.format('%d|%d|%.0f',actID,nUserID ,t)
	local md5String = my.md5(keyString)
	return md5String
end

local function getDeviceId()
	local szWifiID,szImeiID,szSystemID=device.szWifiID,device.szImeiID,device.szSystemID
	local deviceId=string.format('%s,%s,%s',szWifiID,szImeiID,szSystemID)
	return deviceId
end

local function getActivitysBaseUrl()
	local baseUrl
	if(BusinessUtils:getInstance():isGameDebugMode())then
		baseUrl='http://huodong.uc108.org:922/'
	else
		baseUrl='https://huodong.tcy365.com/'
	end
	return baseUrl
end

local function getExchangeBaseUrl()
    local baseUrl = ''
	if BusinessUtils:getInstance():isGameDebugMode() then
        baseUrl = 'http://exchangemall.uc108.org:1505/'
    else
        baseUrl = 'https://exchangemall.tcy365.com/'
    end
    return baseUrl
end

local function getGameResBaseUrl()
    local baseUrl = 'https://gameressvc.uc108.net/'
	if BusinessUtils:getInstance():isGameDebugMode() then
        baseUrl = 'http://gameres.uc108.org:1505/'
    end
    return baseUrl
end

local function getAgentSysBaseUrl()
    local baseUrl = 'http://user.uc158.com/'
	if BusinessUtils:getInstance():isGameDebugMode() then
        baseUrl = 'http://user.uc158.org:1505/'
    end
    return baseUrl
end

-- local function getConfigUpdateBaseUrl()
--     local baseUrl = ''
--     if BusinessUtils:getInstance():isGameDebugMode() then
--         baseUrl = 'http://rmsyssvc.uc108.org:1505/'
--     else
--         baseUrl = 'https://rmsyssvc.uc108.net/'
--     end
--     return baseUrl
-- end

local function getConfigUpdateBaseUrl()
    local baseUrl = ''
    if BusinessUtils:getInstance():isGameDebugMode() then
        baseUrl = 'http://rusysappconfigapi.tcy365.org:1505/'
    else
        baseUrl = 'https://rusysappconfigapi.tcy365.com/'
    end
    return baseUrl
end

local function getNewActivityBaseUrl()
    local baseUrl = '' 
    if BusinessUtils:getInstance():isGameDebugMode() then
        baseUrl = 'http://activitynoticesysapi.ct108.org:1505'
    else
        baseUrl = 'http://activitynoticesysapi.ct108.net'
    end
    return baseUrl       
end
local config={}

local function getConfigByName(name)
	updateContinuousVars()
	return config[name]
end

local function registConfig(name,config)
	config[name]=config
end

local function registConfigList(configList)
    for name,configx in pairs(configList) do
        config[name]=configx
    end
end

local common={
    getTime=getTime,
    countKeyString=countKeyString,
    getDeviceId=getDeviceId,
    getActivitysBaseUrl=getActivitysBaseUrl,
    getExchangeBaseUrl=getExchangeBaseUrl,
    getNewActivityBaseUrl=getNewActivityBaseUrl,
    getGameResBaseUrl = getGameResBaseUrl,
    getAgentSysBaseUrl=getAgentSysBaseUrl,
    getConfigUpdateBaseUrl = getConfigUpdateBaseUrl,
    getTime=getTime,
    getConfigByName=getConfigByName,
    registConfig=registConfig,
    registConfigList=registConfigList,
}

table.merge(myhttp,common)

return {
	getConfigByName=getConfigByName
}
