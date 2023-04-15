local FirstLayer = class("FirstLayer")
local HallContext = import('src.app.plugins.mainpanel.HallContext'):getInstance()
local RoomListModel = import("src.app.GameHall.room.model.RoomListModel"):getInstance()
local UserModel = mymodel('UserModel'):getInstance()
local TimingGameModel = import('src.app.plugins.TimingGame.TimingGameModel'):getInstance()
local SpringFestivalModel = import('src.app.BaseModule.SpringFestivalModel'):getInstance()
local BroadcastModel = mymodel("hallext.BroadcastModel"):getInstance()

function FirstLayer:ctor(roomManager)
    self._roomManager = roomManager
    self._areaBtnsInfo = {
        [1] = {["btnNode"] = nil, ["areaEntry"] = "noshuffle", ["posOriginal"] = nil, ["hideOnLogoff"] = true},
        [2] = {["btnNode"] = nil, ["areaEntry"] = "classic", ["posOriginal"] = nil, ["hideOnLogoff"] = true},
        [3] = {["btnNode"] = nil, ["areaEntry"] = "arena", ["posOriginal"] = nil, ["hideOnLogoff"] = true},
        [4] = {["btnNode"] = nil, ["areaEntry"] = "joy", ["posOriginal"] = nil, ["hideOnLogoff"] = false},
        [5] = {["btnNode"] = nil, ["areaEntry"] = "jisu", ["posOriginal"] = nil, ["hideOnLogoff"] = false},
        [6] = {["btnNode"] = nil, ["areaEntry"] = "timingMiddle", ["posOriginal"] = nil, ["hideOnLogoff"] = true},
        [7] = {["btnNode"] = nil, ["areaEntry"] = "anchorMatch", ["posOriginal"] = nil, ["hideOnLogoff"] = true},
        [8] = {["btnNode"] = nil, ["areaEntry"] = "team2V2", ["posOriginal"] = nil, ["hideOnLogoff"] = false},
    }
    self._FirstLayStrings = HallContext.context["roomStrings"]
    self._ChineseBout = {self._FirstLayStrings["ONE"], self._FirstLayStrings["TWO"], self._FirstLayStrings["THREE"], self._FirstLayStrings["FOUR"], self._FirstLayStrings["FIVE"],
                        self._FirstLayStrings["SIX"], self._FirstLayStrings["SEVEN"], self._FirstLayStrings["EIGHT"], self._FirstLayStrings["NINE"], self._FirstLayStrings["TEN"]}
end

function FirstLayer:initView(viewNode)
    self._initViewNode = viewNode
    self._panelAreas = viewNode.panelAreas
    self._panelQuickStart = viewNode.panelQuickStart
    self._skeletonConfigKey = {}
    
    self:_createAreaBtns()
    self:_initPanelQuickStart()
end

function FirstLayer:_createAreaBtns()
    
    for i = 1, #self._areaBtnsInfo do
        local areaEntry = self._areaBtnsInfo[i]["areaEntry"]
        local nodeName = "nodeSkAni"
        local nodeBtn = self._panelAreas:getChildByName("Button_"..i)
        self._areaBtnsInfo[i]["btnNode"] = nodeBtn
        self._areaBtnsInfo[i]["posOriginal"] = cc.p(nodeBtn:getPosition())

        local spriteStaticImg = nodeBtn:getChildByName("Sprite_StaticImg")
        spriteStaticImg:setVisible(false)

        local skeletonConfigKey = self:getSkeletonName(areaEntry)
        self:refreshSkeletonAni(skeletonConfigKey, i, spriteStaticImg)
        
        local spriteLock = self._panelAreas:getChildByName("Sprite_Lock_" .. i)
        if spriteLock then
            spriteLock:setPosition(nodeBtn:getPosition())
            spriteLock:setVisible(false)
        end
        UIHelper:setTouchByScale(nodeBtn, function()
            print("click areabtn ----", areaEntry)
            self._roomManager:onClickAreaBtn(areaEntry)
        end, nodeBtn, 1.05)

        self:refreshConfigDesc()
        self:refreshEntry()
    end
