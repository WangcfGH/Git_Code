local SecondLayerJoy = class("SecondLayerJoy", import(".SecondLayerBase"))

local RoomListModel = import("src.app.GameHall.room.model.RoomListModel"):getInstance()
local HallContext = import('src.app.plugins.mainpanel.HallContext'):getInstance()
local AssistCommon = import("src.app.GameHall.models.assist.common.AssistCommon"):getInstance()
local WeakenScoreRoomModel = require('src.app.plugins.weakenscoreroom.WeakenScoreRoomModel'):getInstance()
local config = cc.exports.GetRoomConfig()

function SecondLayerJoy:ctor(layerNode, roomManager)
    SecondLayerJoy.super.ctor(self, layerNode, roomManager)
    self.layerName = "joy"
    self._areaEntryByLayer = "joy"
end

function SecondLayerJoy:initView()
    local layerNode = self._layerNode
    self._opePanel = layerNode:getChildByName("Operate_Panel")
    self._panelTop = self._opePanel:getChildByName("Panel_Top")
    self._panelRoomList = self._opePanel:getChildByName("Panel_RoomList")
    self._roomBtnOffline = self._panelRoomList:getChildByName("Btn_Room_Offline")
    self._roomBtnOffline.posXRaw = self._roomBtnOffline:getPositionX()
    self._roomBtnScore = self._panelRoomList:getChildByName("Btn_Room_Score")

    cc.exports.zeroBezelNodeAutoAdapt(self._opePanel)
    self:_initTopBar()
    self:_initPanelRoomList()
end

function SecondLayerJoy:_initTopBar()
    local btnBack = self._panelTop:getChildByName("Button_Back")

    btnBack:addClickEventListener(handler(self, self._onClickBtnBack))
    SubViewHelper:initTopBar(self._panelTop, handler(self._roomManager._mainCtrl, self._roomManager._mainCtrl.onClickExit))
end

function SecondLayerJoy:_initPanelRoomList()
    cc.exports.UIHelper:setTouchByScale(self._roomBtnOffline, function()
        my.playClickBtnSound()
        if self:_checkEnterAniDone() == false then
            print("_checkEnterAniDone false")
            return
        end
        if not UIHelper:checkOpeCycle("SecondLayerJoy_BtnOffline") then
            return
        end
        UIHelper:refreshOpeBegin("SecondLayerJoy_BtnOffline")
        print("onClick enter offline room ")
        self._roomManager:tryEnterOfflineRoom()
    end, self._roomBtnOffline, 1.1)

    cc.exports.UIHelper:setTouchByScale(self._roomBtnScore, function()
        my.playClickBtnSound()
        if self:_checkEnterAniDone() == false then
            print("_checkEnterAniDone false")
            return
        end
        if not UIHelper:checkOpeCycle("SecondLayerJoy_BtnScore") then
            return
        end
        UIHelper:refreshOpeBegin("SecondLayerJoy_BtnScore")
        self:_onClickRoomBtnScore()
    end, self._roomBtnScore, 1.1)
end

function SecondLayerJoy:runEnterAni()
    local nodeTarget = self._panelRoomList
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
        local moveAction = cc.MoveTo:create(0.4, cc.p(nodeTarget.posXRaw, nodeTarget:getPositionY()))
        local fadeAction = cc.FadeTo:create(0.4, 255)
        local spawnAction = cc.Spawn:create(cc.EaseBackOut:create(moveAction), fadeAction)
        nodeTarget:runAction(spawnAction)
    end, 0)
end

function SecondLayerJoy:refreshView()
    self:refreshTopBarInfo()
    self:refreshScoreRoomBtnInfo()

    self.TouchScoreRoomBtnEnable = true -- 根据经典那边的逻辑推断，此处要加上这个标志位控制
end

function SecondLayerJoy:refreshViewOnDepositChange()
    self:refreshTopBarInfo()
    self:refreshScoreRoomBtnInfo()
end

function SecondLayerJoy:onRoomPlayerNumUpdated()
    local roomInfo = RoomListModel.scoreRoomInfo
    if self._roomBtnScore:isVisible() and roomInfo then
        local textOnline = MapOperator:getSubElement(self._roomBtnScore, "Panel_BasicInfo.Text_Online")

        local onlineUserCount = roomInfo["nUsers"]
        if onlineUserCount and onlineUserCount ~= "" then
            textOnline:setString(onlineUserCount)
        end
    end
end

