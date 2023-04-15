
local BaseGameConnect = import("src.app.Game.mBaseGame.BaseGameConnect")
local SKGameConnect = class("SKGameConnect", BaseGameConnect)

local treepack                              = cc.load("treepack")

local SKGameReq                             = import("src.app.Game.mSKGame.SKGameReq")
local SKGameDef                             = import("src.app.Game.mSKGame.SKGameDef")

local GamePublicInterface                   = import("src.app.Game.mMyGame.GamePublicInterface")

function SKGameConnect:sendMsgToServer(msgID)
    local playerInfoManager = self._gameController:getPlayerInfoManager()
    local uitleInfoManager  = self._gameController:getUtilsInfoManager()
    if not playerInfoManager or not uitleInfoManager then return end

    local GR_SENDMSG_TO_SERVER = SKGameReq["GAME_MSG"]
    local data              = {
        nRoomID             = uitleInfoManager:getRoomID(),
        nUserID             = playerInfoManager:getSelfUserID(),
        nMsgID              = msgID
    }
    local pData = treepack.alignpack(data, GR_SENDMSG_TO_SERVER)

    self:sendRequest(SKGameDef.SK_GR_SENDMSG_TO_SERVER, pData, pData:len(), false)
    print("REQ_MsgToServer request sent")
end

function SKGameConnect:reqThrowCards(cardUnite)
    local playerInfoManager = self._gameController:getPlayerInfoManager()
    local uitleInfoManager  = self._gameController:getUtilsInfoManager()
    if not playerInfoManager or not uitleInfoManager or not cardUnite then return end

    local waitingResponse = self._gameController:getResponse()
    if waitingResponse == self._gameController:getResWaitingNothing() then
        local GR_THROW_CARDS = SKGameReq["CARDS_THROW"]
        local data          = {
            nUserID         = playerInfoManager:getSelfUserID(),
            nRoomID         = uitleInfoManager:getRoomID(),
            nTableNO        = playerInfoManager:getSelfTableNO(),
            nChairNO        = playerInfoManager:getSelfChairNO(),
            dwCardType      = cardUnite.dwCardType,
            dwComPareType   = cardUnite.dwComPareType,
            nMainValue      = cardUnite.nMainValue,
            nCardsCount     = cardUnite.nCardsCount,
            nCardIDs        = cardUnite.nCardIDs,
        }
        local pData = treepack.alignpack(data, GR_THROW_CARDS)
        local len   = pData:len() - 4 * (SKGameDef.SK_MAX_CARDS_PER_CHAIR - cardUnite.nCardsCount)

        local session = self:sendRequest(SKGameDef.SK_GR_THROW_CARDS, pData, len, true)
        self._gameController:setSession(session)
        self._gameController:setResponse(SKGameDef.SK_WAITING_THROW_CARDS)
        print("REQ_ThrowCard request sent")
    else
        print("REQ_ThrowCard error, waitingResponse = " .. waitingResponse)
    end
end

function SKGameConnect:reqThrowCards_1(nCardIDs, nCardsCount, dwCardsType)
    if not nCardIDs or not nCardsCount or not dwCardsType then return end
    
    local playerInfoManager = self._gameController:getPlayerInfoManager()
    local utilsInfoManager  = self._gameController:getUtilsInfoManager()
    if not playerInfoManager or not utilsInfoManager then return end

    local waitingResponse = self._gameController:getResponse()
    if waitingResponse == self._gameController:getResWaitingNothing() then
        local GR_THROW_CARDS = SKGameReq["THROW_CARDS_1"]
        local data = {
            nUserID         = playerInfoManager:getSelfUserID(),
            nRoomID         = utilsInfoManager:getRoomID(),
            nTableNO        = playerInfoManager:getSelfTableNO(),
            nChairNO        = playerInfoManager:getSelfChairNO(),
            nSendTable      = playerInfoManager:getSelfTableNO(),
            nSendChair      = playerInfoManager:getSelfChairNO(),
            nSendUser       = playerInfoManager:getSelfUserID(),
            szHardID        = utilsInfoManager:getHardID(),
            dwCardsType     = dwCardsType,
            nCardsCount     = nCardsCount,
            nCardIDs        = nCardIDs
        }
        utilsInfoManager:setThrowInfo(data)          --1.0双扣模板不向自己发送出牌消息 必须自行保存
        
        local pData = treepack.alignpack(data, GR_THROW_CARDS)
        local len   = pData:len() - 4 * (SKGameDef.SK_MAX_CARDS_PER_CHAIR - nCardsCount)

        local session = self:sendRequest(SKGameDef.SK_GR_THROW_CARDS, pData, len, true)
        self._gameController:setSession(session)
        self._gameController:setResponse(SKGameDef.SK_WAITING_THROW_CARDS)
        print("REQ_ThrowCard request sent")
    else
        print("REQ_ThrowCard error, waitingResponse = " .. waitingResponse)
    end
