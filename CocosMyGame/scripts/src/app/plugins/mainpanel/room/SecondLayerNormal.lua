local SecondLayerNormal = class("SecondLayerNormal", import(".SecondLayerBase"))

local RoomListModel = import("src.app.GameHall.room.model.RoomListModel"):getInstance()
local UserModel = mymodel('UserModel'):getInstance()

local NobilityPrivilegeModel = import("src.app.plugins.NobilityPrivilege.NobilityPrivilegeModel"):getInstance()

SecondLayerNormal.roomListLayoutConfig = {
    ["itemWidth"] = 295,
    ["itemHeight"] = 205,
    ["scrollDirection"] = "y",
    ["paddingX"] = 10,
    ["paddingY"] = 10,

    ["visibleWidth"] = 1000,
    ["visibleHeight"] = 460,
    ["visibleCols"] = 3,
    ["visibleRows"] = 2,

    ["gapX"] = 30,
    ["gapXMax"] = 100,
    ["gapY"] = 20,
    ["gapYMax"] = 100,
    ["posXStart"] = -1,
    ["posYStart"] = -1,
}

SecondLayerNormal.skAniInfo_RoomSelect = {
    ["jsonPath"] = "res/hallcocosstudio/images/skeleton/room_select/erjijiemian.json",
    ["atlasPath"] = "res/hallcocosstudio/images/skeleton/room_select/erjijiemian.atlas",
	["aniNames"] = {"erjijiemian"}
}

function SecondLayerNormal:ctor(layerNode, roomManager)
    SecondLayerNormal.super.ctor(self, layerNode, roomManager)
    self.layerName = "normal"

    self._roomBtnsInfo = {
        --[1] = {["roomInfo"] = nil, ["roomNode"] = nil}
    }
    self._quickStartRoomInfo = nil
end

function SecondLayerNormal:initView()
    local layerNode = self._layerNode
    self._opePanel = layerNode:getChildByName("Operate_Panel")
    self._panelTop = self._opePanel:getChildByName("Panel_Top")
    self._panelLeft = self._opePanel:getChildByName("Panel_Left")
    self._scrollViewRooms = self._opePanel:getChildByName("List_Room")
    self._panelQuickStart = self._opePanel:getChildByName("Panel_QuickStart")
    self._nodeSkAniRoomSelect = nil

    cc.exports.zeroBezelNodeAutoAdapt(self._opePanel)
    UIHelper:calcGridLayoutConfig(self._scrollViewRooms, SecondLayerNormal.roomListLayoutConfig, "fillInitColumsAndAveragePaddingGap", nil)
    self:_initTopBar()
    self:_initLeftTab()
    self:_initRoomSelectAni()
    self:_initPanelQuickStart()
end

function SecondLayerNormal:_initTopBar()
    local btnBack = self._panelTop:getChildByName("Button_Back")

    btnBack:addClickEventListener(handler(self, self._onClickBtnBack))
    SubViewHelper:initTopBar(self._panelTop, handler(self._roomManager._mainCtrl, self._roomManager._mainCtrl.onClickExit))
end

function SecondLayerNormal:_initPanelQuickStart()
    local btnQuickStart = self._panelQuickStart:getChildByName("Button_QuickStart")

    btnQuickStart:addClickEventListener(function()
        my.playClickBtnSound()
        self._roomManager:doQuickStartGame(self._roomManager._roomContextOut["areaEntry"])
    end)

    SubViewHelper:setQuickStartAni(self._panelQuickStart)
end

