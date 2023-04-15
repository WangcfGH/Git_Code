local viewCreater = import('src.app.plugins.ValuablePurchase.ValuablePurchaseView')
local ValuablePurchaseCtrl = class('ValuablePurchaseCtrl', cc.load('BaseCtrl'))
local ValuablePurchaseModel = import('src.app.plugins.ValuablePurchase.ValuablePurchaseModel'):getInstance()
local ValuablePurchaseDef = import('src.app.plugins.ValuablePurchase.ValuablePurchaseDef')
local BaseRadio = import('src.app.GameHall.ctrls.BaseRadio')

-- ValuablePurchaseCtrl.RUN_ENTERACTION = false

function ValuablePurchaseCtrl:onCreate(params)
    local viewNode = self:setViewIndexer(viewCreater:createViewIndexer())

    self:bindDestroyButton(viewNode.btnClose)
    self:bindUserEventHandler(self._viewNode, {"btnStartPay"})
    self:addEventListeners()
    self:initMainPanelAni()
    self:updateUI()
    ValuablePurchaseModel:queryInfo()
end

function ValuablePurchaseCtrl:addEventListeners()
    self:listenTo(ValuablePurchaseModel, ValuablePurchaseModel.EVENT_QUERY_INFO_OK, handler(self, self.onQueryInfoOK))
    self:listenTo(ValuablePurchaseModel, ValuablePurchaseModel.EVENT_START_PAY_OK, handler(self, self.onStartPayOK))
    self:listenTo(ValuablePurchaseModel, ValuablePurchaseModel.EVENT_BUY_PURCHASE_OK, handler(self, self.onBuyPurchaseOK))
end

function ValuablePurchaseCtrl:initMainPanelAni()
    local csbPath = 'res/hallcocosstudio/ValuablePurchase/Node_ValuablePurchaseMainAni.csb'
    local action = cc.CSLoader:createTimeline(csbPath)
    if action then
        self._viewNode.nodeMainAni:runAction(action)
        action:play('animation0', true)
    end
end

function ValuablePurchaseCtrl:updateUI()
    self:freshPurchaseItems()
end

