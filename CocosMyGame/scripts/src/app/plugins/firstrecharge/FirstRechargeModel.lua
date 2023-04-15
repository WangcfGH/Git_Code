local FirstRechargeModel =class('FirstRechargeModel',require('src.app.GameHall.models.BaseModel'))
local AssistModel = mymodel('assist.AssistModel'):getInstance()
local FirstRechargeDef = require('src.app.plugins.firstrecharge.FirstRechargeDef')
--local FirstRechargeReq = require('src.app.plugins.FirstRecharge.FirstRechargeReq')
local user = mymodel('UserModel'):getInstance()
local BroadcastModel = mymodel("hallext.BroadcastModel"):getInstance()
local ShopModel = mymodel("ShopModel"):getInstance()
local CardRecorderModel = import("src.app.plugins.shop.cardrecorder.CardRecorderModel"):getInstance()
local deviceModel                   = mymodel('DeviceModel'):getInstance()

local treepack = cc.load('treepack')
local json = cc.load("json").json

local coms=cc.load('coms')
local PropertyBinder=coms.PropertyBinder

my.setmethods(FirstRechargeModel,PropertyBinder)
my.addInstance(FirstRechargeModel)

--import('src.app.plugins.protobuf.protobuf')
protobuf.register_file('src/app/plugins/firstrecharge/proto/pbNewFirstRecharge.pb')

function FirstRechargeModel:onCreate()
    self._FirstRechargeConfig = nil
    self._FirstRechargeInfo = nil

    self._LimitTimeSpecialConfig = nil
    self._LimitTimeSpecialInfo = nil

    --初始化限时特惠活动的计时器 时间记录点 存在标记
    self._FirstLimitLeftTime = nil
    self._FirstLimitTimer = nil

    self:initAssistResponse()
end

function FirstRechargeModel:reset( )
    self._FirstRechargeConfig = nil
    self._FirstRechargeInfo = nil

    self._LimitTimeSpecialConfig = nil
    self._LimitTimeSpecialInfo = nil
end

function FirstRechargeModel:initAssistResponse()
    self._assistResponseMap = {
        [FirstRechargeDef.GR_FIRST_RECHARGE_GET_INFO] = handler(self, self.onFirstRechargeInfo),
        [FirstRechargeDef.GR_LIMITTIME_SPECIAL_GET_INFO] = handler(self, self.onLimitTimeSpecialInfo),
        [FirstRechargeDef.GR_FIRST_RECHARGE_TAKE_REWARD] = handler(self, self.onFirstRechargeTakeRewardRet),
        [FirstRechargeDef.GR_FIRST_RECHARGE_PAY_SUCCESS] = handler(self, self.onFirstRechargePaySuccessRet)
    }
    AssistModel:registCtrl(self, self.dealAssistResponse)
end

function FirstRechargeModel:gc_GetFirstRechargeInfo()
    if not cc.exports.isFirstRechargeSupported()  then
        return
    end

    self._info = {}
    if user.nUserID == nil or user.nUserID < 0 then
        print("userinfo is not ok")
        return
    end

    local platFormType = FirstRechargeDef.FIRST_RECHARGE_APPTYPE_AN
    if MCAgent:getInstance().getLaunchSubMode and MCAgent:getInstance():getLaunchSubMode() == 1 then
        platFormType = FirstRechargeDef.FIRST_RECHARGE_APPTYPE_SET
    elseif cc.exports.LaunchMode["PLATFORM"] == MCAgent:getInstance():getLaunchMode() then
        if device.platform == 'ios' then
            platFormType = FirstRechargeDef.FIRST_RECHARGE_APPTYPE_IOS
        else
            platFormType = FirstRechargeDef.FIRST_RECHARGE_APPTYPE_AN
        end
    end

    if not deviceModel or not deviceModel.szHardID then
        return
    end

    local data = {
        nUserID = user.nUserID,
        nPlatform = platFormType,
        szHardID = deviceModel.szHardID
    }
    local pdata = protobuf.encode('pbNewFirstRecharge.NewFirstRechargeInfo', data)
    AssistModel:sendData(FirstRechargeDef.GR_FIRST_RECHARGE_GET_INFO, pdata, false)
    --AssistModel:sendRequest(FirstRechargeDef.GR_GET_FIRST_RECHARGE_INFO, FirstRechargeReq.QUERY_FirstRecharge_INFO, data, false)
