
local ril=import('src.app.GameHall.models.mcsocket.RequestIdList')
local mcrc=import('src.app.GameHall.models.mcsocket.MCSocketDataStruct')

local TreePack=cc.load('treepack')

local rs=mcrc.MCSocketDataStruct

-- 移动端选桌begin
--解析玩家就座信息
local function parseNTF_GET_SEATED(data)
    local NTF_GET_SEATED={
        lengthMap = {
            [8] = {maxlen = 32},
            maxlen = 8
        },
        nameMap = {
            'nUserID',
            'nTableNO',
            'nChairNO',
            'nNetDelay',
            'nMinScore',
            'nMinDeposit',
            'nFirstSeatedPlayer',
            'szPassword'
        },
        formatKey = '<iiiiiiiA',
        deformatKey = '<iiiiiiiA32',
        maxsize = 60
    }
    local temp = TreePack.unpack(data, NTF_GET_SEATED)
    local ntf_get_seated = {
        pp = {
            nUserID = temp.nUserID,
            nTableNO = temp.nTableNO,
            nChairNO = temp.nChairNO,
            nNetDelay = temp.nNetDelay
        },
        nMinScore = temp.nMinScore,
        nMinDeposit = temp.nMinDeposit,
        nFirstSeatedPlayer = temp.nFirstSeatedPlayer,
        szPassword = temp.szPassword
    }
    local tableSnapData = data 
    local passwordData = tableSnapData:sub(29)
    local next, szPassword = string.unpack(passwordData, "<z")
    ntf_get_seated.szPassword = szPassword
    return ntf_get_seated
end

--解析游戏进行中信息
local function parseNTF_GET_STARTED(data)
    local NTF_GET_STARTED={
        lengthMap = {
            [5] = {maxlen = 8},
            maxlen = 5
        },
        nameMap = {
            'nUserID',
            'nTableNO',
            'nChairNO',
            'nNetDelay',
            'nPlayerAry',
        },
        formatKey = '<iiiii8',
        deformatKey = '<iiiii8',
        maxsize = 48
    }
    local temp = TreePack.unpack(data, NTF_GET_STARTED)
    local ntf_get_started = {
        pp = {
            nUserID = temp.nUserID,
            nTableNO = temp.nTableNO,
            nChairNO = temp.nChairNO,
            nNetDelay = temp.nNetDelay
        },
        nPlayerAry = temp.nPlayerAry
    }
    return ntf_get_started
end

--解析游戏开始信息
local function parseNTF_GAMESTARTUP(data)
    local NTF_GAMESTARTUP={
        lengthMap = {
            [3] = {maxlen = 8},
            [5] = {maxlen = 3},
            maxlen = 5
        },
        nameMap = {
            'nRoomID',
            'nTableNO',
            'nPlayerAry',
            'dwTableChairStatus',
            'nReserved',
        },
        formatKey = '<iii8ii3',
        deformatKey = '<iii8ii3',
        maxsize = 56
    }
    return TreePack.unpack(data, NTF_GAMESTARTUP)
end

--解析清除solo桌响应信息
local function parseSOLOTABLE_CLOSED(data)
    local SOLOTABLE_CLOSED={
        lengthMap = {
            [4] = {maxlen = 8},
            [5] = {maxlen = 5},
            maxlen = 5
        },
        nameMap = {
            'nRoomID',
            'nTableNO',
            'nUserCount',
            'nUserIDs',
            'nReserved'
        },
        formatKey = '<iiiiiiiiiiiiiiii',
        deformatKey = '<iiiiiiiiiiiiiiii',
        maxsize = 64
    }
    return TreePack.unpack(data, SOLOTABLE_CLOSED)
end

