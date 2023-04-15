local UserModel=class('UserModel', import('src.app.GameHall.models.BaseModel'), PlayerRequestHelper:getElementIndexMetaTable())
--当对UserModel进行索引ElementIndexMetaTable中的元素时，会触发对应的请求，获取对应的数据

my.addInstance(UserModel)

function UserModel:ctor(parameters)
    UserModel.super.ctor(self)
    my.forbidKey(self, {"nReserved"})


    local FLAG_LOGON_SIMULATOR=0x00000020
    local FLAG_LOGON_INTER=0x00001000
    local FLAG_LOGON_USERSDK=0x00008000
    local FLAG_LOGON_HANDPHONE=0x00000800
    self.dwLogonFlags    =    0

    if(device.platform=='windows')then
        self.dwLogonFlags=FLAG_LOGON_SIMULATOR

       if (DEBUG > 0) then
           self.dwLogonFlags=bit.bor(self.dwLogonFlags,FLAG_LOGON_INTER)
       end

    else
        self.dwLogonFlags=FLAG_LOGON_HANDPHONE
    end

    self.dwLogonFlags=bit.bor(self.dwLogonFlags,FLAG_LOGON_USERSDK)

end

function UserModel:ReadUserInfo()

    local userPlugin = cc.exports.UserPlugin--require('src.app.GameHall.models.PluginEventHandler.UserPlugin'):getInstance()
    --if not userPlugin:isLoggedIn() then return end

    printf("userName:%s", userPlugin:getUserName())
    printf("password:%s", userPlugin:getPassword())

    local utf8name = userPlugin:getUserName()
    local psw=userPlugin:getPassword()

    self:setUserUtf8Name(utf8name)
    psw=MCCharset:getInstance():utf82GbString(psw, string.len(psw))
    self.szPassword    =    psw
    --self.nUserID       =    tonumber(userPlugin:getUserID())

end

function UserModel:setUserName(gbname)
    self.szUsername    =    gbname
    local utf8name = MCCharset:getInstance():gb2Utf8String(gbname, string.len(gbname))
    self.szUtf8Username    =    utf8name
end

function UserModel:setUserNameRaw(gbname)
    self.szUsernameRaw = gbname
    local utf8name = MCCharset:getInstance():gb2Utf8String(gbname, string.len(gbname))
    self.szUtf8UsernameRaw = utf8name
end

function UserModel:setUserUtf8Name(utf8name)
    self.szUtf8Username    =    utf8name
    local gbname = MCCharset:getInstance():utf82GbString(utf8name, string.len(utf8name))
    self.szUsername    =    gbname
end

function UserModel:acountUserUtf8Name()
    local gbname=self.szUtf8Username
    if gbname == nil  then
        return ""
    end
	local utf8name = MCCharset:getInstance():gb2Utf8String(gbname, string.len(gbname))
	return utf8name
end

local default

function UserModel:resetUserData()
    for k,v in pairs(self) do
        self[k]=default[k]
    end
end

function UserModel:isRoomHost()
    return self.nUserID == self.hostID
end

function UserModel:setUserSex(sex)
    self.nNickSex = sex
end

function UserModel:setUserPassword(password)
    self.szPassword = password
end

function UserModel:setWechatBindStatus(status)
    self.bWechatBinded = status
end

function UserModel:isWechatBinded()
    if self.bWechatBinded then return true end
    return false
end

function UserModel:setWechatInfo(info)
    -- info{usertype, userid, nickname, headurl, sex}
    self.wechatInfo = info
end

function UserModel:getWechatInfo()
    return self.wechatInfo
end

function UserModel:getPortraitPath()
    return self.portraitPath
end

function UserModel:setPortraitPath(portraitPath)
    print("UserModel:setPortraitPath", portraitPath)
    self.portraitPath = portraitPath
end

function UserModel:getPortraitStatus()
    return self.portraitStatus
end

function UserModel:setPortraitStatus(portraitStatus)
    self.portraitStatus = portraitStatus
end

function UserModel:setPlayerYQWInfo(yqwInfo)
    self.yqwInfo = yqwInfo
end

function UserModel:getPlayerYQWInfo()
    return self.yqwInfo
end

