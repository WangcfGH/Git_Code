local WeekCardModel         = class('WeekCardModel', require('src.app.GameHall.models.BaseModel'))
local WeekCardDef           = require('src.app.plugins.WeekCard.WeekCardDef')
local AssistModel             = mymodel('assist.AssistModel'):getInstance()
local user                    = mymodel('UserModel'):getInstance()
local deviceModel             = mymodel('DeviceModel'):getInstance()
local RewardTipDef = import("src.app.plugins.RewardTip.RewardTipDef")
local CardRecorderModel          = import("src.app.plugins.shop.cardrecorder.CardRecorderModel"):getInstance()
local ExchangeLotteryModel       = require('src.app.plugins.ExchangeLottery.ExchangeLotteryModel'):getInstance()
local MyTimeStampCtrl = import("src.app.mycommon.mytimestamp.MyTimeStamp"):getInstance()
local MonthCardConn = require("src.app.plugins.monthcard.MonthCardConn"):getInstance()
local PluginProcessModel = mymodel("hallext.PluginProcessModel"):getInstance()

my.addInstance(WeekCardModel)

local coms=cc.load('coms')
local PropertyBinder=coms.PropertyBinder
local WidgetEventBinder=coms.WidgetEventBinder
my.setmethods(WeekCardModel,PropertyBinder)
my.setmethods(WeekCardModel,WidgetEventBinder)

protobuf.register_file('src/app/plugins/WeekCard/pbWeekCard.pb')

function WeekCardModel:onCreate()
    self._rspStatus = nil
    self._data = nil
    self._bShow = false
    self:initAssistResponse()

    self:listenTo(MyTimeStampCtrl, MyTimeStampCtrl.UPDATE_DAY,  handler(self,self.updateDay))
    self:listenTo(MonthCardConn, MonthCardConn.EVENT_MODULESTATUS_CHANGED, handler(self, self.refreshStatus))
end

function WeekCardModel:updateDay()
    self:gc_GetWeekCardInfo()
end


function WeekCardModel:initAssistResponse()
    self._assistResponseMap = {
        [WeekCardDef.GR_WEEKCARD_REQ_STATUS] = handler(self, self.onWeekCardStatus),
        [WeekCardDef.GR_WEEKCARD_REQ_TAKE_DAILY] = handler(self, self.onTakeWeekCardAward),
        [WeekCardDef.GR_WEEKCARD_PAY_SUCCEED] = handler(self, self.onPlayerPayOK),
    }
    AssistModel:registCtrl(self, self.dealAssistResponse)
end

function WeekCardModel:gc_GetWeekCardInfo()
    print("WeekCardModel:gc_GetWeekCardInfo")
    if not cc.exports.isWeekCardSupported()  then
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
    local pdata = protobuf.encode('pbWeekCard.ReqStatus', data)
    AssistModel:sendData(WeekCardDef.GR_WEEKCARD_REQ_STATUS, pdata, false)
end

--获取是否需要弹出周卡
function WeekCardModel:isNeedPopForNewUser(userID)
    local tbl = CacheModel:getCacheByKey("WEEKCARD_HAGD" .. "_" .. userID)
    checktable(tbl)

    return tbl.isNeedPopForNewUser
end

--设置是否需要弹出周卡
function WeekCardModel:setIsNeedPopForNewUser(userID, bNeed)
    local tbl = CacheModel:getCacheByKey("WEEKCARD_HAGD" .. "_" .. userID)
    checktable(tbl)
    tbl.isNeedPopForNewUser = bNeed

    CacheModel:saveInfoToCache("WEEKCARD_HAGD" .. "_" .. userID, tbl)
end

