local NormalRoomModel = class("NormalRoomModel", require("src.app.GameHall.room.model.BaseRoomModel"))

NormalRoomModel.REQUESTS_PATH = "src.app.GameHall.room.model.NormalRoomRequests"


function NormalRoomModel:enterRoom(callback, isDXXW, isEnterArena)
    self._syncSender.run(self._rsClient, function()
        local respondType, em_dataMap = self:_send("MR_ENTER_ROOM", self._roomInfo, isDXXW, true, nil, isEnterArena)
        if (respondType ~= mc.MR_ENTER_ROOM_OK) and (respondType ~= mc.ENTER_CLOAKINGROOM_OK) then
            callback("failed", respondType, em_dataMap)
            return
        end
        if (em_dataMap[2]["nTableNO"] ~= -1 ) and ( em_dataMap[2]["nChairNO"] ~= -1 ) then 
            local tableInfo = {
                nTableNO = em_dataMap[2]["nTableNO"],
                nChairNO = em_dataMap[2]["nChairNO"]
            }
            callback("succeeded", respondType, em_dataMap, tableInfo)
            return 
        end
        local respondType, nt_dataMap = self:_send("MR_GET_NEWTABLE", self._roomInfo, true) 
        local result = respondType == mc.UR_OPERATE_SUCCEED and "succeeded" or "failed"
        callback(result, respondType, em_dataMap, nt_dataMap)
    end)
end

return NormalRoomModel