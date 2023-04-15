local NationalDayActivityCtrl=class('NationalDayActivityCtrl',cc.load('BaseCtrl'))
local viewCreater=import('src.app.plugins.NationalDayActivity.NationalDayActivityView')
--local AssistConnect = require('src.app.plugins.AssistModel.AssistConnect'):getInstance()
local NationalDayActivityModel = import("src.app.plugins.NationalDayActivity.NationalDayActivityModel"):getInstance()
local PublicInterface = cc.exports.PUBLIC_INTERFACE
local UserModel = mymodel('UserModel'):getInstance()  

local MainTabEventMap = {
        TabButtons   = {
            [1]      = {defaultShow = true, checkBtn = "BtnTotal"},
            [2]      = {checkBtn = "BtnToday"},
            [3]      = {checkBtn = "BtnYesterday"},
        }
    }
--local listener

function NationalDayActivityCtrl:onCreate(...)
	local viewNode=self:setViewIndexer(viewCreater:createViewIndexer())
    self:init()
end

function NationalDayActivityCtrl:init()
    local viewNode = self._viewNode
    self.listViewTab = {}
    self.rankType = 0
    
	--self:bindDestroyButton(viewNode.closeBt)
    --[[viewNode.closeBt:onTouch(function(e)
                if(e.name=='began')then
                    e.target:setScale(cc.exports.GetButtonScale(e.target))
                elseif(e.name=='ended')then
                    e.target:setScale(1.0)
                    self:onColseSelf()
                elseif(e.name=='cancelled')then
                    e.target:setScale(1.0)
                elseif(e.name=='moved')then

                end
            end)]]--
    viewNode.closeBt:addClickEventListener(function()
        my.playClickBtnSound() 
        self:onColseSelf() 
    end)

    --listener = cc.EventListenerKeyboard:create()
    --listener:registerScriptHandler(handler(NationalDayActivityCtrl,NationalDayActivityCtrl.onKeyboardReleased), cc.Handler.EVENT_KEYBOARD_RELEASED)

    self._timeTab = {0,0,0}

    local btnIndex = 0
    local function onTabEvent(widget)
        my.playClickBtnSound()
		self:onTabEvent(widget, MainTabEventMap, handler(self, self.updateBtnView))
	end
    for index, table in pairs(MainTabEventMap.TabButtons) do
        btnIndex = index
        if viewNode[table.checkBtn] then
            viewNode[table.checkBtn]:addClickEventListener(onTabEvent)
            if table.defaultShow then
                self:onTabEvent(viewNode[table.checkBtn]._realnode[1], MainTabEventMap)
                viewNode[table.checkBtn]:setSelected(true)
            end
        end
    end
    viewNode.BtnRule:addClickEventListener(handler(self,self.onShowRule))
    viewNode.BtnStartGame:addClickEventListener(handler(self,self.quickStart))

    self:setUIShow(1)

    self:listenTo(NationalDayActivityModel, NationalDayActivityModel.REFRESH_ACT_RANK, handler(self,self.onUpdateList))

    self:onGetRewardInfo()
    --AssistConnect:onReqRankInfo(self.rankType) --onTabEvent里面有获取
    --AssistConnect:onReqRankInfo(2)
    NationalDayActivityModel:onReqRankInfo(2)

    self:onSetDate()
    --self:updateExchangeView(self.rankType+1)
end
--[[function NationalDayActivityCtrl:onKeyboardReleased(keyCode, event)
    if keyCode == cc.KeyCode.KEY_BACK then
        print('~~on key back clicked~~')
        self:playEffectOnPress()
        self:onColseSelf()
    end
end]]--
function NationalDayActivityCtrl:onColseSelf()
    if self._timerListen then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._timerListen)
        self._timerListen = nil
    end
    cc.exports._gameJsonConfig.NationalDaysActivityRank = {}

    for i=3,1,-1 do
        if self.listViewTab[i] then
            self.listViewTab[i]:removeAllChildren()
            self.listViewTab[i]:removeSelf()
        end
    end

    if(self:informPluginByName(nil,nil))then
        self:removeSelfInstance()
    end
