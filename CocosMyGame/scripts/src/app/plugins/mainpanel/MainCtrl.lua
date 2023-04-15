
local MainView = import('src.app.plugins.mainpanel.MainView')
local MainCtrl = class("MainCtrl",cc.load('SceneCtrl'))

local HallContext = import('src.app.plugins.mainpanel.HallContext'):getInstance()
local MainCtrlSubManager = import('src.app.plugins.mainpanel.MainCtrlSubManager')

local player=mymodel('hallext.PlayerModel'):getInstance()
local user=mymodel('UserModel'):getInstance()
local feedback=mymodel('hallext.FeedbackModel'):getInstance()
local relief=mymodel('hallext.ReliefActivity'):getInstance()
local checkin=mymodel('hallext.CheckinActivity'):getInstance()

local TaskModel = import('src.app.plugins.MyTaskPlugin.TaskModel'):getInstance()
local RoomListModel = import("src.app.GameHall.room.model.RoomListModel"):getInstance()
local ShopModel = mymodel("ShopModel"):getInstance()
local CardRecorderModel = import("src.app.plugins.shop.cardrecorder.CardRecorderModel"):getInstance()
local AssistCommon = import("src.app.GameHall.models.assist.common.AssistCommon"):getInstance()
local ArenaModel = import("src.app.plugins.arena.ArenaModel"):getInstance()
local UserLevelModel = import("src.app.plugins.personalinfo.UserLevelModel"):getInstance()
local RechargeActivityModel = import('src.app.plugins.RechargeActivity.RechargeActivityModel'):getInstance()
local ExchangeCenterModel = require("src.app.plugins.ExchangeCenter.ExchangeCenterModel"):getInstance()
local AdditionConfigModel = import('src.app.GameHall.config.AdditionConfigModel'):getInstance()
local SettingModel = mymodel('hallext.SettingsModel'):getInstance()
local EmailModel = mymodel("hallext.EmailModel"):getInstance()
local LoginLotteryModel = import("src.app.plugins.loginlottery.LoginLotteryModel"):getInstance()
local MonthCardModel = require("src.app.plugins.monthcard.MonthCardConn"):getInstance()
local NewPlayerGiftModel = import("src.app.plugins.newPlayerGift.NewPlayerGiftModel"):getInstance()
local ActivityCenterModel = import('src.app.plugins.activitycenter.ActivityCenterModel'):getInstance()
local NationalDayActivityModel = import("src.app.plugins.NationalDayActivity.NationalDayActivityModel"):getInstance()
local tcyFriendPluginWrapper = PUBLIC_INTERFACE.GetTcyFriendPluginWrapper()

local PublicInterface = cc.exports.PUBLIC_INTERFACE
local viewConfig = require('src.app.HallConfig.PluginViewConfig')
local constStrings = cc.load('json').loader.loadFile('MainSceneStrings.json')
local constReliefStrings=cc.load('json').loader.loadFile('ReliefStrings.json')

local monthcard = require("src.app.plugins.monthcard.MonthCardCtrl")
local MyTimeStampCtrl = import("src.app.mycommon.mytimestamp.MyTimeStamp"):getInstance()
local PluginProcessModel = mymodel('hallext.PluginProcessModel'):getInstance()
local ExchangeLotteryModel = require('src.app.plugins.ExchangeLottery.ExchangeLotteryModel'):getInstance()
local WeakenScoreRoomModel = require('src.app.plugins.weakenscoreroom.WeakenScoreRoomModel'):getInstance()
local GoldSilverModel = require('src.app.plugins.goldsilver.GoldSilverModel'):getInstance()
local GoldSilverModelCopy = require('src.app.plugins.goldsilverCopy.GoldSilverModelCopy'):getInstance()
local FirstRechargeModel      = import("src.app.plugins.firstrecharge.FirstRechargeModel"):getInstance()

local NobilityPrivilegeDef          = import('src.app.plugins.NobilityPrivilege.NobilityPrivilegeDef')
local NobilityPrivilegeModel        = import("src.app.plugins.NobilityPrivilege.NobilityPrivilegeModel"):getInstance()
local NobilityPrivilegeGiftDef      = import('src.app.plugins.NobilityPrivilegeGift.NobilityPrivilegeGiftDef')
local NobilityPrivilegeGiftModel    = import("src.app.plugins.NobilityPrivilegeGift.NobilityPrivilegeGiftModel"):getInstance()

local BroadcastModel        = mymodel("hallext.BroadcastModel"):getInstance()
local LuckyCatDef           = import('src.app.plugins.LuckyCat.LuckyCatDef')
local LuckyCatModel         = import("src.app.plugins.LuckyCat.LuckyCatModel"):getInstance()
local AdvertModel           = import('src.app.plugins.advert.AdvertModel'):getInstance()
local AdvertDefine          = import('src.app.plugins.advert.AdvertDefine')

local BankruptcyDef         = require('src.app.plugins.Bankruptcy.BankruptcyDef')
local BankruptcyModel       = import('src.app.plugins.Bankruptcy.BankruptcyModel'):getInstance()

local DailyRechargeModel = import('src.app.plugins.DailyRecharge.DailyRechargeModel'):getInstance()
local WeekCardModel = import('src.app.plugins.WeekCard.WeekCardModel'):getInstance()
local TimingGameModel = import('src.app.plugins.TimingGame.TimingGameModel'):getInstance()
local ReliefDef             = import('src.app.plugins.relief.ReliefDef')

-- 超级大奖池
local rechargePoolModel = require("src.app.plugins.rechargepool.RechargePoolModel"):getInstance()
local ContinueRechargeModel = require("src.app.plugins.continuerecharge.ContinueRechargeModel"):getInstance()
-- 幸运礼包
local LuckyPackDef          = require('src.app.plugins.LuckyPack.LuckyPackDef')
local LuckyPackModel        = require("src.app.plugins.LuckyPack.LuckyPackModel"):getInstance()

local SpringFestivalModel = import('src.app.BaseModule.SpringFestivalModel'):getInstance()

local ComEvtTrkingModel = require("src.app.GameHall.models.ComEvtTrking.ComEvtTrkingModel"):getInstance()
local WatchVideoTakeRewardModel = require("src.app.plugins.watchvideotakereward.WatchVideoTakeRewardModel"):getInstance()

-- Vivo特权活动
local VivoPrivilegeStartUpDef          = require('src.app.plugins.VivoPrivilegeStartUp.VivoPrivilegeStartUpDef')
local VivoPrivilegeStartUpModel        = require("src.app.plugins.VivoPrivilegeStartUp.VivoPrivilegeStartUpModel"):getInstance()

-- 充值翻翻乐
local RechargeFlopCardModel = require("src.app.plugins.RechargeFlopCard.RechargeFlopCardModel"):getInstance()

-- 周月至尊卡
local WeekMonthSuperCardDef          = require('src.app.plugins.WeekMonthSuperCard.WeekMonthSuperCardDef')
local WeekMonthSuperCardModel        = require("src.app.plugins.WeekMonthSuperCard.WeekMonthSuperCardModel"):getInstance()

local PromoteCodeModel      = require("src.app.plugins.PromoteCode.PromoteCodeModel"):getInstance()

local SafeboxDef = import('src.app.plugins.safebox.SafeboxDef')
local SafeboxModel = import('src.app.plugins.safebox.SafeboxModel'):getInstance()

-- 超值连购
local ValuablePurchaseModel = import('src.app.plugins.ValuablePurchase.ValuablePurchaseModel'):getInstance()

-- 感恩大回馈
local GratitudeRepayDef             = require('src.app.plugins.GratitudeRepay.GratitudeRepayDef')
local GratitudeRepayModel           = require('src.app.plugins.GratitudeRepay.GratitudeRepayModel'):getInstance()

-- 组队2V2
local Team2V2Model = import('src.app.plugins.Team2V2Model.Team2V2Model'):getInstance()

-- 邀请有礼
local NewInviteGiftModel = import('src.app.plugins.invitegift.NewInviteGiftModel'):getInstance()
local OldUserInviteGiftModel = import('src.app.plugins.invitegift.oldusergift.OldUserInviteGiftModel'):getInstance()
local NewUserInviteGiftModel = require('src.app.plugins.invitegift.newusergift.NewUserInviteGiftModel'):getInstance()
local NewUserRedbagLoadCtrl   = import('src.app.plugins.invitegift.newusergift.NewUserRedbagLoadCtrl')
local NewUserInviteGiftModel = require('src.app.plugins.invitegift.newusergift.NewUserInviteGiftModel'):getInstance()

-- 新手礼包
local NewUserRewardModel        = require("src.app.plugins.NewUserReward.NewUserRewardModel"):getInstance()
local NewUserRewardDef      = require('src.app.plugins.NewUserReward.NewUserRewardDef')

-- 巅峰榜
local PeakRankModel = import('src.app.plugins.PeakRank.PeakRankModel'):getInstance()

my.addInstance(MainCtrl)

local USERNAMEMAXWIDTH = 200

