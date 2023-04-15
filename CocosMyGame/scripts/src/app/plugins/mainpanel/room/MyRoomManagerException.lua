local MyRoomManagerException = class("MyRoomManagerException")
local CenterCtrl = require('src.app.BaseModule.CenterCtrl'):getInstance()

function MyRoomManagerException:ctor(roomManager)
    self._roomManager = roomManager
end

function MyRoomManagerException:onEnterRoomFailed(respondType, msg, roomID)
    if self._roomManager._roomContextOut["isEnteredGameScene"] == true then
        GamePublicInterface:quitDirect()
    end
    print("MyRoomManagerException:onEnterRoomFailed and doLeaveCurrentRoom")
    self._roomManager:doLeaveCurrentRoom()
    --self:checkRoomList()
    printLog("MyRoomManagerException", "onEnterRoomFailed, respondType%s, msg:%s", tostring(respondType), tostring(msg))

    local function update_mode2()
        self._roomManager:_showTip(self:getStrByRespondType(respondType))
        CenterCtrl:silentCheckUpdate()
    end

    local function update_mode1()
        CenterCtrl:silentCheckUpdate()
    end
    local function showGoToOtherRoomTip()
        local hostName = self._lastHostName or ""
        local hostID   = self._lastHostID or 0
        local failedReason = string.format(self:getStrByRespondType(respondType) or "", hostName)
        self._roomManager:_showTip(failedReason)
        --[[self:showErrorTip(failedReason, function()
            self:gotoOtherRoom(hostID)
        end, true)]]--
    end
    local errorHandlerMap = {
        [mc.ROOM_NEED_DXXW]  = function()
            --self._roomManager:tryEnterRoom(msg, true, nil)
            --必须要scheduleOnce，直接调用会失败，原因估计是在一个消息处理中不能发出另一个请求
            my.scheduleOnce(function() self._roomManager:tryEnterRoom(msg, true, nil) end, 0)
        end,
        [mc.HARDID_MISMATCH] = function (args)
            print("HARDID_MISMATCH and doLeaveCurrentRoom")
            self._roomManager:doLeaveCurrentRoom()
        end,
        [mc.OLD_EXEMINORVER]  = update_mode2,
        [mc.OLD_EXEMAJORVER]  = update_mode2,
        [mc.OLD_EXEBUILDNO]   = update_mode2,
        [mc.OLD_HALLBUILDNO]  = update_mode1,
        [mc.GR_NEW_HALLBUILDNO] = update_mode1,
        [mc.GR_FULL_PRIVATE_TABLE]         = showGoToOtherRoomTip,
        [mc.GR_FULL_PRIVATE_TABLE_READY]   = showGoToOtherRoomTip,
        [mc.GR_FULL_PRIVATE_TABLE_PLAYING] = showGoToOtherRoomTip,
        [mc.UR_PRIVATE_TABLE_LOCKED]       = showGoToOtherRoomTip,
        [mc.GR_EXPERIENCE_NOTENOUGH]       = function()
            local str = self:getStrByRespondType(respondType)
            self._roomManager:_showTip(str, msg.nMinRoomExperience, msg.nPlayerExperience)
         end
    }

    local enterCode = 0

    if errorHandlerMap[respondType] then
        errorHandlerMap[respondType]()
    elseif  self:getStrByRespondType(respondType) then
        local function enterRoomFailedOperate()
            if self:_dealDepositNotSatisfied(respondType, roomID) == true then
                enterCode = 2
            else
                self._roomManager:_showTip(self:getStrByRespondType(respondType))
            end
        end

        -- 当进入的房间是最低等级的房间时不显示去低级房的按钮
        -- local OldUserInviteGiftModel = require('src.app.plugins.invitegift.oldusergift.OldUserInviteGiftModel'):getInstance()
        -- f OldUserInviteGiftModel:isClickShowPanel(showNotEnoughTipPlugin) then
        --     return 
        -- end
        
        enterRoomFailedOperate()
    else
        self._roomManager:_showTip(self._roomManager._roomStrings["ENTERGAMEFAILED_DEFAULT"])
    end

    UIHelper:sendGameLoadingLog(enterCode)
end

function MyRoomManagerException:_dealDepositNotSatisfied(respondType, roomID)
    if respondType == mc.DEPOSIT_NOTENOUGH then
        self._roomManager:onDepositNotEnoughWhenEnterRoom(roomID)
        return true
    elseif respondType == mc.DEPOSIT_OVERFLOW then
        self._roomManager:onDepositTooHighWhenEnterRoom(roomID)
        return true
    end

    return false
end

