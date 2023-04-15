
local MyGameUtilsInfoManager = import("src.app.Game.mMyGame.MyGameUtilsInfoManager")
local NetlessUtilsInfoManager = class("NetlessUtilsInfoManager", MyGameUtilsInfoManager)

function NetlessUtilsInfoManager:getRoomConfigs()
    return 2242
end

function NetlessUtilsInfoManager:getRoomOptions()
    return 2312
end

function NetlessUtilsInfoManager:getAreaID()
    return 999999
end

function NetlessUtilsInfoManager:getRoomMinDeposit()
    return 0
end

function NetlessUtilsInfoManager:getRoomMaxDeposit()
    return 200000000
end

function NetlessUtilsInfoManager:getBaseScore()      return self._utilsStartInfo.nBaseScore end
function NetlessUtilsInfoManager:getBaseDeposit()    return 1 end
function NetlessUtilsInfoManager:getBoutCount()      return self._utilsStartInfo.nBoutCount end
function NetlessUtilsInfoManager:getThrowWait()      return 15 end
function NetlessUtilsInfoManager:getFirstCatch()     return 0 end
function NetlessUtilsInfoManager:getTributeWait()     return 10 end
function NetlessUtilsInfoManager:getReturnWait()      return 10 end


return NetlessUtilsInfoManager