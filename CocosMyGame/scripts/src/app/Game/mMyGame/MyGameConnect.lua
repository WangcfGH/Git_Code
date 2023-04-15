
local SKGameConnect = import("src.app.Game.mSKGame.SKGameConnect")
local MyGameConnect = class("MyGameConnect", SKGameConnect)

local treepack                              = cc.load("treepack")

local MyGameReq                             = import("src.app.Game.mMyGame.MyGameReq")
local MyGameDef                             = import("src.app.Game.mMyGame.MyGameDef")
local SKGameDef                             = import("src.app.Game.mSKGame.SKGameDef")
local SKGameReq                             = import("src.app.Game.mSKGame.SKGameReq")
local BaseGameReq                           = import("src.app.Game.mBaseGame.BaseGameReq")
local BaseGameDef                           = import("src.app.Game.mBaseGame.BaseGameDef")
local UserModel                             = mymodel('UserModel'):getInstance()
local NobilityPrivilegeModel      = import("src.app.plugins.NobilityPrivilege.NobilityPrivilegeModel"):getInstance()

MyGameConnect.delayTime = 0

protobuf.register_file('src/app/Game/mMyGame/proto/pbAnchorMatch.pb')
protobuf.register_file('src/app/Game/mMyGame/proto/pbNewUserGuide.pb')

function MyGameConnect:reqShowCards(bShow)
    local playerInfoManager = self._gameController:getPlayerInfoManager()
    local uitleInfoManager  = self._gameController:getUtilsInfoManager()
    if not playerInfoManager or not uitleInfoManager then return end

    local waitingResponse = self._gameController:getResponse()
    if waitingResponse == self._gameController:getResWaitingNothing() then
        local GR_SHOW_CARDS = MyGameReq["SHOW_CARDS"]
        local data          = {
            nUserID         = playerInfoManager:getSelfUserID(),
            nRoomID         = uitleInfoManager:getRoomID(),
            nChairNO        = playerInfoManager:getSelfChairNO(),
            nTableNO        = playerInfoManager:getSelfTableNO(),

            bShow           = 0,

            nSendTable      = playerInfoManager:getSelfTableNO(),
            nSendChair      = playerInfoManager:getSelfChairNO(),
            nSendUser       = playerInfoManager:getSelfUserID(),
            szHardID        = uitleInfoManager:getHardID()
        }

        if bShow then
            data.bShow      = 1
        end

        local pData = treepack.alignpack(data, GR_SHOW_CARDS)

        local session = self:sendRequest(MyGameDef.GAME_GR_SHOW_CARDS, pData, pData:len(), true)
        self._gameController:setSession(session)
        self._gameController:setResponse(MyGameDef.GAME_WAITING_SHOW_CARDS)
        print("REQ_ShowCards request sent")
    else
        print("REQ_ShowCards error, waitingResponse = " .. waitingResponse)
    end
end

function MyGameConnect:reqCallFriend(nCardID)
    local playerInfoManager = self._gameController:getPlayerInfoManager()
    local uitleInfoManager  = self._gameController:getUtilsInfoManager()
    if not playerInfoManager or not uitleInfoManager then return end

    local waitingResponse = self._gameController:getResponse()
    if waitingResponse == self._gameController:getResWaitingNothing() then
        local GR_CALL_FRIEND    = MyGameReq["CALL_FRIEND"]
        local data              = {
            nUserID             = playerInfoManager:getSelfUserID(),
            nRoomID             = uitleInfoManager:getRoomID(),
            nChairNO            = playerInfoManager:getSelfChairNO(),
            nTableNO            = playerInfoManager:getSelfTableNO(),

            nSendTable          = playerInfoManager:getSelfTableNO(),
            nSendChair          = playerInfoManager:getSelfChairNO(),
            nSendUser           = playerInfoManager:getSelfUserID(),
            szHardID            = uitleInfoManager:getHardID(),

            nCardID             = nCardID
        }

        local pData = treepack.alignpack(data, GR_CALL_FRIEND)

        local session = self:sendRequest(MyGameDef.GAME_GR_CALL_FRIEND, pData, pData:len(), true)
        self._gameController:setSession(session)
        self._gameController:setResponse(MyGameDef.GAME_WAITING_CALL_FRIEND)
        print("REQ_CallFriend request sent")
    else
        print("REQ_CallFriend error, waitingResponse = " .. waitingResponse)
    end