function MainCtrl:onCreate(params)
    UIHelper:beginRuntime("ShowRedPackOnLaunch", "MainCtrl:onCreate")
    cc.Device:setKeepScreenOn(true)

    print("~~~~~~~~~~~~~MainCtrl onCreate begin~~~~~~~~~~~~")
    MainView:setCtrl(self)
    self:setView(MainView)
    self.subManager = MainCtrlSubManager:create(self)

    local viewNode = self:setViewIndexer(MainView:createViewIndexer())
    viewNode:setName('MainScene')

    self._refreshHandlerOfPluginBtn = {}
    self:_setRefreshHandlerOfPluginBtn()

    self:loginOffUI()
    viewNode.imgIconVerify:setVisible(false)

    self:bindProperty(player, 'PlayerData', self, 'PlayerData')
    self:bindProperty(player, 'PlayerLoginedData', self, 'OnLoginSuccessEvent')
    self:bindProperty(feedback, 'State', self, 'FeedbackState')
    self:bindProperty(relief, 'State', self, 'ReliefState')
    self:bindProperty(checkin, 'Config', self, 'CheckinConfig')

    self:listenTo(player,player.PLAYER_CONTINUE_PWDWRONG,handler(self,self.continuePwdWrong))
    self:listenTo(player,player.PLAYER_LOGIN_OFF,handler(self,self.onPlayLoginOff))
    self:listenTo(player,player.PLAYER_KICKED_OFF,handler(self,self.onUserKickedOff))
    self:listenTo(player,player.PLAYER_KICKED_OFF_BY_ADMIN,handler(self,self.onUserKickedOffByAdmin))
    self:listenTo(player,player.PLAYER_KICKED_OFF_FORBIDTWOHALL,handler(self,self.onUserKickedOff_ForbidTwoHall))
    self:listenTo(player,player.PLAYER_MEMBER_INFO_UPDATED,handler(self,self.doAfterMemberInfoUpdate))  --添加会员更新回调
    self:listenTo(relief,relief.RELIEF_TAKE_FAILED,handler(self,self.onTakeReliefFailed))
    self:listenTo(relief,relief.RELIEF_DATA_UPDATED,handler(self,self.onTakeReliefSuccess))
    self:listenTo(player,player.PLAYER_PORTRAIT_UPDATED,handler(self,self.onPortraitUpdated))
    self:listenTo(player,player.HARDID_MISMATCH,handler(self,self.onHardIDMisMatch))
    self:listenTo(AdditionConfigModel, AdditionConfigModel.EVENT_CONFIG_UPDATED, handler(self, self.onAdditionConfigUpdated))
    self:listenTo(EmailModel, EmailModel.EVENT_EMAILLIST_UPDATED, handler(self, self._setEmailStatus))
    self:listenTo(EmailModel, EmailModel.EVENT_EMAILREWARD_GOT, handler(self, self._setEmailStatus))
    self:listenTo(EmailModel, EmailModel.EVENT_EMAIL_READ, handler(self, self._setEmailStatus))
    self:listenTo(EmailModel, EmailModel.EVENT_REWARDED_BEFORE, handler(self, self._setEmailStatus))
    self:listenTo(EmailModel, EmailModel.EVENT_EMAIL_DELETED, handler(self, self._setEmailStatus))
    self:listenTo(ShopModel, ShopModel.EVENT_UPDATE_RICH,handler(self,self.onUpdateRich))
    self:listenTo(PluginProcessModel, PluginProcessModel.PLUGIN_PROCESS_FINISHED,handler(self,self.onPluginProcessFinished))

    self:listenTo(ExchangeCenterModel, ExchangeCenterModel.EVENT_MODULESTATUS_CHANGED, handler(self, self.onModuleStatusChanged))
    --兑换券
    self:listenTo(ExchangeCenterModel,ExchangeCenterModel.TICKET_LEFT_NUM_UPDATED,handler(self,self.freshExchangeBubble))

    self:listenTo(ShopModel, ShopModel.EVENT_MODULESTATUS_CHANGED, handler(self, self.onModuleStatusChanged))
    self:listenTo(TaskModel, TaskModel.EVENT_MODULESTATUS_CHANGED, handler(self, self.onModuleStatusChanged))
    self:listenTo(HallContext, HallContext.EVENT_MAP["gameScene_goBackToMainScene"], handler(self, self.onBackFromGame))
    self:listenTo(HallContext, HallContext.EVENT_MAP["hall_backToMainSceneFromNonSceneFullScreenCtrl"], handler(self, self.onBackFromNonSceneFullScreenCtrl))
    self:listenTo(LoginLotteryModel, LoginLotteryModel.EVENT_MODULESTATUS_CHANGED, handler(self, self.onModuleStatusChanged))
    self:listenTo(BankruptcyModel, BankruptcyDef.BANKRUPTCY_TIME_UPDATE, handler(self, self.onBankruptcyTimeUpdate))
    self:listenTo(BankruptcyModel, BankruptcyDef.BANKRUPTCY_STATUS_RSP, handler(self, self.onRefreshBankruptcy))
    self:listenTo(BankruptcyModel, BankruptcyDef.BANKRUPTCY_APPLY_BAG_RSP, handler(self, self.onRefreshBankruptcy))
    self:listenTo(WeekCardModel, WeekCardModel.EVENT_MODULESTATUS_CHANGED, handler(self, self.onModuleStatusChanged)) --修改为周卡
    self:listenTo(NewPlayerGiftModel, NewPlayerGiftModel.EVENT_MODULESTATUS_CHANGED, handler(self, self.onModuleStatusChanged))
    self:listenTo(RechargeActivityModel, RechargeActivityModel.EVENT_MODULESTATUS_CHANGED, handler(self, self.onModuleStatusChanged))
    self:listenTo(NationalDayActivityModel, NationalDayActivityModel.EVENT_MODULESTATUS_CHANGED, handler(self, self.onModuleStatusChanged))
    self:listenTo(ActivityCenterModel, ActivityCenterModel.EVENT_MODULESTATUS_CHANGED, handler(self, self.onModuleStatusChanged))
    self:listenTo(GoldSilverModel, GoldSilverModel.EVENT_MODULESTATUS_CHANGED, handler(self, self.onModuleStatusChanged))
    self:listenTo(GoldSilverModelCopy, GoldSilverModelCopy.EVENT_MODULESTATUS_CHANGED, handler(self, self.onModuleStatusChanged))

    self:listenTo(NobilityPrivilegeModel, NobilityPrivilegeDef.NobilityPrivilegeInfoRet, handler(self,self.freshNobilityPrivilege))
    self:listenTo(NobilityPrivilegeGiftModel, NobilityPrivilegeGiftModel.EVENT_MODULESTATUS_CHANGED, handler(self, self.onModuleStatusChanged))

    self:listenTo(LuckyCatModel, LuckyCatDef.LUCKYCATINFORET, handler(self,self.freshLuckyCat))
    self:listenTo(LuckyCatModel, LuckyCatDef.LUCKYCATAWARDGET, handler(self,self.getLuckyCatAward))

    self:listenTo(rechargePoolModel, rechargePoolModel.EVENT_UPDATE_DATA, handler(self, self.onRechargePoolUpdate))
    self:listenTo(ContinueRechargeModel, ContinueRechargeModel.EVENT_INIT_DATA, handler(self, self.onContinueRechargeUpdate))
    self:listenTo(WatchVideoTakeRewardModel, WatchVideoTakeRewardModel.Events.CONFIG_DATA_UPDATED, handler(self, self.onWatchVideoTakeRewardUpdate))
    self:listenTo(RechargeFlopCardModel, RechargeFlopCardModel.Events.RECHARGE_FLOP_CARD_HALL_STATUS_UPDATE, handler(self, self.onRechargeFlopCardUpdate))
    self:listenTo(LuckyPackModel, LuckyPackDef.LUCKY_PACK_QUERY_CONFIG_RSP, handler(self, self.onLuckyPackConfigResp))
    self:listenTo(LuckyPackModel, LuckyPackDef.LUCKY_PACK_QUERY_STATE_RSP, handler(self, self.onLuckyPackStateResp))

    self:listenTo(WeekMonthSuperCardModel, WeekMonthSuperCardDef.WEEK_MONTH_SUPER_CARD_QUERY_CONFIG_RSP, handler(self, self.onRefreshWeekMonthSuperCard))
    self:listenTo(WeekMonthSuperCardModel, WeekMonthSuperCardDef.WEEK_MONTH_SUPER_CARD_QUERY_INFO_RSP, handler(self, self.onRefreshWeekMonthSuperCard))
    self:listenTo(WeekMonthSuperCardModel, WeekMonthSuperCardDef.WEEK_MONTH_SUPER_CARD_TAKE_AWARD_RSP, handler(self, self.onRefreshWeekMonthSuperCard))

    self:listenTo(VivoPrivilegeStartUpModel, VivoPrivilegeStartUpDef.VIVO_PRIVILEGE_STARTUP_QUERY_CONFIG_RSP, handler(self, self.onVivoPrivilegeStartUpConfigResp))
    self:listenTo(VivoPrivilegeStartUpModel, VivoPrivilegeStartUpDef.VIVO_PRIVILEGE_STARTUP_QUERY_STATE_RSP, handler(self, self.onVivoPrivilegeStartUpStateResp))

    self:listenTo(SafeboxModel, SafeboxDef.EVENT_QUERY_SAFEBOX_INFO_OK, handler(self, self.onQuerySafeboxInfoOK))

    -- 超值连购
    self:listenTo(ValuablePurchaseModel, ValuablePurchaseModel.EVENT_QUERY_INFO_OK, handler(self, self.onQueryValuablePurchaseOK))
    self:listenTo(ValuablePurchaseModel, ValuablePurchaseModel.EVENT_BUY_PURCHASE_OK, handler(self, self.onBuyPurchaseOK))

    --感恩大回馈
    self:listenTo(GratitudeRepayModel, GratitudeRepayDef.GRATITUDE_REPAY_QUERY_CONFIG_RSP, handler(self,self.onRefreshGratitudeRepay))

    -- 巅峰榜
    self:listenTo(PeakRankModel, PeakRankModel.EVENT_ON_CONFIG_RSP, handler(self, self.refreshPeakRankBtn))
    self:listenTo(PeakRankModel, PeakRankModel.EVENT_PEAKRANK_UPDATE_REDDOT, handler(self, self.refreshPeakRankBtn))

    my.scheduleFunc(function() feedback:queryState() end, 400)
    cc.exports.gameProtectData.showLottery = true
    
    if PingModeule:isPingSupported() then
        PingModeule:addPingRespondListenr("baidu.com", handler(self, self.onPingUpdated))
    else
        my.scheduleFunc(function() self:updateNetDelay_old() end, 1)
    end
    self:updateBatteryInfo()
    self:setBatteryInfoCallBack()

    if viewNode.memberPic then
        ccui.Helper:doLayout(viewNode.memberPic:getRealNode())
    end

    SettingModel:InitVoiceEnvironment()
    self:_registNetProcessEvents()
    self._readyToShowCheckVersionFailed = params.checkVersionFailed
    print("~~~~~~~~~~~~~MainCtrl onCreate end~~~~~~~~~~~~")

    UserPlugin:registCallbackEventByTag(UserActionResultCode.kModifyNicknameSucceed, handler(self, self.onNickNameChanged), self.__cname)
    self:InitGoldSilver()
    self:InitGoldSilverCopy()
    self:InitExchangeTelephoneLable()

    -- 新的邀请有礼
    self:initInviteGift()

    --测试代码
    my.scheduleOnce(function()
        self:_printAppInfo()
    end, 5)

    --预加载游戏场景纹理资源；可以减少游戏场景加载时间0.5s左右
    UIHelper:preloadGameSceneRes()

    self:setTouched()

    --test new kpi start
    local analyticsPlugin = plugin.AgentManager:getInstance():getAnalyticsPlugin()
    if analyticsPlugin then
        if analyticsPlugin.setCommonInfoMap then
            local params =
            {
                gameId    = tostring(my.getGameID()),   --客户端游戏id
                gameCode  = my.getGameShortName(),      --客户端游戏缩写(不是游戏服务端的缩写，要真实客户端的缩写）
                gameVers  = my.getGameVersion(),        --客户端游戏版本
                roomNo    = "0",
            }
            analyticsPlugin:setCommonInfoMap(params)

            local deviceInfo = analyticsPlugin:getDisdkDeviceInfo()
            print("new kpi--- deviceInfo")
            dump(deviceInfo)
        end
    end
    --test new kpi end
end

--设置触摸事件
function MainCtrl:setTouched()
	local function onTouchBegin(touch, event)
		return self:onTouchBegin(touch, event)
	end
	local listener=cc.EventListenerTouchOneByOne:create()
	listener:registerScriptHandler(onTouchBegin,cc.Handler.EVENT_TOUCH_BEGAN )

	local touchLayer= cc.Layer:create()
	-- local backGroundLayer = cc.LayerColor:create(cc.c4b(255, 255, 255, 255), display.size.width, display.size.height)
    touchLayer:setTouchEnabled(true)
   
    touchLayer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, touchLayer) 
	touchLayer:addTo(self._viewNode, 1000)
end

--响应触摸事件
function MainCtrl:onTouchBegin(touch, event)
	local pos = touch:getLocationInView()
	print("==========MainCtrl:onTouchBegin",pos.x,pos.y)
	self:stopAdvertStandingTimer()	
end 

function MainCtrl:_printAppInfo()
    print("cccc MainCtrl:_printAppInfo")

    local frameSize = cc.Director:getInstance():getOpenGLView():getFrameSize()
    print("frameWidth "..tostring(frameSize.width))
    print("frameHeight "..tostring(frameSize.height))
    print("displayWidth "..tostring(display.width))
    print("displayHeight "..tostring(display.height))
    print("properScale "..tostring(UIHelper:getProperScaleOnFixedHeight()))

    print("sdkName "..tostring(my.getSelfSdkName()))
    print("tcyChannelId "..tostring(my.getTcyChannelId()))

    local agentManager = plugin.AgentManager:getInstance()
    local platformPlugin = agentManager.getTcyPlatformPlugin and agentManager:getTcyPlatformPlugin()
	if platformPlugin then
		local location = platformPlugin:getAppLocation()
        print("province "..tostring(location.province))
        print("city"..tostring(location.city))
    else
        print("engine not support platformPlugin")
	end
end

function MainCtrl:updateNetDelay_old()
    self:updateNetDelay(mc.getNetDelay())
end

function MainCtrl:onPingUpdated(result)
    self:updateNetDelay(result.delay)
end

function MainCtrl:updateNetDelay(delay)
    local viewNode = self._viewNode
    viewNode.panelPin:show()
    delay = math.min(math.floor( delay ), 9999)
    viewNode.txtPin:setString(delay .. "ms")
    
    local netWorkType = DeviceUtils:getInstance():getNetworkType()
    if netWorkType == NetworkType.kNetworkTypeDisconnection then
        self:showNetType("img234GOff")
        viewNode.txtPin:setVisible(false)
	else
        viewNode.txtPin:setVisible(true)
        if delay < 200 then
            viewNode.txtPin:setTextColor(cc.c3b(78,252,131))
            if netWorkType == NetworkType.kNetworkTypeWifi then
                self:showNetType("imgWifiGreen")
            end
        elseif delay < 400 then
            viewNode.txtPin:setTextColor(cc.c3b(250,213,82))
            if netWorkType == NetworkType.kNetworkTypeWifi then
                self:showNetType("imgWifiYellow")
            end
        else
            viewNode.txtPin:setTextColor(cc.c3b(255,88,30))
            if netWorkType == NetworkType.kNetworkTypeWifi then
                self:showNetType("imgWifiRed")
            end
        end
        if netWorkType ~= NetworkType.kNetworkTypeWifi then
		    self:showNetType("img234GOn")
        end
    end
end

