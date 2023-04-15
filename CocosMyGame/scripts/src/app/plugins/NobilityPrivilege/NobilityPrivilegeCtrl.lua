local NobilityPrivilegeCtrl = class("NobilityPrivilegeCtrl", cc.load('BaseCtrl'))
local NobilityPrivilegeView = import('src.app.plugins.NobilityPrivilege.NobilityPrivilegeView')
local NobilityPrivilegeModel      = import("src.app.plugins.NobilityPrivilege.NobilityPrivilegeModel"):getInstance()
local NobilityPrivilegeDef        = import('src.app.plugins.NobilityPrivilege.NobilityPrivilegeDef')
local CenterCtrl = require('src.app.BaseModule.CenterCtrl'):getInstance()
local PluginProcessModel = mymodel('hallext.PluginProcessModel'):getInstance()
local NobilityPrivilegeGiftModel      = import("src.app.plugins.NobilityPrivilegeGift.NobilityPrivilegeGiftModel"):getInstance()
local Def               = import("src.app.plugins.RewardTip.RewardTipDef")

local itemPoolLeft = {} --左侧的itemPool
local itemPoolRight = {}

function NobilityPrivilegeCtrl:onCreate()
	local viewNode = self:setViewIndexer(NobilityPrivilegeView:createViewIndexer())
    self._viewNode = viewNode

    if self._TipConten == nil then
        local FileNameString = "src/app/plugins/NobilityPrivilege/NobilityPrivilege.json"
        local content = cc.FileUtils:getInstance():getStringFromFile(FileNameString)
        self._TipConten = cc.load("json").json.decode(content)
    end

    self:initialListenTo()
    self:initialBtnClick()
    self:updateUI()
    NobilityPrivilegeModel:gc_GetNobilityPrivilegeInfo()

    if NobilityPrivilegeGiftModel:isNeedPop() then
        my.scheduleOnce(function()
            my.informPluginByName({pluginName = 'MemberTransferCtrl'})
        end,1.0)
    end
end

function NobilityPrivilegeCtrl:initialListenTo( )
    self:listenTo(NobilityPrivilegeModel, NobilityPrivilegeDef.NobilityPrivilegeInfoRet, handler(self,self.updateUI))
end

function NobilityPrivilegeCtrl:initialBtnClick( )
    local viewNode = self._viewNode
    viewNode.closeBtn:addClickEventListener(handler(self, self.onClickClose))
    viewNode.BtnShop:addClickEventListener(handler(self, self.onClickBtnShop))   --前往商城按钮
    viewNode.BtnUpgradeTake:addClickEventListener(handler(self, self.onClickBtnUpgradeLevel))   --升级领取按钮
    viewNode.BtnLeft:addClickEventListener(handler(self, self.onClickBtnLeft))   --向左看贵族按钮
    viewNode.BtnRight:addClickEventListener(handler(self, self.onClickBtnRight))   --向右看贵族按钮
    viewNode.BtnDayGift:addClickEventListener(handler(self, self.onClickBtnDayGift))   --每日礼包按钮
    viewNode.BtnWeekGift:addClickEventListener(handler(self, self.onClickBtnWeekGift))   --每周礼包按钮
    viewNode.BtnMonthGift:addClickEventListener(handler(self, self.onClickBtnMonthGift))   --每月礼包按钮
    viewNode.PanelAnimation:getChildByName("Panel_DayGiftDetail"):setVisible(false)
    viewNode.PanelAnimation:getChildByName("Panel_WeeklyGiftDetail"):setVisible(false)
    viewNode.PanelAnimation:getChildByName("Panel_MonthGiftDetail"):setVisible(false)
    viewNode.PanelAnimation:getChildByName("Panel_UpgradeGiftDetail"):setVisible(false)

    viewNode.BtnDayGift:onTouch(function(e)
        self:freshDayGiftItem(e.name)
    end)

    viewNode.BtnWeekGift:onTouch(function(e)
        self:freshWeekGiftItem(e.name)
    end)

    viewNode.BtnMonthGift:onTouch(function(e)
        self:freshMonthGiftItem(e.name)
    end)

    viewNode.BtnUpgradeGift:onTouch(function(e)
        self:freshUpgradeGiftItem(e.name)
    end)
end

function NobilityPrivilegeCtrl:freshWeekGiftItem(event)
    if not CenterCtrl:checkNetStatus() then
        self:goBack()
        return
    end
    
    local viewNode = self._viewNode
    local NodeDetail = viewNode.PanelAnimation:getChildByName("Panel_WeeklyGiftDetail")
    local nobilityPrivilegeInfo = NobilityPrivilegeModel:GetNobilityPrivilegeInfo()
    local nobilityPrivilegeConfig = NobilityPrivilegeModel:GetNobilityPrivilegeConfig()
    if not nobilityPrivilegeInfo or not nobilityPrivilegeConfig then
        NobilityPrivilegeModel:gc_GetNobilityPrivilegeInfo()
        return
    end

   --触摸弹出预览
    if nobilityPrivilegeInfo.weekGiftBagStatus == NobilityPrivilegeDef.NOBILITY_PRIVILEGE_UNLOCK_NEW then 
        if event == 'began' then
            NodeDetail:setVisible(true)
            local nLevel = 0
            local  nPrivilegeLevelList= nobilityPrivilegeConfig.nobilityLevelList
            for i=#nPrivilegeLevelList,1 ,-1 do
                local nWeekGiftBagDetail = nPrivilegeLevelList[i].weekGiftBagDetail
                if #nWeekGiftBagDetail > 0 then
                     nLevel = i
                end
            end
            local rewardList = {}
            if not nobilityPrivilegeConfig.nobilityLevelList[nLevel] then return end 
            local  nWeekGiftBagDetail= nobilityPrivilegeConfig.nobilityLevelList[nLevel].weekGiftBagDetail
            for i=1,#nWeekGiftBagDetail do
                for u, v in pairs(nobilityPrivilegeConfig.weekGiftBagList) do
                    if nWeekGiftBagDetail[i].weekGiftBagID == v.rewardID then
                        table.insert(rewardList,{nType = v.rewardType,nCount = v.rewardCount})
                    end
                end
            end
            self:freshGiftDetail(NodeDetail,rewardList)
        elseif event == 'cancelled' then
            NodeDetail:setVisible(false)
        elseif event == 'ended' then
            NodeDetail:setVisible(false)
        end
    else --触摸弹出预览
        if event == 'began' then
            NodeDetail:setVisible(true)
            local rewardList = {}
            if not nobilityPrivilegeConfig.nobilityLevelList[nobilityPrivilegeInfo.level+1] then return end 
            local  nWeekGiftBagDetail= nobilityPrivilegeConfig.nobilityLevelList[nobilityPrivilegeInfo.level+1].weekGiftBagDetail
            for i=1,#nWeekGiftBagDetail do
                for u, v in pairs(nobilityPrivilegeConfig.weekGiftBagList) do
                    if nWeekGiftBagDetail[i].weekGiftBagID == v.rewardID then
                        table.insert(rewardList,{nType = v.rewardType,nCount = v.rewardCount})
                    end
                end
            end
            self:freshGiftDetail(NodeDetail,rewardList)
        elseif event == 'cancelled' then
            NodeDetail:setVisible(false)
        elseif event == 'ended' then
            NodeDetail:setVisible(false)
        end
    end
end

