local SubTeam2V2RoomManager = class("SubTeam2V2RoomManager")

local PlayerModel   = mymodel("hallext.PlayerModel"):getInstance()
local UserModel     = mymodel('UserModel'):getInstance()
local SettingsModel = mymodel("hallext.SettingsModel"):getInstance()
local HallContext   = import('src.app.plugins.mainpanel.HallContext'):getInstance()

local Team2V2Model          = import('src.app.plugins.Team2V2Model.Team2V2Model'):getInstance()
local Team2V2ModelDef       = require('src.app.plugins.Team2V2Model.Team2V2ModelDef')

function SubTeam2V2RoomManager:ctor(roomManager)
    self._mainCtrl = roomManager._mainCtrl
    self._roomManager = roomManager

    self._team2V2RoomContext = {
        ["lastTableNO"] = nil,
        ["lastHostID"] = nil,
        ["lastHostName"] = nil,
        ["enterTableCallback"] = nil
    }
    self._team2V2RoomContextOut = HallContext.context["teamRoomContext"]
end

function SubTeam2V2RoomManager:getSecondLayerTeam2V2()
    local secondLayer = self._roomManager._roomContext["secondLayer"]
    if secondLayer and secondLayer.layerName == "team2V2" then
        return secondLayer
    end

    return nil
end

function SubTeam2V2RoomManager:tryEnterTeam2V2Room(roomInfo, isDXXW)
    self._roomManager:_createRoomModel(roomInfo, "team2V2")
    local roomModel = self._roomManager._roomContextOut["roomModel"]
    if not roomModel then return end

    roomModel:enterRoom(function(respondType, enterRoom_dataMap)
        if respondType == mc.MR_ENTER_ROOM_OK or respondType == mc.ENTER_CLOAKINGROOM_OK then
            self._roomManager._roomContextOut["roomInfo"] = roomInfo
            self._roomManager._roomContextOut["enterRoomOk"] = enterRoom_dataMap[1]

            --老游戏模板需要这个
            table.merge(UserModel, enterRoom_dataMap[2])
            UserModel["nRoomID"] = roomInfo["nRoomID"]
            UserModel["szHardID"]= require("src.app.GameHall.models.DeviceModel"):getInstance().szHardID

            self._roomManager:_onEnterRoomSucceeded()
            if enterRoom_dataMap[2]["nTableNO"] == -1 or enterRoom_dataMap[2]["nChairNO"] == -1 then
                if Team2V2Model:isSelfLeader() then
                    self:createTeam2V2Table()
                end
            else
                self._roomManager._roomContextOut["tableInfo"] = {
                    nTableNO = enterRoom_dataMap[2]["nTableNO"],
                    nChairNO = enterRoom_dataMap[2]["nChairNO"]
                }
                self._roomManager:_tryEnterGame()
            end

            local NewInviteGiftModel = require('src.app.plugins.invitegift.NewInviteGiftModel'):getInstance()
            NewInviteGiftModel:reqConfig()

            local OldUserInviteGiftModel = require('src.app.plugins.invitegift.oldusergift.OldUserInviteGiftModel'):getInstance()
            OldUserInviteGiftModel:sendInviteGiftData()
        else
            my.stopProcessing()
            self._roomManager.roomManagerException:onEnterRoomFailed(respondType, enterRoom_dataMap, roomInfo["nRoomID"])
        end
        
        self._roomManager._roomContext["isEnteringRoom"] = false
    end)
end

function SubTeam2V2RoomManager:createTeam2V2Table(callback)
    local roomModel = self._roomManager._roomContextOut["roomModel"]
    if not roomModel then return end

    roomModel:createTeam2V2Room(function(respondType, dataMap)
        if respondType == mc.UR_OPERATE_SUCCEEDED then
            self._roomManager._roomContextOut["tableInfo"] = dataMap
            if not self._roomManager._roomContextOut["isEnteredGameScene"] then
                if Team2V2Model:isSelfLeader() then
                    Team2V2Model:onCreateTeam2V2RoomOK(self._roomManager._roomContextOut)
                end
                self._roomManager:_tryEnterGame()
            else
                if callback then callback(dataMap.nTableNO, dataMap.nChairNO) end
            end
            local NewInviteGiftModel = require('src.app.plugins.invitegift.NewInviteGiftModel'):getInstance()
            NewInviteGiftModel:reqConfig()

            local OldUserInviteGiftModel = require('src.app.plugins.invitegift.oldusergift.OldUserInviteGiftModel'):getInstance()
            OldUserInviteGiftModel:sendInviteGiftData()
        else
            self._roomManager.roomManagerException:onEnterRoomFailed(respondType, nil, roomModel._roomInfo["nRoomID"])
        end
    end)
