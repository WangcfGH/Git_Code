local viewCreater = import('src.app.plugins.PeakRank.PeakRankView')
local PeakRankCtrl = class('PeakRankCtrl', cc.load('BaseCtrl'))
local PeakRankDef = import('src.app.plugins.PeakRank.PeakRankDef')
local PeakRankModel = import('src.app.plugins.PeakRank.PeakRankModel'):getInstance()
local BaseRadio = import('src.app.GameHall.ctrls.BaseRadio')
local UserModel = mymodel('UserModel'):getInstance()
local MyTimeStamp = import('src.app.mycommon.mytimestamp.MyTimeStamp'):getInstance()

local PeakRankRankNOString = { '一', '二', '三' }
local PeakRankTitleRankValueString = { '赢的银两', '单局最高胜银', '对局数', '最高连胜', }
local PeakRankMyRankTypeString = {
    {
        '我当前赢的银两',
        '我当前单局最高胜银',
        '我当前对局数',
        '我当前最高连胜',
        '我当前点赞总数'
    },
    {
        '我今日赢的银两',
        '我今日单局最高胜银',
        '我今日对局数',
        '我今日最高连胜',
        '我今日点赞总数'
    },
    {
        '我昨日赢的银两',
        '我昨日单局最高胜银',
        '我昨日对局数',
        '我昨日最高连胜',
        '我昨日点赞总数'
    }
}

local PeakRankMyRankNOString = {
    '我的当前排名', '我的今日排名', '我的昨日排名'
}

local RewardPoolAniNameTbl = {
    'diaosu',
    'jiangci_1',
    'jiangci_2',
    'jiangci_3',
    'jiangci_4',
    'jiangci_5',
    'jiangci_0_xh',
    'jiangci_1_xh',
    'jiangci_2_xh',
    'jiangci_3_xh',
    'jiangci_4_xh',
    'jiangci_5_xh',
}

function PeakRankCtrl:onCreate(params)
    local viewNode = self:setViewIndexer(viewCreater:createViewIndexer())

    self._rankType = PeakRankDef.PeakRankRankType.GainTotal
    self._dayType = PeakRankDef.PeakRankDayType.Total
    self._areaType = PeakRankDef.PeakRankAreaType.None
    self._curListSize = 0
    self._rankDataList = {}

    self._nodeRewardPoolAni = nil
    self._rewardPoolAniName = ''
    self._rankItemForClone = nil

    self._initOver = false

    self:bindDestroyButton(viewNode.btnClose)
    self:bindUserEventHandler(viewNode, {'btnRule'})
    
    self:initRollingNumber()
    self:initRankItemForClone()

    self:initRankTypeRadioBtns()
    self:initDayTypeRadioBtns()
    self:initAreaTypeRadioBtns()

    self:initZhipairenAni()
    self:initGotoPlayBtn()
    self:initRankDate()
    self:initFirstUserName()
    self:addEventListeners()

    self:freshRankTotalValueTip()
    self:freshSelfRankInfo()

    self._initOver = true

    my.runPopupAction(viewNode.panelAnimation:getRealNode(), function()
        self:queryOrFreshRankList()
    end)

    PeakRankModel:updateRoundDateCache()
end

function PeakRankCtrl:addEventListeners()
    self:listenTo(PeakRankModel, PeakRankModel.EVENT_ON_CONFIG_RSP, handler(self, self.onConfigRsp))
    self:listenTo(PeakRankModel, PeakRankModel.EVENT_ON_PEAKRANKINFO_RSP, handler(self, self.onPeakRankInfoRsp))
    self:listenTo(PeakRankModel, PeakRankModel.EVENT_ON_PEAKRANKTOTALVALUE_RSP, handler(self, self.onPeakRankTotalValueRsp))
    self:listenTo(MyTimeStamp, MyTimeStamp.UPDATE_DAY,  handler(self,self.updateDay))

    self._viewNode.listViewRank:addEventListener(handler(self, self.onListViewScrolling))
end

function PeakRankCtrl:onListViewScrolling(target, event)
    local curSelectedIndex = target:getCurSelectedIndex()
    if self._curListSize - curSelectedIndex <= 10 and self._curListSize < #self._rankDataList then
        self:loadNextRankLits()
    end
end

function PeakRankCtrl:onConfigRsp(event)
    
end

