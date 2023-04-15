
cc.exports.PUBLIC_INTERFACE={}

--[[local function getRoomManager()
    return require("src.app.GameHall.room.ctrl.RoomManager"):getInstance()
end]]--

local function getHallContext()
    return require("src.app.plugins.mainpanel.HallContext"):getInstance()
end

local function getRoomListModel()
    local RoomListModel = import("src.app.GameHall.room.model.RoomListModel"):getInstance()
    return RoomListModel
end

function cc.exports.PUBLIC_INTERFACE.GetTableInfo()
    --[[local tableInfo = getRoomManager():getTableInfo()
    return tableInfo]]--
    return getHallContext().context["roomContext"]["tableInfo"]
end

function cc.exports.PUBLIC_INTERFACE.GetEnterRoomOk()
    --return getRoomManager():getEnterRoomOk()
    return getHallContext().context["roomContext"]["enterRoomOk"]
end

function cc.exports.PUBLIC_INTERFACE.GetCurrentRoomInfo()
    --return getRoomManager():getCurrentRoomInfo()
    return getHallContext().context["roomContext"]["roomInfo"]
end

function cc.exports.PUBLIC_INTERFACE.GetCurrentAreaEntry()
    return getHallContext().context["roomContext"]["areaEntry"]
end

function cc.exports.PUBLIC_INTERFACE.GetEnterTeamInfo()
    return getHallContext().context["teamRoomContext"]["enterTeamInfo"]
end

function cc.exports.PUBLIC_INTERFACE.SetHostIdOfEnterTeamInfo(hostId)
    local enterTeamInfo = getHallContext().context["teamRoomContext"]["enterTeamInfo"]
    if enterTeamInfo then
        enterTeamInfo.hostID = hostId
        return true
    else
        print("call PUBLIC_INTERFACE.SetHostIDOfEnterTeamInfo, but enterTeamInfo is nil")
    end

    return false
end

function cc.exports.PUBLIC_INTERFACE.GetHostIdOfEnterTeamInfo()
    local enterTeamInfo = getHallContext().context["teamRoomContext"]["enterTeamInfo"]
    if enterTeamInfo then
        return enterTeamInfo.hostID
    else
        print("call PUBLIC_INTERFACE.GetHostIdOfEnterTeamInfo, but enterTeamInfo is nil")
    end

    return nil
end

function cc.exports.PUBLIC_INTERFACE.isEnterRoomByTeamEntry()
    local roomContext = getHallContext().context["roomContext"]
    if roomContext and roomContext["roomInfo"] and roomContext["roomInfo"]["isTeamRoom"] then
        if roomContext["areaEntry"] == "team" then
            return true
        end
    end

    return false
end

function cc.exports.PUBLIC_INTERFACE.LockTable(params, callback)
    local roomContext = getHallContext().context["roomContext"]
    if roomContext["roomModel"] and roomContext["roomModel"].modelName == "team" then
        return roomContext["roomModel"]:lockTable(params, callback)
    else
        print("call cc.exports.PUBLIC_INTERFACE.LockTable, but roomModel is nil")
    end
end 

function cc.exports.PUBLIC_INTERFACE.UnLockTable(params, callback)
    local roomContext = getHallContext().context["roomContext"]
    if roomContext["roomModel"] and roomContext["roomModel"].modelName == "team" then
        return roomContext["roomModel"]:unLockTable(params, callback)
    else
        print("call cc.exports.PUBLIC_INTERFACE.UnLockTable, but roomModel is nil")
    end
end

function cc.exports.PUBLIC_INTERFACE.GetFinished(params)
    local roomContext = getHallContext().context["roomContext"]
    if roomContext["roomModel"] then
        return roomContext["roomModel"]:getFinished(params)
    else
        print("call cc.exports.PUBLIC_INTERFACE.GetFinished, but roomModel is nil")
    end
end 

function cc.exports.PUBLIC_INTERFACE.SendUpSeat(params)
    local roomContext = getHallContext().context["roomContext"]
    if roomContext["roomModel"] and roomContext["roomModel"].modelName == "team" then
        return roomContext["roomModel"]:standUpSeat(params)
    else
        print("call cc.exports.PUBLIC_INTERFACE.SendUpSeat, but roomModel is nil")
    end
end

