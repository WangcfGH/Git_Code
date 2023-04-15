local PhoneFeeGiftCtrl = class("PhoneFeeGiftCtrl")
local viewCreater       = import("src.app.plugins.PhoneFeeGift.PhoneFeeGiftView")
local PhoneFeeGiftModel = import("src.app.plugins.PhoneFeeGift.PhoneFeeGiftModel"):getInstance()
local PhoneFeeGiftDef = import('src.app.plugins.PhoneFeeGift.PhoneFeeGiftDef')
local PhoneFeeGiftCache = import('src.app.plugins.PhoneFeeGift.PhoneFeeGiftCache'):getInstance()
local MyTimeStamp = import('src.app.mycommon.mytimestamp.MyTimeStamp'):getInstance()
local Def               = import("src.app.plugins.RewardTip.RewardTipDef")
local CenterCtrl = require('src.app.BaseModule.CenterCtrl'):getInstance()

local PROCESS_DST = 3
local BTN_REWARD_STATUS = {
    NOMAL_REWARD = 0,
    TOMORROW_REWARD = 1,
    ALEADY_REWARD = 2
}

function PhoneFeeGiftCtrl:ctor(...)
    self._viewNode = self:setViewIndexer(viewCreater:createViewIndexer())
    if self._PFGTipConten == nil then
        local FileNameString = "src/app/plugins/PhoneFeeGift/PhoneFeeGift.json"
        local content = cc.FileUtils:getInstance():getStringFromFile(FileNameString)
        self._PFGTipConten = cc.load("json").json.decode(content)
    end
    self:initialListenTo()
    self:initialBtnClick()
    self:showDefault()
    self._processNum = 0

    self._aniBubble = nil   
    self._aniHetuArry = {}

    self._PlayZaDanLeft = nil
    self._PlayZaDanMid = nil
    self._PlayZaDanRight = nil

    self:refreshCountDown()
    self:updateUI()
    self._BtnTouchStatus = true
end

function PhoneFeeGiftCtrl:onEnter( ... )
    --self:refreshCountDown()
    --self:updateUI()
    self._alive = true
    self._BtnTouchStatus = true
end

function PhoneFeeGiftCtrl:onCtrlResume()
    self:refreshCountDown()
    self:updateUI()
end

function PhoneFeeGiftCtrl:onExit()
    -- 一调用就卡死，且断点进不来  
    self._alive = false  
    if self._coutndowntimer then
        self._coutndowntimer:stopcountdown()
        self._coutndowntimer = nil
    end

    print("PhoneFeeGiftCtrl:onExit")

    if self._aniBubble then
        self._aniBubble:stopAllActions()
        self._aniBubble = nil 
    end

    if self._CDTimer then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._CDTimer)
        self._CDTimer = nil
    end

    if self._CDTimerHideAniShade then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._CDTimerHideAniShade)
        self._CDTimerHideAniShade = nil
    end

    if self._CDTimerHideAniZadan then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._CDTimerHideAniZadan)
        self._CDTimerHideAniZadan = nil
    end

    self._aniHetuArry = {}

end

function PhoneFeeGiftCtrl:initialListenTo( )

end

function PhoneFeeGiftCtrl:initialBtnClick( )
    local viewNode = self._viewNode
    viewNode.btnGoFight:addClickEventListener(handler(self, self.onClickBtnGoFighting))
    viewNode.btnReward:addClickEventListener(handler(self, self.onClickBtnReward))
end

function PhoneFeeGiftCtrl:createAnimationRepeat(delayTime)
    local time = 1
    local scaleto1 = cc.ScaleTo:create(time, 0.9, 0.9)
    local scaleto2 = cc.ScaleTo:create(time, 1.1, 1.1)
    local scaleto3 = cc.ScaleTo:create(time, 1, 1)
    --local actMoveBy1 = cc.MoveBy:create(time, cc.p(0, 10))
    --local actMoveBy2 = cc.MoveBy:create(time, cc.p(0, -10))
    local delayAction     = cc.DelayTime:create(delayTime)         
    --序列
    local sequenceAction  = cc.Sequence:create(scaleto1, scaleto2, scaleto1, scaleto2, scaleto3, delayAction)
    --重复
    local repeatForever = cc.RepeatForever:create(sequenceAction)
    return repeatForever