function MyRoomManagerException:getStrByRespondType(respondType)
   self._errorTipMap = self._errorTipMap or {
        [0]                             = "RoomNotFind",
        [mc.SERVICE_BUSY]               = "SERVICE_BUSY",
        [mc.FORBID_ENTERROOM]           = "FORBID_ENTERROOM",
        [mc.LEVEL_NOTENOUGH]            = "LEVEL_NOTENOUGH",
        [mc.DEPOSIT_NOTENOUGH]          = "DEPOSIT_NOTENOUGH",
        [mc.DEPOSIT_OVERFLOW]           = "DEPOSIT_OVERFLOW",
        [mc.PLAYING_GAME]               = "PLAYING_GAME",
        [mc.ROOM_FULL]                  = "ROOM_FULL",
        [mc.NORIGHTS_TO_ENTER]          = "NORIGHTS_TO_ENTER",
        [mc.NO_CHAIRS]                  = "NO_CHAIRS",
        [mc.FORBID_SAMEHARDID]          = "FORBID_SAMEHARDID",
        [mc.FORBID_SAMEIPINROOM]        = "FORBID_SAMEIPINROOM",
        [mc.IP_FORBIDDEN]               = "IP_FORBIDDEN",
        [mc.SCREEN_NOTENOUGH]           = "SCREEN_NOTENOUGH",
        [mc.WINSYSTEM_NOTENOUGH]        = "WINSYSTEM_NOTENOUGH",
        [mc.WINSYSTEM_NOTSUPPORT]       = "WINSYSTEM_NOTSUPPORT",
        [mc.FORBID_NODIANXINIP]         = "FORBID_NODIANXINIP",
        [mc.ROOM_DIANXIN]               = "ROOM_DIANXIN",
        [mc.FORBID_PROXY]               = "FORBID_PROXY",
        [mc.FORBID_VIRTUAL]             = "FORBID_VIRTUAL",
        [mc.MATCHSCORE_NOTENOUGH]       = "MATCHSCORE_NOTENOUGH",
        [mc.ROOM_FORBID_IP]             = "ROOM_FORBID_IP",
        [mc.ROOM_NEEDSIGNUP]            = "ROOM_NEEDSIGNUP",
        [mc.MATCH_FINISH]               = "MATCH_FINISH",
        [mc.HARDID_MISMATCH]            = "HARDID_MISMATCH",
        [mc.BOUT_NOTENOUGH]             = "BOUT_NOTENOUGH",
        [mc.TIMECOST_NOTENOUGH]         = "TIMECOST_NOTENOUGH",
        [mc.FORBID_UNEXPIRATION]        = "FORBID_UNEXPIRATION",
        [mc.PLAYSCORE_NOTENOUGH]        = "PLAYSCORE_NOTENOUGH",
        [mc.SCORE_OVERFLOW]             = "SCORE_OVERFLOW",
        [mc.PLAYSCORE_OVERFLOW]         = "PLAYSCORE_OVERFLOW",
        [mc.FORBID_PROXYIP]             = "FORBID_PROXYIP",
        [mc.USER_LOCK]                  = "USER_LOCK",
        [mc.USER_FORBIDDEN]             = "USER_FORBIDDEN",
        [mc.SYSTEM_LOCK]                = "SYSTEM_LOCK",
        [mc.FORBID_EXPIRATION]          = "FORBID_EXPIRATION",
        [mc.NO_THIS_FUNCTION]           = "NO_THIS_FUNCTION",
        [mc.DEPOSIT_OVERFLOW]           = "DEPOSIT_OVERFLOW",
        [mc.SCORE_NOTENOUGH]            = "SCORE_NOTENOUGH",

        [mc.GR_FOLLOW_TARGET_NOTFOUND]  = "GR_FOLLOW_TARGET_PLAYING",
        [mc.GR_FOLLOW_TARGET_PLAYING]   = "GR_FOLLOW_TARGET_PLAYING",
        [mc.GR_FOLLOW_TARGET_OFFTABLE]  = "GR_FOLLOW_TARGET_OFFTABLE",

        [mc.GR_NEW_EXEMAJORVER]         = "VERSION_NEW",
        [mc.GR_NEW_EXEMINORVER]         = "VERSION_NEW",
        [mc.GR_NEW_EXEBUILDNO]          = "VERSION_NEW",
        [mc.OLD_EXEMAJORVER]            = "VERSION_OLD",
        [mc.OLD_EXEMINORVER]            = "VERSION_OLD",
        [mc.OLD_EXEBUILDNO]             = "VERSION_OLD",

        --[mc.GR_NO_EXTRA_TABLE]          = "GR_NO_EXTRA_TABLE",
        [mc.GR_FULL_PRIVATE_TABLE]          = "GR_FULL_PRIVATE_TABLE",
        [mc.GR_NOBODY_PRIVATE_TABLE]        = "GR_NOBODY_PRIVATE_TABLE",
        [mc.GR_FOLLOW_TARGET_PLAYING]       = "GR_FOLLOW_TARGET_PLAYING",
        [mc.GR_FULL_PRIVATE_TABLE_READY]    = "GR_FULL_PRIVATE_TABLE_READY",
        [mc.GR_FULL_PRIVATE_TABLE_PLAYING]  = "GR_FULL_PRIVATE_TABLE_PLAYING",
        [mc.UR_PRIVATE_TABLE_LOCKED]        = "UR_PRIVATE_TABLE_LOCKED",
        [mc.GR_YQW_NO_ROOM_TABLE]           = "GR_YQW_NO_ROOM_TABLE",

        [mc.UR_OPERATE_FAIL]                = "UR_OPERATE_FAIL",
        [mc.GR_EXPERIENCE_NOTENOUGH]        = "GR_EXPERIENCE_NOTENOUGH",
        [mc.GR_TARGET_TABLE_FULL_READY]     = "GR_TARGET_TABLE_FULL_READY",
        [mc.GR_TARGET_TABLE_FULL_PLAYING]   = "GR_TARGET_TABLE_FULL_PLAYING",
        [mc.GR_TARGET_TABLE_IDENTITY_ERR]   = "GR_TARGET_TABLE_IDENTITY_ERR",
        [mc.NO_PERMISSION]                  = "NO_PERMISSION",
        [mc.GR_NO_EXTRA_TABLE]              = "GR_NO_EXTRA_TABLE",
        [mc.ROOM_NOT_OPEN]                  = "ROOM_NOT_OPEN",
    }
    local key = self._errorTipMap[respondType]
    if key and self._roomManager._roomStrings[key] then
       return self._roomManager._roomStrings[key]
    else
        return false
    end
end

return MyRoomManagerException