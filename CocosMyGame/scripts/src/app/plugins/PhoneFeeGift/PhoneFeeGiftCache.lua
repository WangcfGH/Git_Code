local PhoneFeeGiftCache = class("PhoneFeeGiftCache")

my.addInstance(PhoneFeeGiftCache)

PhoneFeeGiftCache.FILE_NAME = "PhoneFeeGiftCache"

function PhoneFeeGiftCache:ctor()
    self._dataMap = {}
    self._curUserId = 0
    self._fileName = PhoneFeeGiftCache.FILE_NAME
    self:getDataWithUserID()
end

function PhoneFeeGiftCache:getCacheFileByName()
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

function PhoneFeeGiftCache:saveCacheFileByName(dataMap)
    local user = mymodel('UserModel'):getInstance()
    if user == nil or user.nUserID == nil then
        return
    end
    local fileName = user.nUserID .. "_" .. self.FILE_NAME .. ".xml"
    my.saveCache(fileName, dataMap)
    self._dataMap = dataMap
end 

function PhoneFeeGiftCache:getDataWithUserID()
    local user = mymodel('UserModel'):getInstance()
    if user.nUserID ~= self._curUserId then
        self._curUserId = user.nUserID
        self._dataMap = self:getCacheFileByName()
    else
        return self._dataMap
    end

    if self._dataMap == nil then
        self._dataMap = {aniLeftPlayed=0,aniMidPlayed=0,aniRightPlayed=0}
    end

    return self._dataMap
end


return PhoneFeeGiftCache