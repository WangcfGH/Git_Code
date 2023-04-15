local viewCreater = import('src.app.plugins.AnchorLuckyBag.LuckyBagRewardListView')
local LuckyBagRewardListCtrl = class('LuckyBagRewardListCtrl', cc.load('BaseCtrl'))
local AnchorLuckyBagModel = import('src.app.plugins.AnchorLuckyBag.AnchorLuckyBagModel'):getInstance()

LuckyBagRewardListCtrl.RUN_ENTERACTION = true

function LuckyBagRewardListCtrl:onCreate(params)
    local viewNode = self:setViewIndexer(viewCreater:createViewIndexer())
    viewNode.imgEmpty:setVisible(false)
    self._loadingTimer = nil

    self:bindDestroyButton(viewNode.btnClose)
    self:startLoading()
    self:initEventListeners()
    AnchorLuckyBagModel:queryRewardList()
end

function LuckyBagRewardListCtrl:initEventListeners()
    self:listenTo(AnchorLuckyBagModel, AnchorLuckyBagModel.EVENT_QUERY_REWARDLIST_OK, handler(self, self.onQueryRewardListOK))
end

function LuckyBagRewardListCtrl:removeEventListeners()
    AnchorLuckyBagModel:removeEventListenersByTag(self:getEventTag())
end

function LuckyBagRewardListCtrl:startLoading()
    self._viewNode.panelLoading:setVisible(true)
    self._viewNode.imgLoading:runAction(cc.RepeatForever:create(cc.RotateBy:create(0.7, 360)))
    self._loadingTimer = my.createOnceSchedule(function()
        self._viewNode.imgEmpty:setVisible(true)
        self:stopLoading()
    end, 5)
end

function LuckyBagRewardListCtrl:stopLoading()
    if self._loadingTimer then
        my.removeSchedule(self._loadingTimer)
        self._loadingTimer = nil
    end
    if self._viewNode and not tolua.isnull(self._viewNode:getRealNode()) then
        self._viewNode.imgLoading:stopAllActions()
        self._viewNode.panelLoading:setVisible(false)
    end
end

function LuckyBagRewardListCtrl:onQueryRewardListOK()
    my.scheduleOnce(function()
        if self._viewNode and not tolua.isnull(self._viewNode:getRealNode()) then
            self:stopLoading()
            self:freshRewardList()
        end
    end, 0.3)
end

function LuckyBagRewardListCtrl:freshRewardList()
    local rewardList = AnchorLuckyBagModel:getRewardList()
    self._viewNode.imgEmpty:setVisible(#rewardList <= 0)
    local csbPath = 'res/hallcocosstudio/AnchorLuckyBag/Node_RewardInfoItem.csb'
    local node = cc.CSLoader:createNode(csbPath)
    local panelRewardInfo = node:getChildByName('Panel_Main')
    panelRewardInfo:retain()
    for i, rewardInfo in ipairs(rewardList) do
        if node then
            local panel = panelRewardInfo:clone()
            self._viewNode.listViewRewardInfo:insertCustomItem(panel, i - 1)
            self:setNodeRewardInfo(panel, rewardInfo)
        end
    end
end

function LuckyBagRewardListCtrl:setNodeRewardInfo(panelRewardInfo, rewardInfo)
    panelRewardInfo:getChildByName('Value_Datatime'):setString(rewardInfo.rewarddatetime)

    local textTiktokAccount = panelRewardInfo:getChildByName('Value_TiktokAccount')
    my.fixUtf8Width(rewardInfo.tiktokaccount, textTiktokAccount, 160)

    local textAnchorAccount = panelRewardInfo:getChildByName('Value_AnchorAccount')
    my.fixUtf8Width(rewardInfo.anchoraccount, textAnchorAccount, 160)

    local listViewItems = panelRewardInfo:getChildByName('ListView_ItemList')
    self:setNodeRewardItems(listViewItems, rewardInfo.rewarditems)

    local textRewardState = panelRewardInfo:getChildByName('Value_RewardState')
    if rewardInfo.rewardstate == AnchorLuckyBagModel.ANCHORLUCKYBAG_REWARDSTATE_WAITINGREWARD  then
        textRewardState:setTextColor(cc.c3b(15, 142, 33))
        textRewardState:setString('等待审核')
    elseif rewardInfo.rewardstate == AnchorLuckyBagModel.ANCHORLUCKYBAG_REWARDSTATE_REJECTREWARD  then
        textRewardState:setTextColor(cc.c3b(255, 0, 0))
        textRewardState:setString('未通过')
    elseif rewardInfo.rewardstate == AnchorLuckyBagModel.ANCHORLUCKYBAG_REWARDSTATE_REWARDED  then
        textRewardState:setTextColor(cc.c3b(0, 0, 255))
        textRewardState:setString('已发放')
    end
end

function LuckyBagRewardListCtrl:setNodeRewardItems(listViewItems, rewarditems)
    local itemCount = #rewarditems
    if itemCount <= 0 then
        return
    end
    local nodeItemsTbl = {}
    local nodeItem0 = listViewItems:getChildByName('Node_Item_0')
    table.insert(nodeItemsTbl, nodeItem0)
   
    for i = 1, itemCount -1 do
        local nodeItem = nodeItem0:clone()
        listViewItems:insertCustomItem(nodeItem, i)
        table.insert(nodeItemsTbl, nodeItem)
    end

    local contentSize = listViewItems:getContentSize()
    listViewItems:setContentSize(cc.size(contentSize.width, itemCount * 26 + itemCount - 1))
    
    for i, nodeItem in ipairs(nodeItemsTbl) do
        local imgIcon = nodeItem:getChildByName('Img_ItemIcon')

        if rewarditems[i].rewardtype == 0 then -- 银子
            imgIcon:loadTexture('res/hall/hallpic/commonitems/commonitem3.png')
        elseif rewarditems[i].rewardtype == 1 then -- 兑换券
            imgIcon:loadTexture('res/hall/hallpic/commonitems/commonitem1.png')
        elseif rewarditems[i].rewardtype == 3 then -- 话费
            imgIcon:loadTexture('res/hall/hallpic/commonitems/commonitem8.png')
        end

        local textCount = nodeItem:getChildByName('Value_ItemCount')
        textCount:setString(rewarditems[i].rewardcount)
    end
end

function LuckyBagRewardListCtrl:onExit()
    if self._loadingTimer then
        my.removeSchedule(self._loadingTimer)
        self._loadingTimer = nil
    end
    self:removeEventListeners()
end

return LuckyBagRewardListCtrl