end

function MyGameConnect:sendHagdMsgToServer(msgID, dataOther)
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
        self:sendRequest(SKGameDef.SK_GR_SENDMSG_TO_SERVER, pData, pData:len(), false)
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
        self:sendRequest(SKGameDef.SK_GR_SENDMSG_TO_SERVER, pData, pData:len(), false)
    end
    
    print("REQ_MsgToServer request sent")
end

function MyGameConnect:sendMsgToServer(msgID)
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

    self:sendRequest(SKGameDef.SK_GR_SENDMSG_TO_SERVER, pData, pData:len(), false)
    print("REQ_MsgToServer request sent")
end

function MyGameConnect:reqUpPlayer(drawIndex)
    local playerInfoManager = self._gameController:getPlayerInfoManager()
    local uitleInfoManager  = self._gameController:getUtilsInfoManager()
    if not playerInfoManager or not uitleInfoManager then return end
    local playerInfo = playerInfoManager:getPlayerInfo(drawIndex)

    local nPlatform = 0
    -- 0表示安卓 1表示IOS 2表示同城游IOS
    if device.platform == "ios" then
        if cc.exports.LaunchMode["ALONE"] == MCAgent:getInstance():getLaunchMode() then
            nPlatform = 1
        else
             nPlatform = 2
        end     
    end
    local nReserved = {}
    for i = 1, 4 do
        nReserved[i] = 0
    end
    nReserved[1] = nPlatform
    

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
            szDestName          = playerInfo.szUserName,
            nReserved           = nReserved ,
            kpiClientData       = self.getKPIClientData()
        }

        local pData = treepack.alignpack(data, GR_UP_PLAYER)

        local session = self:sendRequest(MyGameDef.GAME_GR_UP_PLAYER, pData, pData:len(), false)
        --self._gameController:setSession(session)
        --self._gameController:setResponse(MyGameDef.GAME_GR_UP_PLAYER)
        print("REQ_UpPlayer request sent")
   -- else
    --    print("REQ_UpPlayer error, waitingResponse = " .. waitingResponse)
   -- end
end

function MyGameConnect:reqUpInfo(soloPlayer)
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

        local session = self:sendRequest(MyGameDef.GAME_GR_UP_INFO, pData, pData:len(), false)
        --self._gameController:setSession(session)
        --self._gameController:setResponse(MyGameDef.GAME_GR_UP_INFO)
        print("REQ_UpInfo request sent")
    --else
    --    print("REQ_UpInfo error, waitingResponse = " .. waitingResponse)
    --end
end

function MyGameConnect:reqCheckOffline()
    local playerInfoManager = self._gameController:getPlayerInfoManager()
    local uitleInfoManager  = self._gameController:getUtilsInfoManager()
    if not playerInfoManager or not uitleInfoManager then return end

    local GR_CHECK_OFFLINE = MyGameReq["CHECK_OFFLINE"]
    local data              = {
        nUserID             = playerInfoManager:getSelfUserID(),
        nRoomID             = uitleInfoManager:getRoomID(),
        nTableNO            = playerInfoManager:getSelfTableNO(),
        nChairNO            = playerInfoManager:getSelfChairNO()
    }
    local pData = treepack.alignpack(data, GR_CHECK_OFFLINE)

    self:sendRequest(MyGameDef.GAME_GR_CHECK_OFFLINE, pData, pData:len(), false)
    print("REQ_CheckOffline request sent")
end

function MyGameConnect:TablePlayerForUpdateDeposit(Deposit) --领取低保 银两更新 通知其他玩家
    local playerInfoManager = self._gameController:getPlayerInfoManager()
    local uitleInfoManager  = self._gameController:getUtilsInfoManager()
    if not playerInfoManager or not uitleInfoManager then return end

    local UPDATE_DEPOSIT_TABLE = MyGameReq["UPDATE_DEPOSIT_TABLE"]
    local data              = {
        nUserID             = playerInfoManager:getSelfUserID(),
        nRoomID             = uitleInfoManager:getRoomID(),
        nTableNO            = playerInfoManager:getSelfTableNO(),
        nChairNO            = playerInfoManager:getSelfChairNO(),
        nDeposit            = Deposit
    }
    local pData = treepack.alignpack(data, UPDATE_DEPOSIT_TABLE)

    self:sendRequest(MyGameDef.GAME_GR_OTHER_PLAYER_UPDATE_DEPOSIT, pData, pData:len(), false)
    print("REQ_UpdateOtherPlayerDeposit request sent")
