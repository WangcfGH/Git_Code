--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local InviteGiftModel 		    = class('InviteGiftModel', require('src.app.GameHall.models.BaseModel'))
my.addInstance(InviteGiftModel)
--local PropertyBinder                =   cc.load('coms').PropertyBinder
--my.setmethods(InviteGiftModel, PropertyBinder)

local netProcess = require('src.app.BaseModule.NetProcess'):getInstance()

local SyncSender                    =   cc.load('asynsender').SyncSender
local user                          =   mymodel('UserModel'):getInstance()
--local player                        =   mymodel('hallext.PlayerModel'):getInstance()
local activitysConfig               =   require('src.app.HallConfig.ActivitysConfig')
local inviteGiftConfig              =   require('src.app.plugins.invitegift.InviteGiftConfig')

InviteGiftModel.FIRST_LOGIN_FLAG = 0x00000001
InviteGiftModel.SERVER_VERSION = 2

InviteGiftModel.EVENT_INVITE_GIFT_INFO = "EVENT_INVITE_GIFT_INFO"

InviteGiftModel.SIGN_KEY = "D92B4F5BA37631F5"

function InviteGiftModel:onCreate()
    self._firstLoginTime = nil
    self._isLaunchParamForInviteGift = false
    self._isNotBindWechat = false
    self._isLinkEnterForeGround = false
    self._isFirstLogin = false
    --self:bindProperty(player, 'PlayerLoginedData', self, 'OnLoginSuccessEvent')
    netProcess:addEventListener(netProcess.EventEnum.NetProcessFinished, handler(self, self.onNetProcessFinished))
end

function InviteGiftModel:onNetProcessFinished()
    if not isInviteGiftSupported() then return end
    self._firstLoginTime = math.floor(socket.gettime() * 1000)
    self._isLaunchParamForInviteGift = false
    self._isNotBindWechat = false
    self._isLinkEnterForeGround = false
    self._isFirstLogin = IS_BIT_SET(user["dwFlags"], InviteGiftModel.FIRST_LOGIN_FLAG)
    --print("InviteGiftModel:onNetProcessFinished dwFlags" .. user["dwFlags"])
    if self._isFirstLogin then
        self:queryThirdAccountBindStatus()
    end
end

--[[function InviteGiftModel:setOnLoginSuccessEvent(data)
    if data.nUserID then
        self._firstLoginTime = math.floor(socket.gettime() * 1000)
        self:queryUserInfo()
    end
end

function InviteGiftModel:queryUserInfo()
    local function onCallback(code)
        if code == 'succeed' and IS_BIT_SET(user["dwFlags"], InviteGiftModel.FIRST_LOGIN_FLAG) then
            self:queryThirdAccountBindStatus()
        end
    end
    PlayerRequestHelper:aquireListInfo({["QUERY_USER_GAMEINFO"] = true}, onCallback)
end]]

function InviteGiftModel:queryThirdAccountBindStatus()
    print("InviteGiftModel:queryThirdAccountBindStatus enter")

    UserPlugin:queryThirdAccountBindStatus("weixin", function ( code, msg )
    print("queryThirdAccountBindStatus",code, msg )
        if code == ThirdAccountStatus.kBinded then
            self:getThirdUserAccount()
        else
            self._isNotBindWechat = true
            self:showBindWechatDialog()
        end
    end)
end

function InviteGiftModel:showBindWechatDialog()
    print("InviteGiftModel:showBindWechatDialog enter")
    if self._isLaunchParamForInviteGift and self._isNotBindWechat then
        local pluginTable = {pluginName='InviteGiftSureTipPlugin',params={
            tipTitle="绑定微信",
            tipContent="检测到您还未绑定微信,绑定了微信才能领取邀请奖励哦~",
            okBtTitle="绑定微信",
            closeBtVisible=true,
            onOk=handler(self,self.bindThirdAccount),
        }}
        if self._isLinkEnterForeGround then
            if not PluginTrailMonitor:isPluginInTrail('InviteGiftSureTipPlugin') then
                my.informPluginByName(pluginTable)
                my.dataLink(cc.exports.DataLinkCodeDef.INVITE_GIFT_GUIDE_DIALOG)
            end
        else
            PluginTrailMonitor:pushPluginIntoTrail(pluginTable, PluginTrailOrder.kInviteGiftWeiXinBindDialog)
            my.dataLink(cc.exports.DataLinkCodeDef.INVITE_GIFT_GUIDE_DIALOG)
        end

        self._isNotBindWechat = false
        self._isLaunchParamForInviteGift = false
        self._isLinkEnterForeGround = false
    end
