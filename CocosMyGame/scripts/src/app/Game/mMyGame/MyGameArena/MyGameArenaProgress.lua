local MyGameArenaProgress = class("MyGameArenaProgress")
local ArenaConfig         = require("src.app.HallConfig.ArenaConfig")

MyGameArenaProgress.MAX_REWARD_COUNT = 3
MyGameArenaProgress.MAX_LEVEL_COUNT = 6
MyGameArenaProgress.LEVEL_MIN = 1
MyGameArenaProgress.LEVEL_MAX = 6

MyGameArenaProgress.DIFF_STATE_BY_BK = 1
MyGameArenaProgress.DIFF_STATE_BY_ICON = 2 

MyGameArenaProgress.LEVEL_STATE_NOTACHIEVED = 1
MyGameArenaProgress.LEVEL_STATE_ACHIEVED = 2

MyGameArenaProgress.GENDER_BOY = 0
MyGameArenaProgress.GENDER_GIRL = 1

MyGameArenaProgress.LEVEL_PROGRESS_LEFTPOS_X = 52
MyGameArenaProgress.LEVEL_PROGRESS_RIGHTPOS_X = 1210

MyGameArenaProgress.REWARDS_PANEL_LEFTPOS_X = 133.5
MyGameArenaProgress.REWARDS_PANEL_RIGHTPOS_X = 1146.5

function MyGameArenaProgress:ctor(gameController, parentScene, panelLevelProgress)
    self._gameController = gameController
    self._parentScene = parentScene
    self._panelLevelProgress = panelLevelProgress

    self._isExited = false
    self:_init()
end

function MyGameArenaProgress:_init()
    if self._panelLevelProgress == nil then return end

    local panelLevelProgress = self._panelLevelProgress
    --local panelLevelProgressbar = panelLevelProgress:getChildByName("Panel_Progressbar")
    local progressbarBk = panelLevelProgress:getChildByName("Sprite_Progressbar_BK")
    self._progressbarBk = progressbarBk
    local levelProgress = cc.ProgressTimer:create(cc.Sprite:createWithSpriteFrameName("GameCocosStudio/plist/ArenaStatement/img_arenalevel_progressbar.png"))
    levelProgress:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    levelProgress:setMidpoint(cc.p(0, 0)) 
    levelProgress:setBarChangeRate(cc.p(1, 0))
    levelProgress:setName("LevelProgress")
    levelProgress:setPercentage(0)
    --levelProgress:setLocalZOrder(-1)
    progressbarBk:addChild(levelProgress)
    levelProgress:setAnchorPoint(cc.p(0.5, 0.5))
    local barBKSize = progressbarBk:getContentSize()
    levelProgress:setPosition(cc.p(barBKSize.width/2, barBKSize.height/2))
    self._levelProgress = levelProgress

    for i = 1, MyGameArenaProgress.MAX_LEVEL_COUNT do
        local item = self._progressbarBk:getChildByName("Node_Level_Item_"..i)
        if item then
            item:setLocalZOrder(i)
            self:onLevelItemClick(item, i)
        end
    end

    --头像面板
    local panelUserPortrait = progressbarBk:getChildByName("Node_User_Portrait")
    self._panelUserPortrait = panelUserPortrait
    panelUserPortrait:setLocalZOrder(6)
    --等级奖励详细面板
    local panelLevelRewards = progressbarBk:getChildByName("Node_LevelRewards")
    self._panelLevelRewards = panelLevelRewards
    self._panelLevelRewards:setVisible(false)
    panelLevelRewards:setLocalZOrder(7)
end

function MyGameArenaProgress:onLevelItemClick(item, itemIndex)
    if item == nil or itemIndex == nil or itemIndex <= 0 then return end

	item:addTouchEventListener(function(sender, state)
        if state == TOUCH_EVENT_BEGAN then  --began
            sender:setScale(1.2)
            my.playClickBtnSound()
        elseif state == TOUCH_EVENT_MOVED then --moved             
        elseif state == TOUCH_EVENT_ENDED then --ended  
            sender:setScale(1.0)
            self:showLevelRewardsPanel(item, itemIndex)
        else                --cancelled      
            sender:setScale(1.0)
        end
	end)
end

function MyGameArenaProgress:onExit()
    if self._isExited == true then return end --退出处理只执行1次

    self._isExited = true
end

function MyGameArenaProgress:setData(data)
    self._data = data
end