end

function MyGameConnect:TablePlayerForUpdateTimingGameScore(score) --定时赛更新玩家积分
    local playerInfoManager = self._gameController:getPlayerInfoManager()
    local uitleInfoManager  = self._gameController:getUtilsInfoManager()
    if not playerInfoManager or not uitleInfoManager then return end

    local UPDATE_DEPOSIT_TABLE = MyGameReq["UPDATE_TIMING_GAME_TABLE"]
    local data              = {
        nUserID             = playerInfoManager:getSelfUserID(),
        nRoomID             = uitleInfoManager:getRoomID(),
        nTableNO            = playerInfoManager:getSelfTableNO(),
        nChairNO            = playerInfoManager:getSelfChairNO(),
        nScore              = score
    }
    local pData = treepack.alignpack(data, UPDATE_DEPOSIT_TABLE)

    self:sendRequest(MyGameDef.GR_OTHER_PLAYER_UPDATE_TIMING_GAME, pData, pData:len(), false)
    print("TablePlayerForUpdateTimingGameScore request sent")
end

function MyGameConnect:reqBuyPropsThrow(drawIndex)
    local playerInfoManager = self._gameController:getPlayerInfoManager()
    local uitleInfoManager  = self._gameController:getUtilsInfoManager()
    if not playerInfoManager or not uitleInfoManager then return end
    local playerInfo = playerInfoManager:getPlayerInfo(drawIndex)
    if not playerInfo then return end
    
    local nPlatform = 0
    -- 0表示安卓 1表示IOS 2表示同城游IOS
    if device.platform == "ios" then
        if cc.exports.LaunchMode["ALONE"] == MCAgent:getInstance():getLaunchMode() then
            nPlatform = 1
        else
            nPlatform = 2
        end     
    end

    local GR_BUY_PROPS    = MyGameReq["BUY_PROPS_THROW"]
    local data              = {
        nUserID             = playerInfoManager:getSelfUserID(),
        nRoomID             = uitleInfoManager:getRoomID(),
        nTableNO            = playerInfoManager:getSelfTableNO(),
        nChairNO            = playerInfoManager:getSelfChairNO(),
            
        nDestUserID         = playerInfo.nUserID,
        nDestChairNO        = playerInfo.nChairNO,
        nPropID             = 1,             
        nOSType             = nPlatform,
        szDestName          = playerInfo.szUserName,
        nCurrentCount       = 0,
        kpiClientData = self.getKPIClientData()
    }

    local pData = treepack.alignpack(data, GR_BUY_PROPS)

    local session = self:sendRequest(MyGameDef.GAME_GR_BUY_PROPS_THROW, pData, pData:len(), false)
    print("reqBuyPropsThrow request sent")
end

function MyGameConnect:reqExpressionThrow(drawIndex, expressionIndex)
    local playerInfoManager = self._gameController:getPlayerInfoManager()
    local uitleInfoManager  = self._gameController:getUtilsInfoManager()
    if not playerInfoManager or not uitleInfoManager then return end
    local playerInfo = playerInfoManager:getPlayerInfo(drawIndex)
    if not playerInfo then return end
    
    local nPlatform = 0
    -- 0表示安卓 1表示IOS 2表示同城游IOS
    if device.platform == "ios" then
        if cc.exports.LaunchMode["ALONE"] == MCAgent:getInstance():getLaunchMode() then
            nPlatform = 1
        else
            nPlatform = 2
        end     
    end

    local THROW_EXPRESSION    = MyGameReq["THROW_EXPRESSION"]
    local data              = {
        nUserID             = playerInfoManager:getSelfUserID(),
        nRoomID             = uitleInfoManager:getRoomID(),
        nTableNO            = playerInfoManager:getSelfTableNO(),
        nChairNO            = playerInfoManager:getSelfChairNO(),
            
        nExpressionIndex    = expressionIndex,
        nOSType             = nPlatform
    }

    local pData = treepack.alignpack(data, THROW_EXPRESSION)

    local session = self:sendRequest(MyGameDef.GAME_GR_EXPRESSION_THROW, pData, pData:len(), false)
    print("reqExpressionThrow request sent")