function MainCtrl:showNetType(netType)
    local viewNode = self._viewNode
    local netWorkTypeFlags = {"imgWifiGreen", "imgWifiYellow", "imgWifiRed", "imgWifiOff", "img234GOn", "img234GOff"}
    for _, _netType in ipairs(netWorkTypeFlags) do
        viewNode[_netType]:setVisible(_netType == netType)
    end
end

function MainCtrl:updateBatteryInfo()
    local viewNode = self._viewNode
    if not viewNode.panelBattery then return end

    if self:_checkBatteryAvail() == false then
        viewNode.panelBattery:setVisible(false)
    else
        local batteryInfo = DeviceUtils:getInstance():getGameBatteryInfo()
        if not batteryInfo or not batteryInfo.batteryLevel then
            viewNode.panelBattery:setVisible(false)
        else
            viewNode.panelBattery:setVisible(true)
            viewNode.batteryBar:setPercent(batteryInfo.batteryLevel)
        end
    end
end

function MainCtrl:setCheckInStatus(checkFlag)
    if self._viewNode.checkinBtnRedPoint then
        self._viewNode.checkinBtnRedPoint:setVisible(checkFlag)
    end
end

function MainCtrl:onEnter()
    UIHelper:recordRuntime("ShowRedPackOnLaunch", "MainCtrl:onEnter")
    MainCtrl.super.onEnter(self)

    self:setForegroundCallback()
    self:_disposeOnEnterHallScene()

    MainView:refreshView(self._viewNode)
    if self.subManager.subRoomManager:getSecondLayer() == nil then
        MainView:runEnterAni(self._viewNode)
    end
    tcyFriendPluginWrapper:checkFriendNewMsg()
    self:freshNobilityPrivilege()
    self:palyLuckyCatAni()
    self:freshLuckyCat()
    --20200408改为每次进大厅就弹框
    WeakenScoreRoomModel:sendGetTriggerInfo()--查询积分场触发情况
    WeakenScoreRoomModel:sendGetBoutInfoForLottery() --查询玩家今天打的局数
    my.scheduleOnce(function()
        WeakenScoreRoomModel:onPlayerDepositChange() --登录时弹窗
    end, 2.0)

    -- 广告模块 start
    self:startAdvertStandingTimer()
    -- 广告模块 end

    self:freshYuleRoomBubble()

    -- 引导评论弹框
    local minBout = cc.exports.getGuideCommentsMinBout()    
    if cc.exports.isGuideCommentsSupported() and cc.exports.needShowGuideComments then
        if user.nBout and user.nBout >= minBout then
            local GuideCommentsCount = CacheModel:getCacheByKey("GuideCommentsCount")        
            if type(GuideCommentsCount) ~= "number" or (type(GuideCommentsCount) == "number" and toint(GuideCommentsCount) == 0) then
                my.scheduleOnce(function()
                    local tip = cc.exports.getGuideCommentsTip()
                    my.informPluginByName( {
                        pluginName = "SureDialog",
                        params =
                        {
                            tipContent  = tip,
                            closeBtVisible = true,
                            forbidKeyBack  = false
                        }
                    } )
                    CacheModel:saveInfoToCache("GuideCommentsCount", 1)
                end, 1)            
            end
        end        
    end

    -- 控制定时赛提示动画
    if self._viewNode then
        if cc.exports.isTimingGameSupported() and TimingGameModel:isMatchDay() and TimingGameModel:isInTimeMatchPeriod() then            
            local aniFile= "res/hallcocosstudio/mainpanel/mainpanel.csb"
            local action = cc.CSLoader:createTimeline(aniFile)
            if not tolua.isnull(action) then
                self._viewNode:stopAllActions()
                self._viewNode:runAction(action)
                action:play("tip_animation", true)
            end 
        else
            self._viewNode:stopAllActions()    
        end
    end

    local isOpenAct =  NewUserInviteGiftModel:isOpenNewUserPhoneAct()
    if isOpenAct then
        if self._newUserRedBag then
            self._newUserRedBag:normalAction()
        end
    end
end

function MainCtrl:onEnterTransitionDidFinish()
    local userPlugin = cc.exports.UserPlugin--require('src.app.GameHall.models.PluginEventHandler.UserPlugin'):getInstance()
    userPlugin:setLoginWithDialog(true)
    my.scheduleOnce(function()
        if self._readyToShowKickedOut then
            self:informPluginByName('OnUserKickedOutPlugin')
            self._readyToShowKickedOut = false
        elseif self._readyToShowTwoHallWarnning then
            self:showForbidTwoHallWarnning()
            self._readyToShowTwoHallWarnning = false
        else
            if self._params.centerCtrl:checkNetStatus() then
                --请求首充信息  刷新红点
                FirstRechargeModel:gc_GetFirstRechargeInfo()
            else
                if self._readyToShowSocketError then
                    self:showSocketError()
                end
            end
            self._readyToShowSocketError = false
        end
        if self._readyToShowCheckVersionFailed then
            self:showCheckVersionFaild()
            self._readyToShowCheckVersionFailed = false
        end
    end, 0.1)
    MainView:showRechargePoolBtnAni()
end

function MainCtrl:onUpdateRich()
    player:update({'SafeboxInfo','MemberInfo','UserGameInfo'})
    if user.nDeposit then
        local viewNode = self._viewNode
        if viewNode.userDepositTxt and user.nDeposit then
            viewNode.userDepositTxt:setMoney(user.nDeposit)
        end
        if viewNode.userScoreTxt and user.nScore then
            viewNode.userScoreTxt:setMoney(user.nScore)
        end

        MainView:refreshPanelTop(self._viewNode)

        -- if cc.exports.isReliefSupported() then
        --     relief:queryConfig()
        -- end

        MainView:refreshViewOnDepositChange(self._viewNode)
    end
end

function MainCtrl:onExit()
    MainCtrl.super.onExit(self)
    PluginProcessModel:stopPluginProcess()
    AppUtils:getInstance():removeResumeCallback("Hall_main_setForegroundCallback")

    -- 广告模块 start
    self:stopAdvertStandingTimer()
    -- 广告模块 end

    MainView:onExit()
end

function MainCtrl:onKeyBack()
    print("MainCtrl onkeyBack")

    if my.isLoading() then
        print("loading...")
        return
    end

    if cc.exports.inTickoff then
        cc.exports.inTickoff = false
        return
    end

    if self.subManager.subRoomManager:onKeyback() == true then
        return
    end

    self:onClickExit()
end

function MainCtrl:continuePwdWrong()
	my.scheduleOnce(function()
		my.informPluginByName({pluginName='TipPlugin',params={tipString=constStrings['HLS_CONTINUE_PWDWRONG']}})
    end,0.7)
end

function MainCtrl:loginOffUI()
    printf("MainCtrl loginOffUI")
    local viewNode = self._viewNode
    player:resetPlayerExtendFlag()
    viewNode.usernameTxt:setString(constStrings['player_username_not_logined'])
    --viewNode.userDepositTxt:setString('')
    --viewNode.userScoreTxt:setString('')
    --viewNode.roomCardText:setString('')

    viewNode.memberPic:setVisible(false)

    viewNode:hideSex()

    if viewNode.loginoffPanel then
       viewNode.loginoffPanel:setVisible(true)
    end

    HallContext:onLogoff()
    self.subManager.subRoomManager:onLogoff()
    MainView:onLogoff(self._viewNode)

    BankruptcyModel:onLogoff()
    GoldSilverModel:reset()
    GoldSilverModelCopy:reset()
    MainView:refreshBtnGoldSilverCountdown(self._viewNode, GoldSilverModel)
    MainView:refreshBtnGoldSilverCountdownCopy(self._viewNode, GoldSilverModelCopy)
end

function MainCtrl:onUserKickedOff()
    if self._alive then
        self:informPluginByName('OnUserKickedOutPlugin')
    else
        if my.isInGame() then
            GamePublicInterface:onNotifyKickedOffByLogonAgain()
        end
        self._readyToShowKickedOut = true
    end
end

function MainCtrl:onUserKickedOffByAdmin()
    if my.isInGame() then
        GamePublicInterface:onNotifyKickedOffByLogonAgain()
    end
end

function MainCtrl:onUserKickedOff_ForbidTwoHall()
    if self._alive then
        self:showForbidTwoHallWarnning()
    else
        if my.isInGame() then
            GamePublicInterface:onNotifyKickedOffByLogonAgain()
        end
        self._readyToShowTwoHallWarnning = true
    end
end

function MainCtrl:showForbidTwoHallWarnning()
    my.informPluginByName( {
        pluginName = "SureDialog",
        params =
        {
            tipContent  = constStrings['Forbid_TwoHall'],
            tipTitle    = nil,
            okBtTitle   = constStrings['Forbid_TwoHall_BT'],
            onOk        = handler(self._params.centerCtrl, self._params.centerCtrl.checkNetStatus),
            closeBtVisible = true,
            forbidKeyBack  = false
        }
    } )
end

function MainCtrl:setPlayerData(data)
    if(data.nUserID)then
        local viewNode=self._viewNode
        self:setPlayerName(data)        
        viewNode.userDepositTxt:setMoney(rawget(data, "nDeposit"))
        viewNode.userScoreTxt:setMoney(rawget(data, "nScore"))

        viewNode:setSex(user:getSexName() == "girl")
        MainView:refreshRoleAni(self._viewNode)

        MainView:refreshPanelTop(self._viewNode)
        MainCtrl:StartPush(data.nUserID)
        --viewNode.userIDText:setString(data.nUserID)

        -- if cc.exports.isReliefSupported() then
        --     --之所以用定时器，是因为前面有个注释：sdk回调时发送http请回可能会导致未知错误
        --     TimerManager:scheduleOnceUnique("Timer_MainCtrl_setPlayerData_queryConfig", function()
        --         relief:queryConfig()
        --     end, 0)
        -- end

        self.subManager.subRoomManager:onPlayerDataUpdated()
    end
end

function MainCtrl:setOnLoginSuccessEvent(data)
    print("MainCtrl:setOnLoginSuccessEvent")
    if data.nUserID and data.nUserID > 0 then
        print("onLogon, userId "..tostring(data.nUserID))
        NickNameInterface.resetUserDetailInfo()

        local viewNode=self._viewNode
        viewNode.girlHeadPic:setVisible(true)
        viewNode:setSex(user:getSexName() == "girl")
        self:setPlayerName(data)

        if viewNode.loginoffPanel then
           viewNode.loginoffPanel:setVisible(false)
        end
        
        local strangerManager = require("src.app.BaseModule.StrangerManager")
        strangerManager:Load()
        TimerManager:scheduleOnceUnique("Timer_DelayedGetPortraitInfo_OnLoginSuccess", function()
            player:getPortraitInfo() --延时一小段时间，再执行一次getPortraitInfo
        end, 0.5)

        CommonData:readUserData()
        HallContext:onLogon()
        self.subManager.subRoomManager:onLogon()
        MainView:onLogon(self._viewNode)
        self:_disposeOnLoginSuccess()

        local lastTime = socket.gettime()
        self.lastDay = math.floor((lastTime + 28800) / 86400)
        self:refreshTime()

        --玩家登录成功
        local matchType = cc.exports.getQuickStartMatchType()
        print("QuickStart matchType="..matchType)
        if AdditionConfigModel.ROOM_MATCH_TYPE_RANDOM == matchType then
            local cacheMatchType = CacheModel:getCacheByKey("QuickStartMatchType")
            if type(cacheMatchType) ~= "table" then --已经赋值过了
                return
            end

            local matchRandom = cc.exports.getQuickStartMatchRandom()
            math.randomseed(os.time())
            local randomValue = math.random(0, 100)
            print("QuickStart matchRandom="..matchRandom)
            print("QuickStart randomValue="..randomValue)
            if randomValue <= matchRandom then
                CacheModel:saveInfoToCache("QuickStartMatchType", 1)
            else
                CacheModel:saveInfoToCache("QuickStartMatchType", 2)
            end
        elseif 1 == matchType then
            --CacheModel:saveInfoToCache("QuickStartMatchType", 1)
        elseif 2 == matchType then
            --CacheModel:saveInfoToCache("QuickStartMatchType", 2)
        end        
    end
end

function MainCtrl:refreshTime()
    self.mainTimer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
        local curTime = socket.gettime()
        local overTime = curTime - ((self.lastDay + 1) * 86400 - 28800)
        if overTime > 120 then  -- 0点过后两分钟刷新一下
            RechargeFlopCardModel:reqStatus()           -- 重新请求一次
            self.tempTimer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
                MainView:refreshLeftBar(self._viewNode)
                self.lastDay = math.floor((curTime + 28800) / 86400)
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.tempTimer)
            end, 3.0, false)           -- 3秒后刷新
        end
    end, 60.0, false)           -- 一分钟刷一次
