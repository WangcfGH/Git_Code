local NewUserRewardCtrl = class("NewUserRewardCtrl", cc.load("BaseCtrl"))
local viewCreater = import("src.app.plugins.NewUserReward.NewUserRewardView")
local player = mymodel("hallext.PlayerModel"):getInstance()
local NewUserRewardModel = import("src.app.plugins.NewUserReward.NewUserRewardModel"):getInstance()
local NewUserRewardDef = import("src.app.plugins.NewUserReward.NewUserRewardDef")

my.addInstance(NewUserRewardCtrl)

function NewUserRewardCtrl:onCreate(params)
    local viewNode = self:setViewIndexer(viewCreater:createViewIndexer())
    self._viewNode = viewNode
    self._autoOpen = false
    self._autoOpenTimer = nil
    self._autoDestroyTimer = nil
    self._skeletonAniNode = nil

    viewNode.btnTakeReward:setOpacity(0)
    viewNode.btnTakeReward:addClickEventListener(function()
        self:onTakeRewardBtnClicked()
    end)

    self._autoOpenTimer = my.createOnceSchedule(function()
        if self._viewNode and not tolua.isnull(self._viewNode:getRealNode()) then
            self:autoTakeReward()
        end
    end, 4)

    self:initEventListeners()

    self:setSkeletonAnimation(viewNode)
    self:playShadeAnimation()
end

function NewUserRewardCtrl:initEventListeners()
    self:listenTo(NewUserRewardModel, NewUserRewardDef.EVENT_NEWUSERREWARD_TAKE_REWARD_OK, handler(self, self.onRewardTaked))
end

function NewUserRewardCtrl:onKeyBack()
    
end

function NewUserRewardCtrl:setSkeletonAnimation(viewNode)
    if viewNode then
        local skeletonJson = 'res/hallcocosstudio/images/skeleton/Ani_NewUserReward/gd_xslb.json'
        local skeletonAtlas = 'res/hallcocosstudio/images/skeleton/Ani_NewUserReward/gd_xslb.atlas'
        self._skeletonAniNode = sp.SkeletonAnimation:create(skeletonJson, skeletonAtlas, 1.3)
        if self._skeletonAniNode  then
            self._skeletonAniNode:setVisible(false)
            viewNode.nodeRewardBox:addChild(self._skeletonAniNode)
            self._skeletonAniNode:setMix('xunhuan', 'dakai', 0.3)
            self._skeletonAniNode:registerSpineEventHandler(function (event)
                if event then
                    if event.animation == 'chuxian' then
                        self:playBoxJumpAnimation()
                    elseif event.animation == 'dakai' then
                        self:showRewardTip()
                    end
                end
            end, sp.EventType.ANIMATION_COMPLETE)
        end
    end
end

function NewUserRewardCtrl:playBoxFullDownAnimation()
    if self._skeletonAniNode and not tolua.isnull(self._skeletonAniNode) then
        self._skeletonAniNode:setVisible(true)
        self._skeletonAniNode:setAnimation(0, 'chuxian', false)
    end
end

function NewUserRewardCtrl:playShadeAnimation()
    local panelShade = self._viewNode.panelShade
    if panelShade then
        panelShade:setOpacity(0)
        local fadeAction = cc.FadeTo:create(0.2, 255)
        local callbackAction = cc.CallFunc:create(function() 
            self:showTakeRewardBtn()
            self:playBoxFullDownAnimation()
        end)
        local sequenceAction = cc.Sequence:create(fadeAction, callbackAction)
        panelShade:runAction(sequenceAction)
    end
end

function NewUserRewardCtrl:showTakeRewardBtn()
    if self._viewNode and self._viewNode.btnTakeReward and not tolua.isnull(self._viewNode.btnTakeReward:getRealNode()) then
        self._viewNode.btnTakeReward:setOpacity(0)
        local fadeAction = cc.FadeIn:create(0.3)
        self._viewNode.btnTakeReward:runAction(fadeAction)

        self._viewNode.textTakeReward:setOpacity(0)
        local fadeAction = cc.FadeIn:create(0.3)
        self._viewNode.textTakeReward:runAction(fadeAction)
    end
end

function NewUserRewardCtrl:playBoxJumpAnimation()
    if self._skeletonAniNode and not tolua.isnull(self._skeletonAniNode) then
        self._skeletonAniNode:setAnimation(0, 'xunhuan', true)
    end
end

function NewUserRewardCtrl:playOpenBoxAnimation()
    if self._skeletonAniNode and not tolua.isnull(self._skeletonAniNode) then
        self._skeletonAniNode:setAnimation(0, 'dakai', false)
    end
end

