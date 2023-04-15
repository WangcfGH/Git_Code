--[[update event
    update finish
    EVENT_UPDATE_NEEDLESS
    EVENT_UPDATE_OK
    EVENT_UPDATE_CANCEL
    EVENT_UPDATE_FAILED

    EVENT_UPDATE_ANIMATIONOVER
    EVENT_UPDATE_ENTERSCENE
]]

local UpdateCtrl = class('UpdateCtrl', require('src.app.BaseModule.ViewCtrl'))

require('src.app.TcyCommon.MCConst')

UpdateCtrl.UPDATECONFIG_PATH = 'src/app/HallConfig/UpdateConfig.json'
local NETWORKCHANGE_TIMEOUT = 3
local NOTIFY_TCYAPPUPDATE = false -- temp flag to fix tcyapp 'crash' problem.

function UpdateCtrl:ctor()
    self:onCreate()
end

function UpdateCtrl:onCreate()
    self._callback = { }
    --    setmetatable(self._callback, { __mode = 'v' })

    self:_initConfig()
    self:_initModel()
end

function UpdateCtrl:_initConfig()
    local json = cc.load('json').json
    local updateJson    = MCFileUtils:getInstance():getStringFromFile(self.UPDATECONFIG_PATH)
    local updateObj     = json.decode(updateJson)
    self._updateString  = updateObj.UpdateString
    self._sceneConfig   = updateObj.UpdateSceneConfig
    self._updateConfig  = updateObj.UpdateConfig
    self.REQUIRETABLE   = updateObj.RequireFile
    local additionConfig = json.decode(cc.FileUtils:getInstance():getStringFromFile("res/hall/hallstrings/AdditionConfig.json"))
    self._copyRightConfig = additionConfig and additionConfig['data'] and additionConfig['data']['functions'] and additionConfig['data']['functions']['copyright']
end

function UpdateCtrl:_initModel()
    require('src.app.update.UpdateUtils')

    self._model = require(self.REQUIRETABLE.MODEL):create(self._updateConfig)
    self._model:setResultCallback(handler(self, self._resultCallback))
end

function UpdateCtrl:_registNetworkInfoCallback()
    printLog(self.__cname, '_registNetworkInfoCallback')
    DeviceUtils:getInstance():setGameNetworkInfoCallback(handler(self, self._onNetworkChange))
end

function UpdateCtrl:_unregistNetworkInfoCallback()
    printLog(self.__cname, '_unregistNetworkInfoCallback')
    DeviceUtils:getInstance():setGameNetworkInfoCallback(nil)
end

function UpdateCtrl:showUpdateScene()
    self._updateScene = require(self.REQUIRETABLE.UPDATESCENE):create(self)
    self._checkScene = nil
    self:_showCopyRightText()

    local transition = self._sceneConfig.UpdateTransition
    if UpdateUtils.checkString(transition) then
        local transitionTime = self._sceneConfig.UpdateTransitionTime
        transitionTime = transitionTime > 0 and transitionTime or 1
        self:showAsScene(self._updateScene, transition, transitionTime)
    else
        self:showAsScene(self._updateScene)
    end
end

function UpdateCtrl:startUpdateWithScene()
    self._downloadDirectly = true
    if not self._checkScene then
        self._checkScene = require(self.REQUIRETABLE.CHECKSCENE):create(self)
    end
    self:_dispatchUpdateEvent('EVENT_UPDATE_ENTERSCENE')

    self:showAsScene(self._checkScene)

    local copyRightStayTime = self._copyRightConfig and self._copyRightConfig.time
    if type(copyRightStayTime) ~= 'number' or copyRightStayTime <= 0 then
        copyRightStayTime = 2 -- deafult
    end
    UpdateUtils.unschedule(self._animationTimerID)
    self._animationTimerID = UpdateUtils.scheduleOnce(function()
        self._animationTimerID = nil
        self:_onCheckUpdateAnimationOver()
    end, self._sceneConfig.CheckUpdateStay > copyRightStayTime and self._sceneConfig.CheckUpdateStay or copyRightStayTime)
end

