local RewardTipCtrl    = class("RewardTipCtrl", cc.load('BaseCtrl'))
local viewCreater       = import("src.app.plugins.RewardTip.RewardTipView")
local Def               = import("src.app.plugins.RewardTip.RewardTipDef")

local player                =mymodel('hallext.PlayerModel'):getInstance()
local PluginProcessModel = mymodel('hallext.PluginProcessModel'):getInstance()
local CenterCtrl = require('src.app.BaseModule.CenterCtrl'):getInstance()

function RewardTipCtrl:onCreate(params, ...)
    self._viewNode = self:setViewIndexer(viewCreater:createViewIndexer())
    if params and params.callback then self._callBack = params.callback end
    if params and params.data then self._rewardList = params.data end
    if params and params.showOneByOne then self._showOneByOne = params.showOneByOne end
    if params and params.showtip then self._showtip = params.showtip end
    if params and params.paySuccess then self._paySuccess = params.paySuccess end
    if params and params.showOkOnly then self._showOkOnly = params.showOkOnly end
    if params and params.delayClick then self._delayClick = params.delayClick end
    if params and params.showMemberTip then self._showMemberTip = params.showMemberTip end
    if params and params.showRedPacket then self._showRedPacket = params.showRedPacket end
    if params and params.showRedPacketVocher then self._showRedPacketVocher = params.showRedPacketVocher end
    if params and params.showApply then self._showApply = params.showApply end
    if params and params.lotteryCount then self._lotteryCount = params.lotteryCount end
    if params and params.newUserReward then self._newUserReward = params.newUserReward end
    if params and params.sureCallBack then self._sureCallBack = params.sureCallBack end
    if params and params.canSkipNewUserGuide then self._canSkipNewUserGuide = params.canSkipNewUserGuide end

    self._showBtnExchange = false
    self._showBtnSeize = false
    self._showBtnPlay = false
    self._showBtnSure = true


    self:initListenTo()
    self:initBtnClick()
    self:init()
    self._enableClickTimer = my.scheduleOnce(function()
        self._enableClickSure = true
    end,0.5)
end

function RewardTipCtrl:onExit()
    if self._TimerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._TimerID)
        self._TimerID = nil
    end

    if self._enableClickTimer then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._enableClickTimer)
        self._enableClickTimer = nil
    end

    if self._callBack then
        self._callBack()
    end

end

function RewardTipCtrl:initListenTo( )
    self:listenTo(player,player.PLAYER_LOGIN_OFF,handler(self,self.onPlayLoginOff))
    self:listenTo(PluginProcessModel,PluginProcessModel.CLOSE_REWARD_TIP_CTRL,handler(self,self.onPlayLoginOff))
    self:listenTo(PluginProcessModel, PluginProcessModel.CLOSE_PLUGIN_ON_GUIDE,handler(self,self.onPlayLoginOff))
end

function RewardTipCtrl:initBtnClick()
    self._viewNode.Btn_Sure:addClickEventListener(handler(self,self.onClickSure))
    self._viewNode.Btn_ToExchange:addClickEventListener(handler(self,self.onClickBtnToExchange))
    self._viewNode.Btn_ToSeize:addClickEventListener(handler(self,self.onClickBtnToSeize))
    self._viewNode.Btn_ToPlay:addClickEventListener(handler(self,self.onClickBtnToPlay))
    self._viewNode.Btn_ToApply:addClickEventListener(handler(self,self.onClickBtnToApply))
end