end


function PhoneFeeGiftCtrl:createAnimationWithCallBack(delayTime,  callback)
    local time = 0.3
    local actMoveBy1 = cc.MoveBy:create(time, cc.p(0, 10))
    local actMoveBy2 = cc.MoveBy:create(time, cc.p(0, -10))
    local delayAction     = cc.DelayTime:create(delayTime)    
    local sequenceAction  = cc.Sequence:create(actMoveBy1,actMoveBy2, actMoveBy1,actMoveBy2, delayAction, cc.CallFunc:create(callback))
    return sequenceAction
end

function PhoneFeeGiftCtrl:playAnimationZadan(aniNode)
    if not aniNode then return end

    aniNode:setVisible(true)
    local aniHitFile= "res/hallcocosstudio/activitycenter/zadan.csb"
    aniNode:stopAllActions()
    local aniDraw = cc.CSLoader:createTimeline(aniHitFile)
    if not tolua.isnull(aniDraw) then
        aniNode:runAction(aniDraw)
        aniDraw:play("animation0", false)
    end
end

function PhoneFeeGiftCtrl:playAniHetuComing(aniNode)
    local time = 0.5
    local firstDelay = 2
    aniNode:setScale(0.1)
    local delayAction     = cc.DelayTime:create(firstDelay)    
    local scaleto1 = cc.ScaleTo:create(time, 0.6, 0.6)
    local scaleto2 = cc.ScaleTo:create(time, 1.1, 1.1)
    local scaleto3 = cc.ScaleTo:create(time, 1, 1)       
    local sequenceAction  = cc.Sequence:create(delayAction, scaleto1, scaleto2, scaleto3)
    aniNode:runAction(sequenceAction)
end

