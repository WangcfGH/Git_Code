local CacheManager = {}

CacheManager.CacheFileName = 'CacheManager.xml'

CacheManager.CACHEKEY_FILETYPE  = 'filetype'
CacheManager.CACHEKEY_DURATION  = 'duration'
CacheManager.CACHEKEY_TIMESTAMP = 'timestamp'
CacheManager.CACHEKEY_FILEPATH  = 'path'

local _ONEDAY_ = 60*60*24
local DEFAULT_DURATION = 1

function CacheManager:init()
    self:initCacheTable()
end

function CacheManager:initCacheTable()
    self._cacheTable = {}

    local path = cc.FileUtils:getInstance():getGameWritablePath() .. self.CacheFileName
    self._cacheTable = cc.FileUtils:getInstance():getValueMapFromFile(path)

    self._cacheFilePath = path
end

function CacheManager:getCache(key)
    return self._cacheTable and self._cacheTable[key]
end

--[Comment] 使用key对某个类型的缓存文件进行管理，保存duration时长后删除，若保存的时间小于上一次设置的保存时间，则时间不变。
-- @key 对应缓存文件的搜索key
-- @path 缓存文件的存储路径
-- @fileType 文件类型 参数见CacheManager.CACHEKEY_XXX
-- @duration 缓存文件的持续时间（单位/秒）
function CacheManager:saveCache(key, path, fileType, duration)
    local oldCache = self._cacheTable[key]
    local _duration, time = duration or DEFAULT_DURATION * _ONEDAY_, os.time()
    if oldCache then
        if time + _duration < oldCache[self.CACHEKEY_TIMESTAMP] + oldCache[self.CACHEKEY_DURATION] then
            _duration = oldCache.duration
            time = oldCache[self.CACHEKEY_TIMESTAMP] 
        end
    end

    local newCache = {
        [key] = {
            [self.CACHEKEY_FILETYPE] = fileType,
            [self.CACHEKEY_DURATION] = _duration,
            [self.CACHEKEY_TIMESTAMP] = time,
            [self.CACHEKEY_FILEPATH] = path
        }
    }

    table.merge(self._cacheTable, newCache)
    cc.FileUtils:getInstance():writeToFile(self._cacheTable, self._cacheFilePath)
end

local function convertDayToSecond(day)
    return day * _ONEDAY_
end

--[Comment]
--清除到期缓存
function CacheManager:cleanDueCache()
    local newCacheTable = {}
    --新建缓存表 防止操作字典中遍历顺序错误
    table.merge(newCacheTable, self._cacheTable)
    for key, cache in pairs(self._cacheTable) do
        local curSecond = os.time()
        local duration = cache[self.CACHEKEY_DURATION]
        --duration 设置为非正数的话不删除缓存
        if duration > 0 and curSecond >= (cache[self.CACHEKEY_TIMESTAMP] + duration) then
            cc.FileUtils:getInstance():removeFile(cache[self.CACHEKEY_FILEPATH])
            newCacheTable[key] = nil
        end
    end

    self._cacheTable = newCacheTable
end

CacheManager:init()
return CacheManager
