local ActivityRedPack100Ctrl = class("ActivityRedPack100Ctrl")
local viewCreater       = import("src.app.plugins.RedPack100.ActivityRedPack100View")
local RedPack100Model = import("src.app.plugins.RedPack100.RedPack100Model"):getInstance()
local RedPack100Def = import('src.app.plugins.RedPack100.RedPack100Def')
local RedPack100Cache = import('src.app.plugins.RedPack100.RedPack100Cache'):getInstance()
local MyTimeStamp = import('src.app.mycommon.mytimestamp.MyTimeStamp'):getInstance()
local RewardTipDef               = import("src.app.plugins.RewardTip.RewardTipDef")

local BTN_REWARD_STATUS = {
    NOMAL_REWARD = 0,
    ALEADY_REWARD = 1
}


function ActivityRedPack100Ctrl:setViewIndexer(viewIndexer)
    self._viewNode=viewIndexer
    return self._viewNode
end


function ActivityRedPack100Ctrl:ctor(...)
    cc.SpriteFrameCache:getInstance():addSpriteFrames("res/hallcocosstudio/images/plist/RedPack100Ani.plist")
    --cc.SpriteFrameCache:getInstance():addSpriteFrames("res/hallcocosstudio/images/plist/RedPack100.plist")    
    self._viewNode = self:setViewIndexer(viewCreater:createViewIndexer())
    if self._RedPackTipConten == nil then
        local FileNameString = "src/app/plugins/RedPack100/RedPack100.json"
        local content = cc.FileUtils:getInstance():getStringFromFile(FileNameString)
        self._RedPackTipConten = cc.load("json").json.decode(content)
    end


    self:initialize()
    self:initialBtnClick()
    self:refreshCountDown()
    self:startUpdateTimer()
end

function ActivityRedPack100Ctrl:initialize()
    self._viewNode.panelAniShade:setVisible(false)
    self._viewNode.imgTipFight:setVisible(false)
    self._viewNode.lodingBarValue:setPercent( 0 )
    local strDiffMoney = string.format(self._RedPackTipConten.DIFF_MONEY, 100)
    self._viewNode.txtDiffValue:setString(strDiffMoney)
    self._viewNode.txtMinus:setVisible(false)
end

function ActivityRedPack100Ctrl:startUpdateTimer()
    if self._updateTimer == nil then
        self._updateTimer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(RedPack100Model,RedPack100Model.gc_UpdateRedPackReq),300,false)
    end
end

function ActivityRedPack100Ctrl:stopUpdateTimer()
    if self._updateTimer then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._updateTimer)
        self._updateTimer = nil
    end
end



function ActivityRedPack100Ctrl:onEnter( ... )
    print("ActivityRedPack100Ctrl:onEnter...")
end

function ActivityRedPack100Ctrl:onCtrlResume()
    print("ActivityRedPack100Ctrl:onCtrlResume...")
    self:refreshCountDown()
    self:updateUI()
end

function ActivityRedPack100Ctrl:onExit()
    print("ActivityRedPack100Ctrl:onExit...")
    if self._CDTimerHideAni then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._CDTimerHideAni)
        self._CDTimerHideAni = nil
    end
    if self._aniBtnJump then
        self._aniBtnJump:stopAllActions()
        self._aniBtnJump = nil 
    end
    
    if self._BubbleNode then
        self._BubbleNode:stopAllActions()
        self._BubbleNode = nil 
    end

    if self._BubbleTxtNode then
        self._BubbleTxtNode:stopAllActions()
        self._BubbleTxtNode = nil 
    end

    self:stopUpdateTimer()
end

-- 领奖的按钮动画效果  循环
function ActivityRedPack100Ctrl:playTiquBtnAni(aniNode)
    if not aniNode then return end

    aniNode:setVisible(true)
    local aniHitFile= "res/hallcocosstudio/redpack100/tiquanniu.csb"
    aniNode:stopAllActions()
    local aniDraw = cc.CSLoader:createTimeline(aniHitFile)
    if not tolua.isnull(aniDraw) then
        aniNode:runAction(aniDraw)
        aniDraw:play("animation0", true)
    end
    aniNode:setVisible(true)
