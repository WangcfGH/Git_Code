local LuckyPackModel        = class('LuckyPackModel', require('src.app.GameHall.models.BaseModel'))
local LuckyPackDef          = require('src.app.plugins.LuckyPack.LuckyPackDef')
local RewardTipDef          = import("src.app.plugins.RewardTip.RewardTipDef")
local AssistModel           = mymodel('assist.AssistModel'):getInstance()
local user                  = mymodel('UserModel'):getInstance()
local deviceModel           = mymodel('DeviceModel'):getInstance()

my.addInstance(LuckyPackModel)

protobuf.register_file('src/app/plugins/LuckyPack/pbLuckyPack.pb')

function LuckyPackModel:onCreate()
    self._lastLoginUserID           = nil       -- 最后登陆用户ID
    self._config                    = nil       -- 配置信息
    self._stateUpdateDate           = 0         -- 购买状态更新日期
    self._state                     = 0         -- 购买状态
    self._totalSliver               = 0         -- 购买总银两
    self._discount                  = 0         -- 折扣
    self._tempLotteryInfo           = nil       -- 幸运礼包抽取信息(临时)
    self._savedLotteryInfo          = nil       -- 幸运礼包抽取信息(已同步至chunksvr)
    self._curDateFirstLotteryInfo   = nil       -- 幸运红包今日首次抽奖信息
    self._curDataSpecialLotteryState= 0         -- 幸运红包今日特殊抽奖状态
    self._curDataLotteryTime        = 0         -- 幸运红包今日特殊抽奖次数
    self._curDateLastBuyInfo        = nil       -- 幸运红包今日最后购买信息
    self._maxLotteryTime            = 0         -- 幸运红包最大抽奖次数
    self._specialLotteryLimit       = 0         -- 幸运红包首次红包N次内进行特殊抽奖
    self._curBuyState               = 0         -- 本次新云红包购买状态

    -- 注册回调
    self:initAssistResponse()
end

-- 登陆用户改变
function LuckyPackModel:loginUserChange()
    if self._lastLoginUserID and self._lastLoginUserID ~= user.nUserID then
        self._config                    = nil           -- 配置信息
        self._stateUpdateDate           = 0             -- 购买状态更新日期
        self._state                     = 0             -- 购买状态
        self._totalSliver               = 0             -- 购买总银两
        self._discount                  = 0             -- 折扣
        self._tempLotteryInfo           = nil           -- 幸运礼包抽取信息(临时)
        self._savedLotteryInfo          = nil           -- 幸运礼包抽取信息(已同步至chunksvr)       
        self._curDateFirstLotteryInfo   = nil           -- 幸运红包今日首次抽奖信息
        self._curDataSpecialLotteryState= 0             -- 幸运红包今日特殊抽奖状态
        self._curDataLotteryTime        = 0             -- 幸运红包今日特殊抽奖次数
        self._curDateLastBuyInfo        = nil           -- 幸运红包今日最后购买信息
        self._maxLotteryTime            = 0         -- 幸运红包最大抽奖次数
        self._specialLotteryLimit       = 0         -- 幸运红包首次红包N次内进行特殊抽奖
        self._curBuyState               = 0         -- 本次新云红包购买状态
    end

    self._lastLoginUserID   = user.nUserID      -- 最后登陆用户ID
end

-- 注册回调
function LuckyPackModel:initAssistResponse()
    self._assistResponseMap = {
        [LuckyPackDef.GR_LUCKY_PACK_QUERY_CONFIG] = handler(self, self.onLuckyPackConfig),
        [LuckyPackDef.GR_LUCKY_PACK_QUERY_STATE] = handler(self, self.onLuckyPackState),
        [LuckyPackDef.GR_LUCKY_PACK_SAVE_LOTTERY_INFO] = handler(self, self.onSaveLotteryInfo),
        [LuckyPackDef.GR_LUCKY_PACK_AWARD] = handler(self, self.onPlayerPayOK),
        [LuckyPackDef.GR_LUCKY_PACK_QUERY_FL_INFO_AND_SL_STATE] = handler(self, self.onLuckyPackFLInfoAndSLState),
        [LuckyPackDef.GR_LUCKY_PACK_QUERY_LB_STATE_AND_LB_INFO] = handler(self, self.onLuckyPackLBStateAndLBInfo),
    }

    AssistModel:registCtrl(self, self.dealAssistResponse)
