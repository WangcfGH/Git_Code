local viewCreater=import('src.app.plugins.ArenaModel.ArenaRewardInfoView')
local ArenaRewardInfoCtrl=class('ArenaRewardInfoCtrl',cc.load('BaseCtrl'))
local ArenaRankData = require("src.app.plugins.ArenaRank.ArenaRankData"):getInstance()
local ArenaRankConfig =  cc.load("json").json.decode(cc.FileUtils:getInstance():getStringFromFile("src/app/HallConfig/ArenaRank.json"))
local ScrollBar            = import("src.app.Game.mCommon.ScrollBar")

local MainTabEventMap = {
        NeedHideNode                   = {    --tab切换时需要隐藏的控件 于TabButtons.showNode配合
            ["rankPanel"]            = {},
            ["scorePanel"]           = {},
        },
        TabButtons                                 = {
            [1]      = {defaultShow = true, checkBtn = "scoreCheck", showNode = {["scorePanel"]={}} },
            [2]      = {checkBtn = "rankCheck", showNode = {["rankPanel"]={}} },
        }
    }

function ArenaRewardInfoCtrl:onCreate(params)
    local viewNode=self:setViewIndexer(viewCreater:createViewIndexer())
    self:bindDestroyButton(viewNode.closeBt)
    
    self._scrollBar = ScrollBar:create(viewNode.scrollBar, viewNode.rankScorllView)

    local function CheckCallback(index)
        self:playEffectOnPress()
        if index == 1 then
            if self._scrollBar then
                self._scrollBar:resetForScrollView(viewNode.scoreScorllView)
            end
        elseif index == 2 then
            if self._scrollBar then
                self._scrollBar:resetForScrollView(viewNode.rankScorllView)
            end
        end
    end
    my.initCheckButtonEvent(viewNode, MainTabEventMap, CheckCallback)
    
    self:createRewardList()
    self:createScoreList()

    local itemRewardNode = cc.CSLoader:createNode("res/hallcocosstudio/arena/node_rankreward.csb")
    local itemReward = itemRewardNode:getChildByName("Img_ScoreReward")
    itemRewardNode:removeChild(itemReward, true)
    self._itemReward = itemReward
    self._itemReward:retain()

    local itemScoreNode = cc.CSLoader:createNode("res/hallcocosstudio/arena/node_scorereward.csb")
    local itemScore = itemScoreNode:getChildByName("Img_ScoreReward")
    itemScoreNode:removeChild(itemScore, true)
    self._itemScore = itemScore
    self._itemScore:retain()

    if ArenaRankData._rewardGetForServer == false then
        ArenaRankData:requestRewardList()
    end

    --比赛奖励数据
    local matchRewardList = {}
    for i = 1, params.nAwardInfoNumber do
        matchRewardList[i] = {}
        matchRewardList[i].levelScoreList = params.awardInfo[i].nMatchScore
        matchRewardList[i].levelRewardsList={}
        for j = 1, params.awardInfo[i].nAwardNumber do
            table.insert(matchRewardList[i].levelRewardsList, params.awardInfo[i].awardType[j])
        end
    end
    table.sort(matchRewardList, function ( item, item2 )
    	return item.levelScoreList > item2.levelScoreList
    end)
    self._matchRewardList = matchRewardList
    
    viewNode.rankScorllView:addEventListener(handler(self, self.onRewardListScrolled))
    viewNode.scoreScorllView:addEventListener(handler(self, self.onMatchRewardListScrolled))
    
    self:update()

    self:listenTo(ArenaRankData, ArenaRankData.ARENA_RANK_GET_REWARD_LIST_OK, handler(self, self.updateRewardList))
end

function ArenaRewardInfoCtrl:onExit()
    ArenaRewardInfoCtrl.super.onExit(self)
    if self._itemReward then
        self._itemReward:release()
    end
    if self._itemScore then
        self._itemScore:release()
    end
end

