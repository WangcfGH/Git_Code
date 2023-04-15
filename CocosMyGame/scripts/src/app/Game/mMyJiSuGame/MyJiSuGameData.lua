local MyJiSuGameData = class("MyJiSuGameData", import("src.app.Game.mMyGame.MyGameData"))
local BaseGameReq    = import("src.app.Game.mBaseGame.BaseGameReq")
local MyJiSuGameReq  = import("src.app.Game.mMyJiSuGame.MyJiSuGameReq")

local treepack              = cc.load("treepack")

function MyJiSuGameData:getGameTableInfo(data)
    if data == nil then 
        return nil 
    end

    local gameTableInfo = MyJiSuGameReq["GAME_TABLE_INFO_JS"]
    local msgGameTableInfo = treepack.unpack(data, gameTableInfo)
    local thorwEx = msgGameTableInfo.nThrowWaitEx

    local dataSoloPlayerHead = string.sub(data, gameTableInfo.maxsize + 1)
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

    return msgGameTableInfo, msgSoloPlayers
end

function MyJiSuGameData:getGameMsgAdjustOver(data)
    if data == nil then 
        return nil 
    end

    local gameMsg = MyJiSuGameReq["GAME_MSG"]
    local adjustMsg = MyJiSuGameReq["ADJUSTCARD"] 
    local gameMsgInfo, adjustMsgInfo  = treepack.unpacks(data, gameMsg, adjustMsg)
    dump(gameMsgInfo)
    dump(adjustMsgInfo)
    return gameMsgInfo, adjustMsgInfo
end

function MyJiSuGameData:getGameWinInfo(data)
    if data == nil then 
        return nil 
    end

    local gameWinInfo = MyJiSuGameReq["GAME_WIN_RESULT_JS"]
    local msgGameWin = treepack.unpack(data, gameWinInfo)
    dump(msgGameWin)
    return msgGameWin
end

return MyJiSuGameData