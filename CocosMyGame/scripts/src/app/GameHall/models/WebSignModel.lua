
--[[
@描述: 本文件用来维护网页签名
@作者：陈添泽
@日期：2017.11.27
]]

local WebSignModel = {}
cc.exports.WebSignModel = WebSignModel
local webSignCache = {}
local listeners = {}
local AUTO_UPDATE_WEBSIGN = false

local function _collectWesignInfo(dataMap)
    webSignCache.nValidTime = dataMap.nValidSecond + os.clock()
    webSignCache.szWebSign = dataMap.szWebSign
    webSignCache.nUserID = dataMap.nUserID
end

local function _onWebSignGot()
    for _, listener in pairs(listeners) do
        listener(webSignCache.szWebSign)
    end
end

function WebSignModel:getWebSign(callback)
    if UserPlugin:getUserID() == tostring(webSignCache.nUserID) and webSignCache.nValidTime and webSignCache.nValidTime > os.clock() + 5  then --留下5s缓存 防止给的时候能用 实际使用的时候不行了
        if type(callback) == "function" then callback(webSignCache.szWebSign) end
        return webSignCache.szWebSign
    else
        HallRequests:MR_GET_WEBSIGN(function(respondType, data, msgType, dataMap)
            if respondType == mc.UR_OPERATE_SUCCEED then
                _collectWesignInfo(dataMap)
                if type(callback) == "function" then callback(webSignCache.szWebSign) end
                if AUTO_UPDATE_WEBSIGN then
                    my.scheduleOnce(function ()
                        self:getWebSign(callback)
                    end, webSignCache.nValidTime - 1)
                end
                _onWebSignGot()
            end
        end)
        return false
    end
end

function WebSignModel:addWebSignListenerByTag( callback, tag )
    listeners[tag] = callback
end

function WebSignModel:removeWebSignListenerByTag(tag)
    listeners[tag] = nil
end

return WebSignModel