function SecondLayerNormal:_initLeftTab()
    local spTabNoShuffle = self._panelLeft:getChildByName("Sprite_Tab_NoShuffle")
    local btnTabNoShuffle = self._panelLeft:getChildByName("Button_Tab_NoShuffle")
    local spTabClassic = self._panelLeft:getChildByName("Sprite_Tab_Classic")
    local btnTabClassic = self._panelLeft:getChildByName("Button_Tab_Classic")
    local spTabJiSu = self._panelLeft:getChildByName("Sprite_Tab_JiSu")
    local btnTabJiSu = self._panelLeft:getChildByName("Button_Tab_JiSu")

    btnTabNoShuffle:setPosition(cc.p(58, 340))
    btnTabClassic:setPosition(cc.p(58, 190))
    btnTabJiSu:setPosition(cc.p(58, 40))

    btnTabNoShuffle:onTouch(function(e)
		if e.name=='began' then
            spTabNoShuffle:setVisible(true)
		elseif e.name=='ended' or e.name=='cancelled' then
            spTabNoShuffle:setVisible(false)
            if e.name=='ended' then
                my.playClickBtnSound()
                self:_switchAreaEntry("noshuffle")
            end
		end
	end)
    btnTabClassic:onTouch(function(e)
		if e.name=='began' then
            spTabClassic:setVisible(true)
		elseif e.name=='ended' or e.name=='cancelled' then
            spTabClassic:setVisible(false)
            if e.name=='ended' then
                my.playClickBtnSound()
                self:_switchAreaEntry("classic")
            end
		end
    end)
    btnTabJiSu:onTouch(function(e)
		if e.name=='began' then
            spTabJiSu:setVisible(true)
		elseif e.name=='ended' or e.name=='cancelled' then
            spTabJiSu:setVisible(false)
            if e.name=='ended' then
                my.playClickBtnSound()
                self:_switchAreaEntry("jisu")
            end
		end
	end)
end

function SecondLayerNormal:runEnterAni(isNeedLeft)
    if true then
        local nodeTarget = self._scrollViewRooms
        if nodeTarget.posXRaw == nil then
            nodeTarget.posXRaw = nodeTarget:getPositionX()
        end

        local curPosX = nodeTarget:getPositionX()
        if curPosX > nodeTarget.posXRaw then
            return --动画正在进行中
        end

        --先设定好初始位置和透明度，下一帧再执行帧动画，可以更流畅
        nodeTarget:setPositionX(nodeTarget.posXRaw + 500)
        nodeTarget:setOpacity(10)

        my.scheduleOnce(function()
            local moveAction = cc.MoveTo:create(0.4, cc.p(nodeTarget.posXRaw, nodeTarget and nodeTarget.getPositionY and nodeTarget:getPositionY()))
            local fadeAction = cc.FadeTo:create(0.4, 255)
            local spawnAction = cc.Spawn:create(cc.EaseBackOut:create(moveAction), fadeAction)
            nodeTarget:runAction(spawnAction)
        end, 0)
    end

    if isNeedLeft == false then
    else
        local nodeTarget = self._panelLeft
        if nodeTarget.posXRaw == nil then
            nodeTarget.posXRaw = nodeTarget:getPositionX()
        end

        --先设定好初始位置和透明度，下一帧再执行帧动画，可以更流畅
        nodeTarget:setPositionX(nodeTarget.posXRaw - 200)
        nodeTarget:setOpacity(10)

        my.scheduleOnce(function()
            local moveAction = cc.MoveTo:create(0.4, cc.p(nodeTarget.posXRaw, nodeTarget and nodeTarget.getPositionY and nodeTarget:getPositionY()))
            local fadeAction = cc.FadeTo:create(0.4, 255)
            local spawnAction = cc.Spawn:create(cc.EaseBackOut:create(moveAction), fadeAction)
            nodeTarget:runAction(spawnAction)
        end, 0)
    end
end

function SecondLayerNormal:_switchAreaEntry(targetAreaEntry)
    if targetAreaEntry ~= "noshuffle" and targetAreaEntry ~= "classic" and targetAreaEntry ~= "jisu" then
        return
    end

    if targetAreaEntry == "noshuffle" then
        if RoomListModel:checkAreaEntryAvail(targetAreaEntry) == false then
            local boutNum = cc.exports.getNewUserGuideBoutCount()
            local strTip = string.format(self._roomManager._roomStrings["NEW_PLAYER_LOCK_TIPS"], boutNum )
            self._roomManager:_showTip(strTip)
            return
        end
    end

    if targetAreaEntry == "jisu" then
        if not cc.exports.isJiSuRoomSupported() then
            self._roomManager:_showTip("暂未开始，敬请期待！")
            return
        end
        if RoomListModel:checkAreaEntryAvail(targetAreaEntry) == false then
            local boutNum = cc.exports.getNewUserGuideBoutCount()
            local strTip = string.format(self._roomManager._roomStrings["NEW_PLAYER_LOCK_TIPS"], boutNum )
            self._roomManager:_showTip(strTip)
            return
        end
    end

    self._roomManager._roomContextOut["areaEntry"] = targetAreaEntry
    self:refreshView()
    self:runEnterAni(false)
