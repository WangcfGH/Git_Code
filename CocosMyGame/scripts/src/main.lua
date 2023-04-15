local breakSocketHandle,debugXpCall = require("LuaDebugjit")("LocalHost", 7003)
cc.Director:getInstance():getScheduler():scheduleScriptFunc(breakSocketHandle, 0.3, false)

require "mime"
require "socket"
cc.FileUtils:getInstance():setPopupNotify(false)

require "config"
require "src.cocos.init"

require "src.debugtool.init"
require "src.old"

local function getExtension(str)  
    return str:match(".+%.(%w+)$")  
end

local function getFileName(str)  
    local idx = str:match(".+()%.%w+$")  
    if(idx) then  
        return str:sub(1, idx-1)  
    else  
        return str  
    end  
end 

local function getLuaFilelist(path, fileArray)
    local filelistInDir = MCFileUtils:getInstance():lsContents(path)
    for __, filename in pairs(filelistInDir) do
        local tmpPath = path .. filename .. "\\"
        local isDir = cc.FileUtils:getInstance():isDirectoryExist(tmpPath)
        if (filename ~= '.' and filename ~= '..' and isDir) then
            getLuaFilelist(tmpPath, fileArray)
        elseif (filename ~= '.' and filename ~= '..' and ('lua' == getExtension(filename) or 'luac' == getExtension(filename))) then 
            table.insert(fileArray, getFileName(filename))
        end
    end
end

local function wirteDataToLuaFileList(fileList, fullpath)
    local file = io.open(fullpath,"w")
    if not file then return end

    file:write("cc.exports.LuaFileList = {\n")
    for __, filename in pairs(fileList) do
        file:write("    " .. filename .. " = true,\n")
    end
    file:write("}\n\n return cc.exports.LuaFileList")
    file:close()
end

local function createLuaFileList()
    local filelist = {}
    getLuaFilelist(CC_LUA_CODE_PATH, filelist)
    wirteDataToLuaFileList(filelist, CC_LUA_FILE_LIST)
end    

local function main()
    if DEBUG > 0 then
        createLuaFileList()
    end
    cc.FileUtils:getInstance():purgeCachedEntries()
    require('src.app.BaseModule.MyApp'):create():run()
end

local track = __G__TRACKBACK__
__G__TRACKBACK__ = function(...)
    local msg = track(...)

    local analyticsPlugin = plugin.AgentManager:getInstance():getAnalyticsPlugin()
    local timeStamp = socket.gettime() * 1000
    if analyticsPlugin then
        local params = {}
        params["ErrorMessage"] = msg
        params["timeStamp"] = timeStamp
        my.dataLink(cc.exports.DataLinkCodeDef.GAME_STACK_DUMP_EVENT, params)
        analyticsPlugin:logError("errorid", msg)
    end
    if DEBUG > 0 then
        debugXpCall()
        my.informPluginByName({pluginName='ToastPlugin',params={tipString="something bad!!!",removeTime=3}})
    end
    return msg
end

local status, msg = xpcall(main, __G__TRACKBACK__)
if not status then
    local analyticsPlugin = plugin.AgentManager:getInstance():getAnalyticsPlugin()
    if analyticsPlugin then
        analyticsPlugin:logError("errorid", msg)
    end
    release_print(msg)
end