end
function NationalDayActivityCtrl:onUpdateList(rankType)
    if self.rankType == rankType.value then
        self:updateBtnView(self.rankType+1)
    end

    if nil == self._timerListen then
        self._timerListen = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self,self.update),1,false)
    end

    if cc.exports._gameJsonConfig.NationalDaysActivityRank[1] and next(cc.exports._gameJsonConfig.NationalDaysActivityRank[1]) ~=nil 
        and cc.exports._gameJsonConfig.NationalDaysActivityRank[3] and next(cc.exports._gameJsonConfig.NationalDaysActivityRank[3]) ~=nil then
        --在获取排名信息之后弹出排行榜结果
        self:showRankResult()
    end
end
function NationalDayActivityCtrl:update(delta)  --只更新当前已经查询过的排名
    for i=1,3 do
        if cc.exports._gameJsonConfig.NationalDaysActivityRank then
            if cc.exports._gameJsonConfig.NationalDaysActivityRank[i] and next(cc.exports._gameJsonConfig.NationalDaysActivityRank[i]) ~= nil then
                self._timeTab[i] = self._timeTab[i] + 1
                if self._timeTab[i] == 600 then
                    self._timeTab[i] = 0
                    --AssistConnect:onReqRankInfo(i - 1)
                    NationalDayActivityModel:onReqRankInfo(i - 1)
                end
            end
        end
    end
end
-- showType:  1 显示请求数据中  2 显示所有数据  3 显示当前还没有数据
function NationalDayActivityCtrl:setUIShow(showType)
    local viewNode = self._viewNode
    if showType == 1 then
        viewNode.warning:setVisible(true)
        viewNode.warning2:setVisible(false)
        viewNode.ScrollView:setVisible(false)
        viewNode.NodeSelfNo:setVisible(false)
    elseif showType == 2 then
        viewNode.warning:setVisible(false)
        viewNode.warning2:setVisible(false)
        viewNode.ScrollView:setVisible(true)
        viewNode.NodeSelfNo:setVisible(true)
    elseif showType ==3 then
        viewNode.warning:setVisible(false)
        viewNode.warning2:setVisible(true)
        viewNode.ScrollView:setVisible(false)
        viewNode.NodeSelfNo:setVisible(false)
    end
end
function NationalDayActivityCtrl:onGetRewardInfo()
    self._RewardList = {}
    self._RewardList[1] = {}   --总榜
    self._RewardList[2] = {}   --今日
    self._RewardList[3] = {}   --昨日
    local function addRewardInfoTab(startTab,endTab)
       for k,v in pairs(startTab) do
           local numTab = cc.exports.string_split(v.key,'-')
           table.sort( numTab, function ( item, item2 )  return tonumber(item)<tonumber(item2)  end )
           if #numTab == 1 then
               endTab[numTab[1]] = v
           else
               for i=tonumber(numTab[1]),tonumber(numTab[2]) do
                   endTab[tostring(i)] = v
               end
           end
       end
    end
    if cc.exports._gameJsonConfig.NationalDaysActivity and next(cc.exports._gameJsonConfig.NationalDaysActivity) ~= nil then
        addRewardInfoTab(cc.exports._gameJsonConfig.NationalDaysActivity.FinalReward,self._RewardList[1])
        addRewardInfoTab(cc.exports._gameJsonConfig.NationalDaysActivity.DailyReward,self._RewardList[2])
        self._RewardList[3] = clone(self._RewardList[2])
    end
end
function NationalDayActivityCtrl:onShowRule()
    my.playClickBtnSound()
    my.informPluginByName({pluginName='NationalDayActivityRulePlugin'})
end
function NationalDayActivityCtrl:quickStart()
    my.playClickBtnSound()
    --require("src.app.plugins.mainpanel.MainCtrl"):getInstance():quickStartBtClicked()
    local HallContext = import('src.app.plugins.mainpanel.HallContext'):getInstance()
    HallContext:dispatchEvent({name = HallContext.EVENT_MAP["hall_gotoGameByQuickStart"], value = {["autoDecideRoomScope"] = true}})
    self:onColseSelf()