end

function SecondLayerNormal:refreshView()
    self:refreshTopBarInfo()
    self:refreshLeftTabInfo()
    self:_createRoomList(self._roomManager._roomContextOut["areaEntry"])
    self:refreshPanelQuickStart()

    self._areaEntryByLayer = self._roomManager._roomContextOut["areaEntry"]
end

function SecondLayerNormal:refreshViewOnDepositChange()
    self:refreshTopBarInfo()
    self:refreshPanelQuickStart()
end

function SecondLayerNormal:onRoomPlayerNumUpdated()
    for i = 1, #self._roomBtnsInfo do
        local roomNode = self._roomBtnsInfo[i]["roomNode"]
        local roomInfo = self._roomBtnsInfo[i]["roomInfo"]
        if roomNode and roomInfo then
            local panelBasicInfo = roomNode:getChildByName("Panel_BasicInfo")
            local labelPlayerNum = panelBasicInfo:getChildByName("Text_Online")

            local onlineUserCount = roomInfo["nUsers"]
            if onlineUserCount and onlineUserCount ~= "" then
                labelPlayerNum:setString(onlineUserCount)
            end
        end
    end
end

function SecondLayerNormal:refreshTopBarInfo()
    local spriteGameMode = self._panelTop:getChildByName("Sprite_GameMode")

    local spriteFrameName = "hallcocosstudio/images/plist/room_img/text_noshuffle.png"
    if self._roomManager._roomContextOut["areaEntry"] == "classic" then
        spriteFrameName = "hallcocosstudio/images/plist/room_img/img_classicmode.png"
    elseif self._roomManager._roomContextOut["areaEntry"] == "noshuffle" then
        spriteFrameName = "hallcocosstudio/images/plist/room_img/text_noshuffle.png"
    elseif self._roomManager._roomContextOut["areaEntry"] == "jisu" then
        spriteFrameName = "hallcocosstudio/images/plist/room_img/text_jisu.png"
    end

    local spriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(spriteFrameName)
    if spriteFrame and not tolua.isnull(spriteGameMode) then
        spriteGameMode:setSpriteFrame(spriteFrame)
    end
    
    SubViewHelper:setTopBarInfo(self._panelTop)
end

function SecondLayerNormal:refreshLeftTabInfo()
    local spTabNoShuffle = self._panelLeft:getChildByName("Sprite_Tab_NoShuffle")
    local btnTabNoShuffle = self._panelLeft:getChildByName("Button_Tab_NoShuffle")
    local spTabClassic = self._panelLeft:getChildByName("Sprite_Tab_Classic")
    local btnTabClassic = self._panelLeft:getChildByName("Button_Tab_Classic")
    local spTabJiSu = self._panelLeft:getChildByName("Sprite_Tab_JiSu")
    local btnTabJiSu = self._panelLeft:getChildByName("Button_Tab_JiSu")

    if self._roomManager._roomContextOut["areaEntry"] == "noshuffle" then
        spTabNoShuffle:setVisible(true)
        spTabClassic:setVisible(false)
        spTabJiSu:setVisible(false)

        btnTabNoShuffle:setTouchEnabled(false)
        btnTabClassic:setTouchEnabled(true)
        btnTabJiSu:setTouchEnabled(true)
    elseif self._roomManager._roomContextOut["areaEntry"] == "jisu" then
        spTabNoShuffle:setVisible(false)
        spTabClassic:setVisible(false)
        spTabJiSu:setVisible(true)

        btnTabNoShuffle:setTouchEnabled(true)
        btnTabClassic:setTouchEnabled(true)
        btnTabJiSu:setTouchEnabled(false)
    else
        spTabNoShuffle:setVisible(false)
        spTabClassic:setVisible(true)
        spTabJiSu:setVisible(false)

        btnTabNoShuffle:setTouchEnabled(true)
        btnTabClassic:setTouchEnabled(false)
        btnTabJiSu:setTouchEnabled(true)
    end