--初始化发奖界面
function RewardTipCtrl:init()
    if type(self._rewardList)~='table' then return end
    local path = "res/hallcocosstudio/RewardCtrl/node_award.csb"
    local aniFile = "res/hallcocosstudio/RewardCtrl/gd-kuang.csb"
    local index = 1
    local function showNodeItem()
        local itemCount = #self._rewardList
        if index > itemCount and self._TimerID then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._TimerID)
            self._TimerID = nil
            --显示按钮
            self:SetBtnStatus()
            self:showPanelBtns()
            return
        end

        if self._showOneByOne then
            audio.playSound(cc.FileUtils:getInstance():fullPathForFilename('res/hall/sounds/reward.mp3'),false)
        end

        local item = self._rewardList[index]
        local imgPath = self:GetItemFilePath(item)
        local bShowEffct = self:IsNeedShowEffect(item)
        local pos = self:GetItemPos(index, itemCount)
        local node = cc.CSLoader:createNode(path)
        node:getChildByName("Panel_Main"):getChildByName("Img_Item"):loadTexture(imgPath, ccui.TextureResType.plistType)        
        node:getChildByName("Panel_Main"):getChildByName("Fnt_Num"):setString(item.nCount)        
        if self._showMemberTip then
            node:getChildByName("Panel_Main"):getChildByName("Image_1"):setVisible(true)
        else
            node:getChildByName("Panel_Main"):getChildByName("Image_1"):setVisible(false)
        end
        if self._lotteryCount and self._lotteryCount > 1 and index == 1 then
            node:getChildByName("Panel_Main"):getChildByName("Txt_Multiple"):setVisible(true)
            node:getChildByName("Panel_Main"):getChildByName("Txt_Multiple"):setString(string.format( "X%d", self._lotteryCount))
        end
        
        self._viewNode.List_Item:addChild(node)
        node:setPosition(pos)
        local aniNode = node:getChildByName("Panel_Main"):getChildByName("Ani_Effect")
        aniNode:stopAllActions()
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
        index = index + 1
    end

    local itemCount = #self._rewardList

    if self._showOneByOne then
        if self._TimerID then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._TimerID)
            self._TimerID = nil
        end
        self._TimerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(showNodeItem, 0.2, false)
    else
        for i = 1, itemCount do
            showNodeItem()
        end
        self:SetBtnStatus()
        self:showPanelBtns()
        audio.playSound(cc.FileUtils:getInstance():fullPathForFilename('res/hall/sounds/reward.mp3'),false)
    end

    self:freshTitle()
end

function RewardTipCtrl:freshTitle( )
    local dir = "hallcocosstudio/images/plist/RewardCtrl/"
    local path = nil
    if self._paySuccess then
        path = dir .. "Img_Title2.png"
    elseif self._showRedPacket then
        path = dir .. "Img_Title3.png"
    elseif self._showRedPacketVocher then
        path = dir .. "Img_Title4.png"
    else
        path = dir .. "Img_Title1.png"
    end
    self._viewNode.Img_Title:loadTexture(path,ccui.TextureResType.plistType)
end

function RewardTipCtrl:GetItemFilePath(item)
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
    elseif nType == Def.TYPE_REWARDTYPE_LUCKY_CAT then --小鱼干
        path = dir .. "Img_RewardType_LuckyCat.png"
    elseif nType == Def.TYPE_REWARDTYPE_NOBILITY_EXP then --贵族经验
        path = dir .. "Img_Prop_Jiacheng.png"
    elseif nType == Def.TYPE_REWARDTYPE_TIMINGGAME_TICKET then --定时赛门票
        path = dir .. "Img_TimingTicket1.png"
    elseif nType == Def.TYPE_PHONE then --话费
        path = dir .. "Img_Phone.png"
    end
    return path
end

function RewardTipCtrl:GetItemPos(nIndex,nTotalCount)
    local startY = self._viewNode.List_Item:getContentSize().height/2 - 20
    local startX = 0
    local offsetY = 80
    local perWidth = 138
    local gap = 20
    local bDoubleLine = false

    if nTotalCount>5 then
        bDoubleLine = true
    end

    if bDoubleLine then
        if self._lotteryCount and self._lotteryCount > 1 then
            if nIndex > 1 then
                local itemCount = nTotalCount - 1
                startX = (self._viewNode.List_Item:getContentSize().width - itemCount * perWidth -(itemCount - 1) * gap) / 2
                startY = startY - offsetY
            else
                local itemCount = 1
                startX =(self._viewNode.List_Item:getContentSize().width - itemCount * perWidth -(itemCount - 1) * gap) / 2
                startY = startY + offsetY
            end
        else
            if nIndex>5 then
                local itemCount = nTotalCount - 5
                startX = (self._viewNode.List_Item:getContentSize().width - itemCount * perWidth -(itemCount - 1) * gap) / 2
                startY = startY - offsetY
            else
                local itemCount = 5
                startX =(self._viewNode.List_Item:getContentSize().width - itemCount * perWidth -(itemCount - 1) * gap) / 2
                startY = startY + offsetY
            end
        end
    else
        if nIndex<=5 then
            local itemCount = nTotalCount
            startX = (self._viewNode.List_Item:getContentSize().width - itemCount * perWidth -(itemCount - 1) * gap) / 2
        end
    end

    local posX = 0
    if self._lotteryCount and self._lotteryCount > 1 and nTotalCount > 6 then
        posX = startX + (((nIndex - 1) % (nTotalCount - 1)) + 1) * (perWidth + gap) - perWidth / 2 - gap
    else
        posX = startX + (((nIndex - 1) % 5) + 1) * (perWidth + gap) - perWidth / 2 - gap
    end
    
    return cc.p(posX,startY)
