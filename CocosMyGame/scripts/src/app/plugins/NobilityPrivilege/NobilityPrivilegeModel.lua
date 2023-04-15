local NobilityPrivilegeModel =class('NobilityPrivilegeModel',require('src.app.GameHall.models.BaseModel'))
local AssistModel = mymodel('assist.AssistModel'):getInstance()
local NobilityPrivilegeDef = require('src.app.plugins.NobilityPrivilege.NobilityPrivilegeDef')
local user = mymodel('UserModel'):getInstance()
local BroadcastModel = mymodel("hallext.BroadcastModel"):getInstance()
local ShopModel = mymodel("ShopModel"):getInstance()
local CardRecorderModel = import("src.app.plugins.shop.cardrecorder.CardRecorderModel"):getInstance()
local ExchangeLotteryModel = require('src.app.plugins.ExchangeLottery.ExchangeLotteryModel'):getInstance()
local LoginLotteryModel = import("src.app.plugins.loginlottery.LoginLotteryModel"):getInstance()
local deviceModel                   = mymodel('DeviceModel'):getInstance()

local treepack = cc.load('treepack')
local json = cc.load("json").json

local coms=cc.load('coms')
local PropertyBinder=coms.PropertyBinder
my.setmethods(NobilityPrivilegeModel,PropertyBinder)

my.addInstance(NobilityPrivilegeModel)

protobuf.register_file('src/app/plugins/NobilityPrivilege/proto/pbNobilityPrivilege.pb')

function NobilityPrivilegeModel:onCreate()
    self._NobilityPrivilegeConfig = nil
    self._NobilityPrivilegeInfo = nil
    self._dataReady = false
    self:initAssistResponse()
end

function NobilityPrivilegeModel:reset( )
    self._NobilityPrivilegeConfig = nil
    self._NobilityPrivilegeInfo = nil
end

function NobilityPrivilegeModel:initAssistResponse()
    self._assistResponseMap = {
        [NobilityPrivilegeDef.GR_NOBILITY_PRIVILEGE_GET_INFO] = handler(self, self.onNobilityPrivilegeInfo),
        [NobilityPrivilegeDef.GR_NOBILITY_PRIVILEGE_DAILYGIFTBAG_TAKE] = handler(self, self.onNobilityPrivilegeDailyGiftBagTakeRet),
        [NobilityPrivilegeDef.GR_NOBILITY_PRIVILEGE_WEEKGIFTBAG_TAKE] = handler(self, self.onNobilityPrivilegeWeekGiftBagTakeRet),
        [NobilityPrivilegeDef.GR_NOBILITY_PRIVILEGE_MONTHGIFTBAG_TAKE] = handler(self, self.onNobilityPrivilegeMonthGiftBagTakeRet),
        [NobilityPrivilegeDef.GR_NOBILITY_PRIVILEGE_UPGRADEGIFTBAG_TAKE] = handler(self, self.onNobilityPrivilegeUpgradeGiftBagTakeRet),
        [NobilityPrivilegeDef.GR_NOBILITY_PRIVILEGE_PAY_SUCCESS] = handler(self, self.onNobilityPrivilegePaySuccessRet),
        [NobilityPrivilegeDef.GR_NOBILITY_PRIVILEGE_TAKE_ADDITIONGIFT] = handler(self, self.onNobilityPrivilegeAdditionGiftRet)
    }
    AssistModel:registCtrl(self, self.dealAssistResponse)
end

function NobilityPrivilegeModel:gc_GetNobilityPrivilegeInfo()
    if not cc.exports.isNobilityPrivilegeSupported()  then
        return
    end
    self:reset()
    self._info = {}
    if user.nUserID == nil or user.nUserID < 0 then
        print("userinfo is not ok")
        return
    end

    local platFormType = NobilityPrivilegeDef.NOBILITY_PRIVILEGE_APPTYPE_AN
    if MCAgent:getInstance().getLaunchSubMode and MCAgent:getInstance():getLaunchSubMode() == 1 then
        platFormType = NobilityPrivilegeDef.NOBILITY_PRIVILEGE_APPTYPE_SET
    elseif cc.exports.LaunchMode["PLATFORM"] == MCAgent:getInstance():getLaunchMode() then
        if device.platform == 'ios' then
            platFormType = NobilityPrivilegeDef.NOBILITY_PRIVILEGE_APPTYPE_IOS
        else
            platFormType = NobilityPrivilegeDef.NOBILITY_PRIVILEGE_APPTYPE_AN
        end
    end

    local data = {
        userID = user.nUserID,
        channelType = platFormType,
        channelID   = my.getTcyChannelId()
    }
    local pdata = protobuf.encode('pbNobilityPrivilege.NobilityPrivilegeInfo', data)
    AssistModel:sendData(NobilityPrivilegeDef.GR_NOBILITY_PRIVILEGE_GET_INFO, pdata, false)
