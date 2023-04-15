local RoomDataQuery = class("RoomDataQuery", require('src.app.GameHall.models.BaseModel'))

my.addInstance(RoomDataQuery)

function RoomDataQuery:ctor(delegate)
    self._delegate = delegate
end

function RoomDataQuery:_getPlayersDataOpe()
    return self._delegate:getPlayersData()
end

function RoomDataQuery:_getTablesDataOpe()
    return self._delegate:getTablesData()
end

function RoomDataQuery:_getConfigDataOpe()
    return self._delegate:getConfigData()
end

-- 获取当前有人的桌子数
function RoomDataQuery:queryActivityTableCount()
    return self:_getTablesDataOpe():getActivityTableCount()
end

-- 获取总桌子数
function RoomDataQuery:queryMaxTableCount()
    return self:_getConfigDataOpe():getMaxTableCount()
end

-- 获取桌子信息
function RoomDataQuery:queryTableInfo(tableno)
    return self:_getTablesDataOpe():getTableInfo(tableno)
end

-- 获取玩家列表
function RoomDataQuery:queryAllPlayers()
    return self:_getPlayersDataOpe():getAllPlayers()
end

-- 获取玩家信息
function RoomDataQuery:queryPlayerInfoByUserID(userid)
    return self:_getPlayersDataOpe():getPlayerInfoByUserID(userid)
end

-- 获取玩家信息
function RoomDataQuery:queryPlayerInfoBySeatPosition(tableno, chairno)
    local userid = self:_getTablesDataOpe():getUserIDBySeatPosition(tableno, chairno)
    return self:queryPlayerInfoByUserID(userid)
end

-- 获取桌子上的椅子数量配置
function RoomDataQuery:queryTableChairCount()
    return self:_getConfigDataOpe():getChairCount()
end

-- 获取桌子上的空位
function RoomDataQuery:queryEmptySeat(tableno)
    return self:_getTablesDataOpe():getEmptySeat(tableno)
end

-- 获取桌子上的旁观空位
function RoomDataQuery:queryLookOnSeat(tableno)
    return self:_getTablesDataOpe():getLookOnSeat(tableno)
end

-- 查询好友列表
function RoomDataQuery:queryFriendList()
    return self:_getFriendsDataOpe():getFriendList()
end

-- 查询服务器上的好友列表
function RoomDataQuery:querySvrFriendList()
    return self:_getFriendsDataOpe():getSvrFriendList()
end

-- 查询好友请求列表
function RoomDataQuery:queryFriendApplyList()
    return self:_getFriendsDataOpe():getApplyList()
end

-- 查询在线好友列表
function RoomDataQuery:queryOnlineFriendList()
    local list = self:queryAllPlayers()
    return self:_getFriendsDataOpe():getOnlineFriendList(list)
end

-- 查询空闲在线好友列表
function RoomDataQuery:queryIdelFriendList()
    local list = self:queryAllPlayers()
    return self:_getFriendsDataOpe():getIdelFriendList(list)
end

-- 是否从网站请求了好友
function RoomDataQuery:queryHasQueryFriend()
    return self:_getFriendsDataOpe():hasQueryFriend()
end

-- 是否从网站请求了好友申请
function RoomDataQuery:queryHasQueryFriendApply()
    return self:_getFriendsDataOpe():hasQueryApply()
end

return RoomDataQuery