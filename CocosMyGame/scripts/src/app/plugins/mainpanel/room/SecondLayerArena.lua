local SecondLayerArena = class("SecondLayerArena", import(".SecondLayerBase"))

local RoomListModel = import("src.app.GameHall.room.model.RoomListModel"):getInstance()
local arenaRankData = require("src.app.plugins.ArenaRank.ArenaRankData"):getInstance()
local ArenaModel = require("src.app.plugins.arena.ArenaModel"):getInstance()
local arenaRankGroup = require("src.app.plugins.ArenaRank.ArenaRankGroupNew")
local UserModel = mymodel('UserModel'):getInstance()

function SecondLayerArena:ctor(layerNode, roomManager)
    SecondLayerArena.super.ctor(self, layerNode, roomManager)
    self.layerName = "arena"
    self._areaEntryByLayer = "arena"
    self._arenaRoomManager = roomManager.subArenaRoomManager

    self._arenaRoomViewData = {
        ["viewNodes"] = {},
        ["curIndex"] = 1 
    }

    self._arenaRankGroup = nil
    self._arenaRankGroupNode = nil
end

function SecondLayerArena:initView()
    local layerNode = self._layerNode
    self._opePanel = layerNode:getChildByName("Operate_Panel")
    self._panelTop = self._opePanel:getChildByName("Panel_Gameinfo")
    local panelArenaScene = self._opePanel:getChildByName("Panel_ArenaSence")
    self._panelRankGroup = panelArenaScene:getChildByName("Panel_Arena_Rank_Group")
    self._panelAreaHome = panelArenaScene:getChildByName("Panel_ArenaHome")
    self._panelChallenging = panelArenaScene:getChildByName("Panel_Challengeing")

    cc.exports.zeroBezelNodeAutoAdapt(self._opePanel)
    self:_initTopBar()
    self:_initPanelArenaHome()
    self:_initPanelChalleging()
    --self:_createRoomList(self._roomManager._roomContextOut["areaEntry"])
end

function SecondLayerArena:_initTopBar()
    local btnBack = self._panelTop:getChildByName("Btn_Back")
    local btnHallFame = self._panelTop:getChildByName("Btn_HallFame")
    local btnTutorial = self._panelTop:getChildByName("Btn_Tutorial")

    btnBack:addClickEventListener(handler(self, self._onClickBtnBack))
    btnHallFame:addClickEventListener(function()
        my.playClickBtnSound()
        my.informPluginByName({pluginName='ArenaRankTotalModel'})
    end)
    btnTutorial:addClickEventListener(function()
        my.playClickBtnSound()
        my.informPluginByName({pluginName='ArenaPlayerCourseCtrl'})
    end)
end

function SecondLayerArena:_initPanelArenaHome()
    if self._panelAreaHome == nil then return end

    local imgRoomScore = self._panelAreaHome:getChildByName("Img_RoomScore")
    local btnSwitchPrev = self._panelAreaHome:getChildByName("Btn_left")
    local btnSwitchNext = self._panelAreaHome:getChildByName("Btn_right")
    local btnStart = self._panelAreaHome:getChildByName("Btn_start")
    local btnSelectRoom = self._panelAreaHome:getChildByName("Btn_changeroom")
    local btnRewardInfo = self._panelAreaHome:getChildByName("Btn_rewardintroduce")
    local nodeScoreBub = self._panelAreaHome:getChildByName("Node_ScoreBub")

    self._arenaRoomViewData["viewNodes"] = {
        ["imgScoreBonus"] = imgRoomScore,
        ["imgTextScoreBonus"] = imgRoomScore:getChildByName("Img_Score"),
        ["labelScoreBonusVal"] = imgRoomScore:getChildByName("Fnt_Score"),
        ["imgRoomName"] = self._panelAreaHome:getChildByName("Img_RoomName"),
        ["imgRoomBird"] = self._panelAreaHome:getChildByName("Btn_room"),
        ["nodeScoreBub"] = nodeScoreBub,
        ["labelScoreBonusValOfBub"] = nodeScoreBub:getChildByName("Img_Bubble"):getChildByName("Text_BubbleScore"),
        ["labelDepositMin"] = self._panelAreaHome:getChildByName("Text_Condition_Liang"),
        ["labelOnlineVal"] = self._panelAreaHome:getChildByName("Text_Online"),
        ["btnRewardInfo"] = btnRewardInfo,
        ["imgRewardInfoLight"] = btnRewardInfo:getChildByName("Img_Light"),
        ["labelFreeTrial"] = self._panelAreaHome:getChildByName("Text_SurplusNum"),
    }

    btnSwitchPrev:addClickEventListener(function()
        my.playClickBtnSound()
        self:_clickSwitchRoom("prev")
    end)
    btnSwitchNext:addClickEventListener(function()
        my.playClickBtnSound()
        self:_clickSwitchRoom("next")
    end)

    local function changeRoomCallBack(index)
        local targetIndex = index
        if targetIndex < 1 then
            targetIndex = #ArenaModel.arenaRoomsInfo
        end
        if targetIndex > #ArenaModel.arenaRoomsInfo then
            targetIndex = 1
        end
        self._arenaRoomViewData["curIndex"] = targetIndex
        self:_refreshSelectedRoom(self._arenaRoomViewData["curIndex"])
        self._arenaRoomManager:goToArenaMatch(self._arenaRoomViewData["curIndex"])
    end

    btnStart:addClickEventListener(function()
        my.playClickBtnSound()
        if not UIHelper:checkOpeCycle("SecondLayerArena_btnStart") then
            return
        end
        UIHelper:refreshOpeBegin("SecondLayerArena_btnStart")
        self._arenaRoomManager:goToArenaMatch(self._arenaRoomViewData["curIndex"])
    end)
    btnSelectRoom:addClickEventListener(function()
        my.playClickBtnSound()
        local curMatchIndex = self._arenaRoomViewData["curIndex"]
        local params = {
            matchesInfo = ArenaModel.arenaFreeMatchesInfo, 
            roomsInfo = ArenaModel.arenaRoomsInfo, 
            callback = changeRoomCallBack
        }
        my.informPluginByName({pluginName='ArenaChangeRoomCtrl', params = params})
    end)
    btnRewardInfo:addClickEventListener(function()
        my.playClickBtnSound()
        local curMatchIndex = self._arenaRoomViewData["curIndex"]
        my.informPluginByName({pluginName = 'ArenaRewardInfoCtrl', params = ArenaModel.arenaSilverMatchesInfo[curMatchIndex]})
    end)
