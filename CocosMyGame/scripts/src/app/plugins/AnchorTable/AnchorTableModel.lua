local AnchorTableModel  = class('AnchorTableModel',require('src.app.GameHall.models.BaseModel'))
local RoomDataManager   = require("src.app.plugins.AnchorTable.RoomDataManager.RoomDataManager"):getInstance()          --房间数据管理
local UserModel         = mymodel('UserModel'):getInstance()                                                            --玩家信息模块
local ErrDef            = import('src.app.plugins.AnchorTable.Define.ErrDef')                                           --报错模块
local RoomDef           = import("src.app.plugins.AnchorTable.Define.RoomDef")                                          --房间消息模块
local maxPlayerCount    = require("src.app.Game.mMyGame.GamePublicInterface"):getGameTotalPlayerCount()                 --获取一个桌子上的最大玩家数量
local AnchorTableDef    = require('src.app.plugins.AnchorTable.AnchorTableDef')
local MyTimeStamp 		= import('src.app.mycommon.mytimestamp.MyTimeStamp'):getInstance()

my.addInstance(AnchorTableModel) 
my.setmethods(AnchorTableModel,cc.load('coms').PropertyBinder)

AnchorTableModel.EVENT_MAP = {
    --["anchor_gotoRoom"] = "anchor_gotoRoom",
    --["anchor_leaveRoom"] = "anchor_leaveRoom",
}

function AnchorTableModel:onCreate()    
    self._myRoomManager     = nil
    self._tablePassword     = nil
    self._ruleInfo          = nil
    self._lastSelectTableNO = nil
    self._lastSelectChairNO = nil
    self._startGameMode = RoomDef.START_GAME_MODE.MODE_MANUAL  -- 判断用户入桌方式，手动，自动

    self:init()
end

--初始化
function AnchorTableModel:init()
    RoomDataManager:init() -- 房间数据管理初始化
    self:bindKickOffEvent() -- 绑定踢人事件，挖花这个地方需要调整
end

--绑定对应的踢人事件
function AnchorTableModel:bindKickOffEvent()
    local playerModel = mymodel("hallext.PlayerModel"):getInstance()
    self:listenTo(playerModel, playerModel.PLAYER_KICKED_OFF, handler(self,self.onUserKickedOff))
end

--获取游戏开始的模式
function AnchorTableModel:getStartGameMode()
    return self._startGameMode
end

--设置游戏开始的模式
function AnchorTableModel:setStartMode(mode)
    self._startGameMode = mode
end

--当玩家不在游戏中，直接踢出玩家
function AnchorTableModel:onUserKickedOff()
    if my.isInGame() then
        if self._myRoomManager then
            self._myRoomManager:doLeaveCurrentRoom()
        end
    end
end

--设置房间信息
function AnchorTableModel:setData(params)
    RoomDataManager:setData(params)
    self:dispatchEvent({name = AnchorTableDef.ANCHOR_TABLE_ENTER_ROOM_SET_DATA})
end

--清空房间信息
function AnchorTableModel:clearData()
    RoomDataManager:clearData()
end

--进入主播房
function AnchorTableModel:enterRoom()
    if self._myRoomManager then
        self._myRoomManager:doGotoAnchorRoom()
    end
end

-- 离开房间,这里的新手引导先屏蔽
function AnchorTableModel:leaveRoom()
    self:clearData()
    if self._myRoomManager then
        self._myRoomManager:doLeaveCurrentRoom()
    end
end

-- 消息处理 统一让房间数据管理来进行处理
function AnchorTableModel:onNotify(respondType, dataMap)
    RoomDataManager:notify(respondType, dataMap)
end

-- 获得有人的桌子数量
function AnchorTableModel:getActivityTableCount()
    return RoomDataManager:query("ActivityTableCount")
end

-- 获得总桌子数量
function AnchorTableModel:getMaxTableCount()
    return RoomDataManager:query("MaxTableCount")
end

-- 根据桌子号获取桌子信息
function AnchorTableModel:getTableInfo(tableno)
    return RoomDataManager:query("TableInfo",tableno)
end

-- 获取所有玩家的列表
function AnchorTableModel:getAllPlayers()
    return RoomDataManager:query("AllPlayers")