-- 等到活动界面点击话费礼后更新
function PhoneFeeGiftCtrl:onEnterAfterActivityBtnClick(bReadCacheFirst)
    local zadanCache = PhoneFeeGiftCache:getDataWithUserID()
    local strTodayDate = os.date("%Y%m%d", MyTimeStamp:getLatestTimeStamp())
    local nTodayDate = tonumber(strTodayDate)
    if nTodayDate ~=  zadanCache.loginDate then 
        zadanCache.loginDate = nTodayDate   -- 玩家点击后，把loginDate写入缓存，下次登陆就不会亮红点，直到第二天
        PhoneFeeGiftCache:saveCacheFileByName(zadanCache)
    end

    local viewNode = self._viewNode
    self._PlayZaDanAni = false
    if true == bReadCacheFirst then
        local info = PhoneFeeGiftModel:GetPhoneFeeGiftInfo()
        if info.nSignDate <= nTodayDate then -- 当前日期等于报名日期
            if  next(zadanCache) ~= nil and zadanCache.aniLeftPlayed == 0 then
                self._PlayZaDanLeft = true
            end
        end
        if info.nPlayBout >= info.nDstBout then -- 局数达到目标
            if next(zadanCache) ~= nil and zadanCache.aniMidPlayed == 0 then
                self._PlayZaDanMid = true
            end
        end

        if nTodayDate > info.nSignDate  and nTodayDate < info.nEndDate then
            if next(zadanCache) ~= nil and zadanCache.aniRightPlayed == 0 then
                self._PlayZaDanRight = true
            end
        end
    end

    if  true == self._PlayZaDanLeft then
        -- 首次点开播放砸蛋动画（开发后期加的需求，不使用数据库控制了，缓存控制）
        viewNode.imgEggBrokenleft:setVisible(true)
        viewNode.imgEggNomalLeft:setVisible(false)
        self._zadanLeftNode = viewNode.nodeZadanLeft
        self:playAnimationZadan(self._zadanLeftNode )
        self:playAniHetuComing(viewNode.imgHetu1)
        
        zadanCache.aniLeftPlayed =  1
        self._PlayZaDanAni = true
        self._PlayZaDanLeft = nil
    end

    if true == self._PlayZaDanMid then
        viewNode.imgEggBrokenMid:setVisible(true)
        viewNode.imgEggNomalMid:setVisible(false)
        self._zadanMidNode = viewNode.nodeZadanMid
        self:playAnimationZadan(self._zadanMidNode)

        self:playAniHetuComing(viewNode.imgHetu2)
        zadanCache.aniMidPlayed = 1
        self._PlayZaDanAni = true
        self._PlayZaDanMid = nil
    end

    if true == self._PlayZaDanRight then
        viewNode.imgEggBrokenRight:setVisible(true)
        viewNode.imgEggNomalRight:setVisible(false)
        self._zadanRightNode = viewNode.nodeZadanRight
        self:playAnimationZadan(self._zadanRightNode)

        self:playAniHetuComing(viewNode.imgHetu3)
        zadanCache.aniRightPlayed = 1
        self._PlayZaDanAni = true
        self._PlayZaDanRight = nil
    end

    local function hideAniZadanNode()
        if not self._alive then return end
        if tolua.isnull(self._zadanLeftNode) or tolua.isnull(self._zadanMidNode) or tolua.isnull(self._zadanRightNode) then return end

        if self._zadanLeftNode then
            self._zadanLeftNode:setVisible(false)
            --viewNode.imgEggBrokenleft:setVisible(true)
            --viewNode.imgEggNomalLeft:setVisible(false)
        end

        if self._zadanMidNode then
            self._zadanMidNode:setVisible(false)
            --viewNode.imgEggNomalMid:setVisible(false)
            --viewNode.imgEggBrokenMid:setVisible(true)
        end

        if self._zadanRightNode then
            self._zadanRightNode:setVisible(false)
            --viewNode.imgEggNomalRight:setVisible(false)
            --viewNode.imgEggBrokenRight:setVisible(true)
        end
    end

    if self._PlayZaDanAni == true then -- 表示有播放过动画
        self._CDTimerHideAniZadan = my.scheduleOnce(hideAniZadanNode, 3)
        PhoneFeeGiftCache:saveCacheFileByName(zadanCache)
    end
end

