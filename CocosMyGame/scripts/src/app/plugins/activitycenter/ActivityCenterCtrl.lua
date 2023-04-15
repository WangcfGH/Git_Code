local viewCreater       	= import('src.app.plugins.activitycenter.ActivityCenterView')
local ActivityCenterCtrl    = class('ActivityCenterCtrl',cc.load('BaseCtrl'))

local PlayerInfo         	= mymodel('hallext.PlayerModel'):getInstance()
local ActivityCenterModel   = import('src.app.plugins.activitycenter.ActivityCenterModel'):getInstance()
local ActivityCenterConfig  = require('src.app.plugins.activitycenter.ActivityCenterConfig')
local ActivityCenterStatus  = import('src.app.plugins.activitycenter.ActivityCenterStatus'):getInstance()
local RichText              = require("src.app.mycommon.myrichtext.MyRichText")
local DownloadModel         = mymodel('DownloadModel'):getInstance()
--local roomManager =  require("src.app.plugins.roomspanel.RoomListModel"):getInstance()
local ExchangeLotteryModel = require('src.app.plugins.ExchangeLottery.ExchangeLotteryModel'):getInstance()
local PhoneFeeGiftModel = require('src.app.plugins.PhoneFeeGift.PhoneFeeGiftModel'):getInstance()
local PluginProcessModel = mymodel('hallext.PluginProcessModel'):getInstance()
local RedPack100Model = require("src.app.plugins.RedPack100.RedPack100Model"):getInstance()

local player                =mymodel('hallext.PlayerModel'):getInstance()
local ExchangeLotteryDef    = import('src.app.plugins.ExchangeLottery.ExchangeLotteryDef')
local PhoneFeeGiftDef       = import('src.app.plugins.PhoneFeeGift.PhoneFeeGiftDef')
local RedPack100Def         = import('src.app.plugins.RedPack100.RedPack100Def')
local MyTimeStamp = import('src.app.mycommon.mytimestamp.MyTimeStamp'):getInstance()

local WinningStreakDef        = import('src.app.plugins.WinningStreak.WinningStreakDef')
local WinningStreakModel      = import("src.app.plugins.WinningStreak.WinningStreakModel"):getInstance()

local DailyRechargeModel = import('src.app.plugins.DailyRecharge.DailyRechargeModel'):getInstance()
local DailyRechargeDef   = require('src.app.plugins.DailyRecharge.DailyRechargeDef')

ActivityCenterCtrl._config 	 	= nil
ActivityCenterCtrl._userID	    = 0

ActivityCenterCtrl.AC_LOTTERY = "AC_LOTTERY"
ActivityCenterCtrl.AC_TREASURE_BOX = "AC_TREASURE_BOX"

ActivityCenterCtrl.AC_PHONE_FEE_GIFT = "AC_PHONE_FEE_GIFT"
ActivityCenterCtrl.AC_EXCHANGE_LOTTERY= "AC_EXCHANGE_LOTTERY"
ActivityCenterCtrl.AC_REDPACK100= "AC_REDPACK100"
ActivityCenterCtrl.AC_WINNINGSTREAK= "AC_WINNINGSTREAK"
ActivityCenterCtrl.AC_DAILYRECHARGE= "AC_DAILYRECHARGE"


ActivityCenterCtrl.TYPE_TASK = 1
ActivityCenterCtrl.TYPE_EXCHANGE = 2
ActivityCenterCtrl.TASK_NOTTAKEREWARD = 0
ActivityCenterCtrl.TASK_ALREADYTAKEREWARD = 1

ActivityCenterCtrl.RUN_ENTERACTION = true       -- 弹出时播放动画

ActivityCenterCtrl.ActivityPanelWidth = 880
ActivityCenterCtrl.ActivityPanelHeight = 560
ActivityCenterCtrl.PageDetailPos = cc.p(6, 5)
ActivityCenterCtrl.ActvityCenterPos=cc.p(451,286)

local giftvoucheractivityctrl = nil
local TimingGameTicketActivityctrl = nil

ActivityCenterCtrl.ctrlConfig = {
    ["pluginName"] = "ActivityCenterCtrl",
    ["isAutoRemoveSelfOnNoParent"] = true
}

function ActivityCenterCtrl:isNewMsgInOperatingActivity(category)
    --指定类型
    local isNewMsg = false
    if category then         
        if category == ActivityCenterCtrl.AC_PHONE_FEE_GIFT then
            if PhoneFeeGiftModel:NeedShowRedDot() then
                isNewMsg = true
            end
        elseif category == ActivityCenterCtrl.AC_EXCHANGE_LOTTERY then
            if ExchangeLotteryModel:NeedShowRedDot() then 
                isNewMsg = true   
            end
        elseif category == ActivityCenterCtrl.AC_REDPACK100 then
            if RedPack100Model:NeedShowRedDot() then 
                isNewMsg = true   
            end
        elseif category == ActivityCenterCtrl.AC_WINNINGSTREAK then
            if WinningStreakModel:NeedShowRedDot() then 
                isNewMsg = true   
            end
        elseif category == ActivityCenterCtrl.AC_DAILYRECHARGE then
            if DailyRechargeModel:NeedShowRedDot() then 
                isNewMsg = true   
            end
        end
    end
    return isNewMsg
end

function ActivityCenterCtrl:onCreate(params)
    printf("ActivityCenterCtrl onCreate(...)")

    self._webViewList = {}
    self._hasShowPanel = {}

    self._pageData = {}
    self._pagePanel = {}
    self._buttonPanel = {}
    self._infoPanel = {}
    self._titlePanel = {}
    self._redDotPanel = {}
    self._leftSwitchImg = {}

    self._params = params
    ActivityCenterModel:savePluginParams(clone(params or {}))
    
    self._viewNode=self:setViewIndexer(viewCreater:createViewIndexer())

    self:bindUserEventHandler(self._viewNode, {'closeBtn'})

    --显示等待
    self._viewNode.imgWait:setVisible(true)
    local rotateAction = cc.RotateBy:create(2 , 360)
    local repeatAction = cc.Repeat:create(rotateAction, 999)
    self._viewNode.imgWait:runAction(repeatAction)

    --if ActivityCenterModel._activityTaskConfig then
        --ActivityCenterModel:getActivityTaskConfig()
    --else
    self:initActivityAndNoticePanel()
    --end

    self:listenTo(ActivityCenterModel, ActivityCenterModel.ACTIVITY_CLOSE, handler(self, self.onClose))
    self:listenTo(ActivityCenterModel, ActivityCenterModel.ACTIVITY_SHOW, handler(self, self.freshActivityAndNoticePanel))
    self:listenTo(ActivityCenterModel, ActivityCenterModel.CLOSE_SEND_AGAIN, handler(self, self.onCloseSendAgainTimer))

    self:listenTo(ExchangeLotteryModel,"ExchangeLotteryUpdateRedDot",handler(self,self.updateExchangeLotteryRedDot))
    self:listenTo(PhoneFeeGiftModel,"PhoneFeeGiftUpdateRedDot",handler(self,self.updatePhoneFeeGiftRedDot))
    --self:listenTo(ActivityCenterModel, ActivityCenterModel.ACTIVITY_TITLE_BTN_DISABLE, handler(self, self.onTitleBtnEnableAndDisable))
    --self:listenTo(ActivityCenterModel, ActivityCenterModel.ACTIVITY_TITLE_BTN_ENABLE, handler(self, self.onTitleBtnEnableAndEnable))

    --self:listenTo(ActivityCenterModel, ActivityCenterModel.ACTIVITY_TASK_UPDATE, handler(self, self.updateActivityTask))
    --self:listenTo(ActivityCenterModel, ActivityCenterModel.ACTIVITY_TASK_REWARD, handler(self, self.updateActivityTask))
    
    --self:listenTo(LotteryModel, LotteryModel.LOTTERY_ACTIVITY_STATE_UPDATED, handler(self, self.updateLotteryInfo))
    --self:listenTo(TreasureBoxModel, TreasureBoxModel.TREASURE_BOX_ACTIVITY_STATE_UPDATED, handler(self, self.updateTreasureBoxInfo))
    self:listenTo(player,player.PLAYER_LOGIN_OFF,handler(self,self.onPlayLoginOff))
    self:listenTo(PluginProcessModel, PluginProcessModel.NOTIFY_CLOSE_ALL_PLUGIN,handler(self,self.onClose))
    cc.exports.scaleFrameSizeByHeight(self._viewNode:getChildByName("Panel_Main"):getChildByName("Panel_Animation"))

    --惊喜夺宝
    self:listenTo(ExchangeLotteryModel, ExchangeLotteryDef.ExchangeLotteryInfoRet, handler(self,self.jxdb_updateUI))
    self:listenTo(ExchangeLotteryModel, ExchangeLotteryDef.ExchangeLotteryDrawRet, handler(self,self.jxdb_onGetDrawResult))
    self:listenTo(ExchangeLotteryModel,ExchangeLotteryDef.ExchangeLotterySynSeizeCount,handler(self,self.jxdb_freshSeizeCount))
    self:listenTo(ExchangeLotteryModel,ExchangeLotteryDef.ExchangeLotteryConfigChange,handler(self,self.jxdb_updateUI))
    self:listenTo(ExchangeLotteryModel,ExchangeLotteryDef.ExchangeLotteryDrawFailed,handler(self,self.jxdb_onDrawFailed))

    --话费有礼
    self:listenTo(PhoneFeeGiftModel,PhoneFeeGiftDef.MSG_PHONE_FEE_GIFT_UPDATE,handler(self,self.hfl_onPhoneFeeGiftUpdate))
    self:listenTo(PhoneFeeGiftModel,PhoneFeeGiftDef.MSG_PHONE_FEE_GIFT_REWARD_GETED,handler(self,self.hfl_onPhoneFeeGiftRewardGet))
    self:listenTo(PhoneFeeGiftModel,PhoneFeeGiftDef.MSG_PHONE_FEE_GIFT_REWARD_FAILED,handler(self,self.hfl_onPhoneFeeGiftRewardFailed))
    self:listenTo(PhoneFeeGiftModel,PhoneFeeGiftDef.MSG_PHONE_FEE_GIFT_CLOCK_ZERO,handler(self,self.hfl_onPhoneFeeGiftClockZero))
    self:listenTo(PhoneFeeGiftModel,PhoneFeeGiftDef.MSG_PHONE_FEE_GIFT_NEW_DAY,handler(self,self.hfl_onPhoneFeeGiftNewDay))
    
    -- 百元红包
    self:listenTo(RedPack100Model,RedPack100Def.MSG_REDPACK_DATA_UPDATE,handler(self,self.rp100_onRedPackUpdate))
    self:listenTo(RedPack100Model,RedPack100Def.MSG_REDPACK_REWARD_SUCCESS,handler(self,self.rp100_onRedPackRewardSuccess))
    self:listenTo(RedPack100Model,RedPack100Def.MSG_REDPACK_REWARD_FAILED,handler(self,self.rp100_onRedPackRewardFailed))
    self:listenTo(RedPack100Model,RedPack100Def.MSG_REDPACK_BREAK_RESP, handler(self, self.rp100_onRedPackBreak))
    self:listenTo(RedPack100Model,RedPack100Def.MSG_REDPACK_SIMPLE_TIXIAN, handler(self, self.rp100_onRedPackUpdate))
    self:listenTo(RedPack100Model,RedPack100Def.MSG_REDPACK_CLOCK_ZERO,handler(self,self.rp100_onRedPackClockZero))
    self:listenTo(RedPack100Model,RedPack100Def.MSG_REDPACK_UPDATE_REDDOT,handler(self,self.updateRedPackRedDot))
    self:listenTo(RedPack100Model,RedPack100Def.MSG_REDPACK_NOTIFY_SWITCH_TAB,handler(self,self.rp100_onSwitchTab))
    self:listenTo(RedPack100Model,RedPack100Def.MSG_REDPACK_NOTIFY_SWITCH_EXCHANGELOTTERY_TAB,handler(self,self.rp100_onSwitchExchangeLotteryTab))


    --连胜挑战
    self:listenTo(WinningStreakModel, WinningStreakDef.WinningStreakInfoRet, handler(self,self.lstz_updateUI))
    self:listenTo(WinningStreakModel, WinningStreakDef.WinningStreakAwardRet, handler(self,self.lstz_onGetAwardRet))
    self:listenTo(WinningStreakModel, WinningStreakDef.WinningStreakUpdateRedDot,handler(self,self.updateRedDot))
