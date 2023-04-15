local ActivityCenterStatus = class("ActivityCenterStatus")

my.addInstance(ActivityCenterStatus)

ActivityCenterStatus.FILE_NAME = "ActivityCenterStatus"

function ActivityCenterStatus:ctor()
    self._dataMap = {}
    self._curUserId = 0
    self._fileName = ActivityCenterStatus.FILE_NAME
    self:getDataWithUserID()
end

function ActivityCenterStatus:getCacheFileByName()
    local user = mymodel('UserModel'):getInstance()
    if user == nil or user.nUserID == nil then
        return nil
    end

    local fileName = user.nUserID .. "_" .. self._fileName .. ".xml"
    if(false == my.isCacheExist(fileName))then
        return nil
    end

    local dataMap = my.readCache(fileName)

    if not checktable(dataMap) then
        return nil
    end

    return dataMap
end

function ActivityCenterStatus:saveCacheFileByName(dataMap)
    local user = mymodel('UserModel'):getInstance()
    if user == nil or user.nUserID == nil then
        return
    end
    local fileName = user.nUserID .. "_" .. self.FILE_NAME .. ".xml"
    my.saveCache(fileName, dataMap)
end 

function ActivityCenterStatus:getDataWithUserID()
    local user = mymodel('UserModel'):getInstance()
    if user.nUserID ~= self._curUserId then
        self._curUserId = user.nUserID
        self._dataMap = self:getCacheFileByName()
    else
        return self._dataMap
    end

    if self._dataMap == nil then
       self:resetData()
    end

    return self._dataMap
end

function ActivityCenterStatus:resetData()
    self._dataMap = {}
end

function ActivityCenterStatus:getUserStatus(activityId)
    local key = "A" .. activityId
    self:getDataWithUserID()
    if self._dataMap[key] == nil then
        self._dataMap[key] = {}
    end

    self._dataMap[key]["count"] = self._dataMap[key]["count"] or 0
    self._dataMap[key]["data"] = self._dataMap[key]["data"] or os.date("%Y%m%d")
    self._dataMap[key]["reddot"] = self._dataMap[key]["reddot"] or false

    return self._dataMap[key]["count"], self._dataMap[key]["data"], self._dataMap[key]["reddot"]
end

function ActivityCenterStatus:updateActivity(activityId, updateTime, count, isRedDot)
    local key = "A" .. activityId
    local dataMap = self:getDataWithUserID()
    if dataMap[key] == nil then
        dataMap[key] = {}
    end
    dataMap[key]["data"] = updateTime
    dataMap[key]["count"] = count
    --dataMap[key]["reddot"] = isRedDot

    self:saveCacheFileByName(dataMap)
end

function ActivityCenterStatus:updateActivityTime(activityId, updateTime)
    local key = "A" .. activityId
    local dataMap = self:getDataWithUserID()
    if dataMap[key] == nil then
        dataMap[key] = {}
    end
    dataMap[key]["data"] = updateTime
    self:saveCacheFileByName(dataMap)
end

function ActivityCenterStatus:updateActivityRedDot(activityId)
    local key = "A" .. activityId
    local dataMap = self:getDataWithUserID()
    if dataMap[key] == nil then
        dataMap[key] = {}
    end
    dataMap[key]["reddot"] = true
    self:saveCacheFileByName(dataMap)
end

function ActivityCenterStatus:addActivityCount(activityId)
    local key = "A" .. activityId
    local dataMap = self:getDataWithUserID()
    if dataMap[key] == nil then
        dataMap[key] = {}
    end
    dataMap[key]["count"] = dataMap[key]["count"] + 1
    self:saveCacheFileByName(dataMap)
end

function ActivityCenterStatus:resetActivityRedDot(activityId, bRed)
    local key = "A" .. activityId
    local dataMap = self:getDataWithUserID()
    if dataMap[key] == nil then
        dataMap[key] = {}
    end
    dataMap[key]["reddot"] = bRed
    self:saveCacheFileByName(dataMap)
end

return ActivityCenterStatus