function PhoneFeeGiftCtrl:updateUI()
    local info = PhoneFeeGiftModel:GetPhoneFeeGiftInfo()
    if nil == info then 
        PhoneFeeGiftModel:gc_PhoneFeeGiftReq()
        return
    end
    self._processNum = 0

    local viewNode = self._viewNode

    local strTodayDate = os.date("%Y%m%d", MyTimeStamp:getLatestTimeStamp())
    local nTodayDate = tonumber(strTodayDate)
    
    local zadanCache = PhoneFeeGiftCache:getDataWithUserID()
    if info.nSignDate <= nTodayDate then -- 当前日期等于报名日期
        if  next(zadanCache) ~= nil and zadanCache.aniLeftPlayed == 0 then
            -- 首次点开播放砸蛋动画（开发后期加的需求，不使用数据库控制了，缓存控制）
            -- 放到活动界面点击话费礼页签的时候播放
            self._PlayZaDanLeft = true
        end 
        viewNode.imgEggBrokenleft:setVisible(true)
        viewNode.imgEggNomalLeft:setVisible(false)

        if true == viewNode.imgEggBrokenleft:isVisible() and info.isTakeReward <= 0 then
            table.insert(self._aniHetuArry, viewNode.imgHetu1)
        end   
        
        self._processNum  = self._processNum + 1
    end

    if info.nPlayBout >= info.nDstBout then -- 局数达到目标
        if next(zadanCache) ~= nil and zadanCache.aniMidPlayed == 0 then
            self._PlayZaDanMid = true
        end
 
        viewNode.imgEggNomalMid:setVisible(false)
        viewNode.imgEggBrokenMid:setVisible(true)

        if true == viewNode.imgEggBrokenMid:isVisible() and info.isTakeReward <= 0 then
            table.insert(self._aniHetuArry, viewNode.imgHetu2)
        end

        self._processNum  = self._processNum + 1
    else
        -- 全蛋显示且 显示局数进度
        viewNode.imgEggNomalMid:setVisible(true)
        viewNode.imgEggBrokenMid:setVisible(false)
        if true == viewNode.imgEggNomalMid:isVisible() then
            local tipString = string.format(self._PFGTipConten["PFG_MID_BUBBLE_TIP"],  info.nDstBout, info.nPlayBout)
            viewNode.textDuiju:setString(tipString)
        end
    end

    if nTodayDate > info.nSignDate  and nTodayDate < info.nEndDate then

        if next(zadanCache) ~= nil and zadanCache.aniRightPlayed == 0 then
            self._PlayZaDanRight = true
        end

        viewNode.imgEggNomalRight:setVisible(false)
        viewNode.imgEggBrokenRight:setVisible(true)

        if true == viewNode.imgEggBrokenRight:isVisible()  and info.isTakeReward <= 0 then
            table.insert(self._aniHetuArry, viewNode.imgHetu3)
        end

        self._processNum  = self._processNum + 1
    end

    --话费气泡
    if nil == self._aniBubble then
        if  info.isTakeReward == 0 then
            local deltaNum = PROCESS_DST - self._processNum
            local nYuanHuafei = info.nRewardNum
            if deltaNum > 0 then
                local tipString = string.format(self._PFGTipConten["PFG_BUBBLE_HUAFEI"], deltaNum, nYuanHuafei)
                viewNode.txt_tiphuafe:setString(tipString)
            else
                local tipString = string.format(self._PFGTipConten["PFG_BUBBLE_GETREWARD"], deltaNum, nYuanHuafei)
                viewNode.txt_tiphuafe:setString(tipString)
            end
            self._aniBubble = viewNode.brokenBubble4
            local repeatForever = self:createAnimationRepeat(1)
            self._aniBubble:runAction(repeatForever)
        else
            viewNode.brokenBubble4:setVisible(false)
        end
    end

    -- 轮播三张标签动画
    self:playImgAction()

    -- 设置话费几元
    if viewNode.fntHuafei  then
        local money = info.nRewardNum
        if not money then money = 2000 end
        viewNode.fntHuafei:setString(money)
    end

    -- 进度条
    viewNode.loadingBar:setPercent((self._processNum*100)/PROCESS_DST)
    local text = self._processNum..'/3'
    viewNode.fntProcess:setString(text)

    if info.isComplete == 1 or  self._processNum > 2 then
        viewNode.btnGoFight:setVisible(false)
        viewNode.btnReward:setVisible(true)
        -- 领取按钮的显示
        if nTodayDate == info.nSignDate then
            -- 显示明日领取
            local imgBtn = "hallcocosstudio/images/plist/PhoneFeeGift/Btn_Draw.png"
            local imgLingquTomorrow = "hallcocosstudio/images/plist/PhoneFeeGift/lingqu_ex.png"
            viewNode.btnReward:loadTextureNormal(imgBtn, 1)
            viewNode.btnReward:loadTexturePressed(imgBtn, 1)
            viewNode.imgLingQu:setSpriteFrame(imgLingquTomorrow)
            self._lingquEnable = BTN_REWARD_STATUS.TOMORROW_REWARD
        elseif nTodayDate > info.nSignDate  and nTodayDate < info.nEndDate then
            -- 显示领取或者 已领取
            local imgBtn = "hallcocosstudio/images/plist/PhoneFeeGift/lingqu_btn.png"
            local imgLingqu = "hallcocosstudio/images/plist/PhoneFeeGift/lingqu.png"
            if info.isTakeReward == 0 then
                imgBtn = "hallcocosstudio/images/plist/PhoneFeeGift/lingqu_btn.png"
                imgLingqu = "hallcocosstudio/images/plist/PhoneFeeGift/lingqu.png"
                self._lingquEnable = BTN_REWARD_STATUS.NOMAL_REWARD
            else
                imgBtn= "hallcocosstudio/images/plist/PhoneFeeGift/yilingqu_btn.png"
                imgLingqu = "hallcocosstudio/images/plist/PhoneFeeGift/yilingqu.png"
                self._lingquEnable = BTN_REWARD_STATUS.ALEADY_REWARD
            end
            viewNode.btnReward:loadTextureNormal(imgBtn, 1)
            viewNode.btnReward:loadTexturePressed(imgBtn, 1)
            viewNode.imgLingQu:setSpriteFrame(imgLingqu)

            if self._lingquEnable == BTN_REWARD_STATUS.NOMAL_REWARD then
                local aniBtnFile= "res/hallcocosstudio/activitycenter/cj_anniu.csb"

                viewNode.btnReward:setVisible(true)
                viewNode.btnReward:stopAllActions()
                local action = cc.CSLoader:createTimeline(aniBtnFile)
                if not tolua.isnull(action) then
                    viewNode.btnReward:runAction(action)
                    action:play("animation0", true)
                end

            end
        else
            -- 不在活动期间内
            viewNode.btnGoFight:setVisible(false)
            viewNode.btnReward:setVisible(false)
        end
    end
