
function my.getGameShortName()
    return BusinessUtils:getInstance():getAbbr()
end

function my.getGameVersion()
    return BusinessUtils:getInstance():getAppVersion()
end

function my.getGameID()
    return BusinessUtils:getInstance():getGameID()
end

function my.getAppAbbrName()
    return my.getAbbrName() .. '_an'
end

function my.getAbbrName()
    return my.getGameShortName()
end

function my.getParentAbbrName()
    return "hask"
end

function my.getAppName()
    return BusinessUtils:getInstance():getAppName()
end

local fileutils=cc.FileUtils:getInstance()
function my.getDataCachePath()
	return fileutils:getGameWritablePath()
end

local function _initDataCachePath()
	local cachepath=my.getDataCachePath()
	if(not fileutils:isDirectoryExist(cachepath))then
		fileutils:createDirectory(cachepath)
	end

	if(DEBUG and DEBUG>0)then
		assert(fileutils:isDirectoryExist(cachepath),'')
	end
end

_initDataCachePath()

function my.getFullCachePath(filename)
	local dataCachePath=my.getDataCachePath()
	local fullpath=dataCachePath..filename
	return fullpath
end

function my.saveCache(filename,data)
	local fullpath=my.getFullCachePath(filename)
	fileutils:writeToFile(data,fullpath)
	printf("~~~~~~~fullpath is~~%s~~~~~~~~~",fullpath)
end

function my.readCache(filename)
	local fullpath=my.getFullCachePath(filename)
	--    local fileutils=cc.FileUtils:getInstance()
	local data=fileutils:getValueMapFromFile(fullpath)
	return data
end

function my.isCacheExist(filename)
	local fullpath=my.getFullCachePath(filename)
	--    local fileutils=cc.FileUtils:getInstance()
	return fileutils:isFileExist(fullpath)
end

-- 判断引擎版本号是否大于1.4.20171130
function my.dealEngineVersion()
    if not BusinessUtils:getInstance().getEngineVersion then return false end
    
    local version = BusinessUtils:getInstance():getEngineVersion()
    local func = string.gmatch(version,  "%w+")
    local index = 1
    local bigVersion, smallVersion, buildNO = 0,0,0
    for str in func do
        if index == 1 then
            bigVersion = tonumber(str)
        elseif index == 2 then
            smallVersion = tonumber(str)
        elseif index == 3 then 
            buildNO = tonumber(str)
        end
        index = index + 1
    end
    if not bigVersion and not smallVersion and not buildNO then return false end

    if bigVersion > 1 then
        return true
    elseif bigVersion == 1 and smallVersion > 4 then
        return true
    elseif bigVersion == 1 and smallVersion == 4 and buildNO >= 20171130 then
        return true
    end
    return false
end

function my.isEngineSupportVersion(version)
    if not BusinessUtils:getInstance().getEngineVersion then return false end

    local curVersion = BusinessUtils:getInstance():getEngineVersion()
    local curMajor, curMinor, curBuildNO = unpack(string.split(curVersion, "."))

    local targetMajor, targetMinor, targetBuildNO = unpack(string.split(version, "."))

    curMajor = string.match(curMajor, "%d")
    targetMajor = string.match(targetMajor, "%d")
    if tonumber(curBuildNO) >= tonumber(targetBuildNO) 
    and (tonumber(curMajor)*100+tonumber(curMinor) >= tonumber(targetMajor)*100+tonumber(targetMinor)) then
        return true
    else
        return false
    end
end

