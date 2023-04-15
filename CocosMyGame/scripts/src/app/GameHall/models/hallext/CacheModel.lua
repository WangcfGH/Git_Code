--[[
@描述: 提供公共的缓存接口，方便其他模块调用，而不必每次自己抄一套缓存的代码。
    接口分为面向user的saveInfoToUserCache和面向整个app的saveInfoToCache
@作者：陈添泽
@日期：2017.05.20
]]
local CacheModel = class("CacheModel")

my.addInstance(CacheModel)

local DEFAULT_CACHENAME      = "PublicCache.xml"
local DEFAULT_USER_CACHENAME = "PublicCache_%s.xml"

function CacheModel:ctor( ... )
    local event=cc.load('event')
    event:create():bind(self)

    if(self.onCreate)then
        self:onCreate(...)
    end
end

function CacheModel:onCreate( ... )
    self._listeners = {}
    self._fileInfo  = {}
    self._userFileInfo = {}
    self:_initListener()
    self:readCache()
end

function CacheModel:_initListener()
    local netProcess = require('src.app.BaseModule.NetProcess'):getInstance()
    netProcess:addEventListener(netProcess.EventEnum.PreLoginFinished, handler(self, self._onPreLoginFinished), self.__cname)
end

function CacheModel:_onPreLoginFinished()
    self._userFileInfo = my.readCache(self:getUserCacheName())
end

function CacheModel:readCache()
    self._fileInfo = my.readCache(self:getDefaultCacheName())
    self._userFileInfo = my.readCache(self:getUserCacheName())
end

function CacheModel:getDefaultCacheName()
    return DEFAULT_CACHENAME
end

function CacheModel:saveCache()
    my.saveCache(self:getDefaultCacheName(), self._fileInfo)
end

--[Comment]
--按照key分别从设备缓存和用户缓存文件中读取数据，接口不区分是用户的还是设备的，在使用的时候切记不要使用相同的key存在两个表中
function CacheModel:getCacheByKey(key)
    return self._fileInfo[key] or self._userFileInfo[key] or {}
end

function CacheModel:saveInfoToCache(key, info)
    self._fileInfo[key] = info
    self:saveCache()
    if type(self._listeners[key]) == "table" then
        for _, listener in pairs(self._listeners[key]) do
            listener(self._fileInfo[key])
        end
    end
end

function CacheModel:registInfoChangeByKey(key, listener, tag)
    if not key then printError("CacheModel:registInfoChangeByKey require key as input") return end
    self._listeners[key] = self._listeners[key] or {}
    if tag then 
        self._listeners[key][tag] = listener 
    else
        table.insert(self._listeners[key], listener)
    end
end

function CacheModel:removeListenerByTag(tag, key)
    if key then
        self._listeners[key][tag] = nil
    else
        for key, listenersOfKey in pairs(self._listeners) do
            listenersOfKey[tag] = nil
        end
    end
end

function CacheModel:getUserCacheName()
    return string.format(DEFAULT_USER_CACHENAME, UserPlugin:getUserID())
end

function CacheModel:saveInfoToUserCache(key, info)
    self._userFileInfo[key] = info
    self:saveUserCache()
    if type(self._listeners[key]) == "table" then
        for _, listener in pairs(self._listeners[key]) do
            listener(self._fileInfo[key])
        end
    end
end

function CacheModel:saveUserCache()
    my.saveCache(self:getUserCacheName(), self._userFileInfo)
end

cc.exports.CacheModel = CacheModel:getInstance()

return CacheModel