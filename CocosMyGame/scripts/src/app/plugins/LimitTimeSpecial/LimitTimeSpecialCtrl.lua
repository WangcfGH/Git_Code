local LimitTimeSpecialCtrl = class("LimitTimeSpecialCtrl", cc.load('BaseCtrl'))
local LimitTimeSpecialView = import('src.app.plugins.LimitTimeSpecial.LimitTimeSpecialView')
local ShopModel = mymodel("ShopModel"):getInstance()
local LimitTimeSpecialModel     = import("src.app.plugins.firstrecharge.FirstRechargeModel"):getInstance()
local LimitTimeSpecialDef       = import('src.app.plugins.firstrecharge.FirstRechargeDef')
local CenterCtrl = require('src.app.BaseModule.CenterCtrl'):getInstance()
local PluginProcessModel = mymodel('hallext.PluginProcessModel'):getInstance()

function LimitTimeSpecialCtrl:onCreate()
    self:setView(LimitTimeSpecialView)
    LimitTimeSpecialView:setCtrl(self)
	local viewNode = self:setViewIndexer(LimitTimeSpecialView:createViewIndexer())
    self._viewNode = viewNode

    self:initialListenTo()
    self:initialBtnClick()
    self:updateUI()

    LimitTimeSpecialModel:gc_GetSpecialGiftInfo()
end

function LimitTimeSpecialCtrl:initialListenTo()
    self:listenTo(LimitTimeSpecialModel, LimitTimeSpecialDef.LimitTimeSpecialInfoRet, handler(self,self.updateUI))
end

function LimitTimeSpecialCtrl:initialBtnClick()
    local viewNode = self._viewNode
    viewNode.closeBtn:addClickEventListener(handler(self, self.onClickClose))
    viewNode.BtnBuy:addClickEventListener(handler(self, self.buySpecialGiftItem))
end

