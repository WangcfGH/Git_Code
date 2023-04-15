local ArenaRankTakeRewardCtrl = class('ArenaRankTakeRewardCtrl', cc.load('BaseCtrl'))
local viewCreater = import('src.app.plugins.ArenaRankTakeReward.ArenaRankTakeRewardView')
local ArenaRankConfig =  cc.load("json").json.decode(cc.FileUtils:getInstance():getStringFromFile("src/app/HallConfig/ArenaRank.json"))
local ArenaRankTakeRewardModel = require("src.app.plugins.ArenaRankTakeReward.ArenaRankTakeRewardModel"):getInstance()

function ArenaRankTakeRewardCtrl:onCreate(...)
	local viewNode = self:setViewIndexer(viewCreater:createViewIndexer())

    if ArenaRankTakeRewardModel:isDataAvailable() then
        local rank = ArenaRankTakeRewardModel:getRank()
        local score = ArenaRankTakeRewardModel:getScore()
        local reward = ArenaRankTakeRewardModel:getReward()
        self:setRank(rank)
        self:setScore(score)
        self:setReward(reward)

        ArenaRankTakeRewardModel:resetData()
    end     

    self:bindDestroyButton(viewNode.closeBtn)
    viewNode.bottomPanel:addClickEventListener(handler(self, self.removeSelfInstance))

    self._isPopUpFinished = false
    local function popUpFinish()
        self._isPopUpFinished = true
    end

    local popUpFinishAction = cc.CallFunc:create(popUpFinish)

    viewNode.theBkList:setScale(0.7)
    viewNode.theBkList:setVisible(false)
    viewNode.theBkList:runAction(cc.Sequence:create(cc.Show:create(), cc.ScaleTo:create(0.1, 1), popUpFinishAction, nil))

    --viewNode.bottomPanel:setVisible(false)
    --viewNode.bottomPanel:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.Show:create(), nil))
end

function ArenaRankTakeRewardCtrl:setRank(rank)
    local viewNode = self._viewNode

    local rankLabel = viewNode.rankText

    rankLabel:setString(rank)

end

function ArenaRankTakeRewardCtrl:setScore(score)
    local viewNode = self._viewNode

    local scoreLabel = viewNode.scoreText
    scoreLabel:setString(score)
end

function ArenaRankTakeRewardCtrl:setReward(reward)
    local viewNode = self._viewNode

    for i = 1, 2 do
        viewNode["rewardNode"..i]:setVisible(false)
    end

    local count = 0
    local itemNode = nil
    for i, prizeItem in ipairs(reward) do
        local item = self:createPrizeItem(prizeItem)
        if item then
            count = count + 1
            itemNode = item
        end                
    end

    if count == 1 then
        local x = viewNode.rewardNode1:getPositionX() + viewNode.rewardNode2:getPositionX()
        itemNode:setPositionX(x/2)
    elseif count == 2 then
        
    end
    
end


function ArenaRankTakeRewardCtrl:createPrizeItem(prizeItem)
    local viewNode = self._viewNode

    local prizeID = prizeItem.prizeID
    local count = prizeItem.count

    --数量为0
    if count == 0 then
        return nil
    end

    --没有资源
    if ArenaRankConfig["PrizeList"][prizeID] == nil 
        or ArenaRankConfig["PrizeList"][prizeID].image == nil then
        return nil
    end

    local container = viewNode["rewardNode"..prizeID]
    container:setVisible(true)

    local numFnt = container:getChildByName("Fnt_Num")

    numFnt:setString(count)

    return container
end

function ArenaRankTakeRewardCtrl:onKeyboardReleased(keyCode, event)
	if keyCode == cc.KeyCode.KEY_BACK then
        event:stopPropagation()
		if(self.onKeyBack)then
			return self:onKeyBack()
		end
	end
end

function ArenaRankTakeRewardCtrl:onKeyBack()    
	if self:informPluginByName(nil,nil) and self._isPopUpFinished  then
		self:removeSelfInstance()
	end
end

return ArenaRankTakeRewardCtrl