end

function FirstLayer:getSkeletonName(areaEntry)
    local skeletonConfigKey = "skeletonAni"
    if areaEntry == "timingMiddle" then
        local type = cc.exports.getTimmingGameEntryType() 
        if type == 2 then
            skeletonConfigKey = "skeletonAniTimingType"
        end
    end
    if SpringFestivalModel:showSpringFestivalView() then
        skeletonConfigKey = "skeletonAniSpringFestival"
        if areaEntry == "timingMiddle" then
            local type = cc.exports.getTimmingGameEntryType() 
            if type == 2 then
                skeletonConfigKey = "skeletonAniSpringFestivalTimingType"
            end
        end
    end
    return skeletonConfigKey
end

function FirstLayer:refreshSkeletonAni(skeletonConfigKey, i, spriteStaticImg)
    if skeletonConfigKey == self._skeletonConfigKey[i] then
        return
    end
    local posXAdjust = {0, 0, 0, 2, 2, 2, 2, 2}
    local posYAdjust = {-10, -14, -6, -6, -6, -6, -6, -6}
    local areaEntry = self._areaBtnsInfo[i]["areaEntry"]
    local nodeName = "nodeSkAni"
    local nodeBtn = self._panelAreas:getChildByName("Button_"..i)
    local nodeAni = nodeBtn:getChildByName(nodeName)
    if nodeAni ~= nil then
        nodeBtn:removeChildByName(nodeName)
    end
    local skAniConfig = self._roomManager.areaViewConfig[areaEntry][skeletonConfigKey]
    local skAni = sp.SkeletonAnimation:create(skAniConfig["jsonPath"], skAniConfig["atlasPath"], 1.0)  
    skAni:setAnimation(0, skAniConfig["aniNames"][1], true)
    skAni:setDebugBonesEnabled(false)
    skAni:setName(nodeName)
    skAni:setPosition(cc.p(spriteStaticImg:getPositionX() + posXAdjust[i], spriteStaticImg:getPositionY() + posYAdjust[i]))
    nodeBtn:addChild(skAni)
    skAni:setLocalZOrder(-1)

    self._skeletonConfigKey[i] = skeletonConfigKey
end

-- 获取缓存信息日期
function FirstLayer:getCacheDate()
    local cacheDate = CacheModel:getCacheByKey("TimingGameBroadCastTipDate")
    return cacheDate
end

-- 设置缓存信息日期
function FirstLayer:setCacheDate(date)
    CacheModel:saveInfoToCache("TimingGameBroadCastTipDate", date)
end

function FirstLayer:refreshConfigDesc()
    local nodeBtn = self._panelAreas:getChildByName("Button_"..6)
    local flag = nodeBtn:getChildByName("Sprite_Double")
    local nodeBtn7 = self._panelAreas:getChildByName("Button_"..7)
    local flag7 = nodeBtn7:getChildByName("Sprite_Double")
    
    if flag and cc.exports.isTimingGameSupported()
     and TimingGameModel:isMatchDay() and TimingGameModel:isInTimeMatchPeriod() then
        if not flag:isVisible() then            
            local broadCastTip = cc.exports.getTimmingGameBCTip()
            local broadCastTipTimes = cc.exports.getTimmingGameBCRtimes()
            local data={
                MessageInfo = {
                    enMsgType = BroadcastDef.enMsgTypeImportant,
                    szMsg = broadCastTip,
                    nReserved = {0,0,0,0}
                },
                nDelaySec = -1,
                nInterval = 0,
                nRepeatTimes = broadCastTipTimes,
                nRoadID = 0,
                nReserved = {0,0,0,0}
            }
            
            local curDate = os.date('%Y%m%d',os.time())
            local cacheDate = self:getCacheDate()
            if cacheDate == nil or toint(cacheDate) ~= toint(curDate) then
                self:setCacheDate(curDate)
                my.scheduleOnce(function()
                    BroadcastModel:insertBroadcastMsg(data)
                end, 0.5)
            end
        end

        flag:setVisible(true)
        flag7:setVisible(true)

        local aniFile= "res/hallcocosstudio/mainpanel/mainpanel.csb"
        local action = cc.CSLoader:createTimeline(aniFile)
        if not tolua.isnull(action) and self._initViewNode then
            self._initViewNode:stopAllActions()
            self._initViewNode:runAction(action)
            action:play("tip_animation", true)
        end 
    else
        flag:setVisible(false)
        flag7:setVisible(false)
        if self._initViewNode then
            self._initViewNode:stopAllActions()
        end
    end    
