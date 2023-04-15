
local BaseGameConnect = class("BaseGameConnect")

local treepack                              = cc.load("treepack")

require("src.app.GameHall.PublicInterface")
local PublicInterface                       = cc.exports.PUBLIC_INTERFACE

local BaseGameReq                           = import("src.app.Game.mBaseGame.BaseGameReq")
local BaseGameDef                           = import("src.app.Game.mBaseGame.BaseGameDef")

local targetPlatform = cc.Application:getInstance():getTargetPlatform()

function BaseGameConnect:create(gameController)
    return BaseGameConnect.new(gameController)
end

function BaseGameConnect:ctor(gameController)
    if not gameController then printError("gameController is nil!!!") return end
    self._gameController                    = gameController
end

function BaseGameConnect:pause()
    local networkClient = self._gameController:getNetworkClient()
    if networkClient then
        --networkClient:pause()
    end
end

function BaseGameConnect:resume()
    local networkClient = self._gameController:getNetworkClient()
    if networkClient then
        --networkClient:resume()
    end
end

function BaseGameConnect:disconnect()
    local networkClient = self._gameController:getNetworkClient()
    if networkClient then
        networkClient:disconnect()
    end
end

function BaseGameConnect:sendRequest(msg_type, msgData, msgDataLength, needResponse)
    local session = -1
    local networkClient = self._gameController:getNetworkClient()
    if networkClient then
        session = networkClient:sendRequest(msg_type, msgData, msgDataLength, needResponse)
        print("sendRequest: request=" .. msg_type .. ", session=" ..session .. ", needResponse=" .. tostring(needResponse))
        if -1 == session then
            print("session is -1???")
        else
            if needResponse then
                self._gameController:setSession(session)
                self._gameController:waitForResponse()
            end
        end
    else
        print("networkClient is nil!!!")
    end
    return session
end

function BaseGameConnect:gc_SendGamePulse()
    local playerInfoManager = self._gameController:getPlayerInfoManager()
    if not playerInfoManager then return end

    local GR_GAME_PULSE = BaseGameReq["GAME_PULSE"]
    local data              = {
        nUserID             = playerInfoManager:getSelfUserID(),
    }
    local pData = treepack.alignpack(data, GR_GAME_PULSE)

    self:sendRequest(BaseGameDef.BASEGAME_GR_GAME_PULSE, pData, pData:len(), false)
end

function BaseGameConnect:gc_AppEnterBackground()
    local playerInfoManager = self._gameController:getPlayerInfoManager()
    local utilsInfoManager  = self._gameController:getUtilsInfoManager()
    if not playerInfoManager or not utilsInfoManager then return end

    local waitingResponse = self._gameController:getResponse()
    if waitingResponse == self._gameController:getResWaitingNothing() then
        local MR_ENTER_BACKGROUND = BaseGameReq["ENTER_BKGFKG"]
        local data          = {
            nUserID         = playerInfoManager:getSelfUserID(),
            nRoomID         = utilsInfoManager:getRoomID(),
            nTableNO        = playerInfoManager:getSelfTableNO(),
            nChairNO        = playerInfoManager:getSelfChairNO()
        }
        local pData = treepack.alignpack(data, MR_ENTER_BACKGROUND)

        self:sendRequest(BaseGameDef.BASEGAME_MR_ENTER_BACKGROUND, pData, pData:len(), false)
        cc.exports.PUBLIC_INTERFACE.EnterBackGround(
            utilsInfoManager:getRoomID(),
            playerInfoManager:getSelfTableNO(),
            playerInfoManager:getSelfChairNO()
        )

        --[[cc.exports.RoomServer_AppSwitchBackGroundForeGround('back',
            utilsInfoManager:getRoomID(),
            playerInfoManager:getSelfTableNO(),
            playerInfoManager:getSelfChairNO())]]--
        print("GC_AppEnterBackground request sent")
    else
        print("GC_AppEnterBackground error, waitingResponse = " .. waitingResponse)
    end
end