function PeakRankCtrl:onPeakRankInfoRsp(event)
    local rankType = event.value and event.value.rankType
    local dayType = event.value and event.value.dayType
    local areaType = event.value and event.value.areaType

    if rankType == self._rankType and dayType == self._dayType and areaType == self._areaType then
        self:stopLoading()
        self:freshPeakRank()
    end
end

function PeakRankCtrl:onPeakRankTotalValueRsp(event)
    self:freshRankTotalValue()
    if PeakRankModel:getRankRewardGetType(self._rankType, self._dayType, self._areaType) == PeakRankDef.AWARD_GET_TYPE.PERCENTAGE_TYPE then
        self:freshTrophyAni()
    end
end

function PeakRankCtrl:updateDay()
    PeakRankModel:reqPeakRankInfo(self._rankType, self._dayType, self._areaType)
end

function PeakRankCtrl:initZhipairenAni()
    local ani = sp.SkeletonAnimation:create("res/hallcocosstudio/images/skeleton/PeakRank/zhipairen.json", "res/hallcocosstudio/images/skeleton/PeakRank/zhipairen.atlas")
    ani:setAnimation(0, "zhipairen", true)
    ani:setDebugBonesEnabled(false)
    ani:setAnchorPoint(0.5, 0.5)
    ani:setPosition(cc.p(137, 80))
    ani:setVisible(true)
    self._nodeZhipairenAni = ani
    self._viewNode.panelAnimation:addChild(ani)
end

function PeakRankCtrl:initGotoPlayBtn()
    local btnGotoPlay = self._viewNode.nodeGotoPlayBtnAni:getChildByName('Btn_GotoPlay')
    if btnGotoPlay then
        local csbPath = 'res/hallcocosstudio/PeakRank/Node_BtnGotoPlayAni.csb'
        local timeLine = cc.CSLoader:createTimeline(csbPath)
        if timeLine then
            self._viewNode.nodeGotoPlayBtnAni:getRealNode():runAction(timeLine)
            timeLine:gotoFrameAndPlay(0, 150, true)
        end
        btnGotoPlay:addClickEventListener(handler(self, self.btnGotoPlayClicked))
    end
end

function PeakRankCtrl:initRollingNumber()
    local RollingNumber = import('src.app.plugins.PeakRank.RollingNumber')
    self._rollingNumber = RollingNumber:create(self._viewNode.panelRollReward:getRealNode(), 12)
    self._rollingNumber:setTo(0)
end

function PeakRankCtrl:initRankDate()
    self:freshRankDate()
end

function PeakRankCtrl:initFirstUserName()
    self:freshFirstUserName()
end

function PeakRankCtrl:initRankItemForClone()
    local rankItem = cc.CSLoader:createNode('res/hallcocosstudio/PeakRank/Node_RankItem.csb')
    if rankItem then
        self._rankItemForClone = rankItem:getChildByName('Panel_Main')
        if self._rankItemForClone then
            self._rankItemForClone:retain()
            self._rankItemForClone:removeFromParent()
        end
    end
end

