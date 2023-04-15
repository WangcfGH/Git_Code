--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local YQWImageCtrl = class("YQWImageCtrl")

local imageLoaderPlugin

imageLoaderPlugin = plugin.AgentManager:getInstance():getImageLoaderPlugin()

local usersTable = {}
local callbackTags = {}

--[Comment]
--callback 装饰器， 将callback和tag相关联
local function callbackDecorator(callbackFunc, tag)
    if tag then
        assert(not callbackTags[tag], string.format("tag:%s already used", tostring(tag)))

        callbackTags[tag] = true
        return function( ... )
            if callbackTags[tag] then
                callbackFunc( ... )
            end
            callbackTags[tag] = nil
        end
    else
        return callbackFunc
    end
end

local function dealCallback(url, code, path, callbackFunc, tag)
    print("code = "..code)
    print("code == cc.exports.ImageLoadActionResultCode.kImageLoadOnlineSuccess"..code == cc.exports.ImageLoadActionResultCode.kImageLoadOnlineSuccess)
    if code == cc.exports.ImageLoadActionResultCode.kImageLoadOnlineSuccess then -- 有效数据才缓存下
        print("cache image "..(url or "").." : "..(path or ""))
        usersTable[url] = path
    end
    print('online image get')
    callbackFunc(code, path)
end

function YQWImageCtrl:getUserImage(userid, url, callbackFunc, tag)
    callbackFunc = callbackDecorator(callbackFunc, tag)
    if not usersTable[url] then -- 该url没有缓存
        if not imageLoaderPlugin["loadOnlineImage"] then
            callbackFunc(cc.exports.ImageLoadActionResultCode.kImageLoadOnlineFailed, '')
            return
        end
        imageLoaderPlugin:loadOnlineImage(userid, url, "300-300", function(code,path)
            dealCallback(url, code, path, callbackFunc)
        end)
    else -- 存在缓存用缓存
        print("use cache:" .. url)
        callbackFunc(cc.exports.ImageLoadActionResultCode.kImageLoadOnlineSuccess,usersTable[url])
    end
end

local FileUtils = cc.FileUtils:getInstance()
function YQWImageCtrl:getUserhuodongImage(url, callbackFunc, tag)
    callbackFunc = callbackDecorator(callbackFunc, tag)
    if not url then
        callbackFunc(cc.exports.ImageLoadActionResultCode.kImageLoadOnlineFailed, '')
        return
    end
    if string.find(url, "gif$") then
        printError("gif not support on cocos")
        callbackFunc(cc.exports.ImageLoadActionResultCode.kImageLoadOnlineFailed, '')
        return
    end
    if my.isEngineSupportVersion("v1.3.20170516") and false then
        if not usersTable[url] then -- 该url没有缓存
            if not imageLoaderPlugin["loadOnlineImage"] then
                my.popTip("不支持imageLoaderPlugin:loadOnlineImage") 
                callbackFunc(cc.exports.ImageLoadActionResultCode.kImageLoadOnlineFailed, '')
                return
            end
            imageLoaderPlugin:loadOnlineImage(url, function(code,path)
                dealCallback(url, code, path, callbackFunc)
            end)
        else -- 存在缓存用缓存
            callbackFunc(cc.exports.ImageLoadActionResultCode.kImageLoadOnlineSuccess,usersTable[url])
        end
    else
        local imageName = string.match(url, ".+/([^/]*%.%w+)$")
        if not imageName then
            callbackFunc(cc.exports.ImageLoadActionResultCode.kImageLoadOnlineFailed, '')
            return
        end

        local imagePath = FileUtils:getGameWritablePath() .. imageName
        if FileUtils:isFileExist(imagePath) then
            dealCallback(url, cc.exports.ImageLoadActionResultCode.kImageLoadOnlineSuccess, imagePath, callbackFunc)
        else
            local xhr = cc.XMLHttpRequest:new()
            xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
            xhr:open("GET", url)
            local function downloadImage()
                print("xhr.readyState is:", xhr.readyState, "xhr.status is: ", xhr.status)
                if xhr.readyState == 4 and (xhr.status >= 200 and xhr.status < 207) then
                    local file = io.open(imagePath, "wb")
                    file:write(xhr.response)
                    file:close()
                    dealCallback(url, cc.exports.ImageLoadActionResultCode.kImageLoadOnlineSuccess, imagePath, callbackFunc)
                else
                    callbackFunc(cc.exports.ImageLoadActionResultCode.kImageLoadOnlineFailed, '')
                end
            end
            xhr:registerScriptHandler(downloadImage)
            xhr:send()
        end
    end
end

function YQWImageCtrl:removeCallbackByTag( tag )
    callbackTags[tag] = nil
end

return YQWImageCtrl

--endregion