end

function SecondLayerArena:_initPanelChalleging()
    local btnGiveUp = self._panelChallenging:getChildByName("Btn_GiveUp")
    local btnContinue = self._panelChallenging:getChildByName("Btn_Continue")

    btnGiveUp:addClickEventListener(function()
        my.playClickBtnSound()
        local params = {
            userArenaData = ArenaModel.userArenaData,
            callbackContinue = handler(self._arenaRoomManager, self._arenaRoomManager.continueArenaMatch)
        }
        my.informPluginByName({pluginName = 'GiveUpToArenaCtrl', params = params})
    end)
    btnContinue:addClickEventListener(function()
        my.playClickBtnSound()

        if not UIHelper:checkOpeCycle("SecondLayerArena_btnContinue") then
            return
        end
        UIHelper:refreshOpeBegin("SecondLayerArena_btnContinue")

        local userArenaData = ArenaModel.userArenaData
        if userArenaData.nMatchID > 0 and userArenaData.nHP > 0 then
            self._arenaRoomManager:continueArenaMatch(userArenaData)
        else
            print("arena click btnContinue, but illegal matchid or hp <= 0, matchid "..tostring(userArenaData.nMatchID))
            print("hp "..tostring(userArenaData.nHP))
        end
    end)
end

function SecondLayerArena:_clickSwitchRoom(switchDirection)
    local curIndex = self._arenaRoomViewData["curIndex"]

    local targetIndex = curIndex
    if switchDirection == "prev" then
        targetIndex = curIndex - 1
    else
        targetIndex = curIndex + 1
    end
    if targetIndex < 1 then
        targetIndex = #ArenaModel.arenaRoomsInfo
    end
    if targetIndex > #ArenaModel.arenaRoomsInfo then
        targetIndex = 1
    end

    self._arenaRoomViewData["curIndex"] = targetIndex
    self:_refreshSelectedRoom(self._arenaRoomViewData["curIndex"])
end

