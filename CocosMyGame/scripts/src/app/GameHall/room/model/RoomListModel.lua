local RoomListModel = class("RoomListModel")
local MyTimeStamp = import('src.app.mycommon.mytimestamp.MyTimeStamp'):getInstance()
local AdditionConfigModel = import('src.app.GameHall.config.AdditionConfigModel'):getInstance()

RoomListModel.dwConfigs = {
    ROOM_CFG_RANDOM = 0x00000002,
    ROOM_CFG_PRIVATEROOM = 0x00010000,
    ROOM_CFG_TEAMROOM = 0x00010002,
    ROOM_CFG_ROOMCARD = 0x40000000,
    ROOM_CFG_ARENAROOM = 0x10000000,
}

-- 移动端选桌：begin
RoomListModel.dwManages = {
    ROOM_MNG_SELECTTABLE    = 0x00000800,   --房间Manages配置项：支持选桌
}
-- 移动端选桌：end

RoomListModel.dwOptions = {
    ROOM_OPTION_DEPOSITROOM = 0x00000004,
}

RoomListModel.filterAreaInfos = {
    ["newuser"] = {
        ["areaId"] = 15634,
        ["areaId_wwnc"] = 15524,
        ["areaId_debug"] = 4016, --ceshi
        -- ["areaId_debug"] = 4016, --wcf
        -- ["areaId_debug"] = 4018, --zhulc
    },
    ["normal"] = {
        ["areaId"] = 594,
        ["areaId_wwnc"] = 201,
        ["areaId_debug"] = 635, --ceshi
        -- ["areaId_debug"] = 3874, --wcf
        -- ["areaId_debug"] = 3963, --zhulc
    },
    ["noshuffle"] = {
        ["areaId"] = 6123,
        ["areaId_wwnc"] = 7298,
        ["areaId_debug"] = 2639, --ceshi
        -- ["areaId_debug"] = 3876, --wcf
        -- ["areaId_debug"] = 3877, --zhulc
    },
    ["jisu"] = {
        ["areaId"] = 10894,
        ["areaId_wwnc"] = 10791,
        ["areaId_debug"] = 3898, --ceshi
        -- ["areaId_debug"] = 3900, --wcf
        -- ["areaId_debug"] = 3899, --zhulc
    },
    ["timing"] = {
        ["areaId"] = 12034,
        ["areaId_wwnc"] = 12033,
        ["areaId_debug"] = 3941, --ceshi
        -- ["areaId_debug"] = 3942, --wcf
        -- ["areaId_debug"] = 3943, --zhulc
    },
    ["anchorMatch"] = {
        ["areaId"] = 16162,
        ["areaId_wwnc"] = 16032,
        ["areaId_debug"] = 4025, --ceshi
        -- ["areaId_debug"] = 4021, --wcf
        -- ["areaId_debug"] = 4024, --zhulc
    },
    ["team2V2"] = {
        ["areaId"] = 17365,
        ["areaId_wwnc"] = 17235,
        ["areaId_debug"] = 4031, --ceshi
        -- ["areaId_debug"] = 4028, --wcf
        -- ["areaId_debug"] = 3875, --zhulc
    },
}

RoomListModel.roomGradeConfig = {
    [1] = {
		["name"] = "newcomer",
		["nameZh"] = "新手",
        ["baseDepositDefault"] = 250,
	},
	[2] = {
		["name"] = "junior",
		["nameZh"] = "初级",
        ["baseDepositDefault"] = 600,
	},
	[3] = {
		["name"] = "middle",
		["nameZh"] = "中级",
        ["baseDepositDefault"] = 1500,
	},
    [4] = {
		["name"] = "quanmin",
		["nameZh"] = "全民",
        ["baseDepositDefault"] = 1500,
	},
	[5] = {
		["name"] = "senior",
		["nameZh"] = "高级",
        ["baseDepositDefault"] = 1800,
	},
	[6] = {
		["name"] = "master",
		["nameZh"] = "大师",
        ["baseDepositDefault"] = 6000,
	},
	[7] = {
		["name"] = "supermaster",
		["nameZh"] = "至尊",
        ["baseDepositDefault"] = 10000,
    },
	[8] = {
		["name"] = "zongshi",
		["nameZh"] = "宗师",
        ["baseDepositDefault"] = 50000,
	}
}
--gradeName到gradeIndex的反向映射
RoomListModel.roomGradeNameToIndex = {
    ["newcomer"] = 1, ["junior"] = 2, ["middle"] = 3, ["quanmin"] = 4, ["senior"] = 5,
    ["master"] = 6, ["supermaster"] = 7, ["zongshi"] = 8
}

--当前房间最大等级
RoomListModel.MAX_ROOMGRADE_INDEX = 8

RoomListModel.OFFLINE_ROOMINFO = {
    ["nRoomID"] = 999998,
    ["nAreaID"] = 999999,
    ["szRoomName"] = "单机场",
    ["dwOptions"] = 0,
    ["isOfflineRoom"] = true
}

RoomListModel.EVENT_MAP = {
    ["roomListModel_roomPlayerNumUpdated"] = "roomListModel_roomPlayerNumUpdated",
    ["roomListModel_allRoomsInfoGot"] = "roomListModel_allRoomsInfoGot",
}