function BaseGameConnect:gc_AppEnterForeground()
    local playerInfoManager = self._gameController:getPlayerInfoManager()
    local utilsInfoManager  = self._gameController:getUtilsInfoManager()
    if not playerInfoManager or not utilsInfoManager then return end

    local waitingResponse = self._gameController:getResponse()
    if waitingResponse == self._gameController:getResWaitingNothing() then
        local MR_ENTER_FOREGROUND = BaseGameReq["ENTER_BKGFKG"]
        local data          = {
            nUserID         = playerInfoManager:getSelfUserID(),
            nRoomID         = utilsInfoManager:getRoomID(),
            nTableNO        = playerInfoManager:getSelfTableNO(),
            nChairNO        = playerInfoManager:getSelfChairNO()
        }
        local pData = treepack.alignpack(data, MR_ENTER_FOREGROUND)

        self:sendRequest(BaseGameDef.BASEGAME_MR_ENTER_FOREGROUND, pData, pData:len(), false)
        cc.exports.PUBLIC_INTERFACE.EnterForeground(
            utilsInfoManager:getRoomID(),
            playerInfoManager:getSelfTableNO(),
            playerInfoManager:getSelfChairNO()
        )

        --[[cc.exports.RoomServer_AppSwitchBackGroundForeGround('fore',
            utilsInfoManager:getRoomID(),
            playerInfoManager:getSelfTableNO(),
            playerInfoManager:getSelfChairNO())]]--
        print("GC_AppEnterForeground request sent")
    else
        print("GC_AppEnterForeground error, waitingResponse = " .. waitingResponse)
    end
end

--[[
function BaseGameConnect:gc_CheckVersion()
    local waitingResponse = self._gameController:getResponse()
    if waitingResponse == self._gameController:getResWaitingNothing() then
        local MR_GET_VERSION = BaseGameReq["GETVERSION"]

        local gameVersionName = ""
        if cc.PLATFORM_OS_IPHONE == targetPlatform then
            gameVersionName = "IPHONE"
        else
            gameVersionName = "AND"
        end
        local data          = {
            szExeName       = tostring(gameVersionName)
        }
        local pData = treepack.alignpack(data, MR_GET_VERSION)

        self:sendRequest(BaseGameDef.BASEGAME_MR_GET_VERSION, pData, pData:len(), true)
        self._gameController:setResponse(BaseGameDef.BASEGAME_WAITING_CHECK_VERSION)
        print("GC_CheckVersion request sent")
    else
        print("GC_CheckVersion error, waitingResponse = " .. waitingResponse)
    end
end
]]

function BaseGameConnect:gc_CheckVersion()
    local waitingResponse = self._gameController:getResponse()
    if waitingResponse == self._gameController:getResWaitingNothing() then
        local MR_CHECK_VERSION = BaseGameReq["CHECKVERSION"]

        local gameVersionName = ""
        local majorVer = 0
        local minorVer = 0
        local buildno = 0
        if device.platform == "ios" then
            gameVersionName = "IPHONE"
        else
            gameVersionName = "AND"
        end
        local gameVersion = my.getGameVersion()
        local splitArray = self._gameController:split(gameVersion, ".")
        if #splitArray == 3 then
            majorVer = tonumber(splitArray[1])
            minorVer = tonumber(splitArray[2])
            buildno = tonumber(splitArray[3])
        end

        local data          = {
            szExeName       = tostring(gameVersionName),
            nExeMajorVer    = majorVer,
            nExeMinorVer    = minorVer,
            nExeBuildno     = buildno
        }
        local pData = treepack.alignpack(data, MR_CHECK_VERSION)

        self:sendRequest(BaseGameDef.BASEGAME_MR_CHECK_VERSION, pData, pData:len(), true)
        self._gameController:setResponse(BaseGameDef.BASEGAME_WAITING_CHECK_VERSION)
        print("GC_CheckVersion request sent")
    else
        print("GC_CheckVersion error, waitingResponse = " .. waitingResponse)
    end
end