-- 初始化排行类型单选按钮 盈利/胜银/对局/连胜/点赞
function PeakRankCtrl:initRankTypeRadioBtns()
    local radioCallbackTbl = {}
    local radioStateCallbackTbl = {}
    local defaultIndex = 0

    local pos = {}
    local showIndex = 0
    for i = 1, 5 do
        local radioBtn = self._viewNode.panelRankTypeRadios:getChildByName('Radio_' .. i)
        table.insert(pos, cc.p(radioBtn:getPosition()))

        local rankTypeName = PeakRankModel:getRankTypeName(i)
        radioBtn:getChildByName('Text_BtnTitle'):setString(rankTypeName)

        local rankTypeEnable = PeakRankModel:isRankTypeEnable(i)
        radioBtn:setVisible(rankTypeEnable)

        if rankTypeEnable then
            showIndex = showIndex + 1
            if showIndex < i then
                radioBtn:setPosition(pos[showIndex])
            end
            if defaultIndex == 0 then
                radioBtn:setSelected(true)
                defaultIndex = i
            end
        end

        local function radioCallback()
            self:onRankTypeSelected(i)
        end

        local function radioStateCallback(name, event)
            self:onRankTypeRadioStateEvent(radioBtn, name, event)
        end

        table.insert(radioCallbackTbl, radioCallback)
        table.insert(radioStateCallbackTbl, radioStateCallback)
    end

    self._rankTypeRadio = BaseRadio:create(self._viewNode.panelRankTypeRadios:getRealNode(), #radioCallbackTbl, defaultIndex, radioCallbackTbl, radioStateCallbackTbl)
end

-- 初始化排行日期单选按钮 总榜/今日/昨日
function PeakRankCtrl:initDayTypeRadioBtns()
    local radioCallbackTbl = {}
    local radioStateCallbackTbl = {}
    local defaultIndex = 1

    for i = 1, 3 do
        local function radioCallback()
            self:onDayTypeSelected(i)
        end

        local function radioStateCallback(name, event)
            self:onDayTypeBtnEvent(name, event)
        end

        table.insert(radioCallbackTbl, radioCallback)
        table.insert(radioStateCallbackTbl, radioStateCallback)
    end

    self._dayTypeRadio = BaseRadio:create(self._viewNode.panelDayTypeRadios:getRealNode(), #radioCallbackTbl, defaultIndex, radioCallbackTbl, radioStateCallbackTbl)
end

-- 初始化排行玩法单选按钮 不洗牌/经典
function PeakRankCtrl:initAreaTypeRadioBtns()
    local radioCallbackTbl = {}
    local radioStateCallbackTbl = {}
    local defaultIndex = 1

    for i = 1, 2 do
        local function radioCallback()
            self:onAreaTypeSelected(i)
        end

        local function radioStateCallback(name, event)
            self:onAreaTypeBtnEvent(name, event)
        end

        table.insert(radioCallbackTbl, radioCallback)
        table.insert(radioStateCallbackTbl, radioStateCallback)
    end

    self._areaTypeRadio = BaseRadio:create(self._viewNode.panelAreaTypeRadios:getRealNode(), #radioCallbackTbl, defaultIndex, radioCallbackTbl, radioStateCallbackTbl)
end

-- 切换榜单标签
function PeakRankCtrl:onRankTypeSelected(rankType)
    if self._initOver then
        my.playClickBtnSound()
    end
    
    self._rankType = rankType
    self._rankDataList = {}
    self._dayType = PeakRankDef.PeakRankDayType.Total

    local radioBtnDayTotal = self._viewNode.panelDayTypeRadios:getChildByName('Radio_1')
    local radioBtnDayToday = self._viewNode.panelDayTypeRadios:getChildByName('Radio_2')
    local radioBtnDayYesterDay = self._viewNode.panelDayTypeRadios:getChildByName('Radio_3')
    radioBtnDayTotal:setSelected(true)
    radioBtnDayToday:setSelected(false)
    radioBtnDayYesterDay:setSelected(false)
    radioBtnDayTotal:setEnabled(false)
    radioBtnDayToday:setEnabled(true)
    radioBtnDayYesterDay:setEnabled(true)

    if PeakRankModel:isRankTypeSupportDiffArea(rankType) then
        self._areaType = PeakRankDef.PeakRankAreaType.NoShuffle

        local radioBtnAreaNoshuffle = self._viewNode.panelAreaTypeRadios:getChildByName('Radio_1')
        local radioBtnAreaClassic = self._viewNode.panelAreaTypeRadios:getChildByName('Radio_2')
        radioBtnAreaNoshuffle:setSelected(true)
        radioBtnAreaClassic:setSelected(false)
        radioBtnAreaNoshuffle:setEnabled(false)
        radioBtnAreaClassic:setEnabled(true)
    
        self._viewNode.panelAreaType:setVisible(true)
        self._viewNode.panelRankList:setContentSize(cc.size(600, 295))
    else
        self._areaType = PeakRankDef.PeakRankAreaType.None
        self._viewNode.panelAreaType:setVisible(false)
        self._viewNode.panelRankList:setContentSize(cc.size(650, 295))
    end

    if PeakRankModel:getRankRewardGetType(self._rankType, self._dayType, self._areaType) == PeakRankDef.AWARD_GET_TYPE.PERCENTAGE_TYPE then
        self._viewNode.imgTotalReward:setVisible(true)
        self:freshTrophyAni()
    else
        self._viewNode.imgTotalReward:setVisible(false)
        self:showSculptureAni()
    end

    ccui.Helper:doLayout(self._viewNode.panelRankList:getRealNode())
    self:onRankDayAreaTypeChanged()
end

function PeakRankCtrl:onRankTypeRadioStateEvent(radioBtn, name, event)
    -- 调整按钮选中转态改变时按钮标题的偏移
    local btnTitle = radioBtn:getChildByName('Text_BtnTitle')
    if btnTitle then
        if name == 'began' or name == 'ended' or name == 'selected' then
            btnTitle:setPositionX(51)
        elseif name == 'cancelled' or name == 'unselected' then
            btnTitle:setPositionX(45)
        end
    end

    local imgTitle = radioBtn:getChildByName('Img_SubTitle')
    if imgTitle then
        if name == 'began' or name == 'ended' or name == 'selected' then
            imgTitle:setPositionX(22)
        elseif name == 'cancelled' or name == 'unselected' then
            imgTitle:setPositionX(16)
        end
    end
end

function PeakRankCtrl:onDayTypeSelected(dayType)
    if self._initOver then
        my.playClickBtnSound()
    end

    self._dayType = dayType
    self._rankDataList = {}

    if PeakRankModel:getRankRewardGetType(self._rankType, self._dayType, self._areaType) == PeakRankDef.AWARD_GET_TYPE.PERCENTAGE_TYPE then
        self._viewNode.imgTotalReward:setVisible(true)
        self:freshTrophyAni()
    else
        self._viewNode.imgTotalReward:setVisible(false)
        self:showSculptureAni()
    end

    self:onRankDayAreaTypeChanged()
end

function PeakRankCtrl:onDayTypeBtnEvent(name, event)
    -- none
end

-- 切换玩法标签
function PeakRankCtrl:onAreaTypeSelected(areaType)
    if self._initOver then
        my.playClickBtnSound()
    end
    
    if PeakRankModel:isRankTypeSupportDiffArea(self._rankType) then
        self._areaType = areaType
    else
        self._areaType = PeakRankDef.PeakRankAreaType.None
    end
    self._rankDataList = {}
    self:onRankDayAreaTypeChanged()
end

function PeakRankCtrl:onAreaTypeBtnEvent(name, event)
    -- none
end

function PeakRankCtrl:onRankDayAreaTypeChanged()
    if self._initOver then
        self:queryOrFreshRankList()
    end
end

function PeakRankCtrl:queryOrFreshRankList()
    if PeakRankModel:isRankInfoExpire(self._rankType, self._dayType, self._areaType) then
        self:startLoading()
        my.scheduleOnce(function()
            PeakRankModel:reqPeakRankInfo(self._rankType, self._dayType, self._areaType)
        end, 0.2)
    else
        self:stopLoading()
        self:freshPeakRank()
    end
end

function PeakRankCtrl:getTrophyAnimationName()
    local totalValue = PeakRankModel:getRankTotalValue(self._rankType, self._dayType, self._areaType)
    local aniLevelTable = cc.exports.getPeakRankAniLevelTbl()
    local index = 0
    for i, v in ipairs(aniLevelTable) do
        if totalValue >= v * 100000000 then
            index = i
        end
    end
    local aniName = 'jiangci_' .. tostring(index)
    if self._dayType == PeakRankDef.PeakRankDayType.YesterDay then
        return aniName .. '_xh'
    end
    return aniName
end

-- 右边动画显示为银两掉入奖杯动画
function PeakRankCtrl:freshTrophyAni()
    local aniName = self:getTrophyAnimationName()
    if self._rewardPoolAniName ~= aniName then
        if self._nodeRewardPoolAni then
            self._nodeRewardPoolAni:removeFromParentAndCleanup()
            self._nodeRewardPoolAni = nil
        end

        local ani = sp.SkeletonAnimation:create("res/hallcocosstudio/images/skeleton/PeakRank/jiangci.json", "res/hallcocosstudio/images/skeleton/PeakRank/jiangci.atlas")
        ani:setAnimation(0, aniName, true)
        ani:setDebugBonesEnabled(false)
        ani:setAnchorPoint(0.5, 0.5)
        ani:setVisible(true)
        self._nodeRewardPoolAni = ani
        self._rewardPoolAniName = aniName
        self._viewNode.nodeRewardPoolAni:addChild(ani)
    end
end

-- 右边动画显示为雕塑动画
function PeakRankCtrl:showSculptureAni()
    if self._rewardPoolAniName ~= 'diaosu' then
        -- 不是雕塑动画才需要销毁再创建雕塑动画
        if self._nodeRewardPoolAni then
            self._nodeRewardPoolAni:removeFromParentAndCleanup()
            self._nodeRewardPoolAni = nil
        end
    
        local ani = sp.SkeletonAnimation:create("res/hallcocosstudio/images/skeleton/PeakRank/jiangci.json", "res/hallcocosstudio/images/skeleton/PeakRank/jiangci.atlas")
        ani:setAnimation(0, "diaosu", true)
        ani:setDebugBonesEnabled(false)
        ani:setAnchorPoint(0.5, 0.5)
        ani:setVisible(true)
        self._nodeRewardPoolAni = ani
        self._rewardPoolAniName = 'diaosu'
        self._viewNode.nodeRewardPoolAni:addChild(ani)
    end
end

function PeakRankCtrl:btnRuleClicked()
    my.informPluginByName({pluginName = 'PeakRankRuleCtrl'})
end

function PeakRankCtrl:btnGotoPlayClicked()
    local HallContext = import('src.app.plugins.mainpanel.HallContext'):getInstance()

    if self._areaType == PeakRankDef.PeakRankAreaType.Classic then
        HallContext:dispatchEvent({name = HallContext.EVENT_MAP["hall_gotoGameByQuickStart"], value = {["findScope"] = "classic"}})
    elseif self._areaType == PeakRankDef.PeakRankAreaType.NoShuffle then
        HallContext:dispatchEvent({name = HallContext.EVENT_MAP["hall_gotoGameByQuickStart"], value = {["findScope"] = "noshuffle"}})
    else
        HallContext:dispatchEvent({name = HallContext.EVENT_MAP["hall_gotoGameByQuickStart"], value = {["findScope"] = "noshuffle"}})
    end
end

function PeakRankCtrl:freshPeakRank()
    self._rankDataList = PeakRankModel:getRankDataList(self._rankType, self._dayType, self._areaType)
    self:freshRankTitle()
    self:freshSelfRankInfo()
    self:freshFirstUserName()
    self:freshRankList()
    self:freshRankDate()
    self:freshRankTotalValue(true, true)
    if PeakRankModel:getRankRewardGetType(self._rankType, self._dayType, self._areaType) == PeakRankDef.AWARD_GET_TYPE.PERCENTAGE_TYPE then
        self:freshTrophyAni()
    end
    self:freshRankTotalValueTip()
end

function PeakRankCtrl:freshRankTitle()
    if self._rankType == PeakRankDef.PeakRankRankType.ThumbsUp then
        self._viewNode.titleRankValue:setVisible(false)
        self._viewNode.titleThumbsUp:setVisible(true)
        self._viewNode.titleTotalThumbsUp:setVisible(true)
    else
        self._viewNode.titleThumbsUp:setVisible(false)
        self._viewNode.titleTotalThumbsUp:setVisible(false)
        self._viewNode.titleRankValue:setVisible(true)

        local strTitle = ''
        if self._rankType == PeakRankDef.PeakRankRankType.GainTotal then
            if self._dayType == PeakRankDef.PeakRankDayType.Total then
                strTitle = '累计赢的银两'
            elseif self._dayType == PeakRankDef.PeakRankDayType.Today then
                strTitle = '今日赢的银两'
            elseif self._dayType == PeakRankDef.PeakRankDayType.YesterDay then
                strTitle = '昨日赢的银两'
            end
        else
            strTitle = PeakRankTitleRankValueString[self._rankType]
        end
        self._viewNode.titleRankValue:setString(strTitle)
    end
end

function PeakRankCtrl:freshSelfRankInfo()
    self._viewNode.titleMyRankValue:setString(PeakRankMyRankTypeString[self._dayType][self._rankType])
    self._viewNode.titleMyRankNO:setString(PeakRankMyRankNOString[self._dayType])
    local selfRankInfo = PeakRankModel:getSelfRankInfo(self._rankType, self._dayType, self._areaType)
    if selfRankInfo then
        self._viewNode.textMyRankValue:setString(selfRankInfo.rankValue)

        local maxRankNO = PeakRankModel:getRankMaxRankNo(self._rankType, self._dayType, self._areaType)
        if selfRankInfo.rankNo == -1 or selfRankInfo.rankNo > maxRankNO then
            self._viewNode.textMyRankNO:setString('未上榜')
        else
            self._viewNode.textMyRankNO:setString(selfRankInfo.rankNo)
        end
    else
        self._viewNode.textMyRankValue:setString('暂无数据')
        self._viewNode.textMyRankNO:setString('暂无数据')
    end
end

function PeakRankCtrl:freshFirstUserName()

    if self._rankType == PeakRankDef.PeakRankRankType.GainTotal then
        self._viewNode.textFirstUserName:setVisible(false)
    else
        self._viewNode.textFirstUserName:setVisible(true)
        local firstInfo = self._rankDataList[1]
        if firstInfo then
            my.fitStringInWidget(firstInfo.userName, self._viewNode.textFirstUserName, 160)
        else
            self._viewNode.textFirstUserName:setString('暂无数据')
        end
    end
end

-- 刷新排行
function PeakRankCtrl:freshRankList()
    self._curListSize = 0
    self._viewNode.listViewRank:removeAllChildren()

    if PeakRankModel:isRankTypeSupportDiffArea(self._rankType) then
        self._rankItemForClone:setContentSize(cc.size(600, 50))
    else
        self._rankItemForClone:setContentSize(cc.size(650, 50))
    end

    ccui.Helper:doLayout(self._rankItemForClone)

    self._viewNode.textNoData:setVisible(#self._rankDataList <= 0)

    self:loadNextRankLits()
    
    my.scheduleOnce(function()
        if self._viewNode and not tolua.isnull(self._viewNode:getRealNode()) then
            self._viewNode.listViewRank:jumpToTop()
        end
    end, 0)
end

function PeakRankCtrl:loadNextRankLits()
    local rewardEnable = PeakRankModel:isRankRewardEnable(self._rankType, self._dayType, self._areaType)
    local rewardGetType = PeakRankModel:getRankRewardGetType(self._rankType, self._dayType, self._areaType)
    
    if self._curListSize > 0 then
        self._viewNode.listViewRank:removeLastItem()
    end

    local startIndex = self._curListSize + 1
    local endIndex = self._curListSize + 10
    for i = startIndex, endIndex do
        if i <= #self._rankDataList then
            local rankData = self._rankDataList[i]
            local rankItem = self:createRankItem(i, rankData, rewardEnable, rewardGetType)
            self._curListSize = self._curListSize + 1
            self._viewNode.listViewRank:pushBackCustomItem(rankItem)
        end
    end

    if self._curListSize < #self._rankDataList then
        -- 还没全部加载完，插入一个继续加载提示
        local widget = ccui.Widget:create()
        local contentSize = self._rankItemForClone:getContentSize()
        widget:setContentSize(contentSize)
        local fontPath = "res/common/font/mainfont.TTF"

        local color = cc.c3b(161,74,22)
        local label = ccui.Text:create('继续滑动加载剩余榜单', fontPath, 28)
        label:setTextColor(color)
        label:ignoreContentAdaptWithSize(false)
        label:setAnchorPoint(cc.p(0.5, 0.5))
        label:setPosition(cc.p(contentSize.width / 2, contentSize.height / 2))
        widget:addChild(label)
        self._viewNode.listViewRank:pushBackCustomItem(widget)
    end
end

function PeakRankCtrl:createRankItem(rankNO, rankData, rewardEnable, rewardGetType)
    local rankItem = self._rankItemForClone:clone()
    rankItem:retain()
    if rankItem then
        local imgItemBG = rankItem:getChildByName('Img_ItemBG')
        local textRankNO = rankItem:getChildByName('Text_RankNO')
        local textUserName = rankItem:getChildByName('Text_UserName')
        local textRankValue = rankItem:getChildByName('Text_RankValue')
        local textThumbsUp = rankItem:getChildByName('Text_ThumbsUp')
        local textTotalThumbsUp = rankItem:getChildByName('Text_TotalThumbsUp')
        local panelReward = rankItem:getChildByName('Panel_Reward')
        local textRankReward = panelReward:getChildByName('Text_RankReward')
        local textRewardPercent = panelReward:getChildByName('Text_RewardPercent')
        local imgIconReward = panelReward:getChildByName('Img_IconReward')

        if rankNO <= 3 then
            imgItemBG:loadTexture('hallcocosstudio/images/plist/PeakRank/img_pm_bg_' .. rankNO .. '.png', ccui.TextureResType.plistType)
            textRankNO:setString(PeakRankRankNOString[rankNO])
        else
            textRankNO:setString(rankNO)
        end

        if rankData.userid == UserModel.nUserID then
            local color = cc.c3b(110, 44, 209)
            textUserName:setTextColor(color)
            textRankValue:setTextColor(color)
            textThumbsUp:setTextColor(color)
            textTotalThumbsUp:setTextColor(color)
            textRankReward:setTextColor(color)
            textRewardPercent:setTextColor(color)
            rankItem:getChildByName('Img_ItemBG_Line'):setVisible(true)
        end

        my.fitStringInWidget(rankData.userName, textUserName, 175)
        
        if self._rankType == PeakRankDef.PeakRankRankType.ThumbsUp then
            textRankValue:setVisible(false)
            textThumbsUp:setVisible(true)
            textThumbsUp:setString(string.format('%d/%d', rankData.rankSendValue, rankData.rankGetValue))

            textTotalThumbsUp:setVisible(true)
            textTotalThumbsUp:setString(tostring(rankData.rankTotalValue))
        elseif self._rankType == PeakRankDef.PeakRankRankType.GainTotal
            or self._rankType == PeakRankDef.PeakRankRankType.GainOnece then
            textRankValue:setMoney(rankData.rankValue)
        else
            textRankValue:setString(rankData.rankValue)
        end

        if rewardEnable then
            local reward = PeakRankModel:getRankReward(self._rankType, self._dayType, self._areaType, rankNO)
            if reward then
                if reward.RewardType == 1 then
                    imgIconReward:loadTexture('hallcocosstudio/images/plist/RewardCtrl/Img_Silver1.png', ccui.TextureResType.plistType)
                end

                if rewardGetType == PeakRankDef.AWARD_GET_TYPE.PERCENTAGE_TYPE then
                    -- 百分比显示
                    local rewardPrecent = reward.RewardNum * 100 / 10000
                    if math.floor((rewardPrecent - math.floor(rewardPrecent)) * 10) > 0  then
                        textRewardPercent:setString(string.format('%.1f%%', rewardPrecent))
                    else
                        textRewardPercent:setString(string.format('%d%%', math.floor(rewardPrecent)))
                    end

                    local exchangeRatio = PeakRankModel:getRankExchangeRatioAndRewardType(self._rankType, self._dayType, self._areaType)

                    local rewardCount = math.floor(rewardPrecent * PeakRankModel:getRankTotalValue(self._rankType, self._dayType, self._areaType) / 100 / exchangeRatio)
                    textRankReward:setString(string.format('(     %d)', rewardCount))

                    local textSize = textRankReward:getContentSize()
                    panelReward:setContentSize(cc.size(textSize.width, 50))
                    textRewardPercent:setPositionX(textSize.width / 2)
                    textRankReward:setPositionX(textSize.width / 2)
                    imgIconReward:setPositionX(22)
                elseif rewardGetType == PeakRankDef.AWARD_GET_TYPE.FIXED_TYPE then
                    textRewardPercent:setVisible(false)
                    textRankReward:setString(string.format('     %d', reward.RewardNum ))
                    
                    local textSize = textRankReward:getContentSize()
                    panelReward:setContentSize(cc.size(textSize.width, 50))
                    textRewardPercent:setPositionX(textSize.width / 2)
                    textRankReward:setPosition(cc.p(textSize.width / 2, 26))
                    imgIconReward:setPosition(cc.p(20, 24))
                end
            else
                rewardEnable = false
            end
        end
        
        if not rewardEnable then
            textRewardPercent:setVisible(false)
            imgIconReward:setVisible(false)
            textRankReward:setString('--')
            local textSize = textRankReward:getContentSize()
            panelReward:setContentSize(cc.size(textSize.width, 50))
            textRankReward:setPosition(cc.p(textSize.width / 2, 26))
        end

        if PeakRankModel:isRankTypeSupportDiffArea(self._rankType) then
            panelReward:setPositionX(530)
        else
            panelReward:setPositionX(580)
        end
    end
    return rankItem
end

function PeakRankCtrl:freshRankTotalValue(reset, directSet)
    local totalValue = PeakRankModel:getRankTotalValue(self._rankType, self._dayType, self._areaType)

    if reset then
        self._rollingNumber:setTo(0)
    end

    if self._rankType == PeakRankDef.PeakRankRankType.GainTotal
        and (self._dayType == PeakRankDef.PeakRankDayType.Total 
        or self._dayType == PeakRankDef.PeakRankDayType.Today) then

        if directSet then
            self._rollingNumber:setTo(totalValue)
            my.scheduleOnce(function()
                PeakRankModel:reqPeakRankTotalValue(self._rankType, self._dayType, self._areaType)
            end, 1)
        else
            local curValue = self._rollingNumber:getNumber()
            if curValue >= totalValue then
                my.scheduleOnce(function()
                    PeakRankModel:reqPeakRankTotalValue(self._rankType, self._dayType, self._areaType)
                end, 4)
            else
                self._rollingNumber:rollingTo(totalValue, 4, 3, function()
                    if self._rankType == PeakRankDef.PeakRankRankType.GainTotal
                        and (self._dayType == PeakRankDef.PeakRankDayType.Total 
                        or self._dayType == PeakRankDef.PeakRankDayType.Today) then

                        -- my.scheduleOnce(function()
                            PeakRankModel:reqPeakRankTotalValue(self._rankType, self._dayType, self._areaType)
                        -- end, 0)

                    end
                end)
            end
        end
    else
        self._rollingNumber:setTo(totalValue)
    end
end

function PeakRankCtrl:freshRankTotalValueTip()
    local exchangeRatio, rewardType = PeakRankModel:getRankExchangeRatioAndRewardType(self._rankType, self._dayType, self._areaType)
    if exchangeRatio and rewardType then
        -- 没增加N万两增加1礼券/银子
        local tipString = string.format('每增加%d两增加1', exchangeRatio)
        if rewardType == 1 then
            -- 银子
            tipString = tipString .. '两银子'
        elseif rewardType == 2 then
            tipString = tipString .. '张礼券'
        end
        self._viewNode.textTotalRewardTip:setString(tipString)
    end
end

function PeakRankCtrl:freshRankDate()
    local startDate = PeakRankModel:getRoundStartDate()
    local endDate = PeakRankModel:getRoundEndDate()
    local startYear = math.floor(startDate / 10000)
    local startMonth = math.floor( startDate / 100 % 100)
    local startDay = math.floor(startDate % 100)
    local endYear = math.floor(endDate / 10000)
    local endMonth = math.floor( endDate / 100 % 100)
    local endDay = math.floor(endDate % 100)
    local dateString = string.format('%d.%02d.%02d-%d.%02d.%02d', startYear, startMonth, startDay, endYear, endMonth, endDay)
    self._viewNode.textRankDate:setString(dateString)
end

function PeakRankCtrl:startLoading()
    self:stopLoading()
    self._viewNode.textNoData:setVisible(false)
    self._viewNode.panelLoading:setVisible(true)
    self._viewNode.imgLoading:runAction(cc.RepeatForever:create(cc.RotateBy:create(0.7, 360)))
    self._loadingTimer = my.createOnceSchedule(function()
        self:stopLoading()
        self._viewNode.listViewRank:removeAllChildren()
        self._viewNode.textNoData:setVisible(true)
        -- 五秒还没请求回来，显示“暂无数据”
    end, 5)
end

function PeakRankCtrl:stopLoading()
    if self._loadingTimer then
        my.removeSchedule(self._loadingTimer)
        self._loadingTimer = nil
    end
    if self._viewNode and not tolua.isnull(self._viewNode:getRealNode()) then
        self._viewNode.imgLoading:stopAllActions()
        self._viewNode.panelLoading:setVisible(false)
    end
end

function PeakRankCtrl:removeEventListeners()
    PeakRankModel:removeEventListenersByTag(self:getEventTag())
    MyTimeStamp:removeEventListenersByTag(self:getEventTag())
end

function PeakRankCtrl:removeSchedules()
    if self._timer then
        my.removeSchedule(self._timer)
        self._timer = nil
    end

    if self._loadingTimer then
        my.removeSchedule(self._loadingTimer)
        self._loadingTimer = nil
    end
end

function PeakRankCtrl:onExit(...)
    self:removeSchedules()
    self:removeEventListeners()
    PeakRankModel:clearLastQueryTime()
    PeakRankCtrl.super.onExit(self)
end

return PeakRankCtrl