function WeekCardModel:onWeekCardStatus(data)
    if string.len(data) == nil then return nil end
    if not cc.exports.isWeekCardSupported()  then return end

    local pdata = protobuf.decode('pbWeekCard.RspStatus', data)
    protobuf.extract(pdata)
    dump(pdata, "WeekCardModel:onWeekCardStatus")

    self._data = nil
    self._rspStatus = pdata
    self:dispatchEvent({name = WeekCardDef.WEEK_CARD_STATUS_RSP})
    
    self._bShow = false
    self._myStatusDataExtended["isPluginAvail"] = MonthCardConn:getStatusDataExtended("isPluginAvail")
    if type(self._rspStatus.status) == "string" and self._rspStatus.status == WeekCardDef.ServiceOK then
        self._bShow = true
        self._myStatusDataExtended["isPluginAvail"] = true
    end
    if (self:canTakeAward() or self:canBuyWeekCard()) then
        PluginProcessModel:setPluginReadyStatus("WeekCard", true)
        PluginProcessModel:startPluginProcess()
    else
        PluginProcessModel:setPluginReadyStatus("WeekCard", false)
        PluginProcessModel:startPluginProcess() 
    end
    self:refreshRedDot()
end

function WeekCardModel:refreshStatus()
    if not self._myStatusDataExtended["isPluginAvail"] then
        self._myStatusDataExtended["isPluginAvail"] = MonthCardConn:getStatusDataExtended("isPluginAvail")
        self:refreshRedDot()
    else
        self:refreshRedDot() 
    end
end

function WeekCardModel:refreshRedDot()
    self._myStatusDataExtended["isNeedReddot"] = (MonthCardConn:getStatusDataExtended("isNeedReddot")
     or self:canTakeAward())
    self:dispatchModuleStatusChanged("weekCard", "weekCard_rewardAvailChanged")
end

function WeekCardModel:isWeekCardShow()
    return self._bShow
end

function WeekCardModel:canTakeAward()
    if not self._rspStatus or not self:isWeekCardShow() then return false end
    local diff = math.min(7, self._rspStatus.current_day + 1)
    local bRet = false
    for i = 1, diff do 
        local bCanTake = self:getTaskStatus(self._rspStatus.award_status, i)
        if bCanTake == WeekCardDef.REWARD_CAN_GET then
            bRet = true
            break
        end
    end
    return bRet
end

function WeekCardModel:canBuyWeekCard()
    if not self._rspStatus or not self:isWeekCardShow() then return false end
    local bRet = true
    for i = 1, 7 do 
        local bCanTake = self:getTaskStatus(self._rspStatus.award_status, i)
        if bCanTake == WeekCardDef.REWARD_CAN_GET then
            bRet = false
            break
        end
    end
    
    if self._rspStatus.current_day < 0 then
        return true
    elseif self._rspStatus.current_day >= 0 and self._rspStatus.current_day <= 6 then
        return false
    elseif self._rspStatus.current_day > 6 then
        return bRet
    end
    return false
end

--是否可以使用专属表情
function WeekCardModel:canUseSpecialEmoji()
    if not self._rspStatus or not self:isWeekCardShow() then return false end
    if self._rspStatus.current_day < 0 then
        return false
    elseif self._rspStatus.current_day >= 0 and self._rspStatus.current_day <= 6 then
        return true
    elseif self._rspStatus.current_day > 6 then
        return false
    end
end

function WeekCardModel:gc_TakeDailyAward()
    print("WeekCardModel:gc_TakeDailyAward")
    if not cc.exports.isWeekCardSupported()  then
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
    local pdata = protobuf.encode('pbWeekCard.ReqStatus', data)
    AssistModel:sendData(WeekCardDef.GR_WEEKCARD_REQ_TAKE_DAILY, pdata, false)
end

