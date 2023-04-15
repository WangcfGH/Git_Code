local MyJiSuGameConnect = class("MyJiSuGameConnect", import("src.app.Game.mMyGame.MyGameConnect"))
local MyJiSuGameReq = import("src.app.Game.mMyJiSuGame.MyJiSuGameReq")
local MyJiSuGameDef = import("src.app.Game.mMyJiSuGame.MyJiSuGameDef")

local treepack = cc.load("treepack")

--将表中nCardsCount转换成nCardCount，同时将结构补足
function MyJiSuGameConnect:transDunUniteType(dunUniteTypes)
    local uniteTypes = clone(dunUniteTypes)

    for i=1,3 do
        local cardDunType = uniteTypes[i] or {}
        for j=1,8 do
            local unite = cardDunType[j] or {}
            local count = unite.nCardsCount
            unite.nCardCount = count
            unite.nCardsCount = nil

            cardDunType[j] = unite
        end
        uniteTypes[i] = cardDunType
    end
    return uniteTypes
end

function MyJiSuGameConnect:reqAdjustCardOver(dunUniteTypes, nUsingQuickOpe)
    local playerInfoManager = self._gameController:getPlayerInfoManager()
    local uitleInfoManager  = self._gameController:getUtilsInfoManager()
    if not playerInfoManager or not uitleInfoManager then return end

    local waitingResponse = self._gameController:getResponse()
    if waitingResponse == self._gameController:getResWaitingNothing() then
        local reqInfo = MyJiSuGameReq["ADJUSTCARD"]
        local reqInfoData = {
            nChairNO = playerInfoManager:getSelfChairNO(),
            bAdjustOver = 1,
            cardType = self:transDunUniteType(dunUniteTypes),
            cardTypeCount = {
                #dunUniteTypes[1],
                #dunUniteTypes[2],
                #dunUniteTypes[3],
            },
            nUsingQuickOpe = nUsingQuickOpe,
        }

        local reqData = treepack.alignpack(reqInfoData, reqInfo)

        local GR_SENDMSG_TO_SERVER = MyJiSuGameReq["GAME_MSG"]
        local data              = {
            nRoomID             = uitleInfoManager:getRoomID(),
            nUserID             = playerInfoManager:getSelfUserID(),
            nMsgID              = MyJiSuGameDef.HAGD_GAME_MSG_ADJUST_OVER,
            bNeedEcho           = 0,
            nDatalen            = reqData:len(),
        }
        
        local pData = treepack.alignpack(data, GR_SENDMSG_TO_SERVER)
        pData = pData .. reqData
        local session = self:sendRequest(MyJiSuGameDef.SK_GR_SENDMSG_TO_SERVER, pData, pData:len(), true)

        self._gameController:setSession(session)
        self._gameController:setResponse(MyJiSuGameDef.GAME_WAITING_ADJUST)
        print("reqAdjustCardOver request sent")
    else
        print("reqAdjustCardOver error, waitingResponse = " .. waitingResponse)
        my.scheduleOnce(function()
            if self._gameController == nil or self._gameController:isInGameScene() == false then
                return
            end
            self:reqAdjustCardOver(dunUniteTypes, nUsingQuickOpe)
        end, 0.3)
    end
    
end


return MyJiSuGameConnect