function cc.exports.PUBLIC_INTERFACE.SystemFind(params)
    local roomContext = getHallContext().context["roomContext"]
    if roomContext["roomModel"] and roomContext["roomModel"].modelName == "team" then
        return roomContext["roomModel"]:systemFind(params)
    else
        print("call cc.exports.PUBLIC_INTERFACE.SystemFind, but roomModel is nil")
    end
end

function cc.exports.PUBLIC_INTERFACE.EnterBackGround(nRoomID, nTableNO, nChairNO)
    local roomContext = getHallContext().context["roomContext"]
    if roomContext["roomModel"] then
        return roomContext["roomModel"]:enterBackground(nRoomID, nTableNO, nChairNO)
    else
        print("call cc.exports.PUBLIC_INTERFACE.EnterBackGround, but roomModel is nil")
    end
end

function cc.exports.PUBLIC_INTERFACE.EnterForeground(nRoomID, nTableNO, nChairNO)
    local roomContext = getHallContext().context["roomContext"]
    if roomContext["roomModel"] then
        return roomContext["roomModel"]:enterForeground(nRoomID, nTableNO, nChairNO)
    else
        print("call cc.exports.PUBLIC_INTERFACE.EnterForeground, but roomModel is nil")
    end
end

function cc.exports.PUBLIC_INTERFACE.ChangeTableAndEnter(roomID, callback)
    local roomContext = getHallContext().context["roomContext"]
    if roomContext["roomModel"] and roomContext["roomModel"].modelName == "team" then
        return roomContext["roomModel"]:tryGoToOtherRoom(roomID, callback)
    else
        print("call cc.exports.PUBLIC_INTERFACE.ChangeTableAndEnter, but roomModel is nil")
    end
end

--[[function cc.exports.PUBLIC_INTERFACE.showTeamRoomOnDXXW()
    getRoomManager():showTeamRoomOnDXXW()
end]]--

function cc.exports.PUBLIC_INTERFACE.GoBackToMainScene()
    print("cc.exports.PUBLIC_INTERFACE.GoBackToMainScene")

    local player = mymodel('hallext.PlayerModel'):getInstance()
    player:update({'UserGameInfo'})

    cc.exports.hasStartGame = false
    printLog('PUBLIC_INTERFACE', 'GoBackToMainScene')
    my.informPluginByName({params={message='remove'}})
    audio.playMusic(cc.FileUtils:getInstance():fullPathForFilename('res/Game/GameSound/BGMusic/BG.mp3'),true)

    local HallContext = import('src.app.plugins.mainpanel.HallContext'):getInstance()
    HallContext:dispatchEvent({name = HallContext.EVENT_MAP["gameScene_goBackToMainScene"]})
end

function cc.exports.PUBLIC_INTERFACE.GoBackToMainSceneWithVersion()
    print("cc.exports.PUBLIC_INTERFACE.GoBackToMainSceneWithVersion")

    cc.exports.hasStartGame = false

    local HallContext = import('src.app.plugins.mainpanel.HallContext'):getInstance()
    HallContext:dispatchEvent({name = HallContext.EVENT_MAP["gameScene_goBackToMainScene"]})

    local centerCtrl = require('src.app.BaseModule.CenterCtrl'):getInstance()
    centerCtrl:runUpdate()
    my.informPluginByName({params={message='remove'}})
end

function cc.exports.PUBLIC_INTERFACE.GetGameShortName()
    return my.getGameShortName()
end

--[[function cc.exports.PUBLIC_INTERFACE.GetGameVersion()
    return my.getGameVersion()
end

function cc.exports.PUBLIC_INTERFACE.GetGameID()
    return my.getGameID()
end]]--

function cc.exports.PUBLIC_INTERFACE.GetGameServerIp()
    local curRoomInfo = cc.exports.PUBLIC_INTERFACE.GetCurrentRoomInfo()
    if curRoomInfo then
        return curRoomInfo.szGameIP
    else
        print("call PUBLIC_INTERFACE.GetGameServerIp, but roomInfo is nil!!!")
    end
end

function cc.exports.PUBLIC_INTERFACE.GetGameServerPort()
    local curRoomInfo = cc.exports.PUBLIC_INTERFACE.GetCurrentRoomInfo()
    if curRoomInfo then
        return curRoomInfo.nGamePort + 20000
    else
        print("call PUBLIC_INTERFACE.GetGameServerPort, but roomInfo is nil!!!")
    end
end


function cc.exports.PUBLIC_INTERFACE.GetPlayerInfo()
    return mymodel('UserModel'):getInstance()
end

