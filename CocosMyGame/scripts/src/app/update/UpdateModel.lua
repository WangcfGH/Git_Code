--[[
    UPDATE METHOD:
    UPDATE_NEEDLESS
    UPDATE_FAILED
    UPDATE_INNER_HOT
    UPDATE_INNER_WHOLE
    UPDATE_CHANNEL_NONE
    UPDATE_CHANNEL_LINK
    UPDATE_CHANNEL_PACKAGE
    UPDATE_CHANNEL_TCYAPP
]]

local UpdateModel = class('UpdateModel')
cc.load('httpext')

UpdateModel.APIURL_CHECKUPDATE = '/api/version/Checkupdate?'
UpdateModel.DIR_CHECKFILE = cc.FileUtils:getInstance():getGameWritablePath()

function UpdateModel:ctor(updateConfig)
    self._updateConfig = updateConfig

    self:onCreate()
end

function UpdateModel:onCreate()
    self:_loadConfig()
end

function UpdateModel:_loadConfig()
    self:_loadUpdateConfig()
end

function UpdateModel:_loadUpdateConfig()
    local updateConfig = self._updateConfig
    if DEBUG then
        dump(updateConfig)
    end

    self._baseUrl = BusinessUtils:getInstance():isGameDebugMode() and updateConfig.DebugResourceServerDomain 
        or updateConfig.ResourceServerDomain
end

function UpdateModel:checkUpdate()
    printLog(self.__cname, 'checkUpdate')

    if DeviceUtils:getInstance():getNetworkType() == NetworkType.kNetworkTypeDisconnection then
        self:_updateCheckFinished()
        return
    end
    
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    local params = {
        gamecode = BusinessUtils:getInstance():getAbbr(),
        version = BusinessUtils:getInstance():getAppVersion(),
        os = device.platform == 'ios' and TYPE_OS.OS_IOS or TYPE_OS.OS_ANDROID,
        channelId = BusinessUtils:getInstance():getRecommenderId()
    }

    local url = self:_mosaicUrl(self._baseUrl, self.APIURL_CHECKUPDATE, params)

    if self._curCheckXhr then
        self._curCheckXhr:abort()
        self._curCheckXhr = nil
    end

    local xhr = cc.XMLHttpRequestExt:new()
    xhr.responseType = 0
    xhr:open("POST", url)
    print("UpdateModel:checkUpdate", url)

    xhr:registerScriptHandler(function()
        self._curCheckXhr = nil
        print("UpdateModel:checkUpdate", xhr.status, xhr.response)
        if xhr.status == xhr.HTTP_RESPONSE_SUCCEED then
            self:_dealwithCheckResult(xhr.response)
        else
            self:_updateCheckFinished()
        end
    end)
    xhr:send()
    self._curCheckXhr = xhr
end

function UpdateModel:_mosaicUrl(baseUrl, api, params)
    local url = baseUrl .. api
    local paramIndex = 1
    for k, v in pairs(params) do
        url = url .. k .. '=' .. v
        if paramIndex < table.nums(params) then
            url = url .. '&'
        end
        paramIndex = paramIndex + 1
    end

    return url
end

function UpdateModel:_dealwithCheckResult(result)
    local json = cc.load('json').json
    local jsonResult ={}
    if result then
        jsonResult = json.decode(result)
        dump(jsonResult)
    end

    local switchAction = {
        [CHECKSTATE.STATE_NEW] = function()
            self:_updateCheckFinished({ updateMethod = 'UPDATE_NEEDLESS' })
        end,

        [CHECKSTATE.STATE_OLD_INCOMPATIBLE] = function()
            self:_parseCheckResult(jsonResult)
        end,

        [CHECKSTATE.STATE_OLD_COMPATIBLE] = function()
            self:_parseCheckResult(jsonResult)
        end,

        [CHECKSTATE.STATE_VERSION_ERROR] = function()
            self:_updateCheckFinished({ updateMethod = 'UPDATE_NEEDLESS' })
        end,
    }

    if switchAction[jsonResult.State] then
        switchAction[jsonResult.State]()
    else
        print('unknow state.')
        self:_updateCheckFinished()
    end
