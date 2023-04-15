local TimingGameRewardDescCtrl = class('TimingGameRewardDescCtrl', cc.load('BaseCtrl'))
local viewCreater = import('src.app.plugins.TimingGame.TimingGameRewardDesc.TimingGameRewardDescView')
local TimingGameModel = import('src.app.plugins.TimingGame.TimingGameModel'):getInstance()

function TimingGameRewardDescCtrl:onCreate( ... )
    local viewNode = self:setViewIndexer(viewCreater:createViewIndexer())

    local params = {...}

    self:bindSomeDestroyButtons(viewNode,{
		'btnConfirm',
    })

    self._currentItemCount = 0
    self._listConfig = {
        ["itemWidth"] = 600, --itemWidth
        ["itemHeight"] = 60, --itemHeight
        ["visibleItemCount"] = 10, --初始显示数量
        ["addItemCount"] = 20, --每次增加数量
    }
  
    self:initListener()
    self:updateUI()

    viewNode.listview:onScroll(handler(self, self.onRankListScrolled))
end


function TimingGameRewardDescCtrl:initListener()
    self:listenTo(TimingGameModel, TimingGameModel.EVENT_MAP["timinggame_getConfigFromSvr"], handler(self, self.updateUI))
end

function TimingGameRewardDescCtrl:updateUI()
    local config = TimingGameModel:getConfig()
    local infoData = TimingGameModel:getInfoData()
    if not config or not infoData then 
        self:goBack()
        TimingGameModel:showTips("获取数据中，请稍后再试!")
        return
    end

    self:getRecord(config)
    self._maxItemCount = math.min(100, #self._record) 
    self:initRankListView(config, infoData)
end

function TimingGameRewardDescCtrl:getRecord(config)
    local config = TimingGameModel:getConfig()
    if not config then 
        return
    end

    self._record = {}
    for i = 1, #config.RewardDescription do        
        table.insert(self._record, config.RewardDescription[i])
    end
end

function TimingGameRewardDescCtrl:initRankListView(config, infoData)
    local viewNode = self._viewNode
    if self._currentItemCount == 0 then
        local initCount = math.min(self._listConfig.visibleItemCount, self._maxItemCount)
        for i = 1, initCount do
            local item = self:createRankItem(self._record[i])
            viewNode.listview:pushBackCustomItem(item)
            
            self._currentItemCount = self._currentItemCount + 1
        end
    end
end

function TimingGameRewardDescCtrl:onRankListScrolled(percent)
    local viewNode = self._viewNode
    local index = viewNode.listview:getCurSelectedIndex()
    if self._currentItemCount == 0 then
        self:initRankListView()
    else
        if self._currentItemCount < self._maxItemCount and not self._notCreating then
            self._notCreating = true

            if index > self._currentItemCount - 10 then
                print("create new item in listview")
                local addCount = math.min(self._listConfig.addItemCount, self._maxItemCount - self._currentItemCount)
                for i = 1, addCount do
                    local index = self._currentItemCount + 1
                    local item = self:createRankItem(self._record[index])
                    viewNode.listview:pushBackCustomItem(item)
                    
                    self._currentItemCount = self._currentItemCount + 1
                end
            end
            self._notCreating = false
        end
    end
end

function TimingGameRewardDescCtrl:createRankItem(rewards)
    local item = ccui.Layout:create()
    item:setAnchorPoint(cc.p(0.5, 1))

    local width = self._listConfig.itemWidth
    local height = self._listConfig.itemHeight
    item:setContentSize(cc.size(width, height))

    local fontPath = "res/common/font/mainfont.TTF"
    local color
    local rank = 0
    if rewards.StartPlace == rewards.EndPlace then
        rank = rewards.StartPlace
    end
    if rank >= 1 and rank <= 3 then 
        local rankIconPath = string.format("hallcocosstudio/images/plist/TimingGame/img_jiangbei_%d.png", rank)
        local rankIcon = cc.Sprite:createWithSpriteFrameName(rankIconPath)
        rankIcon:setPosition(cc.p(158.64, 30.41))
        item:addChild(rankIcon)

        color = cc.c3b(186,86,43)
    else
        color = cc.c3b(182,130,80)
        local rankText = rewards.StartPlace.."-"..rewards.EndPlace
        local rankLabel = cc.Label:createWithTTF(rankText, fontPath, 24)
        rankLabel:setTextColor(color)
        rankLabel:enableOutline(color, 1)
        rankLabel:setPosition(cc.p(159.96, 29.08))
        item:addChild(rankLabel)
    end
        
    local imgLinePath = string.format("hallcocosstudio/images/plist/TimingGame/img_TimingGameRewardDescLine.png")
    local imgLine = cc.Sprite:createWithSpriteFrameName(imgLinePath)
    imgLine:setPosition(cc.p(300, 8))
    item:addChild(imgLine)

    if #rewards.Reward == 0 then
        local rewardLabel = cc.Label:createWithTTF("无奖励", fontPath, 24)
        rewardLabel:setTextColor(color)
        rewardLabel:setPosition(cc.p(450.87, 30.73))
        rewardLabel:enableOutline(color, 1)
        item:addChild(rewardLabel)
    elseif #rewards.Reward == 1 then
        local tmpReward = rewards.Reward[1]

        local rewardPath, count = TimingGameModel:getRewardPathCount(tmpReward)
        local rewardIcon = cc.Sprite:createWithSpriteFrameName(rewardPath)
        rewardIcon:setPosition(cc.p(410.24, 29.94))
        item:addChild(rewardIcon)

        local rewardLabel = cc.Label:createWithTTF("x" .. tostring(count), fontPath, 24)
        rewardLabel:setTextColor(color)
        rewardLabel:setPosition(cc.p(479.86, 30.73))
        rewardLabel:enableOutline(color, 1)
        item:addChild(rewardLabel)

    elseif #rewards.Reward >= 2 then
        local tmpReward = rewards.Reward[1]
        local rewardPath, count = TimingGameModel:getRewardPathCount(tmpReward)
        local rewardIcon = cc.Sprite:createWithSpriteFrameName(rewardPath)
        rewardIcon:setPosition(cc.p(320.24, 29.94))
        item:addChild(rewardIcon)

        local rewardLabel = cc.Label:createWithTTF("x" .. tostring(count), fontPath, 24)
        rewardLabel:setTextColor(color)
        rewardLabel:setPosition(cc.p(390.87, 30.73))
        rewardLabel:enableOutline(color, 1)
        item:addChild(rewardLabel)

        tmpReward = rewards.Reward[2]
        rewardPath, count = TimingGameModel:getRewardPathCount(tmpReward)
        local rewardIcon = cc.Sprite:createWithSpriteFrameName(rewardPath)
        rewardIcon:setPosition(cc.p(461.08, 29.94))
        item:addChild(rewardIcon)

        local rewardLabel = cc.Label:createWithTTF("x" .. tostring(count), fontPath, 24)
        rewardLabel:setTextColor(color)
        rewardLabel:setPosition(cc.p(537.72, 30.73))
        rewardLabel:enableOutline(color, 1)
        item:addChild(rewardLabel)
    end
    
    item:setTouchEnabled(true)
    
    return item
end

function TimingGameRewardDescCtrl:goBack()
    TimingGameRewardDescCtrl.super.removeSelf(self)
end

return TimingGameRewardDescCtrl