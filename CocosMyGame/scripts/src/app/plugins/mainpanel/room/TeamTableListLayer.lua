local TeamTableListLayer = class("TeamTableListLayer")

local CenterCtrl = require('src.app.BaseModule.CenterCtrl'):getInstance()
local tcyFriendPlugin = plugin.AgentManager:getInstance():getTcyFriendPlugin()
local ImageCtrl = require("src.app.BaseModule.ImageCtrl")
local UserModel = mymodel('UserModel'):getInstance()

TeamTableListLayer.CHAIR_COUNT = 4

function TeamTableListLayer:ctor(layerNode, roomManager, teamSecondLayer, teamRoomInfo)
    self._layerNode = layerNode
    self._roomManager = roomManager
    self._teamSecondLayer = teamSecondLayer
    self._teamRoomInfo = teamRoomInfo
    self._teamRoomManager = roomManager.subTeamRoomManager

    self._tablesViewData = {
        [1] = {
            ["tableInfo"] = {}, 
            ["playersViewData"] = {},
            ["tableNode"] = nil,
            ["isTableExist"] = false
        },
        [2] = {
            ["tableInfo"] = {},
            ["playersViewData"] = {},
            ["tableNode"] = nil,
            ["isTableExist"] = false
        },
        [3] = {
            ["tableInfo"] = {},
            ["playersViewData"] = {}, 
            ["tableNode"] = nil,
            ["isTableExist"] = false
        }
    }
    self._tablesViewDataMap = {
    }
end

function TeamTableListLayer:initView()
    self._opePanel = self._layerNode:getChildByName("Operate_Panel")
    self._panelTop = self._opePanel:getChildByName("Panel_Top")
    self._btnCreate = self._opePanel:getChildByName("Btn_Create")
    self._btnRefresh = self._opePanel:getChildByName("Btn_Fresh")
    self._btnChange = self._opePanel:getChildByName("Btn_Change")
    self._btnBack = self._opePanel:getChildByName("Btn_Back")
    self._scrollTables = self._opePanel:getChildByName("Scroll_Room")
    self._imgNoTable = self._opePanel:getChildByName("Img_NoRoom")
    self._btnSdkFriends = self._opePanel:getChildByName("Btn_Friends")
    self._btnSdkFriendImgDot = self._btnSdkFriends:getChildByName("Img_Dot")

    cc.exports.zeroBezelNodeAutoAdapt(self._opePanel)
    self:_initTopBar()
    local btnsInfo = {
        {["btn"] = self._btnCreate, ["clickFunc"] = handler(self, self._onClickBtnCreate)},
        {["btn"] = self._btnRefresh, ["clickFunc"] = handler(self, self._onClickBtnRefresh)},
        {["btn"] = self._btnChange, ["clickFunc"] = handler(self, self._onClickBtnChange)},
        {["btn"] = self._btnBack, ["clickFunc"] = handler(self, self._onClickBtnBack)},
        {["btn"] = self._btnSdkFriends, ["clickFunc"] = handler(self, self._onClickBtnSdkFriends)}
    }
    for i = 1, #btnsInfo do
        local btnInfo = btnsInfo[i]
        btnInfo["btn"]:addClickEventListener(btnInfo["clickFunc"])
    end

    self._btnSdkFriends:setVisible(cc.exports.isFriendSupported())
end

function TeamTableListLayer:_initTopBar()
    local panelPlayer = self._panelTop:getChildByName("Panel_Player")
    local panelDeposit = panelPlayer:getChildByName("Panel_Deposit")
    local btnBuyDeposit = panelDeposit:getChildByName("Btn_Charge")
    local btnHelp = self._panelTop:getChildByName("Btn_Help")
    local btnSetting = self._panelTop:getChildByName("Btn_Setting")
    local btnActivity = self._panelTop:getChildByName("Btn_Activity")

    btnHelp:addClickEventListener(function()
        my.playClickBtnSound()
        my.informPluginByName({pluginName = SubViewHelper:getTargetHelpCtrlName()})
    end)
    btnSetting:addClickEventListener(function()
        my.playClickBtnSound()
        my.informPluginByName({pluginName = 'SettingsPlugin'})
    end)
    btnBuyDeposit:addClickEventListener(function()
        my.playClickBtnSound()
        my.informPluginByName({ pluginName = 'ShopCtrl' })
    end)
    btnActivity:addClickEventListener(function()
        my.playClickBtnSound()
        my.informPluginByName({pluginName = 'DailyActivitysCtrl'})
    end)

    btnBuyDeposit:setVisible(cc.exports.isShopSupported())
    btnActivity:setVisible(false) --不需要了
