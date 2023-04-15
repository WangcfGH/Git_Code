
local SKGameNotify = import("src.app.Game.mSKGame.SKGameNotify")
local MyGameNotify = class("MyGameNotify", SKGameNotify)

local MyGameDef                             = import("src.app.Game.mMyGame.MyGameDef")
local SKGameDef                             = import("src.app.Game.mSKGame.SKGameDef")

function MyGameNotify:onNotifyReceived(request, msgType, session, data)
    if self:discardOutDateNotify(request, data) then return end
    
    local switchAction = {
        [MyGameDef.GAME_GR_CALL_FRIEND]         = function(data)
            self:onCallFriend(data)
        end,

        [MyGameDef.GAME_GR_SHOW_CARDS]          = function(data)
            self:onShowCards(data)
        end,

        [MyGameDef.GAME_GR_THROW_READY]         = function(data)
            self:onThrowReady()
        end,

        [MyGameDef.GAME_GR_SYSMSG]              = function(data)
            self:onSystemMsg(data)
        end,
        
        [MyGameDef.GAME_GR_TASKDATA]            = function(data)
            self:onGetTaskData(data)
        end,
        
        [MyGameDef.GAME_GR_UP_PLAYER]            = function(data)
            self:onGetUpPlayer(data)
        end,
        
        [MyGameDef.GAME_GR_UP_INFO]            = function(data)
            self:onGetUpInfo(data)
        end,

        [SKGameDef.SK_GR_SENDMSG_TO_PLAYER]            = function(data)
            self:onGameMsg(data)
        end,

        [MyGameDef.GAME_GR_CARDS_INFO]            = function(data)
            self:onCardsInfo(data)
        end,

        [MyGameDef.GAME_GR_CONTINUALINFO]       = function(args)
            self:onContinualWinInfo(data)
        end,

        [MyGameDef.GAME_GR_OFFLINE_KICKING_PLAYER]       = function(args)
            self:onServerKickingPlayer(data)
        end,    

        [MyGameDef.GAME_GR_BUY_PROPS_THROW]       = function(args)
            self:onBuyPropsThow(data)
        end,

        [MyGameDef.GAME_GR_EXPRESSION_THROW]      = function(args)
            self:onExpressionThow(data)
        end,

        [MyGameDef.GR_EXCHANGE_ROUND_TASK]       = function(args)
            self:onExchangeRoundTask(data)
        end,    
        [MyGameDef.GR_FINISH_EXCHANGE_ROUND_TASK]       = function(args)
            self:onFinishExchangeRoundTask(data)
        end,     
        [MyGameDef.GR_UPGRADE_USER_LEVEL]       = function(args)
            self:onUpgradeUserLevel(data)
        end, 
        [MyGameDef.GR_GAME_WIN_GET_EXCHANGE]       = function(args)
            self:onGameWinExchange(data)
        end,
        [MyGameDef.GR_GAME_UNABLE_TO_CONTINUE]       = function(args)
            self:onGameUnableToContinue(data)
        end,
        [MyGameDef.GR_TABLE_PLAYER_5BOMB_DOUBLE]       = function(args)
            self:onGame5BombDouble(data)
        end,
        [MyGameDef.GR_GAME_RESULT_EXCHANGE_INFO]       = function(args)
            self:onGameResultExchangeInfo(data)
        end,
        [MyGameDef.GR_GAME_RESULT_ACTIVITY_SCORE]       = function(args)
            self:onGameResultActivityScore(data)
        end,
        [MyGameDef.GR_EXPRESSION_PROP_GAME]       = function(args)
            self:onExpressionThrow(data)
        end,
        [MyGameDef.GR_OTHER_PLAYER_UPDATE_TIMING_GAME]       = function(args)
            self:onUpdateTimingGame(data)
        end,
        [MyGameDef.GR_GET_GAME_RULE_INFO] = function(data)
            self:onGetGameRuleInfo(data)
        end
    }
    
    if switchAction[request] then
        switchAction[request](data)
    else
        MyGameNotify.super.onNotifyReceived(self, request, msgType, session, data)
    end
end

function MyGameNotify:handleResponse(response, data)
    local switchAction = {
        [MyGameDef.GAME_WAITING_CALL_FRIEND]        = function() end,
        [MyGameDef.GAME_WAITING_SHOW_CARDS]         = function() end,
        [MyGameDef.MY_WAITING_JUDGE_WELFARE]       = function(data)    self:onJudgeWelfare(data)       end,
    }
    
    if switchAction[response] then
        self._gameController:setResponse(self._gameController:getResWaitingNothing())
        switchAction[response](data)
    else
        MyGameNotify.super.handleResponse(self, response, data)
    end
end

function MyGameNotify:operationFailed(response)
    local switchAction = {
        [MyGameDef.GAME_WAITING_CALL_FRIEND]        = function() end,
        [MyGameDef.GAME_WAITING_SHOW_CARDS]         = function() end,
    }
    
    if switchAction[response] then
        self._gameController:setResponse(self._gameController:getResWaitingNothing())
        switchAction[response]()
    else
        MyGameNotify.super.operationFailed(self, response)
    end