function RoomListModel:ctor()
    cc.load('event'):create():bind(self)

    --self._roomCtrl  = roomCtrl
    self.areasInfo = {} --以areaId为key的map
    self.roomsInfo = {} --以roomId为key的map
    self.roomsInfoListClassic = {}
    self.roomsInfoListNoShuffle = {}
    self.roomsInfoListJiSu = {}
    self.roomsInfoListTiming = {}
    self.roomsInfoListAnchor = {}
    self.roomsInfoListTeam2V2 = {}
    self.roomsInfoListNormal = {} --noshuffle + classic + jisu
    self.roomsInfoListTeam = {}
    self.roomsInfoListArena = {}
    self.scoreRoomInfo = nil --积分场房间
    self.guideRoomInfo = nil --新手引导房

    --gradeRoomsXXX存储的是房间id
    self.gradeRoomsClassic = {[1] = {}, [2] = {}, [3] = {}, [4] = {}, [5] = {}, [6] = {}, [7] = {}, [8] = {}}           --经典场各等级房间
    self.gradeRoomsNoShuffle = {[1] = {}, [2] = {}, [3] = {}, [4] = {}, [5] = {}, [6] = {}, [7] = {}, [8] = {}}         --不洗牌各等级房间
    self.gradeRoomsJiSu = {[1] = {}, [2] = {}, [3] = {}, [4] = {}, [5] = {}, [6] = {}, [7] = {}, [8] = {}}              --极速掼蛋各等级房间
    self.gradeRoomsTiming = {[1] = {}, [2] = {}, [3] = {}, [4] = {}, [5] = {}, [6] = {}, [7] = {}, [8] = {}}            --定时赛各等级房间
    self.gradeRoomsTeam = {[1] = {}, [2] = {}, [3] = {}, [4] = {}, [5] = {}, [6] = {}, [7] = {}, [8] = {}}              --好友组队各等级房间
    self.gradeRoomsArena = {[1] = {}, [2] = {}, [3] = {}, [4] = {}, [5] = {}, [6] = {}, [7] = {}, [8] = {}}             --优先使用不洗牌区的竞技场房间
    self.gradeRoomsAnchorMatch = {[1] = {}, [2] = {}, [3] = {}, [4] = {}, [5] = {}, [6] = {}, [7] = {}, [8] = {}}       --主播娱乐场各等级房间
    self.gradeRoomsTeam2V2 = {[1] = {}, [2] = {}, [3] = {}, [4] = {}, [5] = {}, [6] = {}, [7] = {}, [8] = {}}           --组队2V2场各等级房间

    --自定义配置（比如从AssistSvr获取的配置等）
    self.roomConfigCustom = {
        --[-1] = {["baseDeposit"] = -1}
    }

    self._client    = mc.createClient()
    self._hslUtils  = HslUtils:create(my.getAbbrName())
    self._scheduler = cc.Director:getInstance():getScheduler()
    self._syncsender = cc.load('asynsender').SyncSender

    self:_initRoomConfigCustom()
end

function RoomListModel:getInstance()
    RoomListModel._instance = RoomListModel._instance or RoomListModel:create()
    return RoomListModel._instance
end

function RoomListModel:_initRoomConfigCustom()
    local dataMap = my.readCache("roomconfigcustom.xml")
    if dataMap then
        for roomId, configData in pairs(dataMap) do
            roomId = tonumber(roomId)
            self.roomConfigCustom[roomId] = configData
        end
    end
end

function RoomListModel:autoUpdateRoomList()
    if self._roomInfoTimer and self._roomInfoTimer > socket.gettime() -3600 then
        return
    end

    self._roomInfoTimer = socket.gettime()
    self:getAllRoomInfo(false, nil)
end

function RoomListModel:getAllRoomInfo(isHiddenRoomsWanted, callback)
    print("RoomListModel:getAllRoomInfo")

    self._isHiddenRoomsWanted = isHiddenRoomsWanted
    local function onAreaInfoGot(respondType, data, msgType, dataMap_area)
        print("onAreaInfoGot")
        self:_collectAreaInfo(dataMap_area)

        if dataMap_area[1].nCount == 0 then callback(self.areasInfo, self.roomsInfo) return end

        local nGetRoomlistNum = 0
        for count, area in pairs(dataMap_area[2]) do
            local function onRoomInfoGot(respondType, data, msgType, dataMap)
                self:_collectRoomsInfo(area.nAreaID, dataMap)
                nGetRoomlistNum = nGetRoomlistNum + 1
                --if count == #dataMap_area[2] then
                if nGetRoomlistNum == #dataMap_area[2] then
                    if callback then callback(self.areasInfo, self.roomsInfo) end

                    --房间信息获取完成
                    print("allRoomsInfoGot")
                    self:_dealOnAllRoomsInfoGot()
                    self:dispatchEvent({name = RoomListModel.EVENT_MAP["roomListModel_allRoomsInfoGot"]})
                    self:startPlayerNumUpdateScheduler()
                end
            end
            self:_getRooms(area.nAreaID, isHiddenRoomsWanted, onRoomInfoGot)
        end
    end
    self:_getAreas(isHiddenRoomsWanted, onAreaInfoGot)
end

function RoomListModel:_dealOnAllRoomsInfoGot()
    --计算gradeRoomsXXX
    for roomId, roomInfo in pairs(self.roomsInfo) do
        if roomInfo["isScoreRoom"] == true and roomInfo["nIconID"] == 0 then
			self.scoreRoomInfo = roomInfo
		else
			local gradeIndex = roomInfo["gradeIndex"]
			if gradeIndex and gradeIndex > 0 then
                if roomInfo["isTeam2V2"] == true and 
                   (roomInfo["nAreaID"] == RoomListModel.filterAreaInfos["team2V2"]["areaId"] or 
                    roomInfo["nAreaID"] == RoomListModel.filterAreaInfos["team2V2"]["areaId_wwnc"] or 
                    roomInfo["nAreaID"] == RoomListModel.filterAreaInfos["team2V2"]["areaId_debug"] )then
                        
                    local roomID = roomInfo["nRoomID"]
                    local team2V2RoomInfo = cc.exports.getTeam2V2RoomInfo(roomInfo["nRoomID"])
                    if team2V2RoomInfo then
                        table.merge(roomInfo, team2V2RoomInfo)
                        roomInfo.nMinDeposit = team2V2RoomInfo.nEnterMin
                        roomInfo.nMaxDeposit = team2V2RoomInfo.nEnterMax
                    end
					table.insert(self.gradeRoomsTeam2V2[gradeIndex], roomInfo["nRoomID"])
				end
                if roomInfo["isTeamRoom"] == true and
                    not (roomInfo["nAreaID"] == RoomListModel.filterAreaInfos["team2V2"]["areaId"] or 
                    roomInfo["nAreaID"] == RoomListModel.filterAreaInfos["team2V2"]["areaId_wwnc"] or 
                    roomInfo["nAreaID"] == RoomListModel.filterAreaInfos["team2V2"]["areaId_debug"] )then
					table.insert(self.gradeRoomsTeam[gradeIndex], roomInfo["nRoomID"])
				end
				if roomInfo["isArenaRoom"] == true then
					table.insert(self.gradeRoomsArena[gradeIndex], roomInfo["nRoomID"])
				end

                if roomInfo["isGuideRoom"] == true then
                    self.guideRoomInfo = roomInfo
                elseif roomInfo["isNoShuffleRoom"] == true then
                    table.insert(self.gradeRoomsNoShuffle[gradeIndex], roomInfo["nRoomID"])
                elseif roomInfo["isJiSuRoom"] == true then
                    table.insert(self.gradeRoomsJiSu[gradeIndex], roomInfo["nRoomID"])
                elseif roomInfo["isTimingRoom"] == true then
                    table.insert(self.gradeRoomsTiming[gradeIndex], roomInfo["nRoomID"])
                elseif roomInfo["isAnchorMatch"] == true then
                    table.insert(self.gradeRoomsAnchorMatch[gradeIndex], roomInfo["nRoomID"])
				elseif not roomInfo['isTeam2V2'] then
					table.insert(self.gradeRoomsClassic[gradeIndex], roomInfo["nRoomID"])
				end
			end
		end

    end


    local compareFunc = function(a, b)
        if a.nMinDeposit ~= b.nMinDeposit then
            return a.nMinDeposit > b.nMinDeposit
        end
        return a.nLayOrder > b.nLayOrder
    end

    self.roomsInfoListClassic = self:gradeRoomsToList(self.gradeRoomsClassic)
    self.roomsInfoListNoShuffle = self:gradeRoomsToList(self.gradeRoomsNoShuffle)
    self.roomsInfoListJiSu = self:gradeRoomsToList(self.gradeRoomsJiSu)
    self.roomsInfoListTiming = self:gradeRoomsToList(self.gradeRoomsTiming)
    self.roomsInfoListAnchor = self:gradeRoomsToList(self.gradeRoomsAnchorMatch)
    self.roomsInfoListTeam2V2 = self:gradeRoomsToList(self.gradeRoomsTeam2V2)
    self.roomsInfoListTeam = self:gradeRoomsToList(self.gradeRoomsTeam)
    self.roomsInfoListArena = self:gradeRoomsToList(self.gradeRoomsArena)
    for i = 1, #self.roomsInfoListNoShuffle do
        table.insert(self.roomsInfoListNormal, self.roomsInfoListNoShuffle[i])
    end
    --for i = 1, #self.roomsInfoListJiSu do
    --    table.insert(self.roomsInfoListNormal, self.roomsInfoListJiSu[i])
    --end
    for i = 1, #self.roomsInfoListClassic do
        table.insert(self.roomsInfoListNormal, self.roomsInfoListClassic[i])
    end

    --注意这是从大到小排序
    table.sort(self.roomsInfoListNormal, compareFunc)
    table.sort(self.roomsInfoListClassic, compareFunc)
    table.sort(self.roomsInfoListNoShuffle, compareFunc)
    table.sort(self.roomsInfoListJiSu, compareFunc)
    table.sort(self.roomsInfoListTiming, compareFunc)
    table.sort(self.roomsInfoListTeam, compareFunc)
    table.sort(self.roomsInfoListArena, compareFunc)
    table.sort(self.roomsInfoListAnchor, compareFunc)
    table.sort(self.roomsInfoListTeam2V2, compareFunc)
