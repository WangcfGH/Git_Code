local PhoneFeeGiftModel =class('PhoneFeeGiftModel',require('src.app.GameHall.models.BaseModel'))
local AssistModel = mymodel('assist.AssistModel'):getInstance()
local PhoneFeeGiftDef = require('src.app.plugins.PhoneFeeGift.PhoneFeeGiftDef')
local PhoneFeeGiftReq = require('src.app.plugins.PhoneFeeGift.PhoneFeeGiftReq')
local user = mymodel('UserModel'):getInstance()
local MyTimeStamp = import('src.app.mycommon.mytimestamp.MyTimeStamp'):getInstance()
local PhoneFeeGiftCache = import('src.app.plugins.PhoneFeeGift.PhoneFeeGiftCache'):getInstance()

local treepack = cc.load('treepack')

local coms=cc.load('coms')
local PropertyBinder=coms.PropertyBinder
my.setmethods(PhoneFeeGiftModel,PropertyBinder)

my.addInstance(PhoneFeeGiftModel)


---PhoneFeeGiftModel.PHONE_FEE_GIFT_GO_FIGHT = "PhoneFeeGiftGoFight"
--PhoneFeeGiftModel.PHONE_FEE_GIFT_UPDATE_REDDOT = "PhoneFeeGiftUpdateRedDot"

function PhoneFeeGiftModel:onCreate()

    self:initAssistResponse()

    self._RedDotCount = 0
    self._AvaliableCheck = false
end

function PhoneFeeGiftModel:initAssistResponse()
    self._assistResponseMap = {
        [PhoneFeeGiftDef.GR_PHONE_FEE_GIFT_RSP] = handler(self, self.onPhoneFeeGiftRecieved),
        [PhoneFeeGiftDef.GR_PHONE_FEE_GIFT_ADD_BOUT] = handler(self, self.onPhoneFeeGiftAddBout),
        [PhoneFeeGiftDef.GR_PHONE_FEE_GIFT_REWARD_RESP] = handler(self, self.onPhoneFeeGiftReward)
    }
    AssistModel:registCtrl(self, self.dealAssistResponse)
end

-- 话费礼发送请求
function PhoneFeeGiftModel:gc_PhoneFeeGiftReq()
    self._info = {}
    if user.nUserID == nil or user.nUserID < 0 then
        print("PhoneFeeGiftModel userinfo is not ok")
        return
    end

    local device = require("src.app.GameHall.models.DeviceModel"):getInstance()
    local deviceCombineID = device.szHardID..device.szMachineID..device.szVolumeID
    local data = {
        nUserID = user.nUserID,
        nPlayBout   = user.nBout,
        szDeviceID = deviceCombineID,
    }

    AssistModel:sendRequest(PhoneFeeGiftDef.GR_PHONE_FEE_GIFT_REQ, PhoneFeeGiftReq.PHONE_FEE_GIFT_REQ, data, false)
end

-- 话费礼响应请求
function PhoneFeeGiftModel:onPhoneFeeGiftRecieved(data)
    local info = AssistModel:convertDataToStruct(data,PhoneFeeGiftReq["PHONE_FEE_GIFT_RSP"]);

    if info.nUserID ~= user.nUserID then
        return
    end

    self._info = info

    if self._info.nActStatus ~=  PhoneFeeGiftDef.STATUS_NOMAL then
        print("PhoneFeeGiftModel nActStatus is NOT STATUS_NOMAL")     
        return
    end

    local strTodayDate = os.date("%Y%m%d", MyTimeStamp:getLatestTimeStamp())
    local nTodayDate = tonumber(strTodayDate)
    if nTodayDate > self._info.nEndDate then
        print("PhoneFeeGiftModel return , Activity nTodayDate > nEndDate !!!")     
        return
    end

    if nTodayDate < self._info.nSignDate then
        print("PhoneFeeGiftModel return , Activity nTodayDate < nSignDate !!!")     
        return
    end


    self._AvaliableCheck = true
    self:dispatchEvent({name=PhoneFeeGiftDef.MSG_PHONE_FEE_GIFT_UPDATE})
    
    local pfgCache = PhoneFeeGiftCache:getDataWithUserID()
    if DEBUG and DEBUG >= 1 then
        if pfgCache.loginDate == nil then
            pfgCache.loginDate = 0
        end
        print("PhoneFeeGiftModel , cache date:,   info.isComplete:",pfgCache.loginDate, self._info.isComplete)  

    end   

    local strTodayDate = os.date("%Y%m%d", MyTimeStamp:getLatestTimeStamp())
    local nTodayDate = tonumber(strTodayDate)
    if pfgCache and pfgCache.loginDate ~= nTodayDate or self._info.isComplete == 1 and nTodayDate > info.nSignDate then
        self:setRedDotCount()
        pfgCache.loginDate = nTodayDate
        --PhoneFeeGiftCache:saveCacheFileByName(pfgCache)
    end
    self:askRefreshActivityCenter()
    self:updateRedDot()
end

function PhoneFeeGiftModel:onPhoneFeeGiftAddBout(data)
    local addBoutInfo = AssistModel:convertDataToStruct(data,PhoneFeeGiftReq["PHONE_FEE_GIFT_ADD_BOUT"]);
    if addBoutInfo.nUserID ~= user.nUserID then
        return
    end
    if self._info then
        self._info.nPlayBout = addBoutInfo.nPlayBout
        if addBoutInfo.nPlayBout >= self._info.nDstBout then
            self._info.isComplete = 1
        end
    end

   -- self:dispatchEvent({name=PhoneFeeGiftDef.MSG_PHONE_FEE_GIFT_ADD_BOUT,  param = addBoutInfo})

