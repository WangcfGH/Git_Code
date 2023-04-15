local MyGameArenaStatement      = class("MyGameArenaStatement")
local MyGameArenaProgress       = import("src.app.Game.mMyGame.MyGameArena.MyGameArenaProgress")
local NumberScroller            = import("src.app.Game.mCommon.NumberScroller")
local ArenaConfig               = require("src.app.HallConfig.ArenaConfig")
local SKGameDef                 = import("src.app.Game.mSKGame.SKGameDef")

MyGameArenaStatement.RESOURCE_PATH            = 'res/GameCocosStudio/Arena/ArenaStatement.csb'
MyGameArenaStatement.MAX_BONUS_COUNT = 5        --加成类型最大数量
MyGameArenaStatement.ARENA_ROOM_GRADE_MIN = 1    --最低场次
MyGameArenaStatement.ARENA_ROOM_GRADE_MAX = 5    --最高场次
MyGameArenaStatement.BONUS_VALUES_AVAIL = { ["1"] = true, ["5"] = true, ["10"] = true, ["20"] = true, ["30"] = true } --可选加成值
MyGameArenaStatement.CUR_BOUT_SCORE_OFFSET_Y = 90

function MyGameArenaStatement:ctor(baseNode, gameController, isWin)
    self._gameController = gameController
    
    self._data = {}
    self._isExited = false
    self._curScore = -1

    self._isWin = isWin

    self:_init(baseNode)
end

function MyGameArenaStatement:_init(baseNode)
    if baseNode == nil then return end

    local arenaStatementLayer = cc.CSLoader:createNode(MyGameArenaStatement.RESOURCE_PATH)
    self._arenaStatementLayer = arenaStatementLayer
    arenaStatementLayer:setLocalZOrder(SKGameDef.SK_ZORDER_ARENA_RESULT)
    local visibleSize = cc.Director:getInstance():getVisibleSize()
	local origin = cc.Director:getInstance():getVisibleOrigin()
	arenaStatementLayer:setContentSize(visibleSize)
    ccui.Helper:doLayout(arenaStatementLayer)
    baseNode:addChild(arenaStatementLayer)

    --半透明背景面板
    local panelClickLayerForLevelRewardsPanel = arenaStatementLayer:getChildByName("Panel_ClickLayer")
    local function clickPanelClickLayerForLevelRewardsPanel()
        self:hideLevelRewardsPanel()
    end
    panelClickLayerForLevelRewardsPanel:addClickEventListener(clickPanelClickLayerForLevelRewardsPanel)
    --竞技场数据面板
    local panelStatementData = arenaStatementLayer:getChildByName("Panel_StatementData")
    --继续游戏
    local btnGoonGame = panelStatementData:getChildByName("Button_GoOn_Game")
    local function onBtnGoonGameClicked()
        --my.playClickBtnSound()
        self:onBtnGoonGameClicked()
    end
    btnGoonGame:addClickEventListener(onBtnGoonGameClicked)
    --胜利和失败界面
    local titlePanel = nil
    if self._isWin then
        titlePanel = panelStatementData:getChildByName("Sprite_Title")
        panelStatementData:getChildByName("Sprite_Title2"):setVisible(false)
    else
        titlePanel = panelStatementData:getChildByName("Sprite_Title2")
        panelStatementData:getChildByName("Sprite_Title"):setVisible(false)
    end
    --总积分
    local labelTotalScore = titlePanel:getChildByName("Text_TotalScore")
    labelTotalScore:setString("0")
    self._totalScoreScroller = NumberScroller:create(labelTotalScore)
    self._totalScoreScroller:setScrollEndCallback(self, self.onTotalScoreScrollEnded)

    local panelStatementItems = panelStatementData:getChildByName("Panel_StatementItems")  
    --等级信息界面
    self._panelUpgrade = panelStatementItems:getChildByName("Panel_Upgrade")
    --本局积分
    local panelCurBoutScore = titlePanel:getChildByName("Text_CurBoutScore")
    --local panelCurBoutScore = panelStatementItems:getChildByName("Panel_CurBoutScore")
    self._curBoutScoreScroller = NumberScroller:create(panelCurBoutScore)
    self._curBoutScoreScroller:setScrollEndCallback(self, self.onCurBoutScoreScrollEnded)
    --加成项
    local panelBonusItems = panelStatementItems:getChildByName("Panel_BonusItems")
    self._panelBonusItems = panelBonusItems
    --奖励项
    local panelRewardItems = panelStatementItems:getChildByName("Panel_RewardItems")
    self._panelRewardItems = panelRewardItems
    local textNoRewardMsg = panelStatementItems:getChildByName("Text_NoReward_Message")
    self._textNoRewardMsg = textNoRewardMsg
    panelRewardItems:setVisible(false)
    textNoRewardMsg:setVisible(false)
    --竞技场进度面板
    local panelLevelProgress = arenaStatementLayer:getChildByName("Panel_Level_Progress")
    self._arenaProgress = MyGameArenaProgress:create(self._gameController ,self, panelLevelProgress)
    --升级面板
    local panelLevelUp = arenaStatementLayer:getChildByName("Panel_LevelUp")
    self._panelLevelUp = panelLevelUp
    local panelTitle = panelLevelUp:getChildByName("Panel_Title")
    local spriteLevel = panelTitle:getChildByName("Sprite_Level")
    self._spriteLevel = spriteLevel
    self._imgLevelTxt = spriteLevel:getChildByName("Img_LevelName")
    local panelLeveUpRewardItems = panelLevelUp:getChildByName("Panel_RewardItems")
    self._panelLeveUpRewardItems = panelLeveUpRewardItems
    self._panelLevelUp:setVisible(false)

    local levelUpClickLayer = panelLevelUp:getChildByName("Panel_ClickLayer")
    local function clickLevelUpPanel()
        self:hideLevelUp()
    end
    levelUpClickLayer:addClickEventListener(clickLevelUpPanel)
    --测试
    --[[local arenaInfo = self._gameController._baseGameArenaInfoManager:getArenaInfo()
    if arenaInfo.nAwardInfoNumber <= 0 then
        return
    end
    local progressData = {}
    progressData = {}
    progressData.levelScoreList = {}
    progressData.levelRewardsList = {}
    for i = 1, arenaInfo.nAwardInfoNumber do
        progressData.levelScoreList[i] = arenaInfo.awardInfo[i].nMatchScore
        progressData.levelRewardsList[i] = {}
        for j = 1, arenaInfo.awardInfo[i].nAwardNumber do
            table.insert(progressData.levelRewardsList[i], arenaInfo.awardInfo[i].awardType[j])
        end
    end
    table.sort(progressData.levelScoreList, function ( item, item2 )
    	return item < item2
    end)

    progressData.nScoreMax = arenaInfo.awardInfo[arenaInfo.nAwardInfoNumber].nMatchScore
    self._curScore = 8000
    self._data.nTotalScorePrev = 8000
    self._data.nTotalScore = 15000
    self._arenaProgress:setData(progressData)
    self._arenaProgress:refreshLevels(8000)
    self._arenaProgress:refreshPortrait(8000) --头像
    self:refreshNext()
    
    self._data.levelData = {}
    self._data.levelData.levelRewardsList = {}
    self._data.levelData.levelRewardsList = clone(progressData.levelRewardsList)]]
