local WeekMonthSuperCardModel           = class('WeekMonthSuperCardModel', require('src.app.GameHall.models.BaseModel'))
local WeekMonthSuperCardDef             = require('src.app.plugins.WeekMonthSuperCard.WeekMonthSuperCardDef')
local AssistModel                       = mymodel('assist.AssistModel'):getInstance()
local user                              = mymodel('UserModel'):getInstance()
local deviceModel                       = mymodel('DeviceModel'):getInstance()
local RewardTipDef                      = import("src.app.plugins.RewardTip.RewardTipDef")
local ExchangeLotteryModel              = require('src.app.plugins.ExchangeLottery.ExchangeLotteryModel'):getInstance()
local MyTimeStampCtrl                   = import("src.app.mycommon.mytimestamp.MyTimeStamp"):getInstance()
local PluginProcessModel                = mymodel("hallext.PluginProcessModel"):getInstance()

my.addInstance(WeekMonthSuperCardModel)

local coms=cc.load('coms')
local PropertyBinder        =coms.PropertyBinder
local WidgetEventBinder     =coms.WidgetEventBinder
my.setmethods(WeekMonthSuperCardModel,PropertyBinder)
my.setmethods(WeekMonthSuperCardModel,WidgetEventBinder)

protobuf.register_file('src/app/plugins/WeekMonthSuperCard/pbWeekMonthSuperCard.pb')

local UsageType = {
    TCY         = 1,        --单包
    TCYAPP      = 2,        --同城游
    PLATFORMSET = 3,        --合集包
}

function WeekMonthSuperCardModel:onCreate()
    self._config    = nil
    self._info      = nil

    self:listenTo(MyTimeStampCtrl, MyTimeStampCtrl.UPDATE_DAY,  handler(self,self.updateDay))

    self:initAssistResponse()
end

function WeekMonthSuperCardModel:updateDay()
    self:QueryWeekMonthSuperCardConfig()
    self:QueryWeekMonthSuperCardInfo()
end


function WeekMonthSuperCardModel:initAssistResponse()
    self._assistResponseMap = {
        [WeekMonthSuperCardDef.GR_WEEK_MONTH_SUPER_CARD_QUERY_CONFIG] = handler(self, self.OnQueryWeekMonthSuperCardConfig),
        [WeekMonthSuperCardDef.GR_WEEK_MONTH_SUPER_CARD_QUERY_INFO] = handler(self, self.OnQueryWeekMonthSuperCardInfo),
        [WeekMonthSuperCardDef.GR_WEEK_MONTH_SUPER_CARD_AWARD] = handler(self, self.OnTakeDailyAward),
        [WeekMonthSuperCardDef.GR_WEEK_MONTH_SUPER_CARD_PAY_SUCCEED] = handler(self, self.onPlayerPayOK),
    }
    AssistModel:registCtrl(self, self.dealAssistResponse)
end

function WeekMonthSuperCardModel:isOpen()
    if not cc.exports.isWeekMonthSuperCardSupported() then
        return false
    end

    if not self._config or self._config.Enable ~= 1 then
        return false
    end

    return true
end

function WeekMonthSuperCardModel:isNeedReddot()
    if self._config and self._info  then
        if self._config.Enable == 1 then
            if self._info.wCRewardStatus == WeekMonthSuperCardDef.WEEK_MONTH_SUPER_CARD_NOT_REWARD or 
               self._info.mCRewardStatus == WeekMonthSuperCardDef.WEEK_MONTH_SUPER_CARD_NOT_REWARD or  
               self._info.sCRewardStatus == WeekMonthSuperCardDef.WEEK_MONTH_SUPER_CARD_NOT_REWARD then
                return true
            end
        end
    end

    return false
end

function WeekMonthSuperCardModel:QueryWeekMonthSuperCardConfig()
    print("WeekMonthSuperCardModel:QueryWeekMonthSuperCardConfig")
    if not cc.exports.isWeekMonthSuperCardSupported()  then
        return
    end
      
    if user.nUserID == nil or user.nUserID < 0 then
        print("userinfo is not ok")
        return
    end

    local data = {
        userid      = user.nUserID,
    }
    local pdata = protobuf.encode('pbWeekMonthSuperCard.ReqWeekMonthSuperCardConfig', data)
    AssistModel:sendData(WeekMonthSuperCardDef.GR_WEEK_MONTH_SUPER_CARD_QUERY_CONFIG, pdata, false)
