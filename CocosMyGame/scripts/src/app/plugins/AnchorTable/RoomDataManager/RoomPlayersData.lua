local RoomPlayersData = class("RoomPlayersData")
local DataChangesDef = import("src.app.plugins.AnchorTable.Define.DataChangesDef")
local RoomDef = import("src.app.plugins.AnchorTable.Define.RoomDef")

function RoomPlayersData:create(roomDataManager)
    self._delegate = roomDataManager
    self._playersInfo = {}
end

function RoomPlayersData:setData(players)
    self._playersInfo = players
    
    -- add by masl|玩家姓名和性别以本地数据为准
	local userModel = mymodel('UserModel'):getInstance()
    for _i, _v in pairs(self._playersInfo) do
        if _v.nUserID == userModel.nUserID then
            _v.szUsername = userModel.szUsername
            _v.nNickSex   = userModel.nNickSex
            break
        end
    end
    -- end add by masl|--
end

function RoomPlayersData:clearData()
    self._playersInfo = {}
end

function RoomPlayersData:_changeValue(player, id, newValue)
    if not player then return end
    local oldvalue = nil
    local switch = {
        [DataChangesDef.EVENT_PLAYER_TABLENO] = function(callback)
            oldvalue = player.nTableNO
            if oldvalue == newValue then return end
            player.nTableNO = newValue
            callback()
        end,
        [DataChangesDef.EVENT_PLAYER_CHAIRNO] = function(callback)
            oldvalue = player.nChairNO
            if oldvalue == newValue then return end
            player.nChairNO = newValue
            callback()
        end,
        [DataChangesDef.EVENT_PLAYER_NETSPEED] = function(callback)
            oldvalue = player.nNetSpeed
            if oldvalue == newValue then return end
            player.nNetSpeed = newValue
            callback()
        end,
        [DataChangesDef.EVENT_PLAYER_STATUS] = function(callback)
            oldvalue = player.nStatus
            if oldvalue == newValue then return end
            player.nStatus = newValue
            callback()
        end,
        [DataChangesDef.EVENT_PLAYER_PORTRAIT] = function(callback)
            oldvalue = player.pngHead
            if oldvalue == newValue then return end
            player.pngHead = newValue
            callback()
        end,
    }
    if switch[id] then
        switch[id](function()
            self._delegate:changesNotify(id, player.nUserID, oldvalue, newValue)
        end)
    end
end

function RoomPlayersData:_findPlayer(userid)
    return self._playersInfo[userid]
end

function RoomPlayersData:_playerPosChange(player, player_position)
    if not player or not player_position then return end
    self:_changeValue(player, DataChangesDef.EVENT_PLAYER_TABLENO, player_position.nTableNO)
    self:_changeValue(player, DataChangesDef.EVENT_PLAYER_CHAIRNO, player_position.nChairNO)
    if player_position.nNetDelay then
        self:_changeValue(player, DataChangesDef.EVENT_PLAYER_NETSPEED, player_position.nNetDelay)
    end
end

function RoomPlayersData:getAllPlayers()
    return self._playersInfo
end

function RoomPlayersData:getPlayerInfoByUserID(userid)
    return self:_findPlayer(userid)
end

function RoomPlayersData:getPlayerPos(userid)
    local player = self:_findPlayer(userid)
    if not player then return end
    return player.nTableNO, player.nChairNO
end

---------------------------------------------------------------------------------------------------------------------

-- 玩家进入数据变更
function RoomPlayersData:playerEnter(player)
    local oldValue = self._playersInfo[player.nUserID]
    self._playersInfo[player.nUserID] = player
    self._delegate:changesNotify(DataChangesDef.EVENT_PLAYER_NEW, player.nUserID, oldValue, player)
end

-- 玩家上桌
function RoomPlayersData:playerSeated(ntf_get_seated)
    local player = self:_findPlayer(ntf_get_seated.pp.nUserID)
    if not player then
        print("can't find player "..ntf_get_seated.pp.nUserID.." in room, player seated failed")
        return
    end
    self:_playerPosChange(player, ntf_get_seated.pp)
    self:_changeValue(player, DataChangesDef.EVENT_PLAYER_STATUS, RoomDef.PLAYER_STATUS_SEATED)
