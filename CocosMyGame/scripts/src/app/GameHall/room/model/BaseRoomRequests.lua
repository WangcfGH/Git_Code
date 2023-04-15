local BaseRoomRequests = class("BaseRoomRequests")

BaseRoomRequests.dwClientFlags = {
    FLAG_CLIENTINFO_ANDPHONE = 0x00000010;  --安卓手机
    FLAG_CLIENTINFO_IOSPHONE = 0x00000020;  --苹果手机
    FLAG_CLIENTINFO_IOSPAD   = 0x00000040;  --苹果平板
}
BaseRoomRequests.dwEnterFlag = {
    FLAG_ENTERROOM_INTER        = 0x00000001;  --进入房间的客户端是内部版 
    FLAG_ENTERROOM_LOOKDARK     = 0x00000002;  --进入房间的客户端获取隐名玩家等
    FLAG_ENTERROOM_MATCH        = 0x00000004;  --进入高级比赛房间 
    FLAG_ENTERROOM_SMALLGAME    = 0x00000010;  --进入页游房间 
    FLAG_ENTERROOM_HANDPHONE    = 0x00000800;  --手机进入 
    FLAG_ENTERROOM_DXXW         = 0x00001000;  --进入房间是断线续玩
    FLAG_ENTERROOM_YUEPAI       = 0x00002000;  --约牌客户端进入房间
    FLAG_ENTERROOM_EXEBUILDNO   = 0x00004000;  --进房间需要检查游戏buildno
    FLAG_ENTERROOM_ARENA        = 0x00008000;  --竞技场
    FLAG_ENTERROOM_CLIENT_DXXW  = 0x10000000;  --区分一下客户端的进入方式
}
BaseRoomRequests.dwGetFlags = {
    mobile_user     = 0x00000800;
    notify_respond  = 0x00000001;
}

function BaseRoomRequests:ctor(rsClient)
    self._rsClient           = rsClient
    self._syncSender        = cc.load('asynsender').SyncSender
    self._userModel         = mymodel('UserModel'):getInstance()
    self._gameModel         = mymodel('GameModel'):getInstance()
    self._deviceModel       = mymodel('DeviceModel'):getInstance()
end

--发送协议接口 send
--protocal：协议号
--params：协议参数
--isSentInCoroutine：是否在协程中发送
--callback：如果不是在协程中发送需要设置回调
function BaseRoomRequests:_send(protocal, params, isSentInCoroutine, callback, needResponse)
    if isSentInCoroutine and needResponse then 
        local respondType, dataMap = self._syncSender.send(protocal, params, needResponse)
        return respondType, dataMap
    else
        assert(not isSentInCoroutine, "Send request without response in coroutine is not allowed")
        self._rsClient:send(protocal, params, needResponse, callback)
    end
end

--根据ID 查询玩家在哪个位置
--targetUserID:目标用户ID
function BaseRoomRequests:MR_GET_WHEREISUSER(roomID, targetUserID, isSentInCoroutine, callback)
    local params = {
        nTargetUserID   = targetUserID,
        nUserID         = self._userModel.nUserID,
        nGameID         = self._gameModel.nGameID,
        nRoomID         = roomID,
        szHardID        = self._deviceModel.szHardID,
    }
    local needResponse = true
    return self:_send(mc.MR_GET_WHEREISUSER, params, isSentInCoroutine, callback, needResponse)
end

--结束
function BaseRoomRequests:MR_GET_FINISHED(params)
    self:_send(mc.MR_GET_FINISHED, params)
end

--心跳
function BaseRoomRequests:GR_ROOMUSER_PULSE(roomID)
    local params = {
        nUserID  = self._userModel.nUserID,
        nRoomID  = roomID,
    }
    self:_send(mc.MR_SEND_PULSE, params)
end

--获取游戏版本信息
function BaseRoomRequests:MR_GET_GAMEVERISON(isSentInCoroutine, callback)
    local params = {
        nUserID     = self._userModel.nUserID,
        nGameID     = self._gameModel.nGameID,
        nRoomID     = self._currentRoomID or 0,
        dwGetFlag   = self.dwGetFlags.mobile_user 
    }
    local needResponse = true
    return self:_send(mc.MR_GET_GAMEVERISON, params, isSentInCoroutine, callback, needResponse)
end