function UpdateCtrl:startUpdate()
    -- should show tips when invoke this func.
    self._downloadDirectly = false
    self._curNetType = DeviceUtils:getInstance():getNetworkType()
    self:_registNetworkInfoCallback()

    self._model:checkUpdate()
end

function UpdateCtrl:setCallback(callback, tag)
    assert((type(callback) == 'function' or callback == nil)
    and tag ~= nil, 'UpdateCtrl:setCallback invalid params.')
    local callbackTable = self._callback
    callbackTable[tag] = callback
end

function UpdateCtrl:_dispatchUpdateEvent(event)
    for _, callback in pairs(self._callback) do
        callback(event)
    end
end

function UpdateCtrl:_updateFinished(event)
    self:_unregistNetworkInfoCallback()
    self:_showFinishedText(event)
    self:_dispatchUpdateEvent(event)
    self:clean()
end

function UpdateCtrl:_showFinishedText(event)
    local curScene = self._checkScene or self._updateScene
    if curScene and self._updateString and self._updateString.Connecting then
        curScene:setTipText(self._updateString.Connecting)
    end
end

function UpdateCtrl:_showCopyRightText()
    local curScene = self._checkScene or self._updateScene
    if curScene then
        curScene:showCopyRight(self._copyRightConfig)
    end
end

function UpdateCtrl:_showGameVersionText()
    local curScene = self._checkScene or self._updateScene
    if curScene and curScene.showGameVersion then
        curScene:showGameVersion()
    end
end

function UpdateCtrl:_resultCallback(event, result)
    if event == 'CHECKRESULT' then
        self:_dealwithCheckResult(result)
    elseif event == 'DOWNLOADOK' then
        self:_dealwithDownloadOK(result)
    elseif event == 'DOWNLOADPROGRESS' then
        self:_dealwithDownloadProgress(result)
    elseif event == 'DOWNLOADERROR' then
        self:_dealwithDownloadError(result)
    end
end

function UpdateCtrl:_setUpdateSubTitleText(result, params)
    local updateString = self._updateString

    if result.isChannelUpdate then
        if MCAgent:getInstance():getLaunchMode() == LaunchMode.PLATFORM then
            params.TextSubTitle = updateString.TCYChannelUpdate
        else
            params.TextSubTitle = updateString.ChannelUpdate
        end
    else
        -- inner update
        params.TextSubTitle = string.format(updateString.NetWorkStatus, self:_getNetworkTypeString(DeviceUtils:getInstance():getNetworkType()))
    end
end

function UpdateCtrl:_setUpdateTipsText(result, params)
    local updateString = self._updateString

    local updateString = self._updateString
    if not result.isChannelUpdate then
        local unit, size = updateString.KB, result.fileSize / _1K_
        if result.fileSize >= _1K_ then
            unit = updateString.MB
            size = size / _1K_
        end

        params.TextTips = string.format(updateString.DownloadSize, size, unit)
    end
end

function UpdateCtrl:_setUpdateButton(result, params)
    local updateString = self._updateString

    local function setCancelButton(result)
        local button = { }
        button.ButtonTitle = updateString.Cancel
        button.Callback = handler(self, self.cancel)
        button.Remove = true

        if result.isChannelUpdate then
            if not UpdateUtils.checkString(result.packageName) and
                not UpdateUtils.checkString(result.link) then
                button = nil
            end
        end

        return button
    end

    local function setOKButton(result)
        local button = { }
        button.ButtonTitle = updateString.Update
        button.Callback = handler(self, self.update)

        if result.isChannelUpdate then
            if not UpdateUtils.checkAppExist(result.packageName) and
                not UpdateUtils.checkString(result.link) then
                if result.overlook then
                    button.ButtonTitle = updateString.Quit
                    button.Callback = handler(self, self.quit)
                else
                    button.ButtonTitle = updateString.OK
                    button.Remove = true
                end
            end
        end

        return button
    end

    local buttonTable = { }
    if not result.overlook then
        buttonTable[1] = setCancelButton(result)
    end
    buttonTable[2] = setOKButton(result)

    params.ButtonTable = buttonTable
end

function UpdateCtrl:_buildDialogParamsByCheckResult(result)
    local params, updateString = { }, self._updateString
    params.TextTitle = updateString.UpdateTitle
    self:_setUpdateSubTitleText(result, params)
    self:_setUpdateTipsText(result, params)
    self:_setUpdateButton(result, params)
    params.TextContent = result.description

    return params
