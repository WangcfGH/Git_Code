
local MyGamePlayerManager = import("src.app.Game.mMyGame.MyGamePlayer.MyGamePlayerManager")
local NetlessGamePlayerManager = class("NetlessGamePlayerManager", MyGamePlayerManager)

function NetlessGamePlayerManager:onClickPlayerHead(drawIndex)
    local player = nil
    for i = 1, self._gameController:getTableChairCount() do
        player = self._players[i]
        if player then
            player:showPlayerInfo(false)
            --[[ --防止在完全没网的情况下登录，点击自己的头像会报错
            if drawIndex == 1 and drawIndex == i  then
                player:showPlayerInfo(not player:isPlayerInfoShow())
            else
                player:showPlayerInfo(false)
            end
            --]]
        end
    end
end

return NetlessGamePlayerManager
