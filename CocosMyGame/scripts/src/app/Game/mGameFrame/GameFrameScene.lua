
local GameFrameScene = class("GameFrameScene", cc.load("mvc").ViewBase)

function GameFrameScene:ctor(app, name)
    GameFrameScene.super.ctor(self, app, name)
end

function GameFrameScene:onCreate()
    self:init()
end

function GameFrameScene:init()
    self:createBaseLayer()
    self:createLoadingLayer()
end

function GameFrameScene:createBaseLayer()       end
function GameFrameScene:createBackgroundLayer() end
function GameFrameScene:createGameLayer()       end
function GameFrameScene:createSysInfoLayer()    end
function GameFrameScene:createLoadingLayer()    end

function GameFrameScene:onEnter()
    my.scheduleOnce(function()
        self:createGameLayer()
        self:createSysInfoLayer()
    end, 0)

end

function GameFrameScene:onExit()
end

return GameFrameScene
