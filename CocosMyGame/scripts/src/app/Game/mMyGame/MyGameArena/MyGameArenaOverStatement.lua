local MyGameArenaOverStatement = class("MyGameArenaOverStatement")
local NumberScroller           = import("src.app.Game.mCommon.NumberScroller")
local MyGameArenaProgress      = import("src.app.Game.mMyGame.MyGameArena.MyGameArenaProgress")
local ArenaConfig              = require("src.app.HallConfig.ArenaConfig")
local SKGameDef                = import("src.app.Game.mSKGame.SKGameDef")

MyGameArenaOverStatement.RESOURCE_PATH            = 'res/GameCocosStudio/Arena/ArenaOverStatement.csb'
MyGameArenaOverStatement.BONUS_VALUE_MIN = 5
MyGameArenaOverStatement.RANK_USER_COUNT = 2
MyGameArenaOverStatement.ARENA_ROOM_GRADE_MIN = 1    --最低场次（和加成项最低场次不同）
MyGameArenaOverStatement.ARENA_ROOM_GRADE_MAX = 4    --最高场次

function MyGameArenaOverStatement:ctor(baseNode, gameController)
    self._gameController = gameController

    self._data = {}
    self._isExited = false
    self._curScore = -1

    self:_init(baseNode)
end

function MyGameArenaOverStatement:_init(baseNode)
    if baseNode == nil then return end

    local arenaOverStatementLayer = cc.CSLoader:createNode(MyGameArenaOverStatement.RESOURCE_PATH)
    self._arenaOverStatementLayer = arenaOverStatementLayer
    arenaOverStatementLayer:setLocalZOrder(SKGameDef.SK_ZORDER_ARENA_RESULT)
    local visibleSize = cc.Director:getInstance():getVisibleSize()
	local origin = cc.Director:getInstance():getVisibleOrigin()
	arenaOverStatementLayer:setContentSize(visibleSize)
    ccui.Helper:doLayout(arenaOverStatementLayer)
    baseNode:addChild(arenaOverStatementLayer)

    --半透明背景面板
    local panelClickLayerForLevelRewardsPanel = arenaOverStatementLayer:getChildByName("Panel_ClickLayer")
    local function clickPanelClickLayerForLevelRewardsPanel()
        self:hideLevelRewardsPanel()
    end
    panelClickLayerForLevelRewardsPanel:addClickEventListener(clickPanelClickLayerForLevelRewardsPanel)
    --标题面板
    local panelTitle = arenaOverStatementLayer:getChildByName("Panel_Title")
    local nodeMaxFlag = panelTitle:getChildByName("Node_MaxFlag")
    self._nodeMaxFlag = nodeMaxFlag
    self._nodeMaxFlag:setVisible(false)
    local spriteTitleName = panelTitle:getChildByName("Sprite_TitleName")
    self._spriteTitleName = spriteTitleName
    local labelTotalScore = panelTitle:getChildByName("Text_TotalScore")
    labelTotalScore:setString("0")
    self._totalScoreScroller = NumberScroller:create(labelTotalScore)
    self._labelTotalScore = labelTotalScore
    local spriteLevel = panelTitle:getChildByName("Sprite_Level")
    self._spriteLevel = spriteLevel
    local spriteNoLevel = panelTitle:getChildByName("Img_NoLevel")
    self._spriteNoLevel = spriteNoLevel

    --信息面板
    local panelBoutInfo = arenaOverStatementLayer:getChildByName("Panel_BoutInfo")
    self._panelBoutInfo = panelBoutInfo
    --确定按钮
    local btnOk = arenaOverStatementLayer:getChildByName("Button_OK")
    local function onBtnOkClicked()
        my.playClickBtnSound()
        self:onOkBtnClicked()
    end
    btnOk:addClickEventListener(onBtnOkClicked)

    --奖励面板
    local panelRewardItems = arenaOverStatementLayer:getChildByName("Panel_RewardItems")
    self._panelRewardItems = panelRewardItems

    --竞技场进度面板
    local panelLevelProgress = arenaOverStatementLayer:getChildByName("Panel_Level_Progress")
    self._arenaProgress = MyGameArenaProgress:create(self._gameController ,self, panelLevelProgress)

    --排名上升面板
    local panelRankUp = arenaOverStatementLayer:getChildByName("Panel_RankUp")
    self._panelRankUp = panelRankUp
    local spriteLight = panelRankUp:getChildByName("Sprite_BK")
    self._spriteLight = spriteLight
    local btnOk = panelRankUp:getChildByName("Button_OK")
    local function clickOk()
        my.playClickBtnSound()
        self:hideRankUp()
    end
    btnOk:addClickEventListener(clickOk)
    --初始隐藏
    self._panelRankUp:setVisible(false)

    --初始隐藏
    --self._arenaOverStatementLayer:setVisible(false)
