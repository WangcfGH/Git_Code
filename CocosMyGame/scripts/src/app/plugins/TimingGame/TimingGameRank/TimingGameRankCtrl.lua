local TimingGameRankCtrl = class('TimingGameRankCtrl', cc.load('BaseCtrl'))
local viewCreater = import('src.app.plugins.TimingGame.TimingGameRank.TimingGameRankView')
local TimingGameModel = import('src.app.plugins.TimingGame.TimingGameModel'):getInstance()
local user = mymodel('UserModel'):getInstance()
local player=mymodel('hallext.PlayerModel'):getInstance()

function TimingGameRankCtrl:onCreate( ... )
    local viewNode = self:setViewIndexer(viewCreater:createViewIndexer())

    local params = {...}

    self:bindSomeDestroyButtons(viewNode,{
		'btnClose',
    })
    
    self._currentItemCount = 0
    self._curTabStartTime = nil
    self._fontPath = "res/common/font/mainfont.TTF"
    self._tabFontColor = {
        cc.c3b(161, 34, 0), --选中时字体颜色
        cc.c3b(163, 91, 56), --未选中时颜色
    }
    self._tabTexturePath = {
        "hallcocosstudio/images/plist/TimingGame/btn_cebiao_1.png", --选中时纹理
        "hallcocosstudio/images/plist/TimingGame/btn_cebiao_2.png", --未选中时纹理
    }
    self._rankItemFontColor = {
        cc.c3b(186,86,43), --前三名字体颜色
        cc.c3b(186,86,43), --其他人颜色
    }
    self._selfItemFontColor = {
        cc.c3b(163, 161, 162), --自己数据的字体颜色
    }

    self._rankListConfig = {
        ["itemWidth"] = 750, --itemWidth
        ["itemHeight"] = 58, --itemHeight
        ["visibleItemCount"] = 10, --初始显示数量
        ["addItemCount"] = 20, --每次增加数量
        ["refreshItemCount"] = 20, --每次刷新数量
    }

    local config = TimingGameModel:getConfig()
    local infoData = TimingGameModel:getInfoData()
    if not config or not infoData then 
        self:goBack()
        TimingGameModel:showTips("获取数据中，请稍后再试!")
        return
    end
    self:sortInfoData(infoData)

    self:initTabListView(config, infoData)
    self:initialListenTo()

    viewNode.scrollBar:setSlideCallback(handler(self, self.onRankListScrolled))
    viewNode.scrollBar._slider:setTouchEnabled(false)
    viewNode.panelScroller:setVisible(false)

    TimingGameModel:reqTimingGameRecord(infoData.seasonStartTime[1], infoData.seasonEndTime[1])
    self._newClickTab = infoData.seasonStartTime[1]
    self:updateUI(infoData.seasonStartTime[1])
end

