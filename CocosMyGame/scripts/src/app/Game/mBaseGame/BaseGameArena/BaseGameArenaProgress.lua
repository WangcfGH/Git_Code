local BaseGameArenaProgress = class('BaseGameArenaProgress')

BaseGameArenaProgress.LEVEL_RESOURCE_PATH        = "res/GameCocosStudio/csb/result_levelunit.csb"
BaseGameArenaProgress.REWARDITEM_RESOURCE_PATH   = "res/GameCocosStudio/csb/itemsunit.csb"
BaseGameArenaProgress.REWARDITEM_S_RESOURCE_PATH = "res/GameCocosStudio/csb/itemsunit_s.csb"
BaseGameArenaProgress.REWARDINFO_RESOURCE_PATH   = "res/GameCocosStudio/csb/itemsreward_bg.csb"

BaseGameArenaProgress.LEVELICON_TEXTURE_PATH     = 'res/hall/hallpic/arena/arenalevel/Arena_IconLevel%d.png'
BaseGameArenaProgress.LEVELICON_S_TEXTURE_PATH   = 'res/hall/hallpic/arena/arenalevel/Arena_IconLevel_S%d.png'

function BaseGameArenaProgress:ctor(progress_reward)
    self._progress_reward = progress_reward
    self._level           = {}
    self._rewardInfoTipBGX = nil
    self._rewardInfoTipBGY = nil

    self:_replaceLoadingbar()
end

function BaseGameArenaProgress:_createLevelItem()
    local realNode = cc.CSLoader:createNode(self.LEVEL_RESOURCE_PATH)
    local panelMain = realNode:getChildByName("Panel_Main")
    local viewNode = {
        realNode  = realNode,
        panelMain = panelMain,
        btn_rank1 = panelMain:getChildByName("Btn_Rank1"),
        btn_rank2 = panelMain:getChildByName("Btn_Rank2"),
    }
    return viewNode
end

function BaseGameArenaProgress:_createRewardInfoTip()
    if self._rewardInfoTip then
        self._rewardInfoTip.realNode:setVisible(true)
        self._rewardInfoTip.img_itemBg:removeAllChildren()
        return self._rewardInfoTip
    end
    local realNode   = cc.CSLoader:createNode(self.REWARDINFO_RESOURCE_PATH)
    local panelMain = realNode:getChildByName("Panel_Main")
    local viewNode = {
        realNode        = realNode,
        panelMain       = panelMain,
        img_itemBg      = panelMain:getChildByName("Img_ItemBG"),
        img_arrow       = panelMain:getChildByName("Img_Arrow")
    }
    self._rewardInfoTip = viewNode
    return viewNode
end

function BaseGameArenaProgress:_createRewardItem(size)
    local resPath = size == 'large' and self.REWARDITEM_RESOURCE_PATH or self.REWARDITEM_S_RESOURCE_PATH
    local realNode   = cc.CSLoader:createNode(resPath)
    local panelMain = realNode:getChildByName("Panel_Main")
    local viewNode = {
        realNode        = realNode,
        panelMain       = panelMain,
        img_itemsIcon   = panelMain:getChildByName("Img_ItemsIcon"),
        text_num        = panelMain:getChildByName("Text_Num")
    }
    return viewNode
end

function BaseGameArenaProgress:_replaceLoadingbar()
    local loadingBar = self._progress_reward
    if not loadingBar then return end

    local progressTimer = cc.ProgressTimer:create(cc.Sprite:create("res/hall/hallpic/arena/arenaprogress/Arena_LevelProgress2.png"))
    progressTimer:setType(cc.PROGRESS_TIMER_TYPE_BAR)

    -- Setup for a bar starting from the bottom since the midpoint is 0 for the y
    progressTimer:setMidpoint(cc.p(0,0))
    -- Setup for a vertical bar since the bar change rate is 0 for x meaning no horizontal change
    progressTimer:setBarChangeRate(cc.p(1, 0))
    local ptNowX,ptNowY    = loadingBar:getPosition()
    progressTimer:setPosition(cc.p(ptNowX,ptNowY))
    progressTimer:setLocalZOrder(loadingBar:getLocalZOrder())

    local parent = loadingBar:getParent()
    loadingBar:removeFromParent()
    parent:addChild(progressTimer)
    progressTimer.setPercent = progressTimer.setPercentage

    self._progress_reward = progressTimer