function SecondLayerJoy:refreshTopBarInfo()
    local spriteGameMode = self._panelTop:getChildByName("Sprite_GameMode")

    local spriteFrameName = "hallcocosstudio/images/plist/room_img/img_joymode.png"
    local spriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(spriteFrameName)

    if spriteGameMode and not tolua.isnull(spriteGameMode) and spriteFrame then
        spriteGameMode:setSpriteFrame(spriteFrame)
    end

    SubViewHelper:setTopBarInfo(self._panelTop)
end

function SecondLayerJoy:refreshScoreRoomBtnInfo()
    dump(cc.exports._gameJsonConfig.WeakenScoreRoom, "WeakenScoreRoom")
    dump(cc.exports.nScoreInfo, "nScoreInfo")
    
    local roomInfo = RoomListModel.scoreRoomInfo

    local textOnline = MapOperator:getSubElement(self._roomBtnScore, "Panel_BasicInfo.Text_Online")
    local textDepositLimit = MapOperator:getSubElement(self._roomBtnScore, "Panel_BasicInfo.Text_Deposit")

    local isShow = false --默认不显示

    if roomInfo == nil or HallContext:isLogoff() == true then
        isShow = false
    elseif cc.exports._gameJsonConfig.WeakenScoreRoom 
    and cc.exports._gameJsonConfig.WeakenScoreRoom.Open 
    and cc.exports._gameJsonConfig.WeakenScoreRoom.Open == 1 then
        if cc.exports.nScoreInfo.nTrigger 
        and cc.exports.nScoreInfo.nTrigger == 1 then
            if cc.exports.nScoreInfo.nScore 
            and cc.exports._gameJsonConfig.WeakenScoreRoom.Score 
            and cc.exports.nScoreInfo.nScore < cc.exports._gameJsonConfig.WeakenScoreRoom.Score then --触发，没有领奖
                isShow = true
            end
        end
    elseif cc.exports._gameJsonConfig.WeakenScoreRoom 
    and cc.exports._gameJsonConfig.WeakenScoreRoom.Open 
    and cc.exports._gameJsonConfig.WeakenScoreRoom.Open == 0 then
        isShow = true
    end
    if isShow == true then
        self._roomBtnScore:setVisible(true)
        if self._roomBtnOffline.posXRaw then
            self._roomBtnOffline:setPositionX(self._roomBtnOffline.posXRaw)
        end

        --[[
        if self._roomManager:checkScoreRoomAvail() == false then
            self._roomBtnScore:setColor(cc.c3b(166, 166, 166))
        else
            self._roomBtnScore:setColor(cc.c3b(255, 255, 255))
        end
        --]]

        local onlineUserCount = roomInfo["nUsers"]
        if onlineUserCount and onlineUserCount ~= "" then
            textOnline:setString(onlineUserCount)
        end

        
        local silver = 2500
        local relief = cc.exports.gameReliefData
        if relief and relief.config and relief.config.Limit.LowerLimit then
            silver = relief.config.Limit.LowerLimit
        end
        textDepositLimit:setString("<"..silver)
        
        self:refreshRoomBtnNodeLeftFlag(self._roomBtnScore, roomInfo)
    else
        self:onHideRoomScore()
    end
end

function SecondLayerJoy:_onClickRoomBtnScore()
    print("onClick enter score room ")
    self:onTouchScoreRoomBtn()
end
function SecondLayerJoy:onHideRoomScore()
    self._roomBtnScore:setVisible(false)
    self._roomBtnOffline:setPositionX(self._panelRoomList:getContentSize().width / 2)
end