function LimitTimeSpecialCtrl:updateUI()
    if not self._viewNode then return end

    local specialGiftInfo = LimitTimeSpecialModel:GetSpecialGiftInfo()
    local specialGiftConfig = LimitTimeSpecialModel:GetSpecialGiftConfig()
    if not specialGiftInfo or not specialGiftConfig then
        LimitTimeSpecialModel:gc_GetSpecialGiftInfo()
        return
    end

    local rewardList = specialGiftConfig.RewardList
    local ActivityDetail = specialGiftConfig.FirstRecharge[2]

    -- 礼包银两数量
    for i = 1,3 do 
        local rewardID = ActivityDetail.RewardConfig[i].RewardID
        for u, v in pairs(rewardList) do
            if v.RewardID == rewardID then
                self._viewNode.PanelAnimation:getChildByName("Panel_Silver"..i):getChildByName("Text_Silver"):setString(v.RewardCount.."两")
                self._viewNode.PanelAnimation:getChildByName("Panel_Silver"..i):getChildByName("Text_Price"):setString("价值"..v.Price.."元")

                --不同规格银两数量显示不同图片
                if v.RewardCount <= 2500 then
                    self._viewNode.PanelAnimation:getChildByName("Panel_Silver"..i):getChildByName("Image_Silver"):loadTexture("hallcocosstudio/images/plist/FirstRecharge/FirstRecharge_Silver1.png" ,ccui.TextureResType.plistType)
                elseif v.RewardCount <= 5000 then
                    self._viewNode.PanelAnimation:getChildByName("Panel_Silver"..i):getChildByName("Image_Silver"):loadTexture("hallcocosstudio/images/plist/FirstRecharge/FirstRecharge_Silver2.png",ccui.TextureResType.plistType)
                elseif v.RewardCount <= 20000 then
                    self._viewNode.PanelAnimation:getChildByName("Panel_Silver"..i):getChildByName("Image_Silver"):loadTexture("hallcocosstudio/images/plist/FirstRecharge/FirstRecharge_Silver3.png",ccui.TextureResType.plistType)
                elseif v.RewardCount > 20000 then
                    self._viewNode.PanelAnimation:getChildByName("Panel_Silver"..i):getChildByName("Image_Silver"):loadTexture("hallcocosstudio/images/plist/FirstRecharge/FirstRecharge_Silver4.png",ccui.TextureResType.plistType)
                end

                if v.RewardType == 3 then  --记牌器
                    self._viewNode.PanelAnimation:getChildByName("Panel_Silver"..i):getChildByName("Text_Silver"):setString("记牌器*"..v.RewardCount.."天")
                    self._viewNode.PanelAnimation:getChildByName("Panel_Silver"..i):getChildByName("Image_Silver"):loadTexture("hallcocosstudio/images/plist/FirstRecharge/card_maker.png",ccui.TextureResType.plistType)
                end

                self._viewNode.PanelAnimation:getChildByName("Panel_Silver"..i):getChildByName("Image_Status"):setVisible(false)
                if specialGiftInfo.NewFirstRechargeStatus.nPayStatus == 1 then   --充值完成
                    self._viewNode.PanelAnimation:getChildByName("Panel_Silver"..i):getChildByName("Image_Status"):setVisible(true)
                end
            end
        end
    end
    
    local yellowBtnName = {"hallcocosstudio/images/plist/FirstRecharge/Img_today_yellow.png","hallcocosstudio/images/plist/FirstRecharge/Img_tom_yellow.png","hallcocosstudio/images/plist/FirstRecharge/Img_tri_yellow.png"}
    local grayBtnName = {"hallcocosstudio/images/plist/FirstRecharge/Img_today_gray.png","hallcocosstudio/images/plist/FirstRecharge/Img_tom_gray.png","hallcocosstudio/images/plist/FirstRecharge/Img_tri_gray.png"}
    local tCurDate = os.date("*t")
    local curDate = os.time({year = tCurDate.year, month = tCurDate.month, day = tCurDate.day})
    local nStartDate = specialGiftInfo.NewFirstRechargeStatus.nStartDate
    local startDate = nil
    local diffDay = nil
    if specialGiftInfo.NewFirstRechargeStatus.nPayStatus == 1 and type(nStartDate) == "number" then
        local year = math.floor(nStartDate/10000)
        local month = math.floor((nStartDate - year*10000) / 100)
        local day = math.floor(nStartDate%100)
        startDate = os.time({year = year, month = month, day = day})
        diffDay = math.floor((curDate - startDate) /86400)
    end
    local takedName = "hallcocosstudio/images/plist/FirstRecharge/HasTaken.png"
    for i = 1,3 do 
        local rewardID = ActivityDetail.ActivityDetail[i].RewardID
        for u, v in pairs(rewardList) do
            if v.RewardID == rewardID then
                self._viewNode.PanelAnimation:getChildByName("Panel_Task"..i):getChildByName("Text_Silver"):setString(v.RewardCount.."两")
                self._viewNode.PanelAnimation:getChildByName("Panel_Task"..i):getChildByName("Text_Price"):setVisible(false)

                --不同规格银两数量显示不同图片
                if v.RewardCount <= 2500 then
                    self._viewNode.PanelAnimation:getChildByName("Panel_Task"..i):getChildByName("Image_Silver"):loadTexture("res/hallcocosstudio/images/png/FirstRecharge_Silver1.png")
                elseif v.RewardCount <= 5000 then
                    self._viewNode.PanelAnimation:getChildByName("Panel_Task"..i):getChildByName("Image_Silver"):loadTexture("res/hallcocosstudio/images/png/FirstRecharge_Silver2.png")
                elseif v.RewardCount <= 20000 then
                    self._viewNode.PanelAnimation:getChildByName("Panel_Task"..i):getChildByName("Image_Silver"):loadTexture("res/hallcocosstudio/images/png/FirstRecharge_Silver3.png")
                elseif v.RewardCount > 20000 then
                    self._viewNode.PanelAnimation:getChildByName("Panel_Task"..i):getChildByName("Image_Silver"):loadTexture("res/hallcocosstudio/images/png/FirstRecharge_Silver4.png")
                end
            end
        end

        local panelTask = self._viewNode.PanelAnimation:getChildByName("Panel_Task"..i)
        local btnPlay = panelTask:getChildByName("Button_Play")
        local fnt = btnPlay:getChildByName("Fnt_Bout")
        fnt:setVisible(false)
        local imgStatus = panelTask:getChildByName("Image_Status")
        imgStatus:setVisible(false)

        btnPlay:loadTextureNormal(grayBtnName[i],ccui.TextureResType.plistType)
        btnPlay:setTouchEnabled(false)
        if specialGiftInfo.NewFirstRechargeStatus.nPayStatus == 1 then
            if specialGiftInfo.NewFirstRechargeStatus.nStatus[i] == LimitTimeSpecialDef.FIRST_RECHARGE_TAKED then
                btnPlay:loadTextureNormal(takedName,ccui.TextureResType.plistType)
            elseif specialGiftInfo.NewFirstRechargeStatus.nStatus[i] == LimitTimeSpecialDef.FIRST_RECHARGE_UNTAKE then
                btnPlay:loadTextureNormal(yellowBtnName[1],ccui.TextureResType.plistType)
                local function callback()
                    print("limitTimeSpecial button"..specialGiftInfo.NewFirstRechargeStatus.nStatus[i]..ActivityDetail.RechargeExchangeID..i)
                    self:playEffectOnPress()
                    self:goToTask(specialGiftInfo.NewFirstRechargeStatus.nStatus[i],ActivityDetail.RechargeExchangeID,i)
                end
                btnPlay:addClickEventListener(callback)
                btnPlay:setTouchEnabled(true)
            elseif type(diffDay) == "number" 
            and specialGiftInfo.NewFirstRechargeStatus.nStatus[i] == LimitTimeSpecialDef.FIRST_RECHARGE_UNSTARTED then
                if diffDay == 0 then
                    if i == 1 then
                        btnPlay:loadTextureNormal(grayBtnName[1],ccui.TextureResType.plistType)
                    elseif i == 2 then
                        btnPlay:loadTextureNormal(grayBtnName[2],ccui.TextureResType.plistType)
                    elseif i == 3 then
                        btnPlay:loadTextureNormal(grayBtnName[3],ccui.TextureResType.plistType)
                    end
                elseif diffDay == 1 then
                    if i == 1 then
                        btnPlay:loadTextureNormal(grayBtnName[1],ccui.TextureResType.plistType)
                    elseif i == 2 then
                        btnPlay:loadTextureNormal(grayBtnName[1],ccui.TextureResType.plistType)
                    elseif i == 3 then
                        btnPlay:loadTextureNormal(grayBtnName[2],ccui.TextureResType.plistType)
                    end
                elseif diffDay >= 2 then
                    if i == 1 then
                        btnPlay:loadTextureNormal(grayBtnName[1],ccui.TextureResType.plistType)
                    elseif i == 2 then
                        btnPlay:loadTextureNormal(grayBtnName[1],ccui.TextureResType.plistType)
                    elseif i == 3 then
                        btnPlay:loadTextureNormal(grayBtnName[1],ccui.TextureResType.plistType)
                    end
                end
            elseif specialGiftInfo.NewFirstRechargeStatus.nStatus[i] ==  LimitTimeSpecialDef.FIRST_RECHARGE_OUTDATE then  --已过期
                self._viewNode.PanelAnimation:getChildByName("Panel_Task"..i):getChildByName("Image_Status"):setVisible(true)
                self._viewNode.PanelAnimation:getChildByName("Panel_Task"..i):getChildByName("Image_Status"):loadTexture("OutDate.png",ccui.TextureResType.plistType)
            end
        end
    end

    self._viewNode.PanelAnimation:getChildByName("Button_Buy"):getChildByName("Fnt_Buy"):setString(ActivityDetail.DiscountPrice.."元抢购")
    self._viewNode.Fnt_Price:setString(ActivityDetail.DiscountPrice.."元")

    self._exchangeid = ActivityDetail.RechargeExchangeID
    self._price = ActivityDetail.DiscountPrice

    --倒计时
    self._viewNode.PanelAnimation:getChildByName("Text_RemainTime"):setVisible(false)
    self._viewNode.PanelAnimation:getChildByName("Image_Icon"):setVisible(false)
    if specialGiftInfo.NewFirstRechargeStatus.nPayStatus == 0 then
        self._viewNode.PanelAnimation:getChildByName("Text_RemainTime"):setVisible(true)
        self:updateTimeInterval(specialGiftInfo.NewFirstRechargeStatus.nRemainTime)
    end

    if not self._viewNode then return end       -- 多加一层判空

    self:freshButtonBuyStatus()   --刷新购买按钮信息
    self:playRewardAnimation()
    --不在活动范围冿
    if not LimitTimeSpecialModel:isSpecialGiftAlive() or not LimitTimeSpecialModel:isShowSpecialGift() then
        self:goBack()
        return
    end
