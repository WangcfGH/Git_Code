
if nil == cc or nil == cc.exports then
    return
end

local SKGameDef                                 = import("src.app.Game.mSKGame.SKGameDef")

local JSON = cc.load("json").json
require("src.cocos.cocos2d.bitExtend")

cc.exports.GamePublicInterface                  = {}
local GamePublicInterface                       = cc.exports.GamePublicInterface

GamePublicInterface.OFFLINE_ROOM_ID             = -2000
GamePublicInterface.ROOM_OPT_NEEDDEPOSIT        = 0x00000004
GamePublicInterface.ROOM_CFG_RANDOM             = 0x00000002
GamePublicInterface.ROOM_CFG_CLOAKING           = 0x00000008

GamePublicInterface._gameString                 = nil
GamePublicInterface._gameController             = nil

function GamePublicInterface:IS_FRAME_1()
    return false
end

function GamePublicInterface:getGameFlags()
    return SKGameDef.SK_GF_USE_JOKER--[[SKGameDef.SK_GF_ABT_A_END--]]
end

function GamePublicInterface:IS_BIT_SET(flag, mybit) return (mybit == bit._and(mybit, flag)) end

--[[function GamePublicInterface:getQuickStartRoomID(rooms)
    local quickStartRoomID = self.OFFLINE_ROOM_ID
    
    local roomlist = clone(rooms)
    if roomlist and #roomlist > 0 then    -- 对房间排个序
        table.sort(roomlist, function(a, b)
            if a.min ~= b.min then
                return a.min > b.min 
            end
            return a.order > b.order 
        end)
    end

    if DEBUG and DEBUG == 1 then
        for i = 1, #roomlist do
            local roomImpl = roomlist[i].original
            if roomImpl then
                print("getQuickStartRoomID  ",roomImpl.nRoomID)
            end
        end
    end
    
    for i = 1, #roomlist do
        local roomImpl = roomlist[i].original
        if roomImpl and roomImpl.dwConfigs then
            if self.OFFLINE_ROOM_ID ~= roomImpl.nRoomID
                    and GamePublicInterface:IS_BIT_SET(roomImpl.dwConfigs, self.ROOM_CFG_RANDOM) then
                quickStartRoomID = roomImpl.nRoomID
                break
            end
        end
    end

    for i = 1, #roomlist do
        local roomImpl = roomlist[i].original
        if roomImpl then
            if self.OFFLINE_ROOM_ID ~= roomImpl.nRoomID then
                quickStartRoomID = roomImpl.nRoomID
                break
            end
        end
    end

    local user=mymodel('UserModel'):getInstance()
    if user.nScore == nil then
        user.nScore = 0
    end
    if user.nDeposit == nil then
        user.nDeposit = 0
    end

    local roomsTemp = {}
    local countTemp = 1
    for i = 1, #roomlist do      
        local roomImpl = roomlist[i]
        if roomImpl and roomImpl.area == nil and roomImpl["option"] == 1 and roomImpl["type"] ~= 9 then
            roomsTemp[countTemp] = roomImpl
            countTemp = countTemp + 1
        end
    end
    
    local minRoom
    local bestRoom
    local bFindRoomID = false;

    for i = 1, #roomsTemp do
        local roomImpl = roomsTemp[i].original
        local nextRoomImpl = nil
        if roomsTemp[i+1] then
            nextRoomImpl = roomsTemp[i+1].original
        end
        if not nextRoomImpl then
            -- 下一个房间是空，说明已经到最高级房了
            bestRoom = roomImpl
            --bFindRoomID = true
            --break
           local noJumpRoom = false
           if user.nDeposit > roomImpl.nMaxDeposit then
                 noJumpRoom = true  
           end

           return bestRoom.nRoomID,  noJumpRoom
        end
        
        if roomImpl then 
            -- 判断玩家携带银 是否符合当前房间
            if self.OFFLINE_ROOM_ID ~= roomImpl.nRoomID and
                user.nDeposit >= roomImpl.nMinDeposit and user.nDeposit <= roomImpl.nMaxDeposit then
                    bestRoom = roomImpl
                    bFindRoomID = true
                    break
            end
            
            if self.OFFLINE_ROOM_ID ~= roomImpl.nRoomID and -- 银两超大的时候，因为房间顺序是从大到小排列的
                user.nDeposit >= roomImpl.nMaxDeposit then
                    bestRoom = roomImpl
                    bFindRoomID = true
                    break
            end

        end
    end

    if bFindRoomID == true then -- 竞技场roomsTemp为空，故bestRoom和minRoom都是nil。 这导致了竞技场银两富余情况下开始挑战 按钮没反应。
    -- 这里做个保护（存银计算竞技场自己有arenaRoomInfo可以计算），详情见canGoToRoomForDeposit
        if bestRoom ~= nil then
            quickStartRoomID = bestRoom.nRoomID
        end
    end
    
    return quickStartRoomID
end]]--