end

function NobilityPrivilegeModel:onNobilityPrivilegeInfo(data)
    if string.len(data) == nil then return nil end

    local pdata = protobuf.decode('pbNobilityPrivilege.NobilityPrivilegeInfo', data)
    protobuf.extract(pdata)

    if not cc.exports.isAdverSupported() then --当前渠道不支持广告 则将权限中的广告去掉
        for j=#pdata.nobilityPrivilegeConfig.nobilityLevelList,1,-1 do
            local  nPrivilegeDetail= pdata.nobilityPrivilegeConfig.nobilityLevelList[j].privilegeDetail
            local newDetail = {}
            for i=1,#nPrivilegeDetail do
                for u, v in pairs(pdata.nobilityPrivilegeConfig.privilegeList) do
                    if nPrivilegeDetail[i].privilegeID == v.privilegeID then
                        if v.privilegeType ~= NobilityPrivilegeDef.PRIVILEGE_REMOVE_ADVERT then   
                            table.insert(newDetail, nPrivilegeDetail[i])
                        end
                    end
                end
            end
            pdata.nobilityPrivilegeConfig.nobilityLevelList[j].privilegeDetail = newDetail
        end
    end 
    self._NobilityPrivilegeConfig = pdata.nobilityPrivilegeConfig
    self._NobilityPrivilegeInfo = pdata
    self._dataReady = true
    self:dispatchEvent({name = NobilityPrivilegeDef.NobilityPrivilegeInfoRet})

    -- local status,reliefCount = self:TakeNobilityPrivilegeReliefInfo()
    -- if self:isAlive() and status then
    --     local relief=mymodel('hallext.ReliefActivity'):getInstance()
    --     relief:queryUserState()
    -- end
end

function NobilityPrivilegeModel:isDataReady()
    return self._dataReady
end

function NobilityPrivilegeModel:gc_NobilityPrivilegeDailyGiftBagTake()
    if user.nUserID == nil or user.nUserID < 0 then
        print("userinfo is not ok")
    end 

    local data = {
        userID = user.nUserID
    }

    local pdata = protobuf.encode('pbNobilityPrivilege.TakeDailyGiftBagReward', data)
    AssistModel:sendData(NobilityPrivilegeDef.GR_NOBILITY_PRIVILEGE_DAILYGIFTBAG_TAKE,pdata, false)
end

function NobilityPrivilegeModel:onNobilityPrivilegeDailyGiftBagTakeRet(data)
    if string.len(data) == nil then return nil end

    local awardRet = protobuf.decode('pbNobilityPrivilege.TakeDailyGiftBagReward', data)
    protobuf.extract(awardRet)

     --刷新银两
    local playerModel = mymodel("hallext.PlayerModel"):getInstance()
    playerModel:update({'SafeboxInfo','MemberInfo','UserGameInfo'})

    dump(awardRet)

    if #awardRet.rewardIDList >0 then
        local rewardList = {}
        for u, v in pairs(awardRet.rewardIDList) do
            table.insert( rewardList,{nType = v.rewardType,nCount = v.rewardCount})
        end
        my.informPluginByName({pluginName = 'RewardTipCtrl', params = {data = rewardList,showOkOnly = true}})
    end
    self:gc_GetNobilityPrivilegeInfo()
    CardRecorderModel:sendGetCardMakerInfo() --查询记牌器信息
    ExchangeLotteryModel:gc_GetExchangeLotteryInfo() --查询惊喜夺宝信息
end

