
local MyGameLoadingPanel = import("src.app.Game.mMyGame.MyGameLoadingPanel")
local NetlessLoadingPanel = class("NetlessLoadingPanel", MyGameLoadingPanel)

function NetlessLoadingPanel:onLoadingInterval() 
    self._bLoading = false
    if self.loadingTimerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.loadingTimerID)
        self.loadingTimerID = nil
    end

    if true then
        if self._gameController then
            self._gameController:onRemoveLoadingLayer()
        end
    else
        local function onLoadingTimeout(dt)
            self:onLoadingTimeout()
        end
        self.loadingTimeoutTimerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(onLoadingTimeout, 5.0, false)
    end
end

return NetlessLoadingPanel