end

--获得的list是从小到大排序
function RoomListModel:gradeRoomsToList(gradeRooms)
    if gradeRooms == nil then return {} end

    local roomsInfoList = {}
    for i = 1, #gradeRooms do
        for j=1, #gradeRooms[i] do
            if j == 1 or (j == 2 and gradeRooms[i][j] ~= gradeRooms[i][1]) then
                local roomInfo = self.roomsInfo[gradeRooms[i][j]]
                if roomInfo then
                    table.insert(roomsInfoList, roomInfo)
                end
            end
        end
    end

    return roomsInfoList
end

--获取某个等级的房间列表信息中的第一个
function RoomListModel:getRoomInfoByGradeName(gradeName, gradeRooms)
    if gradeName == nil or gradeRooms == nil then return end

    local gradeIndex = RoomListModel.roomGradeNameToIndex[gradeName]
    if gradeIndex == nil or gradeIndex < 1 or gradeIndex > RoomListModel.MAX_ROOMGRADE_INDEX then
        return nil
    end

    local roomIds = gradeRooms[gradeIndex]
    if roomIds and roomIds[1] then
        return self.roomsInfo[roomIds[1]]
    end

    return nil
end

--获取主播房信息
function RoomListModel:getAnchorRoomInfo()
    if self.roomsInfoListAnchor and type(self.roomsInfoListAnchor) == "table" and #self.roomsInfoListAnchor > 0 then
        return self.roomsInfoListAnchor[1]
    end
    return nil
end

--获取组队2V2房信息
function RoomListModel:getTeam2V2RoomInfo()
    if self.roomsInfoListTeam2V2 and type(self.roomsInfoListTeam2V2) == "table" and #self.roomsInfoListTeam2V2 > 0 then
        return self.roomsInfoListTeam2V2[1]
    end
    return nil
end

function RoomListModel:getConfigedRechargeData(roomId)
    if type(roomId) ~= 'number' then
        return nil
    end
    local one = (self.roomsInfo or {})[roomId]
    if type(one) ~= 'table' then
        print("[ERROR] No information of room:", roomId)
        return nil
    end
    local shopExchangeId = nil
    local gradeIndex = one["gradeIndex"] -- see roomGradeConfig
    if one["isClassicRoom"] == true then
        if gradeIndex == 2 then -- 初级
            shopExchangeId = cc.exports.getRoomQuickRechargeExchangeId('deposit', 'junior')
        elseif gradeIndex == 3 then
            shopExchangeId = cc.exports.getRoomQuickRechargeExchangeId('deposit', 'middle')
        elseif gradeIndex == 4 then
            shopExchangeId = cc.exports.getRoomQuickRechargeExchangeId('deposit', 'senior')
        elseif gradeIndex == 5 then
            shopExchangeId = cc.exports.getRoomQuickRechargeExchangeId('deposit', 'master')
        elseif gradeIndex == 6 then -- 至尊
            shopExchangeId = cc.exports.getRoomQuickRechargeExchangeId('deposit', 'supermaster')
        elseif gradeIndex == 8 then -- 至尊
            shopExchangeId = cc.exports.getRoomQuickRechargeExchangeId('deposit', 'zongshi')
        end
    elseif one["isNoShuffleRoom"] == true then
        if gradeIndex == 2 then -- 初级
            shopExchangeId = cc.exports.getRoomQuickRechargeExchangeId('noshuffle', 'junior')
        elseif gradeIndex == 3 then
            shopExchangeId = cc.exports.getRoomQuickRechargeExchangeId('noshuffle', 'middle')
        elseif gradeIndex == 4 then
            shopExchangeId = cc.exports.getRoomQuickRechargeExchangeId('noshuffle', 'senior')
        elseif gradeIndex == 5 then
            shopExchangeId = cc.exports.getRoomQuickRechargeExchangeId('noshuffle', 'master')
        elseif gradeIndex == 6 then -- 至尊
            shopExchangeId = cc.exports.getRoomQuickRechargeExchangeId('noshuffle', 'supermaster')
        elseif gradeIndex == 8 then -- 至尊
            shopExchangeId = cc.exports.getRoomQuickRechargeExchangeId('deposit', 'zongshi')
        end
    elseif one["isJiSuRoom"] == true then
        if gradeIndex == 2 then -- 初级
            shopExchangeId = cc.exports.getRoomQuickRechargeExchangeId('jisu', 'junior')
        elseif gradeIndex == 7 then -- 全民
            shopExchangeId = cc.exports.getRoomQuickRechargeExchangeId('jisu', 'quanming')
        elseif gradeIndex == 4 then
            shopExchangeId = cc.exports.getRoomQuickRechargeExchangeId('jisu', 'senior')
        elseif gradeIndex == 5 then
            shopExchangeId = cc.exports.getRoomQuickRechargeExchangeId('jisu', 'master')
        elseif gradeIndex == 6 then
            shopExchangeId = cc.exports.getRoomQuickRechargeExchangeId('jisu', 'supermaster')
        elseif gradeIndex == 8 then -- 至尊
            shopExchangeId = cc.exports.getRoomQuickRechargeExchangeId('deposit', 'zongshi')
        end
    end
    return shopExchangeId
