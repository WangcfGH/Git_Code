--[[
@描述: clubrequest其实也是大厅消息，考虑到是独立的模块把亲友圈消息独立到一个文件管理.
这个文件不能单独被使用，只能被HallRequest引用后通过HallRequest来调用
@作者：陈添泽
@日期：2017.12.13
]]

local ClubRequests = {}

--[Comment]
--获取亲友圈列表
function ClubRequests:MR_CLUB_GET_CLUBLIST(callback)
    local client = mc.createClient()
    client:setCallback(callback)

    local params = {
        nUserID = self._userModel.nUserID,
        nGameID = self._gameModel.nGameID,
        szGameCode = my.getAbbrName(),
    }

    client:sendRequest(mc.MR_CLUB_GET_CLUBLIST, params, nil, true)
end

--[Comment]
--获取单个亲友圈的全部信息
function ClubRequests:MR_CLUB_GET_ALLINFO(nClubID, callback)
    local client = mc.createClient()
    client:setCallback(callback)

    local params = {
        nUserID = self._userModel.nUserID,
        nClubID = nClubID,
        nGameID = self._gameModel.nGameID,
        szGameCode = my.getAbbrName(),
    }

    client:sendRequest(mc.MR_CLUB_GET_ALLINFO, params, nil, true)
end

--[Comment]
--亲友圈需要管理亲友圈中玩家状态，所以需要调用登入接口，调用之后会返回亲友圈列表，和当前玩家状态
function ClubRequests:MR_LOGON_CLUB(callback)
    local client = mc.createClient()
    client:setCallback(callback)

    local wechatInfo = self._userModel:getWechatInfo()
    local params = {
        nUserID     = self._userModel.nUserID,
        szNickName  = isWechatFirstSupported() and (self._userModel:getWechatInfo() and self._userModel:getWechatInfo().nickname) or NickNameInterface.getNickName(),
        szPortrait  = wechatInfo and wechatInfo.headurl or "",
        szLbsInfo   = mymodel('hallext.LbsModel'):getInstance():getLbsStr(),
        szLbsArea   = mymodel('hallext.LbsModel'):getInstance():getLbsAreaString(),
        nGameID     = self._gameModel.nGameID,
        szGameCode  = my.getAbbrName(),
        szGameName  = my.getAppName(),
    }
    print("checklbs coding")
    dump(params)

    client:sendRequest(mc.MR_LOGON_CLUB, params, nil, true)
end

--[Comment]
--亲友圈需要管理亲友圈中玩家状态，离开亲友圈需要调用
function ClubRequests:MR_LOGOFF_CLUB()
    local client = mc.createClient()

    local params = {
        nUserID = self._userModel.nUserID,
    }

    client:sendRequest(mc.MR_LOGOFF_CLUB, params, nil, false)
end

--[Comment]
--进入到某个亲友圈，会返回亲友圈的全部信息
function ClubRequests:MR_CLUB_ENTERCLUB(nClubNO, callback)
    local client = mc.createClient()
    client:setCallback(callback)

    local params = {
        nUserID = self._userModel.nUserID,
        nClubNO = nClubNO,
        nGameID = self._gameModel.nGameID,
        szGameCode = my.getAbbrName(),
    }

    client:sendRequest(mc.MR_CLUB_ENTERCLUB, params, nil, true)
end

--[Comment]
--获取玩家消息列表
function ClubRequests:MR_CLUB_GET_PLAYERMSGS(callback)
    local client = mc.createClient()
    client:setCallback(callback)

    local params = {
        nUserID = self._userModel.nUserID,
    }

    client:sendRequest(mc.MR_CLUB_GET_PLAYERMSGS, params, nil, true)
end

function ClubRequests:MR_CLUB_GETCLUBBILL(nClubNO, nPlayerID, nPayType, nDirection, nLastBillTimestamp, nPageSize, callback, abbr, roundBillID)
    local client = mc.createClient()
    client:setCallback(callback)

    local params = {
        nClubNO         = nClubNO,
        nPlayerID       = nPlayerID,
        nPayType        = nPayType,
        nDirection      = nDirection,
        nLastBillTimestamp = nLastBillTimestamp,
        nPageSize       = nPageSize,
        szGameCode      = abbr,
        szRoundBillID   = roundBillID
    }

    client:sendRequest(mc.MR_GET_CLUBROUNDWIN, params, nil, true)
end

function ClubRequests:MR_CLUB_CLIENT_CREATEROOM(nClubNO, nPayType, nRoomType, nAmount, szRuleJson, callback)
    local client = mc.createClient()
    client:setCallback(callback)

    local params = {
        nUserID     = self._userModel.nUserID,
        nClubNO     = nClubNO,
        nGameID     = self._gameModel.nGameID,
        szGameCode  = my.getAbbrName(),
        nRoomType   = nRoomType,
        nAmount     = nAmount,
        nPayType    = nPayType,
        nRuleLength = szRuleJson:len() + 1,
        szRuleJson  = szRuleJson.."\0"
    }


    client:sendRequest_custom(mc.MR_CLUB_CLIENT_CREATEROOM, params, nil, true, true, false, 15)--创建房间有可能比较慢 所以超时10s 超时之后直接断开
end

--[Comment]
--加入亲友圈请求可以增加请求原因，arrRemarkData请求原因字符串
function ClubRequests:MR_CLUB_APPLY_JOINCLUB(nClubNO, arrRemarkData, callback)
    local client = mc.createClient()
    client:setCallback(callback)

    local params = {
        nUserID         = self._userModel.nUserID,
        nClubNO         = nClubNO,
        nGameID         = self._gameModel.nGameID,
        szGameCode      = my.getAbbrName(),
        nRemarkLength   = arrRemarkData:len() + 1,
        arrRemarkData   = arrRemarkData.."\0"
    }


    client:sendRequest(mc.MR_CLUB_APPLY_JOINCLUB, params, nil, true)
end

function ClubRequests:MR_CLUB_APPLY_EXITCLUB(nClubNO, callback)
    local client = mc.createClient()
    client:setCallback(callback)

    local params = {
        nUserID     = self._userModel.nUserID,
        nClubNO     = nClubNO,
        nGameID     = self._gameModel.nGameID,
        szGameCode  = my.getAbbrName(),
    }

    client:sendRequest(mc.MR_CLUB_APPLY_EXITCLUB, params, nil, true)
end

return ClubRequests