end
function NationalDayActivityCtrl:onTabEvent(widgt, TabEventMap, callfunc)
    local viewNode = self._viewNode
    local selectIndex = -1
    for index, table in pairs(TabEventMap.TabButtons) do
        viewNode[table.checkBtn]:setSelected(false)
        if viewNode[table.checkBtn]._realnode[1] == widgt then
            selectIndex = index
        end
    end
    if selectIndex < 0  then
        return
    end
    if cc.exports._gameJsonConfig.NationalDaysActivityRank == nil then
        cc.exports._gameJsonConfig.NationalDaysActivityRank = {}
    end
    if not cc.exports._gameJsonConfig.NationalDaysActivityRank[selectIndex] or next(cc.exports._gameJsonConfig.NationalDaysActivityRank[selectIndex]) == nil then
        self.rankType = selectIndex - 1
        --AssistConnect:onReqRankInfo(self.rankType)
        NationalDayActivityModel:onReqRankInfo(self.rankType)
        self:setUIShow(1)
    end
    if callfunc then
        callfunc(selectIndex)
    end
end

function NationalDayActivityCtrl:updateBtnView(index)
    index = index or 1
    self._exchangeTabIndex = index
    self:updateScrollView(index)
end


function NationalDayActivityCtrl:updateScrollView(index) --显示列表内容
    local viewNode = self._viewNode
    viewNode.ScrollView:setVisible(false)

    for i=1,3 do
        if self.listViewTab[i] then
            self.listViewTab[i]:setVisible(false)
        end
    end

    if not (cc.exports._gameJsonConfig.NationalDaysActivityRank and cc.exports._gameJsonConfig.NationalDaysActivityRank[self._exchangeTabIndex] and next(cc.exports._gameJsonConfig.NationalDaysActivityRank[self._exchangeTabIndex]) ~= nil) then
        return
    end
    local rankDataList = cc.exports._gameJsonConfig.NationalDaysActivityRank[self._exchangeTabIndex]

    if not rankDataList then
        self:setUIShow(1)
        return
    end

    self:initItem(viewNode.NodeSelfNo,rankDataList[tostring(rankDataList.count)],1)   --自己的排名

    local itemNum = rankDataList.count -1
    if itemNum <= 0 then
        self:setUIShow(3)
        if tonumber(rankDataList[tostring(rankDataList.count)].pm) > 0 then
            self:setUIShow(2)
        end
        return
    end

    self:setUIShow(2)

    if self.listViewTab[index] then
        self.listViewTab[index]:setVisible(true)
        self.listViewTab[index]:reloadData()
        return
    end

    local cellsize = cc.size(860, 56)
    local function cellsizeidx(view, idx)
        return cellsize.height, cellsize.width
    end
    local function numofcells(view)
        return rankDataList.count -1
    end

    local function cellatidx(view, idx)
        local cell = view:dequeueCell()
        if nil == cell then
            cell = cc.TableViewCell:new()

            local item = cc.CSLoader:createNode("res/hallcocosstudio/NationalDayActivity/NationalDayActivity_item.csb")
            item:addTo(cell, 0, 1)
            item:setPositionX(11)
            local Panel = item:getChildByName("Panel")
            Panel:getChildByName("Img_UnitMainBG"):setVisible(false)
            item:setVisible(true)
        end
        local item = cell:getChildByTag(1)
        local rankItem = rankDataList[tostring(rankDataList.count -1 - idx)]
        self:initItem(item,rankItem,0)
        return cell
    end
    local listView = cc.TableView:create(viewNode.ScrollView:getContentSize())
    listView:setDirection(cc.SCROLLVIEW_DIRECTION_VERTICAL)
    listView:addTo(viewNode.mainPanel)
    listView:setAnchorPoint(cc.p(0,1))
    listView:setPosition(viewNode.ScrollView:getPositionX(),viewNode.ScrollView:getPositionY()-viewNode.ScrollView:getContentSize().height)

    listView:registerScriptHandler(cellsizeidx, cc.TABLECELL_SIZE_FOR_INDEX)
    listView:registerScriptHandler(numofcells, cc.NUMBER_OF_CELLS_IN_TABLEVIEW)
    listView:registerScriptHandler(cellatidx, cc.TABLECELL_SIZE_AT_INDEX)
    listView:reloadData()
    listView:setTouchEnabled(true)

    self.listViewTab[index] = listView

    --[[
    local ScrollViewChildren = viewNode.ScrollView:getChildren()
    for i = 1, viewNode.ScrollView:getChildrenCount() do
        local child = ScrollViewChildren[i]
        if child then
            child:setVisible(false)
        end
    end

    local itemNum = rankDataList.count -1
    if itemNum <= 0 then
        self:setUIShow(3)
        if tonumber(rankDataList[tostring(rankDataList.count)].pm) > 0 then
            self:setUIShow(2)
        end
        return
    end

    self:setUIShow(2)

    local heigthItem = math.ceil(itemNum)
    local intervalHeight = 3

    local perHeight = 56 --列表大小

    local ContainerHeigth = perHeight * heigthItem + (heigthItem-1)*intervalHeight
    
    local innerContainer = viewNode.ScrollView:getInnerContainer()

    local scrollHeigth = viewNode.ScrollView:getContentSize().height
    if ContainerHeigth < scrollHeigth then
        ContainerHeigth = scrollHeigth
    end
    viewNode.ScrollView:setInnerContainerSize(cc.size(innerContainer:getContentSize().width, ContainerHeigth))

    local startX = 11
    local startY = ContainerHeigth-- - perHeight
    for i=1,itemNum do
        local child = viewNode.ScrollView:getChildByTag(i)
        if child == nil then
            child = cc.CSLoader:createNode("res/hallcocosstudio/NationalDayActivity/NationalDayActivity_item.csb")
            viewNode.ScrollView:addChild(child)
        end
        local x = startX
        local y = startY-i*(perHeight + intervalHeight)

        --更新内容
        local rankItem = rankDataList[tostring(i)]
        self:initItem(child,rankItem,0)
        local Panel = child:getChildByName("Panel")
        Panel:getChildByName("Img_UnitMainBG"):setVisible(false)

        child:setVisible(true)
        child:setPosition(cc.p(x, y))
        child:setTag(i)       
    end
    viewNode.ScrollView:jumpToTop()
    --]]
