
local SKGameResultPanel = class("SKGameResultPanel", ccui.Layout)

function SKGameResultPanel:ctor(gameWin, gameController)
    if not gameWin then printError("gameWin is nil!!!") return end
    if not gameController then printError("gameController is nil!!!") return end
    self._gameWin               = gameWin
    self._gameController        = gameController

    self._resultPanel           = nil

    if self.onCreate then self:onCreate() end
end

function SKGameResultPanel:onCreate()
    self:init()
end

function SKGameResultPanel:init()
    self:initResultPanel()
end

function SKGameResultPanel:initResultPanel()
    --TODO
end

function SKGameResultPanel:onClose()
    self._gameController:playBtnPressedEffect()

    self._gameController:onCloseResultLayer()
end

function SKGameResultPanel:onShare()
    self._gameController:playBtnPressedEffect()

    self._gameController:onShareResult()
end

function SKGameResultPanel:onRestart()
    self._gameController:playBtnPressedEffect()

    self._gameController:onRestart()
end

return SKGameResultPanel