end

-- 拆红包按钮动画效果  循环
function ActivityRedPack100Ctrl:playBreakBtnAni(aniNode)
    if not aniNode then return end

    aniNode:setVisible(true)
    local aniHitFile= "res/hallcocosstudio/redpack100/dianjianniu.csb"
    aniNode:stopAllActions()
    local aniDraw = cc.CSLoader:createTimeline(aniHitFile)
    if not tolua.isnull(aniDraw) then
        aniNode:runAction(aniDraw)
        aniDraw:play("animation0", true)
    end
    aniNode:setVisible(true)
end

-- 领奖动画 不循环
function ActivityRedPack100Ctrl:playQuXianAni(viewNode, rewardRsp)
    local panelShade = viewNode.panelAniShade
    panelShade:setVisible(true) -- 设置取现动画的阴影背景

    -- 播放qq取现声音
    audio.playSound(cc.FileUtils:getInstance():fullPathForFilename('res/hall/sounds/RedPack100Tixian.mp3'),false)

    local aniNode = viewNode.nodeQuxian
    if not aniNode then return end

    aniNode:setVisible(true)
    local aniHitFile= "res/hallcocosstudio/redpack100/quxian.csb"
    aniNode:stopAllActions()
    local aniDraw = cc.CSLoader:createTimeline(aniHitFile)
    if not tolua.isnull(aniDraw) then
        aniNode:runAction(aniDraw)
        aniDraw:play("animation0", false)
    end

    local function onFrameEvent(frame)
        if frame then 
            local event = frame:getEvent()
            if "Play_Over" == event then
                self:QuXianAniCallBack(rewardRsp)
            end
        end
    end
    aniDraw:setFrameEventCallFunc(onFrameEvent)

    -- 定时器做确保
    local function hideAniQuxianNode()
        if nil  == self.bQuxianCalled then
            self:QuXianAniCallBack(rewardRsp)
        end
    end
    self._CDTimerHideAni = my.scheduleOnce(hideAniQuxianNode, 2.5)
end

function ActivityRedPack100Ctrl:playBubbleAni(aniBubbleNode)
    self._BubbleNode = aniBubbleNode
    self._BubbleNode:stopAllActions()

    local time = 0.3
    local scaleto1 = cc.ScaleTo:create(time, 0.9, 0.9)
    local scaleto2 = cc.ScaleTo:create(time, 1.1, 1.1)
    local scaleto3 = cc.ScaleTo:create(time, 1, 1)
    local actMoveBy1 = cc.MoveBy:create(time, cc.p(0, 10))
    local actMoveBy2 = cc.MoveBy:create(time, cc.p(0, -10))
    local delayAction     = cc.DelayTime:create(3)  
    --序列
    local sequenceAction  = cc.Sequence:create(scaleto1, scaleto2, scaleto1, scaleto2, scaleto3, actMoveBy1,actMoveBy2, actMoveBy1,actMoveBy2, delayAction)
    --重复
    local repeatForever = cc.RepeatForever:create(sequenceAction)
    --if not tolua.isnull(self._BubbleNode) then
        self._BubbleNode:runAction(repeatForever)
    --end
end

