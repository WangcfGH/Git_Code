local RoomDataUpdate = class("RoomDataUpdate", require('src.app.GameHall.models.BaseModel'))
local DataChangesDef = import("src.app.plugins.AnchorTable.Define.DataChangesDef")
local ActionDef      = import("src.app.plugins.AnchorTable.Define.ActionDef")

my.addInstance(RoomDataUpdate)

function RoomDataUpdate:ctor(delegate)
    self._delegate = delegate
end

function RoomDataUpdate:_getPlayersDataOpe()
    return self._delegate:getPlayersData()
end

function RoomDataUpdate:_getTablesDataOpe()
    return self._delegate:getTablesData()
end

-- 80000
function RoomDataUpdate:GR_PLAYER_ENTERED(player)
    self:_getPlayersDataOpe():playerEnter(player)
    self._delegate:changesNotify(ActionDef.EVENT_PLAYER_ENTERED, nil, nil, player)
end

-- 80001 
-- 快速开始游戏也能监听到这个消息，因为玩家第一次进入的时候，NewTable的时候提供了一个对应的桌子号和座位号，然后坐进去的时候触发这个消息了，这里需要屏蔽下
function RoomDataUpdate:GR_PLAYER_SEATED(ntf_get_seated)
    local currenttableno, currentchairno = self:_getPlayersDataOpe():getPlayerPos(ntf_get_seated.pp.nUserID)
    if currenttableno ~= -1 and (currentchairno ~= ntf_get_seated.pp.nChairNO or currenttableno ~= ntf_get_seated.pp.nTableNO) then -- 位置发生变化，先离桌
        self:_getTablesDataOpe():playerUnSeated({nChairNO = currentchairno, nTableNO = currenttableno, nUserID = ntf_get_seated.pp.nUserID})
        self._delegate:changesNotify(ActionDef.EVENT_PLAYER_UNSEATED, nil, nil, {nChairNO = currentchairno, nTableNO = currenttableno, nUserID = ntf_get_seated.pp.nUserID})
    end
    self:_getTablesDataOpe():playerSeated(ntf_get_seated)
    self:_getPlayersDataOpe():playerSeated(ntf_get_seated)

    self._delegate:changesNotify(ActionDef.EVENT_PLAYER_SEATED, nil, nil, ntf_get_seated)
end

-- 80002
function RoomDataUpdate:GR_PLAYER_UNSEATED(player_position)
    self:_getTablesDataOpe():playerUnSeated(player_position)
    self:_getPlayersDataOpe():playerUnSeated(player_position)

    self._delegate:changesNotify(ActionDef.EVENT_PLAYER_UNSEATED, nil, nil, player_position)
end

--add by masl|xz-lookon
function RoomDataUpdate:GR_PLAYER_LOOKON(player_position)
    local currenttableno, currentchairno = self:_getPlayersDataOpe():getPlayerPos(player_position.nUserID)
    if currenttableno ~= -1 and (currentchairno ~= player_position.nChairNO or currenttableno ~= player_position.nTableNO) then -- 位置发生变化，先离桌
        self:_getTablesDataOpe():playerUnSeated({nChairNO = currentchairno, nTableNO = currenttableno, nUserID = player_position.nUserID})
        self._delegate:changesNotify(ActionDef.EVENT_PLAYER_UNSEATED, nil, nil, {nChairNO = currentchairno, nTableNO = currenttableno, nUserID = player_position.nUserID})
    end
    self:_getTablesDataOpe():playerLookOn(player_position)
    self:_getPlayersDataOpe():playerLookOn(player_position)

    self._delegate:changesNotify(ActionDef.EVENT_PLAYER_LOOKON, nil, nil, player_position)
end

function RoomDataUpdate:GR_PLAYER_UNLOOKON(player_position)
    self:_getTablesDataOpe():playerUnLookOn(player_position)
    self:_getPlayersDataOpe():playerUnLookOn(player_position)

    self._delegate:changesNotify(ActionDef.EVENT_PLAYER_UNLOOKON, nil, nil, player_position)
end
--end add by masl|xz-lookon

-- 80003
function RoomDataUpdate:GR_PLAYER_STARTED(player_position)
    self:_getPlayersDataOpe():playerStarted(player_position)

    self._delegate:changesNotify(ActionDef.EVENT_PLAYER_STARTED, nil, nil, player_position)
end

-- 80004
function RoomDataUpdate:GR_PLAYER_PLAYING(ntf_get_started)
    self:_getTablesDataOpe():playerPlaying(ntf_get_started)
    self:_getPlayersDataOpe():playerPlaying(ntf_get_started)

    self._delegate:changesNotify(ActionDef.EVENT_PLAYER_PLAYING, nil, nil, ntf_get_started)
end

-- 80005
function RoomDataUpdate:GR_PLAYER_LEFT(player_position)
    self:_getPlayersDataOpe():playerLeft(player_position)
    self:_getTablesDataOpe():playerLeft(player_position)

    self._delegate:changesNotify(ActionDef.EVENT_PLAYER_LEFT, nil, nil, player_position)
