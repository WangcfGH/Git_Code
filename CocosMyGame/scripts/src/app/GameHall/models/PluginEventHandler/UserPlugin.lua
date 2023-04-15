local UserPlugin = class("UserPlugin")

function UserPlugin:ctor()
    self._registHandlerList     = {}
    self._backGroundEventTrail  = {}
    self._userActionResultArray = self:_getUserActionResultArray()
    self._userPlugin = plugin.AgentManager:getInstance():getUserPlugin()
    self._userPlugin:setCallback(handler(self, self.onUserPluginCallback))
    self:_setBackgroundCallback()
    self:_setForegroundCallback()
end

function UserPlugin:getInstance()
    UserPlugin._instance = UserPlugin._instance or UserPlugin:create()
    return UserPlugin._instance
end

function UserPlugin:configDeveloperInfo(table)
    return self._userPlugin:configDeveloperInfo(table)
end

function UserPlugin:setLoginWithDialog(bShowDialog)
    self._bShowDialog = bShowDialog
end

function UserPlugin:login()
    local bShowDialog       = self._bShowDialog or false 
    local bUserWechatLogin  = isRoomCardSupported()

    local through_data = string.format("{\"SilentLoginDialog\":%s, \"IsUseWechatLogin\":%s}", tostring(bShowDialog), tostring(bUserWechatLogin))

    local userID = self:getUserID()
    local gameID = my.getGameID()
    if userID and gameID and type(userID) == "string" and type(gameID) == "number" then
        local promoteCodeCache = CacheModel:getCacheByKey("PromoteCode_"..userID.."_"..gameID)
        if type(promoteCodeCache) == "number" then
            through_data = string.format("{\"SilentLoginDialog\":%s, \"IsUseWechatLogin\":%s, \"PromoteCode\":\"%s\"}", tostring(bShowDialog), tostring(bUserWechatLogin), tostring(promoteCodeCache))
        end
    end    

    return self._userPlugin:userLogin(my.getGameID(), through_data)
end

function UserPlugin:isLoggedIn()
    return self._userPlugin:isLoggedIn()
end

function UserPlugin:getUserID()
    return self._userPlugin:getUserID()
end

function UserPlugin:getUserSex()
    return self._userPlugin:getUserSex()
end

function UserPlugin:getUserName()
    return self._userPlugin:getUserName()
end

function UserPlugin:getPassword()
    return self._userPlugin:getPassword()
end

function UserPlugin:moreGame()
    return self._userPlugin:moreGame()
end

function UserPlugin:exit()
    return self._userPlugin:exit()
end

function UserPlugin:accountSwitch()
    return self._userPlugin:userAccountSwitch(my.getGameID(), GetLoginExtra())
end

function UserPlugin:enterPlatform()
    return self._userPlugin:enterPlatform()
end

function UserPlugin:getUsingSDKName()
    return self._userPlugin:getUsingSDKName()
end

function UserPlugin:modifyUserSex()
    return self._userPlugin:modifyUserSex()
end

function UserPlugin:modifyPassword()
    return self._userPlugin:modifyPassword()
end

function UserPlugin:bindunbingPhone()
    return self._userPlugin:bindunbingPhone()
end

function UserPlugin:getMobile()
    return self._userPlugin:getMobile()
end

function UserPlugin:isMusicEnabled()
    return self._userPlugin:isMusicEnabled()
end

function UserPlugin:realNameRegister()
    return self._userPlugin:realNameRegister()
end

function UserPlugin:antiAddictionQuery()
    return self._userPlugin:antiAddictionQuery()
end

function UserPlugin:modifyUserName()
    return self._userPlugin:modifyUserName()
end

function UserPlugin:getAccessToken()
    return self._userPlugin:getAccessToken()
end

function UserPlugin:isForbidTcyUser()
    return self._userPlugin:isForbidTcyUser()
end

function UserPlugin:isFunctionSupported(functionName)
    return self._userPlugin:isFunctionSupported(functionName)
end

function UserPlugin:setCallback( ... )
    return self._userPlugin:setCallback( ... )
end

function UserPlugin:isBindMobile()
    return self._userPlugin:isBindMobile()
end

function UserPlugin:isOpenMobileLogon()
    if type(self._userPlugin.isOpenMobileLogon) == 'function' then
        return self._userPlugin:isOpenMobileLogon()
    end

    return false
end

function UserPlugin:getAuthInfo()
    return self._userPlugin:getAuthInfo()
end

function UserPlugin:verifyThirdInfo(platformName, callback)
    print("UserPlugin:verifyThirdInfo")
    -- platformName: "weixin", "QQ"
    -- info{usertype, userid, nickname, headurl, sex}
    -- info.usertype == 'QQ'
    -- info.userid - 第三方用户ID
    return self._userPlugin:verifyThirdInfo(platformName, callback)
end