function ActivityRedPack100Ctrl:playBubbleTextAni(aniViewNode, breakInfo)
    self._BubbleTxtNode = aniViewNode.txtMinus
    local function callbackFunc()
        self._BubbleTxtNode:setVisible(false)
        self:setProcessMoneyValue(breakInfo.nAccumulateMoney)
        self:playBubbleAni(aniViewNode.imgDiffMoney)
    end
    
    local pos = cc.p(aniViewNode.txtDiffValue:getPosition())
    local time = 1
    local firstDelay = 1
    local delayAction     = cc.DelayTime:create(firstDelay)    
    local a1 = cc.FadeTo:create(time, 0)
    local a2 = cc.MoveTo:create(time, cc.p(pos.x+10, pos.y+100))
    local action1_spawn = cc.Spawn:create(a1, a2)
    self._BubbleTxtNode:setOpacity(255)
    self._BubbleTxtNode:setPosition(cc.p(pos.x+10, pos.y+20))
    local strMinus = string.format(self._RedPackTipConten.BREAK_GET_MONEY, breakInfo.nGetMoney/100)
    self._BubbleTxtNode:setString(strMinus)
    self._BubbleTxtNode:runAction(cc.Sequence:create(cc.Show:create(), delayAction, action1_spawn, cc.CallFunc:create(callbackFunc)))
end

-- 设置进度条
function ActivityRedPack100Ctrl:setProcessMoneyValue(nProcessMoney)
    local viewNode = self._viewNode
    -- 设置进度条进度
    local nAccuMoney = nProcessMoney/100
    viewNode.lodingBarValue:setPercent( nAccuMoney )
    -- 设置气泡剩余多少
    local diffMoney = 100 - nAccuMoney
    local strDiffMoney = string.format(self._RedPackTipConten.DIFF_MONEY, diffMoney)
    if diffMoney <= 0 then
        strDiffMoney = string.format(self._RedPackTipConten.REWARD_CAN_TIP)
    end

    viewNode.txtDiffValue:setString(strDiffMoney)
    -- 设置气泡位置
    local StartXInProcess = 90
    local xPos = math.floor(viewNode.lodingBarValue:getContentSize().width/100*nAccuMoney)
    viewNode.imgDiffMoney:setPositionX(StartXInProcess + xPos)
end

-- 从活动界面进入的函数
function ActivityRedPack100Ctrl:onEnterAfterActivityBtnClick(bReadCache)
    RedPack100Model:gc_GetRedPackInfo()
    self:updateUI()
end