function WeekCardModel:onTakeWeekCardAward(data)
    if string.len(data) == nil then return nil end
    if not cc.exports.isWeekCardSupported()  then return end

    local pdata = protobuf.decode('pbWeekCard.RspTakeAward', data)
    protobuf.extract(pdata)
    dump(pdata, "WeekCardModel:onTakeWeekCardAward")

    if pdata.take_status == WeekCardDef.TakeSucceed then
        if not self._rspStatus then return end
        self._rspStatus.award_status = pdata.award_status
        self._rspStatus.current_day = pdata.current_day
        self._rspStatus.bout_count = pdata.bout_count
        self._rspStatus.jsonstr = pdata.jsonstr

        self._data = nil
        self:dispatchEvent({name = WeekCardDef.WEEK_CARD_STATUS_RSP})
        self:refreshRedDot()

        if #pdata.awards == 2 then
            local rewardList = {}
            local v = pdata.awards[2]
            table.insert( rewardList,{nType = v.rewardtype,nCount = v.rewardcount})
            if v.rewardtype == RewardTipDef.TYPE_REWARDTYPE_LOTTERY_TIME then
                ExchangeLotteryModel:addSeizeCount(v.rewardcount)
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
        
    elseif pdata.take_status == WeekCardDef.TaskNotComplete then
        my.informPluginByName({pluginName='TipPlugin',params={tipString="任务未完成！",removeTime=1}})
    elseif pdata.take_status == WeekCardDef.TaskRewarded then
        my.informPluginByName({pluginName='TipPlugin',params={tipString="奖励已领取！",removeTime=1}})
    elseif pdata.take_status == WeekCardDef.TakeFail then
        my.informPluginByName({pluginName='TipPlugin',params={tipString="服务器繁忙，请稍后再试！",removeTime=1}})
    end
    
end

function WeekCardModel:onPlayerPayOK(data)
    if string.len(data) == nil then return nil end
    if not cc.exports.isWeekCardSupported()  then return end

    local pdata = protobuf.decode('pbWeekCard.RspTakeAward', data)
    protobuf.extract(pdata)
    dump(pdata, "WeekCardModel:onPlayerPayOK")
    if not self._rspStatus then return end

    self._rspStatus.status = pdata.status
    self._rspStatus.award_status = pdata.award_status 
    
    if pdata.jsonstr and type(pdata.jsonstr) == "string" and string.len(pdata.jsonstr) > 0 then
        self._data = nil
        self._rspStatus.jsonstr = pdata.jsonstr
        self._rspStatus.current_day = pdata.current_day
        self._rspStatus.bout_count = pdata.bout_count
    end

    if #pdata.awards > 0 then
        local rewardList = {}
        for u, v in pairs(pdata.awards) do
            table.insert( rewardList,{nType = v.rewardtype,nCount = v.rewardcount})
            if v.rewardtype == RewardTipDef.TYPE_REWARDTYPE_LOTTERY_TIME then
                ExchangeLotteryModel:addSeizeCount(v.rewardcount)
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
    self:dispatchEvent({name = WeekCardDef.WEEK_CARD_STATUS_RSP, value = {awards = pdata.awards}})
    self:refreshRedDot()
end

function WeekCardModel:setExchangeID(exchangeID)
    self._exchangeID = exchangeID
end

function WeekCardModel:isWeekCardRechargeResult(goodID)
    if type(self._exchangeID) == 'number' and self._exchangeID == goodID then
        return true
    end
    return false
end

function WeekCardModel:getRspStatus()
    return self._rspStatus
end

function WeekCardModel:getJsonData()
    if not self._data then
        local rspStatus = self._rspStatus
        if not rspStatus or type(rspStatus.jsonstr) ~= "string" or string.len(rspStatus.jsonstr) <= 0 then
            print("WeekCardModel:getRspData get json error")
            return nil
        end 
        local data = json.decode(rspStatus.jsonstr)
        self._data = data
        if data == nil then
            print("WeekCardModel:getRspData parse json error")
            return nil
        end
    end
    return self._data
end

function WeekCardModel:getTaskStatus(status, taskid)
    if not status or not taskid then return WeekCardDef.REWARD_CANNOT_GET end
    local lshTemp = bit.lshift(3, (taskid - 1) * 2)
    local bandTemp = bit.band(status, lshTemp)
    local taskStatusTemp = bit.rshift(bandTemp, (taskid - 1) * 2)

    return taskStatusTemp
end

return WeekCardModel