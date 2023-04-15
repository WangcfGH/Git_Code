
local BaseGameData = import("src.app.Game.mBaseGame.BaseGameData")
local SKGameData = class("SKGameData", BaseGameData)

local treepack              = cc.load("treepack")
local SKGameDef             = import("src.app.Game.mSKGame.SKGameDef")
local SKGameReq             = import("src.app.Game.mSKGame.SKGameReq")

local BaseGameReq           = import("src.app.Game.mBaseGame.BaseGameReq")

local GamePublicInterface   = import("src.app.Game.mMyGame.GamePublicInterface")

function SKGameData:getGameStartInfo(data)
    if data == nil then return nil end

    local info = SKGameReq["SK_START_INFO"]
    local msgGameStart = treepack.unpack(data, info)
    return msgGameStart
end

function SKGameData:getOfflineInfo(data)
    if data == nil then return nil end

    local info = SKGameReq["USER_OFFLINE"]
    local msgOffline = treepack.unpack(data, info)
    return msgOffline
end

function SKGameData:getCardsThrowInfo(data)
    if data == nil then return nil end

    local throwInfo = SKGameReq["CARDS_THROW"]
    if GamePublicInterface and GamePublicInterface:IS_FRAME_1() then
        throwInfo = SKGameReq["CARDS_THROW_1"]
    end

    local msgInfo = treepack.unpack(data, throwInfo)
    for i = 1, SKGameDef.SK_MAX_CARDS_PER_CHAIR do
        if i <= msgInfo.nCardsCount then
        else
            msgInfo.nCardIDs[i] = -1
        end
    end

    return msgInfo
end

function SKGameData:getThrowOKInfo(data)
    if data == nil then return nil end
    
    local info = SKGameReq["THROW_OK"]
    local msgInfo = treepack.unpack(data, info)
    return msgInfo
end

function SKGameData:getPassOKInfo(data)
    if data == nil then return nil end

    local info = SKGameReq["PASS_OK"]
    local msgInfo = treepack.unpack(data, info)
    return msgInfo
end

function SKGameData:getCardsPassInfo(data)
    if data == nil then return nil end

    local info = SKGameReq["CARDS_PASS"]
    if GamePublicInterface and GamePublicInterface:IS_FRAME_1() then
        info = SKGameReq["CARDS_PASS_1"]
    end
    
    local msgInfo = treepack.unpack(data, info)
    return msgInfo
end

function SKGameData:getBankerAuctionInfo(data)
    if data == nil then return nil end

    local info = SKGameReq["BANKER_AUCTION"]
    local msgInfo = treepack.unpack(data, info)
    return msgInfo
end

function SKGameData:getAuctionFinishedInfo(data)
    if data == nil then return nil end

    local info = SKGameReq["AUCTION_FINISHED"]
    local msgInfo = treepack.unpack(data, info)
    return msgInfo
end

function SKGameData:getCardsInfo(data)
    if data == nil then return nil end

    local info = SKGameReq["CARDS_INFO"]
    local msgInfo = treepack.unpack(data, info)
    return msgInfo
end

function SKGameData:getGainsInfo(data)
    if data == nil then return nil end

    local info = SKGameReq["GAINS_BONUS"]
    local msgInfo = treepack.unpack(data, info)
    return msgInfo
end

function SKGameData:getGameEnterInfo(data)
    if data == nil then return nil end

    local info = SKGameReq["GAME_ENTER_INFO"]
    local msgInfo = treepack.unpack(data, info)
    return msgInfo
end

function SKGameData:getGameWinInfo(data)
    if data == nil then return nil end

    local info = SKGameReq["GAME_WIN_SK"]
    local msgInfo = treepack.unpack(data, info)
    return msgInfo
end

function SKGameData:getTableInfo(data)
    if data == nil then return nil end

    local startInfo = SKGameReq["SK_START_INFO"]
    local msgStartInfo = treepack.unpack(data, startInfo)
    
    local dataPublicInfo = string.sub(data, startInfo.maxsize + 1)
    local publicInfo = SKGameReq["SK_PUBLIC_INFO"]
    local msgPublicInfo = treePack.unpack(dataPublicInfo, publicInfo)

    local dataPlayInfo = string.sub(data, startInfo.maxsize + publicInfo.maxsize  + 1)
    local playInfo = SKGameReq["SK_PLAYER_INFO"]
    local msgPlayInfo = treepack.unpack(dataPlayInfo, playInfo)

    local gameTableInfo = SKGameReq["SK_TABLE_INFO"]
    local msgGameTableInfo = treepack.unpack(data, gameTableInfo)

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

    return msgStartInfo, msgPublicInfo, msgPlayInfo, msgGameTableInfo, msgSoloPlayers
end

return SKGameData