end

function MyGameNotify:discardOutDateNotify(request, data)
    if device.platform == "windows" then    
        return false
    end
    if self._gameController:isResume() then
        local switchAction = {
            [MyGameDef.GAME_WAITING_CALL_FRIEND]        = function() end,
            [MyGameDef.GAME_WAITING_SHOW_CARDS]         = function() end,
            [MyGameDef.GAME_GR_CARDS_INFO]         = function() end,
            [MyGameDef.GAME_GR_UP_PLAYER]         = function() end,
            [MyGameDef.GAME_GR_CONTINUALINFO]         = function() end,
            [MyGameDef.GAME_GR_OFFLINE_KICKING_PLAYER]         = function() end,      
            [SKGameDef.SK_GR_GAME_START]      = function(data) self:GameStartDataOut(data) end, 
            [SKGameDef.SK_GR_SENDMSG_TO_PLAYER]    = function(data) self:GameMsgDataOut(data) end,
        }

        if switchAction[request] then
            switchAction[request](data)
            return true
        else
            return MyGameNotify.super.discardOutDateNotify(self, request)
        end
    end
    return false
end

function MyGameNotify:onGameMsg(data)
    print("onGameMsg")
    self._gameController:onGameMsg(data)
end

function MyGameNotify:onCallFriend(data)
    print("onCallFriend")
    self._gameController:onCallFriend(data)
end

function MyGameNotify:onShowCards(data)
    print("onShowCards")
    self._gameController:onShowCards(data)
end

function MyGameNotify:onThrowReady()
    print("onThrowReady")
    self._gameController:ope_ThrowReady()
end

function MyGameNotify:onSystemMsg(data)
    print("onSystemMsg")
    self._gameController:onSystemMsg(data)
end

function MyGameNotify:onGetTaskData(data)
    print("onGetTaskData")
    self._gameController:onGetTaskData(data)
end

function MyGameNotify:onGetUpPlayer(data)
    print("onGetUpPlayer")
    self._gameController:onGetUpPlayer(data)
end

function MyGameNotify:onGetUpInfo(data)
    print("onGetUpInfo")
    self._gameController:onGetUpInfo(data)
end

function MyGameNotify:onCardsInfo(data)
    print("onCardsInfo")
    self._gameController:onCardsInfo(data)
end

function MyGameNotify:onJudgeWelfare(data)
    print("onJudgeWelfare")
    self:handleResponse(BaseGameDef.BASEGAME_WAITING_LOOK_SAFE_DEPOSIT, data)

    self._gameController:JudgeWelfare(data)
end

function MyGameNotify:onContinualWinInfo(data)
    print("onContinualWinInfo")

    --self._gameController:onContinualWinInfo(data)
end

function MyGameNotify:onServerKickingPlayer(data)
    print("onServerKickingPlayer")

    self._gameController:onServerKickingPlayer(data)
end

function MyGameNotify:onBuyPropsThow(data)
    print("onBuyPropsThow")

    self._gameController:onBuyPropsThow(data)
end

function MyGameNotify:onExpressionThow(data)
    print("onExpressionThow")

    self._gameController:onExpressionThow(data)
end

function MyGameNotify:onExchangeRoundTask(data)
    print("onExchangeRoundTask")

    self._gameController:onExchangeRoundTask(data)
end

function MyGameNotify:onFinishExchangeRoundTask(data)
    print("onFinishExchangeRoundTask")

    self._gameController:onFinishExchangeRoundTask(data)
end

function MyGameNotify:GameStartDataOut(data)
    print("GameStartDataOut")
    self._gameController:GameStartDataOut(data)
end

function MyGameNotify:GameMsgDataOut(data)
    print("GameMsgDataOut")
    self._gameController:GameMsgDataOut(data)
end

function MyGameNotify:onUpgradeUserLevel(data)
    print("onUpgradeUserLevel")
    self._gameController:onUpgradeUserLevel(data)
end

function MyGameNotify:onGameWinExchange(data)
    print("onGameWinExchange")
    self._gameController:onGameWinExchange(data)
end

function MyGameNotify:onGameUnableToContinue(data)
    print("onGameUnableToContinue")
    --self._gameController:onGameUnableToContinue(data)
end

function MyGameNotify:onGame5BombDouble(data)
    print("onGame5BombDouble")
    self._gameController:onGame5BombDouble(data)
end

function MyGameNotify:onGameResultExchangeInfo(data)
    print("onGameResultExchangeInfo")
    self._gameController:onGameResultExchangeInfo(data)
end

function MyGameNotify:onGameResultActivityScore(data)
    print("onGameResultActivityScore")
    self._gameController:onGameResultActivityScore(data)
end
function MyGameNotify:onExpressionThrow(data)
    print("onExpressionThrow")

    self._gameController:onExpressionThrow(data)
end
function MyGameNotify:onUpdateTimingGame(data)
    print("onUpdateTimingGame")

    self._gameController:onUpdateTimingGame(data)
end

function MyGameNotify:onGetGameRuleInfo(data)
    if self._gameController then
        self._gameController:onGetGameRuleInfo(data)
    end
end

return MyGameNotify