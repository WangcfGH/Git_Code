local TeamRoomModel = class("TeamRoomModel", require("src.app.GameHall.room.model.BaseRoomModel"))

TeamRoomModel.REQUESTS_PATH = "src.app.GameHall.room.model.TeamRoomRequests"

function TeamRoomModel:getTableList(groupNum, callback)
    self._syncSender.run(self._rsClient, function()
        local fgt_respondType, fgt_dataMap = self:_send("MR_FOUND_GROUP_TEAMROOMS", self._roomInfo, groupNum, true)
        if fgt_respondType ~= mc.UR_OPERATE_SUCCEED then return end
        callback("tableList", fgt_respondType, fgt_dataMap)

        for _, tableInfo in pairs(fgt_dataMap[2]) do 
            local detail_respondType, detail_dataMap = self:_send("MR_ASK_DETAIL_TABLEROOMS", self._roomInfo.nRoomID, tableInfo.nTableId, true)
            detail_dataMap.nTableId = tableInfo.nTableId
            callback("tableDetail", detail_respondType, detail_dataMap)
        end
        callback("finished", mc.UR_OPERATE_SUCCEEDED)
    end)
end

function TeamRoomModel:enterSocialRoom_directToGame(tableNO, hostID, enterType, callback)
    printLog("TeamRoomModel", "enterSocialRoom_directToGame, tableNO:%s, hostID:%s, enterType:%s", tostring(tableNO), tostring(hostID), tostring(enterType))
    self._syncSender.run(self._rsClient, function()
        local respondType, em_dataMap = self:_send("MR_ENTER_ROOM", self._roomInfo, true)
        if (respondType ~= mc.MR_ENTER_ROOM_OK) and (respondType ~= mc.ENTER_CLOAKINGROOM_OK) then
            callback("failed", respondType)
            return
        end
        local _tableNO = tableNO
        if not _tableNO then
            local respondType, tableNO = self:_send("MR_GET_WHEREISUSER", self._roomInfo.nRoomID, hostID, true)
            _tableNO = tableNO
            --glabel:setString(glabel:getString().."\ntag2respondtype"..tostring(respondType).." "..tostring(_tableNO))
            if respondType ~= mc.UR_OPERATE_SUCCEED then
                callback("failed", respondType)
                return
            end
        end
        local respondType, nt_dataMap = self:_send("MR_ASK_ENTER_TEAMROOM", self._roomInfo, _tableNO, hostID, enterType, true) 
        local result = respondType == mc.UR_OPERATE_SUCCEED and "succeeded" or "failed"
        callback(result, respondType, em_dataMap, nt_dataMap)
    end)
end

function TeamRoomModel:createRoom(callback)
    self:_send("MR_NEW_TEAMROOM", self._roomInfo, false, callback)
end

function TeamRoomModel:enterTable(tableNO, homeUserID, enterGameFlag, callback)
    self:_send("MR_ASK_ENTER_TEAMROOM", self._roomInfo, tableNO, homeUserID, enterGameFlag, false, callback)
end

function TeamRoomModel:lockTable(params, callback)
    local isOpening = 0
    self:_send("MR_SET_LOCK_TEAMROOM", params, isOpening ,false, callback)
end

function TeamRoomModel:unLockTable(params, callback)
    local isOpening = 1
    self:_send("MR_SET_LOCK_TEAMROOM", params, isOpening ,false, callback)
end

function TeamRoomModel:standUpSeat(params)
    self:_send("MR_STAND_UP_SEAT", params)
end

function TeamRoomModel:tryGoToOtherRoom(excludedHomeID, callback)
    self:_send("MR_TRYGOTO_OTHERROOM", self._roomInfo, excludedHomeID, false, callback)
end

return TeamRoomModel
