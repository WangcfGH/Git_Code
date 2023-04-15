local ContinueRechargeCtrl = class("ContinueRechargeCtrl", cc.load("BaseCtrl"))
local ContinueRechargeModel = require("src.app.plugins.continuerecharge.ContinueRechargeModel"):getInstance()
local ContinueRechargeView = require("src.app.plugins.continuerecharge.ContinueRechargeView")
local RewardTipDef = import("src.app.plugins.RewardTip.RewardTipDef")
local PluginProcessModel = mymodel('hallext.PluginProcessModel'):getInstance()

local CURRENTPANEL = {
    RECHARGE = 1,
    EXCHANGE = 2
}

function ContinueRechargeCtrl:onCreate(params)
    self:setViewIndexer(ContinueRechargeView:createViewIndexer(self))

    self:initBtnClick()
    self:initEvent()

    ContinueRechargeModel:reqConfigAndData()
end

function ContinueRechargeCtrl:initEvent()
    self:listenTo(ContinueRechargeModel, ContinueRechargeModel.EVENT_UPDATE_DATA, handler(self, self.refresh))
    self:listenTo(ContinueRechargeModel, ContinueRechargeModel.EVENT_ON_HUAFEI_RSP, handler(self, self.onHuafeiRsp))
    self:listenTo(ContinueRechargeModel, ContinueRechargeModel.EVENT_CLOSE_CONTINUE_RECHARGE, handler(self, self.goBack))
end

function ContinueRechargeCtrl:onEnter()
    ContinueRechargeCtrl.super.onEnter(self)

    cc.SpriteFrameCache:getInstance():addSpriteFrames("hallcocosstudio/images/plist/huafei.plist")

    self:refresh()
    -- 根据数据选择显示那个界面
    if ContinueRechargeModel:isAllChecked() then
        self:showExchangePanel()
    else
        self:showRechargePanel()
    end

    self:getViewNode().introducePanel:hide()
    ContinueRechargeModel:saveTodayPop()
end

function ContinueRechargeCtrl:onExit()
    ContinueRechargeCtrl.super.onExit(self)
    my.unscheduleFunc(self._scheCountDown)
end

function ContinueRechargeCtrl:showRechargePanel()
    self._currentPanel = CURRENTPANEL.RECHARGE
    local viewNode = self:getViewNode()
    viewNode.rechargePanel:show()
    viewNode.exchangePanel:hide()

    viewNode.rechargeModeBtn:loadTextureNormal("hallcocosstudio/images/plist/huafei/btn_lianchong_1.png", ccui.TextureResType.plistType)
    viewNode.exchangeModeBtn:loadTextureNormal("hallcocosstudio/images/plist/huafei/btn_duihuan_2.png", ccui.TextureResType.plistType)
end

function ContinueRechargeCtrl:showExchangePanel()
    self._currentPanel = CURRENTPANEL.EXCHANGE
    local viewNode = self:getViewNode()
    viewNode.rechargePanel:hide()
    viewNode.exchangePanel:show()

    viewNode.rechargeModeBtn:loadTextureNormal("hallcocosstudio/images/plist/huafei/btn_lianchong_2.png", ccui.TextureResType.plistType)
    viewNode.exchangeModeBtn:loadTextureNormal("hallcocosstudio/images/plist/huafei/btn_duihuan_1.png", ccui.TextureResType.plistType)
end

