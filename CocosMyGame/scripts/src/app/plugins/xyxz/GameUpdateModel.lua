--[[
@描述: 负责检查更新并下载游戏
@作者：陈添泽
@日期：2019.12.16
]]

local GameUpdateModel = class('GameUpdateModel')

GameUpdateModel.EVENT_UPDATE_OK         = 'EVENT_UPDATE_OK'
GameUpdateModel.EVENT_UPDATE_CANCEL     = 'EVENT_UPDATE_CANCEL'
GameUpdateModel.EVENT_UPDATE_FAILED     = 'EVENT_UPDATE_FAILED'
GameUpdateModel.EVENT_UPDATE_PROGRESS   = 'EVENT_UPDATE_PROGRESS'
GameUpdateModel.EVENT_UPDATE_UNZIP      = 'EVENT_UPDATE_UNZIP'
GameUpdateModel.EVENT_UPDATE_START      = 'EVENT_UPDATE_START'
GameUpdateModel.EVENT_UPDATE_PAUSED     = 'EVENT_UPDATE_PAUSED'
GameUpdateModel.EVENT_UPDATE_DOWNLOAD   = 'EVENT_UPDATE_DOWNLOAD'

if BusinessUtils:getInstance():isGameDebugMode() then
    GameUpdateModel.DOMAIN_NAME = "http://rmsyssvc.uc108.org:1505"
else
    GameUpdateModel.DOMAIN_NAME = "https://rmsyssvc.uc108.net"
end
GameUpdateModel.API_CHECKUPDATE = "/api/version/Checkupdate?gamecode=%s&version=%s&os=%d&channelId=%d"

local CHECKSTATE = {
    STATE_NEW               = 1,
    STATE_OLD_INCOMPATIBLE  = 2,
    STATE_OLD_COMPATIBLE    = 3,
    STATE_VERSION_ERROR     = 4
}

local TYPE_OS = {
    OS_ANDROID              = 1,
    OS_IOS                  = 2
}

local PACKAGESOURCE = {
    PACKAGESOURCE_CHANNEL   = 1,
    PACKAGESOURCE_INTERNAL  = 2,
}
local UPDATEWAY = {
    UPDATEWAY_WHOLE         = 2,
    UPDATEWAY_HOT           = 3,
    UPDATEWAY_HOT_WHOLE     = 4
}
local TIMEOUT = 8

my.addInstance(GameUpdateModel)
function GameUpdateModel:ctor()
    local event = cc.load('event')
    event:create():bind(self)
    self._downloadHandlers = {} --下载句柄，用来暂停和重启下载
end

function GameUpdateModel:startUpdate(gameAppConfig, recommenderId, bUnzipToHost)
    --直接串行完成流程
    self._bUnzipToHost = bUnzipToHost --解压到宿主目录下，而不是自己缩写下
    self:_checkUpdate(gameAppConfig, recommenderId)
    self:dispatchEvent({name = self.EVENT_UPDATE_START, params = gameAppConfig})
end

function GameUpdateModel:pauseUpdate(szGameCode)
    DownloadUtils:getInstance():pause(self._downloadHandlers[szGameCode])
    self:dispatchEvent({name = self.EVENT_UPDATE_PAUSED, params = {abbr = szGameCode}})
end

function GameUpdateModel:resumeUpdate(szGameCode)
    DownloadUtils:getInstance():resume(self._downloadHandlers[szGameCode])
    self:dispatchEvent({name = self.EVENT_UPDATE_START, params = {abbr = szGameCode}})
end

function GameUpdateModel:_checkUpdate(gameAppConfig, recommenderId)
    local url = string.format(self.DOMAIN_NAME .. self.API_CHECKUPDATE, 
        gameAppConfig.abbr, 
        gameAppConfig.version, 
        TYPE_OS.OS_ANDROID,--'ios' and TYPE_OS.OS_IOS or TYPE_OS.OS_ANDROID, 理论上是一样的，一律获取安卓包
        recommenderId or BusinessUtils:getInstance():getRecommenderId())
    print(url)
    local xhr = cc.XMLHttpRequestExt:new()
    xhr.responseType = 0
    xhr:setRequestHeader('Content-Type', 'application/json')
    xhr:open("GET", url)
    xhr:registerScriptHandler(function ()
        self:_onCheckUpdateResult(xhr, gameAppConfig)
    end)
    xhr:send()
end