end

function MyGameArenaStatement:hideLevelRewardsPanel()
    if self._arenaProgress ~= nil then
        self._arenaProgress:hideLevelRewardsPanel()
    end
end

function MyGameArenaStatement:onBtnGoonGameClicked()
    self:hide()
    self:onExit()
end

function MyGameArenaStatement:onExit()
    if self._arenaProgress ~= nil then self._arenaProgress:onExit() end
    if self._totalScoreScroller ~= nil then self._totalScoreScroller:onExit() end
    if self._curBoutScoreScroller ~= nil then self._curBoutScoreScroller:onExit() end
    --移除自己，释放资源
    if self._arenaStatementLayer ~= nil then
        self._arenaStatementLayer:removeSelf()
        self._arenaStatementLayer = nil
    end

    if self._gameController then
        if self._gameController._baseGameScene then
            self._gameController._baseGameScene._arenaNewStatement = nil
            self._gameController:onArenaStatementClosed()
        end
    end
end

function MyGameArenaStatement:isExited()
    
end

function MyGameArenaStatement:show(data)
    if data == nil then return end

    self._data = data
    if self:refresh() == true then
        self._arenaStatementLayer:setVisible(true)
    end
end

function MyGameArenaStatement:hide()
    if self._arenaStatementLayer == nil then return end

    self._arenaStatementLayer:setVisible(false)
end

