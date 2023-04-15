local XuanZhuoRoomRequests = class("XuanZhuoRoomRequests", require("src.app.GameHall.room.model.NormalRoomRequests"))
local userPlugin = plugin.AgentManager:getInstance():getUserPlugin()
local RoomDef = import("src.app.plugins.AnchorTable.Define.RoomDef")

--获取座位并自动开始(请求响应)
function XuanZhuoRoomRequests:MR_GET_SEATED_AND_START(roomInfo, tableno, chairno, limit, force, invite, isSentInCoroutine, callback)
    local params = {
        nUserID  = self._userModel.nUserID,
        nGameID  = self._gameModel.nGameID,
        szHardID = self._deviceModel.szHardID,
        nAreaID  = roomInfo.nAreaID,
        nRoomID  = roomInfo.nRoomID,
        nTableNO = tableno,
        nChairNO = chairno,
        szPassword   = limit and limit.szPassword   or "",
        nMinScore    = limit and limit.nMinScore    or RoomDef.SCORE_MIN,
        nMinDeposit  = limit and limit.nMinDeposit  or 0,
        nAllowLookon = limit and limit.nAllowLookon or 1,  -- 默认允许旁观
        nWinRate     = limit and limit.nWinRate     or 0,
        nReserved    = {force or 0, invite or 0},
    }
    return self:_send(mc.MR_GET_SEATED_AND_START, params, isSentInCoroutine, callback, true)
end

--新建桌子并自动开始(请求响应)
function XuanZhuoRoomRequests:MR_GET_NEWTABLE_EX(roomInfo, limit, empty, isSentInCoroutine, callback)
    local params = {
        nUserID  = self._userModel.nUserID,
        nGameID  = self._gameModel.nGameID,
        szHardID = self._deviceModel.szHardID,
        nAreaID  = roomInfo.nAreaID,
        nRoomID  = roomInfo.nRoomID,
        szPassword   = limit and limit.szPassword   or "",
        nMinScore    = limit and limit.nMinScore    or RoomDef.SCORE_MIN,
        nMinDeposit  = limit and limit.nMinDeposit  or 0,
        nAllowLookon = limit and limit.nAllowLookon or 1,  -- 默认允许旁观
        nWinRate     = limit and limit.nWinRate     or 0,
        nReserved    = {empty or 0}
    }
    return self:_send(mc.MR_GET_NEWTABLE_EX, params, isSentInCoroutine, callback, true)
end

--选坐界面唤醒(请求响应)
function XuanZhuoRoomRequests:MR_XZ_RESUME(roomInfo, isSentInCoroutine, callback)
    local params = {
        nUserID  = self._userModel.nUserID,
        nRoomID  = roomInfo.nRoomID,
        nAppID  = 1880000 + self._gameModel.nGameID,
        szHardID = self._deviceModel.szHardID,
    }
    return self:_send(mc.MR_XZ_RESUME, params, isSentInCoroutine, callback, true)
end

--获取房间信息(请求响应)
function XuanZhuoRoomRequests:MR_GET_ROOM_INFO(roomInfo, isSentInCoroutine, callback)
    local params = {
        nUserID  = self._userModel.nUserID,
        nRoomID  = roomInfo.nRoomID,
        nAppID  = 1880000 + self._gameModel.nGameID,
        szHardID = self._deviceModel.szHardID,
    }
    return self:_send(mc.MR_GET_ROOM_INFO, params, isSentInCoroutine, callback, true)
end


return XuanZhuoRoomRequests