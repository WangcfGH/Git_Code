local WinningStreakCtrl      = class('WinningStreakCtrl', cc.load('SceneCtrl'))
--local WinningStreakCtrl = class("WinningStreakCtrl")
local viewCreater       	    = import("src.app.plugins.WinningStreak.WinningStreakView")
local WinningStreakModel      = import("src.app.plugins.WinningStreak.WinningStreakModel"):getInstance()
local WinningStreakDef        = import('src.app.plugins.WinningStreak.WinningStreakDef')
local BroadcastModel = mymodel("hallext.BroadcastModel"):getInstance()
local CenterCtrl = require('src.app.BaseModule.CenterCtrl'):getInstance()
local user = mymodel('UserModel'):getInstance()

function WinningStreakCtrl:ctor(...)
    self._viewNode = self:setViewIndexer(viewCreater:createViewIndexer())
    self._awardPositionX = self._viewNode.Btn_Award:getPositionX()
    self._awardPositionY = self._viewNode.Btn_Award:getPositionY()

    --游戏中才作为插件
    if my.isInGame() then
        WinningStreakCtrl.super.ctor(self,...)
        local windowSize = cc.Director:getInstance():getWinSize()
        self._viewNode:setPosition(cc.p(windowSize.width / 2, windowSize.height / 2))
        --self._viewNode.Panel_Shade:setContentSize(cc.size(windowSize.width, windowSize.height))
    end

    local pCallBack = {}
    table.insert(pCallBack, handler(self, self.onSelectBronze))
    table.insert(pCallBack, handler(self, self.onSelectSilver))
    table.insert(pCallBack, handler(self, self.onSelectGold))
    table.insert(pCallBack, handler(self, self.onSelectDiamond))
    self._viewNode:initTabs(#pCallBack, 1, pCallBack)

    self:initialListenTo()
    self:initialBtnClick()
    self:updateUI()
end

function WinningStreakCtrl:onSelectBronze()
    my.dataLink(cc.exports.DataLinkCodeDef.WINNING_STREAK_SELECT_BRONZE)
    CacheModel:saveInfoToCache("WinningStreakType", WinningStreakDef.WINNING_STREAK_BRONZE)
    self:freshSignAndStatus()
    self:updateUI()
end

function WinningStreakCtrl:onSelectSilver()
    my.playClickBtnSound()
    my.dataLink(cc.exports.DataLinkCodeDef.WINNING_STREAK_SELECT_SILVER)
    CacheModel:saveInfoToCache("WinningStreakType", WinningStreakDef.WINNING_STREAK_SILVER)
    self:freshSignAndStatus()
    self:updateUI()
end

function WinningStreakCtrl:onSelectGold()
    my.playClickBtnSound()
    my.dataLink(cc.exports.DataLinkCodeDef.WINNING_STREAK_SELECT_GOLD)
    CacheModel:saveInfoToCache("WinningStreakType", WinningStreakDef.WINNING_STREAK_GOLD)
    self:freshSignAndStatus()
    self:updateUI()
end

function WinningStreakCtrl:onSelectDiamond()
    my.playClickBtnSound()
    my.dataLink(cc.exports.DataLinkCodeDef.WINNING_STREAK_SELECT_DIAMOND)
    CacheModel:saveInfoToCache("WinningStreakType", WinningStreakDef.WINNING_STREAK_DIAMOND)
    self:freshSignAndStatus()
    self:updateUI()
end

function WinningStreakCtrl:onEnterAfterActivityBtnClick()
    local sStatusWinningStreak = string.format("WinningStreak%s", os.date("%Y%m%d"))
    CacheModel:saveInfoToCache(sStatusWinningStreak, 1)
    WinningStreakModel:gc_GetWinningStreakInfo()   --获取最新数据
    my.dataLink(cc.exports.DataLinkCodeDef.WINNING_STREAK_ENTER_BTN_CLICK)
end

function WinningStreakCtrl:onEnter(...)
    WinningStreakModel:gc_GetWinningStreakInfo()   --在游戏作为插件也要获取最新数据
end

function WinningStreakCtrl:initialListenTo( )
    if my.isInGame() then
        self:listenTo(WinningStreakModel, WinningStreakDef.WinningStreakInfoRet, handler(self,self.updateGameUI))
    end
    self:listenTo(WinningStreakModel, WinningStreakDef.WinningStreakChargeCancel, handler(self,self.updateChargeBtnStatus))
end

function WinningStreakCtrl:initialBtnClick( )
    local viewNode = self._viewNode
    viewNode.Btn_Open:addClickEventListener(handler(self, self.onClickOpen))
    viewNode.Btn_Play:addClickEventListener(handler(self, self.onClickPlay))
    viewNode.Btn_Help:addClickEventListener(handler(self, self.onClickHelp))
    viewNode.Btn_Award:addClickEventListener(handler(self, self.onClickAward))
    viewNode.Btn_Award_Double:addClickEventListener(handler(self, self.onClickAwardDouble))
    viewNode.Btn_Close:addClickEventListener(handler(self, self.onClickClose))
end

function WinningStreakCtrl:freshButtonStatus(sStatus, bCanJoin, chooseType, hideAwardDouble)
    if sStatus == WinningStreakDef.WINNING_STREAK_UNSTARTED then
        self._viewNode.Panel_NoChallenge:setVisible(true)
        self._viewNode.Img_NineStreak:setVisible(true)

        self._viewNode.tabList:setVisible(true)
        self._viewNode.Panel_Challenge:setVisible(false)
        self._viewNode.Btn_Open:setVisible(true)
        self._viewNode.Btn_Play:setVisible(false)
        self._viewNode.Btn_Award:setVisible(false)
        self._viewNode.Btn_Award_Double:setVisible(false)
        self._viewNode.Txt_Award_Double:setVisible(false)
        
        self._viewNode.Btn_Open:setEnabled(true)
        self._viewNode.Btn_Open:setBright(true)
        self._viewNode.Btn_Open:setVisible(true)
        self._viewNode.Btn_Open_NotTime:setVisible(false)
        if bCanJoin == 0  then                         --不在开启挑战时间内
            self._viewNode.Btn_Open:setVisible(false)
            self._viewNode.Btn_Open_NotTime:setVisible(true)
        end
    elseif sStatus == WinningStreakDef.WINNING_STREAK_STARTING then
        self._viewNode.Panel_NoChallenge:setVisible(false)
        self._viewNode.Img_NineStreak:setVisible(true)
        self._viewNode.tabList:setVisible(false)
        self._viewNode.Panel_Challenge:setVisible(true)
        self._viewNode.Btn_Open:setVisible(false)
        self._viewNode.Btn_Play:setVisible(true)
        self._viewNode.Btn_Award:setVisible(false)
        self._viewNode.Btn_Award_Double:setVisible(false)
        self._viewNode.Txt_Award_Double:setVisible(false)
        self._viewNode.Btn_Open_NotTime:setVisible(false)

        self._viewNode:runTimelineAction("animation1", true)
    elseif sStatus == WinningStreakDef.WINNING_STREAK_UNTAKE then
        self._viewNode.Panel_NoChallenge:setVisible(false)
        self._viewNode.Img_NineStreak:setVisible(false)
        self._viewNode.tabList:setVisible(false)
        self._viewNode.Panel_Challenge:setVisible(true)
        self._viewNode.Btn_Open:setVisible(false)
        self._viewNode.Btn_Play:setVisible(false)
        self._viewNode.Btn_Award:setVisible(true)
        self._viewNode.Btn_Award_Double:setVisible(true)

        self._viewNode.Btn_Award:setEnabled(true)
        self._viewNode.Btn_Award:setBright(true)
        self._viewNode.Btn_Award_Double:setEnabled(true)
        self._viewNode.Btn_Award_Double:setBright(true)
        self._viewNode.Txt_Award_Double:setVisible(true)
        self._viewNode.Btn_Open_NotTime:setVisible(false)

        self._viewNode.Btn_Award:setPosition(cc.p(self._awardPositionX,self._awardPositionY))
        if chooseType == WinningStreakDef.WINNING_STREAK_DIAMOND or chooseType == WinningStreakDef.WINNING_STREAK_GOLD or hideAwardDouble then 
            self._viewNode.Txt_Award_Double:setVisible(false) 
            self._viewNode.Btn_Award_Double:setVisible(false)
            self._viewNode.Btn_Award:setPosition(self._viewNode.Btn_Award_Middle:getPosition())
        else
            local aniBtnFile= "res/hallcocosstudio/activitycenter/cj_anniu.csb"
            self._viewNode.Ani_Award_Double:setVisible(true)
            self._viewNode.Ani_Award_Double:stopAllActions()
            local action = cc.CSLoader:createTimeline(aniBtnFile)
            if not tolua.isnull(action) then
                self._viewNode.Ani_Award_Double:runAction(action)
                action:play("animation0", true)
            end
        end

        local aniBtnFile= "res/hallcocosstudio/activitycenter/cj_anniu.csb"
        self._viewNode.Ani_Award:setVisible(true)
        self._viewNode.Ani_Award:stopAllActions()
        local action = cc.CSLoader:createTimeline(aniBtnFile)
        if not tolua.isnull(action) then
            self._viewNode.Ani_Award:runAction(action)
            action:play("animation0", true)
        end
    end

    --刷新状态时都清除下缓存
    CacheModel:saveInfoToCache("WinStreakOnClickOpen", 0)
end

function WinningStreakCtrl:updateGameUI()
    if my.isInGame() then
        self:updateUI()
    end
end

--充值取消后，更新按钮状态
function WinningStreakCtrl:updateChargeBtnStatus()
    self._viewNode.Btn_Award_Double:setEnabled(true)
    self._viewNode.Btn_Award_Double:setBright(true)
    local chooseType = CacheModel:getCacheByKey("WinningStreakType")
    if chooseType == WinningStreakDef.WINNING_STREAK_DIAMOND or chooseType == WinningStreakDef.WINNING_STREAK_GOLD then  
        self._viewNode.Btn_Open:setEnabled(true)
        self._viewNode.Btn_Open:setBright(true)
    end
end

function WinningStreakCtrl:updateUI()
    if (not self._viewNode) or (not self._viewNode.Btn_Close) then return end
    self._viewNode.Btn_Close:setVisible(false)
    self._viewNode.Panel_Shade:setVisible(false)
    self._viewNode.Img_GameBg:setVisible(false)
    if my.isInGame() then    --游戏内要有关闭按钮
        self._viewNode.Img_GameBg:setVisible(true)
        self._viewNode.Btn_Close:setVisible(true)
        self._viewNode.Panel_Shade:setVisible(true)
    end

    local winningStreakInfo = WinningStreakModel:GetWinningStreakInfo()
    local winningStreakConfig = WinningStreakModel:GetWinningStreakConfig()
    if not winningStreakInfo or not winningStreakConfig then
        CacheModel:saveInfoToCache("WinningStreakType", WinningStreakDef.WINNING_STREAK_BRONZE)
        self:freshSignAndStatus()
        self:updateTabStatus(WinningStreakDef.WINNING_STREAK_BRONZE) 
        WinningStreakModel:gc_GetWinningStreakInfo()
        return
    end

    --不在活动范围内
    if not WinningStreakModel:isAlive() then
        self:goBack()
        return
    end

    local data = nil
    local awardData = nil

    if winningStreakInfo.nState == WinningStreakDef.WINNING_STREAK_UNSTARTED then   --未挑战读缓存,也有可能已经挑战完一次了。。。
        local chooseType = CacheModel:getCacheByKey("WinningStreakType")
        if chooseType == WinningStreakDef.WINNING_STREAK_DIAMOND then
            CacheModel:saveInfoToCache("WinningStreakType", WinningStreakDef.WINNING_STREAK_DIAMOND)
            self:updateTabStatus(WinningStreakDef.WINNING_STREAK_DIAMOND)
        elseif chooseType == WinningStreakDef.WINNING_STREAK_GOLD then
            CacheModel:saveInfoToCache("WinningStreakType", WinningStreakDef.WINNING_STREAK_GOLD)
            self:updateTabStatus(WinningStreakDef.WINNING_STREAK_GOLD)
        elseif chooseType == WinningStreakDef.WINNING_STREAK_SILVER then
            CacheModel:saveInfoToCache("WinningStreakType", WinningStreakDef.WINNING_STREAK_SILVER)
            self:updateTabStatus(WinningStreakDef.WINNING_STREAK_SILVER)
        else
            CacheModel:saveInfoToCache("WinningStreakType", WinningStreakDef.WINNING_STREAK_BRONZE)
            self:updateTabStatus(WinningStreakDef.WINNING_STREAK_BRONZE)
        end
    elseif winningStreakInfo.nState == WinningStreakDef.WINNING_STREAK_STARTING then
        CacheModel:saveInfoToCache("WinningStreakType", winningStreakInfo.nChallengeType)
    end

    self:freshSignAndStatus()

    local chooseType = CacheModel:getCacheByKey("WinningStreakType")
    if chooseType == WinningStreakDef.WINNING_STREAK_DIAMOND then
        data = winningStreakConfig["diamond"]
    elseif chooseType == WinningStreakDef.WINNING_STREAK_GOLD then
        data = winningStreakConfig["gold"]
    elseif chooseType == WinningStreakDef.WINNING_STREAK_SILVER then
        data = winningStreakConfig["silver"]
    else
        data = winningStreakConfig["bronze"]
    end

    --刷新活动时间
    self:freshActivityTime(winningStreakConfig)

    awardData = data[WinningStreakDef.WINNING_STREAK_APPTYPE_AN]   --默认安卓
    if MCAgent:getInstance().getLaunchSubMode and MCAgent:getInstance():getLaunchSubMode() == 1 then      --合集
        awardData = data[WinningStreakDef.WINNING_STREAK_APPTYPE_SET]
    elseif cc.exports.LaunchMode["PLATFORM"] == MCAgent:getInstance():getLaunchMode() then
        if device.platform == 'ios' then
            awardData = data[WinningStreakDef.WINNING_STREAK_APPTYPE_IOS]
        else
            awardData = data[WinningStreakDef.WINNING_STREAK_APPTYPE_AN]
        end
    end

    self:freshAwardDeposit(awardData)  --刷新奖励银两

    --五连胜以下不显示领取翻倍
    local hideAwardDouble = false
    if winningStreakInfo.nBout and awardData.multipleLimitBout and winningStreakInfo.nBout < awardData.multipleLimitBout then
        hideAwardDouble = true
    end
    --刷新各个挑战状态的界面展示
    self:freshButtonStatus(winningStreakInfo.nState, winningStreakInfo.bCanJoin, chooseType, hideAwardDouble)
end

function WinningStreakCtrl:freshAwardDeposit(awardData)
    local winningStreakInfo = WinningStreakModel:GetWinningStreakInfo()

    if awardData.pricetype  == 1 then   --银两
        self._viewNode.Img_Silver:setVisible(true)
        self._viewNode.Fnt_StartChallenge:setVisible(true)
        self._viewNode.Fnt_StartChallenge_Middle:setVisible(false)
        self._viewNode.Fnt_StartChallenge:setString(awardData.price.."开启挑战")
    elseif awardData.pricetype  == 2 then  --充值
        self._viewNode.Img_Silver:setVisible(false)
        self._viewNode.Fnt_StartChallenge:setVisible(false)
        self._viewNode.Fnt_StartChallenge_Middle:setVisible(true)
        self._viewNode.Fnt_StartChallenge_Middle:setString("￥"..awardData.price.."元 开启挑战")
    end

    --免费报名
    if tonumber(awardData.totalTime) == 0 and winningStreakInfo.nState == WinningStreakDef.WINNING_STREAK_UNSTARTED then
        self._viewNode.Img_Silver:setVisible(false)
        self._viewNode.Fnt_StartChallenge:setVisible(false)
        self._viewNode.Fnt_StartChallenge_Middle:setVisible(true)
        self._viewNode.Fnt_StartChallenge_Middle:setString("免费报名")
    end

    --刷新翻倍领取的按钮
    if awardData.mul_price then
        self._viewNode.Fnt_Award_Double:setString(awardData.mul_price.."元 翻倍领取")
    end

    local multiRewardList = awardData["multiReward"]
    if multiRewardList then
        for i, j in pairs(multiRewardList) do
            if winningStreakInfo and winningStreakInfo.nBout and winningStreakInfo.nBout >= j.bout then
                self._viewNode.Txt_Award_Double:setString("可领"..j.StartTimes.."-"..j.EndTimes.."倍")   --双倍领取的小提示
            end
        end
    end
 
    self._viewNode.Fnt_Silver:setString(awardData.totalAward)
    if winningStreakInfo.nState == WinningStreakDef.WINNING_STREAK_UNSTARTED then
        self._viewNode.Fnt_FanBei:setString("最高"..awardData.totalTime.."倍")
    elseif winningStreakInfo.nState == WinningStreakDef.WINNING_STREAK_STARTING then
        self._viewNode.Fnt_FanBei:setString("挑战进行中")
    elseif winningStreakInfo.nState == WinningStreakDef.WINNING_STREAK_UNTAKE then
        self._viewNode.Fnt_FanBei:setString("挑战已结束")
    end
    
    self._viewNode.Fnt_FanBei:setVisible(true)
    if tonumber(awardData.totalTime) == 0 and winningStreakInfo.nState == WinningStreakDef.WINNING_STREAK_UNSTARTED then
        self._viewNode.Fnt_FanBei:setString("免费挑战")
    end
    --剩余挑战次数 
    local chooseType = CacheModel:getCacheByKey("WinningStreakType")
    local remainingCount = awardData.ChallengeTimeLimit - winningStreakInfo.nChallengeCount[chooseType]

    if winningStreakInfo.nState == WinningStreakDef.WINNING_STREAK_UNSTARTED then
        self._viewNode:runTimelineAction("animation0", true)
    end
    if remainingCount <= 0 then
        remainingCount = 0
        if winningStreakInfo.nState == WinningStreakDef.WINNING_STREAK_UNSTARTED then    --动画不要播了
            self._viewNode:stopAllActions()
        end
    end
    self._viewNode.Txt_RemainingCount:setString("今日剩余挑战次数:"..remainingCount.."/"..awardData.ChallengeTimeLimit)

     --刷新连胜局数
    self._viewNode.Txt_WinBout:setString("连胜"..winningStreakInfo.nBout.."局")
    if winningStreakInfo.nBout < 0 then
        self._viewNode.Txt_WinBout:setString("连胜0局")
    end

    self._viewNode.Fnt_JackpotDeposit:setString("0银两")
    --与挑战状态无关的数据
    local winningStreakAwardList = awardData["WinningStreakAwardList"]
    for i, j in pairs(winningStreakAwardList) do
        self._viewNode.Panel_Progress:getChildByName("Panel_Streak"..i):getChildByName("Fnt_Streak"):setString("+"..j.bout)
        self._viewNode.Panel_Progress:getChildByName("Panel_Streak"..i):getChildByName("Fnt_Reward"):setString("+"..self:convertMoneyFormat(j.Count, 4))
        self._viewNode.Panel_Progress:getChildByName("Panel_Streak"..i):getChildByName("Image_Status"):setVisible(false)
        if winningStreakInfo and winningStreakInfo.nBout and winningStreakInfo.nBout >= j.bout then
            self._viewNode.Panel_Progress:getChildByName("Panel_Streak"..i):getChildByName("Image_Status"):setVisible(true)   --连胜勾选框的显示
            self._viewNode.Fnt_JackpotDeposit:setString(j.TotalAward.."银两")
        end
    end
end

function WinningStreakCtrl:onClickOpen( )
    my.dataLink(cc.exports.DataLinkCodeDef.WINNING_STREAK_CLICK_OPEN)
    my.playClickBtnSound()

    if not CenterCtrl:checkNetStatus() then
        self:removeSelfInstance()
        return
    end

    local winningStreakInfo = WinningStreakModel:GetWinningStreakInfo()
    if not winningStreakInfo then return end

    local GAP_SCHEDULE = 8 --间隔时间8秒
    local nowTime = os.time()
    self._lastTime = self._lastTime or 0
    if nowTime - self._lastTime > GAP_SCHEDULE then
        self._lastTime = nowTime
    else
        my.informPluginByName({pluginName = 'TipPlugin',params = {tipString = "点击太频繁，请8秒后再操作", removeTime = 3}})
        return
    end

    local winStreakClickOpen = CacheModel:getCacheByKey("WinStreakOnClickOpen")
    if winStreakClickOpen and 1 == winStreakClickOpen then
        return 
    end
    CacheModel:saveInfoToCache("WinStreakOnClickOpen", 1)

    local chooseType = CacheModel:getCacheByKey("WinningStreakType")
    local winningStreakConfig = WinningStreakModel:GetWinningStreakConfig()

    local data = nil
    local awardData = nil
    
    if chooseType == WinningStreakDef.WINNING_STREAK_DIAMOND then
        data = winningStreakConfig["diamond"]
    elseif chooseType == WinningStreakDef.WINNING_STREAK_GOLD then
        data = winningStreakConfig["gold"]
    elseif chooseType == WinningStreakDef.WINNING_STREAK_SILVER then
        data = winningStreakConfig["silver"]
    else
        data = winningStreakConfig["bronze"]
    end

    awardData = data[WinningStreakDef.WINNING_STREAK_APPTYPE_AN]   --默认安卓
    if MCAgent:getInstance().getLaunchSubMode and MCAgent:getInstance():getLaunchSubMode() == 1 then      --合集
        awardData = data[WinningStreakDef.WINNING_STREAK_APPTYPE_SET]
    elseif cc.exports.LaunchMode["PLATFORM"] == MCAgent:getInstance():getLaunchMode() then
        if device.platform == 'ios' then
            awardData = data[WinningStreakDef.WINNING_STREAK_APPTYPE_IOS]
        else
            awardData = data[WinningStreakDef.WINNING_STREAK_APPTYPE_AN]
        end
    end

    local remainingCount = awardData.ChallengeTimeLimit - winningStreakInfo.nChallengeCount[chooseType]
    if remainingCount <= 0 then
        my.informPluginByName({pluginName = 'TipPlugin',params = {tipString = "今日该档位挑战次数不足~", removeTime = 3}})
        return
    end

        --青铜白银校验银两
    if chooseType == WinningStreakDef.WINNING_STREAK_BRONZE or chooseType == WinningStreakDef.WINNING_STREAK_SILVER then
        if not my.isInGame()  then
            if user.nDeposit < awardData.price then
                if user.nSafeboxDeposit + user.nDeposit < awardData.price then
                     my.informPluginByName({pluginName = 'TipPlugin',params = {tipString = "您的银两不足,请充值后再来挑战", removeTime = 3}})
                     return
                else
                    my.informPluginByName({pluginName='SafeboxCtrl'})
                    return
                end
            end
        elseif my.isInGame() and user.nSafeboxDeposit < awardData.price then
            my.informPluginByName({pluginName = 'TipPlugin',params = {tipString = "保险箱银两不足,开启失败", removeTime = 3}})
            return
        end
    end

    --模拟器直接发消息
    --if cc.Application:getInstance():getTargetPlatform() == cc.PLATFORM_OS_WINDOWS then
    if device.platform == 'ios' or device.platform == 'windows' then
        WinningStreakModel:gc_WinningStreakOpen(chooseType)    --服务器原来是 0 1 2 3也改为了1 2 3 4
        return
    end

    --点击完之后不让再点，等刷新
    self._viewNode.Btn_Open:setEnabled(false)
    self._viewNode.Btn_Open:setBright(false)

    --黄金和钻石档是没有game配置的  青铜白银直接请求扣银
--    if chooseType == WinningStreakDef.WINNING_STREAK_BRONZE or chooseType == WinningStreakDef.WINNING_STREAK_SILVER then
--        WinningStreakModel:gc_WinningStreakOpen(chooseType)
--    else
--        WinningStreakModel:_payFor(chooseType,"hall")
--    end
    WinningStreakModel:gc_WinningStreakOpen(chooseType)
end

function WinningStreakCtrl:onClickAward()
    my.playClickBtnSound()

    --点击完之后不让再点，等刷新
    self._viewNode.Btn_Award:setEnabled(false)
    self._viewNode.Btn_Award:setBright(false)

    if not CenterCtrl:checkNetStatus() then
        self:removeSelfInstance()
        return
    end

    local info = WinningStreakModel:GetWinningStreakInfo()
    if not info then return end
    
--    local GAP_SCHEDULE = 2 --间隔时间2秒
--    local nowTime = os.time()
--    self._lastTime = self._lastTime or 0
--    if nowTime - self._lastTime > GAP_SCHEDULE then
--        self._lastTime = nowTime
--    else
--        my.informPluginByName({pluginName = 'TipPlugin',params = {tipString = "点击太频繁，请2秒后再操作", removeTime = 3}})
--        return
--    end

    WinningStreakModel:gc_WinningStreakAward()
end

function WinningStreakCtrl:onClickAwardDouble()
    my.dataLink(cc.exports.DataLinkCodeDef.WINNING_STREAK_CLICK_AWARD_D)
    my.playClickBtnSound()

    if not CenterCtrl:checkNetStatus() then
        self:removeSelfInstance()
        return
    end

    local info = WinningStreakModel:GetWinningStreakInfo()
    if not info then return end

--    local GAP_SCHEDULE = 2 --间隔时间2秒
--    local nowTime = os.time()
--    self._lastTime = self._lastTime or 0
--    if nowTime - self._lastTime > GAP_SCHEDULE then
--        self._lastTime = nowTime
--    else
--        my.informPluginByName({pluginName = 'TipPlugin',params = {tipString = "点击太频繁，请2秒后再操作", removeTime = 3}})
--        return
--    end

      --点击完之后不让再点，等刷新，如果充值失败就难受
    self._viewNode.Btn_Award_Double:setEnabled(false)
    self._viewNode.Btn_Award_Double:setBright(false)

    local chooseType = CacheModel:getCacheByKey("WinningStreakType")
    WinningStreakModel:_payFor(chooseType,"double")
end

function WinningStreakCtrl:onGetAwardRet(data)
    if(type(data)~='table' or type(data.value)~='table')then
        return
    end
end

function WinningStreakCtrl:onExit()
    WinningStreakCtrl.super.onExit(self)
    self:removeEventHosts()
end

function WinningStreakCtrl:setViewIndexer(viewIndexer)
    self._viewNode=viewIndexer
    return self._viewNode
end

function WinningStreakCtrl:goBack()
    WinningStreakCtrl.super.removeSelf(self)
end

function WinningStreakCtrl:onClickClose()
    my.playClickBtnSound()
    self:goBack()
end

function WinningStreakCtrl:onKeyBack()
    self:goBack()
end

function WinningStreakCtrl:updateTabStatus(index)
    for i = 1, WinningStreakDef.WINNING_STREAK_DIAMOND do
        self._viewNode.tabList:getChildByName("Btn_Tab"..i):setEnabled(i ~= index)
        self._viewNode.tabList:getChildByName("Btn_Tab"..i):setBright(i ~= index)
    end
end

function WinningStreakCtrl:freshActivityTime(winningStreakConfig)
    local strBeginDate = string.format("%02d",math.floor((winningStreakConfig.StartDate %10000) /100)) .. "月" .. string.format("%02d", math.floor(winningStreakConfig.StartDate %100)) .."日"
    local strEndDate = string.format("%02d",math.floor((winningStreakConfig.EndDate %10000) /100)) .. "月" .. string.format("%02d", math.floor(winningStreakConfig.EndDate %100)) .."日"
    local strTime = ""
    for i,j in pairs(winningStreakConfig.TimeSection) do
        if winningStreakConfig.TimeSection[i].applyStartTime and winningStreakConfig.TimeSection[i].applyEndTime then
            local strBeginTime = string.format("%02d",math.floor(winningStreakConfig.TimeSection[i].applyStartTime/100)) ..":"..string.format("%02d",math.floor(winningStreakConfig.TimeSection[i].applyStartTime%100))
            local strEndTime = string.format("%02d",math.floor(winningStreakConfig.TimeSection[i].applyEndTime/100)) ..":"..string.format("%02d",math.floor(winningStreakConfig.TimeSection[i].applyEndTime%100))
            strTime = strTime..strBeginTime.."~"..strEndTime.."  "
        end
    end
    self._viewNode.Panel_NoChallenge:getChildByName("Text_ActivityTime"):setString("活动时间: "..strBeginDate.."--"..strEndDate.." 每天"..strTime)
end

function WinningStreakCtrl:freshSignAndStatus()
    local chooseType = CacheModel:getCacheByKey("WinningStreakType")
    if chooseType == WinningStreakDef.WINNING_STREAK_DIAMOND then
        --连胜挑战进度图标的显示
        for i = 1, WinningStreakDef.WINNING_STREAK_TOTAL_COUNT do
            if(i == WinningStreakDef.WINNING_STREAK_TOTAL_COUNT) then
                self._viewNode.Panel_Progress:getChildByName("Panel_Streak"..i):getChildByName("Image_Sign"):loadTexture("hallcocosstudio/images/plist/WinningStreak/Diamond2.png",ccui.TextureResType.plistType)
            else
                self._viewNode.Panel_Progress:getChildByName("Panel_Streak"..i):getChildByName("Image_Sign"):loadTexture("hallcocosstudio/images/plist/WinningStreak/Diamond1.png",ccui.TextureResType.plistType)
            end
            self._viewNode.Panel_Progress:getChildByName("Panel_Streak"..i):getChildByName("Image_Status"):setVisible(false)
        end
    elseif chooseType == WinningStreakDef.WINNING_STREAK_GOLD then
         --连胜挑战进度图标的显示
        for i = 1, WinningStreakDef.WINNING_STREAK_TOTAL_COUNT do
            if(i == WinningStreakDef.WINNING_STREAK_TOTAL_COUNT) then
                self._viewNode.Panel_Progress:getChildByName("Panel_Streak"..i):getChildByName("Image_Sign"):loadTexture("hallcocosstudio/images/plist/WinningStreak/Gold2.png",ccui.TextureResType.plistType)
            else
                self._viewNode.Panel_Progress:getChildByName("Panel_Streak"..i):getChildByName("Image_Sign"):loadTexture("hallcocosstudio/images/plist/WinningStreak/Gold1.png",ccui.TextureResType.plistType)
            end
            self._viewNode.Panel_Progress:getChildByName("Panel_Streak"..i):getChildByName("Image_Status"):setVisible(false)
        end
    elseif chooseType == WinningStreakDef.WINNING_STREAK_SILVER then
        --连胜挑战进度图标的显示
        for i = 1, WinningStreakDef.WINNING_STREAK_TOTAL_COUNT do
            if(i == WinningStreakDef.WINNING_STREAK_TOTAL_COUNT) then
                self._viewNode.Panel_Progress:getChildByName("Panel_Streak"..i):getChildByName("Image_Sign"):loadTexture("hallcocosstudio/images/plist/WinningStreak/Silver2.png",ccui.TextureResType.plistType)
            else
                self._viewNode.Panel_Progress:getChildByName("Panel_Streak"..i):getChildByName("Image_Sign"):loadTexture("hallcocosstudio/images/plist/WinningStreak/Silver1.png",ccui.TextureResType.plistType)
            end
            self._viewNode.Panel_Progress:getChildByName("Panel_Streak"..i):getChildByName("Image_Status"):setVisible(false)
        end
    else
        --连胜挑战进度图标的显示
        for i = 1, WinningStreakDef.WINNING_STREAK_TOTAL_COUNT do
            if(i == WinningStreakDef.WINNING_STREAK_TOTAL_COUNT) then
                self._viewNode.Panel_Progress:getChildByName("Panel_Streak"..i):getChildByName("Image_Sign"):loadTexture("hallcocosstudio/images/plist/WinningStreak/Bronze2.png",ccui.TextureResType.plistType)
            else
                self._viewNode.Panel_Progress:getChildByName("Panel_Streak"..i):getChildByName("Image_Sign"):loadTexture("hallcocosstudio/images/plist/WinningStreak/Bronze1.png",ccui.TextureResType.plistType)
            end
            self._viewNode.Panel_Progress:getChildByName("Panel_Streak"..i):getChildByName("Image_Status"):setVisible(false)
        end
    end
end

function WinningStreakCtrl:onClickPlay( )
    my.playClickBtnSound()

    if not CenterCtrl:checkNetStatus() then
        self:removeSelfInstance()
        return
    end

    local info = WinningStreakModel:GetWinningStreakInfo()
    if not info then return end

    if my.isInGame() then   --游戏中点去对局直接关闭
        self:goBack()
        return
    end

--    local GAP_SCHEDULE = 2 --间隔时间2秒
--    local nowTime = os.time()
--    self._lastTime = self._lastTime or 0
--    if nowTime - self._lastTime > GAP_SCHEDULE then
--        self._lastTime = nowTime
--    else
--        my.informPluginByName({pluginName = 'TipPlugin',params = {tipString = "点击太频繁，请2秒后再操作", removeTime = 3}})
--        return
--    end

    --触发快速开始的逻辑
    my.dataLink(cc.exports.DataLinkCodeDef.WINNING_STREAK_CLICK_PLAY)
    local HallContext = import('src.app.plugins.mainpanel.HallContext'):getInstance()
    HallContext:dispatchEvent({name = HallContext.EVENT_MAP["hall_gotoGameByQuickStart"], value = {["autoDecideRoomScope"] = true}})
end

function WinningStreakCtrl:onClickHelp()
    my.dataLink(cc.exports.DataLinkCodeDef.WINNING_STREAK_CLICK_HELP)
    my.playClickBtnSound()

    if not CenterCtrl:checkNetStatus() then
        self:removeSelfInstance()
        return
    end

    local info = WinningStreakModel:GetWinningStreakInfo()
    if not info then return end

--    local GAP_SCHEDULE = 2 --间隔时间2秒
--    local nowTime = os.time()
--    self._lastTime = self._lastTime or 0
--    if nowTime - self._lastTime > GAP_SCHEDULE then
--        self._lastTime = nowTime
--    else
--        my.informPluginByName({pluginName = 'TipPlugin',params = {tipString = "点击太频繁，请2秒后再操作", removeTime = 3}})
--        return
--    end

    --看是否是弄一个新的插件
    my.informPluginByName({pluginName='WinningStreakRuleCtrl'})
end

function WinningStreakCtrl:convertMoneyFormat(nMoney, nDigit)
    if not nMoney then return "" end
    if nDigit and 'number' ~= type(nDigit) then return nMoney end
    if 'string' ~= type(nMoney) and 'number' ~= type(nMoney) then return "" end

    local sFormat, nCount = string.gsub(nMoney, "%d+", "%%s")
    if 0 >= nCount then return nMoney end

    local function format_func(func, count, digit)
        local nNumber, nResult = func(), nil
        if string.len(tostring(nNumber)) <= 4 then
            nResult = (tostring(nNumber))
        elseif string.len(tostring(nNumber)) <= 8 then
            local nInteger = tostring(math.floor(nNumber / 10000))
            if string.len(nInteger) >= digit then
                nResult = (tostring(nInteger).."万")
            else
                local nTemp = string.sub(tostring(nNumber / 10000), 1, digit + 1)
                nResult = (tostring(tonumber(nTemp)).."万")
            end
        else
            local nInteger = tostring(math.floor(nNumber / 100000000))
            if string.len(nInteger) >= digit then
                nResult = (tostring(nInteger).."亿")
            else
                local nTemp = string.sub(tostring(nNumber / 100000000), 1, digit + 1)
                nResult = (tostring(tonumber(nTemp)).."亿")
            end
        end
        count = count - 1
        if 0 >= count then
            return nResult
        else
            return nResult, format_func(func, count, digit)
        end
    end
    local match_itor = string.gmatch(nMoney, "%d+")
    return string.format(sFormat, format_func(match_itor, nCount, nDigit or 4))
end

return WinningStreakCtrl