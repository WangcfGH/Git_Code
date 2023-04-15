local SubTeamRoomManager = class("SubTeamRoomManager")

local PlayerModel   = mymodel("hallext.PlayerModel"):getInstance()
local UserModel     = mymodel('UserModel'):getInstance()
local SettingsModel = mymodel("hallext.SettingsModel"):getInstance()
local HallContext = import('src.app.plugins.mainpanel.HallContext'):getInstance()

function SubTeamRoomManager:ctor(roomManager)
    self._mainCtrl = roomManager._mainCtrl
    self._roomManager = roomManager

    self._teamRoomContext = {
        ["lastTableNO"] = nil,
        ["lastHostID"] = nil,
        ["lastHostName"] = nil,
        ["enterTableCallback"] = nil
    }
    self._teamRoomContextOut = HallContext.context["teamRoomContext"]
end

function SubTeamRoomManager:getSecondLayerTeam()
    local secondLayer = self._roomManager._roomContext["secondLayer"]
    if secondLayer and secondLayer.layerName == "team" then
        return secondLayer
    end

    return nil
end

function SubTeamRoomManager:getTableListLayer()
    local secondLayer = self:getSecondLayerTeam()
    if secondLayer then
        return secondLayer.subTeamTableList
    end

    return nil
end

function SubTeamRoomManager:closeTeamTableListLayer()
    if self:getTableListLayer() then
        self:getTableListLayer():showView(false)
        print("SubTeamRoomManager:closeTeamTableListLayer and doLeaveCurrentRoom")
        self._roomManager:doLeaveCurrentRoom()
    end
end

function SubTeamRoomManager:addRoomEventListeners()
    local roomModel = self._roomManager._roomContextOut["roomModel"]
    if roomModel then
        self._mainCtrl:listenTo(roomModel, roomModel.EVENT_MAP["baseRoomModel_recieveInvitation"], handler(self, self.onRecieveInvitation))
    end
end