end

function SecondLayerNormal:_createRoomList(areaEntry)
    local scrollViewRoomList = self._scrollViewRooms

    local roomInfoList = {}
    if areaEntry == "noshuffle" then
        roomInfoList = RoomListModel:gradeRoomsToList(RoomListModel.gradeRoomsNoShuffle)
    elseif areaEntry == "jisu" then
        roomInfoList = RoomListModel:gradeRoomsToList(RoomListModel.gradeRoomsJiSu)
    else
        roomInfoList = RoomListModel:gradeRoomsToList(RoomListModel.gradeRoomsClassic)
    end

    scrollViewRoomList:removeAllChildren()
    self._roomBtnsInfo = {}

    local hideRoomCount = 0
    for i = 1, #roomInfoList do
        if cc.exports.isHideJuniorRoomSupported() and toint(cc.exports.getHideJuniorRoomID()) == toint(roomInfoList[i]["nRoomID"]) then
            hideRoomCount = hideRoomCount + 1
            print("Hide This Room %d", toint(roomInfoList[i]["nRoomID"]))
        else
            self:_createNextRoomItem(scrollViewRoomList, i - hideRoomCount, areaEntry, roomInfoList[i], self._roomBtnsInfo)
        end
    end
end

function SecondLayerNormal:_createNextRoomItem(scrollView, itemIndex, areaEntry, roomInfo, itemList)
    local nodeRoomBtn = self:_createRoomBtn(areaEntry, roomInfo)
    if nodeRoomBtn then
        local pos = UIHelper:calcGridItemPosEx(SecondLayerNormal.roomListLayoutConfig, itemIndex)
        nodeRoomBtn:setPosition(pos)
        scrollView:addChild(nodeRoomBtn)
            
        local itemData = {["roomInfo"] = roomInfo, ["roomNode"] = nodeRoomBtn}
        table.insert(itemList, itemData)

        self:_initRoomBtn(itemData)
        self:refreshRoomBtnInfo(itemData)
    end
end

function SecondLayerNormal:_initRoomBtn(roomBtnInfo)
    local roomNode = roomBtnInfo["roomNode"]
    local roomInfo = roomBtnInfo["roomInfo"]

    cc.exports.UIHelper:setTouchByScale(roomNode, function()
        my.playClickBtnSound()
        if self:_checkEnterAniDone() == false then
            print("_checkEnterAniDone false")
            return
        end
        if not UIHelper:checkOpeCycle("SecondLayerNormal_roomNode") then
            return
        end
        UIHelper:refreshOpeBegin("SecondLayerNormal_roomNode")
        print("onClick enter normal room "..tostring(roomInfo["nRoomID"]))

        self._roomManager:tryEnterRoom(roomInfo["nRoomID"], false, nil)
    end, roomNode, 1.1)

    if self._quickStartRoomInfo and self._quickStartRoomInfo["nRoomID"] == roomInfo["nRoomID"] then
        self:_refreshRoomSelectAni(self._quickStartRoomInfo)
    end
end

function SecondLayerNormal:_initRoomSelectAni()
    local nodeMount = self._opePanel
    local nodeName = "nodeSkeletonAni"
    local skAniConfig = SecondLayerNormal.skAniInfo_RoomSelect
	if nodeMount:getChildByName(nodeName) == nil then
		local skAni = sp.SkeletonAnimation:create(skAniConfig["jsonPath"], skAniConfig["atlasPath"], 1.0)  
		skAni:setAnimation(0, skAniConfig["aniNames"][1], true)
		skAni:setDebugBonesEnabled(false)
		skAni:setName(nodeName)
		nodeMount:addChild(skAni)

        self._nodeSkAniRoomSelect = skAni
        self._nodeSkAniRoomSelect:retain()
	end
end

