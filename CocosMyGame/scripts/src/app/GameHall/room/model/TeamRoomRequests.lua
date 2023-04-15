local TeamRoomRequests = class("TeamRoomRequests", require("src.app.GameHall.room.model.BaseRoomRequests"))


--创建队伍
function TeamRoomRequests:MR_NEW_TEAMROOM(roomInfo, isSentInCoroutine, callback) 
    local params = {
        nUserID     = self._userModel.nUserID,
        nGameID     = self._gameModel.nGameID,
        nRoomID     = roomInfo.nRoomID, 
        nAreaID     = roomInfo.nRoomID,
        nTableNO    = 0,
        nChairNO    = 0,
        nIPConfig   = 0,
        nBreakReq   = 0,
        nSpeedReq   = 0,
        nMinScore   = 0,
        nMinDeposit = 0,
        nWaitSeconds= 0,
        nNetDelay   = 0,
        dwGetFlags  = 0,
    }
    local needResponse = true
    return self:_send(mc.MR_NEW_TEAMROOM, params, isSentInCoroutine, callback, needResponse)
end

--队伍 - 探索队伍|换一批
function TeamRoomRequests:MR_FOUND_GROUP_TEAMROOMS(roomInfo, groupNum, isSentInCoroutine, callback) 
    local params = {
        nRoomID     = roomInfo.nRoomID,
        nGroupNum   = groupNum, 
        nUserID     = self._userModel.nUserID,
        nTableIndex = 0, 
        nTableValue = 0
    }
    local needResponse = true
    return self:_send(mc.MR_FOUND_GROUP_TEAMROOMS, params, isSentInCoroutine, callback, needResponse)
end

--包房详情
function TeamRoomRequests:MR_ASK_DETAIL_TABLEROOMS(roomID, tableID, isSentInCoroutine, callback)
    local params = {
        nRoomID     = roomID,
        nTableID    = tableID,
        nUserID     = self._userModel.nUserID
    }
    local needResponse = true
    return self:_send(mc.MR_ASK_DETAIL_TABLEROOMS, params, isSentInCoroutine, callback, needResponse)
end

--进入指定队伍
--tableNO:桌子ID
--homeUserID:房主ID
--enterGameFlag:0-搜索包房进入   1-系统找人进入  2-好友找人进入  3-跟随目标
function TeamRoomRequests:MR_ASK_ENTER_TEAMROOM(roomInfo, tableNO, homeUserID, enterGameFlag, isSentInCoroutine, callback) 
    local params = {
        nUserID     = self._userModel.nUserID,
        nHomeUserID = homeUserID,
        nRoomID     = roomInfo.nRoomID,
        nAreaID     = roomInfo.nAreaID,
        nGameID     = self._gameModel.nGameID,
        nTableNO    = tableNO,
        nChairNO    = 0,
        nIPConfig   = 0,
        nBreakReq   = 0,
        nSpeedReq   = 0,
        nMinScore   = 0,
        nMinDeposit = 0,
        nNetDelay   = 0,
        nEnterGameFlag = enterGameFlag,
    }
    local needResponse = true
    return self:_send(mc.MR_ASK_ENTER_TEAMROOM, params, isSentInCoroutine, callback, needResponse)
end

--设置上锁或取消
--tableNO:桌子ID
--isOpening：是否开放。 0不开放 ；1开放
function TeamRoomRequests:MR_SET_LOCK_TEAMROOM(param, isOpening, isSentInCoroutine, callback) 
    local params = {
        nUserID     = param.nUserID,
        nRoomID     = param.nRoomID,
        nTableNO    = param.nTableNO,
        nChairNO    = param.nChairNO,
        nIsOpening  = isOpening
    }
    local needResponse = true
    return self:_send(mc.MR_SET_LOCK_TEAMROOM, params, isSentInCoroutine, callback, needResponse)
end

function TeamRoomRequests:MR_STAND_UP_SEAT(params)
    return self:_send(mc.MR_STAND_UP_SEAT, params)
end



return TeamRoomRequests