
local BaseGameData = class("BaseGameData")

local treepack      = cc.load("treepack")
local BaseGameReq   = import("src.app.Game.mBaseGame.BaseGameReq")

function BaseGameData:create()
    return BaseGameData.new()
end

function BaseGameData:ctor()
end

function BaseGameData:getCheckVersionInfo(data)
    if data == nil then return nil end

    local info = BaseGameReq["VERSION"]
    local msgInfo = treepack.unpack(data, info)
    return msgInfo
end

function BaseGameData:getEnterGameOKInfo(data)
    if data == nil then return nil end

    local gameEnterInfo = BaseGameReq["GAME_ENTER_INFO"]
    local msgGameEnterInfo = treepack.unpack(data, gameEnterInfo)

    local dataSoloPlayerHead = string.sub(data, gameEnterInfo.maxsize + 1)
    local soloPlayerHead = BaseGameReq["SOLOPLAYER_HEAD"]
    local msgSoloPlayerHead = treepack.unpack(dataSoloPlayerHead, soloPlayerHead)

    local msgSoloPlayers = {}
    local dataSoloPlayerStart = string.sub(dataSoloPlayerHead, soloPlayerHead.maxsize + 1)
    if dataSoloPlayerStart and msgSoloPlayerHead.nPlayerCount then
        for i = 1, msgSoloPlayerHead.nPlayerCount do
            local soloPlayer = BaseGameReq["SOLO_PLAYER"]
            msgSoloPlayers[i] = treepack.unpack(dataSoloPlayerStart, soloPlayer)

            dataSoloPlayerStart = string.sub(dataSoloPlayerStart, soloPlayer.maxsize + 1)
        end
    end

    return msgGameEnterInfo, msgSoloPlayers
end

function BaseGameData:getPlayerAbortInfo(data)
    if data == nil then return nil end

    local info = BaseGameReq["GAME_ABORT"]
    local msgInfo = treepack.unpack(data, info)
    return msgInfo
end

function BaseGameData:getPlayerEnterInfo(data)
    if data == nil then return nil end

    local info = BaseGameReq["SOLO_PLAYER"]
    local msgInfo = treepack.unpack(data, info)
    return msgInfo
end

function BaseGameData:getUserPosInfo(data)
    if data == nil then return nil end

    local userPos = BaseGameReq["USER_POSITION"]
    local msgUserPos = treepack.unpack(data, userPos)

    local msgSoloPlayers = {}
    local dataSoloPlayerStart = string.sub(data, userPos.maxsize + 1)
    if dataSoloPlayerStart and msgUserPos.nPlayerCount then
        for i = 1, msgUserPos.nPlayerCount do
            local soloPlayer = BaseGameReq["SOLO_PLAYER"]
            msgSoloPlayers[i] = treepack.unpack(dataSoloPlayerStart, soloPlayer)

            dataSoloPlayerStart = string.sub(dataSoloPlayerStart, soloPlayer.maxsize + 1)
        end
    end

    return msgUserPos, msgSoloPlayers
end

function BaseGameData:getPlayerStartGameInfo(data)
    if data == nil then return nil end

    local info = BaseGameReq["START_GAME"]
    local msgInfo = treepack.unpack(data, info)
    return msgInfo
end

function BaseGameData:getLeaveGameTooFastInfo(data)
    if data == nil then return nil end

    local info = BaseGameReq["LEAVE_GAME_TOOFAST"]
    local msgInfo = treepack.unpack(data, info)
    return msgInfo
end

function BaseGameData:getChatToTableInfo(data)
    if data == nil then return nil end

    local info = BaseGameReq["CHAT_TO_TABLE"]
    local msgInfo = treepack.unpack(data, info)
    return msgInfo
end

function BaseGameData:getChatFromTableInfo(data)
    if data == nil then return nil end

    local info = BaseGameReq["CHAT_FROM_TABLE"]
    local msgInfo = treepack.unpack(data, info)
    local chatMsg = string.sub(data, info.maxsize + 1)
    return msgInfo, chatMsg
end

function BaseGameData:getDepositNotEnoughInfo(data)
    if data == nil then return nil end

    local info = BaseGameReq["DEPOSIT_NOT_ENOUGH"]
    local msgInfo = treepack.unpack(data, info)
    return msgInfo
end

function BaseGameData:getDepositTooHighInfo(data)
    if data == nil then return nil end

    local info = BaseGameReq["DEPOSIT_TOO_HIGH"]
    local msgInfo = treepack.unpack(data, info)
    return msgInfo
end

function BaseGameData:getScoreNotEnoughInfo(data)
    if data == nil then return nil end

    local info = BaseGameReq["SCORE_NOT_ENOUGH"]
    local msgInfo = treepack.unpack(data, info)
    return msgInfo
end

function BaseGameData:getScoreTooHighInfo(data)
    if data == nil then return nil end

    local info = BaseGameReq["SCORE_TOO_HIGH"]
    local msgInfo = treepack.unpack(data, info)
    return msgInfo
end

function BaseGameData:getUserBoutTooHighInfo(data)
    if data == nil then return nil end

    local info = BaseGameReq["USER_BOUT_TOO_HIGH"]
    local msgInfo = treepack.unpack(data, info)
    return msgInfo
end

function BaseGameData:getTableBoutTooHighInfo(data)
    if data == nil then return nil end

    local info = BaseGameReq["TABLE_BOUT_TOO_HIGH"]
    local msgInfo = treepack.unpack(data, info)
    return msgInfo