end

function UpdateModel:_updateCheckFinished(result)
    if not result then
        result = {updateMethod = 'UPDATE_FAILED'}
    end

    if self._callback then
        self._callback('CHECKRESULT', result)
    end
end

function UpdateModel:setResultCallback(callback)
    self._callback = callback
end

function UpdateModel:_fillupDownloadInfo(url, checkResult)
    if url then
        local downloadInfo = DownloadUtils:getInstance():getDownloadInfo(url)

        checkResult.fileSize = downloadInfo.totalSize - downloadInfo.downloaded
        checkResult.totalSize = downloadInfo.totalSize
        checkResult.path = downloadInfo.path
    else
        checkResult.fileSize = 0
        checkResult.totalSize = 0
    end
end

function UpdateModel:_parseCheckResult(result)
    local checkResult = {}

    local PACKAGESOURCE = {
            PACKAGESOURCE_CHANNEL = 1,
            PACKAGESOURCE_INTERNAL = 2,
        }

    checkResult.description     = result.Description
    checkResult.overlook        = result.Overlook
    checkResult.packageName     = result.PackageName
    checkResult.isChannelUpdate  = result.PackageSource == PACKAGESOURCE.PACKAGESOURCE_CHANNEL
    checkResult.updateTip       = result.UpdateTip
    checkResult.jump            = result.Jump
    checkResult.link            = result.Link
    checkResult.downloadUrl     = result.downloadUrl
    self:_fillupDownloadInfo(result.downloadUrl, checkResult)

    local function parseUpdateMethod(_result)
        local UPDATEWAY = {
            UPDATEWAY_WHOLE = 2,
            UPDATEWAY_HOT = 3,
        }

        local updateMethod = 'UPDATE_FAILED'
        
        if _result.PackageSource == PACKAGESOURCE.PACKAGESOURCE_CHANNEL then
            if not _result.UpdateTip then
                updateMethod = 'UPDATE_NEEDLESS'
            elseif _result.Jump then
                if MCAgent:getInstance():getLaunchMode() == LaunchMode.PLATFORM then
                    updateMethod =  'UPDATE_CHANNEL_TCYAPP'
                elseif UpdateUtils.checkAppExist(_result.PackageName) then
                    updateMethod =  'UPDATE_CHANNEL_PACKAGE'
                elseif UpdateUtils.checkString(_result.Link) then
                    updateMethod =  'UPDATE_CHANNEL_LINK'
                else
                    updateMethod = 'UPDATE_CHANNEL_NONE'
                end
            else
                updateMethod = 'UPDATE_CHANNEL_NONE'
            end
        elseif _result.PackageSource == PACKAGESOURCE.PACKAGESOURCE_INTERNAL then
            if _result.UpdateWay == UPDATEWAY.UPDATEWAY_WHOLE then
                updateMethod = 'UPDATE_INNER_WHOLE'
            elseif _result.UpdateWay == UPDATEWAY.UPDATEWAY_HOT then
                updateMethod = 'UPDATE_INNER_HOT'
            end
        end

        return updateMethod
    end
    checkResult.updateMethod = parseUpdateMethod(result)

    dump(checkResult)
    self:_updateCheckFinished(checkResult)
end

function UpdateModel:startDownload(url)
    printLog(self.__cname, 'startDownload')
    print(url)

    local downloadUtils = DownloadUtils:getInstance()
    downloadUtils:setProgressCallback(handler(self, self._onDownloadProgress))
    downloadUtils:setSuccessCallback(handler(self, self._onDownloadOK))
    downloadUtils:setErrorCallback(handler(self, self._onDownloadError))

    self._downloadID = downloadUtils:download(url, '', self._updateConfig.DownloadTimeOut)
end

function UpdateModel:pauseDownload()
    if self._downloadID then
        printLog(self.__cname, 'pauseDownload')
        DownloadUtils:getInstance():pause(self._downloadID)
    end
end