end

function MainCtrl:setFeedbackState(data)
    print("MainCtrl:setFeedbackState")
    print(data and data.message or "nil")

    local isNeedReddot = false
    if data and data.is_success then
       isNeedReddot = (data.data == feedback.NEW_REPLY)
    end
    MainView:refreshPluginBtnReddotDirectly("help", isNeedReddot)
end

function MainCtrl:setReliefState(data)
    if not cc.exports.isReliefSupported() then return end

    local state = data.state
    if(not state)then
        return
    end

    --提取出来，别处也需要调用
    self:freshExchangeBubble()
end

function MainCtrl:onTakeReliefFailed(data)
    local key = data['value']['status']
    local ss = constReliefStrings[tostring(key)]
    self:informPluginByName('TipPlugin',{tipString=ss})
end

function MainCtrl:onTakeReliefSuccess(data)
    local ss = constReliefStrings['0']
    self:informPluginByName('TipPlugin',{tipString=ss,removeTime=1})
end

function MainCtrl:setCheckinConfig(config)
    if not (config and config.dataList and config.code) then
        return
    end

    if config.code == checkin.Status.SUCCESS and config.dataList[config.todayIndex].statu == checkin.NOT_CHECK_TODAY then
        PluginTrailMonitor:pushPluginIntoTrail({pluginName = "CheckinCtrl"}, PluginTrailOrder.kCheckInDialog)
        self:setCheckInStatus(true)
    else
        self:setCheckInStatus(false)
    end

end

function MainCtrl:StartPush(userId)
    local pushPlugin = plugin.AgentManager:getInstance():getPushPlugin()
    if(pushPlugin == nil)then
        print("~~~~~~~~~~~~pushPlugin is nil~~~~~~~~~~~~~")
        return
    end
    pushPlugin:setCallback(function(code, msg)
        printInfo("%d",code)
        printInfo("%s",msg)
    end)
    local param = nil
    if( BusinessUtils:getInstance():isGameDebugMode() ) then
        param = require("src.app.HallConfig.PushConfig")["Debug"]
    else
        param = require("src.app.HallConfig.PushConfig")["Formal"]
    end

    pushPlugin:configDeveloperInfo(param)
    pushPlugin:setAlias(userId)
    pushPlugin:startPush()
end

function MainCtrl:onPlayLoginOff()
    self:loginOffUI()
    GamePublicInterface:OnInGameHallSocketError()
end

function MainCtrl:_registNetProcessEvents()
    local netProcess = require('src.app.BaseModule.NetProcess'):getInstance()
    netProcess:addEventListener(netProcess.EventEnum.LoginFinished,      handler(self, self._onLoginFinished))
    netProcess:addEventListener(netProcess.EventEnum.SoketError,         handler(self, self._onSocketError))
    netProcess:addEventListener(netProcess.EventEnum.CheckVersionFailed, handler(self, self._onCheckVersionFailed))
end

function MainCtrl:_onLoginFinished()
    self._readyToShowSocketError = false
end

function MainCtrl:loadPortrait()
    if cc.exports.isSocialSupported() then
        local imageCtrl = require('src.app.BaseModule.ImageCtrl')
        local viewNode = self._viewNode
        if viewNode then viewNode:setSex(user:getSexName() == "girl") end
        local userModel = mymodel('UserModel'):getInstance()

        local portraitStatus = userModel:getPortraitStatus()
        viewNode.imgIconVerify:setVisible(portraitStatus == PortraitStatus.DENIED)

        local portraitPath = userModel:getPortraitPath()
        print("MainCtrl:loadPortrait")
        print(portraitPath)
        if type(portraitPath) == "string" and portraitPath ~= "" then
            viewNode:unableSetSex()
            viewNode.girlHeadPic:loadTexture(portraitPath)
        else
            viewNode:enableSetSex()
            viewNode:setSex(user:getSexName() == "girl")
        end
    end
end

function MainCtrl:_startMemorySuperviser()
    local memoryInfo = self:_getCurrentMemoryInfoStr()
    local label = cc.LabelTTF:create(memoryInfo, "Arial", 32)
    label:setAnchorPoint(0, 0)
    label:setPosition(50, 50)
    label:setLocalZOrder(1000)
    label:addTo(self._viewNode:getRealNode())
    my.scheduleFunc(function()
        local memoryInfo = self:_getCurrentMemoryInfoStr()
        label:setString(memoryInfo)
    end, 5)
end

function MainCtrl:_getCurrentMemoryInfoStr()
    local memoryInfo = DeviceUtils:getInstance():getRuntimeMemoryInfo()
    local str = string.format(' availbytes:%s\n totalbytes:%s\n threshold:%s\n lowMemory:%s\n luaMemory:%s',
        tostring(memoryInfo.availbytes), tostring(memoryInfo.totalbytes),
        tostring(memoryInfo.threshold), tostring(memoryInfo.lowMemory),
        tostring(collectgarbage('count')))
    return str
end

function MainCtrl:_onSocketError()
    if self._alive then
        self:showSocketError()
    else
        self._readyToShowSocketError = true
    end
end

function MainCtrl:_onCheckVersionFailed()
    if self._alive then
        self:showCheckVersionFaild()
    else
        self._readyToShowCheckVersionFailed = true
    end
end

function MainCtrl:showSocketError()
    local msg = cc.load('json').loader.loadFile('NetworkError')["network_invalid"]
    my.informPluginByName({pluginName = 'TipPlugin', params = {tipString = msg, removeTime = 3}})

    MainView:refreshPluginBtnAvailDirectly(self._viewNode, 'monthCardPack', false)
    MainView:refreshPluginBtnAvailDirectly(self._viewNode, 'monthCardPack_LeftBar', false)
end

function MainCtrl:showCheckVersionFaild()
    local msg = cc.load('json').loader.loadFile('NetworkError')["CHECK_VERSION_FAILED"]
    my.informPluginByName({pluginName='SureTipPlugin', params={tipContent = msg}})
end

function MainCtrl:removeInstance(...)
    local userPlugin = require('src.app.GameHall.models.PluginEventHandler.UserPlugin'):getInstance()
    userPlugin:removeCallbackEventByTag(UserActionResultCode.kModifyNicknameSucceed, self.__cname)

    MainCtrl.super.removeInstance(self, ...)
end

function MainCtrl:onNickNameChanged()
    self:setPlayerData(user)
end

function MainCtrl:onAdditionConfigUpdated()
    print("onAdditionConfigUpdated")

    self:setSpringFestivalCache()
    
    MainView:refreshView(self._viewNode) --获取到AdditionConfig再刷新一遍界面
    self:InitExchangeTelephoneLable()    --获取到新配置再刷新一次

    if not TimingGameModel:getInfoDataStamp() then
        TimingGameModel:reqTimingGameConfig() --查询定时赛配置
        TimingGameModel:reqTimingGameInfoData() --查询定时赛状态
    end
end

function MainCtrl:setPlayerName(data)
    local viewNode = self._viewNode
    
    local nickName = NickNameInterface.getNickName()
    local userName = nickName or data.szUtf8Username
    my.fitStringInWidget(userName, viewNode.usernameTxt, USERNAMEMAXWIDTH)
end

function MainCtrl:_setEmailStatus()
    MainView:refreshMailBtnReddot(self._viewNode, EmailModel:getNoticeMailCount())
end

function MainCtrl:setBatteryInfoCallBack()
    if self:_checkBatteryAvail() == false then return end

    DeviceUtils:getInstance():setGameBatteryInfoCallback(function(batteryInfo)        
        local viewNode = self._viewNode
        if not viewNode.panelBattery then return end
        if not batteryInfo or not batteryInfo.batteryLevel then
            viewNode.panelBattery:setVisible(false)
        else
            viewNode.panelBattery:setVisible(true)
            viewNode.batteryBar:setPercent(batteryInfo.batteryLevel)
        end 
    end) 
end

--安卓4.5.6大厅无法兼容电量显示，第二次启动游戏会导致tcyapp大厅崩溃
function MainCtrl:_checkBatteryAvail()
    if device.platform == 'android' then
        if my.isEngineSupportVersion("v1.3.20170516") then
            return true
        end
    end

    return false
end

function MainCtrl:onPortraitUpdated()
    self:loadPortrait()
end

function MainCtrl:onHardIDMisMatch()
    my.informPluginByName( {
        pluginName = "SureDialog",
        params =
        {
            tipContent  = "您的账号绑定了设备，无法登录，是否前往解绑",
            tipTitle    = nil,
            okBtTitle   = "解绑",
            onOk        = function ()
                DeviceUtils:getInstance():openBrowser("https://user.tcy365.com/login.html?gourl=http%3a%2f%2fuser.tcy365.com%2faccount_unbind.aspx") 
            end,
            closeBtVisible = true,
            forbidKeyBack  = false
        }
    } )
end

function MainCtrl:OnGetItemInfo(nRoomID, lackDeposit)
    print("MainCtrl:OnGetItemInfo")
    local roomImpl = RoomListModel.roomsInfo[nRoomID]
    if roomImpl == nil then
        print("roomImpl not found")
        return
    end

    local MyGamePromptRecharge = import("src.app.Game.mMyGame.MyGamePromptRecharge")
    local prompt = nil

    local bShowBankruptcyBag = BankruptcyModel:isBankruptcyBagShow()
    if bShowBankruptcyBag then
        my.informPluginByName({pluginName = 'BankruptcyCtrl', params = { enterRoomFailedInfo = {
            nRoomID = nRoomID, lackDeposit = lackDeposit } } })
    else
        if FirstRechargeModel:isInGameAlive() then
            my.informPluginByName({pluginName='FirstRecharge'})
            return
        end
        if cc.exports.isDailyRechargeSupported() and DailyRechargeModel:isDailyRechargeShow() then
            my.informPluginByName({pluginName='ActivityCenterCtrl',params = { moudleName='dailyrecharge',
                    enterRoomFailedInfo = { mainCtrl = self, roomId = nRoomID, lackDeposit = lackDeposit}
                }})
        else
            self:tryShowRoomQuickRechargeView(nRoomID, lackDeposit)
        end
    end
end

function MainCtrl:tryShowRoomQuickRechargeView(roomId, lackDeposit)
    local roomImpl = RoomListModel.roomsInfo[roomId]
    if roomImpl == nil then
        print("roomImpl not found")
        return
    end
    if type(lackDeposit) ~= 'number' then
        return 
    end
    -- 显示快速充值时,玩家可能在每日充值中充值了银两,此时玩家可能已经满足进入房间的条件
    if user.nDeposit and roomImpl.nMinDeposit and user.nDeposit >= roomImpl.nMinDeposit then
        return
    end
    --
    local configedShopExchangeId = RoomListModel:getConfigedRechargeData(roomId)
    local RechargeData = ShopModel:getQuickChargeItemDataByExchangeId(configedShopExchangeId, lackDeposit)
    if not (RechargeData and RechargeData.itemData) then
        print("[ERROR] get the data for room-quick-recharge failed, try to get it by another way...")
        RechargeData = ShopModel:getQuickChargeItemDataForRoom(roomImpl.nMinDeposit, lackDeposit)
    end
    if not (RechargeData and RechargeData.itemData) then
        return
    end
    local MyGamePromptRecharge = import("src.app.Game.mMyGame.MyGamePromptRecharge")
    local prompt = MyGamePromptRecharge:create(self, RechargeData["itemData"]["First_Support"] == 1, RechargeData, true, false, nil, roomImpl)
    if prompt then
        if  cc.exports.GamePublicInterface and cc.exports.GamePublicInterface._gameController then
            cc.exports.GamePublicInterface._gameController._baseGameScene:addChild(prompt, 1910)
        else
            prompt:setName("Node_GuideTipOfDepositUnSatisfied_OnEnterRoom")
            --self._viewNode:addChild(prompt, 100)
            -- 不在主界面触发的时候，会被其他弹窗遮挡，比如活动界面里触发进房间
            local curScene = cc.Director:getInstance():getRunningScene()
            curScene:addChild(prompt, 100)
        end
        prompt:setPosition(display.center)
    end
end

