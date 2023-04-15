local RoomTablesData = class("RoomTablesData")
local RoomDef = import("src.app.plugins.AnchorTable.Define.RoomDef")
local MAX_CHAIR_COUNT = 8
local MAX_VISITOR_COUNT = 8

function RoomTablesData:create(roomDataManager)
    self._delegate = roomDataManager
    self._tablesInfo = {}
end

function RoomTablesData:setData(tables)
    self._tablesInfo = tables
end

function RoomTablesData:clearData()
    self._tablesInfo = {}
end

function RoomTablesData:_newTable(tableno)
    if self._tablesInfo[tableno] then return end
    self._tablesInfo[tableno] = {
        nReserved          = {[1]=0},
        bHavePassword      = 0,
        nVisitorAry        = {},
        nPlayerAry         = {},
        nTableDeposit      = 0,
        nFirstSeatedPlayer = -1,
        nStatus            = RoomDef.TABLE_STATUS_STATIC,
        nMinScore          = -2000000000,
        nMinDeposit        = 0,
        nVisitorCount      = 0,
        nPlayerCount       = 0,
        nTableNO           = tableno
    }
end

function RoomTablesData:_changeValue(curTable, id, newValue)
    if not curTable then return end
    local oldvalue = nil
    local switch = {
        [DataChangesDef.EVENT_TABLE_FIRST_SEATED] = function(callback)
            oldvalue = curTable.nFirstSeatedPlayer
            if oldvalue == newValue then return end
            curTable.nFirstSeatedPlayer = newValue
            callback()
        end,
        [DataChangesDef.EVENT_TABLE_MINSCORE] = function(callback)
            oldvalue = curTable.nMinScore
            if oldvalue == newValue then return end
            curTable.nMinScore = newValue
            callback()
        end,
        [DataChangesDef.EVENT_TABLE_MINDEPOSIT] = function(callback)
            oldvalue = curTable.nMinDeposit
            if oldvalue == newValue then return end
            curTable.nMinDeposit = newValue
            callback()
        end,
        [DataChangesDef.EVENT_TABLE_MINWINBOUT] = function(callback)
            oldvalue = curTable.nReserved[1]
            if oldvalue == newValue then return end
            curTable.nReserved[1] = newValue
            callback()
        end,
        [DataChangesDef.EVENT_TABLE_PASSWORD] = function(callback)
            oldvalue = curTable.bHavePassword
            if oldvalue == newValue then return end
            curTable.bHavePassword = newValue
            callback()
        end,
        [DataChangesDef.EVENT_TABLE_STATUS] = function(callback)
            oldvalue = curTable.nStatus
            if oldvalue == newValue then return end
            curTable.nStatus = newValue
            callback()
        end,
        [DataChangesDef.EVENT_TABLE_CHANGECHAIR1] = function(callback)
            oldvalue = curTable.nPlayerAry[1]
            if oldvalue == newValue then return end
            curTable.nPlayerAry[1] = newValue
            callback()
        end,
        [DataChangesDef.EVENT_TABLE_CHANGECHAIR2] = function(callback)
            oldvalue = curTable.nPlayerAry[2]
            if oldvalue == newValue then return end
            curTable.nPlayerAry[2] = newValue
            callback()
        end,
        [DataChangesDef.EVENT_TABLE_CHANGECHAIR3] = function(callback)
            oldvalue = curTable.nPlayerAry[3]
            if oldvalue == newValue then return end
            curTable.nPlayerAry[3] = newValue
            callback()
        end,
        [DataChangesDef.EVENT_TABLE_CHANGECHAIR4] = function(callback)
            oldvalue = curTable.nPlayerAry[4]
            if oldvalue == newValue then return end
            curTable.nPlayerAry[4] = newValue
            callback()
        end,
        [DataChangesDef.EVENT_TABLE_CHANGECHAIR5] = function(callback)
            oldvalue = curTable.nPlayerAry[5]
            if oldvalue == newValue then return end
            curTable.nPlayerAry[5] = newValue
            callback()
        end,
        [DataChangesDef.EVENT_TABLE_CHANGECHAIR6] = function(callback)
            oldvalue = curTable.nPlayerAry[6]
            if oldvalue == newValue then return end
            curTable.nPlayerAry[6] = newValue
            callback()
        end,
        [DataChangesDef.EVENT_TABLE_CHANGECHAIR7] = function(callback)
            oldvalue = curTable.nPlayerAry[7]
            if oldvalue == newValue then return end
            curTable.nPlayerAry[7] = newValue
            callback()
        end,
        [DataChangesDef.EVENT_TABLE_CHANGECHAIR8] = function(callback)
            oldvalue = curTable.nPlayerAry[8]
            if oldvalue == newValue then return end
            curTable.nPlayerAry[8] = newValue
            callback()
        end,
        [DataChangesDef.EVENT_TABLE_PLAYER_COUNT] = function(callback)
            oldvalue = curTable.nPlayerCount
            if oldvalue == newValue then return end
            curTable.nPlayerCount = newValue
            callback()
        end,
        [DataChangesDef.EVENT_TABLE_LOOKER_ENTER1] = function(callback)
            if not curTable.nVisitorAry[1] then
                curTable.nVisitorAry[1] = {}
            elseif not table.indexof(curTable.nVisitorAry[1], newValue) then
                return
            end
            table.insert(curTable.nVisitorAry[1], newValue)
            callback()
        end,
        [DataChangesDef.EVENT_TABLE_LOOKER_ENTER2] = function(callback)
            if not curTable.nVisitorAry[2] then
                curTable.nVisitorAry[2] = {}
            elseif not table.indexof(curTable.nVisitorAry[2], newValue) then
                return
            end
            table.insert(curTable.nVisitorAry[2], newValue)
            callback()
        end,
        [DataChangesDef.EVENT_TABLE_LOOKER_ENTER3] = function(callback)
            if not curTable.nVisitorAry[3] then
                curTable.nVisitorAry[3] = {}
            elseif not table.indexof(curTable.nVisitorAry[3], newValue) then
                return
            end
            table.insert(curTable.nVisitorAry[3], newValue)
            callback()
        end,
        [DataChangesDef.EVENT_TABLE_LOOKER_ENTER4] = function(callback)
            if not curTable.nVisitorAry[4] then
                curTable.nVisitorAry[4] = {}
            elseif not table.indexof(curTable.nVisitorAry[4], newValue) then
                return
            end
            table.insert(curTable.nVisitorAry[4], newValue)
            callback()
        end,
        [DataChangesDef.EVENT_TABLE_LOOKER_ENTER5] = function(callback)
            if not curTable.nVisitorAry[5] then
                curTable.nVisitorAry[5] = {}
            elseif not table.indexof(curTable.nVisitorAry[5], newValue) then
                return
            end
            table.insert(curTable.nVisitorAry[5], newValue)
            callback()
        end,
        [DataChangesDef.EVENT_TABLE_LOOKER_ENTER6] = function(callback)
            if not curTable.nVisitorAry[6] then
                curTable.nVisitorAry[6] = {}
            elseif not table.indexof(curTable.nVisitorAry[6], newValue) then
                return
            end
            table.insert(curTable.nVisitorAry[6], newValue)
            callback()
        end,
        [DataChangesDef.EVENT_TABLE_LOOKER_ENTER7] = function(callback)
            if not curTable.nVisitorAry[7] then
                curTable.nVisitorAry[7] = {}
            elseif not table.indexof(curTable.nVisitorAry[7], newValue) then
                return
            end
            table.insert(curTable.nVisitorAry[7], newValue)
            callback()
        end,
        [DataChangesDef.EVENT_TABLE_LOOKER_ENTER8] = function(callback)
            if not curTable.nVisitorAry[8] then
                curTable.nVisitorAry[8] = {}
            elseif not table.indexof(curTable.nVisitorAry[8], newValue) then
                return
            end
            table.insert(curTable.nVisitorAry[8], newValue)
            callback()
        end,
        [DataChangesDef.EVENT_TABLE_LOOKER_ABORT1] = function(callback)
            if not curTable.nVisitorAry[1] then return end
            if 0 < table.removebyvalue(curTable.nVisitorAry[1], newValue, true) then
                callback()
            end
        end,
        [DataChangesDef.EVENT_TABLE_LOOKER_ABORT2] = function(callback)
            if not curTable.nVisitorAry[2] then return end
            if 0 < table.removebyvalue(curTable.nVisitorAry[2], newValue, true) then
                callback()
            end
        end,
        [DataChangesDef.EVENT_TABLE_LOOKER_ABORT3] = function(callback)
            if not curTable.nVisitorAry[3] then return end
            if 0 < table.removebyvalue(curTable.nVisitorAry[3], newValue, true) then
                callback()
            end
        end,
        [DataChangesDef.EVENT_TABLE_LOOKER_ABORT4] = function(callback)
            if not curTable.nVisitorAry[4] then return end
            if 0 < table.removebyvalue(curTable.nVisitorAry[4], newValue, true) then
                callback()
            end
        end,
        [DataChangesDef.EVENT_TABLE_LOOKER_ABORT5] = function(callback)
            if not curTable.nVisitorAry[5] then return end
            if 0 < table.removebyvalue(curTable.nVisitorAry[5], newValue, true) then
                callback()
            end
        end,
        [DataChangesDef.EVENT_TABLE_LOOKER_ABORT6] = function(callback)
            if not curTable.nVisitorAry[6] then return end
            if 0 < table.removebyvalue(curTable.nVisitorAry[6], newValue, true) then
                callback()
            end
        end,
        [DataChangesDef.EVENT_TABLE_LOOKER_ABORT7] = function(callback)
            if not curTable.nVisitorAry[7] then return end
            if 0 < table.removebyvalue(curTable.nVisitorAry[7], newValue, true) then
                callback()
            end
        end,
        [DataChangesDef.EVENT_TABLE_LOOKER_ABORT8] = function(callback)
            if not curTable.nVisitorAry[8] then return end
            if 0 < table.removebyvalue(curTable.nVisitorAry[8], newValue, true) then
                callback()
            end
        end,
        [DataChangesDef.EVENT_TABLE_VISITOR_COUNT] = function(callback)
            oldvalue = curTable.nVisitorCount
            if oldvalue == newValue then return end
            curTable.nVisitorCount = newValue
            callback()
        end,
    }
    if switch[id] then
        switch[id](function()
            self._delegate:changesNotify(id, curTable.nTableNO, oldvalue, newValue)
        end)
    end