function NobilityPrivilegeCtrl:freshMonthGiftItem(event)
    if not CenterCtrl:checkNetStatus() then
        self:goBack()
        return
    end
    
    local viewNode = self._viewNode
    local NodeDetail = viewNode.PanelAnimation:getChildByName("Panel_MonthGiftDetail")
    local nobilityPrivilegeInfo = NobilityPrivilegeModel:GetNobilityPrivilegeInfo()
    local nobilityPrivilegeConfig = NobilityPrivilegeModel:GetNobilityPrivilegeConfig()
    if not nobilityPrivilegeInfo or not nobilityPrivilegeConfig then
        NobilityPrivilegeModel:gc_GetNobilityPrivilegeInfo()
        return
    end

   --触摸弹出预览
    if nobilityPrivilegeInfo.monthGiftBagStatus == NobilityPrivilegeDef.NOBILITY_PRIVILEGE_UNLOCK_NEW then 
        if event == 'began' then
            NodeDetail:setVisible(true)
            local nLevel = 0
            local  nPrivilegeLevelList= nobilityPrivilegeConfig.nobilityLevelList
            for i=#nPrivilegeLevelList,1 ,-1 do
                local nMonthGiftBagDetail = nPrivilegeLevelList[i].monthGiftBagDetail
                if #nMonthGiftBagDetail > 0 then
                     nLevel = i
                end
            end
            local rewardList = {}
            if not nobilityPrivilegeConfig.nobilityLevelList[nLevel] then return end 
            local  nMonthGiftBagDetail= nobilityPrivilegeConfig.nobilityLevelList[nLevel].monthGiftBagDetail
            for i=1,#nMonthGiftBagDetail do
                for u, v in pairs(nobilityPrivilegeConfig.monthGiftBagList) do
                    if nMonthGiftBagDetail[i].monthGiftBagID == v.rewardID then
                        table.insert(rewardList,{nType = v.rewardType,nCount = v.rewardCount})
                    end
                end
            end
            self:freshGiftDetail(NodeDetail,rewardList)
        elseif event == 'cancelled' then
            NodeDetail:setVisible(false)
        elseif event == 'ended' then
            NodeDetail:setVisible(false)
        end
    else --触摸弹出预览
        if event == 'began' then
            NodeDetail:setVisible(true)
            local rewardList = {}
            if not nobilityPrivilegeConfig.nobilityLevelList[nobilityPrivilegeInfo.level+1] then return end 
            local  nMonthGiftBagDetail= nobilityPrivilegeConfig.nobilityLevelList[nobilityPrivilegeInfo.level+1].monthGiftBagDetail
            for i=1,#nMonthGiftBagDetail do
                for u, v in pairs(nobilityPrivilegeConfig.monthGiftBagList) do
                    if nMonthGiftBagDetail[i].monthGiftBagID == v.rewardID then
                        table.insert(rewardList,{nType = v.rewardType,nCount = v.rewardCount})
                    end
                end
            end
            self:freshGiftDetail(NodeDetail,rewardList)
        elseif event == 'cancelled' then
            NodeDetail:setVisible(false)
        elseif event == 'ended' then
            NodeDetail:setVisible(false)
        end
    end
end

function NobilityPrivilegeCtrl:freshUpgradeGiftItem(event)
    if not CenterCtrl:checkNetStatus() then
        self:goBack()
        return
    end
    
    local viewNode = self._viewNode
    local NodeDetail = viewNode.PanelAnimation:getChildByName("Panel_UpgradeGiftDetail")
    local nobilityPrivilegeInfo = NobilityPrivilegeModel:GetNobilityPrivilegeInfo()
    local nobilityPrivilegeConfig = NobilityPrivilegeModel:GetNobilityPrivilegeConfig()
    if not nobilityPrivilegeInfo or not nobilityPrivilegeConfig then
        NobilityPrivilegeModel:gc_GetNobilityPrivilegeInfo()
        return
    end

   --触摸弹出预览
    if event == 'began' then
        NodeDetail:setVisible(true)
            --升级礼包
        local nTakeStatus = false
        local nRewardLevel = 0 
        for i = #nobilityPrivilegeInfo.upgradeGiftBagStatus,1,-1 do
            if nobilityPrivilegeInfo.upgradeGiftBagStatus[i] == NobilityPrivilegeDef.NOBILITY_PRIVILEGE_UNTAKE then
                nTakeStatus = true
                nRewardLevel = i
            end
        end
        if not nTakeStatus then
            nRewardLevel = nobilityPrivilegeInfo.level + 2
        end
    
        --已满级
        if nRewardLevel >= #nobilityPrivilegeConfig.nobilityLevelList  then
            nRewardLevel = #nobilityPrivilegeConfig.nobilityLevelList
        end

        --触摸弹出预览
        local rewardList = {}
        if not nobilityPrivilegeConfig.nobilityLevelList[nRewardLevel] then return end 
        local  nUpgradeGiftBagDetail= nobilityPrivilegeConfig.nobilityLevelList[nRewardLevel].upgradeGiftBagDetail
        for i=1,#nUpgradeGiftBagDetail do
            for u, v in pairs(nobilityPrivilegeConfig.upgradeGiftBagList) do
                if nUpgradeGiftBagDetail[i].upgradeGiftBagID == v.rewardID then
                    table.insert( rewardList,{nType = v.rewardType,nCount = v.rewardCount})
                end
            end
        end
        self:freshGiftDetail(NodeDetail,rewardList)
    elseif event == 'cancelled' then
        NodeDetail:setVisible(false)
    elseif event == 'ended' then
        NodeDetail:setVisible(false)
    end
end

function NobilityPrivilegeCtrl:freshDayGiftItem(event)
    if not CenterCtrl:checkNetStatus() then
        self:goBack()
        return
    end
    
    local viewNode = self._viewNode
    local NodeDetail = viewNode.PanelAnimation:getChildByName("Panel_DayGiftDetail")
    local nobilityPrivilegeInfo = NobilityPrivilegeModel:GetNobilityPrivilegeInfo()
    local nobilityPrivilegeConfig = NobilityPrivilegeModel:GetNobilityPrivilegeConfig()
    if not nobilityPrivilegeInfo or not nobilityPrivilegeConfig then
        NobilityPrivilegeModel:gc_GetNobilityPrivilegeInfo()
        return
    end
    if nobilityPrivilegeInfo.dailyGiftBagStatus == NobilityPrivilegeDef.NOBILITY_PRIVILEGE_UNLOCK then 
        if event == 'began' then
            NodeDetail:setVisible(true)
            local nLevel = 0
            local  nPrivilegeLevelList= nobilityPrivilegeConfig.nobilityLevelList
            for i=#nPrivilegeLevelList,1 ,-1 do
                local nDailyGiftBagDetail = nPrivilegeLevelList[i].dailyGiftBagDetail
                if #nDailyGiftBagDetail > 0 then
                     nLevel = i
                end
            end
            local rewardList = {}
            if not nobilityPrivilegeConfig.nobilityLevelList[nLevel] then return end 
            local  nDailyGiftBagDetail= nobilityPrivilegeConfig.nobilityLevelList[nLevel].dailyGiftBagDetail
            for i=1,#nDailyGiftBagDetail do
                for u, v in pairs(nobilityPrivilegeConfig.dailyGiftBagList) do
                    if nDailyGiftBagDetail[i].dailyGiftBagID == v.rewardID then
                        table.insert(rewardList,{nType = v.rewardType,nCount = v.rewardCount})
                    end
                end
            end
            self:freshGiftDetail(NodeDetail,rewardList)
        elseif event == 'cancelled' then
            NodeDetail:setVisible(false)
        elseif event == 'ended' then
            NodeDetail:setVisible(false)
        end
    else --触摸弹出预览
        if event == 'began' then
            NodeDetail:setVisible(true)
            local rewardList = {}
            if not nobilityPrivilegeConfig.nobilityLevelList[nobilityPrivilegeInfo.level+1] then return end 
            local  nDailyGiftBagDetail= nobilityPrivilegeConfig.nobilityLevelList[nobilityPrivilegeInfo.level+1].dailyGiftBagDetail
            for i=1,#nDailyGiftBagDetail do
                for u, v in pairs(nobilityPrivilegeConfig.dailyGiftBagList) do
                    if nDailyGiftBagDetail[i].dailyGiftBagID == v.rewardID then
                        table.insert(rewardList,{nType = v.rewardType,nCount = v.rewardCount})
                    end
                end
            end
            self:freshGiftDetail(NodeDetail,rewardList)
        elseif event == 'cancelled' then
            NodeDetail:setVisible(false)
        elseif event == 'ended' then
            NodeDetail:setVisible(false)
        end
    end
