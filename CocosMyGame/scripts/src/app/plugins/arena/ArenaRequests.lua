local ArenaRequests = class("ArenaRequests")
local UserModel = mymodel('UserModel'):getInstance()

function ArenaRequests:ctor()
end

function ArenaRequests:MR_GET_ARENA_CONFIG(callback)
    local client = mc.createClient()
    client:setCallback(callback)
    --client:send(requestId)
    client:sendRequest(mc.MR_GET_ARENA_CONFIG, {}, nil, true, nil, nil, 10) --10s超时，防止回应因超时丢失
end

function ArenaRequests:MR_GET_MY_ARENA_DETAIL(callback)
    local client = mc.createClient()
    client:setCallback(callback)
    --client:send(requestId)
    client:sendRequest(mc.MR_GET_MY_ARENA_DETAIL, {}, nil, true, nil, nil, 10) --10s超时，防止回应因超时丢失
end

function ArenaRequests:MR_ARENA_REQ_SIGNUP(matchID, signUpPayType, callback)
    local client = mc.createClient()
    client:setCallback(callback)
    local extraParams = {
        nMatchID        = matchID,
        nSignUpPayType  = signUpPayType,
        szName          = UserModel.szUtf8Username
    }
    --client:send( mc.MR_ARENA_REQ_SIGNUP, extraParams)
    client:sendRequest(mc.MR_ARENA_REQ_SIGNUP, extraParams, nil, true)
end

function ArenaRequests:MR_ARENA_REQ_GIVEUP(matchID, callback)
    local client = mc.createClient()
    client:setCallback(callback)
    local extraParams = {
        nMatchID        = matchID,
    }
    --client:send(mc.MR_ARENA_REQ_GIVEUP, extraParams)
    client:sendRequest(mc.MR_ARENA_REQ_GIVEUP, extraParams, nil, true)
end

function ArenaRequests:MR_ARENA_REQ_MY_RANK(callback)
    local client = mc.createClient()
    client:setCallback(callback)
    local extraParams = {
        nRankType   = 0
    }
    --client:send(mc.MR_ARENA_REQ_MY_RANK, extraParams)
    client:sendRequest(mc.MR_ARENA_REQ_MY_RANK, extraParams, nil, true)
end

function ArenaRequests:MR_ARENA_REQ_RANK(targetRank, range, callback)
    local client = mc.createClient()
    client:setCallback(callback)
    local extraParams = {
        nRange      = range,
        nRankType   = 0,
        nTargetRank = targetRank
    }
    --client:send(mc.MR_ARENA_REQ_RANK, extraParams)
    client:sendRequest(mc.MR_ARENA_REQ_RANK, extraParams, nil, true)
end

return ArenaRequests