end

function TeamTableListLayer:refreshView()
    self._btnSdkFriendImgDot:setVisible(false)
    self._imgNoTable:setVisible(true)
    self._btnRefresh:setVisible(true)
    self._btnChange:setVisible(false)

    self._scrollTables:removeAllChildren()

    self:refreshTopBarInfo()
end

function TeamTableListLayer:refreshViewOnDepositChange()
    self:refreshTopBarInfo()
end

function TeamTableListLayer:refreshTopBarInfo()
    local panelPlayer = self._panelTop:getChildByName("Panel_Player")
    local panelDeposit = panelPlayer:getChildByName("Panel_Deposit")
    local panelScore = panelPlayer:getChildByName("Panel_Score")
    local labelDeposit = panelDeposit:getChildByName("Text_Deposit")
    local labelScore = panelScore:getChildByName("Text_PlayerScore")
    local labelUserName = panelPlayer:getChildByName("Text_Name")
    local imgVIPAvail = panelPlayer:getChildByName("Img_VIP")
    local imgVIPUnAvail = panelPlayer:getChildByName("Img_VIP_F")

    labelDeposit:setString(UserModel.nDeposit or 0)
    labelScore:setString(UserModel.nScore or 0)
    --labelUserName:setString(UserModel.szUtf8Username or "")
    SubViewHelper:refreshSelfName(labelUserName, 200)
    imgVIPAvail:setVisible(false)
    imgVIPUnAvail:setVisible(false)
end

function TeamTableListLayer:_onClickBtnCreate()
    my.playClickBtnSound()
    if not UIHelper:checkOpeCycle("TeamTableListLayer_onClickBtnCreate") then
        return
    end
    UIHelper:refreshOpeBegin("TeamTableListLayer_onClickBtnCreate")

    self._teamRoomManager:createTeamTable()
end

function TeamTableListLayer:_onClickBtnRefresh()
    my.playClickBtnSound()
    if not UIHelper:checkOpeCycle("TeamTableListLayer_onClickBtnRefresh") then
        return
    end
    UIHelper:refreshOpeBegin("TeamTableListLayer_onClickBtnRefresh")

    my.startProcessing()
    self._teamRoomManager:_aquireTableList()
end

function TeamTableListLayer:_onClickBtnChange()
    my.playClickBtnSound()
    if not UIHelper:checkOpeCycle("TeamTableListLayer_onClickBtnChange") then
        return
    end
    UIHelper:refreshOpeBegin("TeamTableListLayer_onClickBtnChange")

    my.startProcessing()
    self._teamRoomManager:_aquireTableList()
end

function TeamTableListLayer:_onClickBtnBack()
    my.playClickBtnSound()
    if not UIHelper:checkOpeCycle("TeamTableListLayer_onClickBtnBack") then
        return
    end
    UIHelper:refreshOpeBegin("TeamTableListLayer_onClickBtnBack")

    self._teamRoomManager:closeTeamTableListLayer()
end

function TeamTableListLayer:_onClickBtnSdkFriends()
    my.playClickBtnSound()
    if not UIHelper:checkOpeCycle("TeamTableListLayer_onClickBtnSdkFriends") then
        return
    end
    UIHelper:refreshOpeBegin("TeamTableListLayer_onClickBtnSdkFriends")
    if not CenterCtrl:checkNetStatus() then return end

    self._btnSdkFriendImgDot:setVisible(false)

    if tcyFriendPlugin and tcyFriendPlugin.showChatDialogMain then
        tcyFriendPlugin:showChatDialogMain()
    end

    --测试代码
    --[[local tcyFriendPluginWrapper = PUBLIC_INTERFACE.GetTcyFriendPluginWrapper()
    tcyFriendPluginWrapper:testInvitation()]]--
end

function TeamTableListLayer:showView(isShow)
    self._layerNode:setVisible(isShow == true)
end