end

function FirstRechargeModel:gc_GetSpecialGiftInfo()
    if not cc.exports.isLimitTimeSpecialSupported()  then
        return
    end

    self._info = {}
    if user.nUserID == nil or user.nUserID < 0 then
        print("userinfo is not ok")
        return
    end

    local platFormType = FirstRechargeDef.FIRST_RECHARGE_APPTYPE_AN
    if MCAgent:getInstance().getLaunchSubMode and MCAgent:getInstance():getLaunchSubMode() == 1 then
        platFormType = FirstRechargeDef.FIRST_RECHARGE_APPTYPE_SET
    elseif cc.exports.LaunchMode["PLATFORM"] == MCAgent:getInstance():getLaunchMode() then
        if device.platform == 'ios' then
            platFormType = FirstRechargeDef.FIRST_RECHARGE_APPTYPE_IOS
        else
            platFormType = FirstRechargeDef.FIRST_RECHARGE_APPTYPE_AN
        end
    end

    if not deviceModel or not deviceModel.szHardID then
        return
    end

    local data = {
        nUserID = user.nUserID,
        nPlatform = platFormType,
        szHardID = deviceModel.szHardID
    }
    local pdata = protobuf.encode('pbNewFirstRecharge.NewFirstRechargeInfo', data)
    AssistModel:sendData(FirstRechargeDef.GR_LIMITTIME_SPECIAL_GET_INFO, pdata, false)
end

function FirstRechargeModel:onFirstRechargeInfo(data)
    if string.len(data) == nil then return nil end

    local pdata = protobuf.decode('pbNewFirstRecharge.NewFirstRechargeInfo', data)
    protobuf.extract(pdata)


    self._FirstRechargeConfig = pdata.NewFirstRechargeConfig
    self._FirstRechargeInfo = pdata

    self:dispatchEvent({name = FirstRechargeDef.FirstRechargeInfoRet})

    ShopModel:onDealFirstRecharge(self._FirstRechargeInfo.bEnable)

    --登录弹窗模块
    if self:isAlive() and self:isShowFirstRecharge() then
        local PluginProcessModel = mymodel("hallext.PluginProcessModel"):getInstance()
        PluginProcessModel:setPluginReadyStatus("FirstRecharge", true)
        PluginProcessModel:startPluginProcess()
    end 
end

function FirstRechargeModel:onLimitTimeSpecialInfo(data)
    if string.len(data) == nil then return nil end

    local pdata = protobuf.decode('pbNewFirstRecharge.NewFirstRechargeInfo', data)
    protobuf.extract(pdata)


    self._LimitTimeSpecialConfig = pdata.NewFirstRechargeConfig
    self._LimitTimeSpecialInfo = pdata

    --更新计时器的值
    self:startFirstLimitTimer(pdata.NewFirstRechargeStatus.nRemainTime)

    self:dispatchEvent({name = FirstRechargeDef.LimitTimeSpecialInfoRet})

    ShopModel:onDealFirstRecharge(self._LimitTimeSpecialInfo.bEnable)          --todo

    --登录弹窗模块
    if self:isSpecialGiftAlive() and self:isShowSpecialGift()  then
        local PluginProcessModel = mymodel("hallext.PluginProcessModel"):getInstance()
        PluginProcessModel:setPluginReadyStatus("LimitTimeSpecial", true)
        PluginProcessModel:startPluginProcess()
    end 
end

function FirstRechargeModel:gc_FirstRechargeTakeReward(nExchangeID, nDay)
    if user.nUserID == nil or user.nUserID < 0 then
        print("userinfo is not ok")
    end 

    local data = {
        nUserID = user.nUserID,
        nExchangeID = nExchangeID,
        nDay = nDay,
    }

    local pdata = protobuf.encode('pbNewFirstRecharge.TakeReward', data)
    AssistModel:sendData(FirstRechargeDef.GR_FIRST_RECHARGE_TAKE_REWARD,pdata, false)
end