end

function BaseGameArenaProgress:showLevel(awardCount, awardList, curMatchScore, isTouchForbidden)
    if awardCount == 0 then
        return 
    end
    local progressSize = self._progress_reward:getContentSize()
    local startX = 0
    local startY = progressSize.height/2
    local topMatchScore = 0
    for _, awardInfo in pairs(awardList) do 
        topMatchScore = topMatchScore >= awardInfo.nMatchScore and topMatchScore or awardInfo.nMatchScore
    end
    local buttonSize = {}
    local shiftHight
    curMatchScore = type(curMatchScore) == 'number' and curMatchScore or 0

    for i = 0, awardCount do 
        local awardInfo = awardList[i]
        local levelItem
        if i == 0 then
            levelItem = self:_createLevelItem()
            self._level[0] = levelItem
            local texturePath = string.format(self.LEVELICON_S_TEXTURE_PATH, 0)
            levelItem.btn_rank1:loadTextureNormal(texturePath)
            levelItem.btn_rank1:setTouchEnabled(false)
            levelItem.realNode:setPosition(cc.p(startX, startY))
            table.insert(buttonSize, levelItem.btn_rank1:getContentSize())
            table.insert(buttonSize, levelItem.btn_rank2:getContentSize()) 

            levelItem.btn_rank1:setTouchEnabled(false)
            levelItem.btn_rank2:setTouchEnabled(false)
        else
            levelItem = self:_createLevelItem()
            table.insert(self._level, levelItem)
            local distance = progressSize.width*awardInfo.nMatchScore/topMatchScore
            levelItem.realNode:setPosition(cc.p(startX+distance, startY))

            if curMatchScore >= awardInfo.nMatchScore then
                local texturePath = string.format(self.LEVELICON_TEXTURE_PATH, i)
                levelItem.btn_rank2:loadTextureNormal(texturePath, ccui.TextureResType.localType)
                levelItem.btn_rank2:show()
                levelItem.btn_rank1:hide()
            else
                --local texturePath = string.format(self.LEVELICON_S_TEXTURE_PATH, i)
                local texturePath = string.format(self.LEVELICON_S_TEXTURE_PATH, 1)
                levelItem.btn_rank1:loadTextureNormal(texturePath)
                levelItem.btn_rank1:show()
                levelItem.btn_rank2:hide()
            end

            local function onRankTouched(event)
                if event.name == 'began' then 
                    self:_showRewardInfoTip(awardInfo, levelItem.realNode, shiftHight)
                elseif event.name == 'moved' then 
                elseif event.name == 'ended' then 
                    self:_removeRewardInfoTip()
                elseif event.name == 'cancelled' then 
                    self:_removeRewardInfoTip()
                end
            end
            levelItem.btn_rank1:onTouch(function(event)
                shiftHight = buttonSize[1].height
                onRankTouched(event)
            end)
            levelItem.btn_rank2:onTouch(function(event)
                shiftHight = buttonSize[2].height
                onRankTouched(event)
            end)
            levelItem.btn_rank1:setTouchEnabled(not isTouchForbidden)
            levelItem.btn_rank2:setTouchEnabled(not isTouchForbidden)
        end

        levelItem.realNode:addTo(self._progress_reward)
    end

end

function BaseGameArenaProgress:setPercent(percent)
    self._progress_reward:setPercent(percent)
    --print('percent', percent)
end