end

function RewardTipCtrl:IsNeedShowEffect(item)
    local nType = item.nType
    local nCount = item.nCount

    local result = false
    if nType == Def.TYPE_SILVER then --银子
        if nCount >= 10000 then
            result = true
        end
    elseif nType == Def.TYPE_TICKET then --礼券
        if nCount >= 50 then
            result = true
        end
    elseif nType == Def.TYPE_CARDMARKER_1D then --1d记牌器
        result = true
    elseif nType == Def.TYPE_CARDMARKER_7D then --7d记牌器
        result = true
    elseif nType == Def.TYPE_CARDMARKER_30D then --30d记牌器
        result = true
    elseif nType == Def.TYPE_REWARDTYPE_NOBILITY_EXP then --贵族经验
        result = true
    elseif nType == Def.TYPE_REWARDTYPE_TIMINGGAME_TICKET then --定时赛门票
        result = true
    elseif nType == Def.TYPE_PHONE then     --话费
        result = true
    end
    return result
end

function RewardTipCtrl:SetBtnStatus()
    if type(self._rewardList)~='table' then return end

    for k,v in pairs(self._rewardList) do
        local nType = v.nType
        if nType == Def.TYPE_SILVER then --银子
            self._showBtnPlay = true
        elseif nType == Def.TYPE_TICKET then --礼券
            self._showBtnExchange = true
        elseif nType == Def.TYPE_CARDMARKER_1D then --1d记牌器
            self._showBtnPlay = true
        elseif nType == Def.TYPE_CARDMARKER_7D then --7d记牌器
            self._showBtnPlay = true
        elseif nType == Def.TYPE_CARDMARKER_30D then --30d记牌器
            self._showBtnPlay = true
        elseif nType == Def.TYPE_ROSE then --玫瑰
            self._showBtnPlay = true
        elseif nType == Def.TYPE_LIGHTING then --闪电
            local ExchangeLotteryModel = require('src.app.plugins.ExchangeLottery.ExchangeLotteryModel'):getInstance()
            if ExchangeLotteryModel:GetActivityOpen() then
                self._showBtnSeize = true
            else
                self._showBtnPlay = true
            end
        elseif nType == Def.TYPE_CARDMARKER then
            self._showBtnPlay = true
        elseif nType == Def.TYPE_PROP_LIANSHENG then
            self._showBtnPlay = true
        elseif nType == Def.TYPE_PROP_JIACHENG then
            self._showBtnPlay = true
        elseif nType == Def.TYPE_PROP_BAOXIAN then
            self._showBtnPlay = true
        elseif nType == Def.TYPE_RED_PACKET then --红包
            self._showBtnExchange = true
        elseif nType == Def.TYPE_RED_PACKET_VOCHER then --红包礼券
            self._showBtnExchange = true
        end
    end

    local secondLayer = cc.exports.PUBLIC_INTERFACE.GetCurrentAreaEntry()
    if secondLayer and secondLayer == "arena" then
        self._showBtnPlay = false
    end
    if not cc.exports.isExchangeSupported() then
        self._showBtnExchange = false
    end
end