--获取进阶提示房间号
--[[function GamePublicInterface:getPromptTipRoomID(rooms, nPromptLine, nRoomID)
    --初始化promptTipRoomID
    local promptTipRoomID  = self.OFFLINE_ROOM_ID
    local promptTipRoomMin = 0


    local function tabSort(a, b)
        if a.original.nMinDeposit ~= b.original.nMinDeposit then
            return a.original.nMinDeposit < b.original.nMinDeposit
        end
        return a.original.nRoomID < b.original.nRoomID
    end


    --获取携银
    local user=mymodel('UserModel'):getInstance()
    if user.nDeposit == nil then
        user.nDeposit = 0
    end

    --获取可见房
    local roomsTemp = {}
    for i = 1, #rooms do      
        local roomImpl = rooms[i]
        if roomImpl and roomImpl.area == nil and roomImpl["option"] == 1 and roomImpl["type"] ~= 9 then
            roomsTemp[#roomsTemp + 1] = roomImpl
        end
    end
    if next(roomsTemp) ~= nil then
        table.sort(roomsTemp,tabSort)

        local curIndex = 1
        for i = 1, #roomsTemp do
            local roomImpl = roomsTemp[i].original
            if nRoomID == roomImpl.nRoomID then
                curIndex = i -- 拿到当前所在房间的下标
            end
        end
        local roomImpl = roomsTemp[curIndex].original
        promptTipRoomID = roomImpl.nRoomID
        promptTipRoomMin = roomImpl.nMinDeposit
    end

    --获取提示房，能够进的最小房间
    for i = 1, #roomsTemp do
        local roomImpl = roomsTemp[i].original
        
        if nRoomID ~= roomImpl.nRoomID then
            if user.nDeposit >= roomImpl.nMinDeposit and user.nDeposit <= roomImpl.nMaxDeposit and nPromptLine >= roomImpl.nMinDeposit then
                if roomImpl.nMinDeposit > promptTipRoomMin then
                    promptTipRoomID = roomImpl.nRoomID
                    promptTipRoomMin = roomImpl.nMinDeposit
                    break
                end
            end
        end
    end

    return promptTipRoomID,promptTipRoomMin
end]]--

function GamePublicInterface:getGameString(key)
    if not self._gameString then
        local jsonGameString = cc.FileUtils:getInstance():getStringFromFile("src/app/Game/mMyGame/GameString.json")
        self._gameString = JSON.decode(jsonGameString)
    end

    if self._gameString then
        return self._gameString[key]
    end

    return nil
end

function GamePublicInterface:setGameController(gameController)
    self._gameController = gameController
end

function GamePublicInterface:onNotifyAdminMsgToRoom(msg)
    if self._gameController then
    --self._gameController:onNotifyAdminMsgToRoom(msg)
    end
end

function GamePublicInterface:onNotifyKickedOffByAdmin()
    if self._gameController then
        self._gameController:onNotifyKickedOffByAdmin()
    end
end

function GamePublicInterface:onNotifyKickedOffByLogonAgain()
    if self._gameController then
        self._gameController:onNotifyKickedOffByLogonAgain()
    end
end

function GamePublicInterface:onNotifyKickedOffByRoomPlayer()
    if self._gameController then
        self._gameController:onNotifyKickedOffByAdmin()
    end
end

function GamePublicInterface:onQuitFromRoom()
    if self._gameController then
        self._gameController:onQuitFromRoom()
    end
end

function GamePublicInterface:getGameTotalPlayerCount()
    MyGameDef = require("src.app.Game.mMyGame.MyGameDef")
    return MyGameDef.MY_TOTAL_PLAYERS
end

function GamePublicInterface:getRemiandRoundCount()
    return 5
    --to do by game
end

--[[function GamePublicInterface:applyToCharteredRoom()
    if self._gameController then
        self._gameController._baseGameConnect:gc_LeaveGame_forChangetable()
    end
end]]--

function GamePublicInterface:quitDirect()
    if self._gameController then
        self._gameController:quitDirect()
    end
end

function GamePublicInterface:isTableFull()
    if self._gameController then
        return self._gameController:isTableFull()
    end
    return false
end

function GamePublicInterface:IsPlayerInTable(userID)
    if self._gameController then
        return self._gameController:IsPlayerInTable(userID)
    end
    return false
end

function GamePublicInterface:GetCurrentTableNO()
    if self._gameController then
        return self._gameController:GetCurrentTableNO()
    end
    return -1
end

function GamePublicInterface:GetCharteredRoomHostName()
    if self._gameController then
        return self._gameController:GetCharteredRoomHostName()
    end
    return ""
end

function GamePublicInterface:GetCharteredRoomHostID()
    if self._gameController then
        return self._gameController:GetCharteredRoomHostID()
    end
    return 0
end

--[[function GamePublicInterface:GetFilterAreaID()
    return nil, 2639, 635 ,1708, 2909 -- yourAreaID , nowash, ceshi, shuihu, niuniu
    --return nil, nil, nil, nil  -- yourAreaID , nowash, ceshi, shuihu
end]]--

function GamePublicInterface:GetGameControllerConfig(key)
    if not self._gameControllerConfig then
        local jsonGameString = cc.FileUtils:getInstance():getStringFromFile("src/app/Game/mMyGame/GameController.json")
        self._gameControllerConfig = JSON.decode(jsonGameString)
    end
    if self._gameControllerConfig then
        return self._gameControllerConfig[key]
    end
    return nil
end







function GamePublicInterface:OnInGameHallSocketError()
    --[[if self._gameController then
        return _gameController:onHallSocketError()
    end]]--
end

function GamePublicInterface:OnInGameRoomSocketError()
    --[[if self._gameController then
        return self._gameController:onRoomSocketError()
    end]]--
end


function GamePublicInterface:getGameStringToUTF8ByKey(stringKey)
    local content = self:getGameString(stringKey)
    local utf8Content = MCCharset:getInstance():gb2Utf8String(content, string.len(content))
    return utf8Content
end

return GamePublicInterface