end

function MyGameConnect:reqExchangeRoundTask()
    local playerInfoManager = self._gameController:getPlayerInfoManager()
    if not playerInfoManager then return end
    
    local ExchangeCenterModel = require("src.app.plugins.ExchangeCenter.ExchangeCenterModel"):getInstance()

    local EXCHANGE_ROUND_INFO    = MyGameReq["EXCHANGE_ROUND_INFO"]
    local data              = {
        nUserID             = playerInfoManager:getSelfUserID(),
        nExchangeRoundNum   = ExchangeCenterModel:getTicketNumData() 
    }

    local pData = treepack.alignpack(data, EXCHANGE_ROUND_INFO)

    local session = self:sendRequest(MyGameDef.GR_EXCHANGE_ROUND_TASK, pData, pData:len(), false)
    print("reqExchangeRoundTask request sent")
end

function MyGameConnect:reqFinishExchangeRoundTask()
    local playerInfoManager = self._gameController:getPlayerInfoManager()
    local uitleInfoManager  = self._gameController:getUtilsInfoManager()
    if not playerInfoManager or not uitleInfoManager then return end
    
    local FINISH_EXCHANGE_ROUND_INFO    = MyGameReq["FINISH_EXCHANGE_ROUND_INFO"]
    local data              = {
        nUserID             = playerInfoManager:getSelfUserID(),
        nRoomID             = uitleInfoManager:getRoomID(),
        nTableNO            = playerInfoManager:getSelfTableNO(),
        nChairNO            = playerInfoManager:getSelfChairNO(),
    }

    local pData = treepack.alignpack(data, FINISH_EXCHANGE_ROUND_INFO)

    local session = self:sendRequest(MyGameDef.GR_FINISH_EXCHANGE_ROUND_TASK, pData, pData:len(), false)
    print("reqFinishExchangeRoundTask request sent")
end

function MyGameConnect:reqUpgradeUserLevel(data)
    local session = self:sendRequest(MyGameDef.GR_UPGRADE_USER_LEVEL, data, data:len(), false)
    print("reqUpgradeUserLevel request sent")
end

function MyGameConnect:reqGameWinExchange(data)
    local session = self:sendRequest(MyGameDef.GR_GAME_WIN_GET_EXCHANGE, data, data:len(), false)
    print("reqGameWinExchange request sent")
end

function MyGameConnect:reqGameWinGetRoomExchange()
    local playerInfoManager = self._gameController:getPlayerInfoManager()
    local uitleInfoManager  = self._gameController:getUtilsInfoManager()
    if not playerInfoManager or not uitleInfoManager then return end

    local FINISH_EXCHANGE_ROUND_INFO    = MyGameReq["FINISH_EXCHANGE_ROUND_INFO"]
    local data              = {
        nUserID             = playerInfoManager:getSelfUserID(),
        nRoomID             = uitleInfoManager:getRoomID(),
        nTableNO            = playerInfoManager:getSelfTableNO(),
        nChairNO            = playerInfoManager:getSelfChairNO(),
    }

    local pData = treepack.alignpack(data, FINISH_EXCHANGE_ROUND_INFO)
    local session = self:sendRequest(MyGameDef.GR_GAME_WIN_GET_ROOM_EXCHANGE, pData, pData:len(), false)
    print("reqGameWinGetRoomExchange request sent")
end