end

-- 玩家准备
function RoomPlayersData:playerStarted(player_position)
    local player = self:_findPlayer(player_position.nUserID)
    if not player then
        print("can't find player "..player_position.nUserID.." in room, player get start failed")
        return
    end
    self:_playerPosChange(player, player_position)
    self:_changeValue(player, DataChangesDef.EVENT_PLAYER_STATUS, RoomDef.PLAYER_STATUS_WAITING)
end

-- 玩家离桌
function RoomPlayersData:playerUnSeated(player_position)
    local player = self:_findPlayer(player_position.nUserID)
    if not player then
        print("can't find player "..player_position.nUserID.." in room, player unseated failed")
        return
    end
    self:_changeValue(player, DataChangesDef.EVENT_PLAYER_TABLENO, -1)
    self:_changeValue(player, DataChangesDef.EVENT_PLAYER_CHAIRNO, -1)
    self:_changeValue(player, DataChangesDef.EVENT_PLAYER_STATUS, RoomDef.PLAYER_STATUS_WALKAROUND)
end

-- 玩家开始旁观
function RoomPlayersData:playerLookOn(player_position)
    local player = self:_findPlayer(player_position.nUserID)
    if not player then
        print("can't find player "..player_position.nUserID.." in room, player lookon failed")
        return
    end
    self:_playerPosChange(player, player_position)
    self:_changeValue(player, DataChangesDef.EVENT_PLAYER_STATUS, RoomDef.PLAYER_STATUS_LOOKON)
end

-- 玩家结束旁观
function RoomPlayersData:playerUnLookOn(player_position)
    local player = self:_findPlayer(player_position.nUserID)
    if not player then
        print("can't find player "..player_position.nUserID.." in room, player unlookon failed")
        return
    end
    self:_changeValue(player, DataChangesDef.EVENT_PLAYER_TABLENO, -1)
    self:_changeValue(player, DataChangesDef.EVENT_PLAYER_CHAIRNO, -1)
    self:_changeValue(player, DataChangesDef.EVENT_PLAYER_STATUS, RoomDef.PLAYER_STATUS_WALKAROUND)
end

-- 玩家游戏中
function RoomPlayersData:playerPlaying(ntf_get_started)
    local player = self:_findPlayer(ntf_get_started.pp.nUserID)
    if not player then
        print("can't find player "..ntf_get_started.pp.nUserID.." in room, player playing failed")
        return
    end
    self:_playerPosChange(player, ntf_get_started.pp)
    self:_changeValue(player, DataChangesDef.EVENT_PLAYER_STATUS, RoomDef.PLAYER_STATUS_PLAYING)
    for k,v in ipairs(ntf_get_started.nPlayerAry) do
        if v ~= 0 then
            local player = self:_findPlayer(v)
            if not player then
                print("can't find player "..v.." in room, player playing failed2")
                return
            end
            self:_changeValue(player, DataChangesDef.EVENT_PLAYER_TABLENO, ntf_get_started.pp.nTableNO)
            self:_changeValue(player, DataChangesDef.EVENT_PLAYER_CHAIRNO, k-1)
            self:_changeValue(player, DataChangesDef.EVENT_PLAYER_STATUS, RoomDef.PLAYER_STATUS_PLAYING)
        end
    end
end

-- 玩家离开房间
function RoomPlayersData:playerLeft(player_position)
    local oldValue = self._playersInfo[player_position.nUserID]
    self._playersInfo[player_position.nUserID] = nil
    self._delegate:changesNotify(DataChangesDef.EVENT_PLAYER_NEW, player_position.nUserID, oldValue, nil)
end

-- 强制散桌
function RoomPlayersData:soloTableClosed(solotable_closed)
    for k,v in ipairs(solotable_closed.nUserIDs) do
        if v ~= 0 then
            local player = self:_findPlayer(v)
            if not player then
                print("can't find player "..v.." in room, game soloTableClosed failed")
                return
            end
            self:_changeValue(player, DataChangesDef.EVENT_PLAYER_TABLENO, -1)
            self:_changeValue(player, DataChangesDef.EVENT_PLAYER_CHAIRNO, -1)
            self:_changeValue(player, DataChangesDef.EVENT_PLAYER_STATUS, RoomDef.PLAYER_STATUS_WALKAROUND)
        end
    end