end

function NobilityPrivilegeCtrl:freshGiftDetail(NodeDetail,rewardList)
     local viewNode = self._viewNode
    if type(rewardList)~='table' then return end
    local index = 1
    local function showNodeItem()
        local itemCount = #rewardList
        local item = rewardList[index]
        local imgPath = self:GetItemFilePath(item)
        local node = NodeDetail:getChildByName("Node_"..index)
        node:getChildByName("Panel_Main"):getChildByName("Img_Item"):loadTexture(imgPath, ccui.TextureResType.plistType)
        node:getChildByName("Panel_Main"):getChildByName("Fnt_Num"):setString(item.nCount)

        node:getChildByName("Panel_Main"):getChildByName("Image_1"):setVisible(false)

        local aniNode = node:getChildByName("Panel_Main"):getChildByName("Ani_Effect")
        aniNode:stopAllActions()
        aniNode:setVisible(false)
        index = index + 1
    end

    local itemCount = #rewardList
    if itemCount == 0 then return end
    for i = 1, itemCount do
        showNodeItem()
    end

    for i = 2, 5 do
        NodeDetail:getChildByName("Sprite_SepLine"..(i - 1)):setVisible(true)
        NodeDetail:getChildByName("Node_"..i):setVisible(true)
    end

    if itemCount + 1 <= 5 then
        for i = itemCount + 1, 5 do
            NodeDetail:getChildByName("Sprite_SepLine"..(i - 1)):setVisible(false)
            NodeDetail:getChildByName("Node_"..i):setVisible(false)
        end
    end
    local newBkWidth = 600 - 120 * (5 - itemCount)
    if itemCount == 1 then
        newBkWidth = 127
    end
    NodeDetail:getChildByName("Image_Bk"):setContentSize(cc.size(newBkWidth, 136))
end

function NobilityPrivilegeCtrl:GetItemFilePath(item)
    local dir = "hallcocosstudio/images/plist/RewardCtrl/"
    local path = nil

    local nType = item.nType
    local nCount = item.nCount

    if nType == Def.TYPE_SILVER then --银子
        if nCount>=10000 then 
            path = dir .. "Img_Silver4.png"
        elseif nCount>=5000 then
            path = dir .. "Img_Silver3.png"
        elseif nCount>=1000 then
            path = dir .. "Img_Silver2.png"
        else
            path = dir .. "Img_Silver1.png"
        end
    elseif nType == Def.TYPE_TICKET then --礼券
        if nCount>=100 then 
            path = dir .. "Img_Ticket4.png"
        elseif nCount>=50 then
            path = dir .. "Img_Ticket3.png"
        elseif nCount>=20 then
            path = dir .. "Img_Ticket2.png"
        else
            path = dir .. "Img_Ticket1.png"
        end
    elseif nType == Def.TYPE_CARDMARKER_1D then --1d记牌器
        path = dir .. "1tian.png"
    elseif nType == Def.TYPE_CARDMARKER_7D then --7d记牌器
        path = dir .. "7tian.png"
    elseif nType == Def.TYPE_CARDMARKER_30D then --30d记牌器
        path = dir .. "30tian.png"
    elseif nType == Def.TYPE_ROSE then --玫瑰
        path = dir .. "Img_Rose.png"
    elseif nType == Def.TYPE_LIGHTING then --闪电
        path = dir .. "Img_Lighting.png"
    elseif nType == Def.TYPE_CARDMARKER then
        path = dir .. "Img_CardMarker.png"
    elseif nType == Def.TYPE_PROP_LIANSHENG then
        path = dir .. "Img_Prop_Liansheng.png"
    elseif nType == Def.TYPE_PROP_JIACHENG then
        path = dir .. "Img_Prop_Jiacheng.png"
    elseif nType == Def.TYPE_PROP_BAOXIAN then
        path = dir .. "Img_Prop_Baoxian.png"
    elseif nType == Def.TYPE_RED_PACKET then --红包
        path = dir .. "Img_RedPacket_100.png"
    elseif nType == Def.TYPE_RED_PACKET_VOCHER then --红包礼券
        path = dir .. "Img_RedPacket_Vocher.png"
    elseif nType == Def.TYPE_REWARDTYPE_LOTTERY_TIME then --惊喜夺宝
        path = dir .. "Img_RewardType_Lottery.png"
    end
    return path
end

