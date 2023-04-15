
local BaseGameSelfInfo = import("src.app.Game.mBaseGame.BaseGameSelfInfo")
local SKGameSelfInfo = class("SKGameSelfInfo", BaseGameSelfInfo)
local AdvertModel    = import('src.app.plugins.advert.AdvertModel'):getInstance()
local AdvertDefine   = import('src.app.plugins.advert.AdvertDefine')
local SKGameDef                                 = import("src.app.Game.mSKGame.SKGameDef")

function SKGameSelfInfo:ctor(selfInfoPanel, NodeMatching, NodeCancelRobot, NoBigger, DuiJiaShouPai, NodeMatchingJumpend)
    self._selfInfoCancelAuto    = nil
    self._selfInfoMatching      = NodeMatching
    self._selfInfoCancelAuto   = NodeCancelRobot
    self._selfInfoMatching:setVisible(false)
    self._selfInfoNoBigger      = NoBigger
    self._selfInfoTribute       = nil
    self._selfInfoReturn        = nil
    self._selfInfoDuiJiaShouPai = DuiJiaShouPai

    self._selfInfoMatchingJumpend = NodeMatchingJumpend
    self._selfInfoMatchingJumpend:setVisible(false)

    SKGameSelfInfo.super.ctor(self, selfInfoPanel)
end

function SKGameSelfInfo:init()
    if not self._selfInfoPanel then return end

    self._selfInfoPanel:setLocalZOrder(SKGameDef.SK_ZORDER_SELFINFO)

    --self._selfInfoCancelAuto    = self._selfInfoPanel:getChildByName("Node_gamehosting")
    --self._selfInfoNoBigger      = self._selfInfoPanel:getChildByName("Node_nocardskip")

    self._selfInfoTribute       = self._selfInfoPanel:getChildByName("Img_AttentionTribute")
    self._selfInfoTribute:setVisible(false)
    self._selfInfoReturn       = self._selfInfoPanel:getChildByName("Img_AttentionPayBack")
    self._selfInfoReturn:setVisible(false)
    self._selfInfoPanel:setVisible(true)

    self._selfInfoDuiJiaShouPai:setVisible(false)
    self._selfInfoCancelAuto:setVisible(false)
   
    SKGameSelfInfo.super.init(self)

    self._selfInfoPanel:getChildByName("Img_Dot"):setVisible(true)
    self._selfInfoPanel:getChildByName("Img_Dot_0"):setVisible(true)
    self._selfInfoPanel:getChildByName("Img_Dot_1"):setVisible(true)
    
    local matchingTimeText = self._selfInfoMatching:getChildByName("Panel_animation_matching"):getChildByName("Text_Time")
    if matchingTimeText then
        matchingTimeText:setVisible(false)
    end
end

function SKGameSelfInfo:showTribute(bShow)
    if self._selfInfoTribute then
        self._selfInfoTribute:setVisible(bShow)
        self._selfInfoPanel:setVisible(bShow)
        if bShow then
            local csbPath = "res/GameCocosStudio/csb/Node_AttentionWords.csb"
            local action = cc.CSLoader:createTimeline(csbPath)
            if action then
                self._selfInfoPanel:getParent():runAction(action)
                action:gotoFrameAndPlay(1, 14, true)
            end
        end
    end
end

function SKGameSelfInfo:showReturn(bShow)
    if self._selfInfoReturn then
        self._selfInfoReturn:setVisible(bShow)
        self._selfInfoPanel:setVisible(bShow)
        if bShow then
            local csbPath = "res/GameCocosStudio/csb/Node_AttentionWords.csb"
            local action = cc.CSLoader:createTimeline(csbPath)
            if action then
                self._selfInfoPanel:getParent():runAction(action)
                action:gotoFrameAndPlay(1, 14, true)
            end
        end
    end
end

function SKGameSelfInfo:showCancelAuto(bShow)
    if self._selfInfoCancelAuto then
        self._selfInfoCancelAuto:setVisible(bShow)
        if bShow then
            self:startInterAdvertStandingTimer()
        else
            self:stopInterAdvertStandingTimer()
        end

        if bShow then
            local csbPath = "res/GameCocosStudio/csb/Node_CancelRobot.csb"
            local action = cc.CSLoader:createTimeline(csbPath)
            if action then
                self._selfInfoCancelAuto:runAction(action)
                action:gotoFrameAndPlay(1, 14, true)
            end
        end
    end
end

function SKGameSelfInfo:showMatching(bShow)
    if PUBLIC_INTERFACE.IsStartAsTeam2V2() then
        local gameController = cc.exports.GamePublicInterface._gameController
        if gameController then
            if gameController._baseGameUtilsInfoManager and gameController._baseGameUtilsInfoManager.getBoutCount then
                local boutCount = gameController._baseGameUtilsInfoManager:getBoutCount()
                if boutCount and boutCount > 0 then
                    bShow = false
                end
            end
        end
    end

    if self._selfInfoMatching then
        self._selfInfoMatching:setVisible(bShow)
        self._selfInfoMatching:stopAllActions()

        if bShow then
            local csbPath = "res/GameCocosStudio/csb/Node_Animation_matching.csb"
            local action = cc.CSLoader:createTimeline(csbPath)
            if action then
                self._selfInfoMatching:runAction(action)
                action:gotoFrameAndPlay(0, 22, true)
            end
        end
    end
end

