local NetProcess    = require('src.app.BaseModule.NetProcess'):getInstance()
local UserModel     = mymodel('UserModel'):getInstance()
local AssistModel   = mymodel('assist.AssistModel'):getInstance()
local scheduler     = cc.Director:getInstance():getScheduler()

local NewInviteGiftModel = class('NewInviteGiftModel', require('src.app.GameHall.models.BaseModel'))

my.addInstance(NewInviteGiftModel)
protobuf.register_file('src/app/plugins/invitegift/Fission.pb')

NewInviteGiftModel.GR_QUERY_INVITEGIFT_CONFIG	    = 400000 + 4601
NewInviteGiftModel.GR_CHECK_USERBIND_INFO           = 400000 + 4602
NewInviteGiftModel.GR_CHECK_USERBIND_INFO_FAILED    = 400000 + 4603

NewInviteGiftModel.EVENT_OLDUSER_TRIGGER            = 'EVENT_OLDUSER_TRIGGER'
NewInviteGiftModel.EVENT_NEWUSER_TRIGGER            = 'EVENT_NEWUSER_TRIGGER'
NewInviteGiftModel.EVENT_INVITE_GIFT_PROCESS_OVER   = 'EVENT_INVITE_GIFT_PROCESS_OVER'


NewInviteGiftModel.OldUserStatus = {
    NOTDO = 0,
    CANDO = 1,
    DOING = 2
}

NewInviteGiftModel.NewUserStatus = {
    NOTBIND = 0,
    BINDING = 1,
    BINDED  = 2
}

NewInviteGiftModel.TakeRewardError = {
	REWARD_PARAM_ERROR = 1, 	--参数异常
	REWARD_CONFIG_ERROR = 2,	--配置异常
	REWARD_USER_ERROR = 3,		--玩家异常
	REWARD_BIND_ERROR = 4,		--玩家未绑定
	REWARD_PHONE_INVALID = 5,	--手机号格式异常
	REWARD_PHONE_TAKED = 6,		--手机号已领过奖励
	REWARD_TODAY_TAKED = 7,		--今天已领过奖励
	REWARD_TICKET_LESS = 8,		--话费券不满足可领条件
	REWARD_BOUT_LESS = 9,		--对局数不满足可领条件
	REWARD_BOUT_LIMIT = 10,		--对局数异常
	REWARD_DAY_INVALID = 11,		--不在领奖有效期
	REWARD_INTERFACE_ERROR =12, 	--接口错误
    REWARD_DATE_INVALID = 13,   --不是活动有效期
    REWARD_CEILING = 14,        --任务奖励达上限
    REWARD_BEYOND_TIMES = 15,	--领奖超出配置次数
    REWARD_REAPEAT = 16,		--重复领奖
    REWARD_SHARE_NOTOPEN =  17, --邀请有礼分享领奖未开启
}

function NewInviteGiftModel:onCreate()
    -- 注册回调
    self:initAssistResponse()

    AssistModel:addEventListener(AssistModel.ASSIST_CONNECT_OK, handler(self, self.onAssistConnectOK))
    NetProcess:addEventListener(NetProcess.EventEnum.NetProcessFinished, handler(self, self.onNetProcessFinished))
    self:initEvent()
end

-- 注册回调
function NewInviteGiftModel:initAssistResponse()
    self._assistResponseMap = {
        [NewInviteGiftModel.GR_CHECK_USERBIND_INFO] = handler(self, self.rspUserBindInfo),
        [NewInviteGiftModel.GR_QUERY_INVITEGIFT_CONFIG] = handler(self, self.rspConfig),
        [NewInviteGiftModel.GR_CHECK_USERBIND_INFO_FAILED] = handler(self, self.onUserBindInfoFailed),
    }

    AssistModel:registCtrl(self, self.dealAssistResponse)
end

function NewInviteGiftModel:initEvent()
    -- 切后台
    AppUtils:getInstance():addResumeCallback(handler(self, self.onResumeCallback), 'Game_SetForegroundCallback')
end

-- 获取配置信息
function NewInviteGiftModel:reqConfig()
    if not cc.exports.isGoodFriendGiftInviteGiftSupported() then return end

    AssistModel:sendData(NewInviteGiftModel.GR_QUERY_INVITEGIFT_CONFIG)
end