end

-- 获取特定玩家信息
function AnchorTableModel:getPlayerInfoByUserID(userid)
    return RoomDataManager:query("PlayerInfoByUserID",userid)
end

-- 获取某个位置上的玩家信息
function AnchorTableModel:getPlayerInfoBySeatPosition(tableno,chairno)
    return RoomDataManager:query("PlayerInfoBySeatPosition",tableno,chairno)
end

-- 获取桌子上的椅子数配置
function AnchorTableModel:getTableChairCount()
    return RoomDataManager:query("TableChairCount")
end

-- 获取桌子（注：empty为true时，即请求空桌子，否则为快速开始）
--[[
    limit格式:
    limit = {
        szPassword   = "abc",  -- 密码,最大32字节,不写则取默认值""
        nMinScore    = 100,    -- 最低积分,不写则取默认值RoomDef.SCORE_MIN
        nMinDeposit  = 100,    -- 最低银两,不写则取默认值0
        nAllowLookon = 100,    -- 0允许旁观,1禁止旁观,不写则取默认值1
        nWinRate     = 10      -- 最低胜率,不写则取默认值0
    }
]]
-- 请求入桌
function AnchorTableModel:reqTable(limit, empty, callback)    
    callback = callback or function(isSuccess, respondType, nt_dataMap)
        if nt_dataMap and isSuccess == "succeeded" then
            local table = self:getTableInfo(nt_dataMap.nTableNO)
            local nFirstSeatedPlayer = table.nFirstSeatedPlayer
            if table.nPlayerCount == 0 then -- 自己是第一个入桌的
                nFirstSeatedPlayer = UserModel.nUserID
            end
            --开张新桌子
            self:onNotify("GR_PLAYER_NEWTABLE",{
                pp = {
                    nUserID = UserModel.nUserID,
                    nTableNO = nt_dataMap.nTableNO,
                    nChairNO = nt_dataMap.nChairNO
                },
                nFirstSeatedPlayer = nFirstSeatedPlayer,
                nReserved = nt_dataMap.nReserved,
            })
            --桌子信息都在里面
            if self._myRoomManager then
                self._myRoomManager._roomContextOut["tableInfo"] = nt_dataMap
            end
            --通过对应的桌子号锁定座位
            self:dispatchEvent({name = AnchorTableDef.ANCHOR_TABLE_FOCUS_CHAIR_BY_TABLE_NO, value = {tableno = nt_dataMap.nTableNO}})
            --直接进入游戏
            if self._myRoomManager then
                self._myRoomManager:xz_enterGame()
            end
        elseif isSuccess == "failed" then
            if respondType == ErrDef.Common.UR_OPERATE_FAILED then
                local msg = empty and "没有空桌子啦" or "所有桌子都满员了，请换房或者等待空位"
                my.informPluginByName({pluginName='TipPlugin',params={tipString=msg,removeTime=1}})
            elseif respondType == ErrDef.Common.UR_PASSWORD_WRONG then
                local msg = "密码错误"
                my.informPluginByName({pluginName='TipPlugin',params={tipString=msg,removeTime=1}})
            --在这里处理一下对应的错误信息
            elseif not self:_dealErrMsg(respondType) then
                print("快速开始失败:error"..respondType)
            end
        end
    end
    --我们暂时只处理新桌子的情况
    self:MR_GET_NEWTABLE_EX(limit, empty, callback)
end

-- 创建桌子 暂时不需要
function AnchorTableModel:createNewTable(limit, callback)
    self:setStartMode(RoomDef.START_GAME_MODE.MODE_NEW)
    self:reqTable(limit, 1, callback)
end

-- 获取玩家信息 指定玩家的信息
function AnchorTableModel:getPlayerData(userid)
    return self:getAllPlayers()[userid]
end

-- 获取玩家名
function AnchorTableModel:getPlayerName(userid)
    local playerData = self:getAllPlayers()[userid]
    if playerData then 
        return playerData.szUsername
    end
end

-- 获取玩家状态
function AnchorTableModel:getPlayerStatus(userid)
    local playerData = self:getAllPlayers()[userid]
    if playerData then 
        return playerData.nStatus
    end
end