function NobilityPrivilegeCtrl:freshScrollView2(nLevel)
    local viewNode = self._viewNode
    if not viewNode then return end

    local nobilityPrivilegeInfo = NobilityPrivilegeModel:GetNobilityPrivilegeInfo()
    local nobilityPrivilegeConfig = NobilityPrivilegeModel:GetNobilityPrivilegeConfig()
    if not nobilityPrivilegeInfo or not nobilityPrivilegeConfig then
        NobilityPrivilegeModel:gc_GetNobilityPrivilegeInfo()
        return
    end

    viewNode.BtnLeft:setVisible(true)
    if nLevel <= 0 then
        nLevel = 0
        viewNode.BtnLeft:setVisible(false)
    end

    viewNode.BtnRight:setVisible(true)
    if nLevel >= #nobilityPrivilegeConfig.nobilityLevelList - 2 then  --读取配置
        nLevel = #nobilityPrivilegeConfig.nobilityLevelList - 2
        viewNode.BtnRight:setVisible(false)
    end

    self._nLevel = nLevel
    viewNode.PanelNobilityInfo:getChildByName("Fnt_Level"):setString("贵族"..nLevel)
    viewNode.PanelNobilityInfo:getChildByName("Text_Privilege"):setVisible(false)
    if nLevel == nobilityPrivilegeInfo.level then
        viewNode.PanelNobilityInfo:getChildByName("Text_Privilege"):setVisible(true)
    end
    viewNode.PanelNobilityInfoNext:getChildByName("Fnt_Level"):setString("贵族"..nLevel+1)
    viewNode.PanelNobilityInfoNext:getChildByName("Text_Privilege"):setVisible(false)
     if (nLevel+1) == nobilityPrivilegeInfo.level then
        viewNode.PanelNobilityInfoNext:getChildByName("Text_Privilege"):setVisible(true)
    end

    local  nPrivilegeDetail= nobilityPrivilegeConfig.nobilityLevelList[nLevel+1].privilegeDetail
    local  nPrivilegeDetailNext= nobilityPrivilegeConfig.nobilityLevelList[nLevel+2].privilegeDetail

    --策划需求，右边比左边多的是新，有的level高的是升级
    for i=1,#nPrivilegeDetailNext do
        local nPrivilegeIDNext = nPrivilegeDetailNext[i].privilegeID
        for u, v in pairs(nobilityPrivilegeConfig.privilegeList) do
            if nPrivilegeIDNext == v.privilegeID then
                local status = false
                for j=1,#nPrivilegeDetail do
                    local nPrivilegeID = nPrivilegeDetail[j].privilegeID
                    for x, y in pairs(nobilityPrivilegeConfig.privilegeList) do
                        if nPrivilegeID == y.privilegeID then
                            if v.privilegeType == y.privilegeType and v.privilegeLevel > y.privilegeLevel then
                                v.showIcon = 3
                                status = true
                            elseif v.privilegeType == y.privilegeType and v.privilegeLevel <= y.privilegeLevel then
                                v.showIcon = 1
                                status = true
                            end
                        end
                    end
                end
                if not status then
                    v.showIcon = 2
                end
            end
        end
    end
    local nPrivilegeCount = #nPrivilegeDetail
    if nPrivilegeCount < 5 then
        viewNode.ScrollInfo:setInnerContainerSize(cc.size(400, 190))
    else
        viewNode.ScrollInfo:setInnerContainerSize(cc.size(400, 40*nPrivilegeCount+30))
    end

    viewNode.ScrollInfo:removeAllChildren()
    for i=1,#nPrivilegeDetail do
        local nodeItem = cc.CSLoader:createNode(NobilityPrivilegeView.PATH_NODE_NOBILITYPRIVILEGEITEM)
        local nodeAward = nodeItem:getChildByName("Panel_Item")
        nodeAward:retain()
        nodeAward:removeFromParent()
        self:scriptAwardItem(nodeAward,i,nPrivilegeDetail[i],false)
        if nPrivilegeCount < 5 then
            nodeAward:setPosition(cc.p(200,200-40 * i))
        else
            nodeAward:setPosition(cc.p(200,40 *(nPrivilegeCount+1-i)))
        end
        viewNode.ScrollInfo:addChild(nodeAward)
        nodeAward:release()
    end

    local nPrivilegeCountNext = #nPrivilegeDetailNext
    if nPrivilegeCountNext < 5 then
        viewNode.ScrollInfoNext:setInnerContainerSize(cc.size(400, 190))
    else
        viewNode.ScrollInfoNext:setInnerContainerSize(cc.size(400, 40*nPrivilegeCountNext+30))
    end

    viewNode.ScrollInfoNext:removeAllChildren()
    for i=1,#nPrivilegeDetailNext do
        local nodeItem = cc.CSLoader:createNode(NobilityPrivilegeView.PATH_NODE_NOBILITYPRIVILEGEITEM)
        local nodeAward = nodeItem:getChildByName("Panel_Item")
        nodeAward:retain()
        nodeAward:removeFromParent()
        self:scriptAwardItem(nodeAward,i,nPrivilegeDetailNext[i],true)
        if nPrivilegeCountNext < 5 then
            nodeAward:setPosition(cc.p(200,200-40 * i))
        else
            nodeAward:setPosition(cc.p(200,40 *(nPrivilegeCountNext+1-i)))
        end
        viewNode.ScrollInfoNext:addChild(nodeAward)
        nodeAward:release()
    end
end

function NobilityPrivilegeCtrl:getNeedShownPrivilegeCount(nobilityPrivilegeConfig, nPrivilegeDetails)
    local count = #nPrivilegeDetails
    for i = 1, #nPrivilegeDetails do
        local nPrivilegeDetail = nPrivilegeDetails[i]
        local nPrivilegeID = nPrivilegeDetail.privilegeID
        for u, v in pairs(nobilityPrivilegeConfig.privilegeList) do
            if nPrivilegeID == v.privilegeID then
                if v.privilegeType == 15 and not cc.exports.isAutoSupplySupported() then --自动存取银开关
                    count = count - 1
                end
            end
        end
    end
    return count
end

function NobilityPrivilegeCtrl:isNeedShownPrivilege(nobilityPrivilegeConfig, nPrivilegeDetail)
    local bNeed = true
    local nPrivilegeID = nPrivilegeDetail.privilegeID
    for u, v in pairs(nobilityPrivilegeConfig.privilegeList) do
        if nPrivilegeID == v.privilegeID then
            if v.privilegeType == 15 and not cc.exports.isAutoSupplySupported() then --自动存取银开关
                bNeed = false
            end
        end
    end
    return bNeed
end

