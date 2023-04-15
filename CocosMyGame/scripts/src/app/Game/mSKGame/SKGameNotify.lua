
local BaseGameNotify = import("src.app.Game.mBaseGame.BaseGameNotify")
local SKGameNotify = class("SKGameNotify", BaseGameNotify)

local SKGameDef                             = import("src.app.Game.mSKGame.SKGameDef")

local GamePublicInterface                   = import("src.app.Game.mMyGame.GamePublicInterface")

function SKGameNotify:onNotifyReceived(request, msgType, session, data)
    if self:discardOutDateNotify(request) then return end
    
    local switchAction = {
        [SKGameDef.SK_GR_GAME_START]        = function(data)
            self._gameController:setResponse(self._gameController:getResWaitingNothing())
            self:onGameStart(data)
        end,
        
        [SKGameDef.GR_TOCLIENT_OFFLINE]       = function(data)
            self:onOffline(data)
        end,

        [SKGameDef.SK_GR_CARDS_THROW]       = function(data)
            self:onCardsThrow(data)
        end,
        
        [SKGameDef.SK_GR_CARDS_PASS]        = function(data)
            self:onCardsPass(data)
        end,
        
        [SKGameDef.SK_GR_BANKER_AUCTION]    = function(data)
            self:onBankerAuction(data)
        end,
        
        [SKGameDef.SK_GR_AUCTION_FINISHED]  = function(data)
            self:onAuctionFinished(data)
        end,
        
        [SKGameDef.SK_GR_INVALID_THROW]     = function(data)
            self:onInvalidThrow(data)
        end,
        
        [SKGameDef.SK_GR_CARDS_INFO]        = function(data)
            self:onCardsInfo(data)
        end,
        
        [SKGameDef.SK_GR_THROW_AGAIN]        = function(data)
            self:onThrowAgain(data)
        end,

        [SKGameDef.SK_GR_GAINS_BONUS]        = function(data)
            self:onGainsBonus(data)
        end,
        
        [SKGameDef.SK_GR_GAME_WIN]          = function(data)
            self._gameController:setResponse(self._gameController:getResWaitingNothing())
            self:onGameWin(data)
        end,
    }
    
    if switchAction[request] then
        switchAction[request](data)
    else
        SKGameNotify.super.onNotifyReceived(self, request, msgType, session, data)
    end    
end

function SKGameNotify:handleResponse(response, data)
    local switchAction = {
        [SKGameDef.SK_WAITING_THROW_CARDS]      = function()
            if GamePublicInterface and GamePublicInterface:IS_FRAME_1() then
                self:rspThrowCards(data)            --1.0模板这里返回了throw_ok结构                                                                         
            end
        end,
        
        [SKGameDef.SK_WAITING_PASS_CARDS]       = function()
            if GamePublicInterface and GamePublicInterface:IS_FRAME_1() then
                self:rspPassCards(data)            --1.0模板这里返回了pass_ok结构                                                                         
            end
        end,
        
        [SKGameDef.SK_WAITING_AUCTIONBANKER]    = function()
        end,
    }
    
    if switchAction[response] then
        self._gameController:setResponse(self._gameController:getResWaitingNothing())
        switchAction[response](data)
    else
        SKGameNotify.super.handleResponse(self, response, data)
    end
end

function SKGameNotify:operationFailed(response)
    local switchAction = {
        [SKGameDef.SK_WAITING_THROW_CARDS]      = function()
            print("operationFailed when SK_WAITING_THROW_CARDS")
            if self._gameController and self._gameController.onThrowCardFailed then
                self._gameController:onThrowCardFailed()
            end
        end,
        [SKGameDef.SK_WAITING_PASS_CARDS]       = function() end,
        [SKGameDef.SK_WAITING_AUCTIONBANKER]    = function() end,
    }

    if switchAction[response] then
        self._gameController:setResponse(self._gameController:getResWaitingNothing())
        switchAction[response]()
    else
        SKGameNotify.super.operationFailed(self, response)
    end
end

function SKGameNotify:discardOutDateNotify(request)
    if self._gameController:isResume() then
        local switchAction = {
            [SKGameDef.SK_WAITING_THROW_CARDS]      = function() end,
            [SKGameDef.SK_WAITING_PASS_CARDS]       = function() end,
            [SKGameDef.SK_GR_CARDS_THROW]    = function() end,
            [SKGameDef.SK_GR_CARDS_PASS]    = function() end,
            [SKGameDef.SK_GR_BANKER_AUCTION]    = function() end,
            [SKGameDef.SK_GR_AUCTION_FINISHED]    = function() end,
--            [SKGameDef.SK_GR_SENDMSG_TO_PLAYER]    = function() end,
        }

        if switchAction[request] then
            return true
        else
            return SKGameNotify.super.discardOutDateNotify(self, request)
        end
    end
    return false
end

function SKGameNotify:onGameStart(data)
    print("onGameStart")
    self._gameController:onGameStart(data)
end

function SKGameNotify:onCardsThrow(data)
    if self._gameController:isCardsThrowResponse(data) then
        self._gameController:setResponse(self._gameController:getResWaitingNothing())
    end
    print("onCardsThrow")
    self._gameController:onCardsThrow(data)
end

function SKGameNotify:onOffline(data)
    print("onOffline")
    self._gameController:onOfflineInfo(data)
end

function SKGameNotify:onCardsPass(data)
    if self._gameController:isCardsPassResponse(data) then
        self._gameController:setResponse(self._gameController:getResWaitingNothing())
    end
    print("onCardsPass")
    self._gameController:onCardsPass(data)
end

function SKGameNotify:onBankerAuction(data)
    print("onBankerAuction")
    self._gameController:onBankerAuction(data)
end

function SKGameNotify:onAuctionFinished(data)
    print("onAuctionFinished")
    self._gameController:onAuctionFinished(data)
end

function SKGameNotify:onInvalidThrow(data)
    print("onInvalidThrow")
    self._gameController:onInvalidThrow(data)
end

function SKGameNotify:onCardsInfo(data)
    print("onCardsInfo")
    self._gameController:onCardsInfo(data)
end

function SKGameNotify:onThrowAgain(data)
    print("onThrowAgain")
    self._gameController:onThrowAgain(data)
end

function SKGameNotify:onGainsBonus(data)
    print("onGainsBonus")
    self._gameController:onGainsBonus(data)
end

function SKGameNotify:onGameWin(data)
    print("onGameWin")
    self._gameController:onGameWin(data)
end

function SKGameNotify:rspThrowCards(data)
    print("rspThrowCards")
    self._gameController:rspThrowCards(data)
end

function SKGameNotify:rspPassCards(data)
    print("rspPassCards")
    self._gameController:rspPassCards(data)
end

return SKGameNotify