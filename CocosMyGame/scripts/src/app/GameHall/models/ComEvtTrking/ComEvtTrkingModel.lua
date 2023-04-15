local ComEvtTrkingModel = class('ComEvtTrkingModel', require('src.app.GameHall.models.BaseModel'))
my.addInstance(ComEvtTrkingModel)

protobuf.register_file("src/app/GameHall/models/ComEvtTrking/commonEvtTrking.pb")

local ProtoNumbers = {
    GR_QUICKRECHARGE_WAKEUP_LOG = (400000 + 7007),
    GR_QUICKRECHARGE_BUY_LOG = (400000 + 7008),
    GR_WATCH_VIDEO_EVENT_TRACKING = 500201
}

ComEvtTrkingModel.WATCH_VIDEO_SCENE = {
    NONE = 0,
    LOGIN_LOTTERY = 1, -- 每日抽奖模块
    WATCH_VIDEO_TAKE_REWARD = 2, -- 看视频领奖励模块
    LOGIN_LOTTERY_EXTRA_REWARD = 3, -- 每日抽奖额外奖励
}
ComEvtTrkingModel.WATCH_VIDEO_RESULT = {
    SUCCESS = 0,
    FAIL = 1
}
ComEvtTrkingModel.WATCH_VIDEO_ERROR_REASON = {
    NONE = 0,
    LOAD_ERROR = 1,
    NOT_SUPPORT = 2,
    DISMISS = 3
}

-- 快速充值埋点 begin
function ComEvtTrkingModel:sendQuickRechargeWakeupEvent(roomid, isInGame)
    local func = function ()
        local path = 0 -- 大厅
        if isInGame then 
            path = 1 -- 游戏内
        end
        local user = mymodel('UserModel'):getInstance()
        local NobilityPrivilegeModel = import("src.app.plugins.NobilityPrivilege.NobilityPrivilegeModel"):getInstance()
        self._evtQuickGiftsInfo = {
            userid = user.nUserID or 0,
            roomid = roomid or 0,
            originsilvers = user.nDeposit or 0,
            isclick = 0,
            clicktime = 0,
            closetime = 0,
            opentime = os.time(),
            viplevel =  NobilityPrivilegeModel:GetSelfNobilityPrivilegeLevel() or -1,
            path = path,
            channel = BusinessUtils:getInstance():getTcyChannel()
        }
        local pbdata = protobuf.encode("commonEvtTrking.quickRechargeWakeupEvt", self._evtQuickGiftsInfo)
        local AssistModel = mymodel('assist.AssistModel'):getInstance()
        AssistModel:sendData(ProtoNumbers.GR_QUICKRECHARGE_WAKEUP_LOG, pbdata)
    end
    pcall(func)
end

function ComEvtTrkingModel:sendQuickRechargeClickBuyBtn()
    local func = function ()
        if self._evtQuickGiftsInfo then
            self._evtQuickGiftsInfo.isclick = 1
            self._evtQuickGiftsInfo.clicktime = os.time()
            self._evtQuickGiftsInfo.closetime = os.time() -- "快速充值"点击购买就会关闭
            local pbdata = protobuf.encode("commonEvtTrking.quickRechargeWakeupEvt", self._evtQuickGiftsInfo)
            local AssistModel = mymodel('assist.AssistModel'):getInstance()
            AssistModel:sendData(ProtoNumbers.GR_QUICKRECHARGE_WAKEUP_LOG, pbdata)
        end
    end
    pcall(func)
end

function ComEvtTrkingModel:sendQuickRechargeClickCloseBtn()
    local func = function ()
        if self._evtQuickGiftsInfo then
            self._evtQuickGiftsInfo.closetime = os.time()
            local pbdata = protobuf.encode("commonEvtTrking.quickRechargeWakeupEvt", self._evtQuickGiftsInfo)
            local AssistModel = mymodel('assist.AssistModel'):getInstance()
            AssistModel:sendData(ProtoNumbers.GR_QUICKRECHARGE_WAKEUP_LOG, pbdata)
        end
    end
    pcall(func)
end
function ComEvtTrkingModel:saveRechargeInfo(exchangeid, price)
    self._rechargeInfo = {
        exchangeid = exchangeid, 
        price = price
    }
