
local NetlessConnect = class("NetlessConnect")

local treepack                              = cc.load("treepack")

local MyGameReq                             = import("src.app.Game.mMyGame.MyGameReq")
local MyGameDef                             = import("src.app.Game.mMyGame.MyGameDef")
local SKGameDef                             = import("src.app.Game.mSKGame.SKGameDef")
local SKGameReq                             = import("src.app.Game.mSKGame.SKGameReq")

function NetlessConnect:create(gameController)
    return NetlessConnect.new(gameController)
end

function NetlessConnect:ctor(gameController)
    if not gameController then printError("gameController is nil!!!") return end
    self._gameController                    = gameController
end

function NetlessConnect:startGame(chairId)
    local hah = 1
    self.GameNotify = self._gameController._baseGameNotify
end

function NetlessConnect:gc_StartGame()
    local playerInfoManager = self._gameController:getPlayerInfoManager()
    local uitleInfoManager  = self._gameController:getUtilsInfoManager()
    if not playerInfoManager or not uitleInfoManager then return end

    local waitingResponse = self._gameController:getResponse()
    if waitingResponse == self._gameController:getResWaitingNothing() then
        local GR_START_GAME = BaseGameReq["START_GAME"]
        local data          = {
            nUserID         = playerInfoManager:getSelfUserID(),
            nRoomID         = uitleInfoManager:getRoomID(),
            nTableNO        = playerInfoManager:getSelfTableNO(),
            nChairNO        = playerInfoManager:getSelfChairNO()
        }
        local pData = treepack.alignpack(data, GR_START_GAME)

        --self:sendRequest(BaseGameDef.BASEGAME_GR_START_GAME, pData, pData:len(), true)
        --self._gameController:setResponse(BaseGameDef.BASEGAME_WAITING_START_GAME)
        print("GC_StartGame request sent")
    else
        print("GC_StartGame error, waitingResponse = " .. waitingResponse)
    end
end

function NetlessConnect:reqThrowCards(chairNo, cardUnite)
    local playerInfoManager = self._gameController:getPlayerInfoManager()
    local uitleInfoManager  = self._gameController:getUtilsInfoManager()
    if not playerInfoManager or not uitleInfoManager then return end

    local GR_THROW_CARDS = SKGameReq["CARDS_THROW"]
    local data          = {
        nUserID         = playerInfoManager:getSelfUserID(),
        nRoomID         = uitleInfoManager:getRoomID(),
        nTableNO        = playerInfoManager:getSelfTableNO(),
        nChairNO        = chairNo,
        nNextChair      = self:getNextThrowChair(chairNo),
        dwCardType      = cardUnite.dwCardType,
        dwComPareType   = cardUnite.dwComPareType,
        nMainValue      = cardUnite.nMainValue,
        nCardsCount     = cardUnite.nCardsCount,
        nCardIDs        = cardUnite.nCardIDs,
    }

    self._gameController:XygRemoveCardIDs(self._gameController.GameCard[chairNo+1], cardUnite.nCardIDs, self._gameController:getChairCardsCount())

    local pData = treepack.alignpack(data, GR_THROW_CARDS)
    self._gameController:onCardsThrow(pData)
end

function NetlessConnect:reqPassCards(chairNo)
    local playerInfoManager = self._gameController:getPlayerInfoManager()
    local uitleInfoManager  = self._gameController:getUtilsInfoManager()
    if not playerInfoManager or not uitleInfoManager then return end

    local waitChair = uitleInfoManager:getWaitChair()
    local nextChair, nextFirst = self:getNextThrowChair(chairNo)
    --[[local nextFirst = 0
    if nextChair == waitChair then
        nextFirst = 1
    end--]]

    local GR_PASS_CARDS = SKGameReq["CARDS_PASS"]
    local data          = {
        nUserID         = playerInfoManager:getSelfUserID(),
        nRoomID         = uitleInfoManager:getRoomID(),
        nChairNO        = chairNo,
        nTableNO        = playerInfoManager:getSelfTableNO(),
        bNextFirst      = nextFirst,
        nNextChair      = nextChair        
    }
        
    local pData = treepack.alignpack(data, GR_PASS_CARDS)
    
    self._gameController:onCardsPass(pData)
end

function NetlessConnect:getNextThrowChair(chairNo)
    local uitleInfoManager  = self._gameController:getUtilsInfoManager()
    if not uitleInfoManager then return end    
    local waitChair = uitleInfoManager:getWaitChair()
    local nextFirst = 0

    local nextChairNo = uitleInfoManager:RUL_GetNextChairNO(chairNo)
    local GameCards = self._gameController.GameCard
    for i=1, MyGameDef.MY_TOTAL_PLAYERS do
        if nextChairNo == waitChair then
            nextFirst = 1
        end

        local inhandCards, cardsCount = self._gameController:GetRootHandCard(GameCards[nextChairNo+1])
        if cardsCount <= 0 then
            nextChairNo = uitleInfoManager:RUL_GetNextChairNO(nextChairNo)
        else
            break
        end
    end

    return nextChairNo, nextFirst
end

