local NobilityPrivilegeGiftModel =class('NobilityPrivilegeGiftModel',require('src.app.GameHall.models.BaseModel'))
local AssistModel = mymodel('assist.AssistModel'):getInstance()
local NobilityPrivilegeGiftDef = require('src.app.plugins.NobilityPrivilegeGift.NobilityPrivilegeGiftDef')
local user = mymodel('UserModel'):getInstance()
local BroadcastModel = mymodel("hallext.BroadcastModel"):getInstance()
local ShopModel = mymodel("ShopModel"):getInstance()
local deviceModel                   = mymodel('DeviceModel'):getInstance()
local NobilityPrivilegeModel      = import("src.app.plugins.NobilityPrivilege.NobilityPrivilegeModel"):getInstance()

local treepack = cc.load('treepack')
local json = cc.load("json").json

local coms=cc.load('coms')
local PropertyBinder=coms.PropertyBinder
my.setmethods(NobilityPrivilegeGiftModel,PropertyBinder)

my.addInstance(NobilityPrivilegeGiftModel)

NobilityPrivilegeGiftModel.EVENT_MAP = {
    ["NobilityPrivilegeGiftModel_NobilityPrivilegeGiftAvailChanged"] = "NobilityPrivilegeGiftModel_NobilityPrivilegeGiftAvailChanged"
}

protobuf.register_file('src/app/plugins/NobilityPrivilegeGift/proto/pbMemberTrans.pb')

function NobilityPrivilegeGiftModel:onCreate()
    self._NobilityPrivilegeGiftConfig = nil
    self._NobilityPrivilegeGiftInfo = nil

    self:initAssistResponse()
end

function NobilityPrivilegeGiftModel:reset( )
    self._NobilityPrivilegeGiftConfig = nil
    self._NobilityPrivilegeGiftInfo = nil
end

function NobilityPrivilegeGiftModel:initAssistResponse()
    self._assistResponseMap = {
        [NobilityPrivilegeGiftDef.GR_NOBILITY_PRIVILEGE_GIFT_GET_INFO] = handler(self, self.onNobilityPrivilegeGiftInfo),
        [NobilityPrivilegeGiftDef.GR_NOBILITY_PRIVILEGE_GIFT_TRANSFER] = handler(self, self.onTransferNobilityPrivilegeGiftRet),
        [NobilityPrivilegeGiftDef.GR_NOBILITY_PRIVILEGE_GIFT_PAY_SUCCESS] = handler(self, self.onNobilityPrivilegeGiftPaySuccessRet)
    }
    AssistModel:registCtrl(self, self.dealAssistResponse)
end

function NobilityPrivilegeGiftModel:gc_GetNobilityPrivilegeGiftInfo(nDate)
    if not cc.exports.isNobilityPrivilegeGiftSupported()  then
        return
    end
    self:reset()
    if not nDate then
        nDate = 0
    end

    if user.nUserID == nil or user.nUserID < 0 then
        print("userinfo is not ok")
        return
    end

    local platFormType = NobilityPrivilegeGiftDef.NOBILITY_PRIVILEGE_GIFT_APPTYPE_AN
    if MCAgent:getInstance().getLaunchSubMode and MCAgent:getInstance():getLaunchSubMode() == 1 then
        platFormType = NobilityPrivilegeGiftDef.NOBILITY_PRIVILEGE_GIFT_APPTYPE_SET
    elseif cc.exports.LaunchMode["PLATFORM"] == MCAgent:getInstance():getLaunchMode() then
        if device.platform == 'ios' then
            platFormType = NobilityPrivilegeGiftDef.NOBILITY_PRIVILEGE_GIFT_APPTYPE_IOS
        else
            platFormType = NobilityPrivilegeGiftDef.NOBILITY_PRIVILEGE_GIFT_APPTYPE_AN
        end
    end

    local data = {
        userID = user.nUserID,
        platform = platFormType,
        endDate = nDate,
        transStatus = 0
    }
    local pdata = protobuf.encode('pbMemberTrans.memberTransInfo', data)
    AssistModel:sendData(NobilityPrivilegeGiftDef.GR_NOBILITY_PRIVILEGE_GIFT_GET_INFO, pdata, false)
end