--解析玩家进入新桌子
local function parseNTF_GET_NEWTABLE(data)
    local NTF_GET_NEWTABLE={
        lengthMap = {
			[11] = { maxlen = 1 },
			maxlen = 11
		},
		nameMap = {
			'nUserID',		-- [1] ( int )
			'nTableNO',		-- [2] ( int )
			'nChairNO',		-- [3] ( int )
			'nNetDelay',		-- [4] ( int )
			'nMinScore',		-- [5] ( int )
			'nMinDeposit',		-- [6] ( int )
			'nFirstSeatedPlayer',		-- [7] ( int )
			'nHomeUserID',		-- [8] ( int )
			'nHavePassword',		-- [9] ( int )
			'nWinRate',		-- [10] ( int )
			'nReserved',		-- [11] ( int )
		},
		formatKey = '<i11',
		deformatKey = '<i11',
		maxsize = 44
    }
    local temp = TreePack.unpack(data, NTF_GET_NEWTABLE)
    local ntf_get_newtable = {
        pp = {
            nUserID = temp.nUserID,
            nTableNO = temp.nTableNO,
            nChairNO = temp.nChairNO,
            nNetDelay = temp.nNetDelay
        },
        nMinScore = temp.nMinScore,
        nMinDeposit = temp.nMinDeposit,
        nFirstSeatedPlayer = temp.nFirstSeatedPlayer,
        nHomeUserID = temp.nHomeUserID,
        nReserved = temp.nReserved
    }
    return ntf_get_newtable
end

-- 解析玩家位置信息
local function parsePLAYER_POSITION(data) return TreePack.unpack(data, rs.PLAYER_POSITION) end

-- 解析玩家进入信息
local function parsePLAYER_ONLY(data)     return TreePack.unpack(data, rs.PLAYER_ONLY)     end

-- 解析房间信息
local function parseGET_ROOM_INFO_OK(data)
    assert(data, "parseGET_ROOM_INFO_OK, data is nil !!!")

    local nextidx, roomInfo = 0, {}
    nextidx, roomInfo.nPlayerCount      = string.unpack(data, "<i")
    nextidx, roomInfo.nTableCount       = string.unpack(data, "<i", nextidx)
    nextidx, roomInfo.nActiveTableCount = string.unpack(data, "<i", nextidx)
    nextidx, roomInfo.nReserved         = string.unpack(data, "<i2", nextidx)
        
    -- 玩家信息
    local idx = nextidx - 1
    local len = rs.PLAYER_ONLY.maxsize
    local players = {}
    for i=1,roomInfo.nPlayerCount do
        local player = TreePack.unpack(data:sub(idx+len*(i-1)+1,idx+len*i),rs.PLAYER_ONLY)
        players[player.nUserID] = player
    end
    -- 桌子信息
    idx = idx+len*roomInfo.nPlayerCount
    len = rs.XZ_TABLE_HEAD.maxsize
    local len2 = rs.XZ_PLAYER_POS.maxsize
    local len3 = rs.XZ_VISITOR_POS.maxsize
    local tables = {}
    for i=1,roomInfo.nActiveTableCount do
        local oneTable = TreePack.unpack(data:sub(idx+1,idx+len),rs.XZ_TABLE_HEAD)
        tables[oneTable.nTableNO] = oneTable
        idx = idx + len
        -- 椅子信息
        oneTable.nPlayerAry = {}
        for j=1, oneTable.nPlayerCount do
            local pos = TreePack.unpack(data:sub(idx+1,idx+len2),rs.XZ_PLAYER_POS)
            oneTable.nPlayerAry[pos.nChairNO+1] = pos.nUserID
            idx = idx + len2
        end
        -- 旁观者信息
        oneTable.nVisitorAry = {}
        for j=1, oneTable.nVisitorCount do
            local pos = TreePack.unpack(data:sub(idx+1,idx+len3),rs.XZ_VISITOR_POS)
            if not oneTable.nVisitorAry[pos.nChairNO+1] then
                oneTable.nVisitorAry[pos.nChairNO+1] = {}
            end
            table.insert(oneTable.nVisitorAry[pos.nChairNO+1],pos.nUserID)
            idx = idx + len3
        end
    end
    return {roominfo,players,tables}
end
-- 移动端选桌end

