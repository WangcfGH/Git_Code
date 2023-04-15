local BankruptcyModel         = class('BankruptcyModel', require('src.app.GameHall.models.BaseModel'))
local BankruptcyDef           = require('src.app.plugins.Bankruptcy.BankruptcyDef')
local AssistModel             = mymodel('assist.AssistModel'):getInstance()
local user                    = mymodel('UserModel'):getInstance()
local deviceModel             = mymodel('DeviceModel'):getInstance()

my.addInstance(BankruptcyModel)

protobuf.register_file('src/app/plugins/Bankruptcy/pbBankruptcy.pb')

function BankruptcyModel:onCreate()
    self._bShow = false     --用于判断当前是否有礼包
    self._rspStatus = nil
    self._rspTakeReward = nil

    self:initAssistResponse()
end

function BankruptcyModel:initAssistResponse()
    self._assistResponseMap = {
        [BankruptcyDef.GR_BANKRUPTCY_REQ_STATUS] = handler(self, self.onBankruptcyStatus),
        [BankruptcyDef.GR_BANKRUPTCY_REQ_APPLY_BAG] = handler(self, self.onApplyBagRet),
        [BankruptcyDef.GR_BANKRUPTCY_PAY_SUCCEED] = handler(self, self.onPlayerPayOK),
    }

    AssistModel:registCtrl(self, self.dealAssistResponse)
end

function BankruptcyModel:reqBankruptcyStatus()
    print("BankruptcyModel:reqBankruptcyStatus")
    if not cc.exports.isBankruptcySupported()  then
        return
    end

    if not self:isNeedReqBag() then
        return
    end
      
    if user.nUserID == nil or user.nUserID < 0 then
        print("userinfo is not ok")
        return
    end

    local data = {
        userid = user.nUserID,
    }
    local pdata = protobuf.encode('pbBankruptcy.ReqStatus', data)
    AssistModel:sendData(BankruptcyDef.GR_BANKRUPTCY_REQ_STATUS, pdata, false)
end

function BankruptcyModel:onBankruptcyStatus(data)
    if string.len(data) == nil then return nil end
    if not cc.exports.isBankruptcySupported() then return end

    local pdata = protobuf.decode('pbBankruptcy.RspStatus', data)
    protobuf.extract(pdata)
    dump(pdata, "BankruptcyModel:onBankruptcyStatus")

    self._rspStatus = pdata
    self._curUserID = pdata.userid
    if type(self._rspStatus.status) == "string" and self._rspStatus.status == "ServiceOK" 
    and type(self._rspStatus.lefttime) == "number" and self._rspStatus.lefttime > 0 then
        self._bShow = true
        self._disappearTime = os.time() + self._rspStatus.lefttime --破产礼包消失的时间
        self:startBankruptcyTimeUpdateTimer()
    else
        self._bShow = false
    end

    self:dispatchEvent({name = BankruptcyDef.BANKRUPTCY_STATUS_RSP})
end

function BankruptcyModel:isNeedReqBag()
    local bRet = true
    if self._rspStatus then
        if self._bShow then
            bRet = false
        elseif type(self._rspStatus.leftcout) == "number" and self._rspStatus.leftcout <= 0 then
            bRet = false
        end
    end
    if self._curUserID then
        if user.nUserID and self._curUserID ~= user.nUserID then
            bRet = true
        end
    end
    print("BankruptcyModel:isNeedReqBag bRet:", bRet)
    return bRet
end

function BankruptcyModel:reqApplyBag(nRoomID)
    print("BankruptcyModel:reqApplyBag roomID:", nRoomID)
    if not cc.exports.isBankruptcySupported()  then
        return
    end

    if not self:isNeedReqBag() then
        return
    end
      
    if user.nUserID == nil or user.nUserID < 0 then
        print("userinfo is not ok")
        return
    end

    if type(nRoomID) ~= "number" then
        print("nRoomID is not ok")
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

    local hardid = ""
    if deviceModel and deviceModel.szHardID then
        hardid = deviceModel.szHardID
    end

    local data = {
        userid = user.nUserID,
        roomid = nRoomID,
        platform = platFormType,
        hardid = hardid,
    }
    local pdata = protobuf.encode('pbBankruptcy.ReqApplyBag', data)
    AssistModel:sendData(BankruptcyDef.GR_BANKRUPTCY_REQ_APPLY_BAG, pdata, false)
end