end

function RoomTablesData:_getTable(tableno)
    if tableno < 0 then return end
    self:_newTable(tableno)
    return self._tablesInfo[tableno]
end

-- 获取有人的桌子的数量
function RoomTablesData:getActivityTableCount()
    return #self._tablesInfo
end

-- 根据桌子号获取桌子信息
function RoomTablesData:getTableInfo(tableno)
    return self:_getTable(tableno)
end

function RoomTablesData:getUserIDBySeatPosition(tableno,chairno)
    local userid = -1
    local table = self._tablesInfo[tableno]
    if table then
        if table.nPlayerAry[chairno+1] then
            userid = table.nPlayerAry[chairno+1]
        end
    end
    return userid
end

function RoomTablesData:getEmptySeat(tableno)
    local chairno = -1
    local table = self._tablesInfo[tableno]
    if table then
        for i=1, MAX_CHAIR_COUNT do
            if not table.nPlayerAry[i] or table.nPlayerAry[i] < 0 then
                chairno = i-1
                break
            end
        end
    end
    return chairno
end

function RoomTablesData:getLookOnSeat(tableno)
    local chairno = -1
    local table = self._tablesInfo[tableno]
    if table then
        for i=1, MAX_CHAIR_COUNT do
            if not table.nVisitorAry or not table.nVisitorAry[i] or #table.nVisitorAry[i] < MAX_VISITOR_COUNT then
                chairno = i-1
                break
            end
        end
    end
    return chairno