end

function WeekMonthSuperCardModel:QueryWeekMonthSuperCardInfo()
    print("WeekMonthSuperCardModel:QueryWeekMonthSuperCardInfo")
    if not cc.exports.isWeekMonthSuperCardSupported()  then
        return
    end
      
    if user.nUserID == nil or user.nUserID < 0 then
        print("userinfo is not ok")
        return
    end
    
    local channelID = self:getChannelID()
    local platFormType = self:getPlatformType()

    local data = {
        userid      = user.nUserID,
        channelID   = channelID,
        platform    = platFormType,
    }
    local pdata = protobuf.encode('pbWeekMonthSuperCard.ReqWeekMonthSuperCardInfo', data)
    AssistModel:sendData(WeekMonthSuperCardDef.GR_WEEK_MONTH_SUPER_CARD_QUERY_INFO, pdata, false)
end

function WeekMonthSuperCardModel:TakeDailyAward(cardType)
    print("WeekMonthSuperCardModel:TakeAward")
    if not cc.exports.isWeekMonthSuperCardSupported()  then
        return
    end
      
    if user.nUserID == nil or user.nUserID < 0 then
        print("userinfo is not ok")
        return
    end

    local channelID = self:getChannelID()
    local platFormType = self:getPlatformType()

    local data = {
        userid      = user.nUserID,
        channelID   = channelID,
        platform    = platFormType,
        cardType    = cardType,
    }
    local pdata = protobuf.encode('pbWeekMonthSuperCard.ReqWeekMonthSuperCardReward', data)
    AssistModel:sendData(WeekMonthSuperCardDef.GR_WEEK_MONTH_SUPER_CARD_AWARD, pdata, false)
end

function WeekMonthSuperCardModel:SaveWeekMonthSuperUserChannelID()
    if not cc.exports.isWeekMonthSuperCardSupported()  then
        return
    end    
    if user.nUserID == nil or user.nUserID < 0 then
        print("userinfo is not ok")
        return
    end

    local platFormType = self:getPlatformType()

    local data = {
        userid      = user.nUserID,
        platform    = platFormType,
        channelID   = my.getTcyChannelId()
    }
    local pdata = protobuf.encode('pbWeekMonthSuperCard.SaveUserChannelID', data)
    AssistModel:sendData(WeekMonthSuperCardDef.GR_WEEK_MONTH_SUPER_CARD_SAVE_CHANNEL_ID, pdata, false)
end

--响应周月至尊卡配置数据获取
function WeekMonthSuperCardModel:OnQueryWeekMonthSuperCardConfig(data)
    if string.len(data) == nil then return nil end
    if not cc.exports.isWeekMonthSuperCardSupported() then return end

    local pdata = json.decode(data)

    dump(pdata, "WeekMonthSuperCardModel:OnQueryWeekMonthSuperCardConfig")

    self._config = pdata    

    local PluginProcessModel = mymodel("hallext.PluginProcessModel"):getInstance()
    if self._config.Enable == 1 then
        PluginProcessModel:setPluginReadyStatus("WeekMonthSuperCardCtrl", true)
        PluginProcessModel:startPluginProcess()   
    else
        PluginProcessModel:setPluginReadyStatus("WeekMonthSuperCardCtrl", false)
        PluginProcessModel:startPluginProcess() 
    end

    self:dispatchEvent({name = WeekMonthSuperCardDef.WEEK_MONTH_SUPER_CARD_QUERY_CONFIG_RSP})
end

function WeekMonthSuperCardModel:OnQueryWeekMonthSuperCardInfo(data)
    if string.len(data) == nil then return nil end
    if not cc.exports.isWeekMonthSuperCardSupported()  then return end

    local pdata = protobuf.decode('pbWeekMonthSuperCard.RespWeekMonthSuperCardInfo', data)
    protobuf.extract(pdata)
    dump(pdata, "WeekMonthSuperCardModel:OnQueryWeekMonthSuperCardInfo")

    self._info = pdata

    self:dispatchEvent({name = WeekMonthSuperCardDef.WEEK_MONTH_SUPER_CARD_QUERY_INFO_RSP})    
end