end

--请求幸运礼包配置数据
function LuckyPackModel:reqLuckyPackConfig()
    print("LuckyPackModel:reqLuckyPackConfig")
    if not cc.exports.isLuckyPackSupported()  then
        return
    end
      
    if user.nUserID == nil or user.nUserID < 0 then
        print("userinfo is not ok")
        return
    end

    local data = {
        userid = user.nUserID,
    }
    local pdata = protobuf.encode('pbLuckyPack.ReqLuckyPackConfig', data)
    AssistModel:sendData(LuckyPackDef.GR_LUCKY_PACK_QUERY_CONFIG, pdata, false)
end

--响应幸运礼包配置数据获取
function LuckyPackModel:onLuckyPackConfig(data)
    if string.len(data) == nil then return nil end
    if not cc.exports.isLuckyPackSupported() then return end

    local pdata = json.decode(data)

    dump(pdata, "LuckyPackModel:onLuckyPackConfig")

    self._config = pdata
    self._maxLotteryTime = self._config.MaxLotteryTime
    self._specialLotteryLimit = self._config.SpecialLotteryLimit

    local curDate = os.date('%Y%m%d',os.time())
    local cacheDate = self:getCacheLoginOpenDate()
    local firstBuyDate = self:getCacheFirstBuyDate()
    if cacheDate == nil or toint(cacheDate) ~= toint(curDate) then
        if self._config.Enable == 1 then
            local PluginProcessModel = mymodel("hallext.PluginProcessModel"):getInstance()
            PluginProcessModel:setPluginReadyStatus("LuckyPackCtrl", true)
            PluginProcessModel:startPluginProcess()
            self:setCacheLoginOpenDate(curDate)
        end
    elseif firstBuyDate and toint(firstBuyDate) == toint(curDate) then
        if self._config.Enable == 1 then
            local PluginProcessModel = mymodel("hallext.PluginProcessModel"):getInstance()
            PluginProcessModel:setPluginReadyStatus("LuckyPackCtrl", true)
            PluginProcessModel:startPluginProcess()
            self:setCacheFirstBuyDate(0)
        end
    end

    self:dispatchEvent({name = LuckyPackDef.LUCKY_PACK_QUERY_CONFIG_RSP})
end

--请求幸运礼包购买状态数据
function LuckyPackModel:reqLuckyPackState()
    print("LuckyPackModel:reqLuckyPackState")
    if not cc.exports.isLuckyPackSupported()  then
        return
    end
      
    if user.nUserID == nil or user.nUserID < 0 then
        print("userinfo is not ok")
        return
    end

    local data = {
        userid = user.nUserID,
    }
    local pdata = protobuf.encode('pbLuckyPack.ReqLuckyPackState', data)
    AssistModel:sendData(LuckyPackDef.GR_LUCKY_PACK_QUERY_STATE, pdata, false)
end

--响应幸运礼包购买状态获取
function LuckyPackModel:onLuckyPackState(data)
    if string.len(data) == nil then return nil end
    if not cc.exports.isLuckyPackSupported() then return end

    local pdata = protobuf.decode('pbLuckyPack.LuckyPackStateResp', data)
    protobuf.extract(pdata)
    dump(pdata, "LuckyPackModel:onLuckyPackStatus")

    self._state = pdata.state
    self._totalSliver = pdata.totalSliver
    self._discount = pdata.discount
    self._stateUpdateDate = os.date('%Y%m%d',os.time())

    self:dispatchEvent({name = LuckyPackDef.LUCKY_PACK_QUERY_STATE_RSP})
