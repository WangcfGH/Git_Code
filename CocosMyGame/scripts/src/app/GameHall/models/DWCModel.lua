--[[
@描述: 电玩城数据模块，用来下载和启动电玩城。从接口设计来看是支持其他游戏的，但是我们设计模块的时候只考虑电玩城
@作者：陈添泽
@日期：2018.3.15
]]
local DWC                       = {}
cc.exports.DWC                  = DWC

local DWC_GAMECODE              = "jjdw"
local DWC_GAMEID                = 776

--cs
local DWC_CHILDID               = 12345
local DWC_CHILDCODE             = "abc"

local listeners                 = {icon = {}, download = {}}
local platformNotifyCache       = {}
local bDownloadStatus           = false
local bBackGroud                = false
local bDownloadFinished         = false

local DOMAIN_NAME_DEBUG         = "ht".."tp://arcadecollectionapi.tcy365.org:1507/"
local DOMAIN_NAME_PRERELEASE    = "ht".."tp://arcadecollectionapi.tcy365.net:2505/"
local DOMAIN_NAME_RELEASE       = "https://arcadecollectionapi.tcy365.net/"

local API_GET_ICON              = "api/Client/GetIcon?gameCode=%s&gameAttr=%s&versionNo=%s"
local API_CHECK_CHANNELVALID    = "api/Client/CheckIsValidChannel?gameCode=%s&gameAttr=%s&channelId=%s&gameId=%s"
local DWC_CACHE_KEY             = "DWCIconUrl"

local function _downloadDWC(isIgnore4G)
    local params    = {
        sourcecode  = my.getAbbrName(),
        sourceid    = my.getGameID(),
        destcode    = DWC_GAMECODE,
        destid      = DWC_GAMEID,
        sourcever   = my.getGameVersion(),
        isIgnore4G  = isIgnore4G or false
    }
    BusinessUtils:getInstance():notifyPlatform(GameNotification.kGameNotificationDownloadGame, "", json.encode(params))
end

local function _startDWC()
    local params    = {
        sourcecode  = my.getAbbrName(),
        sourceid    = my.getGameID(),
        destcode    = DWC_GAMECODE,
        destid      = DWC_GAMEID,
        sourcever   = my.getGameVersion(),
        childid     = DWC_CHILDID,
        childcode   = DWC_CHILDCODE
    }
    BusinessUtils:getInstance():notifyPlatform(GameNotification.kGameNotificationQuitAndEnter, "", json.encode(params))
end

local function _pauseDownload()
    local params    = {
        sourcecode  = my.getAbbrName(),
        sourceid    = my.getGameID(),
        destcode    = DWC_GAMECODE,
        destid      = DWC_GAMEID,
        sourcever   = my.getGameVersion()
    }
    BusinessUtils:getInstance():notifyPlatform(GameNotification.kGameNotificationStopDownloadGame, "", json.encode(params))
end

local function _endGame()
    if(mc and mc.createClient)then
        local mclient = mc.createClient()
        mclient:sendRequest(mc.LOGOFF_USER, {}, 'hall', false)
        mclient:destroy('hall')
        mclient:destroy('room')
    end
    local agent = MCAgent:getInstance()
    agent:endToLua()
end

local function _dispatchDownloadEvents(...)
    for _, listener in pairs(listeners["download"]) do
        listener(...)
    end
end

local function _dispatchIconEvent(...)
    for _, listener in pairs(listeners["icon"]) do
        listener(...)
    end
end

local function _onPlatformNotify(code, msg, extra)
    print("on platform notify dwcmodule", code, msg, extra)
    if bBackGroud then
        print("bBackGroud = true, notify saved to cache")
        table.insert(platformNotifyCache, {code = code, msg = msg, extra = extra})
    else
        if TcyNotification.kTcyNotificationDownloadGame == code then
            local content = safeDecoding(extra)
            local tcyCode = content.code 
            local ext     = content.ext
            if tcyCode == GAME_DOWNLOAD.USER_CANCEL_DOWNLOAD 
            or tcyCode == GAME_DOWNLOAD.GET_GAMEINFO_ERROR 
            or tcyCode == GAME_DOWNLOAD.GAME_DOWNLOAD_ERROR 
            or tcyCode == GAME_DOWNLOAD.GAME_DOWNLOAD_SUCCESS 
            or tcyCode == GAME_DOWNLOAD.GAME_DOWNLOAD_PAUSE
            or tcyCode == GAME_DOWNLOAD.IS_DOWNLOAD_CURRENT_NOT_WIFI
            or tcyCode == GAME_DOWNLOAD.WIFI_CHANGE_4G then
                bDownloadStatus = false
                DWC:cancelPlatformListner()
            end
            if tcyCode == GAME_DOWNLOAD.GAME_DOWNLOAD_SUCCESS then
                bDownloadFinished = true
            end
            _dispatchDownloadEvents(tcyCode, ext)
        end
    end
end

local function _listenToPlatform()
    BusinessUtils:getInstance():setPlatformListener("DWC" , _onPlatformNotify)
end

local function _getIconUrl()
    local domain    = BusinessUtils:getInstance():isGameDebugMode() and DOMAIN_NAME_DEBUG or DOMAIN_NAME_RELEASE
    local gameAttr  = cc.exports.LaunchMode["PLATFORM"] == MCAgent:getInstance():getLaunchMode() and DWC_HOST_ATTR.PLATFORM or DWC_HOST_ATTR.APK
    local versionNo = 0 --服务端接口设计存在疑议，其实每次直接获取最新的url即可，不需要传输版本号
    local url       = string.format(domain..API_GET_ICON, my.getAbbrName(), gameAttr, versionNo)
    return url