function ActivityRedPack100Ctrl:updateUI()
    local viewNode = self._viewNode
    local breakInfo = RedPack100Model:GetRedPackInfo()
    -- 设置获奖用户列表数据
    if breakInfo.szCompleteUsers  and type(breakInfo.szCompleteUsers) == 'table' then
        for k,v in pairs(breakInfo.szCompleteUsers) do  
            if k > 3 then break end
            if v ~= "" then
                local txtName = "txtUserName"..k
                local utf8Name=MCCharset:getInstance():gb2Utf8String(v, string.len(v))
                my.fixUtf8Width(utf8Name, viewNode[txtName], 100)
            end
        end
    end

    -- 累计金额进度条
    local nProcessMoney = 0
    if false == RedPack100Model:isNeedPlayProcessTextAni() then
        if breakInfo.nAccumulateMoney > 0 then
            nProcessMoney = breakInfo.nAccumulateMoney
            if breakInfo.nAccumulateMoney > RedPack100Def.REDPACK_REWARD_NUM  then
                nProcessMoney = RedPack100Def.REDPACK_REWARD_NUM 
            end
            self:playBubbleAni(viewNode.imgDiffMoney)
        end
    else
        if breakInfo.nPrevMoney > 0 then
            nProcessMoney = breakInfo.nPrevMoney
            if breakInfo.nPrevMoney > RedPack100Def.REDPACK_REWARD_NUM then
                nProcessMoney = RedPack100Def.REDPACK_REWARD_NUM
            end
        end
    end

    self:setProcessMoneyValue(nProcessMoney)

    -- 按钮显示
    viewNode.btnJump:setVisible(false)
    viewNode.btnBreak:setVisible(false)
    viewNode.btnReward:setVisible(false)
    viewNode.btnLogin:setVisible(false)
    viewNode.imgTipFight:setVisible(false)

    local strTodayDate = os.date("%Y%m%d", MyTimeStamp:getLatestTimeStamp())
    local nTodayDate = tonumber(strTodayDate)       -- 服务器今日时间
            
    local strStartDate = string.format("%s000000", breakInfo.nStartDate)
    local strBtnShowDate = cc.exports.getNewDate(strStartDate, breakInfo.nBtnStartShowDay, "Day") -- 往后加x天,
    local nBtnShowDate = tonumber(strBtnShowDate)   -- 对局按钮显示日期
    if nTodayDate < nBtnShowDate then
        --新增代码 20200227
        if breakInfo.nAccumulateMoney >= RedPack100Def.REDPACK_REWARD_NUM then
            -- 显示领奖100元了
            viewNode.btnReward:setVisible(true)
            viewNode.lodingBarValue:setPercent( 100 )
            local strDiffMoney = string.format(self._RedPackTipConten.REWARD_CAN_TIP)
            viewNode.txtDiffValue:setString(strDiffMoney)

            if breakInfo.nRewardDate > 0 then
                viewNode.imgTixian:setVisible(false)
                viewNode.btnReward:setEnabled(false)
                viewNode.btnReward:loadTextureNormal("hallcocosstudio/images/plist/RedPack100/btn_disable.png", 1) -- 不知为何前面setEnabled false之后不置灰，这里强制替换
                viewNode.nodeTiqu:setVisible(false)
                viewNode.spriteReward:setSpriteFrame("hallcocosstudio/images/plist/RedPack100/aleady_rewarded.png")
                
                viewNode.txtMinus:setVisible(false)
                local strAleady = string.format(self._RedPackTipConten.REWARD_ALEADY_TIP, 0)
                viewNode.txtDiffValue:setString(strAleady)
            else
                self:playTiquBtnAni(viewNode.nodeTiqu)
            end
            return
        end
        if breakInfo.nCurrentDay <= 4 then
            --第四天不能参加惊喜夺宝活动，不要显示任务
            local ExchangeLotteryModel = require('src.app.plugins.ExchangeLottery.ExchangeLotteryModel'):getInstance()
            if breakInfo.nCurrentData == -1  or breakInfo.nDestData == 0 or (breakInfo.nCurrentDay ==4 and not ExchangeLotteryModel:GetActivityOpen())then   --配置为0表示当前任务活动关闭
                viewNode.btnLogin:setVisible(true)
                -- 未达到对局按钮显示器日期
                local diffMoney = 100 - breakInfo.nAccumulateMoney/100
                viewNode.btnLogin:setVisible(true)
                local nHopeMoney = math.ceil(diffMoney)
                local strHopeMoney = string.format(self._RedPackTipConten.BTN_LOGIN_HOPE_MONEY, nHopeMoney)
                viewNode.txtBMFontTip:setString(strHopeMoney)
            elseif breakInfo.nCurrentData < breakInfo.nDestData then
                viewNode.btnJump:setVisible(true)
                local strJumpBoutTip = string.format(self._RedPackTipConten.BTN_JUMP_BOUT_TIP, breakInfo.nCurrentData, breakInfo.nDestData)
                viewNode.txtBMFont:setString(strJumpBoutTip)
                -- 最后一行对局提示

                if breakInfo.nDestData > 0 then
                    local stTip = string.format(self._RedPackTipConten["FIGHT_DEST_DAY_TASK"..breakInfo.nCurrentDay], breakInfo.nDestData)
                    viewNode.txtTipFight:setString(stTip)
                    viewNode.imgTipFight:setVisible(true)
                end

                if not self._aniBtnJump then
                    self._aniBtnJump = viewNode.btnJump
                    local repeatForever = self:createAnimationRepeat(0.1)
                    self._aniBtnJump:runAction(repeatForever)
                end
            elseif breakInfo.nCurrentData >= breakInfo.nDestData then
                viewNode.btnBreak:setVisible(true)
                self:playBreakBtnAni(viewNode.nodeBreak)
            end
        end
    else
        -- 达到了对局按钮显示日期
        if breakInfo.nAccumulateMoney >= RedPack100Def.REDPACK_REWARD_NUM then
            -- 显示领奖100元了
            viewNode.btnReward:setVisible(true)
            viewNode.lodingBarValue:setPercent( 100 )
            local strDiffMoney = string.format(self._RedPackTipConten.REWARD_CAN_TIP)
            viewNode.txtDiffValue:setString(strDiffMoney)

            if breakInfo.nRewardDate > 0 then
                viewNode.imgTixian:setVisible(false)
                viewNode.btnReward:setEnabled(false)
                viewNode.btnReward:loadTextureNormal("hallcocosstudio/images/plist/RedPack100/btn_disable.png", 1) -- 不知为何前面setEnabled false之后不置灰，这里强制替换
                viewNode.nodeTiqu:setVisible(false)
                viewNode.spriteReward:setSpriteFrame("hallcocosstudio/images/plist/RedPack100/aleady_rewarded.png")
                
                viewNode.txtMinus:setVisible(false)
                local strAleady = string.format(self._RedPackTipConten.REWARD_ALEADY_TIP, 0)
                viewNode.txtDiffValue:setString(strAleady)
            else
                self:playTiquBtnAni(viewNode.nodeTiqu)
            end
        else
            if breakInfo.nAvailableBout >= breakInfo.nDestBout then
                viewNode.btnBreak:setVisible(true)
                self:playBreakBtnAni(viewNode.nodeBreak)
            else
                viewNode.btnJump:setVisible(true)
                local strJumpBoutTip = string.format(self._RedPackTipConten.BTN_JUMP_BOUT_TIP, breakInfo.nAvailableBout, breakInfo.nDestBout)
                viewNode.txtBMFont:setString(strJumpBoutTip)
                -- 最后一行对局提示

                if breakInfo.nDestBout > 0 then
                    local stTip = string.format(self._RedPackTipConten.FIGHT_DEST_BOUT_TIP, breakInfo.nDestBout)
                    viewNode.txtTipFight:setString(stTip)
                    viewNode.imgTipFight:setVisible(true)
                end

                if not self._aniBtnJump then
                    self._aniBtnJump = viewNode.btnJump
                    local repeatForever = self:createAnimationRepeat(0.1)
                    self._aniBtnJump:runAction(repeatForever)
                end
            end
        end
    end

    if true == RedPack100Model:isNeedPlayProcessTextAni() then
        -- 需要播放飘文字动画
        local breakInfo = RedPack100Model:GetRedPackInfo()
            if breakInfo.nRewardDate <= 0 then  -- 该条件避免领奖后，出现首次登陆直接进入活动界面，状态会出现可提现问题
                self:playBubbleTextAni(self._viewNode, breakInfo)
            end
        RedPack100Model:setDataForProcessAni(breakInfo.nAccumulateMoney, false)
    end
