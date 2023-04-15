local DailyRechargeModel         = class('DailyRechargeModel', require('src.app.GameHall.models.BaseModel'))
local DailyRechargeDef           = require('src.app.plugins.DailyRecharge.DailyRechargeDef')
local AssistModel                = mymodel('assist.AssistModel'):getInstance()
local user                       = mymodel('UserModel'):getInstance()
local deviceModel                = mymodel('DeviceModel'):getInstance()
local CardRecorderModel          = import("src.app.plugins.shop.cardrecorder.CardRecorderModel"):getInstance()
local ExchangeLotteryModel       = require('src.app.plugins.ExchangeLottery.ExchangeLotteryModel'):getInstance()
local RewardTipDef = import("src.app.plugins.RewardTip.RewardTipDef")

my.addInstance(DailyRechargeModel)

protobuf.register_file('src/app/plugins/DailyRecharge/pbDailyRecharge.pb')

function DailyRechargeModel:onCreate()
    self._rspStatus = nil
    self._data = nil
    self._bShow = false
    self:initAssistResponse()
end

function DailyRechargeModel:initAssistResponse()
    self._assistResponseMap = {
        [DailyRechargeDef.GR_DAILY_RECHARGE_REQ_STATUS] = handler(self, self.onDailyRechargeStatus),
        [DailyRechargeDef.GR_DAILY_RECHARGE_REQ_TAKE_AWARD] = handler(self, self.onTakeDailyRechargeAward),
        [DailyRechargeDef.GR_DAILY_RECHARGE_PAY_SUCCEED] = handler(self, self.onPlayerPayOK),
    }
    AssistModel:registCtrl(self, self.dealAssistResponse)
end

function DailyRechargeModel:gc_GetDailyRechargeInfo()
    print("DailyRechargeModel:gc_GetDailyRechargeInfo")
    if not cc.exports.isDailyRechargeSupported()  then
        return
    end
      
    if user.nUserID == nil or user.nUserID < 0 then
        print("userinfo is not ok")
        return
    end

    local platFormType = 1
    if MCAgent:getInstance().getLaunchSubMode and MCAgent:getInstance():getLaunchSubMode() == 1 then
        platFormType = 3
    elseif cc.exports.LaunchMode["PLATFORM"] == MCAgent:getInstance():getLaunchMode() then
        if device.platform == 'ios' then
            platFormType = 2
        else
            platFormType = 1
        end
    end

    local data = {
        userid = user.nUserID,
        platform = platFormType,
    }
    local pdata = protobuf.encode('pbDailyRecharge.ReqStatus', data)
    AssistModel:sendData(DailyRechargeDef.GR_DAILY_RECHARGE_REQ_STATUS, pdata, false)
end

function DailyRechargeModel:onDailyRechargeStatus(data)
    if string.len(data) == nil then return nil end
    if not cc.exports.isDailyRechargeSupported()  then return end

    local pdata = protobuf.decode('pbDailyRecharge.RspStatus', data)
    protobuf.extract(pdata)
    dump(pdata, "DailyRechargeModel:onDailyRechargeStatus")

    self._data = nil
    self._rspStatus = pdata
    self:dispatchEvent({name = DailyRechargeDef.DAILY_RECHARGE_STATUS_RSP})

    self._bShow = false
    if type(self._rspStatus.status) == "string" and self._rspStatus.status == DailyRechargeDef.ServiceOK then
        self._bShow = true
    end
    
    self:askRefreshActivityCenter(self._bShow)
end

function DailyRechargeModel:isDailyRechargeShow()
    return self._bShow
end