function UpdateModel:resumeDownload()
    if self._downloadID then
        printLog(self.__cname, 'resumeDownload')
        DownloadUtils:getInstance():resume(self._downloadID)
    end
end

function UpdateModel:stopDownload()
    if self._downloadID then
        printLog(self.__cname, 'stopDownload')
        DownloadUtils:getInstance():stop(self._downloadID)
    end

    self._downloadID = nil
end

function UpdateModel:_onDownloadOK(url, storagePath, customID)
    printf('%s download OK, storagePath is %s.', url, storagePath)
    if self._callback then
        self._callback('DOWNLOADOK', {url = url, storagePath = storagePath})
    end
end

function UpdateModel:_onDownloadProgress(total, downloaded, url, customID)
    printf('%s, %d downloaded.', url, downloaded)
    if self._callback then
        self._callback('DOWNLOADPROGRESS', {total = total, downloaded = downloaded, url = url})
    end
end

function UpdateModel:_onDownloadError(code, msg, url, customID)
    if self._callback then
        self._callback('DOWNLOADERROR', {code = code, msg = msg, url = url, customID = customID})
    end
end

function UpdateModel:decompressFile(filePath, decompressPath, bDelete)
    printLog(self.__cname, 'decompressFile')
    local mcAgent, fileUtils = MCAgent:getInstance(),  cc.FileUtils:getInstance()

    cc.FileUtils:getInstance():createDirectory(decompressPath)
    mcAgent:decompress(filePath, decompressPath)
    if bDelete then
        fileUtils:removeFile(filePath)
    end
end

function UpdateModel:getCheckMD5(url)
    if not url then
        printLog(self.__cname, 'getCheckMD5 url is nil')
        return
    end

    printLog(self.__cname, 'getCheckMD5: ' .. url)
    local abbr, channelID = BusinessUtils:getInstance():getAbbr(), BusinessUtils:getInstance():getRecommenderId()
    local fileName = abbr .. '_an_' .. channelID
    self._md5FilePath = self.DIR_CHECKFILE .. fileName .. '_packageinfo.txt'

    local checkString = cc.FileUtils:getInstance():getStringFromFile(self._md5FilePath)
    if UpdateUtils.checkString(checkString) then
        local checkObj = cc.load('json').json.decode(checkString)
        if checkObj and self:checkLocalVersion(checkObj.version) then
            self.MD5 = checkObj.md5
        else
            self:getCheckMD5FromNet(fileName, url)
        end
    else
        self:getCheckMD5FromNet(fileName, url)
    end
end

function UpdateModel:getCheckMD5FromNet(fileName, url)
    local checkFileUrl = self:_getMD5DownloadUrl(url, fileName)
    if checkFileUrl then
        local xhr = cc.XMLHttpRequestExt:new()
        xhr.responseType = 0
        xhr:open("GET", checkFileUrl)

        xhr:registerScriptHandler(function()
            if xhr.status == xhr.HTTP_RESPONSE_SUCCEED then
                self:_dealwithNewMD5(xhr.response)
            end
        end)
        xhr:send()
    end
end

function UpdateModel:_getMD5DownloadUrl(url, fileName)
    local findPos, checkFileUrl = string.find(url, fileName)
    if findPos then
        checkFileUrl = string.sub(url, 1, findPos + string.len(fileName) - 1)
        checkFileUrl = checkFileUrl .. '_packageinfo.txt'
    end

    return checkFileUrl
end

function UpdateModel:_dealwithNewMD5(response)
    local json = cc.load('json').json
    local checkObj = json.decode(response)

    -- write file
    if checkObj then
        checkObj.version = BusinessUtils:getInstance():getAppVersion()
        io.writefile(self._md5FilePath, json.encode(checkObj))
        self.MD5 = checkObj.md5
    end
end

function UpdateModel:checkLocalVersion(version)
    return version == BusinessUtils:getInstance():getAppVersion()
end

function UpdateModel:deleteCheckFile()
    cc.FileUtils:getInstance():removeFile(self._md5FilePath)
end

return UpdateModel