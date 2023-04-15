
local ConfigModelBase = class('ConfigModelBase')

local json = cc.load("json").json

local KEY_VERSION           = 'version'
local KEY_DATA              = 'data'
local KEY_ID                = 'ID'

-- local RETURN_KEY_STATUS     = 'Status'
local RETURN_KEY_STATUS     = 'Code'
local RETURN_KEY_MSG        = 'Msg'
local RETURN_KEY_DATA       = 'Data'

-- local RETURN_KEY_VERSION    = 'Version'
local RETURN_KEY_VERSION    = 'ConfigVersion'
local RETURN_KEY_HEAD       = 'ConfigJson'

local TIME_OUT              = 5000

local HTTP_REQUEST_SUCCESS  = 200

local function getConfigUpdateBaseUrl()
    return myhttp:getConfigUpdateBaseUrl()
end

function ConfigModelBase:ctor()
    self.__configContent    = nil
    self.__configVersion    = 0
    self.__configData       = ''
    self._isReceivedResponseFromServer = false --是否已经从后台获取回应；某些敏感功能，在未获得后台回应前，不允许使用本地缓存
    local event=cc.load('event')
    event:create():bind(ConfigModelBase)

    self:init()
end

function ConfigModelBase:init()
    self:initConfigContent()
    
    self:initConfigVersion()
    self:initConfigData()
end

function ConfigModelBase:isReceivedResponseFromServer()
    return self._isReceivedResponseFromServer
end

function ConfigModelBase:reset()
    self:ctor()
end

function ConfigModelBase:initConfigContent()
    if self.__configContent == nil then
        self.__configContent = self:getConfigContent(self:getConfigPath() .. self:getConfigName())
    end
end

-- must be overrided
function ConfigModelBase:getConfigPath()
    return ''
end

-- must be overrided
function ConfigModelBase:getConfigName()
    return ''
end

-- must be overrided
function ConfigModelBase:getConfigType()
    return 0
end

-- must be overrided
function ConfigModelBase:getConfigID()
    return ''
end

function ConfigModelBase:getReqTimeOut()
    return TIME_OUT
end

function ConfigModelBase:isStringValid(str)
    if (str and 'string' == type(str) and 0 < string.len(str)) then return true else return false end
end

function ConfigModelBase:isNumberValid(str)
    if (str and 'number' == type(str)) then return true else return false end
end

function ConfigModelBase:getConfigContent(filename)
    if self:isStringValid(filename) then
        local config = cc.FileUtils:getInstance():getStringFromFile(filename)
        if self:isStringValid(config) then
            return config
        end
    end
    return nil
end

function ConfigModelBase:parseConfig(content, key, default)
    if self:isStringValid(content) then
        local decontent = safeDecoding(content)
        if decontent then
            local outcontent = decontent[key]
            if outcontent then
                return outcontent
            end
        end
    end
    return default
end

-- function ConfigModelBase:initConfigVersion()
--     self.__configVersion = self:parseVersion(self.__configContent)
-- end

function ConfigModelBase:initConfigVersion()
    local ChangeToNewAddtion = CacheModel:getCacheByKey("ChangeToNewAddtion")
    if type(ChangeToNewAddtion) == "number" and ChangeToNewAddtion == 1 then
        self.__configVersion = self:parseVersion(self.__configContent)
    else
        self.__configVersion = 0
    end
end

function ConfigModelBase:initConfigData()
    self.__configData = self:parseConfigData(self.__configContent)
end

function ConfigModelBase:updateConfigVersion(content)
    self.__configVersion = self:parseVersion(content)
end

function ConfigModelBase:updateConfigData(content)
    print("ConfigModelBase:updateConfigData")
    self.__configData = self:parseConfigData(content)
    dump(self.__configData)
end

function ConfigModelBase:parseVersion(content)
    return self:parseConfig(content, KEY_VERSION, 0)
end

function ConfigModelBase:parseConfigData(content)
    return self:parseConfig(content, KEY_DATA, '')
end

function ConfigModelBase:getConfigVersion()
    return self.__configVersion