end

----------------------------------------------------------------------------------------------------------------

-- 玩家上桌
function RoomTablesData:playerSeated(ntf_get_seated)
    if not ntf_get_seated.pp.nTableNO then return end
    local table = self:_getTable(ntf_get_seated.pp.nTableNO)
    if not table then
        print("can't find table "..ntf_get_seated.pp.nTableNO.." in room, player get seat failed")
        return
    end
    self:_changeValue(table, DataChangesDef["EVENT_TABLE_CHANGECHAIR"..ntf_get_seated.pp.nChairNO+1], ntf_get_seated.pp.nUserID)
    self:_changeValue(table, DataChangesDef.EVENT_TABLE_FIRST_SEATED, ntf_get_seated.nFirstSeatedPlayer)
    if ntf_get_seated.nMinScore then
        self:_changeValue(table, DataChangesDef.EVENT_TABLE_MINSCORE, ntf_get_seated.nMinScore)
    end
    if ntf_get_seated.nMinDeposit then
        self:_changeValue(table, DataChangesDef.EVENT_TABLE_MINDEPOSIT, ntf_get_seated.nMinDeposit)
    end
    if ntf_get_seated.szPassword then
        local bHavePassword = ('' == ntf_get_seated.szPassword) and 0 or 1
        self:_changeValue(table, DataChangesDef.EVENT_TABLE_PASSWORD, bHavePassword)  -- 设置密码限制
    end
    local playerUnSeated = true
    for i=1, 4 do
        if table.nPlayerAry and table.nPlayerAry[i] and table.nPlayerAry[i] == ntf_get_seated.pp.nUserID then
            playerUnSeated = false
        end
    end
    if playerUnSeated then
        self:_changeValue(table, DataChangesDef.EVENT_TABLE_PLAYER_COUNT, table.nPlayerCount + 1)
    end