end

function LimitTimeSpecialCtrl:updateTimeInterval(nTimeInterval)
    local surplusTime = tonumber(nTimeInterval) - 86400 * 2                 -- 为了保证兼容性，客户端手动减去两天的时间
    if surplusTime > 0 then
        self._timeCount = surplusTime
        if self._giftTimer == nil then
            self:refreshGiftTime(self._timeCount)
            self._giftTimer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
                self._timeCount = self._timeCount - 1
                self:refreshGiftTime(self._timeCount)
            end, 1.0, false)
        end
    else
        self:unRegisterGiftTimer()
        self:goBack()
    end
end

function LimitTimeSpecialCtrl:refreshGiftTime(time)
    if time <= 0 then
         self:unRegisterGiftTimer()
         self:goBack()
    else
        local dayNum, hourNum, minutesNum, secondNum = self:formatSeconds(time)
        if not self._viewNode then return end
        if not  self._viewNode.PanelAnimation:getChildByName("Text_RemainTime") then return end
        self._viewNode.PanelAnimation:getChildByName("Text_RemainTime"):setString("剩余时间:"..dayNum*24+hourNum..":"..minutesNum..":"..secondNum)
    end
end

function LimitTimeSpecialCtrl:formatSeconds(time)
    if not time then return end

    local daySpan    = 24*60*60
    local hourSpan   = 60*60
    local dayNum     = math.floor(time / daySpan)
    local hourNum    = math.floor((time - dayNum * daySpan) / hourSpan)
    local minutesNum = math.floor((time - dayNum * daySpan - hourNum * hourSpan) / 60)
    local secondNum  = time - dayNum * daySpan - hourNum * hourSpan - minutesNum * 60
    
    if dayNum < 0     then dayNum     = 0 end
    if hourNum < 0    then hourNum    = 0 end
    if minutesNum < 0 then minutesNum = 0 end
    if secondNum < 0  then secondNum  = 0 end

    return dayNum, hourNum, minutesNum, secondNum