function SecondLayerNormal:refreshRoomBtnInfo(roomBtnInfo)
    local roomNode = roomBtnInfo["roomNode"]
    local roomInfo = roomBtnInfo["roomInfo"]
   
    local imgRoomBg = roomNode:getChildByName("Img_RoomBG")                             -- 房间二级界面按钮 背景
    local spriteRoomName = roomNode:getChildByName("Sprite_RoomName")                   -- 房间二级界面按钮 名称
    local spriteBaseDepositBG = roomNode:getChildByName("Sprite_BaseDeposit")           -- 房间二级界面按钮 底银背景
    local bfBaseDeposit = roomNode:getChildByName("Bf_BaseDeposit")                     -- 房间二级界面按钮 低银
    local panelBasicInfo = roomNode:getChildByName("Panel_BasicInfo")
    panelBasicInfo:getChildByName("Image_BottomBarBk"):setVisible(false)                      -- 隐藏底部一个阴影横条
    local iconDeposit = panelBasicInfo:getChildByName("Img_IconDeposit")
    local textOnline = panelBasicInfo:getChildByName("Text_Online")
    local textDeposit = panelBasicInfo:getChildByName("Text_Deposit")
    local imgLTFlag = roomNode:getChildByName("Img_LTFlag")
    local imgRTFlag = roomNode:getChildByName("Img_RTFlag")
    local imgLimitOpenTimeFlag = roomNode:getChildByName("Img_LimitTimeOpenFlag")
    local imgOpenTime = roomNode:getChildByName("Img_OpenTime")
    local textOpenTime = roomNode:getChildByName("Img_OpenTime"):getChildByName("Text_OpenTime")

    -- 设置背景
    local gradeIndex = roomInfo["gradeIndex"]
    local areaEntry = self._roomManager._roomContextOut["areaEntry"]
    if areaEntry == "noshuffle" then
        local roomInfoList = RoomListModel:gradeRoomsToList(RoomListModel.gradeRoomsNoShuffle)
        if  gradeIndex >= #roomInfoList then
            gradeIndex = #roomInfoList - 1
        end
        imgRoomBg:loadTexture("hallcocosstudio/images/plist/room_img/img_noshuffle_roombk_"..gradeIndex..".png", ccui.TextureResType.plistType)
    elseif areaEntry == "jisu" then
        local roomInfoList = RoomListModel:gradeRoomsToList(RoomListModel.gradeRoomsJiSu)
        if  gradeIndex > #roomInfoList then
            gradeIndex = #roomInfoList - 1
        end
        if gradeIndex < 1 then
            gradeIndex = 1
        end
        imgRoomBg:loadTexture("hallcocosstudio/images/plist/room_img/img_jisu_roombk_"..gradeIndex..".png", ccui.TextureResType.plistType)
    else
        local roomInfoList = RoomListModel:gradeRoomsToList(RoomListModel.gradeRoomsClassic)
        if  gradeIndex > #roomInfoList then
            gradeIndex = #roomInfoList - 1
        end
        imgRoomBg:loadTexture("hallcocosstudio/images/plist/room_img/img_roombk_"..gradeIndex..".png", ccui.TextureResType.plistType)     
    end
    -- 设置房间名称
    local spriteFrameName = ""
    if areaEntry == "noshuffle" then
        spriteFrameName = "hallcocosstudio/images/plist/room_img/img_text_noshuffle_"..roomInfo["gradeName"].."room.png"
    elseif areaEntry == "jisu" then
        spriteFrameName = "hallcocosstudio/images/plist/room_img/img_text_jisu_"..roomInfo["gradeName"].."room.png"
    else
        spriteFrameName = "hallcocosstudio/images/plist/room_img/img_text_"..roomInfo["gradeName"].."room.png"
    end
    local spriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(spriteFrameName)
    spriteRoomName:setSpriteFrame(spriteFrame)

    --设置人数
    local onlineUserCount = roomInfo["nUsers"]
    if onlineUserCount and onlineUserCount ~= "" then
        textOnline:setString(onlineUserCount)
    end

    -- 设置银两区间
    local maxRoomDeposits = roomInfo["nMaxDeposit"]
    if maxRoomDeposits == 2000000000 then -- 表示房间无上限
        local strDepositFrom = my.convertMoneyToTenThousand(roomInfo["nMinDeposit"])
        textDeposit:setString("≥" .. strDepositFrom)
    else
        local strDepositFrom = my.convertMoneyToTenThousand(roomInfo["nMinDeposit"])
        local strDepositTo = my.convertMoneyToTenThousand(roomInfo["nMaxDeposit"])
        textDeposit:setString(strDepositFrom.."-"..strDepositTo)
    end
    iconDeposit:setPositionX(textDeposit:getPositionX() - textDeposit:getContentSize().width - 6)

    self:refreshRoomBtnNodeLeftFlag(roomBtnInfo)

    imgRTFlag:setVisible(RoomListModel:isRoomDoubleExchangeAvail(roomInfo["nRoomID"]))
    imgLimitOpenTimeFlag:setVisible(RoomListModel:isLimitTimeOpenRoom(roomInfo["nRoomID"]))
    imgOpenTime:setVisible(RoomListModel:isLimitTimeOpenRoom(roomInfo["nRoomID"]))
    --设置开放时间
    if RoomListModel:isLimitTimeOpenRoom(roomInfo["nRoomID"]) then
        local startHour, startMinute, endHour, endMinute = RoomListModel:getOpenTime(roomInfo["nRoomID"])
        local strOpenTime = string.format("%2d:%02d-%2d:%02d", startHour, startMinute, endHour, endMinute)
        textOpenTime:setString(strOpenTime)
        if areaEntry == "noshuffle" then
            imgOpenTime:loadTexture('hallcocosstudio/images/plist/room_img/img_timetip.png', ccui.TextureResType.plistType)
        elseif areaEntry == 'classic' then
            imgOpenTime:loadTexture('hallcocosstudio/images/plist/room_img/img_timetip1.png', ccui.TextureResType.plistType)
        end
    end

    -- 设置底银
    local spriteBaseDepositName = ""
    if areaEntry == "noshuffle" then
        spriteBaseDepositName = "hallcocosstudio/images/plist/room_img/img_noshuffle_basedeposit.png"
    elseif areaEntry == "jisu" then
        spriteBaseDepositName = "hallcocosstudio/images/plist/room_img/img_jisu_basedeposit.png"
    else
        spriteBaseDepositName = "hallcocosstudio/images/plist/room_img/img_basedeposit.png"
    end
    local spriteBaseDepositFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(spriteBaseDepositName)
    spriteBaseDepositBG:setSpriteFrame(spriteBaseDepositFrame)
    bfBaseDeposit:setString(RoomListModel:getRoomBaseDeposit(roomInfo["nRoomID"]))