function BaseGameArenaProgress:runProgressAction(oldScore, newScore, topMatchScore, callback)
    local loadingBar = self._progress_reward
    if not loadingBar then return end

    local newPercent = math.ceil(newScore/topMatchScore*100)
    local lastPercent = math.ceil(oldScore/topMatchScore*100)
    --local progressAction = cc.ProgressTo:create(lastPercent, newPercent)
    local progressAction = cc.ProgressFromTo:create(1.0, lastPercent, newPercent)
    if type(callback) == 'function' then
        local sequence = cc.Sequence:create(progressAction, cc.CallFunc:create(callback))
        self._progress_reward:runAction(sequence)
    else
        self._progress_reward:runAction(progressAction)
    end

end

function BaseGameArenaProgress:_showRewardInfoTip(awardInfo, parentNode, shiftHight)
    local rewardInfoTip = self:_createRewardInfoTip()

    local itemSize 
    local containerSize = rewardInfoTip.panelMain:getContentSize()
    local arrowHight = rewardInfoTip.img_arrow:getContentSize().height
    local gapX
    local gapY 
    local startX
    local startY
    for count = 1, awardInfo.nAwardNumber do 
        local awardItemInfo = awardInfo.awardType[count]
        local rewardItem = self:_createRewardItem('small')

        rewardItem.realNode:addTo(rewardInfoTip.img_itemBg)

        rewardItem.text_num:setString(awardItemInfo.nCount)

        --奖励的类型 nType 1 银子，2比赛券，3兑换券， 6积分
        local iconName = awardItemInfo.nType == 1 and "RewardDeposit_S.png"
                    or awardItemInfo.nType == 2 and "RewardTicket_S1.png"
                    or awardItemInfo.nType == 3 and "RewardExchange_S.png"
                    or awardItemInfo.nType == 6 and "RewardScore_S.png"
                    or ''
        local texturePath = 'res/hall/hallpic/commonicon/'..iconName
        rewardItem.img_itemsIcon:loadTexture(texturePath)

        itemSize = itemSize or rewardItem.panelMain:getContentSize()
        gapX = gapX or (containerSize.width-itemSize.width*2)/3
        gapY = gapY or (containerSize.height-itemSize.height*2)/3
        startX = startX or gapX
        startY = startY or containerSize.height-gapY-itemSize.height
        local row = math.ceil(count/2)
        local line = count%2 == 0 and 2 or count%2
        rewardItem.realNode:setPosition(cc.p(startX+(gapX+itemSize.width)*(row-1), startY-(gapY+itemSize.height)*(line-1)))
    end

    local overflowX = parentNode:convertToWorldSpace(cc.p(0,0)).x+containerSize.width/2-display.width
    overflowX = overflowX > -10 and overflowX+10 or 0
    local less = parentNode:convertToWorldSpace(cc.p(0,0)).x-containerSize.width/2
    less = less < 10 and less-10 or 0 

    self._rewardInfoTipBGX = self._rewardInfoTipBGX or rewardInfoTip.img_itemBg:getPositionX()
    self._rewardInfoTipBGY = self._rewardInfoTipBGY or rewardInfoTip.img_itemBg:getPositionY()
    rewardInfoTip.img_itemBg:setPosition(cc.p(-overflowX-less+self._rewardInfoTipBGX, self._rewardInfoTipBGY))
    rewardInfoTip.realNode:setPosition(cc.p(0, containerSize.height/2+shiftHight/2+arrowHight))
    
    local preParent = rewardInfoTip.realNode:getParent()
    if preParent then
        rewardInfoTip.realNode:retain()
        preParent:removeChild(rewardInfoTip.realNode)
        parentNode:addChild(rewardInfoTip.realNode)
        rewardInfoTip.realNode:release()
    else
        parentNode:addChild(rewardInfoTip.realNode)
    end

end

function BaseGameArenaProgress:_removeRewardInfoTip()
    if self._rewardInfoTip then 
        self._rewardInfoTip.realNode:setVisible(false)
    end
end

return BaseGameArenaProgress