function DailyRechargeModel:gc_TakeRechargeAward(taskid)
    print("DailyRechargeModel:gc_TakeRechargeAward")
    if not cc.exports.isDailyRechargeSupported()  then
        return
    end
      
    if user.nUserID == nil or user.nUserID < 0 then
        print("userinfo is not ok")
        return
    end

    local platFormType = 1
    if MCAgent:getInstance().getLaunchSubMode and MCAgent:getInstance():getLaunchSubMode() == 1 then
        platFormType = 3
    elseif cc.exports.LaunchMode["PLATFORM"] == MCAgent:getInstance():getLaunchMode() then
        if device.platform == 'ios' then
            platFormType = 2
        else
            platFormType = 1
        end
    end

    local isTotalItem = 0
    if taskid == 6 then isTotalItem = 1 end

    local data = {
        userid = user.nUserID,
        taskid = taskid,
        platform = platFormType,
        totalItem = isTotalItem
    }
    local pdata = protobuf.encode('pbDailyRecharge.ReqTakeReward', data)
    AssistModel:sendData(DailyRechargeDef.GR_DAILY_RECHARGE_REQ_TAKE_AWARD, pdata, false)
end

function DailyRechargeModel:onTakeDailyRechargeAward(data)
    if string.len(data) == nil then return nil end
    if not cc.exports.isDailyRechargeSupported()  then return end

    local pdata = protobuf.decode('pbDailyRecharge.RspTakeAward', data)
    protobuf.extract(pdata)
    dump(pdata, "DailyRechargeModel:onTakeDailyRechargeAward")

    if pdata.takestatus == DailyRechargeDef.TakeSucceed then
        if not self._rspStatus then return end
        self._rspStatus.awardstatus = pdata.awardstatus
        self._rspStatus.totalItemStatus = pdata.totalItemStatus
        self:dispatchEvent({name = DailyRechargeDef.DAILY_RECHARGE_STATUS_RSP})
        self:dispatchEvent({name = DailyRechargeDef.DAILY_RECHARGE_UPDATE_REDDOT})

        if #pdata.awards > 0 then
            local rewardList = {}
            for u, v in pairs(pdata.awards) do
                if v.cantake and v.cantake == 1 then
                    table.insert( rewardList,{nType = v.rewardtype,nCount = v.rewardcount})
                    if v.rewardtype == RewardTipDef.TYPE_REWARDTYPE_LOTTERY_TIME then
                        ExchangeLotteryModel:addSeizeCount(v.rewardcount)
                    end
                end
            end
            if #rewardList > 0 then
                my.informPluginByName({pluginName = 'RewardTipCtrl', params = {data = rewardList,showOkOnly = true}})
                CardRecorderModel:sendGetCardMakerInfo() --查询记牌器信息

                my.scheduleOnce(function ()
                    local playerModel = mymodel("hallext.PlayerModel"):getInstance()
                    playerModel:update({'SafeboxInfo','MemberInfo','UserGameInfo'})
                end, 2)
            end
        end
        
    elseif pdata.takestatus == DailyRechargeDef.TaskNotComplete then
        my.informPluginByName({pluginName='TipPlugin',params={tipString="任务未完成！",removeTime=1}})
    elseif pdata.takestatus == DailyRechargeDef.TaskRewarded then
        my.informPluginByName({pluginName='TipPlugin',params={tipString="奖励已领取！",removeTime=1}})
    elseif pdata.takestatus == DailyRechargeDef.TakeFail then
        my.informPluginByName({pluginName='TipPlugin',params={tipString="服务器繁忙，请稍后再试！",removeTime=1}})
    end
    
end

function DailyRechargeModel:onPlayerPayOK(data)
    if string.len(data) == nil then return nil end
    if not cc.exports.isDailyRechargeSupported()  then return end

    local pdata = protobuf.decode('pbDailyRecharge.RspStatus', data)
    protobuf.extract(pdata)
    dump(pdata, "DailyRechargeModel:onPlayerPayOK")
    if not self._rspStatus then return end

    self._rspStatus.status = pdata.status
    self._rspStatus.totalItemStatus = pdata.totalItemStatus
    self._rspStatus.currecharge = pdata.currecharge
    self._rspStatus.awardstatus = pdata.awardstatus 
    
    if pdata.totalcondition and type(pdata.totalcondition) == "number" and pdata.totalcondition > 0 then
        self._rspStatus.totalcondition = pdata.totalcondition 
    end

    if pdata.jsonstr and type(pdata.jsonstr) == "string" and string.len(pdata.jsonstr) > 0 then
        self._data = nil
        self._rspStatus.jsonstr = pdata.jsonstr
    end
    self:dispatchEvent({name = DailyRechargeDef.DAILY_RECHARGE_STATUS_RSP})
    self:dispatchEvent({name = DailyRechargeDef.DAILY_RECHARGE_UPDATE_REDDOT})

    -- 埋点
    self:_onPayOk()
