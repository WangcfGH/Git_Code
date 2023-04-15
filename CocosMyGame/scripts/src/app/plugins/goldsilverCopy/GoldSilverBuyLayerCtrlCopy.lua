local GoldSilverBuyLayerCtrlCopy = class('GoldSilverBuyLayerCtrlCopy', cc.load('BaseCtrl'))
local GoldSilverBuyLayerViewCopy = require("src.app.plugins.goldsilverCopy.GoldSilverBuyLayerViewCopy")
local GoldSilverModelCopy = import("src.app.plugins.goldsilverCopy.GoldSilverModelCopy"):getInstance()
local Def = require('src.app.plugins.goldsilverCopy.GoldSilverDefCopy')
local MyTimeStamp = import('src.app.mycommon.mytimestamp.MyTimeStamp'):getInstance()

function GoldSilverBuyLayerCtrlCopy:onCreate(param)
    local viewNode = self:setViewIndexer(GoldSilverBuyLayerViewCopy:createViewIndexer(self))
    self._viewNode = viewNode
    cc.exports.zeroBezelNodeAutoAdapt(self._viewNode:getChildByName("Operate_Panel"))
    self:initialBtnClick()
    
    self:updateUI()
end

function GoldSilverBuyLayerCtrlCopy:initialBtnClick( )
    local viewNode = self._viewNode

    viewNode.Btn_Close:addClickEventListener(handler(self, self.onClose))
    viewNode.Btn_UnLockSilver:addClickEventListener(handler(self, self.unLockSilver))
    viewNode.Btn_UnLockGold:addClickEventListener(handler(self, self.unLockGold))
end

function GoldSilverBuyLayerCtrlCopy:updateUI( )
    local info = GoldSilverModelCopy:GetGoldSilverInfo()
    local rewardConfig = GoldSilverModelCopy:GetGoldSilverRewardConfig()

    if not info or not rewardConfig then
        GoldSilverModelCopy:GoldSilverInfoReq()
        return
    end

    local viewNode = self._viewNode
    local apptype = GoldSilverModelCopy:AppType()
    local payLevel = info.nPayLevel
    local silverPrice = GoldSilverModelCopy:GetItem(apptype,Def.PAY_TYPE_SILVER,payLevel)
    local goldPrice = GoldSilverModelCopy:GetItem(apptype,Def.PAY_TYPE_GOLD,payLevel)
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
    if GoldSilverModelCopy:IsHejiPackage() then
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

function GoldSilverBuyLayerCtrlCopy:onClose( )
    my.playClickBtnSound()
    self:removeSelfInstance()
end

function GoldSilverBuyLayerCtrlCopy:onExit()
    my.informPluginByName({ pluginName = 'GoldSilverCtrlCopy' })
end

function GoldSilverBuyLayerCtrlCopy:unLockSilver( )
    my.playClickBtnSound()
    if not GoldSilverModelCopy:IsDuringLastTwoDays() then
        --当金银杯活动剩余3天，且玩家等级小于等于10级时，玩家购买金杯银杯时弹出提示  20200305 by taoqiang
        local nowtimestamp = MyTimeStamp:getLatestTimeStamp()
        local nowDate = os.date('%Y%m%d',nowtimestamp)
        local dayDiff = tonumber(GoldSilverModelCopy:GetEndData()) - tonumber(nowDate) - 1
        if GoldSilverModelCopy:GetCurLevel() <= cc.exports.getGoldSilverTipLevelCopyValue()  and dayDiff <= cc.exports.getGoldSilverTipDayCopyValue() then
            local tipString = "活动即将结束，此时购买将有风险不能享受全额奖励，是否仍然确定购买?"
            local function callback()
                GoldSilverModelCopy:payForReq(Def.PAY_TYPE_SILVER)
                self:removeSelfInstance()
                my.informPluginByName({ pluginName = 'GoldSilverCtrlCopy' })
            end
            my.informPluginByName({pluginName = "ChooseDialog", params = {onOk = callback, tipContent = tipString }})
            return
        end

        if not cc.exports.isQRCodePaySupported() then
            GoldSilverModelCopy:payForReq(Def.PAY_TYPE_SILVER)
        end

        self:removeSelfInstance()
        my.informPluginByName({ pluginName = 'GoldSilverCtrlCopy' })
    else
        local tipString = "活动已结束，不能购买了哦"
        my.informPluginByName({pluginName='TipPlugin',params={tipString=tipString,removeTime=2.0}})
    end
end

function GoldSilverBuyLayerCtrlCopy:unLockGold( )
    my.playClickBtnSound()
    if not GoldSilverModelCopy:IsDuringLastTwoDays() then
        --当金银杯活动剩余3天，且玩家等级小于等于10级时，玩家购买金杯银杯时弹出提示  20200305 by taoqiang
        local nowtimestamp = MyTimeStamp:getLatestTimeStamp()
        local nowDate = os.date('%Y%m%d',nowtimestamp)
        local dayDiff = tonumber(GoldSilverModelCopy:GetEndData()) - tonumber(nowDate) - 1
        if GoldSilverModelCopy:GetCurLevel() <= cc.exports.getGoldSilverTipLevelCopyValue()  and dayDiff <= cc.exports.getGoldSilverTipDayCopyValue() then
            local tipString = "活动即将结束，此时购买将有风险不能享受全额奖励，是否仍然确定购买?"
            local function callback()
                GoldSilverModelCopy:payForReq(Def.PAY_TYPE_GOLD)
                self:removeSelfInstance()
                my.informPluginByName({ pluginName = 'GoldSilverCtrlCopy' })
            end
            my.informPluginByName({pluginName = "ChooseDialog", params = {onOk = callback, tipContent = tipString }})
            return
        end
        
        if not cc.exports.isQRCodePaySupported() then
            GoldSilverModelCopy:payForReq(Def.PAY_TYPE_GOLD)
        end
        self:removeSelfInstance()
        my.informPluginByName({ pluginName = 'GoldSilverCtrlCopy' })
    else
        local tipString = "活动已结束，不能购买了哦"
        my.informPluginByName({pluginName='TipPlugin',params={tipString=tipString,removeTime=2.0}})
    end
end

return GoldSilverBuyLayerCtrlCopy