-- 请求用户的绑定信息
function NewInviteGiftModel:reqUserBindInfo(WXInfo, oldUserID)
    if not cc.exports.isGoodFriendGiftInviteGiftSupported() then return end

    if mymodel('NewUserGuideModel'):getInstance():isNeedGuide() then
        return
    end

    local channelID = 0
    if BusinessUtils:getInstance().getTcyChannel then
        channelID = BusinessUtils:getInstance():getTcyChannel()
    end

    local data = {
        nUserID = UserModel.nUserID,
        nOldUserID = oldUserID,
        nChannelID = channelID,
        szNickName = string.gsub(UserModel.szNickName, "%s+", ""),
        szDeviceID = string.gsub(cc.exports.getDeviceID(), "%s+", ""),
        szRegistDate = UserModel.nCreateDay .. UserModel.nCreateHour,
        szUnionID = WXInfo.unionID or nil,
        isWXLogin = WXInfo.isWXLogin,
    }

    if oldUserID then
        data.isHaveCmd = true
    else
        data.isHaveCmd = false
    end

    dump(data)

    local pbdata = protobuf.encode('tc.protobuf.fission.PB_CheckUserBindInfo', data)
    AssistModel:sendData(NewInviteGiftModel.GR_CHECK_USERBIND_INFO, pbdata)

    self._reqUserBindInfoSche = my.scheduleOnce(function()
        print("[NewInviteGiftModel:reqUserBindInfo] timeout")
        --my.informPluginByName({ pluginName = 'TipPlugin', params = { tipString = '邀请有礼配置获取超时', removeTime = 2 } })
        self:dispatchEvent({ name = NewInviteGiftModel.EVENT_INVITE_GIFT_PROCESS_OVER })
    end, 5)
end

function NewInviteGiftModel:rspConfig(rawData)
    self._invitegiftConfig = {}
    local json = cc.load("json").json
    self._invitegiftConfig = json.decode(rawData)
end

-- 回应用户的绑定信息
function NewInviteGiftModel:rspUserBindInfo(rawData)
    if self._reqUserBindInfoSche then
        scheduler:unscheduleScriptEntry(self._reqUserBindInfoSche)
    end

    local data = pb_decode('tc.protobuf.fission.PB_UserBindInfo', rawData)
    self._data = data

    if data.nOldStatus and data.nOldStatus ~= NewInviteGiftModel.OldUserStatus.NOTDO then
        -- 老玩家处理
        print("[NewInviteGiftModel:rspUserBindInfo] olduser proccess")
        self:dispatchEvent({name = NewInviteGiftModel.EVENT_OLDUSER_TRIGGER, value = data})
    elseif data.nNewStatus then
        -- 新玩家处理
        print("[NewInviteGiftModel:rspUserBindInfo] newuser proccess")
        self:dispatchEvent({name = NewInviteGiftModel.EVENT_NEWUSER_TRIGGER, value = data})
    end

    if not self:isAutoEnterGame() then
        self:dispatchEvent({name = NewInviteGiftModel.EVENT_INVITE_GIFT_PROCESS_OVER})
    end
end

-- 回应用户的绑定信息失败
function NewInviteGiftModel:onUserBindInfoFailed()
    -- 绑定关系检查失败直接进行其它游戏流程
    if self._reqUserBindInfoSche then
        scheduler:unscheduleScriptEntry(self._reqUserBindInfoSche)
    end
    print("check bind failed")
    self:dispatchEvent({name = NewInviteGiftModel.EVENT_INVITE_GIFT_PROCESS_OVER})
end

function NewInviteGiftModel:onAssistConnectOK()
    self:reqConfig()
end

function NewInviteGiftModel:onNetProcessFinished()
    -- 延迟0.5秒确保活动数据拿到
    my.scheduleOnce(function ()
        self:reqBindInfo()
    end, 0.5)
end

function NewInviteGiftModel:reqBindInfo()
    self:checkWXInfo(function (data)
        local oldUserID = nil

        local cmdInfo = self:getCMDInfoFromLaunchParams()
        if cmdInfo and cmdInfo.oldUserID then
            oldUserID = cmdInfo.oldUserID
        end

        if not oldUserID then
            cmdInfo = self:getCMDInfoFromClipBoard()
            if cmdInfo and cmdInfo.oldUserID then
                oldUserID = cmdInfo.oldUserID
            end
        end

        self:reqUserBindInfo(data, oldUserID)
    end)
end

-- 切后台检测口令
function NewInviteGiftModel:onResumeCallback()
    print("background callback")
    if not self._data then
        print("[NewInviteGiftModel:onResumeCallback] data is empty")
        return
    end

    local flag = false
    if not self._data.nOldStatus then
        flag = true
    elseif self._data.nOldStatus == NewInviteGiftModel.OldUserStatus.NOTDO then
        flag = true
    end

    if self._data.nNewStatus and (self._data.nNewStatus ~= NewInviteGiftModel.NewUserStatus.NOTBIND) then
        flag = false
    end

    if flag then
        self:checkWXInfo(function(data)
            local cmd = ""
            if DeviceUtils:getInstance().getClipboardContent then
                cmd = DeviceUtils:getInstance():getClipboardContent()
                if cmd and string.len(cmd) > 0 then
                    cc.exports.clipboardContent = cmd
                end
            end
            if DeviceUtils:getInstance().copyToClipboard then
                DeviceUtils:getInstance():copyToClipboard('')
            end
            print("test print launchInfo clipboard content")
            print(cmd)

            local oldUserID = nil
            local tblCMD = self:parseCmdString(cmd)
            if tblCMD and tblCMD.oldUserID then
                oldUserID = tblCMD.oldUserID
            end

            if not oldUserID then
                return
            end

            self._isBackgroundCopy = true

            self:reqUserBindInfo(data, oldUserID)
        end)
    end