function ArenaRewardInfoCtrl:createRewardList()
    self._rewardListConfig = {
        ["startPosOffset"] = {x = 0, y = 0}, --左上角开始位置
        ["itemWidth"] = 709,
        ["itemHeight"] = 65,
        ["viewOffset"] = 10,
        ["itemOffset"] = 20, --每个条目的间隔
        ["visibleItemCount"] = 10, --初始显示数量
        ["addItemCount"] = 20 --每次增加数量
    }
end

function ArenaRewardInfoCtrl:createScoreList()
    self._scoreListConfig = {
        ["startPosOffset"] = {x = 0, y = 5}, --左上角开始位置
        ["itemWidth"] = 709,
        ["itemHeight"] = 65,
        ["viewOffset"] = 10,
        ["itemOffset"] = 20, --每个条目的间隔
        ["visibleItemCount"] = 10, --初始显示数量
        ["addItemCount"] = 20 --每次增加数量
    }
end

function ArenaRewardInfoCtrl:update()
    self:updateRewardList()   
    self:updateScoreList()
end

function ArenaRewardInfoCtrl:updateRewardList()
    local viewNode = self._viewNode

    --重置 
    viewNode.rankScorllView:removeAllChildren()

    --滚动区域
    local list = ArenaRankData:getRewardList() or {}
    local totalItemCount = #list
    local listWidth = viewNode.rankScorllView:getContentSize().width
    local listHeight = viewNode.rankScorllView:getContentSize().height
    local itemHeight = self._rewardListConfig["itemHeight"]
    local itemOffset = self._rewardListConfig["itemOffset"]
    local viewOffset = self._rewardListConfig["viewOffset"]    
    listHeight = math.max(listHeight, totalItemCount * (itemHeight + itemOffset) + viewOffset)
    viewNode.rankScorllView:setInnerContainerSize(cc.size(listWidth, listHeight))
    self._nextRewardItemPosY = self._rewardListConfig["startPosOffset"].y
    self._visibleRewardItemCount = 0
    self._nextRewardInList = 1

    --初始可见条目
    local initVisibleItemCount = math.min(totalItemCount, self._rewardListConfig["visibleItemCount"])
    local validItemCount = 0
    local nextRewardInList = 1
    for i, itemData in ipairs(list) do
        if validItemCount >= initVisibleItemCount then
            break
        end 
        local item = self:createRewardItem(itemData.rankBegin, itemData.rankEnd, itemData.prizeList)
        if item then
            self:addItemToRewardListView(item)
            validItemCount = validItemCount + 1
        end
        nextRewardInList = nextRewardInList + 1
    end
    self._nextRewardInList = nextRewardInList
end

function ArenaRewardInfoCtrl:addItemToRewardListView(item)
    local viewNode = self._viewNode

    local width = viewNode.rankScorllView:getInnerContainerSize().width
    local height = viewNode.rankScorllView:getInnerContainerSize().height 
    local itemHeight = self._rewardListConfig["itemHeight"]
    local itemOffset = self._rewardListConfig["itemOffset"]

    item:setPosition(cc.p(width / 2, height - self._nextRewardItemPosY))

    item:setAnchorPoint(cc.p(0.5, 1))
    viewNode.rankScorllView:addChild(item)

    self._visibleRewardItemCount = self._visibleRewardItemCount + 1
    self._nextRewardItemPosY = self._nextRewardItemPosY + itemHeight + itemOffset
end