end

function FirstLayer:_initPanelQuickStart()
    local btnQuickStart = self._panelQuickStart:getChildByName("Button_QuickStart")
    btnQuickStart:addClickEventListener(function()
        my.playClickBtnSound()

        --17期客户端埋点
        my.dataLink(cc.exports.DataLinkCodeDef.HALL_QUICK_START_GAME_BTN)
        self._roomManager:doQuickStartGame("normal")
    end)
    SubViewHelper:setQuickStartAni(self._panelQuickStart)
end

function FirstLayer:refreshView()
    self:refreshPanelQuickStart()
    self:refreshAreaEntryLock()
    self:refreshEntry()
    self:yqylAction()
end

--邀请有礼icon动画
function FirstLayer:yqylAction()
    local path =  "res/hallcocosstudio/invitegiftactive/olduser/yqyl_icon.csb"
    self._initViewNode.yqylNode:stopAllActions()
    local action = cc.CSLoader:createTimeline(path)
    self._initViewNode.yqylNode:runAction(action)
    action:play("normal", true)   
end

function FirstLayer:refreshEntry()
    for i = 1, #self._areaBtnsInfo do
        local nodeBtn = self._panelAreas:getChildByName("Button_"..i)
        if cc.exports.isTeam2V2RoomSupported() then            
            if i == 4 then
                nodeBtn:setVisible(false)
            end
            if i == 5 then
                self._panelAreas:getChildByName("Sprite_Lock_5"):setVisible(false)
                nodeBtn:setVisible(false)
            end
            if i == 8 then
                nodeBtn:setVisible(true)
            end
        else
            if cc.exports.isJiSuRoomSupported() then  
                if i == 4 then
                    nodeBtn:setVisible(false)
                end
                if i == 5 then
                    nodeBtn:setVisible(true)
                end
                if i == 8 then
                    self._panelAreas:getChildByName("Sprite_Lock_8"):setVisible(false)
                    nodeBtn:setVisible(false)
                end
            else
                if i == 4 then
                    if cc.exports.isYuleRoomSupported() then
                        nodeBtn:setVisible(true)
                    else
                        nodeBtn:setVisible(false)
                    end
                end
                if i == 5 then
                    self._panelAreas:getChildByName("Sprite_Lock_5"):setVisible(false)
                    nodeBtn:setVisible(false)
                end
                if i == 8 then
                    self._panelAreas:getChildByName("Sprite_Lock_8"):setVisible(false)
                    nodeBtn:setVisible(false)
                end
            end
        end

        if cc.exports.isAnchorRoomSupported() then
            if i == 3 then
                nodeBtn:setVisible(false)
                nodeBtn:setTouchEnabled(false)
            end
            if i == 6 then
                nodeBtn:setVisible(false)
                nodeBtn:setTouchEnabled(false)
            end
            if i == 7 then
                nodeBtn:setVisible(true)
                nodeBtn:setTouchEnabled(true)
            end
        else
            if cc.exports.isTimingGameSupported() then
                if i == 3 then
                    nodeBtn:setVisible(false)
                    nodeBtn:setTouchEnabled(false)
                end
                if i == 6 then
                    nodeBtn:setVisible(true)
                    nodeBtn:setTouchEnabled(true)
                end
                if i == 7 then
                    nodeBtn:setVisible(false)
                    nodeBtn:setTouchEnabled(false)
                end
            else
                if i == 3 then
                    nodeBtn:setVisible(true)
                    nodeBtn:setTouchEnabled(true)
                end
                if i == 6 then
                    self._panelAreas:getChildByName("Sprite_Lock_6"):setVisible(false)
                    nodeBtn:setVisible(false)
                    nodeBtn:setTouchEnabled(false)
                end
                if i == 7 then
                    self._panelAreas:getChildByName("Sprite_Lock_7"):setVisible(false)
                    nodeBtn:setVisible(false)
                    nodeBtn:setTouchEnabled(false)
                end
            end
        end
        local areaEntry = self._areaBtnsInfo[i]["areaEntry"]
        local skiName = self:getSkeletonName(areaEntry)
        local spriteStaticImg = nodeBtn:getChildByName("Sprite_StaticImg")
        self:refreshSkeletonAni(skiName, i , spriteStaticImg)
    end