function MyGameArenaStatement:refresh()
    if self._data == nil then return  false end
    if self._arenaStatementLayer == nil then return false end
    if self._isExited == true then return false end

    local totalScore = self._data.nTotalScore
    local totalScorePrev = self._data.nTotalScorePrev
    local curBoutScore = totalScore - totalScorePrev
    self._totalScoreScroller:setValueWithoutAnim(totalScorePrev) --前总积分

    self:refreshScoreBonus() --得分加成

    self._arenaProgress:setData(self._data)
    self._curScore = totalScorePrev
    self._arenaProgress:refreshLevels(self._curScore) --等级

    self._arenaProgress:refreshPortrait(totalScorePrev) --头像
    self._curBoutScoreScroller:setValueWithoutAnim(0)

    --self:refreshNext()
    self:runBonusItemAction(curBoutScore)

    self:updateLevel()--任务等级
    return true
end

--1、加成项动画
function MyGameArenaStatement:runBonusItemAction(curBoutScore)
    self._curBoutScoreScroller:setValueWithAnim(curBoutScore)
end

--4、头像和进度条动画
function MyGameArenaStatement:onTotalScoreScrollEnded()
    self:refreshNext()
end

--3、总积分滚动动画
function MyGameArenaStatement:onCurBoutScoreScrollEnded()
    if self._data == nil then return end
    if self._isExited == true then return end

    local totalScore = self._data.nTotalScore
    local function delayedFunc()
        if self._isExited == true then return end
        self._totalScoreScroller:setValueWithAnim(totalScore)
    end
    my.scheduleOnce(delayedFunc, 0.3)
end

function MyGameArenaStatement:refreshNext()
    local curScore = self._curScore
    if curScore < 0 then return end

    local totalScore = self._data.nTotalScore
    local totalScorePrev = self._data.nTotalScorePrev
    local level = self._arenaProgress:calLevelByScore(totalScore)
    local levelPrev = self._arenaProgress:calLevelByScore(totalScorePrev)
    local curLevel = self._arenaProgress:calLevelByScore(curScore)
    
    local destScore = curScore
    if level >= 0 and level > curLevel then
        destScore = self._arenaProgress:calScoreByLevel(curLevel + 1)
    elseif level >= 0 and level == curLevel then
        destScore = totalScore
    else
        return
    end

    self._arenaProgress:refreshLevels(curScore) --等级和头像
    self._arenaProgress:runPortraitAction(curScore, destScore)
    --self._totalScoreScroller:setValueWithAnim(destScore) --总积分
end

--根据数据自动显示和隐藏加成项，并自适应位置
function MyGameArenaStatement:refreshScoreBonus()
    if self._data == nil then return false end
    if self._panelBonusItems == nil then return end
    if self._isExited == true then return end

    local bonusItemsData = self._data.bonusItems
    if bonusItemsData == nil then 
        self._panelBonusItems:setVisible(false)
        return 
    end
    self._panelBonusItems:setVisible(true)
    local arenaRoomGrade = self._data.nArenaRoomGrade

    local bonusItems = {} --界面上的加成项
    local defaultItemCount = MyGameArenaStatement.MAX_BONUS_COUNT
    local defaultItemNames = {"first_win", "room_grade", "win_plus", "lose_plus", "streaking"}
    local bonusTypeList = ArenaConfig["ArenaBonusTypeList"]
    local bonusItem_RoomGrade_Index = -1
    local bonusItem_RoomGrade_Type = -1
    for i = 1, defaultItemCount do
        bonusItems[i] = {}
        local typeItem = self._arenaProgress:getItemByKeyAttribute(bonusTypeList, "name", defaultItemNames[i])
        bonusItems[i].nType = typeItem.nType
        bonusItems[i].node = self._panelBonusItems:getChildByName("Node_Item_"..i)
        bonusItems[i].isToShow = false
        bonusItems[i].nValue = -1
        if defaultItemNames[i] == "room_grade" then 
            bonusItem_RoomGrade_Index = i
            bonusItem_RoomGrade_Type = bonusItems[i].nType
        end

        --记录各项初始位置
        if self._bonusItemPosX == nil then
           self._bonusItemPosX = {}
        end
        if self._bonusItemPosX[i] == nil then
            self._bonusItemPosX[i] = bonusItems[i].node:getPositionX()
        end
    end
    --根据数据获得需要显示的项
    local bonusesAvail = MyGameArenaStatement.BONUS_VALUES_AVAIL
    for i = 1, #bonusItems do
        for j = 1, #bonusItemsData do
            if bonusItemsData[j].nType == bonusItems[i].nType and bonusItemsData[j].nValue > 0 then--and bonusesAvail[bonusItemsData[j].nValue..""] == true then
                bonusItems[i].isToShow = true
                bonusItems[i].nValue = bonusItemsData[j].nValue
                break
            end
        end
    end
    if arenaRoomGrade == nil or arenaRoomGrade < MyGameArenaStatement.ARENA_ROOM_GRADE_MIN
        or arenaRoomGrade > MyGameArenaStatement.ARENA_ROOM_GRADE_MAX then
        if bonusItem_RoomGrade_Index ~= -1 then 
            bonusItems[bonusItem_RoomGrade_Index].isToShow = false 
        end
    end
    
    --刷新
    local count = 0
    for i = 1, #bonusItems do
        local node = bonusItems[i].node
        if bonusItems[i].isToShow == true then
            count = count + 1
            if node ~= nil then
                node:setPositionX(self._bonusItemPosX[count])
                local spriteItemValue = node:getChildByName("Sprite_BonusItem_Value")
                if spriteItemValue ~= nil then
                    --spriteItemValue:setSpriteFrame("img_bonus_"..bonusItems[i].nValue..".png")
                    spriteItemValue:setString("x"..bonusItems[i].nValue.."%")
                    spriteItemValue:setVisible(true)
                end
                if bonusItems[i].nType == bonusItem_RoomGrade_Type then --房间场次等级
                    local spriteItemGrade = node:getChildByName("Sprite_RoomGrade")
                    if spriteItemGrade ~= nil then
                        spriteItemGrade:setSpriteFrame("GameCocosStudio/plist/ArenaStatement/img_roomgrade_"..arenaRoomGrade..".png")
                        spriteItemGrade:setVisible(true)
                    end
                end
                node:setVisible(true) 
            end
        else
            if node ~= nil then node:setVisible(false) end
        end
    end