end

function SubTeam2V2RoomManager:enterTeam2V2Table(tableNO, homeUserID, hostName, enterType, callback)
    printLog('SubTeam2V2RoomManager', 'enterTeam2V2Table')
    local enterType_map = {
        explore     = 0,
        system_find = 1,
        friend_find = 2,
        follow      = 3
    }
    print('++++++++++++++++++++++++++++++++++++++enterType'..enterType..'+++++++++++++++++++++')
    local enterGameFlag = enterType_map[enterType]
    self._team2V2RoomContext["lastTableNO"] = tableNO
    self._team2V2RoomContext["lastHostID"] = homeUserID
    self._team2V2RoomContext["lastHostName"] = hostName
    self._team2V2RoomContext["enterTableCallback"] = callback

    if enterGameFlag == 0 then
        self._team2V2RoomContext["lastHostName"] = hostName
    end

    local roomModel = self._roomManager._roomContextOut["roomModel"]
    if not roomModel then return end

    roomModel:enterTeam2V2Table(tableNO, homeUserID, enterGameFlag, handler(self, self._onEnterTable))
end

function SubTeam2V2RoomManager:_onEnterTable(respondType, dataMap)
    if respondType == mc.UR_OPERATE_SUCCEEDED then
        self._roomManager._roomContextOut["tableInfo"] = dataMap
        if not dataMap.nHomeUserID then
            self._roomManager._roomContextOut["tableInfo"]["nHomeUserID"] = self._team2V2RoomContext["lastHostID"]
        end
        if not self._roomManager._roomContext["isEnteredGameScene"] then
            self._roomManager:_tryEnterGame()

            local NewInviteGiftModel = require('src.app.plugins.invitegift.NewInviteGiftModel'):getInstance()
            NewInviteGiftModel:reqConfig()

            local OldUserInviteGiftModel = require('src.app.plugins.invitegift.oldusergift.OldUserInviteGiftModel'):getInstance()
            OldUserInviteGiftModel:sendInviteGiftData()
        else
            if self._team2V2RoomContext["enterTableCallback"] then 
                self._team2V2RoomContext["enterTableCallback"](dataMap.nTableNO, dataMap.nChairNO)
            end
        end
    else
        self:_onEnterTableFailed(respondType)
    end

    self._team2V2RoomContext["lastTableNO"] = nil
    self._team2V2RoomContext["lastHostID"] = nil
    self._team2V2RoomContext["lastHostName"] = nil
    self._team2V2RoomContext["enterTableCallback"] = nil
end

function SubTeam2V2RoomManager:_onEnterTableFailed(respondType)
    local reasonString = self._roomManager.roomManagerException:getStrByRespondType(respondType) or ""
    local function showGoToOtherRoomTip()
        local hostName = self._lastHostName or ""
        local hostID   = self._lastHostID or 0

        local failedReason = ''
        
        if respondType == mc.GR_FULL_PRIVATE_TABLE then
            failedReason = string.format('对不起，%s的房间已经满了哦', hostName)
        elseif respondType == mc.GR_FULL_PRIVATE_TABLE_READY then
            failedReason = string.format('对不起，%s的房间已经满了哦', hostName)
        elseif respondType == mc.GR_NOBODY_PRIVATE_TABLE then
            failedReason = '对不起，房间已经散了哦'
        elseif respondType == mc.GR_FULL_PRIVATE_TABLE_PLAYING then
            failedReason = string.format('对不起，玩家%s的队伍已经开始游戏了', hostName)
        elseif respondType == mc.UR_PRIVATE_TABLE_LOCKED then
            failedReason = string.format('对不起，玩家%s的房间已经上锁', hostName)
        end
        self._roomManager:_showTip(failedReason)
    end
    local errorHandlerMap = {
        [mc.GR_FULL_PRIVATE_TABLE]          = showGoToOtherRoomTip,
        [mc.GR_FULL_PRIVATE_TABLE_READY]    = showGoToOtherRoomTip,
        [mc.GR_NOBODY_PRIVATE_TABLE]        = showGoToOtherRoomTip,
        [mc.GR_FULL_PRIVATE_TABLE_PLAYING]  = showGoToOtherRoomTip,
        [mc.UR_PRIVATE_TABLE_LOCKED]        = showGoToOtherRoomTip
    }
    if errorHandlerMap[respondType] then
        errorHandlerMap[respondType]()
    elseif  reasonString and reasonString ~= '' then
        self._roomManager:_showTip(reasonString)
    end