end

--抽取幸运礼包
function LuckyPackModel:LotteryLuckyPack()
    -- 获取当前包类型
    local platFormType = 1      --默认平台安卓包
    if MCAgent:getInstance().getLaunchSubMode and MCAgent:getInstance():getLaunchSubMode() == 1 then
        platFormType = 3        --合集包
    elseif cc.exports.LaunchMode["PLATFORM"] == MCAgent:getInstance():getLaunchMode() then
        if device.platform == 'ios' then
            platFormType = 2    --IOS平台包
        else
            platFormType = 1    --安卓平台包
        end
    end

    -- 获取贵族等级
    local NobilityPrivilegeModel= import("src.app.plugins.NobilityPrivilege.NobilityPrivilegeModel"):getInstance()
    local nobilityLevel = NobilityPrivilegeModel:GetSelfNobilityPrivilegeLevel()
    if nobilityLevel == nil or nobilityLevel < 0 then nobilityLevel = 0 end

    -- 根据包类型选择抽奖项
    local LotteryItemsConfig    = nil
    local ProbabilityConfig     = nil
    local ProbabilityItem       = nil
    if platFormType == LuckyPackDef.LUCKY_PACK_ITEMS_TYPE_AND then
        LotteryItemsConfig = self._config.AndroidItems
        ProbabilityConfig = self._config.AndroidProbability
    elseif platFormType == LuckyPackDef.LUCKY_PACK_ITEMS_TYPE_IOS then
        LotteryItemsConfig = self._config.IOSItems
        ProbabilityConfig = self._config.IOSProbability
    elseif platFormType == LuckyPackDef.LUCKY_PACK_ITEMS_TYPE_HEJI then
        LotteryItemsConfig = self._config.HeJiItems
        ProbabilityConfig = self._config.HeJiProbability
    end

    local commonLottery = LuckyPackDef.LUCKY_PACK_LOTTERY_MODE_COMMON
    if self._state == 0 then    -- 今日未购买幸运红包
        if self._curDateFirstLotteryInfo and self._curDataSpecialLotteryState == 0 and 
           self._curDataLotteryTime > 0 and self._curDataLotteryTime < self._specialLotteryLimit then
            math.randomseed(os.time())
            local specialLotteryInde = math.random(self._curDataLotteryTime + 1, self._specialLotteryLimit)
            if specialLotteryInde == self._curDataLotteryTime + 1 then
                commonLottery = LuckyPackDef.LUCKY_PACK_LOTTERY_MODE_DISCOUNT_FIRST
            end
        end        
    elseif self._state > 0 then -- 今日已购买幸运红包
        commonLottery = LuckyPackDef.LUCKY_PACK_LOTTERY_MODE_PRICE_FIRST
    end

    -- 分模式抽奖
    if commonLottery == LuckyPackDef.LUCKY_PACK_LOTTERY_MODE_COMMON then            -- 普通抽奖模式
        -- 根据贵族等级选择抽奖概率配置项
        ProbabilityItem = ProbabilityConfig[nobilityLevel + 1]

        -- 根据抽奖配置项随机出Index
        local ItemIndexCount = #ProbabilityItem.ItemIndex
        math.randomseed(os.time())
        local Index = math.random(ItemIndexCount)
        local RandomItemIndex = ProbabilityItem.ItemIndex[Index]

        -- 根据抽奖配置项随机出折扣
        local MinDiscount = ProbabilityItem.Discount[1]
        local MaxDiscount = ProbabilityItem.Discount[2]
        math.randomseed(os.time())
        local RandomDiscount = math.random(MinDiscount, MaxDiscount)

        -- 根据原价算出原价(向上取整)和奖励银两(向下取整)
        local originalPrice = math.ceil(LotteryItemsConfig[RandomItemIndex].SpecialPrice / (RandomDiscount / 100))
        local awardSliver = math.floor(LotteryItemsConfig[RandomItemIndex].BuySilver / (RandomDiscount / 100)) - LotteryItemsConfig[RandomItemIndex].BuySilver

        self._tempLotteryInfo               = {}
        self._tempLotteryInfo.userID        = user.nUserID
        self._tempLotteryInfo.plateform     = platFormType
        self._tempLotteryInfo.itemIndex     = RandomItemIndex
        self._tempLotteryInfo.originalPrice = originalPrice
        self._tempLotteryInfo.specialPrice  = LotteryItemsConfig[RandomItemIndex].SpecialPrice
        self._tempLotteryInfo.discount      = RandomDiscount
        self._tempLotteryInfo.buySliver     = LotteryItemsConfig[RandomItemIndex].BuySilver
        self._tempLotteryInfo.awardSliver   = awardSliver
        self._tempLotteryInfo.exchangeID    = LotteryItemsConfig[RandomItemIndex].ExchangeID
        self._tempLotteryInfo.specialLottery= 0
        self._tempLotteryInfo.nobilityLevel = nobilityLevel
    elseif commonLottery == LuckyPackDef.LUCKY_PACK_LOTTERY_MODE_DISCOUNT_FIRST then    -- 优惠于第一次抽取模式
        local firstItemIndex = self._curDateFirstLotteryInfo.itemIndex
        local firstIndex = 1
        local firstDiscount = self._curDateFirstLotteryInfo.discount
        
        -- 根据贵族等级选择抽奖概率配置项
        ProbabilityItem = ProbabilityConfig[nobilityLevel + 1]

        -- 根据抽奖配置项随机出Index
        local ItemIndexCount = #ProbabilityItem.ItemIndex
        firstIndex = ItemIndexCount
        for i=1, ItemIndexCount do
            if ProbabilityItem.ItemIndex[i] > firstItemIndex then
                firstIndex = i
                break                
            end
        end
        local Index = 1
        math.randomseed(os.time())
        Index = math.random(firstIndex, ItemIndexCount)
        local RandomItemIndex = ProbabilityItem.ItemIndex[Index]

        -- 根据抽奖配置项随机出折扣
        local MinDiscount = ProbabilityItem.Discount[1]
        local MaxDiscount = ProbabilityItem.Discount[2]
        if firstDiscount >= MinDiscount then
            MaxDiscount = firstDiscount
        end
        math.randomseed(os.time())
        local RandomDiscount = math.random(MinDiscount, MaxDiscount)

        -- 根据原价算出原价(向上取整)和奖励银两(向下取整)
        local originalPrice = math.ceil(LotteryItemsConfig[RandomItemIndex].SpecialPrice / (RandomDiscount / 100))
        local awardSliver = math.floor(LotteryItemsConfig[RandomItemIndex].BuySilver / (RandomDiscount / 100)) - LotteryItemsConfig[RandomItemIndex].BuySilver

        self._tempLotteryInfo               = {}
        self._tempLotteryInfo.userID        = user.nUserID
        self._tempLotteryInfo.plateform     = platFormType
        self._tempLotteryInfo.itemIndex     = RandomItemIndex
        self._tempLotteryInfo.originalPrice = originalPrice
        self._tempLotteryInfo.specialPrice  = LotteryItemsConfig[RandomItemIndex].SpecialPrice
        self._tempLotteryInfo.discount      = RandomDiscount
        self._tempLotteryInfo.buySliver     = LotteryItemsConfig[RandomItemIndex].BuySilver
        self._tempLotteryInfo.awardSliver   = awardSliver
        self._tempLotteryInfo.exchangeID    = LotteryItemsConfig[RandomItemIndex].ExchangeID        
        self._tempLotteryInfo.specialLottery= 1
        self._tempLotteryInfo.nobilityLevel = nobilityLevel
    elseif commonLottery == LuckyPackDef.LUCKY_PACK_LOTTERY_MODE_PRICE_FIRST then       -- 金额大于上次模式
        local lastItemIndex = self._curDateLastBuyInfo.itemIndex
        local lastIndex = 1
        local lastDiscount = self._curDateLastBuyInfo.discount
        
        -- 根据贵族等级选择抽奖概率配置项
        ProbabilityItem = ProbabilityConfig[nobilityLevel + 1]

        -- 根据抽奖配置项随机出Index
        local ItemIndexCount = #ProbabilityItem.ItemIndex
        lastIndex = ItemIndexCount
        for i=1, ItemIndexCount do
            if ProbabilityItem.ItemIndex[i] > lastItemIndex then
                lastIndex = i
                break
            end
        end
        local Index = 1
        math.randomseed(os.time())
        Index = math.random(lastIndex, ItemIndexCount)
        local RandomItemIndex = ProbabilityItem.ItemIndex[Index]

        -- 根据抽奖配置项随机出折扣
        local MinDiscount = ProbabilityItem.Discount[1]
        local MaxDiscount = ProbabilityItem.Discount[2]
        if lastDiscount >= MinDiscount then
            MaxDiscount = lastDiscount
        end

        math.randomseed(os.time())
        local RandomDiscount = math.random(MinDiscount, MaxDiscount)

        -- 根据原价算出原价(向上取整)和奖励银两(向下取整)
        local originalPrice = math.ceil(LotteryItemsConfig[RandomItemIndex].SpecialPrice / (RandomDiscount / 100))
        local awardSliver = math.floor(LotteryItemsConfig[RandomItemIndex].BuySilver / (RandomDiscount / 100)) - LotteryItemsConfig[RandomItemIndex].BuySilver

        self._tempLotteryInfo               = {}
        self._tempLotteryInfo.userID        = user.nUserID
        self._tempLotteryInfo.plateform     = platFormType
        self._tempLotteryInfo.itemIndex     = RandomItemIndex
        self._tempLotteryInfo.originalPrice = originalPrice
        self._tempLotteryInfo.specialPrice  = LotteryItemsConfig[RandomItemIndex].SpecialPrice
        self._tempLotteryInfo.discount      = RandomDiscount
        self._tempLotteryInfo.buySliver     = LotteryItemsConfig[RandomItemIndex].BuySilver
        self._tempLotteryInfo.awardSliver   = awardSliver
        self._tempLotteryInfo.exchangeID    = LotteryItemsConfig[RandomItemIndex].ExchangeID
        self._tempLotteryInfo.specialLottery= 0
        self._tempLotteryInfo.nobilityLevel = nobilityLevel
    end