end

function PhoneFeeGiftCtrl:playImgAction()
    local  function nextAnimation()
        self:playImgAction()
    end
    if #self._aniHetuArry == 0 then
        return
    end

    if not self._hetuIndex then  self._hetuIndex = 0 end
    self._hetuIndex = self._hetuIndex + 1
    if self._hetuIndex > #self._aniHetuArry then self._hetuIndex = 1 end

    local sequence = self:createAnimationWithCallBack(1, nextAnimation)
    self._aniHetuArry[self._hetuIndex]:runAction(sequence)

end


function PhoneFeeGiftCtrl:onPhoneFeeGiftClockZero()
    self:onExit()
end

function PhoneFeeGiftCtrl:onPhoneFeeGiftNewDay()
    self:updateUI()
end

function PhoneFeeGiftCtrl:showDefault()
    local viewNode = self._viewNode
    viewNode.imgEggBrokenleft:setVisible(false)
    viewNode.imgEggNomalLeft:setVisible(true)
       
    viewNode.imgEggBrokenMid:setVisible(false)
    viewNode.imgEggNomalMid:setVisible(true)

    viewNode.imgEggBrokenRight:setVisible(false)
    viewNode.imgEggNomalRight:setVisible(true)

    viewNode.btnGoFight:setVisible(true)
    viewNode.btnReward:setVisible(false)
    viewNode.nodeReward:setVisible(false)

    viewNode.panelAniShade:setVisible(false)

    viewNode.nodeZadanLeft:setVisible(false)
    viewNode.nodeZadanMid:setVisible(false)
    viewNode.nodeZadanRight:setVisible(false)

end


function PhoneFeeGiftCtrl:refreshCountDown()
    local viewNode = self._viewNode
    local info = PhoneFeeGiftModel:GetPhoneFeeGiftInfo()
    if info ~= nil then
        local nowtimestamp = MyTimeStamp:getLatestTimeStamp()
        local strNowDate = os.date("%Y%m%d", nowtimestamp)
        local nNowDate = tonumber(strNowDate)
        local nEndDate = info.nEndDate

        if self._coutndowntimer == nil then
            self._coutndowntimer = import("src.app.plugins.timecalc.TimeCountDownEx").new(viewNode.textLeftSec, nNowDate, nEndDate, 000000, 240000, nowtimestamp)
            self._coutndowntimer:startcountdown()
        else

            self._coutndowntimer:resettime(nNowDate, nEndDate, 000000, 240000, nowtimestamp)
        end
    end
end

function PhoneFeeGiftCtrl:onPhoneFeeGiftUpdate()
    self:updateUI()
end