function MyGameArenaProgress:refreshLevels(curScore)
    if curScore == nil then return end
    if self._data == nil then return end
    if self._progressbarBk == nil or self._levelProgress == nil or self._panelUserPortrait == nil then return end
    if self._isExited == true then return end

    local levelItemsData = self._data.levelData
    if levelItemsData == nil then return end

    local levelItems = {}
    local defaultItemCount = MyGameArenaProgress.MAX_LEVEL_COUNT
    for i = 1, defaultItemCount do
        levelItems[i] = {}
        levelItems[i].nDiffStateType = MyGameArenaProgress.DIFF_STATE_BY_BK
        levelItems[i].node = self._progressbarBk:getChildByName("Node_Level_Item_"..i)
        levelItems[i].nState = MyGameArenaProgress.LEVEL_STATE_NOTACHIEVED
        levelItems[i].bShow = false
        levelItems[i].score = levelItemsData.levelScoreList[i]
    end
    --[[levelItems[5].nDiffStateType = MyGameArenaProgress.DIFF_STATE_BY_ICON
    levelItems[5].btnEffectName = "ani_levelbtn_effect_2"
    levelItems[6].nDiffStateType = MyGameArenaProgress.DIFF_STATE_BY_ICON
    levelItems[6].btnEffectName = "ani_levelbtn_effect_2"
    levelItems[7].nDiffStateType = MyGameArenaProgress.DIFF_STATE_BY_ICON
    levelItems[7].btnEffectName = "ani_levelbtn_effect_3"]]

    --从数据中获取信息
    local levelScoreList = levelItemsData.levelScoreList
    for i = 1, #levelScoreList do
        if i <= MyGameArenaProgress.MAX_LEVEL_COUNT then
            if levelScoreList[i] > 0 then
                levelItems[i].bShow = true
            end
            if curScore >= levelScoreList[i] then
                levelItems[i].nState = MyGameArenaProgress.LEVEL_STATE_ACHIEVED
            end
        end
    end

    for i = 1, #levelItems do
        local node = levelItems[i].node
        if node ~= nil then
            if levelItems[i].bShow ~= true then 
                node:setVisible(false)
            else
                node:setVisible(true)
                --位置
                local pos = self:_calPosXByScore(levelItems[i].score)
                node:setPosition(pos)
                --状态
                if levelItems[i].nDiffStateType == MyGameArenaProgress.DIFF_STATE_BY_BK then
                    local itemBk = node:getChildByName("Sprite_Item_BK")
                    if itemBk then
                        if levelItems[i].nState == MyGameArenaProgress.LEVEL_STATE_ACHIEVED then
                            itemBk:setSpriteFrame("GameCocosStudio/plist/ArenaStatement/Athletics_img_yuan2.png")
                        else
                            itemBk:setSpriteFrame("GameCocosStudio/plist/ArenaStatement/Athletics_img_yuan1.png")
                        end
                    end
                --[[else
                    local itemIcon = node:getChildByName("Sprite_Item_Icon")
                    local animEffect = node:getChildByName("Armature_LightEffect")
                    if levelItems[i].nState == MyGameArenaProgress.LEVEL_STATE_ACHIEVED then
                        itemIcon:setSpriteFrame("img_level_"..i.."_m.png")
                        if animEffect ~= nil then 
                            animEffect:getAnimation():play(levelItems[i].btnEffectName)
                            animEffect:setVisible(true)
                        end
                    else
                        itemIcon:setSpriteFrame("img_level_"..i.."_s.png")
                        if animEffect ~= nil then
                            animEffect:setVisible(false)
                        end
                    end]]
                end
            end
        end
        --node:setVisible(false) --测试
    end
    --进度条
    local curProgress = curScore / levelItemsData.nScoreMax * 100
    if curProgress < 0 then curProgress = 0 end
    if curProgress > 100 then curProgress = 100 end
    self._levelProgress:setPercentage(curProgress)
end

--头像
function MyGameArenaProgress:refreshPortrait(curScore)
    if curScore == nil then return end
    if self._data == nil then return end
    if self._panelUserPortrait == nil then return end
    if self._isExited == true then return end

    local pos = self:_calPosXByScore(curScore)
    --[[local nGender = self._data.nGender
    local spritePortrait = self._panelUserPortrait:getChildByName("Sprite_Portrait")
    if nGender == MyGameArenaProgress.GENDER_BOY then
        spritePortrait:setSpriteFrame("img_userportrait_boy.png")
    else
        spritePortrait:setSpriteFrame("img_userportrait_girl.png")
    end]]
    pos = cc.p(pos.x, pos.y + 90)
    self._panelUserPortrait:setPosition(pos)
end

--头像动画
function MyGameArenaProgress:runPortraitAction(originScore, destScore)
    if destScore == nil then return end
    if self._data == nil then return end
    if self._panelUserPortrait == nil then return end
    if self._isExited == true then return end

    local posXByScore = self:_calPosXByScore(destScore)
    local function afterPortraitMove()
        --动画回调
        self:runLevelProgressAction(originScore, destScore)
    end
    local delayAction = cc.DelayTime:create(0.3)
    local distance = math.abs(self._panelUserPortrait:getPositionX() - posXByScore.x)
    local moveTime = self:_calMoveTimeByDistance(distance)
    local portraitMoveAction = cc.MoveTo:create(moveTime, cc.p(posXByScore.x, self._panelUserPortrait:getPositionY()))
    local portraitMoveCallBack = cc.CallFunc:create(afterPortraitMove)
    self._panelUserPortrait:runAction(cc.Sequence:create(delayAction, portraitMoveAction, portraitMoveCallBack))
