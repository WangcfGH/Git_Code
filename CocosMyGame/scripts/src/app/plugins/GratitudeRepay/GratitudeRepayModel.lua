local GratitudeRepayModel           = class('GratitudeRepayModel', require('src.app.GameHall.models.BaseModel'))
local GratitudeRepayDef             = require('src.app.plugins.GratitudeRepay.GratitudeRepayDef')
local RewardTipDef                  = import("src.app.plugins.RewardTip.RewardTipDef")
local AssistModel                   = mymodel('assist.AssistModel'):getInstance()
local user                          = mymodel('UserModel'):getInstance()
local deviceModel                   = mymodel('DeviceModel'):getInstance()
local MyTimeStampCtrl               = import("src.app.mycommon.mytimestamp.MyTimeStamp"):getInstance()
local PluginProcessModel            = mymodel("hallext.PluginProcessModel"):getInstance()

my.addInstance(GratitudeRepayModel)

local coms=cc.load('coms')
local PropertyBinder        =coms.PropertyBinder
local WidgetEventBinder     =coms.WidgetEventBinder
my.setmethods(GratitudeRepayModel,PropertyBinder)
my.setmethods(GratitudeRepayModel,WidgetEventBinder)

protobuf.register_file('src/app/plugins/GratitudeRepay/pbGratitudeRepay.pb')

function GratitudeRepayModel:onCreate()
    self._lastLoginUserID           = nil       -- 最后登陆用户ID
    self._config                    = nil       -- 感恩回馈活动配置
    self._info                      = nil       -- 感恩回馈活动信息
    self._lotterySuccessInfo        = nil       -- 抽取成功信息

    self:listenTo(MyTimeStampCtrl, MyTimeStampCtrl.UPDATE_DAY,  handler(self,self.updateDay))

    -- 注册回调
    self:initAssistResponse()
end

-- 登陆用户改变
function GratitudeRepayModel:loginUserChange()
    if self._lastLoginUserID and self._lastLoginUserID ~= user.nUserID then
        self._config                    = nil       -- 感恩回馈活动配置
        self._info                      = nil       -- 感恩回馈活动信息        
    end

    self._lastLoginUserID   = user.nUserID      -- 最后登陆用户ID
end

-- 新的一天重新请求
function GratitudeRepayModel:updateDay()
    self:QueryGratitudeRepayInfo()
end

-- 是否开启感恩回馈活动
function GratitudeRepayModel:isOpen()
    if not cc.exports.isGratitudeRepaySupported() then
        return false
    end

    if not self._config then
        return false
    end

    if self._config.Enable ~= 1 then
        return false
    end

    local currentDay = os.date('%Y%m%d',os.time())
    local nowtimestamp = MyTimeStampCtrl:getLatestTimeStamp()
    if nowtimestamp then
        currentDay = os.date('%Y%m%d',nowtimestamp)
    end

    if toint(currentDay) < toint(self._config.StartDate) or toint(currentDay) > toint(self._config.EndDate) then
        return false
    end

    return true
end

-- 是否显示感恩回馈活动红点
function GratitudeRepayModel:isNeedReddot()
    return false
end

-- 注册回调
function GratitudeRepayModel:initAssistResponse()
    self._assistResponseMap = {
        [GratitudeRepayDef.GR_GRATITUDE_REPAY_QUERY_CONFIG] = handler(self, self.onQueryGratitudeRepayConfig),        
        [GratitudeRepayDef.GR_GRATITUDE_REPAY_QUERY_INFO] = handler(self, self.OnQueryGratitudeRepayInfo),        
        [GratitudeRepayDef.GR_GRATITUDE_REPAY_PAY_SUCCEED] = handler(self, self.onPlayerPayOK),      
    }

    AssistModel:registCtrl(self, self.dealAssistResponse)
end

--请求感恩回馈活动配置
function GratitudeRepayModel:reqGratitudeRepayConfig()
    print("GratitudeRepayModel:reqGratitudeRepayConfig")
    if not cc.exports.isGratitudeRepaySupported() then
        self:startPluginProcess()
        return
    end

    if user.nUserID == nil or user.nUserID < 0 then
        print("userinfo is not ok")
        self:startPluginProcess()
        return
    end

    local data = {
        userid = user.nUserID,
    }
    local pdata = protobuf.encode('pbGratitudeRepay.ReqGratitudeRepayConfig', data)
    AssistModel:sendData(GratitudeRepayDef.GR_GRATITUDE_REPAY_QUERY_CONFIG, pdata, false)
end