function BaseGameConnect:gc_EnterGame()
    local playerInfoManager = self._gameController:getPlayerInfoManager()
    local utilsInfoManager  = self._gameController:getUtilsInfoManager()
    local arenaInfoManager  = self._gameController:getArenaInfoManager()
    if not playerInfoManager or not utilsInfoManager or not arenaInfoManager then return end

    local waitingResponse = self._gameController:getResponse()
    if waitingResponse == self._gameController:getResWaitingNothing() then
        local GR_ENTER_GAME_EX = BaseGameReq["ENTER_GAME"]

        local data          = {
            nUserID         = playerInfoManager:getSelfUserID(),
            nUserType       = playerInfoManager:getSelfUserType(),
            nGameID         = utilsInfoManager:getGameID(),
            nRoomID         = utilsInfoManager:getRoomID(),
            nTableNO        = playerInfoManager:getSelfTableNO(),
            nChairNO        = playerInfoManager:getSelfChairNO(),
            szHardID        = utilsInfoManager:getHardID(),
            bLookOn         = utilsInfoManager:getLookOn(),
            nRoomTokenID    = utilsInfoManager:getRoomTokenID(),
            nMbNetType      = utilsInfoManager:getMbNetType(),
            nMatchID        = arenaInfoManager:isArenaPlayer() and arenaInfoManager:getMatchID() or 0,

            nUserID1        = playerInfoManager:getSelfUserID(),
            nUserType1      = playerInfoManager:getSelfUserType(),
            nStatus         = playerInfoManager:getSelfStatus(),
            nTableNO1       = playerInfoManager:getSelfTableNO(),
            nChairNO1       = playerInfoManager:getSelfChairNO(),
            nNickSex        = playerInfoManager:getSelfNickSex(),
            nPortrait       = playerInfoManager:getSelfPortrait(),
            nNetSpeed       = playerInfoManager:getSelfNetSpeed(),
            nClothingID     = playerInfoManager:getSelfClothingID(),
            szUserName      = playerInfoManager:getSelfUserName(),
            szNickName      = playerInfoManager:getSelfNickName(),
            nDeposit        = playerInfoManager:getSelfDeposit(),
            nPlayerLevel    = playerInfoManager:getSelfPlayerLevel(),
            nScore          = playerInfoManager:getSelfScore(),
            nBreakOff       = playerInfoManager:getSelfBreakOff(),
            nWin            = playerInfoManager:getSelfWin(),
            nLoss           = playerInfoManager:getSelfLoss(),
            nStandOff       = playerInfoManager:getSelfStandOff(),
            nBout           = playerInfoManager:getSelfBout(),
            nTimeCost       = playerInfoManager:getSelfTimeCost()
        }

        local pData = treepack.alignpack(data, GR_ENTER_GAME_EX)
        --dump(cc.exports.GetExtraConfigInfo().GameID)
        dump(data)
        self:sendRequest(BaseGameDef.BASEGAME_GR_ENTER_GAME, pData, pData:len(), true)
        self._gameController:setResponse(BaseGameDef.BASEGAME_WAITING_ENTER_GAME)
        print("GC_EnterGame request sent")
    else
        print("GC_EnterGame error, waitingResponse = " .. waitingResponse)
    end
end

function BaseGameConnect:gc_LeaveGame()
    local playerInfoManager = self._gameController:getPlayerInfoManager()
    local utilsInfoManager  = self._gameController:getUtilsInfoManager()
    if not playerInfoManager or not utilsInfoManager then return end

    local waitingResponse = self._gameController:getResponse()
    if waitingResponse == self._gameController:getResWaitingNothing() then
        local GR_LEAVE_GAME = BaseGameReq["LEAVE_GAME"]
        local data          = {
            nUserID         = playerInfoManager:getSelfUserID(),
            nRoomID         = utilsInfoManager:getRoomID(),
            nTableNO        = playerInfoManager:getSelfTableNO(),
            nChairNO        = playerInfoManager:getSelfChairNO(),
            nSendTable      = playerInfoManager:getSelfTableNO(),
            nSendChair      = playerInfoManager:getSelfChairNO(),
            nSendUser       = playerInfoManager:getSelfUserID(),
            szHardID        = utilsInfoManager:getHardID()
        }
        local pData = treepack.alignpack(data, GR_LEAVE_GAME)

        self:sendRequest(BaseGameDef.BASEGAME_GR_LEAVE_GAME, pData, pData:len(), true)
        self._gameController:setResponse(BaseGameDef.BASEGAME_WAITING_LEAVE_GAME)
        print("~~~~~~~~~~~~~~GC_LeaveGame request sent~~~~~~~~~~~~~~~~~~~~~~~~~~")
    else
        print("GC_LeaveGame error, waitingResponse = " .. waitingResponse)
    end
end