end

function BaseGameData:getUserDepositEventInfo(data)
    if data == nil then return nil end

    local info = BaseGameReq["USER_DEPOSITEVENT"]
    local msgInfo = treepack.unpack(data, info)
    return msgInfo
end

function BaseGameData:getSafeBoxDepositInfo(data)
    if data == nil then return nil end

    local info = BaseGameReq["SAFE_DEPOSIT_EX"]
    local msgInfo = treepack.unpack(data, info)
    return msgInfo
end

function BaseGameData:getSoloTableInfo(data)
    if data == nil then return nil end

    local soloTable = BaseGameReq["SOLO_TABLE"]
    local msgsoloTable = treepack.unpack(data, soloTable)

    local msgSoloPlayers = {}
    local dataSoloPlayerStart = string.sub(data, soloTable.maxsize + 1)
    if dataSoloPlayerStart and msgsoloTable.nUserCount then
        for i = 1, msgsoloTable.nUserCount do
            local soloPlayer = BaseGameReq["SOLO_PLAYER"]
            msgSoloPlayers[i] = treepack.unpack(dataSoloPlayerStart, soloPlayer)

            dataSoloPlayerStart = string.sub(dataSoloPlayerStart, soloPlayer.maxsize + 1)
        end
    end

    return msgsoloTable, msgSoloPlayers, dataSoloPlayerStart
end

function BaseGameData:getStartFailedNotEnoughInfo(data)
    if data == nil then return nil end

    local info = BaseGameReq["DEPOSIT_NOT_ENOUGH"]
    local msgInfo = treepack.unpack(data, info)
    return msgInfo
end

function BaseGameData:getStartFailedTooHighInfo(data)
    if data == nil then return nil end

    local info = BaseGameReq["DEPOSIT_TOO_HIGH"]
    local msgInfo = treepack.unpack(data, info)
    return msgInfo
end

function BaseGameData:getGameAbortInfo(data)
    if data == nil then return nil end

    local info = BaseGameReq["GAME_ABORT"]
    local msgInfo = treepack.unpack(data, info)
    return msgInfo
end

function BaseGameData:getRndKeyInfo(data)
    if data == nil then return nil end

    local info = BaseGameReq["SAFE_RNDKEY"]
    local msgInfo = treepack.unpack(data, info)
    return msgInfo
end

function BaseGameData:getChairChanged(data)
    if data == nil then return nil end

    local info = BaseGameReq["SOMEONE_NEWCHAIR"]
    local msgInfo = treepack.unpack(data, info)
    return msgInfo
end

function BaseGameData:getTickoff(data)
    if data == nil then return nil end

    local info = BaseGameReq["TELLLIENT_KICKOFF_EX"]
    local msgInfo = treepack.unpack(data, info)
    return msgInfo
end

function BaseGameData:getHostChanged(data)
    if data == nil then return nil end

    local info = BaseGameReq["TELLLIENT_HOMEUSERCHANGED"]
    local msgInfo = treepack.unpack(data, info)
    return msgInfo

end

function BaseGameData:getSyncInfo(data)
    if data == nil then return nil end

    local head = BaseGameReq["TELLCLIENT_SOCLALLY"]
    local msgInfo = treepack.unpack(data, head)

    local msgSoloPlayers = {}
    local dataSoloPlayerStart = string.sub(data, head.maxsize + 1)
    if dataSoloPlayerStart and msgInfo.nCount then
        for i = 1, msgInfo.nCount do
            local info = BaseGameReq["ONE_PLAYER_SOCLALLY"]
            msgSoloPlayers[i] = treepack.unpack(dataSoloPlayerStart, info)

            dataSoloPlayerStart = string.sub(dataSoloPlayerStart, info.maxsize + 1)
        end
    end

    return msgSoloPlayers
end

function BaseGameData:onGetHomeInfoOnDXXW(data)
    if data == nil then return nil end

    local info = BaseGameReq["TOCLIENT_HOMEINFO_ONDXXW"]
    local msgInfo = treepack.unpack(data, info)
    return msgInfo
end

function BaseGameData:onGetCancelTeamMatchOKInfo(data)
    if data == nil then return nil end

    local _, hostID = string.unpack(data, '<i')
    return hostID
end

function BaseGameData:getErrorInfo(data)
    if data == nil then return nil end

    local info = BaseGameReq["ERROR_INFO"]
    local msgInfo = treepack.unpack(data, info)
    return msgInfo
end

function BaseGameData:onRecieveArenaEvents(data)
    if data == nil then return nil end

    local info = BaseGameReq["MATCH_ARENA_EVENT"]
    local msgInfo = treepack.unpack(data, info)
    return msgInfo
end

function BaseGameData:onRecieveArenaResult(data)
    if data == nil then return nil end

    local info = BaseGameReq["USER_ARENA_RESULT"]
    local msgInfo = treepack.unpack(data, info)
    return msgInfo
end

function BaseGameData:onRecieveArenaReward(data)
    if data == nil then return nil end

    local info = BaseGameReq["MATCH_ARENA_REWARD"]
    local msgInfo = treepack.unpack(data, info)
    return msgInfo
end 

function BaseGameData:onArenaPlayerDXXW(data)
    if data == nil then return nil end

    local info = BaseGameReq["MATCHERONDXXW"]
    local msgInfo = treepack.unpack(data, info)
    return msgInfo
end

return BaseGameData
