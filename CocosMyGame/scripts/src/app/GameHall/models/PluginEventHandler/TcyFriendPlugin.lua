local TcyFriendPlugin = class("TcyFriendPlugin")
local HallContext = import('src.app.plugins.mainpanel.HallContext'):getInstance()

TcyFriendPlugin.EVENT_MAP = {
    ["tcyFriendPlugin_friendSdkNewMsg"] = "tcyFriendPlugin_friendSdkNewMsg",
    ["tcyFriendPlugin_friendSdkMsgReaded"] = "tcyFriendPlugin_friendSdkMsgReaded",
    ["tcyFriendPlugin_inviteChoose"] = "tcyFriendPlugin_inviteChoose",
    ["tcyFriendPlugin_recieveInvitation"] = "tcyFriendPlugin_recieveInvitation"
}

function TcyFriendPlugin:ctor()
    cc.load('event'):create():bind(self)

    self._tcyFriendPlugin = plugin.AgentManager:getInstance():getTcyFriendPlugin()
    self._userPlugin      = require('src.app.GameHall.models.PluginEventHandler.UserPlugin'):getInstance()
    --self._roomManager     = require("src.app.GameHall.room.ctrl.RoomManager"):getInstance()
    self._userModel       = mymodel("UserModel"):getInstance()
    self._roomStrings     = cc.load('json').loader.loadFile('RoomStrings.json')
    self._settingsModel   = mymodel("hallext.SettingsModel"):getInstance()

    self._lastSdkInvitationData = nil
end

function TcyFriendPlugin:init()
    self:_setPluginCallback()
    if isFriendSupported() or isSDKBallSupported() then
        self:login()
    end
    self:_initSDK()
    self:_setAgreeToBeInvitedHandler()
    self:_setInviteFriendHandler()
    self:_setReceiveInvitationHandler()
end

function TcyFriendPlugin:getInstance()
    TcyFriendPlugin._instance = TcyFriendPlugin._instance or TcyFriendPlugin:create()
    return TcyFriendPlugin._instance
end

function TcyFriendPlugin:login()
    if not self._tcyFriendPlugin then return end
    local userPlugin = self._userPlugin
    print('TcyFriendPlugin:login()',
        tonumber(userPlugin:getUserID()),
        userPlugin:getUserName(), 
        my.getGameID(), 
        userPlugin:getAccessToken(), 
        userPlugin:getUserSex())
    self._tcyFriendPlugin:loginFriend( 
        tonumber(self._userPlugin:getUserID()),
        self._userPlugin:getUserName(), 
        my.getGameID(), 
        self._userPlugin:getAccessToken(), 
        self._userPlugin:getUserSex(),
        isSDKBallSupported()
    )
end

function TcyFriendPlugin:_initSDK()
    if not self._tcyFriendPlugin then return end
    local path = my.getDataCachePath()
    local config = cc.FileUtils:getInstance():getStringFromFile("ct108_tcysdk.json")
    self._tcyFriendPlugin:initTcysdkinGame({RecommendInfoPath = tostring(path), TcySDKConfig = tostring(config)})
end

function TcyFriendPlugin:_setPluginCallback()
    if not self._tcyFriendPlugin then return end
    --[[self._friendCallbackTable = {}
    setmetatable(self._friendCallbackTable, { __mode = 'k' })]]--

    self._tcyFriendPlugin:setCallback(function(code, msg)
        printLog("TcyFriendPlugin", "Callback")
        printf("code:%s, msg%s", code, msg)

        --[[for _, callback in pairs(self._friendCallbackTable) do
            callback(code, msg)
        end]]--

        --发出newMessage消息
        if code == TcyFriendActionResultCode.kFriendSNSNewMessage then
            self:dispatchEvent({name = TcyFriendPlugin.EVENT_MAP["tcyFriendPlugin_friendSdkNewMsg"]})
        end
    end)
end

--[[function TcyFriendPlugin:setPluginCallback(callback)
    local index = #self._friendCallbackTable
    self._friendCallbackTable[index] = callback
    return index
end

function TcyFriendPlugin:removePluginCallback(key)
    self._friendCallbackTable[key] = nil
end]]--

function TcyFriendPlugin:_setInviteFriendHandler()
    if not self._tcyFriendPlugin then return end
    self._tcyFriendPlugin:setSDKInviteFriendCallback(handler(self, self._inviteFriend))
end

function TcyFriendPlugin:_setAgreeToBeInvitedHandler()
    if not self._tcyFriendPlugin then return end
    self._tcyFriendPlugin:setSDKAgreeToBeInvitedCallback(handler(self, self._onAgreeTouched))
end