function ArenaRewardInfoCtrl:createRewardItem(rankBegin, rankEnd, prizeList)
    --local itemNode = cc.CSLoader:createNode("res/hallcocosstudio/mainpanel/node_rankreward.csb")
    --local item = itemNode:getChildByName("Img_ScoreReward")
    --itemNode:removeChild(item, true)
    local item = self._itemReward:clone()
    item:setAnchorPoint(cc.p(0.5, 1))
    
    local width = item:getContentSize().width
    local height = item:getContentSize().height

    local rankFirst = 1
    local rankSecond = 2
    local rankThird = 3
    
    local Rank1Img = item:getChildByName("Img_Rank1")
    local Rank2Img = item:getChildByName("Img_Rank2")
    local Rank3Img = item:getChildByName("Img_Rank3")
    local RankOtherImg = item:getChildByName("Img_Rank4")
    local rewardImg = item:getChildByName("Img_Reward")

    Rank1Img:setVisible(false)
    Rank2Img:setVisible(false)
    Rank3Img:setVisible(false)
    local rankImgTable = {Rank1Img, Rank2Img, Rank3Img}
    RankOtherImg:setVisible(false)

    --排名, 奖励
    if rankBegin == rankEnd and rankBegin >= rankFirst and rankEnd <= rankThird then
        rankImgTable[rankBegin]:setVisible(true)       
    else
        RankOtherImg:setVisible(true)
        local rankFromToLabel = RankOtherImg:getChildByName("Fnt_Rank")

        rankFromToLabel:setString(string.format(ArenaRankConfig["RankFromTo"], rankBegin, rankEnd))
    end    
    local prizeContainer = self:createPrizeItemList(prizeList, rewardImg)

    --没有奖品
    if prizeContainer == nil then
        return nil
    end

    return item
end

function ArenaRewardInfoCtrl:createPrizeItemList(prizeList, parentNode)
    local itemIcon1 = parentNode:getChildByName("Img_ExchangeIcon")
    local itemIcon2 = parentNode:getChildByName("Img_SilverIcon")
    local itemValue1 = parentNode:getChildByName("Text_ExchangeValue")
    local itemValue2 = parentNode:getChildByName("Text_SilverValue")
    itemIcon1:setVisible(false)
    itemIcon2:setVisible(false)
    itemValue1:setVisible(false)
    itemValue2:setVisible(false)

    local itemIconPos1 = cc.p(itemIcon1:getPosition())
    local itemIconPos2 = cc.p(itemIcon2:getPosition())
    local itemValuePos1 = cc.p(itemValue1:getPosition())
    local itemValuePos2 = cc.p(itemValue2:getPosition())
    local itemNodeTable = {{itemIcon = itemIcon2, itemValue = itemValue2}, {itemIcon = itemIcon1, itemValue = itemValue1}}   

    local itemPosTable = {{itemIconPos = itemIconPos2, itemValuePos = itemValuePos2}, {itemIconPos = itemIconPos1, itemValuePos = itemValuePos1}}

    table.sort(prizeList, function ( item, item2 )
    	return item.prizeID < item2.prizeID
    end)
    
    --nType 1 为银两 2为兑换券

    local havePrize = nil
    for i, prizeItem in ipairs(prizeList) do
        if prizeItem.count > 0 then
            if prizeItem.prizeID > 0 and prizeItem.prizeID <= #itemNodeTable then
                local currTable = itemNodeTable[prizeItem.prizeID]
                local currPosTable = itemPosTable[prizeItem.prizeID]
                currTable.itemValue:setString(prizeItem.count)
                currTable.itemIcon:setPosition(currPosTable.itemIconPos)
                currTable.itemValue:setPosition(currPosTable.itemValuePos)
                currTable.itemIcon:setVisible(true)
                currTable.itemValue:setVisible(true)
                havePrize = true
            end
        end
    end
    return havePrize
end