-- 是否游戏中
function AnchorTableModel:gameRunning()
    local status = self:getPlayerStatus(UserModel.nUserID)
    if (status) and (RoomDef.PLAYER_STATUS_PLAYING == status) then 
        return true
    end
    return false
end

-- 上桌（注：不传chairno即让系统自动分配椅子号）
--[[
    limit格式:
    limit = {
        szPassword   = "abc",  -- 密码,最大32字节,不写则取默认值""
        nMinScore    = 100,    -- 最低积分,不写则取默认值RoomDef.SCORE_MIN
        nMinDeposit  = 100,    -- 最低银两,不写则取默认值0
        nAllowLookon = 100,    -- 0允许旁观,1禁止旁观,不写则取默认值1
        nWinRate     = 10      -- 最低胜率,不写则取默认值0
    }
]]
--请求对应的桌位，我们这里能够拿到对应的携带银信息 点击桌子和点击座位是不一样的
function AnchorTableModel:reqSeat(tableno, chairno, limit, force, bInvite, callback)
    -- add by masl|xz 检查房间限制
    local invite    = checkbool(bInvite) and 1 or 0
    local tableInfo = self:getTableInfo(tableno)
    if 1 ~= invite and tableInfo and not limit then
        local nWinRate = (0==UserModel.nBout) and 0 or (UserModel.nWin / UserModel.nBout)
        if nWinRate * 100 < tableInfo.nReserved[1] then
            my.informPluginByName({pluginName='TipPlugin',params={tipString="您的胜率小于上桌限制",removeTime=1}})
            return
        end
        if UserModel.nScore < tableInfo.nMinScore then
            my.informPluginByName({pluginName='TipPlugin',params={tipString="您的积分小于上桌限制",removeTime=1}})
            return
        elseif UserModel.nDeposit < tableInfo.nMinDeposit then
            my.informPluginByName({pluginName='TipPlugin',params={tipString="您的银子小于上桌限制",removeTime=1}})
            return
        end
        if 1 == tableInfo.bHavePassword then
            my.informPluginByName({pluginName='TipPlugin',params={tipString="该桌子设置了密码，无法入座",removeTime=1}})
            --self:showPasswordCtrl(tableno, chairno, force, callback)
            return
        end
    end
    -- end add by masl|xz 检查房间限制
    callback = callback or function(isSuccess, respondType, nt_dataMap)
        if nt_dataMap and isSuccess == "succeeded" then
            local table = self:getTableInfo(nt_dataMap.nTableNO)
            local nFirstSeatedPlayer = table.nFirstSeatedPlayer
            if table.nPlayerCount == 0 then -- 自己是第一个入桌的
                nFirstSeatedPlayer = UserModel.nUserID
            end
            self:onNotify("GR_PLAYER_NEWTABLE",{
                pp = {
                    nUserID = UserModel.nUserID,
                    nTableNO = nt_dataMap.nTableNO,
                    nChairNO = nt_dataMap.nChairNO
                },
                nFirstSeatedPlayer = nFirstSeatedPlayer,
                nReserved = nt_dataMap.nReserved,
            })

            if self._myRoomManager then
                self._myRoomManager._roomContextOut["tableInfo"] = nt_dataMap
            end
            self:dispatchEvent({name = AnchorTableDef.ANCHOR_TABLE_FOCUS_CHAIR_BY_TABLE_NO, value = {tableno = nt_dataMap.nTableNO}})    
            if self._myRoomManager then
                self._myRoomManager:xz_enterGame()
            end
        elseif isSuccess == "failed" then
            if respondType == ErrDef.Common.UR_OPERATE_FAILED then
                my.informPluginByName({pluginName='TipPlugin',params={tipString="上桌失败",removeTime=1}})
            elseif respondType == ErrDef.Common.UR_OBJECT_EXIST then                
                self:reqAgainSeat()
            elseif respondType == ErrDef.Common.UR_PASSWORD_WRONG then
                my.informPluginByName({pluginName='TipPlugin',params={tipString="密码错误",removeTime=1}})
            elseif respondType == ErrDef.Common.GR_NO_CHAIRS then
                my.informPluginByName({pluginName='TipPlugin',params={tipString="该桌子已满，请尝试其他桌子",removeTime=1}})
            elseif respondType == ErrDef.Common.GR_NO_CHAIRS then
                my.informPluginByName({pluginName='TipPlugin',params={tipString="该桌子已满，请尝试其他桌子",removeTime=1}})
            elseif respondType == ErrDef.Common.GR_MINSCORE_FORBIDDEN then
                my.informPluginByName({pluginName='TipPlugin',params={tipString="您的积分小于上桌限制",removeTime=1}})
            elseif respondType == ErrDef.Common.GR_MINDEPOSIT_FORBIDDEN then
                my.informPluginByName({pluginName='TipPlugin',params={tipString="您的银子小于上桌限制",removeTime=1}})
            elseif respondType == ErrDef.Common.GR_MINWINRATE_FORBIDDEN then
                my.informPluginByName({pluginName='TipPlugin',params={tipString="您的胜率小于上桌限制",removeTime=1}})
            elseif not self:_dealErrMsg(respondType) then
                print("快速开始失败:error"..respondType)
            end
        end
    end

    --请求座位，进入游戏
    self:MR_GET_SEATED_AND_START(tableno, chairno, limit, force, invite, callback)
