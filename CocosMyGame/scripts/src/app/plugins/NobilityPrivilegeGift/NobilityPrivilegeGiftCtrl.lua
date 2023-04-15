local NobilityPrivilegeGiftCtrl = class("NobilityPrivilegeGiftCtrl", cc.load('BaseCtrl'))
local NobilityPrivilegeGiftView = import('src.app.plugins.NobilityPrivilegeGift.NobilityPrivilegeGiftView')
local NobilityPrivilegeGiftModel      = import("src.app.plugins.NobilityPrivilegeGift.NobilityPrivilegeGiftModel"):getInstance()
local NobilityPrivilegeGiftDef        = import('src.app.plugins.NobilityPrivilegeGift.NobilityPrivilegeGiftDef')
local CenterCtrl = require('src.app.BaseModule.CenterCtrl'):getInstance()
local PluginProcessModel = mymodel('hallext.PluginProcessModel'):getInstance()

function NobilityPrivilegeGiftCtrl:onCreate()
	local viewNode = self:setViewIndexer(NobilityPrivilegeGiftView:createViewIndexer())
    self._viewNode = viewNode

    self:initialListenTo()
    self:initialBtnClick()
    self:updateUI()
    --NobilityPrivilegeGiftModel:gc_GetNobilityPrivilegeGiftInfo()
end

function NobilityPrivilegeGiftCtrl:initialListenTo( )
    self:listenTo(NobilityPrivilegeGiftModel, NobilityPrivilegeGiftDef.NobilityPrivilegeGiftInfoRet, handler(self,self.updateUI))
end

function NobilityPrivilegeGiftCtrl:initialBtnClick( )
    local viewNode = self._viewNode
    viewNode.closeBtn:addClickEventListener(handler(self, self.onClickClose))
    viewNode.BtnBuy:addClickEventListener(handler(self, self.buyChargeItem))
end

function NobilityPrivilegeGiftCtrl:updateUI()
    local viewNode = self._viewNode
    if not viewNode then return end

    local nobilityPrivilegeGiftInfo = NobilityPrivilegeGiftModel:GetNobilityPrivilegeGiftInfo()
    local nobilityPrivilegeGiftConfig = NobilityPrivilegeGiftModel:GetNobilityPrivilegeGiftConfig()
    if not nobilityPrivilegeGiftInfo or not nobilityPrivilegeGiftConfig then
        --NobilityPrivilegeGiftModel:gc_GetNobilityPrivilegeGiftInfo()
        return
    end

    self._viewNode:stopAllActions()
    self._viewNode:runTimelineAction("animation0", true)

    local nDiscountPrice = nobilityPrivilegeGiftInfo.curMemberTranDetail.discountPrice
    local nOriginalPrice = nobilityPrivilegeGiftInfo.curMemberTranDetail.originalPrice
    self._exchangeid  = nobilityPrivilegeGiftInfo.exchangeID
    self._price = nDiscountPrice
    viewNode.ListViewTip:getChildByName("Text_Point"):setString(nOriginalPrice.."点")
    viewNode.BtnBuy:getChildByName("Text_Buy"):setString("原价"..nOriginalPrice.."元")
    viewNode.BtnBuy:getChildByName("Fnt_Buy"):setString(nDiscountPrice.."元抢购")

    local rewardDetail = nobilityPrivilegeGiftInfo.curMemberTranDetail.rewardDetail
    local rewardList = nobilityPrivilegeGiftInfo.memberTransConfig.rewardList
    for i = 1,#rewardDetail do
        for u, v in pairs(rewardList) do
            if v.rewardID == rewardDetail[i].rewardID and v.rewardType == 1 then
                viewNode.PanelSilver:getChildByName("Text_Value"):setString(v.rewardCount)
            elseif v.rewardID == rewardDetail[i].rewardID and v.rewardType == 2 then
                viewNode.PanelNobility:getChildByName("Text_Value"):setString(v.rewardCount)
            end
        end
    end
    --倒计时
    self:updateTimeInterval(nobilityPrivilegeGiftInfo.memberRemainSeconds)
    --不在活动范围冿
    if not NobilityPrivilegeGiftModel:isAlive() then
        self:goBack()
        return
    end
end

function NobilityPrivilegeGiftCtrl:goBack()
    self:unRegisterGiftTimer()
    NobilityPrivilegeGiftCtrl.super.removeSelf(self)
end

function NobilityPrivilegeGiftCtrl:onClickClose()
    my.playClickBtnSound()
    self:goBack()
end

function NobilityPrivilegeGiftCtrl:onKeyBack()
    self:goBack()
end

function NobilityPrivilegeGiftCtrl:buyChargeItem()
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
        print("NobilityPrivilegeGiftCtrl:buyChargeItem, price "..self._price.."exchangeid:"..self._exchangeid)
        NobilityPrivilegeGiftModel:_payFor(self._price,self._exchangeid)
    end
end

function NobilityPrivilegeGiftCtrl:updateTimeInterval(nTimeInterval)
    if tonumber(nTimeInterval) > 0 then
        self._timeCount = nTimeInterval
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

function NobilityPrivilegeGiftCtrl:formatSeconds(time)
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

function NobilityPrivilegeGiftCtrl:refreshGiftTime(time)
    if time <= 0 then
         self:unRegisterGiftTimer()
         self:goBack()
    else
        local dayNum, hourNum, minutesNum, secondNum = self:formatSeconds(time)
        if not self._viewNode then return end
        if not  self._viewNode.PanelAnimation:getChildByName("Text_RemainTime") then return end

        if dayNum > 0 then
            self._viewNode.PanelAnimation:getChildByName("Text_RemainTime"):setString("剩余"..dayNum.."天")
        else
            self._viewNode.PanelAnimation:getChildByName("Text_RemainTime"):setString("倒计时:"..hourNum.."小时"..minutesNum.."分钟"..secondNum.."秒")
        end
    end
end

function NobilityPrivilegeGiftCtrl:unRegisterGiftTimer()
    if self._giftTimer then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._giftTimer)
        self._giftTimer = nil
    end
end

return NobilityPrivilegeGiftCtrl