function BaseGameConnect:gc_LeaveGame_forChangetable()
    local playerInfoManager = self._gameController:getPlayerInfoManager()
    local utilsInfoManager  = self._gameController:getUtilsInfoManager()
    if not playerInfoManager or not utilsInfoManager then return end

    local GR_LEAVE_GAME = BaseGameReq["LEAVE_GAME"]
    local data          = {
        nUserID         = playerInfoManager:getSelfUserID(),
        nRoomID         = utilsInfoManager:getRoomID(),
        nTableNO        = playerInfoManager:getSelfTableNO(),
        nChairNO        = playerInfoManager:getSelfChairNO(),
        nSendTable      = playerInfoManager:getSelfTableNO(),
        nSendChair      = playerInfoManager:getSelfChairNO(),
        nSendUser       = playerInfoManager:getSelfUserID(),
        szHardID        = utilsInfoManager:getHardID()
    }
    local pData = treepack.alignpack(data, GR_LEAVE_GAME)

    print("gc_LeaveGame_forChangetable")
    dump(data, "LEAVE_GAME data")
    self:sendRequest(BaseGameDef.BASEGAME_GR_LEAVE_GAME, pData, pData:len(), true)
    self._gameController:setResponse(BaseGameDef.BASEGAME_WAITING_LEAVE_GAME_FOR_CHANGE)
end

function BaseGameConnect:gc_AskNewTableChair()
    local playerInfoManager = self._gameController:getPlayerInfoManager()
    local utilsInfoManager  = self._gameController:getUtilsInfoManager()
    if not playerInfoManager or not utilsInfoManager then return end

    local waitingResponse = self._gameController:getResponse()
    if waitingResponse == self._gameController:getResWaitingNothing() then
        local GR_ASK_NEW_TABLECHAIR = BaseGameReq["ASK_NEWTABLECHAIR"]
        local data          = {
            nUserID         = playerInfoManager:getSelfUserID(),
            nRoomID         = utilsInfoManager:getRoomID(),
            nTableNO        = playerInfoManager:getSelfTableNO(),
            nChairNO        = playerInfoManager:getSelfChairNO()
        }
        local pData = treepack.alignpack(data, GR_ASK_NEW_TABLECHAIR)

        self:sendRequest(BaseGameDef.BASEGAME_GR_ASK_NEW_TABLECHAIR, pData, pData:len(), true)
        self._gameController:setResponse(BaseGameDef.BASEGAME_WAITING_ASK_NEW_TABLE)
        print("GC_AskNewTableChair request sent")
    else
        print("GC_AskNewTableChair error, waitingResponse = " .. waitingResponse)
    end
end

function BaseGameConnect:gc_AskRandomTable()
    local playerInfoManager = self._gameController:getPlayerInfoManager()
    local utilsInfoManager  = self._gameController:getUtilsInfoManager()
    if not playerInfoManager or not utilsInfoManager then return end

    local waitingResponse = self._gameController:getResponse()
    if waitingResponse == self._gameController:getResWaitingNothing() then
        local GR_ASK_RANDOM_TABLE = BaseGameReq["ASK_NEWTABLECHAIR"]
        local data          = {
            nUserID         = playerInfoManager:getSelfUserID(),
            nRoomID         = utilsInfoManager:getRoomID(),
            nTableNO        = playerInfoManager:getSelfTableNO(),
            nChairNO        = playerInfoManager:getSelfChairNO()
        }
        local pData = treepack.alignpack(data, GR_ASK_RANDOM_TABLE)

        self:sendRequest(BaseGameDef.BASEGAME_GR_ASK_RANDOM_TABLE, pData, pData:len(), true)
        self._gameController:setResponse(BaseGameDef.BASEGAME_WAITING_ASK_RANDOM_TABLE)
        print("GC_AskRandomTable request sent")
    else
        print("GC_AskRandomTable error, waitingResponse = " .. waitingResponse)
    end
end

function BaseGameConnect:gc_GetTableInfo()
    local playerInfoManager = self._gameController:getPlayerInfoManager()
    local utilsInfoManager  = self._gameController:getUtilsInfoManager()
    if not playerInfoManager or not utilsInfoManager then return end

    local waitingResponse = self._gameController:getResponse()
    if waitingResponse == self._gameController:getResWaitingNothing() then
        local GR_GET_TABLE_INFO = BaseGameReq["GET_TABLE_INFO"]
        local data          = {
            nUserID         = playerInfoManager:getSelfUserID(),
            nRoomID         = utilsInfoManager:getRoomID(),
            nTableNO        = playerInfoManager:getSelfTableNO(),
            nChairNO        = playerInfoManager:getSelfChairNO()
        }
        local pData = treepack.alignpack(data, GR_GET_TABLE_INFO)

        self:sendRequest(BaseGameDef.BASEGAME_GR_GET_TABLE_INFO, pData, pData:len(), true)
        self._gameController:setResponse(BaseGameDef.BASEGAME_WAITING_GET_TABLE_INFO)

        --self._gameController:waitForGetTableDataResponse()   --获取桌面数据时加个自定义超时
        print("GC_GetTableInfo request sent")
    else
        print("GC_GetTableInfo error, waitingResponse = " .. waitingResponse)
    end
