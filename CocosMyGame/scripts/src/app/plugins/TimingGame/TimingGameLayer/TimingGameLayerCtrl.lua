local TimingGameLayerCtrl = class('TimingGameLayerCtrl', cc.load('BaseCtrl'))
local viewCreater = import('src.app.plugins.TimingGame.TimingGameLayer.TimingGameLayerView')
local TimingGameModel = import('src.app.plugins.TimingGame.TimingGameModel'):getInstance()
local TimingGameDef = require('src.app.plugins.TimingGame.TimingGameDef')

function TimingGameLayerCtrl:onCreate( ... )
    local viewNode = self:setViewIndexer(viewCreater:createViewIndexer())

    local params = {...}

    self:initialListenTo()
    self:initialBtnClick()
    self:updateUI()

    local lastReqSt = TimingGameModel:getInfoDataStamp() --定时赛主界面打开间隔15s刷新
    local curTimeSt = os.time()
    if curTimeSt - lastReqSt > 15 then
        TimingGameModel:reqTimingGameInfoData()
    end
end

function TimingGameLayerCtrl:initialListenTo()
    self:listenTo(TimingGameModel, TimingGameModel.EVENT_MAP["timinggame_getInfoDataFromSvr"], handler(self, self.updateUI))
    self:listenTo(TimingGameModel, TimingGameModel.EVENT_MAP["timinggame_getApplySucceedFromSvr"], handler(self, self.applySucceed))
end

function TimingGameLayerCtrl:initialBtnClick()
    local viewNode = self._viewNode

    self:bindSomeDestroyButtons(viewNode,{
        'btnClose',
    })
  
    self:bindButtonToPlugin(viewNode.btnRule, 'TimingGameRule')
    self:bindButtonToPlugin(viewNode.btnRewardDesc, 'TimingGameRewardDesc')
    self:bindButtonToPlugin(viewNode.btnRankList, 'TimingGameRank')

    local bindList={
		'btnConfirm',
	}
	
    self:bindUserEventHandler(viewNode,bindList)
end

function TimingGameLayerCtrl:isInClickGap()
    local GAP_SCHEDULE = 2 --间隔时间2秒
    local nowTime = os.time()
    self._lastTime = self._lastTime or 0
    if nowTime - self._lastTime > GAP_SCHEDULE then
        self._lastTime = nowTime
    else
        my.informPluginByName({pluginName = 'TipPlugin',params = {tipString = "点击太频繁，请2秒后再操作", removeTime = 3}})
        return true
    end
    return false
end

function TimingGameLayerCtrl:applySucceed()
    local roomInfo = cc.exports.PUBLIC_INTERFACE.GetCurrentRoomInfo()
    local timingGameRoomID = TimingGameModel:getTimingGameRoomID()
    if my.isInGame() and roomInfo and roomInfo.nRoomID == timingGameRoomID then
        self:goBack()
    end
end

function TimingGameLayerCtrl:btnConfirmClicked()
    if self:isInClickGap() then return end

    local config = TimingGameModel:getConfig()
    local infoData = TimingGameModel:getInfoData()

    if not config or not infoData then
        TimingGameModel:showTips("获取数据中，请稍后再试!")
        return
    end

    local btnType, status = TimingGameModel:getBtnStatus()
    if btnType == 1 then
        if status == TimingGameDef.TIMING_GAME_CAN_START_MATCH then
            if TimingGameModel:isAbortBoutTimeNotEnough() then
                self:goBack()
                TimingGameModel:showTips("因结算需要，最后5分钟停止比赛!")
            else
                self:goBack()
                TimingGameModel:gotoTimingGameRoom()
            end
        end
    elseif btnType == 2 then
        if status == TimingGameDef.TIMING_GAME_TICKET_NOT_ENOUGH then
            TimingGameModel:showTips("门票不足!")
            if cc.exports.getTimmingGameTicketEntranceSwitch() == 0 then
                if TimingGameModel:isTicketTaskEntryShow() then
                    my.scheduleOnce(function() my.informPluginByName({pluginName = "TimingGameTicketTask"}) end, 0)
                end
            else
                my.scheduleOnce(function() my.informPluginByName({pluginName = "TimingGameGetTicket"}) end, 0)
            end
        else
            local curTime = TimingGameModel:getCurrentTime()
            local curTimeTbl = os.date("*t", curTime)
            if curTimeTbl.hour == 0 and curTimeTbl.min == 0 then
                TimingGameModel:showTips("服务器正忙，请稍后再报名!")
            else
                TimingGameModel:reqApplyMatch()
                -- TimingGameModel:showTips("报名中，请稍后!")
            end
        end
        return
    elseif btnType == 4 then
        TimingGameModel:showTips("已报名!")
    else
        TimingGameModel:showTips("报名截止!")
        self:updateUI()
    end