function TimingGameRankCtrl:sortInfoData(infoData)
    local tbl = {}
    for i = 1, #infoData.seasonStartTime do
        if infoData.seasonStartTime[i] ~= 0 
        and infoData.seasonEndTime[i] ~= 0 then
            table.insert(tbl, {
                infoData.seasonStartTime[i], 
                infoData.seasonEndTime[i]
            })
        end
    end
    table.sort(tbl, function(l, r)
        return l[1] > r[1]
    end)
    local index = 1
    local curStartTime, curEndTime = TimingGameModel:getCurrentSeasonTime()
    if TimingGameModel:isMatchDay() and curStartTime ~= 0 and curEndTime ~= 0 then
        local bAdd = false
        if #tbl >= 1 then
            local tblFirstTime = TimingGameModel:getTimeTable(tbl[1][1])
            local tblirstTimeSt = os.time(tblFirstTime)
            if curStartTime > tblirstTimeSt then
                bAdd = true
            end
        else
            bAdd = true
        end
        if bAdd then
            local tblStartTime = os.date("*t", curStartTime)
            local tblEndTime = os.date("*t", curEndTime)
            local startTime = string.format("%d%02d%02d%02d%02d00",tblStartTime.year, 
            tblStartTime.month, tblStartTime.day, tblStartTime.hour, tblStartTime.min)
            local endTime = string.format("%d%02d%02d%02d%02d00",tblEndTime.year, 
            tblEndTime.month, tblEndTime.day, tblEndTime.hour, tblEndTime.min)
            table.insert(tbl, 1, {tonumber(startTime), tonumber(endTime)})
        end
    end
    local count = math.min(11, #tbl)
    if count >= 1 then
        for i = 1, count do
            infoData.seasonStartTime[i] = tbl[i][1]
            infoData.seasonEndTime[i] = tbl[i][2]
        end
    else
        self._viewNode.panelRecords:setVisible(false)
        self._viewNode.panelNoRecord:setVisible(true)
    end
end

function TimingGameRankCtrl:initTabListView(config, infoData)
    local size = #infoData.seasonStartTime
    for i = 1, size do
        local startTime = infoData.seasonStartTime[i]
        local endTime = infoData.seasonEndTime[i]

        local stStartTime = TimingGameModel:getTimeTable(startTime)
        local stEndTime = TimingGameModel:getTimeTable(endTime)
        local str = string.format("%d年%02d月%02d日%02d:%02d-%02d:%02d", stStartTime.year, 
        stStartTime.month, stStartTime.day, stStartTime.hour, stStartTime.min, stEndTime.hour, stEndTime.min)

        local custom_image = ccui.ImageView:create(self._tabTexturePath[2], ccui.TextureResType.plistType)  
        custom_image:setContentSize(204,85)  

        local label = cc.Label:createWithTTF(str, self._fontPath, 22, cc.size(175, 48), cc.TEXT_ALIGNMENT_CENTER)
        label:setTextColor(self._tabFontColor[2])
        label:setPosition(cc.p(95.24, 44.18))
        custom_image:addChild(label, 0, "Text_Desc")
        custom_image:setName("Img_Tab" .. startTime)
        custom_image:setTouchEnabled(true)
        -- custom_image:setScale9Enabled(true)
        custom_image:ignoreContentAdaptWithSize(true)
        -- custom_image:setContentSize(cc.size(175, 48))
        custom_image:addTouchEventListener(function(sender, state)
            if state == ccui.TouchEventType.began then
            elseif state == ccui.TouchEventType.moved then
            elseif state == ccui.TouchEventType.ended then
                my.playClickBtnSound()
                self:selectTab(startTime)
                TimingGameModel:reqTimingGameRecord(startTime, endTime)
                self._newClickTab = startTime
                self:updateUI(startTime)
            else
            end
        end)
        self._viewNode.listTabView:pushBackCustomItem(custom_image)
    end
end

function TimingGameRankCtrl:initialListenTo()
    self:listenTo(TimingGameModel, TimingGameModel.EVENT_MAP["timinggame_getSeasonRecordFromSvr"], handler(self, self.updateUIByMsg))
    self:bindProperty(player, 'PlayerData', self, 'PlayerData')
end

function TimingGameRankCtrl:setPlayerData(data)
    if(data.nUserID)then
        self:setPlayerName(data)
    end
end

function TimingGameRankCtrl:setPlayerName(data)
    local viewNode = self._viewNode
    
    local nickName = NickNameInterface.getNickName()
    local userName = nickName or data.szUtf8Username
    if userName and type(userName) == "string" and string.len(userName) > 0 then
        self._name = userName
        my.fitStringInWidget(userName, viewNode.selfTextUserName, 192) 
    end
end

function TimingGameRankCtrl:updateUIByMsg(data)
    if not data or not data.value or not data.value.seasonStartTime then return end
    
    self:updateUI(data.value.seasonStartTime)
end

function TimingGameRankCtrl:updateUI1(startTime)
    local reocrd = TimingGameModel:getSeasonRecord()
    if not reocrd[startTime] then return end

    self._viewNode.listRankView:removeAllItems()
    self._currentItemCount = 0
    self._maxItemCount = #reocrd[startTime][1]
    if self._maxItemCount <= 6 then 
        self._viewNode.panelScroller:setVisible(false)
    else
        self._viewNode.panelScroller:setVisible(true)
    end

    self:selectTab(startTime)

    local config = TimingGameModel:getConfig()
    local infoData = TimingGameModel:getInfoData()
    if not config or not infoData then 
        self:goBack()
        TimingGameModel:showTips("获取数据中，请稍后再试!")
        return
    end

    self:initSelfRankItem(config, infoData, reocrd[startTime])
    self:initRankListView(config, infoData, reocrd[startTime])
end

function TimingGameRankCtrl:updateUI(startTime)
    
    self._initing = true
    local reocrd = TimingGameModel:getSeasonRecord()
    if self._newClickTab ~= startTime then
        return
    end
    if not reocrd[startTime] then 
        self._maxItemCount = 0
        self._viewNode.panelScroller:setVisible(false)
        local items = self._viewNode.listRankView:getItems()
        local size = #items
        while size > self._maxItemCount do
            self._viewNode.listRankView:removeLastItem()
            self._currentItemCount = self._currentItemCount - 1
            size = size - 1
        end
        self:selectTab(startTime)

        local viewNode = self._viewNode
        viewNode.selfRankIcon:setVisible(false)
        viewNode.selfTextRank:setVisible(false)
        viewNode.selfRewardIcon1:setVisible(false)
        viewNode.selfRewardIcon2:setVisible(false)
        viewNode.selfTextRewardNum1:setVisible(false)
        viewNode.selfTextRewardNum2:setVisible(false)
        viewNode.selfTextNoReward:setVisible(false)

        viewNode.selfTextRank:setVisible(true)
        viewNode.selfTextRank:setString("未上榜")
        --viewNode.selfTextUserName:setString(self:getSelfName())
        viewNode.selfTextScore:setString("----")
        viewNode.selfTextNoReward:setVisible(true)
        viewNode.selfTextNoReward:setString("----")

        local color = cc.c3b(163,161,162)
        viewNode.selfTextUserName:setTextColor(color)
        viewNode.selfTextRank:setTextColor(color)
        viewNode.selfTextScore:setTextColor(color)
        viewNode.selfTextRewardNum1:setTextColor(color)
        viewNode.selfTextRewardNum2:setTextColor(color)
        viewNode.selfTextNoReward:setTextColor(color)

        -- viewNode.selfTextUserName:enableOutline(color, 1)
        viewNode.selfTextRank:enableOutline(color, 1)
        viewNode.selfTextScore:enableOutline(color, 1)
        viewNode.selfTextRewardNum1:enableOutline(color, 1)
        viewNode.selfTextRewardNum2:enableOutline(color, 1)
        viewNode.selfTextNoReward:enableOutline(color, 1)
        return 
    end

    self._maxItemCount = #reocrd[startTime][1]
    -- if self._maxItemCount <= 6 then 
    --     self._viewNode.panelScroller:setVisible(false)
    -- else
    --     self._viewNode.panelScroller:setVisible(true)
    -- end
    
    self:selectTab(startTime)

    local config = TimingGameModel:getConfig()
    local infoData = TimingGameModel:getInfoData()
    if not config or not infoData then 
        self:goBack()
        TimingGameModel:showTips("获取数据中，请稍后再试!")
        return
    end

    self._viewNode.listRankView:stopAllActions()
    self._viewNode.listRankView:jumpToTop()
    -- self._viewNode.scrollBar:scrollOnlySliderToPercent(0)

    self:initSelfRankItem(config, infoData, reocrd[startTime])
    self:initRankListView(config, infoData, reocrd[startTime])

    local items = self._viewNode.listRankView:getItems()
    local size = #items
    while size > self._maxItemCount do
        self._viewNode.listRankView:removeLastItem()
        self._currentItemCount = self._currentItemCount - 1
        size = size - 1
    end
    local showCount = math.min(self._maxItemCount, self._rankListConfig.visibleItemCount)
    self._refreshCount = math.max(showCount, self._currentItemCount)
    -- self._refreshCount = showCount --这里多余，请注释，取了20为循环条件，导致刷新不全
    -- self._refreshCount = self._currentItemCount

    for i = 1, self._refreshCount do
        local rec = reocrd[startTime]
        local rank, score, name = i, rec[1][i].maxScore, rec[1][i].userNmae
        
        local rewards = self:getReward(i, rec[1][i].rewardType,rec[1][i].rewardNum)
        if i <= size then
            self:refreshRankItem(rec[1][i], items[i], rank, score, name, rewards)
        else
            local item = self:createRankItem(rec[1][i], rank, score, name, rewards)
            self._viewNode.listRankView:pushBackCustomItem(item)
            -- self._viewNode.listRankView:addChild(item)
            self._currentItemCount = self._currentItemCount + 1
        end
    end
    self._initing = false
end


function TimingGameRankCtrl:selectTab(startTime)
    if self._curTabStartTime then
        if self._curTabStartTime == startTime then
            return
        else
            local oldTab = self._viewNode.listTabView:getChildByName("Img_Tab" .. self._curTabStartTime)
            oldTab:loadTexture(self._tabTexturePath[2], ccui.TextureResType.plistType)
            local label = oldTab:getChildByName("Text_Desc")
            label:setTextColor(self._tabFontColor[2])
        end
    end
    local newTab = self._viewNode.listTabView:getChildByName("Img_Tab" .. startTime)
    newTab:loadTexture(self._tabTexturePath[1], ccui.TextureResType.plistType)
    local newlabel = newTab:getChildByName("Text_Desc")
    newlabel:setTextColor(self._tabFontColor[1])

    self._curTabStartTime = startTime
end

function TimingGameRankCtrl:getReward(index, rewardType, rewardNum)
    local tbl = {}
    for i = 1, #rewardType do
        if rewardType[i] ~= 0 and rewardNum[i] ~= 0 then
            table.insert(tbl, {
                rewardType = rewardType[i],
                rewardNum = rewardNum[i],
            })
        end
    end
    if #tbl == 0 then
        if not self._rewardConfig then
            local config = TimingGameModel:getConfig()
            if config then
                self._rewardConfig = {}
                for i = 1, #config.RewardDescription do
                    local item = config.RewardDescription[i]
                    for j = item.StartPlace, item.EndPlace do
                        local rewardTbl = {}
                        for k = 1, #item.Reward do
                            table.insert(rewardTbl, 
                            {
                                rewardType = item.Reward[k].RewardType,
                                rewardNum = item.Reward[k].RewardNum,
                            })
                        end
                        table.insert(self._rewardConfig, rewardTbl)
                    end
                end
            end
        end
        tbl = self._rewardConfig[index] or {}
    end
    return tbl
end

--return  rank, score, name, rewards
function TimingGameRankCtrl:getSelfRankInfo(record)
    local userID = user.nUserID
    for i = 1, #record[1] do
        if record[1][i].userid == userID then
            return i, record[1][i].maxScore, self:getSelfName(), self:getReward(i, record[1][i].rewardType,record[1][i].rewardNum)
        end
    end
    return -1
end

function TimingGameRankCtrl:getSelfName()
    local nickName = NickNameInterface.getNickName()
    local userName = nickName or user.szUtf8Username
    if self._name then
        userName = self._name
    end
    return userName
end

function TimingGameRankCtrl:getRewardDesc(count)
    return "x" .. tostring(count)
end

function TimingGameRankCtrl:initSelfRankItem(config, infoData, record)
    local viewNode = self._viewNode
    viewNode.selfRankIcon:setVisible(false)
    viewNode.selfTextRank:setVisible(false)
    viewNode.selfRewardIcon1:setVisible(false)
    viewNode.selfRewardIcon2:setVisible(false)
    viewNode.selfTextRewardNum1:setVisible(false)
    viewNode.selfTextRewardNum2:setVisible(false)
    viewNode.selfTextNoReward:setVisible(false)

    local rank, score, name, rewards = self:getSelfRankInfo(record)

    local color = cc.c3b(163,161,162)
    if rank ~= -1 then
        color = cc.c3b(200,144,45)
    end
    viewNode.selfTextUserName:setTextColor(color)
    viewNode.selfTextRank:setTextColor(color)
    viewNode.selfTextScore:setTextColor(color)
    viewNode.selfTextRewardNum1:setTextColor(color)
    viewNode.selfTextRewardNum2:setTextColor(color)
    viewNode.selfTextNoReward:setTextColor(color)

    -- viewNode.selfTextUserName:enableOutline(color, 1)
    viewNode.selfTextRank:enableOutline(color, 1)
    viewNode.selfTextScore:enableOutline(color, 1)
    viewNode.selfTextRewardNum1:enableOutline(color, 1)
    viewNode.selfTextRewardNum2:enableOutline(color, 1)
    viewNode.selfTextNoReward:enableOutline(color, 1)

    viewNode.selfRewardIcon1:ignoreContentAdaptWithSize(true)
    viewNode.selfRewardIcon2:ignoreContentAdaptWithSize(true)

    if rank == -1 then
        viewNode.selfTextRank:setVisible(true)
        viewNode.selfTextRank:setString("未上榜")
        my.fitStringInWidget(self:getSelfName(), viewNode.selfTextUserName, 192) 
        -- viewNode.selfTextUserName:setString(self:getSelfName())
        viewNode.selfTextScore:setString("----")
        viewNode.selfTextNoReward:setVisible(true)
        viewNode.selfTextNoReward:setString("----")
        return
    else
        if rank >= 1 and rank <= 3 then 
            local rankIconPath = string.format("hallcocosstudio/images/plist/TimingGame/img_jiangbei_%d.png", rank)
            viewNode.selfRankIcon:loadTexture(rankIconPath, ccui.TextureResType.plistType)
            viewNode.selfRankIcon:setVisible(true)
            viewNode.selfTextRank:setVisible(false)
        else
            viewNode.selfTextRank:setString(rank)
            viewNode.selfRankIcon:setVisible(false)
            viewNode.selfTextRank:setVisible(true)
        end
    
        my.fitStringInWidget(self:getSelfName(), viewNode.selfTextUserName, 192) 
        -- viewNode.selfTextUserName:setString(self:getSelfName())
        viewNode.selfTextScore:setString(score)
        local posY = viewNode.selfTextScore:getPositionY()
            
        local color = viewNode.selfTextNoReward:getTextColor()
        if #rewards == 0 then
            viewNode.selfTextNoReward:setString("无奖励")  
            viewNode.selfTextNoReward:enableOutline(color, 1) 
            viewNode.selfTextNoReward:setVisible(true)
        elseif #rewards == 1 then
            local tmpReward = {
                RewardType = rewards[1].rewardType,
                RewardNum = rewards[1].rewardNum,
            }

            local rewardPath, count = TimingGameModel:getRewardPathCount(tmpReward)
            viewNode.selfRewardIcon1:loadTexture(rewardPath, ccui.TextureResType.plistType)
            viewNode.selfRewardIcon1:setPosition(cc.p(521.63, posY))
            viewNode.selfRewardIcon1:setVisible(true)
            
            viewNode.selfTextRewardNum1:setString(self:getRewardDesc(count))
            viewNode.selfTextRewardNum1:setPosition(cc.p(605.12, posY))
            viewNode.selfTextRewardNum1:setVisible(true)
    
        elseif #rewards >= 2 then
            local tmpReward = {
                RewardType = rewards[1].rewardType,
                RewardNum = rewards[1].rewardNum,
            }
            local rewardPath, count = TimingGameModel:getRewardPathCount(tmpReward)
            viewNode.selfRewardIcon1:loadTexture(rewardPath, ccui.TextureResType.plistType)
            viewNode.selfRewardIcon1:setPosition(cc.p(465.64, posY))
            viewNode.selfRewardIcon1:setVisible(true)
    
            viewNode.selfTextRewardNum1:setString(self:getRewardDesc(count))
            viewNode.selfTextRewardNum1:setPosition(cc.p(536.12, posY))
            viewNode.selfTextRewardNum1:setVisible(true)

            tmpReward = {
                RewardType = rewards[2].rewardType,
                RewardNum = rewards[2].rewardNum,
            }
            rewardPath, count = TimingGameModel:getRewardPathCount(tmpReward)
            
            viewNode.selfRewardIcon2:loadTexture(rewardPath, ccui.TextureResType.plistType)
            viewNode.selfRewardIcon2:setPosition(cc.p(600.26, posY))
            viewNode.selfRewardIcon2:setVisible(true)
    
            viewNode.selfTextRewardNum2:setString(self:getRewardDesc(count))
            viewNode.selfTextRewardNum2:setPosition(cc.p(673.14, posY))
            viewNode.selfTextRewardNum2:setVisible(true)
        end
    end
end

function TimingGameRankCtrl:createRankItem(record, rank, score, name, rewards)
    local item = ccui.Layout:create()
    item:setAnchorPoint(cc.p(0.5, 1))

    local width = self._rankListConfig.itemWidth
    local height = self._rankListConfig.itemHeight
    item:setContentSize(cc.size(width, height))

    if record.userid == user.nUserID then
        item:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
        item:setBackGroundColor(cc.c3b(144,238,144))
        item:setBackGroundColorOpacity(0.4 * 255)
    else
        item:setBackGroundColorType(ccui.LayoutBackGroundColorType.none)
    end

    local fontPath = "res/common/font/mainfont.TTF"
    local color
    if rank >= 1 and rank <= 3 then 
        local rankIconPath = string.format("hallcocosstudio/images/plist/TimingGame/img_jiangbei_%d.png", rank)
        local rankIcon = cc.Sprite:createWithSpriteFrameName(rankIconPath)
        rankIcon:setPosition(cc.p(49.62, 29.86))
        rankIcon:setName("Img_RankIcon")
        item:addChild(rankIcon)

        color = self._rankItemFontColor[1]
    else
        color = self._rankItemFontColor[2]
        local rankLabel = cc.Label:createWithTTF(rank, fontPath, 24)
        rankLabel:setTextColor(color)
        rankLabel:enableOutline(color, 1)
        rankLabel:setPosition(cc.p(49.44, 30.86))
        rankLabel:setName("Text_Rank")
        item:addChild(rankLabel)
    end

    local strName = MCCharset:getInstance():gb2Utf8String(name, string.len(name))
    if record.userid == user.nUserID then
        strName = self:getSelfName()
    end
    local nameLabel = cc.Label:createWithTTF(strName, fontPath, 24)
    nameLabel:setTextColor(color)
    --nameLabel:enableOutline(color, 1)
    nameLabel:setPosition(cc.p(183.88, 30.86))
    nameLabel:setName("Text_UserName")
    item:addChild(nameLabel)

    local scoreLabel = cc.Label:createWithTTF(score, fontPath, 24)
    scoreLabel:setTextColor(color)
    scoreLabel:enableOutline(color, 1)
    scoreLabel:setPosition(cc.p(354.22, 30.86))
    scoreLabel:setName("Text_Score")
    item:addChild(scoreLabel)
        
    if #rewards == 0 then
        local rewardLabel = cc.Label:createWithTTF("无奖励", fontPath, 24)
        rewardLabel:setTextColor(color)
        rewardLabel:setPosition(cc.p(534.16, 30.86))
        rewardLabel:enableOutline(color, 1)
        rewardLabel:setName("Text_NoReward")
        item:addChild(rewardLabel)
    elseif #rewards == 1 then
        local tmpReward = {
            RewardType = rewards[1].rewardType,
            RewardNum = rewards[1].rewardNum,
        }

        local rewardPath, count = TimingGameModel:getRewardPathCount(tmpReward)
        local rewardIcon = cc.Sprite:createWithSpriteFrameName(rewardPath)
        rewardIcon:setPosition(cc.p(521.63, 30.86))
        rewardIcon:setName("Img_RewardIcon1")
        item:addChild(rewardIcon)

        local rewardLabel = cc.Label:createWithTTF(self:getRewardDesc(count), fontPath, 24)
        rewardLabel:setTextColor(color)
        rewardLabel:setPosition(cc.p(605.12, 30.86))
        rewardLabel:enableOutline(color, 1)
        rewardLabel:setName("Text_RewardNum1")
        item:addChild(rewardLabel)

    elseif #rewards >= 2 then
        local tmpReward = {
            RewardType = rewards[1].rewardType,
            RewardNum = rewards[1].rewardNum,
        }
        local rewardPath, count = TimingGameModel:getRewardPathCount(tmpReward)
        local rewardIcon = cc.Sprite:createWithSpriteFrameName(rewardPath)
        rewardIcon:setPosition(cc.p(465.64, 30.86))
        rewardIcon:setName("Img_RewardIcon1")
        item:addChild(rewardIcon)

        local rewardLabel = cc.Label:createWithTTF(self:getRewardDesc(count), fontPath, 24)
        rewardLabel:setTextColor(color)
        rewardLabel:setPosition(cc.p(536.12, 30.86))
        rewardLabel:enableOutline(color, 1)
        rewardLabel:setName("Text_RewardNum1")
        item:addChild(rewardLabel)

        tmpReward = {
            RewardType = rewards[2].rewardType,
            RewardNum = rewards[2].rewardNum,
        }
        rewardPath, count = TimingGameModel:getRewardPathCount(tmpReward)
        local rewardIcon = cc.Sprite:createWithSpriteFrameName(rewardPath)
        rewardIcon:setPosition(cc.p(600.26, 30.86))
        rewardIcon:setName("Img_RewardIcon2")
        item:addChild(rewardIcon)

        local rewardLabel = cc.Label:createWithTTF(self:getRewardDesc(count), fontPath, 24)
        rewardLabel:setTextColor(color)
        rewardLabel:setPosition(cc.p(673.14, 30.86))
        rewardLabel:enableOutline(color, 1)
        rewardLabel:setName("Text_RewardNum2")
        item:addChild(rewardLabel)
    end

    local linePath = string.format("hallcocosstudio/images/plist/TimingGame/img_xian.png")
    -- local imgLine = cc.Sprite:createWithSpriteFrameName(linePath)
    local imgLine = ccui.ImageView:create(linePath, ccui.TextureResType.plistType)  
    imgLine:ignoreContentAdaptWithSize(true)
    imgLine:setScale9Enabled(true)

    imgLine:setContentSize(cc.size(750, 3))
    imgLine:setPosition(cc.p(375.00, 1.00))
    item:addChild(imgLine)
    
    item:setTouchEnabled(true)
    
    return item
end

function TimingGameRankCtrl:refreshRankItem(record, item, rank, score, name, rewards)
    local fontPath = "res/common/font/mainfont.TTF"
    local color

    if record.userid == user.nUserID then
        item:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
        item:setBackGroundColor(cc.c3b(144,238,144))
        item:setBackGroundColorOpacity(0.4 * 255)
    else
        item:setBackGroundColorType(ccui.LayoutBackGroundColorType.none)
    end

    if rank >= 1 and rank <= 3 then 
        local rankIcon = item:getChildByName("Img_RankIcon")
        local rankIconPath = string.format("hallcocosstudio/images/plist/TimingGame/img_jiangbei_%d.png", rank)
        if not rankIcon then 
            rankIcon = cc.Sprite:createWithSpriteFrameName(rankIconPath)
            rankIcon:setName("Img_RankIcon")
            rankIcon:setPosition(cc.p(49.62, 29.86))
            item:addChild(rankIcon)
        else
            rankIcon:setSpriteFrame(rankIconPath)
        end
        color = self._rankItemFontColor[1]
    else
        color = self._rankItemFontColor[2]
        local rankLabel = item:getChildByName("Text_Rank")
        if not rankLabel then
            rankLabel = cc.Label:createWithTTF(rank, fontPath, 24)
            rankLabel:setTextColor(color)
            rankLabel:enableOutline(color, 1)
            rankLabel:setPosition(cc.p(49.44, 30.86))
            rankLabel:setName("Text_Rank")
            item:addChild(rankLabel)
        else
            rankLabel:setString(rank)
        end
    end

    local strName = MCCharset:getInstance():gb2Utf8String(name, string.len(name))
    if record.userid == user.nUserID then
        strName = self:getSelfName()
    end
    local nameLabel = item:getChildByName("Text_UserName")
    if not nameLabel then
        nameLabel = cc.Label:createWithTTF(strName, fontPath, 24)
        nameLabel:setTextColor(color)
        --nameLabel:enableOutline(color, 1)
        nameLabel:setPosition(cc.p(183.88, 30.86))
        nameLabel:setName("Text_UserName")
        item:addChild(nameLabel)
    else
        my.fitStringInWidget(strName, nameLabel, 192) 
        -- nameLabel:setString(strName)
    end

    local scoreLabel = item:getChildByName("Text_Score")
    if not scoreLabel then
        scoreLabel = cc.Label:createWithTTF(score, fontPath, 24)
        scoreLabel:setTextColor(color)
        scoreLabel:enableOutline(color, 1)
        scoreLabel:setPosition(cc.p(354.22, 30.86))
        scoreLabel:setName("Text_Score")
        item:addChild(scoreLabel)
    else
        scoreLabel:setString(score)
    end
        
    if #rewards == 0 then
        local rewardLabel = item:getChildByName("Text_NoReward")
        if not rewardLabel then
            rewardLabel = cc.Label:createWithTTF("无奖励", fontPath, 24)
            rewardLabel:setTextColor(color)
            rewardLabel:setPosition(cc.p(534.16, 30.86))
            rewardLabel:enableOutline(color, 1)
            rewardLabel:setName("Text_NoReward")
            item:addChild(rewardLabel)
        else
            rewardLabel:setString("无奖励")
            rewardLabel:setVisible(true)
        end
        local rewardIcon = item:getChildByName("Img_RewardIcon1")
        if rewardIcon then
            rewardIcon:setVisible(false)
        end
        local rewardLabel = item:getChildByName("Text_RewardNum1")
        if rewardLabel then
            rewardLabel:setVisible(false)
        end
        rewardIcon = item:getChildByName("Img_RewardIcon2")
        if rewardIcon then
            rewardIcon:setVisible(false)
        end
        rewardLabel = item:getChildByName("Text_RewardNum2")
        if rewardLabel then
            rewardLabel:setVisible(false)
        end
    elseif #rewards == 1 then
        local tmpReward = {
            RewardType = rewards[1].rewardType,
            RewardNum = rewards[1].rewardNum,
        }

        local rewardPath, count = TimingGameModel:getRewardPathCount(tmpReward)
        local rewardIcon = item:getChildByName("Img_RewardIcon1")
        if not rewardIcon then
            rewardIcon = cc.Sprite:createWithSpriteFrameName(rewardPath)
            rewardIcon:setPosition(cc.p(521.63, 30.86))
            rewardIcon:setName("Img_RewardIcon1")
            item:addChild(rewardIcon)
        else
            rewardIcon:setPosition(cc.p(521.63, 30.86))
            rewardIcon:setSpriteFrame(rewardPath)
            rewardIcon:setVisible(true)
        end

        local rewardLabel = item:getChildByName("Text_RewardNum1")
        if not rewardLabel then
            rewardLabel = cc.Label:createWithTTF(self:getRewardDesc(count), fontPath, 24)
            rewardLabel:setTextColor(color)
            rewardLabel:setPosition(cc.p(605.12, 30.86))
            rewardLabel:enableOutline(color, 1)
            rewardLabel:setName("Text_RewardNum1")
            item:addChild(rewardLabel)
        else
            rewardLabel:setPosition(cc.p(605.12, 30.86))
            rewardLabel:setString(self:getRewardDesc(count))
            rewardLabel:setVisible(true)
        end
        local rewardIcon = item:getChildByName("Img_RewardIcon2")
        if rewardIcon then
            rewardIcon:setVisible(false)
        end
        local rewardLabel = item:getChildByName("Text_RewardNum2")
        if rewardLabel then
            rewardLabel:setVisible(false)
        end
        rewardLabel = item:getChildByName("Text_NoReward")
        if rewardLabel then
            rewardLabel:setVisible(false)
        end
    elseif #rewards >= 2 then
        local tmpReward = {
            RewardType = rewards[1].rewardType,
            RewardNum = rewards[1].rewardNum,
        }
        local rewardPath, count = TimingGameModel:getRewardPathCount(tmpReward)
        local rewardIcon = item:getChildByName("Img_RewardIcon1")
        if not rewardIcon then
            rewardIcon = cc.Sprite:createWithSpriteFrameName(rewardPath)
            rewardIcon:setPosition(cc.p(465.64, 30.86))
            rewardIcon:setName("Img_RewardIcon1")
            item:addChild(rewardIcon)
        else
            rewardIcon:setPosition(cc.p(465.64, 30.86))
            rewardIcon:setSpriteFrame(rewardPath)
            rewardIcon:setVisible(true)
        end

        local rewardLabel = item:getChildByName("Text_RewardNum1")
        if not rewardLabel then
            rewardLabel = cc.Label:createWithTTF(self:getRewardDesc(count), fontPath, 24)
            rewardLabel:setTextColor(color)
            rewardLabel:setPosition(cc.p(536.12, 30.86))
            rewardLabel:enableOutline(color, 1)
            rewardLabel:setName("Text_RewardNum1")
            item:addChild(rewardLabel)
        else
            rewardLabel:setPosition(cc.p(536.12, 30.86))
            rewardLabel:setString(self:getRewardDesc(count))
            rewardLabel:setVisible(true)
        end

        tmpReward = {
            RewardType = rewards[2].rewardType,
            RewardNum = rewards[2].rewardNum,
        }
        rewardPath, count = TimingGameModel:getRewardPathCount(tmpReward)
        local rewardIcon = item:getChildByName("Img_RewardIcon2")
        if not rewardIcon then
            rewardIcon = cc.Sprite:createWithSpriteFrameName(rewardPath)
            rewardIcon:setPosition(cc.p(600.26, 30.86))
            rewardIcon:setName("Img_RewardIcon2")
            item:addChild(rewardIcon)
        else
            rewardIcon:setSpriteFrame(rewardPath)
            rewardIcon:setVisible(true)
        end

        local rewardLabel = item:getChildByName("Text_RewardNum2")
        if not rewardLabel then
            rewardLabel = cc.Label:createWithTTF(self:getRewardDesc(count), fontPath, 24)
            rewardLabel:setTextColor(color)
            rewardLabel:setPosition(cc.p(673.14, 30.86))
            rewardLabel:enableOutline(color, 1)
            rewardLabel:setName("Text_RewardNum2")
            item:addChild(rewardLabel)
        else
            rewardLabel:setString(self:getRewardDesc(count))
            rewardLabel:setVisible(true)
        end
        local rewardLabel = item:getChildByName("Text_NoReward")
        if rewardLabel then
            rewardLabel:setVisible(false)
        end
    end

    -- local linePath = string.format("hallcocosstudio/images/plist/TimingGame/img_xian.png")
    -- local imgLine = ccui.ImageView:create(linePath, ccui.TextureResType.plistType)  
    -- imgLine:setContentSize(cc.size(750, 3))
    -- local imgLine = cc.Sprite:createWithSpriteFrameName(linePath)
    -- imgLine:setPosition(cc.p(337.00, 1.00))
    -- item:addChild(imgLine)
    
    item:setTouchEnabled(true)
    
    return item
end

function TimingGameRankCtrl:initRankListView(config, infoData, record)
    local viewNode = self._viewNode
    if self._currentItemCount == 0 then
        local initCount = math.min(self._rankListConfig.visibleItemCount, self._maxItemCount)
        self._notCreating = true
        for i = 1, initCount do
            local rank, score, name = i, record[1][i].maxScore, record[1][i].userNmae
            local rewards = self:getReward(i, record[1][i].rewardType,record[1][i].rewardNum)
            local item = self:createRankItem(record[1][i], rank, score, name, rewards)
            viewNode.listRankView:pushBackCustomItem(item)
            
            self._currentItemCount = self._currentItemCount + 1
        end
        self._notCreating = false
    end
end

function TimingGameRankCtrl:onRankListScrolled(percent, event)
    if self._initing then return end
    local viewNode = self._viewNode
    local index = viewNode.listRankView:getCurSelectedIndex()
    if self._currentItemCount == 0 then
        self:initRankListView()
    else
        if event and event.name and event.name ~= "SCROLL_TO_BOTTOM" then
            return
        end
        if self._curTabStartTime and self._currentItemCount < self._maxItemCount and not self._notCreating then
            self._notCreating = true

            local records = TimingGameModel:getSeasonRecord() or {} 
            local record = records[self._curTabStartTime]
            if index > self._currentItemCount - 10 and record then
                print("create new item in listview")
                local addCount = math.min(self._rankListConfig.addItemCount, self._maxItemCount - self._currentItemCount)
                for i = 1, addCount do
                    local index = self._currentItemCount + 1
                    local rank, score, name = index, record[1][index].maxScore, record[1][index].userNmae
                    local rewards = self:getReward(rank, record[1][index].rewardType,record[1][index].rewardNum)

                    local item = self:createRankItem(record[1][index], rank, score, name, rewards)
                    viewNode.listRankView:pushBackCustomItem(item)
                    
                    self._currentItemCount = self._currentItemCount + 1
                end
            end
            self._notCreating = false
            return 
        end

        if self._refreshCount < self._maxItemCount and not self._notRefreshing then
            self._notRefreshing = true
            local records = TimingGameModel:getSeasonRecord() or {} 
            local record = records[self._curTabStartTime]
            if index > self._refreshCount - 10 and record then
                print("refresh item in listview")
                local refreshCount = math.min(self._rankListConfig.refreshItemCount, self._maxItemCount - self._refreshCount)
                for i = 1, refreshCount do
                    local index = self._refreshCount + 1
                    local rank, score, name = index, record[1][index].maxScore, record[1][index].userNmae
                    local rewards = self:getReward(rank, record[1][index].rewardType,record[1][index].rewardNum)

                    --getItem下标从0开始
                    local item = viewNode.listRankView:getItem(self._refreshCount)
                    self:refreshRankItem(record[1][index], item, rank, score, name, rewards)
                    
                    self._refreshCount = self._refreshCount + 1
                end
            end
            self._notRefreshing = false
            return 
        end
    end
end

function TimingGameRankCtrl:goBack()
    TimingGameRankCtrl.super.removeSelf(self)
end

return TimingGameRankCtrl