end

function BaseGameConnect:gc_StartGame()
    local playerInfoManager = self._gameController:getPlayerInfoManager()
    local utilsInfoManager  = self._gameController:getUtilsInfoManager()
    local arenaInfoManager  = self._gameController:getArenaInfoManager()
    if not playerInfoManager or not utilsInfoManager or not arenaInfoManager then return end

    local waitingResponse = self._gameController:getResponse()
    if waitingResponse == self._gameController:getResWaitingNothing() then
        local GR_START_GAME = BaseGameReq["START_GAME"]
        local data          = {
            nUserID         = playerInfoManager:getSelfUserID(),
            nRoomID         = utilsInfoManager:getRoomID(),
            nTableNO        = playerInfoManager:getSelfTableNO(),
            nChairNO        = playerInfoManager:getSelfChairNO(),
            nMatchID        = arenaInfoManager:isArenaPlayer() and arenaInfoManager:getMatchID() or 0
        }
        local pData = treepack.alignpack(data, GR_START_GAME)

        self:sendRequest(BaseGameDef.BASEGAME_GR_START_GAME, pData, pData:len(), true)
        self._gameController:setResponse(BaseGameDef.BASEGAME_WAITING_START_GAME)
        print("GC_StartGame request sent")
    else
        print("GC_StartGame error, waitingResponse = " .. waitingResponse)
    end
end

function BaseGameConnect:gc_StartTeamReady()
    local playerInfoManager = self._gameController:getPlayerInfoManager()
    local utilsInfoManager  = self._gameController:getUtilsInfoManager()
    if not playerInfoManager or not utilsInfoManager then return end

    local waitingResponse = self._gameController:getResponse()
    if waitingResponse == self._gameController:getResWaitingNothing() then
        local GR_START_TEAM_READY = BaseGameReq["START_TEAM_READY"]
        local data          = {
            nUserID         = playerInfoManager:getSelfUserID(),
            nRoomID         = utilsInfoManager:getRoomID(),
            nTableNO        = playerInfoManager:getSelfTableNO(),
            nChairNO        = playerInfoManager:getSelfChairNO()
        }
        local pData = treepack.alignpack(data, GR_START_TEAM_READY)

        self:sendRequest(BaseGameDef.BASEGAME_GR_START_TEAM_READY, pData, pData:len(), true)
        self._gameController:setResponse(BaseGameDef.BASEGAME_WAITING_START_TEAM_READY)
        print("GC_StartTeamReady request sent")
    else
        print("GC_StartTeamReady error, waitingResponse = " .. waitingResponse)
    end
end

function BaseGameConnect:gc_CancelTeamMatch()
    local playerInfoManager = self._gameController:getPlayerInfoManager()
    local utilsInfoManager  = self._gameController:getUtilsInfoManager()
    if not playerInfoManager or not utilsInfoManager then return end

    local waitingResponse = self._gameController:getResponse()
    if waitingResponse == self._gameController:getResWaitingNothing() then
        local GR_CANCEL_TEAM_MATCH_EX = BaseGameReq["CANCEL_TEAM_MATCH"]
        local data          = {
            nUserID         = playerInfoManager:getSelfUserID(),
            nRoomID         = utilsInfoManager:getRoomID(),
            nTableNO        = playerInfoManager:getSelfTableNO(),
            nChairNO        = playerInfoManager:getSelfChairNO()
        }
        local pData = treepack.alignpack(data, GR_CANCEL_TEAM_MATCH_EX)

        self:sendRequest(BaseGameDef.BASEGAME_GR_CANCEL_TEAM_MATCH_EX, pData, pData:len(), true)
        self._gameController:setResponse(BaseGameDef.BASEGAME_WAITING_CANCEL_TEAM_MATCH)
        print("gc_CancelTeamReady request sent")
    else
        print("gc_CancelTeamReady error, waitingResponse = " .. waitingResponse)
    end
end