end

function MyGameArenaOverStatement:onOkBtnClicked()
    if self._lastVCTOfOkBtn ~= nil and (os.time() - self._lastVCTOfOkBtn) <= 2 then return else self._lastVCTOfOkBtn = os.time() end

    --self:hide()
    --self:onExit()
    if self._gameController ~= nil then
        self._gameController:onExitGameClicked()
    end
end

function MyGameArenaOverStatement:hideLevelRewardsPanel()
    if self._arenaProgress ~= nil then
        self._arenaProgress:hideLevelRewardsPanel()
    end
end

function MyGameArenaOverStatement:refresh()
    if self._data == nil then return  false end
    if self._arenaOverStatementLayer == nil then return end
    if self._isExited == true then return end

    local totalScore = self._data.nTotalScore
    local totalScorePrev = self._data.nTotalScorePrev
    self._totalScoreScroller:setValueWithoutAnim(totalScore) --总积分
    --标题中的等级
    local curLevel = self._data.nLevel
    if self._spriteLevel ~= nil then
        if curLevel >= self._arenaProgress.LEVEL_MIN and curLevel <= self._arenaProgress.LEVEL_MAX then
            self._spriteLevel:setSpriteFrame("GameCocosStudio/plist/ArenaStatement/Arena_id_egg"..curLevel..".png")
            self._spriteLevel:setVisible(true)
            self._spriteNoLevel:setVisible(false)
        else
            self._spriteLevel:setVisible(false)
            self._spriteNoLevel:setVisible(true)
        end
    end
    --标题中的场次
    local arenaRoomGrade = self._data.nArenaRoomGrade
    if arenaRoomGrade >= MyGameArenaOverStatement.ARENA_ROOM_GRADE_MIN 
        and arenaRoomGrade <= MyGameArenaOverStatement.ARENA_ROOM_GRADE_MAX then
        if self._spriteTitleName ~= nil then 
            self._spriteTitleName:setSpriteFrame("GameCocosStudio/plist/ArenaOverStatement/text_arena_level_"..arenaRoomGrade..".png")
            self._spriteTitleName:setVisible(true)
        end
    else
        if self._spriteTitleName ~= nil then self._spriteTitleName:setVisible(false) end
    end
    self:refreshRewardItems()
    self:refreshBoutInfo() --局数信息
    self._arenaProgress:setData(self._data)
    self._arenaProgress:refreshLevels(totalScore) --等级和头像
    self._arenaProgress:refreshPortrait(totalScore)
    self:refreshNewRecordBreak()
    local function showRunkUpFunc()
        self:showRankUp()
    end
    my.scheduleOnce(showRunkUpFunc, 1)
    return true
end

--本周最高
function MyGameArenaOverStatement:refreshNewRecordBreak()
    if self._nodeMaxFlag == nil then return end
    if self._isExited == true then return end

    if self._gameController == nil then return end
    local rankUpData = self._gameController:getRankUpData()
    if rankUpData == nil then return end
    local userData_1 = rankUpData[1]
    if userData_1.userScore <= userData_1.userScorePrev then
        self._nodeMaxFlag:setVisible(false) --未达到本周最高
        return
    end

    self._nodeMaxFlag:setVisible(true)
    --光芒旋转
    local spriteLight = self._nodeMaxFlag:getChildByName("Sprite_Icon_BK")
    if spriteLight ~= nil then
        spriteLight:runAction(cc.RepeatForever:create(cc.RotateBy:create(1, 60))) --光芒旋转
    end
end

