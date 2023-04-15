local PromoteCodeModel          = class('PromoteCodeModel', require('src.app.GameHall.models.BaseModel'))
local PropertyBinder            = cc.load('coms').PropertyBinder
local WidgetEventBinder         = cc.load('coms').WidgetEventBinder
local user                      = mymodel('UserModel'):getInstance()
local player                    = mymodel('hallext.PlayerModel'):getInstance()
local device                    = mymodel('DeviceModel'):getInstance()

my.addInstance(PromoteCodeModel)

my.setmethods(PromoteCodeModel, PropertyBinder)
my.setmethods(PromoteCodeModel, WidgetEventBinder)

local oscodeDefault = 0
local oscodeAndroid = 1
local oscodeIOS     = 2
local oscodeWindows = 3

local UsageType = {
    TCY         = 1,    --单包
    TCYAPP      = 2,    --同城游
    PLATFORMSET = 3,    --合集包
}

-- 构造函数
function PromoteCodeModel:onCreate()
    self._promoteCode = nil

    if (DEBUG > 0) then
        self._domain = "http://promote.tcy365.org:1507"
    else
        self._domain = "https://promote.tcy365.com"
    end

    self._api = "/api/user/getuserbindpromotecode"

    -- 登录消息监听，登录成功获从缓存中取获取推广码
    self:bindProperty(player, 'PlayerLoginedData', self, 'OnLoginSuccessEvent')
end

-- 登录成功响应事件
function PromoteCodeModel:setOnLoginSuccessEvent(data)
    if data.nUserID then
        if device.platform == 'ios' or cc.exports.isCpsAppSupport() then
            local promoteCodeCache = self:getCachePromoteCode()
            if type(promoteCodeCache) == "number" then
                self._promoteCode = promoteCodeCache
            else
                self:getPromoteCodeByHttp()
            end
        end
    end
end

-- 获取推广码
function PromoteCodeModel:getPromoteCode()
    return self._promoteCode
end

-- 设置推广码
function PromoteCodeModel:setPromoteCode(date)
    self._promoteCode = date
    self:setCachePromoteCode(date)
end

-- 获取推广码缓存
function PromoteCodeModel:getCachePromoteCode()
    if user.nUserID == nil or user.nUserID < 0 then return end
    if BusinessUtils:getInstance().getGameID == nil then return end

    local userID = user.nUserID
    local gameID = BusinessUtils:getInstance():getGameID()

    local cacheDate = CacheModel:getCacheByKey("PromoteCode_"..userID.."_"..gameID)
    return cacheDate
end

-- 设置推广码缓存
function PromoteCodeModel:setCachePromoteCode(date)
    if user.nUserID == nil or user.nUserID < 0 then return end
    if BusinessUtils:getInstance().getGameID == nil then return end

    local userID = user.nUserID
    local gameID = BusinessUtils:getInstance():getGameID()

    CacheModel:saveInfoToCache("PromoteCode_"..userID.."_"..gameID, date)
end

-- 从后台获取推广码
function PromoteCodeModel:getPromoteCodeByHttp()
    local function _onCallback(xhr)
        if xhr.status == xhr.HTTP_RESPONSE_SUCCEED then
            local result = json.decode(xhr.response)
            dump(result)
            if result.Code == 0 then
                if result.Data and toint(result.Data) > 0 then
                    self:setPromoteCode(result.Data)
                else
                    print("http getuserbindinfo failed result.Data is error")
                end
            else
                print("http getuserbindinfo failed result.Code is", result.Code)
            end
        end
    end

    self:SendHttp(_onCallback)
end

-- 获取包体类型
function PromoteCodeModel:getUsageType()
    if  MCAgent:getInstance().getLaunchSubMode and MCAgent:getInstance():getLaunchSubMode() > 0 then
        return UsageType.PLATFORMSET
    end
    if cc.exports.LaunchMode["PLATFORM"] == MCAgent:getInstance():getLaunchMode() then
        return UsageType.TCYAPP
    else
        return UsageType.TCY
    end