end

function MyGameArenaProgress:_calPosXByScore(score)
    if score == nil then return 0 end
    if self._data == nil then return 0 end
    if self._levelProgress == nil then return 0 end
    if self._isExited == true then return 0 end

    local ScoreMax = self._data.levelData.nScoreMax

    if score > ScoreMax then --防止头像过了
        score = ScoreMax
    end

    local progressSize = self._levelProgress:getContentSize()
    local y = progressSize.height / 2
    local x = (score / ScoreMax)*progressSize.width
    return cc.p(x, y)
end

function MyGameArenaProgress:calProgressPercent(posXByScore)
    if posXByScore == nil or posXByScore <= 0 then return 0 end

    local leftStartPosX = MyGameArenaProgress.LEVEL_PROGRESS_LEFTPOS_X
    local rightEndPosX = MyGameArenaProgress.LEVEL_PROGRESS_RIGHTPOS_X

    if posXByScore >= rightEndPosX then return 100 end
    if posXByScore <= leftStartPosX then return 0 end
    --调整以使头像指针准确指向进度位置
    local percent = (posXByScore - leftStartPosX) / (rightEndPosX - leftStartPosX)
    local progressPercent = (posXByScore - leftStartPosX) / (rightEndPosX - leftStartPosX + 30) * 100
    local offsetProgress = 0.75 - 0.5 * percent
    progressPercent = progressPercent + offsetProgress
    return progressPercent
end

function MyGameArenaProgress:calLevelByScore(score)
    if score == nil or score < 0 then return 0 end
    if self._data == nil then return 0 end
    local levelItemsData = self._data.levelData
    if levelItemsData == nil then return 0 end

    local level = 0
    local levelScoreList = levelItemsData.levelScoreList
    for i = 1, #levelScoreList do
        if score >= levelScoreList[i] then
            level = i
        else
            break
        end
    end
    if level < 0 then level = 0 end
    if level > MyGameArenaProgress.MAX_LEVEL_COUNT then level = MyGameArenaProgress.MAX_LEVEL_COUNT end
    return level
end

function MyGameArenaProgress:calScoreByLevel(level)
    if level == nil or level <= 0 or level > MyGameArenaProgress.MAX_LEVEL_COUNT then return 0 end
    if self._data == nil then return 0 end
    local levelItemsData = self._data.levelData
    if levelItemsData == nil then return 0 end

    local levelScore = 0
    local levelScoreList = levelItemsData.levelScoreList
    return levelScoreList[level]
end

--进度动画
function MyGameArenaProgress:runLevelProgressAction(originScore, destScore)
    if originScore == nil or destScore == nil then return end
    if self._data == nil then return end
    if self._panelUserPortrait == nil or self._levelProgress == nil then return end
    if self._isExited == true then return end

    local levelItemsData = self._data.levelData
    if levelItemsData == nil then return end

    local maxScore = levelItemsData.nScoreMax
    local originLevel = self:calLevelByScore(originScore)
    local destLevel = self:calLevelByScore(destScore)
    local posXByScore = self:_calPosXByScore(destScore).x

    local function afterProgressAction()
        --刷新等级进度
        self:refreshLevels(destScore)
        --升级回调
        if self._parentScene ~= nil then
            local callback = self._parentScene.onLevelUp
            if callback ~= nil and type(callback) == "function" then callback(self._parentScene, originScore, destScore)  end
        end
    end
    --进度变化动画
    local distance = math.abs(self:_calPosXByScore(originScore).x - posXByScore)
    local moveTime = self:_calMoveTimeByDistance(distance)
    --local destProgress = self:calProgressPercent(posXByScore)
    local destProgress = destScore / maxScore * 100
    local progressAction = cc.ProgressTo:create(moveTime + 0.2, destProgress)
    local progressActionCallBack = cc.CallFunc:create(afterProgressAction)
    self._levelProgress:runAction(cc.Sequence:create(progressAction, progressActionCallBack))
end

function MyGameArenaProgress:_calMoveTimeByDistance(distance)
    if distance == nil then return 0 end
    
    local maxDistance = 1280
    local minMoveTime = 0.1
    local moveTime = distance / maxDistance * 2.5
    if moveTime < minMoveTime then moveTime = minMoveTime end
    return moveTime
end