function cc.exports.PUBLIC_INTERFACE.GetDeviceModel()
    return  mymodel('DeviceModel'):getInstance()
end

function cc.exports.PUBLIC_INTERFACE.GetPlayer()
    return mymodel('hallext.PlayerModel'):getInstance()
end

function cc.exports.PUBLIC_INTERFACE.AddStranger(param)
	return my.AddStranger(param)
end

function cc.exports.PUBLIC_INTERFACE.DeleteStranger(userId)
	return my.DeleteStranger(userId)
end

function cc.exports.PUBLIC_INTERFACE.GetAllStranger()
	return my.GetAllStranger()
end

function cc.exports.PUBLIC_INTERFACE.GetTcyFriendPluginWrapper()
    return mymodel("PluginEventHandler.TcyFriendPlugin"):getInstance()
end

--[[function cc.exports.PUBLIC_INTERFACE.GetTableCondition()
    return getRoomManager():getCurrentTableCondition()
end]]--

function cc.exports.PUBLIC_INTERFACE.GetAudioChat()
    return cc.exports.AudioChat
end

function cc.exports.PUBLIC_INTERFACE.GetLauchParamsManager()
    return cc.exports.launchParamsManager
end

--[Comment]
--data = {
--    {userID = 123, url = adsfasd}, {userID = 1231, url = adsfasd1}
--}
--callback(usersTable)
--usersTable = {
--    [123] = {userID = 123, path = "asdf", size = "60-60"}
--}
function cc.exports.PUBLIC_INTERFACE.GetImagesForGame(data, sizeWanted, callback, tag)
    local ImageCtrl = require('src.app.BaseModule.ImageCtrl')
    ImageCtrl:getImageForGameScene(data, sizeWanted, callback, tag)
end

function cc.exports.PUBLIC_INTERFACE.GetLbsInfo()
    return mymodel('hallext.LbsModel'):getInstance():getLbsInfo()
end
function cc.exports.PUBLIC_INTERFACE.CheckHallLoginInGame(onLoginOK)
    local netProcess = require('src.app.BaseModule.NetProcess'):getInstance()
    netProcess:checkHallLoginInGame(onLoginOK)
end

function cc.exports.PUBLIC_INTERFACE.DisconnectHallSvr()
    local mclient = mc.createClient()
    return mclient:dispatchSocketError("hall")
end

function cc.exports.PUBLIC_INTERFACE.OnArenaDXXW()
    local roomContext = getHallContext().context["roomContext"]
    local curRoomInfo = roomContext["roomInfo"]
    if curRoomInfo and curRoomInfo["isArenaRoom"] == true then
        roomContext["areaEntry"] = "arena"
    end
end

function cc.exports.PUBLIC_INTERFACE.IsStartAsArenaPlayer(roomInfoToEnter)
    local roomContext = getHallContext().context["roomContext"]
    if roomContext["areaEntry"] == "arena" then
        if roomInfoToEnter ~= nil and roomInfoToEnter["isArenaRoom"] == true then
            return true
        else
            local curRoomInfo = roomContext["roomInfo"]
            if curRoomInfo and curRoomInfo["isArenaRoom"] == false then
                return false
            else
                return true
            end
        end
    end

    return false
end

function cc.exports.PUBLIC_INTERFACE.onNoShuffleRoomDXXW()
    local roomContext = getHallContext().context["roomContext"]
    local curRoomInfo = roomContext["roomInfo"]
    if curRoomInfo and curRoomInfo["isNoShuffleRoom"] == true then
        roomContext["areaEntry"] = "noshuffle"
    end
end

function cc.exports.PUBLIC_INTERFACE.IsStartAsNoShuffle(roomInfoToEnter)
    local roomContext = getHallContext().context["roomContext"]
    if roomContext["areaEntry"] == "noshuffle" then
        if roomInfoToEnter ~= nil and roomInfoToEnter["isNoShuffleRoom"] == true then
            return true
        else
            local curRoomInfo = roomContext["roomInfo"]
            if curRoomInfo and curRoomInfo["isNoShuffleRoom"] or curRoomInfo["isGuideRoom"] then
                return true
            else
                return false
            end
        end
    end

    return false
end

function cc.exports.PUBLIC_INTERFACE.onNoJiSuRoomDXXW()
    local roomContext = getHallContext().context["roomContext"]
    local curRoomInfo = roomContext["roomInfo"]
    if curRoomInfo and curRoomInfo["isJiSuRoom"] == true then
        roomContext["areaEntry"] = "jisu"
    end