end

-- 强制上桌(注：先尝试上传过来的椅子号，如果失败则尝试上目前空的椅子号直到桌子满了)
function AnchorTableModel:reqSeatForce(tableno, chairno, limit, bInvite, callback)
    self:reqSeat(tableno, chairno or -1, limit, 1, bInvite, callback)
end

-- 重新请求入座
function AnchorTableModel:reqAgainSeat()
    if self._lastSelectTableNO and self._lastSelectChairNO then
        local tableInfo = RoomDataManager:query("TableInfo", self._lastSelectTableNO)
        if not self:haveAnchorPlayer(self._lastSelectTableNO) then
            my.informPluginByName({pluginName='TipPlugin',params={tipString="主播已散桌",removeTime=3}})
            self:reqResume()
            return
        end

        if tableInfo.nPlayerCount >= 4 then
            my.informPluginByName({pluginName='TipPlugin',params={tipString="该桌子已满，您晚了一步哦",removeTime=3}})
            return
        end

        for i=1, 4 do
            if tableInfo.nPlayerAry[i] == nil then
                local limit = nil
                if self._tablePassword then
                    limit = {szPassword = self._tablePassword}
                end
                my.informPluginByName({pluginName='TipPlugin',params={tipString="座位上有人，系统自动给您分配新座位了哈！",removeTime=3}})
                self:reqSeat(self._lastSelectTableNO, i - 1, limit)
                return
            end
        end
    end    
end

