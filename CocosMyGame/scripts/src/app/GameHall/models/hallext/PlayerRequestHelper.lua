local PlayerRequestHelper = {}

local ClassicRequestConditionMap = {
    ["QUERY_MEMBER"]        = isVIPSupported,
    ["QUERY_SAFE_DEPOSIT"]  = isSafeBoxSupported,
    ["QUERY_BACKDEPOSIT"]   = function() return (not isSafebBoxSupported) and isBackBoxSupported end,
    ["GET_RNDKEY"]          = false,
    ["QUERY_USER_GAMEINFO"] = true,
    -- ["QUERY_WEALTH"] = true
}

local YQWRequestConditionMap = {
    ["QUERY_MEMBER"]          = isVIPSupported,
    ["MR_YQW_GET_HAPPY_COIN"] = isRoomCardSupported,
    ["QUERY_USER_GAMEINFO"] = true
}

local messageBuffer = {}
--防止由于触发机制在获取过程中发送相同请求

local function aquireListInfo(list, callback)
    local requestCount, callbackCount = 0, 0
    for request, condition in pairs(list) do
        if ((type(condition) == "function" and condition()) or (type(condition) == "boolean" and condition)) and (not messageBuffer[request]) then
            messageBuffer[request] = true
            HallRequests[request](HallRequests, function(respondType, data, msgType, dataMap)
                messageBuffer[request] = nil
                dump(dataMap)
                if respondType == mc.UR_OPERATE_SUCCEED then
                    local userModel = mymodel('UserModel'):getInstance()
                    local PlayerModel = mymodel("hallext.PlayerModel"):getInstance()
                    if request == "QUERY_MEMBER" then
                        userModel:setUserMemberInfo(dataMap)

                        PlayerModel:dispatchEvent({name = PlayerModel.PLAYER_MEMBER_INFO_UPDATED, value=userModel})
                    else
                        table.merge(userModel, dataMap)
                    end
                elseif request == "MR_YQW_GET_HAPPY_COIN" then
                    local userModel = mymodel('UserModel'):getInstance()
                    userModel.nTotalBalance = 0
                    local _, code = type(data) == "string" and string.len(data) > 0 and string.unpack(data, '<i')
                    printf('user happy coin failed, code:%s', tostring(code))
                end
                callbackCount = callbackCount + 1
                if callbackCount == requestCount then 
                    if type(callback) == "function" then callback('succeed') end
                    if type(PlayerRequestHelper._dataUpdateHandler) == "function" then PlayerRequestHelper._dataUpdateHandler() end
                end
            end)
            requestCount = requestCount + 1
        end
    end
    if requestCount == 0 then
        if type(callback) == "function" then callback('succeed') end
    end
end

function PlayerRequestHelper:aquireYQWInfo(callback)
    aquireListInfo(YQWRequestConditionMap, callback)
end 

function PlayerRequestHelper:aquireClassicInfo(callback)
    aquireListInfo(ClassicRequestConditionMap, callback)
end

function PlayerRequestHelper:setDataUpdateCallback(callback)
    self._dataUpdateHandler = callback
end

function PlayerRequestHelper:getElementIndexMetaTable()
    local structs = import('src.app.GameHall.models.mcsocket.MCSocketDataStruct').MCSocketDataStruct
    local elementRequestMap = {
        QUERY_MEMBER            = {"isMember", "memberInfo"},
        QUERY_SAFE_DEPOSIT      = structs["SAFE_DEPOSIT"].nameMap,
        QUERY_BACKDEPOSIT       = structs["BACK_DEPOSIT"].nameMap,
        GET_RNDKEY              = structs["GET_RNDKEY_OK"].nameMap,  
        QUERY_USER_GAMEINFO     = structs["USER_GAMEINFO"].nameMap,
        MR_YQW_GET_HAPPY_COIN   = {"nTotalBalance", "nDonateBalance"},
        -- QUERY_WEALTH            = structs["QUERY_WEALTH"].nameMap,
    }

    local unAvalableMap = {
        nUserID     = true,
        nReserved   = true,
        nGameID     = true,
        dwFlags     = true
    }

    local indexMetaTable = {
        __index = function( target, key )
            if not cc.exports.hasLogined then return end
            if string.match(key, "%A+") then return end --带符号的不管
            if unAvalableMap[key] then return end       --特定几个说好不要的不管
            for name, struct in pairs(elementRequestMap) do
                if table.indexof(struct, key) then
                    aquireListInfo({[name] = true})
                    return
                end
            end
        end
    }
    local super = {}
    setmetatable(super, indexMetaTable)
    return super
end

function PlayerRequestHelper:aquireListInfo(...)
    aquireListInfo(...)
end


local client = mc.createClient()
client:registHandler(mc.UR_SOCKET_ERROR,  function ()
    messageBuffer = {}
end, 'hall')
client:registHandler(mc.UR_SOCKET_GRACEFULLY_ERROR,  function ()
    messageBuffer = {}
end, 'hall')

cc.exports.PlayerRequestHelper = PlayerRequestHelper

return PlayerRequestHelper