function TeamTableListLayer:showSdkFriendNewMsgRedDot(isShow)
    self._btnSdkFriendImgDot:setVisible(isShow == true)
end

function TeamTableListLayer:isViewVisible()
    if self._layerNode and not tolua.isnull(self._layerNode) and self._layerNode:isVisible() then
        return true
    end

    return false
end

function TeamTableListLayer:showTables(tableList, tableCondition)
    print("TeamTableListLayer:showTables")
    dump(tableList)
    dump(tableCondition)

    self:_clearTables()

    for i = 1, #tableList do
        local infoItem = tableList[i]
        infoItem["szUserName"] = MCCharset:getInstance():gb2Utf8String(infoItem["szUserName"], infoItem["szUserName"]:len())
        if infoItem["nExistPlayerIDs"] then
            for i = #infoItem["nExistPlayerIDs"], 1, -1 do
                if infoItem["nExistPlayerIDs"][i] > 0 then
                else
                    table.remove(infoItem["nExistPlayerIDs"], i)
                end
            end
        end

        self._tablesViewData[i]["tableInfo"] = infoItem
        self._tablesViewData[i]["isTableExist"] = true
        self._tablesViewDataMap[infoItem["nTableId"]] = self._tablesViewData[i]
        self:_createTableView(self._tablesViewData[i], i)
        self:_refreshTableView(self._tablesViewData[i])
    end

    self._imgNoTable:setVisible(not (#tableList > 0))
    self._btnRefresh:setVisible(not (#tableList > 0))
    self._btnChange:setVisible(#tableList > 0)

    my.stopProcessing()
end

function TeamTableListLayer:_createTablePlayers(tableViewData)
    local tableNode = tableViewData["tableNode"]
    local tableInfo = tableViewData["tableInfo"]
    local playersViewData = tableViewData["playersViewData"]

    local nodeTableDetail = tableNode:getChildByName("Node_room_detail")
    local panelTableDetail = nodeTableDetail:getChildByName("Panel_Main")
    local scrollPlayers = panelTableDetail:getChildByName("Scroll_Player")
    local imgDown = panelTableDetail:getChildByName("Img_Down")

    scrollPlayers:removeAllChildren()
    local userIds = {}
    for i = 1, #playersViewData do
        self:_createTablePlayer(scrollPlayers, tableViewData, playersViewData[i], i)
        self:_refreshTablePlayerView(tableViewData, playersViewData[i])
        userIds[i] = playersViewData[i]["playerInfo"]["nUserID"]
    end

    if #playersViewData < 4 then
        scrollPlayers:setTouchEnabled(false)
        imgDown:setVisible(false)
    else
        scrollPlayers:setTouchEnabled(true)
        imgDown:setVisible(false)
    end
    scrollPlayers:scrollToTop(0.01, false)

    ImageCtrl:getImageByUserIDs(userIds, '60-60', function(portraitList)
        self._refreshPlayersPortrait(tableViewData, portraitList)
    end)
end

function TeamTableListLayer:_createTablePlayer(scrollPlayers, tableViewData, playerViewData, itemIndex)
    local nodeRaw = cc.CSLoader:createNode("res/hallcocosstudio/gamefriend/friend.csb")
    local playerNode = nodeRaw:getChildByName("Panel_Main")
    playerNode:removeFromParent()

    local posY = scrollPlayers:getInnerContainerSize().height - playerNode:getContentSize().height * itemIndex - 10
    playerNode:setPosition(0, posY)

    playerNode:setName("player_"..tostring(playerViewData["playerInfo"]["nUserID"]))
    scrollPlayers:addChild(playerNode)

    playerViewData["playerNode"] = playerNode
end

function TeamTableListLayer:_refreshTablePlayerView(tableViewData, playerViewData)
    local tableInfo = tableViewData["tableInfo"]
    local playerInfo = playerViewData["playerInfo"]
    local playerNode = playerViewData["playerNode"]

    local labelUserName = playerNode:getChildByName("Text_Host")
    local labelWinRate = playerNode:getChildByName("Text_Victory")
    local labelDeposit = playerNode:getChildByName("Text_Score")
    local imgFriendFlag = playerNode:getChildByName("Img_Friend")
    local imgHead = playerNode:getChildByName("Img_Head")
    local imgHeadPic = imgHead:getChildByName("Img_HeadPic")

    local displayName = self:_getDisplayUserName(playerInfo["szUserName"], tableInfo["nHomeUserID"])
    if tableInfo["nHomeUserID"] == playerInfo["nUserID"] then
        labelUserName:setString("房主："..displayName)
    else
        labelUserName:setString(displayName)
    end
    my.fixUtf8Width(displayName, labelUserName, 176)

    local winRate = 0
    if playerInfo["nTotalBount"] ~= 0 then
        winRate = math.floor(playerInfo["nWins"] * 100 / playerInfo["nTotalBount"])
    end
    local winRateStr = string.format("胜率：%d%%(%d局)", winRate, playerInfo["nTotalBount"])
    labelWinRate:setString(winRateStr)
    labelDeposit:setString(playerInfo["nDeposit"])

    if tcyFriendPlugin and tcyFriendPlugin:isFriend(playerInfo["nUserID"]) then
        imgFriendFlag:setVisible(true)
    else
        imgFriendFlag:setVisible(false)
    end

    imgHeadPic:setVisible(true)
    imgHeadPic:loadTexture(cc.exports.getHeadResPath(playerInfo["nNickSex"]))
end

function TeamTableListLayer:_getDisplayUserName(userName, nHomeUserID)
    local displayName = userName
    if tcyFriendPlugin == nil then return displayName end

    if tcyFriendPlugin and tcyFriendPlugin:isFriend(nHomeUserID) then
        local remarkName = tcyFriendPlugin:getRemarkName(nHomeUserID)
        if remarkName ~= nil and remarkName ~= "" then
            displayName = remarkName
        end
    end

    return displayName
end

function TeamTableListLayer:_clearTables()
    self._scrollTables:removeAllChildren()
    for i = 1, #self._tablesViewData do
        self._tablesViewData[i]["tableInfo"] = {}
        self._tablesViewData[i]["playersInfo"] = {}
        self._tablesViewData[i]["tableNode"] = nil
        self._tablesViewData[i]["isTableExist"] = false
    end
    self._tablesViewDataMap = {}
end

function TeamTableListLayer:_createTableView(tableViewData, itemIndex)
    local nodeRaw = cc.CSLoader:createNode("res/hallcocosstudio/gamefriend/query_room.csb")
    local tableNode = nodeRaw:getChildByName("Panel_Main")
    tableNode:removeFromParent()
    tableNode:setName("tableNode_"..itemIndex)

    local itemWidth = tableNode:getContentSize().width
    local itemHeight = tableNode:getContentSize().height
    local paddingX = 0
    local gapX = (self._scrollTables:getContentSize().width - 3 * itemWidth - 2 * paddingX) / 2
    local posX = paddingX + (itemWidth + gapX) * (itemIndex - 1)
    local posY = (self._scrollTables:getContentSize().height - itemHeight) / 2
    tableNode:setPosition(posX, posY)

    self._scrollTables:addChild(tableNode)

    tableViewData["tableNode"] = tableNode
    self:_initTableView(tableViewData)
end

function TeamTableListLayer:_initTableView(tableViewData)
    local tableNode = tableViewData["tableNode"]

    local panelRoomInfo = tableNode:getChildByName("Panel_RoomInfo")
    local btnDetail = panelRoomInfo:getChildByName("Btn_Detail")
    local btnEnter = tableNode:getChildByName("Btn_Enter")
    local nodeTableDetail = tableNode:getChildByName("Node_room_detail")
    local panelTableDetail = nodeTableDetail:getChildByName("Panel_Main")
    local btnBack = panelTableDetail:getChildByName("Panel_RoomInfo"):getChildByName("Btn_Back")

    nodeTableDetail:setVisible(false)
    btnDetail:addClickEventListener(function()
        my.playClickBtnSound()
        self:_onClickBtnShowTableDetail(tableViewData)
    end)
    btnEnter:addClickEventListener(function()
        my.playClickBtnSound()
        self:_onClickBtnEnterTable(tableViewData)
    end)
    btnBack:addClickEventListener(function()
        my.playClickBtnSound()
        self:_onClickBtnBackOfTableDetail(tableViewData)
    end)
end

function TeamTableListLayer:_onClickBtnShowTableDetail(tableViewData)
    print("TeamTableListLayer:_onClickBtnShowTableDetail")
    
    local tableNode = tableViewData["tableNode"]

    local nodeTableDetail = tableNode:getChildByName("Node_room_detail")
    local panelRoomInfoDetail = tableNode:getChildByName("Panel_RoomInfoDetail")
    local btnEnter = tableNode:getChildByName("Btn_Enter")

    nodeTableDetail:setVisible(true)
    panelRoomInfoDetail:setVisible(false)
    btnEnter:setVisible(false)
end

function TeamTableListLayer:_onClickBtnEnterTable(tableViewData)
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
    self._teamRoomManager:_doEnterTeamTableWhenEnteredRoom()
end

function TeamTableListLayer:_onClickBtnBackOfTableDetail(tableViewData)
    print("TeamTableListLayer:_onClickBtnBackOfTableDetail")

    local tableNode = tableViewData["tableNode"]

    local nodeTableDetail = tableNode:getChildByName("Node_room_detail")
    local panelRoomInfoDetail = tableNode:getChildByName("Panel_RoomInfoDetail")
    local btnEnter = tableNode:getChildByName("Btn_Enter")

    nodeTableDetail:setVisible(false)
    panelRoomInfoDetail:setVisible(true)
    btnEnter:setVisible(true)
end

function TeamTableListLayer:_refreshTableView(tableViewData)
    local tableNode = tableViewData["tableNode"]
    local tableInfo = tableViewData["tableInfo"]

    local panelRoomInfo = tableNode:getChildByName("Panel_RoomInfo")
    local panelHost = tableNode:getChildByName("Panel_Host")
    local nodeTableDetail = tableNode:getChildByName("Node_room_detail")
    local panelRoomInfoDetail = tableNode:getChildByName("Panel_RoomInfoDetail")
    local imgFriendFlag = panelRoomInfo:getChildByName("Img_Friend")
    local tablePlayerNum = panelRoomInfo:getChildByName("Text_Num")
    local labelHostUserName = panelHost:getChildByName("Text_Host")
    local imgHead = panelHost:getChildByName("Img_Head")
    local imgHeadPic = imgHead:getChildByName("Img_HeadPic")
    local labelAvgBouts = panelRoomInfoDetail:getChildByName("Text_Round")
    local labelAvgWinRate = panelRoomInfoDetail:getChildByName("Text_Victory")
    local labelAvgDeposit = panelRoomInfoDetail:getChildByName("Text_Score")
    
    imgFriendFlag:setVisible(self:_hasFriend(tableInfo["nExistPlayerIDs"]))
    local existPlayerCount = tableInfo["nExistPlayerIDs"] and #tableInfo["nExistPlayerIDs"] or 1
    tablePlayerNum:setString(existPlayerCount.."/"..TeamTableListLayer.CHAIR_COUNT)
    local displayName = self:_getDisplayUserName(tableInfo["szUserName"], tableInfo["nHomeUserID"])
    labelHostUserName:setString(displayName)

    imgHeadPic:loadTexture(cc.exports.getHeadResPath(tableInfo["nNickSex"]))                
    self:_addImgHeadMask(imgHead, imgHeadPic)

    labelAvgBouts:setString("平均局数："..tableInfo["nAvgBounts"])
    labelAvgWinRate:setString("平均胜率："..tableInfo["nAvgWins"].."%")
    labelAvgDeposit:setString("平均银两："..tableInfo["nAvgDeposit"])

    ImageCtrl:getImageByUserIDs({tableInfo["nHomeUserID"]}, '60-60', function(portraitList)
        self._refreshHostPortrait(tableViewData, portraitList)
    end)
end

function TeamTableListLayer:_refreshHostPortrait(tableViewData, portraitList)
    print("TeamTableListLayer:_refreshHostPortrait")
    if tableViewData == nil or portraitList == nil then return end
    if tableViewData["isTableExist"] ~= true or tableViewData["tableNode"] == nil then
        print("tableViewData isTableExist not true or tableNode is not existed, isTableExist "..tostring(tableViewData["isTableExist"]))
        return
    end
    if tolua.isnull(tableViewData["tableNode"]) then
        print("tolua.isnull is true")
        return
    end

    local tableNode = tableViewData["tableNode"]
    local tableInfo = tableViewData["tableInfo"]

    local hostPortraitInfo = portraitList[tableInfo["nHomeUserID"]]
    if hostPortraitInfo == nil or hostPortraitInfo["path"] == "" then
        print("hostPortraitInfo nil or empty, nil "..tostring(hostPortraitInfo))
        return
    end
    print("hostPortraitInfo path "..tostring(hostPortraitInfo["path"]))

    local panelHost = tableNode:getChildByName("Panel_Host")
    local imgHead = panelHost:getChildByName("Img_Head")
    local imgHeadPic = imgHead:getChildByName("Img_HeadPic")

    imgHeadPic:loadTexture(hostPortraitInfo["path"]) 
	imgHeadPic:setVisible(true)
end

function TeamTableListLayer:_refreshPlayersPortrait(tableViewData, portraitList)
    print("TeamTableListLayer:_refreshHostPortrait")
    if tableViewData == nil or portraitList == nil then return end
    if tableViewData["isTableExist"] ~= true or tableViewData["tableNode"] == nil then
        print("tableViewData isTableExist not true or tableNode is not existed, isTableExist "..tostring(tableViewData["isTableExist"]))
        return
    end
    if tolua.isnull(tableViewData["tableNode"]) then
        print("tolua.isnull is true")
        return
    end

    local tableNode = tableViewData["tableNode"]
    local tableInfo = tableViewData["tableInfo"]
    local nodeTableDetail = tableNode:getChildByName("Node_room_detail")
    local panelTableDetail = nodeTableDetail:getChildByName("Panel_Main")
    local scrollPlayers = panelTableDetail:getChildByName("Scroll_Player")

    local childPlayerNodes = scrollPlayers:getChildren()
    for userId, portraitInfo in pairs(portraitList) do
        for _, childNode in pairs(childPlayerNodes) do
            if portraitInfo["path"] == "" then
                break
            end

            local nodeName = childNode:getName()
            local expectName = "player_"..tostring(userId)
            if nodeName == expectName then
                local imgHead = childNode:getChildByName("Img_Head")
                local imgHeadPic = imgHead:getChildByName("Img_HeadPic")

                imgHeadPic:loadTexture(portraitInfo["path"]) 
	            imgHeadPic:setVisible(true)
                break
            end
        end
    end

end

function TeamTableListLayer:_addImgHeadMask(imgHead, imgHeadPic)
    local clip = cc.ClippingNode:create()
    clip:setInverted(false)  
	clip:setAlphaThreshold(0.05)  
	imgHead:addChild(clip)  

	imgHead:removeChild(imgHeadPic, true)
	clip:addChild(imgHeadPic)

	--以下模型是带图像遮罩  
	local nodef = cc.Node:create()  
	local close = cc.Sprite:create("Friend_IconMask1.png");  
	nodef:addChild(close)  
	nodef:setPosition(cc.p(close:getContentSize().width / 2 + 2, close:getContentSize().height / 2 + 2))  
	clip:setStencil(nodef)
end

function TeamTableListLayer:_hasFriend(userIds)
    if tcyFriendPlugin == nil then return false end
    if userIds == nil then return false end

    for _, userId in pairs(userIds)do
        if tcyFriendPlugin:isFriend(userId) then
            return true
        end
    end

    return false
end

function TeamTableListLayer:setTableDetail(tableDetail)
    print("TeamTableListLayer:setTableDetail")
    dump(tableDetail)

    local tableViewData = self._tablesViewDataMap[tableDetail["nTableId"]]
    if tableViewData == nil then
        print("tableViewData not found by tableId "..tostring(tableDetail[1]["nTableId"]))
        return
    end
    local playersItem = tableDetail[2]
    for i = 1, #playersItem do
        local infoItem = playersItem[i]
        infoItem["szUserName"] = MCCharset:getInstance():gb2Utf8String(infoItem["szUserName"], infoItem["szUserName"]:len())
        tableViewData["playersViewData"][i] = {
            ["playerInfo"] = infoItem,
            ["playerNode"] = nil
        }
    end

    self:_createTablePlayers(tableViewData)
end

function TeamTableListLayer:onTableAquireFinished()
    print("TeamTableListLayer:onTableAquireFinished")
end

return TeamTableListLayer