end

function FirstLayer:refreshAreaEntryLock()
    local function getChineseByNum(num)
        local str = {'一', '二', '三', '四', '五', '六', '七', '八', '九'}
        return str[num] and str[num] or str[3]
    end

    local lockBout = cc.exports.getNewUserGuideBoutCount()
    local strLockTip = string.format("O %s局解锁", getChineseByNum(lockBout) )

    for i, areaBtnInfo in ipairs(self._areaBtnsInfo) do
        local spriteLock = self._panelAreas:getChildByName("Sprite_Lock_" .. tostring(i))
        local textLockTip = spriteLock:getChildByName("Text_LockTip")
        local nodeSkAni = areaBtnInfo.btnNode:getChildByName('nodeSkAni')
        if RoomListModel:checkAreaEntryAvail(areaBtnInfo.areaEntry) then
            spriteLock:setVisible(false)
            nodeSkAni:setColor(cc.c3b(255, 255, 255))
        else
            spriteLock:setVisible(true)
            textLockTip:setString(strLockTip)
            nodeSkAni:setColor(cc.c3b(127, 127, 127))
        end
    end
end

function FirstLayer:refreshViewOnDepositChange()
    self:refreshPanelQuickStart()
end

function FirstLayer:refreshPanelQuickStart()
    SubViewHelper:setQuickStartRoomInfo(self._panelQuickStart, "normal")
end

function FirstLayer:onLogoff()
    self:_refreshAreaBtnsByLoginStatus(false)
end

function FirstLayer:onLogon()
    self:_refreshAreaBtnsByLoginStatus(true)
end

function FirstLayer:_refreshAreaBtnsByLoginStatus(isLoginOn)
    for i = 1, #self._areaBtnsInfo do
        local btnsInfo = self._areaBtnsInfo[i]
        if btnsInfo["btnNode"] and btnsInfo["hideOnLogoff"] == true then
            btnsInfo["btnNode"]:setVisible(isLoginOn == true)
            local lock = self._panelAreas:getChildByName("Sprite_Lock_" .. i)
            if lock and not isLoginOn then
                lock:setVisible(false)
            end
        end
    end

    local joyBtnsInfo = self._areaBtnsInfo[4]
    if joyBtnsInfo["btnNode"] then
        if isLoginOn == false then
            local posCenter = cc.p(self._panelAreas:getContentSize().width / 2, self._panelAreas:getContentSize().height / 2)
            joyBtnsInfo["btnNode"]:setPosition(posCenter)
        else
            joyBtnsInfo["btnNode"]:setPosition(joyBtnsInfo["posOriginal"])
        end
    end
end

return FirstLayer