function MainCtrl:onClickExit()
    my.playClickBtnSound()
	if not UIHelper:checkOpeCycle("hall_opeExit") then return end
	UIHelper:refreshOpeBegin("hall_opeExit")

	my.dataLink(cc.exports.DataLinkCodeDef.HALL_MAIN_QUIT_MB)
	local targetPlatform = cc.Application:getInstance():getTargetPlatform()
	if cc.PLATFORM_OS_WINDOWS == targetPlatform then
        self._params.centerCtrl:showExitTipPlugin()
	else
		if cc.exports.UserPlugin then
			cc.exports.UserPlugin:exit()
		else
			self._params.centerCtrl:showExitTipPlugin()
		end
	end
end

function MainCtrl:doAfterMemberInfoUpdate()
    TaskModel:SendTaskDataReq(TaskModel.TaskDef.REQ_TYPE_ALL, 0)
    LoginLotteryModel:sendLotteryCountReq()
end

function MainCtrl:_disposeOnEnterHallScene()
    if HallContext:isLogoff() == false then
        my.scheduleOnce(function()  self:_tryAutoTakeRelief() end)

        if user.nUserID and user.nUserID < 0 then
            LoginLotteryModel:sendLotteryCountReq()   --抽奖红点问题 如果在游戏场对局5局,大厅收不到消息，每次查一下
        end
    end
end

--之所以用定时器，是因为前面有个注释：sdk回调时发送http请回可能会导致未知错误
function MainCtrl:_disposeOnLoginSuccess()
    UIHelper:recordRuntime("ShowRedPackOnLaunch", "MainCtrl:_disposeOnLoginSuccess()")

    self:startPluginProcess()

    cc.exports.hasLogined = true
    cc.exports.isGameNewPlayer = false
    feedback:queryState()
    tcyFriendPluginWrapper:checkFriendNewMsg()
    print("_disposeOnLoginSuccess...")
    MyTimeStampCtrl:startTimerSchedule()    -- 登陆成功定时获取服务器时间戳
    if cc.exports.isActivityCenterSupported() then
        local nCurUserBout = user.nBout
        local activityCenterModel = import('src.app.plugins.activitycenter.ActivityCenterModel'):getInstance()
        -- 切换账号的时候，可能遇到user.nBout不及时更新，所以这里定时检测nBout，然后再发送
        TimerManager:waitUntil("Timer_DisposeOnLoginSuccess_ByActivityMatrixInfo", 
            function() return user.nBout ~= nCurUserBout end, function()
                print("_disposeOnLoginSuccess will getActivityMaxtrixInfo", user.nBout, nCurUserBout)
                activityCenterModel:getActivityMaxtrixInfo()
        end, 0.3, 5, function() activityCenterModel:getActivityMaxtrixInfo() end)
    end

	MainView:refreshView(self._viewNode)
    MainView:showPacketSetAni()
    
    --自动领取低保奖励
    -- TimerManager:scheduleOnceUnique("Timer_MainCtrl_disposeOnLoginSuccess", function()
    --     relief:queryUserState()
    --     my.scheduleOnce(function() self:_tryAutoTakeRelief() end, 1.5)
    -- end, 0)

    local NewUserRewardModel = import('src.app.plugins.NewUserReward.NewUserRewardModel'):getInstance()
    NewUserRewardModel:queryRewaredState()

    BankruptcyModel:reqBankruptcyStatus()   --查询破产礼包状态

    RechargeActivityModel:rechargeInfoReq() --查询充值有礼

    WeekCardModel:gc_GetWeekCardInfo()      --查询周卡状态

    TimingGameModel:reqTimingGameConfig()   --查询定时赛配置
    TimingGameModel:reqTimingGameInfoData() --查询定时赛状态

    ContinueRechargeModel:reqConfigAndData() --查询连充配置状态

    LuckyPackModel:loginUserChange()                --登陆用户改变
    LuckyPackModel:reqLuckyPackConfig()             --查询幸运礼包配置
    LuckyPackModel:reqLuckyPackState()              --查询幸运礼包购买状态
    LuckyPackModel:reqLuckyPackFLInfoAndSLState()   --查询幸运礼包今日首次抽奖信息和今日特殊抽奖状态
    LuckyPackModel:reqLuckyPackLBStateAndLBInfo()   --查询幸运礼包今日最后购买状态和今日最后购买信息
    
    RechargeFlopCardModel:loginUserChange()         --登陆用户改变
    
    WeekMonthSuperCardModel:QueryWeekMonthSuperCardConfig()             --查询周月至尊卡配置
    WeekMonthSuperCardModel:QueryWeekMonthSuperCardInfo()               --查询周月至尊卡信息
    WeekMonthSuperCardModel:SaveWeekMonthSuperUserChannelID()           --保存周月至尊卡玩家渠道号

    VivoPrivilegeStartUpModel:reqVivoPrivilegeStartUpConfig()           --查询Vivo特权活动配置
    VivoPrivilegeStartUpModel:reqVivoPrivilegeStartUpStateInfo()        --查询Vivo特权活动领奖状态

    GratitudeRepayModel:reqGratitudeRepayConfig()                       --查询感恩大回馈配置

    TimerManager:waitUntil("Timer_DisposeOnLoginSuccess_ByPlayerBoutInfo", 
        function() return user.nBout ~= nil end, function()
        SafeboxModel:querySafeboxInfo()
        self:_disposeNewPlayerOnLoginSuccess() --新手处理
        self:_disposeNonNewPlayerOnLoginSuccess() --非新手处理
    end, 0.3, 6)

    TimerManager:scheduleOnceUnique("Timer_MainCtrl_DelayedAssistRequestOnLoginSuccess", function()
        UserLevelModel:sendGetUserLevelReqForMySelf()
		ArenaModel:sendGetArenaRankRewardList()
		ArenaModel:sendGetArenaRankMatchConfig()--13期
    end, 0.3)
    
    NewPlayerGiftModel:reset()
    NewPlayerGiftModel:newPlayerGiftInfoReq() --查询是否有新手礼包

    ExchangeCenterModel:getTicketNum()

    AssistCommon:sendNoticyAssitSvrUserId() --发自己的ID过去
    AssistCommon:sendNoticyAssitSvrUserIdEX()
    AssistCommon:onGetNoShuffleInfo() --不洗牌

    --等待获取到GameJsonConfig这份配置才执行相关处理
    local checkFuncOfGotGameJsonConfig = function()
        if cc.exports._gameJsonConfig then
            if cc.exports._gameJsonConfig.roomBaseDeposit ~= nil then
                return true
            end
        end
        return false
    end
    TimerManager:waitUntil("Timer_DisposeOnLoginSuccess_ByGameJsonConfig", checkFuncOfGotGameJsonConfig, function()
        print("Timer_DisposeOnLoginSuccess_ByGameJsonConfig")
        print(cc.exports.isOutlayGameSupported(true))
        print(cc.exports.isLegendComeSupported(true))
        MainView:refreshLeftBar(self._viewNode) --刷新联运游戏-传奇来了是否可见
    end, 0.5, 6)

    --要在大转盘之前先获取贵族数据
    NobilityPrivilegeModel:gc_NobilityPrivilegePlayerLogin()  --登录信息给广播使用
    NobilityPrivilegeModel:gc_GetNobilityPrivilegeInfo()
    NobilityPrivilegeGiftModel:gc_GetNobilityPrivilegeGiftInfo()

    --招财猫信息获取
    LuckyCatModel:gc_GetLuckyCatInfo()

    LoginLotteryModel:checkInfo()
    CardRecorderModel:sendGetCardMakerInfo() --查询记牌器信息
    if cc.exports.isMonthCardSupported() then
        my.scheduleOnce(function()
            monthcard:createConnect()
            monthcard:StartGetMCardRechargeconfig()
        end , 0.8)  -- 为了保证月卡在 日常任务后面弹出
    end

    ExchangeLotteryModel:reset()
    GoldSilverModel:GoldSilverInfoReq()
    GoldSilverModelCopy:GoldSilverInfoReq()

    --请求首充信息
    FirstRechargeModel:gc_GetFirstRechargeInfo()
    --请求限时特惠信息
    FirstRechargeModel:gc_GetSpecialGiftInfo()
    
    -- 超值连购
    ValuablePurchaseModel:queryInfo()

    Team2V2Model:reqTeam2V2ModelConfig()
    Team2V2Model:reqQueryTeam()

    -- 巅峰榜
    PeakRankModel:reqPeakRankConfig()
end

function MainCtrl:_disposeNewPlayerOnLoginSuccess()
    if user.nBout and user.nBout == 0 then
        print("new player")
                
        if launchParamsManager:isInvitedToTeam2V2() and RoomListModel:checkAreaEntryAvail('team2V2') then
            PluginProcessModel:stopPluginProcess()
            local inviteContent = launchParamsManager:getContent()
            Team2V2Model:receiveInvite(inviteContent)
        end

        PluginProcessModel:resetPluginList()
        PluginProcessModel:resetNeedStart()
        if PluginProcessModel:isNeedStart() then
            -- PluginProcessModel:setPluginReadyStatus("NewUserRewardPlugin",true)
            PluginProcessModel:startPluginProcess()

            if cc.exports._newPlayerExchangeVoucherNum == nil then
                cc.exports._newPlayerExchangeVoucherNum = 0
            end
            ExchangeCenterModel:addTicketNum(cc.exports._newPlayerExchangeVoucherNum)
            AssistCommon:sendQueryExchangeVoucherReq(1, 0)  --发送获取新手兑换券
        else
            if self._pluginProcessTimer then
                my.removeSchedule(self._pluginProcessTimer)
                self._pluginProcessTimer = nil
            end
            self:showPanelSwallow(false)
        end
        cc.exports.isGameNewPlayer = true
    end
end

function MainCtrl:_disposeNonNewPlayerOnLoginSuccess()
    if user.nBout and user.nBout > 0 then 
        PluginProcessModel:resetPluginList()
        PluginProcessModel:resetNeedStart()

        if launchParamsManager:isInvitedToTeam2V2() and RoomListModel:checkAreaEntryAvail('team2V2') then
            PluginProcessModel:stopPluginProcess()
            local inviteContent = launchParamsManager:getContent()
            Team2V2Model:receiveInvite(inviteContent)
        end

        if PluginProcessModel:isNeedStart() then
            PluginProcessModel:startPluginProcess()
        else
            if self._pluginProcessTimer then
                my.removeSchedule(self._pluginProcessTimer)
                self._pluginProcessTimer = nil
            end
            self:showPanelSwallow(false)
        end
    end
end

function MainCtrl:_tryAutoTakeRelief()
    if player.bNeedRelief and cc.exports.gameReliefData then
        if relief.state ~= 'SATISFIED' then
            return
        end

        local limit = cc.exports.gameReliefData.config.Limit
        local timesLeft = cc.exports.gameReliefData.state.Count
        --展示界面

        local dailyLimitNum = cc.exports.gameReliefData.config.Limit.DailyLimitNum
        --贵族使用缓存,领过了就别领了
        local user = mymodel('UserModel'):getInstance()
        local NobilityPrivilegeModel      = import("src.app.plugins.NobilityPrivilege.NobilityPrivilegeModel"):getInstance()
        local status,reliefCount = NobilityPrivilegeModel:TakeNobilityPrivilegeReliefInfo()
        local reliefUsedCount = tonumber(CacheModel:getCacheByKey("NobilityPrivilegeRelief"..user.nUserID..os.date('%Y%m%d',os.time())))
        if not reliefUsedCount then reliefUsedCount = 0 end
        if reliefUsedCount and reliefUsedCount >= reliefCount then   --当天升级使用低保超过了缓存，则返回
            return
        end        

        my.informPluginByName({pluginName='ReliefCtrl',params={fromSence = ReliefDef.FROM_SCENE_MAINCTRL, promptParentNode = self._viewNode, leftTime = timesLeft, limit = limit}})
    end
end

