local ArenaDataSet = class("ArenaDataSet")
my.addInstance(ArenaDataSet)
local user                          = mymodel('UserModel'):getInstance()

function ArenaDataSet:ctor()
    self._dataSet = {["nUserID"] = -1}
end

function ArenaDataSet:setData(key, data)
    if key ==nil or data == nil then return end
    self:_checkData()

    if self._dataSet[key] == nil then self._dataSet[key] = {} end
    local targetData = self._dataSet[key]
    targetData["data"] = data
    targetData["updateTime"] = os.time()
end

--获取数据
function ArenaDataSet:getData(key)
    if key == nil then return nil end
    self:_checkData()

    local targetData = self._dataSet[key]
    if targetData ~= nil then 
        return targetData["data"]
    end
    return nil
end

--核查数据的正确性
function ArenaDataSet:_checkData()
    local dataOwner = self._dataSet["nUserID"]
    if dataOwner ~= user.nUserID then 
        self._dataSet = {["nUserID"] = user.nUserID} --用户id不符，则重置
    end
end

return ArenaDataSet
