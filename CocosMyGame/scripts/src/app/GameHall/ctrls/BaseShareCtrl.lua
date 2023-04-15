local configPath        = "src/app/HallConfig/ShareConfig.json"
local config            = json.decode(cc.FileUtils:getInstance():getStringFromFile(configPath))  --放在文件级变量是因为json.decode 效率较低，为了不重复读取放在文件级变量
local shareImgCache     = {}    --分享图片的缓存，之所以不用isFileExist是考虑到更新之后图片变更，但是名字没有变化的情况

local BaseShareCtrl     = class('BaseShareCtrl',cc.load('BaseCtrl'))

function BaseShareCtrl:onCreate(params)
end

function BaseShareCtrl:getShareConfig()
    return config
end

function BaseShareCtrl:getShareContent(shareTo)
    local configInfo = config[shareTo]
    local content = clone(configInfo)
    local randArray = content["randArray"]
    if type(randArray) == "table" then
        local randInfo = randArray[math.random(1, #randArray)]
        table.merge(content, randInfo)
    end

    if content["image"] then
        local sharePath = self:loadShareImg(content["image"], content["bRefresh"])
        content["image"] = sharePath
        content["imagePath"] = sharePath
    end
    content["type"] = tostring(cc.exports.C2DXContentType[content["type"]])
    content["randArray"] = nil
    return content
end

function BaseShareCtrl:loadShareImg(imageName, bRefresh)
    if (not shareImgCache[imageName]) or bRefresh then
        local targetPath    = BusinessUtils:getInstance():getUpdateDirectory() .. imageName
        local defaultPath   = config["DefaulteImagePath"]
        local imgStream     = cc.FileUtils:getInstance():getStringFromFile(defaultPath..imageName)
        local file          = io.open(targetPath,"wb+")
        file:write(imgStream)
        file:close()
        shareImgCache[imageName] = targetPath
    end
    return shareImgCache[imageName]
end

--[Comment]
--platType目前只支持微信好友和微信朋友圈
--cc.exports.C2DXPlatType.C2DXPlatTypeWeixiSession      微信好友
--cc.exports.C2DXPlatType.C2DXPlatTypeWeixiTimeline     朋友圈
function BaseShareCtrl:share(shareInfo, platType)
    if not self:checkShareEnabled(shareInfo) then
        return 
    end

    self:showTip(config["TIP_SHARE_ING"])
    self:lockShare()
    local sharePlugin = plugin.AgentManager:getInstance():getSharePlugin()
    sharePlugin:setCallback(handler(self, self.onShareCallback))
    local isSSo = true --是否支持 ANDROID SINGLE SIGN-ON
    self:configDeveloperInfo()
    sharePlugin:share(platType, isSSo, shareInfo)
end

function BaseShareCtrl:configDeveloperInfo()
    local sharePlugin = plugin.AgentManager:getInstance():getSharePlugin()
    if sharePlugin then
        sharePlugin:configDeveloperInfo({})
    end
end

function BaseShareCtrl:onShareCallback(code, msg)
    print("onShareCallback, code:", code, "msg:", msg)
    --防止切回来黑块出现
    my.scheduleOnce(function()
        print("onShareCallback scheduleOnce, code:", code, "msg:", msg)
        if code == cc.exports.ShareResultCode.kShareSuccess then
            self:showTip(config["TIP_SHARE_SUCCESS"])
            self:onShareSuccess()
        else
            self:showTip(config["TIP_SHARE_FAILED"])
        end
    end, 0.1)
    self:unlockShare()
end

function BaseShareCtrl:showTip(format, sec, ...)
    self:informPluginByName("TipPlugin", {
        tipString = string.format(format, ...),
        removeTime = sec or 1.5
    })
end

function BaseShareCtrl:checkShareEnabled(shareInfo)
    if not DeviceUtils:getInstance():isAppInstalled("com.tencent.mm") then
        self:showTip(config["TIP_WECHATE_NOTINSTALLED"])
        return false
    end

    if not plugin.AgentManager:getInstance():getSharePlugin() then
        self:showTip(config["TIP_FUNCTION_NOTSUPPORT"])
        return false
    end

    if self._shareLocked then
        return false
    end

    if shareInfo.image and (not cc.FileUtils:getInstance():isFileExist(shareInfo.image)) then
        self:showTip(config["TIP_IMAGE_NOTEXIST"])
        return false
    end

    return true
end

function BaseShareCtrl:lockShare()
    self._shareLocked  = true
    self._shareTimerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
        self:unlockShare()
    end, 3, false)
end

function BaseShareCtrl:unlockShare()
    if self._shareTimerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._shareTimerID)
        self._shareTimerID = nil
        self._shareLocked  = false
    end
end

--[Comment]
function BaseShareCtrl:onShareSuccess()
    local taskModel = import('src.app.plugins.taskctrl.TaskModel'):getInstance()
    taskModel:reqChangeLTaskParamForShareType()
end

--cc.register(BaseShareCtrl, 'BaseShareCtrl')

return BaseShareCtrl