function MainCtrl:_setRefreshHandlerOfPluginBtn()
    self._refreshHandlerOfPluginBtn = {
        ["shopModel_firstRechargeAvailChanged"] = function() MainView:refreshRechargeBtn() end,
        ["ExchangeCenterModel_rewardAvailChanged"] = function() 
            MainView:refreshPluginBtnReddotByModel("exchange", ExchangeCenterModel) 
        end,
        ["taskModel_rewardAvailChanged"] = function() MainView:refreshPluginBtnReddotByModel("task", TaskModel) end,
        ["loginLotteryModel_rewardAvailChanged"] = function() 
            MainView:refreshPluginBtnReddotByModel("lottery", LoginLotteryModel)
        end,
        ["goldSilver_rewardAvailChanged"] = function() 
            self:updateGoldSilverBtn()
        end,
        ["goldSilver_rewardAvailChangedCopy"] = function() 
            self:updateGoldSilverBtnCopy()
        end,
        -- ["monthCard_rewardAvailChanged"] = function()
        --     MainView:refreshPluginBtnReddotByModel("monthCardPack", MonthCardModel)
        --     MainView:refreshPluginBtnAvail(self._viewNode, "monthCardPack", MonthCardModel)
        -- end,
        ["weekCard_rewardAvailChanged"] = function()
            MainView:refreshPluginBtnReddotByModel("monthCardPack", WeekCardModel)
            MainView:refreshPluginBtnAvail(self._viewNode, "monthCardPack", WeekCardModel)

            MainView:refreshPluginBtnReddotByModel("monthCardPack_LeftBar", WeekCardModel)
            if not MainView._pluginViewData["packSet"]["isAvail"] then
                MainView:refreshPluginBtnAvail(self._viewNode, "monthCardPack_LeftBar", WeekCardModel)
            end
        end,
        ["newPlayerGiftModel_rewardAvailChanged"] = function()
            MainView:refreshPluginBtnReddotByModel("loginPack", NewPlayerGiftModel)
            MainView:refreshPluginBtnAvail(self._viewNode, "loginPack", NewPlayerGiftModel)

            MainView:refreshPluginBtnReddotByModel("loginPack_LeftBar", NewPlayerGiftModel)
            if not MainView._pluginViewData["packSet"]["isAvail"] then
                MainView:refreshPluginBtnAvail(self._viewNode, "loginPack_LeftBar", NewPlayerGiftModel)
            end
        end,
        ["rechargeAct_rewardAvailChanged"] = function()
            MainView:refreshPluginBtnReddotByModel("rechargeAct", RechargeActivityModel)
            MainView:refreshPluginBtnAvail(self._viewNode, "rechargeAct", RechargeActivityModel)
        end,
        ["topRank_pluginAvailChanged"] = function()
            MainView:refreshPluginBtnAvail(self._viewNode, "topRank", NationalDayActivityModel)
            local isNeedReddot = true
            local lastNoticeTime = CommonData:getUserData("topRank_lastNoticeTime")
            if lastNoticeTime and DateUtil:isTodayTime(lastNoticeTime) then
                isNeedReddot = false
            end
            MainView:refreshPluginBtnReddotDirectly("topRank", isNeedReddot)
        end,
        ["activity_newContentAvail"] = function() 
            MainView:refreshPluginBtnReddotByModel("activity", ActivityCenterModel)
        end,
        ["NobilityPrivilegeGiftModel_NobilityPrivilegeGiftAvailChanged"] = function() MainView:refreshNobilityPrivilegeGiftBtn() end,
    }
end

function MainCtrl:refreshViewByRefreshHandler()
    for _, handler in pairs(self._refreshHandlerOfPluginBtn) do
        if handler then handler() end
    end
end

function MainCtrl:onModuleStatusChanged(data)
    local eventData = data.value
    local moduleName = eventData["moduleName"]
    local eventName = eventData["eventName"]
    local dataModel = eventData["dataModel"]

    local refreshHandler = {
        
    }
    
    if refreshHandler[eventName] then
        refreshHandler[eventName]()
    elseif self._refreshHandlerOfPluginBtn[eventName] then
        self._refreshHandlerOfPluginBtn[eventName]()
    end
end

--切后台回来
function MainCtrl:setForegroundCallback()
    local callback = function()
        -- 由于切后台所有定时器都不动了，所以切后台回来需要重新请求下服务器时间戳
        MyTimeStampCtrl:onStampResume()
        -- vivo特权启动活动
        if cc.exports.isVivoVipActivitySupported() and cc.exports.autoPopVivoPrivilegeStartUp then
            cc.exports.autoPopVivoPrivilegeStartUp = false
            if BusinessUtils:getInstance().getLaunchParamInfo then
                local json = cc.load("json").json
                local lauchParam = BusinessUtils:getInstance():getLaunchParamInfo()
                if lauchParam and lauchParam.extra and lauchParam.extra ~= "" then
                    local extra = json.decode(lauchParam.extra) or {}
                    if extra["fromPackage"] and extra["fromPackage"] == "com.vivo.game" then
                        my.informPluginByName({ pluginName = 'VivoPrivilegeStartUpCtrl' })
                    end
                end
            end
        end
    end
    AppUtils:getInstance():removeResumeCallback("Hall_main_setForegroundCallback")
    AppUtils:getInstance():addResumeCallback(callback, "Hall_main_setForegroundCallback")
end

function MainCtrl:onBackFromGame()
    self.subManager.subRoomManager:onBackFromGame()

    local newUserGuideBoutCount = cc.exports.getNewUserGuideBoutCount()
    if user.nBout == newUserGuideBoutCount then
        NewInviteGiftModel:reqBindInfo()
    end

    if user.nUserID and user.nUserID > 0 then
        UserLevelModel:sendGetUserLevelReqForMySelf() --添加获取等级
    end

    OldUserInviteGiftModel:canGetAwardPop()
    
    if OldUserInviteGiftModel:isEnable() then
        OldUserInviteGiftModel:sendInviteGiftData()
        self:updateRedPacketIcon()
    end
    --回到大厅请求新玩家话费券数据
    local isOpenAct =  NewUserInviteGiftModel:isOpenNewUserPhoneAct()
    if isOpenAct then
        if self._newUserRedBag then
            self._newUserRedBag:normalAction()
            self._newUserRedBag:onEnter()
        end
        NewUserInviteGiftModel:reqNewUserGetAwarddata()
    end

    my.scheduleOnce(function()
        PluginProcessModel:continuePluginProcess()  
    end, 1)
end

function MainCtrl:onBackFromNonSceneFullScreenCtrl()
    if not my.isInGame() then
        MainView:runEnterAni(self._viewNode)
    end
end

function MainCtrl:InitGoldSilver()
    local GoldSilverDef = import('src.app.plugins.goldsilver.GoldSilverDef')
    local function OnGoldSilverInfoRet()
        MainView:refreshBtnGoldSilverCountdown(self._viewNode, GoldSilverModel)
    end
    local function updateMonth()
        GoldSilverModel:GoldSilverInfoReq()
        MainView:refreshBtnGoldSilverCountdown(self._viewNode, GoldSilverModel)
    end
    self:listenTo(GoldSilverModel, GoldSilverDef.GoldSilverInfoReceived,  OnGoldSilverInfoRet)
    self:listenTo(MyTimeStampCtrl, MyTimeStampCtrl.UPDATE_MONTH,  updateMonth)
end

function MainCtrl:InitGoldSilverCopy()
    local GoldSilverDefCopy = import('src.app.plugins.goldsilverCopy.GoldSilverDefCopy')
    local function OnGoldSilverInfoRet()
        MainView:refreshBtnGoldSilverCountdownCopy(self._viewNode, GoldSilverModelCopy)
    end
    local function updateMonth()
        GoldSilverModelCopy:GoldSilverInfoReq()
        MainView:refreshBtnGoldSilverCountdownCopy(self._viewNode, GoldSilverModelCopy)
    end

    local function updateDay()
        GoldSilverModelCopy:GoldSilverInfoReq()
    end

    self:listenTo(GoldSilverModelCopy, GoldSilverDefCopy.GoldSilverInfoReceivedCopy,  OnGoldSilverInfoRet)
    self:listenTo(MyTimeStampCtrl, MyTimeStampCtrl.UPDATE_MONTH,  updateMonth)
    self:listenTo(MyTimeStampCtrl, MyTimeStampCtrl.UPDATE_DAY,  updateDay)
end

function MainCtrl:onBankruptcyTimeUpdate()
    MainView:refreshBankruptcyTime(self._viewNode, BankruptcyModel)
end

function MainCtrl:onRefreshBankruptcy()
    MainView:refreshBankruptcy(self._viewNode, BankruptcyModel)
end

function MainCtrl:showPanelSwallow(bShow)
    self._viewNode.Panel_Swallow:setVisible(bShow)
end

function MainCtrl:startPluginProcess()
    PluginProcessModel:reset()
    --PluginProcessModel:resetPluginList()
    --PluginProcessModel:resetNeedStart()
    self:showPanelSwallow(true)
    --过三秒就当作已经完成了

    if self._pluginProcessTimer then
        my.removeSchedule(self._pluginProcessTimer)
        self._pluginProcessTimer = nil
    end

    self._pluginProcessTimer = my.createOnceSchedule(function()
        if self then
            if PluginProcessModel:isNeedStart() then
                PluginProcessModel:startPluginProcessWhileTimeOut()
            end
            self:showPanelSwallow(false)
        end
    end, 5)
end


function MainCtrl:onPluginProcessFinished()
    self:showPanelSwallow(false)
    -- 所有窗口弹结束，更新缓存里的logindate
    local myGameData = PluginProcessModel:getMyGameDataXml(user.nUserID)
    local date = PluginProcessModel:getTodayDate()
    if date ~= myGameData.logindate then
        myGameData.logindate = date
        PluginProcessModel:saveMyGameDataXml(myGameData, user.nUserID)
    end
end

function MainCtrl:getGameStringToUTF8ByKey(stringKey)
    local content = ""
    if GamePublicInterface then
        content =  GamePublicInterface:getGameString(stringKey)
    end
    local utf8Content = MCCharset:getInstance():gb2Utf8String(content, string.len(content))
    return utf8Content
end

function MainCtrl:updateGoldSilverBtn( )
    local info = GoldSilverModel:GetGoldSilverInfo()
    if not info then return end
    MainView:refreshPluginBtnReddotByModel("goldSilver", GoldSilverModel) 

    local viewNode = self._viewNode
    local panelBubble = viewNode.panelLeftBar:getChildByName("Btn_GoldSilver"):getChildByName("Panel_Bubble")
    local bShow, tipString = GoldSilverModel:getHallTipConfig()
    if bShow and tipString then
        local txt = panelBubble:getChildByName("Text_Tip1")
        if txt then
            txt:setString(tipString)
        end
        panelBubble:setVisible(true)
    else
        panelBubble:setVisible(false)
    end
end

function MainCtrl:updateGoldSilverBtnCopy( )
    local info = GoldSilverModelCopy:GetGoldSilverInfo()
    if not info then return end
    MainView:refreshPluginBtnReddotByModel("goldSilverCopy", GoldSilverModelCopy) 

    local viewNode = self._viewNode
    local panelBubble = viewNode.panelLeftBar:getChildByName("Btn_GoldSilverCopy"):getChildByName("Panel_Bubble")
    local bShow, tipString = GoldSilverModelCopy:getHallTipConfig()
    if bShow and tipString then
        local txt = panelBubble:getChildByName("Text_Tip1")
        if txt then
            txt:setString(tipString)
        end
        panelBubble:setVisible(true)
    else
        panelBubble:setVisible(false)
    end
end

function MainCtrl:InitExchangeTelephoneLable()
    local viewNode = self._viewNode
    local imgTelephoneLabel = viewNode.panelBottomBar:getChildByName("Btn_Exchange"):getChildByName("Img_TelephoneLabel")
    if not imgTelephoneLabel then return end
    imgTelephoneLabel:setVisible(false)
    if cc.exports.isExchangeTelephoneLabelSupported() then
        imgTelephoneLabel:setVisible(true)
    end
end

-- 初始化邀请有礼相关
function MainCtrl:initInviteGift()
    self:listenTo(NewInviteGiftModel, NewInviteGiftModel.EVENT_INVITE_GIFT_PROCESS_OVER, handler(self, self.inviteGiftProcessOver))
    self:listenTo(OldUserInviteGiftModel, OldUserInviteGiftModel.EVENT_UPDATE_PACKET_ICON, handler(self, self.updateRedPacketIcon))
    self:listenTo(OldUserInviteGiftModel, OldUserInviteGiftModel.EVENT_UPDATE_GIFT_ICON, handler(self, self.updateInviteGiftIcon))
    self:listenTo(NewUserInviteGiftModel, NewUserInviteGiftModel.EVENT_UPDATE_TICKET_ICON, handler(self, self.updateTicketIcon))
    self:listenTo(OldUserInviteGiftModel, OldUserInviteGiftModel.EVENT_YQYL_RED_DOT, handler(self, self.showYqylRedDot))
    self._viewNode.redPacketNode:setVisible(false)
    self._viewNode.redPacketDot:setVisible(false)
    self._viewNode.yqylNode:setVisible(false)
    self._viewNode.redbagPanel:setVisible(false)
end

function MainCtrl:inviteGiftProcessOver()
    PluginTrailMonitor:popPluginInTrail()
end