end

function RoomListModel:_collectAreaInfo(areasInfo)
    if type(areasInfo[2]) ~= 'table' then return end
    for _, area in pairs(areasInfo[2]) do
        self.areasInfo[area.nAreaID] = area
        self.areasInfo[area.nAreaID].roomList = {}
    end

    --self:_filterArea(areasInfo, GamePublicInterface:GetFilterAreaID())
    self:_filterArea(areasInfo)
end

function RoomListModel:_collectRoomsInfo(areaID, roomsInfo)
    if roomsInfo and self.areasInfo[areaID] then
        self.areasInfo[areaID].nCount = roomsInfo[1].nRoomCount
        for _, room in pairs(roomsInfo[2]) do
            table.insert(self.areasInfo[areaID].roomList, room.nRoomID)
            local roomNameRaw = MCCharset:getInstance():gb2Utf8String(room.szRoomName, room.szRoomName:len())
            room["szRoomName"] = roomNameRaw
            self:_setRoomPlayingModeInfo(self.areasInfo[areaID], room)
            self:_calcRoomGradeInfo(room)

            --在线人数的默认值，需要继承上一次的数据
            local roomInfoOld = self.roomsInfo[room.nRoomID]
            if roomInfoOld and roomInfoOld["nUsers"] then
                room["nUsers"] = roomInfoOld["nUsers"]
            end

            self.roomsInfo[room.nRoomID] = room
        end
    end
end

function RoomListModel:_calcRoomGradeInfo(roomInfo)
    for i = 1, #RoomListModel.roomGradeConfig do
        if string.find(roomInfo["szRoomName"], RoomListModel.roomGradeConfig[i]["nameZh"]) ~= nil then
            roomInfo["gradeIndex"] = i
            roomInfo["gradeName"] = RoomListModel.roomGradeConfig[i]["name"]
            roomInfo["gradeNameZh"] = RoomListModel.roomGradeConfig[i]["nameZh"].."房"
            break
        end
    end
end

function RoomListModel:_setRoomPlayingModeInfo(areaInfo, roomInfo)
    roomInfo["isDepositRoom"] = false --银子场房间
    roomInfo["isScoreRoom"] = false --积分场房间

    roomInfo["isClassicRoom"] = false --经典场房间
    roomInfo["isNoShuffleRoom"] = false --不洗牌房间
    roomInfo["isJiSuRoom"] = false
    roomInfo["isTimingRoom"] = false

    roomInfo["isAnchorMatch"] = false

    roomInfo["isTeamRoom"] = false --好友组对房
    roomInfo["isArenaRoom"] = false --竞技场房间

    roomInfo['isGuideRoom'] = false -- 新手引导房

    if bit.band(roomInfo.dwOptions, RoomListModel.dwOptions.ROOM_OPTION_DEPOSITROOM) == RoomListModel.dwOptions.ROOM_OPTION_DEPOSITROOM then
        roomInfo["isDepositRoom"] = true
        roomInfo["isScoreRoom"] = false
    else
        roomInfo["isDepositRoom"] = false
        roomInfo["isScoreRoom"] = true
    end

    if areaInfo["areaEntry"] == "newuser" then
        roomInfo['isGuideRoom'] = true
        roomInfo["isClassicRoom"] = false
        roomInfo["isNoShuffleRoom"] = false
        roomInfo["isJiSuRoom"] = false
    elseif areaInfo["areaEntry"] == "noshuffle" then
        roomInfo["isClassicRoom"] = false
        roomInfo["isNoShuffleRoom"] = true
        roomInfo["isJiSuRoom"] = false
        roomInfo["isTeam2V2"] = false
    elseif areaInfo["areaEntry"] == "jisu" then
        roomInfo["isClassicRoom"] = false
        roomInfo["isNoShuffleRoom"] = false
        roomInfo["isJiSuRoom"] = true
        roomInfo["isTeam2V2"] = false
    elseif areaInfo["areaEntry"] == "timing" then
        roomInfo["isClassicRoom"] = false
        roomInfo["isNoShuffleRoom"] = false
        roomInfo["isTimingRoom"] = true
        roomInfo["isTeam2V2"] = false
    elseif areaInfo["areaEntry"] == "anchorMatch" then
        roomInfo["isClassicRoom"] = false
        roomInfo["isNoShuffleRoom"] = false
        roomInfo["isAnchorMatch"] = true
        roomInfo["isTeam2V2"] = false
    elseif areaInfo["areaEntry"] == "team2V2" then
        roomInfo["isClassicRoom"] = false
        roomInfo["isNoShuffleRoom"] = false
        roomInfo["isAnchorMatch"] = false
        roomInfo["isTeam2V2"] = true
    else
        roomInfo["isClassicRoom"] = true
        roomInfo["isNoShuffleRoom"] = false
        roomInfo["isJiSuRoom"] = false
        roomInfo["isTeam2V2"] = false
    end

    if bit.band(roomInfo.dwConfigs, RoomListModel.dwConfigs.ROOM_CFG_TEAMROOM) == RoomListModel.dwConfigs.ROOM_CFG_TEAMROOM then
        if not roomInfo['isTeam2V2'] then
            roomInfo["isTeamRoom"] = true
        end
    end

    if bit.band(roomInfo.dwConfigs, RoomListModel.dwConfigs.ROOM_CFG_ARENAROOM) == RoomListModel.dwConfigs.ROOM_CFG_ARENAROOM
    and roomInfo["isTimingRoom"] == false and roomInfo["isAnchorMatch"] == false then
        roomInfo["isArenaRoom"] = true
    end

    --旧逻辑
    --区分房间类型  1是普通，2随机级牌，3是连局，4是热门，9是4人对战 8既是热门也是4人对战 begin
    local roomType = roomInfo["nLayOrder"]
    roomType = math.abs(roomType)
    if roomType >= 10 then
        roomType = roomType / 10
        local intData, decimalData =  math.modf(roomType)
        roomType = decimalData * 10
    end
    roomType = math.floor(roomType + 0.5)
    roomInfo["type"] = roomType
    --区分房间类型  1是普通，2随机级牌，3是连局，4是热门，9是4人对战 8既是热门也是4人对战 end