end

--同步幸运礼包抽取信息
function LuckyPackModel:reqSaveLotteryInfo()
    print("LuckyPackModel:reqSaveLotteryInfo")
    dump(lotteryInfo, "LuckyPackModel:reqSaveLotteryInfo")
    if not cc.exports.isLuckyPackSupported()  then
        return
    end
      
    if user.nUserID == nil or user.nUserID < 0 then
        print("userinfo is not ok")
        return
    end

    if self._tempLotteryInfo == nil then
        print("lotteryInfo is not ok")
        return
    end

    local data = {
        userid          = user.nUserID,
        plateform       = self._tempLotteryInfo.plateform,
        itemIndex       = self._tempLotteryInfo.itemIndex,
        originalPrice   = self._tempLotteryInfo.originalPrice,
        specialPrice    = self._tempLotteryInfo.specialPrice,
        discount        = self._tempLotteryInfo.discount,
        buySliver       = self._tempLotteryInfo.buySliver,
        awardSliver     = self._tempLotteryInfo.awardSliver,
        exchangeID      = self._tempLotteryInfo.exchangeID,
        specialLottery  = self._tempLotteryInfo.specialLottery,
        nobilityLevel   = self._tempLotteryInfo.nobilityLevel,
    }
    local pdata = protobuf.encode('pbLuckyPack.ReqLuckyPackSaveLotteryInfo', data)
    AssistModel:sendData(LuckyPackDef.GR_LUCKY_PACK_SAVE_LOTTERY_INFO, pdata, false)