end


function ActivityRedPack100Ctrl:createAnimationRepeat(delayTime)
    local time = 0.3
    local scaleto2 = cc.ScaleTo:create(time, 1.1, 1.1)
    local scaleto3 = cc.ScaleTo:create(time, 1, 1)
    local delayAction     = cc.DelayTime:create(delayTime)         
    --序列
    local sequenceAction  = cc.Sequence:create(scaleto2, scaleto3, delayAction)
    --重复
    local repeatForever = cc.RepeatForever:create(sequenceAction)
    return repeatForever
end

function ActivityRedPack100Ctrl:initialBtnClick( )
    local viewNode = self._viewNode
    viewNode.btnJump:addClickEventListener(handler(self, self.onClickBtnJump))
    viewNode.btnBreak:addClickEventListener(handler(self, self.onClickBtnBreak))
    viewNode.btnReward:addClickEventListener(handler(self, self.onClickBtnReward))
    viewNode.btnLogin:addClickEventListener(handler(self, self.onClickBtnLogin))
    viewNode.btnHelp:addClickEventListener(handler(self, self.onClickBtnHelp))
end


function ActivityRedPack100Ctrl:onClickBtnJump()
    my.playClickBtnSound()
    local breakInfo = RedPack100Model:GetRedPackInfo()
    if breakInfo.nCurrentDay <= 4 and breakInfo.nCurrentData ~= -1  and breakInfo.nDestData ~= 0 then
        if breakInfo.nCurrentDay == 1 then
            --经典房
            local HallContext = import('src.app.plugins.mainpanel.HallContext'):getInstance()
            HallContext:dispatchEvent({name = HallContext.EVENT_MAP["hall_gotoGameByQuickStart"], value = {["findScope"] = "classic"}})
        elseif breakInfo.nCurrentDay == 2 then
            --不能玩不洗牌场
            local RoomListModel = import("src.app.GameHall.room.model.RoomListModel"):getInstance()
            if RoomListModel:checkAreaEntryAvail("noshuffle") == false then
                local tipString = "不洗牌场未解锁，建议前往经典场进行对局"
                my.informPluginByName({pluginName='TipPlugin',params={tipString=tipString,removeTime=2.0}})
                return
            end
            --不洗牌房间
            local HallContext = import('src.app.plugins.mainpanel.HallContext'):getInstance()
            HallContext:dispatchEvent({name = HallContext.EVENT_MAP["hall_gotoGameByQuickStart"], value = {["findScope"] = "noshuffle"}})
        elseif breakInfo.nCurrentDay == 3 then
            --触发快速开始的逻辑
            local HallContext = import('src.app.plugins.mainpanel.HallContext'):getInstance()
            HallContext:dispatchEvent({name = HallContext.EVENT_MAP["hall_gotoGameByQuickStart"], value = {["autoDecideRoomScope"] = true}})
        elseif breakInfo.nCurrentDay == 4 then
            RedPack100Model:notifyActivityCenterSwitchExchangeLottery()
            --local ActivityCenterCtrl = import("src.app.plugins.activitycenter.ActivityCenterCtrl")
            --ActivityCenterCtrl:topTitleBtnClicked(1, false, "exchangelottery")
            --ActivityCenterCtrl:showPageItemInfoForRedPacket(1,102)
            --my.informPluginByName({pluginName='ActivityCenterCtrl',params = {moudleName='exchangelottery'}})
        end
        return 
    end
    local RoomListModel = import("src.app.GameHall.room.model.RoomListModel"):getInstance()
    local roomInfoList = RoomListModel:gradeRoomsToList(RoomListModel.gradeRoomsClassic)
    local nMasterRoomIndex = #roomInfoList
    if nMasterRoomIndex > 5 then
        nMasterRoomIndex = 5    -- 大师房在此列表中的index是5
    end
    local nMasterRoomID = roomInfoList[nMasterRoomIndex].nRoomID
    local HallContext = import('src.app.plugins.mainpanel.HallContext'):getInstance()
    HallContext:dispatchEvent({name = HallContext.EVENT_MAP["gameScene_gotoGameByRoomId"], value = {["targetRoomId"] = nMasterRoomID}})
 