end
function ComEvtTrkingModel:sendQuickRechargeBuySuccessEvt()
    local func = function ()
        if self._rechargeInfo then
            local id = self._rechargeInfo.exchangeid
            local price = self._rechargeInfo.price
            local roomid = 0
            if self._evtQuickGiftsInfo then
                roomid = self._evtQuickGiftsInfo.roomid or 0
            end
            self._rechargeInfo = nil
            local user = mymodel('UserModel'):getInstance()
            local NobilityPrivilegeModel = import("src.app.plugins.NobilityPrivilege.NobilityPrivilegeModel"):getInstance()
            local data = {
                userid = user.nUserID or 0,
                channel = BusinessUtils:getInstance():getTcyChannel(),
                buytime = os.time(),
                roomid = (self._evtQuickGiftsInfo and self._evtQuickGiftsInfo.roomid or 0),
                originsilvers = (self._evtQuickGiftsInfo and self._evtQuickGiftsInfo.originsilvers or 0),
                price = price,
                goodid = id,
                viplevel = NobilityPrivilegeModel:GetSelfNobilityPrivilegeLevel() or -1,
                path = (self._evtQuickGiftsInfo and self._evtQuickGiftsInfo.path or 0)
            }
            local pbdata = protobuf.encode("commonEvtTrking.quickRechargeBuyEvt", data)
            local AssistModel = mymodel('assist.AssistModel'):getInstance()
            AssistModel:sendData(ProtoNumbers.GR_QUICKRECHARGE_BUY_LOG, pbdata)
        end
    end
    pcall(func)
end
-- 快速充值埋点 end

function ComEvtTrkingModel:initWatchVideoEventInfo(scene)
    local user = mymodel('UserModel'):getInstance()
    local func = function ()
        self._watchVideoInfo = {
            userid = user.nUserID or 0,
            waketime = os.time(),
            opentime = 0,
            finishtime = 0,
            hardid = DeviceUtils:getInstance():getMacAddress(),
            channel = BusinessUtils:getInstance():getTcyChannel(),
            appid = BusinessUtils:getInstance():getAbbr(),
            scene = scene or self.WATCH_VIDEO_SCENE.NONE,
            result = self.WATCH_VIDEO_RESULT.FAIL, -- 指示视频有没有成功显示出来
            reason = self.WATCH_VIDEO_ERROR_REASON.NONE
        }
    end
    pcall(func)
end

function ComEvtTrkingModel:changeWatchVideoEventInfo(fieldName, value)
    if self._watchVideoInfo then
        if type(self._watchVideoInfo[fieldName]) == type(value) then
            self._watchVideoInfo[fieldName] = value
        else
            print("[ERROR] invalid fieldName and value:", fieldName, value)
        end
    end
end

function ComEvtTrkingModel:sendWatchVideoEventInfo()
    local func = function ()
        if self._watchVideoInfo then
            local pbdata = protobuf.encode("commonEvtTrking.watchVideoEvent", self._watchVideoInfo)
            local AssistModel = mymodel('assist.AssistModel'):getInstance()
            AssistModel:sendData(ProtoNumbers.GR_WATCH_VIDEO_EVENT_TRACKING, pbdata)
        end
    end
    pcall(func)
end

function ComEvtTrkingModel:watchVideoCallback(code, msg)
    local AdvertModel = import('src.app.plugins.advert.AdvertModel'):getInstance()
    if code == AdvertModel.AdSdkRetType.ADSDK_RET_AD_VIDEOCOMPLETE then
        self:changeWatchVideoEventInfo('finishtime', os.time())
        self:sendWatchVideoEventInfo()
    elseif code == AdvertModel.AdSdkRetType.ADSDK_RET_SHOWAD_SUCCESS then
        self:changeWatchVideoEventInfo('result', self.WATCH_VIDEO_RESULT.SUCCESS)
        self:changeWatchVideoEventInfo('reason', self.WATCH_VIDEO_ERROR_REASON.NONE)
        self:changeWatchVideoEventInfo('opentime', os.time())
    elseif code == AdvertModel.AdSdkRetType.ADSDK_RET_LOADAD_FAIL then
        self:changeWatchVideoEventInfo('result', self.WATCH_VIDEO_RESULT.FAIL)
        self:changeWatchVideoEventInfo('reason', self.WATCH_VIDEO_ERROR_REASON.LOAD_ERROR)
        self:sendWatchVideoEventInfo()
    elseif code == AdvertModel.AdSdkRetType.ADSDK_RET_AD_DIMISS then
        self:changeWatchVideoEventInfo('result', self.WATCH_VIDEO_RESULT.FAIL)
        self:changeWatchVideoEventInfo('reason', self.WATCH_VIDEO_ERROR_REASON.DISMISS)
        self:sendWatchVideoEventInfo()
    elseif code == AdvertModel.AdSdkRetType.ADSDK_RET_AD_NOT_SUPPORT then
        self:changeWatchVideoEventInfo('result', self.WATCH_VIDEO_RESULT.FAIL)
        self:changeWatchVideoEventInfo('reason', self.WATCH_VIDEO_ERROR_REASON.NOT_SUPPORT)
        self:sendWatchVideoEventInfo()
    end   
end

return ComEvtTrkingModel