end

function PromoteCodeModel:getDeviceId()
	local szWifiID,szImeiID,szSystemID=device.szWifiID,device.szImeiID,device.szSystemID
	local deviceId=string.format('%s,%s,%s',szWifiID,szImeiID,szSystemID)
	return deviceId
end

-- 发送获取推广码的http请求
function PromoteCodeModel:SendHttp(callback)
    local usageType     = self:getUsageType()
    local subChannelId  = BusinessUtils:getInstance():getRecommenderId()
    local channelId     = subChannelId                          -- 单包的情况
    if usageType ~= UsageType.TCY then
        channelId = BusinessUtils:getInstance():getTcyChannel() -- 非单包情况
    end

    local params = {
        gameid      = BusinessUtils:getInstance():getGameID(),
        userid      = plugin.AgentManager:getInstance():getUserPlugin():getUserID(),
        channelid   = channelId
    }

    local xhr = cc.XMLHttpRequestExt:new()
    xhr.responseType = 0
    xhr:setRequestHeader('Content-Type', 'application/json')

    --Set Header Start
    --操作系统 1:安卓 2:苹果
    local osType = oscodeAndroid
    if device.platform == 'ios' then osType = oscodeIOS end
    --硬件信息
    local deviceID = self:getDeviceId()
    --网络 2G，3G，4G，5G，wifi
    local networkString = { '2G', '3G', 'Wifi', '4G', 'Unknow' }
    local typeString = networkString[DeviceUtils:getInstance():getNetworkType()]
    if typeString == 'Wifi' then
        local wifiInfo = DeviceUtils:getInstance():getGameWifiInfo()
        if wifiInfo then
            typeString = typeString .. '_' .. wifiInfo.wifiLevel
        end
    end
    --请求时间戳
    local curTime = os.time() * 1000
    local headers = {
        Imei    = DeviceUtils:getInstance().getIMEI and DeviceUtils:getInstance():getIMEI() or "",
        Os      = osType,
        OsVer   = DeviceUtils:getInstance().getSystemVersion and DeviceUtils:getInstance():getSystemVersion() or "",
        HardInfo= deviceID,
        Net     = typeString,
        Package = BusinessUtils:getInstance().getPackageName and BusinessUtils:getInstance():getPackageName() or "",
        AppVer  = BusinessUtils:getInstance().getAppVersion and BusinessUtils:getInstance():getAppVersion() or "",
        EVer    = BusinessUtils:getInstance().getEngineVersion and BusinessUtils:getInstance():getEngineVersion() or "",
        Ak      = plugin.AgentManager:getInstance():getUserPlugin():getAccessToken(),
        UId     = plugin.AgentManager:getInstance():getUserPlugin():getUserID(),
        Channel = channelId,
        Ts      = curTime,
    }
    if type(headers) == "table" then
        for key, value in pairs(headers) do
            xhr:setRequestHeader(key, value)
        end
    end
    --Other Header End

    --KPI start
    local analyticsPlugin = plugin.AgentManager:getInstance():getAnalyticsPlugin()
    if analyticsPlugin and analyticsPlugin.getDisdkExtendedJsonInfo then
        local gsClient = analyticsPlugin:getDisdkExtendedJsonInfo()
        if gsClient then
            xhr:setRequestHeader("GsClientData", gsClient);
        end
    end
    --KPI end

    local url = string.format("%s%s?gameid=%d&userid=%d&channelid=%d", self._domain, self._api, params.gameid, params.userid, params.channelid)
    xhr:open('GET', url)
    xhr:registerScriptHandler( function()
        printLog(self.__cname, 'status: %s, response: %s', xhr.status, xhr.response)
        callback(xhr)
    end )
    xhr:send()
    printLog(self.__cname, 'http GET url: %s', url)
end

return PromoteCodeModel