--    self:listenTo(WinningStreakModel,ExchangeLotteryDef.ExchangeLotterySynSeizeCount,handler(self,self.jxdb_freshSeizeCount))
--    self:listenTo(WinningStreakModel,ExchangeLotteryDef.ExchangeLotteryConfigChange,handler(self,self.jxdb_updateUI))
--    self:listenTo(WinningStreakModel,ExchangeLotteryDef.ExchangeLotteryDrawFailed,handler(self,self.jxdb_onDrawFailed))

    self:listenTo(DailyRechargeModel, DailyRechargeDef.DAILY_RECHARGE_UPDATE_REDDOT,handler(self,self.updateRedDot))
    -- 时间戳
    self:listenTo(MyTimeStamp,MyTimeStamp.UPDATE_STAMP, handler(self,self.hfl_onCtrlResume))

end

--连胜挑战begin
function ActivityCenterCtrl:lstz_updateUI()
    if self.WinningStreakCtrl then
        self.WinningStreakCtrl:updateUI()
    end
end

function ActivityCenterCtrl:lstz_onGetAwardRet(data)
    if self.WinningStreakCtrl then
        self.WinningStreakCtrl:onGetAwardRet()
    end
end
--连胜挑战end

function ActivityCenterCtrl:jxdb_updateUI()
    if self.ExchangeLotteryCtrl then
        self.ExchangeLotteryCtrl:updateUI()
    end
end

function ActivityCenterCtrl:jxdb_onGetDrawResult(data)
    if self.ExchangeLotteryCtrl then
        self.ExchangeLotteryCtrl:onGetDrawResult(data)
    end
end
function ActivityCenterCtrl:jxdb_freshSeizeCount()
    if self.ExchangeLotteryCtrl then
        self.ExchangeLotteryCtrl:freshSeizeCount()
    end
end
function ActivityCenterCtrl:jxdb_onDrawFailed()
    if self.ExchangeLotteryCtrl then
        self.ExchangeLotteryCtrl:onDrawFailed()
    end
end

function ActivityCenterCtrl:hfl_onPhoneFeeGiftUpdate( )
    if self.PhoneFeeGiftCtrl then
        self.PhoneFeeGiftCtrl:onPhoneFeeGiftUpdate()
    end
end
function ActivityCenterCtrl:hfl_onPhoneFeeGiftRewardGet(data)
    if self.PhoneFeeGiftCtrl then
        self.PhoneFeeGiftCtrl:onPhoneFeeGiftRewardGet(data)
    end
end
function ActivityCenterCtrl:hfl_onPhoneFeeGiftRewardFailed(data)
    if self.PhoneFeeGiftCtrl then
        self.PhoneFeeGiftCtrl:onPhoneFeeGiftRewardFailed(data)
    end
end
function ActivityCenterCtrl:hfl_onPhoneFeeGiftClockZero( )
    if self.PhoneFeeGiftCtrl then
        self.PhoneFeeGiftCtrl:onPhoneFeeGiftClockZero()
    end
end
function ActivityCenterCtrl:hfl_onCtrlResume( )
    if self.PhoneFeeGiftCtrl then
        self.PhoneFeeGiftCtrl:onCtrlResume()
    end

    if self.RedPack100Ctrl then
        self.RedPack100Ctrl:onCtrlResume()
    end
end
function ActivityCenterCtrl:hfl_onPhoneFeeGiftNewDay( )
    if self.PhoneFeeGiftCtrl then
        self.PhoneFeeGiftCtrl:onPhoneFeeGiftNewDay()
    end
end

function ActivityCenterCtrl:rp100_onRedPackUpdate( )
    if self.RedPack100Ctrl then
        self.RedPack100Ctrl:onRedPackUpdate()
    end
end

function ActivityCenterCtrl:rp100_onRedPackRewardSuccess(data )
    if self.RedPack100Ctrl then
        self.RedPack100Ctrl:onRedPackRewardSuccess(data)
    end
end

function ActivityCenterCtrl:rp100_onRedPackRewardFailed(data )
    if self.RedPack100Ctrl then
        self.RedPack100Ctrl:onRedPackRewardFailed(data)
    end
end

function ActivityCenterCtrl:rp100_onRedPackBreak(data)
    if self.RedPack100Ctrl then
        self.RedPack100Ctrl:onRedPackActivityBtnBreak(data)
    end
end

function ActivityCenterCtrl:rp100_onRedPackClockZero()
    if self.RedPack100Ctrl then
        self.RedPack100Ctrl:onRedPackClockZero()
    end
end

-- 断线重连后会出现互动界面和 红包界面同时打开情况，这个时候跳转活动界面直接切换
function ActivityCenterCtrl:rp100_onSwitchTab(params)
    self:topTitleBtnClicked(ActivityCenterModel.UNKNOWN_TYPE, false, "redpack100")
end

--百元红包做任务通知切到惊喜夺宝界面
function ActivityCenterCtrl:rp100_onSwitchExchangeLotteryTab(params)
    self:topTitleBtnClicked(ActivityCenterModel.UNKNOWN_TYPE, false, "exchangelottery")
end


function ActivityCenterCtrl:onPlayLoginOff()
    self:onClose()
end

function ActivityCenterCtrl:onEnter( ... )
    ActivityCenterCtrl.super.onEnter(self)
    if self.PhoneFeeGiftCtrl then
        self.PhoneFeeGiftCtrl:onEnter(...)
    end
    if self.ExchangeLotteryCtrl then
        self.ExchangeLotteryCtrl:onEnter(...)
    end

    if self.RedPack100Ctrl then
        self.RedPack100Ctrl:onEnter(...)
    end

    if self.WinningStreakCtrl then
        self.WinningStreakCtrl:onEnter(...)
    else
        WinningStreakModel:gc_GetWinningStreakInfo()   --不然局数超过限定条件不会显示连胜界面
    end
	-- 每次手动点击会进这个函数
end

function ActivityCenterCtrl:updateLotteryInfo()
    self:setLotteryData()
    self:updateRedDot()
end

function ActivityCenterCtrl:updateTreasureBoxInfo()
    self:setTreasureBoxData()
    self:updateRedDot()
end