end

function LimitTimeSpecialCtrl:goToTask(nStatus,nExchangeID,nDay) 
    if not CenterCtrl:checkNetStatus() then
        self:removeSelfInstance()
        return
    end

    local info = LimitTimeSpecialModel:GetSpecialGiftInfo()
    if not info then return end

    local GAP_SCHEDULE = 2 --间隔时间2秒
    local nowTime = os.time()
    self._lastTime = self._lastTime or 0
    if nowTime - self._lastTime > GAP_SCHEDULE then
        self._lastTime = nowTime
    else
        my.informPluginByName({pluginName = 'TipPlugin',params = {tipString = "点击太频繁，请2秒后再操作", removeTime = 3}})
        return
    end

    if nStatus == LimitTimeSpecialDef.FIRST_RECHARGE_STARTING then
        if my.isInGame() then   --游戏中点去对局直接关闭
            self:goBack()
            return
        end
        --触发快速开始的逻辑
        my.dataLink(cc.exports.DataLinkCodeDef.LIMIT_TIME_SPECIAL_CLICK_PLAY)
        local HallContext = import('src.app.plugins.mainpanel.HallContext'):getInstance()
        HallContext:dispatchEvent({name = HallContext.EVENT_MAP["hall_gotoGameByQuickStart"], value = {["autoDecideRoomScope"] = true}})
    elseif nStatus == LimitTimeSpecialDef.FIRST_RECHARGE_UNTAKE then
        LimitTimeSpecialModel:gc_SpecialGiftTakeReward(nExchangeID, nDay)
    end
end