--[jfcrh]为了添加积分场限制条件
function SecondLayerJoy:onTouchScoreRoomBtn(index, roomList, isInGameTag)
    --[[local currentIndex = index or 3
    local RoomModelListEx = self._roomManager:storeRoomInfoEx(cc.exports.RoomModelList)

    local params = roomList or RoomModelListEx[currentIndex].RoomList
    if params == nil then
        return
    end]]
    local scoreRoomInfo = RoomListModel.scoreRoomInfo
    if scoreRoomInfo == nil then
        return
    end

    local function gotoScoreRoom()
        --[[ 原来的注释
        local roomInfo = params[1]
        roomInfo.nGroupId = NONE_GROUP_ID
        roomInfo.updateOnlineNum = false
        self:enterRoom(roomInfo)
        ]]
        self._roomManager:doGotoScoreGame()
        print("SecondLayerJoy:onTouchScoreRoomBtn gotoScoreRoom")
    end

    --gotoScoreRoom()

    local function popInSureDialog()
        local lastNoticeTime = CommonData:getUserData("scoreRoom_lastNoticeTime")
        if lastNoticeTime and DateUtil:isTodayTime(lastNoticeTime) then
            gotoScoreRoom()
            return
        else
            CommonData:setUserData("scoreRoom_lastNoticeTime", os.time())
            CommonData:saveUserData()
        end

        my.informPluginByName({
            pluginName = "ChooseDialog",
            params =
            {
                tipContent  = string.format(config['SCORE_ROOM_SCORE_IN'], cc.exports._gameJsonConfig.WeakenScoreRoom.Score),
                onOk        = gotoScoreRoom
            }
        })
    end

    local weakOpen = WeakenScoreRoomModel:onGetWeakOpen()
    local triggerStatus = WeakenScoreRoomModel:onCheckTriggerLimitStatus()
    local silverStatus = WeakenScoreRoomModel:onCheckSliverStatus()

    print("SecondLayerJoy:onTouchScoreRoomBtn silverStatus isInGame", silverStatus, isInGameTag)

    if not weakOpen then --没开限制活动
        gotoScoreRoom()
        return
    end

    local function checkBtnStatus(  )
        if silverStatus then  --已经破产
            if triggerStatus then --已经触发并且没有领奖
                popInSureDialog()
            elseif WeakenScoreRoomModel:onCheckScore() then --已经触发，已经领奖
                self:onHideRoomScore()
                my.informPluginByName({pluginName='TipPlugin',params={tipString=config["SCORE_ROOM_SCORE_OUT"],removeTime=1}})
            elseif WeakenScoreRoomModel:onCheckStatusFromServer() then --触发信息已经过期，重新获取
                self.TouchScoreRoomBtnEnable = false
                cc.exports.nScoreInfoNeedResponse = 0
                WeakenScoreRoomModel:sendGetTriggerInfo()
                my.scheduleOnce(function()
                    if cc.exports.nScoreInfoNeedResponse == 0 then  --防止客户端跟服务器之间连接有问题
                        popInSureDialog()
                    elseif cc.exports.nScoreInfoNeedResponse == 1 then
                        if WeakenScoreRoomModel:onCheckTriggerLimitStatusAgain() then
                            popInSureDialog()
                        else
                            self:onHideRoomScore()
                            my.informPluginByName({pluginName='TipPlugin',params={tipString=config["SCORE_ROOM_SCORE_WARNNING"],removeTime=1}})
                        end
                    end
                    cc.exports.nScoreInfoNeedResponse = -1
                    self.TouchScoreRoomBtnEnable = true
                end, 2)
            else
                my.informPluginByName({pluginName='TipPlugin',params={tipString=config["SCORE_ROOM_SCORE_WARNNING"],removeTime=1}})
            end
        else
            my.informPluginByName({pluginName='TipPlugin',params={tipString=config["SCORE_ROOM_SCORE_SILVER"],removeTime=1}})
        end
    end
    if isInGameTag then  --从游戏中跳转
        checkBtnStatus()
        return
    end

    if cc.exports.nScoreInfoNeedResponse == 0 and not self.TouchScoreRoomBtnEnable then
        my.informPluginByName({pluginName='TipPlugin',params={tipString=config["SCORE_ROOM_IS_WAITTING"],removeTime=1}})
        return
    end

    checkBtnStatus()
end

function SecondLayerJoy:dealOnClose()
end

function SecondLayerJoy:refreshNPLevelLimit()
    if self._roomBtnScore and RoomListModel.scoreRoomInfo then
        self:refreshRoomBtnNodeLeftFlag(self._roomBtnScore, RoomListModel.scoreRoomInfo)
    end
end

function SecondLayerJoy:refreshRoomBtnNodeLeftFlag(roomNode, roomInfo)
    local imgNPLevelFlag = roomNode:getChildByName("Img_LTFlag_NPLevel")
    local textNPLevel = roomNode:getChildByName("Text_NPLevelLimit")
    local valueNPLevel = roomNode:getChildByName("Value_NPLevelLimit")

    --代码保护，防止资源获取不到或者被销毁后再去访问
    if not imgNPLevelFlag or not textNPLevel or not valueNPLevel then 
       return
    end

    local NobilityPrivilegeModel = import("src.app.plugins.NobilityPrivilege.NobilityPrivilegeModel"):getInstance()
    -- 刷新房间贵族准入等级
    local NPLevel = NobilityPrivilegeModel:getRoomNPLevelLimit(roomInfo["nRoomID"])
    if NPLevel > 0 then
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
    end
end

return SecondLayerJoy