end

function cc.exports.PUBLIC_INTERFACE.IsStartAsJiSu(roomInfoToEnter)
    local roomContext = getHallContext().context["roomContext"]
    if roomContext["areaEntry"] == "jisu" then
        if roomInfoToEnter ~= nil and roomInfoToEnter["isJiSuRoom"] == true then
            return true
        else
            local curRoomInfo = roomContext["roomInfo"]
            if curRoomInfo and curRoomInfo["isJiSuRoom"] == false then
                return false
            else
                return true
            end
        end
    end

    return false
end

function cc.exports.PUBLIC_INTERFACE.OnTimingDXXW()
    local roomContext = getHallContext().context["roomContext"]
    local curRoomInfo = roomContext["roomInfo"]
    if curRoomInfo and curRoomInfo["isTimingRoom"] == true then
        roomContext["areaEntry"] = "timing"
    end
end

function cc.exports.PUBLIC_INTERFACE.IsStartAsTimingGame(roomInfoToEnter)
    local roomContext = getHallContext().context["roomContext"]
    if roomContext["areaEntry"] == "timing" or roomContext["areaEntry"] == "timingMiddle" then
        if roomInfoToEnter ~= nil and roomInfoToEnter["isTimingRoom"] == true then
            return true
        end
    end
    local curRoomInfo = roomContext["roomInfo"]
    if curRoomInfo and (curRoomInfo["isTimingRoom"] == false
    or not curRoomInfo["isTimingRoom"]) then
        return false
    else
        return true
    end

    return false
end

-- 移动端选桌：begin
function cc.exports.PUBLIC_INTERFACE.OnAnchorMatchDXXW()
    local roomContext = getHallContext().context["roomContext"]
    local curRoomInfo = roomContext["roomInfo"]
    if curRoomInfo and curRoomInfo["isAnchorMatch"] == true then
        roomContext["areaEntry"] = "anchorMatch"
    end
end

function cc.exports.PUBLIC_INTERFACE.IsStartAsAnchorMatchGame(roomInfoToEnter)
    local roomContext = getHallContext().context["roomContext"]
    if roomContext["areaEntry"] == "anchorMatch" then
        if roomInfoToEnter ~= nil and roomInfoToEnter["isAnchorMatch"] == true then
            return true
        end
    end
    local curRoomInfo = roomContext["roomInfo"]
    if curRoomInfo and (curRoomInfo["isAnchorMatch"] == false
    or not curRoomInfo["isAnchorMatch"]) then
        return false
    else
        return true
    end

    return false
end
-- 移动端选桌：end

function cc.exports.PUBLIC_INTERFACE.onFriendRoomDXXW()
    local roomContext = getHallContext().context["roomContext"]
    local curRoomInfo = roomContext["roomInfo"]
    if curRoomInfo and curRoomInfo["isTeamRoom"] == true then
        roomContext["areaEntry"] = "team"
    end
end

function cc.exports.PUBLIC_INTERFACE.IsStartAsFriendRoom(roomInfoToEnter)
    local roomContext = getHallContext().context["roomContext"]
    if roomContext["areaEntry"] == "team" then
        if roomInfoToEnter ~= nil and roomInfoToEnter["isTeamRoom"] == true then
            return true
        else
            local curRoomInfo = roomContext["roomInfo"]
            if curRoomInfo and curRoomInfo["isTeamRoom"] == false then
                return false
            else
                return true
            end
        end
    end

    return false
end

function cc.exports.PUBLIC_INTERFACE.IsStartAsTeam2V2(roomInfoToEnter)
    local roomContext = getHallContext().context["roomContext"]
    if roomContext["areaEntry"] == "team2V2" then
        if roomInfoToEnter ~= nil and roomInfoToEnter["isTeam2V2"] == true then
            return true
        else
            local curRoomInfo = roomContext["roomInfo"]
            if curRoomInfo and curRoomInfo["isTeam2V2"] == false then
                return false
            else
                return true
            end
        end
    end

    return false
end

function cc.exports.PUBLIC_INTERFACE.getGameStringToUTF8ByKey(stringKey)
    local content = ""
    if cc.exports.GamePublicInterface then
        content =  cc.exports.GamePublicInterface:getGameString(stringKey)
    end
    local utf8Content = MCCharset:getInstance():gb2Utf8String(content, string.len(content))
    return utf8Content
end