end

function UpdateCtrl:_canbeDownloadDirectly(result)
    if not self._downloadDirectly then
        return false

    elseif result.updateMethod == 'UPDATE_INNER_HOT' then
        if DeviceUtils:getInstance():getNetworkType() == NetworkType.kNetworkTypeWifi then
            return true
        elseif result.fileSize <= self._sceneConfig.AutoUpdateSize * _1K_ * _1K_ and result.fileSize > 0 then
            return true
        end
    end

    return false
end

function UpdateCtrl:_checkUpdateResult(result)
    local bVaild = true
    if result.isChannelUpdate then
        -- do nothing
    else
        -- params check
        if not result.downloadUrl or string.len(result.downloadUrl) == 0 then
            bVaild = false
        elseif result.totalSize <= 0 then
            bVaild = false
        end
    end

    return bVaild
end

function UpdateCtrl:_isDownloadComplete(result)
    return result.fileSize == 0 and result.totalSize > 0
end

function UpdateCtrl:_dealwithCheckResult(result)
    self._checkResult = result

    self:_stopNetworkChangeTimer()
    printLog(self.__cname, '_dealwithCheckResult')
    if result then
        self._model:getCheckMD5(result.downloadUrl)
        if result.updateMethod == 'UPDATE_NEEDLESS' then
            self:_updateFinished('EVENT_UPDATE_NEEDLESS')
        elseif self:_checkUpdateResult(result) then
            if self:_canbeDownloadDirectly(result) then
                self:update()
            elseif self:_isDownloadComplete(result) then
                self:showUpdateScene()
            else
                self:_showUpdateDialog(result)
            end
        else
            self:_showCheckUpdateFailedTip()
        end
    else
        self:_updateFinished('EVENT_UPDATE_NEEDLESS')
    end
end

function UpdateCtrl:_dealwithDownloadOK(result)
    self:_unregistNetworkInfoCallback()
    self:_stopNetworkChangeTimer()

    local checkresult = self._checkResult
    table.merge(checkresult, result)
    local businessUtils = BusinessUtils:getInstance()

    self._updateScene:setUpdateProgress(100)
    self._updateScene:setTipText(self._updateString.CheckTips)
    if not self:_checkFile(result.storagePath) then
        cc.FileUtils:getInstance():removeFile(result.storagePath)
        self._model:deleteCheckFile()
        self:_showMD5CheckErrorTip()

    elseif checkresult.updateMethod == 'UPDATE_INNER_HOT' then
        self._updateScene:setTipText(self._updateString.DecompressTips)
        self._model:decompressFile(result.storagePath, businessUtils:getUpdateDirectory() .. BusinessUtils:getInstance():getAbbr() .. '/', true)
        self._updateScene:setTipText(self._updateString.DecompressCompleteTips)
        businessUtils:updateConfigs() -- update interface data (getAppVersion).
        self:_updateFinished('EVENT_UPDATE_OK')

    elseif checkresult.updateMethod == 'UPDATE_INNER_WHOLE' then
        self._updateScene:setTipText(self._updateString.CheckComplete)
        self._updateScene:showInstallButton(true)
        printLog(self.__cname, 'auto install apk ' .. result.storagePath)
        DeviceUtils:getInstance():startApkInstaller(result.storagePath)
    end
end

function UpdateCtrl:_onNetworkChange()
    local lastNetType = self._curNetType
    self._curNetType = DeviceUtils:getInstance():getNetworkType()

    self:_dealwithNetworkChange(lastNetType, self._curNetType)
end

function UpdateCtrl:_dealwithDownloadProgress(result)
    local percent =(result.downloaded / result.total) * 100
    self._updateScene:setUpdateProgress(percent)
    self._updateScene:setTipText(self:_createTipString(result.total, result.total - result.downloaded))

    self._downloaded = result.downloaded
end

function UpdateCtrl:_dealwithDownloadError(result)
    printLog(self.__cname, '_dealwithDownloadError')
    dump(result)

    self:_startNetworkChangeTimer()
    self._model:stopDownload()
    self._downloadStop = true