end

-- 80011
function RoomDataUpdate:GR_PLAYER_LEAVETABLE(player_position)
    self:_getTablesDataOpe():playerUnSeated(player_position)
    self:_getPlayersDataOpe():playerUnSeated(player_position)

    self._delegate:changesNotify(ActionDef.EVENT_PLAYER_LEAVETABLE, nil, nil, player_position)
end

-- 80014
function RoomDataUpdate:GR_PLAYER_NEWTABLE(ntf_get_newtable)
    local currenttableno, currentchairno = self:_getPlayersDataOpe():getPlayerPos(ntf_get_newtable.pp.nUserID)
    if currenttableno ~= -1 and (currentchairno ~= ntf_get_newtable.pp.nChairNO or currenttableno ~= ntf_get_newtable.pp.nTableNO) then -- 位置发生变化，先离桌
        self:_getTablesDataOpe():playerUnSeated({nChairNO = currentchairno, nTableNO = currenttableno, nUserID = ntf_get_newtable.pp.nUserID})
        self._delegate:changesNotify(ActionDef.EVENT_PLAYER_UNSEATED, nil, nil, {nChairNO = currentchairno, nTableNO = currenttableno, nUserID = ntf_get_newtable.pp.nUserID})
    end
    self:_getTablesDataOpe():playerNewTable(ntf_get_newtable)
    self:_getPlayersDataOpe():playerNewTable(ntf_get_newtable)

    self._delegate:changesNotify(ActionDef.EVENT_PLAYER_NEWTABLE, nil, nil, ntf_get_newtable)
end

function RoomDataUpdate:GR_SOLOTABLE_CLOSED(solotable_closed)
    self:_getPlayersDataOpe():soloTableClosed(solotable_closed)
    self:_getTablesDataOpe():soloTableClosed(solotable_closed)

    self._delegate:changesNotify(ActionDef.EVENT_SOLOTABLE_CLOSED, nil, nil, solotable_closed)
end

function RoomDataUpdate:GR_PLAYER_GAMESTARTUP(ntf_gamestartup)
    self:_getPlayersDataOpe():playerGameStartup(ntf_gamestartup)
    self:_getTablesDataOpe():playerGameStartup(ntf_gamestartup)

    self._delegate:changesNotify(ActionDef.EVENT_PLAYER_GAMESTARTUP, nil, nil, ntf_gamestartup)
end

function RoomDataUpdate:GR_PLAYER_GAMEBOUTEND(ntf_gamestartup)
    self:_getPlayersDataOpe():playerGameBoutEnd(ntf_gamestartup)
    self:_getTablesDataOpe():playerGameBoutEnd(ntf_gamestartup)

    self._delegate:changesNotify(ActionDef.EVENT_PLAYER_GAMEBOUTEND, nil, nil, ntf_gamestartup)
end

--每获取一次房间信息的时候都去刷新一下房间
function RoomDataUpdate:MR_GET_ROOM_INFO(ntf_roominfo)
    self:_getPlayersDataOpe():setData(ntf_roominfo.players)
    self:_getTablesDataOpe():setData(ntf_roominfo.tables)

    self._delegate:changesNotify(DataChangesDef.EVENT_ROOM_INFO_REFRESH, nil, nil, ntf_roominfo)
end
--end add by jp

----------------------------------------------------
--             上面是消息响应时更新数据           --
----------------------我是分割线--------------------
--             下面是直接更新数据的接口           --
----------------------------------------------------

-- 删除某条邀请纪录
function RoomDataUpdate:execDelFriendApply(userid)
    self:_getFriendsDataOpe():delApply(userid)
end

-- 过滤某个好友
function RoomDataUpdate:execFilterFriend(userid)
    self:_getFriendsDataOpe():filterFriend(userid)
end

-- 取消过滤某个玩家
function RoomDataUpdate:execCancelFilterFriend(userid)
    self:_getFriendsDataOpe():cancelFilterFriend(userid)
end

-- 增加玩家积分数据
function RoomDataUpdate:execAddPlayerScore(userid, score)
    self:_getPlayersDataOpe():addScore(userid, score)
end

-- 增加玩家胜局信息
function RoomDataUpdate:execAddPlayerWinBout(userid)
    self:_getPlayersDataOpe():addWinBout(userid)
end

-- 增加玩家负局信息
function RoomDataUpdate:execAddPlayerLossBout(userid)
    self:_getPlayersDataOpe():addLossBout(userid)
end

-- 增加玩家平局信息
function RoomDataUpdate:execAddPlayerStandOffBout(userid)
    self:_getPlayersDataOpe():addStandOffBout(userid)
end

-- 获取到玩家头像信息
function RoomDataUpdate:execGetPlayerPortrait(head_info)
    self:_getPlayersDataOpe():getPlayerPortrait(head_info)
end


return RoomDataUpdate