end

function TimingGameLayerCtrl:updateUI()
    local config = TimingGameModel:getConfig()
    local infoData = TimingGameModel:getInfoData()

    --未获取到数据
    if not config or not infoData then 
        self:setInitView()
        return 
    end

    if TimingGameModel:isEnable() and TimingGameModel:isMatchDay() 
    and not TimingGameModel:isOverTimeMatchPeriod() then
        self:setViewWhenHasSeason(config, infoData)
    elseif TimingGameModel:isEnable() and TimingGameModel:isOverTimeMatchPeriod() then
        self:setOverView(config)
    else
        self:setInitView()
        self._viewNode.btnRankList:setTouchEnabled(true)
        self._viewNode.btnRule:setTouchEnabled(true)
        self._viewNode.btnRewardDesc:setTouchEnabled(true)

        self._viewNode.btnRankList:setBright(true)
        self._viewNode.btnRule:setBright(true)
        self._viewNode.btnRewardDesc:setBright(true)
    end

    local tipStr = "超多话费等你来\n拿哦！"
    if not TimingGameModel:isMatchDay() then
        tipStr = "今日未开启！"
    end
    local txtTip = self._viewNode.imgCloseTip:getChildByName("Text_CloseTip")
    if txtTip then
        txtTip:setString(tipStr)
    end
end

function TimingGameLayerCtrl:setOverView(config)
    self._viewNode.txtRule1:setString("今日比赛已结束")
    local rule2 = string.format("满足对局%d次，或积分不足%d万", config.SeasonMaxBout, config.MinScore / 10000)
    self._viewNode.txtRule2:setString(rule2)
    self._viewNode.txtRule3:setString(string.format("第%d名", 1))
    self._viewNode.txtRule4:setString("暂无数据")
    self._viewNode.txtRule5:setString("暂无数据")

    self._viewNode.btnConfirm:setTouchEnabled(false)
    self._viewNode.btnRankList:setTouchEnabled(true)
    self._viewNode.btnRule:setTouchEnabled(true)
    self._viewNode.btnRewardDesc:setTouchEnabled(true)
    
    self._viewNode.btnConfirm:setBright(false)
    self._viewNode.btnRankList:setBright(true)
    self._viewNode.btnRule:setBright(true)
    self._viewNode.btnRewardDesc:setBright(true)
    
    self._viewNode.txtDesc1:setString("每5分钟刷新一次")
    self._viewNode.txtDesc2:setString("暂无数据")

    local rewards = {}
    rewards = TimingGameModel:getRankReward(1)
    --设置奖励界面
    if #rewards == 0 then
        self._viewNode.panelReward1:setVisible(false)
        self._viewNode.panelReward2:setVisible(false)
    elseif #rewards == 1 then
        self._viewNode.panelReward1:setVisible(true)
        self._viewNode.panelReward2:setVisible(false)
        self:setReward(self._viewNode.imgIcon1, self._viewNode.txtReward1, rewards[1])
    elseif #rewards >= 2 then
        self._viewNode.panelReward1:setVisible(true)
        self._viewNode.panelReward2:setVisible(true)
        self:setReward(self._viewNode.imgIcon1, self._viewNode.txtReward1, rewards[1])
        self:setReward(self._viewNode.imgIcon2, self._viewNode.txtReward2, rewards[2])
    end