function WeekMonthSuperCardModel:OnTakeDailyAward(data)
    if string.len(data) == nil then return nil end
    if not cc.exports.isWeekMonthSuperCardSupported()  then return end

    local pdata = protobuf.decode('pbWeekMonthSuperCard.RespWeekMonthSuperCardReward', data)
    protobuf.extract(pdata)
    dump(pdata, "WeekMonthSuperCardModel:OnTakeDailyAward")    

    if pdata.rewardResult == WeekMonthSuperCardDef.TAKE_DAILY_AWARD_RESULT_SUCCESS then
        if self._info then
            local platFormType  = self:getPlatformType()
            local rewardList    = {}
            if pdata.cardType == WeekMonthSuperCardDef.CARD_TYPE_WEEK_CARD then
                self._info.wCRewardStatus   = pdata.cardRewardStatus
                self._info.wCRewardLeftDate = pdata.cardRewardLeftDate                
                if self._config then
                    local rewardConfig = self._config.List[platFormType].WeekPackages.Rewards[2]
                    table.insert(rewardList, {nType = rewardConfig.RewardType, nCount = rewardConfig.RewardCount})
                end                                
            elseif pdata.cardType == WeekMonthSuperCardDef.CARD_TYPE_MONTH_CARD then
                self._info.mCRewardStatus   = pdata.cardRewardStatus
                self._info.mCRewardLeftDate = pdata.cardRewardLeftDate
                if self._config then
                    local rewardConfig = self._config.List[platFormType].MonthPackages.Rewards[2]
                    table.insert(rewardList, {nType = rewardConfig.RewardType, nCount = rewardConfig.RewardCount})
                end 
            elseif pdata.cardType == WeekMonthSuperCardDef.CARD_TYPE_SUPER_CARD then
                self._info.sCRewardStatus   = pdata.cardRewardStatus
                self._info.sCRewardLeftDate = pdata.cardRewardLeftDate
                if self._config then
                    local rewardConfig = self._config.List[platFormType].SuperPackages.Rewards[2]
                    table.insert(rewardList, {nType = rewardConfig.RewardType, nCount = rewardConfig.RewardCount})
                end 
            end

            if #rewardList > 0 then
                my.informPluginByName({pluginName = 'RewardTipCtrl', params = {data = rewardList, showOkOnly = true}})
                my.scheduleOnce(function ()
                    local playerModel = mymodel("hallext.PlayerModel"):getInstance()
                    playerModel:update({'SafeboxInfo','MemberInfo','UserGameInfo'})
                end, 2)    
            end
        end
    elseif pdata.rewardResult == WeekMonthSuperCardDef.TAKE_DAILY_AWARD_RESULT_CLOSE then
        my.informPluginByName({pluginName='ToastPlugin',params={tipString="活动已关闭",removeTime=3}})        
        self:QueryWeekMonthSuperCardConfig()
        self:QueryWeekMonthSuperCardInfo()
    elseif pdata.rewardResult == WeekMonthSuperCardDef.TAKE_DAILY_AWARD_RESULT_NOT_BUY then
        my.informPluginByName({pluginName='ToastPlugin',params={tipString="未购买卡包",removeTime=3}})
        self:QueryWeekMonthSuperCardConfig()
        self:QueryWeekMonthSuperCardInfo()
    elseif pdata.rewardResult == WeekMonthSuperCardDef.TAKE_DAILY_AWARD_RESULT_RECEIVED then
        my.informPluginByName({pluginName='ToastPlugin',params={tipString="奖励已领取",removeTime=3}})
        self:QueryWeekMonthSuperCardConfig()
        self:QueryWeekMonthSuperCardInfo()
    end

    self:dispatchEvent({name = WeekMonthSuperCardDef.WEEK_MONTH_SUPER_CARD_TAKE_AWARD_RSP})
end