end

function SubTeam2V2RoomManager:onLeaderStartMatch()

    local teamInfo = Team2V2Model:getTeamInfo()
    local realTeamInfo = teamInfo.realTeamInfo
    if realTeamInfo == nil or realTeamInfo.tableNO == nil or realTeamInfo.tableNO < 0 then
        return
    end
    
    if self._roomManager._roomContextOut["tableInfo"] and realTeamInfo.tableNO == self._roomManager._roomContextOut["tableInfo"]["nTableNO"] then
        self._roomManager:_showTip("您已经在此房间中~")
        return
    end

    self._team2V2RoomContextOut["enterTeamInfo"] = {
        hostName = teamInfo.leaderUserName,
        hostID = teamInfo.leaderUserID,
        roomID = realTeamInfo.roomID,
        tableNO = realTeamInfo.tableNO,
        enterType = "explore"
    }
    
    UserModel.hostName = self._team2V2RoomContextOut["enterTeamInfo"]["hostName"]
    UserModel.hostID = self._team2V2RoomContextOut["enterTeamInfo"]["hostID"]
    UserModel.applyRoomId = self._team2V2RoomContextOut["enterTeamInfo"]["roomID"]
    UserModel.applyTableId = self._team2V2RoomContextOut["enterTeamInfo"]["tableNO"]

    self:_tryEnterTeamByLeaderStartMatch()
end

function SubTeam2V2RoomManager:_tryEnterTeamByLeaderStartMatch()
    if self:_doGoBackToHallWhenLeaderStartMatchInGame() == true then
        print("_doGoBackToHallWhenLeaderStartMatchInGame")
    elseif self:_doEnterTeam2V2TableWhenEnteredRoom() == true then
        print("_doEnterTeam2V2TableWhenEnteredRoom")
    else
        self:_doEnterTeam2V2RoomWhenLeaderStartMatchInHall()
    end
end

function SubTeam2V2RoomManager:_doGoBackToHallWhenLeaderStartMatchInGame()
    if self._roomManager._roomContextOut["isEnteredGameScene"] == true then
        self._team2V2RoomContextOut["readyToFollowOnBackFromGame"] = true
        GamePublicInterface:quitDirect()
        return true
    end

    return false
end

function SubTeam2V2RoomManager:_doEnterTeam2V2TableWhenEnteredRoom()
    local curRoomInfo = self._roomManager._roomContextOut["roomInfo"]
    local curRoomModel = self._roomManager._roomContextOut["roomModel"]

    if curRoomModel == nil then
        return false --说明没有进入好友房的房间，所以无法执行“进桌子”流程，需要先进房间
    end
    if curRoomInfo and (curRoomInfo["isTeam2V2"] ~= true or self._roomManager._roomContextOut["areaEntry"] ~= "team2V2") then
        return false --当前在非好友房界面，说明没有进入好友房的房间，所以无法执行“进桌子”流程，需要先进房间
    end

    local enterTeamInfo = self._team2V2RoomContextOut["enterTeamInfo"]
    if curRoomInfo and curRoomInfo["nRoomID"] == enterTeamInfo["roomID"] then
        self:enterTeam2V2Table(enterTeamInfo.tableNO, enterTeamInfo.hostID, enterTeamInfo.hostName, enterTeamInfo.enterType)

        print("SubTeam2V2RoomManager:_doEnterTeam2V2TableWhenEnteredRoom true")
        return true
    end

    return false