function NobilityPrivilegeCtrl:freshScrollView(nLevel)
    local viewNode = self._viewNode
    if not viewNode then return end

    local nobilityPrivilegeInfo = NobilityPrivilegeModel:GetNobilityPrivilegeInfo()
    local nobilityPrivilegeConfig = NobilityPrivilegeModel:GetNobilityPrivilegeConfig()
    if not nobilityPrivilegeInfo or not nobilityPrivilegeConfig then
        NobilityPrivilegeModel:gc_GetNobilityPrivilegeInfo()
        return
    end

    viewNode.BtnLeft:setVisible(true)
    if nLevel <= 0 then
        nLevel = 0
        viewNode.BtnLeft:setVisible(false)
    end

    viewNode.BtnRight:setVisible(true)
    if nLevel >= #nobilityPrivilegeConfig.nobilityLevelList - 2 then  --读取配置
        nLevel = #nobilityPrivilegeConfig.nobilityLevelList - 2
        viewNode.BtnRight:setVisible(false)
    end

    self._nLevel = nLevel
    viewNode.PanelNobilityInfo:getChildByName("Fnt_Level"):setString("贵族"..nLevel)
    viewNode.PanelNobilityInfo:getChildByName("Text_Privilege"):setVisible(false)
    if nLevel == nobilityPrivilegeInfo.level then
        viewNode.PanelNobilityInfo:getChildByName("Text_Privilege"):setVisible(true)
    end
    viewNode.PanelNobilityInfoNext:getChildByName("Fnt_Level"):setString("贵族"..nLevel+1)
    viewNode.PanelNobilityInfoNext:getChildByName("Text_Privilege"):setVisible(false)
     if (nLevel+1) == nobilityPrivilegeInfo.level then
        viewNode.PanelNobilityInfoNext:getChildByName("Text_Privilege"):setVisible(true)
    end

    local  nPrivilegeDetail= nobilityPrivilegeConfig.nobilityLevelList[nLevel+1].privilegeDetail
    local  nPrivilegeDetailNext= nobilityPrivilegeConfig.nobilityLevelList[nLevel+2].privilegeDetail

    --策划需求，右边比左边多的是新，有的level高的是升级
    for i=1,#nPrivilegeDetailNext do
        local nPrivilegeIDNext = nPrivilegeDetailNext[i].privilegeID
        for u, v in pairs(nobilityPrivilegeConfig.privilegeList) do
            if nPrivilegeIDNext == v.privilegeID then
                local status = false
                for j=1,#nPrivilegeDetail do
                    local nPrivilegeID = nPrivilegeDetail[j].privilegeID
                    for x, y in pairs(nobilityPrivilegeConfig.privilegeList) do
                        if nPrivilegeID == y.privilegeID then
                            if v.privilegeType == y.privilegeType and v.privilegeLevel > y.privilegeLevel then
                                v.showIcon = 3
                                status = true
                            elseif v.privilegeType == y.privilegeType and v.privilegeLevel <= y.privilegeLevel then
                                v.showIcon = 1
                                status = true
                            end
                        end
                    end
                end
                if not status then
                    v.showIcon = 2
                end
            end
        end
    end
    local nPrivilegeCount = self:getNeedShownPrivilegeCount(nobilityPrivilegeConfig, nPrivilegeDetail)
    if nPrivilegeCount < 5 then
        viewNode.ScrollInfo:setInnerContainerSize(cc.size(400, 190))
    else
        viewNode.ScrollInfo:setInnerContainerSize(cc.size(400, 40*nPrivilegeCount+30))
    end

    viewNode.ScrollInfo:removeAllChildren()

    if #itemPoolLeft < #nPrivilegeDetail then
        for i=#itemPoolLeft, #nPrivilegeDetail do
            local nodeItem = cc.CSLoader:createNode(NobilityPrivilegeView.PATH_NODE_NOBILITYPRIVILEGEITEM)
            local nodeAward = nodeItem:getChildByName("Panel_Item")
            nodeAward:retain()
            nodeAward:removeFromParent()
            table.insert(itemPoolLeft, nodeAward)
            --nodeAward:release()
        end
    end

    local index = 1
    for i=1,#nPrivilegeDetail do
        if self:isNeedShownPrivilege(nobilityPrivilegeConfig, nPrivilegeDetail[i]) then
            local nodeAward = itemPoolLeft[index]
            self:scriptAwardItem(nodeAward,index,nPrivilegeDetail[i],false)
            if nPrivilegeCount < 5 then
                nodeAward:setPosition(cc.p(200,200-40 * index))
            else
                nodeAward:setPosition(cc.p(200,40 *(nPrivilegeCount+1-index)))
            end
            index = index + 1
            viewNode.ScrollInfo:addChild(nodeAward)
        end
    end

    local nPrivilegeCountNext = self:getNeedShownPrivilegeCount(nobilityPrivilegeConfig, nPrivilegeDetailNext)
    if nPrivilegeCountNext < 5 then
        viewNode.ScrollInfoNext:setInnerContainerSize(cc.size(400, 190))
    else
        viewNode.ScrollInfoNext:setInnerContainerSize(cc.size(400, 40*nPrivilegeCountNext+30))
    end

    viewNode.ScrollInfoNext:removeAllChildren()
    if #itemPoolRight < #nPrivilegeDetailNext then
        for i=#itemPoolRight, #nPrivilegeDetailNext do
            local nodeItem = cc.CSLoader:createNode(NobilityPrivilegeView.PATH_NODE_NOBILITYPRIVILEGEITEM)
            local nodeAward = nodeItem:getChildByName("Panel_Item")
            nodeAward:retain()
            nodeAward:removeFromParent()
            table.insert(itemPoolRight, nodeAward)
            --nodeAward:release()
        end
    end
    local indexNext = 1
    for i=1,#nPrivilegeDetailNext do
        if self:isNeedShownPrivilege(nobilityPrivilegeConfig, nPrivilegeDetailNext[i]) then
            local nodeAward = itemPoolRight[i]
            self:scriptAwardItem(nodeAward,indexNext,nPrivilegeDetailNext[i],true)
            if nPrivilegeCountNext < 5 then
                nodeAward:setPosition(cc.p(200,200-40 * indexNext))
            else
                nodeAward:setPosition(cc.p(200,40 *(nPrivilegeCountNext+1-indexNext)))
            end
            indexNext = indexNext + 1
            viewNode.ScrollInfoNext:addChild(nodeAward)
        end
    end
end

function NobilityPrivilegeCtrl:scriptAwardItem(nodeAward, nIndex, nPrivilegeDetail,iconStatus)
    local nobilityPrivilegeInfo = NobilityPrivilegeModel:GetNobilityPrivilegeInfo()
    local nobilityPrivilegeConfig = NobilityPrivilegeModel:GetNobilityPrivilegeConfig()
    if not nobilityPrivilegeInfo or not nobilityPrivilegeConfig then
        NobilityPrivilegeModel:gc_GetNobilityPrivilegeInfo()
        return
    end

    if tolua.isnull(nodeAward) then return end

    local nPrivilegeID = nPrivilegeDetail.privilegeID
    for u, v in pairs(nobilityPrivilegeConfig.privilegeList) do
        if nPrivilegeID == v.privilegeID then
            --刷新特权信息
            local txtInfo = nodeAward:getChildByName("ListView_Info"):getChildByName("Text_Info")
            local strTip = ""
            if #v.showValue == 0 then
                strTip = string.format(self._TipConten["NOBILITY_PRIVILEGE_TIP"..v.privilegeType])
            elseif #v.showValue == 1 and v.showValue[1] then
                strTip = string.format(self._TipConten["NOBILITY_PRIVILEGE_TIP"..v.privilegeType],v.showValue[1])
            end

            if v.privilegeType == 15 then --自动存取银开关
                local name = cc.exports.isAutoSupplySaveSupported() and "自动存取银" or "自动取银"
                strTip = "开启" .. name
            end

            txtInfo:setString(nIndex.."."..strTip)

            local imgIcon = nodeAward:getChildByName("ListView_Info"):getChildByName("Image_Icon")
            imgIcon:ignoreContentAdaptWithSize(true)
            if not iconStatus then
                imgIcon:setVisible(false)
                return
            end
            if v.showIcon == 1 then
                imgIcon:setVisible(false)
            elseif v.showIcon == 2 then
                imgIcon:setVisible(true)
                imgIcon:loadTexture("hallcocosstudio/images/plist/NobilityPrivilege/NobilityPrivilege_new.png",ccui.TextureResType.plistType)
            elseif v.showIcon == 3 then
                imgIcon:setVisible(true)
                imgIcon:loadTexture("hallcocosstudio/images/plist/NobilityPrivilege/NobilityPrivilege_upgrade.png",ccui.TextureResType.plistType)
            end
        end
    end
end