function NobilityPrivilegeGiftModel:onNobilityPrivilegeGiftInfo(data)
    if string.len(data) == nil then return nil end

    local pdata = protobuf.decode('pbMemberTrans.memberTransInfo', data)
    protobuf.extract(pdata)

    self._NobilityPrivilegeGiftInfo = pdata

    if self._NobilityPrivilegeGiftInfo.transStatus == 0 then
        --一天只弹一次
        local nDate = tonumber(CacheModel:getCacheByKey("PopMemberTransfer"))
        local nToday = os.date('%Y%m%d',os.time())
        if not nDate then nDate = 0 end
        if tonumber(nDate) < tonumber(nToday) and user.isMember then 
            ---my.informPluginByName({pluginName = "MemberTransferCtrl"})
            local PluginProcessModel = mymodel("hallext.PluginProcessModel"):getInstance()
            PluginProcessModel:setPluginReadyStatus("MemberTransferCtrl", true)
            PluginProcessModel:startPluginProcess()
            CacheModel:saveInfoToCache("PopMemberTransfer", os.date('%Y%m%d',os.time()))
        end
    end

    --本次版本不要贵族礼包了
--    if (self._NobilityPrivilegeGiftInfo.transStatus == 0) or (self._NobilityPrivilegeGiftInfo.transStatus == 1 and self._NobilityPrivilegeGiftInfo.rechargeStatus == 1) then
--        if self._myStatusDataExtended["isNobilityPrivilegeGiftAvail"] then
--            self._myStatusDataExtended["isNobilityPrivilegeGiftAvail"] = false
--            self:dispatchModuleStatusChanged("NobilityPrivilegeGift", NobilityPrivilegeGiftModel.EVENT_MAP["NobilityPrivilegeGiftModel_NobilityPrivilegeGiftAvailChanged"])
--        end
--    elseif self._NobilityPrivilegeGiftInfo.transStatus == 1 then
--        if not self._myStatusDataExtended["isNobilityPrivilegeGiftAvail"] then
--            self._myStatusDataExtended["isNobilityPrivilegeGiftAvail"] = true
--            self:dispatchModuleStatusChanged("NobilityPrivilegeGift", NobilityPrivilegeGiftModel.EVENT_MAP["NobilityPrivilegeGiftModel_NobilityPrivilegeGiftAvailChanged"])
--        end
--    end

--    self:dispatchEvent({name = NobilityPrivilegeGiftDef.NobilityPrivilegeGiftInfoRet})
end

function NobilityPrivilegeGiftModel:gc_TransferNobilityPrivilegeGift()
    local nDate = 0
    if not cc.exports.isNobilityPrivilegeGiftSupported()  then
        return
    end

    if user.nUserID == nil or user.nUserID < 0 then
        print("userinfo is not ok")
        return
    end

    local platFormType = NobilityPrivilegeGiftDef.NOBILITY_PRIVILEGE_GIFT_APPTYPE_AN
    if MCAgent:getInstance().getLaunchSubMode and MCAgent:getInstance():getLaunchSubMode() == 1 then
        platFormType = NobilityPrivilegeGiftDef.NOBILITY_PRIVILEGE_GIFT_APPTYPE_SET
    elseif cc.exports.LaunchMode["PLATFORM"] == MCAgent:getInstance():getLaunchMode() then
        if device.platform == 'ios' then
            platFormType = NobilityPrivilegeGiftDef.NOBILITY_PRIVILEGE_GIFT_APPTYPE_IOS
        else
            platFormType = NobilityPrivilegeGiftDef.NOBILITY_PRIVILEGE_GIFT_APPTYPE_AN
        end
    end

    local data = {
        userID = user.nUserID,
        platform = platFormType,
        endDate = nDate,
        transStatus = 1
    }
    local pdata = protobuf.encode('pbMemberTrans.memberTransInfo', data)
    AssistModel:sendData(NobilityPrivilegeGiftDef.GR_NOBILITY_PRIVILEGE_GIFT_TRANSFER, pdata, false)
end


function NobilityPrivilegeGiftModel:onTransferNobilityPrivilegeGiftRet(data)
    if string.len(data) == nil then return nil end

    local pdata = protobuf.decode('pbMemberTrans.memberTransInfo', data)
    protobuf.extract(pdata)

    self._NobilityPrivilegeGiftInfo = pdata  
    my.informPluginByName({pluginName = "MemberTransferCtrl"})
    self:gc_GetNobilityPrivilegeGiftInfo()

    NobilityPrivilegeModel:gc_GetNobilityPrivilegeInfo()  --转换成功增加经验，重新获取
end