function ContinueRechargeCtrl:UpdateTips()
    local config = ContinueRechargeModel:getConfig()
    local status = ContinueRechargeModel:getStatus()
    local totalChecked = ContinueRechargeModel:getCheckedTotalDay()
    local viewNode = self:getViewNode()
    viewNode.txtHuaFei:setString(config.huafei)
    viewNode.tipHuaiFeiNum:setString(config.huafei .. "元")
    viewNode.tipDayRechargeNum:setString(config.normalGoods[1].price .. "元")
    viewNode.tipExchangeTotalNum:setString(config.exchangeNum * ContinueRechargeModel:getTotalDay() .. "元")
    viewNode.tipExchangeNum:setString(totalChecked * config.exchangeNum .. "元")

    local startTime = status.startdate
    if status.buydate ~= 0 then
        startTime = status.buydate
    end
    local data = {
        year = math.floor(startTime / 10000),
        month = math.floor((startTime % 10000) / 100),
        day = startTime % 100,
        hour = 0,
        minute = 0,
        second = 0
    }

    local currentDay = status.current
    local time1 = os.time(data)
    print(os.date("%Y%m%d%H%M%S", os.time(data)))
    local time2 = os.time()
    local totalDay = ContinueRechargeModel:getTotalDay()
    local endTime
    local diff
    if currentDay <= totalDay and status.buydate == 0  then
        -- 显示活动剩余天数
        endTime = time1 + 24 * 60 * 60 * totalDay
        print(os.date("%Y%m%d%H%M%S", endTime))
        viewNode.tipTime:setString("活动剩余时间:")
        diff = endTime - time2
    elseif currentDay <= totalDay and status.buydate ~= 0 and status.state ~= 127 then
        -- 显示剩余充值天数
        endTime = time1 + 24 * 60 * 60 * totalDay
        print(os.date("%Y%m%d%H%M%S", endTime))
        viewNode.tipTime:setString("剩余购买时间:")
        diff = endTime - time2
    elseif currentDay <= totalDay + config.leftday then
        -- 显示剩余几天兑换
        endTime = time1 + 24 * 60 * 60 * (totalDay + config.leftday)
        viewNode.tipTime:setString("剩余兑换时间:")
        diff = endTime - time2
    end
    my.unscheduleFunc(self._scheCountDown)
    self._scheCountDown = function ()
        local diff = endTime - os.time()
        if diff < 0 then diff = 0 end
        local tbl = self:convertTime(diff)
        viewNode.tipTime:getChildByName("Text_shengyu"):setString(string.format("%d天%d时%d分", tbl.day, tbl.hour, tbl.mintue))
    end
    self._scheCountDown()
    my.scheduleFunc(self._scheCountDown, 1)
end

function ContinueRechargeCtrl:convertTime(second)
    local tbl = {}
    tbl.day = math.floor(second / (60 * 60 * 24))
    tbl.hour = math.floor((second % (60 * 60 * 24)) / 3600)
    tbl.mintue = math.floor(((second % (60 * 60 * 24)) % 3600) / 60)
    return tbl
end

function ContinueRechargeCtrl:initBtnClick()
    local viewNode = self:getViewNode()

    viewNode.closeBtn:addClickEventListener(function ()
        my.playClickBtnSound()
        self:goBack()
    end)

    -- viewNode.rechargeModeBtn:setSelected(true)
    viewNode.rechargeModeBtn:addClickEventListener(function ()
        my.playClickBtnSound()
        self:showRechargePanel()
    end)
    viewNode.exchangeModeBtn:addClickEventListener(function ()
        my.playClickBtnSound()
        self:showExchangePanel()
    end)

    viewNode.introduceBtn:addClickEventListener(function ()
        my.playClickBtnSound()
        viewNode.introducePanel:show()
    end)

    viewNode.introduceCloseBtn:addClickEventListener(function ()
        my.playClickBtnSound()
        viewNode.introducePanel:hide()
    end)
end

function ContinueRechargeCtrl:refreshRechargePanel()
    local viewNode = self:getViewNode()

    local config = ContinueRechargeModel:getConfig()
    local status = ContinueRechargeModel:getStatus()

    local rechargePanel = viewNode.rechargePanel

    local btnList = rechargePanel:getChildByName("Node_BtnList"):getChildren()

    for index, btn in ipairs(btnList) do
        self:initDayBtn(btn, index)
    end

    -- 初始化兑换券信息
    viewNode.ticketText:setString(config.exchangeNum .. "元兑换券")

    local currentDay = status.current

    -- 默认显示某一天的奖品信息
    if currentDay > ContinueRechargeModel:getTotalDay() then
        -- 当到了兑换时间如果有没签到的日期则默认显示补签日期
        local n = ContinueRechargeModel:getFirstAddCheckDayNum()
        if n > 0 then
            self:updateRechargeItem(n)
        else
            self:updateRechargeItem(ContinueRechargeModel:getTotalDay())
        end
    else
        self:updateRechargeItem(currentDay)
    end
    
end

