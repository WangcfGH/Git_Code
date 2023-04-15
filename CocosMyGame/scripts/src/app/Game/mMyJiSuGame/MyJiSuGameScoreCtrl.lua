
local MyJiSuGameScoreCtrl = class("MyJiSuGameScoreCtrl")

function MyJiSuGameScoreCtrl:create(panelGameScore, gameController)
    return MyJiSuGameScoreCtrl.new(panelGameScore, gameController)
end

function MyJiSuGameScoreCtrl:ctor(panelGameScore, gameController)
    self._gameController        = gameController
    self._panelGameScore          = panelGameScore

    self:init()
end

function MyJiSuGameScoreCtrl:init()
    if not self._panelGameScore then return end
     
    local panel = self._panelGameScore
    self._title = panel:getChildByName("Text_Title")
    self._panelRounds = {}
    self._txtValues = {}

    for i = 1,3 do
        self._panelRounds[i] = panel:getChildByName("Panel_Round" .. i)
        if self._panelRounds[i] then
            self._txtValues[i] = self._panelRounds[i]:getChildByName("Text_Value")
        end
    end

    self:resetValues()
    --self:setVisible(false)
end

function MyJiSuGameScoreCtrl:setRoundValue(index, value)
    if self._txtValues and self._txtValues[index] and type(value) == "number" then
        self._txtValues[index]:setString(value .. "积分")
    end
end

function MyJiSuGameScoreCtrl:resetValues()
    for i = 1,3 do
        self:setRoundValue(i, 0)
    end
end

function MyJiSuGameScoreCtrl:setVisible(visible)
    if self._panelGameScore then
        self._panelGameScore:setVisible(visible)
    end
end


return MyJiSuGameScoreCtrl