function FirstRechargeModel:isShowFirstRecharge()
    if not self._FirstRechargeInfo or not self._FirstRechargeConfig then
        self:gc_GetFirstRechargeInfo()
        return false
    end
    if self._FirstRechargeInfo.NewFirstRechargeStatus.nActivityType == 1 then   -- 首冲活动结束现在是特惠数据（为了兼容没有删除数据）
        return false
    end
    if self._FirstRechargeInfo.NewFirstRechargeStatus.nPayStatus == 1 then   --充值完成
        for i = 1,3 do
            local status = self._FirstRechargeInfo.NewFirstRechargeStatus.nStatus[i]
            if status == FirstRechargeDef.FIRST_RECHARGE_UNTAKE or status == FirstRechargeDef.FIRST_RECHARGE_UNSTARTED then
                return true
            end
        end
        return false
    else
        return true
    end
end

function FirstRechargeModel:isShowSpecialGift()
    if not self._LimitTimeSpecialInfo or not self._LimitTimeSpecialConfig then
        --self:gc_GetSpecialGiftInfo()
        return false
    end

    if not self._FirstRechargeInfo or not self._FirstRechargeConfig then        -- 也需要知道首冲是否充值
        --self:gc_GetFirstRechargeInfo()
        return false
    end

    if self._FirstRechargeInfo.NewFirstRechargeStatus.nPayStatus == 1 or self._FirstRechargeInfo.NewFirstRechargeStatus.nActivityType == 1 then
        if self._LimitTimeSpecialInfo.NewFirstRechargeStatus.nPayStatus == 1 then   --充值完成
            for i = 1,3 do
                local status = self._LimitTimeSpecialInfo.NewFirstRechargeStatus.nStatus[i]
                if status == FirstRechargeDef.FIRST_RECHARGE_UNTAKE or status == FirstRechargeDef.FIRST_RECHARGE_UNSTARTED then
                    return true         -- 有奖励未领取
                end
            end
            return false
        elseif self._LimitTimeSpecialInfo.NewFirstRechargeStatus.nRemainTime > 172800 then   -- 为了兼容，否则应该是小于0的情况
            return true
        else
            return false
        end
    end

    return false
end

function FirstRechargeModel:onFirstRechargePaySuccessRet(data)
    if string.len(data) == nil then return nil end

    local awardRet = protobuf.decode('pbNewFirstRecharge.TakeReward', data)
    protobuf.extract(awardRet)

     --刷新银两
    local playerModel = mymodel("hallext.PlayerModel"):getInstance()
    playerModel:update({'SafeboxInfo','MemberInfo','UserGameInfo'})

    dump(awardRet)

    if #awardRet.RewardIDList >0 then
        local rewardList = {}
        for u, v in pairs(awardRet.RewardIDList) do
            table.insert( rewardList,{nType = v.RewardType,nCount = v.RewardCount})
        end
        --加个延时看下效果
        --my.scheduleOnce(function() my.informPluginByName({pluginName = 'RewardTipCtrl', params = {data = rewardList,showOkOnly = true}}) end,2)
        my.informPluginByName({pluginName = 'RewardTipCtrl', params = {data = rewardList,showOkOnly = true}})
    end
    self:gc_GetFirstRechargeInfo()
    self:gc_GetSpecialGiftInfo()

    CardRecorderModel:sendGetCardMakerInfo() --查询记牌器信息
end

function FirstRechargeModel:onFirstRechargeTakeRewardRet(data)
    if string.len(data) == nil then return nil end

    local awardRet = protobuf.decode('pbNewFirstRecharge.TakeReward', data)
    protobuf.extract(awardRet)

     --刷新银两
    local playerModel = mymodel("hallext.PlayerModel"):getInstance()
    playerModel:update({'SafeboxInfo','MemberInfo','UserGameInfo'})

    dump(awardRet)

    if #awardRet.RewardIDList >0 then
        local rewardList = {}
        for u, v in pairs(awardRet.RewardIDList) do
            table.insert( rewardList,{nType = v.RewardType,nCount = v.RewardCount})
        end
        my.informPluginByName({pluginName = 'RewardTipCtrl', params = {data = rewardList,showOkOnly = true}})
    end
    self:gc_GetFirstRechargeInfo()
    self:gc_GetSpecialGiftInfo()
