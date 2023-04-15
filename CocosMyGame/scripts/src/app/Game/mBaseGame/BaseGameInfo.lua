
local BaseGameGameInfo = class("BaseGameGameInfo")

function BaseGameGameInfo:create(gameInfo, gameController)
    return BaseGameGameInfo.new(gameInfo, gameController)
end

function BaseGameGameInfo:ctor(gameInfo, gameController)
    if not gameController then printError("gameController is nil!!!") return end
    self._gameController    = gameController

    self._gameInfo          = gameInfo

    self._baseScoreWord     = nil
    self._baseScore         = nil

    self:init()
end

function BaseGameGameInfo:init()
    if not self._gameInfo then return end

    self._baseScoreWord = self._gameInfo:getChildByName("gameinfo_basescore_word")
    self._baseScore = self._gameInfo:getChildByName("gameinfo_basescore")

    self:hideAllChildren()
end

function BaseGameGameInfo:hideAllChildren()
    if not self._gameInfo then return end

    local gameInfoChildren = self._gameInfo:getChildren()
    for i = 1, self._gameInfo:getChildrenCount() do
        local child = gameInfoChildren[i]
        if child then
            child:setVisible(false)
        end
    end
end

function BaseGameGameInfo:setBaseScore(score)
    if "string" ~= type(score) then return end

    if self._baseScore then
        self._baseScore:setVisible(true)
        self._baseScore:setString(score)
    end

    if self._baseScoreWord then
        self._baseScoreWord:setVisible(true)
    end
end

function BaseGameGameInfo:setVisible(visible)
    if self._gameInfo then
        self._gameInfo:setVisible(visible)
    end
end

function BaseGameGameInfo:ope_ShowGameInfo(bShow)
    if self._gameInfo then
        self._gameInfo:setVisible(bShow)
    end
end

return BaseGameGameInfo