function ContinueRechargeCtrl:refreshExchangePanel()
    local viewNode = self:getViewNode()
    local config = ContinueRechargeModel:getConfig()

    local str = config.huafei .. '元话费'
    self:updateExchageItem(viewNode.exchangeNode1, str, 0)

    local str2 = config.exchangeDeposite .. "两"
    self:updateExchageItem(viewNode.exchangeNode2, str2, 1)

    -- 刷新进度条
    local percent = (ContinueRechargeModel:getCheckedTotalDay() / ContinueRechargeModel:getTotalDay()) * 100
    local progress = viewNode.progress
    progress:setPercent(percent)

    local num = ContinueRechargeModel:getTotalDay() - ContinueRechargeModel:getCheckedTotalDay()
    if num == 0 then
        viewNode.lackDayNumText:setString("已完成")
    else
        viewNode.lackDayNumText:setString("还差" .. num .. "天")
    end
  
end

function ContinueRechargeCtrl:updateExchageItem(itemNode, describe, exchangeType)
    local config = ContinueRechargeModel:getConfig()
    local totalTicket = config.exchangeNum * ContinueRechargeModel:getTotalDay()
    itemNode:getChildByName("Text_tip"):setString("消耗" .. totalTicket .. "元兑换券")

    itemNode:getChildByName("Image_bg1"):getChildByName("Text"):setString(describe)

    local canChange = ContinueRechargeModel:canExchange()
    local btnExchange = itemNode:getChildByName("Btn_duihuan")
    if canChange then
        btnExchange:setEnabled(true)
        btnExchange:setBright(true)
    else
        btnExchange:setEnabled(false)
        btnExchange:setBright(false)
    end

    btnExchange:addClickEventListener(function ()
        my.playClickBtnSound()
        local GAP_SCHEDULE = 2 --间隔时间2秒
        local nowTime = os.time()
        self._lastTime = self._lastTime or 0
        if nowTime - self._lastTime > GAP_SCHEDULE then
            self._lastTime = nowTime
        else
            my.informPluginByName({pluginName = 'TipPlugin',params = {tipString = "点击太快了，请2秒后再操作~", removeTime = 2}})
            return
        end
        self:exchangeBtnClicked(exchangeType)
    end)
end

function ContinueRechargeCtrl:exchangeBtnClicked(exchangeType)
    local config = ContinueRechargeModel:getConfig()
    -- 兑换请求
    local exchangeInfo = {
        type = exchangeType,
        number = 0
    }
    if exchangeType == 0 then
        my.informPluginByName( { pluginName = "MobileInputPlugin" , params = {
            onInputFinished = function(input, onInputValid)
                self._waitHuafeiExchange = onInputValid
                local test = json.decode(input)
                exchangeInfo.number = test.mobile
                ContinueRechargeModel:reqExchange(exchangeInfo)
            end,
    
            jsonFormat = "{\"mobile\":%s}",
            awardInfo = {
                path = "res/hall/hallpic/commonitems/commonitem8.png",
                name = config.huafei .. '元话费',
                url = ""
            }
        }})
    else
        ContinueRechargeModel:reqExchange(exchangeInfo)
    end
end

function ContinueRechargeCtrl:initDayBtn(btn, index)
    local status = ContinueRechargeModel:getStatus()
    local currentDay = status.current

    -- 设置为初始状态
    btn:setEnabled(true)
    btn:setBright(true)
    btn:loadTextureNormal("hallcocosstudio/images/plist/huafei/qiandao_1.png", ccui.TextureResType.plistType)
    local imgSign = btn:getChildByName("Img_Sign")
    imgSign:hide()
    local imgChecked = btn:getChildByName("Img_Checked")
    imgChecked:hide()
    local imgGuang = btn:getChildByName("Img_Guang")
    imgGuang:hide()

    -- 先设置按钮状态
    if index > currentDay then
        btn:setEnabled(false)
        btn:setBright(false)
    end

    if ContinueRechargeModel:getCheckedByDayNumber(index) then
        -- 显示对勾
        imgChecked:show()
        btn:setEnabled(false)
    else
        if index < currentDay then
            -- 显示补签状态
            imgSign:show()
            btn:loadTextureNormal("hallcocosstudio/images/plist/huafei/qiandao_2.png", ccui.TextureResType.plistType)
        end
    end
    
    btn:addClickEventListener(function ()
        my.playClickBtnSound()
        self:updateRechargeItem(index)
    end)
end