end

function MyGameArenaStatement:onLevelUp(originScore, destScore)
    self:showLevelUp(originScore, destScore)
end

--升级
function MyGameArenaStatement:showLevelUp(originScore, destScore)
    if originScore == nil or destScore == nil then return end
    if self._data == nil then return false end
    if self._panelLevelUp == nil then return end
    if self._isExited == true then return end

    local originLevel = self._arenaProgress:calLevelByScore(originScore)
    local destLevel = self._arenaProgress:calLevelByScore(destScore)
    if destLevel <= 0 or destLevel <= originLevel then return end

    --刷新等级
    if self._spriteLevel ~= nil then self._spriteLevel:setSpriteFrame("GameCocosStudio/plist/Upgrade/Arena_id_Bigegg"..destLevel..".png") end
    if self._imgLevelTxt ~= nil then self._imgLevelTxt:loadTexture("GameCocosStudio/plist/ArenaStatement/Athletics_img_egg"..destLevel..".png", 1) end
    
    self:refreshLevelUpRewards(destLevel)

    self._curScore = destScore
    self._panelLevelUp:setVisible(true)

    --动画
    local csbPath = "res/GameCocosStudio/Arena/ArenaStatement.csb"
    local action = cc.CSLoader:createTimeline(csbPath)
    if action then
        self._arenaStatementLayer:runAction(action)
        action:play("animation0", false)

        local function onFrameEvent( frame)
            if frame then 
                local event = frame:getEvent()
                if "Play_Over" == event then
                    action:play("animation1", true)
                end
            end
        end
        action:setFrameEventCallFunc(onFrameEvent)
    end
end