function SecondLayerArena:_refreshSelectedRoom(targetIndex)
    local viewNodes = self._arenaRoomViewData["viewNodes"]
    local roomInfo = ArenaModel.arenaRoomsInfo[targetIndex]
    if roomInfo == nil then
        print("SecondLayerArena:_refreshSelectedRoom, but target roomInfo is nil, targetIndex "..tostring(targetIndex))
        return
    end

    local matchGradeIndex = math.max(math.min(roomInfo["gradeIndex"], 6), 1)
    local matchConfig = arenaRankData:getMatchConfig()
    local roomScoreBonus = matchConfig["RoomAddition_" .. roomInfo["nRoomID"]] or 0
    if roomScoreBonus > 0 then
        viewNodes.imgScoreBonus:setVisible(true)
        local imgJfjcIndex = math.max(matchGradeIndex - 2, 1) 
        local imgName = "hallcocosstudio/images/plist/Arena/img_jfjc_bg_"..imgJfjcIndex..".png"
        viewNodes.imgScoreBonus:loadTexture(imgName, ccui.TextureResType.plistType)
        imgName = "hallcocosstudio/images/plist/Arena/Arena_mark_zi"..imgJfjcIndex..".png"
        viewNodes.imgTextScoreBonus:loadTexture(imgName, ccui.TextureResType.plistType)

        viewNodes.labelScoreBonusVal:setString(roomScoreBonus .. "%")
        viewNodes.labelScoreBonusValOfBub:setString(roomScoreBonus .. "%")
        self:_showScoreBubbleAni(viewNodes.nodeScoreBub, true)
    else
        self:_showScoreBubbleAni(viewNodes.nodeScoreBub, false)
        viewNodes.imgScoreBonus:setVisible(false)
    end

    local onlineUserCount = roomInfo["nUsers"]
    if onlineUserCount and onlineUserCount ~= "" then
        viewNodes.labelOnlineVal:setString(onlineUserCount)
    end
    viewNodes.labelDepositMin:setString("≥"..roomInfo["nMinDeposit"])

    local imgIndex = math.max(matchGradeIndex - 1, 1)
    local imgName = "hallcocosstudio/images/plist/Arena/Arena_img_figure"..imgIndex..".png"
    viewNodes.imgRoomBird:loadTexture(imgName, ccui.TextureResType.plistType)

    imgIndex = matchGradeIndex
    imgName = "hallcocosstudio/images/plist/Arena/Arena_hc_zi"..imgIndex..".png"
    viewNodes.imgRoomName:loadTexture(imgName, ccui.TextureResType.plistType)

    imgIndex = math.max(matchGradeIndex - 1, 1)
    imgName = "hallcocosstudio/images/plist/Arena/Arena_btn_Reward"..imgIndex..".png"
    viewNodes.btnRewardInfo:loadTextureNormal(imgName, ccui.TextureResType.plistType)
    viewNodes.btnRewardInfo:loadTexturePressed(imgName, ccui.TextureResType.plistType)

    imgIndex = math.min(math.max(matchGradeIndex - 1, 1), 4)
    imgName = "hallcocosstudio/images/plist/Arena/Arena_btn_RewardG"..imgIndex..".png"
    viewNodes.imgRewardInfoLight:loadTexture(imgName, ccui.TextureResType.plistType)
end

function SecondLayerArena:_showScoreBubbleAni(nodeScoreBub, isShow)
    if isShow == false then
        nodeScoreBub:stopAllActions()
        nodeScoreBub:setVisible(false)
    else
        nodeScoreBub:stopAllActions()
        local aniScoreBub = cc.CSLoader:createTimeline('res/hallcocosstudio/arena/node_scorebub.csb')
        nodeScoreBub:runAction(aniScoreBub)
        aniScoreBub:play("animation0", true)
        nodeScoreBub:setVisible(true)
    end
end

function SecondLayerArena:refreshView()
    self:refreshTopBarInfo()

    self:showTutorialPanelIfNeeded()

    local userArenaData = ArenaModel.userArenaData
    local isMatchExist = (userArenaData.nMatchID and userArenaData.nMatchID > 0)--and dataMap.nHP > 0)
	if isMatchExist then 
		ArenaModel:getMatchInfoByMatchIDFromLocal(userArenaData.nMatchID)
        self._panelAreaHome:setVisible(false)
        self._panelChallenging:setVisible(true)
        self:refreshPanelChalleging(userArenaData, ArenaModel.userMatchInfo)       
	else
        self._panelAreaHome:setVisible(true)
        self._panelChallenging:setVisible(false)
        self:refreshPanelHome()
	end

    self:showArenaRankGroup()
end

function SecondLayerArena:refreshViewOnDepositChange()
    self:refreshTopBarInfo()
end

function SecondLayerArena:onRoomPlayerNumUpdated()
    local viewNodes = self._arenaRoomViewData["viewNodes"]
    local curIndex = self._arenaRoomViewData["curIndex"]
    local roomInfo = ArenaModel.arenaRoomsInfo[curIndex]
    if roomInfo and viewNodes.labelOnlineVal then
        local onlineUserCount = roomInfo["nUsers"]
        if onlineUserCount and onlineUserCount ~= "" then
            viewNodes.labelOnlineVal:setString(onlineUserCount)
        end
    end
end