function ContinueRechargeCtrl:showSelectDayAni(index)
    local viewNode = self:getViewNode()
    local btnList = viewNode.rechargePanel:getChildByName("Node_BtnList"):getChildren()
    local rotation = 0
    if self._curIndex then
        local oldBtn = btnList[self._curIndex]
        local oldImg = oldBtn:getChildByName("Img_Guang")
        oldImg:setVisible(false)
        rotation = oldImg:getRotation()
    end
    self._curIndex = index
    local btn = btnList[self._curIndex]
    local img = btn:getChildByName("Img_Guang")
    img:setVisible(true)
    local rot = cc.RotateBy:create(1, 30)
    img:setRotation(rotation + 30)
    img:stopAllActions()
    img:runAction(cc.RepeatForever:create(cc.RotateBy:create(1, 60)))
end

-- 根据天数显示当天的充值奖品
function ContinueRechargeCtrl:updateRechargeItem(index)
    self:showSelectDayAni(index)
    local config = ContinueRechargeModel:getConfig()
    local status = ContinueRechargeModel:getStatus()

    local viewNode = self:getViewNode()
    
    local dayReward = config.dayRewards[index]
    local itemListSub = {}
    for _, reward in pairs(dayReward.iteminfos) do
        table.insert(itemListSub, reward)
    end

    local itemListMain = {}
    local btnInfo = {
        currentIndex = index,
    }

    local addGoods = ContinueRechargeModel:getAddGoodsByDayNum(index)
    local normalGoods = ContinueRechargeModel:getNormalGoodsByDayNum(index)

    -- 进入兑换阶段之后按照index当天的状态判断是正常签到的还是补签的
    if status.current > ContinueRechargeModel:getTotalDay() then
        if ContinueRechargeModel:getCheckedByDayNumber(index) then
            local info = {
                itemid = 1,
                count = normalGoods.param.productnum,
                countable = 1
            }
            table.insert(itemListMain, info)
            btnInfo.goodsInfo = normalGoods
        else
            local info = {
                itemid = 1,
                count = addGoods.param.productnum,
                countable = 1
            }
            table.insert(itemListMain, info)
            btnInfo.goodsInfo = addGoods
        end
    else
        if index < status.current then
            local info = {
                itemid = 1,
                count = addGoods.param.productnum,
                countable = 1
            }
            table.insert(itemListMain, info)
            btnInfo.goodsInfo = addGoods
        else
            local info = {
                itemid = 1,
                count = normalGoods.param.productnum,
                countable = 1
            }
            table.insert(itemListMain, info)
            btnInfo.goodsInfo = normalGoods
        end
    end
    
    if ContinueRechargeModel:getCheckedByDayNumber(index) then
        local user = mymodel('UserModel'):getInstance()
        local key = "ContinueRechargeCacheKey".. user.nUserID .. status.buydate
        local cache = CacheModel:getCacheByKey(key)
        local strIndex = tostring(index)
        if cache[strIndex] and cache[strIndex] == 1 then --显示补签物品
            local info = {
                itemid = 1,
                count = addGoods.param.productnum,
                countable = 1
            }
            itemListMain = {}
            table.insert(itemListMain, info)
            btnInfo.goodsInfo = addGoods
        end
    end
    self:updateBuyBtn(btnInfo)
    self:initItem(viewNode.rewardMainNode, itemListMain)
    self:initItem(viewNode.rewardSubNode, itemListSub)

end

-- 初始化每个奖品的信息
function ContinueRechargeCtrl:initItem(itemNode, itemList)
    if #itemList < 1 then return end

    local imgIcon = itemNode:getChildByName("Icon")
    local itemText = itemNode:getChildByName("Text")
    local aniNode = itemNode:getChildByName("Ani_Node")
    aniNode:removeAllChildren()
    imgIcon:show()

    if #itemList > 1 then
        -- 大于一个的时候变成礼包
        imgIcon:loadTexture('hallcocosstudio/images/plist/huafei/img_suijidaoju2.png', ccui.TextureResType.plistType)
        itemNode:addTouchEventListener(function (sender, event)
            if event == ccui.TouchEventType.ended or event == ccui.TouchEventType.canceled then
                self:hideBagDetail()
            elseif event == ccui.TouchEventType.began then
                self:showBagDetail(cc.p(itemNode:getPosition()), itemList)
            end
        end)

        itemText:setString("神秘礼包")
    else
        local itemInfo = itemList[1]
        if itemInfo.itemid == 1 then
            local resPath = "hallcocosstudio/images/plist/RewardCtrl/Img_Silver3.png"
            imgIcon:loadTexture(resPath, ccui.TextureResType.localType)
            itemText:setString(itemInfo.count .. "两")
        else
            local path = RewardTipDef:getItemImgPath(itemInfo.itemid, itemInfo.count)
            if imgIcon and path then
                imgIcon:loadTexture(path, ccui.TextureResType.plistType)
            end
            itemText:setString(RewardTipDef:getItemShortName(itemInfo.itemid, itemInfo.count))
        end
    end