function NobilityPrivilegeCtrl:freshLevelInfo()
    local viewNode = self._viewNode
    if not viewNode then return end 

    local nobilityPrivilegeInfo = NobilityPrivilegeModel:GetNobilityPrivilegeInfo()
    local nobilityPrivilegeConfig = NobilityPrivilegeModel:GetNobilityPrivilegeConfig()
    if not nobilityPrivilegeInfo or not nobilityPrivilegeConfig then
        NobilityPrivilegeModel:gc_GetNobilityPrivilegeInfo()
        return
    end

    local nLevel = nobilityPrivilegeInfo.level
    viewNode.FntLevel1:setString("贵族"..nLevel)
    viewNode.FntLevel2:setVisible(false)
    viewNode.FntLevel4:setVisible(false)

    --已经满级
    if nLevel >= #nobilityPrivilegeConfig.nobilityLevelList - 1 then
        viewNode.PanelAnimation:getChildByName("Text_Level_Tips"):setString(",您已到达最高贵族等级")
        viewNode.FntLevel4:setVisible(true)
        viewNode.FntLevel4:setString("已满级")
        local nExperienceTotal = nobilityPrivilegeConfig.nobilityLevelList[nLevel+1].experienceTotal
        viewNode.PanelAnimation:getChildByName("Text_Progress"):setString(nobilityPrivilegeInfo.rechargeTotal.."/"..nExperienceTotal)
        viewNode.PanelAnimation:getChildByName("Panel_Progress"):getChildByName("ProgressBar"):setPercent(100)
        return
    end
    --刷新经验进度条
    local nExperienceTotal = nobilityPrivilegeConfig.nobilityLevelList[nLevel+2].experienceTotal
    viewNode.PanelAnimation:getChildByName("Text_Progress"):setString(nobilityPrivilegeInfo.rechargeTotal.."/"..nExperienceTotal)
    viewNode.PanelAnimation:getChildByName("Panel_Progress"):getChildByName("ProgressBar"):setPercent(nobilityPrivilegeInfo.rechargeTotal/nExperienceTotal*100)
    viewNode.PanelAnimation:getChildByName("Text_Level_Tips"):setString(",再充值"..nExperienceTotal - nobilityPrivilegeInfo.rechargeTotal.."元即可升级")
end

function NobilityPrivilegeCtrl:freshGiftInfo()
    local viewNode = self._viewNode
    if not viewNode then return end 

    local nobilityPrivilegeInfo = NobilityPrivilegeModel:GetNobilityPrivilegeInfo()
    local nobilityPrivilegeConfig = NobilityPrivilegeModel:GetNobilityPrivilegeConfig()
    if not nobilityPrivilegeInfo or not nobilityPrivilegeConfig then
        NobilityPrivilegeModel:gc_GetNobilityPrivilegeInfo()
        return
    end

    --每日礼包
    local  nPrivilegeLevelList= nobilityPrivilegeConfig.nobilityLevelList
    for i=#nPrivilegeLevelList,1 ,-1 do
        local nDailyGiftBagDetail = nPrivilegeLevelList[i].dailyGiftBagDetail
        if #nDailyGiftBagDetail > 0 then
             viewNode.PanelDayGift:getChildByName("Text_Tip"):setString("贵族"..(i-1).."开启")
        end
    end

    if nobilityPrivilegeInfo.dailyGiftBagStatus == NobilityPrivilegeDef.NOBILITY_PRIVILEGE_UNLOCK then 
        viewNode.PanelDayGift:getChildByName("Image_Lock"):setVisible(true)
    elseif nobilityPrivilegeInfo.dailyGiftBagStatus == NobilityPrivilegeDef.NOBILITY_PRIVILEGE_UNTAKE then 
        viewNode.PanelDayGift:getChildByName("Image_Lock"):setVisible(false)
        viewNode.PanelDayGift:getChildByName("Text_Tip"):setString("可领取")
    elseif nobilityPrivilegeInfo.dailyGiftBagStatus == NobilityPrivilegeDef.NOBILITY_PRIVILEGE_TAKED then 
        viewNode.PanelDayGift:getChildByName("Image_Lock"):setVisible(false)
        viewNode.PanelDayGift:getChildByName("Text_Tip"):setString("已领取")
    end

    --每周礼包
    local  nPrivilegeLevelList= nobilityPrivilegeConfig.nobilityLevelList
    for i=#nPrivilegeLevelList,1 ,-1 do
        local nWeekGiftBagDetail = nPrivilegeLevelList[i].weekGiftBagDetail
        if #nWeekGiftBagDetail > 0 then
             viewNode.PanelWeeklyGift:getChildByName("Text_Tip"):setString("贵族"..(i-1).."开启")
        end
    end

    if nobilityPrivilegeInfo.weekGiftBagStatus == NobilityPrivilegeDef.NOBILITY_PRIVILEGE_UNLOCK_NEW then 
        viewNode.PanelWeeklyGift:getChildByName("Image_Lock"):setVisible(true)
    elseif nobilityPrivilegeInfo.weekGiftBagStatus == NobilityPrivilegeDef.NOBILITY_PRIVILEGE_UNTAKE_NEW then 
        viewNode.PanelWeeklyGift:getChildByName("Image_Lock"):setVisible(false)
        viewNode.PanelWeeklyGift:getChildByName("Text_Tip"):setString("可领取")
    elseif nobilityPrivilegeInfo.weekGiftBagStatus == NobilityPrivilegeDef.NOBILITY_PRIVILEGE_TAKED_NEW then 
        viewNode.PanelWeeklyGift:getChildByName("Image_Lock"):setVisible(false)
        viewNode.PanelWeeklyGift:getChildByName("Text_Tip"):setString("已领取")
    end

    --每月礼包
    local  nPrivilegeLevelList= nobilityPrivilegeConfig.nobilityLevelList
    for i=#nPrivilegeLevelList,1 ,-1 do
        local nMonthGiftBagDetail = nPrivilegeLevelList[i].monthGiftBagDetail
        if #nMonthGiftBagDetail > 0 then
             viewNode.PanelMonthGift:getChildByName("Text_Tip"):setString("贵族"..(i-1).."开启")
        end
    end

    if nobilityPrivilegeInfo.monthGiftBagStatus == NobilityPrivilegeDef.NOBILITY_PRIVILEGE_UNLOCK_NEW then 
        viewNode.PanelMonthGift:getChildByName("Image_Lock"):setVisible(true)
    elseif nobilityPrivilegeInfo.monthGiftBagStatus == NobilityPrivilegeDef.NOBILITY_PRIVILEGE_UNTAKE_NEW then 
        viewNode.PanelMonthGift:getChildByName("Image_Lock"):setVisible(false)
        viewNode.PanelMonthGift:getChildByName("Text_Tip"):setString("可领取")
    elseif nobilityPrivilegeInfo.monthGiftBagStatus == NobilityPrivilegeDef.NOBILITY_PRIVILEGE_TAKED_NEW then 
        viewNode.PanelMonthGift:getChildByName("Image_Lock"):setVisible(false)
        viewNode.PanelMonthGift:getChildByName("Text_Tip"):setString("已领取")
    end

    --升级礼包
    local nTakeStatus = false
    local nRewardLevel = 0 
    viewNode.BtnUpgradeTake:loadTextureNormal("hallcocosstudio/images/plist/NobilityPrivilege/NobilityPrivilege_upgradetake.png",ccui.TextureResType.plistType)
    viewNode.BtnUpgradeTake:loadTexturePressed("hallcocosstudio/images/plist/NobilityPrivilege/NobilityPrivilege_upgradetake.png",ccui.TextureResType.plistType)
    for i = #nobilityPrivilegeInfo.upgradeGiftBagStatus,1,-1 do
        if nobilityPrivilegeInfo.upgradeGiftBagStatus[i] == NobilityPrivilegeDef.NOBILITY_PRIVILEGE_UNTAKE then
            nTakeStatus = true
            nRewardLevel = i
            viewNode.BtnUpgradeTake:loadTextureNormal("hallcocosstudio/images/plist/NobilityPrivilege/NobilityPrivilege_upgradeuntake.png",ccui.TextureResType.plistType)
            viewNode.BtnUpgradeTake:loadTexturePressed("hallcocosstudio/images/plist/NobilityPrivilege/NobilityPrivilege_upgradeuntake.png",ccui.TextureResType.plistType)
        end
    end
    if not nTakeStatus then
        nRewardLevel = nobilityPrivilegeInfo.level + 2
    end
    viewNode.PanelUpgradeGift:getChildByName("Fnt_Level"):setString("贵族"..nRewardLevel-1)
    --达到最高等级，置灰
    if nobilityPrivilegeInfo.level >= #nobilityPrivilegeConfig.nobilityLevelList - 1 and not nTakeStatus then
        viewNode.BtnUpgradeTake:loadTextureNormal("hallcocosstudio/images/plist/NobilityPrivilege/NobilityPrivilege_MaxLevel.png",ccui.TextureResType.plistType)
        viewNode.BtnUpgradeTake:loadTexturePressed("hallcocosstudio/images/plist/NobilityPrivilege/NobilityPrivilege_MaxLevel.png",ccui.TextureResType.plistType)
        viewNode.BtnUpgradeTake:loadTextureDisabled("hallcocosstudio/images/plist/NobilityPrivilege/NobilityPrivilege_MaxLevel.png",ccui.TextureResType.plistType)
        viewNode.BtnUpgradeTake:setEnabled(false)
        viewNode.BtnUpgradeTake:setBright(false)
        viewNode.PanelUpgradeGift:getChildByName("Fnt_Level"):setString("已满级")
        nRewardLevel = nRewardLevel - 1 --满级的话用最高级别的价值
    end
    if not nobilityPrivilegeConfig.nobilityLevelList[nRewardLevel] then return end 
    local  nUpgradeGiftBagDetail= nobilityPrivilegeConfig.nobilityLevelList[nRewardLevel].upgradeGiftBagDetail
    for i=1,#nUpgradeGiftBagDetail do
        for u, v in pairs(nobilityPrivilegeConfig.privilegeList) do
            if nUpgradeGiftBagDetail[i].upgradeGiftBagID == v.privilegeID then
                if v.privilegeType == 1 and v.showValue[1] then
                    viewNode.PanelUpgradeGift:getChildByName("Text_Gift"):setString("价值"..v.showValue[1].."元")
                end
            end
        end
    end