end

--已经在游戏中 点邀请有礼链接进来 重新走流程
function InviteGiftModel:enterGameFromInviteGiftLink(isLinkEnterForeGround)
    if not isInviteGiftSupported() then return end
    print("InviteGiftModel:enterGameFromInviteGiftLink" .. tostring(self._isFirstLogin))
    self._isLinkEnterForeGround = isLinkEnterForeGround
    if isLinkEnterForeGround then
        self._isNotBindWechat = false
        self._isLaunchParamForInviteGift = true
        if self._isFirstLogin then
            self:queryThirdAccountBindStatus()
        end
    else
        self._isLaunchParamForInviteGift = true
        self:showBindWechatDialog()
    end
end

function InviteGiftModel:bindThirdAccount()
    UserPlugin:bindThirdAccountForWeixinType()
end

function InviteGiftModel:bindThirdAccountCallback(success, msg)
    if not isInviteGiftSupported() then return end
    print("InviteGiftModel:bindThirdAccountCallback enter ")
    if success and self._isFirstLogin then
        self:getThirdUserAccount()
    end
end

function InviteGiftModel:getThirdUserAccount()
    print("InviteGiftModel:getThirdUserAccount enter")
    UserPlugin:getThirdUserAccount("weixin", function ( code, msg, info )
        print("getThirdUserAccount",code, msg )
        dump(info)
        if code == AsyncQueryStatus.kSuccess and info.unionId and info.unionId ~= "" then
            self:postFirstLoad(info.unionId)
        elseif code == 50001 then --未绑定微信
        end
    end)
end

function InviteGiftModel:getInviteGiftSignString(unionId)
	local keyString=string.format('%s&%s&%s',my.getAbbrName(),unionId, InviteGiftModel.SIGN_KEY)
    local md5String=my.md5(keyString)
    return md5String
end

function InviteGiftModel:getFirstLoadPostParams(unionId)
    local params = {
        abbr = my.getAbbrName(),
        inviteduid = user.nUserID,
        invitedunionid = unionId,
        dnumber = myhttp.getDeviceId(),
        activitid = activitysConfig.InviteGiftActId,
        ip = "192.168.1.111",
        sign = self:getInviteGiftSignString(unionId),
        firstlogintime = self._firstLoginTime,
        wxkey = UserPlugin:getThirdAppId("weixin")
    }
    return json.encode(params)
end

function InviteGiftModel:httpPost(url, params, callback, version)
    local xhr = cc.XMLHttpRequestExt:new()
    xhr.responseType = 0
    xhr:setRequestHeader('Content-Type', 'application/json')

    --KPI start
    local analyticsPlugin = plugin.AgentManager:getInstance():getAnalyticsPlugin()
    if analyticsPlugin and analyticsPlugin.getDisdkExtendedJsonInfo then
        local gsClient = analyticsPlugin:getDisdkExtendedJsonInfo()
        if gsClient then
            xhr:setRequestHeader("GsClientData", gsClient);
        end
    end
    --KPI end
    
    if version then
        xhr:setRequestHeader('Version', version) --邀请有礼用于区分后台的新老版本
    end
    xhr:open('POST', url)
    xhr:registerScriptHandler( function()
        printLog(self.__cname, 'status: %s, response: %s', xhr.status, xhr.response)
        callback(xhr)
    end )
    xhr:send(params)
    printLog(self.__cname, 'http post url: %s, params: %s', url, params)
end

function InviteGiftModel:postFirstLoad(unionId)
    local function _onCallback(xhr)
        if xhr.status == xhr.HTTP_RESPONSE_SUCCEED then
            local result = json.decode(xhr.response)
            dump(result)
            if result.StatusCode == 0 then
                
            else
                
            end
        end
    end
    local params = self:getFirstLoadPostParams(unionId)
    print(params)
    local url = string.format("%s%s", inviteGiftConfig.baseUrl, "/api/Invite/FirstLoad")
    self:httpPost(url, params, _onCallback, InviteGiftModel.SERVER_VERSION)
end

function InviteGiftModel:queryInviteGift()
    local client=my.jhttp:create()
    SyncSender.run(client,function()
        local sender,dataMap=SyncSender.send('queryInviteGift')
        dump(dataMap)
        self:dispatchEvent({name=InviteGiftModel.EVENT_INVITE_GIFT_INFO, value=dataMap})
    end)
end

return InviteGiftModel
--endregion
