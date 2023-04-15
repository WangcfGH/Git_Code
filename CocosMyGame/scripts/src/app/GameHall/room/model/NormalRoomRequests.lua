local NormalRoomRequests = class("NormalRoomRequests", require("src.app.GameHall.room.model.BaseRoomRequests"))

function NormalRoomRequests:MR_GET_NEWTABLE(roomInfo, isSentInCoroutine, callback)
    local params = {
        nUserID  = self._userModel.nUserID,
        nGameID  = self._gameModel.nGameID,
        nAreaID  = roomInfo.nAreaID,
        nRoomID  = roomInfo.nRoomID, 
    }
    local needResponse = true
    return self:_send(mc.MR_GET_NEWTABLE, params, isSentInCoroutine, callback, needResponse)
end

return NormalRoomRequests