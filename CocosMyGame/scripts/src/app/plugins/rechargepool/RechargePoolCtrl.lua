local RechargePoolCtrl      = class('RechargePoolCtrl', cc.load('BaseCtrl'))
local viewCreater           = import('src.app.plugins.rechargepool.RechargePoolView')
local RechargePoolUnitView  = import('src.app.plugins.rechargepool.RechargePoolUnitView')
local RechargePoolModel     = import('src.app.plugins.rechargepool.RechargePoolModel'):getInstance()
local UserModel             = mymodel('UserModel'):getInstance()
local ScrollNumberNode = require("src/app/plugins/rechargepool/ScrollNumberNode")

RechargePoolCtrl.LOGUI = 'RechargePool'
RechargePoolCtrl.RUN_ENTERACTION = true

local RANKLIST_PREITEM  = 3     -- 滚动列表顶部/底部预留几个用于滑动的

-- 3个tab页
local Tab = {
    Reward = 1,     -- 每日奖励
    TodayRank = 2,  -- 今日排行
    LastRank = 3,   -- 昨日排行
}

local rechargePoolPlist = "res/hallcocosstudio/images/plist/rechargepool.plist"

function RechargePoolCtrl:onCreate() 
    cc.SpriteFrameCache:getInstance():addSpriteFrames(rechargePoolPlist)

    local viewNode = self:setViewIndexer(viewCreater:createViewIndexer())

    self._rankItemPool = {}
    self._rankItemShow = {}
    self._ignoreScrollEvent = true
    self._leftSecond = 0
    self._secondTimer = nil

    self:bindUserEventHandler(viewNode,{"btnClose", "btnShop", "btnRule", "btnToday", "btnLast", "btnDayReward"})
    viewNode.panelRule:addClickEventListener(handler(self, self.switchRuleShow))
    if viewNode.scrollRank then
        viewNode.scrollRank:addEventListener(handler(self, self.onScrollRankUpdate))
    end

    --event
    self:listenTo(RechargePoolModel, RechargePoolModel.EVENT_UPDATE_DATA, handler(self, self.updateView))
    self:listenTo(RechargePoolModel, RechargePoolModel.EVENT_UPDATE_RANK, handler(self, self.updateRankList))
end

function RechargePoolCtrl:onEnter()
    RechargePoolCtrl.super.onEnter(self)
    RechargePoolModel:setVisible(true)
    self:updateView({name = RechargePoolModel.EVENT_UPDATE_DATA, value = 'onenter'})
    self:_addResumeCallback()
end

function RechargePoolCtrl:onExit()
    RechargePoolCtrl.super.onExit(self)

    RechargePoolModel:setVisible(false)
    RechargePoolModel:clearAfterReward()

    self:removeEventHosts()
    -- 释放所有rankItem
    for _,item in pairs(self._rankItemPool) do
        item:getRealNode():release()
    end
    -- 停止计时器
    if self._secondTimer then
        cc.exports.removeSchedule(self._secondTimer)
        self._secondTimer = nil
    end
    
    --
    cc.SpriteFrameCache:getInstance():removeSpriteFramesFromFile(rechargePoolPlist)
    --
    self:_removeResumeCallback()
end

function RechargePoolCtrl:onEnterActionFinished()
    RechargePoolCtrl.super.onEnterActionFinished(self)

    if self._viewNode then
        self._viewNode:runTimelineAction("animation0", true)
    end

    local waitToReq = self._waitToReq
    self._waitToReq = ""
    if waitToReq == "activity_info" then
        RechargePoolModel:reqRechargeActivityInfo() -- 请求最新数据,主要为了倒计时
    end
end

function RechargePoolCtrl:_addResumeCallback()
    local appUtils = AppUtils:getInstance()
    appUtils:addResumeCallback(handler(self, self._onResumeApp), "RechargePool_OnResume")
end

function RechargePoolCtrl:_removeResumeCallback()
    local appUtils = AppUtils:getInstance()
    appUtils:removeResumeCallback("RechargePool_OnResume")
end

function RechargePoolCtrl:_onResumeApp()
    RechargePoolModel:onResumeApp()
end

function RechargePoolCtrl:onKeyBack()
    RechargePoolCtrl.super.onKeyBack(self)
    --
    local PluginProcessModel = mymodel("hallext.PluginProcessModel"):getInstance()
    PluginProcessModel:stopPluginProcess()
end