end

function UpdateCtrl:_dealwithNetworkChange(oldNetType, curNetType)
    printLog(self.__cname, '_dealwithNetworkChange: oldType is ' .. oldNetType .. ', newType is ' .. curNetType)

    if oldNetType == curNetType then
        -- do nothing
    elseif curNetType == NetworkType.kNetworkTypeDisconnection then
        self:_startNetworkChangeTimer()
    else
        self:_stopNetworkChangeTimer()

        local checkResult = self._checkResult
        if checkResult then
            -- already checked
            if checkResult.updateMethod == 'UPDATE_INNER_HOT' or checkResult.updateMethod == 'UPDATE_INNER_WHOLE' then
                -- stay in check scene
                if self._checkScene then
                    self:_modifyUpdateDialogSubTitle(curNetType)
                else
                    local leftSize =(checkResult.fileSize -(self._downloaded or 0)) / _1K_ / _1K_
                    if leftSize > self._sceneConfig.AutoUpdateSize then
                        self._model:pauseDownload()
                        self:_showWifiChangeToOtherTip(curNetType, leftSize)
                    else
                        self:_closeTipDialog()
                        self:_continueDownload()
                    end
                end

            elseif curNetType == NetworkType.kNetworkTypeWifi then
                if self._updateScene and not self._checkScene then
                    self:_closeTipDialog()
                    self:_continueDownload()
                else
                    -- in checkscene do nothing
                end
            else
                -- Do nothing
            end
        end
    end
end

function UpdateCtrl:_createTipString(totalSize, fileSize)
    local downloadSize = totalSize - fileSize
    local percent = downloadSize / totalSize * 100
    local updateString = self._updateString

    local downloadUint = updateString.KB
    downloadSize = downloadSize / _1K_
    if downloadSize > _1K_ then
        downloadSize = downloadSize / _1K_
        downloadUint = updateString.MB
    end

    local totalUnit = updateString.KB
    totalSize = totalSize / _1K_
    if totalSize > _1K_ then
        totalSize = totalSize / _1K_
        totalUnit = updateString.MB
    end

    local updateTips = self._updateString.UpdateTips
    if downloadSize == totalSize then
        updateTips = self._updateString.UpdateCompleteTips
    end

    local tipText = string.format(updateTips, downloadSize, downloadUint,
    totalSize, totalUnit, percent)
    return tipText
end

function UpdateCtrl:onSceneTransitionFinish(sceneName)
    if sceneName == 'CheckScene' then
        -- do check
        self._curNetType = DeviceUtils:getInstance():getNetworkType()
        self:_registNetworkInfoCallback()
        self._model:checkUpdate()
        self:_showCopyRightText()
        self:_showGameVersionText()

    elseif sceneName == 'UpdateScene' then
        self._updateScene:setTipText(self:_createTipString(self._checkResult.totalSize, self._checkResult.fileSize))

        local downloadSize = self._checkResult.totalSize - self._checkResult.fileSize
        local percent = downloadSize / self._checkResult.totalSize * 100
        self._updateScene:setUpdateProgress(percent)

        self._model:startDownload(self._checkResult.downloadUrl)
    end
end

function UpdateCtrl:onSceneExit(sceneName)
    if sceneName == 'CheckScene' then
        self._checkScene = nil
    elseif sceneName == 'UpdateScene' then
        self._updateScene = nil
    end
end

function UpdateCtrl:_onCheckUpdateAnimationOver()
    self:_dispatchUpdateEvent('EVENT_UPDATE_ANIMATIONOVER')
end

function UpdateCtrl:install()
    printLog(self.__cname, 'install ' .. self._checkResult.storagePath)
    DeviceUtils:getInstance():startApkInstaller(self._checkResult.storagePath)
end

function UpdateCtrl:cancel()
    self:_updateFinished('EVENT_UPDATE_CANCEL')
end

function UpdateCtrl:quit()
    printLog(self.__cname, 'quit ' .. self._checkResult.updateMethod)

    if self._checkResult.updateMethod == 'UPDATE_CHANNEL_TCYAPP' and NOTIFY_TCYAPPUPDATE then
        local businessUtils = BusinessUtils:getInstance()
        businessUtils:notifyPlatformToUpdateGame(businessUtils:getPackageName())
    end

    MCAgent:getInstance():endToLua()
