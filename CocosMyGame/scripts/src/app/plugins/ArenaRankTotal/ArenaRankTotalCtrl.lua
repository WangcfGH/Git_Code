local ArenaRankTotalCtrl = class('ArenaRankTotalCtrl', cc.load('BaseCtrl'))
local viewCreater = import('src.app.plugins.ArenaRankTotal.ArenaRankTotalView')
local User = mymodel('UserModel'):getInstance()
local ArenaRankTotalModel = require('src.app.plugins.ArenaRankTotal.ArenaRankTotalModel'):getInstance()
local ArenaRankConfig =  cc.load("json").json.decode(cc.FileUtils:getInstance():getStringFromFile("src/app/HallConfig/ArenaRank.json"))
local ScrollBar            = import("src.app.Game.mCommon.ScrollBar")

function ArenaRankTotalCtrl:onCreate(...)
	local viewNode = self:setViewIndexer(viewCreater:createViewIndexer()) 
    
    self._scrollBar = ScrollBar:create(viewNode.scrollBar, viewNode.rankList)

    self:createRankList()

    self:bindDestroyButton(viewNode.closeBtn) 
    viewNode.rankList:addEventListener(handler(self, self.onRankListScrolled))
    self:listenTo(ArenaRankTotalModel, ArenaRankTotalModel.RANK_INFO_UPDATED, handler(self, self.updateRankList))

    self._isPopUpFinished = false
    local function callBackInTheEnd()
        ArenaRankTotalModel:reqRankInfo()
        self._isPopUpFinished = true
    end    

    local lastAction = cc.CallFunc:create(callBackInTheEnd)

    local panelAni = viewNode:getChildByName("Panel_Celebrity")
    if not tolua.isnull(panelAni) then
        panelAni:setVisible(true)
        panelAni:setScale(0.6)
        panelAni:setOpacity(255)
        local scaleTo1 = cc.EaseSineOut:create(cc.ScaleTo:create(0.16, 1.1))
        local scaleTo2 = cc.ScaleTo:create(0.09, 1)

        local ani = cc.Sequence:create(scaleTo1, scaleTo2,lastAction,nil)
        panelAni:runAction(ani)
    end
    -- viewNode.theBkList:setScale(0.7)
    -- viewNode.theBkList:setVisible(false)
    -- viewNode.theBkList:runAction(cc.Sequence:create(cc.Show:create(), cc.ScaleTo:create(0.1, 1), lastAction, nil))
end

function ArenaRankTotalCtrl:createRankList()
    local viewNode = self._viewNode

    if self._itemScore == nil then
        local itemScoreNode = cc.CSLoader:createNode("res/hallcocosstudio/arena/node_celebrityrank.csb")
        local itemScore = itemScoreNode:getChildByName("Img_ScoreReward")
        itemScoreNode:removeChild(itemScore, true)
        self._itemScore = itemScore
        self._itemScore:retain()
        self._nameTxtColor = itemScore:getChildByName("Text_PlayerName"):getTextColor()
    end

    self._rankListConfig = {
        ["startPosOffset"] = {x = 0, y = 0}, --左上角开始位置
        ["itemWidth"] = 709,
        ["itemHeight"] = 65,
        ["itemOffset"] = 10,
        ["viewOffset"] = 70,
        ["visibleItemCount"] = 10, --初始显示数量
        ["addItemCount"] = 20 --每次增加数量
    }

    self:updateRankList()
end

function ArenaRankTotalCtrl:createRankItem(rank, score, name, isBoy)
    local width = self._rankListConfig["itemWidth"]
    local height = self._rankListConfig["itemHeight"]
  
    local item = self._itemScore:clone()

    --排名
    local rankFirst = 1
    local rankSecond = 2
    local rankThird = 3    

    local Rank1Img = item:getChildByName("Img_Rank1")
    local Rank2Img = item:getChildByName("Img_Rank2")
    local Rank3Img = item:getChildByName("Img_Rank3")
    local RankOtherImg = item:getChildByName("Img_Rank4")

    Rank1Img:setVisible(false)
    Rank2Img:setVisible(false)
    Rank3Img:setVisible(false)
    local rankImgTable = {Rank1Img, Rank2Img, Rank3Img}
    RankOtherImg:setVisible(false)


    local rankLabel
    if rank >= rankFirst and rank <= rankThird then
        rankImgTable[rank]:setVisible(true)                    
    else
        RankOtherImg:setVisible(true)
        local rankFromToLabel = RankOtherImg:getChildByName("Fnt_Rank")
        rankFromToLabel:setString(string.format(ArenaRankConfig["TotalRankTxt"], rank))  
    end
    
    --名字
    local nameTxt = item:getChildByName("Text_PlayerName")
    nameTxt:setString(name)
    nameTxt:setTextColor(self._nameTxtColor)

    --分
    local scoreTxt = item:getChildByName("Img_MaxScore"):getChildByName("Text_MaxScoreValue")
    scoreTxt:setString(score)
    
    return item
end

