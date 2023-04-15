
local SKGameData = import("src.app.Game.mSKGame.SKGameData")
local MyGameData = class("MyGameData", SKGameData)

local treepack              = cc.load("treepack")
local BaseGameReq           = import("src.app.Game.mBaseGame.BaseGameReq")
local MyGameReq             = import("src.app.Game.mMyGame.MyGameReq")

function MyGameData:getGameMsg(data)
    if data == nil then 
        return nil 
    end

    local gameMsg = MyGameReq["GAME_MSG"]
    local msgGameMsg = treepack.unpack(data, gameMsg)
    dump(msgGameMsg)
    return msgGameMsg
end

function MyGameData:getGameMsgTributeCard(data)
    if data == nil then 
        return nil 
    end

    local gameMsg = MyGameReq["GAME_MSG_TRIBUTE_CARD"]
    local msgGameMsg = treepack.unpack(data, gameMsg)
    dump(msgGameMsg)
    return msgGameMsg
end

function MyGameData:getGameMsgTributeCardOver(data)
    if data == nil then 
        return nil 
    end

    local gameMsg = MyGameReq["GAME_MSG_TRIBUTE_CARD_OVER"]
    local msgGameMsg = treepack.unpack(data, gameMsg)
    dump(msgGameMsg)
    return msgGameMsg
end

function MyGameData:getGameMsgReturnCard(data)
    if data == nil then 
        return nil 
    end

    local gameMsg = MyGameReq["GAME_MSG_RETURN_CARD"]
    local msgGameMsg = treepack.unpack(data, gameMsg)
    dump(msgGameMsg)
    return msgGameMsg
end

function MyGameData:getGameStartInfo(data)
    if data == nil then 
        return nil 
    end

    local gameStartInfo = MyGameReq["GAME_START_INFO"]
    local msgGameStart = treepack.unpack(data, gameStartInfo)
    return msgGameStart
end

function MyGameData:getGameWinInfo(data)
    if data == nil then 
        return nil 
    end

    local gameWinInfo = MyGameReq["GAME_WIN_RESULT"]
    local msgGameWin = treepack.unpack(data, gameWinInfo)
    dump(msgGameWin)
    return msgGameWin
end

function MyGameData:getGameTableInfo(data)
    if data == nil then 
        return nil 
    end

    local gameTableInfo = MyGameReq["GAME_TABLE_INFO"]
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

function MyGameData:getCallFriendInfo(data)
    if data == nil then 
        return nil 
    end

    local callFriendInfo = MyGameReq["CALL_FRIEND"]
    local msgCallFriendInfo = treepack.unpack(data, callFriendInfo)

    return msgCallFriendInfo
end

function MyGameData:getShowCardsInfo(data)
    if data == nil then 
        return nil 
    end

    local showCardsInfo = MyGameReq["SHOW_CARDS"]
    local msgshowCardsInfo = treepack.unpack(data, showCardsInfo)

    return msgshowCardsInfo
end

function MyGameData:getSystemMsg(data)
    if data == nil then 
        return nil 
    end

    local systemMsg = MyGameReq["SYSTEM_MSG"]
    local msgSystemMsg = treepack.unpack(data, systemMsg)

    return msgSystemMsg
end

function MyGameData:getTaskData(data)
    if data == nil then 
        return nil 
    end

    local taskDataMsg = MyGameReq["TASKDATA_MSG"]
    local taskData = treepack.unpack(data, taskDataMsg)

    return taskData
end

function MyGameData:getUpPlayerData(data)
    if data == nil then 
        return nil 
    end

    local upDataMsg = MyGameReq["UpPlayerRes"]
    local upData = treepack.unpack(data, upDataMsg)

    return upData
end

function MyGameData:getUpInfo(data)
    if data == nil then 
        return nil 
    end

    local upInfoMsg = MyGameReq["UpInfoRes"]
    local upInfo = treepack.unpack(data, upInfoMsg)

    return upInfo
end

function MyGameData:getContinualWinInfo(data)
    if data == nil then 
        return nil 
    end

    local ContinualWinInfoData = MyGameReq["CONTINUALWININFO"]
    local ContinualWinInfo = treepack.unpack(data, ContinualWinInfoData)

    return ContinualWinInfo
end

function MyGameData:getCheckOfflineInfo(data)
    if data == nil then 
        return nil 
    end

    local CheckOfflineInfoData = MyGameReq["CHECK_OFFLINE"]
    local CheckOfflineInfo = treepack.unpack(data, CheckOfflineInfoData)

    return CheckOfflineInfo
end

function MyGameData:getBuyPropRespInfo(data)
    if data == nil then 
        return nil 
    end

    local BuyPropRespInfoData = MyGameReq["BUY_PROP_RESP"]
    local BuyPropRespInfo = treepack.unpack(data, BuyPropRespInfoData)

    return BuyPropRespInfo
end

function MyGameData:getExpressionThrowRespInfo(data)
    if data == nil then 
        return nil 
    end

    local ThrowExpression = MyGameReq["THROW_EXPRESSION"]
    local ThrowExpressionRespInfo = treepack.unpack(data, ThrowExpression)

    return ThrowExpressionRespInfo
end

function MyGameData:getExchangeTaskInfo(data)
    if data == nil then 
        return nil 
    end
    local ExchangeTaskInfoData = MyGameReq["EXCHANGE_ROUND_INFO"]
    local ExchangeTaskInfo = treepack.unpack(data, ExchangeTaskInfoData)
    return ExchangeTaskInfo
end

function MyGameData:getFinishExchangeTaskInfo(data)
    if data == nil then 
        return nil 
    end
    local FinishExchangeTaskInfoData = MyGameReq["FINISH_EXCHANGE_ROUND_INFO"]
    local FinishExchangeTaskInfo = treepack.unpack(data, FinishExchangeTaskInfoData)
    return FinishExchangeTaskInfo
end

function MyGameData:getGameReusltExchangeInfo(data)
    if data == nil then 
        return nil 
    end
    local GameReusltExchangeInfo = MyGameReq["GAME_RESULT_EXCHANGE_INFO"]
    local GameReusltExchangeInfo = treepack.unpack(data, GameReusltExchangeInfo)
    return GameReusltExchangeInfo
end

function MyGameData:getGameResultActivityData(data)
    if data == nil then 
        return nil 
    end
    local GameReusltActivityData= MyGameReq["GAME_NATIONAL_ACTIVITY"]
    local GameReusltInfo = treepack.unpack(data, GameReusltActivityData)
    return GameReusltInfo
end

function MyGameData:get5BombDoubleOpenData(data)
    if data == nil then 
        return nil
    end
    local openTagReq = MyGameReq["FiveBoomDoubleOpen"]
    local openTagTab = treepack.unpack(data, openTagReq)
    return openTagTab
end

function MyGameData:getTimingGameTable(data)
    if data == nil then 
        return nil
    end
    local openTagReq = MyGameReq["UPDATE_TIMING_GAME_TABLE"]
    local openTagTab = treepack.unpack(data, openTagReq)
    return openTagTab
end

return MyGameData