function SKGameSelfInfo:isWaitArrangeTableShow()
    if self._selfInfoMatching then
        return self._selfInfoMatching:isVisible()
    end
    return false
end

function SKGameSelfInfo:showNoBigger(bShow)
    if self._selfInfoNoBigger then
        self._selfInfoNoBigger:setVisible(bShow)
        
        --[[if bShow then
            local csbPath = "res/GameCocosStudio/csb/game_scene_animation/Node_nocardskip.csb"
            local action = cc.CSLoader:createTimeline(csbPath)
            if action then
                self._selfInfoNoBigger:runAction(action)
                action:gotoFrameAndPlay(0, 120, false)
            end
        end--]]
    end
end

function SKGameSelfInfo:showDuiJiaShouPai(bShow)
    if self._selfInfoDuiJiaShouPai then
        self._selfInfoDuiJiaShouPai:setVisible(bShow)
        
        if bShow then
            local csbPath = "res/GameCocosStudio/csb/Node_Duijiashoupai.csb"
            local action = cc.CSLoader:createTimeline(csbPath)
            if action then
                self._selfInfoDuiJiaShouPai:runAction(action)
                action:gotoFrameAndPlay(1, 14, true)
            end
        end
    end
end

function SKGameSelfInfo:showMatchingTimesStart(time, gameController)
    local matchingTimeText = self._selfInfoMatching:getChildByName("Panel_animation_matching"):getChildByName("Text_Time")
    if matchingTimeText then
        matchingTimeText:setVisible(true)
        self._matchingTimeCount = time
        
        matchingTimeText:setString(string.format(gameController:getGameStringToUTF8ByKey("G_GAME_MATCHING_TIME_TIPS"), self._matchingTimeCount))
        self:stopMatchingTimeTimerID()
        local function matchingTimeCallback(args)
            if self._matchingTimeCount > 0  then
                self._matchingTimeCount = self._matchingTimeCount - 1
                matchingTimeText:setString(string.format(gameController:getGameStringToUTF8ByKey("G_GAME_MATCHING_TIME_TIPS"), self._matchingTimeCount))
            else
                self:stopMatchingTimeTimerID()
                matchingTimeText:setVisible(false)
            end
        end 
        self._matchingTimeTimerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc(matchingTimeCallback, 1, false)
    end
end

function SKGameSelfInfo:stopMatchingTimeTimerID()
    if self._matchingTimeTimerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._matchingTimeTimerID)
        self._matchingTimeTimerID = nil
    end
end

function SKGameSelfInfo:showMatchingJumpend(bShow)
    if PUBLIC_INTERFACE.IsStartAsTeam2V2() then
        local gameController = cc.exports.GamePublicInterface._gameController
        if gameController then
            if gameController._baseGameUtilsInfoManager and gameController._baseGameUtilsInfoManager.getBoutCount then
                local boutCount = gameController._baseGameUtilsInfoManager:getBoutCount()
                if boutCount and boutCount > 0 then
                    bShow = false
                end
            end
        end
    end

    if self._selfInfoMatchingJumpend then
        self._selfInfoMatchingJumpend:setVisible(bShow)
        self._selfInfoMatchingJumpend:stopAllActions()

        if bShow then
            local csbPath = "res/GameCocosStudio/csb/Node_Animation_matching2.csb"
            local action = cc.CSLoader:createTimeline(csbPath)
            if action then
                self._selfInfoMatchingJumpend:runAction(action)
                action:gotoFrameAndPlay(0, 22, true)
            end
        end
    end
end

-- 打开停留定时器
function SKGameSelfInfo:startInterAdvertStandingTimer()
    -- 定时器已经开了
    if self._standingInterAdvertTimer then return end

    -- 非初级房托管也不播插屏
    local gameController = cc.exports.GamePublicInterface._gameController
    local roomInfo = cc.exports.PUBLIC_INTERFACE.GetCurrentRoomInfo()
    local utf8Name = roomInfo.szRoomName
    if gameController:isNeedDeposit() then
        if utf8Name ~= "初级房" then return end
    end

    -- 确定场景：积分房、银两初级房
    local scene = AdvertDefine.INTERSTITIAL_AUTO_PLAY_SCORE
    if  cc.exports.GamePublicInterface and cc.exports.GamePublicInterface._gameController then
        if gameController:isNeedDeposit() then
            scene = AdvertDefine.INTERSTITIAL_AUTO_PLAY_PRIMARY_DEPOSIT
        end
    end

    -- 校验停留时间
    local standingTime = AdvertModel:getInterVdStandingTime(scene)
    if standingTime <= 0 then return end

    self._standingInterAdvertTimer = my.createSchedule(function()
        if not self then return end
        
        if  cc.exports.GamePublicInterface and cc.exports.GamePublicInterface._gameController then
            if not cc.exports.GamePublicInterface._gameController:isGameRunning() then
                return
            end
        end

        self:stopInterAdvertStandingTimer()
        if AdvertModel:isNeedShowInterstitial(scene) then
            AdvertModel:showInterstitialAdvert(scene)
        end
    end, standingTime)
end

-- 关闭停留定时器
function SKGameSelfInfo:stopInterAdvertStandingTimer()
    if self._standingInterAdvertTimer then
        my.removeSchedule(self._standingInterAdvertTimer)
        self._standingInterAdvertTimer = nil
    end
end
return SKGameSelfInfo