function MyGameConnect:gc_LeaveGameEx()
    local playerInfoManager = self._gameController:getPlayerInfoManager()
    local utilsInfoManager  = self._gameController:getUtilsInfoManager()
    if not playerInfoManager or not utilsInfoManager then return end

    --local waitingResponse = self._gameController:getResponse()
    --if waitingResponse == self._gameController:getResWaitingNothing() then
        local GR_LEAVE_GAME = BaseGameReq["LEAVE_GAME"]
        local data          = {
            nUserID         = playerInfoManager:getSelfUserID(),
            nRoomID         = utilsInfoManager:getRoomID(),
            nTableNO        = playerInfoManager:getSelfTableNO(),
            nChairNO        = playerInfoManager:getSelfChairNO(),
            nSendTable      = playerInfoManager:getSelfTableNO(),
            nSendChair      = playerInfoManager:getSelfChairNO(),
            nSendUser       = playerInfoManager:getSelfUserID(),
            szHardID        = utilsInfoManager:getHardID()
        }
        local pData = treepack.alignpack(data, GR_LEAVE_GAME)

        self:sendRequest(BaseGameDef.BASEGAME_GR_LEAVE_GAME, pData, pData:len(), true)
        self._gameController:setResponse(BaseGameDef.BASEGAME_WAITING_LEAVE_GAME)
        print("~~~~~~~~~~~~~~GC_LeaveGame request sent~~~~~~~~~~~~~~~~~~~~~~~~~~")
    --else
    --    print("GC_LeaveGame error, waitingResponse = " .. waitingResponse)
    --end
end

-- 重载是为了解决后台切回的时候，点击出牌或者不出按钮，按钮消失，但操作并未执行的问题
-------------------BEDIN--------------------
function MyGameConnect:reqThrowCards(cardUnite, bAutoPlay)
    self.delayTime = self.delayTime + 0.3
    if self.delayTime > 0.9 then
        self.delayTime = 0
        self._gameController:showOperationBtns()
        return
    end
    local playerInfoManager = self._gameController:getPlayerInfoManager()
    local uitleInfoManager  = self._gameController:getUtilsInfoManager()
    if not playerInfoManager or not uitleInfoManager or not cardUnite then return end

    local waitingResponse = self._gameController:getResponse()
    local nReserved = {}
    for i = 1, 4 do
        nReserved[i] = 0
    end
    nReserved[1] = bAutoPlay and 1 or 0
    if waitingResponse == self._gameController:getResWaitingNothing() then
        self.delayTime = 0
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
            nReserved       = nReserved
        }
        local pData = treepack.alignpack(data, GR_THROW_CARDS)
        local len   = pData:len() - 4 * (SKGameDef.SK_MAX_CARDS_PER_CHAIR - cardUnite.nCardsCount)

        local session = self:sendRequest(SKGameDef.SK_GR_THROW_CARDS, pData, len, true)
        self._gameController:setSession(session)
        self._gameController:setResponse(SKGameDef.SK_WAITING_THROW_CARDS)
        print("REQ_ThrowCard request sent")
    else
        print("REQ_ThrowCard error, waitingResponse = " .. waitingResponse)
        my.scheduleOnce(function()
            if self._gameController == nil or self._gameController:isInGameScene() == false then
                return
            end
            self:reqThrowCards(cardUnite,bAutoPlay)
        end, 0.3)
    end
end

function MyGameConnect:reqThrowCards_1(nCardIDs, nCardsCount, dwCardsType)
    if not nCardIDs or not nCardsCount or not dwCardsType then return end

    self.delayTime = self.delayTime + 0.3
    if self.delayTime > 0.9 then
        self.delayTime = 0
        self._gameController:showOperationBtns()
        return
    end
    
    local playerInfoManager = self._gameController:getPlayerInfoManager()
    local utilsInfoManager  = self._gameController:getUtilsInfoManager()
    if not playerInfoManager or not utilsInfoManager then return end

    local waitingResponse = self._gameController:getResponse()
    if waitingResponse == self._gameController:getResWaitingNothing() then
        self.delayTime = 0
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
        print("REQ_ThrowCard error, _1 waitingResponse = " .. waitingResponse)
        my.scheduleOnce(function()
            if self._gameController == nil or self._gameController:isInGameScene() == false then
                return
            end
            self:reqThrowCards_1(nCardIDs, nCardsCount, dwCardsType)
        end,0.3)
    end
end