end

function FirstRechargeModel:gc_SpecialGiftTakeReward(nExchangeID, nDay)
    if user.nUserID == nil or user.nUserID < 0 then
        print("userinfo is not ok")
    end 

    local data = {
        nUserID = user.nUserID,
        nExchangeID = nExchangeID,
        nDay = nDay,
    }

    local pdata = protobuf.encode('pbNewFirstRecharge.TakeReward', data)
    AssistModel:sendData(FirstRechargeDef.GR_FIRST_RECHARGE_TAKE_REWARD,pdata, false)
end

function FirstRechargeModel:onLimitTimeSpecialTakeRewardRet(data)
    if string.len(data) == nil then return nil end

    local awardRet = protobuf.decode('pbNewFirstRecharge.TakeReward', data)
    protobuf.extract(awardRet)

     --刷新银两
    local playerModel = mymodel("hallext.PlayerModel"):getInstance()
    playerModel:update({'SafeboxInfo','MemberInfo','UserGameInfo'})

    dump(awardRet)

    if #awardRet.RewardIDList >0 then
        local rewardList = {}
        for u, v in pairs(awardRet.RewardIDList) do
            table.insert( rewardList,{nType = v.RewardType,nCount = v.RewardCount})
        end
        my.informPluginByName({pluginName = 'RewardTipCtrl', params = {data = rewardList,showOkOnly = true}})
    end
    self:gc_GetSpecialGiftInfo()
end

function FirstRechargeModel:GetFirstRechargeInfo()
    if self._FirstRechargeInfo then
        return self._FirstRechargeInfo
    end
    return nil
end

function FirstRechargeModel:GetSpecialGiftInfo()
    if self._LimitTimeSpecialInfo then
        return self._LimitTimeSpecialInfo
    end
    return nil
end

function FirstRechargeModel:GetFirstRechargeConfig()
    if self._FirstRechargeConfig then
        return self._FirstRechargeConfig
    end
    return nil
end

function FirstRechargeModel:GetSpecialGiftConfig()
    if self._LimitTimeSpecialConfig then
        return self._LimitTimeSpecialConfig
    end
    return nil
end

function FirstRechargeModel:isNeedReddot()
    if not self._FirstRechargeInfo or not self._FirstRechargeConfig then
        --self:gc_GetFirstRechargeInfo()
        return false
    end
    if self._FirstRechargeInfo.NewFirstRechargeStatus.nPayStatus == 1 then   --充值完成
        for i = 1,3 do
            if self._FirstRechargeInfo.NewFirstRechargeStatus.nStatus[i] == FirstRechargeDef.FIRST_RECHARGE_UNTAKE then  --领取奖励
                return true
            end
        end
    end
    return false
end

function FirstRechargeModel:isSpecialGiftNeedReddot()
    if not self._LimitTimeSpecialInfo or not self._LimitTimeSpecialConfig then
        --self:gc_GetSpecialGiftInfo()
        return false
    end
    if self._LimitTimeSpecialInfo.NewFirstRechargeStatus.nPayStatus == 1 then   --充值完成
        for i = 1,3 do
            if self._LimitTimeSpecialInfo.NewFirstRechargeStatus.nStatus[i] == FirstRechargeDef.FIRST_RECHARGE_UNTAKE then  --领取奖励
                return true
            end
        end
    end
    return false
end

function FirstRechargeModel:isPay()
    if not self._FirstRechargeInfo or not self._FirstRechargeConfig then
        self:gc_GetFirstRechargeInfo()
        return false
    end
    -- nActivityType == 1说明已经进去特惠礼包阶段了，为了兼容性数据未删除
    if self._FirstRechargeInfo.NewFirstRechargeStatus.nPayStatus == 1 or self._FirstRechargeInfo.NewFirstRechargeStatus.nActivityType == 1 then
        return true
    else
        return false
    end
end