end

function SecondLayerNormal:_createRoomBtn(areaEntry, roomInfo)
    local roomBtnConfig = self._roomManager.areaViewConfig[areaEntry]["roomBtn"]
    if roomBtnConfig == nil then return end
    if roomInfo["gradeIndex"] and roomInfo["gradeIndex"] > RoomListModel.MAX_ROOMGRADE_INDEX then
        print("exceed max room gradeindex "..tostring(RoomListModel.MAX_ROOMGRADE_INDEX))
        return nil
    end

    local roomBtnName = "roomBtn_"..roomInfo["gradeName"]
    local nodeRaw = cc.CSLoader:createNode(roomBtnConfig["csbPath"])
    local nodeRoomBtn = nodeRaw:getChildByName("Btn_Room")
    nodeRoomBtn:removeFromParent()
    nodeRoomBtn:setName(roomBtnName)

    return nodeRoomBtn
end

function SecondLayerNormal:refreshPanelQuickStart()
    local areaEntry = self._roomManager._roomContextOut["areaEntry"]
    self._quickStartRoomInfo = SubViewHelper:setQuickStartRoomInfo(self._panelQuickStart, areaEntry)
    self:_refreshRoomSelectAni(self._quickStartRoomInfo)
end

function SecondLayerNormal:_refreshRoomSelectAni(fitRoomInfo)
    print("SecondLayerNormal:_refreshRoomSelectAni")
    if fitRoomInfo == nil or self._nodeSkAniRoomSelect == nil then
        self._nodeSkAniRoomSelect:setVisible(false)
        return 
    end

    local selectedRoomBtnInfo = nil
    for i = 1, #self._roomBtnsInfo do
        local roomNode = self._roomBtnsInfo[i]["roomNode"]
        local roomInfo = self._roomBtnsInfo[i]["roomInfo"]
        if roomNode and roomInfo then
            if roomInfo["nRoomID"] == fitRoomInfo["nRoomID"] then
                selectedRoomBtnInfo = self._roomBtnsInfo[i]
            elseif toint(fitRoomInfo["nRoomID"]) == toint(cc.exports.getHideJuniorRoomID()) and 
                   toint(roomInfo["nRoomID"]) == toint(cc.exports.getMergeHideJuniorRoomID()) then
                selectedRoomBtnInfo = self._roomBtnsInfo[i]
            end
        end
    end
    if selectedRoomBtnInfo == nil then
        print("no roomBtnInfo found by fitRoomInfo, roomId "..tostring(fitRoomInfo["nRoomID"]))
        self._nodeSkAniRoomSelect:setVisible(false)
        return
    end

    local roomNode = selectedRoomBtnInfo["roomNode"]
    self._nodeSkAniRoomSelect:setVisible(true)
    self._nodeSkAniRoomSelect:removeFromParent()
    roomNode:addChild(self._nodeSkAniRoomSelect)
    self._nodeSkAniRoomSelect:setPosition(cc.p(roomNode:getContentSize().width / 2, roomNode:getContentSize().height / 2))