end

-- 游戏开局
function RoomPlayersData:playerGameStartup(ntf_gamestartup)
    for k,v in ipairs(ntf_gamestartup.nPlayerAry) do
        if v ~= 0 then
            local player = self:_findPlayer(v)
            if not player then
                print("can't find player "..v.." in room, game startup failed")
                return
            end
            self:_changeValue(player, DataChangesDef.EVENT_PLAYER_TABLENO, ntf_gamestartup.nTableNO)
            self:_changeValue(player, DataChangesDef.EVENT_PLAYER_CHAIRNO, k-1)
            self:_changeValue(player, DataChangesDef.EVENT_PLAYER_STATUS, RoomDef.PLAYER_STATUS_PLAYING)
        end
    end
end

-- 游戏结束
function RoomPlayersData:playerGameBoutEnd(ntf_gamestartup)
    for k,v in ipairs(ntf_gamestartup.nPlayerAry) do
        if v ~= 0 then
            local player = self:_findPlayer(v)
            if not player then
                print("can't find player "..v.." in room, game startup failed")
                return
            end
            self:_changeValue(player, DataChangesDef.EVENT_PLAYER_TABLENO, ntf_gamestartup.nTableNO)
            self:_changeValue(player, DataChangesDef.EVENT_PLAYER_CHAIRNO, k-1)
            self:_changeValue(player, DataChangesDef.EVENT_PLAYER_STATUS, RoomDef.PLAYER_STATUS_WAITING)
        end
    end
end

-- 玩家位置变化，比如换桌换座
function RoomPlayersData:playerNewTable(ntf_get_newtable)
    local player = self:_findPlayer(ntf_get_newtable.pp.nUserID)
    if not player then
        print("can't find player "..ntf_get_newtable.pp.nUserID.." in room, player playing failed")
        return
    end
    self:_playerPosChange(player, ntf_get_newtable.pp)
end

---------------------------------------------------------------------------------------------------------------------

-- 增加玩家积分数据
function RoomPlayersData:addScore(userid, score)
    if not userid or 'number' ~= type(userid) then return end
    if not score or 'number' ~= type(score) then return end

    for _i, _v in pairs(self._playersInfo) do
        if _v.nUserID == userid then
            _v.nScore = _v.nScore + score
            break
        end
    end
end

-- 增加玩家胜局信息
function RoomPlayersData:addWinBout(userid)
    if not userid or 'number' ~= type(userid) then return end

    for _i, _v in pairs(self._playersInfo) do
        if _v.nUserID == userid then
            _v.nWin = _v.nWin + 1
            _v.nBout = _v.nBout + 1
            break
        end
    end
end

-- 增加玩家负局信息
function RoomPlayersData:addLossBout(userid)
    if not userid or 'number' ~= type(userid) then return end

    for _i, _v in pairs(self._playersInfo) do
        if _v.nUserID == userid then
            _v.nLoss = _v.nLoss + 1
            _v.nBout = _v.nBout + 1
            break
        end
    end
end

-- 增加玩家平局信息
function RoomPlayersData:addStandOffBout(userid)
    if not userid or 'number' ~= type(userid) then return end

    for _i, _v in pairs(self._playersInfo) do
        if _v.nUserID == userid then
            _v.nStandOff = _v.nStandOff + 1
            _v.nBout = _v.nBout + 1
            break
        end
    end
end

-- 获取到玩家头像信息
function RoomPlayersData:getPlayerPortrait(head_info)
    if not head_info then return end
    if not head_info.userID then return end
    if not head_info.path or '' == head_info.path then return end

    local player = self:_findPlayer(head_info.userID)
    if not player then
        print("can't find player "..head_info.userID.." in room")
        return
    end
    self:_changeValue(player, DataChangesDef.EVENT_PLAYER_PORTRAIT, head_info.path)
end

return RoomPlayersData