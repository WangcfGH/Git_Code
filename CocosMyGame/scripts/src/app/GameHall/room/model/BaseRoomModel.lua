local BaseRoomModel = class("BaseRoomModel")

BaseRoomModel.REQUESTS_PATH = "src.app.GameHall.room.model.BaseRoomRequests"

BaseRoomModel.EVENT_MAP = {
    ["baseRoomModel_recieveInvitation"] = "baseRoomModel_recieveInvitation",
    ["baseRoomModel_roomSocketError"] = "baseRoomModel_roomSocketError"
}

function BaseRoomModel:ctor(roomInfo, roomModelName)
    cc.load('event'):create():bind(self)
    self.modelName = roomModelName

    self:onCreate( roomInfo)
end

function BaseRoomModel:onCreate(roomInfo)
    --self._roomManager           = roomManager
    self._roomInfo              = roomInfo
    self._syncSender            = cc.load('asynsender').SyncSender
    self._scheduler             = cc.Director:getInstance():getScheduler()
    self._pulseSchedulerHandler = nil

    local ip = ""
    if my.judgeIPString(roomInfo.szWWW) then
        ip = roomInfo.szWWW
    else
        ip = roomInfo.szGameIP
    end
    require('src.app.HallConfig.ServerConfig').room = {ip, roomInfo.nPort == 0 and 31629 or roomInfo.nPort + 1000}

    self._rsClient              = require("src.app.GameHall.room.model.RoomServer"):getInstance()
    self._rsClient:setConnectionCallback(handler(self, self._onConnecttion))
    self:_registNotifyEvents()
    self._roomRequests          = require(self.REQUESTS_PATH):create(self._rsClient)
end

function BaseRoomModel:_send(request, ... )
    return self._roomRequests[request](self._roomRequests, ... )
end

function BaseRoomModel:getFinished(params)
    self:_send("MR_GET_FINISHED", params)
end

function BaseRoomModel:leaveRoom()
    self:_send("MR_LEAVE_ROOM", self._roomInfo.nRoomID, self._roomInfo.nAreaID)
    self._rsClient:disconnect()
    self:_stopPulse()
end

function BaseRoomModel:_pulse()
    self:_send("GR_ROOMUSER_PULSE", self._roomInfo.nRoomID)
end

function BaseRoomModel:_startPulse()
    if not self._pulseSchedulerHandler then
        self._pulseSchedulerHandler = self._scheduler:scheduleScriptFunc(function()
            self:_pulse()
        end, 60, false)
    end
end

function BaseRoomModel:_stopPulse()
    if self._pulseSchedulerHandler then 
        self._scheduler:unscheduleScriptEntry(self._pulseSchedulerHandler)
        self._pulseSchedulerHandler = nil
    end
end

function BaseRoomModel:getGameVersion(roomID, callback)
    self:_send("MR_GET_GAMEVERISON", {
            nRoomID = roomID
    }, false, callback)
end

function BaseRoomModel:enterRoom(callback, isDXXW)
    self:_send("MR_ENTER_ROOM", self._roomInfo, isDXXW, false, callback)
end

--isActived: 是否激活 0 后台 1 前台
function BaseRoomModel:enterBackground(nRoomID, nTableNO, nChairNO)
    local isActived = 0
    self:_send("MR_SET_GAMEISACTIVED", nRoomID, nTableNO, nChairNO, isActived)
end

function BaseRoomModel:enterForeground(nRoomID, nTableNO, nChairNO)
    local isActived = 1
    self:_send("MR_SET_GAMEISACTIVED", nRoomID, nTableNO, nChairNO, isActived)
end

function BaseRoomModel:findPlayer(roomID, targetUserID, callback)
    self:_send("MR_GET_WHEREISUSER", roomID, targetUserID, false, callback)
end

function BaseRoomModel:_onConnecttion(respondType)
    if respondType == mc.UR_SOCKET_CONNECT then 
        self:_startPulse()
    elseif respondType == mc.UR_SOCKET_ERROR 
    or  respondType == mc.UR_SOCKET_GRACEFULLY_ERROR then 
        self:_stopPulse()
        --self._roomManager:onSocketError()
        self:dispatchEvent({name = BaseRoomModel.EVENT_MAP["baseRoomModel_roomSocketError"]})
    end
end

function BaseRoomModel:_registNotifyEvents()
    self._rsClient:registRespondHandler(mc.MR_BE_FOUND_BY_SYSTEM, function(respondType, dataMap)
        --self._roomManager:onGetInvitation(dataMap, "roomServer")

        if dataMap.szHUserName then
            dataMap.szHUserName = MCCharset:getInstance():gb2Utf8String(dataMap.szHUserName, dataMap.szHUserName:len())
        end
        if dataMap.inviteName then
            dataMap.inviteName = MCCharset:getInstance():gb2Utf8String(dataMap.inviteName, dataMap.inviteName:len())
        end
        local eventData = {["inviteInfo"] = dataMap, ["fromType"] = "roomServer"}
        self:dispatchEvent({name = BaseRoomModel.EVENT_MAP["baseRoomModel_recieveInvitation"], value = eventData})
    end)
end

function BaseRoomModel:isConnectted()
    return self._rsClient and self._rsClient:isConnectted()
end


return BaseRoomModel