--响应感恩回馈活动配置获取
function GratitudeRepayModel:onQueryGratitudeRepayConfig(data)
    if string.len(data) == nil then return nil end
    if not cc.exports.isGratitudeRepaySupported() then return end

    local pdata = json.decode(data)

    dump(pdata, "GratitudeRepayModel:onQueryGratitudeRepayConfig")

    self._config = pdata   

    self:startPluginProcess()
    self:dispatchEvent({name = GratitudeRepayDef.GRATITUDE_REPAY_QUERY_CONFIG_RSP})
end

--请求查询感恩回馈信息
function GratitudeRepayModel:QueryGratitudeRepayInfo()
    print("GratitudeRepayModel:QueryGratitudeRepayInfo")    
    
    local platFormType = self:getPlatformType()

    local data = {
        userid      = user.nUserID,
        channelID   = my.getTcyChannelId(),
        platform    = platFormType
    }
    local pdata = protobuf.encode('pbGratitudeRepay.ReqGratitudeRepayInfo', data)
    AssistModel:sendData(GratitudeRepayDef.GR_GRATITUDE_REPAY_QUERY_INFO, pdata, false)
end

--响应查询感恩回馈信息
function GratitudeRepayModel:OnQueryGratitudeRepayInfo(data)
    if string.len(data) == nil then return nil end
    if not cc.exports.isGratitudeRepaySupported()  then return end

    local pdata = protobuf.decode('pbGratitudeRepay.GratitudeRepayInfoResp', data)
    protobuf.extract(pdata)
    dump(pdata, "GratitudeRepayModel:OnQueryGratitudeRepayInfo")

    self._info = pdata    

    self:dispatchEvent({name = GratitudeRepayDef.GRATITUDE_REPAY_QUERY_INFO_RSP})    
end

-- 感恩回馈活动抽取成功
function GratitudeRepayModel:onPlayerPayOK(data)
    if string.len(data) == nil then return nil end
    if not cc.exports.isGratitudeRepaySupported()  then return end

    local pdata = protobuf.decode('pbGratitudeRepay.NotifyGratitudeRepayPayOK', data)
    protobuf.extract(pdata)
    dump(pdata, "GratitudeRepayModel:onPlayerPayOK")

    if pdata.payResult == GratitudeRepayDef.LOTTERY_SUCCESS then
        if self._config.LotteryCount >= 0 then
            self._info.remainCount = self._info.remainCount - pdata.lotteryCount
        end
        self._lotterySuccessInfo = pdata
    elseif pdata.payResult == GratitudeRepayDef.LOTTERY_COUNT_NOT_ENGOUGH then
        self:QueryGratitudeRepayInfo()
    elseif pdata.payResult == GratitudeRepayDef.LOTTERY_ITEM_INDEX_NOT_SAME then
        self:QueryGratitudeRepayInfo()
    end

    self:dispatchEvent({name = GratitudeRepayDef.GRATITUDE_REPAY_PAY_SUCCEED})    
end

function GratitudeRepayModel:startPluginProcess()
    local PluginProcessModel = mymodel("hallext.PluginProcessModel"):getInstance()
    if self:isOpen() then
        PluginProcessModel:setPluginReadyStatus("GratitudeRepayCtrl", true)
        PluginProcessModel:startPluginProcess()
    else
        PluginProcessModel:setPluginReadyStatus("GratitudeRepayCtrl", false)
        PluginProcessModel:startPluginProcess()
    end
end

-- 判断是否是感恩有礼的计费点
function GratitudeRepayModel:isGratitudeRepayPayResult(goodID)
    if self._config and self._config.LotteryConfig  then
        for i=1, #self._config.LotteryConfig do
            for j=1, #self._config.LotteryConfig[i].AllLevelItems do
                if self._config.LotteryConfig[i].AllLevelItems[j].OneExchangeID == goodID then
                    return true
                end

                if self._config.LotteryConfig[i].AllLevelItems[j].MultExchangeID == goodID then
                    return true
                end
            end
        end
    end

    return false
end

-- 获取配置
function GratitudeRepayModel:getConfig()
    return self._config
end

-- 获取信息
function GratitudeRepayModel:getInfo()
    return self._info
end

-- 获取抽取成功信息
function GratitudeRepayModel:getLotterySuccessInfo()
    return self._lotterySuccessInfo
end

-- 获取今日选中的价格档位信息
function GratitudeRepayModel:todayItemInfo()
    if self._config and self._info then
        local platFormType = self:getPlatformType()
        local todayItemIndex = self._info.selectItemIndex + 1
        return self._config.LotteryConfig[platFormType].AllLevelItems[todayItemIndex]
    end

    return nil
end

-- 获取平台类型
function GratitudeRepayModel:getPlatformType()
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

return GratitudeRepayModel