end

--响应幸运礼包抽取信息同步
function LuckyPackModel:onSaveLotteryInfo(data)
    if string.len(data) == nil then return nil end
    if not cc.exports.isLuckyPackSupported() then return end

    local pdata = protobuf.decode('pbLuckyPack.LuckyPackSaveLotteryInfoResp', data)
    protobuf.extract(pdata)
    dump(pdata, "LuckyPackModel:onSaveLotteryInfo")

    --同步失败，充值抽奖信息，重新抽奖
    if pdata.result ~= 1 then
        self._tempLotteryInfo   = nil
        self._savedLotteryInfo  = nil
    else
        self._savedLotteryInfo  = self._tempLotteryInfo
        self._tempLotteryInfo   = nil
    end

    self:dispatchEvent({name = LuckyPackDef.LUCKY_PACK_SAVE_LOTTERY_INFO_RSP})

    LuckyPackModel:reqLuckyPackFLInfoAndSLState()   --查询幸运礼包今日首次抽奖信息和今日特殊抽奖状态    
end

function LuckyPackModel:isLuckyPackRechargeResult(goodID)
    if self._config and self._config.AllExchangeIDs  then
        for i=1, #self._config.AllExchangeIDs do
            if self._config.AllExchangeIDs[i] == goodID then
                return true
            end
        end
    end
    
    return false