local RespondCases={

        ADMINMSG_TO_ROOM = rs.SYSTEM_MSG,

        UR_OPERATE_SUCCEED = {
            QUERY_BACKDEPOSIT = rs.BACK_DEPOSIT,
            UPDATE_SPECIFY_USERINFO = rs.UPDATE_USERSPECIFYINFO_OK,
            QUERY_WEALTH = rs.USER_WEALTH,
            QUERY_MEMBER = rs.MEMBER_INFO,
            GET_DOWNLOAD_SERVER = rs.SERVERS,
            QUERY_SALARY_DEPOSIT = rs.SALARY_DEPOSIT,
            ASK_ENTER_GAME = rs.PLAYER_POSITION,
            GET_RNDKEY = rs.GET_RNDKEY_OK,
            QUICK_REG = rs.QUICK_REG_OK,
            QUERY_USER_GAMEINFO = rs.USER_GAMEINFO,
            MR_GET_NEWTABLE=rs.NTF_MR_GET_NEWTABLE,
            MR_NEW_PRIVATEROOM=rs.NTF_MR_GET_NEWTABLE,
            MR_STAND_UP_SEAT=rs.NTF_GET_SEATED,
            MR_ASK_ENTER_PRIVATEROOM=rs.NTF_MR_GET_NEWTABLE,
            MR_ASK_ENTER_TEAMROOM = rs.NTF_PLAYER_NEWTABLE,
            MR_NEW_TEAMROOM = rs.NTF_PLAYER_NEWTABLE,
            MR_TRYGOTO_OTHERROOM=rs.TRYGOTORESULT,
            GET_ASSISTSVR = function (data)
                local head={struct=rs.ASSIST_SERVER_HEAD,length=20}
                local unit={struct=rs.ASSIST_SERVER,length=124}
                return TreePack.parseListWithInfoHead(data,head,unit)
            end ,

            --旁观
            GR_GET_LOOKON = rs.PLAYER_POSITION,
            GET_AREAS = function (data)
                local head={struct=rs.AREAS,length=16}
                local unit={struct=rs.AREA,length=108}

                return TreePack.parseListWithInfoHead(data,head,unit)

            end ,
            MR_GET_WEBSIGN = rs.GET_WEBSIGN_OK,
            QUERY_SAFE_DEPOSIT = rs.SAFE_DEPOSIT,
            GET_ROOMS=function (data)
                local head={struct=rs.ROOMS,length=16}
                local unit={struct=rs.ROOM,length=420}

                local roomsInfo,roomsList=unpack(TreePack.parseListWithInfoHead(data,head,unit))

                table.sort(roomsList,function(a,b)
                    return a.nLayOrder<b.nLayOrder
                end)

                return {roomsInfo,roomsList}
            end,
            EXCHANGE_WEALTH=rs.EXCHANGE_WEALTH_OK,
            GET_WEBSIGN_OK=rs.GET_WEBSIGN,

            MR_FOUND_NEW_GROUP_TABLEROOMS=function (data)
                local head={struct=rs.REPLY_NEW_GROUP_TABLEROOMS,length=36}
                local unit={struct=rs.ONE_TABLEROOM,length=92}
                return TreePack.parseListWithInfoHead(data,head,unit)
            end,

            MR_ASK_DETAIL_TABLEROOMS=function (data)
                local head={struct=rs.REPLY_DETAIL_TABLEROOMS,length=40}
                local unit={struct=rs.ONE_TRPLAYER,length=56}
                return TreePack.parseListWithInfoHead(data,head,unit)
            end,

            MR_ASK_SYSTEM_FIND_PLAYERS=function (data)
                printf("~~~~~~~~~MR_ASK_SYSTEM_FIND_PLAYERS ok~~~~~~~~~~~~")
            end,
            MR_FOUND_GROUP_TEAMROOMS=function (data)
                local head={struct=rs.REPLY_NEW_GROUP_TABLEROOMS,length=36}
                local unit={struct=rs.ONE_TABLEROOM,length=92}
                return TreePack.parseListWithInfoHead(data,head,unit)
            end,
            MR_GET_WHEREISUSER = function (data)
                local pos, int = string.unpack(data, '<i')
                return int
            end,
            SEARCH_PLAYER_INGAME = rs.SEARCH_PLAYER_INGAME_OK,
            CHECK_VERSION        = rs.CHECK_VERSION_OK,
            MR_QUERY_DXXW_INFO   = rs.USER_DXXW_INFO,
            MR_GET_ROOM          = rs.ROOM,

            --竞技场
            MR_GET_ARENA_CONFIG = function(data)
				local head={struct=rs.ARENA_CONFIG_HEAD,length = 44}
				local unit={struct=rs.ARENA_CONFIG, length = 1016}
				local dataMap = TreePack.parseListWithInfoHead(data, head, unit)
				return dataMap
			end,
			MR_GET_MY_ARENA_DETAIL = rs.MY_ARENA_DETAIL,
			MR_ARENA_REQ_SIGNUP = rs.ARENA_ACK_SIGNUP,
			MR_ARENA_REQ_GIVEUP = rs.ARENA_ACK_SIGNUP,
			MR_ARENA_REQ_TICKET = function(data)
				local head={struct=rs.ARENA_ACK_TICKET,length = 36}
				local unit={struct=rs.ARENA_TICKET, length = 116}
				local dataMap = TreePack.parseListWithInfoHead(data, head, unit)
				return dataMap
			end,
			MR_ARENA_REQ_RANK = function(data)
				local head={struct=rs.ARENA_ACK_RANK,length = 40}
				local unit={struct=rs.ARENA_RANK, length = 84}
				local dataMap = TreePack.parseListWithInfoHead(data, head, unit)
				return dataMap
			end,
			MR_ARENA_REQ_MY_RANK    = rs.ARENA_USER_RANK,
			MR_GET_ONE_ARENA_CONFIG = rs.ARENA_ONE_CONFIG,
			MR_GET_MY_ARENA_HONOR   = rs.MY_ARENA_HONOR,


            MR_GET_YQWROOMINFO   = function(data)
                local dataMap = TreePack.unpack(data, rs.YQWROOM_INFO)
                dataMap.szRuleJson = string.sub(data, rs.YQWROOM_INFO.maxsize + 1, rs.YQWROOM_INFO.maxsize + dataMap.nRuleLen)
                return dataMap
            end,
            MR_GET_YQWPLAYERINFO = rs.YQWROOM_INFO,
            MR_YQW_GET_HAPPY_COIN= function(data)
                local dataMap = TreePack.unpack(data, rs.HAPPY_COIN_DATA)
                --拼接longlong的高低位
                dataMap.nTotalBalance = dataMap.nTotalBalance_HIGH >= 0 
                                    and dataMap.nTotalBalance_HIGH * math.pow(2, 32) + dataMap.nTotalBalance_LOW
                                    or  dataMap.nTotalBalance_HIGH * math.pow(2, 32) - dataMap.nTotalBalance_LOW
                dataMap.nDonateBalance = dataMap.nDonateBalance_HIGH >= 0 
                                     and dataMap.nDonateBalance_HIGH * math.pow(2, 32) + dataMap.nDonateBalance_LOW
                                     or  dataMap.nDonateBalance_HIGH * math.pow(2, 32) - dataMap.nDonateBalance_LOW
                return dataMap
            end,
            MR_YQW_ALLOC_ROOM       = rs.NTF_MR_GET_NEWTABLE,
            MR_YQW_JOIN_ROOM        = rs.NTF_MR_GET_NEWTABLE,

            MR_GET_YQWROUNDWIN = function(data)
                local totalLen, headLen, billLen, roundPlayerInfoLen = string.len(data), rs.GET_YQWROUNDBILL_RESP.maxsize, rs.ROUND_BILL.maxsize, rs.ROUND_PLAYER_INFO.maxsize
                local GET_YQWROUNDBILL_RESP = TreePack.unpack(data, rs.GET_YQWROUNDBILL_RESP)
                if GET_YQWROUNDBILL_RESP.nErrCode ~= YQWGetBillResult.YQWGetBillResult_OK then
                    return {header = GET_YQWROUNDBILL_RESP, body = {}}
                end

                local ROUNDBILLS, data = {}, string.sub(data, headLen + 1, totalLen)
                for index = 1, GET_YQWROUNDBILL_RESP.nRoundBillCount do
                    local ROUND_BILL = TreePack.unpack(data, rs.ROUND_BILL)
                    ROUND_BILL.playerInfo = {}
                    data = string.sub(data, billLen + 1, totalLen)
                    for playerInfoIndex = 1, ROUND_BILL.nPlayerCount do
                        ROUND_BILL.playerInfo[playerInfoIndex] = TreePack.unpack(data, rs.ROUND_PLAYER_INFO)
                        data = string.sub(data, roundPlayerInfoLen + 1, totalLen)
                    end
                    ROUNDBILLS[index] = ROUND_BILL
                end

                return {header = GET_YQWROUNDBILL_RESP, body = ROUNDBILLS}
            end,

            MR_GET_CLUBROUNDWIN = function(data)
                local totalLen, headLen, billLen, roundPlayerInfoLen = string.len(data), rs.GET_YQWROUNDBILL_RESP.maxsize, rs.ROUND_BILL.maxsize, rs.ROUND_PLAYER_INFO.maxsize
                local GET_YQWROUNDBILL_RESP = TreePack.unpack(data, rs.GET_YQWROUNDBILL_RESP)
                if GET_YQWROUNDBILL_RESP.nErrCode ~= YQWGetBillResult.YQWGetBillResult_OK then
                    return {header = GET_YQWROUNDBILL_RESP, body = {}}
                end

                local ROUNDBILLS, data = {}, string.sub(data, headLen + 1, totalLen)
                for index = 1, GET_YQWROUNDBILL_RESP.nRoundBillCount do
                    local ROUND_BILL = TreePack.unpack(data, rs.ROUND_BILL)
                    ROUND_BILL.playerInfo = {}
                    data = string.sub(data, billLen + 1, totalLen)
                    for playerInfoIndex = 1, ROUND_BILL.nPlayerCount do
                        ROUND_BILL.playerInfo[playerInfoIndex] = TreePack.unpack(data, rs.ROUND_PLAYER_INFO)
                        data = string.sub(data, roundPlayerInfoLen + 1, totalLen)
                    end
                    ROUNDBILLS[index] = ROUND_BILL
                end

                return {header = GET_YQWROUNDBILL_RESP, body = ROUNDBILLS}
            end,

            MR_GET_YQWGAMEWIN = function(data)
                local totalLen, headLen, gameBillLen, gamePlayerInfoLen = string.len(data), rs.GET_YQWGAMEBILL_RESP.maxsize, rs.GAME_BILL.maxsize, rs.GAME_PLAYER_INFO.maxsize
                local leftLen = totalLen
                local GET_YQWGAMEBILL_RESP = TreePack.unpack(data, rs.GET_YQWGAMEBILL_RESP)
                if GET_YQWGAMEBILL_RESP.nErrCode ~= YQWGetBillResult.YQWGetBillResult_OK then
                    return {header = GET_YQWGAMEBILL_RESP, body = {}}
                end
                leftLen = leftLen - headLen

                local GAMEBILLS, data = {}, string.sub(data, headLen+1, totalLen)
                for index = 1, GET_YQWGAMEBILL_RESP.nGameBillCount do
                    local GAMEBILL = TreePack.unpack(data, rs.GAME_BILL)
                    GAMEBILL.gamePlayerInfo = {}
                    data = string.sub(data, gameBillLen+1, totalLen)
                    leftLen = leftLen - rs.GAME_BILL.maxsize
                    for playerInfoIndex = 1, GAMEBILL.nPlayerCount do
                        GAMEBILL.gamePlayerInfo[playerInfoIndex] = TreePack.unpack(data, rs.GAME_PLAYER_INFO)
                        data = string.sub(data, gamePlayerInfoLen+1, totalLen)
                        leftLen = leftLen - rs.GAME_PLAYER_INFO.maxsize
                    end
                    GAMEBILLS[index] = GAMEBILL
                end

                local GAMERULES
                if leftLen > 0 then
                    local _, ruleLen = string.unpack(data, '<i')
                    GAMERULES = ruleLen > 0 and string.sub(data, 5, 5 + ruleLen)
                    GAMERULES = GAMERULES and GAMERULES or nil
                end

                return {header = GET_YQWGAMEBILL_RESP, body = GAMEBILLS, extendData = {GAMERULES}}
            end,
            MR_CLUB_GET_CLUBLIST            = function(data)
                local head, clubInfoArray = TreePack.parseAsHeadCountStruct(data, rs.CLUB_GET_CLUBLIST_RESP, rs.CLUB_CLUBINFO)
                return {head, clubInfoArray}
            end,
            --扣玩家币start--
            MR_CLUB_GET_ALLINFO             = function(data)
                local head, playerArray, yqwRoomArray, ruleJsons = TreePack.parseAsHeadCountStruct(data, rs.CLUB_GET_ALLINFO_RESP, rs.CLUB_PLAYERINFO, rs.CLUB_YQWROOMINFO)
                return {head, playerArray, yqwRoomArray, ruleJsons}
            end,
            --扣玩家币end--
            MR_LOGON_CLUB                   = function(data)
                local head, clubInfoArray = TreePack.parseAsHeadCountStruct(data, rs.CLUB_LOGON_RESP, rs.CLUB_CLUBINFO)
                return {head, clubInfoArray}
            end,
            --扣玩家币start--
            MR_CLUB_ENTERCLUB               = function(data)
                local head, playerArray, yqwRoomArray, ruleJsons= TreePack.parseAsHeadCountStruct(data, rs.CLUB_GET_ALLINFO_RESP, rs.CLUB_PLAYERINFO, rs.CLUB_YQWROOMINFO)
                return {head, playerArray, yqwRoomArray, ruleJsons}
            end,
            --扣玩家币end--
            MR_CLUB_GET_PLAYERMSGS          = function(data)
                local head, msgArray = TreePack.parseAsHeadCountStruct(data, rs.CLUB_GET_PLAYERMSGS_RESP, rs.CLUB_PLAYERMSG)
                return {head, msgArray}
            end,
            MR_CLUB_CLIENT_CREATEROOM       = rs.CLUB_CLIENT_CREATEROOM_RESP,

            -- 移动端选桌begin
            MR_GET_ROOM_INFO = parseGET_ROOM_INFO_OK,           --获取房间信息(请求响应)
            MR_GET_SEATED_AND_START = rs.NTF_MR_GET_NEWTABLE,   --获取座位并自动开始(请求响应)
            MR_GET_NEWTABLE_EX = rs.NTF_MR_GET_NEWTABLE,        --新建桌子并自动开始(请求响应)
            -- 移动端选桌end
        },
        UR_OPERATE_FAIL = {
            MR_CLUB_CLIENT_CREATEROOM       = function(data)
                local CLUB_FAILED_RESP = TreePack.unpack(data, rs.CLUB_FAILED_RESP)
                CLUB_FAILED_RESP.szMsg = string.sub(data, rs.CLUB_FAILED_RESP.maxsize + 1, rs.CLUB_FAILED_RESP.maxsize + CLUB_FAILED_RESP.nMsgLength)
                return CLUB_FAILED_RESP
            end,
            MR_CLUB_GET_PLAYERMSGS          = function(data)
                local CLUB_FAILED_RESP = TreePack.unpack(data, rs.CLUB_FAILED_RESP)
                CLUB_FAILED_RESP.szMsg = string.sub(data, rs.CLUB_FAILED_RESP.maxsize + 1, rs.CLUB_FAILED_RESP.maxsize + CLUB_FAILED_RESP.nMsgLength)
                return CLUB_FAILED_RESP
            end,
            MR_CLUB_ENTERCLUB               = function(data)
                local CLUB_FAILED_RESP = TreePack.unpack(data, rs.CLUB_FAILED_RESP)
                CLUB_FAILED_RESP.szMsg = string.sub(data, rs.CLUB_FAILED_RESP.maxsize + 1, rs.CLUB_FAILED_RESP.maxsize + CLUB_FAILED_RESP.nMsgLength)
                return CLUB_FAILED_RESP
            end,
            MR_LOGON_CLUB                   = function(data)
                local CLUB_FAILED_RESP = TreePack.unpack(data, rs.CLUB_FAILED_RESP)
                CLUB_FAILED_RESP.szMsg = string.sub(data, rs.CLUB_FAILED_RESP.maxsize + 1, rs.CLUB_FAILED_RESP.maxsize + CLUB_FAILED_RESP.nMsgLength)
                return CLUB_FAILED_RESP
            end,
            MR_CLUB_GET_ALLINFO             = function(data)
                local CLUB_FAILED_RESP = TreePack.unpack(data, rs.CLUB_FAILED_RESP)
                CLUB_FAILED_RESP.szMsg = string.sub(data, rs.CLUB_FAILED_RESP.maxsize + 1, rs.CLUB_FAILED_RESP.maxsize + CLUB_FAILED_RESP.nMsgLength)
                return CLUB_FAILED_RESP
            end,
            MR_CLUB_GET_CLUBLIST            = function(data)
                local CLUB_FAILED_RESP = TreePack.unpack(data, rs.CLUB_FAILED_RESP)
                CLUB_FAILED_RESP.szMsg = string.sub(data, rs.CLUB_FAILED_RESP.maxsize + 1, rs.CLUB_FAILED_RESP.maxsize + CLUB_FAILED_RESP.nMsgLength)
                return CLUB_FAILED_RESP
            end,
            MR_CLUB_APPLY_JOINCLUB          = function(data)
                local CLUB_FAILED_RESP = TreePack.unpack(data, rs.CLUB_FAILED_RESP)
                CLUB_FAILED_RESP.szMsg = string.sub(data, rs.CLUB_FAILED_RESP.maxsize + 1, rs.CLUB_FAILED_RESP.maxsize + CLUB_FAILED_RESP.nMsgLength)
                return CLUB_FAILED_RESP
            end,

        },
        SEARCH_PLAYER_INGAME_OK = rs.SEARCH_PLAYER_INGAME_OK,
        REG_USER_OK = rs.REG_USER_OK_MB,

        -- 移动端选桌：begin
        MR_ENTER_ROOM_OK = function (data)
            local enterRoomOk=TreePack.unpack(data,rs.MR_ENTER_ROOM_OK_ONLY)
            -- 选桌模式进房间时要获取所有玩家信息和桌子信息
            local FLAG_ENTERROOMOK_MOBILE = 0x800
            if  FLAG_ENTERROOMOK_MOBILE == bit.band(FLAG_ENTERROOMOK_MOBILE , enterRoomOk.dwEnterOKFlag) then
                local playerOnly=TreePack.unpack(data:sub(rs.MR_ENTER_ROOM_OK_ONLY.maxsize+1,rs.PLAYER_ONLY.maxsize + rs.MR_ENTER_ROOM_OK_ONLY.maxsize),rs.PLAYER_ONLY)
                return {enterRoomOk,playerOnly}
            else
                -- 玩家信息
                local idx = rs.MR_ENTER_ROOM_OK_ONLY.maxsize
                local len = rs.PLAYER_ONLY.maxsize
                local allPlayers = {}
                for i=1,enterRoomOk.nPlayerCount do
                    local player = TreePack.unpack(data:sub(idx+len*(i-1)+1,idx+len*i),rs.PLAYER_ONLY)
                    allPlayers[player.nUserID] = player
                end
                -- 桌子信息
                idx = idx+len*enterRoomOk.nPlayerCount
                len = rs.XZ_TABLE_HEAD.maxsize
                local len2 = rs.XZ_PLAYER_POS.maxsize
                local len3 = rs.XZ_VISITOR_POS.maxsize
                local allTables = {}
                for i=1,enterRoomOk.nActiveTableCount do
                    local oneTable = TreePack.unpack(data:sub(idx+1,idx+len),rs.XZ_TABLE_HEAD)
                    allTables[oneTable.nTableNO] = oneTable
                    idx = idx + len
                    -- 椅子信息
                    oneTable.nPlayerAry = {}
                    for j=1, oneTable.nPlayerCount do
                        local pos = TreePack.unpack(data:sub(idx+1,idx+len2),rs.XZ_PLAYER_POS)
                        oneTable.nPlayerAry[pos.nChairNO+1] = pos.nUserID
                        idx = idx + len2
                    end
                    -- 旁观者信息
                    oneTable.nVisitorAry = {}
                    for j=1, oneTable.nVisitorCount do
                        local pos = TreePack.unpack(data:sub(idx+1,idx+len3),rs.XZ_VISITOR_POS)
                        if not oneTable.nVisitorAry[pos.nChairNO+1] then
                            oneTable.nVisitorAry[pos.nChairNO+1] = {}
                        end
                        table.insert(oneTable.nVisitorAry[pos.nChairNO+1],pos.nUserID)
                        idx = idx + len3
                    end
                end
                return {enterRoomOk,allPlayers,allTables}
            end
        end,
        -- 移动端选桌：end

        --旁观
        MR_QUERY_ROOMINFO_BYROOMNO = function (data)
            local roomInfo=TreePack.unpack(data,rs.MR_ROOMINFO_BY_ROOMNO)
            return roomInfo
        end,

        ROOM_NEED_DXXW = function(data)
            local _, id = string.unpack(data,'<i')
            return id
        end,

        GET_ROOMUSERS_OK=function (data)
            local head={struct=rs.ITEM_COUNT,length=20}
            local unit={struct=rs.ITEM_USERS,length=8}

            local dataMap = TreePack.parseListWithInfoHead(data,head,unit)
            return dataMap
        end,
        GET_GAMELEVEL_OK = rs.GAME_LEVEL,

        LOGON_NEED_ACTIVATE = rs.USER_ACTIVATE,

        GET_SERVERS_OK = rs.SERVERS,
        PAY_RESULT = function (data)
            local payResult=TreePack.unpack(data,rs.PAY_RESULT)
            if payResult then --获取int64值
                payResult["llBalance"] = cc.exports.getInt64Val(payResult["llBalance2"], payResult["llBalance1"])
                payResult["llOperationID"] = cc.exports.getInt64Val(payResult["llOperationID2"], payResult["llOperationID1"])
            end
            cc.exports.DealPayResult(payResult)
            return
        end,
        PAY_VIP_RESULT          = function (data)
            local payvipResult=TreePack.unpack(data,rs.PAY_VIP_RESULT)
            cc.exports.DealPayVIPResult(payvipResult)
            return
        end,
        MR_BE_FOUND_BY_SYSTEM   = function (data)
            local systemFind=TreePack.unpack(data,rs.BE_FOUND_BY_SYSTEM)
            
            return systemFind
        end,
        EXPERIENCE_NOTENOUGH    = rs.EXPERIENCE_NOTENOUGH,
        GR_CURRENCY_EXCHANGE    = rs.CURRENCY_EXCHANGE_EX,
        GR_MAILSYS_NOTIFY       = rs.MAILSYS_NOTIFY,
        MR_CLUB_NOTIFY_YQWROOM_STATUS       = rs.CLUB_YQWROOM_STATUS_NTF,
        MR_CLUB_NOTIFY_PLAYER_ONLINE        = rs.CLUB_PLAYER_ONLINE_NTF,
        MR_CLUB_NOTIFY_CLUBPLAYER_STATUS    = rs.CLUB_CLUBPLAYER_STATUS_NTF,
        MR_CLUB_NOTIFY_CLUBEDIT             = function(data)
            local head, clubGameArray = TreePack.parseAsHeadCountStruct(data, rs.CLUB_CLUBPEDIT_NTF, rs.CLUB_CLUBGAME)
            return {head, clubGameArray}
        end,
        MR_CLUB_NOTIFY_CLUBDISSOLVE         = function (data)
            local pos, int = string.unpack(data, '<i')
            return int
        end,
        MR_CLUB_NOTIFY_PLAYERINFO           = rs.CLUB_PLAYERINFO,
        --扣玩家币start--
        MR_CLUB_NOTIFY_RULEEDIT             = function(data)
            local ruleDif, ruleJsons = TreePack.parseAsHeadCountStruct(data, rs.CLUB_RULEEDIT_NTF)    
            return {ruleDif, ruleJsons}        
        end,
        --扣玩家币end--
        MR_CLUB_RESPONSE_LOGON_OK           = {
            MR_LOGON_CLUB                   = function(data)
                local head, clubInfoArray = TreePack.parseAsHeadCountStruct(data, rs.CLUB_LOGON_RESP, rs.CLUB_CLUBINFO)
                return {head, clubInfoArray}
            end,
        },

        -- 移动端选桌：begin
        GR_PLAYER_ENTERED     = parsePLAYER_ONLY,       --玩家进入房间(响应)
        GR_PLAYER_SEATED      = parseNTF_GET_SEATED,    --玩家就座(响应)
        GR_PLAYER_UNSEATED    = parsePLAYER_POSITION,   --玩家离座(响应)
        GR_PLAYER_STARTED     = parsePLAYER_POSITION,   --玩家开始玩游戏(响应)
        GR_PLAYER_PLAYING     = parseNTF_GET_STARTED,   --游戏进行中(响应)
        GR_PLAYER_LEFT        = parsePLAYER_POSITION,   --玩家离开房间(响应)
        GR_PLAYER_LEAVETABLE  = parsePLAYER_POSITION,   --玩家离座(响应)
        GR_PLAYER_NEWTABLE    = parseNTF_GET_NEWTABLE,  --玩家到新的桌子(响应)
        GR_SOLOTABLE_CLOSED   = parseSOLOTABLE_CLOSED,  ---清除solo桌(响应)
        GR_PLAYER_GAMESTARTUP = parseNTF_GAMESTARTUP,   --游戏开始(响应)
        GR_PLAYER_GAMEBOUTEND = parseNTF_GAMESTARTUP,   --游戏一局结束(响应)
        -- 移动端选桌：end
}

local function getResponseExchMap(respondId,requestId)
    local exchMap
    local name=ril.RespondIdReflact[respondId]
    local respondCase=RespondCases[name]
    if(type(respondCase)=='table' and respondCase.nameMap==nil)then
        local requestName=ril.RequestIdReflact[requestId]
        if(not requestName)then
            exchMap=respondCase
        else
            exchMap=respondCase[requestName]
        end
    else
        exchMap=respondCase
    end

    if(exchMap==nil)then
        exchMap=mcrc.getExchMap(respondId)
    end
    return exchMap
end

return {
    getExchMap=getResponseExchMap,
}