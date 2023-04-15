local RoomConfigData = class("RoomConfigData")

-- "<var>" = {
--     "dwActivityClothings" = 0
--     "dwConfigs"           = 2240
--     "dwGameOptions"       = 0
--     "dwManages"           = 0
--     "dwOptions"           = 18689
--     "nAreaID"             = 507
--     "nBoyClothing"        = 0
--     "nChairCount"         = 4
--     "nExeMajorVer"        = 0
--     "nExeMinorVer"        = 0
--     "nFontColor"          = 0
--     "nGameDBID"           = 0
--     "nGameData"           = 0
--     "nGameID"             = 105
--     "nGameParam"          = 0
--     "nGamePort"           = 31405
--     "nGameVID"            = 1001050000
--     "nGifID"              = 0
--     "nGiftDeposit"        = 0
--     "nGiftScore"          = 0
--     "nGirlClothing"       = 1
--     "nHallBuildNO"        = 0
--     "nIconID"             = 0
--     "nInactiveSecond"     = 30
--     "nLayOrder"           = 20
--     "nMatchID"            = 0
--     "nMaxBoutSecond"      = 36000
--     "nMaxDeposit"         = 1000000000
--     "nMaxPlayScore"       = 2000000000
--     "nMaxSalarySecond"    = 3600
--     "nMaxScore"           = 2000000000
--     "nMaxUsers"           = 240
--     "nMinBoutSecond"      = 0
--     "nMinDeposit"         = 0
--     "nMinExperience"      = 0
--     "nMinLevel"           = 0
--     "nMinPlayScore"       = -2000000000
--     "nMinSalarySecond"    = 30
--     "nMinScore"           = -2000000000
--     "nPort"               = 0
--     "nReserved" = {
--         1 = 0
--         2 = 0
--         3 = 0
--         4 = 0
--         5 = 0
--         6 = 0
--         7 = 0
--     }
--     "nRoomID"             = 2156
--     "nRoomType"           = 1
--     "nStatus"             = 0
--     "nSubType"            = 0
--     "nTableCount"         = 60
--     "nTableID"            = 100
--     "nTableIDPlay"        = 100
--     "nTableStyle"         = 4
--     "nUnitSalary"         = 1
--     "nUsers"              = 5
--     "nUsersOnline"        = 0
--     "szExeName"           = "snda"
--     "szGameIP"            = "192.168.8.33"
--     "szPassword"          = ""
--     "szRoomName"          = "GBK编码"
--     "szWWW"               = ""
-- }

function RoomConfigData:create(roomDataManager)
    self._delegate = roomDataManager
    self._configInfo = {}
end

function RoomConfigData:setData(config)
    self._configInfo = config
end

function RoomConfigData:clearData()
    self._configInfo = {}
end

-- 获取总桌子数
function RoomConfigData:getMaxTableCount()
    return self._configInfo.nTableCount
end

-- 获取椅子数配置
function RoomConfigData:getChairCount()
    return self._configInfo.nChairCount
end

return RoomConfigData