function MyGameConnect:reqPassCards(bAutoPlay)
    self.delayTime = self.delayTime + 0.3
    if self.delayTime > 0.9 then
        self.delayTime = 0
        self._gameController:showOperationBtns()
        return
    end

    local playerInfoManager = self._gameController:getPlayerInfoManager()
    local uitleInfoManager  = self._gameController:getUtilsInfoManager()
    if not playerInfoManager or not uitleInfoManager then return end

    local waitingResponse = self._gameController:getResponse()
    local nReserved = {}
    for i = 1, 4 do
        nReserved[i] = 0
    end
    nReserved[1] = bAutoPlay and 1 or 0
    if waitingResponse == self._gameController:getResWaitingNothing() then
        self.delayTime = 0

        local GR_PASS_CARDS = SKGameReq["CARDS_PASS"]
        local data          = {
            nUserID         = playerInfoManager:getSelfUserID(),
            nRoomID         = uitleInfoManager:getRoomID(),
            nChairNO        = playerInfoManager:getSelfChairNO(),
            nTableNO        = playerInfoManager:getSelfTableNO(),
            nReserved       = nReserved          
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
        my.scheduleOnce(function()
            if self._gameController == nil or self._gameController:isInGameScene() == false then
                return
            end
            self:reqPassCards()
        end,0.3)
    end
end

function MyGameConnect:sendSDKInfo()
    local playerInfoManager = self._gameController:getPlayerInfoManager()
    local uitleInfoManager  = self._gameController:getUtilsInfoManager()
    if not playerInfoManager or not uitleInfoManager then return end

    local sdkName = ""
    local userPlugin = plugin.AgentManager:getInstance():getUserPlugin()
    if device.platform == "windows" then
        sdkName = "tcy"
    end
    if(userPlugin:isFunctionSupported('getUsingSDKName'))then
        sdkName = userPlugin:getUsingSDKName()
        sdkName = string.lower(sdkName)
        if sdkName == "tcy" then
            if(cc.exports.LaunchMode["PLATFORM"] == MCAgent:getInstance():getLaunchMode())then
                sdkName = "tcyapp"
            end
        end
    end

    --local AssistConnect = require('src.app.plugins.AssistModel.AssistConnect'):getInstance()
    local userPlugin = plugin.AgentManager:getInstance():getUserPlugin()
    local utf8nickname = userPlugin:getNickName()
    local du=DeviceUtils:getInstance()
    local model=du:getPhoneModel()
    local SDKInfo = MyGameReq["NOTIFY_PLAYERINFO_REQ"]
    local data          = {
        nUserID         = playerInfoManager:getSelfUserID(),
        nTableNo        = playerInfoManager:getSelfTableNO(),
        nRoomID         = uitleInfoManager:getRoomID(),
        szPlayerChannel = sdkName,
        szVersion       = self:_getVersion(),
        szNickName      = MCCharset:getInstance():utf82GbString(utf8nickname, string.len(utf8nickname)),
        nSafeDeposit    = UserModel.nSafeboxDeposit,
        szPhone         = model
    }

    local pData = treepack.alignpack(data, SDKInfo)

    local session = self:sendRequest(MyGameDef.MY_SDK_INFO, pData, pData:len(), false)
    print("SDKInfo game request sent")
end

function MyGameConnect:_getVersion()
    local version = my.getGameVersion()
    local ma, mi, bu = cc.exports.parseGameVersion( version )
    return ma..'.'..mi
end

--------------------END---------------------

--[[KPI start]]
--获取KPI上报的数据
function MyGameConnect:getKPIClientData()
    local clientData = my.getKPIClientData()
    local PublicInterface = cc.exports.PUBLIC_INTERFACE
    local playerInfo = PublicInterface.GetPlayerInfo()

    local gameVersion   = clientData.GameVers
    local splitArray    = string.split(gameVersion, ".")
    local majorVer          = 0
    local minorVer          = 0
    local buildno           = 0
    if #splitArray == 3 then
        majorVer        = tonumber(splitArray[1])
        minorVer        = tonumber(splitArray[2])
        buildno         = tonumber(splitArray[3])
    end

    local data  = {
        UserId  = playerInfo.nUserID,
        GameId  = clientData.GameId,
        GameCode = clientData.GameCode,
        ExeMajorVer = majorVer,
        ExeMinorVer = minorVer,
        ExeBuildno = buildno,
        RecomGameId = tonumber(clientData.RecomGameId),
        RecomGameCode = tonumber(clientData.RecomGameCode),
        GroupId = clientData.GroupId,
        Channel = clientData.Channel,
        HardId = clientData.HardId,
        MobileHardInfo = clientData.MobileHardInfo,
        PkgType = clientData.PkgType,
        CUID    = clientData.CUID
    }
    return data
end
--[[KPI end]]

--进入游戏时，上报贵族等级
function MyGameConnect:gc_EnterGame()
    local playerInfoManager = self._gameController:getPlayerInfoManager()
    local utilsInfoManager  = self._gameController:getUtilsInfoManager()
    local arenaInfoManager  = self._gameController:getArenaInfoManager()
    if not playerInfoManager or not utilsInfoManager or not arenaInfoManager then return end
    local TimingGameModel = import('src.app.plugins.TimingGame.TimingGameModel'):getInstance()
    local infoData = TimingGameModel:getInfoData()
    local timingScore = 0
    if PUBLIC_INTERFACE.IsStartAsTimingGame() 
    and infoData and infoData.seasonScore then
        timingScore = infoData.seasonScore
    end

    local waitingResponse = self._gameController:getResponse()
    if waitingResponse == self._gameController:getResWaitingNothing() then
        local GR_ENTER_GAME_EX = BaseGameReq["ENTER_GAME"]

        local data          = {
            nUserID         = playerInfoManager:getSelfUserID(),
            nUserType       = playerInfoManager:getSelfUserType(),
            nGameID         = utilsInfoManager:getGameID(),
            nRoomID         = utilsInfoManager:getRoomID(),
            nTableNO        = playerInfoManager:getSelfTableNO(),
            nChairNO        = playerInfoManager:getSelfChairNO(),
            szHardID        = utilsInfoManager:getHardID(),
            bLookOn         = utilsInfoManager:getLookOn(),
            dwParentGameCode= my.getGameShortName(),
            nRoomTokenID    = utilsInfoManager:getRoomTokenID(),
            nMbNetType      = utilsInfoManager:getMbNetType(),
            nMatchID        = arenaInfoManager:isArenaPlayer() and arenaInfoManager:getMatchID() or 0,
            nParentGameId   = my.getGameID(),
            nUserID1        = playerInfoManager:getSelfUserID(),
            nUserType1      = playerInfoManager:getSelfUserType(),
            nStatus         = playerInfoManager:getSelfStatus(),
            nTableNO1       = playerInfoManager:getSelfTableNO(),
            nChairNO1       = playerInfoManager:getSelfChairNO(),
            nNickSex        = playerInfoManager:getSelfNickSex(),
            nPortrait       = playerInfoManager:getSelfPortrait(),
            nNetSpeed       = playerInfoManager:getSelfNetSpeed(),
            nClothingID     = playerInfoManager:getSelfClothingID(),
            szUsername      = playerInfoManager:getSelfUserName(),
            szNickName      = playerInfoManager:getSelfNickName(),
            nDeposit        = playerInfoManager:getSelfDeposit(),
            nPlayerLevel    = playerInfoManager:getSelfPlayerLevel(),
            nScore          = playerInfoManager:getSelfScore(),
            nBreakOff       = playerInfoManager:getSelfBreakOff(),
            nWin            = playerInfoManager:getSelfWin(),
            nLoss           = playerInfoManager:getSelfLoss(),
            nStandOff       = playerInfoManager:getSelfStandOff(),
            nBout           = playerInfoManager:getSelfBout(),
            nTimeCost       = playerInfoManager:getSelfTimeCost(),
            nReserved1       = {NobilityPrivilegeModel:GetSelfNobilityPrivilegeLevel(),timingScore}            
        }

        local pData = treepack.alignpack(data, GR_ENTER_GAME_EX)
        --dump(cc.exports.GetExtraConfigInfo().GameID)
        dump(data)
        self:sendRequest(BaseGameDef.BASEGAME_GR_ENTER_GAME, pData, pData:len(), true)
        self._gameController:setResponse(BaseGameDef.BASEGAME_WAITING_ENTER_GAME)
        print("GC_EnterGame request sent")
    else
        print("GC_EnterGame error, waitingResponse = " .. waitingResponse)
    end
end

function MyGameConnect:reqSetGameRuleInfo(ruleInfo)
    local params = {
        userid = UserModel.nUserID,
        playtype = ruleInfo.PlayType,
        bouttype = ruleInfo.BoutType,
        encryption = ruleInfo.EncryptionType,
        anchoruserid = UserModel.nUserID,
    }

    local pData = protobuf.encode('pbAnchorMatch.SetGameRuleInfo', params)
    self:sendRequest(MyGameDef.GR_SET_GAME_RULE_INFO, pData, pData:len(), false)
end

function MyGameConnect:reqGetGameRuleInfo()
    local params = {
        userid = UserModel.nUserID
    }

    local pData = protobuf.encode('pbAnchorMatch.GetGameRuleInfo', params)
    self:sendRequest(MyGameDef.GR_GET_GAME_RULE_INFO, pData, pData:len(), false)
end


function MyGameConnect:gc_AnchorLeaveGame()
    local playerInfoManager = self._gameController:getPlayerInfoManager()
    local utilsInfoManager  = self._gameController:getUtilsInfoManager()
    if not playerInfoManager or not utilsInfoManager then return end

    local waitingResponse = self._gameController:getResponse()
    if waitingResponse == self._gameController:getResWaitingNothing() then
        local GR_LEAVE_GAME = BaseGameReq["LEAVE_GAME"]
        local data          = {
            nUserID         = playerInfoManager:getSelfUserID(),
            nRoomID         = utilsInfoManager:getRoomID(),
            nTableNO        = playerInfoManager:getSelfTableNO(),
            nChairNO        = playerInfoManager:getSelfChairNO(),
            nSendTable      = playerInfoManager:getSelfTableNO(),
            nSendChair      = playerInfoManager:getSelfChairNO(),
            nSendUser       = playerInfoManager:getSelfUserID(),
            szHardID        = utilsInfoManager:getHardID()
        }
        local pData = treepack.alignpack(data, GR_LEAVE_GAME)

        self:sendRequest(MyGameDef.GR_ANCHOR_LEAVE_GAME, pData, pData:len(), true)
        self._gameController:setResponse(BaseGameDef.BASEGAME_WAITING_LEAVE_GAME)
        print("~~~~~~~~~~~~~~GC_LeaveGame request sent~~~~~~~~~~~~~~~~~~~~~~~~~~")
    else
        print("GC_LeaveGame error, waitingResponse = " .. waitingResponse)
    end
end

-- 引导局引导开始时间上报
function MyGameConnect:reqStartGuide(bout)
    local playerInfoManager = self._gameController:getPlayerInfoManager()
    local data = {
        userid = playerInfoManager:getSelfUserID(),
        step = bout,
        starttime = os.time()
    }

    local pData = protobuf.encode('pbNewUserGuide.LogBoutGuideData', data)
    self:sendRequest(MyGameDef.GR_BOUTGUIDE_UPLOAD_DATA, pData, pData:len(), false)
end

-- 引导局引导结束时间上报
function MyGameConnect:reqFinishGuide()
    local nGuideBout = self._gameController._baseGameUtilsInfoManager._utilsStartInfo.nGuideBout
    local playerInfoManager = self._gameController:getPlayerInfoManager()
    local data = {
        userid = playerInfoManager:getSelfUserID(),
        step = nGuideBout,
        endtime = os.time()
    }

    local pData = protobuf.encode('pbNewUserGuide.LogBoutGuideData', data)
    self:sendRequest(MyGameDef.GR_BOUTGUIDE_UPLOAD_DATA, pData, pData:len(), false)
end

-- 引导局完成对局上报
function MyGameConnect:reqFinishGuideBout()
    local nGuideBout = self._gameController._baseGameUtilsInfoManager._utilsStartInfo.nGuideBout
    local playerInfoManager = self._gameController:getPlayerInfoManager()
    local data = {
        userid = playerInfoManager:getSelfUserID(),
        step = nGuideBout,
        finish = 1,
    }

    local pData = protobuf.encode('pbNewUserGuide.LogBoutGuideData', data)
    self:sendRequest(MyGameDef.GR_BOUTGUIDE_UPLOAD_DATA, pData, pData:len(), false)
end

-- 引导局托管上报
function MyGameConnect:reqAutoPlay()
    local nGuideBout = self._gameController._baseGameUtilsInfoManager._utilsStartInfo.nGuideBout
    local playerInfoManager = self._gameController:getPlayerInfoManager()
    local data = {
        userid = playerInfoManager:getSelfUserID(),
        step = nGuideBout,
        bot = 1
    }

    local pData = protobuf.encode('pbNewUserGuide.LogBoutGuideData', data)
    self:sendRequest(MyGameDef.GR_BOUTGUIDE_UPLOAD_DATA, pData, pData:len(), false)
end

return MyGameConnect