function BaseGameConnect:gc_LookSafeDeposit()
    local playerInfoManager = self._gameController:getPlayerInfoManager()
    local utilsInfoManager  = self._gameController:getUtilsInfoManager()
    if not playerInfoManager or not utilsInfoManager then return end

    local waitingResponse = self._gameController:getResponse()
    if waitingResponse == self._gameController:getResWaitingNothing() then
        local GR_LOOK_SAFE_DEPOSIT = BaseGameReq["LOOK_SAFE_DEPOSIT"]
        local data          = {
            nUserID         = playerInfoManager:getSelfUserID(),
            nGameID         = utilsInfoManager:getGameID(),
            szHardID        = utilsInfoManager:getHardID()
        }
        local pData = treepack.alignpack(data, GR_LOOK_SAFE_DEPOSIT)

        local requestCode = BaseGameDef.BASEGAME_GR_LOOK_SAFE_DEPOSIT
        if cc.exports.isBackBoxSupported() then
            requestCode = BaseGameDef.BASEGAME_GR_LOOK_BACKDEPOSIT_INGAME
        end
        self:sendRequest(requestCode, pData, pData:len(), true)
        self._gameController:setResponse(BaseGameDef.BASEGAME_WAITING_LOOK_SAFE_DEPOSIT)
        print("GC_LookSafeDeposit request sent")
    else
        print("GC_LookSafeDeposit error, waitingResponse = " .. waitingResponse)
    end
end

function BaseGameConnect:gc_SaveDeposit(saveDeposit, gameDeposit)
    print("BaseGameConnect:gc_SaveDeposit saveDeposit "..tostring(saveDeposit))
    print("gameDeposit "..tostring(gameDeposit))
    local playerInfoManager = self._gameController:getPlayerInfoManager()
    local utilsInfoManager  = self._gameController:getUtilsInfoManager()
    if not playerInfoManager or not utilsInfoManager then return end

    local waitingResponse = self._gameController:getResponse()
    if waitingResponse == self._gameController:getResWaitingNothing() then
        local GR_SAVE_SAFE_DEPOSIT = BaseGameReq["TAKESAVE_SAFE_DEPOSIT"]
        local data          = {
            nUserID         = playerInfoManager:getSelfUserID(),
            nGameID         = utilsInfoManager:getGameID(),
            nRoomID         = utilsInfoManager:getRoomID(),
            nTableNO        = playerInfoManager:getSelfTableNO(),
            nChairNO        = playerInfoManager:getSelfChairNO(),
            nDeposit        = saveDeposit,
            nGameDeposit    = gameDeposit,
            dwFlags         = BaseGameDef.BASEGAME_FLAG_SUPPORT_KEEPDEPOSIT_EX,
            szHardID        = utilsInfoManager:getHardID()
        }
        local pData = treepack.alignpack(data, GR_SAVE_SAFE_DEPOSIT)

        local requestCode = BaseGameDef.BASEGAME_GR_SAVE_SAFE_DEPOSIT
        if cc.exports.isBackBoxSupported() then
            requestCode = BaseGameDef.BASEGAME_GR_SAVE_BACKDEPOSIT_INGAME
        end
        self:sendRequest(requestCode, pData, pData:len(), true)
        self._gameController:setResponse(BaseGameDef.BASEGAME_WAITING_SAVE_SAFE_DEPOSIT)
        print("GC_SaveSafeDeposit request sent")
    else
        print("GC_SaveSafeDeposit error, waitingResponse = " .. waitingResponse)
    end
end

function BaseGameConnect:gc_TakeDeposit(deposit, keyResult, gameDeposit)
    local playerInfoManager = self._gameController:getPlayerInfoManager()
    local utilsInfoManager  = self._gameController:getUtilsInfoManager()
    if not playerInfoManager or not utilsInfoManager then return end

    local waitingResponse = self._gameController:getResponse()
    if waitingResponse == self._gameController:getResWaitingNothing() then
        local GR_TAKE_SAFE_DEPOSIT = BaseGameReq["TAKESAVE_SAFE_DEPOSIT"]
        local data          = {
            nUserID         = playerInfoManager:getSelfUserID(),
            nGameID         = utilsInfoManager:getGameID(),
            nRoomID         = utilsInfoManager:getRoomID(),
            nTableNO        = playerInfoManager:getSelfTableNO(),
            nChairNO        = playerInfoManager:getSelfChairNO(),
            nDeposit        = deposit,
            nKeyResult      = keyResult,
            nGameDeposit    = gameDeposit,
            dwFlags         = BaseGameDef.BASEGAME_FLAG_SUPPORT_MONTHLY_LIMIT_EX,
            szHardID        = utilsInfoManager:getHardID()
        }
        local pData = treepack.alignpack(data, GR_TAKE_SAFE_DEPOSIT)

        local requestCode = BaseGameDef.BASEGAME_GR_TAKE_SAFE_DEPOSIT
        if cc.exports.isBackBoxSupported() then
            requestCode = BaseGameDef.BASEGAME_GR_TAKE_BACKDEPOSIT_INGAME
        end
        self:sendRequest(requestCode, pData, pData:len(), true)
        self._gameController:setResponse(BaseGameDef.BASEGAME_WAITING_TAKE_SAFE_DEPOSIT)
        print("GC_TakeSafeDeposit request sent")
    else
        print("GC_TakeSafeDeposit error, waitingResponse = " .. waitingResponse)
    end