function ArenaRankTotalCtrl:createSelfRankItem(rank, score, isInRange)
    local viewNode = self._viewNode
    local isBoy = true
    local name = User.szUsername
    name = MCCharset:getInstance():gb2Utf8String(name, string.len(name))
    --[[local girl = 1    
    if plugin.AgentManager:getInstance():getUserPlugin():getUserSex() == girl then
        isBoy = false
    end]]
    viewNode.selfNameFnt:setString(name)
    viewNode.selfScoreFnt:setString(score)

    if not isInRange then
        viewNode.selfRankFnt:setString(ArenaRankConfig["OutRankTotal"])
        --viewNode.selfRankFnt:setString(MCCharset:getInstance():gb2Utf8String(ArenaRankConfig[OutRankTotal], string.len(ArenaRankConfig[OutRankTotal])))
    else
        viewNode.selfRankFnt:setString(rank)
    end
    
    return container
end

function ArenaRankTotalCtrl:updateRankList()
    local viewNode = self._viewNode

    --重置 
    viewNode.rankList:removeAllChildren()
    
    local list = ArenaRankTotalModel:getRankList()
    local totalItemCount = #list
    local listWidth = viewNode.rankList:getContentSize().width
    local listHeight = viewNode.rankList:getContentSize().height
    local itemHeight = self._rankListConfig["itemHeight"]
    local itemOffset = self._rankListConfig["itemOffset"]
    local viewOffset = self._rankListConfig["viewOffset"] 
    listHeight = math.max(listHeight, totalItemCount * (itemHeight + itemOffset) + viewOffset)
    viewNode.rankList:setInnerContainerSize(cc.size(listWidth, listHeight))
    self._nextRankItemPosY = self._rankListConfig["startPosOffset"].y
    self._visibleRankItemCount = 0

    --初始可见条目
    local initVisibleItemCount = math.min(totalItemCount, self._rankListConfig["visibleItemCount"])
    for i, itemData in ipairs(list) do
        if i > initVisibleItemCount then
            break
        end 
        local item = self:createRankItem(itemData.rank, itemData.score, itemData.name, itemData.sex)
        self:addItemToRankListView(item)
    end

    local selfRankInfo = ArenaRankTotalModel:getMyRankInfo()
    local selfRank = selfRankInfo.rank or 0
    local selfRankScore = selfRankInfo.score or 0
    local isInRange = selfRankInfo.isInRange
    local selfRankItem = self:createSelfRankItem(selfRank, selfRankScore, isInRange)

    self._scrollBar:resetForScrollView(viewNode.rankList)
end

function ArenaRankTotalCtrl:addItemToRankListView(item)
    local viewNode = self._viewNode

    local width = viewNode.rankList:getInnerContainerSize().width
    local height = viewNode.rankList:getInnerContainerSize().height 
    local itemHeight = self._rankListConfig["itemHeight"]
    local itemOffset = self._rankListConfig["itemOffset"]

    item:setAnchorPoint(cc.p(0.5, 1))
    item:setPosition(cc.p(width / 2, height - self._nextRankItemPosY))

    viewNode.rankList:addChild(item)

    self._visibleRankItemCount = self._visibleRankItemCount + 1
    self._nextRankItemPosY = self._nextRankItemPosY + itemHeight + itemOffset
end

function ArenaRankTotalCtrl:onRankListScrolled(sender, state)
    if not (self._nextRankItemPosY and self._visibleRankItemCount) then
        return 
    end  

    local viewNode = self._viewNode

    local posY = viewNode.rankList:getInnerContainer():getPositionY() * -1
    local innerHeight = viewNode.rankList:getInnerContainerSize().height
    local visibleHeight = viewNode.rankList:getContentSize().height 
    local invisibleHeight = innerHeight - visibleHeight
    local moveLength =  invisibleHeight - posY --滚动距离

    if self._nextRankItemPosY - moveLength <= visibleHeight then 
        local list = ArenaRankTotalModel:getRankList()
        local visibleItemCount = self._visibleRankItemCount
        local addCount = 0
        for i, itemData in ipairs(list) do
            if i > visibleItemCount and addCount <= self._rankListConfig["addItemCount"] then 
                local item = self:createRankItem(itemData.rank, itemData.score, itemData.name, itemData.sex)
                self:addItemToRankListView(item)                   
                addCount = addCount + 1
            end
        end         
    end
    
    self._scrollBar:updateScrollBarPos(viewNode.rankList)
end

function ArenaRankTotalCtrl:onKeyboardReleased(keyCode, event)
	if keyCode == cc.KeyCode.KEY_BACK then
        event:stopPropagation()
		if(self.onKeyBack)then
			return self:onKeyBack()
		end
	end
end

function ArenaRankTotalCtrl:onKeyBack()    
	if self:informPluginByName(nil,nil) and self._isPopUpFinished  then
		self:removeSelfInstance()
	end
end

function ArenaRankTotalCtrl:onExit()    
	ArenaRankTotalCtrl.super.onExit(self)
    if self._itemScore then
        self._itemScore:release()
        self._itemScore = nil
    end
end


return ArenaRankTotalCtrl