end

function ContinueRechargeCtrl:hideBagDetail()
    local nodeDetail = self:getViewNode().nodeDetail
    nodeDetail:hide()
end

function ContinueRechargeCtrl:showBagDetail(pos, itemList)
    local viewNode = self:getViewNode()
    -- 位置调整
    local nodeDetail = viewNode.nodeDetail
    nodeDetail:show()
    local imgBG = nodeDetail:getChildByName("Img_BG")
    local size = imgBG:getContentSize()
    nodeDetail:setPosition(cc.p(pos.x - size.width / 2 + 10, pos.y + size.height / 2 - 20))

    -- 信息设置
    local strList = {}
    for _, v in pairs(itemList) do
        table.insert(strList, RewardTipDef:getItemName(v.itemid, v.count))
    end
    local res = table.concat(strList, "\n")
    local text = nodeDetail:getChildByName("Text_jiangli")
    text:setString(res)
end

function ContinueRechargeCtrl:updateBuyBtn(param)
    local buyBtn = self:getViewNode().buyBtn

    buyBtn:getChildByName('fnt_jiage'):setString(param.goodsInfo.price  .. "元可购买")
    if ContinueRechargeModel:getCheckedByDayNumber(param.currentIndex) then
        buyBtn:setEnabled(false)
        buyBtn:setColor(cc.c3b(200, 200, 200))
    else
        buyBtn:setEnabled(true)
        buyBtn:setColor(cc.c3b(255, 255, 255))
    end
    buyBtn:addClickEventListener(function ()
        my.playClickBtnSound()
        local converted = cc.exports.convertFormat(param.goodsInfo.param)
        converted.productname = MCCharset:getInstance():gb2Utf8String(converted.productname, string.len(converted.productname))
        converted.title = MCCharset:getInstance():gb2Utf8String(converted.title, string.len(converted.title))
        converted.notetip = MCCharset:getInstance():gb2Utf8String(converted.notetip, string.len(converted.notetip))
        converted.product_subject = MCCharset:getInstance():gb2Utf8String(converted.product_subject, string.len(converted.product_subject))
        converted.product_body = MCCharset:getInstance():gb2Utf8String(converted.product_body, string.len(converted.product_body))
        if not converted then
            dump("[ERROR] convert format failed...")
            my.informPluginByName({pluginName = 'ToastPlugin', params = { tipString = "充值异常,请您稍后重试", removeTime = 2}})
            return
        end
        ContinueRechargeModel:setExchangeID(param.goodsInfo.param.exchangeid)
        local shopModel = mymodel("ShopModel"):getInstance()
        shopModel:PayForProduct(converted) 
    end)
end

function ContinueRechargeCtrl:onHuafeiRsp()
    if self._waitHuafeiExchange then
        self._waitHuafeiExchange()
    end
    self:refresh()
    my.informPluginByName({pluginName = 'TipPlugin', params = {tipString = "话费兑换成功", removeTime = 1}})
end

function ContinueRechargeCtrl:refresh()
    self:refreshRechargePanel()
    self:refreshExchangePanel()
    self:UpdateTips()
    self:hideBagDetail()
end

function ContinueRechargeCtrl:goBack()
    --每日登录弹框
    PluginProcessModel:PopNextPlugin()
    ContinueRechargeCtrl.super.removeSelf(self)
end

function ContinueRechargeCtrl:onKeyBack()
    PluginProcessModel:stopPluginProcess()
    ContinueRechargeCtrl.super.removeSelf(self)
end


return ContinueRechargeCtrl