function NobilityPrivilegeModel:gc_NobilityPrivilegeWeekGiftBagTake()
    if user.nUserID == nil or user.nUserID < 0 then
        print("userinfo is not ok")
    end 

    local data = {
        userID = user.nUserID
    }

    local pdata = protobuf.encode('pbNobilityPrivilege.TakeWeekGiftBagReward', data)
    AssistModel:sendData(NobilityPrivilegeDef.GR_NOBILITY_PRIVILEGE_WEEKGIFTBAG_TAKE,pdata, false)
end

function NobilityPrivilegeModel:onNobilityPrivilegeWeekGiftBagTakeRet(data)
    if string.len(data) == nil then return nil end

    local awardRet = protobuf.decode('pbNobilityPrivilege.TakeWeekGiftBagReward', data)
    protobuf.extract(awardRet)

     --刷新银两
    local playerModel = mymodel("hallext.PlayerModel"):getInstance()
    playerModel:update({'SafeboxInfo','MemberInfo','UserGameInfo'})

    dump(awardRet)

    if #awardRet.rewardIDList >0 then
        local rewardList = {}
        for u, v in pairs(awardRet.rewardIDList) do
            table.insert( rewardList,{nType = v.rewardType,nCount = v.rewardCount})
        end
        my.informPluginByName({pluginName = 'RewardTipCtrl', params = {data = rewardList,showOkOnly = true}})
    end
    self:gc_GetNobilityPrivilegeInfo()
    CardRecorderModel:sendGetCardMakerInfo() --查询记牌器信息
    ExchangeLotteryModel:gc_GetExchangeLotteryInfo() --查询惊喜夺宝信息
end

function NobilityPrivilegeModel:gc_NobilityPrivilegeMonthGiftBagTake()
    if user.nUserID == nil or user.nUserID < 0 then
        print("userinfo is not ok")
    end 

    local data = {
        userID = user.nUserID
    }

    local pdata = protobuf.encode('pbNobilityPrivilege.TakeMonthGiftBagReward', data)
    AssistModel:sendData(NobilityPrivilegeDef.GR_NOBILITY_PRIVILEGE_MONTHGIFTBAG_TAKE,pdata, false)
end

function NobilityPrivilegeModel:onNobilityPrivilegeMonthGiftBagTakeRet(data)
    if string.len(data) == nil then return nil end

    local awardRet = protobuf.decode('pbNobilityPrivilege.TakeMonthGiftBagReward', data)
    protobuf.extract(awardRet)

     --刷新银两
    local playerModel = mymodel("hallext.PlayerModel"):getInstance()
    playerModel:update({'SafeboxInfo','MemberInfo','UserGameInfo'})

    dump(awardRet)

    if #awardRet.rewardIDList >0 then
        local rewardList = {}
        for u, v in pairs(awardRet.rewardIDList) do
            table.insert( rewardList,{nType = v.rewardType,nCount = v.rewardCount})
        end
        my.informPluginByName({pluginName = 'RewardTipCtrl', params = {data = rewardList,showOkOnly = true}})
    end
    self:gc_GetNobilityPrivilegeInfo()
    CardRecorderModel:sendGetCardMakerInfo() --查询记牌器信息
    ExchangeLotteryModel:gc_GetExchangeLotteryInfo() --查询惊喜夺宝信息
end

function NobilityPrivilegeModel:gc_NobilityPrivilegeUpgradeGiftBagTake()
    if user.nUserID == nil or user.nUserID < 0 then
        print("userinfo is not ok")
    end 

    local data = {
        userID = user.nUserID
    }

    local pdata = protobuf.encode('pbNobilityPrivilege.TakeUpgradeGiftBagReward', data)
    AssistModel:sendData(NobilityPrivilegeDef.GR_NOBILITY_PRIVILEGE_UPGRADEGIFTBAG_TAKE,pdata, false)
end

