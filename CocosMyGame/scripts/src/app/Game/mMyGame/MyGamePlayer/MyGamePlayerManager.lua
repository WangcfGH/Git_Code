local SKGamePlayerManager = import("src.app.Game.mSKGame.SKGamePlayerManager")
local MyGamePlayerManager = class("MyGamePlayerManager", SKGamePlayerManager)
local AdvertModel         = import('src.app.plugins.advert.AdvertModel'):getInstance()
local AdvertDefine        = import('src.app.plugins.advert.AdvertDefine')

function MyGamePlayerManager:tipJingBao(drawIndex)
    if self._players[drawIndex] then
        self._players[drawIndex]:tipJingBao()
    end
end

--设置玩家银子
function MyGamePlayerManager:setPlayerDeposit(drawIndex, nDeposit)
    if PUBLIC_INTERFACE.IsStartAsAnchorMatchGame() then
        return
    end
    
    if self._players[drawIndex] then
        self._players[drawIndex]:setDeposit(nDeposit)
    end
end

function MyGamePlayerManager:setPlayerAlarm(drawIndex, isHaveAlarm)
    if self._players[drawIndex] then
        self._players[drawIndex]:setAlarm(isHaveAlarm)
    end
end

function MyGamePlayerManager:updataExpressionInfo(data)
    local sourceIndex = self._gameController:rul_GetDrawIndexByChairNO(data.nChairNO)
    local selfIndex = self._gameController:getMyDrawIndex()
    if sourceIndex == selfIndex then
        for i = 1, 4 do
            if self._players[i] then
                self._players[i]:updataExpressionInfo()
            end    
        end
    end
end

function MyGamePlayerManager:freshMyNobilityPrivilege(nlevel)
    if self._players[1] then
        self._players[1]:freshNobilityPrivilegeHead(nlevel)
    end 
end

function MyGamePlayerManager:FreshPlace(drawIndex, nPlace)
    -- 广告模块 start
    local selfIndex = self._gameController:getMyDrawIndex()
    if drawIndex == selfIndex and nPlace < 3 and not self._gameController:isNeedDeposit() then
        if AdvertModel:isNeedShowInterstitial(AdvertDefine.INTERSTITIAL_THROW_OVER_SCORE) then
            AdvertModel:showInterstitialAdvert(AdvertDefine.INTERSTITIAL_THROW_OVER_SCORE)
            AdvertModel:addInterVdShowCount(AdvertDefine.INTERSTITIAL_THROW_OVER_SCORE, 1)
        end    
    end
    -- 广告模块 end

    MyGamePlayerManager.super.FreshPlace(self, drawIndex, nPlace)
end 

function MyGamePlayerManager:setTimingScore(drawIndex, score)
    if self._players[drawIndex] then
        self._players[drawIndex]:setTimingScore(score)
    end
end

return MyGamePlayerManager