-- 更新老玩家红包图标
function MainCtrl:updateRedPacketIcon()
    if OldUserInviteGiftModel:isRedPacketEnable() then
        self._viewNode.redPacketNode:setVisible(true)

        if not self.XyhbSpine then
            local spineXyhb = sp.SkeletonAnimation:create("res/hall/spine/xyhb_icon/xyhb.json", "res/hall/spine/xyhb_icon/xyhb.atlas", 1)  
            self._viewNode.redPacketNode:addChild(spineXyhb)
            self.XyhbSpine = spineXyhb
        end

        self.XyhbSpine:setAnimation(0, "xyhb", true)
        --红点状态
        if OldUserInviteGiftModel:isRedPacketDotShow() then
            self._viewNode.redPacketDot:show()
        else
            self._viewNode.redPacketDot:hide()
        end
        --气泡状态
        if OldUserInviteGiftModel:isCanGetAward() then
            self._viewNode.Image_xyhb_qp:show() 
        else
            self._viewNode.Image_xyhb_qp:hide()
        end
    else
        self._viewNode.redPacketNode:setVisible(false)
    end
end

-- 更新老玩家邀请有礼图标
function MainCtrl:updateInviteGiftIcon()
    self._viewNode.yqylNode:setVisible(OldUserInviteGiftModel:isInviteGiftEnable())
end

-- 更新新玩家话费奖励图标
function MainCtrl:updateTicketIcon()
    local isOpenAct = NewUserInviteGiftModel:isOpenNewUserPhoneAct()
    self._viewNode.redbagPanel:setVisible( isOpenAct )
    if isOpenAct then
        self:showNewUserRedbagInfo()
    end
end

function MainCtrl:showYqylRedDot()
    if self._viewNode.yqylDot then
        self._viewNode.yqylDot:setVisible(OldUserInviteGiftModel:isShowRedDot())
    end

    self:updateRedPacketIcon()
end


function MainCtrl:showNewUserRedbagInfo()
    if not self._newUserRedBag then
        local redbag = NewUserRedbagLoadCtrl:create({isGame=false})
        local node = redbag._viewNode:getRealNode()
        self._viewNode.redbagPanel:addChild( node )
        node:setPosition(cc.p(50,50))
        self._newUserRedBag = redbag
    end
end

function MainCtrl:freshExchangeBubble()
    local viewNode = self._viewNode
    local panelBubble = viewNode.panelBottomBar:getChildByName("Btn_Exchange"):getChildByName("Panel_Bubble")
    if not panelBubble then return end
    panelBubble:setVisible(false)

    --当玩家没有低保次数时破产，且礼券大于等于20时，大厅礼券按钮冒出气泡
    local ReliefActivity=mymodel('hallext.ReliefActivity'):getInstance()
    local config = ReliefActivity.config
	local reliefstate = ReliefActivity.state
    if not config or not config.Limit or not config.Limit.LowerLimit or not reliefstate then return end

    local user = mymodel('UserModel'):getInstance()
    if not user.nSafeboxDeposit or not user.nDeposit then return end
    print("MainCtrl:setReliefState"..reliefstate..user.nDeposit..user.nSafeboxDeposit..config.Limit.LowerLimit..cc.exports.getExchangeNumValue())

    if reliefstate == 'USED_UP' and user.nDeposit + user.nSafeboxDeposit < config.Limit.LowerLimit then
        if ExchangeCenterModel._ticketLeftNum and ExchangeCenterModel._ticketLeftNum >= cc.exports.getExchangeNumValue() then
            print(ExchangeCenterModel._ticketLeftNum)
            panelBubble:setVisible(true)
        end
    end

    --播放动画
    panelBubble:stopAllActions()
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
    panelBubble:runAction(repeatForever)
end

function MainCtrl:freshYuleRoomBubble()
    local viewNode = self._viewNode
    local panelBubble = viewNode.panelBottomBar:getChildByName("Btn_YuleRoom"):getChildByName("Panel_Bubble")
    if not panelBubble then return end
    
    panelBubble:setVisible(false)
    panelBubble:stopAllActions()

    if not cc.exports.isYuleRoomSupported() then return end

    local isTiped = CacheModel:getCacheByKey("FreshYueleRoomBubble" .. tostring(user.nUserID))
    if isTiped and toint(isTiped) > 0 then return end
    
    panelBubble:setVisible(true)

    --播放动画
    panelBubble:stopAllActions()
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
    panelBubble:runAction(repeatForever)

    CacheModel:saveInfoToUserCache("FreshYueleRoomBubble" .. tostring(user.nUserID), 1)
end

function MainCtrl:showNobilityPrivilegeHead()
    local viewNode = self._viewNode
    local nobilityPrivilegeInfo = NobilityPrivilegeModel:GetNobilityPrivilegeInfo()
    local nobilityPrivilegeConfig = NobilityPrivilegeModel:GetNobilityPrivilegeConfig()
    if not nobilityPrivilegeInfo or not nobilityPrivilegeConfig then
        NobilityPrivilegeModel:gc_GetNobilityPrivilegeInfo()
        return
    end
    local nMyLevel = nobilityPrivilegeInfo.level
    local nLevel = 0 
    if nMyLevel >= 2 then
        if nMyLevel  >= 15 then
            nLevel = 15
        elseif nMyLevel >= 12 then
            nLevel = 12
        elseif nMyLevel  >= 10 then
            nLevel = 10
        elseif nMyLevel >= 7 then
            nLevel = 7
        elseif nMyLevel >= 5 then
            nLevel = 5
        elseif nMyLevel  >= 2 then
            nLevel = 2
        end
        viewNode.PanelNobilityPrivilege:setVisible(true)
        local imgHead = viewNode.PanelNobilityPrivilege:getChildByName("Image_NobilityPrivilege")
        imgHead:loadTexture("hallcocosstudio/images/plist/NobilityPrivilege/NobilityPrivilege_head"..nLevel..".png",ccui.TextureResType.plistType)
        imgHead:ignoreContentAdaptWithSize(true)
        viewNode.PanelNobilityPrivilege:getChildByName("Text_NobilityPrivilege"):setString(nMyLevel)
        local aniFile = "res/hallcocosstudio/NobilityPrivilege/tx_kuang.csb"
        local aniNode = viewNode.PanelNobilityPrivilege:getChildByName("Ani_HeadKuang")
        aniNode:stopAllActions()
        aniNode:removeAllChildren()
        local node = cc.CSLoader:createNode(aniFile)
        local action = cc.CSLoader:createTimeline(aniFile)
        aniNode:addChild(node)
        if not tolua.isnull(action) then
            node:runAction(action)
            action:play("animation0", true)
        end
    else
        viewNode.PanelNobilityPrivilege:setVisible(false)
    end
end

function MainCtrl:freshNobilityPrivilege()
    if SafeboxModel:isDataReady() then
        self:queryReliefInfo()
    end
    
    --有贵族特权系统不显示会员
    local viewNode = self._viewNode
    viewNode.nobilityPrivilegeBtn:setVisible(false)
    if NobilityPrivilegeModel:isAlive() then
		viewNode.memberPic:setVisible(false)
        viewNode.nobilityPrivilegeBtn:setVisible(true)
        self:showNobilityPrivilegeHead()
    end
    viewNode.nobilityPrivilegeBtn:getChildByName("Img_Dot"):setVisible(false)
    local bg = viewNode.nobilityPrivilegeBtn:getChildByName("Img_BG")
    bg:setVisible(false)
    bg:stopAllActions()
    if NobilityPrivilegeModel:isNeedReddot() then
        viewNode.nobilityPrivilegeBtn:getChildByName("Img_Dot"):setVisible(true)
        bg:setVisible(true)
        bg:runAction(cc.RepeatForever:create(cc.RotateBy:create(1, 30)))
    end

    -- 刷新房间列表的贵族准入显示
    local secondLayer = self.subManager.subRoomManager:getSecondLayer()
    if secondLayer then
        secondLayer:refreshNPLevelLimit()
        secondLayer:refreshPanelQuickStart()
    end

    local firstLayer = self.subManager.subRoomManager.firstLayer
    if firstLayer then
        firstLayer:refreshPanelQuickStart()
    end
end

function MainCtrl:getLuckyCatAward(rewardData)
    local skJsonFilePath = "res/hallcocosstudio/images/skeleton/redpack100vocher/xinshou_box.json"
    local skAtlasFilePath = "res/hallcocosstudio/images/skeleton/redpack100vocher/xinshou_box.atlas"    
    if rewardData.value.nType == LuckyCatDef.LUCKYCAT_REWARD_EXCHANGE then
        skJsonFilePath = "res/hallcocosstudio/images/skeleton/luckycat/xinshou_box.json"
        skAtlasFilePath = "res/hallcocosstudio/images/skeleton/luckycat/xinshou_box.atlas"
    end
    -- 播放拆红包声音
    audio.playSound(cc.FileUtils:getInstance():fullPathForFilename('res/hall/sounds/RedPackBreak.mp3'),false)
    -- 播放礼包特效
    if not cc.FileUtils:getInstance():isFileExist(skJsonFilePath) then return end
    local breakEffectSkeletonAni = sp.SkeletonAnimation:create(skJsonFilePath, skAtlasFilePath, 1)
    breakEffectSkeletonAni:setAnimation(0, "box_effect", true) 
    breakEffectSkeletonAni:setPositionY(80)
    self._viewNode.nodeBreakEffectAni:setVisible(true)
    self._viewNode.nodeBreakEffectAni:addChild(breakEffectSkeletonAni)
    -- 播放礼包打开特效 
    if not cc.FileUtils:getInstance():isFileExist(skJsonFilePath) then return end
    local breakOpenSkeletonAni = sp.SkeletonAnimation:create(skJsonFilePath, skAtlasFilePath, 1)
    breakOpenSkeletonAni:setAnimation(0, "box_ani_close", false) 
    breakOpenSkeletonAni:setPositionY(80)
    self._viewNode.nodeBreakOpenAni:setVisible(true)
    self._viewNode.nodeBreakOpenAni:addChild(breakOpenSkeletonAni)
    breakOpenSkeletonAni:registerSpineEventHandler(function (event)
        -- 播放礼包关闭特效
        self._viewNode.nodeBreakOpenAni:setVisible(false)
        if not cc.FileUtils:getInstance():isFileExist(skJsonFilePath) then return end
        local breakCloseSkeletonAni = sp.SkeletonAnimation:create(skJsonFilePath, skAtlasFilePath, 1)
        breakCloseSkeletonAni:setAnimation(0, "box_ani_open", false) 
        breakCloseSkeletonAni:setPositionY(80)
        self._viewNode.nodeBreakCloseAni:setVisible(true)
        self._viewNode.nodeBreakCloseAni:addChild(breakCloseSkeletonAni)
        breakCloseSkeletonAni:registerSpineEventHandler(function (event)
            self._viewNode.nodeBreakEffectAni:setVisible(false)
            self._viewNode.nodeBreakOpenAni:setVisible(false)
            self._viewNode.nodeBreakCloseAni:setVisible(false)
            print("Enter show award")
            local rewardList = {}
            rewardList = rewardData.value
            my.informPluginByName({pluginName = 'RewardTipCtrl', params = {data = rewardList, showtip = true}})
        end, sp.EventType.ANIMATION_COMPLETE)
    end, sp.EventType.ANIMATION_COMPLETE)
end

function MainCtrl:onClickLuckyCat()
    -- 校验招财猫信息和配置
    local viewNode = self._viewNode
    if not LuckyCatModel:checkCatInfoAndConfig() then return end
    -- 获取招财猫信息和配置
    local LuckyCatInfo = LuckyCatModel:GetLuckyCatInfo()
    local LuckyCatConfig = LuckyCatModel:GetLuckyCatConfig()

    my.playClickBtnSound()    
    if LuckyCatInfo.state == LuckyCatDef.LUCKYCAT_STATUS_TASK then
        -- 任务阶段
        if not UIHelper:checkOpeCycle("SubViewHelper_onClickPluginBtn_LuckyCatCtrl") then
            return
        end
        UIHelper:refreshOpeBegin("SubViewHelper_onClickPluginBtn_LuckyCatCtrl")
        my.scheduleOnce(function() my.informPluginByName({pluginName = "LuckyCatCtrl"}) end, 0)
    elseif LuckyCatInfo.state == LuckyCatDef.LUCKYCAT_STATUS_REWARD then
        -- 瓜分奖励阶段
        LuckyCatModel:gc_LuckyCatTakeAward()
        viewNode.BtnLuckyCat:setVisible(false)
        viewNode.nodeRoleAni:setVisible(true)
    end
