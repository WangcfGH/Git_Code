
local MoreGame                       = {}
cc.exports.MoreGame                  = MoreGame

--cs
local listeners                 = {download = {}}
local platformNotifyCache       = {}
local bDownloadStatus           = false
local bBackGroud                = false
local bDownloadFinished         = false 
local downloadGameCode          = nil     
local downloadGameID            = nil    

local function _downloadMoreGame(gameCode, gameID, isIgnore4G)
    local params    = {
        sourcecode  = my.getAbbrName(),
        sourceid    = my.getGameID(),
        destcode    = gameCode,
        destid      = gameID,
        sourcever   = my.getGameVersion(),
        isIgnore4G  = isIgnore4G or false
    }
    BusinessUtils:getInstance():notifyPlatform(GameNotification.kGameNotificationDownloadGame, "", json.encode(params))
end

local function _startMoreGame(gameCode, gameID)
    local params    = {
        sourcecode  = my.getAbbrName(),
        sourceid    = my.getGameID(),
        destcode    = gameCode,
        destid      = gameID,
        sourcever   = my.getGameVersion(),
    }
    BusinessUtils:getInstance():notifyPlatform(GameNotification.kGameNotificationQuitAndEnter, "", json.encode(params))
end


local function _quitMoreGame(gameCode, gameID)
    local params    = {
        destcode    = gameCode,
        destid      = gameID,
        sourcever   = my.getGameVersion(),
    }
    BusinessUtils:getInstance():notifyPlatform(GameNotification.kGameNotificationQuitAndEnter, "", json.encode(params))
end

local function _pauseDownload(gameCode, gameID)
    local params    = {
        sourcecode  = my.getAbbrName(),
        sourceid    = my.getGameID(),
        destcode    = gameCode,
        destid      = gameID,
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

local function _onPlatformNotify(code, msg, extra)
    print("on platform notify MoreGamemodule", code, msg, extra)
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
                MoreGame:cancelPlatformListner(content.destcode)
            elseif tcyCode == GAME_DOWNLOAD.GAME_DOWNLOAD_PROGRESS then
                if downloadGameCode ~= content.destcode then return end  
                bDownloadStatus = true
            end
            if tcyCode == GAME_DOWNLOAD.GAME_DOWNLOAD_SUCCESS then
                bDownloadFinished = true
            end
            _dispatchDownloadEvents(content)
        end
    end
end

local function _listenToPlatform(gameCode)
    BusinessUtils:getInstance():setPlatformListener(gameCode, _onPlatformNotify)
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
function MoreGame:cancelPlatformListner(gameCode)
    -- import('src.app.BaseModule.LaunchParamsManager'):initListeners()
    -- 由于改用新的监听接口所以监听不会互相顶掉，所以不再需要重新设置监听了
    -- 出于礼貌调用一下取消监听的接口
    BusinessUtils:getInstance():setPlatformListener(gameCode, nil)
end

function MoreGame:startDownload(gameCode, gameID, onDownload, isIgnore4G, downloadType)
    if downloadType then
        self:addDownloadListener(onDownload, downloadType)
    end
    if bDownloadStatus and gameCode == downloadGameCode then
        return 
    end  
    _listenToPlatform(gameCode)
    bDownloadStatus  = true
    downloadGameCode = gameCode
    downloadGameID   = gameID
    _downloadMoreGame(gameCode, gameID, isIgnore4G)
end

function MoreGame:pauseDownload(gameCode, gameID)
    _pauseDownload(gameCode, gameID)
end

function MoreGame:startGame(gameCode, gameID)
    _startMoreGame(gameCode, gameID)
    _endGame()
end

function MoreGame:quitMoreGame(gameCode, gameID)
    _quitMoreGame(gameCode, gameID)
    _endGame()
end

function MoreGame:isDownloading()
    return bDownloadStatus
end

function MoreGame:isDownloadFinished(gameCode)
    return bDownloadFinished and gameCode == downloadGameCode
end

function MoreGame:addDownloadListener(callback, tag)    
    listeners["download"][tag or "default"] = callback
end

function MoreGame:removeDownloadListenerByTag(tag)
    listeners["download"][tag] = nil
end
                                        
function MoreGame:getCurrentDownloadGameID()
    return downloadGameID
end

function MoreGame:getCurrentDownloadGameCode()
    return downloadGameCode
end

AppUtils:getInstance():addPauseCallback(_onBackgroundCallback, "MoreGame_setBackgroundCallback")
AppUtils:getInstance():addResumeCallback(_onForegroundCallback, "MoreGame_ForegroundCallback")

return MoreGame