function MyGameArenaProgress:playArenaEffect(soundName)
    if self._gameController ~= nil then
        self._gameController:playArenaEffect(soundName)
    end
end

function MyGameArenaProgress:hideLevelRewardsPanel()
    if self._panelLevelRewards == nil then return end
    if self._isExited == true then return end

    self._panelLevelRewards:setVisible(false)
end

function MyGameArenaProgress:showLevelRewardsPanel(item, itemIndex)
    if itemIndex == nil or itemIndex <= 0 then return end
    if self._panelLevelRewards == nil then return end
    if self._isExited == true then return end

    if itemIndex == self._curVisibleItemIndex then
        if self._panelLevelRewards:isVisible() == true then
            self._panelLevelRewards:setVisible(false)
            return
        end
    end
    self:refreshLevelRewardsPanel(itemIndex)
    
    local offsetX = 50
    local posX = item:getPositionX() + offsetX
    local leftPosX = MyGameArenaProgress.REWARDS_PANEL_LEFTPOS_X
    local rightPosX = MyGameArenaProgress.REWARDS_PANEL_RIGHTPOS_X
    if posX < leftPosX then posX = leftPosX end
    if posX > rightPosX then posX = rightPosX end
    self._panelLevelRewards:setPositionX(posX)
    --箭头位置
    local spriteArrowLeft = self._panelLevelRewards:getChildByName("Sprite_Arrow_Left")
    local spriteArrowRight = self._panelLevelRewards:getChildByName("Sprite_Arrow_Right")
    if posX >= rightPosX then
        spriteArrowRight:setPositionX(60)
        spriteArrowLeft:setVisible(false)
        spriteArrowRight:setVisible(true)
    else
        if posX <= leftPosX then
            spriteArrowLeft:setPositionX(-90)
        else
            spriteArrowLeft:setPositionX(-40)
        end
        spriteArrowLeft:setVisible(true)
        spriteArrowRight:setVisible(false)
    end 
    
    self._panelLevelRewards:setVisible(true)
    self._curVisibleItemIndex = itemIndex
end

function MyGameArenaProgress:refreshLevelRewardsPanel(itemIndex)
    if itemIndex == nil or itemIndex <= 0 then return end
    if self._data == nil then return end
    if self._panelLevelRewards == nil then return end
    if self._isExited == true then return end
    if itemIndex > MyGameArenaProgress.MAX_LEVEL_COUNT then itemIndex = MyGameArenaProgress.MAX_LEVEL_COUNT end

    --刷新此等级的奖励
    local rewardItemsData = self._data.levelData.levelRewardsList[itemIndex]
    if rewardItemsData == nil then return end

    local rewardItems = {}
    local defaultItemCount = MyGameArenaProgress.MAX_REWARD_COUNT
    local defaultItemNames = {"silver", "exchange_ticket", "cardmaster"}
    local rewardTypeList = ArenaConfig["ArenaRewardTypeList"]
    for i = 1, defaultItemCount do
        rewardItems[i] = {}
        local typeItem = self:getItemByKeyAttribute(rewardTypeList, "name", defaultItemNames[i])
        rewardItems[i].nType = typeItem.nType
        rewardItems[i].nCount = 0
        rewardItems[i].node = self._panelLevelRewards:getChildByName("Node_Item_"..i)
        rewardItems[i].isToShow = false

        --记录各项初始位置
        if self._levelRewardItemPos == nil then
           self._levelRewardItemPos = {}
        end
        if self._levelRewardItemPos[i] == nil then
            self._levelRewardItemPos[i] = {rewardItems[i].node:getPositionX(), rewardItems[i].node:getPositionY()}
        end
    end
    for i = 1, #rewardItems do
        for j = 1, #rewardItemsData do
            if rewardItemsData[j].nType == rewardItems[i].nType then
                rewardItems[i].isToShow = true
                rewardItems[i].nCount = rewardItemsData[j].nCount
                break
            end
        end
    end

    local count = 0
    for i = 1, #rewardItems do
        local node = rewardItems[i].node
        if rewardItems[i].isToShow == true then
            count = count + 1
            if node ~= nil then
                node:setPosition(cc.p(self._levelRewardItemPos[count][1], self._levelRewardItemPos[count][2]))
                local labelItemCount = node:getChildByName("Text_Item_Count")
                if labelItemCount ~= nil then labelItemCount:setString("x"..rewardItems[i].nCount) end
                node:setVisible(true)
            end
        else
            if node ~= nil then node:setVisible(false) end
        end
    end
end

function MyGameArenaProgress:getItemByKeyAttribute(itemList, attName, attValue)
    if itemList == nil or attName == nil or attValue ==  nil then return end

    for i = 1, #itemList do
        if itemList[i][attName] == attValue then
            return itemList[i]
        end
    end
    
    return nil
end

return MyGameArenaProgress
