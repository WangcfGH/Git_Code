
local MyGamePlayer = import("src.app.Game.mMyGame.MyGamePlayer.MyGamePlayer")
local NetlessGamePlayer = class("NetlessGamePlayer", MyGamePlayer)

function NetlessGamePlayer:init()
    NetlessGamePlayer.super.init(self)

    self._playerUpNum:setVisible(false)
    self._playerUpNum:setString("0")

    self._playerUserDeposit:setVisible(true)
    self._playerUserDeposit:setString("0")
end

--玩家银子显示
function NetlessGamePlayer:setDeposit(iDeposit)
    if self._playerUserDeposit then
        self._playerUserDeposit:setVisible(true)
        self._playerUserDeposit:setString("0")
    end
end

function NetlessGamePlayer:showPlayerUpBtn(playerInfo)
    local upBtn = ccui.Helper:seekWidgetByName(self._playerInfoPanel, "Btn_PraiseInfo")
    if upBtn then
        upBtn:setTouchEnabled(false)
        upBtn:setBright(false)
    end
end

return NetlessGamePlayer