function UserModel:isAgentAccount()
    return checkbool(self.bAgent) or checkbool(self.bSubAgent)
end

function UserModel:setAgentAccount(bAgent)
    self.bAgent = checkbool(bAgent)
end

function UserModel:setSubAgentAccount(bAgent)
    self.bSubAgent = checkbool(bAgent)
end

function UserModel:setUserMemberInfo(dataMap)
    local USER_TYPE_MEMBER = 1
    local today = tonumber(os.date('%Y%m%d',os.time()))
    if bit.band(dataMap.nMemberType, USER_TYPE_MEMBER) == USER_TYPE_MEMBER 
        and tonumber(dataMap.nMemberBegin) <= today
        and tonumber(dataMap.nMemberEnd) >= today then

        self.isMember = true
        local nYearEnd = toint(dataMap.nMemberEnd / 10000)
        local nMonthEnd = toint((dataMap.nMemberEnd - nYearEnd * 10000) / 100)
        local nDayEnd = (dataMap.nMemberEnd - nYearEnd * 10000 - nMonthEnd * 100)
        self.memberInfo = {
            endline = {
                nYearEnd    = nYearEnd,
                nMonthEnd   = nMonthEnd,
                nDayEnd     = nDayEnd,
            }
        }

        local nDate = tonumber(dataMap.nMemberEnd)
        --告诉chunksvr更新特权礼包用
        local NobilityPrivilegeGiftModel      = import("src.app.plugins.NobilityPrivilegeGift.NobilityPrivilegeGiftModel"):getInstance()
        NobilityPrivilegeGiftModel:gc_GetNobilityPrivilegeGiftInfo(nDate)
    else
        self.isMember = false
    end
end




--自定义功能
--获得保险箱银两（ios单包为后备箱银两）
function UserModel:getSafeboxDeposit()
    local safeboxDeposit = self.nSafeboxDeposit or 0
    if cc.exports.isBackBoxSupported() then
        safeboxDeposit = self.nBackDeposit or 0
    end

    return safeboxDeposit
end

function UserModel:saveMyGameDataXml(gameData)
    local userId = self.nUserID or -1
    print("UserModel:saveMyGameDataXml, userid "..tostring(userId))
    my.saveCache("MyGameData"..userId..".xml", gameData)
end

function UserModel:getMyGameDataXml()
    local userId = self.nUserID or -1
    print("UserModel:getMyGameDataXml, userid "..tostring(userId))
    return my.readCache("MyGameData"..userId..".xml")
end

--0：boy；1:girl
function UserModel:getSexName()
    print("UserModel:getSexName")
    local sexName = "girl"
    if self.nNickSex == 0 or self.nNickSex == false then
        sexName = "boy"
    else
        sexName = "girl"
    end

    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if targetPlatform == cc.PLATFORM_OS_WINDOWS then 
    else
        local userPlugin = plugin.AgentManager:getInstance():getUserPlugin()
        local pluginSex = userPlugin:getUserSex()
        print("pluginSex "..tostring(pluginSex))
        if pluginSex == 0 or pluginSex == false then
            sexName = "boy"
        else
            sexName = "girl"
        end
    end
    print("sexName "..tostring(sexName))
    return sexName
end

--转换性别（如果是自己，则使用大厅性别，以保持和大厅一致）
function UserModel:getNickSexWithCheckSelf(userId, nickSex)
    if userId and userId > 0 and userId == self.nUserID then
        if self:getSexName() == "girl" then
            if type(nickSex) == "boolean" then
                return true
            else
                return 1
            end
        else
            if type(nickSex) == "boolean" then
                return false
            else
                return 0
            end
        end
    else
        return nickSex
    end
end

function UserModel:getSelfDisplayName()
    local nickName = NickNameInterface.getNickName()
    local displayName = nickName or UserModel.szUtf8Username

    --displayName = "发了多杀接发神经大佛阿斯加德欧艾斯" --测试代码

    return displayName
end

function UserModel:getDisplayNameWithCheckSelf(userId, userName)
    if userId and userId > 0 and userId == self.nUserID then
        return self:getSelfDisplayName()
    end
    return userName
end

default=UserModel:create()
default.szUtf8Username=''
default.szUsername=''
default.szPassword=''

return UserModel