function PhoneFeeGiftCtrl:onPhoneFeeGiftRewardGet(data)
    if nil == data.value then
        return
    end

    -- 关闭碎片飘动画
    self._aniHetuArry = {}  -- 停止轮动
    -- 隐藏话费气泡
    if self._aniBubble then
        self._aniBubble:stopAllActions()
        self._aniBubble:setVisible(false)
        self._aniBubble = nil 
    end

    self:setRewardAniPlayingStatus(true)   -- 避免播放领奖动画时候，切换活动标题页签
    -- 播放动画
    local rewardRsp = data.value
    local info = PhoneFeeGiftModel:GetPhoneFeeGiftInfo()
    local viewNode = self._viewNode
    if info.isComplete == 1  and info.isTakeReward == 1 then
        local aniNode = viewNode.nodeReward
        aniNode:setVisible(true)
        local aniHitFile= "res/hallcocosstudio/activitycenter/huafei.csb"

        aniNode:stopAllActions()
        audio.playSound(cc.FileUtils:getInstance():fullPathForFilename('res/hall/sounds/PhoneFeeGift.mp3'),false)
        viewNode.panelAniShade:setVisible(true)
        local aniDraw = cc.CSLoader:createTimeline(aniHitFile)
        if not tolua.isnull(aniDraw) then
            aniNode:runAction(aniDraw)
            aniDraw:play("animation0", false)
        end
        aniNode:setVisible(true)

        local function hideAniShade()
            viewNode.panelAniShade:setVisible(false)
            aniNode:setVisible(false)
            local rewardList = {}
            table.insert( rewardList,{nType = Def.TYPE_SILVER, nCount = rewardRsp.nRewardNum}) 
            my.informPluginByName({pluginName = 'RewardTipCtrl', params = {data = rewardList, showtip = true,}})

            self:setRewardAniPlayingStatus(false)        --动画结束，恢复活动页签可点击状态
        end
        self._CDTimerHideAniShade =my.scheduleOnce(hideAniShade, 2.5)
    end   
    
    local imgBtn= "hallcocosstudio/images/plist/PhoneFeeGift/yilingqu_btn.png"
    local imgLingqu = "hallcocosstudio/images/plist/PhoneFeeGift/yilingqu.png"
    self._lingquEnable = BTN_REWARD_STATUS.ALEADY_REWARD
    viewNode.btnReward:stopAllActions()
    viewNode.btnReward:loadTextureNormal(imgBtn, 1)
    viewNode.btnReward:loadTexturePressed(imgBtn, 1)
    viewNode.imgLingQu:setSpriteFrame(imgLingqu) 
end

function PhoneFeeGiftCtrl:onPhoneFeeGiftRewardFailed(data)
    if nil == data.value then
        return
    end

    local rsp = data.value
    if PhoneFeeGiftDef.STATUS_REWARD_SOAP_FAILED == rsp.nStatusCode then
        my.informPluginByName({pluginName='TipPlugin',params={tipString = self._PFGTipConten["PFG_REWARD_SOAP_FAILED"], removeTime = 2}})
    elseif PhoneFeeGiftDef.STATUS_ALEADY_REWARD == rsp.nStatusCode then
        my.informPluginByName({pluginName='TipPlugin',params={tipString = self._PFGTipConten["PFG_ALEADY_REWARD"], removeTime = 2}})
    elseif PhoneFeeGiftDef.STATUS_REWARD_EXCEED == rsp.nStatusCode then
        my.informPluginByName({pluginName='TipPlugin',params={tipString = self._PFGTipConten["PFG_REWARD_TIME_EXCEED"], removeTime = 2}})
    else
        my.informPluginByName({pluginName='TipPlugin',params={tipString = self._PFGTipConten["PFG_UNKNOWN_ERROR"], removeTime = 2}})
    end

end


