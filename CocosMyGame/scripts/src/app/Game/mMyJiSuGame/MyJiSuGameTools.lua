local MyJiSuGameTools = class("MyJiSuGameTools", import("src.app.Game.mSKGame.SKGameTools"))


function MyJiSuGameTools:ope_StartPlay()
    self._gameController:ResetArrageButton()
end

function MyJiSuGameTools:onRule()
    if self._gameController:isArenaPlayer() then
        my.informPluginByName({pluginName='ArenaPlayerCourseCtrl'})
    else
        my.informPluginByName({pluginName='JiSuGameRulePlugin'})
    end
end

return MyJiSuGameTools