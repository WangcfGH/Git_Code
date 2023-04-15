local JudgeNewPlayer       = class("JudgeNewPlayer")
local user              = mymodel('UserModel'):getInstance()

JudgeNewPlayer.instance    = nil

-- 单实例
function JudgeNewPlayer.getInstance()
    if not JudgeNewPlayer.instance then
        JudgeNewPlayer.instance = JudgeNewPlayer.new()
    end
    return JudgeNewPlayer.instance
end

-- 获取玩家的总游戏局数
function JudgeNewPlayer:getPlayerBout()
    return user.nBout
end

-- 获取今天日期
function JudgeNewPlayer:getTodayDate()
    local tmYear=os.date('%Y',os.time())
    local tmMon=os.date('%m',os.time())
    local tmMday=os.date('%d',os.time())
    return tmYear.."_"..tmMon.."_"..tmMday
end

function JudgeNewPlayer:getIsNewDataCacheName()
    return "JudgeNewPlayer.xml"
end

-- 读缓存
function JudgeNewPlayer:readIsNewDataCache()
    local dataMap
    local filename = self:getIsNewDataCacheName()
    if(false == my.isCacheExist(filename))then
        return false
    end

    dataMap=my.readCache(filename)
    dataMap=checktable(dataMap)
    local date = self:getTodayDate()
    if (date ~= dataMap.szDate) then
        return false
    end
    print("readIsNewDataCache",filename)
    dump(dataMap)
    return dataMap
end

-- 写缓存
function JudgeNewPlayer:saveCacheIsNew(dataMap)
    local data  = checktable(dataMap)
    dump(data)
    my.saveCache(JudgeNewPlayer:getIsNewDataCacheName(), data)
end


-- 是否新手 1, 新手; 0, 老手; -1, 未获取到局数/userID
function JudgeNewPlayer:isNewPlayer()
    local isNewData = nil -- {isNew: false, date: 2018_04_04}
    local bout = self:getPlayerBout()
    local userID = user.nUserID
    if bout and userID then
        if bout > 0 then
            isNewData = self:readIsNewDataCache()
            if isNewData and isNewData.nUserID == userID and isNewData.nIsNew == 1 then
                return 1
            else
                return 0
            end
        else
            isNewData = {
                nUserID = userID,
                nIsNew = 1,
                szDate = self:getTodayDate(),
            }
            self:saveCacheIsNew(isNewData)
            return 1
        end
    else
        return -1 -- 未获取到局数或者userID
    end
end

return JudgeNewPlayer