function RewardTipCtrl:showPanelBtns( )
    self._viewNode.Panel_Btns:setVisible(true)
    self._viewNode.Btn_ToExchange:setVisible(false)
    self._viewNode.Btn_ToSeize:setVisible(false)
    self._viewNode.Btn_ToPlay:setVisible(false)
    self._viewNode.Btn_ToApply:setVisible(false)

    if self._newUserReward then
        self._viewNode.Btn_ToPlay:setVisible(true)

        if self._canSkipNewUserGuide then
            self._viewNode.Btn_Sure:setVisible(true)
            local image = self._viewNode.Btn_Sure:getChildByName('Image_2')
            local imagePath = 'hallcocosstudio/images/plist/RewardCtrl/Img_SkipGuide.png'
            image:loadTexture(imagePath, ccui.TextureResType.plistType)
            image:setContentSize(cc.size(131, 36))
        else
            self._viewNode.Btn_Sure:setVisible(false)
            local x = (self._viewNode.Panel_Btns:getContentSize().width)/2
            self._viewNode.Btn_ToPlay:setPosition(x,90)
        end
        return
    end

    if self._showOkOnly then
        local x = (self._viewNode.Panel_Btns:getContentSize().width)/2
        self._viewNode.Btn_Sure:setPosition(x,90)
        return
    end

    if self._showBtnSeize then
        self._viewNode.Btn_ToSeize:setVisible(true)
    elseif self._showBtnExchange then
        self._viewNode.Btn_ToExchange:setVisible(true)
        if self._showtip then
            self._viewNode.Panel_Bubble:setVisible(true)
            self._viewNode.Text_Tip:setVisible(true)
        end
    elseif self._showBtnPlay then
        self._viewNode.Btn_ToPlay:setVisible(true)
    elseif self._showApply then
        self._viewNode.Btn_ToApply:setVisible(true)
    else
        --当其他三个按钮都不显示的话,确认按钮居中显示
        local x = (self._viewNode.Panel_Btns:getContentSize().width)/2
        self._viewNode.Btn_Sure:setPosition(x,90)
    end
end

function RewardTipCtrl:onClickBtnToExchange()
    my.playClickBtnSound()
    self:removeSelfInstance()
    if not CenterCtrl:checkNetStatus() then
        self:removeSelfInstance()
        return
    end
    if self._showtip then
        my.informPluginByName({pluginName='ExchangeCenterPlugin',params= {defaultPage = "phoneFee"}})
    else
        my.informPluginByName({pluginName='ExchangeCenterPlugin'})
    end
end

function RewardTipCtrl:onClickBtnToSeize()
    my.playClickBtnSound()
    self:removeSelfInstance()
    if not CenterCtrl:checkNetStatus() then
        self:removeSelfInstance()
        return
    end

    PluginProcessModel:closeShopCtrl()

    my.informPluginByName({pluginName='ActivityCenterCtrl',params = {moudleName='exchangelottery'}})
end

function RewardTipCtrl:onClickBtnToPlay()
    my.playClickBtnSound()
    self:removeSelfInstance()
    if not CenterCtrl:checkNetStatus() then
        self:removeSelfInstance()
        return
    end

    local function quickStart(dt)
        local HallContext = import('src.app.plugins.mainpanel.HallContext'):getInstance()
        HallContext:dispatchEvent({name = HallContext.EVENT_MAP["hall_gotoGameByQuickStart"], value = {["autoDecideRoomScope"] = true}})
    end

    PluginProcessModel:closeShopCtrl()

    if not my.isInGame() then
        PluginProcessModel:notifyClosePlugin()
        my.scheduleOnce(quickStart, 0.5)
    end
    
end

function RewardTipCtrl:onClickBtnToApply()
    my.playClickBtnSound()
    self:removeSelfInstance()
    if not CenterCtrl:checkNetStatus() then
        self:removeSelfInstance()
        return
    end

    PluginProcessModel:closeShopCtrl()

    if not my.isInGame() then
        PluginProcessModel:notifyClosePlugin()
    end
    my.scheduleOnce(function() my.informPluginByName({pluginName = "TimingGameLayer"}) end, 0)
    
end

function RewardTipCtrl:onClickSure()
    if not self._enableClickSure and self._delayClick then
        return
    end

    if self._sureCallBack then
        self._callBack = nil
        self._sureCallBack()
    end

    my.playClickBtnSound()
    self:removeSelfInstance()
    if not CenterCtrl:checkNetStatus() then
        return
    end

end

function RewardTipCtrl:onPlayLoginOff()
    self:removeSelfInstance()
end

function RewardTipCtrl:onKeyBack()
    if not self._newUserReward then
        RewardTipCtrl.super.onKeyBack(self)
    end
end

return RewardTipCtrl