function SubTeamRoomManager:tryEnterTeamRoom(roomInfo, isDXXW)
    self._roomManager:_createRoomModel(roomInfo, "team")
    local roomModel = self._roomManager._roomContextOut["roomModel"]
    if not roomModel then return end

    roomModel:enterRoom(function(respondType, enterRoom_dataMap)
        if respondType == mc.MR_ENTER_ROOM_OK or respondType == mc.ENTER_CLOAKINGROOM_OK then
            self._roomManager._roomContextOut["roomInfo"] = roomInfo
            self._roomManager._roomContextOut["enterRoomOk"] = enterRoom_dataMap[1]
            --self._isEnteredAsTeamRoom = true
            --self._currentViewMode   = self.ViewMode.ROOM_TEAM

            --老游戏模板需要这个
            table.merge(UserModel, enterRoom_dataMap[2])
            UserModel["nRoomID"] = roomInfo["nRoomID"]
            UserModel["szHardID"]= require("src.app.GameHall.models.DeviceModel"):getInstance().szHardID

            self._roomManager:_onEnterRoomSucceeded()
            if enterRoom_dataMap[2]["nTableNO"] == -1 or enterRoom_dataMap[2]["nChairNO"] == -1 then
                --self._roomListCtrl:removeRoomList()
                --self:_showTeamRoom()
                --if isTableListAquired then
                    --self:_aquireTableList()
                --end

                if self:getTableListLayer() and self:getTableListLayer():isViewVisible() == true then
                    self:_aquireTableList()
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

function SubTeamRoomManager:_aquireTableList()
    if self:_checkRoomModel() == false then
        return
    end
    local roomModel = self._roomManager._roomContextOut["roomModel"]
    if not roomModel then return end

    roomModel:getTableList(3, function(reqType, respondType, dataMap)
        if respondType ~= mc.UR_OPERATE_SUCCEEDED then
            print("SubTeamRoomManager:_aquireTableList, getTableList failed!!!")
            return
        end

        if not self:getTableListLayer() then
            print("SubTeamRoomManager:_aquireTableList tableList got but tableListLayer is nil")
            return
        end

        if reqType == "tableList" then
            self:getTableListLayer():showTables(dataMap[2], dataMap[1])
        elseif reqType == "tableDetail" then
            self:getTableListLayer():setTableDetail(dataMap)
        elseif reqType == "finished" then
            printLog("portrait", "finished")
            self:getTableListLayer():onTableAquireFinished()
        end
    end)
end

--如果RoomModel因为某些异常不存在了，则TableListLayer必定无法正常运行，做“自动关闭TableListLayer”处理
function SubTeamRoomManager:_checkRoomModel()
    if self._roomManager._roomContextOut["roomModel"] ~= nil then
        return true
    end

    print("SubTeamRoomManager:_checkRoomModel, roomModel is nil and closeTeamTableListLayer")

    self:closeTeamTableListLayer()
    my.stopProcessing()

    return false
end

function SubTeamRoomManager:createTeamTable(callback)
    local roomModel = self._roomManager._roomContextOut["roomModel"]
    if not roomModel then return end

    roomModel:createRoom(function(respondType, dataMap)
        if respondType == mc.UR_OPERATE_SUCCEEDED then
            self._roomManager._roomContextOut["tableInfo"] = dataMap
            if not self._roomManager._roomContextOut["isEnteredGameScene"] then
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

function SubTeamRoomManager:enterTeamTable(tableNO, homeUserID, hostName, enterType, callback)
    printLog('SubTeamRoomManager', 'enterTeamTable')
    local enterType_map = {
        explore     = 0,
        system_find = 1,
        friend_find = 2,
        follow      = 3
    }
    print('++++++++++++++++++++++++++++++++++++++enterType'..enterType..'+++++++++++++++++++++')
    local enterGameFlag = enterType_map[enterType]
    self._teamRoomContext["lastTableNO"] = tableNO
    self._teamRoomContext["lastHostID"] = homeUserID
    self._teamRoomContext["lastHostName"] = hostName
    self._teamRoomContext["enterTableCallback"] = callback

    if enterGameFlag == 0 then
        self._teamRoomContext["lastHostName"] = hostName
    end

    local roomModel = self._roomManager._roomContextOut["roomModel"]
    if not roomModel then return end

    roomModel:enterTable(tableNO, homeUserID, enterGameFlag, handler(self, self._onEnterTable))
end

function SubTeamRoomManager:_onEnterTable(respondType, dataMap)
    if respondType == mc.UR_OPERATE_SUCCEEDED then
        self._roomManager._roomContextOut["tableInfo"] = dataMap
        if not dataMap.nHomeUserID then
            self._roomManager._roomContextOut["tableInfo"]["nHomeUserID"] = self._teamRoomContext["lastHostID"]
        end
        if not self._roomManager._roomContext["isEnteredGameScene"] then
            self._roomManager:_tryEnterGame()

            local NewInviteGiftModel = require('src.app.plugins.invitegift.NewInviteGiftModel'):getInstance()
            NewInviteGiftModel:reqConfig()

            local OldUserInviteGiftModel = require('src.app.plugins.invitegift.oldusergift.OldUserInviteGiftModel'):getInstance()
            OldUserInviteGiftModel:sendInviteGiftData()
        else
            if self._teamRoomContext["enterTableCallback"] then 
                self._teamRoomContext["enterTableCallback"](dataMap.nTableNO, dataMap.nChairNO)
            end
        end
    else
        self:_onEnterTableFailed(respondType)
    end

    self._teamRoomContext["lastTableNO"] = nil
    self._teamRoomContext["lastHostID"] = nil
    self._teamRoomContext["lastHostName"] = nil
    self._teamRoomContext["enterTableCallback"] = nil
end

function SubTeamRoomManager:_onEnterTableFailed(respondType)
    --[[if self:isInGame() then
        GamePublicInterface:quitDirect()
    end]]--
    local reasonString = self._roomManager.roomManagerException:getStrByRespondType(respondType) or ""
    local function showGoToOtherRoomTip()
        local hostName = self._lastHostName or ""
        local hostID   = self._lastHostID or 0
        local failedReason = string.format(self._roomManager.roomManagerException:getStrByRespondType(respondType) or "", hostName)
        --[[self:showErrorTip(failedReason, function()
            self:gotoOtherRoom(hostID)
        end, true)]]--
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

function SubTeamRoomManager:onFriendSdkNewMessage()
    print("SubTeamRoomManager:onFriendSdkNewMessage")
    self:_refreshSdkFriendNewMsgReddot(true)
end

function SubTeamRoomManager:onFriendSdkMessageReaded()
    print("SubTeamRoomManager:onFriendSdkMessageReaded")
    self:_refreshSdkFriendNewMsgReddot(false)
end

function SubTeamRoomManager:_refreshSdkFriendNewMsgReddot(isNeedReddot)
    self._mainCtrl._view:refreshPluginBtnReddotDirectly("friend", isNeedReddot)
    if self:getTableListLayer() then
        self:getTableListLayer():showSdkFriendNewMsgRedDot(isNeedReddot)
    end
end

function SubTeamRoomManager:onRecieveInvitation(eventData)
    print("SubTeamRoomManager:onRecieveInvitation")
    dump(eventData.value)

    local inviteInfo = eventData.value["inviteInfo"]
    local fromType = eventData.value["fromType"]

    if SettingsModel:isForbiddenRoomTips() then
        printLog("SubTeamRoomManager", "onGetInvitation...forbid")
        return
    end

    self._teamRoomContextOut["enterTeamInfo"] = {
        hostName = inviteInfo.szHUserName,
        hostID = inviteInfo.nHomeUserID,
        roomID = inviteInfo.nRoomID,
        tableNO = inviteInfo.nTableNO,
        enterType = nil
    }
    if fromType == "sdk" then
        self._teamRoomContextOut["enterTeamInfo"]["enterType"] = "friend_find"
    elseif fromType == "roomServer" then
        self._teamRoomContextOut["enterTeamInfo"]["enterType"] = "system_find"
    end

    --兼容游戏内CharteredRoom
    UserModel.hostName = self._teamRoomContextOut["enterTeamInfo"]["hostName"]
    UserModel.hostID = self._teamRoomContextOut["enterTeamInfo"]["hostID"]
    UserModel.applyRoomId = self._teamRoomContextOut["enterTeamInfo"]["roomID"]
    UserModel.applyTableId = self._teamRoomContextOut["enterTeamInfo"]["tableNO"]
			
    my.scheduleOnce(function ()        
		local  tips = require('src.app.plugins.charteredroom.CharteredInviteTips').new()
        tips:CreateViewNode(inviteInfo)
	end, 0.4)
end

function SubTeamRoomManager:onFriendInviteChoose(eventData)
    print("SubTeamRoomManager:onFriendInviteChoose")
    dump(eventData.value)

    local chooseType = eventData.value["chooseType"]
    local inviteInfo = eventData.value["inviteInfo"]
    
    printLog("SubTeamRoomManager", "onFriendInviteChoose, clickType:%s", clickType)
    if chooseType == "refused" then
        print("onFriendInviteChoose refused")
    elseif chooseType == "accepted" then
        if inviteInfo == nil or inviteInfo.nTableNO == nil or inviteInfo.nTableNO < 0 then
            return
        end
        
		if self._roomManager._roomContextOut["tableInfo"] and inviteInfo.nTableNO == self._roomManager._roomContextOut["tableInfo"]["nTableNO"] then
			printLog('SubTeamRoomManager', 'enterTeamTable, player on table already')
			self._roomManager:_showTip(self._roomManager._roomStrings['FOLLOW_ALREADY_ONTABLE'])
			return
		end

		self._teamRoomContextOut["enterTeamInfo"] = {
			hostName = inviteInfo.szHUserName,
            hostID = inviteInfo.nHomeUserID,
            roomID = inviteInfo.nRoomID,
            tableNO = inviteInfo.nTableNO,
            enterType = "friend_find"
		}
        --兼容游戏内CharteredRoom
        UserModel.hostName = self._teamRoomContextOut["enterTeamInfo"]["hostName"]
        UserModel.hostID = self._teamRoomContextOut["enterTeamInfo"]["hostID"]
        UserModel.applyRoomId = self._teamRoomContextOut["enterTeamInfo"]["roomID"]
        UserModel.applyTableId = self._teamRoomContextOut["enterTeamInfo"]["tableNO"]

        self:_tryEnterTeamByInvitation()
    end
end

function SubTeamRoomManager:_tryEnterTeamByInvitation()

    if self:_doGoBackToHallWhenAgreeInvitationInGame() == true then
        print("_doGoBackToHallWhenAgreeInvitationInGame")
    elseif self:_doEnterTeamTableWhenEnteredRoom() == true then
        print("_doEnterTeamTableWhenEnteredRoom")
    else
        self:_doEnterTeamRoomWhenAgreeInvitationInHall()
    end
end

function SubTeamRoomManager:_doGoBackToHallWhenAgreeInvitationInGame()
    if self._roomManager._roomContextOut["isEnteredGameScene"] == true then
        self._teamRoomContextOut["readyToFollowOnBackFromGame"] = true
        GamePublicInterface:quitDirect()

        print("SubTeamRoomManager:_doGoBackToHallWhenAgreeInvitationInGame true")
        return true
    end

    return false
end

function SubTeamRoomManager:_doEnterTeamTableWhenEnteredRoom()
    local curRoomInfo = self._roomManager._roomContextOut["roomInfo"]
    local curRoomModel = self._roomManager._roomContextOut["roomModel"]

    if curRoomModel == nil then
        return false --说明没有进入好友房的房间，所以无法执行“进桌子”流程，需要先进房间
    end
    if curRoomInfo and (curRoomInfo["isTeamRoom"] ~= true or self._roomManager._roomContextOut["areaEntry"] ~= "team") then
        return false --当前在非好友房界面，说明没有进入好友房的房间，所以无法执行“进桌子”流程，需要先进房间
    end

    local enterTeamInfo = self._teamRoomContextOut["enterTeamInfo"]
    if curRoomInfo and curRoomInfo["nRoomID"] == enterTeamInfo["roomID"] then
        self:enterTeamTable(enterTeamInfo.tableNO, enterTeamInfo.hostID, enterTeamInfo.hostName, enterTeamInfo.enterType)

        print("SubTeamRoomManager:_doEnterTeamTableWhenEnteredRoom true")
        return true
    end

    return false
end

function SubTeamRoomManager:_doEnterTeamRoomWhenAgreeInvitationInHall()
    print("SubTeamRoomManager:_doEnterTeamRoomWhenAgreeInvitationInHall")

    print("SubTeamRoomManager:_doEnterTeamRoomWhenAgreeInvitationInHall and doLeaveCurrentRoom")
    self._roomManager:doLeaveCurrentRoom() --在进新房间前，先离开当前房间

    self._roomManager._roomContextOut["areaEntry"] = "team"
    local enterTeamInfo = self._teamRoomContextOut["enterTeamInfo"]
    self._roomManager:tryEnterRoom(enterTeamInfo.roomID, false, function()
        if enterTeamInfo.tableNO and enterTeamInfo.tableNO > 0 then
            self:enterTeamTable(enterTeamInfo.tableNO, enterTeamInfo.hostID, enterTeamInfo.hostName, enterTeamInfo.enterType)
            return
        end

        --aaaa需要测试
        local roomModel = self._roomManager._roomContextOut["roomModel"]
        if not roomModel then return end

        roomModel:findPlayer(roomID, hostID, function(respondType, tableNOInner)
		    if not tableNOInner or tableNOInner < 0 then
			    local formatString = self._roomManager.roomManagerException:getStrByRespondType(respondType)
			    if not formatString then
				    formatString = self._roomManager._roomStrings["FOLLOW_TARGET_OFFTABLE"]
			    end
			    local failedReason = string.format(formatString, hostName or '')
			    --[[self:showErrorTip(failedReason, function()
				    self:gotoOtherRoom(hostID)
			    end)]]--
                self._roomManager:_showTip(failedReason)
			    return
		    end

		    self:enterTeamTable(tableNOInner, enterTeamInfo.hostID, enterTeamInfo.hostName, enterTeamInfo.enterType)
	    end)
    end)
end

function SubTeamRoomManager:dealOnBackFromGame()
    if self:_doFollowAfterBackFromGame() == true then
        return true
    elseif self:getTableListLayer() and self:getTableListLayer():isViewVisible() == true then
        printLog("SubTeamRoomManager", "onBackFromGame4")

        my.scheduleOnce(function()
            my.startProcessing()
            self:_aquireTableList()
        end, 0)
        
        return true
    end

    return false
end

function SubTeamRoomManager:_doFollowAfterBackFromGame()
    if self._teamRoomContextOut["readyToFollowOnBackFromGame"] ~= true then
        return false
    end
    self._teamRoomContextOut["readyToFollowOnBackFromGame"] = false

    my.scheduleOnce(function()
        if self:_doEnterTeamTableWhenEnteredRoom() == true then
            print("_doEnterTeamTableWhenEnteredRoom")
        else
            self:_doEnterTeamRoomWhenAgreeInvitationInHall()
        end
    end, 0.1) --延时的原因：从游戏内返回立即调用“触发进入游戏的流程”，会失败

    return true
end

function SubTeamRoomManager:onKeyback()
    if self:getSecondLayerTeam() then
        if self:getTableListLayer() and self:getTableListLayer():isViewVisible() then
            self:closeTeamTableListLayer()
            return true
        end
    end
    return false
end

function SubTeamRoomManager:dealOnClose()
end

return SubTeamRoomManager