function ArenaRewardInfoCtrl:onRewardListScrolled(sender, state)
    if not (self._nextRewardItemPosY and self._visibleRewardItemCount) then
        return 
    end  

    local viewNode = self._viewNode

    local posY = viewNode.rankScorllView:getInnerContainer():getPositionY() * -1
    local innerHeight = viewNode.rankScorllView:getInnerContainerSize().height
    local visibleHeight = viewNode.rankScorllView:getContentSize().height 
    local invisibleHeight = innerHeight - visibleHeight
    local moveLength =  invisibleHeight - posY --滚动距离

    if self._nextRewardItemPosY - moveLength <= visibleHeight then 
        local list = ArenaRankData:getRewardList() or {}
        local visibleItemCount = self._visibleRewardItemCount
        local addCount = 0
        local nextRewardInList = 1
        for i, itemData in ipairs(list) do
            if addCount >= self._rewardListConfig["addItemCount"] then
                break
            end
            if i > visibleItemCount and i >= self._nextRewardInList then
                local item = self:createRewardItem(itemData.rankBegin, itemData.rankEnd, itemData.prizeList)
                if item then
                    self:addItemToRewardListView(item)   
                    addCount = addCount + 1  
                end      
            end
            nextRewardInList = nextRewardInList + 1
        end         
        self._nextRewardInList = nextRewardInList
    end

    self._scrollBar:updateScrollBarPos(viewNode.rankScorllView)
end



function ArenaRewardInfoCtrl:updateScoreList()
    local viewNode = self._viewNode

    --重置 
    viewNode.scoreScorllView:removeAllChildren()

    --滚动区域
    local list = self._matchRewardList or {}
    local totalItemCount = #list
    local listWidth = viewNode.scoreScorllView:getContentSize().width
    local listHeight = viewNode.scoreScorllView:getContentSize().height
    local itemHeight = self._scoreListConfig["itemHeight"]
    local itemOffset = self._scoreListConfig["itemOffset"]
    local viewOffset = self._scoreListConfig["viewOffset"]    
    listHeight = math.max(listHeight, totalItemCount * (itemHeight + itemOffset) + viewOffset)
    viewNode.scoreScorllView:setInnerContainerSize(cc.size(listWidth, listHeight))
    self._nextMatchRewardItemPosY = self._scoreListConfig["startPosOffset"].y
    self._visibleMatchRewardItemCount = 0
    self._nextMatchRewardInList = 1

    --初始可见条目
    local initVisibleItemCount = math.min(totalItemCount, self._scoreListConfig["visibleItemCount"])
    local validItemCount = 0
    local nextMatchRewardInList = 1
    for i, itemData in ipairs(list) do
        if validItemCount >= initVisibleItemCount then
            break
        end 
        local item = self:createMatchRewardItem(i, itemData)
        if item then
            self:addItemToMatchRewardListView(item)
            validItemCount = validItemCount + 1
        end
        nextMatchRewardInList = nextMatchRewardInList + 1
    end
    self._nextMatchRewardInList = nextMatchRewardInList
end