function BankruptcyModel:onApplyBagRet(data)
    if string.len(data) == nil then return nil end
    if not cc.exports.isBankruptcySupported() then return end

    local pdata = protobuf.decode('pbBankruptcy.RspStatus', data)
    protobuf.extract(pdata)
    dump(pdata, "BankruptcyModel:onApplyBagRet")

    self._rspStatus = pdata
    if type(self._rspStatus.status) == "string" and self._rspStatus.status == "ServiceOK" 
    and type(self._rspStatus.lefttime) == "number" and self._rspStatus.lefttime > 0 then
        self._bShow = true
        self._disappearTime = os.time() + self._rspStatus.lefttime --破产礼包消失的时间
        self:startBankruptcyTimeUpdateTimer()
    else
        self._bShow = false
    end

    self:dispatchEvent({name = BankruptcyDef.BANKRUPTCY_APPLY_BAG_RSP})
end

function BankruptcyModel:onPlayerPayOK(data)
    if string.len(data) == nil then return nil end
    if not cc.exports.isBankruptcySupported() then return end

    local pdata = protobuf.decode('pbBankruptcy.RspTakeAward', data)
    protobuf.extract(pdata)
    dump(pdata, "BankruptcyModel:onPlayerPayOK")

    if not pdata.awards or #pdata.awards ~= 2 then
        print("BankruptcyModel:onPlayerPayOK awardinfo error")
        return
    end

    self._rspTakeReward = pdata
    self._bShow = false
    self._disappearTime = 0
    if self._rspStatus then
        self._rspStatus.leftcout = self._rspTakeReward.leftcout
        self._rspStatus.status = self._rspTakeReward.status
    end

    local playerModel = mymodel("hallext.PlayerModel"):getInstance()
    playerModel:update({'SafeboxInfo','MemberInfo','UserGameInfo'})

    self:dispatchEvent({name = BankruptcyDef.BANKRUPTCY_STATUS_RSP, value = {awards = self._rspTakeReward.awards}})

    local awards = self._rspTakeReward.awards
    local rewardList = {}
    for i=1,2 do
        table.insert( rewardList,{nType = awards[i].rewardtype,nCount = awards[i].rewardcount})
    end 
    my.informPluginByName({pluginName = 'RewardTipCtrl', params = {data = rewardList,showOkOnly = true}})
    -- 埋点
    self:_onPayOk()
end

function BankruptcyModel:getRspStatus()
    return self._rspStatus
end

function BankruptcyModel:isBankruptcyBagShow()
    return self._bShow
end

function BankruptcyModel:onLogoff()
    self._bShow = false
    self._rspStatus = nil
    self._disappearTime = 0
    TimerManager:stopTimer("Timer_BankruptcyModel_LimitTimeUpdate")
end

function BankruptcyModel:startBankruptcyTimeUpdateTimer()
    TimerManager:scheduleLoop("Timer_BankruptcyModel_LimitTimeUpdate", function()
        local lefttime = self:getLeftTime()
        if lefttime <= 0 then
            TimerManager:stopTimer("Timer_BankruptcyModel_LimitTimeUpdate")
            self._bShow = false
            self._rspStatus = nil
            self._disappearTime = 0
            self:dispatchEvent({name = BankruptcyDef.BANKRUPTCY_STATUS_RSP})
        end
        self:dispatchEvent({name = BankruptcyDef.BANKRUPTCY_TIME_UPDATE})
    end, 1.0)
end

function BankruptcyModel:getLeftTime( )
    local lefttime = 0
    if not self._rspStatus or not self._bShow then
        return lefttime
    end
    
    if type(self._disappearTime) == "number" then
        lefttime = self._disappearTime - os.time()
    end
    
    return lefttime
end

function BankruptcyModel:getLeftTimeStr()
    local retStr = ""
    local lefttime = self:getLeftTime()
    if lefttime <= 0 then
        return retStr
    end

    local hours = math.modf(lefttime/3600)
    local mins = math.modf((lefttime - hours*3600)/60)
    local secs = lefttime - hours*3600 - mins*60
    if tonumber(hours) < 10 then
        hours = "0"..hours
    end
    if tonumber(mins) < 10 then
        mins = "0"..mins
    end
    if tonumber(secs) < 10 then
        secs = "0"..secs
    end
    local time = hours..":"..mins..":"..secs
    return time
end

function BankruptcyModel:setExchangeID(exchangeID)
    self._exchangeID = exchangeID
end

function BankruptcyModel:isBankruptcyRechargeResult(goodID)
    if type(self._exchangeID) == 'number' and self._exchangeID == goodID then
        return true
    end
    return false
end

--price 为0未点击
function BankruptcyModel:getGiftBagClickLogData(excahngeID, price, bCreate)
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

    local nScenesID = 5 --高级破产礼包
    local lowlist = {12966, 12952, 12959}
    for i=1,#lowlist do
        if lowlist[i] == excahngeID then
            nScenesID = 4
            break
        end
    end

    ret.Date = os.date("%Y/%m/%d", t)
    ret.Time = os.date("%H:%M:%S", t)
    ret.LeftTime = self:getLeftTimeStr() --破产礼包剩余时间
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

