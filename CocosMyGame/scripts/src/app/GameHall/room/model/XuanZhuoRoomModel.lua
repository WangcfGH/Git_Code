local XuanZhuoRoomModel = class("XuanZhuoRoomModel", require("src.app.GameHall.room.model.BaseRoomModel"))

XuanZhuoRoomModel.REQUESTS_PATH = "src.app.GameHall.room.model.XuanZhuoRoomRequests"

-- 进入移动端选桌房
function XuanZhuoRoomModel:setMyRoomManager(myRoomManager)
    self._myRoomManager = myRoomManager
end

-- 进入移动端选桌房
function XuanZhuoRoomModel:enterRoom(callback, isDXXW)
    self._syncSender.run(self._rsClient, function()
        local respondType, em_dataMap = self:_send("MR_ENTER_ROOM", self._roomInfo, isDXXW, true)
        if (respondType ~= mc.MR_ENTER_ROOM_OK) and (respondType ~= mc.ENTER_CLOAKINGROOM_OK) then
            callback("failed", respondType, em_dataMap)
            return
        end
        -- 在玩家列表中找到自己的位置
        local myUserID = mymodel('UserModel'):getInstance().nUserID
        local tableInfo = nil
        if (em_dataMap[2][myUserID]["nTableNO"] ~= -1 ) and ( em_dataMap[2][myUserID]["nChairNO"] ~= -1 ) then -- 玩家已经上桌了
            tableInfo = {
                nTableNO = em_dataMap[2][myUserID]["nTableNO"],
                nChairNO = em_dataMap[2][myUserID]["nChairNO"]
            }
        end
        callback("succeeded", respondType, em_dataMap, tableInfo)
    end)
    --self._rsClient
end

-- 注册通知响应消息列表
local response = {
    GR_PLAYER_ENTERED            = 80000,   --玩家进入房间
    GR_PLAYER_SEATED             = 80001,   --玩家就座
    GR_PLAYER_UNSEATED           = 80002,   --玩家离座
    GR_PLAYER_STARTED            = 80003,   --玩家开始玩游戏
    GR_PLAYER_PLAYING            = 80004,   --游戏进行中
    GR_PLAYER_LEFT               = 80005,   --玩家离开房间
    GR_PLAYER_LEAVETABLE         = 80011,   --玩家离座
    GR_PLAYER_NEWTABLE           = 80014,   --玩家到新的桌子
    GR_SOLOTABLE_CLOSED          = 80024,   --清除solo桌
    GR_PLAYER_GAMESTARTUP        = 80030,   --游戏开始
    GR_PLAYER_GAMEBOUTEND        = 80031,   --游戏一局结束
    MR_GET_ROOM_INFO             = 31011,   --获取房间信息(请求响应)
}   

-- 绑定房间通知消息至选桌管理器
function XuanZhuoRoomModel:_bindNotifyToTableManagerCtrl(id)
    local ril=import('src.app.GameHall.models.mcsocket.RequestIdList')
    self._rsClient:registRespondHandler(id, function(responseType, dataMap)
        if not self._myRoomManager or not self._myRoomManager:isCurrentXuanZhuoRoom() then return end
        local msg = ril.RespondIdReflact[responseType]
        if not msg then
            printError("can't find "..responseType.."'s name in RequestIdList.lua")
        end
        local AnchorTableModel = require("src.app.plugins.AnchorTable.AnchorTableModel"):getInstance()
        AnchorTableModel:onNotify(msg, dataMap)
    end)
end

-- 注册消息响应
function XuanZhuoRoomModel:_registNotifyEvents()
    XuanZhuoRoomModel.super._registNotifyEvents(self)

    for k,v in pairs(response) do
        self:_bindNotifyToTableManagerCtrl(v)
    end
end

--获取座位并自动开始(请求响应)
function XuanZhuoRoomModel:MR_GET_SEATED_AND_START(tableno, chairno, limit, force, invite, callback)
    --self._syncSender.run(self._rsClient, function()
        self:_send("MR_GET_SEATED_AND_START", self._roomInfo, tableno, chairno, limit, force, invite, false, function(respondType, nt_dataMap)
            local result = respondType == mc.UR_OPERATE_SUCCEED and "succeeded" or "failed"
            callback(result, respondType, nt_dataMap)
        end)
    --end)
end

--新建桌子并自动开始(请求响应)
function XuanZhuoRoomModel:MR_GET_NEWTABLE_EX(limit, empty, callback)
    --self._syncSender.run(self._rsClient, function()
        self:_send("MR_GET_NEWTABLE_EX", self._roomInfo, limit, empty, false, function(respondType, nt_dataMap)
            local result = respondType == mc.UR_OPERATE_SUCCEED and "succeeded" or "failed"
            callback(result, respondType, nt_dataMap)
        end)
    --end)
end

--选坐界面唤醒(请求响应)
function XuanZhuoRoomModel:MR_XZ_RESUME(callback)
    --self._syncSender.run(self._rsClient, function()
        self:_send("MR_XZ_RESUME", self._roomInfo, false, function(respondType, nt_dataMap)
            local result = respondType == mc.UR_OPERATE_SUCCEED and "succeeded" or "failed"
            callback(result, respondType, nt_dataMap)
        end) 
    --end)
end

--获取房间信息(请求响应)
function XuanZhuoRoomModel:MR_GET_ROOM_INFO(callback)
    --self._syncSender.run(self._rsClient, function()
        self:_send("MR_GET_ROOM_INFO", self._roomInfo, false, function(respondType, nt_dataMap)
            local result = respondType == mc.UR_OPERATE_SUCCEED and "succeeded" or "failed"
            callback(result, respondType, nt_dataMap)
        end) 
    --end)
end

--判断是否是选桌房
function XuanZhuoRoomModel:isCurrentXuanZhuoRoom()
    return true
end

return XuanZhuoRoomModel