end
--selfType  1表示是自己的排名
function NationalDayActivityCtrl:initItem(item,rankItem,selfType)
    local Panel = item:getChildByName("Panel")
    Panel:getChildByName("reward1"):setVisible(false)
    Panel:getChildByName("reward2"):setVisible(false)
    Panel:getChildByName("reward3"):setVisible(false)
    Panel:getChildByName("Img1"):setVisible(false)
    Panel:getChildByName("Img2"):setVisible(false)
    Panel:getChildByName("Img3"):setVisible(false)
    Panel:getChildByName("No"):setVisible(false)
    Panel:getChildByName("NO_pic"):setVisible(false)
    Panel:getChildByName("out_list"):setVisible(false)

    Panel:getChildByName("reward1"):setColor(cc.c3b(177,73,9))
    Panel:getChildByName("reward2"):setColor(cc.c3b(177,73,9))
    Panel:getChildByName("reward3"):setColor(cc.c3b(177,73,9))
    Panel:getChildByName("No"):setColor(cc.c3b(177,73,9))
    Panel:getChildByName("Name"):setColor(cc.c3b(177,73,9))
    Panel:getChildByName("Score"):setColor(cc.c3b(177,73,9))

    local utf8name = MCCharset:getInstance():gb2Utf8String(rankItem.u, string.len(rankItem.u))
    local nameStr = my.getStringByLength(utf8name,8)
    if nameStr == UserModel.szUtf8Username then
        nameStr = UserModel:getSelfDisplayName() --对自己，替换成昵称
    end

    if tonumber(rankItem.pm) < 1 then
        local config = cc.exports.GetRoomConfig()
        Panel:getChildByName("out_list"):setVisible(true)
        Panel:getChildByName("Name"):setString(nameStr)
        Panel:getChildByName("Score"):setString(rankItem.s)
        return
    end

    local rewardItem = self._RewardList[self._exchangeTabIndex][rankItem.pm]

    if tonumber(rankItem.pm) <= 3 then
        Panel:getChildByName("NO_pic"):setVisible(true)
        Panel:getChildByName("NO_pic"):setSpriteFrame("hallcocosstudio/images/plist/NationalDayActivity/huangguan_"..rankItem.pm..".png")
    else
        Panel:getChildByName("No"):setVisible(true)
    end
    Panel:getChildByName("No"):setString(rankItem.pm)
    Panel:getChildByName("Name"):setString(nameStr)
    Panel:getChildByName("Score"):setString(rankItem.s)

    if rewardItem then
        if rewardItem.gift then
            Panel:getChildByName("reward3"):setVisible(true)
            Panel:getChildByName("Img3"):setVisible(true)
            Panel:getChildByName("reward3"):setString(MCCharset:getInstance():gb2Utf8String(rewardItem.gift, string.len(rewardItem.gift)))
        end
        if rewardItem.silver then
            Panel:getChildByName("reward1"):setVisible(true)
            Panel:getChildByName("Img1"):setVisible(true)
            Panel:getChildByName("reward1"):setString(MCCharset:getInstance():gb2Utf8String(rewardItem.silver, string.len(rewardItem.silver)))
        end
        if rewardItem.vochers then
            Panel:getChildByName("reward2"):setVisible(true)
            Panel:getChildByName("Img2"):setVisible(true)
            Panel:getChildByName("reward2"):setString(MCCharset:getInstance():gb2Utf8String(rewardItem.vochers, string.len(rewardItem.vochers)))
        end
    end

    local rankDataList = cc.exports._gameJsonConfig.NationalDaysActivityRank[self._exchangeTabIndex]
    if DEBUG == 0 then
        print("NationalDayActivityCtrl:initItem", self._exchangeTabIndex, self._exchangeTabIndex)
        dump(rankItem)
        dump(cc.exports._gameJsonConfig.NationalDaysActivityRank)
    end

    if rankDataList == nil or next(rankDataList) == nil then
        return
    end

    if selfType == 0 and tonumber(rankItem.pm) == tonumber(rankDataList[tostring(rankDataList.count)].pm) then
        Panel:getChildByName("reward1"):setColor(cc.c3b(90,145,3))
        Panel:getChildByName("reward2"):setColor(cc.c3b(90,145,3))
        Panel:getChildByName("reward3"):setColor(cc.c3b(90,145,3))
        Panel:getChildByName("No"):setColor(cc.c3b(90,145,3))
        Panel:getChildByName("Name"):setColor(cc.c3b(90,145,3))
        Panel:getChildByName("Score"):setColor(cc.c3b(90,145,3))
    end