function NobilityPrivilegeModel:onNobilityPrivilegeUpgradeGiftBagTakeRet(data)
    if string.len(data) == nil then return nil end

    local awardRet = protobuf.decode('pbNobilityPrivilege.TakeUpgradeGiftBagReward', data)
    protobuf.extract(awardRet)

     --刷新银两
    local playerModel = mymodel("hallext.PlayerModel"):getInstance()
    playerModel:update({'SafeboxInfo','MemberInfo','UserGameInfo'})

    dump(awardRet)

    if #awardRet.rewardIDList >0 then
        local rewardList = {}
        for u, v in pairs(awardRet.rewardIDList) do
            table.insert( rewardList,{nType = v.rewardType,nCount = v.rewardCount})
        end
        my.informPluginByName({pluginName = 'RewardTipCtrl', params = {data = rewardList,showOkOnly = true}})
    end
    self:gc_GetNobilityPrivilegeInfo()
    CardRecorderModel:sendGetCardMakerInfo() --查询记牌器信息
    ExchangeLotteryModel:gc_GetExchangeLotteryInfo() --查询惊喜夺宝信息
end

function NobilityPrivilegeModel:onNobilityPrivilegePaySuccessRet(data)
    if string.len(data) == nil then return nil end

    self:gc_GetNobilityPrivilegeInfo()
    LoginLotteryModel:onGetLoginLotteryInfo()  --更新特权里的转盘抽奖信息
end

function NobilityPrivilegeModel:onNobilityPrivilegeAdditionGiftRet(data)
    if string.len(data) == nil then return nil end

    my.scheduleOnce(function()
        --刷新银两
        local playerModel = mymodel("hallext.PlayerModel"):getInstance()
        playerModel:update({'SafeboxInfo','MemberInfo','UserGameInfo'})

        my.informPluginByName({pluginName = 'TipPlugin',params = {tipString = "加赠奖励已到账~", removeTime = 2}})
    end, 2)
end

function NobilityPrivilegeModel:GetNobilityPrivilegeInfo()
    if self._NobilityPrivilegeInfo then
        return self._NobilityPrivilegeInfo
    end
    return nil
end

function NobilityPrivilegeModel:GetNobilityPrivilegeConfig()
    if self._NobilityPrivilegeConfig then
        return self._NobilityPrivilegeConfig
    end
    return nil
end

function NobilityPrivilegeModel:isNeedReddot()
    if not self:isAlive() then
        return false
    end

    local nobilityPrivilegeInfo = self._NobilityPrivilegeInfo
    if nobilityPrivilegeInfo.dailyGiftBagStatus == NobilityPrivilegeDef.NOBILITY_PRIVILEGE_UNTAKE then 
        return true
    end

    if nobilityPrivilegeInfo.weekGiftBagStatus == NobilityPrivilegeDef.NOBILITY_PRIVILEGE_UNTAKE_NEW then 
        return true
    end

    if nobilityPrivilegeInfo.monthGiftBagStatus == NobilityPrivilegeDef.NOBILITY_PRIVILEGE_UNTAKE_NEW then 
        return true
    end

    --升级礼包
    for i = #nobilityPrivilegeInfo.upgradeGiftBagStatus,1,-1 do
        if nobilityPrivilegeInfo.upgradeGiftBagStatus[i] == NobilityPrivilegeDef.NOBILITY_PRIVILEGE_UNTAKE then
            return true
        end
    end

    return false
end

function NobilityPrivilegeModel:isAlive()
    if not cc.exports.isNobilityPrivilegeSupported()  then
        return  false
    end

    if  not self._NobilityPrivilegeInfo then
        return false
    end

    if self._NobilityPrivilegeInfo and  self._NobilityPrivilegeInfo.enable == 0 then
        return false
    end

    return true
end

function NobilityPrivilegeModel:GetSelfNobilityPrivilegeLevel()
    if not self:isAlive()  then
        return  -1
    end

    return self._NobilityPrivilegeInfo.level
end

