local RoomDataManager = class("RoomDataManager", require('src.app.GameHall.models.BaseModel'))

my.addInstance(RoomDataManager)

function RoomDataManager:onCreate()
    --local event=cc.load('event')
    --event:create():bind(self)
    
    self._tablesData = import("src.app.plugins.AnchorTable.RoomDataManager.RoomTablesData")
    self._playersData = import("src.app.plugins.AnchorTable.RoomDataManager.RoomPlayersData")
    self._configData = import("src.app.plugins.AnchorTable.RoomDataManager.RoomConfigData")
    self._queryInterface = require("src.app.plugins.AnchorTable.RoomDataManager.RoomDataQuery"):getInstance(self)
    self._updateInterface = require("src.app.plugins.AnchorTable.RoomDataManager.RoomDataUpdate"):getInstance(self)
end

function RoomDataManager:init()
    self._tablesData:create(self)
    self._playersData:create(self)
    self._configData:create(self)
end

function RoomDataManager:setData(params)
    self._tablesData:setData(params.tables)
    self._playersData:setData(params.players)
    self._configData:setData(params.roomInfo)
end

function RoomDataManager:clearData()
    self._tablesData:clearData()
    self._playersData:clearData()
    self._configData:clearData()
end

function RoomDataManager:getPlayersData()
    return self._playersData
end

function RoomDataManager:getTablesData()
    return self._tablesData
end

function RoomDataManager:getConfigData()
    return self._configData
end

-- 数据变动通知
function RoomDataManager:changesNotify(id, who, oldValue, newValue)
    if oldValue == newValue then return end
    self:dispatchEvent({name = id, value = {who = who, oldValue = oldValue, newValue = newValue}})
end

function RoomDataManager:query(name,...)
    return self._queryInterface["query"..name](self._queryInterface,...)
end

function RoomDataManager:notify(respondType, dataMap)
    if self._updateInterface[respondType] then
        self._updateInterface[respondType](self._updateInterface,dataMap)
    else
        print("recv "..respondType..", but can't find deal function")
    end
end

function RoomDataManager:exec(name,...)
    return self._updateInterface["exec"..name](self._updateInterface,...)
end

function RoomDataManager:onGetImage(info)
    self:exec("GetPlayerPortrait", info)
end

return RoomDataManager