end

function UpdateCtrl:update()
    local switchAction = {
        UPDATE_INNER_HOT = function()
            self:_updateInnerHot()
        end,

        UPDATE_INNER_WHOLE = function()
            self:_updateInnerWhole()
        end,

        UPDATE_CHANNEL_LINK = function()
            self:_updateChannelLink()
        end,

        UPDATE_CHANNEL_PACKAGE = function()
            self:_updateChannelPackage()
        end,

        UPDATE_CHANNEL_TCYAPP = function()
            self:_updateChannelTcyApp()
        end,

        UPDATE_CHANNEL_NONE = function()
            self:_updateFinished('EVENT_UPDATE_CANCEL')
        end,

    }

    local updateMethod = self._checkResult.updateMethod
    if switchAction[updateMethod] then
        switchAction[updateMethod]()
    end

end

function UpdateCtrl:_updateInnerHot()
    self:showUpdateScene()
end

function UpdateCtrl:_updateInnerWhole()
    self:showUpdateScene()
end

function UpdateCtrl:_updateChannelLink()
    local link = self._checkResult.link
    if UpdateUtils.checkString(link) then
        DeviceUtils:getInstance():openBrowser(link)
    end
end

function UpdateCtrl:_updateChannelPackage()
    local app = self._checkResult.packageName

    printLog(self.__cname, '_updateChannelPackage: app name is ' .. app)
    if UpdateUtils.checkAppExist(app) then
        DeviceUtils:getInstance():openApp(app)
    end
end

function UpdateCtrl:_updateChannelTcyApp()
    printLog(self.__cname, '_updateChannelTcyApp')
    if NOTIFY_TCYAPPUPDATE then
        BusinessUtils:getInstance():notifyPlatformToUpdateGame(BusinessUtils:getInstance():getPackageName())
    end
    MCAgent:getInstance():endToLua()
end

function UpdateCtrl:_showUpdateDialog(result)
    local params = self:_buildDialogParamsByCheckResult(result)
    local popDialog = require('src.app.update.PopupDialog'):create(params)
    popDialog:show()
    self._popupDialogTag = popDialog.CHAILDTAG
end

function UpdateCtrl:_showCheckUpdateFailedTip()
    local params = {
        TextTitle = self._updateString.CheckUpdateError,
        TextTips = self._updateString.CheckUpdateErrorTips
    }
    local buttonTable = {
        {
            ButtonTitle = self._updateString.CheckUpdateAbort,
            Callback = handler(self,self.enterGameWithoutNetwork),
            Remove = true
        },
        {
            ButtonTitle = self._updateString.Retry,
            Callback = handler(self,self.retry),
            Remove = true
        }
    }

    params.ButtonTable = buttonTable

    local tipDialog = require('src.app.update.TipDialog'):create(params)
    tipDialog:show(self._checkScene or self._updateScene)
end

function UpdateCtrl:_showNetworkErrorTip()
    local params = {
        TextTitle = self._updateString.UpdateError,
        TextTips = self._updateString.UpdateErrorTips
    }
    local buttonTable = {
        {
            ButtonTitle = self._updateString.Cancel,
            Callback = handler(self,self.enterGameWithoutNetwork),
            Remove = true
        },
        {
            ButtonTitle = self._updateString.Retry,
            Callback = handler(self,self.retry),
            Remove = true
        }
    }
    params.ButtonTable = buttonTable

    local tipDialog = require('src.app.update.TipDialog'):create(params)
    tipDialog:show(self._checkScene or self._updateScene)
end

function UpdateCtrl:_showMD5CheckErrorTip()
    local params = {
        TextTitle = self._updateString.PackageError,
        TextTips = self._updateString.PackageErrorTips,
        ButtonTable =
        {
            [2] =
            {
                ButtonTitle = self._updateString.OK,
                Callback = function()
                    self:_updateFinished('EVENT_UPDATE_FAILED')
                end,
                Remove = true
            }
        }
    }

    local tipDialog = require('src.app.update.TipDialog'):create(params)
    tipDialog:show(self._checkScene or self._updateScene)