end


function TimingGameLayerCtrl:setInitView()
    self._viewNode.txtRule1:setString("--:-- - --:-- (暂未开启)")
    self._viewNode.txtRule2:setString("暂未开启")
    self._viewNode.txtRule3:setString("暂无数据")
    self._viewNode.txtRule4:setString("暂无数据")
    self._viewNode.txtRule5:setString("暂无数据")
    self._viewNode.panelReward1:setVisible(false)
    self._viewNode.panelReward2:setVisible(false)

    self._viewNode.btnRankList:setBright(false)
    self._viewNode.btnConfirm:setBright(false)
    self._viewNode.btnRule:setBright(false)
    self._viewNode.btnRewardDesc:setBright(false)
    
    self._viewNode.txtDesc1:setString("每5分钟刷新一次")
    self._viewNode.txtDesc2:setString("暂无数据")
end

function TimingGameLayerCtrl:setViewWhenHasSeason(config, infoData)
    --设置rule text
    local stStartTime, stEndTime = TimingGameModel:getCurrentSeasonTime()
    local startTime = os.date("*t", stStartTime)
    local endTime = os.date("*t", stEndTime)
    local abortApplyTime = os.date("*t", stEndTime - config.SeasonAbortApplyMinutes * 60)
    local abortBoutTime = os.date("*t", stEndTime - config.SeasonAbortBoutMinutes * 60)
    local seasonTime = string.format("%02d:%02d-%02d:%02d (%02d:%02d报名截止|%02d:%02d对局截止)",
        startTime.hour,startTime.min,
        endTime.hour,endTime.min,
        abortApplyTime.hour,abortApplyTime.min,
        abortBoutTime.hour,abortBoutTime.min
    )
    self._viewNode.txtRule1:setString(seasonTime)

    local rule2 = string.format("满足对局%d次，或积分不足%d万", config.SeasonMaxBout, config.MinScore / 10000)
    self._viewNode.txtRule2:setString(rule2)

    local applyStartTime = TimingGameModel:getTimeTable(infoData.applyStartTime)
    local applyEndTime = TimingGameModel:getTimeTable(infoData.applyEndTime)
    local stApplyStartTime = os.time(applyStartTime)
    local stApplyEndTime = os.time(applyEndTime)
    local stStartTime, stEndTime = TimingGameModel:getCurrentSeasonTime()
    local date = tonumber(os.date("%Y%m%d", TimingGameModel:getCurrentTime()))
     
    local rule3, rule4, rule5
    local rewards = {}
    rewards = TimingGameModel:getRankReward(1)
    if #rewards ~= 0 then
        rule3 = string.format("第%d名", 1)
    elseif #rewards == 0 and infoData.applyedTime > 0 then
        rule3 = "未上榜"
    else
        rule3 = "未参赛"
    end
    if date ~= infoData.applyDate or stApplyStartTime ~= stStartTime or
    stApplyEndTime ~= stEndTime then
        rule4 = "未参赛"
        rule5 = "未参赛"
    else
        if infoData.rankingscore == 0 and infoData.ranking == 0 then
            rule4 = "----"
            rule5 = "----"
        else
            rule4 = tostring(infoData.rankingscore)
            rule5 = tostring(infoData.ranking)
        end
    end
    self._viewNode.txtRule3:setString(rule3)
    self._viewNode.txtRule4:setString(rule4)
    self._viewNode.txtRule5:setString(rule5)
    
    --设置奖励界面
    if #rewards == 0 then
        self._viewNode.panelReward1:setVisible(false)
        self._viewNode.panelReward2:setVisible(false)
    elseif #rewards == 1 then
        self._viewNode.panelReward1:setVisible(true)
        self._viewNode.panelReward2:setVisible(false)
        self:setReward(self._viewNode.imgIcon1, self._viewNode.txtReward1, rewards[1])
    elseif #rewards >= 2 then
        self._viewNode.panelReward1:setVisible(true)
        self._viewNode.panelReward2:setVisible(true)
        self:setReward(self._viewNode.imgIcon1, self._viewNode.txtReward1, rewards[1])
        self:setReward(self._viewNode.imgIcon2, self._viewNode.txtReward2, rewards[2])
    end

    local btnType, status = TimingGameModel:getBtnStatus()
    --设置desc text
    local desc1 = string.format("每%d分钟刷新一次", math.floor(config.HallRefreshTime / 60))
    self._viewNode.txtDesc1:setString(desc1)
    if btnType == 1 or btnType == 4 then
        local desc2 = string.format("积分: %d  局数:%d/%d", 
        infoData.seasonScore, infoData.seasonBoutNum, config.SeasonMaxBout)
        self._viewNode.txtDesc2:setString(desc2)
    elseif btnType == 2 then
        local infoApplyTime = infoData.applyedTime

        if date ~= infoData.applyDate or stApplyStartTime ~= stStartTime or
        stApplyEndTime ~= stEndTime then
            infoApplyTime = 0
        end
        local applyedTime = infoApplyTime + 1
        applyedTime = applyedTime <= 0 and 1 or applyedTime

        local applyTicketNums = config.ApplyTicketsNum[1]
        if applyedTime <= #config.ApplyTicketsNum then
            applyTicketNums = config.ApplyTicketsNum[applyedTime]
        else
            applyTicketNums = config.ApplyTicketsNum[#config.ApplyTicketsNum]
        end

        local desc2 = string.format("报名需要%d张门票", applyTicketNums)
        self._viewNode.txtDesc2:setString(desc2)
    else
        self._viewNode.txtDesc2:setVisible(false)
    end
    
    self._viewNode.btnRankList:setTouchEnabled(true)
    self._viewNode.btnConfirm:setTouchEnabled(true)
    self._viewNode.btnRule:setTouchEnabled(true)
    self._viewNode.btnRewardDesc:setTouchEnabled(true)

    self._viewNode.btnRankList:setBright(true)
    self._viewNode.btnConfirm:setBright(true)
    self._viewNode.btnRule:setBright(true)
    self._viewNode.btnRewardDesc:setBright(true)

    --设置按钮状态
    if btnType == 1 then
        local path = "hallcocosstudio/images/plist/TimingGame/btn_kabs.png"
        self._viewNode.btnConfirm:loadTextureNormal(path, ccui.TextureResType.plistType)
        self._viewNode.btnConfirm:loadTexturePressed(path, ccui.TextureResType.plistType)
    elseif btnType == 2 then
        local path = "hallcocosstudio/images/plist/TimingGame/btn_baoming.png"
        self._viewNode.btnConfirm:loadTextureNormal(path, ccui.TextureResType.plistType)
        self._viewNode.btnConfirm:loadTexturePressed(path, ccui.TextureResType.plistType)
    elseif btnType == 4 then
        local path = "hallcocosstudio/images/plist/TimingGame/btn_ybm.png"
        self._viewNode.btnConfirm:loadTextureNormal(path, ccui.TextureResType.plistType)
        self._viewNode.btnConfirm:loadTexturePressed(path, ccui.TextureResType.plistType)
        self._viewNode.btnConfirm:setTouchEnabled(false)
        self._viewNode.btnConfirm:setBright(false)
    else
        local path = "hallcocosstudio/images/plist/TimingGame/btn_bmjs.png"
        self._viewNode.btnConfirm:loadTextureNormal(path, ccui.TextureResType.plistType)
        self._viewNode.btnConfirm:loadTexturePressed(path, ccui.TextureResType.plistType)
        self._viewNode.btnConfirm:setTouchEnabled(false)
        self._viewNode.btnConfirm:setBright(false)
    end
end


function TimingGameLayerCtrl:setReward(img, txt, reward)
    local path, count = TimingGameModel:getRewardPathCount(reward)
    img:loadTexture(path, ccui.TextureResType.plistType)
    img:ignoreContentAdaptWithSize(true)
    local str = string.format("x%d", count)
    txt:setString(str)
end

function TimingGameLayerCtrl:goBack()
    TimingGameLayerCtrl.super.removeSelf(self)
end

return TimingGameLayerCtrl