local MyJiSuGameNotify = class("MyJiSuGameNotify", import("src.app.Game.mMyGame.MyGameNotify"))
local MyJiSuGameDef = import("src.app.Game.mMyJiSuGame.MyJiSuGameDef")

function MyJiSuGameNotify:handleResponse(response, data)
    local switchAction = {
        [MyJiSuGameDef.GAME_WAITING_ADJUST] = function() self:onAdjustSucceed(data) end,
    }
    
    if switchAction[response] then
        self._gameController:setResponse(self._gameController:getResWaitingNothing())
        switchAction[response](data)
    else
        MyJiSuGameNotify.super.handleResponse(self, response, data)
    end
end

function MyJiSuGameNotify:operationFailed(response)
    local switchAction = {
        [MyJiSuGameDef.GAME_WAITING_ADJUST] = function() self:onAdjustFailed() end,
    }
    
    if switchAction[response] then
        self._gameController:setResponse(self._gameController:getResWaitingNothing())
        switchAction[response]()
    else
        MyJiSuGameNotify.super.operationFailed(self, response)
    end
end

function MyJiSuGameNotify:onAdjustSucceed(data)
    print("onAdjustSucceed")
    self._gameController:onGameMsg(data)
end

function MyJiSuGameNotify:onAdjustFailed()
    print("onAdjustFailed")
    self._gameController:onAdjustFailed()
end

return MyJiSuGameNotify