function MyGameArenaStatement:refreshLevelUpRewards(destLevel)
    if destLevel == nil then return end
    if self._data == nil then return false end
    if self._panelLeveUpRewardItems == nil then return end
    if self._isExited == true then return end

    local panelRewardItems = self._panelLeveUpRewardItems
    local totalWidth = panelRewardItems:getContentSize().width
    local totalHeight = panelRewardItems:getContentSize().height
    local rewardData = self._data.levelData.levelRewardsList[destLevel]
    if rewardData == nil then return end

    local curItemCount = panelRewardItems:getChildrenCount() - 1
    local itemCount = #rewardData
    local validCount = 0
    for i = 1, itemCount do
        if rewardData[i].nCount ~= nil and rewardData[i].nCount > 0 then
            validCount = validCount + 1
        end
    end
    if validCount <= 0 then 
        panelRewardItems:setVisible(false)
        return
    end
    panelRewardItems:setVisible(true)
    if curItemCount > validCount then
        --移除多余
        for i = (validCount + 1), curItemCount do
            local item = panelRewardItems:getChildByName("Node_Item_"..i)
            if item ~= nil then panelRewardItems:removeChild(item) end
        end 
    elseif curItemCount < validCount then
        --新增不足
        for i = (curItemCount + 1), validCount do
            local item = cc.Node:create()
            item:setName("Node_Item_"..i)
            local spriteBk = cc.Sprite:createWithSpriteFrameName("GameCocosStudio/plist/ArenaStatement/Athletics_defenkuang.png")
            spriteBk:setName("Sprite_BK")
            item:addChild(spriteBk)
            local spriteIcon = cc.Sprite:createWithSpriteFrameName("Game_Img_Silver.png")
            spriteIcon:setName("Sprite_Icon")
            spriteIcon:setPosition(cc.p(-3, 3))
            item:addChild(spriteIcon)
            --local textCount = cc.Label:createWithBMFont("res/GameCocosStudio/Arena/font/Font_GameNumber_24.fnt", "")
            local textCount = cc.Label:create()
            textCount:setName("Text_Count")
            textCount:setPosition(cc.p(0, -65))
            textCount:setString("x0")
            item:addChild(textCount)
            item:setPosition(cc.p(650, 70))
            panelRewardItems:addChild(item)
        end
    end
    --调整位置同时刷新界面
    local gapList = {0, 120, 100, 50, 50} --显示项为1、2、3、4、>=5时的间隔距离
    local gap = 0
    if validCount > #gapList then gap = gapList[#gapList] else gap = gapList[validCount] end
    local itemWidth = 100
    local allItemsWidth = validCount * (itemWidth + gap) - gap
    if allItemsWidth < 0 then allItemsWidth = 0 end
    local startXOffset = 5
    local startX = (totalWidth - allItemsWidth) / 2 + itemWidth / 2 + startXOffset
    local rewardTypeList = ArenaConfig["ArenaRewardTypeList"]
    for i = 1, validCount do
        local item = panelRewardItems:getChildByName("Node_Item_"..i)
        if item ~= nil then 
            item:setPosition(cc.p(startX + (itemWidth + gap) * (i - 1), 70))
            local spriteIcon = item:getChildByName("Sprite_Icon")
            local textCount = item:getChildByName("Text_Count")
            local itemAtt = self._arenaProgress:getItemByKeyAttribute(rewardTypeList, "nType", rewardData[i].nType)
            if itemAtt ~= nil then
                spriteIcon:setSpriteFrame(itemAtt.imageName)
                --textCount:setString("x"..rewardData[i].nCount..""..itemAtt.typeUnit)
                textCount:setString(rewardData[i].nCount)

                --self._gameController:updateArenaPlayerRewardData(rewardData[i].nType, rewardData[i].nCount)
            end
        end
    end
end

function MyGameArenaStatement:hideLevelUp()
    if self._panelLevelUp == nil then return end

    --连续两次点击时间间隔必须大于1s，避免快速点击异常
    if self._lastVCTOfHideLevelUp ~= nil and (os.time() - self._lastVCTOfHideLevelUp) < 1 then return else self._lastVCTOfHideLevelUp = os.time() end

    self._panelLevelUp:setVisible(false)

    self:refreshNext() --继续进度
end

function MyGameArenaStatement:playArenaEffect(soundName)
    
end

function MyGameArenaStatement:updateLevel()
    local panelLevel = self._panelUpgrade
    if not cc.exports._userLevelData.nLevelExp then 
        if panelLevel then
            panelLevel:setVisible(false)
        end
        return 
    end
    if panelLevel then
        panelLevel:setVisible(true)

        local thisLevelImage = panelLevel:getChildByName("Img_This")
        local thisLevelColor = thisLevelImage:getChildByName("Img_LevelColor")
        local thisLevelText = thisLevelImage:getChildByName("Text_LevelNum")
        local BGResName, ColorResName, levelString = cc.exports.LevelResAndTextForData(cc.exports._userLevelData.nLevel)
        thisLevelImage:loadTexture(BGResName)
        thisLevelColor:loadTexture(ColorResName)
        thisLevelText:setString(levelString)

        local levelProgressBar = panelLevel:getChildByName("Progressbar_Level")
        local progressVlaue = cc.exports._userLevelData.nLevelExp / cc.exports._userLevelData.nNextExp
        if progressVlaue > 1 then
            progressVlaue = 1
        end
        levelProgressBar:setPercent(progressVlaue * 100)
        
        local levelText = panelLevel:getChildByName("Text_Level")
        levelText:setString(cc.exports._userLevelData.nLevel)
    end
end

return MyGameArenaStatement