function MyGameArenaOverStatement:refreshRewardItems()
    if self._data == nil then return end
    if self._panelRewardItems == nil then return end
    if self._isExited == true then return end

    local panelRewardItems = self._panelRewardItems
    local totalWidth = panelRewardItems:getContentSize().width
    local totalHeight = panelRewardItems:getContentSize().height
    local level = self._data.nLevel
    local levelRewardsList = self._data.levelData.levelRewardsList
    if levelRewardsList == nil then return end

    --计算本轮获得的累计奖励
    local rewardData = {}
    local count = 0
    for i = 1, level do
        local levelRewardData = levelRewardsList[i]
        for j = 1, #levelRewardData do
            local dataItem = levelRewardData[j]
            local isTypeExist = false
            for k = 1, #rewardData do
                if dataItem.nType == rewardData[k].nType then
                    rewardData[k].nCount = rewardData[k].nCount + dataItem.nCount
                    isTypeExist = true
                    break
                end
            end
            if isTypeExist == false then
                count = count + 1
                rewardData[count] = {}
                rewardData[count].nType = dataItem.nType
                rewardData[count].nCount = dataItem.nCount
            end
        end
    end

    local curItemCount = panelRewardItems:getChildrenCount() - 1
    local itemCount = #rewardData
    local validCount = 0
    for i = 1, itemCount do
        if rewardData[i].nCount ~= nil and rewardData[i].nCount > 0 then
            validCount = validCount + 1
        end
    end
    panelRewardItems:getChildByName("Img_Noaward"):setVisible(false)
    if validCount <= 0 then 
        --panelRewardItems:setVisible(false)
        for i = 1, 3 do
            local item = panelRewardItems:getChildByName("Node_Item_"..i)
            if item then
                item:setVisible(false)
            end
        end
        panelRewardItems:getChildByName("Img_Noaward"):setVisible(true)
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
            local spriteBk = cc.Sprite:createWithSpriteFrameName("GameCocosStudio/plist/ArenaOverStatement/athletics_ben_iconbg.png")
            spriteBk:setName("Sprite_BK")
            item:addChild(spriteBk)
            local spriteIcon = cc.Sprite:createWithSpriteFrameName("Game_Img_Silver.png")
            spriteIcon:setName("Sprite_Icon")
            spriteIcon:setPosition(cc.p(-3, 3))
            item:addChild(spriteIcon)
            local textCount = cc.Label:createWithBMFont("res/GameCocosStudio/font/1.fnt", "")
            textCount:setName("Text_Count")
            textCount:setPosition(cc.p(0, -65))
            textCount:setString("0")
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
    local startX = (totalWidth - allItemsWidth) / 2 + itemWidth / 2
    local rewardTypeList = ArenaConfig["ArenaRewardTypeList"]
    for i = 1, validCount do
        local item = panelRewardItems:getChildByName("Node_Item_"..i)
        if item ~= nil then 
            item:setPosition(cc.p(startX + (itemWidth + gap) * (i - 1), totalHeight/2))
            local spriteIcon = item:getChildByName("Sprite_Icon")
            local textCount = item:getChildByName("Text_Count")
            local itemAtt = self._arenaProgress:getItemByKeyAttribute(rewardTypeList, "nType", rewardData[i].nType)
            if itemAtt ~= nil then
                spriteIcon:setSpriteFrame(itemAtt.imageName)
                --textCount:setString("x"..rewardData[i].nCount..""..itemAtt.typeUnit)
                textCount:setString(rewardData[i].nCount)
            end
        end
    end
end

--局数信息
function MyGameArenaOverStatement:refreshBoutInfo()
    if self._data == nil then return false end
    if self._panelBoutInfo == nil then return end
    if self._isExited == true then return end

    local boutInfo = self._data.boutInfo
    if boutInfo == nil then return end

    local textWinBout = self._panelBoutInfo:getChildByName("Node_InfoItem_1"):getChildByName("Text_Value")
    local textMaxStreaking = self._panelBoutInfo:getChildByName("Node_InfoItem_2"):getChildByName("Text_Value")
    local textTotalBout = self._panelBoutInfo:getChildByName("Node_InfoItem_3"):getChildByName("Text_Value")

    textWinBout:setString(boutInfo.nWinBout)
    textMaxStreaking:setString(boutInfo.nMaxStreaking)
    textTotalBout:setString(boutInfo.nTotalBout)
end