function LimitTimeSpecialCtrl:freshButtonBuyStatus() 
    --提示文字
    self._viewNode.BtnBuy:setVisible(true)
    self._viewNode.PanelAnimation:getChildByName("Text_Tips"):setVisible(false)

    local specialGiftInfo = LimitTimeSpecialModel:GetSpecialGiftInfo()
    local spcialGiftConfig = LimitTimeSpecialModel:GetSpecialGiftConfig()
    if not specialGiftInfo or not spcialGiftConfig then
        LimitTimeSpecialModel:gc_GetSpecialGiftInfo()
        return
    end
    if specialGiftInfo.NewFirstRechargeStatus.nPayStatus == 1 then   --充值完成
        self._viewNode.BtnBuy:setVisible(false)
        for i = 1,3 do 
            if specialGiftInfo.NewFirstRechargeStatus.nStatus[i] ==  LimitTimeSpecialDef.FIRST_RECHARGE_UNSTARTED then  --已完成
                self._viewNode.PanelAnimation:getChildByName("Text_Tips"):setVisible(true)
                self._viewNode.PanelAnimation:getChildByName("Text_Tips"):setString("明日要来领奖哦~")
            end
        end
        for i = 1,3 do
            if specialGiftInfo.NewFirstRechargeStatus.nStatus[i] == LimitTimeSpecialDef.FIRST_RECHARGE_UNTAKE then  --领取奖励
                self._viewNode.PanelAnimation:getChildByName("Text_Tips"):setVisible(true)
                self._viewNode.PanelAnimation:getChildByName("Text_Tips"):setString("有奖励未领取哦~")
            end
        end
    end
end

function LimitTimeSpecialCtrl:playRewardAnimation()
    local specialGiftInfo = LimitTimeSpecialModel:GetSpecialGiftInfo()
    local specialGiftConfig = LimitTimeSpecialModel:GetSpecialGiftConfig()
    if not specialGiftInfo or not specialGiftConfig then
        LimitTimeSpecialModel:gc_GetSpecialGiftInfo()
        return
    end

    local bShowEffct  = specialGiftInfo.NewFirstRechargeStatus.nPayStatus == 0
    if bShowEffct then
        self._viewNode:runTimelineAction("animation0", true)
    end

    --骨骼动画
    local nodeJi = self._viewNode.PanelAnimation:getChildByName("Node_Ji")
    local nodeName = "nodeSkeletonAni"

    local jsonPath = "res/hallcocosstudio/images/skeleton/FirstRecharge/Ji/ji_xsth.json"
    local atlasPath = "res/hallcocosstudio/images/skeleton/FirstRecharge/Ji/ji_xsth.atlas"
    local aniNames = "ji_xsth"

    local nodeAni = nodeJi:getChildByName(nodeName)
    if nodeAni ~= nil then
        return
    end
	if nodeJi:getChildByName(nodeName) == nil then
		nodeAni = sp.SkeletonAnimation:create(jsonPath, atlasPath, 1.0)  
		nodeAni:setAnimation(0, aniNames, true)
		nodeAni:setDebugBonesEnabled(false)
		nodeAni:setName(nodeName)
		nodeJi:addChild(nodeAni)
	end

    --花草骨骼动画
    local nodeMount = self._viewNode.PanelAnimation:getChildByName("Node_Hua")
    nodeName = "nodeSkeletonAni"
    jsonPath = "res/hallcocosstudio/images/skeleton/FirstRecharge/Hua/huacao.json"
    atlasPath = "res/hallcocosstudio/images/skeleton/FirstRecharge/Hua/huacao.atlas"
    aniNames = "huacao1"

    local nodeAni = nodeMount:getChildByName(nodeName)
    if nodeAni ~= nil then
        return
    end
	if nodeMount:getChildByName(nodeName) == nil then
		nodeAni = sp.SkeletonAnimation:create(jsonPath, atlasPath, 1.0)  
		nodeAni:setAnimation(0, aniNames, true)
		nodeAni:setDebugBonesEnabled(false)
		nodeAni:setName(nodeName)
		nodeMount:addChild(nodeAni)
	end

    --花草骨骼动画2
    local nodeMount2 = self._viewNode.PanelAnimation:getChildByName("Node_Hua2")
    nodeName = "nodeSkeletonAni2"
    aniNames = "huacao2"

    local nodeAni2 = nodeMount2:getChildByName(nodeName)
    if nodeAni2 ~= nil then
        return
    end
	if nodeMount2:getChildByName(nodeName) == nil then
		nodeAni2 = sp.SkeletonAnimation:create(jsonPath, atlasPath, 1.0)  
		nodeAni2:setAnimation(0, aniNames, true)
		nodeAni2:setDebugBonesEnabled(false)
		nodeAni2:setName(nodeName)
		nodeMount2:addChild(nodeAni2 )
	end

    --标题星星动画
    local aniFile = "res/hallcocosstudio/FirstRecharge/biaoti.csb"
    local aniNodeTitle = self._viewNode.PanelAnimation:getChildByName("Ani_Title")
    aniNodeTitle:stopAllActions()
    aniNodeTitle:setVisible(true)
    local action = cc.CSLoader:createTimeline(aniFile)
    if not tolua.isnull(action) then
        aniNodeTitle:runAction(action)
        action:play("animation0", true)
    end


    --奖励物品动画
    local aniFile = "res/hallcocosstudio/FirstRecharge/wuping.csb"
    for i = 1,3 do 
        local aniNode = self._viewNode.PanelAnimation:getChildByName("Panel_Silver"..i):getChildByName("Ani_Effect")
        aniNode:stopAllActions()
        aniNode:setVisible(false)
        --后续需要用到
        local bShowEffct  = specialGiftInfo.NewFirstRechargeStatus.nPayStatus == 0
        if bShowEffct then
            local action = cc.CSLoader:createTimeline(aniFile)
            if not tolua.isnull(action) then
                aniNode:runAction(action)
                action:play("animation0", true)
            end
            aniNode:setVisible(true)
        else
            aniNode:setVisible(false)
        end
    end