function ArenaRewardInfoCtrl:createMatchRewardItem(index, itemData)
    --local itemNode = cc.CSLoader:createNode("res/hallcocosstudio/mainpanel/node_scorereward.csb")
    --local item = itemNode:getChildByName("Img_ScoreReward")
    --itemNode:removeChild(item, true)
    local item = self._itemScore:clone()
    item:setAnchorPoint(cc.p(0.5, 1))
    
    local width = item:getContentSize().width
    local height = item:getContentSize().height

    local itemChildren = item:getChildren()
    for i = 1, item:getChildrenCount() do
        local child = itemChildren[i]
        if child then
            child:setVisible(false)
        end
    end

    local levelBg = item:getChildByName("Img_Level"..index)
    if levelBg then
        levelBg:setVisible(true)
    end

    local scoreBg = item:getChildByName("Img_ScoreBG")
    scoreBg:setVisible(true)
    
    local scoreTxt = scoreBg:getChildByName("Text_ScoreValue")
    scoreTxt:setString(itemData.levelScoreList)

    local rewardBg = item:getChildByName("Img_Reward")
    rewardBg:setVisible(true)

    local itemIcon1 = rewardBg:getChildByName("Img_ExchangeIcon")
    local itemIcon2 = rewardBg:getChildByName("Img_SilverIcon")
    local itemValue1 = rewardBg:getChildByName("Text_ExchangeValue")
    local itemValue2 = rewardBg:getChildByName("Text_SilverValue")
    itemIcon1:setVisible(false)
    itemIcon2:setVisible(false)
    itemValue1:setVisible(false)
    itemValue2:setVisible(false)

    local itemIconPos1 = cc.p(itemIcon1:getPosition())
    local itemIconPos2 = cc.p(itemIcon2:getPosition())
    local itemValuePos1 = cc.p(itemValue1:getPosition())
    local itemValuePos2 = cc.p(itemValue2:getPosition())
    local itemNodeTable = {{itemIcon = itemIcon2, itemValue = itemValue2}, {itemIcon = itemIcon1, itemValue = itemValue1}}   

    local itemPosTable = {{itemIconPos = itemIconPos2, itemValuePos = itemValuePos2}, {itemIconPos = itemIconPos1, itemValuePos = itemValuePos1}}

    --nType 1 为银两 3为兑换券
    local tableType = {[1]=1, [3]=2}

    for i = 1, #itemData.levelRewardsList do
        local rewardItem = itemData.levelRewardsList[i]
        local typeIndex = tableType[rewardItem.nType]

        local currTable = itemNodeTable[typeIndex]
        local currPosTable = itemPosTable[typeIndex]
        currTable.itemValue:setString(rewardItem.nCount)
        currTable.itemIcon:setPosition(currPosTable.itemIconPos)
        currTable.itemValue:setPosition(currPosTable.itemValuePos)
        currTable.itemIcon:setVisible(true)
        currTable.itemValue:setVisible(true)
    end
    

    return item
end

function ArenaRewardInfoCtrl:addItemToMatchRewardListView(item)
    local viewNode = self._viewNode

    local width = viewNode.scoreScorllView:getInnerContainerSize().width
    local height = viewNode.scoreScorllView:getInnerContainerSize().height 
    local itemHeight = self._scoreListConfig["itemHeight"]
    local itemOffset = self._scoreListConfig["itemOffset"]

    item:setPosition(cc.p(width / 2, height - self._nextMatchRewardItemPosY))

    item:setAnchorPoint(cc.p(0.5, 1))
    viewNode.scoreScorllView:addChild(item)

    self._visibleMatchRewardItemCount = self._visibleMatchRewardItemCount + 1
    self._nextMatchRewardItemPosY = self._nextMatchRewardItemPosY + itemHeight + itemOffset
end


function ArenaRewardInfoCtrl:onMatchRewardListScrolled(sender, state)
    if not (self._nextMatchRewardItemPosY and self._visibleMatchRewardItemCount) then
        return 
    end  

    local viewNode = self._viewNode

    local posY = viewNode.scoreScorllView:getInnerContainer():getPositionY() * -1
    local innerHeight = viewNode.scoreScorllView:getInnerContainerSize().height
    local visibleHeight = viewNode.scoreScorllView:getContentSize().height 
    local invisibleHeight = innerHeight - visibleHeight
    local moveLength =  invisibleHeight - posY --滚动距离

    if self._nextMatchRewardItemPosY - moveLength <= visibleHeight then 
        local list = self._matchRewardList or {}
        local visibleItemCount = self._visibleMatchRewardItemCount
        local addCount = 0
        local nextMatchRewardInList = 1
        for i, itemData in ipairs(list) do
            if addCount >= self._scoreListConfig["addItemCount"] then
                break
            end
            if i > visibleItemCount and i >= self._nextMatchRewardInList then
                local item = self:createMatchRewardItem(i, itemData)
                if item then
                    self:addItemToMatchRewardListView(item)   
                    addCount = addCount + 1
                end      
            end
            nextMatchRewardInList = nextMatchRewardInList + 1
        end         
        self._nextMatchRewardInList = nextMatchRewardInList
    end
    
    self._scrollBar:updateScrollBarPos(viewNode.scoreScorllView)
end

return ArenaRewardInfoCtrl