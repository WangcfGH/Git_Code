local RewardTipCtrlEx    = class("RewardTipCtrlEx", cc.load('BaseCtrl'))
local viewCreater       = import("src.app.plugins.RewardTipEx.RewardTipViewEx")
local Def               = import("src.app.plugins.RewardTip.RewardTipDef") -- Def就用已有的

local player                =mymodel('hallext.PlayerModel'):getInstance()
local PluginProcessModel = mymodel('hallext.PluginProcessModel'):getInstance()
local CenterCtrl = require('src.app.BaseModule.CenterCtrl'):getInstance()
local AdvertModel          = import('src.app.plugins.advert.AdvertModel'):getInstance()
local LoginLotteryModel = import("src.app.plugins.loginlottery.LoginLotteryModel"):getInstance()
local ComEvtTrkingModel = require("src.app.GameHall.models.ComEvtTrking.ComEvtTrkingModel"):getInstance()

function RewardTipCtrlEx:onCreate(params, ...)
    self._viewNode = self:setViewIndexer(viewCreater:createViewIndexer())
    if params and params.callback then self._callBack = params.callback end
    if params and params.data then self._rewardList = params.data end
    if params and params.showOneByOne then self._showOneByOne = params.showOneByOne end
    if params and params.showRedPacketVocher then self._showRedPacketVocher = params.showRedPacketVocher end
    if params and params.extraRewardIdx then self._extraRewardIdx = params.extraRewardIdx end
    --
    self:initListenTo()
    self:initBtns()
    self:init()
    self._enableClickTimer = my.scheduleOnce(function()
        self._enableClickSure = true
    end,0.5)
end

function RewardTipCtrlEx:onExit()
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

function RewardTipCtrlEx:initListenTo( )
    self:listenTo(player,player.PLAYER_LOGIN_OFF,handler(self,self.onPlayLoginOff))
    self:listenTo(PluginProcessModel,PluginProcessModel.CLOSE_REWARD_TIP_CTRL,handler(self,self.onPlayLoginOff))
    self:listenTo(PluginProcessModel, PluginProcessModel.CLOSE_PLUGIN_ON_GUIDE,handler(self,self.onPlayLoginOff))
end

function RewardTipCtrlEx:_onCheckBoxClicked(sender, eventType)
    local sureBtnVisible = true
    if eventType == ccui.CheckBoxEventType.selected then
        sureBtnVisible = false
    end
    if self._viewNode.btnSure then
        self._viewNode.btnSure:setVisible(sureBtnVisible)
    end
    if self._viewNode.btnWatchVideo then
        self._viewNode.btnWatchVideo:setVisible(not sureBtnVisible)
    end
    -- 额外奖励显隐
    for _, node in pairs(self._extraRewardNodeTbl or {}) do
        if not tolua.isnull(node) then
            node:setVisible(not sureBtnVisible)
        end
    end
end

function RewardTipCtrlEx:_onSureBtnClicked()
    self:removeSelfInstance()
end

function RewardTipCtrlEx:_onWatchVideoBtnClicked()
    local rewardIdx = self._extraRewardIdx
    local func = function (code, msg)
        ComEvtTrkingModel:watchVideoCallback(code, msg)
        if code == AdvertModel.AdSdkRetType.ADSDK_RET_AD_VIDEOCOMPLETE then
            LoginLotteryModel:onTakeExtraReward(rewardIdx)
            self:removeSelfInstance()
        elseif code == AdvertModel.AdSdkRetType.ADSDK_RET_LOADAD_FAIL then
            my.informPluginByName({pluginName='ToastPlugin',params={tipString = '视频播放失败,请您稍后再试',removeTime=1}})
        elseif code == AdvertModel.AdSdkRetType.ADSDK_RET_AD_VIDEOPLAYERROR then
            my.informPluginByName({pluginName='ToastPlugin',params={tipString = '视频播放失败,请您稍后再试',removeTime=1}})
        elseif code == AdvertModel.AdSdkRetType.ADSDK_RET_AD_DIMISS then
            my.informPluginByName({pluginName='ToastPlugin',params={tipString = '视频播放失败,请您稍后再试',removeTime=1}})
        elseif code == AdvertModel.AdSdkRetType.ADSDK_RET_AD_NOT_SUPPORT then
            my.informPluginByName({pluginName='ToastPlugin',params={tipString = '视频播放失败,请您稍后再试',removeTime=1}})
        end
    end
    ComEvtTrkingModel:initWatchVideoEventInfo(ComEvtTrkingModel.WATCH_VIDEO_SCENE.LOGIN_LOTTERY_EXTRA_REWARD)
    AdvertModel:ShowVideoAd(func)
    -- test 
    -- func(AdvertModel.AdSdkRetType.ADSDK_RET_AD_VIDEOCOMPLETE)