end

-- 玩家离桌
function RoomTablesData:playerUnSeated(player_position)
    if not player_position.nTableNO then 
        printError("playerUnSeated not table")
        return 
    end
    local table = self:_getTable(player_position.nTableNO)
    if not table then
        print("can't find table "..player_position.nTableNO.." in room, player get unseat failed")
        return
    end

    -- 第一个人离桌需要清空桌子的积分限制
    if player_position.nUserID == table.nFirstSeatedPlayer then
        self:_changeValue(table, DataChangesDef.EVENT_TABLE_MINSCORE, RoomDef.SCORE_MIN)
        self:_changeValue(table, DataChangesDef.EVENT_TABLE_MINDEPOSIT, 0)
        self:_changeValue(table, DataChangesDef.EVENT_TABLE_MINWINBOUT, 0)  -- 清除胜率限制
        self:_changeValue(table, DataChangesDef.EVENT_TABLE_PASSWORD, 0) -- 清除密码限制
    end

    self:_changeValue(table, DataChangesDef["EVENT_TABLE_CHANGECHAIR"..player_position.nChairNO+1], nil)
    self:_changeValue(table, DataChangesDef.EVENT_TABLE_PLAYER_COUNT, table.nPlayerCount - 1)
end

-- 玩家开始旁观
function RoomTablesData:playerLookOn(player_position)
    if not player_position.nTableNO then return end
    local table = self:_getTable(player_position.nTableNO)
    if not table then
        print("can't find table "..ntf_get_lookon.pp.nTableNO.." in room, player get lookon failed")
        return
    end
    self:_changeValue(table, DataChangesDef["EVENT_TABLE_LOOKER_ENTER"..player_position.nChairNO+1], player_position.nUserID)
    self:_changeValue(table, DataChangesDef.EVENT_TABLE_VISITOR_COUNT, table.nVisitorCount + 1)
end

-- 玩家结束旁观
function RoomTablesData:playerUnLookOn(player_position)
    if not player_position.nTableNO then return end
    local table = self:_getTable(player_position.nTableNO)
    if not table then
        print("can't find table "..player_position.nTableNO.." in room, player get unlookon failed")
        return
    end
    
    self:_changeValue(table, DataChangesDef["EVENT_TABLE_LOOKER_ABORT"..player_position.nChairNO+1], player_position.nUserID)
    self:_changeValue(table, DataChangesDef.EVENT_TABLE_VISITOR_COUNT, table.nVisitorCount - 1)
end

-- 玩家游戏中
function RoomTablesData:playerPlaying(ntf_get_started)
    local table = self:_getTable(ntf_get_started.pp.nTableNO)
    if not table then
        print("can't find table "..ntf_get_started.pp.nTableNO.." in room, player playing failed")
        return
    end
    self:_changeValue(table,DataChangesDef.EVENT_TABLE_STATUS, RoomDef.TABLE_STATUS_PLAYING)
end

-- 强制散桌
function RoomTablesData:soloTableClosed(solotable_closed)
    local table = self:_getTable(solotable_closed.nTableNO)
    if not table then
        print("can't find table "..solotable_closed.nTableNO.." in room, game soloTableClosed failed")
        return
    end
    self:_changeValue(table, DataChangesDef.EVENT_TABLE_MINSCORE, RoomDef.SCORE_MIN)
    self:_changeValue(table, DataChangesDef.EVENT_TABLE_MINDEPOSIT, 0)
    self:_changeValue(table, DataChangesDef.EVENT_TABLE_MINWINBOUT, 0)  -- 清除胜率限制
    self:_changeValue(table, DataChangesDef.EVENT_TABLE_PASSWORD, 0) -- 清除密码限制

    for i=1, MAX_CHAIR_COUNT do
        self:_changeValue(table, DataChangesDef["EVENT_TABLE_CHANGECHAIR"..i], nil)
    end
    self:_changeValue(table, DataChangesDef.EVENT_TABLE_PLAYER_COUNT, 0)
    self:_changeValue(table,DataChangesDef.EVENT_TABLE_STATUS, RoomDef.TABLE_STATUS_STATIC)