--升级
function MyGameArenaOverStatement:showRankUp()
    if self._panelRankUp == nil then return end
    if self._isExited == true then return end

    if self._gameController == nil then return end
    local rankUpData = self._gameController:getRankUpData()
    if rankUpData == nil then return end
    
    if type(DEBUG) == "number" and DEBUG > 0 then
        dump(rankUpData)
    end

    local userData_1 = rankUpData[1]
    local rankUserCount = MyGameArenaOverStatement.RANK_USER_COUNT
    if #rankUpData ~= rankUserCount then return false end
    local rankPrev = userData_1.userRankPrev
    local rank = userData_1.userRank
    if rank <= 0 or rank >= rankPrev then return end --排名无效或者未发生变化，则不显示排名变化页面

    if self:refreshRankUp(rankUpData) == false then return end
    if self._spriteLight ~= nil then
        self._spriteLight:runAction(cc.RepeatForever:create(cc.RotateBy:create(1, 30))) --光芒旋转
    end
    self._panelRankUp:setVisible(true)
end

function MyGameArenaOverStatement:refreshRankUp(rankUpData)
    if rankUpData == nil then return false end
    if self._panelRankUp == nil then return false end
    if self._isExited == true then return false end

    local rankUserCount = MyGameArenaOverStatement.RANK_USER_COUNT
    if #rankUpData ~= rankUserCount then return false end

    for i = 1, rankUserCount do
        local nodeUser = self._panelRankUp:getChildByName("Node_RankInfo_"..(rankUserCount - i + 1))
        local textUserName = nodeUser:getChildByName("Text_UserName")
        local textUserScore = nodeUser:getChildByName("Text_UserScore")
        local textUserRank = nodeUser:getChildByName("Text_UserRank")
        local spritePortrait = nodeUser:getChildByName("Sprite_Portrait")
        local userData = rankUpData[i]
        if userData.userGender == MyGameArenaProgress.GENDER_BOY then
            --spritePortrait:setSpriteFrame("img_portrait_boy.png")
            spritePortrait:setTexture("res/Game/GamePic/GameContents/Role_Boy.png")
        else
            --spritePortrait:setSpriteFrame("img_portrait_girl.png")
            spritePortrait:setTexture("res/Game/GamePic/GameContents/Role_Girl.png")
        end

        textUserName:setString(userData.userName)
        textUserScore:setString(userData.userScore)
        textUserRank:setString(userData.userRank)
    end
    --动画
    local nodeUser_1 = self._panelRankUp:getChildByName("Node_RankInfo_1")
    local nodeUser_2 = self._panelRankUp:getChildByName("Node_RankInfo_2")
    local delayAction = cc.DelayTime:create(0.5)
    local moveTime = 0.8
    local moveAction_1 = cc.MoveTo:create(moveTime, cc.p(nodeUser_1:getPositionX(),nodeUser_2:getPositionY()))
    local moveAction_2 = cc.MoveTo:create(moveTime, cc.p(nodeUser_2:getPositionX(),nodeUser_1:getPositionY()))
    nodeUser_1:runAction(cc.Sequence:create(delayAction, moveAction_1))
    nodeUser_2:runAction(cc.Sequence:create(delayAction, moveAction_2))
    return true
end

function MyGameArenaOverStatement:hideRankUp()
    if self._panelRankUp == nil then return end
    if self._isExited == true then return end

    self._panelRankUp:setVisible(false)
end

function MyGameArenaOverStatement:onExit()
    if self._isExited == true then return end --退出处理只执行1次
    if self._arenaProgress ~= nil then self._arenaProgress:onExit() end
    if self._totalScoreScroller ~= nil then self._totalScoreScroller:onExit() end

    --移除自己，释放资源
    if self._arenaOverStatementLayer ~= nil then
        self._arenaOverStatementLayer:removeSelf()
        self._arenaOverStatementLayer = nil
    end

    self._isExited = true
    if self._gameController then
        --self._gameController:onArenaOverStatementClosed()
        if self._gameController._baseGameScene then
            self._gameController._baseGameScene._arenaOverStatement = nil
        end
    end
end

function MyGameArenaOverStatement:isExited()
    return self._isExited
end

function MyGameArenaOverStatement:show(data)
    if data == nil then return end

    self._data = data
    if self:refresh() == true then
        self._arenaOverStatementLayer:setVisible(true)
    end
end

function MyGameArenaOverStatement:hide()
    if self._arenaOverStatementLayer == nil then return end

    self._arenaOverStatementLayer:setVisible(false)
end

function MyGameArenaOverStatement:playArenaEffect(soundName)
    
end

return MyGameArenaOverStatement