function WeekMonthSuperCardModel:onPlayerPayOK(data)
    if string.len(data) == nil then return nil end
    if not cc.exports.isWeekMonthSuperCardSupported()  then return end

    local pdata = protobuf.decode('pbWeekMonthSuperCard.NotifyWeekMonthSuperCardPayOK', data)
    protobuf.extract(pdata)
    dump(pdata, "WeekMonthSuperCardModel:onPlayerPayOK")
    
    if pdata.payResult == WeekMonthSuperCardDef.WEEK_MONTH_SUPER_CARD_BUY_OK then
        if self._info then
            local platFormType  = self:getPlatformType()
            local rewardList    = {}
            if pdata.cardType == WeekMonthSuperCardDef.CARD_TYPE_WEEK_CARD then
                self._info.weekCardStatus   = WeekMonthSuperCardDef.WEEK_MONTH_SUPER_CARD_BUYYED
                self._info.wCRewardStatus   = WeekMonthSuperCardDef.WEEK_MONTH_SUPER_CARD_REWARDED
                self._info.wCRewardLeftDate = self._config.WeekCardRewardDay - 1
                if self._config then
                    local rewardConfig = self._config.List[platFormType].WeekPackages.Rewards[1]
                    table.insert(rewardList, {nType = rewardConfig.RewardType, nCount = rewardConfig.RewardCount})
                    rewardConfig = self._config.List[platFormType].WeekPackages.Rewards[2]
                    table.insert(rewardList, {nType = rewardConfig.RewardType, nCount = rewardConfig.RewardCount})
                end  
            elseif pdata.cardType == WeekMonthSuperCardDef.CARD_TYPE_MONTH_CARD then
                self._info.monthCardStatus = WeekMonthSuperCardDef.WEEK_MONTH_SUPER_CARD_BUYYED
                self._info.mCRewardStatus = WeekMonthSuperCardDef.WEEK_MONTH_SUPER_CARD_REWARDED
                self._info.mCRewardLeftDate = self._config.MonthCardRewardDay -1
                if self._config then
                    local rewardConfig = self._config.List[platFormType].MonthPackages.Rewards[1]
                    table.insert(rewardList, {nType = rewardConfig.RewardType, nCount = rewardConfig.RewardCount})
                    rewardConfig = self._config.List[platFormType].MonthPackages.Rewards[2]
                    table.insert(rewardList, {nType = rewardConfig.RewardType, nCount = rewardConfig.RewardCount})
                end 
            elseif pdata.cardType == WeekMonthSuperCardDef.CARD_TYPE_SUPER_CARD then
                self._info.superCardStatus = WeekMonthSuperCardDef.WEEK_MONTH_SUPER_CARD_BUYYED
                self._info.sCRewardStatus = WeekMonthSuperCardDef.WEEK_MONTH_SUPER_CARD_REWARDED
                self._info.sCRewardLeftDate = self._config.SuperCardRewardDay - 1
                if self._config then
                    local rewardConfig = self._config.List[platFormType].SuperPackages.Rewards[1]
                    table.insert(rewardList, {nType = rewardConfig.RewardType, nCount = rewardConfig.RewardCount})
                    rewardConfig = self._config.List[platFormType].SuperPackages.Rewards[2]
                    table.insert(rewardList, {nType = rewardConfig.RewardType, nCount = rewardConfig.RewardCount})
                end 
            end

            if #rewardList > 0 then
                my.informPluginByName({pluginName = 'RewardTipCtrl', params = {data = rewardList, showOkOnly = true}})
                my.scheduleOnce(function ()
                    local playerModel = mymodel("hallext.PlayerModel"):getInstance()
                    playerModel:update({'SafeboxInfo','MemberInfo','UserGameInfo'})
                end, 2)    
            end
        end
    else
        my.informPluginByName({pluginName='ToastPlugin',params={tipString="购买失败",removeTime=3}})
        self:QueryWeekMonthSuperCardConfig()
        self:QueryWeekMonthSuperCardInfo()
    end

    self:dispatchEvent({name = WeekMonthSuperCardDef.WEEK_MONTH_SUPER_CARD_PAY_PAY_SUCCEED})
end

function WeekMonthSuperCardModel:getPlatformType()
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

    return platFormType
end

function WeekMonthSuperCardModel:getUsageType()
    if  MCAgent:getInstance().getLaunchSubMode and MCAgent:getInstance():getLaunchSubMode() > 0 then
        return UsageType.PLATFORMSET
    end
    if cc.exports.LaunchMode["PLATFORM"] == MCAgent:getInstance():getLaunchMode() then
        return UsageType.TCYAPP
    else
        return UsageType.TCY
    end
end

function WeekMonthSuperCardModel:getChannelID()
    local usageType     = self:getUsageType()
    local subChannelId  = BusinessUtils:getInstance():getRecommenderId()
    local channelId     = subChannelId  --单包的情况
    if usageType ~= 1 then
        channelId = BusinessUtils:getInstance():getTcyChannel()
    end

    return channelId
end

function WeekMonthSuperCardModel:getConfig()
    return self._config
end

function WeekMonthSuperCardModel:getInfo()
    return self._info
end