--开启付费
function FirstRechargeModel:AppType()
    local platFormType = FirstRechargeDef.FIRST_RECHARGE_APPTYPE_AN
    if MCAgent:getInstance().getLaunchSubMode and MCAgent:getInstance():getLaunchSubMode() == 1 then
        platFormType = FirstRechargeDef.FIRST_RECHARGE_APPTYPE_SET
    elseif cc.exports.LaunchMode["PLATFORM"] == MCAgent:getInstance():getLaunchMode() then
        if device.platform == 'ios' then
            platFormType = FirstRechargeDef.FIRST_RECHARGE_APPTYPE_IOS
        else
            platFormType = FirstRechargeDef.FIRST_RECHARGE_APPTYPE_AN
        end
    end

    return platFormType
end

function FirstRechargeModel:_payFor(price,exchangeid)
    if self._waitingPayResult then return end
 
    --local exchangeid = 11362
    
    local function getPayExtArgs()
        local strPayExtArgs = "{"
        if cc.exports.LaunchMode["PLATFORM"] == MCAgent:getInstance():getLaunchMode() then
            if (cc.exports.GetShopConfig()['platform_app_client_id'] and cc.exports.GetShopConfig()['platform_app_client_id'] ~= "") then 
                strPayExtArgs = strPayExtArgs..string.format("\"platform_app_client_id\":\"%d\",", 
                    cc.exports.GetShopConfig()['platform_app_client_id'])
            end
            if (cc.exports.GetShopConfig()['platform_cooperate_way_id'] and cc.exports.GetShopConfig()['platform_cooperate_way_id'] ~= "") then 
                strPayExtArgs = strPayExtArgs..string.format("\"platform_cooperate_way_id\":\"%d\",", 
                    cc.exports.GetShopConfig()['platform_cooperate_way_id'])
            end
        else
            print("FirstRechargeModel single app")
        end
    
        local userID = plugin.AgentManager:getInstance():getUserPlugin():getUserID()
        local gameID = BusinessUtils:getInstance():getGameID()
        if userID and gameID and type(userID) == "string" and type(gameID) == "number" then
            local promoteCodeCache = CacheModel:getCacheByKey("PromoteCode_"..userID.."_"..gameID)
            if type(promoteCodeCache) == "number" then
                strPayExtArgs = strPayExtArgs..string.format("\"promote_code\":\"%s\",", tostring(promoteCodeCache))
            end
        end
        
        if string.sub(strPayExtArgs, string.len(strPayExtArgs)) == "," then 
            strPayExtArgs = string.sub(strPayExtArgs, 1, string.len(strPayExtArgs) - 1)
        end
    
        if 1 == string.len(strPayExtArgs) then
            strPayExtArgs = ""
        else
            strPayExtArgs = strPayExtArgs .. "}"
        end
    
        print("FirstRechargeModel pay_ext_args:", strPayExtArgs)
        return strPayExtArgs
            
    end
    
    local paymodel = mymodel("PayModel"):getInstance()
    local param = clone(paymodel:getPayMetaTable())
    
    param["Product_Name"]   = "首充"
    param["Product_Id"] = ""  --sid
        
    local apptype = self:AppType()
    print("----------------------------------apptype = ",apptype)
    --local price
    --price,exchangeid = self:GetItem(apptype,nPayLevel,nPayType)
    print("------ price and exchangeid:",price,exchangeid)
    if apptype == FirstRechargeDef.FIRST_RECHARGE_APPTYPE_AN then
        print("FIRST_RECHARGE_APPTYPE_AN")
    elseif apptype == FirstRechargeDef.FIRST_RECHARGE_APPTYPE_SET then
        print("FIRST_RECHARGE_APPTYPE_SET")
        param["Product_Id"] = "com.uc108.mobile.gamecenter.tongbao" .. price
    elseif apptype == FirstRechargeDef.FIRST_RECHARGE_APPTYPE_IOS then
        print("FIRST_RECHARGE_APPTYPE_IOS")
        param["Product_Id"] = "com.uc108.mobile.gamecenter.tongbao" .. price
    end
    
    local through_data = string.format("{\"RewardToGame\":%d,\"ExchangeId\":%d}", 0, exchangeid)
    
    param["pay_point_num"]  = 0
    param["Product_Price"] = tostring(price)     --价格
    param["Exchange_Id"]  = tostring(1)      --物品ID  1是银子 2是会员 3是积分 4是钻石
    param["through_data"] = through_data;
    param["ext_args"] = getPayExtArgs();

    local kpiData = my.getKPIClientData()
    param["RecomGameId"]   = tostring(kpiData.RecomGameId)
    param["RecomGameCode"] = kpiData.RecomGameCode
    param["RecomGameVers"] = ""
    
    if device.platform == 'windows' or cc.exports.isHSoxRaySupported() then
        print("To Create ActivityRechargeHSoxCtrl")
        dump(param, "FirstRechargeModel:payForProduct param")
        my.informPluginByName({pluginName='ActivityRechargeHSoxCtrl',params = param})
        self._waitingPayResult = true
        my.scheduleOnce(function()
            self._waitingPayResult = false
        end,3)
    else
        local iapPlugin = plugin.AgentManager:getInstance():getIAPPlugin()
        local function payCallBack(code, msg)
            my.scheduleOnce(function()
                self._waitingPayResult = false
            end,3)

            if code == PayResultCode.kPaySuccess then
                --my.informPluginByName({pluginName = 'TipPlugin',params = {tipString = "挑战已开启", removeTime = 3}})
            else
                if string.len(msg) ~= 0 then
                    --刷新消息，让充值按钮可以点击
                    self:gc_GetFirstRechargeInfo()
                    --self:dispatchEvent({name = FirstRechargeDef.FirstRechargeChargeCancel})
                    my.informPluginByName({pluginName='TipPlugin',params={tipString=msg,removeTime=2}})
                end
                if( code == PayResultCode.kPayFail )then
        
                elseif( code == PayResultCode.kPayTimeOut )then
        
                elseif( code == PayResultCode.kPayProductionInforIncomplete )then
        
                end
            end
        end
        iapPlugin:setCallback(payCallBack)
        iapPlugin:payForProduct(param)
        self._waitingPayResult = true
    end