function SecondLayerArena:showTutorialPanelIfNeeded()
    local myGameData = UserModel:getMyGameDataXml()
    if true ~= myGameData.arenaTutorial then
        myGameData.arenaTutorial = true
        UserModel:saveMyGameDataXml(myGameData)

        my.informPluginByName({pluginName='ArenaPlayerCourseCtrl'})
    end
end

function SecondLayerArena:refreshTopBarInfo()
    if self._panelTop == nil then return end

    local labelDeposit = self._panelTop:getChildByName("Text_PlayerDeposit")
    local labelScore = self._panelTop:getChildByName("Text_PlayerScore")

    labelDeposit:setString(UserModel.nDeposit or 0)
    labelScore:setString(UserModel.nScore or 0)
end

function SecondLayerArena:refreshPanelChalleging(userArenaData, userMatchInfo)
    local imgMatchGrade = self._panelChallenging:getChildByName("Text_FieldName")
    local labelScoreVal = self._panelChallenging:getChildByName("Text_ScoreValue")
    local imgBlood1 = self._panelChallenging:getChildByName("Img_Heart1")
    local imgBlood2 = self._panelChallenging:getChildByName("Img_Heart2")
    local imgBlood3 = self._panelChallenging:getChildByName("Img_Heart3")
    local imgBloods = {imgBlood1, imgBlood2, imgBlood3}

    local matchGradeIndex = ArenaModel:getMatchGradeIndex(userMatchInfo["nMatchID"])
    if matchGradeIndex == nil then
        print("ArenaModel:getMatchGradeIndex return nil")
        dump(ArenaModel.userArenaData)
        dump(ArenaModel.userMatchInfo)
        dump(ArenaModel.arenaFreeMatchesInfo)
        dump(ArenaModel.arenaSilverMatchesInfo)
        dump(ArenaModel.arenaRoomsInfo)
        return
    end
    local imgIndex = math.max(math.min(3 + matchGradeIndex, 9), 4)
    local imgName = "hallcocosstudio/images/plist/Arena/Arenap_zi"..imgIndex..".png"
    imgMatchGrade:loadTexture(imgName, ccui.TextureResType.plistType)
    labelScoreVal:setString(tostring(userArenaData.nMatchScore))

    --血量
    for i = 1, userArenaData.nHP do
        if i <= 3 then
            imgBloods[i]:setVisible(true)
        end
    end
    for i = userArenaData.nHP + 1, 3 do
        if i <= 3 then
            imgBloods[i]:setVisible(false)
        end
    end
end

function SecondLayerArena:refreshPanelHome()
    self._arenaRoomViewData["curIndex"] = 1
    local defaultRoomID = RoomListModel:findFitRoomByDeposit(UserModel.nDeposit, "arena", UserModel.nSafeboxDeposit)
    for i = 1, #ArenaModel.arenaRoomsInfo do
        if ArenaModel.arenaRoomsInfo[i]["nRoomID"] == defaultRoomID then
            self._arenaRoomViewData["curIndex"] = i
            break
        end
    end
    self:_refreshSelectedRoom(self._arenaRoomViewData["curIndex"])

    --剩余次数
    local viewNodes = self._arenaRoomViewData["viewNodes"]
    local signUpRemainCount = ArenaModel:GetSignUpCountToday()
    if signUpRemainCount < 0 then
        viewNodes.labelFreeTrial:setString("0")
    else
        viewNodes.labelFreeTrial:setString(signUpRemainCount)
    end
end

function SecondLayerArena:showArenaRankGroup()
    local width = self._panelRankGroup:getContentSize().width
    local height = self._panelRankGroup:getContentSize().height
      
    arenaRankData:request()
    --self:destroyArenaRankGroupIfExist() --如果原来有，则先删除
    
    self._arenaRankGroup = arenaRankGroup:create()
    self._arenaRankGroupNode = self._arenaRankGroup:generate()
    self._arenaRankGroupNode:setPosition(cc.p(width /2, height / 2))
    self._panelRankGroup:addChild(self._arenaRankGroupNode)

    self._arenaRankGroup:startAranaRankFrushTimer()
end

function SecondLayerArena:destroyArenaRankGroupIfExist()
    if self._arenaRankGroup then
        self._arenaRankGroup:stopAranaRankFrushTimer()

        if self._arenaRankGroupNode then
            self._arenaRankGroupNode:removeFromParent()
            self._arenaRankGroupNode = nil
        end        
        self._arenaRankGroup:destroy()
        self._arenaRankGroup = nil
    end
end

function SecondLayerArena:onKeyback()
    self._roomManager:closeSecondeLayer(true)
    return true
end

function SecondLayerArena:dealOnClose()
    self:destroyArenaRankGroupIfExist()
end

return SecondLayerArena