function ValuablePurchaseCtrl:freshPurchaseItems()
    self._viewNode.listViewPurchaseItem:removeAllChildren()
    local radioCallbackTbl = {}
    local radioStateCallbackTbl = {}
    local purchaseItemList = ValuablePurchaseModel:getPurchaseItemList()
    local radioBtnIndex = 0
    local defaultIndex = 0
    for i = 1, #purchaseItemList do
        radioBtnIndex = radioBtnIndex + 1
        local purchaseItem = purchaseItemList[i]
        local radioBtn = self:createPurchaseItemButton(radioBtnIndex, purchaseItem)
        if radioBtn then
            local function radioBtnClicked()
                self:onPurchaseItemSelected(purchaseItem)
            end

            local function radioStateCallback(name, event)
                if event and name == 'ended' then
                    my.playClickBtnSound()
                end

                local btnTitle = radioBtn:getChildByName('Text_BtnTitle')
                local subTitle = radioBtn:getChildByName('Text_SubTitle')
                if btnTitle and subTitle then
                    print(name)
                    if name == 'began' then
                        btnTitle:setTextColor(cc.c3b(188, 56, 31))
                        subTitle:setFntFile('res/hallcocosstudio/images/font/ValuablePurchase/fnt_czlg_1.fnt')
                    elseif name == 'ended' then
                        btnTitle:setTextColor(cc.c3b(188, 56, 31))
                        subTitle:setFntFile('res/hallcocosstudio/images/font/ValuablePurchase/fnt_czlg_1.fnt')
                    elseif name == 'cancelled' then
                        btnTitle:setTextColor(cc.c3b(255, 255, 255))
                        subTitle:setFntFile('res/hallcocosstudio/images/font/ValuablePurchase/fnt_czlg_2.fnt')
                    elseif name == 'moved' then
                        btnTitle:setTextColor(cc.c3b(255, 255, 255))
                        subTitle:setFntFile('res/hallcocosstudio/images/font/ValuablePurchase/fnt_czlg_2.fnt')
                    elseif name == 'selected' then
                        btnTitle:setTextColor(cc.c3b(188, 56, 31))
                        subTitle:setFntFile('res/hallcocosstudio/images/font/ValuablePurchase/fnt_czlg_1.fnt')
                    elseif name == 'unselected' then
                        btnTitle:setTextColor(cc.c3b(255, 255, 255))
                        subTitle:setFntFile('res/hallcocosstudio/images/font/ValuablePurchase/fnt_czlg_2.fnt')
                    end
                end
            end

            table.insert(radioCallbackTbl, radioBtnClicked)
            table.insert(radioStateCallbackTbl, radioStateCallback)
            self._viewNode.listViewPurchaseItem:insertCustomItem(radioBtn, radioBtnIndex - 1)
        end

        local todayDate = tonumber(os.date('%Y%m%d', os.time()))

        if defaultIndex == 0 and todayDate > purchaseItem.purchasedate then
            defaultIndex = radioBtnIndex
        end
    end

    if #radioCallbackTbl > 0 then
        if defaultIndex == 0 then
            defaultIndex = 1
        end

        local BaseRadio = import('src.app.GameHall.ctrls.BaseRadio')
        if defaultIndex > 5 then
            local percent = (defaultIndex / #radioCallbackTbl) * 100
            my.scheduleOnce(function()
                self._viewNode.listViewPurchaseItem:jumpToPercentVertical(percent)
            end, 0)
        end
        self._radio = BaseRadio:create(self._viewNode.listViewPurchaseItem:getRealNode(), #radioCallbackTbl, defaultIndex, radioCallbackTbl, radioStateCallbackTbl)
    end
end

function ValuablePurchaseCtrl:createPurchaseItemButton(radioIndex, purchaseItem)
    local csbPath = 'res/hallcocosstudio/ValuablePurchase/Node_ItemRadioBtn.csb'
    local node = cc.CSLoader:createNode(csbPath)
    if node then
        local radioBtn = node:getChildByName('Btn_Radio')
        radioBtn:setName('Radio_' .. radioIndex)
        radioBtn:retain()
        radioBtn:removeFromParent()
        radioBtn:getChildByName('Text_BtnTitle'):setString(tostring(purchaseItem.price) .. '元礼包')
        local extraRewardCount = 0
        for i = 1, #purchaseItem.dayextrarewardlist do
            local dayExtraReward = purchaseItem.dayextrarewardlist[i]
            if dayExtraReward.rewardtypelist[1] == ValuablePurchaseDef.VALUABLE_PURCHASE_ITEMTYPE_SILVER then
                extraRewardCount = extraRewardCount + dayExtraReward.rewardcountlist[1]
            end
            if dayExtraReward.rewardtypelist[2] == ValuablePurchaseDef.VALUABLE_PURCHASE_ITEMTYPE_SILVER then
                extraRewardCount = extraRewardCount + dayExtraReward.rewardcountlist[2]
            end
        end
        local discount = math.floor(extraRewardCount * 100 / purchaseItem.rewardcount)
        local discountStr = string.format('多送%d%%', discount)
        radioBtn:getChildByName('Text_SubTitle'):setString(discountStr)
        return radioBtn
    end
    return nil
end

function ValuablePurchaseCtrl:onPurchaseItemSelected(purchaseItem)
    dump(purchaseItem)
    self._curPurchaseItem = purchaseItem

    self:freshDayPurchaseList()
    self:freshBuyBtn()
end

function ValuablePurchaseCtrl:freshDayPurchaseList()
    local directRewardCount = self._curPurchaseItem.rewardcount
    local dayExtraRewardList = self._curPurchaseItem.dayextrarewardlist

    local curBuyIndex = 0
    self._viewNode.listViewDayPurchase:removeAllChildren()
    for i = 1, #dayExtraRewardList do
        local dayExtraReward = dayExtraRewardList[i]
        local hasBought = i <= self._curPurchaseItem.continuedays
        local nodeDayRewardItem = self:createDayRewardItem(i, directRewardCount, dayExtraReward, hasBought)
        if nodeDayRewardItem then

            local todayDate = tonumber(os.date('%Y%m%d', os.time()))
            if todayDate > self._curPurchaseItem.purchasedate then
                if i == self._curPurchaseItem.continuedays + 1 then
                    curBuyIndex = i
                end
            end
            self._viewNode.listViewDayPurchase:insertCustomItem(nodeDayRewardItem, i - 1)
        end
    end

    if curBuyIndex > 3 then
        local percent = (curBuyIndex / #dayExtraRewardList) * 100
        my.scheduleOnce(function()
            self._viewNode.listViewDayPurchase:jumpToPercentVertical(percent)
        end, 0)
    end
end

function ValuablePurchaseCtrl:freshBuyBtn()
    local todayDate = tonumber(os.date('%Y%m%d', os.time()))
    if todayDate <= self._curPurchaseItem.purchasedate then
        -- 今日已购买
        self._viewNode.btnStartPay:setBright(false)
        self._viewNode.btnStartPay:setTouchEnabled(false)
    else
        self._viewNode.btnStartPay:setBright(true)
        self._viewNode.btnStartPay:setTouchEnabled(true)
    end
end

function ValuablePurchaseCtrl:getRewardNameAndIconPathByRewardTypeAndPropID(rewardType, propID, rewardCount)
    local dir = "hallcocosstudio/images/plist/RewardCtrl/"
    local path = nil

    if rewardType == ValuablePurchaseDef.VALUABLE_PURCHASE_ITEMTYPE_SILVER then
        if rewardCount >= 10000 then 
            path = dir .. "Img_Silver4.png"
        elseif rewardCount >= 5000 then
            path = dir .. "Img_Silver3.png"
        elseif rewardCount >= 1000 then
            path = dir .. "Img_Silver2.png"
        else
            path = dir .. "Img_Silver1.png"
        end
        return 'x' .. rewardCount .. '两', path
    elseif rewardType == ValuablePurchaseDef.VALUABLE_PURCHASE_ITEMTYPE_EXCHANGE then
        if rewardCount>=100 then 
            path = dir .. "Img_Ticket4.png"
        elseif rewardCount>=50 then
            path = dir .. "Img_Ticket3.png"
        elseif rewardCount>=20 then
            path = dir .. "Img_Ticket2.png"
        else
            path = dir .. "Img_Ticket1.png"
        end
        return '礼券x' .. rewardCount, path
    else
        if propID == ValuablePurchaseDef.REWARD_PROP_ID_ONEDAY_CARD_MARKER then
            return '1天记牌器x' .. rewardCount, dir .. '1tian.png'
        elseif propID == ValuablePurchaseDef.REWARD_PROP_ID_7DAY_CARD_MARKER then
            return '7天记牌器x' .. rewardCount, dir .. '7tian.png'
        elseif propID == ValuablePurchaseDef.REWARD_PROP_ID_30DAY_CARD_MARKER then
            return '30天记牌器x' .. rewardCount, dir .. '30tian.png'
        elseif propID == ValuablePurchaseDef.REWARD_PROP_ID_EXPRESSION_ROSE then
            return '玫瑰表情x' .. rewardCount, 'hallcocosstudio/images/plist/RewardCtrl/Img_Rose.png'
        elseif propID == ValuablePurchaseDef.REWARD_PROP_ID_EXPRESSION_LIGHTNING then
            return '闪电表情x' .. rewardCount, 'hallcocosstudio/images/plist/RewardCtrl/Img_Lighting.png'
        elseif propID == ValuablePurchaseDef.REWARD_PROP_ID_ONEBOUT_CARDMARKER then
            return '1局记牌器x' .. rewardCount, 'hallcocosstudio/images/plist/RewardCtrl/Img_CardMarker.png'
        elseif propID == ValuablePurchaseDef.REWARD_PROP_ID_TIMING_GAME_TICKET then
            return '定时赛门票x' .. rewardCount, 'hallcocosstudio/images/plist/RewardCtrl/Img_TimingTicket1.png'
        end
    end
    return nil, nil
end

function ValuablePurchaseCtrl:createDayRewardItem(days, directRewardCount, dayExtraReward, hasBought)
    local csbPath = 'res/hallcocosstudio/ValuablePurchase/Node_DayRewardItem.csb'
    local node = cc.CSLoader:createNode(csbPath)
    if node then
        local panelMain = node:getChildByName('Panel_Main')
        panelMain:retain()
        panelMain:removeFromParent()
        panelMain:setName('DayRewardItem_' .. days)
        panelMain:getChildByName('Fnt_Days'):setString(tostring(days))
        panelMain:getChildByName('Fnt_RewardCount'):setString(tostring(directRewardCount) .. '两')
        panelMain:getChildByName('Img_Bought'):setVisible(hasBought)
        panelMain:getChildByName('Img_Cover'):setVisible(hasBought)
        local imgRewardIcon1 = panelMain:getChildByName('Img_RewardIcon1')
        local imgRewardIcon2 = panelMain:getChildByName('Img_RewardIcon2')
        local textRewardCount1 = panelMain:getChildByName('Text_RewardCount1')
        local textRewardCount2 = panelMain:getChildByName('Text_RewardCount2')
        local imgDays = panelMain:getChildByName('Img_Days')
        local nodeLightAni = panelMain:getChildByName('Node_LightAni')

        if days <= 3 then
            imgDays:loadTexture('hallcocosstudio/images/plist/ValuablePurchase/jiaobiao_' .. days .. '.png', ccui.TextureResType.plistType)
        else
            imgDays:loadTexture('hallcocosstudio/images/plist/ValuablePurchase/jiaobiao_3.png', ccui.TextureResType.plistType)
        end

        local todayDate = tonumber(os.date('%Y%m%d', os.time()))
        if todayDate > self._curPurchaseItem.purchasedate then
            if days == self._curPurchaseItem.continuedays + 1 then
                local action = cc.CSLoader:createTimeline('res/hallcocosstudio/ValuablePurchase/Node_LightAni.csb')
                if action then
                    nodeLightAni:setVisible(true)
                    nodeLightAni:runAction(action)
                    action:play('animation0', true)
                end
            end
        end

        -- 奖励ICON及名称
        local rewardName1, rewardIconPath1 = self:getRewardNameAndIconPathByRewardTypeAndPropID(dayExtraReward.rewardtypelist[1], dayExtraReward.propidlist[1], dayExtraReward.rewardcountlist[1])
        local rewardName2, rewardIconPath2 = self:getRewardNameAndIconPathByRewardTypeAndPropID(dayExtraReward.rewardtypelist[2], dayExtraReward.propidlist[2], dayExtraReward.rewardcountlist[2])
        if rewardName1 and rewardIconPath1 then
            textRewardCount1:setString(rewardName1)
            imgRewardIcon1:loadTexture(rewardIconPath1, ccui.TextureResType.plistType)
        end
        if rewardName2 and rewardIconPath2 then
            textRewardCount2:setString(rewardName2)
            imgRewardIcon2:loadTexture(rewardIconPath2, ccui.TextureResType.plistType)
        end

        return panelMain
    end
    return nil
end

function ValuablePurchaseCtrl:btnStartPayClicked()
    local purchaseId = self._curPurchaseItem.id
    ValuablePurchaseModel:startPay(purchaseId)
end

function ValuablePurchaseCtrl:onQueryInfoOK()
    if ValuablePurchaseModel:isEnable() then
        self:updateUI()
    else
        self:removeSelf()
    end
end

function ValuablePurchaseCtrl:onStartPayOK(event)
    if event and event.value and event.value.continuePay then
        local purchaseId = event.value.purchaseId
        local purchaseItem = ValuablePurchaseModel:getPurchaseItemByPurchaseId(purchaseId)
        if purchaseItem then
            self:payForProduct(purchaseItem.exchangeid, purchaseItem.price)
        end
    end
end

function ValuablePurchaseCtrl:onBuyPurchaseOK(event)
    local purchaseItem = ValuablePurchaseModel:getPurchaseItemByPurchaseId(event.value.purchaseId)
    if purchaseItem then
        self._curPurchaseItem = purchaseItem
        self:freshDayPurchaseList()
        self:freshBuyBtn()
    end
end

function ValuablePurchaseCtrl:removeEventListeners()
    ValuablePurchaseModel:removeEventListenersByTag(self:getEventTag())
end

function ValuablePurchaseCtrl:onExit()
    self:removeEventListeners()
    local PluginProcessModel = mymodel('hallext.PluginProcessModel'):getInstance()
    PluginProcessModel:PopNextPlugin()
end

function ValuablePurchaseCtrl:payForProduct(excahngeID, price)
    if self._waitingPayResult then
        my.informPluginByName({pluginName='TipPlugin',params={tipString="操作太频繁，请稍后再试！",removeTime=2}})
        return
    end
    local DeviceModel = require("src.app.GameHall.models.DeviceModel"):getInstance()
    local szWifiID, szImeiID, szSystemID = DeviceModel.szWifiID, DeviceModel.szImeiID, DeviceModel.szSystemID
    local deviceId = string.format("%s,%s,%s", szWifiID, szImeiID, szSystemID)

    local function getPayExtArgs()
        local strPayExtArgs = "{"
        if cc.exports.LaunchMode["PLATFORM"] == MCAgent:getInstance():getLaunchMode() then
            if (cc.exports.GetShopConfig()["platform_app_client_id"] and cc.exports.GetShopConfig()["platform_app_client_id"] ~= "") then
                strPayExtArgs = strPayExtArgs .. string.format('"platform_app_client_id":"%d",', cc.exports.GetShopConfig()["platform_app_client_id"])
            end
            if (cc.exports.GetShopConfig()["platform_cooperate_way_id"] and cc.exports.GetShopConfig()["platform_cooperate_way_id"] ~= "") then
                strPayExtArgs = strPayExtArgs .. string.format('"platform_cooperate_way_id":"%d",', cc.exports.GetShopConfig()["platform_cooperate_way_id"])
            end
        end

        local userID = plugin.AgentManager:getInstance():getUserPlugin():getUserID()
        local gameID = BusinessUtils:getInstance():getGameID()
        if userID and gameID and type(userID) == "string" and type(gameID) == "number" then
            local promoteCodeCache = CacheModel:getCacheByKey("PromoteCode_" .. userID .. "_" .. gameID)
            if type(promoteCodeCache) == "number" then
                strPayExtArgs = strPayExtArgs .. string.format('"promote_code":"%s",', tostring(promoteCodeCache))
            end
        end

        if string.sub(strPayExtArgs, string.len(strPayExtArgs)) == "," then
            strPayExtArgs = string.sub(strPayExtArgs, 1, string.len(strPayExtArgs) - 1)
        end

        if 1 == string.len(strPayExtArgs) then
            strPayExtArgs = ""
        else
            strPayExtArgs = strPayExtArgs .. "}"
        end
        print("pay_ext_args:", strPayExtArgs)
        return strPayExtArgs
    end

    local paymodel = mymodel("PayModel"):getInstance()
    local param = clone(paymodel:getPayMetaTable())

    param["Product_Name"] = "超值连购礼包"
    param["Product_Id"] = ""

    local price,exchangeid = price, excahngeID
    local through_data = string.format("{\"RewardToGame\":%d,\"ExchangeId\":%d}", 0, exchangeid)

    param["pay_point_num"]  = 0
    param["Product_Price"] = tostring(price)     --价格
    param["Exchange_Id"]  = tostring(1)      --物品ID  1是银子 2是会员 3是积分 4是钻石
    param["through_data"] = through_data;
    param["ext_args"] = getPayExtArgs();

    local kpiData = my.getKPIClientData()
    param["RecomGameId"]   = tostring(kpiData.RecomGameId)
    param["RecomGameCode"] = kpiData.RecomGameCode
    param["RecomGameVers"] = ""

    if device.platform == 'windows' or cc.exports.isHSoxRaySupported() then
        my.informPluginByName({pluginName='ActivityRechargeHSoxCtrl',params = param})
    else
        local iapPlugin = plugin.AgentManager:getInstance():getIAPPlugin()
        local function payCallBack(code, msg)
            my.scheduleOnce(function()
                self._waitingPayResult = false
            end,3)
            if code == PayResultCode.kPaySuccess then

            else
                if string.len(msg) ~= 0 then
                    my.informPluginByName({pluginName='TipPlugin',params={tipString=msg,removeTime=2}})
                end

                if( code == PayResultCode.kPayFail )then

                elseif( code == PayResultCode.kPayTimeOut )then

                elseif( code == PayResultCode.kPayProductionInforIncomplete )then

                end
            end
        end
        iapPlugin:setCallback(payCallBack)
        iapPlugin:payForProduct(param)
        self._waitingPayResult = true
    end
end

return ValuablePurchaseCtrl