function TcyFriendPlugin:_setReceiveInvitationHandler()
    if not self._tcyFriendPlugin then return end
    self._tcyFriendPlugin:setSDKReceiveInvitationCallback(handler(self, self._onRecieveInvitation))
end

function TcyFriendPlugin:_inviteFriend(session, userID)
    if not self._tcyFriendPlugin then return end
    printLog("TcyFriendPlugin", "_inviteFriend")
    local enterTeamInfo = HallContext.context["teamRoomContext"]["enterTeamInfo"]
    local isAllowed, failedReason = self:_isInvitationAllowed(userID)
    print(isAllowed, failedReason)
    if isAllowed then
        --local roomInfo      = self._roomManager:getCurrentRoomInfo()
        local roomInfo      = HallContext.context["roomContext"]["roomInfo"]

        local roomID        = roomInfo.nRoomID
        local tableNO       = GamePublicInterface:GetCurrentTableNO()
        local userID        = self._userModel.nUserID
        --local szUserName    = self._userModel.szUtf8Username
        local szUserName    = self._userModel:getSelfDisplayName()
        --local roomType      = self._roomManager:isCurrentSocialRoom() and RoomType.kRoomTypeFriend or RoomType.kRoomTypeNormal
        local roomType = RoomType.kRoomTypeNormal
        if HallContext.context["roomContext"]["areaEntry"] == "team" then
            roomType = RoomType.kRoomTypeFriend
        end

        local through_data  = {
            gameName    = my.getAppName(),
            gameID      = my.getGameID(),
            --roomName    = MCCharset:getInstance():gb2Utf8String(roomInfo.szRoomName, string.len(roomInfo.szRoomName)),
            roomName = roomInfo.szRoomName,
            --right       = self._roomManager:isCurrentSocialRoom() and self._roomStrings["CHARTERED_RIGHT"] or "" ,
            right = "",
            hostName    = enterTeamInfo["hostName"],
            hostID      = enterTeamInfo["hostID"],
            userid      = userID,
            roomID      = roomID,
            tableNO     = tableNO,
            abbr        = my.getAbbrName(),
            invitedContent = self._roomStrings["SKD_INVITE_CONTENT"]
        }
        --[[if HallContext.context["roomContext"]["areaEntry"] == "team" then
            through_data.right = self._roomStrings["CHARTERED_RIGHT"]
        end]]--
        local through_str = cc.load("json").json.encode(through_data)
        self._tcyFriendPlugin:onInviteFriendBack(session, InviteFriendType.kInviteFriendSuccess, "", roomID, tableNO, userID, szUserName, through_str, roomType)
    else
        local failedReason_text = self._roomStrings[failedReason]
        self._tcyFriendPlugin:onInviteFriendBack(session, InviteFriendType.kInviteFriendFailed, failedReason_text, 0, 0, 0,"","",0)
    end
end

function TcyFriendPlugin:_onAgreeTouched(session, playerinfo)
    if not self._tcyFriendPlugin then return end
    local isAllowed, failedReason = self:_isFollowAllowed(session, playerinfo)

    if isAllowed then
        --self._roomManager:onInviteClicked("accepted", playerinfo)
        local extraInfo = playerinfo.extrainfo and cc.load("json").json.decode(playerinfo.extrainfo)
        local sdkFindData = {
            ["nRoomID"] = playerinfo.roomid,
            ["nTableNO"] = playerinfo.tableno,
            ["inviteName"] = "您的好友"..playerinfo.hostname,
            ["szHUserName"] = extraInfo['hostName'],
            ["nHomeUserID"] = tonumber(extraInfo['hostID'])
        }
        local eventData = {["chooseType"] = "accepted", ["inviteInfo"] = sdkFindData}
        self:dispatchEvent({name = TcyFriendPlugin.EVENT_MAP["tcyFriendPlugin_inviteChoose"], value = eventData})
    else
        local failedStr = self._roomStrings[failedReason]
        self._tcyFriendPlugin:onAgreeToBeInvitedBack(session, AgreeToBeInvitedType.kAgreeToBeInvitedFailed, failedStr)
        my.informPluginByName({pluginName='ToastPlugin',params={tipString=failedStr,removeTime=5}})
    end
end

function TcyFriendPlugin:onChooseAgreeFromInviteDialog(inviteInfo)
    local eventData = {["chooseType"] = "accepted", ["inviteInfo"] = inviteInfo}
    self:dispatchEvent({name = TcyFriendPlugin.EVENT_MAP["tcyFriendPlugin_inviteChoose"], value = eventData})
end