function RechargePoolCtrl:btnCloseClicked()
    -- my.playClickBtnSound()
    self:removeSelfInstance()
    --
    local PluginProcessModel = mymodel("hallext.PluginProcessModel"):getInstance()
    PluginProcessModel:PopNextPlugin()
end

function RechargePoolCtrl:btnRuleClicked()
    my.playClickBtnSound()
    self:switchRuleShow()
end

function RechargePoolCtrl:btnDayRewardClicked()
    my.playClickBtnSound()
    self._tabChoose = Tab.Reward
    self:updateTabBtns()
    if self._viewNode and self._viewNode.panelRank then
        self._viewNode.panelRank:setVisible(false)
    end
end

function RechargePoolCtrl:btnTodayClicked()
    my.playClickBtnSound()

    self._tabChoose = Tab.TodayRank
    self:updateTabBtns()
    if self._viewNode and self._viewNode.panelRank then
        self._viewNode.panelRank:setVisible(true)
    end

    -- 请求排行榜
    if not RechargePoolModel:isInClearDay() then
        RechargePoolModel:reqRechargeRankInfo(RechargePoolModel:getTodayDate())
    else
        self:updateRankList()
    end
end

function RechargePoolCtrl:btnLastClicked()
    my.playClickBtnSound()

    self._tabChoose = Tab.LastRank
    self:updateTabBtns()
    if self._viewNode and self._viewNode.panelRank then
        self._viewNode.panelRank:setVisible(true)
    end

    -- 请求排行榜
    if (not RechargePoolModel:isInClearDay()) or RechargePoolModel:isOpenDayNextDay() then
        RechargePoolModel:reqRechargeRankInfo(RechargePoolModel:getLastDate())
    else
        self:updateRankList()
    end
end

function RechargePoolCtrl:updateTabBtns()
    local viewNode = self._viewNode
    if not viewNode then return end

    if viewNode.btnDayReward then
        viewNode.btnDayReward:setTouchEnabled(self._tabChoose ~= Tab.Reward)
        viewNode.btnDayReward:setBright(self._tabChoose ~= Tab.Reward)
    end
    if viewNode.btnToday then
        viewNode.btnToday:setTouchEnabled(self._tabChoose ~= Tab.TodayRank)
        viewNode.btnToday:setBright(self._tabChoose ~= Tab.TodayRank)
    end
    if viewNode.btnLast then
        viewNode.btnLast:setTouchEnabled(self._tabChoose ~= Tab.LastRank)
        viewNode.btnLast:setBright(self._tabChoose ~= Tab.LastRank)
    end
    if viewNode.textTips then
        if self._tabChoose == Tab.Reward then
            viewNode.textTips:setString("排名越靠前，瓜分奖励越多哦~")
        else
            local seconds = cc.exports.getRechargePoolRankUpdateInverval() or 300
            local str = string.format( "排行榜信息，每%d分钟刷新一次", math.floor(seconds / 60))
            viewNode.textTips:setString(str)
        end
    end
end

-- 设置规则面板显隐
function RechargePoolCtrl:switchRuleShow()
    self._viewNode.panelRule:setVisible(not self._viewNode.panelRule:isVisible())
end

function RechargePoolCtrl:btnShopClicked()
    my.playClickBtnSound()
    my.informPluginByName({pluginName = "ShopCtrl"})
    self:removeSelfInstance()
end

function RechargePoolCtrl:updateView(event)
    if not RechargePoolModel:isShowEntry() then
        self:btnCloseClicked()
        return
    end
    if RechargePoolModel:isHasAward() then
        self._tabChoose = Tab.Reward
    else
        if not RechargePoolModel:isInClearDay() then
            if RechargePoolModel:isAfterReward() then -- 如果是领取奖励返回后
                self._tabChoose = Tab.Reward
            else
                self._tabChoose = Tab.TodayRank
            end
        else
            self._tabChoose = Tab.Reward
        end
    end 
    RechargePoolModel:clearAfterReward()
    self:updateTabBtns()
    self:showStaticInfo()
    self:updateActivityInfo1()
    if event and event.value == "onenter" then
        self:updateActivityInfo2(false)
    else
        self:updateActivityInfo2(true)
    end
    if self._tabChoose == Tab.Reward then   
        if self._viewNode and self._viewNode.panelRank then
            self._viewNode.panelRank:setVisible(false)
        end
    else
        if self._viewNode and self._viewNode.panelRank then
            self._viewNode.panelRank:setVisible(true)
            self:updateRankList()
        end
        --
        if event and event.value == "onenter" then
            self._waitToReq = "activity_info"
        else -- 请求排名
            self._waitToReq = ""
            RechargePoolModel:reqRechargeRankInfo(RechargePoolModel:getTodayDate())
        end
    end

    local promoteNumTip = cc.exports.getRechargePoolPromoteNumTip()
    if promoteNumTip then
        self._viewNode.textNum:setString(tostring(promoteNumTip))
    end