--处理错误信息
function AnchorTableModel:_dealErrMsg(respondType)
    local ril=import('src.app.GameHall.models.mcsocket.RequestIdList')
    local roomStrings = cc.load('json').loader.loadFile('RoomStrings.json')

    if respondType == ErrDef.TcyFriend.ERR_IN_BLACKLIST then
        my.informPluginByName({pluginName='TipPlugin',params={tipString="对方是您的黑名单成员",removeTime=1}})
    elseif respondType == ErrDef.TcyFriend.ERR_MARK_TOOLONG then
        my.informPluginByName({pluginName='TipPlugin',params={tipString="备注信息过长",removeTime=1}})
    elseif respondType == ErrDef.TcyFriend.ERR_HUANXIN_SEND then
        my.informPluginByName({pluginName='TipPlugin',params={tipString="发送环信消息失败",removeTime=1}})
    elseif respondType == ErrDef.TcyFriend.ERR_INVITE_STATE then
        my.informPluginByName({pluginName='TipPlugin',params={tipString="邀请操作状态不正确",removeTime=1}})
    elseif respondType == ErrDef.TcyFriend.ERR_FRIEND_FULL then
        my.informPluginByName({pluginName='TipPlugin',params={tipString="对方好友数量已满",removeTime=1}})
    elseif respondType == ErrDef.TcyFriend.ERR_AREADY_DEAL then
        my.informPluginByName({pluginName='TipPlugin',params={tipString="您已经处理过这个请求",removeTime=1}})
    elseif respondType == ErrDef.TcyFriend.ERR_ADD_USER then
        my.informPluginByName({pluginName='TipPlugin',params={tipString="添加用户错误",removeTime=1}})
    elseif respondType == ErrDef.TcyFriend.ERR_USER_UNEXIST then
        my.informPluginByName({pluginName='TipPlugin',params={tipString="该用户不存在",removeTime=1}})
    elseif respondType == ErrDef.TcyFriend.ERR_AREADY_FRIEND then
        my.informPluginByName({pluginName='TipPlugin',params={tipString="此人已经是你的好友了",removeTime=1}})
    elseif respondType == ErrDef.TcyFriend.ERR_OPE_CACHE then
        my.informPluginByName({pluginName='TipPlugin',params={tipString="操作缓存错误",removeTime=1}})
    elseif respondType == ErrDef.TcyFriend.ERR_FRIEND_NOT_FOUND then
        my.informPluginByName({pluginName='TipPlugin',params={tipString="该好友不存在",removeTime=1}})
    elseif respondType == ErrDef.TcyFriend.ERR_FRIEND_EXCEPTION then
        -- 网站bug,不予提示 -- modify by jinp|xz
        -- my.informPluginByName({pluginName='TipPlugin',params={tipString="捕获异常",removeTime=1}})
    elseif respondType == ErrDef.TcyFriend.ERR_CALL_HUANXIN then
        my.informPluginByName({pluginName='TipPlugin',params={tipString="调用环信接口错误",removeTime=1}})
    elseif respondType == ErrDef.TcyFriend.ERR_OPE_DATABASE then
        my.informPluginByName({pluginName='TipPlugin',params={tipString="操作数据库错误",removeTime=1}})
    elseif respondType == ErrDef.TcyFriend.ERR_REQUEST_EXPIRED then
        my.informPluginByName({pluginName='TipPlugin',params={tipString="这条申请已失效",removeTime=1}})
    elseif respondType == ErrDef.TcyFriend.ERR_SELF_FRIEND_FULL then
        my.informPluginByName({pluginName='TipPlugin',params={tipString="您的好友数量已满",removeTime=1}})
    elseif respondType == ErrDef.TcyFriend.ERR_ADD_SELF then
        my.informPluginByName({pluginName='TipPlugin',params={tipString="您不能添加自己为好友",removeTime=1}})
    elseif respondType == ErrDef.TcyFriend.ERR_AUTH_INVALID then
        my.informPluginByName({pluginName='TipPlugin',params={tipString="认证数据不合法",removeTime=1}})
    elseif respondType == ErrDef.TcyFriend.ERR_TOKEN_EXPIRED then
        my.informPluginByName({pluginName='TipPlugin',params={tipString="授权令牌已过期",removeTime=1}})
    elseif respondType == ErrDef.TcyFriend.ERR_TOKEN_INVALID then
        my.informPluginByName({pluginName='TipPlugin',params={tipString="无效的授权令牌",removeTime=1}})
    elseif respondType == ErrDef.TcyFriend.ERR_TOKEN_ILLEGAL then
        my.informPluginByName({pluginName='TipPlugin',params={tipString="不合法的授权令牌",removeTime=1}})
    elseif respondType == ErrDef.TcyFriend.ERR_USERID_ILLEGAL then
        my.informPluginByName({pluginName='TipPlugin',params={tipString="不合法的用户编号",removeTime=1}})
    elseif respondType == ErrDef.TcyFriend.ERR_APPID_ILLEGAL then
        my.informPluginByName({pluginName='TipPlugin',params={tipString="不合法的应用编号",removeTime=1}})
    elseif respondType == ErrDef.TcyFriend.ERR_INVALID_REQUEST then
        my.informPluginByName({pluginName='TipPlugin',params={tipString="无效的请求参数",removeTime=1}})
    elseif respondType == ErrDef.TcyFriend.ERR_NOT_ENOUGH_AUTH then
        my.informPluginByName({pluginName='TipPlugin',params={tipString="没有足够的权限",removeTime=1}})
    elseif respondType == ErrDef.TcyFriend.ERR_IP_LIMIT then
        my.informPluginByName({pluginName='TipPlugin',params={tipString="好友系统：IP被限制",removeTime=1}})
    elseif respondType == ErrDef.TcyFriend.ERR_SERVICE_PAUSE then
        my.informPluginByName({pluginName='TipPlugin',params={tipString="好友系统：服务暂停",removeTime=1}})
    elseif respondType == ErrDef.TcyFriend.ERR_SERVICE_EXCEPT then
        my.informPluginByName({pluginName='TipPlugin',params={tipString="好友系统：服务异常",removeTime=1}})
    elseif ril.RespondIdReflact[respondType] and roomStrings[ril.RespondIdReflact[respondType]] then
        local msg = roomStrings[ril.RespondIdReflact[respondType]]
        my.informPluginByName({pluginName='TipPlugin',params={tipString=msg,removeTime=1}})
    elseif DEBUG and DEBUG > 0 then
        local msg = string.format("error：%d", respondType)
        my.informPluginByName({pluginName='TipPlugin',params={tipString=msg,removeTime=3}})
    else
        return false
    end
    return true