end

--响应幸运礼包购买成功并发放奖励
function LuckyPackModel:onPlayerPayOK(data)
    if string.len(data) == nil then return nil end
    if not cc.exports.isLuckyPackSupported() then return end

    local pdata = protobuf.decode('pbLuckyPack.LuckyPackBuyResp', data)
    protobuf.extract(pdata)
    dump(pdata, "LuckyPackModel:onPlayerPayOK")

    self._state = self._state + 1
    if self._savedLotteryInfo then
        self._totalSliver = self._savedLotteryInfo.buySliver + self._savedLotteryInfo.awardSliver
        self._discount = self._savedLotteryInfo.discount
    end
    self._stateUpdateDate = os.date('%Y%m%d',os.time())

    local curDate = os.date('%Y%m%d',os.time())
    local cacheDate = self:getCacheDate()
    if cacheDate == nil or toint(cacheDate) ~= toint(curDate) then
        self:setCacheDate(curDate)
        self:setCacheCount(1)
    else
        local cacheCount = self:getCacheCount()
        self:setCacheCount(toint(cacheCount) + 1)
    end

    if self._state == 1 then
        self:setCacheFirstBuyDate(curDate)
    end

    local rewardList = {}
    table.insert( rewardList,{nType = RewardTipDef.TYPE_SILVER, nCount = pdata.buySliver + pdata.awardSliver})

    my.informPluginByName({pluginName = 'RewardTipCtrl', params = {data = rewardList, showOkOnly = true}})

    self._curBuyState = 1

    self:dispatchEvent({name = LuckyPackDef.LUCKY_PACK_AWARD_RSP})

    LuckyPackModel:reqLuckyPackLBStateAndLBInfo()   --查询幸运礼包今日最后购买状态和今日最后购买信息
end

--请求幸运礼包今日首次抽奖信息和今日特殊抽奖状态
function LuckyPackModel:reqLuckyPackFLInfoAndSLState()
    print("LuckyPackModel:reqLuckyPackFLInfoAndSLState")
    if not cc.exports.isLuckyPackSupported()  then
        return
    end
      
    if user.nUserID == nil or user.nUserID < 0 then
        print("userinfo is not ok")
        return
    end

    local data = {
        userid = user.nUserID,
    }
    local pdata = protobuf.encode('pbLuckyPack.ReqLuckyPackFLInfoAndSLState', data)
    AssistModel:sendData(LuckyPackDef.GR_LUCKY_PACK_QUERY_FL_INFO_AND_SL_STATE, pdata, false)