function NobilityPrivilegeGiftModel:onNobilityPrivilegeGiftPaySuccessRet(data)
    if string.len(data) == nil then return nil end

    local awardRet = protobuf.decode('pbMemberTrans.timeLimitGiftBagPaySuccess', data)
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
    self:gc_GetNobilityPrivilegeGiftInfo()
end

function NobilityPrivilegeGiftModel:GetNobilityPrivilegeGiftInfo()
    if self._NobilityPrivilegeGiftInfo then
        return self._NobilityPrivilegeGiftInfo
    end
    return nil
end

function NobilityPrivilegeGiftModel:GetNobilityPrivilegeGiftConfig()
    if self._NobilityPrivilegeGiftConfig then
        return self._NobilityPrivilegeGiftConfig
    end
    return nil
end

function NobilityPrivilegeGiftModel:isNeedReddot()
    return  true
end

--开启付费
function NobilityPrivilegeGiftModel:AppType()
    local platFormType = NobilityPrivilegeGiftDef.NOBILITY_PRIVILEGE_GIFT_APPTYPE_AN
    if MCAgent:getInstance().getLaunchSubMode and MCAgent:getInstance():getLaunchSubMode() == 1 then
        platFormType = NobilityPrivilegeGiftDef.NOBILITY_PRIVILEGE_GIFT_APPTYPE_SET
    elseif cc.exports.LaunchMode["PLATFORM"] == MCAgent:getInstance():getLaunchMode() then
        if device.platform == 'ios' then
            platFormType = NobilityPrivilegeGiftDef.NOBILITY_PRIVILEGE_GIFT_APPTYPE_IOS
        else
            platFormType = NobilityPrivilegeGiftDef.NOBILITY_PRIVILEGE_GIFT_APPTYPE_AN
        end
    end

    return platFormType
end

function NobilityPrivilegeGiftModel:_payFor(price,exchangeid)
    if self._waitingPayResult then return end
    
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
            print("NobilityPrivilegeGiftModel single app")
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
    
        print("NobilityPrivilegeGiftModel pay_ext_args:", strPayExtArgs)
        return strPayExtArgs
            
    end
    
    local paymodel = mymodel("PayModel"):getInstance()
    local param = clone(paymodel:getPayMetaTable())
    
    param["Product_Name"]   = "特权礼包"
    param["Product_Id"] = ""  --sid
        
    local apptype = self:AppType()
    print("----------------------------------apptype = ",apptype)
    print("------ price and exchangeid:",price,exchangeid)
    if apptype == NobilityPrivilegeGiftDef.NOBILITY_PRIVILEGE_GIFT_APPTYPE_AN then
        print("NOBILITY_PRIVILEGE_GIFT_APPTYPE_AN")
    elseif apptype == NobilityPrivilegeGiftDef.NOBILITY_PRIVILEGE_GIFT_APPTYPE_SET then
        print("NOBILITY_PRIVILEGE_GIFT_APPTYPE_SET")
    elseif apptype == NobilityPrivilegeGiftDef.NOBILITY_PRIVILEGE_GIFT_APPTYPE_IOS then
        print("NOBILITY_PRIVILEGE_GIFT_APPTYPE_IOS")
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
        dump(param, "NobilityPrivilegeGiftModel:payForProduct param")
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
            else
                if string.len(msg) ~= 0 then
                    --刷新消息，让充值按钮可以点击
                    self:gc_GetNobilityPrivilegeGiftInfo()
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

function NobilityPrivilegeGiftModel:isAlive()
    if not cc.exports.isNobilityPrivilegeGiftSupported()  then
        return  false
    end

    if  not self._NobilityPrivilegeGiftInfo then
        return false
    end

    if self._NobilityPrivilegeGiftInfo and self._NobilityPrivilegeGiftInfo.transStatus == 0 then
        return false
    end

    if self._NobilityPrivilegeGiftInfo and self._NobilityPrivilegeGiftInfo.transStatus == 1 and self._NobilityPrivilegeGiftInfo.rechargeStatus == 1 then
        return false
    end

    return true
end

function NobilityPrivilegeGiftModel:isNeedPop()
    if not cc.exports.isNobilityPrivilegeGiftSupported()  then
        return  false
    end

    if  not self._NobilityPrivilegeGiftInfo then
        return false
    end

    if not user.isMember then
        return false
    end

    if self._NobilityPrivilegeGiftInfo and self._NobilityPrivilegeGiftInfo.transStatus == 0 then
        return true
    end

    return false
end

return NobilityPrivilegeGiftModel