function PhoneFeeGiftCtrl:onClickBtnGoFighting()
    my.playClickBtnSound()
    if self._BtnTouchStatus == false then
        print("onClickBtnGoFighting return , can not press two btns one time!!!") 
        return
    end
    local function quickStart(dt)
        my.dataLink(cc.exports.DataLinkCodeDef.PHONE_FEE_GIFT_GO_FIGHT)
        local HallContext = import('src.app.plugins.mainpanel.HallContext'):getInstance()
        HallContext:dispatchEvent({name = HallContext.EVENT_MAP["hall_gotoGameByQuickStart"], value = {["autoDecideRoomScope"] = true}})
    end
    my.scheduleOnce(quickStart, 0.5)
    PhoneFeeGiftModel:notifyActivityCenterClose()
end

-- 防止公告title页签和领奖/去对战按钮同时点击问题，这里设置按钮状态
function PhoneFeeGiftCtrl:setBtnsTouchStatus(bEnable)
    self._BtnTouchStatus = bEnable
end
-- 防止公告title页签和领奖/去对战按钮同时点击问题，这里设置按钮状态
function PhoneFeeGiftCtrl:setRewardAniPlayingStatus(bPlaying)
    self._AniPlaying = bPlaying
end
-- 防止公告title页签和领奖/去对战按钮同时点击问题，活动ctrl读取该状态决定是否相应页签切换
function PhoneFeeGiftCtrl:getRewardAniPlayingStatus()
    if self._AniPlaying then
        return self._AniPlaying
    end
    return false
end
function PhoneFeeGiftCtrl:onClickBtnReward()
    my.playClickBtnSound()
    if self._BtnTouchStatus == false then
        print("onClickBtnReward return , can not press two btns one time!!!") 
        return
    end
    if self._waitingclick == true then 
        return 
    end
    self._waitingclick = true
    self._CDTimer = my.scheduleOnce(function()
        if self then
            self._CDTimer = nil
            self._waitingclick = false
        end
    end, 1)

    if BTN_REWARD_STATUS.NOMAL_REWARD ==  self._lingquEnable then
        -- 奖励请求

        PhoneFeeGiftModel:gc_PhoneFeeGiftRewardReq()

    elseif BTN_REWARD_STATUS.TOMORROW_REWARD == self._lingquEnable then
        my.informPluginByName({pluginName='TipPlugin',params={tipString = self._PFGTipConten["PFG_TOMORRWO_REWARD"], removeTime = 2}})
    elseif BTN_REWARD_STATUS.ALEADY_REWARD == self._lingquEnable then
        my.informPluginByName({pluginName='TipPlugin',params={tipString = self._PFGTipConten["PFG_ALEADY_REWARD"], removeTime = 2}})
    end

--[[
  if DEBUG and DEBUG > 0 then

        self:setRewardAniPlayingStatus(true) 
        local viewNode = self._viewNode
        if true then
            local aniNode = viewNode.nodeReward
            aniNode:setVisible(true)
            local aniHitFile= "res/hallcocosstudio/activitycenter/huafei.csb"

            aniNode:stopAllActions()
            audio.playSound(cc.FileUtils:getInstance():fullPathForFilename('res/hall/sounds/PhoneFeeGift.mp3'),false)
            viewNode.panelAniShade:setVisible(true)
            local aniDraw = cc.CSLoader:createTimeline(aniHitFile)
            if not tolua.isnull(aniDraw) then
                aniNode:runAction(aniDraw)
                aniDraw:play("animation0", false)
            end


            local function hideAniShade()
                viewNode.panelAniShade:setVisible(false)
                aniNode:setVisible(false)
                local rewardList = {}
                table.insert( rewardList,{nType = 2,nCount = 200})
                my.informPluginByName({pluginName = 'RewardTipCtrl', params = {data = rewardList, showtip = true,}})
                self:setRewardAniPlayingStatus(false)        --动画结束，恢复活动页签可点击状态
            end
            my.scheduleOnce(hideAniShade, 2.5)
        end   
    end
    ]]
end

function PhoneFeeGiftCtrl:setViewIndexer(viewIndexer)
    self._viewNode=viewIndexer
    return self._viewNode
end


return PhoneFeeGiftCtrl