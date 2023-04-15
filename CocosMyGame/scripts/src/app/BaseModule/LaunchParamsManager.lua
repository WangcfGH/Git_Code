
-- 不能在此时引用hallconst 否则会热更新失效

local launchParams, content
if device.platform == "windows" then
    launchParams = {
        type        = 1,--LaunchType.kLaunchTypeEnter,
        subtype     = 4,--LaunchSubType.kLaunchSubTypeYQW,
        destination = 3,--LaunchDestination.kLaunchDestinationGameTable,
        source      = 1,--LaunchSource.kLaunchSourceTcyApp,
        extra       = "",--YQW.getStringFromFile("content.json"),
        content     = "http://i.ct108.net/v3.html?c=811476/10000004//62" --cc.FileUtils:getInstance():getStringFromFile("src/app/content.json")
    }
else
    launchParams = BusinessUtils:getInstance():getLaunchParamInfo()
    BusinessUtils:getInstance():cleanLaunchParam()
end
dump(launchParams)

local launchParamsManager = { }
cc.exports.launchParamsManager = launchParamsManager

local function _isTCYApp()
    return cc.exports.LaunchMode["PLATFORM"] == MCAgent:getInstance():getLaunchMode()
end

local function _checkLaunchParamsLoaded()
    if launchParams then return end
    launchParams = BusinessUtils:getInstance():getLaunchParamInfo()
    BusinessUtils:getInstance():cleanLaunchParam()
end

function launchParamsManager:getContent()
    print("launchParamsManager:getContent")
    _checkLaunchParamsLoaded()
    if (not launchParams) or type(launchParams.content) ~= 'string' or launchParams.content == '' then return end
    if content then return content end
    local buffer
    if string.sub(launchParams.content, 1, 3) == '%7B' then
        -- 判断是否是url编码
        buffer = string.urldecode(launchParams.content)
    else
        buffer = launchParams.content
    end

    if not string.find(buffer, "{") then
        return
    end
    content = string.len(buffer) > 0 and json.decode(buffer) or ""
    return content
end

function launchParamsManager:getContentSource()
    print("launchParamsManager:getContentSource")
    _checkLaunchParamsLoaded()
    if (not launchParams) or type(launchParams.content) ~= 'string' or launchParams.content == '' then return end
    
    dump(launchParams.content)
    return launchParams.content
end

function launchParamsManager:initListeners()
    BusinessUtils:getInstance():setMlinkListener(_onLinkEnterForeGround)
    BusinessUtils:getInstance():setPlatformListener(_onLinkEnterForeGround)

    AppUtils:getInstance():removeResumeCallback("WordCmd_ForegroundCallback")
    AppUtils:getInstance():addResumeCallback(_onForegroundCallback, "WordCmd_ForegroundCallback")
end

local function _onLinkEnterForeGround(code, msg, extra)
    printLog("onLinkEnterForGround", "code:%s, msg:%s, extra:%s", tostring(code), tostring(msg), tostring(extra))
    my.scheduleOnce(function()
        if code == TcyNotification.kTcyNotificationShared
        or code == MlinkNotification.kMlinkNotificationShared then
            BusinessUtils:getInstance():cleanLaunchParam()
            local centerCtrl = require('src.app.BaseModule.CenterCtrl'):getInstance()
            launchParams = {content = extra}
            if centerCtrl:checkNetStatus() then
                launchParamsManager:checkLaunchParams(true)
            end
        end
    end, 0.2)
end

local function _onForegroundCallback()
    print("====>>>>_onForegroundCallback")
    my.scheduleOnce(function()
        local netProcess = import('src.app.BaseModule.NetProcess'):getInstance()
        if netProcess:isNetStatusFinished() then
            launchParamsManager:checkWordCmd()
        end
    end, 0.3)
end

function launchParamsManager:checkLaunchParams(isLinkEnterForeGround)
    _checkLaunchParamsLoaded()
    local content = self:getContent()
    if my.isInGame() then
        
    elseif self:isInvitedToTeam2V2() then
        my.informPluginByName({pluginName = "ToastPlugin", params = {tipString = json.encode(content), removeTime = 3}})
    elseif self:isInvitedGiftFromLink() then
        local inviteGiftModel   = require('src.app.plugins.invitegift.InviteGiftModel'):getInstance()
        inviteGiftModel:enterGameFromInviteGiftLink(isLinkEnterForeGround)
    end
    launchParamsManager:clearLauchParams()
end

function launchParamsManager:clearLauchParams()
    launchParams    = nil
    content         = nil
end

-- 是否是组队邀请
function launchParamsManager:isInvitedToTeam2V2()
    _checkLaunchParamsLoaded()
    if (not launchParams) or (not launchParams.content) then return false end
    content = self:getContent()
    local Team2V2Model = import('src.app.plugins.Team2V2Model.Team2V2Model'):getInstance()
    return Team2V2Model:isTeam2V2InviteContent(content)
end

--邀请有礼链接进入
function launchParamsManager:isInvitedGiftFromLink()
    _checkLaunchParamsLoaded()
    if (not launchParams) or (not launchParams.content) then return false end
    content = self:getContent()
    if  content
    and content.abbr == BusinessUtils:getInstance():getAbbr()   --游戏缩写正确
    and content.t    == YQWShareType.YQWShareType_InviteGift    --分享类型是邀请有礼
    then
        return true
    end
end

return launchParamsManager