end

function RoomListModel:_getAreas(isHiddenRoomsWanted, callback)
    local extraParams = {
        dwGetFlags = 0x800
    }
    if isHiddenRoomsWanted == true then
        extraParams.dwGetFlags = 0x801
    end
    local client = mc.createClient()
    client:setCallback(callback)
    client:sendRequest(mc.GET_AREAS, extraParams, nil, true)
end

function RoomListModel:_getAreas_co(isHiddenRoomsWanted)
    local extraParams = {
        dwGetFlags = 0x800
    }
    if isHiddenRoomsWanted == true then
        extraParams.dwGetFlags = 0x801
    end
    local respondType,data,msgType,dataMap = self._syncsender.send(mc.GET_AREAS, extraParams)
    return dataMap
end

function RoomListModel:_getRooms(areaID, isHiddenRoomsWanted, callback)
    local extraParams = {
        dwGetFlags  = 0x800,
        nAreaID     = areaID
    }
    if isHiddenRoomsWanted == true then
        extraParams.dwGetFlags = 0x801
    end
    local client = mc.createClient()
    client:setCallback(callback)
    client:sendRequest(mc.GET_ROOMS, extraParams, nil, true)
end

function RoomListModel:_getRooms_co(areaID, isHiddenRoomsWanted)
    local extraParams = {
        dwGetFlags  = 0x800,
        nAreaID     = areaID
    }
    if isHiddenRoomsWanted == true then
        extraParams.dwGetFlags = 0x801
    end
    local respondType,data,msgType,dataMap = self._syncsender.send(mc.GET_ROOMS, extraParams)
    return dataMap
end

--[[function RoomListModel:startPlayerNumUpdateScheduler(dt, callback)
    if self._playerNumUpdateScheduleHandler then
        return
    end
    self._updateNumCallback = function(respondType, data, msgType, dataMap)
        self:_mergePlayerNum(dataMap)
        callback(self.areasInfo, self.roomsInfo)
    end
    self:_updataRoomPlayerNum()
    self._playerNumUpdateScheduleHandler = self._scheduler:scheduleScriptFunc(handler(self,self._updataRoomPlayerNum), dt, false)
end]]--

function RoomListModel:startPlayerNumUpdateScheduler()
    if self._playerNumUpdateScheduleHandler then
        return
    end

    self:_updataRoomPlayerNum()
    self._playerNumUpdateScheduleHandler = self._scheduler:scheduleScriptFunc(handler(self,self._updataRoomPlayerNum), 120, false)
end

function RoomListModel:stopPlayerNumUpdateScheduler()
    if not self._playerNumUpdateScheduleHandler then
        return
    end
    self._scheduler:unscheduleScriptEntry(self._playerNumUpdateScheduleHandler)
    self._playerNumUpdateScheduleHandler = nil
end

function RoomListModel:_updataRoomPlayerNum()

    local roomIDs = table.keys(self.roomsInfo)

    local extraParams = {
        dwGetFlags      = 0x800;
        nRoomCount      = table.maxn(roomIDs);
        nRoomIDs        = roomIDs;
        nAgentGroupID   = HslUtils:getInstance().getHallSvrAgentGroup and HslUtils:getInstance():getHallSvrAgentGroup() or 6;
    }
    if self._isHiddenRoomsWanted == true then
        extraParams["dwGetFlags"] = 0x801
    end

    --[[if not self._updateNumCallback then return end
    self._client:registHandler(mc.GET_ROOMUSERS_OK, self._updateNumCallback, "hall")
    self._client:sendRequest(mc.GET_ROOMUSERS, extraParams, "hall", false)]]--


    self._client:registHandler(mc.GET_ROOMUSERS_OK, function(respondType, data, msgType, dataMap)
        self:_mergePlayerNum(dataMap)
        self:dispatchEvent({name = RoomListModel.EVENT_MAP["roomListModel_roomPlayerNumUpdated"]})
    end, "hall")
    self._client:sendRequest(mc.GET_ROOMUSERS, extraParams, "hall", false)
end

function RoomListModel:_mergePlayerNum(dataMap)
    for _, info in pairs(dataMap[2]) do
        self.roomsInfo[info.nItemID].nUsers = info.nUsers
        if cc.exports.isHideJuniorRoomSupported() and toint(info.nItemID) == toint(cc.exports.getMergeHideJuniorRoomID()) then
            for _, userInfo in pairs(dataMap[2]) do
                if toint(userInfo.nItemID) == toint(cc.exports.getHideJuniorRoomID()) then
                    self.roomsInfo[info.nItemID].nUsers = self.roomsInfo[info.nItemID].nUsers + userInfo.nUsers
                end
            end
        end
    end
    for areaID, area in pairs(self.areasInfo) do
        area.nUsers = 0
        for _, roomID in pairs(area.roomList) do
            if not self.roomsInfo[roomID].nUsers then return end
            area.nUsers = area.nUsers + self.roomsInfo[roomID].nUsers
        end
    end
end

--[[function RoomListModel:_filterArea(rawAreaInfo, ...)
    local filterAreaInfo = {}
    local targetAreaIDs = {...}
    if BusinessUtils:getInstance():isGameDebugMode() and #targetAreaIDs > 0 then
        for k, v in pairs(self.areasInfo) do
            if table.keyof(targetAreaIDs, k) then
                filterAreaInfo[k] = v
            end
        end
    end

    if next(filterAreaInfo) then
        self.areasInfo = filterAreaInfo
        rawAreaInfo[2] = table.values(filterAreaInfo)
    end
end]]--