--银两超过6位数，显示成XX万，保留1位小数，为10.0万时，显示成10万
function WeekMonthSuperCardModel:getSilverNumString(num)
    local tipString
    if num > 99999 then
        num = num / 10000
        local num1, num2 = math.modf(tonumber(string.format("%.1f", num)))
        if math.abs(num2) <= 0.0001 then
            tipString = string.format("%d万", num1)
        else
            tipString = string.format("%.1f万", num1 + num2)
        end
    else
        tipString = string.format("%d", num)
    end
    return tipString
end

-- 获取卡包价格
function WeekMonthSuperCardModel:getCardPrice(cardType)
    local cardPrice     = 0
    local platFormType = self:getPlatformType()
    if self._config then
        if cardType == WeekMonthSuperCardDef.CARD_TYPE_WEEK_CARD then
            cardPrice = self._config.List[platFormType].WeekPackages.Price
        elseif cardType == WeekMonthSuperCardDef.CARD_TYPE_MONTH_CARD then
            cardPrice = self._config.List[platFormType].MonthPackages.Price
        else
            cardPrice = self._config.List[platFormType].SuperPackages.Price
        end
    end
    return cardPrice
end

-- 获取卡包ExchangeID
function WeekMonthSuperCardModel:getCardExchangeID(cardType)
    local cardExchangeID     = 0
    local platFormType = self:getPlatformType()
    if self._config then
        if cardType == WeekMonthSuperCardDef.CARD_TYPE_WEEK_CARD then
            cardExchangeID = self._config.List[platFormType].WeekPackages.ExchangeID
        elseif cardType == WeekMonthSuperCardDef.CARD_TYPE_MONTH_CARD then
            cardExchangeID = self._config.List[platFormType].MonthPackages.ExchangeID
        else
            cardExchangeID = self._config.List[platFormType].SuperPackages.ExchangeID
        end
    end
    return cardExchangeID
end

-- 获取卡包立即获得银两和每日获得银两
function WeekMonthSuperCardModel:getOnceSliverDailySliver(cardType)
    local onceSliver    = 0
    local dailySliver   = 0
    local platFormType = self:getPlatformType()
    if self._config then
        if cardType == WeekMonthSuperCardDef.CARD_TYPE_WEEK_CARD then
            local rewardConfig = self._config.List[platFormType].WeekPackages.Rewards
            onceSliver  = rewardConfig[1].RewardCount
            dailySliver = rewardConfig[2].RewardCount
        elseif cardType == WeekMonthSuperCardDef.CARD_TYPE_MONTH_CARD then
            local rewardConfig = self._config.List[platFormType].MonthPackages.Rewards
            onceSliver  = rewardConfig[1].RewardCount
            dailySliver = rewardConfig[2].RewardCount
        else
            local rewardConfig = self._config.List[platFormType].SuperPackages.Rewards
            onceSliver  = rewardConfig[1].RewardCount
            dailySliver = rewardConfig[2].RewardCount
        end
    end
    
    return onceSliver, dailySliver
end

-- 计算卡包获取银子总额
function WeekMonthSuperCardModel:calcCardTotalSliver(cardType)
    local totalSliver   = 0
    local platFormType = self:getPlatformType()
    if self._config then
        if cardType == WeekMonthSuperCardDef.CARD_TYPE_WEEK_CARD then
            local rewardConfig = self._config.List[platFormType].WeekPackages.Rewards
            totalSliver = rewardConfig[1].RewardCount + rewardConfig[2].RewardCount * self._config.WeekCardRewardDay 
        elseif cardType == WeekMonthSuperCardDef.CARD_TYPE_MONTH_CARD then
            local rewardConfig = self._config.List[platFormType].MonthPackages.Rewards
            totalSliver = rewardConfig[1].RewardCount + rewardConfig[2].RewardCount * self._config.MonthCardRewardDay 
        else
            local rewardConfig = self._config.List[platFormType].SuperPackages.Rewards
            totalSliver = rewardConfig[1].RewardCount + rewardConfig[2].RewardCount * self._config.SuperCardRewardDay 
        end
    end

    return totalSliver
end

function WeekMonthSuperCardModel:isWeekMonthSuperRechargeResult(goodID)
    if self._config and self._config.List  then
        for i=1, #self._config.List do
            if self._config.List[i].WeekPackages.ExchangeID == goodID then
                return true
            end

            if self._config.List[i].MonthPackages.ExchangeID == goodID then
                return true
            end

            if self._config.List[i].SuperPackages.ExchangeID == goodID then
                return true
            end
        end
    end
    
    return false
end

return WeekMonthSuperCardModel