end

function SecondLayerNormal:dealOnClose()
    if self._nodeSkAniRoomSelect then
        self._nodeSkAniRoomSelect:release()
        self._nodeSkAniRoomSelect = nil
    end
end

function SecondLayerNormal:refreshRoomBtnNodeLeftFlag(roomBtnInfo)
    if not roomBtnInfo or not roomBtnInfo["roomNode"] or not roomBtnInfo["roomInfo"] then return end
    local roomNode = roomBtnInfo["roomNode"]
    local roomInfo = roomBtnInfo["roomInfo"]
    local imgLTFlag = roomNode:getChildByName("Img_LTFlag")
    local imgNPLevelFlag = roomNode:getChildByName("Img_LTFlag_NPLevel")
    local textNPLevel = roomNode:getChildByName("Text_NPLevelLimit")
    local valueNPLevel = roomNode:getChildByName("Value_NPLevelLimit")

    -- 刷新房间贵族准入等级
    local NPLevel = NobilityPrivilegeModel:getRoomNPLevelLimit(roomInfo["nRoomID"])
    if NPLevel > 0 then
        imgLTFlag:setVisible(false)
        imgNPLevelFlag:setVisible(true)
        textNPLevel:setVisible(true)
        valueNPLevel:setVisible(true)
        valueNPLevel:setString(tostring(NPLevel))
        if NPLevel < 10 then
            textNPLevel:setString('贵族 准入')
        else
            textNPLevel:setString('贵族  准入')
        end
    else
        imgNPLevelFlag:setVisible(false)
        textNPLevel:setVisible(false)
        valueNPLevel:setVisible(false)

        local areaEntry = self._roomManager._roomContextOut["areaEntry"]
        -- 设置左上角标
        if areaEntry == "noshuffle" then
            imgLTFlag:setVisible(true)
            imgLTFlag:loadTexture("hallcocosstudio/images/plist/room_img/img_flag_noshuffle.png", ccui.TextureResType.plistType)
        elseif areaEntry == "jisu" then
            imgLTFlag:setVisible(true)
            imgLTFlag:loadTexture("hallcocosstudio/images/plist/room_img/img_flag_jisu.png", ccui.TextureResType.plistType)
        else
            imgLTFlag:setVisible(false)
        end
    end
end

function SecondLayerNormal:refreshNPLevelLimit()
    for k, v in pairs(self._roomBtnsInfo) do
        if v then
            self:refreshRoomBtnNodeLeftFlag(v)
        end
    end
end

return SecondLayerNormal