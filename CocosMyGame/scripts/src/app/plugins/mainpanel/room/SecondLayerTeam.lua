local SecondLayerTeam = class("SecondLayerTeam", import(".SecondLayerBase"))

local RoomListModel = import("src.app.GameHall.room.model.RoomListModel"):getInstance()
local TeamTableListLayer = import("src.app.plugins.mainpanel.room.TeamTableListLayer")

SecondLayerTeam.CSB_PATH_LAYER_TABLELIST = "res/hallcocosstudio/gamefriend/charteredroom.csb"

function SecondLayerTeam:ctor(layerNode, roomManager)
    SecondLayerTeam.super.ctor(self, layerNode, roomManager)
    self.layerName = "team"
    self._areaEntryByLayer = "team"

    self.subTeamTableList = nil
    self._roomBtnsInfo = {
        [1] = {["roomInfo"] = nil, ["roomNode"] = nil},
        [2] = {["roomInfo"] = nil, ["roomNode"] = nil}
    }
end

function SecondLayerTeam:initView()
    local layerNode = self._layerNode
    self._opePanel = layerNode:getChildByName("Operate_Panel")
    self._panelTop = self._opePanel:getChildByName("Panel_Top")
    self._panelRoomList = self._opePanel:getChildByName("Panel_RoomList")

    cc.exports.zeroBezelNodeAutoAdapt(self._opePanel)
    self:_initTopBar()
    self:_createRoomList()
end

function SecondLayerTeam:_initTopBar()
    local btnBack = self._panelTop:getChildByName("Button_Back")

    btnBack:addClickEventListener(handler(self, self._onClickBtnBack))
    SubViewHelper:initTopBar(self._panelTop, handler(self._roomManager._mainCtrl, self._roomManager._mainCtrl.onClickExit))
end

function SecondLayerTeam:_createRoomList()
    local roomInfoList = RoomListModel:gradeRoomsToList(RoomListModel.gradeRoomsTeam)
    local maxCount = math.min(#roomInfoList, 2) --好友房仅支持显示两个
    for i = 1, maxCount do
        local roomInfo = roomInfoList[i]
        local nodeRoomBtn = self:_createRoomBtn(roomInfo)
        if nodeRoomBtn then
            self._panelRoomList:addChild(nodeRoomBtn)
            local posX = self._panelRoomList:getContentSize().width / 2 - 50 - nodeRoomBtn:getContentSize().width / 2
            if i == 2 then
                posX = self._panelRoomList:getContentSize().width / 2 + 50 + nodeRoomBtn:getContentSize().width / 2
            end
            local posY = (self._panelRoomList:getContentSize().height - 100) / 2 + 70
            nodeRoomBtn:setPosition(cc.p(posX, posY))
            
            local roomBtnInfo = {["roomInfo"] = roomInfo, ["roomNode"] = nodeRoomBtn}
            table.insert(self._roomBtnsInfo, roomBtnInfo)

            self:_initRoomBtn(roomBtnInfo)
            self:refreshRoomBtnInfo(roomBtnInfo)
        end
    end

    if 1 == #roomInfoList then
        self._roomBtnsInfo[1]["roomNode"]:setPositionX(self._panelRoomList:getContentSize().width / 2) --只有一个房间按钮，则让它居中
    end
end

function SecondLayerTeam:_createRoomBtn(roomInfo)
    local roomBtnConfig = self._roomManager.areaViewConfig["team"]["roomBtn"]
    if roomBtnConfig == nil then return end

    local roomBtnName = "roomBtn_"..roomInfo["gradeName"]
    local nodeRaw = cc.CSLoader:createNode(roomBtnConfig["csbPath"])
    local nodeRoomBtn = nodeRaw:getChildByName("Btn_Room")
    nodeRoomBtn:removeFromParent()
    nodeRoomBtn:setName(roomBtnName)

    return nodeRoomBtn
end

function SecondLayerTeam:_initRoomBtn(roomBtnInfo)
    local roomNode = roomBtnInfo["roomNode"]
    local roomInfo = roomBtnInfo["roomInfo"]

    cc.exports.UIHelper:setTouchByScale(roomNode, function()
        my.playClickBtnSound()
        if not UIHelper:checkOpeCycle("SecondLayerTeam_onClickroomNode") then
            return
        end
        UIHelper:refreshOpeBegin("SecondLayerTeam_onClickroomNode")

        print("onClick enter team room "..tostring(roomInfo["nRoomID"]))
        self._roomManager:tryEnterRoom(roomBtnInfo["roomInfo"]["nRoomID"], nil, function()
            self:_showLayerTableList()
        end)
    end, roomNode, 1.1)
end

function SecondLayerTeam:refreshRoomBtnInfo(roomBtnInfo)
    local roomNode = roomBtnInfo["roomNode"]
    local roomInfo = roomBtnInfo["roomInfo"]

    local imgRoomBk1 = roomNode:getChildByName("Img_RoomBG1_backimage")
    local imgRoomBk2 = roomNode:getChildByName("Img_RoomBG2_backimage")
    local imgRoomName1 = roomNode:getChildByName("Img_RoomNameBG1")
    local imgRoomName2 = roomNode:getChildByName("Img_RoomNameBG2")
    local labelScoreCondition = roomNode:getChildByName("Text_Condition_Feng")
    local labelDepositCondition = roomNode:getChildByName("Text_Condition_Liang")

    if roomInfo["gradeName"] == "senior" then
        imgRoomBk2:setVisible(true)
        imgRoomName2:setVisible(true)
    else
        imgRoomBk2:setVisible(false)
        imgRoomName2:setVisible(false)
    end
    labelScoreCondition:setVisible(false)
    labelDepositCondition:setMoney("≥"..roomInfo["nMinDeposit"])
end

function SecondLayerTeam:refreshView()
    self:refreshTopBarInfo()
end

function SecondLayerTeam:refreshViewOnDepositChange()
    self:refreshTopBarInfo()
    if self.subTeamTableList then
        self.subTeamTableList:refreshViewOnDepositChange()
    end
end

function SecondLayerTeam:refreshTopBarInfo()
    SubViewHelper:setTopBarInfo(self._panelTop)
end

function SecondLayerTeam:_showLayerTableList(roomInfo)
    if self._subTeamTableList == nil then
        local layerNodeTableList = cc.CSLoader:createNode(SecondLayerTeam.CSB_PATH_LAYER_TABLELIST)
        layerNodeTableList:setName("Layer_TeamTableList")
        self._layerNode:addChild(layerNodeTableList)
        layerNodeTableList:setContentSize(display.size)
        my.presetAllButton(layerNodeTableList)
        ccui.Helper:doLayout(layerNodeTableList)

        self.subTeamTableList = TeamTableListLayer:create(layerNodeTableList, self._roomManager, self, roomInfo)
        self.subTeamTableList:initView()
    end
    self.subTeamTableList:showView(true)
    self.subTeamTableList:refreshView()
end

function SecondLayerTeam:dealOnClose()
end

return SecondLayerTeam