end

function NobilityPrivilegeCtrl:updateUI()
    if not self._viewNode then return end

    local nobilityPrivilegeInfo = NobilityPrivilegeModel:GetNobilityPrivilegeInfo()
    local nobilityPrivilegeConfig = NobilityPrivilegeModel:GetNobilityPrivilegeConfig()
    if not nobilityPrivilegeInfo or not nobilityPrivilegeConfig then
        NobilityPrivilegeModel:gc_GetNobilityPrivilegeInfo()
        return
    end

    self._nLevel  = nobilityPrivilegeInfo.level or 0
    self:freshScrollView(self._nLevel)

    self:freshLevelInfo()
    self:freshGiftInfo()
    self:playAnimation()

    --不在活动范围冿
    if not NobilityPrivilegeModel:isAlive() then
        self:goBack()
        return
    end
end

function NobilityPrivilegeCtrl:goBack()
    for i,v in pairs(itemPoolLeft) do
        v:release()
    end
    itemPoolLeft={}
    for i,v in pairs(itemPoolRight) do
        v:release()
    end
    itemPoolRight={}
    NobilityPrivilegeCtrl.super.removeSelf(self)
end

function NobilityPrivilegeCtrl:onClickClose()
    my.playClickBtnSound()
    self:goBack()
end

function NobilityPrivilegeCtrl:onKeyBack()
    self:goBack()
end

function NobilityPrivilegeCtrl:onClickBtnShop( )
--    local AdvertModel           = import('src.app.plugins.advert.AdvertModel'):getInstance()

--    if AdvertModel:isNeedShowBanner() then
--        AdvertModel:showBannerAdvert()
--        return
--    end
    my.playClickBtnSound()
    if not CenterCtrl:checkNetStatus() then
        self:goBack()
        return
    end

    local GAP_SCHEDULE = 2 --间隔时间2秒
    local nowTime = os.time()
    self._lastTime = self._lastTime or 0
    if nowTime - self._lastTime > GAP_SCHEDULE then
        self._lastTime = nowTime
    else
        my.informPluginByName({pluginName = 'TipPlugin',params = {tipString = "点击太频繁，请2秒后再操作", removeTime = 3}})
        return
    end

    local nobilityLogSdkInfo = NobilityPrivilegeModel:getNobilityLogSdkCommonInfo()
    my.dataLink(cc.exports.DataLinkCodeDef.NOBILITY_GOTO_SHOP_BTN_CLICK, nobilityLogSdkInfo)

    my.informPluginByName({pluginName = "ShopCtrl", params = {defaultPage = "silver", uniqueFlag = nobilityLogSdkInfo.behaviorUnique}})    
end

function NobilityPrivilegeCtrl:onClickBtnLeft( )
    my.playClickBtnSound()
    if not CenterCtrl:checkNetStatus() then
        self:goBack()
        return
    end
    self._nLevel = self._nLevel - 1
    self:freshScrollView(self._nLevel)
end

function NobilityPrivilegeCtrl:onClickBtnRight( )
    my.playClickBtnSound()
    if not CenterCtrl:checkNetStatus() then
        self:goBack()
        return
    end

    self._nLevel = self._nLevel + 1

    self:freshScrollView(self._nLevel)
end

function NobilityPrivilegeCtrl:onClickBtnDayGift( )
    if not CenterCtrl:checkNetStatus() then
        self:goBack()
        return
    end
    
    local nobilityPrivilegeInfo = NobilityPrivilegeModel:GetNobilityPrivilegeInfo()
    local nobilityPrivilegeConfig = NobilityPrivilegeModel:GetNobilityPrivilegeConfig()
    if not nobilityPrivilegeInfo or not nobilityPrivilegeConfig then
        NobilityPrivilegeModel:gc_GetNobilityPrivilegeInfo()
        return
    end

    if nobilityPrivilegeInfo.dailyGiftBagStatus == NobilityPrivilegeDef.NOBILITY_PRIVILEGE_UNTAKE then
        NobilityPrivilegeModel:gc_NobilityPrivilegeDailyGiftBagTake()
    end
end

function NobilityPrivilegeCtrl:onClickBtnWeekGift( )
    if not CenterCtrl:checkNetStatus() then
        self:goBack()
        return
    end
    
    local nobilityPrivilegeInfo = NobilityPrivilegeModel:GetNobilityPrivilegeInfo()
    local nobilityPrivilegeConfig = NobilityPrivilegeModel:GetNobilityPrivilegeConfig()
    if not nobilityPrivilegeInfo or not nobilityPrivilegeConfig then
        NobilityPrivilegeModel:gc_GetNobilityPrivilegeInfo()
        return
    end

    if nobilityPrivilegeInfo.weekGiftBagStatus == NobilityPrivilegeDef.NOBILITY_PRIVILEGE_UNTAKE_NEW then
        NobilityPrivilegeModel:gc_NobilityPrivilegeWeekGiftBagTake()
    end
end

function NobilityPrivilegeCtrl:onClickBtnMonthGift( )
    if not CenterCtrl:checkNetStatus() then
        self:goBack()
        return
    end
    
    local nobilityPrivilegeInfo = NobilityPrivilegeModel:GetNobilityPrivilegeInfo()
    local nobilityPrivilegeConfig = NobilityPrivilegeModel:GetNobilityPrivilegeConfig()
    if not nobilityPrivilegeInfo or not nobilityPrivilegeConfig then
        NobilityPrivilegeModel:gc_GetNobilityPrivilegeInfo()
        return
    end

    if nobilityPrivilegeInfo.monthGiftBagStatus == NobilityPrivilegeDef.NOBILITY_PRIVILEGE_UNTAKE_NEW then
        NobilityPrivilegeModel:gc_NobilityPrivilegeMonthGiftBagTake()
    end