end

-- 解析剪切板中的数据
function NewInviteGiftModel:parseCmdString(str)
    if not str then return end

    local index = string.find(str, "&c=")
    if not index then
        index = string.find(str, "?c=")
        if not index then
            return
        end
    end
    local cmd = string.sub(str, index + 3, #str)

    local tbl = {}
    while true do
        local pos = string.find(cmd, "/")
        if not pos then
            break
        end
        local element = string.sub(cmd, 1, pos - 1)
        table.insert(tbl, element)
        cmd = string.sub(cmd, pos + 1)
    end

    if #tbl == 0 then
        return
    end
    local res = {
        oldUserID = tonumber(tbl[1]),
    }

    return res 
end

-- 获取微信绑定信息并请求活动绑定
function NewInviteGiftModel:checkWXInfo(callback)
    print("NewInviteGiftModel:getThirdUserAccount enter")
    UserPlugin:getThirdUserAccount("weixin", function ( code, msg, info )
        print("getThirdUserAccount",code, msg )
        dump(info)

        local reqInfo = {
            unionID = nil,
            isWXLogin = false
        }
        self:setWinXinReqInfo(info)
        if code == AsyncQueryStatus.kSuccess and info.unionId and info.unionId ~= "" then
            print("success")
            reqInfo.unionID = info.unionId
            reqInfo.isWXLogin = true
        else --未绑定微信
            print("not bind")
            reqInfo.unionID = nil
            reqInfo.isWXLogin = false
        end

        if type(callback) == "function" then
            callback(reqInfo) 
        end
    end)
end

function NewInviteGiftModel:setWinXinReqInfo(info)
    self.weixinReqInfo = info
end

function NewInviteGiftModel:getWinXinReqInfo()
    return self.weixinReqInfo
end

function NewInviteGiftModel:setNewUserStatus(status)
    if not self._data then
        print("[NewInviteGiftModel:setNewUserStatus] invite gift data is empty")
        return 
    end

    self._data.nNewStatus = status
end

function NewInviteGiftModel:setOldUserStatus(status)
    if not self._data then
        print("[NewInviteGiftModel:setNewUserStatus] invite gift data is empty")
        return 
    end

    self._data.nOldStatus = status
end

function NewInviteGiftModel:setAutoEnterGame(value)
    self._isAutoEnterGame = value
end

-- 从启动信息获取口令信息
function NewInviteGiftModel:getCMDInfoFromLaunchParams()
    local cmd = ""
    if BusinessUtils:getInstance().getLaunchParamInfo then
        cmd = launchParamsManager:getContentSource()
    end

    local tblCMD = self:parseCmdString(cmd)
    return tblCMD
end

-- 从剪切板获取口令信息
function NewInviteGiftModel:getCMDInfoFromClipBoard()
    local cmd = ""
    if DeviceUtils:getInstance().getClipboardContent then
        cmd = DeviceUtils:getInstance():getClipboardContent()
        if cmd and string.len(cmd) > 0 then
            cc.exports.clipboardContent = cmd
        end
    end
    if (cmd == nil or cmd == "") and cc.exports.clipboardContent and string.len(cc.exports.clipboardContent) > 0 then
        cmd = cc.exports.clipboardContent
    end

    if DeviceUtils:getInstance().copyToClipboard then
        DeviceUtils:getInstance():copyToClipboard('')
    end
    local tblCMD = self:parseCmdString(cmd)
    return tblCMD
end

-- 获取新玩家配置
function NewInviteGiftModel:getNewUserConfig()
    if not self._invitegiftConfig then
        print("invite gift is empty")
        return
    end

    local res = clone(self._invitegiftConfig)
    res.oldUser = nil

    return res
end

-- 获取老玩家配置
function NewInviteGiftModel:getOldUserConfig()
    if not self._invitegiftConfig then
        print("invite gift is empty")
        return
    end

    local res = clone(self._invitegiftConfig)
    res.newUser = nil

    return res
end

-- 返回老玩家活动状态
function NewInviteGiftModel:getOldUserStatus()
    if not self._data then
        print("[NewInviteGiftModel:getOldUserStatus] invite gift data is empty")
        return 
    end

    return self._data.nOldStatus
end

-- 返回新玩家活动状态
function NewInviteGiftModel:getNewUserStatus()
    if not self._data then
        print("[NewInviteGiftModel:getOldUserStatus] invite gift data is empty")
        return 
    end

    return self._data.nNewStatus
end

function NewInviteGiftModel:isBackgroundCopy()
    return self._isBackgroundCopy
end

function NewInviteGiftModel:isAutoEnterGame()
    return self._isAutoEnterGame
end

return NewInviteGiftModel