end

function ActivityRedPack100Ctrl:onClickBtnBreak()
    my.playClickBtnSound()

    local GAP_SCHEDULE = 2 --间隔时间2秒
    local nowTime = os.time()
    self._lastTime = self._lastTime or 0
    if nowTime - self._lastTime > GAP_SCHEDULE then
        self._lastTime = nowTime
    else
        my.informPluginByName({pluginName = 'TipPlugin',params = {tipString = "点击太频繁，请2秒后再操作", removeTime = 3}})
        return
    end
    
    local breakInfo = RedPack100Model:GetRedPackInfo()
    if breakInfo and breakInfo.nAvailableBout >= breakInfo.nDestBout then
        -- 发请求拆红包
        RedPack100Model:gc_BreakRedPack(RedPack100Def.BREAK_COND_BOUT_REACHED)
    end

    if breakInfo.nCurrentDay <= 4 then
        if breakInfo.nCurrentData ~= -1  and breakInfo.nCurrentData >= breakInfo.nDestData then
            -- 发请求拆红包
            RedPack100Model:gc_BreakRedPack(RedPack100Def.BREAK_COND_DAY_TASK)
        end
    end

end

function ActivityRedPack100Ctrl:onClickBtnReward()
    my.playClickBtnSound()
    if self._waitingclick == true then 
        print("ActivityRedPack100Ctrl:onClickBtnReward return , press btn too quick!!!") 
        return 
    end
    self._waitingclick = true
    self._CDTimer = my.scheduleOnce(function()
        if self then
            self._CDTimer = nil
            self._waitingclick = false
        end
    end, 2)
    local breakInfo = RedPack100Model:GetRedPackInfo()
    if breakInfo.nRewardDate > 0 then   -- 已经领取过奖了，不领
        my.informPluginByName({pluginName='TipPlugin',params={tipString = self._RedPackTipConten["RP100_REWARD_ALEADY"], removeTime = 2}})
        return
    end

    if breakInfo and breakInfo.nAccumulateMoney >= RedPack100Def.REDPACK_REWARD_NUM then
        local dataIn = {nAccumulateMoney = breakInfo.nAccumulateMoney, nRewardNum=RedPack100Def.REDPACK_REWARD_NUM } -- nRewardNum可以不填写
        RedPack100Model:gc_RewardRedPack(dataIn)
    end
    my.dataLink(cc.exports.DataLinkCodeDef.RED_PACK100_REWARD_BTN_CLICKED)