end

-- 刷新数据
function RechargePoolCtrl:showStaticInfo()
    local view = self._viewNode
    if not view then return end

    local activityInfo = RechargePoolModel:getActivityInfo()
    local stConfig = activityInfo and activityInfo.config or {}
    -- 活动名称
    if view.textPoolName and stConfig.name then
        view.textPoolName:setString(stConfig.name)
    end
    -- 规则说明
    if view.textRule and stConfig.ruledes then
        view.textRule:setString(stConfig.ruledes)
    end
    -- 活动日期
    if view.textDateRange and stConfig.startday then
        local startDate = stConfig.startday
        local cur = os.time({year=math.floor(startDate/10000),month=math.floor(startDate%10000/100),day=startDate%100})
        local nextt = cur + (stConfig.openday - 1)  * 24 * 60 * 60
        local y = tonumber(os.date("%Y", nextt))
        local m = tonumber(os.date("%m", nextt))
        local d = tonumber(os.date("%d", nextt))
        local strStartDate = string.format("%d年%d月%d日", math.floor(startDate/10000), math.floor(startDate%10000/100), startDate%100)
        local strEndDate = string.format("%d年%d月%d日", y, m, d)
        view.textDateRange:setString(string.format("活动时间：%s-%s", strStartDate, strEndDate))
    end
end

-- 设置每日领奖
function RechargePoolCtrl:setDayRewardList()
    local view = self._viewNode
    if not view or not view.scrollDayList then return end
    local activityInfo = RechargePoolModel:getActivityInfo()
    if not activityInfo then return end

    local openday = activityInfo.config and activityInfo.config.openday
    if not openday then return end

    local sz = view.scrollDayList:getContentSize()
    view.scrollDayList:removeAllChildren()
    view.scrollDayList:setClippingEnabled(true)
    view.scrollDayList:setBounceEnabled(true)
    view.scrollDayList:setTouchEnabled(true)

    local currentDate = activityInfo.config.startday + activityInfo.today - 1
    local startDate = activityInfo.config.startday
    local count = 0
    local height = 0

    local startY = nil
    for i = 1, openday do
        -- 构造每日信息
        local dayInfo = {}
        dayInfo.date = startDate + i - 1
        dayInfo.index = i   -- 第几天
        dayInfo.btnState = false    -- 是否可领奖
        dayInfo.reward = 0
        dayInfo.nTodaySpan = -1     -- -1前日，0今日，1后日
        if dayInfo.date < currentDate then
            dayInfo.nTodaySpan = -1
            local playerInfo = RechargePoolModel:getPlayerInfo(i)
            if playerInfo then
                -- 说明玩家根本没有上榜
                dayInfo.reward = playerInfo.nReward
                if dayInfo.reward and dayInfo.reward > 0 then
                    dayInfo.btnState = not playerInfo.bAward
                else
                    dayInfo.btnState = false
                end
            end
        elseif dayInfo.date == currentDate then
            dayInfo.nTodaySpan = 0
        else
            dayInfo.nTodaySpan = 1
        end
        -- 创建节点
        local node = cc.CSLoader:createNode(RechargePoolUnitView.DayUnitCsbPath)
        if not node then break end
        local itemView = my.NodeIndexer(node, RechargePoolUnitView.DayUnitViewConfig)
        if not itemView then break end
        self:setDayItemInfo(itemView, dayInfo)
        height = itemView.panelMain:getContentSize().height

        if not startY then
            startY = math.max(openday, 5) * height - height/2 - 35
        end

        node:setPosition(cc.p(0, startY - (i-1)*height))
        view.scrollDayList:addChild(node)
        count = count + 1
    end

    view.scrollDayList:setInnerContainerSize(cc.size(view.scrollDayList:getInnerContainerSize().width, height * count))
    view.scrollDayList:setContentSize(cc.size(sz.width, 5 * height))
end