end

function DailyRechargeModel:NeedShowRedDot()
    local bRet = false
    if self._rspStatus and self._rspStatus.awardstatus then
        for i = 1, 5 do
            if i ~= 4 then
                local awardstatus = self:getTaskStatus(self._rspStatus.awardstatus, i)
                if awardstatus == DailyRechargeDef.REWARD_CAN_GET then
                    bRet = true
                    break
                end
            end
        end
    end
    return bRet
end

function DailyRechargeModel:askRefreshActivityCenter(bShow)
    local activityCenterModel = import('src.app.plugins.activitycenter.ActivityCenterModel'):getInstance()
    if activityCenterModel:isNeedRefresh(DailyRechargeDef.ID_IN_ACTIVITY_CENTER,bShow) then
        activityCenterModel:setMatrixActivityNeedShow(DailyRechargeDef.ID_IN_ACTIVITY_CENTER,bShow)
    end
end

function DailyRechargeModel:getRspStatus()
    return self._rspStatus
end

function DailyRechargeModel:getJsonData()
    if not self._data then
        local rspStatus = self._rspStatus
        if not rspStatus or type(rspStatus.jsonstr) ~= "string" or string.len(rspStatus.jsonstr) <= 0 then
            print("DailyRechargeModel:getRspData get json error")
            return nil
        end 
        local data = json.decode(rspStatus.jsonstr)
        self._data = data
        if data == nil then
            print("DailyRechargeModel:getRspData parse json error")
            return nil
        end
    end
    return self._data
end

function DailyRechargeModel:getTaskStatus(status, taskid)
    if not status or not taskid then return DailyRechargeDef.REWARD_CANNOT_GET end
    local lshTemp = bit.lshift(3, (taskid - 1) * 2)
    local bandTemp = bit.band(status, lshTemp)
    local taskStatusTemp = bit.rshift(bandTemp, (taskid - 1) * 2)

    return taskStatusTemp
end

--price 为0未点击
function DailyRechargeModel:getGiftBagClickLogData(excahngeID, price, bCreate)
    local ret = {}
    local t = os.time()
    local user = mymodel('UserModel'):getInstance()
    local clientData = my.getKPIClientData()
    local nRoomID = 0
    if my.isInGame() then
        local PublicInterface = cc.exports.PUBLIC_INTERFACE
        local RoomInfo = PublicInterface.GetCurrentRoomInfo()
        if RoomInfo then
            nRoomID = RoomInfo.nRoomID
        end
    end

    local status = self:getRspStatus()
    if not status or not status.totalcondition then return end

    local nScenesID = 2 --每日礼包A
    if status.totalcondition > 60 then
        nScenesID = 3 --每日礼包B
    end

    ret.Date = os.date("%Y/%m/%d", t)
    ret.Time = os.date("%H:%M:%S", t)
    ret.UserID = user.nUserID
    ret.Create = bCreate and "true" or "false"
    ret.Channel = clientData.Channel
    ret.RoomID = nRoomID
    ret.SelfDeposit = user.nDeposit
    ret.SafeBoxDeposit = user.nSafeboxDeposit
    ret.ScenesID = nScenesID
    ret.ClickBuyGift = price
    ret.PayStatus = 0
    ret.NowDeposit = user.nDeposit

    return ret
    --my.dataLink(cc.exports.DataLinkCodeDef.GIFT_BAG_CLICK, GiftBagClick) --礼包点击事件埋点
end