end

-- 获取房间信息，定时刷新对应房间信息
function AnchorTableModel:reqGetRoomInfo(callback)
    callback = callback or function(isSuccess, respondType, nt_dataMap)
        if isSuccess == "succeeded" then
            self:onNotify("MR_GET_ROOM_INFO",{players=nt_dataMap[2], tables=nt_dataMap[3]})
        elseif isSuccess == "failed" then
            if not self:_dealErrMsg(respondType) then
                print("获取房间信息失败:error"..respondType)
            end
        end
    end
    self:MR_GET_ROOM_INFO(callback)
end

-- 发送唤醒请求 切后台回来之后请求消息
function AnchorTableModel:reqResume(callback)    
    callback = callback or function(isSuccess, respondType, nt_dataMap)
        print("发送唤醒返回")
        self:resume(respondType, nt_dataMap)
    end
    self:MR_XZ_RESUME(callback)
end

--切后台操作：唤醒玩家重刷桌子
function AnchorTableModel:resume(...)
    self:dispatchEvent({name = AnchorTableDef.ANCHOR_TABLE_RESUME_TABLE_CTRL})
end

--获取座位并自动开始(请求响应)
function AnchorTableModel:MR_GET_SEATED_AND_START(tableno, chairno, limit, force, invite, callback)
    if self._myRoomManager then
        self._myRoomManager:MR_GET_SEATED_AND_START(tableno, chairno, limit, force, invite, callback)
    end
end

--新建桌子并自动开始(请求响应)
function AnchorTableModel:MR_GET_NEWTABLE_EX(limit, empty, callback)
    if self._myRoomManager then
        self._myRoomManager:MR_GET_NEWTABLE_EX(limit, empty, callback)
    end
end

--选坐界面唤醒(请求响应)
function AnchorTableModel:MR_XZ_RESUME(callback)
    if self._myRoomManager then
        self._myRoomManager:MR_XZ_RESUME(callback)
    end
end

--获取房间信息(请求响应)
function AnchorTableModel:MR_GET_ROOM_INFO(callback)
    if self._myRoomManager then
        self._myRoomManager:MR_GET_ROOM_INFO(callback)
    end
end

--判断是否是主播
function AnchorTableModel:isAnchorUser(nUserID)
    local myUserID = nUserID
    local anchorPlayNum = cc.exports.getAnchorPlayerNum()
    local anchorPlayUseID = cc.exports.getAnchorPlayerUseID()
    for i=1, anchorPlayNum do
        for j=1, #anchorPlayUseID["Anchor_"..i] do
            if anchorPlayUseID["Anchor_"..i][j] == myUserID then
                return true
            end
        end
    end

    return false
end

--获取该玩家是第几个主播以及这个主播的第几个号
function AnchorTableModel:getAnchorIndexserIdIndex(nUserID)
    local myUserID = nUserID
    local anchorPlayNum = cc.exports.getAnchorPlayerNum()
    local anchorPlayUseID = cc.exports.getAnchorPlayerUseID()
    for i=1, anchorPlayNum do
        for j=1, #anchorPlayUseID["Anchor_"..i] do
            if anchorPlayUseID["Anchor_"..i][j] == myUserID then
                return i, j
            end
        end
    end

    return nil, nil
end

