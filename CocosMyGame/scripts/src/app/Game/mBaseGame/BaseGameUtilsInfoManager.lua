
local BaseGameUtilsInfoManager = class("BaseGameUtilsInfoManager")

function BaseGameUtilsInfoManager:create()
    return BaseGameUtilsInfoManager.new()
end

function BaseGameUtilsInfoManager:ctor()
    self._utilsInfo               = {}

    self:init()
end

function BaseGameUtilsInfoManager:init()
    self._utilsInfo.nTablePlayerCount = 0
end

function BaseGameUtilsInfoManager:setTablePlayerCount(tablePlayerCount)
    self._utilsInfo.nTablePlayerCount = tablePlayerCount
end

function BaseGameUtilsInfoManager:getTablePlayerCount()
    return self._utilsInfo.nTablePlayerCount
end

function BaseGameUtilsInfoManager:setUitlsInfo(utilsInfo)
    self:setUtilsInfo(utilsInfo)
end

function BaseGameUtilsInfoManager:setUtilsInfo(utilsInfo)
    self._utilsInfo.szHardID        = utilsInfo.szHardID
    self._utilsInfo.nRoomTokenID    = utilsInfo.nRoomTokenID
    self._utilsInfo.nMbNetType      = utilsInfo.nMbNetType
    self._utilsInfo.bLookOn         = utilsInfo.bLookOn
    self._utilsInfo.nGameID         = utilsInfo.nGameID
    self._utilsInfo.nRoomID         = utilsInfo.nRoomID
    self._utilsInfo.nRoomInfo       = utilsInfo.nRoomInfo
end

function BaseGameUtilsInfoManager:getUtilsInfo()
    return self._utilsInfo
end

function BaseGameUtilsInfoManager:getHardID()       if self._utilsInfo then return self._utilsInfo.szHardID         end end
function BaseGameUtilsInfoManager:getRoomTokenID()  if self._utilsInfo then return self._utilsInfo.nRoomTokenID     end end
function BaseGameUtilsInfoManager:getMbNetType()    if self._utilsInfo then return self._utilsInfo.nMbNetType       end end
function BaseGameUtilsInfoManager:getLookOn()       if self._utilsInfo then return self._utilsInfo.bLookOn          end end
function BaseGameUtilsInfoManager:getGameID()       if self._utilsInfo then return my.getGameID()                   end end
function BaseGameUtilsInfoManager:getRoomID()       if self._utilsInfo then return self._utilsInfo.nRoomID          end end
function BaseGameUtilsInfoManager:getRoomTokenID()  if self._utilsInfo then return self._utilsInfo.nRoomTokenID     end end
function BaseGameUtilsInfoManager:getRoomInfo()     if self._utilsInfo then return self._utilsInfo.nRoomInfo        end end

function BaseGameUtilsInfoManager:getRoomConfigs()
    return self._utilsInfo.nRoomInfo.dwConfigs
end

function BaseGameUtilsInfoManager:getRoomOptions()
    return self._utilsInfo.nRoomInfo.dwOptions
end

function BaseGameUtilsInfoManager:getAreaID()
    return self._utilsInfo.nRoomInfo.nAreaID
end

function BaseGameUtilsInfoManager:getRoomMinDeposit()
    return self._utilsInfo.nRoomInfo.nMinDeposit
end

function BaseGameUtilsInfoManager:getRoomMaxDeposit()
    return self._utilsInfo.nRoomInfo.nMaxDeposit
end

return BaseGameUtilsInfoManager
