
local fileutils = cc.FileUtils:getInstance()

local function getLogDir()
    local dir = device.writablePath .. "/pntlog/"
    if not fileutils:isDirectoryExist(dir) then
         fileutils:createDirectory(dir)
    end

    if gDbgConfig.bWin32 then
        return dir
    end
    if DEBUG <= 0 then
        dir = dir.."release/"
    else
        dir = dir .. os.date("%Y%m%d/")
    end
    if not fileutils:isDirectoryExist(dir) then
         fileutils:createDirectory(dir)
    end
    return dir
end

local function updateFileList(szNewFile)
    local path = getLogDir() .. "filelist.txt"
    if szNewFile == "temp.txt" and fileutils:isFileExist(path) then
        return
    end
    local f = io.open(path, "a")
    f:write(szNewFile .. "\n")
    f:close()
end

local function getFileListByDate(szDate)
    if DEBUG <= 0 then
        szDate = "release"
    end
    local dir = string.format("%s/pntlog/%s/", device.writablePath, szDate)
    local path = dir .. "filelist.txt"
    if fileutils:isFileExist(path) then
        local list = {}
        local f = io.open(path, "r")
        while true do
            local line = f:read("*line")
            if not line then break end
            if fileutils:isFileExist(dir .. line) then
                table.insert(list, line)
            end
        end
        f:close()
        return list
    end
    return {}
end
cc.exports.getFileListByDate = getFileListByDate

local userFile
cc.exports.gCurLogPath = getLogDir() .. "temp.txt"
local tempFile = io.open(gCurLogPath, "w")
updateFileList("temp.txt")

local function writeToFile(szStr)
    if not DbgInterface then
        return  
    end
    
    if not userFile then
        local nPlayerId = DbgInterface:getPlayerId()
        if nPlayerId and nPlayerId > 0 then
            if not userFile then
                local fileName = string.format("%s_%s.txt", nPlayerId, os.date("%H%M%S"))
                if gDbgConfig.bWin32 or DEBUG <= 0 then
                    fileName = string.format("release_%s.txt", nPlayerId)
                end
                tempFile:close()
                local isUpdateFileList = true
                if DEBUG <= 0 and fileutils:isFileExist(getLogDir() .. fileName) then
                    local result = os.remove(getLogDir() .. fileName)
                    isUpdateFileList = false
                end
                local result, msg = os.rename(cc.exports.gCurLogPath, getLogDir() .. fileName)
                cc.exports.gCurLogPath = getLogDir() .. fileName
                userFile = io.open(gCurLogPath, "a+")
                if isUpdateFileList then
                    updateFileList(fileName)
                end
            end
        end
    end

    local f = userFile or tempFile
    f:write(szStr)
    f:flush()
end

local function concat(...)
    local tb = {}
    for i=1, select('#', ...) do
        local arg = select(i, ...)  
        tb[#tb+1] = tostring(arg)
    end
    return table.concat(tb, "\t")
end

local function convertSecToTime(localtime)
    local time = math.floor(localtime)
    local day = math.floor(time/86400)
    local hour = math.floor((time-day*86400)/3600)
    local min = math.floor((time-day*86400-hour*3600)/60)
    local sec = math.round(time-day*86400-hour*3600-min*60)
    local msec = localtime*1000-time*1000
    local ddd = tonumber(os.date("%H", 0))
    return day + math.floor((hour + ddd)/24), (hour + ddd)%24, min, sec, msec
end

local old_print = print
function print(...)
    local localtime
    local ok, socket = pcall(function()
        return require("socket")
    end)
    if ok then
        localtime = socket.gettime()
    else
        localtime = os.time()
    end
    local day, hour, min, sec, msec = convertSecToTime(localtime)
    local pntRet = string.format("[%.2d:%.2d:%.2d.%.3d]", hour, min, sec, msec) .. concat(...) .. "\n"
    writeToFile(pntRet)

    if not gDbgConfig.bWin32 and DbgInterface then
        DbgInterface:uploadPrintLog(pntRet)
    end

    old_print(...)
end

if release_print then
    local old_release_print = release_print
    function release_print(...)
        local pntRet = os.date("[%H:%M:%S] ") .. concat(...) .. "\n"
        writeToFile(pntRet)

        if not gDbgConfig.bWin32 and DbgInterface then
            DbgInterface:uploadPrintLog(pntRet)
        end

        old_release_print(...)
    end
end

cc.exports.writeTestLog = function(...)
    local path = getLogDir() .. "test.log"
    local f = io.open(path, "a")
    f:write(concat(...) .. "\n")
    f:close()
end
