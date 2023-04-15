local SecondLayerAnchorMatch = class("SecondLayerAnchorMatch", import(".SecondLayerBase"))

local RoomListModel = import("src.app.GameHall.room.model.RoomListModel"):getInstance()
local HallContext = import('src.app.plugins.mainpanel.HallContext'):getInstance()
local AssistCommon = import("src.app.GameHall.models.assist.common.AssistCommon"):getInstance()

local TimingGameModel = import('src.app.plugins.TimingGame.TimingGameModel'):getInstance()

function SecondLayerAnchorMatch:ctor(layerNode, roomManager)
    SecondLayerAnchorMatch.super.ctor(self, layerNode, roomManager)
    self.layerName = "timing"
    self._areaEntryByLayer = "timing"

    self._roomStrings = HallContext.context["roomStrings"]

    self._roomContextOut = HallContext.context["roomContext"] --导出的上下文，提供外部访问                    
end

function SecondLayerAnchorMatch:initView()
    local layerNode = self._layerNode
    self._opePanel = layerNode:getChildByName("Operate_Panel")
    self._panelTop = self._opePanel:getChildByName("Panel_Top")
    self._panelRoomList = self._opePanel:getChildByName("Panel_RoomList")
    self._roomBtnArena = self._panelRoomList:getChildByName("Btn_Room_Arena")
    self._roomBtnArena.posXRaw = self._roomBtnArena:getPositionX()
    self._roomBtnAnchor = self._panelRoomList:getChildByName("Btn_Room_Anchor")
    self._lockAnchor = self._panelRoomList:getChildByName("Sprite_Lock_Anchor")
    self._roomBtnTiming = self._panelRoomList:getChildByName("Btn_Room_Timing")
    self._imgBuyTicket = self._roomBtnTiming:getChildByName("Img_BuyTicket")
    self._imgRoomBg = self._roomBtnTiming:getChildByName("Img_RoomBG")
    self._btnBuyTicket = self._imgBuyTicket:getChildByName("Btn_BuyTicket")
    
    cc.exports.zeroBezelNodeAutoAdapt(self._opePanel)
    self:_initTopBar()
    self:_initPanelRoomList()
    self:_initTimingView()
end

function SecondLayerAnchorMatch:_initTimingView()
    local strStartEndTime = TimingGameModel:getStartEndTimeStr()
    local strDuration = TimingGameModel:getContinueTimeStr()

    local txtDesc1 = self._roomBtnTiming:getChildByName("Text_Desc")
    if txtDesc1 then
        txtDesc1:setString(strStartEndTime)
    end
    local txtDesc2 = self._roomBtnTiming:getChildByName("Text_Desc2")
    if txtDesc2 then
        txtDesc2:setString(strDuration)
    end

    local chaoGeRoomBg = cc.exports.getTimmingGameChaoGeRoomBg()
    if chaoGeRoomBg and chaoGeRoomBg == 1 then
        self._imgRoomBg:loadTexture("hallcocosstudio/images/plist/TimingGame/btn_dingshisai_chaoge.png", ccui.TextureResType.plistType)
    end

    local longQiRoomBg = cc.exports.getTimmingGameLongQiRoomBg()
    if longQiRoomBg and longQiRoomBg == 1 then
        self._imgRoomBg:loadTexture("hallcocosstudio/images/plist/TimingGame/btn_dingshisai_longqi.png", ccui.TextureResType.plistType)
    end
end

function SecondLayerAnchorMatch:_initTopBar()
    local btnBack = self._panelTop:getChildByName("Button_Back")

    btnBack:addClickEventListener(handler(self, self._onClickBtnBack))
    SubViewHelper:initTopBar(self._panelTop, handler(self._roomManager._mainCtrl, self._roomManager._mainCtrl.onClickExit))

    self._panelTicket = self._panelTop:getChildByName("Panel_Ticket")
    self._roomBtnGetTicket = self._panelTicket:getChildByName("Button_Add")    
    self._textTicketValue = self._panelTicket:getChildByName("Bmf_Value")

    if cc.exports.isTimingGameSupported() then
        self:refreshTickets()
    else
        self._panelTicket:setVisible(false)
    end
end