end

-- 游戏开局
function RoomTablesData:playerGameStartup(ntf_gamestartup)
    local table = self:_getTable(ntf_gamestartup.nTableNO)
    if not table then
        print("can't find table "..ntf_gamestartup.nTableNO.." in room, game startup failed")
        return
    end
    self:_changeValue(table,DataChangesDef.EVENT_TABLE_STATUS, RoomDef.TABLE_STATUS_PLAYING)
end

-- 游戏结束
function RoomTablesData:playerGameBoutEnd(ntf_gamestartup)
    local table = self:_getTable(ntf_gamestartup.nTableNO)
    if not table then
        print("can't find table "..ntf_gamestartup.nTableNO.." in room, game bout end failed")
        return
    end
    self:_changeValue(table,DataChangesDef.EVENT_TABLE_STATUS, RoomDef.TABLE_STATUS_STATIC)
end

function RoomTablesData:playerLeft(player_position)
    if not player_position.nTableNO then return end
    local table = self:_getTable(player_position.nTableNO)
    if not table then
        print("can't find table "..player_position.nTableNO.." in room, player left failed")
        return
    end

    -- 第一个人离桌需要清空桌子的积分限制
    if player_position.nUserID == table.nFirstSeatedPlayer then
        self:_changeValue(table, DataChangesDef.EVENT_TABLE_MINSCORE, RoomDef.SCORE_MIN)
        self:_changeValue(table, DataChangesDef.EVENT_TABLE_MINDEPOSIT, 0)
        self:_changeValue(table, DataChangesDef.EVENT_TABLE_MINWINBOUT, 0)  -- 清除胜率限制
        self:_changeValue(table, DataChangesDef.EVENT_TABLE_PASSWORD, 0) -- 清除密码限制
    end

    self:_changeValue(table, DataChangesDef["EVENT_TABLE_CHANGECHAIR"..player_position.nChairNO+1], nil)
    self:_changeValue(table, DataChangesDef.EVENT_TABLE_PLAYER_COUNT, table.nPlayerCount - 1)
end

-- 玩家位置变化，比如换桌换座
function RoomTablesData:playerNewTable(ntf_get_newtable)
    if not ntf_get_newtable.pp.nTableNO then return end
    local table = self:_getTable(ntf_get_newtable.pp.nTableNO)
    if not table then
        print("can't find table "..ntf_get_newtable.pp.nTableNO.." in room, player get new table failed")
        return
    end
    self:_changeValue(table, DataChangesDef["EVENT_TABLE_CHANGECHAIR"..ntf_get_newtable.pp.nChairNO+1], ntf_get_newtable.pp.nUserID)
    self:_changeValue(table, DataChangesDef.EVENT_TABLE_FIRST_SEATED, ntf_get_newtable.nFirstSeatedPlayer)
    if ntf_get_newtable.nMinScore then
        self:_changeValue(table, DataChangesDef.EVENT_TABLE_MINSCORE, ntf_get_newtable.nMinScore)
    end
    if ntf_get_newtable.nMinDeposit then
        self:_changeValue(table, DataChangesDef.EVENT_TABLE_MINDEPOSIT, ntf_get_newtable.nMinDeposit)
    end
    if ntf_get_newtable.nReserved[1] then
        self:_changeValue(table, DataChangesDef.EVENT_TABLE_PASSWORD, ntf_get_newtable.nReserved[1])  -- 设置密码限制
    end
    if ntf_get_newtable.nReserved[2] then
        self:_changeValue(table, DataChangesDef.EVENT_TABLE_MINWINBOUT, ntf_get_newtable.nReserved[2])  -- 设置胜率限制
    end
    --设置玩家数量
    self:_changeValue(table, DataChangesDef.EVENT_TABLE_PLAYER_COUNT, table.nPlayerCount + 1)
end

return RoomTablesData