end
function NationalDayActivityCtrl:onSetDate()
    if cc.exports._gameJsonConfig.NationalDaysActivity and next(cc.exports._gameJsonConfig.NationalDaysActivity) ~= nil then
        local startTime = cc.exports._gameJsonConfig.NationalDaysActivity.StartDate
        local endtime = cc.exports._gameJsonConfig.NationalDaysActivity.EndDate

        if startTime and endtime then
            local startDay = string.sub(startTime, -2)
            local startMon = string.sub(startTime, -4,-3)
            local endDay = string.sub(endtime, -2)
            local endMon = string.sub(endtime, -4,-3)
            local constStrings=cc.load('json').loader.loadFile('DailyActivitysStrings.json')
            local dayStr = constStrings['Day']
            local monthStr = constStrings['Month']
            self._viewNode.dateTime:setString(startMon .. monthStr.. startDay .. dayStr .."-" .. endMon .. monthStr .. endDay .. dayStr)
        end
    end
end

function NationalDayActivityCtrl:showRankResult()
    local finalRankDataList = cc.exports._gameJsonConfig.NationalDaysActivityRank[1]
    local dailyRankDataList = cc.exports._gameJsonConfig.NationalDaysActivityRank[3]
    local finalRankData = finalRankDataList[tostring(finalRankDataList.count)]
    local dailyRankData = dailyRankDataList[tostring(dailyRankDataList.count)]
    local finalReward = self._RewardList[1][finalRankData.pm]
    local dailyReward = self._RewardList[3][dailyRankData.pm]

    --如果当天第一次打开巅峰榜，弹出名次提示
    local  myRankData = self:readMyRankData() or {}
    local date = self:getTodayDate()


    if cc.exports._gameJsonConfig.NationalDaysActivity and next(cc.exports._gameJsonConfig.NationalDaysActivity) ~= nil then
        local time = os.date("%Y%m%d", os.time() - 86400)
        if tonumber(time)>=tonumber(cc.exports._gameJsonConfig.NationalDaysActivity.EndDate) 
            and  myRankData.FinalRewardDate ~= cc.exports._gameJsonConfig.NationalDaysActivity.EndDate 
                and finalRankData.pm and tonumber(finalRankData.pm) > 0 then

            myRankData.FinalRewardDate = cc.exports._gameJsonConfig.NationalDaysActivity.EndDate
            local finalData = {}
            finalData.rankType = 1 --总榜
            finalData.reward = finalReward
            finalData.rank = finalRankData.pm

            local dailyData = {}
            dailyData.rankType = 3 --日榜
            dailyData.reward = dailyReward
            dailyData.rank = dailyRankData.pm

            if date ~= myRankData.logindate and dailyRankDataList and dailyRankData.pm and tonumber(dailyRankData.pm) > 0 then
                myRankData.logindate = date
                local function callback()
                    my.scheduleOnce( function()
                        my.informPluginByName( { pluginName = 'RankRewardCtrl', params = { data = finalData } })
                    end , 0.5)
                end
                my.informPluginByName( { pluginName = 'RankRewardCtrl', params = { callback = callback, data = dailyData } })
            else
                myRankData.logindate = date
                my.informPluginByName( { pluginName = 'RankRewardCtrl', params = { data = finalData } })
            end
        else
            if date ~= myRankData.logindate and dailyRankDataList then
                myRankData.logindate = date
                local dailyData = {}
                dailyData.rankType = 3 --日榜
                dailyData.reward = dailyReward
                dailyData.rank = dailyRankData.pm
                if dailyRankData.pm and tonumber(dailyRankData.pm) > 0 then
                    my.informPluginByName({pluginName= 'RankRewardCtrl', params = { data = dailyData }})
                end
            end
        end
    end
    self:saveMyRankData(myRankData)
end

function NationalDayActivityCtrl:getTodayDate()
	local tmYear=os.date('%Y',os.time())
	local tmMon=os.date('%m',os.time())
	local tmMday=os.date('%d',os.time())
	return tmYear.."_"..tmMon.."_"..tmMday
end

function NationalDayActivityCtrl:readMyRankData()
	local playerInfo 	= PublicInterface.GetPlayerInfo()
    if not playerInfo then return end
    local nUserID = playerInfo.nUserID
    return my.readCache("MyRankData"..nUserID..".xml")
end

function NationalDayActivityCtrl:saveMyRankData(rankData)
	local playerInfo 	= PublicInterface.GetPlayerInfo()
    if not playerInfo then return end
    local nUserID = playerInfo.nUserID
    my.saveCache("MyRankData"..nUserID..".xml", rankData)
end

function NationalDayActivityCtrl:onExit()
    local PluginProcessModel = mymodel('hallext.PluginProcessModel'):getInstance()
    PluginProcessModel:PopNextPlugin()
end

return NationalDayActivityCtrl