function NewUserRewardCtrl:onTakeRewardBtnClicked()
    self:onTakeReward()
end

function NewUserRewardCtrl:autoTakeReward()
    self:onTakeReward()
end

function NewUserRewardCtrl:showRewardTip()
    local rewardList = NewUserRewardModel:getRewardList()

    if #rewardList > 0 then
        my.informPluginByName(
            {
                pluginName = "RewardTipCtrl",
                params = {
                    data = rewardList,
                    newUserReward = true,
                    canSkipNewUserGuide = cc.exports.canSkipNewUserGuide(),
                    calback = function()
                        local PluginProcessModel = mymodel('hallext.PluginProcessModel'):getInstance()
                        PluginProcessModel:stopPluginProcess()
                    end,
                    sureCallBack = function()

                        local NewUserGuideModel = mymodel('NewUserGuideModel'):getInstance()
                        NewUserGuideModel:skipGuide()

                        -- local PluginProcessModel = mymodel('hallext.PluginProcessModel'):getInstance()
                        -- PluginProcessModel:PopNextPlugin()
                        
                        local NewInviteGiftModel = require('src.app.plugins.invitegift.NewInviteGiftModel'):getInstance()
                        NewInviteGiftModel:reqBindInfo()
                    end
                }
            }
        )
        -- 更新数据
        -- 道具
        local PropModel = require("src.app.plugins.shop.prop.PropModel"):getInstance()
        PropModel:updatePropByReq(rewardList)
        -- 记牌器
        local CardRecorderModel = import("src.app.plugins.shop.cardrecorder.CardRecorderModel"):getInstance()
        CardRecorderModel:updateByReq(rewardList)
        -- 定时赛门票
        local TimingGameModel = import('src.app.plugins.TimingGame.TimingGameModel'):getInstance()
        TimingGameModel:reqTimingGameInfoData()
        self:destroyPlugin()
    else
        self:destroyPlugin()
    end
end


function NewUserRewardCtrl:onTakeReward()
    local CenterCtrl = require('src.app.BaseModule.CenterCtrl'):getInstance()
    if not CenterCtrl:checkNetStatus() then
        return
    end

    if self._autoOpenTimer then
        my.removeSchedule(self._autoOpenTimer)
        self._autoOpenTimer = nil
    end
    self._viewNode.btnTakeReward:setVisible(false)
    NewUserRewardModel:takeReward()

    -- 三秒后自动关闭
    self._autoDestroyTimer = my.createOnceSchedule(function()
        self:destroyPlugin()
    end, 5)
end

function NewUserRewardCtrl:onRewardTaked(event)
    local rewardData = event.value
    if rewardData.rewardresult == NewUserRewardDef.NEWUSERREWARD_REWARDRESULT_SUCCESS then
        -- 领取成功播放动画
        self:playOpenBoxAnimation()
    else
        if rewardData.rewardresult == NewUserRewardDef.NEWUSERREWARD_REWARDRESULT_DISABLE then
            my.informPluginByName({pluginName = "ToastPlugin", params = {tipString = "活动已关闭~", removeTime = 2}})
        elseif rewardData.rewardresult == NewUserRewardDef.NEWUSERREWARD_REWARDRESULT_REWARDED then
            my.informPluginByName({pluginName = "ToastPlugin", params = {tipString = "您已领取过该奖励，不能重复领取~", removeTime = 2}})
        elseif rewardData.rewardresult == NewUserRewardDef.NEWUSERREWARD_REWARDRESULT_NOTHISCONFIG then
            my.informPluginByName({pluginName = "ToastPlugin", params = {tipString = "没有该奖励~", removeTime = 2}})
        elseif rewardData.rewardresult == NewUserRewardDef.NEWUSERREWARD_REWARDRESULT_UPTOLIMIT then
            my.informPluginByName({pluginName = "ToastPlugin", params = {tipString = "该设备领取此奖励次数已达上限~", removeTime = 2}})
        elseif rewardData.rewardresult == NewUserRewardDef.NEWUSERREWARD_REWARDRESULT_FAILD then
            my.informPluginByName({pluginName = "ToastPlugin", params = {tipString = "新手礼包物品领取失败，请联系客服处理~", removeTime = 2}})
        end
        self:destroyPlugin()
    end
end

function NewUserRewardCtrl:destroyPlugin()
    if self._autoDestroyTimer then
        my.removeSchedule(self._autoDestroyTimer)
        self._autoDestroyTimer = nil
    end

    my.scheduleOnce(function()
        if(self:informPluginByName(nil,nil))then
            self:removeSelfInstance()
        end
    end, 0)
end

return NewUserRewardCtrl