--返回值  是否用贵族低保 送几次低保 提示等级  提示低保次数 贵族低保提示是否显示
function NobilityPrivilegeModel:TakeNobilityPrivilegeReliefInfo()
    if not self:isAlive()  then
        return  false,0,0,0,false
    end

    local nLevel = self._NobilityPrivilegeInfo.level
    local nLowLevel = 0
    local nLowLevelCount = 0
    local nHighLevel = 0
    local nHighLevelCount = 0
    for j=#self._NobilityPrivilegeConfig.nobilityLevelList,1,-1 do
        local  nPrivilegeDetail= self._NobilityPrivilegeConfig.nobilityLevelList[j].privilegeDetail
        for i=1,#nPrivilegeDetail do
            for u, v in pairs(self._NobilityPrivilegeConfig.privilegeList) do
                if nPrivilegeDetail[i].privilegeID == v.privilegeID then
                    if v.privilegeType == 11 then   --送低保
                        nLowLevel = j-1
                        nLowLevelCount = v.showValue[1]
                    end
                end
            end
        end
    end

    for j=#self._NobilityPrivilegeConfig.nobilityLevelList,1,-1 do
        local  nPrivilegeDetail= self._NobilityPrivilegeConfig.nobilityLevelList[j].privilegeDetail
        for i=1,#nPrivilegeDetail do
            for u, v in pairs(self._NobilityPrivilegeConfig.privilegeList) do
                if nPrivilegeDetail[i].privilegeID == v.privilegeID then
                    if v.privilegeType == 11 and v.showValue[1] > nLowLevelCount then   --送低保
                        nHighLevel = j-1
                        nHighLevelCount = v.showValue[1]
                    end
                end
            end
        end
    end

    --做一下保护，万一不送低保了呢
    if nLowLevel > 0 and nHighLevel > 0 then
        if nLevel < nLowLevel then
            return false,nLowLevelCount,nLowLevel,nLowLevelCount,true
        elseif nLevel < nHighLevel then
            return true,nLowLevelCount,nHighLevel,nHighLevelCount,true
        elseif nLevel < #self._NobilityPrivilegeConfig.nobilityLevelList then 
            return true,nHighLevelCount,nHighLevel,nHighLevelCount,false
        end
    end
        
        
    return false,0,0,0,false
end

function NobilityPrivilegeModel:gc_NobilityPrivilegePlayerLogin()
    if not cc.exports.isNobilityPrivilegeSupported()  then
        return
    end

    self._info = {}
    if user.nUserID == nil or user.nUserID < 0 then
        print("userinfo is not ok")
        return
    end

    local UserModel = mymodel('UserModel'):getInstance()
    local data = {
        userID = user.nUserID,
        userName = UserModel.szUsername
    }

    local pdata = protobuf.encode('pbNobilityPrivilege.NobilityPlayerLogin', data)
    AssistModel:sendData(NobilityPrivilegeDef.GR_NOBILITY_PRIVILEGE_USER_LOGIN, pdata, false)
end

--充值是否加赠，返回值 是否开启  是否解锁  解锁等级 加成
function NobilityPrivilegeModel:isRechargeGive()
    if not self:isAlive()  then
        return  false,false,0,0
    end

    local nLevel = self._NobilityPrivilegeInfo.level
    local nUnlockLevel = -1
    local nShowValue = 0
    local nMyShowValue = 0

    for j=#self._NobilityPrivilegeConfig.nobilityLevelList,1,-1 do
        local  nPrivilegeDetail= self._NobilityPrivilegeConfig.nobilityLevelList[j].privilegeDetail
        for i=1,#nPrivilegeDetail do
            for u, v in pairs(self._NobilityPrivilegeConfig.privilegeList) do
                if nPrivilegeDetail[i].privilegeID == v.privilegeID then
                    if v.privilegeType == NobilityPrivilegeDef.PRIVILEGE_SHOP_GIVE then
                        nUnlockLevel = j -1
                        nShowValue = v.showValue[1]
                    end
                end
            end
        end
    end

    local  nPrivilegeDetail= self._NobilityPrivilegeConfig.nobilityLevelList[nLevel+1].privilegeDetail
    for i=1,#nPrivilegeDetail do
        for u, v in pairs(self._NobilityPrivilegeConfig.privilegeList) do
            if nPrivilegeDetail[i].privilegeID == v.privilegeID then
                if v.privilegeType == NobilityPrivilegeDef.PRIVILEGE_SHOP_GIVE then
                    nMyShowValue = v.showValue[1]
                end
            end
        end
    end


    if nUnlockLevel >= 0 then
        if nLevel >= nUnlockLevel then
            return true,true,nLevel,nMyShowValue
        else
            return true,false,nUnlockLevel,nShowValue
        end
    end

    return  false,false,0,0
end