end

function BaseGameConnect:gc_TakeRndKey()
    local playerInfoManager = self._gameController:getPlayerInfoManager()
    local utilsInfoManager  = self._gameController:getUtilsInfoManager()
    if not playerInfoManager or not utilsInfoManager then return end

    local waitingResponse = self._gameController:getResponse()
    if waitingResponse == self._gameController:getResWaitingNothing() then
        local GR_TAKE_SAFE_RNDKEY = BaseGameReq["LOOK_SAFE_DEPOSIT"]
        local data          = {
            nUserID         = playerInfoManager:getSelfUserID(),
            nGameID         = utilsInfoManager:getGameID(),
            szHardID        = utilsInfoManager:getHardID()
        }
        local pData = treepack.alignpack(data, GR_TAKE_SAFE_RNDKEY)

        self:sendRequest(BaseGameDef.BASEGAME_GR_TAKE_SAFE_RNDKEY, pData, pData:len(), true)
        self._gameController:setResponse(BaseGameDef.BASEGAME_WAITING_TAKE_SAFE_RNDKEY)
        print("GC_TakeSafeRndKey request sent")
    else
        print("GC_TakeSafeRndKey error, waitingResponse = " .. waitingResponse)
    end
end

function BaseGameConnect:gc_ChatToTable(content)
    local playerInfoManager = self._gameController:getPlayerInfoManager()
    local utilsInfoManager  = self._gameController:getUtilsInfoManager()
    if not playerInfoManager or not utilsInfoManager then return end

    if 60 < string.len(content) then
        content = string.sub(content, 1, 60)
    end

    local GR_CHATTOTABLE = BaseGameReq["CHAT_TO_TABLE"]
    local data          = {
        nUserID         = playerInfoManager:getSelfUserID(),
        nRoomID         = utilsInfoManager:getRoomID(),
        nTableNO        = playerInfoManager:getSelfTableNO(),
        nChairNO        = playerInfoManager:getSelfChairNO(),
        szHardID        = utilsInfoManager:getHardID(),
        szChatMsg       = content
    }
    local pData = treepack.alignpack(data, GR_CHATTOTABLE)

    self:sendRequest(BaseGameDef.BASEGAME_GR_CHAT_TO_TABLE, pData, pData:len(), false)
    print("GC_ChatToTable request sent")
end

function BaseGameConnect:gc_ChangeChair(toChairNO)
    local playerInfoManager = self._gameController:getPlayerInfoManager()
    local utilsInfoManager  = self._gameController:getUtilsInfoManager()
    if not playerInfoManager or not utilsInfoManager then return end

    local ASK_ONLY_CHANGE_CHAIR = BaseGameReq["ASK_ONLY_CHANGE_CHAIR"]
    local data          = {
        nUserID         = playerInfoManager:getSelfUserID(),
        nRoomID         = utilsInfoManager:getRoomID(),
        nTableNO        = playerInfoManager:getSelfTableNO(),
        nChairNO        = playerInfoManager:getSelfChairNO(),
        nToChairNO      = toChairNO,
    }
    local pData = treepack.alignpack(data, ASK_ONLY_CHANGE_CHAIR)

    self:sendRequest(BaseGameDef.BASEGAME_GR_ASK_ONLY_CHANGE_CHAIR, pData, pData:len(), false)
    print("gc_ChangeChair request sent")
end