end

function ActivityRedPack100Ctrl:onClickBtnLogin()
    my.playClickBtnSound()

end

function ActivityRedPack100Ctrl:onClickBtnHelp()
    my.playClickBtnSound()
    -- 弹窗说明提示
    my.informPluginByName({pluginName='RedPack100ExplainPlugin'})
end


function ActivityRedPack100Ctrl:refreshCountDown()
    local viewNode = self._viewNode
    local breakInfo = RedPack100Model:GetRedPackInfo()
    if breakInfo ~= nil then
        local nowtimestamp = MyTimeStamp:getLatestTimeStamp()
        local strNowDate = os.date("%Y%m%d", nowtimestamp)
        local nNowDate = tonumber(strNowDate)
        local nEndDate = breakInfo.nEndDate

        if self._coutndowntimer == nil then
            self._coutndowntimer = import("src.app.plugins.timecalc.RedPackTimeCountDownEx").new(viewNode.textLeftSec, nNowDate, nEndDate, 000000, 000000, nowtimestamp)
            self._coutndowntimer:startcountdown()
        else
            self._coutndowntimer:resettime(nNowDate, nEndDate, 000000, 000000, nowtimestamp)
        end
    end
end

-- 领取100元动画播放结束
function  ActivityRedPack100Ctrl:QuXianAniCallBack(rewardRsp)
    local viewNode = self._viewNode
    if viewNode then
        local panelShade = viewNode.panelAniShade
        local aniNode = viewNode.nodeQuxian
        if panelShade then
            panelShade:setVisible(false)
        end
        if aniNode then
            aniNode:setVisible(false)
        end

        viewNode.imgTixian:setVisible(false)
        viewNode.btnReward:setEnabled(false)
        viewNode.btnReward:loadTextureNormal("hallcocosstudio/images/plist/RedPack100/btn_disable.png", 1) -- 不知为何前面setEnabled false之后不置灰，这里强制替换
        viewNode.nodeTiqu:setVisible(false)
        viewNode.spriteReward:setSpriteFrame("hallcocosstudio/images/plist/RedPack100/aleady_rewarded.png")

        viewNode.txtMinus:setVisible(false)
        local strAleady = string.format(self._RedPackTipConten.REWARD_ALEADY_TIP, 0)
        viewNode.txtDiffValue:setString(strAleady)
        self.bQuxianCalled = true

        local rewardList = {}
        table.insert( rewardList,{nType = 12})
        my.informPluginByName({pluginName = "RewardTipCtrl", params = {data = rewardList,showRedPacket = true, showtip = true}})
    end