function NetlessConnect:sendHagdMsgToServer(msgID, dataOther)
    local playerInfoManager = self._gameController:getPlayerInfoManager()
    local uitleInfoManager  = self._gameController:getUtilsInfoManager()
    if not playerInfoManager or not uitleInfoManager then return end

    if msgID == MyGameDef.HAGD_GAME_MSG_TRIBUTE then
           
        local TRIBUTECARD = MyGameReq["TRIBUTECARD"]
        local TRIBUTECARD_Data = treepack.alignpack(dataOther, TRIBUTECARD)


        local GR_SENDMSG_TO_SERVER = MyGameReq["GAME_MSG_TRIBUTE_CARD"]
        local data              = {
            nRoomID             = uitleInfoManager:getRoomID(),
            nUserID             = playerInfoManager:getSelfUserID(),
            nMsgID              = msgID,
            bNeedEcho           = 0,
            nDatalen            = TRIBUTECARD_Data:len(),
            chairno             = dataOther.chairno,
            nCardID             = dataOther.nCardID
        }
        
        local pData = treepack.alignpack(data, GR_SENDMSG_TO_SERVER)
        --self:sendRequest(SKGameDef.SK_GR_SENDMSG_TO_SERVER, pData, pData:len(), false)
    elseif msgID == MyGameDef.HAGD_GAME_MSG_RETURN then
        local RETURNCARD = MyGameReq["RETURNCARD"]
        local RETURNCARD_Data = treepack.alignpack(dataOther, RETURNCARD)


        local GR_SENDMSG_TO_SERVER = MyGameReq["GAME_MSG_RETURN_CARD"]
        local data              = {
            nRoomID             = uitleInfoManager:getRoomID(),
            nUserID             = playerInfoManager:getSelfUserID(),
            nMsgID              = msgID,
            bNeedEcho           = 0,
            nDatalen            = RETURNCARD_Data:len(),
            chairno             = dataOther.chairno,
            nCardID             = dataOther.nCardID,
            nTributeChair       = dataOther.nTributeChair,
            nThrowChair         = dataOther.nThrowChair
        }
        
        local pData = treepack.alignpack(data, GR_SENDMSG_TO_SERVER)
        --self:sendRequest(SKGameDef.SK_GR_SENDMSG_TO_SERVER, pData, pData:len(), false)
    end
    
    print("REQ_MsgToServer request sent")
end

function NetlessConnect:sendMsgToServer(msgID)
    local playerInfoManager = self._gameController:getPlayerInfoManager()
    local uitleInfoManager  = self._gameController:getUtilsInfoManager()
    if not playerInfoManager or not uitleInfoManager then return end

    local GR_SENDMSG_TO_SERVER = MyGameReq["GAME_MSG"]
    local data              = {
        nRoomID             = uitleInfoManager:getRoomID(),
        nUserID             = playerInfoManager:getSelfUserID(),
        nMsgID              = msgID,
        bNeedEcho            = 0,
        nDatalen            = 0
    }
    local pData = treepack.alignpack(data, GR_SENDMSG_TO_SERVER)

    --self:sendRequest(SKGameDef.SK_GR_SENDMSG_TO_SERVER, pData, pData:len(), false)
    print("REQ_MsgToServer request sent")
end

function NetlessConnect:reqUpPlayer(drawIndex)
    local playerInfoManager = self._gameController:getPlayerInfoManager()
    local uitleInfoManager  = self._gameController:getUtilsInfoManager()
    if not playerInfoManager or not uitleInfoManager then return end
    local playerInfo = playerInfoManager:getPlayerInfo(drawIndex)
    if not playerInfo then return end
    
    --local waitingResponse = self._gameController:getResponse()
    --if waitingResponse == self._gameController:getResWaitingNothing() then
        local GR_UP_PLAYER    = MyGameReq["UP_PLAYER"]
        local data              = {
            nUserID             = playerInfoManager:getSelfUserID(),
            nRoomID             = uitleInfoManager:getRoomID(),
            nTableNO            = playerInfoManager:getSelfTableNO(),
            nChairNO            = playerInfoManager:getSelfChairNO(),
            
            nGameID             = uitleInfoManager:getGameID(),
            nDestID             = playerInfo.nUserID,
            nDestChairNO        = playerInfo.nChairNO,
            szDestName          = playerInfo.szUserName             
        }

        local pData = treepack.alignpack(data, GR_UP_PLAYER)

        --local session = self:sendRequest(MyGameDef.GAME_GR_UP_PLAYER, pData, pData:len(), false)
        --self._gameController:setSession(session)
        --self._gameController:setResponse(MyGameDef.GAME_GR_UP_PLAYER)
        print("REQ_UpPlayer request sent")
   -- else
    --    print("REQ_UpPlayer error, waitingResponse = " .. waitingResponse)
   -- end
end

function NetlessConnect:reqUpInfo(soloPlayer)
    local playerInfoManager = self._gameController:getPlayerInfoManager()
    local uitleInfoManager  = self._gameController:getUtilsInfoManager()
    if not playerInfoManager or not uitleInfoManager then return end

    --local waitingResponse = self._gameController:getResponse()
    --if waitingResponse == self._gameController:getResWaitingNothing() then
        local GR_UP_INFO    = MyGameReq["UpInfo"]
        local data              = {
            nUserID             = playerInfoManager:getSelfUserID(),
            nDestID             = soloPlayer.nUserID,    
            nDestChairNO        = soloPlayer.nChairNO,       
        }

        local pData = treepack.alignpack(data, GR_UP_INFO)

        --local session = self:sendRequest(MyGameDef.GAME_GR_UP_INFO, pData, pData:len(), false)
        --self._gameController:setSession(session)
        --self._gameController:setResponse(MyGameDef.GAME_GR_UP_INFO)
        print("REQ_UpInfo request sent")
    --else
    --    print("REQ_UpInfo error, waitingResponse = " .. waitingResponse)
    --end
end

function NetlessConnect:gc_AppEnterForeground()
end

function NetlessConnect:gc_GetTableInfo()
end

function NetlessConnect:pause()

end

function NetlessConnect:resume()

end

function NetlessConnect:disconnect()

end

function NetlessConnect:sendRequest(msg_type, msgData, msgDataLength, needResponse)
    local session = -1

    return session
end

return NetlessConnect