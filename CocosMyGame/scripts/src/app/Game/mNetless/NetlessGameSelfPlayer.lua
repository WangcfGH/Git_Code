
local MyGameSelfPlayer = import("src.app.Game.mMyGame.MyGamePlayer.MyGameSelfPlayer")
local NetlessGameSelfPlayer = class("NetlessGamePlayer", MyGameSelfPlayer)

function NetlessGameSelfPlayer:init()
    NetlessGameSelfPlayer.super.init(self)

    self._playerUpNum:setVisible(false)
    self._playerUpNum:setString("0")
end

function NetlessGameSelfPlayer:showPlayerUpBtn(playerInfo)
    local upBtn = ccui.Helper:seekWidgetByName(self._playerInfoPanel, "Btn_PraiseInfo")
    if upBtn then
        if self._drawIndex == 1 then
            upBtn:setVisible(false)
            return
        end
        
        upBtn:setTouchEnabled(false)
        upBtn:setBright(false)
    end
end

return NetlessGameSelfPlayer