function UserPlugin:queryThirdAccountBindStatus(platformName, callback)
    print("UserPlugin:queryThirdAccountBindStatus")
    return self._userPlugin:queryThirdAccountBindState(platformName, function( code, msg )
        print(code, msg)
        callback(code, msg)
    end)
end

function UserPlugin:queryThirdInfo( platformName, callback)
    print("UserPlugin:queryThirdInfo")
    return self._userPlugin:queryThirdInfo(platformName, function(code, msg, info)
        callback(code, msg, info)
    end)
end

function UserPlugin:getThirdUserAccount( platformName, callback)
    if not self._userPlugin.getThirdUserAccount then return end
    print("UserPlugin:getThirdUserAccount")
    return self._userPlugin:getThirdUserAccount(platformName, function(code, msg, info)
        callback(code, msg, info)
    end)
end

function UserPlugin:getThirdAppId( platformName)
    if not self._userPlugin.getThirdAppId then return end
    print("UserPlugin:getThirdAppId")
    return self._userPlugin:getThirdAppId(platformName)
end

function UserPlugin:registCallbackEventByTag(code, handler, tag)
    assert(type(tag) == 'string', 'please use type \'string\' for tag')
    self._registHandlerList[code] = self._registHandlerList[code] or {}
    self._registHandlerList[code][tag] = handler
end

function UserPlugin:removeCallbackEventByTag(code, tag)
    if not self._registHandlerList[code] then return end
    self._registHandlerList[code][tag] = nil
end

function UserPlugin:registCallbackEvent(code, handler)
    self._registHandlerList[code] = self._registHandlerList[code] or {}
    table.insert(self._registHandlerList[code], handler)
end

function UserPlugin:onUserPluginCallback(code, msg)
    printLog('UserPlugin', 'onUserPluginCallback, code:%s, means:%s, msg:%s', tostring(code), self._userActionResultArray[code], tostring(msg))

    if self._bBackGroud then
        table.insert(self._backGroundEventTrail, {code = code, msg = msg})
    else
        self:handlerCallbackList(code, msg)
    end
end

function UserPlugin:handlerCallbackList(code, msg)
    print(self._registHandlerList[code], type(self._registHandlerList[code]))
    if type(self._registHandlerList[code]) ~= 'table' then return end
    for _, handler in pairs(self._registHandlerList[code]) do 
        if type(handler) == 'function' then
            handler(code, msg)
        else
            printLog('UserPlugin', 'handlerCallbackList, inproper handler type:%s', tostring(type(handler)))
        end
    end
end

function UserPlugin:_getUserActionResultArray()
    local array = {}
    for key, value in pairs(UserActionResultCode) do 
        array[value] = key 
    end
    return array
end

function UserPlugin:_setForegroundCallback()
    local callback = function(...)
        self:_onResume(...)
    end
    AppUtils:getInstance():removeResumeCallback("UserPlugin_setForegroundCallback")
    AppUtils:getInstance():addResumeCallback(callback, "UserPlugin_setForegroundCallback")
end

function UserPlugin:_setBackgroundCallback()
    local callback = function(...)
        self:_onPause(...)
    end
    AppUtils:getInstance():removePauseCallback("UserPlugin_setBackgroundCallback")
    AppUtils:getInstance():addPauseCallback(callback, "UserPlugin_setBackgroundCallback")
end

function UserPlugin:_onPause()
    self._bBackGroud = true
end

function UserPlugin:_onResume()
    self._bBackGroud = false
    local schedueID
    schedueID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(schedueID)
        for _, event in pairs(self._backGroundEventTrail) do
            self:handlerCallbackList(event.code, event.msg)
            self._backGroundEventTrail = {}
        end
    end, 0.1, false)
end

function UserPlugin:bindThirdAccount(...)
    return self._userPlugin:bindThirdAccount(...)
end

--统一一个微信绑定的接口
function UserPlugin:bindThirdAccountForWeixinType(callback)
    return self._userPlugin:bindThirdAccount('weixin', function(success, msg)
        my.scheduleOnce(function()
            if success then
                my.informPluginByName({pluginName = 'TipPlugin', params = {tipString = "绑定成功", removeTime = 1}})
                mymodel('hallext.PlayerModel'):getInstance():getWechatInfo()
            else
                my.informPluginByName({pluginName = 'TipPlugin', params = {tipString = msg, removeTime = 1}})
            end
            --邀请有礼微信绑定相关处理
            local inviteGiftModel = require('src.app.plugins.invitegift.InviteGiftModel'):getInstance()
            inviteGiftModel:bindThirdAccountCallback(success, msg)
            if type(calback) == "function" then
                calback(success, msg)
            end
        end, 0.5)
    end)
end

function UserPlugin:getAccessTokenByGameID(...)
    return self._userPlugin:getAccessTokenByGameID(...)
end

function UserPlugin:resetCallback()
    self._userPlugin:setCallback(handler(self, self.onUserPluginCallback))
end

cc.exports.UserPlugin = UserPlugin:getInstance()

return UserPlugin