--礼券是否加赠，返回值 是否开启  是否解锁  解锁等级 加成
function NobilityPrivilegeModel:isExchangeGive()
    if not self:isAlive()  then
        return  false,false,0,0
    end

    local nLevel = self._NobilityPrivilegeInfo.level
    local nUnlockLevel = -1
    local nShowValue = 0
    local nMyShowValue = 0

    for j=#self._NobilityPrivilegeConfig.nobilityLevelList,1,-1 do
        local  nPrivilegeDetail= self._NobilityPrivilegeConfig.nobilityLevelList[j].privilegeDetail
        for i=1,#nPrivilegeDetail do
            for u, v in pairs(self._NobilityPrivilegeConfig.privilegeList) do
                if nPrivilegeDetail[i].privilegeID == v.privilegeID then
                    if v.privilegeType == NobilityPrivilegeDef.PRIVILEGE_EXCHANGE_GIVE then
                        nUnlockLevel = j -1
                        nShowValue = v.showValue[1]
                    end
                end
            end
        end
    end

    local  nPrivilegeDetail= self._NobilityPrivilegeConfig.nobilityLevelList[nLevel+1].privilegeDetail
    for i=1,#nPrivilegeDetail do
        for u, v in pairs(self._NobilityPrivilegeConfig.privilegeList) do
            if nPrivilegeDetail[i].privilegeID == v.privilegeID then
                if v.privilegeType == NobilityPrivilegeDef.PRIVILEGE_EXCHANGE_GIVE then
                    nMyShowValue = v.showValue[1]
                end
            end
        end
    end


    if nUnlockLevel >= 0 then
        if nLevel >= nUnlockLevel then
            return true,true,nLevel,nMyShowValue
        else
            return true,false,nUnlockLevel,nShowValue
        end
    end

    return  false,false,0,0
end

--是否免广告
function NobilityPrivilegeModel:isAdverFree()
    if not self:isAlive()  then
        return  false
    end

    local nLevel = self._NobilityPrivilegeInfo.level
    local nUnlockLevel = -1

    for j=#self._NobilityPrivilegeConfig.nobilityLevelList,1,-1 do
        local  nPrivilegeDetail= self._NobilityPrivilegeConfig.nobilityLevelList[j].privilegeDetail
        for i=1,#nPrivilegeDetail do
            for u, v in pairs(self._NobilityPrivilegeConfig.privilegeList) do
                if nPrivilegeDetail[i].privilegeID == v.privilegeID then
                    if v.privilegeType == NobilityPrivilegeDef.PRIVILEGE_REMOVE_ADVERT then
                        nUnlockLevel = j -1
                    end
                end
            end
        end
    end

    if nUnlockLevel >= 0 then
        if nLevel >= nUnlockLevel then
            return true,true,nLevel
        else
            return true,false,nUnlockLevel
        end
    end

    return  false,false,0
end

--是否自动存取银  返回值， 是否开启 是否解锁 贵族几解锁
function NobilityPrivilegeModel:isAutoSupply()
    if not self:isAlive()  then
        return  false,false,0
    end

    local nLevel = self._NobilityPrivilegeInfo.level
    local nUnlockLevel = -1


    for j=#self._NobilityPrivilegeConfig.nobilityLevelList,1,-1 do
        local  nPrivilegeDetail= self._NobilityPrivilegeConfig.nobilityLevelList[j].privilegeDetail
        for i=1,#nPrivilegeDetail do
            for u, v in pairs(self._NobilityPrivilegeConfig.privilegeList) do
                if nPrivilegeDetail[i].privilegeID == v.privilegeID then
                    if v.privilegeType == NobilityPrivilegeDef.PRIVILEGE_AUTO_SUPPLY then
                        nUnlockLevel = j -1
                    end
                end
            end
        end
    end

    if nUnlockLevel >= 0 then
        if nLevel >= nUnlockLevel then
            return true,true,nLevel
        else
            return true,false,nUnlockLevel
        end
    end

    return  false,false,0
end