end

function LimitTimeSpecialCtrl:takeRelief()
    if my.isInGame() then   --游戏中点关闭能领低保领低保
        local ReliefActivity=mymodel('hallext.ReliefActivity'):getInstance()
        local config = ReliefActivity.config
	    local state = ReliefActivity.state

        local bCanGetWelfare = false

        local user = mymodel('UserModel'):getInstance()
        print("LimitTimeSpecialCtrl:takeRelief"..state..user.nDeposit..config.Limit.LowerLimit)
        if state == 'SATISFIED' and user.nDeposit < config.Limit.LowerLimit then
            bCanGetWelfare = true
        end

        if bCanGetWelfare then
            my.informPluginByName({pluginName='ReliefCtrl',params={fromSence = ReliefDef.FROM_SCENE_FIRSTRECHARGE}})
        elseif ReliefActivity:isVideoAdReliefValid() then
            -- 视频低保
            my.informPluginByName({pluginName='ReliefCtrl',params={fromSence = ReliefDef.FROM_SCENE_FIRSTRECHARGE, VideoAdRelief = true}})
        end
    end
end

function LimitTimeSpecialCtrl:onClickClose()
    self:takeRelief()
    my.playClickBtnSound()
    self:goBack()
end

function LimitTimeSpecialCtrl:unRegisterGiftTimer()
    if self._giftTimer then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._giftTimer)
        self._giftTimer = nil
    end
end

function LimitTimeSpecialCtrl:goBack()
    --每日登录弹框
    PluginProcessModel:PopNextPlugin()

    self:unRegisterGiftTimer()
    LimitTimeSpecialCtrl.super.removeSelf(self)

    if self._params and self._params.closeCallback and type(self._params.closeCallback) == "function" then
        self._params.closeCallback()
    end
end

function LimitTimeSpecialCtrl:buySpecialGiftItem()
    if not CenterCtrl:checkNetStatus() then
        self:removeSelfInstance()
        return
    end

    local GAP_SCHEDULE = 60 --间隔时间60秒  --策划需求
    local nowTime = os.time()
    self._lastTime = self._lastTime or 0
    if nowTime - self._lastTime > GAP_SCHEDULE then
        self._lastTime = nowTime
    else
        my.informPluginByName({pluginName = 'TipPlugin',params = {tipString = "点击太频繁，请于一分钟后再尝试", removeTime = 3}})
        return
    end

    if self._exchangeid and self._price then
        print("LimitTimeSpecialCtrl:buySpecialGiftItem, price "..self._price.."exchangeid:"..self._exchangeid)
        LimitTimeSpecialModel:_payFor(self._price,self._exchangeid)
    end
end

return LimitTimeSpecialCtrl