function BaseGameConnect:gc_Tickoff(model,targetUserID,targetChairNO)
    local playerInfoManager = self._gameController:getPlayerInfoManager()
    local utilsInfoManager  = self._gameController:getUtilsInfoManager()
    if not playerInfoManager or not utilsInfoManager then return end

    local HOME_TICK_PLAYER = BaseGameReq["HOME_TICK_PLAYER"]
    local data          = {
        nUserID         = playerInfoManager:getSelfUserID(),
        nRoomID         = utilsInfoManager:getRoomID(),
        nTableNO        = playerInfoManager:getSelfTableNO(),
        nChairNO        = playerInfoManager:getSelfChairNO(),
        nTickModel      = model,
        nTargetUserID   = targetUserID,
        nTargetChairNO  = targetChairNO
    }
    local pData = treepack.alignpack(data, HOME_TICK_PLAYER)

    self:sendRequest(BaseGameDef.BASEGAME_GR_HOME_TICK_PLAYER, pData, pData:len(), false)
    print("gc_Tickoff request sent")
end

function BaseGameConnect:gc_sendSyncInfo()
    local playerInfoManager = self._gameController:getPlayerInfoManager()
    local utilsInfoManager  = self._gameController:getUtilsInfoManager()
    if not playerInfoManager or not utilsInfoManager then return end

    local imageCtrl = require('src.app.BaseModule.ImageCtrl')
    local t = imageCtrl:getPortraitCacheForGS()
    t.lbs=""

    local tcyFriendPlugin = plugin.AgentManager:getInstance():getTcyFriendPlugin()
    if tcyFriendPlugin then
          if(tcyFriendPlugin.getPositionInfo)then
               local positionInfo = tcyFriendPlugin:getPositionInfo()
               local info={}
               if positionInfo then
                        info["la"]=positionInfo.latitude
                        info["lo"]=positionInfo.longitude
                        info["po"]=positionInfo.provinceName
                        info["ci"]=positionInfo.cityName
                        info["di"]=positionInfo.districtName
                        info["st"]=positionInfo.streetName
                        info["bu"]=positionInfo.buidingName
                        local json = cc.load("json").json
                        local lbs = json.encode(info)
                        t.lbs=lbs
                        printf("~~~~~~~~~~gc_sendSyncInfo lbs lenth[%d] [%s]~~~~~~~~~~~~~~",string.len(t.lbs),t.lbs)
                else
                        printf("gc_sendSyncInfo positionInfo is nil")
                end
           end
    end

    local GR_SYNCH_SOCLALLY_INFO = BaseGameReq["GR_SYNCH_SOCLALLY_INFO"]
    local data          = {
        nUserID         = playerInfoManager:getSelfUserID(),
        nGameID         = utilsInfoManager:getGameID(),
        nRoomID         = utilsInfoManager:getRoomID(),
        nTableNO        = playerInfoManager:getSelfTableNO(),
        nChairNO        = playerInfoManager:getSelfChairNO(),
        szHeadUrl       = t.url,
        szLBSInfo       = t.lbs
    }
    local pData = treepack.alignpack(data, GR_SYNCH_SOCLALLY_INFO)

    self:sendRequest(BaseGameDef.BASEGAME_GR_SYNCH_SOCLALLY_INFO, pData, pData:len(), false)
    print("gc_sendSyncInfo request sent")

end


function BaseGameConnect:TeamGameRoom_LeaveGame()
    local playerInfoManager = self._gameController:getPlayerInfoManager()
    local utilsInfoManager  = self._gameController:getUtilsInfoManager()
    if not playerInfoManager or not utilsInfoManager then return end

    local waitingResponse = self._gameController:getResponse()
    if waitingResponse == self._gameController:getResWaitingNothing() then
        local GR_LEAVE_GAME = BaseGameReq["TEAM_GAME_ROOM_LEAVE_GAME"]
        local data          = {
            nUserID         = playerInfoManager:getSelfUserID(),
            nRoomID         = utilsInfoManager:getRoomID(),
            nTableNO        = playerInfoManager:getSelfTableNO(),
            nChairNO        = playerInfoManager:getSelfChairNO()
        }
        local pData = treepack.alignpack(data, GR_LEAVE_GAME)

        self:sendRequest(BaseGameDef.BASEGAME_MOBILE_REQ_BASE_EX, pData, pData:len(), true)
        self._gameController:setResponse(BaseGameDef.BASEGAME_WAITING_TEAM_ROOM_LEAVE_GAME)
        print("~~~~~~~~~~~~~~GC_LeaveGame request sent~~~~~~~~~~~~~~~~~~~~~~~~~~")
    else
        print("GC_LeaveGame error, waitingResponse = " .. waitingResponse)
    end
end


return BaseGameConnect