function RoomListModel:_filterArea(rawAreaInfo)
    print("RoomListModel:_filterArea")
    for areaId, areaInfo in pairs(self.areasInfo) do
          print("areaId "..tostring(areaId)) --打印信息
    end
    dump(filterAreaInfo)

    local filterAreaInfo = {}
    for areaEntry, filter in pairs(RoomListModel.filterAreaInfos) do
        for areaId, areaInfo in pairs(self.areasInfo) do
            if areaId == filter["areaId"] or areaId == filter["areaId_wwnc"] or areaId == filter["areaId_debug"] then
                local areaName = MCCharset:getInstance():gb2Utf8String(areaInfo["szAreaName"], string.len(areaInfo["szAreaName"]))
                areaInfo["szAreaName"] = areaName
                areaInfo["areaEntry"] = areaEntry
                filterAreaInfo[areaId] = areaInfo
            end
        end
    end

    if next(filterAreaInfo) then
        self.areasInfo = filterAreaInfo
        rawAreaInfo[2] = table.values(filterAreaInfo)
    end
end

--检验不洗牌、竞技场、好友房进入限制（新手玩过一局后才可进入）
function RoomListModel:checkAreaEntryAvail(areaEntry)
    local UserModel = mymodel('UserModel'):getInstance()

    if areaEntry == 'noshuffle' then
        return true
    else
        local NewUserGuideModel = mymodel('NewUserGuideModel'):getInstance()
        if NewUserGuideModel:isNeedGuide() then
            return false
        end
    end

    return true
end

function RoomListModel:findFitRoomInGame()
    local HallContext = import('src.app.plugins.mainpanel.HallContext'):getInstance()
    local areaEntry = HallContext.context["roomContext"]["areaEntry"]
    local legalEtries = {["noshuffle"] = true, ["classic"] = true, ["jisu"] = true}
    if legalEtries[areaEntry] == nil then
        return nil, nil
    end

    local UserModel = mymodel('UserModel'):getInstance()
    return self:findFitRoomByDeposit(UserModel.nDeposit, areaEntry, UserModel.nSafeboxDeposit)
end

--findScope支持5种，"classic"、"noshuffle"、"jisu"、"arena"、"team"
function RoomListModel:findFitRoomByDeposit(userDeposit, findScope, userSafeBoxDeposit)
    print("RoomListModel:findFitRoomByDeposit")

    local NewUserGuideModel = mymodel('NewUserGuideModel'):getInstance()
    if NewUserGuideModel:isNeedGuide() then
        return self.guideRoomInfo
    end

    local targetRoomInfo = nil

    --未传入AreaEntry则自动确认
    if findScope == nil then
        local curAreaEntry = cc.exports.PUBLIC_INTERFACE.GetCurrentAreaEntry()
        findScope = curAreaEntry or "classic"
    end
    if self:checkAreaEntryAvail("noshuffle") == false then
        findScope = "classic"
    end

    if self:checkAreaEntryAvail("jisu") == false then
        findScope = "classic"
    end

    userDeposit = userDeposit or 0
    local roomListMap = {
        ["classic"] = self.roomsInfoListClassic,
        ["noshuffle"] = self.roomsInfoListNoShuffle,
        ["jisu"] = self.roomsInfoListJiSu,
        ["arena"] = self.roomsInfoListArena,
        ["team"] = self.roomsInfoListTeam,
        ["normal"] = self.roomsInfoListNormal
    }
    local roomList = roomListMap[findScope]
    if roomList == nil then
        print("findScope illegal, "..tostring(findScope))
        return nil, false
    end

    local minBeginDepositRoomInfo = nil
    local maxEndDepositRoomInfo = nil
    for i = 1, #roomList do
        local roomInfo = roomList[i]
        if minBeginDepositRoomInfo == nil or roomInfo["nMinDeposit"] < minBeginDepositRoomInfo["nMinDeposit"] then
            minBeginDepositRoomInfo = roomInfo
        end
        if maxEndDepositRoomInfo == nil or roomInfo["nMaxDeposit"] > maxEndDepositRoomInfo["nMaxDeposit"] then
            maxEndDepositRoomInfo = roomInfo
        end

        if not userSafeBoxDeposit or not cc.exports.isSafeBoxSupported() then
            userSafeBoxDeposit = 0
        end

        local NobilityPrivilegeModel = import("src.app.plugins.NobilityPrivilege.NobilityPrivilegeModel"):getInstance()
        local nplevelEnable = NobilityPrivilegeModel:isRoomEnableEnterByNPLevel(roomInfo["nRoomID"])
        if nplevelEnable and userDeposit >= roomInfo["nMinDeposit"] and userDeposit <= roomInfo["nMaxDeposit"] then
            local depositCoefficient = AdditionConfigModel:getRoomDepositParam(roomInfo.nRoomID)
            if (userDeposit + userSafeBoxDeposit) >= roomInfo["nMinDeposit"] * depositCoefficient then
                if targetRoomInfo == nil or roomInfo["nMinDeposit"] > targetRoomInfo["nMinDeposit"] then
                    if self:isLimitTimeOpenRoom(roomInfo.nRoomID) then
                        local curTimeStamp = MyTimeStamp:getLatestTimeStamp()
                        if curTimeStamp > 0 then
                            local startHour, startMinute, endHour, endMinute = self:getOpenTime(roomInfo.nRoomID)
                            local curYear = os.date("%Y", curTimeStamp)
                            local curMonth = os.date("%m", curTimeStamp)
                            local curDay = os.date("%d", curTimeStamp)
                            local startTimeStamp = os.time({year = curYear, month = curMonth, day = curDay, hour=startHour, min=startMinute, sec=0})
                            local endTimeStamp = os.time({year = curYear, month = curMonth, day = curDay, hour=endHour, min=endMinute, sec=0})
                            if startTimeStamp <= curTimeStamp and curTimeStamp <= endTimeStamp then
                                targetRoomInfo = roomInfo
                                break
                            end
                        end
                    else
                        targetRoomInfo = roomInfo
                        break
                    end
                end
            end
        end
    end

    local isNoFitRoom = false
    if targetRoomInfo == nil then
        isNoFitRoom = true
        if minBeginDepositRoomInfo and userDeposit < minBeginDepositRoomInfo["nMinDeposit"] then
            targetRoomInfo = minBeginDepositRoomInfo
        elseif maxEndDepositRoomInfo and userDeposit > maxEndDepositRoomInfo["nMaxDeposit"] then
            targetRoomInfo = maxEndDepositRoomInfo
        end
    end

    print("targetRoomInfo roomId "..tostring(targetRoomInfo and targetRoomInfo["nRoomID"] or "nil"))

    return targetRoomInfo, isNoFitRoom
end