-- 破产礼包埋点 begin
function BankruptcyModel:initLogInfoOnEnter(bEnterRoomInHall)
    self._evtTriggerEvtInfo = nil
    self._evtBuyInfo = nil
    local func = function ()
        local user = mymodel('UserModel'):getInstance()
        local NobilityPrivilegeModel = import("src.app.plugins.NobilityPrivilege.NobilityPrivilegeModel"):getInstance()
        self._evtTriggerEvtInfo = {
            userid = user.nUserID or 0,
            channel = BusinessUtils:getInstance():getTcyChannel(),
            roomid = 0,
            originsilvers = user.nDeposit,
            isclick = 0,
            clicktime = 0,
            closetime = 0,
            opentime = os.time(),
            viplevel = NobilityPrivilegeModel:GetSelfNobilityPrivilegeLevel(),
            path = 1
        }
        if my.isInGame() then
            local PublicInterface = cc.exports.PUBLIC_INTERFACE
            if PublicInterface then
                local RoomInfo = PublicInterface.GetCurrentRoomInfo()
                if RoomInfo then
                    self._evtTriggerEvtInfo.roomid = RoomInfo.nRoomID or 0
                end
            end
            self._evtTriggerEvtInfo.path = 3 -- 表示游戏内
        else
            if bEnterRoomInHall then
                self._evtTriggerEvtInfo.path = 2 -- 进入房间时触发
            else
                self._evtTriggerEvtInfo.path = 1 -- 主动点击房间按钮
            end
        end
        local pbdata = protobuf.encode("pbBankruptcy.TriggerEvent", self._evtTriggerEvtInfo)
        AssistModel:sendData(BankruptcyDef.GR_BANKRUPTCY_TRIGGER_EVT, pbdata)
    end
    local status, msg = pcall(func)
    if not status then
        self._evtTriggerEvtInfo = nil
        print("[BankruptcyModel] call func error:", msg)
    end
end

function BankruptcyModel:onClickBuyBtn(exchangeid, price)
    self._evtBuyInfo = {
        exchangeid = exchangeid,
        price = price
    }
    local func = function ()
        if self._evtTriggerEvtInfo then
            self._evtTriggerEvtInfo.isclick = 1
            self._evtTriggerEvtInfo.clicktime = os.time()
            self._evtTriggerEvtInfo.closetime = os.time() -- 点击购买时会关闭界面
            local pbdata = protobuf.encode("pbBankruptcy.TriggerEvent", self._evtTriggerEvtInfo)
            AssistModel:sendData(BankruptcyDef.GR_BANKRUPTCY_TRIGGER_EVT, pbdata)
        end
    end
    local status, msg = pcall(func)
    if not status then
        print("[BankruptcyModel] call func error:", msg)
    end
end

function BankruptcyModel:onClickCloseBtn()
    local func = function ()
        if self._evtTriggerEvtInfo then
            self._evtTriggerEvtInfo.closetime = os.time()
            local pbdata = protobuf.encode("pbBankruptcy.TriggerEvent", self._evtTriggerEvtInfo)
            AssistModel:sendData(BankruptcyDef.GR_BANKRUPTCY_TRIGGER_EVT, pbdata)
        end
    end
    local status, msg = pcall(func)
    if not status then
        print("[BankruptcyModel] call func error:", msg)
    end
end

function BankruptcyModel:_onPayOk()
    local func = function ()
        local user = mymodel('UserModel'):getInstance()
        local NobilityPrivilegeModel = import("src.app.plugins.NobilityPrivilege.NobilityPrivilegeModel"):getInstance()
        local data = {
            userid = user.nUserID or 0,
            channel = BusinessUtils:getInstance():getTcyChannel(),
            buytime = os.time(),
            roomid = (self._evtTriggerEvtInfo and self._evtTriggerEvtInfo.roomid or 0),
            originsilvers = (self._evtTriggerEvtInfo and self._evtTriggerEvtInfo.originsilvers or 0),
            price = (self._evtBuyInfo and self._evtBuyInfo.exchangeid or 0),
            goodid = (self._evtBuyInfo and self._evtBuyInfo.price or 0),
            viplevel = NobilityPrivilegeModel:GetSelfNobilityPrivilegeLevel(),
            path = (self._evtTriggerEvtInfo and self._evtTriggerEvtInfo.path or 1)
        }
        local pbdata = protobuf.encode("pbBankruptcy.PurchaseEvent", data)
        AssistModel:sendData(BankruptcyDef.GR_BANKRUPTCY_BUY_EVT, pbdata)
    end
    local status, msg = pcall(func)
    if not status then
        print("[BankruptcyModel] call func error:", msg)
    end
end

-- 破产礼包埋点 end

return BankruptcyModel