function TcyFriendPlugin:_onRecieveInvitation(session, playerinfo)
    if not self._tcyFriendPlugin then return end

    local isInfoExist = playerinfo.extrainfo
    local extraInfo = playerinfo.extrainfo and cc.load("json").json.decode(playerinfo.extrainfo)

    local isSameGame = isInfoExist and (tostring(extraInfo["gameID"]) == tostring(my.getGameID())) 
    local isPlaying             = cc.exports.hasStartGame
    local isMatching            = cc.exports.isStartMatch
    local inTickoff             = cc.exports.inTickoff
    local isRoomTipForbidden    = self._settingsModel:isForbiddenRoomTips()

    local showPlace = ((not isSameGame) or isPlaying or isMatching or inTickoff or isRoomTipForbidden) and "sdk" or "hall"
    printLog("TcyFriendPlugin", "_onRecieveInvitation")
    dump(playerinfo)
    dump(extraInfo)

    --测试代码
    --showPlace = "hall"

    print(isSameGame, isPlaying, isMatching, inTickoff, isRoomTipForbidden, showPlace)
    if showPlace == "sdk" then 
        self._tcyFriendPlugin:onReceiveInvitationBack(session, cc.exports.ReceiveInvitationType.kReceiveInvitationdSDK, "")
    else
        self._tcyFriendPlugin:onReceiveInvitationBack(session,cc.exports.ReceiveInvitationType.kReceiveInvitationdHall,"")
        --self._roomManager:onGetInvitation(playerinfo, "sdk")

        local sdkFindData = {
            ["nRoomID"] = playerinfo.roomid,
            ["nTableNO"] = playerinfo.tableno,
            ["inviteName"] = "您的好友"..playerinfo.hostname,
            ["szHUserName"] = extraInfo['hostName'],
            ["nHomeUserID"] = tonumber(extraInfo['hostID']),
            ["receiveTime"] = os.time()
        }
        if self:_checkSdkInvitationPeriod(sdkFindData) == false then
            print("_checkSdkInvitationPeriod false")
            dump(self._lastSdkInvitationData)
            return
        end
        self._lastSdkInvitationData = sdkFindData
        local eventData = {["inviteInfo"] = sdkFindData, ["fromType"] = "sdk"}
        self:dispatchEvent({name = TcyFriendPlugin.EVENT_MAP["tcyFriendPlugin_recieveInvitation"], value = eventData})
    end
end

--1s内仅处理一个好友邀请；避免连续快速出现n多个弹框
function TcyFriendPlugin:_checkSdkInvitationPeriod(sdkFindData)
    if sdkFindData == nil then return true end
    if self._lastSdkInvitationData == nil then return true end

    local checkSame = function(data1, data2)
        local itemKeys = {"nRoomID", "nTableNO", "nHomeUserID"}
        for _, key in pairs(itemKeys) do
            if data1[key] ~= data2[key] then
                return false
            end
        end
        return true
    end

    local timeElapsed = os.time() - self._lastSdkInvitationData["receiveTime"]
    if timeElapsed >= 0 and timeElapsed <= 1.1 then
        --if checkSame(sdkFindData, self._lastSdkInvitationData) == true then
            return false
        --end
    end

    return true
end

function TcyFriendPlugin:testInvitation(roomId, tableNo)
    local playerinfo = {}
    playerinfo.roomid = 10033
    playerinfo.tableno = 2000
    playerinfo.hostname = "玩家159128"
    playerinfo.extrainfo = "{\"gameID\":81, \"hostName\":\"hezhen008\", \"hostID\":159128}"
    self:_onRecieveInvitation(1, playerinfo)
end

function TcyFriendPlugin:_isInvitationAllowed(userID)
    --local isUserHost            = self._roomManager:getTableInfo() and self._roomManager:getTableInfo().nHomeUserID == self._userModel.nUserID
    local isUserHost = false
    local roomContext = HallContext.context["roomContext"]
    local enterTeamInfo = HallContext.context["teamRoomContext"]["enterTeamInfo"]
    if enterTeamInfo and enterTeamInfo["hostID"] == self._userModel.nUserID then
        if roomContext["roomModel"] and roomContext["roomModel"].modelName == "team" then
            isUserHost = true
        end
    end
    --local isInGame              = self._roomManager:isInGame()
    local isInGame = (roomContext["isEnteredGameScene"] == true)
    local isPlaying             = cc.exports.hasStartGame
    local isMatching            = cc.exports.isStartMatch
    local isTableFull           = GamePublicInterface:isTableFull()
    local isPlayerInTable       = GamePublicInterface:IsPlayerInTable(userID)
    local isSocialSupported    = cc.exports.isSocialSupported()

    local failedReason = (not isUserHost)         and "SDK_INVITE_ERR_DISABLE"
                      or (not isInGame)           and "SDK_INVITE_ERR_PLACE"
                      or      isPlaying           and "SDK_INVITE_ERR_PLAYING"
                      or      isMatching          and "SDK_INVITE_ERR_MATCHING"
                      or      isTableFull         and "SDK_INVITE_ERR_FULL"
                      or      isPlayerInTable     and "SDK_INVITE_ERR_ALLREADY"
                      or (not isSocialSupported) and "SDK_INVITE_ERR_NOTSUPPORT"

    local isAllowed = failedReason == false
    return isAllowed, failedReason
