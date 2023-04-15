local UpdateConfigsModel = class("UpdateConfigsModel")

local event=cc.load('event')

local json = cc.load("json").json


function UpdateConfigsModel:ctor()
    event:create():bind(self)
end

function UpdateConfigsModel:getInstance()
    if not UpdateConfigsModel._instance then
        UpdateConfigsModel._instance = UpdateConfigsModel:create()
    end
    return UpdateConfigsModel._instance
end

-- function UpdateConfigsModel:SendHttp(version, pType)
--     local baseUrl = self:getUrl({
--         {'GameCode', my.getAbbrName()},
--         {'ChannleId', BusinessUtils:getInstance():getRecommenderId()},
--         {'Version', version},
--         {'ConfigType', pType},
--         {'VersionId', my.getGameVersion()}
--     })
    
--     local xhr = cc.XMLHttpRequestExt:new()
--     xhr.timeout = 3
--     xhr.responseType = 0
--     xhr:open("GET", baseUrl)
--     printf("~~~~~~~url~~~~~ %s",baseUrl)
--     local function onReadyStateChange()
--         local x = xhr.response
--         local y = xhr.status
--         local z = xhr.responseText
--         if( xhr.status == xhr.HTTP_RESPONSE_SUCCEED )then
--             local AppJsonObj = json.decode(xhr.response)
--             printf("~~~~~~~~~~~~~save recharge~~~~~~~~~~~~~~")
--             if AppJsonObj["Status"] == 1 then
--                 self:saveShopConfigJson(AppJsonObj)
--                 cc.exports.LoadShopItemsConfig(true)
--             else
--                 cc.exports.LoadShopItemsConfig()
--             end
--         else
--             cc.exports.LoadShopItemsConfig()
--         end
--     end
--     xhr:registerScriptHandler(onReadyStateChange)
--     xhr:send()
-- end

function UpdateConfigsModel:SendHttp(version, pType)
    local usageType = self:getUsageType()
    local subChannelId = BusinessUtils:getInstance():getRecommenderId()
    local channelId = subChannelId --单包的情况
    if usageType ~= 1 then
        channelId = BusinessUtils:getInstance():getTcyChannel()
    end

    local baseUrl = self:getUrl({
        {'AppCode', my.getGameShortName()},
        {'ChannelId', channelId},
        {'SubChannelId', subChannelId},
        {'VersionNo', my.getGameVersion()},
        {'ConfigVersion', version},
        {'ConfigType', pType},
        {'UsageType', self:getUsageType()},
    })
    
    local xhr = cc.XMLHttpRequestExt:new()
    xhr.timeout = 3
    xhr.responseType = 0
    xhr:open("GET", baseUrl)
    printf("~~~~~~~url~~~~~ %s",baseUrl)
    local function onReadyStateChange()
        local x = xhr.response
        local y = xhr.status
        local z = xhr.responseText
        if( xhr.status == xhr.HTTP_RESPONSE_SUCCEED )then
            local AppJsonObj = json.decode(xhr.response)
            printf("~~~~~~~~~~~~~save recharge~~~~~~~~~~~~~~")
            if AppJsonObj["Code"] == 0 then
                self:saveShopConfigJson(AppJsonObj)
                cc.exports.LoadShopItemsConfig(true)
            else
                cc.exports.LoadShopItemsConfig()
            end
        else
            cc.exports.LoadShopItemsConfig()
        end
    end
    xhr:registerScriptHandler(onReadyStateChange)
    xhr:send()
end

function UpdateConfigsModel:saveShopConfigJson(dataMap)
    local data=checktable(dataMap)
    local writeablePath=cc.FileUtils:getInstance():getGameWritablePath()
    local DefaultSettingsDataFilePath=writeablePath..'/'..self:getShopConfigName()
    local pp = tostring(data.Data["ConfigJson"])
    io.writefile(DefaultSettingsDataFilePath, pp)
    DefaultSettingsDataFilePath=writeablePath..'/'..self:getShopVersionName()

    local app = '{\n  "appversion":'
    local ver = '\n  "version":'
    pp = app..'"'..my.getGameVersion()..'",\n'..ver..data.Data["ConfigVersion"]..'\n}'
    dump(pp)
    io.writefile(DefaultSettingsDataFilePath, MCCharset:getInstance():gb2Utf8String(pp, string.len(pp)))
end

function UpdateConfigsModel:getShopConfigName()
    local configName = "shopitemsconfig.json"
    if cc.exports.IsHejiPackage() == true then
        configName = "shopitemsconfig_heji.json"
    elseif device.platform == "windows" then
        configName = "shopitemsconfig.json"
    else
        if MCAgent:getInstance():getLaunchMode() == cc.exports.LaunchMode["ALONE"] then
            if device.platform == "ios" then -- ios单包
                configName = "shopitemsconfig_alone_ios.json"
            else -- 安卓单包
                --configName = "shopitemsconfig_alone_android.json"
                configName = "shopitemsconfig_heji.json" -- 2018年7月31日 Android单包被要求使用合集包的购买配置
            end
        else
            if device.platform == "ios" then -- ios集成包
                configName = "shopitemsconfig_ios.json"
            else -- 安卓集成包
                configName = "shopitemsconfig.json"
            end
        end
    end

    --测试代码
    --configName = "shopitemsconfig.json"

    return configName
end

function UpdateConfigsModel:getShopVersionName()
    return "newshopversion.json"
end

-- local DEBUG_BASEURL = 'http://rmsyssvc.uc108.org:1505/api/config/GetUpdateConfig?'
-- local BASEURL = 'https://rmsyssvc.uc108.net/api/config/GetUpdateConfig?'
local DEBUG_BASEURL = 'http://rusysappconfigapi.tcy365.org:1505/api/AppConfig/GetUploadConfig?'
local BASEURL = 'https://rusysappconfigapi.tcy365.com/api/AppConfig/GetUploadConfig?'
function UpdateConfigsModel:getUrl(params)
    local baseUrl = BusinessUtils:getInstance():isGameDebugMode() and DEBUG_BASEURL or BASEURL

    for paramsIndex = 1, #params do
        local param = params[paramsIndex]

        baseUrl = baseUrl .. param[1] .. '=' .. param[2]
        if #params > paramsIndex then
            baseUrl = baseUrl .. '&'
        end
    end
    
    return baseUrl
end

local UsageType = {
    TCY    = 1,--单包
    TCYAPP = 2,--同城游
    PLATFORMSET = 3,    --合集包
}

function UpdateConfigsModel:getUsageType()
    if  MCAgent:getInstance().getLaunchSubMode and MCAgent:getInstance():getLaunchSubMode() > 0 then
        return UsageType.PLATFORMSET
    end
    if cc.exports.LaunchMode["PLATFORM"] == MCAgent:getInstance():getLaunchMode() then
        return UsageType.TCYAPP
    else
        return UsageType.TCY
    end
end

return UpdateConfigsModel