end

function NobilityPrivilegeCtrl:onClickBtnUpgradeLevel( )
--    local AdvertModel           = import('src.app.plugins.advert.AdvertModel'):getInstance()

--    if AdvertModel:isNeedShowBanner() then
--        AdvertModel:hideBannerAdvert()
--        return
--    end
    my.playClickBtnSound()
    if not CenterCtrl:checkNetStatus() then
        self:goBack()
        return
    end

    local nobilityPrivilegeInfo = NobilityPrivilegeModel:GetNobilityPrivilegeInfo()
    local nobilityPrivilegeConfig = NobilityPrivilegeModel:GetNobilityPrivilegeConfig()
    if not nobilityPrivilegeInfo or not nobilityPrivilegeConfig then
        NobilityPrivilegeModel:gc_GetNobilityPrivilegeInfo()
        return
    end

    local GAP_SCHEDULE = 2 --间隔时间2秒
    local nowTime = os.time()
    self._lastTime = self._lastTime or 0
    if nowTime - self._lastTime > GAP_SCHEDULE then
        self._lastTime = nowTime
    else
        my.informPluginByName({pluginName = 'TipPlugin',params = {tipString = "点击太频繁，请2秒后再操作", removeTime = 3}})
        return
    end

        --升级礼包
    local nTakeStatus = false
    for i = #nobilityPrivilegeInfo.upgradeGiftBagStatus,1,-1 do
        if nobilityPrivilegeInfo.upgradeGiftBagStatus[i] == NobilityPrivilegeDef.NOBILITY_PRIVILEGE_UNTAKE then
            nTakeStatus = true
            NobilityPrivilegeModel:gc_NobilityPrivilegeUpgradeGiftBagTake()
            return
        end
    end
    
    if not nTakeStatus then
        local nobilityLogSdkInfo = NobilityPrivilegeModel:getNobilityLogSdkCommonInfo()
        my.dataLink(cc.exports.DataLinkCodeDef.NOBILITY_GOTO_RECHARGE_BTN_CLICK, nobilityLogSdkInfo)

        my.informPluginByName({pluginName = "ShopCtrl", params = {defaultPage = "silver", uniqueFlag = nobilityLogSdkInfo.behaviorUnique}})
    end
end

function NobilityPrivilegeCtrl:playAnimation()
    local nobilityPrivilegeInfo = NobilityPrivilegeModel:GetNobilityPrivilegeInfo()
    local nobilityPrivilegeConfig = NobilityPrivilegeModel:GetNobilityPrivilegeConfig()
    if not nobilityPrivilegeInfo or not nobilityPrivilegeConfig then
        NobilityPrivilegeModel:gc_GetNobilityPrivilegeInfo()
        return
    end

    self._viewNode:stopAllActions()
    if nobilityPrivilegeInfo.level < #nobilityPrivilegeConfig.nobilityLevelList - 1 then
        self._viewNode:runTimelineAction("animation0", true)
    end

    --贵族特权动画
    local aniFile = "res/hallcocosstudio/NobilityPrivilege/gztq_bt.csb"
    local aniNode = self._viewNode.PanelAnimation:getChildByName("Ani_NobilityPrivilege")
    aniNode:stopAllActions()
    aniNode:setVisible(true)
    local action = cc.CSLoader:createTimeline(aniFile)
    if not tolua.isnull(action) then
        aniNode:runAction(action)
        action:play("animation0", true)
    end

    --皇冠动画
    aniFile = "res/hallcocosstudio/NobilityPrivilege/gztq_hg.csb"
    aniNode = self._viewNode.PanelAnimation:getChildByName("Ani_Cap")
    aniNode:stopAllActions()
    aniNode:setVisible(true)
    local action = cc.CSLoader:createTimeline(aniFile)
    if not tolua.isnull(action) then
        aniNode:runAction(action)
        action:play("animation0", true)
    end

    --底框动画
    aniFile = "res/hallcocosstudio/NobilityPrivilege/gztq_diguang.csb"
    aniNode = self._viewNode.PanelAnimation:getChildByName("Ani_DiKuang")
    aniNode:stopAllActions()
    aniNode:setVisible(true)
    local action = cc.CSLoader:createTimeline(aniFile)
    if not tolua.isnull(action) then
        aniNode:runAction(action)
        action:play("animation0", true)
    end

    --每日礼包动画
    aniFile = "res/hallcocosstudio/NobilityPrivilege/kelingqu.csb"
    aniNode = self._viewNode.AniDayGift
    aniNode:stopAllActions()
    aniNode:setVisible(false)
    if nobilityPrivilegeInfo.dailyGiftBagStatus == NobilityPrivilegeDef.NOBILITY_PRIVILEGE_UNTAKE then
        aniNode:setVisible(true)
        local action = cc.CSLoader:createTimeline(aniFile)
        if not tolua.isnull(action) then
            aniNode:runAction(action)
            action:play("animation0", true)
        end
    end

    --每周礼包动画
    aniFile = "res/hallcocosstudio/NobilityPrivilege/kelingqu.csb"
    aniNode = self._viewNode.AniWeeklyGift
    aniNode:stopAllActions()
    aniNode:setVisible(false)
    if nobilityPrivilegeInfo.weekGiftBagStatus == NobilityPrivilegeDef.NOBILITY_PRIVILEGE_UNTAKE_NEW then
        aniNode:setVisible(true)
        local action = cc.CSLoader:createTimeline(aniFile)
        if not tolua.isnull(action) then
            aniNode:runAction(action)
            action:play("animation0", true)
        end
    end

    --每月礼包动画
    aniFile = "res/hallcocosstudio/NobilityPrivilege/kelingqu.csb"
    aniNode = self._viewNode.AniMonthGift
    aniNode:stopAllActions()
    aniNode:setVisible(false)
    if nobilityPrivilegeInfo.monthGiftBagStatus == NobilityPrivilegeDef.NOBILITY_PRIVILEGE_UNTAKE_NEW then
        aniNode:setVisible(true)
        local action = cc.CSLoader:createTimeline(aniFile)
        if not tolua.isnull(action) then
            aniNode:runAction(action)
            action:play("animation0", true)
        end
    end

    --升级礼包动画
    aniFile = "res/hallcocosstudio/NobilityPrivilege/kelingqu.csb"
    aniNode = self._viewNode.AniUpgradeGift
    aniNode:stopAllActions()
    aniNode:setVisible(false)

    local nTakeStatus = false
    for i = #nobilityPrivilegeInfo.upgradeGiftBagStatus,1,-1 do
        if nobilityPrivilegeInfo.upgradeGiftBagStatus[i] == NobilityPrivilegeDef.NOBILITY_PRIVILEGE_UNTAKE then
            nTakeStatus = true
        end
    end
    if nTakeStatus then
        aniNode:setVisible(true)
        local action = cc.CSLoader:createTimeline(aniFile)
        if not tolua.isnull(action) then
            aniNode:runAction(action)
            action:play("animation0", true)
        end
    end
end

return NobilityPrivilegeCtrl