function ActivityCenterCtrl:closeBtnClicked()
    my.dataLink(cc.exports.DataLinkCodeDef.HALL_ACTIVITY_CENTER_CLOSE)

    if type(self._params) == 'table' and self._params.moudleName == 'dailyrecharge' and self._params.enterRoomFailedInfo then
        local roomId = self._params.enterRoomFailedInfo.roomId
        local lackDeposit = self._params.enterRoomFailedInfo.lackDeposit
        local mainCtrl = self._params.enterRoomFailedInfo.mainCtrl
        if mainCtrl then 
            my.scheduleOnce(function () 
                mainCtrl:tryShowRoomQuickRechargeView(roomId, lackDeposit)
            end)
        end
    else
        PluginProcessModel:PopNextPlugin()    
    end
    if self.ExchangeLotteryCtrl and not self.ExchangeLotteryCtrl:onClickClose() then
        return
    end
    self:onClose()
end

function ActivityCenterCtrl:onGetActivityMatrixInfo()
    self:initActivityAndNoticePanel()
    self:topTitleBtnClicked(ActivityCenterModel.ACTIVITY_TYPE)
end

function ActivityCenterCtrl:onCloseSendAgainTimer()
    if self._sendAgainTimeID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._sendAgainTimeID)
        self._sendAgainTimeID = nil
    end
end

--初始化活动面板
function ActivityCenterCtrl:initActivityAndNoticePanel()
    if self._viewNode.imgWait then
        self._viewNode.imgWait:setVisible(false)
    end

    self._pageData = {}
    self._pagePanel = {}
    self._buttonPanel = {}
    self._infoPanel = {}
    self._titlePanel = {}
    self._redDotPanel = {}
    self._hasShowPanel = {}
    self._leftSwitchImg = {} -- 左上角的图片切换
    self._currentPageIndex = {}

    --收到活动配置后，进行循环
    for k, v in ipairs(ActivityCenterModel.PAGE_TYPE) do
        self:initPagePanel(v)
        self._hasShowPanel[v] = false
        self._pageData[v] = {
            ["activityId"] = {},
            ["buttonList"] = {}, 
            ["infoList"] = {},
            ["linkIndex"] = {},
        }
        self:generatePageInfo(v)

        table.insert(self._currentPageIndex, 1)
    end

    local activityCount = #self._pageData[ActivityCenterModel.ACTIVITY_TYPE].activityId
    local noticeCount = #self._pageData[ActivityCenterModel.NOTICE_TYPE].activityId
    if activityCount + noticeCount <= 0 then
        -- 如果打开活动界面，活动列表和公告列表都是0 那么隔3s后重新请求一次。总共一次
        if nil == self._sendAgainTimeID then
            self._sendAgainTimeID = my.scheduleOnce(function()
                if nil == self._sendAgain then
                    ActivityCenterModel:getActivityMaxtrixInfo()
                    self._sendAgain = true
                end
            end, 3)
        end
    end

    --选择显示哪个界面
    if self._params and self._params.auto then
        local priorityType = ActivityCenterModel:getPriority(ActivityCenterModel.UNKNOWN_TYPE, self._params.scene)
        self:topTitleBtnClicked(priorityType, self._params.auto)
    elseif self._params and self._params.moudleName then
        self:topTitleBtnClicked(ActivityCenterModel.UNKNOWN_TYPE, false, self._params.moudleName)
    else
        self:topTitleBtnClicked(ActivityCenterModel.ACTIVITY_TYPE, true)
    end

    self:updateRedDot()
end

function ActivityCenterCtrl:initPagePanel(pageType)
    local viewNode = self._viewNode
    if pageType == ActivityCenterModel.ACTIVITY_TYPE then
        self._pagePanel[pageType] = viewNode.activityPanel
        self._buttonPanel[pageType] = viewNode.activityButtonsPanel
        self._infoPanel[pageType] = viewNode.activitiesPanel
        self._titlePanel[pageType] = viewNode.jchdBtn
        self._redDotPanel[pageType] = viewNode.jchdRedDot
        self._leftSwitchImg[pageType]  = viewNode.imageJchd
    elseif pageType == ActivityCenterModel.NOTICE_TYPE then
        self._pagePanel[pageType] = viewNode.noticePanel
        self._buttonPanel[pageType] = viewNode.noticeButtonsPanel
        self._infoPanel[pageType] = viewNode.noticesPanel
        self._titlePanel[pageType] = viewNode.yxggBtn
        self._redDotPanel[pageType] = viewNode.yxggRedDot
        self._leftSwitchImg[pageType]  = viewNode.imageYxgg
    end
    self._leftSwitchImg[pageType]:setVisible(false) -- 使用动画的title，这里就把静态图隐藏起来
    self._titlePanel[pageType]:addClickEventListener(function()  my.playClickBtnSound() self:topTitleBtnClicked(pageType) end)
    self._titlePanel[pageType]:onTouch( function(e) end)    --重写按钮的onTouch并不做任何事，屏蔽按钮的缩放效果
end

function ActivityCenterCtrl:generatePageInfo(pageType)
    local pageInfo = ActivityCenterModel:getMatrixPageInfo(pageType)
    if pageInfo == nil or self._hasShowPanel[pageType] then
        return
    end

    self._hasShowPanel[pageType] = true
    if pageType == ActivityCenterModel.ACTIVITY_TYPE then   -- ActivityMatrix里的活动ID都删除的情况下可以执行
        self._viewNode.Img_NoActivitys:setVisible(next(pageInfo) == nil)
    end
    
    if pageType == ActivityCenterModel.NOTICE_TYPE then -- ActivityMatrix里的公告ID都删除的情况下可以执行
        self._viewNode.Img_NoNotice:setVisible(next(pageInfo) == nil)
    end

    for k, v in ipairs(pageInfo) do
        if v.showByActivityReturn == true and v.needShow == true then  -- 活动本身有限制条件是否显示，会作用给needshow
            self:generatePageItemInfo(pageType, v)
        end
    end

    local availableCount = #self._pageData[pageType]["buttonList"]
    if pageType == ActivityCenterModel.ACTIVITY_TYPE then   -- 使用button个数在判断一下
        self._viewNode.Img_NoActivitys:setVisible(availableCount==0)
    end
    
    if pageType == ActivityCenterModel.NOTICE_TYPE then
        self._viewNode.Img_NoNotice:setVisible(availableCount==0)
    end

    self:stretchPageButton(pageType)
end

function ActivityCenterCtrl:generatePageItemInfo(pageType, pageItemInfo)
    local activityId = pageItemInfo.activity
  
    if activityId >= ActivityCenterModel.ACTIVITY_START and activityId <= ActivityCenterModel.ACTIVITY_END then
        if ActivityCenterConfig.ActivityList[activityId] == nil then
            return
        end
        local btn = self.ActivityBtnList[activityId](self, pageType, pageItemInfo)
        local info = self.ActivityFunList[activityId](self, pageType, pageItemInfo)
        self:generatePageLink(pageItemInfo.type, pageItemInfo, btn, info)
        self.ActivitySetDataList[activityId](self)
    elseif activityId >= ActivityCenterModel.NOTICE_START and activityId <= ActivityCenterModel.NOTICE_END then
        local btn = self:generateNoticeBtn(pageType, pageItemInfo)
        local info = self:generateNoticeImage(pageType, pageItemInfo)
        self:generatePageLink(pageItemInfo.type, pageItemInfo, btn, info)  
    elseif activityId > ActivityCenterModel.NOTICE_END and math.floor(activityId/10000) == ActivityCenterModel.TASK_ID then
        --增加标签时间判断
        local curDate = ActivityCenterModel._curDate
        if not curDate then return end
        local activityBeginDate, activityEndDate = ActivityCenterModel:getActivityValidDate(activityId)
        if curDate < activityBeginDate or curDate > activityEndDate then return end

        activityId = ActivityCenterModel.TASK_ID
        local btn = self.ActivityBtnList[activityId](self, pageType, pageItemInfo)
        local info = self.ActivityFunList[activityId](self, pageType, pageItemInfo)
        self:generatePageLink(pageItemInfo.type, pageItemInfo, btn, info)
        self.ActivitySetDataList[activityId](self)
    end
end

function ActivityCenterCtrl:stretchPageButton(pageType)
    local viewNode = self._viewNode
 
    local availableCount = #self._pageData[pageType]["buttonList"]

    if availableCount <=0 then
        return
    end

    local unitHeight = 0
    for i, n in pairs(self._pageData[pageType]["buttonList"]) do  
        unitHeight = n:getContentSize().height           
    end

    local offset = 5
    local width = self._buttonPanel[pageType]:getContentSize().width
    local height = self._buttonPanel[pageType]:getContentSize().height
    --为按键设置位置，width为300，height根据数量位子移动
    self._buttonPanel[pageType]:setInnerContainerSize(cc.size(width, 300))
    if height < availableCount * (unitHeight + offset) - offset then    
        height = availableCount * (unitHeight + offset) - offset
        self._buttonPanel[pageType]:setInnerContainerSize(cc.size(width, height))
    end



    local startHeight = 0  -- 滚动条里按钮起始高度
    for i, n in pairs(self._pageData[pageType]["buttonList"]) do  
        n:setAnchorPoint(cc.p(0.5, 1))            
        n:setPosition(cc.p(width/2-8, height-startHeight))
        startHeight = startHeight +  n:getContentSize().height + offset
        n:setVisible(true)
    end
end