function SecondLayerAnchorMatch:_initPanelRoomList()
    cc.exports.UIHelper:setTouchByScale(self._roomBtnAnchor, function()
        my.playClickBtnSound()
        if self:_checkEnterAniDone() == false then
            print("_checkEnterAniDone false")
            return
        end
        if not UIHelper:checkOpeCycle("SecondLayerAnchorMatch_BtnAnchor") then
            return
        end
        UIHelper:refreshOpeBegin("SecondLayerAnchorMatch_BtnAnchor")
        print("onClick enter anchor room ")
        
        my.informPluginByName({pluginName = "AnchorTableCtrl"})
    end, self._roomBtnAnchor, 1.1)

    cc.exports.UIHelper:setTouchByScale(self._roomBtnArena, function()
        my.playClickBtnSound()
        if self:_checkEnterAniDone() == false then
            print("_checkEnterAniDone false")
            return
        end
        if not UIHelper:checkOpeCycle("SecondLayerAnchorMatch_BtnArena") then
            return
        end
        UIHelper:refreshOpeBegin("SecondLayerAnchorMatch_BtnArena")
        print("onClick enter arena room ")
        
        self._roomManager:onClickAreaBtn("arena", function ()
            self._roomManager:clearSecondeLayerDataAnchor()
        end)
    end, self._roomBtnArena, 1.1)

    cc.exports.UIHelper:setTouchByScale(self._roomBtnTiming, function()
        my.playClickBtnSound()
        if self:_checkEnterAniDone() == false then
            print("_checkEnterAniDone false")
            return
        end
        if not UIHelper:checkOpeCycle("SecondLayerAnchorMatch_BtnTiming") then
            return
        end
        UIHelper:refreshOpeBegin("SecondLayerAnchorMatch_BtnTiming")
        local areaEntry = "timing"
        if RoomListModel:checkAreaEntryAvail(areaEntry) == false then
            print("checkAreaEntryAvail false, areaEntry "..tostring(areaEntry))
            local boutNum = cc.exports.getNewUserGuideBoutCount()
            local strTip = string.format(self._roomStrings["NEW_PLAYER_LOCK_TIPS"], boutNum )
            self:_showTip(strTip)
            return
        end

        local config = TimingGameModel:getConfig()
        if not config then
            self:_showTip("获取配置中，请稍后再试~")
            return
        end
        if config.Enable ~= 1 then
            self:_showTip("定时赛暂未开启，请稍后再试~")
            return
        end
        my.scheduleOnce(function() my.informPluginByName({pluginName = "TimingGameLayer"}) end, 0)
    end, self._roomBtnTiming, 1.1)

    local func = function()
        my.playClickBtnSound()
        if self:_checkEnterAniDone() == false then
            print("_checkEnterAniDone false")
            return
        end
        if not UIHelper:checkOpeCycle("SecondLayerAnchorMatch_BtnGetTicket") then
            return
        end
        UIHelper:refreshOpeBegin("SecondLayerAnchorMatch_BtnGetTicket")

        local config = TimingGameModel:getConfig()
        local infoData = TimingGameModel:getInfoData()
        if not config or not infoData then
            self:_showTip("服务繁忙，请稍后再试~")
            return
        end
        if config.Enable ~= 1 then
            self:_showTip("定时赛暂未开启，请稍后再试~")
            return
        end
        my.scheduleOnce(function() my.informPluginByName({pluginName = "TimingGameGetTicket"}) end, 0)
    end
    cc.exports.UIHelper:setTouchByScale(self._roomBtnGetTicket, func , self._roomBtnGetTicket, 1.1)
    cc.exports.UIHelper:setTouchByScale(self._btnBuyTicket, func , self._btnBuyTicket, 1.1)

    if cc.exports.getTimmingGameTicketEntranceSwitch() == 1 then
        self._roomBtnGetTicket:setVisible(true)
        self._imgBuyTicket:setVisible(true)
    else
        self._roomBtnGetTicket:setVisible(false)
        self._imgBuyTicket:setVisible(false)
    end

    self._lockAnchor:setVisible(false)

    if not cc.exports.isTimingGameSupported() then
        self._roomBtnTiming:setVisible(false)
        self._panelRoomList:getChildByName("Sprite_Lock_Timing"):setVisible(false)

        local roomlistPanelWidth = self._panelRoomList:getContentSize().width
        local roomBtnWidth = self._roomBtnAnchor:getContentSize().width
        local spaceWidth = (roomlistPanelWidth - roomBtnWidth * 2) / 3
        self._roomBtnAnchor:setPositionX(spaceWidth + roomBtnWidth / 2)
        self._lockAnchor:setPositionX(spaceWidth + roomBtnWidth / 2)

        self._roomBtnArena:setPositionX(spaceWidth * 2 + roomBtnWidth * 1.5)        
        self._panelRoomList:getChildByName("Sprite_Lock_Arena"):setPositionX(spaceWidth * 2 + roomBtnWidth * 1.5)
    else
        self._roomBtnTiming:setVisible(true)
        self._panelRoomList:getChildByName("Sprite_Lock_Timing"):setVisible(true)

        local roomlistPanelWidth = self._panelRoomList:getContentSize().width
        local roomBtnWidth = self._roomBtnAnchor:getContentSize().width
        local spaceWidth = (roomlistPanelWidth - roomBtnWidth * 3) / 4
        self._roomBtnAnchor:setPositionX(spaceWidth + roomBtnWidth / 2)
        self._lockAnchor:setPositionX(spaceWidth + roomBtnWidth / 2)
        
        self._roomBtnTiming:setPositionX(spaceWidth * 2 + roomBtnWidth * 1.5)
        self._panelRoomList:getChildByName("Sprite_Lock_Timing"):setPositionX(spaceWidth * 2 + roomBtnWidth * 1.5)

        self._roomBtnArena:setPositionX(spaceWidth * 3 + roomBtnWidth * 2.5)
        self._panelRoomList:getChildByName("Sprite_Lock_Arena"):setPositionX(spaceWidth * 3 + roomBtnWidth * 2.5)
    end