-- 设置单日奖励数据
function RechargePoolCtrl:setDayItemInfo(view, itemInfo)
    if not view or not itemInfo then return end
    -- 第几天
    if view.textDay and itemInfo.index then
        view.textDay:setString(string.format("第%d天", itemInfo.index))
    end
    -- 奖励
    if view.textValue and itemInfo.reward then
        view.textValue:setVisible(itemInfo.reward > 0)
        view.textValue:setString(string.format("%d两", itemInfo.reward))
    end
    -- 未获奖
    if view.imgStateNoReward then
        view.imgStateNoReward:setVisible(itemInfo.reward <= 0 and itemInfo.nTodaySpan < 0)
    end
    -- 进行中
    if view.imgStateNow then
        view.imgStateNow:setVisible(itemInfo.nTodaySpan == 0)
    end
    -- 未开放
    if view.imgStateFuture then
        view.imgStateFuture:setVisible(itemInfo.nTodaySpan > 0)
    end
    -- 领奖按钮
    if view.btnTake then
        view.btnTake:setVisible(itemInfo.nTodaySpan < 0)
        view.btnTake:setBright(itemInfo.btnState or false)
        view.btnTake:setTouchEnabled(itemInfo.btnState or false)
        view.btnTake:addClickEventListener(function()
            my.playClickBtnSound()
            if not cc.exports.checkBtnClickable() then
                print("[INFO] rechargepool, get reward, click too fast...")
                return
            end

            -- 按钮先置灰
            view.btnTake:setBright(false)
            view.btnTake:setTouchEnabled(false)
            -- 发送请求
            RechargePoolModel:reqTakeAward(itemInfo.index)
        end)
    end
    -- 商城按钮
    if view.btnShop then
        view.btnShop:setVisible(itemInfo.nTodaySpan == 0)
        view.btnShop:addClickEventListener(handler(self,self.btnShopClicked))
    end
    -- 敬请期待
    if view.imgLocked then
        view.imgLocked:setVisible(itemInfo.nTodaySpan > 0)
    end
end

-- 刷新奖池数据
function RechargePoolCtrl:updateActivityInfo1()
    local view = self._viewNode
    if not view then return end

    local activityInfo = RechargePoolModel:getActivityInfo()
    if not activityInfo then return end

    -- 每日奖励
    self:setDayRewardList()
    -- 今日倒计时
    if RechargePoolModel:isInClearDay() then
        if self._viewNode.textLeftTime then
            self._viewNode.textLeftTime:setString(string.format("本日奖池瓜分倒计时：%02d：%02d：%02d", 0, 0, 0))
        end
        self._viewNode.btnShop:setTouchEnabled(false)
        self._viewNode.btnShop:setBright(false)
        return
    end

    self._viewNode.btnShop:setTouchEnabled(true)
    self._viewNode.btnShop:setBright(true)

    self._leftSecond = RechargePoolModel:getTodayLeftTime()
    if self._secondTimer then
        cc.exports.removeSchedule(self._secondTimer)
        self._secondTimer = nil
    end
    if self._leftSecond > 0 then
        self._secondTimer = cc.exports.createSchedule(function()
            self._leftSecond = self._leftSecond - 1
            self:stepClock()
        end, 1.0)
    end

    self:stepClock()
end

function RechargePoolCtrl:updateActivityInfo2(useClippinpNode)
    local view = self._viewNode
    if not view then return end

    local activityInfo = RechargePoolModel:getActivityInfo()
    if not activityInfo then return end

    -- 今日奖池
    if view.panelPoolValue and activityInfo.poolprize then
        local idx = 9
        local num = activityInfo.poolprize
        while idx > 0 do
            local textNum = view.panelPoolValue:getChildByName("Font_"..idx)
            if textNum then
                local nodeName = "_SCROLL_NUM_NODE"
                local node = textNum:getChildByName(nodeName)
                local value = num % 10
                if not node then
                    node = ScrollNumberNode:create(value)
                    node:setName(nodeName)
                    textNum:addChild(node)
                else
                    node:gotoNumber(value, 1)
                end 
                if useClippinpNode then
                    textNum:setString("")
                    node:setVisible(true)
                else
                    textNum:setString(tostring(num % 10))
                    node:setVisible(false)
                end
            end
            num = math.floor(num / 10)
            idx = idx - 1
        end
    end    
end