-- Ex接口不考虑贵族等级
--findScope支持5种，"classic"、"noshuffle"、"jisu"、"arena"、"team"
function RoomListModel:findFitRoomByDepositEx(userDeposit, findScope, userSafeBoxDeposit)
    print("RoomListModel:findFitRoomByDeposit")
    local targetRoomInfo = nil

    --未传入AreaEntry则自动确认
    if findScope == nil then
        local curAreaEntry = cc.exports.PUBLIC_INTERFACE.GetCurrentAreaEntry()
        findScope = curAreaEntry or "classic"
    end
    if self:checkAreaEntryAvail("noshuffle") == false then
        findScope = "classic"
    end

    if self:checkAreaEntryAvail("jisu") == false then
        findScope = "classic"
    end

    userDeposit = userDeposit or 0
    local roomListMap = {
        ["classic"] = self.roomsInfoListClassic,
        ["noshuffle"] = self.roomsInfoListNoShuffle,
        ["jisu"] = self.roomsInfoListJiSu,
        ["arena"] = self.roomsInfoListArena,
        ["team"] = self.roomsInfoListTeam,
        ["normal"] = self.roomsInfoListNormal
    }
    local roomList = roomListMap[findScope]
    if roomList == nil then
        print("findScope illegal, "..tostring(findScope))
        return nil, false
    end

    local minBeginDepositRoomInfo = nil
    local maxEndDepositRoomInfo = nil
    for i = 1, #roomList do
        local roomInfo = roomList[i]
        if minBeginDepositRoomInfo == nil or roomInfo["nMinDeposit"] < minBeginDepositRoomInfo["nMinDeposit"] then
            minBeginDepositRoomInfo = roomInfo
        end
        if maxEndDepositRoomInfo == nil or roomInfo["nMaxDeposit"] > maxEndDepositRoomInfo["nMaxDeposit"] then
            maxEndDepositRoomInfo = roomInfo
        end

        if not userSafeBoxDeposit or not cc.exports.isSafeBoxSupported() then
            userSafeBoxDeposit = 0
        end

        if userDeposit >= roomInfo["nMinDeposit"] and userDeposit <= roomInfo["nMaxDeposit"] then
            local depositCoefficient = AdditionConfigModel:getRoomDepositParam(roomInfo.nRoomID)
            if (userDeposit + userSafeBoxDeposit) >= roomInfo["nMinDeposit"] * depositCoefficient then
                if targetRoomInfo == nil or roomInfo["nMinDeposit"] > targetRoomInfo["nMinDeposit"] then
                    if self:isLimitTimeOpenRoom(roomInfo.nRoomID) then
                        local curTimeStamp = MyTimeStamp:getLatestTimeStamp()
                        if curTimeStamp > 0 then
                            local startHour, startMinute, endHour, endMinute = self:getOpenTime(roomInfo.nRoomID)
                            local curYear = os.date("%Y", curTimeStamp)
                            local curMonth = os.date("%m", curTimeStamp)
                            local curDay = os.date("%d", curTimeStamp)
                            local startTimeStamp = os.time({year = curYear, month = curMonth, day = curDay, hour=startHour, min=startMinute, sec=0})
                            local endTimeStamp = os.time({year = curYear, month = curMonth, day = curDay, hour=endHour, min=endMinute, sec=0})
                            if startTimeStamp <= curTimeStamp and curTimeStamp <= endTimeStamp then
                                targetRoomInfo = roomInfo
                                break
                            end
                        end
                    else
                        targetRoomInfo = roomInfo
                        break
                    end
                end
            end
        end
    end

    local isNoFitRoom = false
    if targetRoomInfo == nil then
        isNoFitRoom = true
        if minBeginDepositRoomInfo and userDeposit < minBeginDepositRoomInfo["nMinDeposit"] then
            targetRoomInfo = minBeginDepositRoomInfo
        elseif maxEndDepositRoomInfo and userDeposit > maxEndDepositRoomInfo["nMaxDeposit"] then
            targetRoomInfo = maxEndDepositRoomInfo
        end
    end

    print("targetRoomInfo roomId "..tostring(targetRoomInfo and targetRoomInfo["nRoomID"] or "nil"))

    return targetRoomInfo, isNoFitRoom
end

function RoomListModel:_findJumpRoomByDeposit(userDeposit, findScope, curRoomInfo, findDirection)
    local targetRoomInfo = nil
    userDeposit = userDeposit or 0
    local roomListMap = {
        ["classic"] = self.roomsInfoListClassic,
        ["noshuffle"] = self.roomsInfoListNoShuffle,
        ["jisu"] = self.roomsInfoListJiSu
    }
    local roomList = roomListMap[findScope]
    if roomList == nil then
        print("findScope illegal, "..tostring(findScope))
        return
    end
    if curRoomInfo == nil then
        print("curRoomInfo is nil")
        return
    end
    if findDirection ~= "junior" and findDirection ~= "senior" then
        print("findDirection illegal, "..tostring(findDirection))
        return
    end

    for i = 1, #roomList do
        local roomInfo = roomList[i]
        local NobilityPrivilegeModel = import("src.app.plugins.NobilityPrivilege.NobilityPrivilegeModel"):getInstance()
        local nvlevelEnable = NobilityPrivilegeModel:isRoomEnableEnterByNPLevel(roomInfo["nRoomID"])
        if nvlevelEnable and userDeposit >= roomInfo["nMinDeposit"] and userDeposit <= roomInfo["nMaxDeposit"] then
            if findDirection == "junior" then
                if roomInfo["nMinDeposit"] < curRoomInfo["nMinDeposit"] then
                    if targetRoomInfo == nil or roomInfo["nMinDeposit"] < targetRoomInfo["nMinDeposit"] then
                        targetRoomInfo = roomInfo
                    end
                end
            elseif findDirection == "senior" then
                if roomInfo["nMinDeposit"] > curRoomInfo["nMinDeposit"] then
                    if targetRoomInfo == nil or roomInfo["nMinDeposit"] > targetRoomInfo["nMinDeposit"] then
                        targetRoomInfo = roomInfo
                    end
                end
            end
        end
    end

    return targetRoomInfo
end

function RoomListModel:findJuniorRoomByDeposit(userDeposit, findScope, curRoomInfo)
    print("RoomListModel:findJuniorRoomByDeposit")
    return self:_findJumpRoomByDeposit(userDeposit, findScope, curRoomInfo, "junior")
end

function RoomListModel:findSeniorRoomByDeposit(userDeposit, findScope, curRoomInfo)
    print("RoomListModel:findSeniorRoomByDeposit")
    return self:_findJumpRoomByDeposit(userDeposit, findScope, curRoomInfo, "senior")
end