end

function TcyFriendPlugin:_isFollowAllowed(session, playerinfo)

    local isInfoExist = playerinfo.extrainfo and string.len(playerinfo.extrainfo) > 0
    local extraInfo = playerinfo.extrainfo and cc.load("json").json.decode(playerinfo.extrainfo)

    local isSameGame = isInfoExist and extraInfo["gameID"] == my.getGameID()
    local isPlaying             = cc.exports.hasStartGame
    local isMatching            = cc.exports.isStartMatch
    local inTickoff             = cc.exports.inTickoff
    --local isRoomExist           = self._roomManager:isSocialRoom(playerinfo.roomid)
    local isRoomExist = false
    local RoomListModel = import("src.app.GameHall.room.model.RoomListModel"):getInstance()
    local roomInfo = RoomListModel.roomsInfo[playerinfo.roomid]
    if roomInfo and roomInfo["isTeamRoom"] then
        isRoomExist = true
    end

    local failedReason = (not isSameGame)  and "SDK_BEINVITED_ERR_SAME"
                      or isPlaying         and "SDK_BEINVITED_ERR_PLAYING"
                      or isMatching        and "SDK_BEINVITED_ERR_MATCHING"
                      or inTickoff         and "SDK_BEINVITED_ERR_PLAYING"
                      or (not isRoomExist) and "SDK_BEINVITED_ERR_NOROOM"

    printLog("_isFollowAllowed")
    dump(playerinfo)
    dump(extraInfo)
    print(isSameGame, isPlaying, isMatching, inTickoff, failedReason)

   local isAllowed = failedReason == false
   return isAllowed, failedReason

end

function TcyFriendPlugin:isFriend(userID)
    return self._tcyFriendPlugin and self._tcyFriendPlugin:isFriend(userID)
end

function TcyFriendPlugin:addFriend(userID, friendSource)
    return self._tcyFriendPlugin and self._tcyFriendPlugin:addFriend(userID, friendSource)
end

function TcyFriendPlugin:getPositionInfo()
    return self._tcyFriendPlugin and self._tcyFriendPlugin:getPositionInfo()
end

function TcyFriendPlugin:showFriendListDialog()
    self:dispatchEvent({name = TcyFriendPlugin.EVENT_MAP["tcyFriendPlugin_friendSdkMsgReaded"]})

    return self._tcyFriendPlugin and self._tcyFriendPlugin:showFriendListDialog()
end

function TcyFriendPlugin:getDistance(selfLatitude, selfLongitude, latitude, longitude)
    return self._tcyFriendPlugin and self._tcyFriendPlugin:getDistance(selfLatitude, selfLongitude, latitude, longitude)
end

function TcyFriendPlugin:destory()
    if self._tcyFriendPlugin then
        self._tcyFriendPlugin:destoryFriendSDK()
    end
end

function TcyFriendPlugin:getRemarkName(userID)
    return self._tcyFriendPlugin and self._tcyFriendPlugin:getRemarkName(userID)
end



--自定义功能
--好友未读消息
function TcyFriendPlugin:checkFriendNewMsg()
    if self:_isHaveFriendMsg() == true then
        self:dispatchEvent({name = TcyFriendPlugin.EVENT_MAP["tcyFriendPlugin_friendSdkNewMsg"]})
    end
end

function TcyFriendPlugin:_isHaveFriendMsg()
    if self._tcyFriendPlugin == nil then return false end

    local friendmsgJson = self._tcyFriendPlugin:getAllUnreadMsgInfo()
	if friendmsgJson and friendmsgJson ~= "" then
		local json = cc.load("json").json
		local friendmsg = json.decode(friendmsgJson)
		if friendmsg.unReadInviteCount and friendmsg.unReadMessagesCount then
			friendmsg.unReadInviteCount = tonumber(friendmsg.unReadInviteCount)
			friendmsg.unReadMessagesCount = tonumber(friendmsg.unReadMessagesCount)
			if friendmsg.unReadInviteCount > 0  or friendmsg.unReadMessagesCount > 0 then
				return true
			end
		end
	end

    return false
end

return TcyFriendPlugin