--/*************** MyHandCardsCache **************************/
--/*************** 缓存用户使用的横向or竖向排列方式 ***********/
local MyHandCardsCache = class("MyHandCardsCache")
my.addInstance(MyHandCardsCache)

function MyHandCardsCache:getCacheDataName()
    local cacheFile= "HandCardsMode.xml"
    local user=mymodel('UserModel'):getInstance()
    local id = user.nUserID
    if type(id) == 'number' then
        cacheFile = id.."_"..cacheFile
        return cacheFile
    end
    
    return cacheFile
end

function MyHandCardsCache:readFromCacheData()
    local dataMap
    local filename = self:getCacheDataName()
    if(false == my.isCacheExist(filename))then
        return nil
    end

    dataMap=my.readCache(filename)
    dataMap=checktable(dataMap)
    return dataMap
end

function MyHandCardsCache:setHandCardsModeCache(mode)
    local dataCache = {}
    dataCache.HandCardsMode = mode

    local data=checktable(dataCache)
    local filename = self:getCacheDataName()
    if filename ~= "" then
        my.saveCache(filename,data)
    end

    return
end


return MyHandCardsCache