end

function SKGameConnect:reqPassCards()
    local playerInfoManager = self._gameController:getPlayerInfoManager()
    local uitleInfoManager  = self._gameController:getUtilsInfoManager()
    if not playerInfoManager or not uitleInfoManager then return end

    local waitingResponse = self._gameController:getResponse()
    if waitingResponse == self._gameController:getResWaitingNothing() then
        local GR_PASS_CARDS = SKGameReq["CARDS_PASS"]
        local data          = {
            nUserID         = playerInfoManager:getSelfUserID(),
            nRoomID         = uitleInfoManager:getRoomID(),
            nChairNO        = playerInfoManager:getSelfChairNO(),
            nTableNO        = playerInfoManager:getSelfTableNO()           
        }
        
        if GamePublicInterface and GamePublicInterface:IS_FRAME_1() then
            GR_PASS_CARDS   = SKGameReq["PASS_CARDS_1"]
            data.nSendTable = playerInfoManager:getSelfTableNO()
            data.nSendChair = playerInfoManager:getSelfChairNO()
            data.nSendUser  = playerInfoManager:getSelfUserID()
            data.szHardID   = uitleInfoManager:getHardID() 
            
            uitleInfoManager:setPassInfo(data)          --1.0双扣模板不向自己发送过牌消息 也自行保存吧
        end      
        
        local pData = treepack.alignpack(data, GR_PASS_CARDS)

        local session = self:sendRequest(SKGameDef.SK_GR_PASS_CARDS, pData, pData:len(), true)
        self._gameController:setSession(session)
        self._gameController:setResponse(SKGameDef.SK_WAITING_PASS_CARDS)
        print("REQ_PassCard request sent")
    else
        print("REQ_PassCard error, waitingResponse = " .. waitingResponse)
    end
end

function SKGameConnect:reqAuctionBanker(bPassed, nGains)
    local playerInfoManager = self._gameController:getPlayerInfoManager()
    local uitleInfoManager  = self._gameController:getUtilsInfoManager()
    if not playerInfoManager or not uitleInfoManager then return end

    local waitingResponse = self._gameController:getResponse()
    if waitingResponse == self._gameController:getResWaitingNothing() then
        local GR_AUCTION_BANKER = SKGameReq["AUCTION_BANKER"]
        local data          = {
            nUserID         = playerInfoManager:getSelfUserID(),
            nRoomID         = uitleInfoManager:getRoomID(),
            nChairNO        = playerInfoManager:getSelfChairNO(),
            nTableNO        = playerInfoManager:getSelfTableNO(),
            bPassed         = bPassed,
            nGains          = nGains            
        }
        local pData = treepack.alignpack(data, GR_AUCTION_BANKER)

        local session = self:sendRequest(SKGameDef.SK_GR_AUCTION_BANKER, pData, pData:len(), true)
        self._gameController:setSession(session)
        self._gameController:setResponse(SKGameDef.SK_WAITING_AUCTIONBANKER)
        print("REQ_AuctionBanker request sent")
    else
        print("REQ_AuctionBanker error, waitingResponse = " .. waitingResponse)
    end
end

return SKGameConnect