function RoomListModel:findSeniorRoomInGame(curRoomInfo)
    local HallContext = import('src.app.plugins.mainpanel.HallContext'):getInstance()
    local areaEntry = HallContext.context["roomContext"]["areaEntry"]
    local legalEtries = {["noshuffle"] = true, ["classic"] = true, ["jisu"] = true}
    if legalEtries[areaEntry] == nil then
        return nil, nil
    end

    local UserModel = mymodel('UserModel'):getInstance()
    return self:findSeniorRoomByDeposit(UserModel.nDeposit, areaEntry, curRoomInfo)
end

--合并配置项
function RoomListModel:updateAndSaveRoomConfigCustom(dataMap)
    if dataMap == nil or dataMap["roomBaseDeposit"] == nil then return end

    local roomBaseDeposit = dataMap["roomBaseDeposit"]
    for strRoomId, baseDeposit in pairs(roomBaseDeposit) do
        local roomId = tonumber(strRoomId)
        if roomId ~= nil then
            if self.roomConfigCustom[roomId] == nil then
                self.roomConfigCustom[roomId] = {}
            end

            self.roomConfigCustom[roomId]["baseDeposit"] = baseDeposit
        end
    end

    self:saveRoomConfigCustom()
end

function RoomListModel:saveRoomConfigCustom()
    local dataMap = {}

    local saveDataKeys = {"baseDeposit"}
    for roomId, configData in pairs(self.roomConfigCustom) do
        local strRoomId = tostring(roomId) --缓存的key必须是string类型
        dataMap[strRoomId] = {}

        for _, key in pairs(saveDataKeys) do
            dataMap[strRoomId][key] = self.roomConfigCustom[roomId][key]
        end
    end
    my.saveCache("roomconfigcustom.xml", dataMap)
end

--未进入游戏前，获得房间基础银
function RoomListModel:getRoomBaseDeposit(roomId)
    if roomId == nil then return 0 end

    if self.roomConfigCustom[roomId] then
        if self.roomConfigCustom[roomId]["baseDeposit"] then
            return self.roomConfigCustom[roomId]["baseDeposit"]
        end
    end

    if self.roomsInfo[roomId] then
        local gradeIndex = self.roomsInfo[roomId]["gradeIndex"]
        return RoomListModel.roomGradeConfig[gradeIndex]["baseDepositDefault"]
    end

    return 0
end

-- [jfcrh] 积分场弱化，获取积分场按钮状态
function RoomListModel:onGetScoreRoomBtnStatus()
    local status = false
    local user=mymodel('UserModel'):getInstance()
    if not user.nSafeboxDeposit or not user.nDeposit then
        return false
    end
    local nDeposit = user.nSafeboxDeposit + user.nDeposit
    local relief = mymodel('hallext.ReliefActivity'):getInstance()
    local loginLottery = require("src.app.plugins.loginlottery.LoginLotteryModel"):getInstance()
    local loginRewardMoney = 0
    local loginLotteryCount = 0
    if loginLottery then
        loginRewardMoney = loginLottery:getAvailableRewardMoney()
        loginLotteryCount = loginLottery:getLotteryCount()
    end

    if next(cc.exports._gameJsonConfig) and cc.exports._gameJsonConfig.ScoreRoomOpenLimit and cc.exports._gameJsonConfig.ScoreRoomOpenLimit.open == 1 then
        --低保、每日抽奖、连续登陆，都领完才算彻底破产，同时携银<2000
        local silver = 2000
        if cc.exports._gameJsonConfig.ScoreRoomOpenLimit.silver then
            silver = cc.exports._gameJsonConfig.ScoreRoomOpenLimit.silver
        end
        if relief.state == relief.USED_UP and nDeposit < silver and loginRewardMoney <= 0 and loginLotteryCount <= 0 then
            status = true
        else
            status = false
        end
    else
        status = true
    end
    return status
end

--房间是否开启了礼券奖励
function RoomListModel:isRoomExchangeAvail(roomId)
    roomId = tostring(roomId) --注意需要转为string
    if cc.exports._gameJsonConfig and cc.exports._gameJsonConfig.ExchangeRoomConfig then
        local gameConfig = cc.exports._gameJsonConfig
        local rewardConfig = cc.exports._gameJsonConfig.ExchangeRoomConfig[roomId]
        if rewardConfig and rewardConfig["RewardNum"] > 0 then
            return true
        end
    end
    return false
end

--房间是否开启了双倍礼券奖励
function RoomListModel:isRoomDoubleExchangeAvail(roomId)
    if self:isRoomExchangeAvail(roomId) == false then
        return false
    end

    --local doubleExchangeConfig = CommonData:getAppData("DoubleExchangeConfig")
    --if doubleExchangeConfig == nil then
    --    return false
    --end

    local isOpen = cc.exports.isDoubleExchangeSupported()
    local startWeekday = cc.exports.isDoubleExchangeStartDate() or 0
    local endWeekday = cc.exports.isDoubleExchangeEndDate() or 0
    if not isOpen then
        return false
    end

    local timeTable = os.date("*t", os.time())
    local curWeekday = timeTable["wday"] - 1
    if curWeekday == 0 then curWeekday = 7 end
    if startWeekday <= endWeekday then
        if curWeekday >= startWeekday and curWeekday <= endWeekday then
            return true
        end
    else
        if curWeekday >= startWeekday or curWeekday <= endWeekday then
            return true
        end
    end

    return false
end

function RoomListModel:getNewUserGuideRoom()
    return self.guideRoomInfo
end

--房间是否限时开发
function RoomListModel:isLimitTimeOpenRoom(roomId)
    local openTime = cc.exports.getOpenTime()
    if openTime and openTime[tostring(roomId)] then
        return true
    end

    return false
end

--获取房间限时开放时间
function RoomListModel:getOpenTime(roomId)
    local openTime = cc.exports.getOpenTime()
    if openTime and openTime[tostring(roomId)] then
        local openTime = openTime[tostring(roomId)]
        local startHour = math.modf(openTime/1000000)
        local startMinute = math.modf((openTime % 1000000) / 10000)
        local endHour = math.modf((openTime % 10000) / 100)
        local endMinute = openTime % 100
        return startHour, startMinute, endHour, endMinute
    end
end

--获取房间限时开放时间字符串
function RoomListModel:getOpenTimeStr(roomId)
    local openTime = cc.exports.getOpenTime()
    if openTime and openTime[tostring(roomId)] then

    end
end

function RoomListModel:getRoomInfoByRoomID(roomID)
    for i, roomInfo in ipairs(self.roomsInfo) do
        if roomInfo.nRoomID == roomID then
            return roomInfo
        end
    end
    return nil
end

return RoomListModel