--基础按钮相关
function ActivityCenterCtrl:topTitleBtnClicked(pageType, isAuto, moudleName)
    --在有惊喜夺宝且惊喜夺宝在抽奖的时候，不让点
    if self.ExchangeLotteryCtrl and not self.ExchangeLotteryCtrl:onClickClose() then
        return
    end

    if self.PhoneFeeGiftCtrl and self.PhoneFeeGiftCtrl:getRewardAniPlayingStatus() then
        return
    end
    if pageType == ActivityCenterModel.ACTIVITY_TYPE then  --恢复话费礼按钮可点击状态
        if self.PhoneFeeGiftCtrl then
            self.PhoneFeeGiftCtrl:setBtnsTouchStatus(true)
        end
        if self.ExchangeLotteryCtrl then
            self.ExchangeLotteryCtrl:setClickCD(false)
        end
    end

    if pageType == ActivityCenterModel.NOTICE_TYPE then
        if self.PhoneFeeGiftCtrl then   -- 切换标题页签，禁用话费礼按钮点击
            self.PhoneFeeGiftCtrl:setBtnsTouchStatus(false)
        end
        if self.ExchangeLotteryCtrl then
            self.ExchangeLotteryCtrl:setClickCD(true)
        end
    end
    for k, v in ipairs(ActivityCenterModel.PAGE_TYPE) do
        self:hidePageItemInfo(v)
    end

    if isAuto then -- isAuto 为true 则配置中优先级为1的优先显示
        local pageInfo = ActivityCenterModel:getMatrixPageInfo(pageType)
        if not pageInfo then
            self:showPageItemInfoDef(pageType)
        else
            local priorityIndex = ActivityCenterModel:getPriority(pageType, self._sceneType)
            local priority = #pageInfo + 100 --  最大优先级（删掉部分活动后，v.priority 可能比#pageInfo大导致遍历不全）
            if (pageInfo and type(pageInfo) == "table" and next(pageInfo)) then
                for k, v in pairs(pageInfo) do -- 登陆显示的时候，纠正优先显示的下标。
                    if v.showByActivityReturn == true and v.needShow == true then
                        if v.priority <= priority then
                            priorityIndex = k
                            priority = v.priority
                        end
                    end
                end
            end
            self:showPageItemInfo(pageType, pageInfo[priorityIndex])
        end
    elseif moudleName then
        for k, v in ipairs(ActivityCenterModel.PAGE_TYPE) do
            local activityId = ActivityCenterConfig.ActivityExplain[moudleName]
            local index = self._pageData[v]["linkIndex"][activityId]
            --如果在活动列表里有该
            if index then
                local avaliblePageInfo = {}
                local pageInfo = ActivityCenterModel:getMatrixPageInfo(v)
                if (pageInfo and type(pageInfo) == "table" and next(pageInfo)) then
                    for m, info in pairs(pageInfo) do   --  pageInfo活动列表里要剔除掉showByActivityReturn=false情况，不然会出现显示空白情况
                        if info.showByActivityReturn == true and info.needShow == true then
                            table.insert(avaliblePageInfo, info)
                        end
                    end
                end
                self:showPageItemInfo(v, avaliblePageInfo[index])
                pageType = v
                break
            else
                if v == ActivityCenterModel.ACTIVITY_TYPE and index == nil then
                    local avaliblePageInfo = {}
                    local pageInfo = ActivityCenterModel:getMatrixPageInfo(v)
                    --传入的参数不可为nil，不可为空，表类型
                    if (pageInfo and type(pageInfo) == "table" and next(pageInfo)) then
                        for m, info in pairs(pageInfo) do   --  pageInfo活动列表里要剔除掉showByActivityReturn=false情况，不然会出现显示空白情况
                            if info.showByActivityReturn == true and info.needShow == true then
                                table.insert(avaliblePageInfo, info)
                            end
                        end
                    end
                    self:showPageItemInfo(v, avaliblePageInfo[#avaliblePageInfo])
                    pageType = v
                    break
                end
            end
        end
    else
        self:showPageItemInfoDef(pageType)
    end

    for k, v in ipairs(ActivityCenterModel.PAGE_TYPE) do
        if v == pageType then
            self._pagePanel[v]:setVisible(true)
            self._titlePanel[v]:setOpacity(255)
            self._titlePanel[v]:setEnabled(false)
            --self._leftSwitchImg[v]:setVisible(true)

        else
            self._pagePanel[v]:setVisible(false)
            self._titlePanel[v]:setOpacity(0)
            self._titlePanel[v]:setEnabled(true)
            --self._leftSwitchImg[v]:setVisible(false)
        end
    end

    self._viewNode.nodeTitle:setVisible(true)
    if self._viewNode.nodeTitle then
        local switchAni = cc.CSLoader:createTimeline("res/hallcocosstudio/activitycenter/switchtitle.csb")
        if not tolua.isnull(switchAni) then
            self._viewNode.nodeTitle:stopAllActions()
            self._viewNode.nodeTitle:runAction(switchAni)
            if ActivityCenterModel.ACTIVITY_TYPE == pageType then
                switchAni:play("ani_1to2", false)
            else
                switchAni:play("ani_2to1", false)
            end
        end
    end
end

function ActivityCenterCtrl:hidePageItemInfo(pageType)
    for k, v in ipairs(self._webViewList) do
        v:reload()
        v:setVisible(false)
    end
    for k, v in ipairs(self._pageData[pageType]["infoList"]) do
        v:setVisible(false)
    end
end

function ActivityCenterCtrl:addWebView(noticeInfo, parentNode)
    local webview = ccexp.WebView:create()
    webview:setScalesPageToFit(true)

    if string.len(noticeInfo.jump) > 0 then  
        webview:setContentSize(cc.size(668.00 - 10, 375 - 10))
        webview:setPosition(334, 287.5)      
    else
        webview:setContentSize(cc.size(668.00 - 10, 475 - 10))
        webview:setPosition(334, 237.5)    
    end

  
    table.insert(self._webViewList, webview)
               
    webview:setName("WebView")
    parentNode:addChild(webview)

    return webview
end

function ActivityCenterCtrl:destoryWebview()
    for k, v in pairs(self._webViewList) do
        v:reload()
        v:removeFromParent()
    end
end

function ActivityCenterCtrl:onCleanup()
    self:destoryWebview()
    if ActivityCenterCtrl.super.onCleanup then
        ActivityCenterCtrl.super.onCleanup(self)
    end
end


function ActivityCenterCtrl:onKeyBack()
    PluginProcessModel:stopPluginProcess()
    self:onClose()
end

--活动按钮生成
function ActivityCenterCtrl:generateActivityBtn(pageType, pageItemInfo)
    local activityId = pageItemInfo.activity
    
    local activityInfo = ActivityCenterModel:getActivityInfoByKey(activityId)

    local btn = self:addActivityBtn(activityId)
    local textFnt = self:addActivityTitle(activityId, btn)
    --self:addActivityTime(activityInfo, btn, textFnt)
    local redDot = self:addActivityRedDot(btn)

    if pageItemInfo.reddotShow then
        redDot:setVisible(true)
    else
        redDot:setVisible(false)
    end

    self._buttonPanel[pageType]:addChild(btn)

    return btn     
end

function ActivityCenterCtrl:addActivityRedDot(btn)
    local btnWidth = btn:getContentSize().width   
    local btnHeight = btn:getContentSize().height 

    -- 从plist合图里创建用createWithSpriteFrameName
    -- 从本地路径里散图创建用create
    local redDot = cc.Sprite:createWithSpriteFrameName("hallcocosstudio/images/plist/Common/hongdian_pic.png")
    redDot:setName("RedDot")
    redDot:setPosition(cc.p(btnWidth * 0.90, btnHeight * 0.90))
    btn:addChild(redDot)

    return redDot
end

function ActivityCenterCtrl:addActivityBtn(activityId)
    local normal = ""
    local push = ""
    local disable = ""
    local btn = nil
    if not ActivityCenterConfig.ActivityList[activityId] then
        normal = ActivityCenterConfig.ActivityCommon["title_btn_normal"] 
        push = ActivityCenterConfig.ActivityCommon["title_btn_push"]
        disable = ActivityCenterConfig.ActivityCommon["title_btn_disable"]
    else
        normal = ActivityCenterConfig.ActivityList[activityId]["title_btn_normal"] or ActivityCenterConfig.ActivityCommon["title_btn_normal"] 
        push = ActivityCenterConfig.ActivityList[activityId]["title_btn_push"] or ActivityCenterConfig.ActivityCommon["title_btn_push"]
        disable = ActivityCenterConfig.ActivityList[activityId]["title_btn_disable"] or ActivityCenterConfig.ActivityCommon["title_btn_disable"]
    end
        
    btn = ccui.Button:create(normal, push, disable, UI_TEX_TYPE_PLIST) 

    return btn   
end
--增加活动的标题
function ActivityCenterCtrl:addActivityTitle(activityId, btn)
    local title
    if ActivityCenterConfig.ActivityList[activityId] then
        title = ActivityCenterConfig.ActivityList[activityId]["title"]
        if activityId == RedPack100Def.ID_IN_ACTIVITY_CENTER then
            local queryInfo = RedPack100Model:GetRedPackInfo()
            if queryInfo.nShowMode and queryInfo.nShowMode == RedPack100Def.REDPACK_SHOW_VOCHER_MODE then
                title = ActivityCenterConfig.ActivityList[activityId]["title2"]
            end
        end
    elseif math.floor(activityId/10000) == ActivityCenterModel.TASK_ID and ActivityCenterModel._activityTaskConfig ~= nil then
        local gbtitle = ActivityCenterModel:getTabTitleByTaskID(activityId)
        title = MCCharset:getInstance():gb2Utf8String(gbtitle, gbtitle:len())
    end

    if not title then return end

    local height = btn:getContentSize().height
    local width = btn:getContentSize().width

    local textTtfNode = cc.CSLoader:createNode("res/hallcocosstudio/activitycenter/activitytext.csb") --self:generateTemplate()    


    local textTTF = textTtfNode:getChildByName("Text_TTF")
    textTTF:setString(title)
    textTTF:setVisible(false)

    local fntTextNomal = textTtfNode:getChildByName("Fnt_Nomal")
    fntTextNomal:setString(title)
    fntTextNomal:setVisible(false)

    local fntTextPressed = textTtfNode:getChildByName("Fnt_Pressed")
    fntTextPressed:setString(title)
    fntTextPressed:setVisible(false)

    textTtfNode:setAnchorPoint(cc.p(0.5, 0.5))
    textTtfNode:setPosition(cc.p(width/2-5, height/2)) 
    textTtfNode:setName("title")
    
    if ActivityCenterConfig.FntContent[title] ~= nil then
        fntTextNomal:setVisible(true)
    else
        textTTF:setVisible(true)
    end

    btn:addChild(textTtfNode)
    local strLabel =  ActivityCenterConfig.ActivityList[activityId]["btn_label"] or ""
    if strLabel ~= "" then
        local label = cc.Sprite:createWithSpriteFrameName(strLabel) -- 在ActivityCenter.plist里面的标签图
        label:setName("BtnLabel")
        local btnWidth = btn:getContentSize().width   
        local btnHeight = btn:getContentSize().height 
        label:setPosition(cc.p(26, 50))
        btn:addChild(label)
    end

    return label
end

function ActivityCenterCtrl:createTreasureBoxImage(pageType, data)
    local viewNode = self._viewNode

    local activityId = data.activity
    local activityBk = cc.Sprite:createWithSpriteFrameName(ActivityCenterConfig.ActivityList[activityId]["bkimage"])
    activityBk:setAnchorPoint(cc.p(0, 0))
    activityBk:setPosition(cc.p(0, 0))  
   
    local activityBkWidth = activityBk:getContentSize().width   
    local activityBkHeight = activityBk:getContentSize().height 
    local contenSize = activityBk:getContentSize()
    activityBk:setScaleX(ActivityCenterCtrl.ActivityPanelWidth / activityBkWidth);  
    activityBk:setScaleY(ActivityCenterCtrl.ActivityPanelHeight / activityBkHeight);

    self._infoPanel[pageType]:addChild(activityBk) 
                     
    return activityBk
end

function ActivityCenterCtrl:setTreasureBoxData()
    for k, v in ipairs(ActivityCenterModel.PAGE_TYPE) do 
        local activityId = ActivityCenterConfig.ActivityExplain["phonefeegift"]

        if self._pageData[v] then
            local index = self._pageData[v]["linkIndex"][activityId]
            local info = self._pageData[v]["infoList"][index]

            if index == nil or info == nil then
                
            else
                --local redDot = info:getChildByName("AwardRuleBtn"):getChildByName("RedDot")
                --redDot:setVisible(TreasureBoxModel:isTreasureAvailable())
            end
        end
    end
end

-- 话费有礼
function ActivityCenterCtrl:generatePhoneFeeGift(pageType, data)
    local activity = self:createPhoneFeeGiftImage(pageType, data)
    return activity
end

function ActivityCenterCtrl:createPhoneFeeGiftImage(pageType, data)
    local viewNode = self._viewNode

    local activityId = data.activity
    self.PhoneFeeGiftCtrl = import("src.app.plugins.PhoneFeeGift.PhoneFeeGiftCtrl"):create() 
    local activityBk = self.PhoneFeeGiftCtrl._viewNode:getRealNode()
    activityBk:setPosition(ActivityCenterCtrl.ActvityCenterPos)
    self._infoPanel[pageType]:addChild(activityBk) 
     return activityBk  

end

function ActivityCenterCtrl:setPhoneFeeGiftData(bRedShow)
    --PhoneFeeGiftModel:setRedDotCount()
end

-- 惊喜夺宝
function ActivityCenterCtrl:generateSupriseTreasure(pageType, data)
    local activity = self:createSupriseTreasureImage(pageType, data)
    return activity
end

function ActivityCenterCtrl:createSupriseTreasureImage(pageType, data)
    local viewNode = self._viewNode

    local activityId = data.activity
    local ExchangeLotteryCtrl = import("src.app.plugins.ExchangeLottery.ExchangeLotteryCtrl")
    self.ExchangeLotteryCtrl = ExchangeLotteryCtrl:create() 
    local activityBk = self.ExchangeLotteryCtrl._viewNode:getRealNode()
    activityBk:setPosition(448,288)
    self._infoPanel[pageType]:addChild(activityBk) 
     return activityBk  
end

function ActivityCenterCtrl:setSupriseTreasureData(pageType, data)
    --return self:setTreasureBoxData()
end

-- 百元红包活动
function ActivityCenterCtrl:generateRedPack100(pageType, data)
    local activity = self:createRedPack100Image(pageType, data)
    return activity
end

function ActivityCenterCtrl:createRedPack100Image(pageType, data)
    local viewNode = self._viewNode

    local queryInfo = RedPack100Model:GetRedPackInfo()
    if queryInfo.nShowMode and queryInfo.nShowMode == 1 then
        self.RedPack100Ctrl = import("src.app.plugins.RedPack100Vocher.Vocher_ActivityRedPack100Ctrl"):create() 
    else
        self.RedPack100Ctrl = import("src.app.plugins.RedPack100.ActivityRedPack100Ctrl"):create() 
    end 
    local activityBk = self.RedPack100Ctrl._viewNode:getRealNode()
    activityBk:setPosition(ActivityCenterCtrl.ActvityCenterPos)
    self._infoPanel[pageType]:addChild(activityBk) 
    return activityBk  
end

function ActivityCenterCtrl:setRedPack100Data(pageType, data)
end

-- 连胜挑战
function ActivityCenterCtrl:generateWinningStreak(pageType, data)
    local activity = self:createWinningStreakImage(pageType, data)
    return activity
end

function ActivityCenterCtrl:createWinningStreakImage(pageType, data)
    local viewNode = self._viewNode

    local activityId = data.activity
    local WinningStreakCtrl = import("src.app.plugins.WinningStreak.WinningStreakCtrl")
    self.WinningStreakCtrl = WinningStreakCtrl:create() 
    local activityBk = self.WinningStreakCtrl._viewNode:getRealNode()
    activityBk:setPosition(448,288)
    self._infoPanel[pageType]:addChild(activityBk) 
     return activityBk  
end

function ActivityCenterCtrl:setWinningStreakData(pageType, data)
    --return self:setTreasureBoxData()
end

-- 每日充值
function ActivityCenterCtrl:generateDailyRecharge(pageType, data)
    local activity = self:createDailyRechargeImage(pageType, data)
    return activity
end 

function ActivityCenterCtrl:createDailyRechargeImage(pageType, data)
    local viewNode = self._viewNode

    local activityId = data.activity
    local DailyRechargeCtrl = import("src.app.plugins.DailyRecharge.DailyRechargeCtrl")
    self.DailyRechargeCtrl = DailyRechargeCtrl:create() 
    local activityBk = self.DailyRechargeCtrl._viewNode:getRealNode()
    activityBk:setPosition(448,288)
    self._infoPanel[pageType]:addChild(activityBk) 
     return activityBk  
end

function ActivityCenterCtrl:setDailyRechargeData(pageType, data)
    --return self:setTreasureBoxData()
end

-- 房间对局送兑换券
function ActivityCenterCtrl:generateRoomgift(pageType, data)
    local viewNode = self._viewNode
    local panel =  self._infoPanel[pageType]

    local giftvoucheractivity = panel:getChildByName("giftvoucheractivity")
    if not giftvoucheractivity then
        local activityId = data.activity
        giftvoucheractivityctrl = import("src.app.plugins.giftvoucheractivity.giftvoucheractivityctrl"):create(self) 
        giftvoucheractivity = giftvoucheractivityctrl._viewNode:getRealNode()
        giftvoucheractivity:setPosition(ActivityCenterCtrl.ActvityCenterPos)
        panel:addChild(giftvoucheractivity)
        giftvoucheractivity:setName("giftvoucheractivity")
    end
    return giftvoucheractivity
end

--对局送门票
function ActivityCenterCtrl:generatefreetick(pageType, data)
    local viewNode = self._viewNode
    local panel =  self._infoPanel[pageType]

    local TimingGameTicketActivity = panel:getChildByName("TimingGameTicketActivity")
    if not TimingGameTicketActivity then
        local activityId = data.activity
        TimingGameTicketActivityctrl = import("src.app.plugins.TimingGame.TimingGameTicketActivity.TimingGameTicketActivityctrl"):create(self)
        TimingGameTicketActivity = TimingGameTicketActivityctrl._viewNode:getRealNode()
        TimingGameTicketActivity:setPosition(ActivityCenterCtrl.ActvityCenterPos)
        panel:addChild(TimingGameTicketActivity)
        TimingGameTicketActivity:setName("TimingGameTicketActivity")  
    end
    return TimingGameTicketActivity
end

function ActivityCenterCtrl:createRoomExchangeImage(pageType, data)
    local viewNode = self._viewNode

    local activityId = data.activity
    local activityBk = cc.CSLoader:createNode("res/hallcocosstudio/settings/settings.csb") 
    activityBk:setAnchorPoint(cc.p(0, 0))
    activityBk:setPosition(ActivityCenterCtrl.PageDetailPos)  

    local contenSize = activityBk:getContentSize()
    activityBk:setScaleX(ActivityCenterCtrl.ActivityPanelWidth / contenSize.width);  
    activityBk:setScaleY(ActivityCenterCtrl.ActivityPanelHeight / contenSize.height);
    self._infoPanel[pageType]:addChild(activityBk) 
    return activityBk    
end

function ActivityCenterCtrl:setRoomExchangeData(pageType, data)
    --return self:setTreasureBoxData()
end

function ActivityCenterCtrl:generatePageLink(pageType, pageItemInfo, button, info)
    local activityId = pageItemInfo.activity
    table.insert(self._pageData[pageType]["activityId"], activityId)
    table.insert(self._pageData[pageType]["buttonList"], button)
    table.insert(self._pageData[pageType]["infoList"], info)
    self._pageData[pageType]["linkIndex"][activityId] = #self._pageData[pageType]["infoList"]

    if not button then
        return -- 配置ActivityNotice和ActivityMatrix的公告ID对不上会导致公告button为nil，这里加保护
    end

    button:addClickEventListener(function()
        my.playClickBtnSound()
        -- 在有惊喜夺宝且惊喜夺宝在抽奖的时候，不让点
        if self.ExchangeLotteryCtrl and not self.ExchangeLotteryCtrl:onClickClose() then
            return
        end
        if math.floor(activityId/10000) == ActivityCenterModel.TASK_ID then
            ActivityCenterModel:onTabTaskData(activityId) 
        end
        self:showPageItemInfo(pageType, pageItemInfo)
        --dump(pageItemInfo)
    end)
end

function ActivityCenterCtrl:showPageItemInfo(pageType, pageItemInfo)
    if pageItemInfo == nil then
        return
    end

    local activityId = pageItemInfo.activity
    local index = self._pageData[pageType]["linkIndex"][activityId]
    if index == nil then
        return
    end

    if activityId == ActivityCenterConfig.ActivityExplain["phonefeegift"] then
        PhoneFeeGiftModel:clearRedDotCount()
    end

    self:hidePageItemInfo(pageType) 
    if activityId >= ActivityCenterModel.NOTICE_START and activityId <= ActivityCenterModel.NOTICE_END then
        local noticeInfo = ActivityCenterModel:getNoticeInfoByKey(activityId)
        if noticeInfo.type == ActivityCenterModel.LINK_TYPE then
             if string.find(noticeInfo.content, "%.jpg$") or string.find(noticeInfo.content, "%.png$") then 

             else
                local webview = self._pageData[pageType]["infoList"][index]:getChildByName("WebView")

                if activityId >= ActivityCenterModel.HSOX_START then
                    local user = mymodel('UserModel'):getInstance()
                    noticeInfo.content = noticeInfo.content .. "?" .. "userid=" .. user.nUserID .. "&" .. "activityid=" .. activityId
                end

                webview:loadURL(noticeInfo.content)
                webview:setVisible(true)
             end
        end
    end

    self._pageData[pageType]["infoList"][index]:setVisible(true)    
    self:callSubCtrlDoSomething(activityId)

    local btn = self._pageData[pageType]["buttonList"][index]

    if pageItemInfo.reddotShow then -- 点击过后页签红点消失处理
        btn:getChildByName("RedDot"):setVisible(false)
        ActivityCenterStatus:updateActivityRedDot(activityId)
        pageItemInfo.reddotShow = false
        ActivityCenterModel:subRedDotTypeCount(pageType, activityId, true)
    end
    
    self:updateRedDot() -- 根据各活动的红点显示状态，重新刷新红点

    self:setPageButtonFocus(pageType, btn)
    self._currentPageIndex[pageType] = index    -- 记录当前活动/公告 最近一次的索引
end

function ActivityCenterCtrl:setPageButtonFocus(pageType, button)

    for k, v in ipairs(self._pageData[pageType]["buttonList"]) do
        v:setEnabled(true)
        v:setBright(true)

        local textTtfNode = v:getChildByName("title")
        local textTTF = textTtfNode:getChildByName("Text_TTF")
        if false == textTTF:isVisible() then    --  没有用默认字体显示的，需要单独处理
            local fntTextNomal = textTtfNode:getChildByName("Fnt_Nomal")
            local fntTextPressed = textTtfNode:getChildByName("Fnt_Pressed")
            fntTextNomal:setVisible(true)
            fntTextPressed:setVisible(false)
        end
    end

    button:setEnabled(false)
    button:setBright(false)
    local textTtfNode = button:getChildByName("title")
    local fntTextNomal = textTtfNode:getChildByName("Fnt_Nomal")
    local fntTextPressed = textTtfNode:getChildByName("Fnt_Pressed")
    local textTTF = textTtfNode:getChildByName("Text_TTF")
    if false == textTTF:isVisible() then
        fntTextNomal:setVisible(false)
        fntTextPressed:setVisible(true)
    end

end

function ActivityCenterCtrl:generateNoticeBtn(pageType, pageItemInfo)
    local viewNode = self._viewNode
    local activityId = pageItemInfo.activity
    local noticeInfo = ActivityCenterModel:getNoticeInfoByKey(activityId)

    if not noticeInfo then
        return
    end

    local normal = ActivityCenterConfig.ActivityCommon["title_btn_normal"] 
    local push = ActivityCenterConfig.ActivityCommon["title_btn_push"]
    local disable = ActivityCenterConfig.ActivityCommon["title_btn_disable"]
    local btn = ccui.Button:create(normal, push, disable, UI_TEX_TYPE_PLIST)

    local title = noticeInfo["title"]
    local utf8title = MCCharset:getInstance():gb2Utf8String(title, string.len(title))

    local btnWidth = btn:getContentSize().width   
    local btnHeight = btn:getContentSize().height 


    local redDot = cc.Sprite:createWithSpriteFrameName("hallcocosstudio/images/plist/Common/hongdian_pic.png")
    redDot:setName("RedDot")
    redDot:setPosition(cc.p(btnWidth * 0.88, btnHeight * 0.90))
    btn:addChild(redDot)

    if pageItemInfo.reddotShow then
        redDot:setVisible(true)
    else
        redDot:setVisible(false)
    end

    local textTtfNode = cc.CSLoader:createNode("res/hallcocosstudio/activitycenter/activitytext.csb")    
    local textTTF = textTtfNode:getChildByName("Text_TTF")
    textTTF:setString(utf8title)
    textTTF:setVisible(false)

    local fntTextNomal = textTtfNode:getChildByName("Fnt_Nomal")
    fntTextNomal:setString(utf8title)
    fntTextNomal:setVisible(false)

    local fntTextPressed = textTtfNode:getChildByName("Fnt_Pressed")
    fntTextPressed:setString(utf8title)
    fntTextPressed:setVisible(false)

    if ActivityCenterConfig.FntContent[utf8title] ~= nil then
        fntTextNomal:setVisible(true)
    else
        textTTF:setVisible(true)
    end

    textTtfNode:setAnchorPoint(cc.p(0.5, 0.5))
    textTtfNode:setPosition(cc.p(btnWidth/2-5, btnHeight/2)) 
    textTtfNode:setName("title")
    btn:addChild(textTtfNode)


    self._buttonPanel[pageType]:addChild(btn)

    return btn 
end

function ActivityCenterCtrl:generateNoticeImage(pageType, pageItemInfo)
    local activityId = pageItemInfo.activity
    local noticeInfo = ActivityCenterModel:getNoticeInfoByKey(activityId)

    if not noticeInfo then
        return
    end

    if noticeInfo.type == ActivityCenterModel.TEXT_TYPE then
        return self:generateNoticeText(pageType, noticeInfo)
    elseif noticeInfo.type == ActivityCenterModel.LINK_TYPE then
        return self:generateNoticeLink(pageType, noticeInfo)
    end
    
end

-- 文字形式的公告
function ActivityCenterCtrl:generateNoticeText(pageType, noticeInfo)
    local noticeBk, titleBk = self:generateNoticeBk()

    local originalTitle = noticeInfo["title"]
    local originalContent = noticeInfo["content"]

    local utf8title = MCCharset:getInstance():gb2Utf8String(originalTitle, string.len(originalTitle))
    local utf8content = MCCharset:getInstance():gb2Utf8String(originalContent, string.len(originalContent))

    local specialTitleString = ""
    local specialContentString = ""

    for w in string.gmatch(utf8title, "<%w+>") do
        specialTitleString = specialTitleString .. w
    end

    for w in string.gmatch(utf8content, "<%w+>") do
        specialContentString = specialContentString .. w
    end

    local textTitleFontSize = 40
    local textTitle = cc.LabelTTF:create(utf8title, "黑体", textTitleFontSize)
    local specialTitle = cc.LabelTTF:create(specialTitleString, "黑体", textTitleFontSize)

    local textContent = cc.LabelTTF:create(utf8content, "黑体", 30)
    local specialContent = cc.LabelTTF:create(specialContentString, "黑体", 30)

    local titleLen = textTitle:getContentSize().width - specialTitle:getContentSize().width
    local titleHeight = textTitle:getContentSize().height

    local contentLen = textContent:getContentSize().width - specialContent:getContentSize().width
    local contentHeight = textContent:getContentSize().height

    local richTitle = RichText:create()
    richTitle:setAnchorPoint(cc.p(0.5, 0.5))
    richTitle:setPosition(375, 30.5)
    richTitle:setContentSize(titleLen, titleHeight)
    richTitle:setFontSize(textTitleFontSize)
    richTitle:setTextColor(cc.c3b(255, 255, 255))
    richTitle:setStringEx(utf8title)
    titleBk:addChild(richTitle)

    local richContent = RichText:create()
    richContent:setAnchorPoint(cc.p(0, 1))
    richContent:setPosition(40, 450)
    richContent:setContentSize(800, contentHeight)
    richTitle:setFontSize(35)   -- 内容大小

    utf8content = string.gsub(utf8content,"\\n","\n")
    utf8content = string.gsub(utf8content,"\\r","\r")
    richContent:setStringEx(utf8content) 

    --noticeBk:addChild(richContent)
    -- 文字形式的公告放在滚动条里
    local richContentHeight = 800
    richContent:setPosition(40, richContentHeight)
    local  scrollview = ccui.ScrollView:create() --创建滚动视图
    scrollview:setTouchEnabled(true)
    scrollview:setBounceEnabled(true)               --这句必须要不然就不会滚动噢
    scrollview:setDirection(ccui.ScrollViewDir.vertical) --设置滚动的方向
    scrollview:setContentSize(cc.size(ActivityCenterCtrl.ActivityPanelWidth,ActivityCenterCtrl.ActivityPanelHeight - titleHeight - 60))     --设置尺寸
    scrollview:setInnerContainerSize(cc.size(richContent:getContentSize().width, richContentHeight))
    scrollview:setAnchorPoint(cc.p(0, 0))
    scrollview:setPosition(ActivityCenterCtrl.PageDetailPos)
    scrollview:addChild(richContent)
    noticeBk:addChild(scrollview)

    self._infoPanel[pageType]:addChild(noticeBk)
    
    return noticeBk
end

-- 链接形式的公告
function ActivityCenterCtrl:generateNoticeLink(pageType, noticeInfo)
    if string.find(noticeInfo.content, "%.jpg$") or string.find(noticeInfo.content, "%.png$") then 
        local picBk = ccui.Scale9Sprite:createWithSpriteFrameName("hallcocosstudio/images/plist/ActivityCenter/notice_yellow_di.png")
        picBk:setContentSize(cc.size(ActivityCenterCtrl.ActivityPanelWidth, ActivityCenterCtrl.ActivityPanelHeight))
        picBk:setAnchorPoint(cc.p(0,0))
        picBk:setPosition(ActivityCenterCtrl.PageDetailPos)

        local pic = ccui.ImageView:create()
        pic:ignoreContentAdaptWithSize(false)
        --pic:setPosition(334, 237.5)
        --pic:setContentSize(cc.size(668, 475))
        pic:setContentSize(cc.size(ActivityCenterCtrl.ActivityPanelWidth, ActivityCenterCtrl.ActivityPanelHeight))  -- 链接形式公告设置大小
        pic:setAnchorPoint(cc.p(0,0))
        pic:setPosition(cc.p(0,0))

        if string.len(noticeInfo.jump) > 0 then 
            local btn = self:generateJumpBtn(noticeInfo, pic)
            picBk:addChild(btn)
        end

        picBk:addChild(pic)
        self._infoPanel[pageType]:addChild(picBk) 

        local url = noticeInfo.content
        local urlArr = string.split(url, '/')
        local fileName = urlArr[#urlArr]
        local filePath = my.getDataCachePath() .. fileName
        if(my.isCacheExist(fileName)) then
            pic:loadTexture(filePath, ccui.TextureResType.localType)
        else
            -- local function downloadCallback(event, ...)
            --     if event == DownloadModel.DOWNEVENT_ERROR then
            --         print("ActivityCenterCtrl:downloadCallback err url:".. url)
            --     elseif event == DownloadModel.DOWNEVENT_SUCCESS and not tolua.isnull(pic) then
            --         pic:loadTexture(filePath, ccui.TextureResType.localType)
            --     end
            -- end

            -- DownloadModel:download(url, downloadCallback, filePath)

            local thirdPartyImageCtrl = require('src.app.BaseModule.YQWImageCtrl')
            thirdPartyImageCtrl:getUserhuodongImage(url, function(code, path)
                if code == cc.exports.ImageLoadActionResultCode.kImageLoadOnlineSuccess and not tolua.isnull(pic) then
                    pic:loadTexture(filePath, ccui.TextureResType.localType)
                else
                    print("ActivityCenterCtrl:downloadCallback err url:".. url)
                end
            end)

        end

        return picBk    
    else
        local webViewBk = ccui.Scale9Sprite:create("notice_yellow_di.png")
        --webViewBk:setPosition(334, 237.5)
        --webViewBk:setContentSize(cc.size(668, 475))
        webViewBk:setContentSize(cc.size(ActivityCenterCtrl.ActivityPanelWidth, ActivityCenterCtrl.ActivityPanelHeight))
        webViewBk:setAnchorPoint(cc.p(0,0))
        webViewBk:setPosition(ActivityCenterCtrl.PageDetailPos)

        local webview = self:addWebView(noticeInfo, webViewBk)

        if string.len(noticeInfo.jump) > 0 then 
            local btn = self:generateJumpBtn(noticeInfo, webview)
            webViewBk:addChild(btn)
        end
  
        self._infoPanel[pageType]:addChild(webViewBk)

        return webViewBk
    end
end

function ActivityCenterCtrl:generateJumpBtn(noticeInfo, obj)
    if obj then
        obj:setContentSize(cc.size(ActivityCenterCtrl.ActivityPanelWidth- 10, ActivityCenterCtrl.ActivityPanelHeight - 10))
        obj:setPosition(ActivityCenterCtrl.ActivityPanelWidth/2, ActivityCenterCtrl.ActivityPanelHeight/2)
    end
    local normal = "h_ac_qianwan_btn.png" 
    local push = "h_ac_qianwan_btn.png"
    local disable = "h_ac_qianwan_btn.png"
    local btn = ccui.Button:create(normal, push, disable, UI_TEX_TYPE_PLIST)
    btn:setPosition(ActivityCenterCtrl.ActivityPanelWidth/2, ActivityCenterCtrl.ActivityPanelHeight/2-200)

    btn:addClickEventListener(function() 
        my.playClickBtnSound() 
        self:onClose()
        self:jumpToWeb(noticeInfo.jump, noticeInfo.id) 
    end)

    return btn
end

function ActivityCenterCtrl:jumpToWeb(jumpInfo, activityId)
    if activityId and activityId >= ActivityCenterModel.HSOX_START then
        local user = mymodel('UserModel'):getInstance()
        jumpInfo = jumpInfo .. "?" .. "userid=" .. user.nUserID .. "&" .. "actid=" .. activityId .. "&" .. "ver=" .. ActivityCenterModel.HSOXACTVER
    end
    my.informPluginByName({pluginName='ActivityJumpWeb', params={url = jumpInfo}})
end

function ActivityCenterCtrl:generateNoticeBk()
    local dikuangPos = cc.p(self._viewNode.dikuang:getPosition())

    local noticeBk = ccui.Scale9Sprite:createWithSpriteFrameName("hallcocosstudio/images/plist/ActivityCenter/notice_yellow_di.png")
    noticeBk:setContentSize(cc.size(ActivityCenterCtrl.ActivityPanelWidth, ActivityCenterCtrl.ActivityPanelHeight))
    noticeBk:setAnchorPoint(cc.p(0,0))
    noticeBk:setPosition(ActivityCenterCtrl.PageDetailPos)

    local titleBk = cc.Scale9Sprite:createWithSpriteFrameName("hallcocosstudio/images/plist/ActivityCenter/h_ac_notice_bk.png")
    titleBk:setPosition(440, 500)   -- 文字公告 title位置
    titleBk:setContentSize(cc.size(780, 61))
    --titleBk:setScaleX(1.1)
    noticeBk:addChild(titleBk)

    return noticeBk, titleBk
end

function ActivityCenterCtrl:showPageItemInfoDef(pageType)
    --self:hidePageItemInfo(pageType)
    local nIndex = self._currentPageIndex[pageType] or 1
    for k, v in pairs(self._pageData[pageType]["buttonList"]) do
        if nIndex == k then
            local activityId = self._pageData[pageType]["activityId"][k]
            if activityId == ActivityCenterConfig.ActivityExplain["phonefeegift"] then
                PhoneFeeGiftModel:clearRedDotCount()
            end
            if activityId >= ActivityCenterModel.NOTICE_START and activityId <= ActivityCenterModel.NOTICE_END then
                local noticeInfo = ActivityCenterModel:getNoticeInfoByKey(activityId)
                if noticeInfo.type == ActivityCenterModel.LINK_TYPE then
                     if string.find(noticeInfo.content, "%.jpg$") or string.find(noticeInfo.content, "%.png$") then 

                     else
                        local vebview = self._pageData[pageType]["infoList"][k]:getChildByName("WebView")

                        if activityId >= ActivityCenterModel.HSOX_START then
                            local user = mymodel('UserModel'):getInstance()
                            noticeInfo.content = noticeInfo.content .. "?" .. "userid=" .. user.nUserID .. "&" .. "activityid=" .. activityId
                        end

                        vebview:loadURL(noticeInfo.content)
                        vebview:setVisible(true)
                     end
                end
            end
            self._pageData[pageType]["infoList"][k]:setVisible(true)  
            self:callSubCtrlDoSomething(activityId, true)
                  
            local btn = self._pageData[pageType]["buttonList"][k]
            self:setPageButtonFocus(pageType, btn)
     
            for m, n in pairs(self._pageData[pageType]["linkIndex"]) do
                if n == k then
                    local pageItemInfo = ActivityCenterModel:getMatrixInfoByKey(pageType, m)
                    if pageItemInfo.reddotShow then
                        btn:getChildByName("RedDot"):setVisible(false)
                        ActivityCenterStatus:updateActivityRedDot(m)
                        pageItemInfo.reddotShow = false
                        ActivityCenterModel:subRedDotTypeCount(pageType, m)
                    end
                    self:updateRedDot()
                    break
                end
            end
     
            return

        end
    end
end

function ActivityCenterCtrl:updateRedDot()
    self:setRedDot(ActivityCenterCtrl.AC_PHONE_FEE_GIFT, ActivityCenterConfig.ActivityExplain["phonefeegift"])
    self:setRedDot(ActivityCenterCtrl.AC_EXCHANGE_LOTTERY, ActivityCenterConfig.ActivityExplain["exchangelottery"])
    self:setRedDot(ActivityCenterCtrl.AC_REDPACK100, ActivityCenterConfig.ActivityExplain["redpack100"])
    self:setRedDot(ActivityCenterCtrl.AC_WINNINGSTREAK, ActivityCenterConfig.ActivityExplain["winningstreak"])  --连胜挑战
    self:setRedDot(ActivityCenterCtrl.AC_DAILYRECHARGE, ActivityCenterConfig.ActivityExplain["dailyrecharge"])  --连胜挑战

    --任务红点Begin
    if "table" == type(ActivityCenterModel._activityTaskReddot) then
        for k, v in pairs(ActivityCenterModel._activityTaskReddot) do
            if rawget(v, "nRedDotCnt") > 0 then
                local reddotShow = true
                for m, n in ipairs(ActivityCenterModel.PAGE_TYPE) do
                    local index = self._pageData[n] and self._pageData[n]["linkIndex"][rawget(v, "nTaskGID")] or nil
                    local pageItemInfo = ActivityCenterModel:getMatrixInfoByKey(n, rawget(v, "nTaskGID"))

                    if index and pageItemInfo and pageItemInfo.needShow then
                        self._pageData[n]["buttonList"][index]:getChildByName("RedDot"):setVisible(reddotShow)
                        ActivityCenterModel:addRedDotTypeCount(n, rawget(v, "nTaskGID"), true)
                    end
                end
            end
        end
    end 
    --任务红点End
  
    for k, v in ipairs(ActivityCenterModel.PAGE_TYPE) do
        self:updateTitleRedDot(v)
    end
end

function ActivityCenterCtrl:updateTitleRedDot(pageType)
    local redDotCount = ActivityCenterModel:getRedDotTypeCount(pageType)
    if pageType > #self._redDotPanel then
        return
    end
    if redDotCount > 0 then
        self._redDotPanel[pageType]:setVisible(true)

        if pageType == ActivityCenterModel.ACTIVITY_TYPE then
            local textRedDotNum = self._viewNode.jchdRedDotNum
            textRedDotNum:setString(redDotCount)
        end
    else
        self._redDotPanel[pageType]:setVisible(false)
    end
end

function ActivityCenterCtrl:setRedDot(msgBoxEnum, activityId)
    for k, v in ipairs(ActivityCenterModel.PAGE_TYPE) do
        local isRedDotVisible = self:isNewMsgInOperatingActivity(msgBoxEnum)
        local index = self._pageData[v] and self._pageData[v]["linkIndex"][activityId] or nil
        local pageItemInfo = ActivityCenterModel:getMatrixInfoByKey(v, activityId)

        if index and pageItemInfo and pageItemInfo.needShow then
            if isRedDotVisible then 
                self._pageData[v]["buttonList"][index]:getChildByName("RedDot"):setVisible(isRedDotVisible)
                ActivityCenterModel:addRedDotTypeCount(v, activityId, true)
            else
                if pageItemInfo.reddotShow then
                    --此时不隐藏
                else
                    self._pageData[v]["buttonList"][index]:getChildByName("RedDot"):setVisible(isRedDotVisible)
                    ActivityCenterModel:subRedDotTypeCount(v, activityId, true)
                end
            end
        end

        if not WinningStreakModel:NeedShowRedDot()  and ActivityCenterConfig.ActivityExplain["winningstreak"] == activityId then
            ActivityCenterModel:subRedDotTypeCount(v, activityId, false)
        end
    end
end

function ActivityCenterCtrl:freshActivityAndNoticePanel( )
    if self._infoPanel[ActivityCenterModel.ACTIVITY_TYPE] then
        self._infoPanel[ActivityCenterModel.ACTIVITY_TYPE]:removeAllChildren()
    end
    if self._buttonPanel[ActivityCenterModel.ACTIVITY_TYPE] then
        self._buttonPanel[ActivityCenterModel.ACTIVITY_TYPE]:removeAllChildren()
    end

    self:initActivityAndNoticePanel()
end

function ActivityCenterCtrl:updateExchangeLotteryRedDot( )
    self:updateRedDot()
end

function ActivityCenterCtrl:updatePhoneFeeGiftRedDot( )
    self:updateRedDot()
end

function ActivityCenterCtrl:updateRedPackRedDot( )
    self:updateRedDot()
end

function ActivityCenterCtrl:onClose( )
    self._viewNode:stopAllActions()
    if self.PhoneFeeGiftCtrl then
        --self.PhoneFeeGiftCtrl:removeInstance()
        self.PhoneFeeGiftCtrl:onExit()
        self.PhoneFeeGiftCtrl = nil
    end
    if self.ExchangeLotteryCtrl then
        --self.ExchangeLotteryCtrl:removeInstance()
        self.ExchangeLotteryCtrl:onExit()
        self.ExchangeLotteryCtrl = nil
    end

    if self.RedPack100Ctrl then
        self.RedPack100Ctrl:onExit()
        self.RedPack100Ctrl = nil
    end

    if giftvoucheractivityctrl then
        giftvoucheractivityctrl:removeSelfInstance()
        giftvoucheractivityctrl = nil
    end

    --活动功能不存在
    if TimingGameTicketActivityctrl then
        TimingGameTicketActivityctrl:removeSelfInstance()
        TimingGameTicketActivityctrl = nil
    end

    if self.WinningStreakCtrl then
        self.WinningStreakCtrl:onExit()
        self.WinningStreakCtrl = nil
    end

    if self.DailyRechargeCtrl then
        self.DailyRechargeCtrl:onExit()
        self.DailyRechargeCtrl = nil
    end
    
    self._viewNode:stopAllActions()
    self:removeSelfInstance()

    if self._params and self._params.closeCallback and type(self._params.closeCallback) == "function" then
        self._params.closeCallback()
    end
end

function ActivityCenterCtrl:callSubCtrlDoSomething(activityID, bReadCache)
    local activityId = ActivityCenterConfig.ActivityExplain["phonefeegift"]
    if activityId == activityID then
        if self.PhoneFeeGiftCtrl then
            self.PhoneFeeGiftCtrl:onEnterAfterActivityBtnClick(bReadCache)
            return
        end
    end
    activityId = ActivityCenterConfig.ActivityExplain["redpack100"]
    if activityId == activityID then
        if self.RedPack100Ctrl then
            self.RedPack100Ctrl:onEnterAfterActivityBtnClick(bReadCache)
            return
        end
    end

    --连胜挑战
    activityId = ActivityCenterConfig.ActivityExplain["winningstreak"]
    if activityId == activityID then
        if self.WinningStreakCtrl then
            self.WinningStreakCtrl:onEnterAfterActivityBtnClick()
            return
        end
    end

end

function ActivityCenterCtrl:onExit()
 
end


ActivityCenterCtrl.ActivityBtnList = {
[101] = ActivityCenterCtrl.generateActivityBtn, 
[102] = ActivityCenterCtrl.generateActivityBtn,
[103] = ActivityCenterCtrl.generateActivityBtn,
[104] = ActivityCenterCtrl.generateActivityBtn,
[105] = ActivityCenterCtrl.generateActivityBtn,
[106] = ActivityCenterCtrl.generateActivityBtn,
[107] = ActivityCenterCtrl.generateActivityBtn,
}

ActivityCenterCtrl.ActivityFunList = {
[101] = ActivityCenterCtrl.generatePhoneFeeGift,    -- 话费有礼
[102] = ActivityCenterCtrl.generateSupriseTreasure, -- 惊喜夺宝
[103] = ActivityCenterCtrl.generateRoomgift,    -- 房间对局送兑换券
[104] = ActivityCenterCtrl.generateRedPack100,      -- 百元红包活动
[105] = ActivityCenterCtrl.generateWinningStreak,      -- 连胜挑战活动
[106] = ActivityCenterCtrl.generateDailyRecharge,      -- 每日充值活动
[107] = ActivityCenterCtrl.generatefreetick,      -- 免费门票
}

ActivityCenterCtrl.ActivitySetDataList = {
[101] = ActivityCenterCtrl.setPhoneFeeGiftData,
[102] = ActivityCenterCtrl.setSupriseTreasureData,
[103] = ActivityCenterCtrl.setRoomExchangeData,
[104] = ActivityCenterCtrl.setRedPack100Data,
[105] = ActivityCenterCtrl.setWinningStreakData,
[106] = ActivityCenterCtrl.setDailyRechargeData,
[107] = ActivityCenterCtrl.setRoomExchangeData, --这个函数啥也没做
}




return ActivityCenterCtrl