--获取该渠道的主播UserID
function AnchorTableModel:anchorUserIDByChannelID()
    local userIDs = {}
    local tcyChannelId = my.getTcyChannelId()
    local anchorPlayNum = cc.exports.getAnchorPlayerNum()
    local anchorPlayUseID = cc.exports.getAnchorPlayerUseID()
    for i=1, anchorPlayNum do
        for j=1, #anchorPlayUseID["Anchor_"..i] do
            table.insert(userIDs, anchorPlayUseID["Anchor_"..i][j])
        end
    end
    return userIDs
end

--获取主播桌号
function AnchorTableModel:anchorTableNO(nUserID)
    local anchorIndex, anchorUserIdIndex = self:getAnchorIndexserIdIndex(nUserID)
    if anchorIndex and anchorUserIdIndex then
        local anchorPlayUseTableNO = cc.exports.getAnchorPlayerUseTableNO()
        if anchorPlayUseTableNO and anchorPlayUseTableNO["Anchor_"..anchorIndex] and anchorPlayUseTableNO["Anchor_"..anchorIndex][anchorUserIdIndex] then
            local tableNO = anchorPlayUseTableNO["Anchor_"..anchorIndex][anchorUserIdIndex]
            local spiltIndex = string.find(tableNO, "-")
            local talbeStartNO = string.sub(tableNO, 1, spiltIndex -1)
            local talbeEndNO = string.sub(tableNO, spiltIndex + 1)
            return talbeStartNO, talbeEndNO
        end
    end

    return nil, nil
end

--获取主播时间
function AnchorTableModel:anchorTime(nUserID)
    local anchorIndex, anchorUserIdIndex = self:getAnchorIndexserIdIndex(nUserID)
    if anchorIndex and anchorUserIdIndex then
        local anchorPlayUseTime = cc.exports.getAnchorPlayerUseTime()
        if anchorPlayUseTime and anchorPlayUseTime["Anchor_"..anchorIndex] and anchorPlayUseTime["Anchor_"..anchorIndex][anchorUserIdIndex] then
            local anchorTime = anchorPlayUseTime["Anchor_"..anchorIndex][anchorUserIdIndex]
            local startHour = math.modf(anchorTime/1000000)
            local startMinute = math.modf((anchorTime % 1000000) / 10000)
            local endHour = math.modf((anchorTime % 10000) / 100)
            local endMinute = anchorTime % 100
            return startHour * 100 + startMinute, endHour * 100 + endMinute
        end
    end

    return nil, nil
end

-- 获取当前时间(格式：HHMM)
function AnchorTableModel:getCurrentHourMiu()
    local nowtimestamp = MyTimeStamp:getLatestTimeStamp()
    if nowtimestamp == 0 then
        nowtimestamp = os.time()
    end
    local strTime = os.date("%H%M%S", nowtimestamp)
    local curHourMiu = math.modf(tonumber(strTime) / 100)

    return curHourMiu
end

-- 获取秘钥
function AnchorTableModel:getTablePassword()
    return self._tablePassword
end

-- 设置秘钥
function AnchorTableModel:setTablePassword(password)
    self._tablePassword = password
end

-- 获取规则
function AnchorTableModel:getTableRule()
    return self._ruleInfo
end

-- 设置规则
function AnchorTableModel:setTableRule(ruleInfo)
    self._ruleInfo = ruleInfo
end

-- 获取最后入座的桌号和座位号
function AnchorTableModel:getLastSeletInfo()
    return self._lastSelectTableNO, self._lastSelectChairNO
end

-- 设置最后入座的桌号和座位号
function AnchorTableModel:setLastSeletInfo(tableNO, chairNO)
    self._lastSelectTableNO = tableNO
    self._lastSelectChairNO = chairNO
end

-- 判断桌子是否有主播
function AnchorTableModel:haveAnchorPlayer(tableNO)
    local tableInfo = RoomDataManager:query("TableInfo", tableNO)
	for i=1, 4 do
        if tableInfo.nPlayerAry and tableInfo.nPlayerAry[i] then
            if AnchorTableModel:isAnchorUser(tableInfo.nPlayerAry[i]) then
				return true
			end
        end
    end

	return false
end

return AnchorTableModel