end

function SubTeam2V2RoomManager:_doEnterTeam2V2RoomWhenLeaderStartMatchInHall()
    print("SubTeam2V2RoomManager:_doEnterTeam2V2RoomWhenLeaderStartMatchInHall")

    print("SubTeam2V2RoomManager:_doEnterTeam2V2RoomWhenLeaderStartMatchInHall and doLeaveCurrentRoom")
    self._roomManager:doLeaveCurrentRoom() --在进新房间前，先离开当前房间

    self._roomManager._roomContextOut["areaEntry"] = "team2V2"
    local enterTeamInfo = self._team2V2RoomContextOut["enterTeamInfo"]
    self._roomManager:tryEnterRoom(enterTeamInfo.roomID, false, function()
        if enterTeamInfo.tableNO and enterTeamInfo.tableNO > 0 then
            self:enterTeam2V2Table(enterTeamInfo.tableNO, enterTeamInfo.hostID, enterTeamInfo.hostName, enterTeamInfo.enterType)
            return
        end

        --aaaa需要测试
        local roomModel = self._roomManager._roomContextOut["roomModel"]
        if not roomModel then return end

        roomModel:findPlayer(enterTeamInfo.roomID, enterTeamInfo.hostID, function(respondType, tableNOInner)
            if not tableNOInner or tableNOInner < 0 then
                local formatString = self._roomManager.roomManagerException:getStrByRespondType(respondType)
                if not formatString then
                    formatString = self._roomManager._roomStrings["FOLLOW_TARGET_OFFTABLE"]
                end
                local failedReason = string.format(formatString, enterTeamInfo.hostName or '')
                self._roomManager:_showTip(failedReason)
                return
            end

            self:enterTeam2V2Table(tableNOInner, enterTeamInfo.hostID, enterTeamInfo.hostName, enterTeamInfo.enterType)
        end)
    end)
end

function SubTeam2V2RoomManager:dealOnBackFromGame()
    local layerTeam2V2 = self:getSecondLayerTeam2V2()
    if layerTeam2V2 then
        layerTeam2V2:refreshView()
        return true
    end

    return false
end

function SubTeam2V2RoomManager:onKeyback()
    local layerTeam2V2 = self:getSecondLayerTeam2V2()
    if layerTeam2V2 then
        layerTeam2V2:onKeyback()
        return true
    end
    return false
end

function SubTeam2V2RoomManager:dealOnClose()
end

function SubTeam2V2RoomManager:tryEnterTableWhenEnteredRoom()
    print("TeamTableListLayer:_onClickBtnEnterTable")

    if not UIHelper:checkOpeCycle("TeamTableListLayer_onClickBtnEnterTable") then
        return
    end
    UIHelper:refreshOpeBegin("TeamTableListLayer_onClickBtnEnterTable")

    local roomInfo = self._roomManager._roomContextOut["roomInfo"]
    local tableInfo = tableViewData["tableInfo"]

    self._teamRoomManager._teamRoomContextOut["enterTeamInfo"] = {
        hostName = tableInfo["szUserName"],
		hostID = tableInfo["nHomeUserID"],
		roomID = roomInfo["nRoomID"],
		tableNO = tableInfo["nTableId"],
        enterType = "friend_find"
    }
    --兼容游戏内CharteredRoom
    UserModel.hostName = self._teamRoomManager._teamRoomContextOut["enterTeamInfo"]["hostName"]
    UserModel.hostID = self._teamRoomManager._teamRoomContextOut["enterTeamInfo"]["hostID"]
    UserModel.applyRoomId = self._teamRoomManager._teamRoomContextOut["enterTeamInfo"]["roomID"]
    UserModel.applyTableId = self._teamRoomManager._teamRoomContextOut["enterTeamInfo"]["tableNO"]

    self._teamRoomManager._teamRoomContextOut["enterTeamInfo"]["enterType"] = "expore"
    self._teamRoomManager:_doEnterTeam2V2TableWhenEnteredRoom()
end

return SubTeam2V2RoomManager