end

function SecondLayerAnchorMatch:_showTip(str, ...)
    if not str then return end
    local tipString = string.format(str, ...)
    local pluginName = self._roomContextOut["isEnteredGameScene"] and "ToastPlugin" or "TipPlugin"
    my.informPluginByName({pluginName = pluginName, params = {tipString = tipString, removeTime = 2}})
end

function SecondLayerAnchorMatch:runEnterAni()
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
        if not tolua.isnull(nodeTarget) then
            local moveAction = cc.MoveTo:create(0.4, cc.p(nodeTarget.posXRaw, nodeTarget:getPositionY()))
            local fadeAction = cc.FadeTo:create(0.4, 255)
            local spawnAction = cc.Spawn:create(cc.EaseBackOut:create(moveAction), fadeAction)
            nodeTarget:runAction(spawnAction)
        end                
    end, 0)

    if TimingGameModel:isNeedPopGetTicketCtrl() then
        TimingGameModel:saveTodayGetTicketPop()
        my.scheduleOnce(function()
            my.informPluginByName({pluginName = "TimingGameGetTicket"})
        end, 0)
    end
end

function SecondLayerAnchorMatch:refreshView()
    self:refreshTopBarInfo()
    self:refreshScoreRoomBtnInfo()
    self:refreshEntryLock()

    self.TouchScoreRoomBtnEnable = true -- 根据经典那边的逻辑推断，此处要加上这个标志位控制
end

function SecondLayerAnchorMatch:refreshViewOnDepositChange()
    self:refreshTopBarInfo()
    self:refreshScoreRoomBtnInfo()
end

function SecondLayerAnchorMatch:onRoomPlayerNumUpdated()
end

--用于刷新门票数量
function SecondLayerAnchorMatch:refreshTickets()
    if self._textTicketValue then
        local ticketCount = TimingGameModel:getSelfTicketCount()
        local num = type(ticketCount) == "number" and ticketCount or 0
        self._textTicketValue:setString(num)
    end
end

--用于刷新配置信息
function SecondLayerAnchorMatch:refreshConfigDesc()
    self:_initTimingView()
end

function SecondLayerAnchorMatch:refreshTopBarInfo()
     local spriteGameMode = self._panelTop:getChildByName("Sprite_GameMode")

    local spriteFrameName = "hallcocosstudio/images/plist/room_img/text_timing.png"
    local spriteFrame = cc.SpriteFrameCache:getInstance():getSpriteFrame(spriteFrameName)
    spriteGameMode:setSpriteFrame(spriteFrame)

    SubViewHelper:setTopBarInfo(self._panelTop)
end

function SecondLayerAnchorMatch:refreshScoreRoomBtnInfo()
end

function SecondLayerAnchorMatch:onTouchScoreRoomBtn(index, roomList, isInGameTag)
end

function SecondLayerAnchorMatch:dealOnClose()
end

function SecondLayerAnchorMatch:refreshEntryLock()
    -- 校验定时赛
    if RoomListModel:checkAreaEntryAvail("timing") == true then
        self._panelRoomList:getChildByName("Sprite_Lock_Timing"):setVisible(false)
        self._roomBtnTiming:setColor(cc.c3b(255, 255, 255))
    else
        self._panelRoomList:getChildByName("Sprite_Lock_Timing"):setVisible(true)
        self._roomBtnTiming:setColor(cc.c3b(127, 127, 127))
        self._panelRoomList:getChildByName("Sprite_Lock_Timing"):setPosition(self._roomBtnTiming:getPosition())
    end    

    -- 校验竞技场
    if RoomListModel:checkAreaEntryAvail("arena") == true then
        self._panelRoomList:getChildByName("Sprite_Lock_Arena"):setVisible(false)
        self._roomBtnArena:setColor(cc.c3b(255, 255, 255))
    else
        self._panelRoomList:getChildByName("Sprite_Lock_Arena"):setVisible(true)
        self._roomBtnArena:setColor(cc.c3b(127, 127, 127))
        self._panelRoomList:getChildByName("Sprite_Lock_Arena"):setPosition(self._roomBtnArena:getPosition())
    end
end

return SecondLayerAnchorMatch