end

local function _getCheckChannelValidUrl()
    local domain    = BusinessUtils:getInstance():isGameDebugMode() and DOMAIN_NAME_DEBUG or DOMAIN_NAME_RELEASE
    local gameAttr  = cc.exports.LaunchMode["PLATFORM"] == MCAgent:getInstance():getLaunchMode() and DWC_HOST_ATTR.PLATFORM or DWC_HOST_ATTR.APK
    local channelId = BusinessUtils:getInstance():getTcyChannel()--BusinessUtils:getInstance():getRecommenderId()
    local gameId    = my.getGameID()
    local url       = string.format(domain..API_CHECK_CHANNELVALID, my.getAbbrName(), gameAttr, channelId, my.getGameID())
    return url
end

--[Comment]
--毫无意义的header。
local function _getRequestHeaders()
    local headers = {
        Os          = device.platform == "ios" and 2 or 1,
        TcyVersion  = "",
        TcyCode     = "",
        EngineNo    = BusinessUtils:getInstance().getEngineVersion and BusinessUtils:getInstance():getEngineVersion() or "",
        TcyPackage  = "",
        TcyPromoter = "",
        UserId      = UserPlugin:getUserID(),
        HardInfo    = mymodel('DeviceModel'):getInstance().szHardID,
        Network     = my.getNetworkTypeString(),
        Imei        = mymodel('DeviceModel'):getInstance().szImeiID,
        Timestamp   = tostring(os.time()),
        IpNumer     = "",
        CheckCode   = my.md5(string.format( "%s%s%d%s", UserPlugin:getUserID(), mymodel('DeviceModel'):getInstance().szImeiID, os.time(), "A12*d#^2なopぃxcふ~~jm")),
        Token       = UserPlugin:getAccessToken()
    }
    return headers
end

local function _onBackgroundCallback()
    bBackGroud = true
end

local function _onForegroundCallback()
    local schedueID
    schedueID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(schedueID)
        bBackGroud = false
        for _, notify in pairs(platformNotifyCache) do
            print("platformNotifyCache operating")
            _onPlatformNotify(notify.code, notify.msg, notify.extra)
        end
        platformNotifyCache = {}
    end, 0.1, false)
end

--[Comment]
--之所以需要主动取消监听的原因在于，setPlatformListener是单注入的，监听的时候把原来链接启动的监听覆盖了，所以更新好了要帮忙设置回来
function DWC:cancelPlatformListner()
    -- import('src.app.BaseModule.LaunchParamsManager'):initListeners()
    -- 由于改用新的监听接口所以监听不会互相顶掉，所以不再需要重新设置监听了
    -- 出于礼貌调用一下取消监听的接口
    BusinessUtils:getInstance():setPlatformListener("DWC" , nil)
end

function DWC:startDownload(onDownload, isIgnore4G)
    if bDownloadStatus then
        print("DWC downloading, please don't keep press")
        return 
    end
    bDownloadStatus = true
    self:addDownloadListener(onDownload)
    _listenToPlatform()
    _downloadDWC(isIgnore4G)
end

function DWC:pauseDownload()
    _pauseDownload()
end

function DWC:startGame()
    self:cancelPlatformListner()
    _startDWC()
    _endGame()
end

function DWC:updateIconInfo(callback)
    local function onGetIconInfo(xhr)
        if xhr.status == xhr.HTTP_RESPONSE_SUCCEED then
            local data = json.decode(xhr.response)
            print(string.format( "Code:%s, Message:", tostring(data.Code), tostring(data.Message)))
            dump(data.Data)
            if data.Data and type(data.Data.ImgUrl) == "string" then
                CacheModel:saveInfoToCache(DWC_CACHE_KEY, data.Data.ImgUrl)
                _dispatchIconEvent(data.Data.ImgUrl)
                if type(callback) == "function" then
                    callback(data.Data.ImgUrl)
                end
            end
        else
            printLog("DWC", 'updateIconInfo failed')
        end
    end
    HttpUtils.httpGet(_getIconUrl(), "", onGetIconInfo, "", _getRequestHeaders())
end

function DWC:checkChannelValid(callback)
    local function onCheckResult(xhr)
        if xhr.status == xhr.HTTP_RESPONSE_SUCCEED then
            local data = json.decode(xhr.response)
            dump(data)
            callback(data.Data)
        else
            printLog("DWC", 'checkChannelValid failed')
            --test 内网需要使用流量测试，接口超时暂定为可以打开
            local bAble = BusinessUtils:getInstance():isGameDebugMode()
            callback(bAble)
        end
    end
    HttpUtils.httpGet(_getCheckChannelValidUrl(), "", onCheckResult, "", _getRequestHeaders())
end

function DWC:isDownloading()
    return bDownloadStatus
end

function DWC:isDownloadFinished()
    return bDownloadFinished
end

function DWC:addDownloadListener(callback, tag)
    listeners["download"][tag or "default"] = callback
end

function DWC:removeDownloadListenerByTag(tag)
    listeners["download"][tag] = nil
end

function DWC:addIconListener(callback, tag)
    listeners["icon"][tag or "default"] = callback
end

function DWC:removeIconListenerByTag(tag)
    listeners["icon"][tag] = nil
end

AppUtils:getInstance():addPauseCallback(_onBackgroundCallback, "DWC_setBackgroundCallback")
AppUtils:getInstance():addResumeCallback(_onForegroundCallback, "DWC_ForegroundCallback")

return DWC