end

function RewardTipCtrlEx:initBtns()
    if not self._viewNode then return end
    if self._viewNode.checkBox then
        self._viewNode.checkBox:addEventListenerCheckBox(handler(self, self._onCheckBoxClicked))
        self._viewNode.checkBox:setSelected(true)
    end
    if self._viewNode.btnSure then
        self._viewNode.btnSure:addClickEventListener(handler(self, self._onSureBtnClicked))
        self._viewNode.btnSure:setVisible(false)
    end
    if self._viewNode.btnWatchVideo then
        self._viewNode.btnWatchVideo:addClickEventListener(handler(self, self._onWatchVideoBtnClicked))
        self._viewNode.btnWatchVideo:setVisible(true)
    end
    if self._viewNode.Panel_Btns then
        self._viewNode.Panel_Btns:setVisible(true)
    end
end

--初始化发奖界面
function RewardTipCtrlEx:init()
    if type(self._rewardList)~='table' then return end
    local path = "res/hallcocosstudio/RewardCtrl/node_award.csb"
    local aniFile = "res/hallcocosstudio/RewardCtrl/gd-kuang.csb"
    local index = 1
    local function showNodeItem()
        local itemCount = #self._rewardList
        if index > itemCount and self._TimerID then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._TimerID)
            self._TimerID = nil
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
        if item.extra == true then
            local img = node:getChildByName("Panel_Main"):getChildByName("Image_1")
            if img then 
                img:loadTexture("res/hallcocosstudio/images/png/extra.png", ccui.TextureResType.localType)
                img:setVisible(true)
            end
            -- 保存额外奖励节点
            self._extraRewardNodeTbl = self._extraRewardNodeTbl or {}
            table.insert(self._extraRewardNodeTbl, node)
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
        audio.playSound(cc.FileUtils:getInstance():fullPathForFilename('res/hall/sounds/reward.mp3'),false)
    end

    self:freshTitle()
end

function RewardTipCtrlEx:freshTitle( )
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

function RewardTipCtrlEx:GetItemFilePath(item)
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
    end
    return path
end

function RewardTipCtrlEx:GetItemPos(nIndex,nTotalCount)
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
        if nIndex>5 then
            local itemCount = nTotalCount - 5
            startX = (self._viewNode.List_Item:getContentSize().width - itemCount * perWidth -(itemCount - 1) * gap) / 2
            startY = startY - offsetY
        else
            local itemCount = 5
            startX =(self._viewNode.List_Item:getContentSize().width - itemCount * perWidth -(itemCount - 1) * gap) / 2
            startY = startY + offsetY
        end
    else
        if nIndex<=5 then
            local itemCount = nTotalCount
            startX = (self._viewNode.List_Item:getContentSize().width - itemCount * perWidth -(itemCount - 1) * gap) / 2
        end
    end

    local posX = startX + (((nIndex-1)%5)+1) *(perWidth + gap) - perWidth / 2 - gap
    return cc.p(posX,startY)
end

function RewardTipCtrlEx:IsNeedShowEffect(item)
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
    end
    return result
end

function RewardTipCtrlEx:onPlayLoginOff()
    self:removeSelfInstance()
end

return RewardTipCtrlEx