end

-- 领奖消息的回应处理
function ActivityRedPack100Ctrl:onRedPackRewardSuccess(data)
    local viewNode = self._viewNode
    ----viewNode.btnReward:setEnabled(false)
    -- 弹框领奖界面
    local rewardRsp = data.value
    if rewardRsp then
        local breakInfo = RedPack100Model:GetRedPackInfo()
        local strTodayDate = os.date("%Y%m%d", MyTimeStamp:getLatestTimeStamp())
        local nTodayDate = tonumber(strTodayDate)       -- 服务器今日时间
        breakInfo.nRewardDate = nTodayDate -- 领奖成功

        -- 播放动画
        self:playQuXianAni(viewNode, rewardRsp)
    end

end

function ActivityRedPack100Ctrl:onRedPackRewardFailed(data)
    if nil == data.value then
        return
    end

    local respReward = data.value
    if respReward and respReward.nRespCode then
        if RedPack100Def.REWARD_EXCEED == respReward.nRespCode then
            my.informPluginByName({pluginName='TipPlugin',params={tipString = self._RedPackTipConten["RP100_REWARD_EXCEED"], removeTime = 2}})
        elseif RedPack100Def.REWARD_ALEADY == respReward.nRespCode then
            my.informPluginByName({pluginName='TipPlugin',params={tipString = self._RedPackTipConten["RP100_REWARD_ALEADY"], removeTime = 2}})
        elseif RedPack100Def.REWARD_SOAP_FAILED == respReward.nRespCode then
            my.informPluginByName({pluginName='TipPlugin',params={tipString = self._RedPackTipConten["RP100_REWARD_SOAP_FAILED"], removeTime = 2}})
        elseif RedPack100Def.REWARD_MONEY_CHECK == respReward.nRespCode then
            my.informPluginByName({pluginName='TipPlugin',params={tipString = self._RedPackTipConten["RP100_REWARD_MONEY_CHECK"], removeTime = 2}})
        elseif RedPack100Def.REWARD_ERROR == respReward.nRespCode then
            my.informPluginByName({pluginName='TipPlugin',params={tipString = self._RedPackTipConten["RP100_REWARD_ERROR"], removeTime = 2}})
        end
    end
end

function ActivityRedPack100Ctrl:onRedPackUpdate()
    -- Model 层直接合并了数据，这里刷新即可
    self:updateUI()
end

function ActivityRedPack100Ctrl:onRedPackActivityBtnBreak(data)
    if data and data.value then
        if data.value ~= RedPack100Def.BREAK_COND_BOUT_REACHED and data.value ~= RedPack100Def.BREAK_COND_DAY_TASK then
            return
        end
    end

    local breakInfo = RedPack100Model:GetRedPackInfo()
    if not breakInfo then
        return
    end
    -- 播放拆红包声音
    -- audio.playSound(cc.FileUtils:getInstance():fullPathForFilename('res/hall/sounds/RedPackBreak.mp3'),false)
    -- 通知model层需要播放飘文字动画
    local prevMoney = breakInfo.nAccumulateMoney - breakInfo.nGetMoney
    RedPack100Model:setDataForProcessAni(prevMoney, true)
    -- 先关闭气泡动画
    if self._BubbleNode then
        self._BubbleNode:stopAllActions()
    end

    my.informPluginByName({pluginName='RedPack100SimplePlugin', params = {nGetMoney = breakInfo.nGetMoney}})
end

function ActivityRedPack100Ctrl:onRedPackClockZero()
    self:onExit()
end

return ActivityRedPack100Ctrl