function GameUpdateModel:_onCheckUpdateResult(xhr, gameAppConfig)
    if xhr.status == xhr.HTTP_RESPONSE_SUCCEED then
        local response = json.decode(xhr.response)
        if      CHECKSTATE.STATE_NEW                == response.State then
            self:dispatchEvent({name = self.EVENT_UPDATE_OK, params = gameAppConfig})
        elseif  CHECKSTATE.STATE_OLD_INCOMPATIBLE   == response.State 
            or  CHECKSTATE.STATE_OLD_COMPATIBLE     == response.State then
            --不论是否强更一律直接开始
            if response.PackageSource       == PACKAGESOURCE.PACKAGESOURCE_CHANNEL then
                --渠道更新包括“通知tcyapp”、“打开应用市场”、“打开链接”————全部不处理
                self:dispatchEvent({name = self.EVENT_UPDATE_FAILED, params = gameAppConfig})
            elseif response.PackageSource   == PACKAGESOURCE.PACKAGESOURCE_INTERNAL then
                if response.UpdateWay       == UPDATEWAY.UPDATEWAY_WHOLE then
                    --整包更新————不处理
                    self:dispatchEvent({name = self.EVENT_UPDATE_FAILED, params = gameAppConfig})
                elseif response.UpdateWay   == UPDATEWAY.UPDATEWAY_HOT 
                or     response.UpdateWay   == UPDATEWAY.UPDATEWAY_HOT_WHOLE then
                    if response.downloadUrl and string.len(response.downloadUrl) > 0 then
                        self:startDownload(response.downloadUrl, gameAppConfig)
                    else 
                        self:dispatchEvent({name = self.EVENT_UPDATE_FAILED, params = gameAppConfig})
                    end
                end
            end
        elseif  CHECKSTATE.STATE_VERSION_ERROR      == response.State then
            self:dispatchEvent({name = self.EVENT_UPDATE_FAILED, params = gameAppConfig})
        else
            self:dispatchEvent({name = self.EVENT_UPDATE_OK, params = gameAppConfig})
        end
    else
        self:dispatchEvent({name = self.EVENT_UPDATE_FAILED, params = gameAppConfig})
    end
    
end

function GameUpdateModel:startDownload(url, gameAppConfig)
    local downloadInfo  = DownloadUtils:getInstance():getDownloadInfo(url)
    local totalSize     = downloadInfo.totalSize
    local fileSize      = downloadInfo.downloaded

    local function onDownloadProgress(total, downloaded, url, customID)
        -- printf('onDownloadProgress %s, total:%d  downloaded: %d.', url, total, downloaded)
        gameAppConfig.total         = total
        gameAppConfig.downloaded    = downloaded
        self:dispatchEvent({name = self.EVENT_UPDATE_PROGRESS, params = gameAppConfig})
    end
    local function onDownloadOK(url, storagePath, customID)
        if type(gameAppConfig.md5) ~= "string" or gameAppConfig.md5:len() == 0 or self:_checkFileMD5(storagePath, gameAppConfig.md5) then
            self:_decompressFile(storagePath, gameAppConfig)
            self:dispatchEvent({name = self.EVENT_UPDATE_UNZIP, params = gameAppConfig})
        else
            cc.FileUtils:getInstance():removeFile(storagePath)
            self:dispatchEvent({name = self.EVENT_UPDATE_FAILED, params = gameAppConfig})
        end
    end
    local function onDownloadError(code, msg, url, customID)
        self:dispatchEvent({name = self.EVENT_UPDATE_FAILED, params = gameAppConfig})
        local failMessage
        if code and msg then
            failMessage = "download fail code:".. tostring(code).." message:"..msg
        else
            failMessage = "download fail code:" 
        end
    end

    DownloadUtils:getInstance():setProgressCallback(onDownloadProgress)
    DownloadUtils:getInstance():setSuccessCallback(onDownloadOK)
    DownloadUtils:getInstance():setErrorCallback(onDownloadError)
    self._downloadHandlers[gameAppConfig.abbr] = DownloadUtils:getInstance():download(url, '', TIMEOUT)
    self:dispatchEvent({name = self.EVENT_UPDATE_DOWNLOAD, params = gameAppConfig})
end

--[文件解压]
function GameUpdateModel:_decompressFile(filePath, gameAppConfig)
    my.scheduleOnce(function()
        local abbr = self._bUnzipToHost and BusinessUtils:getInstance():getAbbr() or gameAppConfig.abbr
        local targetPath = BusinessUtils:getInstance():getUpdateDirectory() .. abbr .. '/'
        cc.FileUtils:getInstance():createDirectory(targetPath)
        MCAgent:getInstance():decompress(filePath, targetPath)
        cc.FileUtils:getInstance():removeFile(filePath)
        self:dispatchEvent({name = self.EVENT_UPDATE_OK, params = gameAppConfig})
    end)
end

function GameUpdateModel:_checkFileMD5(filePath, md5)
    local checkMD5 = MCCrypto:md5File(filePath)
    return string.lower(md5) == string.lower(checkMD5)
end

return GameUpdateModel