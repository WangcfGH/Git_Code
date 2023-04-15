local RedPack100Cache = class("RedPack100Cache")

my.addInstance(RedPack100Cache)

RedPack100Cache.FILE_NAME = "RedPack100Cache"

function RedPack100Cache:ctor()
    self._dataMap = {}
    self._curUserId = 0
    self._fileName = RedPack100Cache.FILE_NAME
    self:getDataWithUserID()
end

function RedPack100Cache:getCacheFileByName()
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

function RedPack100Cache:saveCacheFileByName(dataMap)
    local user = mymodel('UserModel'):getInstance()
    if user == nil or user.nUserID == nil then
        return
    end
    local fileName = user.nUserID .. "_" .. self.FILE_NAME .. ".xml"
    my.saveCache(fileName, dataMap)
    self._dataMap = dataMap
end 

function RedPack100Cache:getDataWithUserID()
    local user = mymodel('UserModel'):getInstance()
    if user.nUserID ~= self._curUserId then
        self._curUserId = user.nUserID
        self._dataMap = self:getCacheFileByName()
    else
        return self._dataMap
    end

    if self._dataMap == nil then
        self._dataMap = {}
    end

    return self._dataMap
end


return RedPack100Cache