local GoldSilverBuyLayerCtrl = class('GoldSilverBuyLayerCtrl', cc.load('BaseCtrl'))
local GoldSilverBuyLayerView = require("src.app.plugins.goldsilver.GoldSilverBuyLayerView")
local GoldSilverModel = import("src.app.plugins.goldsilver.GoldSilverModel"):getInstance()
local Def = require('src.app.plugins.goldsilver.GoldSilverDef')
local MyTimeStamp = import('src.app.mycommon.mytimestamp.MyTimeStamp'):getInstance()

function GoldSilverBuyLayerCtrl:onCreate(param)
    local viewNode = self:setViewIndexer(GoldSilverBuyLayerView:createViewIndexer(self))
    self._viewNode = viewNode
    cc.exports.zeroBezelNodeAutoAdapt(self._viewNode:getChildByName("Operate_Panel"))
    self:initialBtnClick()
    
    self:updateUI()
end

function GoldSilverBuyLayerCtrl:initialBtnClick( )
    local viewNode = self._viewNode

    viewNode.Btn_Close:addClickEventListener(handler(self, self.onClose))
    viewNode.Btn_UnLockSilver:addClickEventListener(handler(self, self.unLockSilver))
    viewNode.Btn_UnLockGold:addClickEventListener(handler(self, self.unLockGold))
end

function GoldSilverBuyLayerCtrl:updateUI( )
    local info = GoldSilverModel:GetGoldSilverInfo()
    local rewardConfig = GoldSilverModel:GetGoldSilverRewardConfig()

    if not info or not rewardConfig then
        GoldSilverModel:GoldSilverInfoReq()
        return
    end

    local viewNode = self._viewNode
    local apptype = GoldSilverModel:AppType()
    local payLevel = info.nPayLevel
    local silverPrice = GoldSilverModel:GetItem(apptype,Def.PAY_TYPE_SILVER,payLevel)
    local goldPrice = GoldSilverModel:GetItem(apptype,Def.PAY_TYPE_GOLD,payLevel)
    local nSilverSilver = 0
    local nSilverTicket = 0
    local nGoldSilver = 0
    local nGoldTicket =0

    for i=1,#rewardConfig do
        local item = rewardConfig[i]["stReward"]
        if item then
            nSilverSilver = nSilverSilver + item.nSilverSilver
            nSilverTicket = nSilverTicket + item.nSilverTicket
            nGoldSilver = nGoldSilver + item.nGoldSilver
            nGoldTicket = nGoldTicket + item.nGoldTicket
        end
    end
    local silverValue
    local goldValue
    if GoldSilverModel:IsHejiPackage() then
        silverValue = (nSilverSilver + nSilverTicket*100)/5000
        goldValue = (nGoldSilver + nGoldTicket*100)/5000
    else
        silverValue = (nSilverSilver + nSilverTicket*100)/10000
        goldValue = (nGoldSilver + nGoldTicket*100)/10000
    end
    viewNode.Text_Silver:setString(string.format( "%d元可以获得价值%d元的银两", silverPrice, silverValue))
    viewNode.Text_Gold:setString(string.format( "%d元可以获得价值%d元的银两和礼券", goldPrice, goldValue))


    if info.nSilverBuyStatus == 0 then
        viewNode.Btn_UnLockSilver:setVisible(true)
        viewNode.Img_SilverUnlocked:setVisible(false)
    else
        viewNode.Btn_UnLockSilver:setVisible(false)
        viewNode.Img_SilverUnlocked:setVisible(true)
    end

    if info.nGoldBuyStatus == 0 then
        viewNode.Btn_UnLockGold:setVisible(true)
        viewNode.Img_GoldUnlocked:setVisible(false)
    else
        viewNode.Btn_UnLockGold:setVisible(false)
        viewNode.Img_GoldUnlocked:setVisible(true)
    end
end

function GoldSilverBuyLayerCtrl:onClose( )
    my.playClickBtnSound()
    self:removeSelfInstance()
end

function GoldSilverBuyLayerCtrl:onExit()
    my.informPluginByName({ pluginName = 'GoldSilverCtrl' })
end

function GoldSilverBuyLayerCtrl:unLockSilver( )
    my.playClickBtnSound()
    if not GoldSilverModel:IsDuringLastTwoDays() then
        --当金银杯活动剩余3天，且玩家等级小于等于10级时，玩家购买金杯银杯时弹出提示  20200305 by taoqiang
        local nowtimestamp = MyTimeStamp:getLatestTimeStamp()
        local nowDate = os.date('%Y%m%d',nowtimestamp)
        local dayDiff = tonumber(GoldSilverModel:GetEndData()) - tonumber(nowDate) - 1
        if GoldSilverModel:GetCurLevel() <= cc.exports.getGoldSilverTipLevelValue()  and dayDiff <= cc.exports.getGoldSilverTipDayValue() then
            local tipString = "活动即将结束，此时购买将有风险不能享受全额奖励，是否仍然确定购买?"
            local function callback()
                GoldSilverModel:payForReq(Def.PAY_TYPE_SILVER)
                self:removeSelfInstance()
                my.informPluginByName({ pluginName = 'GoldSilverCtrl' })
            end
            my.informPluginByName({pluginName = "ChooseDialog", params = {onOk = callback, tipContent = tipString }})
            return
        end

        if not cc.exports.isQRCodePaySupported() then
            GoldSilverModel:payForReq(Def.PAY_TYPE_SILVER)
        end

        self:removeSelfInstance()
        my.informPluginByName({ pluginName = 'GoldSilverCtrl' })
    else
        local tipString = "活动已结束，不能购买了哦"
        my.informPluginByName({pluginName='TipPlugin',params={tipString=tipString,removeTime=2.0}})
    end
end

function GoldSilverBuyLayerCtrl:unLockGold( )
    my.playClickBtnSound()
    if not GoldSilverModel:IsDuringLastTwoDays() then
        --当金银杯活动剩余3天，且玩家等级小于等于10级时，玩家购买金杯银杯时弹出提示  20200305 by taoqiang
        local nowtimestamp = MyTimeStamp:getLatestTimeStamp()
        local nowDate = os.date('%Y%m%d',nowtimestamp)
        local dayDiff = tonumber(GoldSilverModel:GetEndData()) - tonumber(nowDate) - 1
        if GoldSilverModel:GetCurLevel() <= cc.exports.getGoldSilverTipLevelValue()  and dayDiff <= cc.exports.getGoldSilverTipDayValue() then
            local tipString = "活动即将结束，此时购买将有风险不能享受全额奖励，是否仍然确定购买?"
            local function callback()
                GoldSilverModel:payForReq(Def.PAY_TYPE_GOLD)
                self:removeSelfInstance()
                my.informPluginByName({ pluginName = 'GoldSilverCtrl' })
            end
            my.informPluginByName({pluginName = "ChooseDialog", params = {onOk = callback, tipContent = tipString }})
            return
        end
        
        if not cc.exports.isQRCodePaySupported() then
            GoldSilverModel:payForReq(Def.PAY_TYPE_GOLD)
        end
        self:removeSelfInstance()
        my.informPluginByName({ pluginName = 'GoldSilverCtrl' })
    else
        local tipString = "活动已结束，不能购买了哦"
        my.informPluginByName({pluginName='TipPlugin',params={tipString=tipString,removeTime=2.0}})
    end
end

return GoldSilverBuyLayerCtrl