end

--响应幸运礼包今日首次抽奖信息和今日特殊抽奖状态
function LuckyPackModel:onLuckyPackFLInfoAndSLState(data)
    if string.len(data) == nil then return nil end
    if not cc.exports.isLuckyPackSupported() then return end

    local pdata = protobuf.decode('pbLuckyPack.LuckyPackFLInfoAndSLStateResp', data)
    protobuf.extract(pdata)
    dump(pdata, "LuckyPackModel:onLuckyPackFLInfoAndSLState")

    if pdata.FLotteryState > 0 then
        self._curDateFirstLotteryInfo = {}
        self._curDateFirstLotteryInfo.plateform = pdata.plateform
        self._curDateFirstLotteryInfo.itemIndex = pdata.itemIndex
        self._curDateFirstLotteryInfo.originalPrice = pdata.originalPrice
        self._curDateFirstLotteryInfo.specialPrice = pdata.specialPrice
        self._curDateFirstLotteryInfo.discount = pdata.discount
        self._curDateFirstLotteryInfo.buySliver = pdata.buySliver
        self._curDateFirstLotteryInfo.awardSliver = pdata.awardSliver
        self._curDateFirstLotteryInfo.exchangeID = pdata.exchangeID
    end
    
    self._curDataSpecialLotteryState = pdata.SLotteryState

    self._curDataLotteryTime         = pdata.lotteryTime

    self:dispatchEvent({name = LuckyPackDef.LUCKY_PACK_QUERY_FL_INFO_AND_SL_STATE_RSP})
end

--请求幸运礼包今日最后购买状态和今日最后购买信息
function LuckyPackModel:reqLuckyPackLBStateAndLBInfo()
    print("LuckyPackModel:reqLuckyPackState")
    if not cc.exports.isLuckyPackSupported()  then
        return
    end
      
    if user.nUserID == nil or user.nUserID < 0 then
        print("userinfo is not ok")
        return
    end

    local data = {
        userid = user.nUserID,
    }
    local pdata = protobuf.encode('pbLuckyPack.ReqLuckyPackLBStateAndLBInfo', data)
    AssistModel:sendData(LuckyPackDef.GR_LUCKY_PACK_QUERY_LB_STATE_AND_LB_INFO, pdata, false)
end

--响应幸运礼包今日最后购买状态和今日最后购买信息
function LuckyPackModel:onLuckyPackLBStateAndLBInfo(data)
    if string.len(data) == nil then return nil end
    if not cc.exports.isLuckyPackSupported() then return end

    local pdata = protobuf.decode('pbLuckyPack.LuckyPackLBStateAndLBInfoResp', data)
    protobuf.extract(pdata)
    dump(pdata, "LuckyPackModel:onLuckyPackLBStateAndLBInfo")

    if pdata.sLBState > 0 then
        self._curDateLastBuyInfo = {}
        self._curDateLastBuyInfo.plateform = pdata.plateform
        self._curDateLastBuyInfo.itemIndex = pdata.itemIndex
        self._curDateLastBuyInfo.originalPrice = pdata.originalPrice
        self._curDateLastBuyInfo.specialPrice = pdata.specialPrice
        self._curDateLastBuyInfo.discount = pdata.discount
        self._curDateLastBuyInfo.buySliver = pdata.buySliver
        self._curDateLastBuyInfo.awardSliver = pdata.awardSliver
        self._curDateLastBuyInfo.exchangeID = pdata.exchangeID
    end

    self:dispatchEvent({name = LuckyPackDef.LUCKY_PACK_QUERY_LB_STATE_AND_LB_INFO})