-- 今日倒计时
function RechargePoolCtrl:stepClock()
    if not self._viewNode then return end

    if self._leftSecond < 0 then
        self._leftSecond = 0
        if self._secondTimer then
            cc.exports.removeSchedule(self._secondTimer)
            self._secondTimer = nil
        end

        -- 今天归零了，请求新一天的数据 稍微延迟一点
        if RechargePoolModel:isRankOpen() then
            cc.exports.createOnceSchedule(function()
                -- 切回奖励页
                self._tabChoose = Tab.Reward
                self:updateTabBtns()
                if self._viewNode and self._viewNode.panelRank then
                    self._viewNode.panelRank:setVisible(false)
                end
                -- 请求活动数据
                RechargePoolModel:reqRechargeActivityInfo()
            end, 1.0)
        end
    end

    local hour = math.floor(self._leftSecond / 3600)
    local minute = math.floor(self._leftSecond % 3600 / 60)
    local second = self._leftSecond % 60
    if self._viewNode.textLeftTime then
        self._viewNode.textLeftTime:setString(string.format("本日奖池瓜分倒计时：%02d：%02d：%02d", hour, minute, second))
    end
end

-- 刷新排行榜
function RechargePoolCtrl:updateRankList()
    local view = self._viewNode
    if not view then return end

    local date = RechargePoolModel:getTodayDate()
    if self._tabChoose == Tab.LastRank then
        date = RechargePoolModel:getLastDate()
    end

    -- 我的信息
    local myRankInfo = RechargePoolModel:getMyRankInfo(date)
    if myRankInfo then
        -- 排名
        if view.textMyRank and myRankInfo.nRank and view.imgMyNoRank then
            if not myRankInfo.nRank or myRankInfo.nRank < 0 then
                view.textMyRank:setVisible(false)
                view.imgMyNoRank:setVisible(true)
            else
                view.textMyRank:setVisible(true)
                view.imgMyNoRank:setVisible(false)
                view.textMyRank:setString(tostring(myRankInfo.nRank))
            end
        end
        -- 昵称
        if view.textMyName then
            my.fitStringInWidget(NickNameInterface.getNickName(), view.textMyName, 180)
        end
        -- 充值金额
        if view.textMyValue and myRankInfo.nValue then
            view.textMyValue:setString(myRankInfo.nValue)
        end
        -- 奖励
        if view.textMyReward and myRankInfo.nReward then
            view.textMyReward:setString(myRankInfo.nReward)
        end
    end

    -- 排行榜 实际只显示可见的部分元素，滑动时动态添加
    local rankListInfo = RechargePoolModel:getRankList(date)
    if view.scrollRank and rankListInfo then
        self._ignoreScrollEvent = true
        view.scrollRank:removeAllChildren()
        for _,item in pairs(self._rankItemShow) do
            self:putRankItem(item)
        end
        self._rankItemShow = {}
        self._rankListInfo = rankListInfo
        
        if not self._scrollContentHeight then
            self._scrollContentHeight = view.scrollRank:getContentSize().height
        end
        local tempItem = self:getRankItem()
        local height = tempItem.panelMain:getContentSize().height
        self:putRankItem(tempItem)
        local maxShowCount = math.min(math.ceil(self._scrollContentHeight / height) + RANKLIST_PREITEM * 2, #rankListInfo)   -- 前后各预留几条
        local i = 1
        local innerHeight = height * #rankListInfo
        if innerHeight < self._scrollContentHeight then -- 元素太少
            innerHeight = self._scrollContentHeight
        end
        while i <= maxShowCount do
            local itemView = self:getRankItem()
            if not itemView then break end
            self:setRankItemInfo(itemView, rankListInfo[i])
            local node = itemView:getRealNode()
            node:setTag(i)
            view.scrollRank:addChild(node)
            node:setPosition(cc.p(0, innerHeight - height * i))
            table.insert(self._rankItemShow, itemView)
            i = i + 1
        end

        view.scrollRank:setInnerContainerSize(cc.size(view.scrollRank:getInnerContainerSize().width, innerHeight))
        view.scrollRank:jumpToTop()
        self._totalRankCount = #rankListInfo
        self._itemHeight = height
        self._lastPosY = view.scrollRank:getInnerContainer():getPositionY()
        self._scrollTopY = self._lastPosY
        if self._totalRankCount > 0 then
            self._ignoreScrollEvent = false
        end
    end
end

-- 设置一条排行数据
function RechargePoolCtrl:setRankItemInfo(view, itemInfo)
    if not view or not itemInfo then return end
    view:getRealNode():setName(itemInfo.nRank)
    -- 排名
    if view.textRank and itemInfo.nRank then
        if itemInfo.nRank == 1 then
            view.textRank:setString("一")
        elseif itemInfo.nRank == 2 then
            view.textRank:setString("二")
        elseif itemInfo.nRank == 3 then
            view.textRank:setString("三")
        else
            view.textRank:setString(itemInfo.nRank)
        end
    end
    -- 昵称
    if view.textUser and itemInfo.szUserName then
        local utf8Name = itemInfo.szUserName -- MCCharset:getInstance():gb2Utf8String(itemInfo.szUserName,itemInfo.szUserName:len())
        my.fitStringInWidget(utf8Name, view.textUser, 180)
    end
    -- 充值金额
    if view.textValue and itemInfo.nValue then
        view.textValue:setString(itemInfo.nValue)
    end
    -- 奖励
    if view.textReward and itemInfo.nReward then
        view.textReward:setString(itemInfo.nReward)
    end
    -- 自己高亮
    if view.imgHightLight then
        view.imgHightLight:setVisible(itemInfo.nUserID == UserModel.nUserID)
    end
end

-- 滚动列表动态添加元素
function RechargePoolCtrl:onScrollRankUpdate(sender, state)
    if self._ignoreScrollEvent then return end

    local scrollView = self._viewNode.scrollRank
    local posY = scrollView:getInnerContainer():getPositionY()
    if posY == self._lastPosY or not next(self._rankItemShow) then return end

    if posY > self._lastPosY then
        -- 计算最顶部可见元素
        local idx = math.ceil((posY - self._scrollTopY) / self._itemHeight)
        local topIdx = self._rankItemShow[1]:getTag()
        local count = 0
        while idx - RANKLIST_PREITEM > topIdx do   -- 顶部预留3个元素
            local itemView = table.remove(self._rankItemShow, 1)
            self:putRankItem(itemView)
            scrollView:removeChild(itemView:getRealNode())
            count = count + 1
            topIdx = topIdx + 1
        end
        local bottomIdx = self._rankItemShow[#self._rankItemShow]:getTag()
        for i = 1, count do   -- 移除的item插入底部
            local itemView = self:getRankItem()
            itemView:setTag(bottomIdx + i)
            self:setRankItemInfo(itemView, self._rankListInfo[bottomIdx+i])
            local node = itemView:getRealNode()
            node:setPosition(cc.p(0, self._itemHeight * (self._totalRankCount - bottomIdx - i)))
            scrollView:addChild(node)
            table.insert(self._rankItemShow, itemView)
        end
    else
        -- 计算最底部可见元素
        local idx = math.ceil((posY + scrollView:getContentSize().height - self._scrollTopY) / self._itemHeight)
        local bottomIdx = self._rankItemShow[#self._rankItemShow]:getTag()
        local count = 0
        while idx + RANKLIST_PREITEM < bottomIdx do   -- 底部预留3个元素
            local itemView = table.remove(self._rankItemShow)
            self:putRankItem(itemView)
            scrollView:removeChild(itemView:getRealNode())
            count = count + 1
            bottomIdx = bottomIdx - 1
        end
        local topIdx = self._rankItemShow[1]:getTag()
        for i = 1, count do   -- 移除的item插入顶部
            local itemView = self:getRankItem()
            itemView:setTag(topIdx - i)
            self:setRankItemInfo(itemView, self._rankListInfo[topIdx - i])
            local node = itemView:getRealNode()
            node:setPosition(cc.p(0, self._itemHeight * (self._totalRankCount - topIdx + i)))
            scrollView:addChild(node)
            table.insert(self._rankItemShow, 1, itemView)
        end
    end

    self._lastPosY = posY

    return
end

-- 获得一个排行item
function RechargePoolCtrl:getRankItem()
    -- 从item池中取出一个
    if next(self._rankItemPool) then
        return table.remove(self._rankItemPool)
    end

    -- item池空了，创建新元素
    local node = cc.CSLoader:createNode(RechargePoolUnitView.RankUnitCsbPath)
    if not node then return end
    local itemView = my.NodeIndexer(node, RechargePoolUnitView.RankUnitViewConfig)
    if not itemView then return end

    node:retain()

    return itemView
end

-- 放回item
function RechargePoolCtrl:putRankItem(view)
    table.insert(self._rankItemPool, view)
end

return RechargePoolCtrl