end

function MainCtrl:freshLuckyCat()
    -- 招财猫主界面入口显示
    local viewNode = self._viewNode
    viewNode.BtnLuckyCat:setVisible(false)
    viewNode.nodeRoleAni:setVisible(true)

    -- 校验招财猫信息和配置
    if not LuckyCatModel:checkCatInfoAndConfig() then return end
    -- 获取招财猫信息和配置
    local LuckyCatInfo = LuckyCatModel:GetLuckyCatInfo()
    local LuckyCatConfig = LuckyCatModel:GetLuckyCatConfig()

    -- 活动开启期间显示招财猫入口按钮
    if LuckyCatModel:isAlive() then
        if LuckyCatInfo.state == LuckyCatDef.LUCKYCAT_STATUS_REWARD and LuckyCatModel:getMultiGrade() <= 0 then -- 瓜分奖励阶段：未解锁玩家不显示招财猫
            -- 隐藏招财猫
            viewNode.BtnLuckyCat:setVisible(false)
            viewNode.nodeRoleAni:setVisible(true)
        elseif LuckyCatInfo.state == LuckyCatDef.LUCKYCAT_STATUS_REWARD and LuckyCatInfo.catData.flag > 0 then  -- 瓜分奖励阶段：已领奖玩家不显示招财猫
            -- 隐藏招财猫
            viewNode.BtnLuckyCat:setVisible(false)
            viewNode.nodeRoleAni:setVisible(true)
        else                                                                                                    -- 任务阶段or刮风奖励阶段且解锁：显示招财猫
            -- 显示招财猫
            viewNode.nodeRoleAni:setVisible(false)
            viewNode.BtnLuckyCat:setVisible(true)
            local  multi = LuckyCatModel:getMultiGrade()
            if multi > 0 then
                local rewardType = LuckyCatConfig.LuckyCatReward[1].RewardType
                local bgName = "hallcocosstudio/images/plist/LuckyCat/LuckyCat_3.png"
                if rewardType == LuckyCatDef.LUCKYCAT_REWARD_EXCHANGE then
                    bgName = "hallcocosstudio/images/plist/LuckyCat/LuckyCat_4.png"
                end
                viewNode.BtnLuckyCat:loadTextureNormal(bgName,ccui.TextureResType.plistType)
                viewNode.BtnLuckyCat:loadTexturePressed(bgName,ccui.TextureResType.plistType)
                viewNode.BtnLuckyCat:loadTextureDisabled(bgName,ccui.TextureResType.plistType)
                --显示瓜分人数
                viewNode.BtnLuckyCat:getChildByName("Text_LockCount"):setVisible(false)
                if LuckyCatModel:getLockCount() > 0 then
                    viewNode.BtnLuckyCat:getChildByName("Text_LockCount"):setVisible(true)
                    viewNode.BtnLuckyCat:getChildByName("Text_LockCount"):setString(string.format("已有%d人解锁瓜分资格", LuckyCatModel:getLockCount()))
                end
            else
                local rewardType = LuckyCatConfig.LuckyCatReward[1].RewardType
                local bgName = "hallcocosstudio/images/plist/LuckyCat/LuckyCat_1.png"
                if rewardType == LuckyCatDef.LUCKYCAT_REWARD_EXCHANGE then
                    bgName = "hallcocosstudio/images/plist/LuckyCat/LuckyCat_2.png"
                end
                viewNode.BtnLuckyCat:loadTextureNormal(bgName,ccui.TextureResType.plistType)
                viewNode.BtnLuckyCat:loadTexturePressed(bgName,ccui.TextureResType.plistType)
                viewNode.BtnLuckyCat:loadTextureDisabled(bgName,ccui.TextureResType.plistType)
                --隐藏瓜分人数
                viewNode.BtnLuckyCat:getChildByName("Text_LockCount"):setVisible(false)
            end

            -- 活动期间红点才显示
            viewNode.BtnLuckyCat:getChildByName("Img_Dot"):setVisible(false)
            if LuckyCatModel:isNeedReddot() and LuckyCatInfo.state == LuckyCatDef.LUCKYCAT_STATUS_TASK then
                viewNode.BtnLuckyCat:getChildByName("Img_Dot"):setVisible(true)
            end

            -- 播放动画
            local panelBubble = viewNode.BtnLuckyCat:getChildByName("Panel_Bubble")
            if LuckyCatInfo.state == LuckyCatDef.LUCKYCAT_STATUS_TASK then
                local rewardType = LuckyCatConfig.LuckyCatReward[1].RewardType
                if tonumber(rewardType) == LuckyCatDef.LUCKYCAT_REWARD_SILVER then
                    panelBubble:getChildByName("Text_Tip"):setString("点我瓜分10亿银两")
                else
                    panelBubble:getChildByName("Text_Tip"):setString("点我瓜分10万话费")
                end
            elseif LuckyCatInfo.state == LuckyCatDef.LUCKYCAT_STATUS_REWARD then
                panelBubble:getChildByName("Text_Tip"):setString("点我领取奖励")
            end    
        end
    end
end

function MainCtrl:palyLuckyCatAni()
    -- 播放动画
    local viewNode = self._viewNode
    local panelBubble = viewNode.BtnLuckyCat:getChildByName("Panel_Bubble") 
    panelBubble:stopAllActions()
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
    panelBubble:runAction(repeatForever)
end

-- 打开停留定时器
function MainCtrl:startAdvertStandingTimer()
    if self._standingAdvertTimer then return end    -- 定时器已经开了

    local standingTime = AdvertModel:getInterVdStandingTime(AdvertDefine.INTERSTITIAL_STAND_HALL)
    if standingTime <= 0 then return end
    self._standingAdvertTimer = my.createSchedule(function()
        if not self then return end
        self:stopAdvertStandingTimer()
        if AdvertModel:isNeedShowInterstitial(AdvertDefine.INTERSTITIAL_STAND_HALL) then
            AdvertModel:showInterstitialAdvert(AdvertDefine.INTERSTITIAL_STAND_HALL)
            AdvertModel:addInterVdShowCount(AdvertDefine.INTERSTITIAL_STAND_HALL, 1)
        end
    end, standingTime)
end

-- 关闭停留定时器
function MainCtrl:stopAdvertStandingTimer()
    if self._standingAdvertTimer then
        my.removeSchedule(self._standingAdvertTimer)
        self._standingAdvertTimer = nil
    end
end

function MainCtrl:onRechargePoolUpdate()
    local viewNode = self:getViewNode()
    if not viewNode then
        return
    end
    MainView:refreshLeftBar(viewNode)
    MainView:refreshRechargePoolBtnRedDot()
end

function MainCtrl:onWatchVideoTakeRewardUpdate()
    local viewNode = self:getViewNode()
    if not viewNode then 
        return
    end
    MainView:refreshLeftBar(viewNode)
    MainView:refreshWatchVideoBtn()
end

function MainCtrl:onRechargeFlopCardUpdate()
    local viewNode = self:getViewNode()
    if not viewNode then 
        return
    end
    MainView:refreshLeftBar(viewNode)
    MainView:refreshRechargeFlopCardBtn()
end

function MainCtrl:onContinueRechargeUpdate()
    local viewNode = self:getViewNode()
    if not viewNode then
        return
    end
    MainView:refreshLeftBar(viewNode)
    MainView:refreshContinueRechargeBtnRedDot()
end

function MainCtrl:onLuckyPackConfigResp()
    local viewNode = self:getViewNode()
    if not viewNode then
        return
    end
    MainView:refreshLeftBar(viewNode)
end

function MainCtrl:onLuckyPackStateResp()
    local viewNode = self:getViewNode()
    if not viewNode then
        return
    end
    -- ToDo
end

-- 每日首次自动弹出特权活动
function MainCtrl:AutoPopVivoPrivilegeStartUp()
    if cc.exports.isVivoVipActivitySupported() then
        if VivoPrivilegeStartUpModel._state == VivoPrivilegeStartUpDef.VIVO_PRIVILEGE_STARTUP_NOT_REWARD then
            local curDate = os.date('%Y%m%d',os.time())
            local cacheDate = VivoPrivilegeStartUpModel:getCacheLoginOpenDate()
            if cacheDate == nil or toint(cacheDate) ~= toint(curDate) then
                -- vivo特权启动活动
                if BusinessUtils:getInstance().getLaunchParamInfo then
                    local json = cc.load("json").json
                    local lauchParam = BusinessUtils:getInstance():getLaunchParamInfo()
                    if lauchParam and lauchParam.extra and lauchParam.extra ~= "" then
                        local extra = json.decode(lauchParam.extra) or {}
                        --if extra["fromPackage"] and extra["fromPackage"] == "com.vivo.game" then
                            VivoPrivilegeStartUpModel:setCacheLoginOpenDate(curDate)
                            my.informPluginByName({ pluginName = 'VivoPrivilegeStartUpCtrl' })
                        --end
                    end
                end
            end
        end
    end
end

function MainCtrl:onRefreshWeekMonthSuperCard()
    MainView:refreshLeftBar(self._viewNode)
end

function MainCtrl:onRefreshGratitudeRepay()
    MainView:refreshLeftBar(self._viewNode)
end

-- 响应Vivo特权活动配置获取
function MainCtrl:onVivoPrivilegeStartUpConfigResp()
    if VivoPrivilegeStartUpModel._config ~= nil and VivoPrivilegeStartUpModel._state ~= nil then
        self:AutoPopVivoPrivilegeStartUp()
    end    
end

-- 响应Vivo特权活动领奖状态获取
function MainCtrl:onVivoPrivilegeStartUpStateResp()
    if VivoPrivilegeStartUpModel._config ~= nil and VivoPrivilegeStartUpModel._state ~= nil then
        self:AutoPopVivoPrivilegeStartUp()
    end 
end

function MainCtrl:setSpringFestivalCache()
    local enable = cc.exports.isSpringFestivalViewSupported()
    local startDate = cc.exports.getSpringFestivalViewStartDate()
    local endDate = cc.exports.getSpringFestivalViewEndDate()
    SpringFestivalModel:setSpringFestivalCache(enable, startDate, endDate)
end

function MainCtrl:testSkeleton(  )
    local nodeAni = sp.SkeletonAnimation:create('res/skeleton/guandan_nv.json', 'res/skeleton/guandan_nv.atlas', 1)  
    nodeAni:setAnimation(1, 'zhayan', true)
    nodeAni:setDebugBonesEnabled(false)
    nodeAni:setPosition(cc.p(display.center.x, display.center.y - 200))
    local viewNode = self:getViewNode()
    viewNode:addChild(nodeAni, 1)
end

function MainCtrl:onKeyboardReleased(keyCode, event)
    if keyCode == cc.KeyCode.KEY_BACK then
        print("on key back clicked")
        if (self.onKeyBack) then
            return self:onKeyBack()
        end
    elseif keyCode == cc.KeyCode.KEY_SPACE then
        my.informPluginByName({pluginName = "PeakRankCtrl"})
    end
end

function MainCtrl:onQuerySafeboxInfoOK()
    if MainView:refreshPluginBtnView(self._viewNode, 'safeBox') then
        MainView:refreshBottomBarBtnPos(self._viewNode)
    end

    if NobilityPrivilegeModel:isDataReady() then
        self:queryReliefInfo()
    end
end

function MainCtrl:queryReliefInfo()
    relief:queryConfig()
    my.scheduleOnce(function()
        self:_tryAutoTakeRelief()
    end, 2)
end

function MainCtrl:onQueryValuablePurchaseOK()
    local enable  = ValuablePurchaseModel:isEnable()
    MainView:refreshPluginBtnAvailDirectly(self._viewNode, 'valuablePurchase', enable)
    self:refreshValuablePurchaseBtnRedDot()
end

function MainCtrl:onBuyPurchaseOK()
    self:refreshValuablePurchaseBtnRedDot()
end

function MainCtrl:refreshValuablePurchaseBtnRedDot()
    local isNeedRedDot = ValuablePurchaseModel:isNeedRedDot()
    MainView:refreshValuablePurchaseBtnRedDot(self._viewNode, isNeedRedDot)
end

function MainCtrl:refreshPeakRankBtn()
    MainView:refreshPeakRankBtn(self._viewNode)
end

function MainCtrl:refreshPeakRankBtnRedDot()
    MainView:refreshPeakRankBtnRedDot(self._viewNode)
end

cc.register( "MainCtrl", MainCtrl )

return MainCtrl
