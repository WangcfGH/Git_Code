local MyJiSuGameUtilsInfoManager = class("MyJiSuGameUtilsInfoManager", import("src.app.Game.mMyGame.MyGameUtilsInfoManager"))
local MyJiSuGameDef = import("src.app.Game.mMyJiSuGame.MyJiSuGameDef")

--理牌时间就是进贡的时间
function MyJiSuGameUtilsInfoManager:getSetCardWait()     
    if self._utilsStartInfo then 
        return self._utilsStartInfo.nThrowWaitEx[3]         
    end 
end

--当前应该出第几墩
function MyJiSuGameUtilsInfoManager:getRoundInfo()     
    return self._nRound
end

--设置当前应该出第几墩
function MyJiSuGameUtilsInfoManager:setRoundInfo(nRound)     
    self._nRound = nRound
end

--获取断线续玩数据
function MyJiSuGameUtilsInfoManager:getGameInfoJS()     
    if self._utilsTableInfo then
        return self._utilsTableInfo.gameInfoJS
    end
end

--获取duncardids 转换成{{},{},{}}形式，同时去除-1
function MyJiSuGameUtilsInfoManager:getJSDunCardIDs(nChairNO)     
    local dunCardIDs = {{},{},{}}
    if self._utilsTableInfo and self._utilsTableInfo.gameInfoJS then
        local gameInfoJS = self._utilsTableInfo.gameInfoJS
        for i = 1, 3 do
            for j = 1, 8 do
                if gameInfoJS.dunCards[nChairNO+1][i].nCardIDs[j] ~= -1 then
                    table.insert(dunCardIDs[i], gameInfoJS.dunCards[nChairNO+1][i].nCardIDs[j])
                end
            end
        end
    end
    return dunCardIDs
end

--获取已扔出的牌，同时去除-1
function MyJiSuGameUtilsInfoManager:getJSThrowedCardIDs()     
    local cardIDs = {{},{},{},{}}
    if self._utilsTableInfo and self._utilsTableInfo.gameInfoJS then
        local gameInfoJS = self._utilsTableInfo.gameInfoJS
        for i = 1, 4 do
            for j = 1, 8 do
                if gameInfoJS.throwedCards[i][j] ~= -1 then
                    table.insert(cardIDs[i], gameInfoJS.throwedCards[i][j])
                end
            end
        end
    end
    return cardIDs
end

return MyJiSuGameUtilsInfoManager