end

-- 话费礼发送领奖请求
function PhoneFeeGiftModel:gc_PhoneFeeGiftRewardReq()

    if user.nUserID == nil or user.nUserID < 0 then
        print("PhoneFeeGiftModel userinfo is not ok")
        return
    end

    local data = {
        nUserID = user.nUserID,
        nPlayBout   = user.nBout,
        szUserName = user.szUsername,
    }

    AssistModel:sendRequest(PhoneFeeGiftDef.GR_PHONE_FEE_GIFT_REWARD, PhoneFeeGiftReq.PHONE_FEE_GIFT_REWARD_REQ, data, false)
end

-- 响应领奖请求
function PhoneFeeGiftModel:onPhoneFeeGiftReward(data)
    local rewardRsp = AssistModel:convertDataToStruct(data,PhoneFeeGiftReq["PHONE_FEE_GIFT_REWARD_RESP"]);
    if rewardRsp.nUserID ~= user.nUserID then
        return
    end

    if rewardRsp.nRewardNum > 0 and rewardRsp.nStatusCode == PhoneFeeGiftDef.STATUS_NOMAL then
        self._info.isTakeReward = 1;
        self._info.isComplete = 1
        self._RedDotCount = 0   -- 领完奖置为0

        self:dispatchEvent({name=PhoneFeeGiftDef.MSG_PHONE_FEE_GIFT_REWARD_GETED,  value = rewardRsp})
    else
        self:dispatchEvent({name=PhoneFeeGiftDef.MSG_PHONE_FEE_GIFT_REWARD_FAILED,  value = rewardRsp})
    end


    self:updateRedDot()
end


function PhoneFeeGiftModel:GetPhoneFeeGiftInfo()
    if self._info and next(self._info) ~= nil then
        return self._info
    end
    return nil
end

function PhoneFeeGiftModel:notifyActivityCenterClose()
    local activityCenterModel = import("src.app.plugins.activitycenter.ActivityCenterModel"):getInstance()
    activityCenterModel:onNotifyCloseCtrl()
end

function PhoneFeeGiftModel:askRefreshActivityCenter()
    self._AvaliableCheck = false
    local activityCenterModel = import("src.app.plugins.activitycenter.ActivityCenterModel"):getInstance()
    activityCenterModel:setMatrixActivityNeedShow(PhoneFeeGiftDef.ID_IN_ACTIVITY_CENTER, true)
end

-- 倒计时到0 的处理
function PhoneFeeGiftModel:onCountDownZero()
    self._AvaliableCheck = false

    self._RedDotCount = 0
    self:updateRedDot()

    self:dispatchEvent({name = PhoneFeeGiftDef.MSG_PHONE_FEE_GIFT_CLOCK_ZERO})
    local activityCenterModel = import("src.app.plugins.activitycenter.ActivityCenterModel"):getInstance()
    activityCenterModel:setMatrixActivityNeedShow(PhoneFeeGiftDef.ID_IN_ACTIVITY_CENTER, false)

end

-- 倒计时到新的一天
function PhoneFeeGiftModel:onCountDownNewDay()
    self:dispatchEvent({name = PhoneFeeGiftDef.MSG_PHONE_FEE_GIFT_NEW_DAY})
end

function PhoneFeeGiftModel:updateRedDot()
    self:dispatchEvent({name = PhoneFeeGiftDef.PHONE_FEE_GIFT_UPDATE_REDDOT})
end

-- 活动界面创建话费礼的时候，设置一次红点
function PhoneFeeGiftModel:setRedDotCount()
    if self._info and next(self._info) ~= nil then
        local info  = self._info
        if info.isTakeReward <= 0 then
            -- 未领取， 当天首次登陆或者 已完成任务+第二天登陆
            self._RedDotCount = 1
        else
            self._RedDotCount = 0
        end
        print("PhoneFeeGiftModel setRedDotCount :"..self._RedDotCount)  
    end
end

function PhoneFeeGiftModel:clearRedDotCount()
    if self._info and next(self._info) ~= nil then
        local info  = self._info
        local strTodayDate = os.date("%Y%m%d", MyTimeStamp:getLatestTimeStamp())
        local nTodayDate = tonumber(strTodayDate)
        if info.isComplete == 1 and info.isTakeReward == 0 and  nTodayDate > info.nSignDate and nTodayDate < info.nEndDate then
            -- 任务完成，未领取。则不清理红点，直到领取
        else
            self._RedDotCount = 0
        end

    end
    --self:updateRedDot() -- 通知ActivityCenterCtrl更新红点
end

function PhoneFeeGiftModel:NeedShowRedDot()
    local bNeedShow = false
    if self._info and next(self._info) ~= nil then
        local info  = self._info
        if self._RedDotCount and self._RedDotCount > 0 then
            bNeedShow = true
        end
    end
    return bNeedShow
end

-- 登陆的时候，下发给AssistSvr，用于服务判断该玩家是否参加了 话费礼活动
function PhoneFeeGiftModel:getActivityCheckResult()
    if true == self._AvaliableCheck then
        return 1
    else
        return 0
    end
end


return PhoneFeeGiftModel