end

function ConfigModelBase:getConfigData()
    return self.__configData
end

-- function ConfigModelBase:reqLatestConfig()
--     local url = getConfigUpdateBaseUrl()
--     url = string.format('%sapi/config/GetUpdateConfig?GameCode=%s&ChannleId=%s&VersionId=%s&Version=%d&ConfigType=%d',
--             url, my.getGameShortName(), BusinessUtils:getInstance():getRecommenderId(), my.getGameVersion(), self:getConfigVersion(), self:getConfigType())

--     print("1111111111111="..url)
--     local xhr = cc.XMLHttpRequest:new()
--     xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
--     xhr.timeout = self:getReqTimeOut()
--     xhr:open("GET", url)
--     xhr:registerScriptHandler(function()
--         self:onGetConfigCallback(xhr)
--     end)
--     xhr:send()
-- end

function ConfigModelBase:reqLatestConfig()
    local url = getConfigUpdateBaseUrl()
    local usageType = self:getUsageType()
    local subChannelId = BusinessUtils:getInstance():getRecommenderId()
    local channelId = subChannelId --单包的情况
    if usageType ~= 1 then
        channelId = BusinessUtils:getInstance():getTcyChannel()
    end
    url = string.format('%sapi/AppConfig/GetUploadConfig?AppCode=%s&ChannelId=%s&SubChannelId=%s&VersionNo=%s&ConfigVersion=%d&ConfigType=%d&UsageType=%d',
            url, my.getGameShortName(), channelId, subChannelId, my.getGameVersion(), self:getConfigVersion(), self:getConfigType(), self:getUsageType())
    print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>")
    print(url)
    local xhr = cc.XMLHttpRequest:new()
    xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_JSON
    xhr.timeout = self:getReqTimeOut()
    xhr:open("GET", url)
    xhr:registerScriptHandler(function()
        self:onGetConfigCallback(xhr)
    end)
    xhr:send()
end

function ConfigModelBase:updateConfig(path, filename, content, configversion)
    if not self:isStringValid(path) or
        not self:isStringValid(filename) or
        not self:isStringValid(content) or
        not self:isNumberValid(configversion) or
        math.ceil(configversion) <= self:getConfigVersion() then return end

    local jsonContent = safeDecoding(content)
    if jsonContent and jsonContent[KEY_ID] == self:getConfigID() then
        jsonContent[KEY_VERSION] = math.ceil(configversion)
        content = json.encode(jsonContent)

        if self:isStringValid(content) then
            self:writeConfig(path, filename, content)
            self:updateConfigVersion(content)
            self:updateConfigData(content)
        end
    end
end

function ConfigModelBase:writeConfig(path, filename, content)
    cc.FileUtils:getInstance():createDirectory(path)
    return io.writefile(path .. filename, content)
end

function ConfigModelBase:getConfigUpdateBaseUrl()
    return getConfigUpdateBaseUrl()
end

function ConfigModelBase:onGetConfigCallback(xhr)
    if xhr.status == HTTP_REQUEST_SUCCESS then
        local returnContent = safeDecoding(xhr.response)
        if returnContent then
            self._isReceivedResponseFromServer = true

            if 0 > returnContent[RETURN_KEY_STATUS] then
                dump(returnContent[RETURN_KEY_MSG])
            else
                if returnContent[RETURN_KEY_DATA] and
                self:isStringValid(returnContent[RETURN_KEY_DATA][RETURN_KEY_HEAD]) and
                self:isNumberValid(returnContent[RETURN_KEY_DATA][RETURN_KEY_VERSION]) then

                    self:updateConfig(
                        BusinessUtils:getInstance():getUpdateDirectory() .. my.getAbbrName() .. '/' .. self:getConfigPath(),
                        self:getConfigName(),
                        returnContent[RETURN_KEY_DATA][RETURN_KEY_HEAD],
                        returnContent[RETURN_KEY_DATA][RETURN_KEY_VERSION])
                end
            end
        end
    end
end

return ConfigModelBase