-- 埋点 begin
function DailyRechargeModel:initLogInfoOnEnter()
    self:clearEvtInfo()
    local func = function ()
        local user = mymodel('UserModel'):getInstance()
        local NobilityPrivilegeModel = import("src.app.plugins.NobilityPrivilege.NobilityPrivilegeModel"):getInstance()
        self._evtTriggerInfo = {
            userid = user.nUserID or 0,
            channel = BusinessUtils:getInstance():getTcyChannel(),
            roomid = 0,
            originsilvers = user.nDeposit or 0,
            isclick = 0,
            clicktime = 0,
            closetime = 0,
            opentime = os.time(),
            viplevel = NobilityPrivilegeModel:GetSelfNobilityPrivilegeLevel(),
            path = 1
        }
        if my.isInGame() then
            local PublicInterface = cc.exports.PUBLIC_INTERFACE
            local RoomInfo = PublicInterface.GetCurrentRoomInfo()
            if RoomInfo then
                self._evtTriggerInfo.roomid = RoomInfo.nRoomID or 0
            end
            self._evtTriggerInfo.path = 3 -- 表示游戏内
        else
            local ActivityCenterModel = import('src.app.plugins.activitycenter.ActivityCenterModel'):getInstance()
            if ActivityCenterModel:pluginNameInParams('dailyrecharge') then
                self._evtTriggerInfo.path = 2 -- 进入房间时触发打开
            else
                self._evtTriggerInfo.path = 1 -- 主动点击打开
            end
        end
        local pbdata = protobuf.encode("pbDailyRecharge.TriggerEvent", self._evtTriggerInfo)
        AssistModel:sendData(DailyRechargeDef.GR_DAILY_RECHARGE_TRIGGER_EVT, pbdata)
    end
    local status, msg = pcall(func)
    if status then
        self._evtTriggerInfoValid = true
    end
end

function DailyRechargeModel:onClickBuyBtn(exchangeid, price)
    self._evtBuyInfo = {
        exchangeid = exchangeid,
        price = price
    }
    local func = function ()
        if self._evtTriggerInfoValid and self._evtTriggerInfo then
            self._evtTriggerInfo.isclick = 1
            self._evtTriggerInfo.clicktime = os.time()
            local pbdata = protobuf.encode("pbDailyRecharge.TriggerEvent", self._evtTriggerInfo)
            AssistModel:sendData(DailyRechargeDef.GR_DAILY_RECHARGE_TRIGGER_EVT, pbdata)
        end
    end
    pcall(func)
end

function DailyRechargeModel:onClickCloseBtn()
    local func = function ()
        if self._evtTriggerInfoValid and self._evtTriggerInfo and (not self._evtClosed) then -- self._evtClosed避免重复调用
            self._evtClosed = true
            self._evtTriggerInfo.closetime = os.time()
            local pbdata = protobuf.encode("pbDailyRecharge.TriggerEvent", self._evtTriggerInfo)
            AssistModel:sendData(DailyRechargeDef.GR_DAILY_RECHARGE_TRIGGER_EVT, pbdata)
        end
    end
    pcall(func)
end

function DailyRechargeModel:_onPayOk()
    local func = function ()
        if self._evtTriggerInfoValid and self._evtTriggerInfo then
            local data = {
                userid = self._evtTriggerInfo.userid,
                channel = self._evtTriggerInfo.channel,
                buytime = os.time(),
                roomid = self._evtTriggerInfo.roomid,
                originsilvers = self._evtTriggerInfo.originsilvers,
                viplevel = self._evtTriggerInfo.viplevel,
                path = self._evtTriggerInfo.path
            }
            if self._evtBuyInfo then 
                data.price = self._evtBuyInfo.price
                data.goodid = self._evtBuyInfo.exchangeid
            end
            local pbdata = protobuf.encode("pbDailyRecharge.PurchaseEvent", data)
            AssistModel:sendData(DailyRechargeDef.GR_DAILY_RECHARGE_PURCHASE_EVT, pbdata)
        end
    end
    pcall(func)
end

function DailyRechargeModel:clearEvtInfo()
    self._evtTriggerInfoValid = false
    self._evtTriggerInfo = nil
    self._evtBuyInfo = nil
    self._evtClosed = false
end

-- 埋点 end

return DailyRechargeModel