end

function UpdateCtrl:enterGameWithoutNetwork()
    self._curNetType = DeviceUtils:getInstance():getNetworkType()
--    if self._curNetType == NetworkType.kNetworkTypeDisconnection then
        self:_updateFinished('EVENT_UPDATE_CANCEL')
--    else
        -- retry
--        self:startUpdateWithScene()
--    end
end

function UpdateCtrl:retry()
    UpdateUtils.scheduleOnce(function()
        self:startUpdateWithScene()
    end, 0.5)
end

function UpdateCtrl:_showWifiChangeToOtherTip(curNetType, leftSize)
    local params = {
        TextTitle = self._updateString.UpdateBreak,
        TextTips = string.format(self._updateString.UpdateContinueTip,self:_getNetworkTypeString(curNetType),leftSize),
        ButtonTable =
        {
            [2] =
            {
                ButtonTitle = self._updateString.OK,
                Callback = handler(self,self._continueDownload),
                Remove = true
            }
        }
    }

    local tipDialog = require('src.app.update.TipDialog'):create(params)
    tipDialog:show(self._checkScene or self._updateScene)
end

function UpdateCtrl:_closeTipDialog()
    local tag = require('src.app.update.TipDialog').CHAILDTAG
    local tipDialog = cc.Director:getInstance():getRunningScene():getChildByTag(tag)
    if tipDialog then
        tipDialog:removeFromParent()
    end
end

function UpdateCtrl:_continueDownload()
    if self._downloadStop then
        self._downloadStop = false
        self._model:startDownload(self._checkResult.downloadUrl)
        printLog(self.__cname, '_continueDownload: restart download.')
    else
        self._model:resumeDownload()
        printLog(self.__cname, '_continueDownload: resume download.')
    end
end

function UpdateCtrl:_modifyUpdateDialogSubTitle(curNetType)
    if not self._popupDialogTag then
        return
    end

    local popupDialog = cc.Director:getInstance():getRunningScene():getChildByTag(self._popupDialogTag)
    if popupDialog then
        local subTitle = string.format(self._updateString.NetWorkStatus, self:_getNetworkTypeString(curNetType))
        popupDialog:setSubTitle(subTitle)
    end
end

function UpdateCtrl:_getNetworkTypeString(networkType)
    local updateString = self._updateString

    local networkStringTable = {
        [NetworkType.kNetworkTypeDisconnection] = updateString.Disconnection,
        [NetworkType.kNetworkType2G] = updateString.StringPhone,
        [NetworkType.kNetworkType3G] = updateString.StringPhone,
        [NetworkType.kNetworkTypeWifi] = updateString.Wifi,
        [NetworkType.kNetworkType4G] = updateString.StringPhone,
        [NetworkType.kNetworkTypeUnknown] = updateString.Unknow
    }
    return networkStringTable[networkType] or ''
end

function UpdateCtrl:_checkFile(path)
    local checkMD5 = self._model.MD5

    local data = io.readfile(path)
--    if checkMD5 and data then
--        local md5 = MCCrypto:md5(data, data:len())
--        return string.lower(md5) == string.lower(checkMD5)
--    end

    if checkMD5 and data then
        local md5 = MCCrypto:md5File(path)
        return string.lower(md5) == string.lower(checkMD5)
    end

    -- if md5 is not exist, do not check.
    return true
end

function UpdateCtrl:clean()
    self:_stopNetworkChangeTimer()

    self._checkResult = nil
    self._checkScene = nil
    self._updateScene = nil
end

function UpdateCtrl:_startNetworkChangeTimer()
    if self._networkChangeTimer then
        return
    end

    self._networkChangeTimer = UpdateUtils.scheduleOnce( function()
        printLog(self.__cname, 'network change timeout.')
        self:_showNetworkErrorTip()
        self._networkChangeTimer = nil
    end , NETWORKCHANGE_TIMEOUT)
end

function UpdateCtrl:_stopNetworkChangeTimer()
    if self._networkChangeTimer then
        UpdateUtils.unschedule(self._networkChangeTimer)
        self._networkChangeTimer = nil
    end
end

return UpdateCtrl