--是否兑换中心广播  返回值， 是否开启 是否解锁 贵族几解锁
function NobilityPrivilegeModel:isExchangeBroadcast()
    if not self:isAlive()  then
        return  false,false,0
    end

    local nLevel = self._NobilityPrivilegeInfo.level
    local nUnlockLevel = -1


    for j=#self._NobilityPrivilegeConfig.nobilityLevelList,1,-1 do
        local  nPrivilegeDetail= self._NobilityPrivilegeConfig.nobilityLevelList[j].privilegeDetail
        for i=1,#nPrivilegeDetail do
            for u, v in pairs(self._NobilityPrivilegeConfig.privilegeList) do
                if nPrivilegeDetail[i].privilegeID == v.privilegeID then
                    if v.privilegeType == NobilityPrivilegeDef.PRIVILEGE_EXCHANGE_BROADCAST then
                        nUnlockLevel = j -1
                    end
                end
            end
        end
    end

    if nUnlockLevel >= 0 then
        if nLevel >= nUnlockLevel then
            return true,true,nLevel
        else
            return true,false,nUnlockLevel
        end
    end

    return  false,false,0
end

--是否增加抽奖次数
function NobilityPrivilegeModel:isAddLotteryCount()
    if not self:isAlive()  then
        return  false,false,0,0
    end

    local nLevel = self._NobilityPrivilegeInfo.level
    local nUnlockLevel = -1
    local nShowValue = 0
    local nMyShowValue = 0

    for j=#self._NobilityPrivilegeConfig.nobilityLevelList,1,-1 do
        local  nPrivilegeDetail= self._NobilityPrivilegeConfig.nobilityLevelList[j].privilegeDetail
        for i=1,#nPrivilegeDetail do
            for u, v in pairs(self._NobilityPrivilegeConfig.privilegeList) do
                if nPrivilegeDetail[i].privilegeID == v.privilegeID then
                    if v.privilegeType == NobilityPrivilegeDef.PRIVILEGE_LOTTERYTIME_ADD then
                        nUnlockLevel = j -1
                        nShowValue = v.privilegeLevel + 1
                    end
                end
            end
        end
    end

    local  nPrivilegeDetail= self._NobilityPrivilegeConfig.nobilityLevelList[nLevel+1].privilegeDetail
    for i=1,#nPrivilegeDetail do
        for u, v in pairs(self._NobilityPrivilegeConfig.privilegeList) do
            if nPrivilegeDetail[i].privilegeID == v.privilegeID then
                if v.privilegeType == NobilityPrivilegeDef.PRIVILEGE_LOTTERYTIME_ADD then
                    nMyShowValue = v.privilegeLevel + 1
                end
            end
        end
    end


    if nUnlockLevel >= 0 then
        if nLevel >= nUnlockLevel then
            return true,true,nLevel,nMyShowValue
        else
            return true,false,nUnlockLevel,nShowValue
        end
    end

    return  false,false,0,0
end

function NobilityPrivilegeModel:getNobilityLogSdkCommonInfo()
    local deviceUtils = DeviceUtils:getInstance()
    local nobilityLogSdkInfo = {
        ["clickTime"]       = os.date("%Y%m%d%H%M%S", os.time()),
        ["userID"]          = user.nUserID,
        ["platFormType"]    = device.platform,
        ["tcyChannel"]      = tostring(my.getTcyChannelId()),
        ["clientVersion"]   = BusinessUtils:getInstance():getAppVersion(),
        ["deviceType"]      = deviceUtils:getPhoneBrand(),
        ["operator"]        = deviceUtils.getSPN and deviceUtils:getSPN() or "暂无数据",
        ["networkType"]     = my.getNetworkTypeString(),
        ["behaviorUnique"]  = tostring(user.nUserID..os.date("%Y%m%d%H%M%S", os.time()))
    }

    return nobilityLogSdkInfo
end

function NobilityPrivilegeModel:getRoomNPLevelLimit(roomid)
    if self:isAlive() then
        local roomLevelLimtConfig = self._NobilityPrivilegeConfig.roomNPLevelLimitConfig
        for i, v in pairs(roomLevelLimtConfig) do
            if v and v.roomid == roomid then
                return v.level
            end
        end
    end
    return 0
end

function NobilityPrivilegeModel:isRoomEnableEnterByNPLevel(roomid)
    if not roomid then
        return false
    end
    if self:isAlive() then
        local roomNPLevel = self:getRoomNPLevelLimit(roomid)
        local userNPLevel = self:GetSelfNobilityPrivilegeLevel()
        return userNPLevel >= roomNPLevel
    end
    return true
end

return NobilityPrivilegeModel