end

-- 获取配置信息
function LuckyPackModel:getConfig()
    return self._config
end

-- 获取状态信息（跨天则重置）
function LuckyPackModel:getState()
    local curDate = os.date('%Y%m%d',os.time())
    if curDate ~= self._stateUpdateDate then
        self._state = 0
        self._stateUpdateDate = os.date('%Y%m%d',os.time())
        self._totalSliver = 0
        self._discount = 0
        self._curDateFirstLotteryInfo   = nil
        self._curDataSpecialLotteryState= 0
        self._curDataLotteryTime        = 0
        self._curDateLastBuyInfo        = nil
    end

    return self._state
end

-- 获取幸运礼包最大抽奖次数
function LuckyPackModel:getMaxLotteryTime()
    return self._maxLotteryTime
end

-- 获取幸运礼包购买总金额
function LuckyPackModel:getTotalSliver()
    return self._totalSliver
end

-- 获取幸运礼包折扣
function LuckyPackModel:getDiscount()
    return self._discount
end

-- 获取抽奖信息
function LuckyPackModel:getLotteryInfo()
    return self._savedLotteryInfo
end

-- 获取本次购买状态
function LuckyPackModel:getCurBuyState()
    return self._curBuyState
end

-- 获取首登自动弹窗最后日期
function LuckyPackModel:getCacheLoginOpenDate()
    if user.nUserID == nil or user.nUserID < 0 then return end

    local cacheDate = CacheModel:getCacheByKey("LuckyPackLoginOpenDate"..user.nUserID)
    return cacheDate
end

-- 设置首登自动弹窗最后日期
function LuckyPackModel:setCacheLoginOpenDate(date)
    if user.nUserID == nil or user.nUserID < 0 then return end
    CacheModel:saveInfoToCache("LuckyPackLoginOpenDate"..user.nUserID, date)
end

-- 获取首次购买后第一次打开游戏自动弹窗最后日期
function LuckyPackModel:getCacheFirstBuyDate()
    if user.nUserID == nil or user.nUserID < 0 then return end

    local cacheDate = CacheModel:getCacheByKey("LuckyPackRirstBuyDate"..user.nUserID)
    return cacheDate
end

-- 设置首次购买后第一次打开游戏自动弹窗最后日期
function LuckyPackModel:setCacheFirstBuyDate(date)
    if user.nUserID == nil or user.nUserID < 0 then return end
    CacheModel:saveInfoToCache("LuckyPackRirstBuyDate"..user.nUserID, date)
end

-- 获取缓存信息日期
function LuckyPackModel:getCacheDate()
    local cacheDate = CacheModel:getCacheByKey("LuckyPackDate")
    return cacheDate
end

-- 设置缓存信息日期
function LuckyPackModel:setCacheDate(date)
    CacheModel:saveInfoToCache("LuckyPackDate", date)
end

-- 获取缓存信息次数
function LuckyPackModel:getCacheCount()
    local cacheCount = CacheModel:getCacheByKey("LuckyPackCount")
    return cacheCount
end

-- 设置缓存信息次数
function LuckyPackModel:setCacheCount(count)
    CacheModel:saveInfoToCache("LuckyPackCount", count)
end

-- 获取购买次数
function LuckyPackModel:getBuyCount()
    local curDate = os.date('%Y%m%d',os.time())
    local cacheDate = self:getCacheDate()
    if cacheDate == nil or toint(cacheDate) ~= toint(curDate) then
        return 0
    end

    local cacheCount = self:getCacheCount()
    if cacheCount == nil then
        return 0
    end

    return toint(cacheCount)
end

-- 幸运礼包是否开启
function LuckyPackModel:isOpen()
    if cc.exports.isLuckyPackSupported() then
        if self._config and toint(self._config.Enable) > 0 then
            return true
        end
        return false
    end

    return false
end

return LuckyPackModel