end

function FirstRechargeModel:isAlive()
    if not cc.exports.isFirstRechargeSupported()  then
        return  false
    end

    if  not self._FirstRechargeInfo then
        return false
    end

    if self._FirstRechargeInfo and not self._FirstRechargeInfo.bEnable  then
        return false
    end

    return true
end

function FirstRechargeModel:isSpecialGiftAlive()
    if not cc.exports.isLimitTimeSpecialSupported()  then
        return  false
    end

    if  not self._LimitTimeSpecialInfo then
        return false
    end

    if self._LimitTimeSpecialInfo and not self._LimitTimeSpecialInfo.bEnable  then
        return false
    end

    return true
end

function FirstRechargeModel:isInGameAlive()
    if not self:isAlive()  then
        return  false
    end

    if self._FirstRechargeInfo.NewFirstRechargeStatus.nPayStatus == 0 then
        return true
    end

    return false
end

function FirstRechargeModel:isFirstRechargeResult(goodID)
    if  not self._FirstRechargeConfig then
        return false
    end

    print("111111111111111"..goodID)
    for i, j in pairs(self._FirstRechargeConfig.FirstRecharge) do
        print("222222222"..j.RechargeExchangeID)
        if j.RechargeExchangeID and tonumber(j.RechargeExchangeID) == goodID then
            return true
        end
    end

    return false
end

--停止限时特惠的计时器
function FirstRechargeModel:stopFirstLimitTimer()
    if(self._FirstLimitTimer)then
        --取消之前的定时器
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._FirstLimitTimer)
        self._FirstLimitTimer=nil
    end
end

--启动限时特惠的计时器
function FirstRechargeModel:startFirstLimitTimer(nTimeInterval)
    --关闭定时器
    self:stopFirstLimitTimer()
    --获取最新的时间启动定时器
    self._FirstLimitLeftTime = nTimeInterval
    if not self._FirstLimitTimer then
        self._FirstLimitTimer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
            self._FirstLimitLeftTime = self._FirstLimitLeftTime - 1
        end, 1.0, false)
    end
end

--得到限时特惠的计时器的值
function FirstRechargeModel:getFirstLimitLeftTime()
    return self._FirstLimitLeftTime
end

return FirstRechargeModel