--进房间
function BaseRoomRequests:MR_ENTER_ROOM(roomInfo, isDXXW, isSentInCoroutine, callback, isEnterArena)
    local params = {
        nUserID         = self._userModel.nUserID,
        szUniqueID      = self._userModel.szUniqueID,
        nGameID         = self._gameModel.nGameID,
        nExeMajorVer    = self._gameModel.nExeMajorVer,
        nExeMinorVer    = self._gameModel.nExeMinorVer,
        nExeBuildno     = self._gameModel.nExeBuildno,
        szHardID        = self._deviceModel.szHardID,
        szVolumeID      = self._deviceModel.szVolumeID,
        szMachineID     = self._deviceModel.szMachineID,
        szPhysAddr      = self._deviceModel.szPhysAddr,
        dwScreenXY      = self._deviceModel.dwScreenXY,
        nAreaID         = roomInfo.nAreaID,
        nGameVID        = roomInfo.nGameVID,
        nRoomID         = roomInfo.nRoomID,
        nRoomSvrID      = 0,
        nEnterTime      = 0,
        dwIPAddr        = 0,
        dwEnterFlags    = self.dwEnterFlag.FLAG_ENTERROOM_HANDPHONE 
                        + self.dwEnterFlag.FLAG_ENTERROOM_EXEBUILDNO,
        dwClientPort    = 0,
        dwServerPort    = 0,
        dwClientSockIP  = 0,
        dwRemoteSockIP  = 0,
        dwClientLANIP   = 0,
        dwClientMask    = 0,
        dwClientGateway = 0,
        dwClientDNS     = 0,
        dwPixelsXY      = 0,
        dwClientFlags   = 0,
        nHostID         = 0,
        nQuanID         = 0,
    }
    local targetPlatform = cc.Application:getInstance():getTargetPlatform()
    if targetPlatform == cc.PLATFORM_OS_ANDROID then 
        params.dwClientFlags = self.dwClientFlags.FLAG_CLIENTINFO_ANDPHONE
    elseif targetPlatform == cc.PLATFORM_OS_IPHONE then 
        params.dwClientFlags = self.dwClientFlags.FLAG_CLIENTINFO_IOSPHONE
    elseif targetPlatform == cc.PLATFORM_OS_IPAD then 
        params.dwClientFlags = self.dwClientFlags.FLAG_CLIENTINFO_IOSPAD
    end
    if isDXXW then
        params.dwEnterFlags = bit.bor(params.dwEnterFlags, self.dwEnterFlag.FLAG_ENTERROOM_CLIENT_DXXW)
    end
    if isEnterArena then
        params.dwEnterFlags = bit.bor(params.dwEnterFlags, self.dwEnterFlag.FLAG_ENTERROOM_ARENA)
    end
    local needResponse = true
    return self:_send(mc.MR_ENTER_ROOM, params, isSentInCoroutine, callback, needResponse)
end

--离开房间
function BaseRoomRequests:MR_LEAVE_ROOM(roomID, areaID)
    local params = {
        nUserID  = self._userModel.nUserID,
        nGameID  = self._gameModel.nGameID,
        szHardID = self._deviceModel.szHardID,
        nAreaID  = areaID,
        nRoomID  = roomID,
    }
    self:_send(mc.MR_LEAVE_ROOM, params)
end

--游戏切换后台通知room
--tableNO: 桌号
--chairNO: 位置
--isActived: 是否激活 0 后台 1 前台
function BaseRoomRequests:MR_SET_GAMEISACTIVED(nRoomID, nTableNO, nChairNO, isActived)
    local params = {
        nUserID       = self._userModel.nUserID,
        nGameID       = self._gameModel.nGameID,
        nRoomID       = nRoomID,
        nTableNO      = nTableNO,
        nChairNO      = nChairNO,
        nIsActived    = isActived,
    }
    self:_send(mc.MR_SET_GAMEISACTIVED, params)
end

--尝试去其他包间
--excludedHomeID：要排除的房主id所在的桌子
function BaseRoomRequests:MR_TRYGOTO_OTHERROOM(roomInfo, excludedHomeID, isSentInCoroutine, callback) 
    local params = {
        nUserID         = self._userModel.nUserID,
        nGameID         = self._gameModel.nGameID,
        nRoomID         = roomInfo.nRoomID, 
        nAreaID         = roomInfo.nAreaID,
        nIPConfig       = 0,
        nBreakReq       = 0,
        nSpeedReq       = 0,
        nMinScore       = 0,
        nMinDeposit     = 0,
        nNetDelay       = 0,
        nExcludedHomeID = excludedHomeID
    }
    local needResponse = true
    self:_send(mc.MR_TRYGOTO_OTHERROOM, params, isSentInCoroutine, callback, needResponse)
end

return BaseRoomRequests