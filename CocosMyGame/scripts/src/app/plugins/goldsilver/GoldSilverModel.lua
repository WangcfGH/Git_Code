local GoldSilverModel = class("GoldSilverModel", require('src.app.GameHall.models.BaseModel'))
local AssistModel = mymodel('assist.AssistModel'):getInstance()
local Def = require('src.app.plugins.goldsilver.GoldSilverDef')
local Req = require('src.app.plugins.goldsilver.GoldSilverReq')
local user = mymodel('UserModel'):getInstance()
local treepack = cc.load('treepack')

local playerModel = mymodel("hallext.PlayerModel"):getInstance()
local ExchangeCenterModel = require("src.app.plugins.ExchangeCenter.ExchangeCenterModel"):getInstance()
local MyTimeStamp = import('src.app.mycommon.mytimestamp.MyTimeStamp'):getInstance()

GoldSilverModel.BUY_TYPE_SILVER = 0
GoldSilverModel.BUY_TYPE_GOLD = 1

local GamePublicInterface                       = cc.exports.GamePublicInterface

GoldSilverModel.EVENT_MAP = {
    ["goldSilver_rewardAvailChanged"] = "goldSilver_rewardAvailChanged"
}

function GoldSilverModel:onCreate()

    self._assistResponseMap = {
        [Def.GR_GOLDSILVER_INFO_RESP] = handler(self, self.GoldSilverInfoResp),
        [Def.GR_GOLDSILVER_TAKEREWARD_RESP] = handler(self,self.GoldSilverTakeRewardResp),
        [Def.GR_GOLDSILVER_PAY_REQ] = handler(self,self.payForResp),
        [Def.GR_GOLDSILVER_SYN_SCORE] = handler(self,self.OnSynUserScore),
        [Def.GR_GOLDSILVER_SYN_BUYSTATE] = handler(self,self.OnSynBuyState),
        [Def.GR_GOLDSILVER_SYN_INICONFIG] = handler(self,self.OnSynIniConfig),
        [Def.GR_GOLDSILVER_SYN_REWARDCONFIG] = handler(self,self.OnRewardConfigChanged)
    }
    AssistModel:registCtrl(self, self.dealAssistResponse)
end

function GoldSilverModel:reset( )
    self._info = {}
    self._rewardConfig = {}
    self._waitingResponse = false
    self._firstReq = true
end

function GoldSilverModel:GoldSilverInfoReq()
    if self._waitingResponse then return end
    self._waitingResponse = true
    my.scheduleOnce(function()
        self._waitingResponse = false
    end,1)

    self._info = {}
    if user.nUserID == nil or user.nUserID < 0 then
        print("userinfo is not ok")
        return
    end
    local DeviceModel = require("src.app.GameHall.models.DeviceModel"):getInstance()
    local deviceCombineID = DeviceModel.szHardID..DeviceModel.szMachineID..DeviceModel.szVolumeID
    
    local nUserID = user.nUserID
    local cache = my.readCache("GoldSilverCache" .. nUserID .. ".xml")
    local fileTime = "0"
    if cache and cache["fileTime"] then
        fileTime = cache["fileTime"]
    end

    if self._firstReq then
        fileTime = "0"
        --self._firstReq = false
    end

    if cache and cache["rewardConfig"] then
        self._rewardConfig = cache["rewardConfig"]
    end

    local apptype = self:GetPackageType()

    print("----------------------------------apptype = ",apptype)
    local data = {
        nUserID = user.nUserID ,
        nPackageType = apptype,
        nChannelID = tonumber(BusinessUtils:getInstance():getTcyChannel()),
        szFileTime = fileTime,
        szDeviceID     = deviceCombineID,
        nResult = 0
    }

    AssistModel:sendRequest(Def.GR_GOLDSILVER_INFO_REQ, Req.GOLDSILVERINFO_REQ, data, false)
end

function GoldSilverModel:GoldSilverInfoResp(data)
    local result
    result,data = AssistModel:convertDataToStruct(data,Req["GOLDSILVERINFO_RESPEX"]);

    if result.nUserID ~= user.nUserID then
        return
    end

    self._info = result

    if result.nStatusCode~=Def.GOLDSILVER_SUCCESS then
        self:dispatchEvent({name = Def.GoldSilverInfoReceived})
        return
    end

    print("----------------------------------nUpdateConfig = ",result.nUpdateConfig)
    if result.nUpdateConfig == 1 then
        if result.head and result.head.nLeavel then
            self._rewardConfig = {}
            for i = 1,result.head.nLeavel do
                local process
                process,data = AssistModel:convertDataToStruct(data,Req["GOLDSILVERPROCESS"])
                table.insert( self._rewardConfig,process)
            end
        end

        dump(self._rewardConfig)
        local data = {}
        data["rewardConfig"] = self._rewardConfig
        data["fileTime"] = result.szFileTime
        local nUserID = user.nUserID
        if nUserID then
            my.saveCache("GoldSilverCache".. nUserID .. ".xml",data)
        end
    end

    self:dispatchEvent({name = Def.GoldSilverInfoReceived})
    self._myStatusDataExtended["isNeedReddot"] = self:isRewardAvail()
    self:dispatchModuleStatusChanged("goldSilver", GoldSilverModel.EVENT_MAP["goldSilver_rewardAvailChanged"])

        --登录弹窗模块
    local PluginProcessModel = mymodel("hallext.PluginProcessModel"):getInstance()
    PluginProcessModel:setPluginReadyStatus("GoldSilverCtrl", true)
    PluginProcessModel:startPluginProcess()  
end

function GoldSilverModel:GoldSilverTakeRewardReq(nTakeType, nLevel)
    if self._waitingResponse then return end
    self._waitingResponse = true
    my.scheduleOnce(function()
        self._waitingResponse = false
    end,1)

    if user.nUserID == nil or user.nUserID < 0 then
        print("userinfo is not ok")
    end

    local DeviceModel = require("src.app.GameHall.models.DeviceModel"):getInstance()
    local deviceCombineID = DeviceModel.szHardID..DeviceModel.szMachineID..DeviceModel.szVolumeID

    local apptype = self:GetPackageType()
    local data = {
        nUserID = user.nUserID,
        nPackageType = apptype,
        nChannelID = tonumber(BusinessUtils:getInstance():getTcyChannel()),
        szDeviceID     = deviceCombineID,
        nTakeType = nTakeType,
        nLevel = nLevel,
        nResult = 0
    }
    AssistModel:sendRequest(Def.GR_GOLDSILVER_TAKEREWARD_REQ, Req.GOLDSILVERTAKEREWARD_REQ, data, false)
end

function GoldSilverModel:GoldSilverTakeRewardResp(data)
    local result
    result = AssistModel:convertDataToStruct(data,Req["GOLDSILVERTAKEREWARD_RESPEX"]);

    if result.nUserID ~= user.nUserID then
        return
    end

    if result.nStatusCode ~= Def.GOLDSILVER_SUCCESS then
        my.informPluginByName({pluginName='TipPlugin',params={tipString="领取失败，请及时联系客服",removeTime=2}})
        return
    end

    --领奖成功
    if self._info and next(self._info) ~= nil then
        self._info.llfreelowStatus.nStateLow = result.llfreelowStatus.nStateLow
        self._info.llfreelowStatus.nStateHigh = result.llfreelowStatus.nStateHigh
        self._info.llfreehighStatus.nStateLow = result.llfreehighStatus.nStateLow
        self._info.llfreehighStatus.nStateHigh = result.llfreehighStatus.nStateHigh
        self._info.llsilverlowStatus.nStateLow = result.llsilverlowStatus.nStateLow
        self._info.llsilverlowStatus.nStateHigh = result.llsilverlowStatus.nStateHigh
        self._info.llsilverhighStatus.nStateLow = result.llsilverhighStatus.nStateLow
        self._info.llsilverhighStatus.nStateHigh = result.llsilverhighStatus.nStateHigh
        self._info.llgoldlowStatus.nStateLow = result.llgoldlowStatus.nStateLow
        self._info.llgoldlowStatus.nStateHigh = result.llgoldlowStatus.nStateHigh
        self._info.llgoldhighStatus.nStateLow = result.llgoldhighStatus.nStateLow
        self._info.llgoldhighStatus.nStateHigh = result.llgoldhighStatus.nStateHigh
    end 

    local nSilver = result.nSilver
    local nTicket = result.nTicket

    local rewardList = {}
    if nSilver>0 then
        table.insert( rewardList,{nType = 1,nCount = nSilver})
    end

    if nTicket>0 then
        table.insert( rewardList,{nType = 2,nCount = nTicket})
    end

    self:updateUserTicketInfo(nTicket)
    my.scheduleOnce(function ()
        local playerModel = mymodel("hallext.PlayerModel"):getInstance()
        playerModel:update({'SafeboxInfo','MemberInfo','UserGameInfo'})
    end, 2)

    --弹出奖励界面
    my.informPluginByName({pluginName = "RewardTipCtrl", params = {data = rewardList}})
    self:dispatchEvent({name = Def.GoldSilverTakeRewardRet})
    self._myStatusDataExtended["isNeedReddot"] = self:isRewardAvail()
    self:dispatchModuleStatusChanged("goldSilver", GoldSilverModel.EVENT_MAP["goldSilver_rewardAvailChanged"])
end

function GoldSilverModel:OnSynUserScore(data)
    local result = treepack.unpack(data, Req["GOLDSILVER_SCORECHANGE"])

    if result.nUserID ~= user.nUserID then
        return
    end

    --金银杯经验加成游戏内给个提示
    local nDiffScore = 0
    local levelbefore = self:GetCurLevel()
    local status = Def.GOLDSILVER_NOTOPEN
    if self._info and next(self._info) ~= nil then
        nDiffScore = result.nDailyScore - self._info.nDailyScore
        self._info.nDailyScore = result.nDailyScore
        self._info.nTotalScore = result.nTotalScore
        status = self._info.nStatusCode
    end
    local levelafter = self:GetCurLevel()
    if levelbefore~=levelafter then
        if levelafter == 1 then
            my.dataLink(cc.exports.DataLinkCodeDef.GOLD_SILVER_UPGRADE_ONE, {strDate = os.date("%Y%m%d")})
        elseif levelafter == #self._rewardConfig then
            my.dataLink(cc.exports.DataLinkCodeDef.GOLD_SILVER_UPGRADE_MAX, {strDate = os.date("%Y%m%d")})
        end
    end

    self:dispatchEvent({name = Def.SynGoldSilverScore})
    self._myStatusDataExtended["isNeedReddot"] = self:isRewardAvail()
    self:dispatchModuleStatusChanged("goldSilver", GoldSilverModel.EVENT_MAP["goldSilver_rewardAvailChanged"])

    if status and status == Def.GOLDSILVER_SUCCESS and my.isInGame() and nDiffScore > 0 then
        local string = "恭喜您获得金银杯经验  +"..nDiffScore
        my.informPluginByName( { pluginName = 'TipPlugin', params = { tipString = string, removeTime = 1.0 } })
    end
end

function GoldSilverModel:OnSynBuyState(data)
    local result = treepack.unpack(data, Req["GOLDSILVER_BUYSTATUSCHANGE"])

    if result.nUserID ~= user.nUserID then
        return
    end

    if self._info and next(self._info) ~= nil then
        self._info.nSilverBuyStatus = result.nSilverState
        self._info.nGoldBuyStatus = result.nGoldState
    end

    self:dispatchEvent({name = Def.SynGoldSilverBuyState})
    self._myStatusDataExtended["isNeedReddot"] = self:isRewardAvail()
    self:dispatchModuleStatusChanged("goldSilver", GoldSilverModel.EVENT_MAP["goldSilver_rewardAvailChanged"])
end

function GoldSilverModel:payForReq(nPayType)
    if self._waitingResponse then 
        my.informPluginByName({pluginName = 'TipPlugin',params = {tipString = "点击太频繁，请2秒后再操作", removeTime = 2}})
        return
    end
    self._waitingResponse = true
    my.scheduleOnce(function()
        self._waitingResponse = false
    end,1)

    if user.nUserID == nil or user.nUserID < 0 then
        print("userinfo is not ok")
        return
    end
        
    local data = {
        nUserID = user.nUserID, 
        nPayType = nPayType
    }

    AssistModel:sendRequest(Def.GR_GOLDSILVER_PAY_REQ, Req.GOLDSILVERPAY_REQ, data, false)
end

function GoldSilverModel:payForResp(data)
    local result = treepack.unpack(data, Req["GOLDSILVERPAY_RESP"]);
    if result.nUserID ~= user.nUserID then
        return
    end

    if result.nResult ~= Def.GOLDSILVER_SUCCESS then
        -- if result.nResult == Def.PASSCHECK_END then
        --     my.informPluginByName({pluginName='TipPlugin',params={tipString="活动已结束",removeTime=2}})
        -- end
        --return
    end
    self:_payFor(result.nPayType)
end
--
function GoldSilverModel:GetGoldSilverInfo( )
    if self._info and next(self._info) ~= nil then
        return self._info
    end
    return nil
end

function GoldSilverModel:GetGoldSilverRewardConfig( )
    if self._rewardConfig and next(self._rewardConfig) ~= nil then
        return self._rewardConfig
    end
    return nil
end

function GoldSilverModel:GetCurLevel( )
    if not self._info or next(self._info) == nil then return nil end
    if not self._rewardConfig or next(self._rewardConfig) == nil then return nil end

    local tempScore = self._info.nTotalScore
    local level = 0
    for i=1,#self._rewardConfig do
        if tempScore >= self._rewardConfig[i].nNeedScore then
            level = level + 1
            tempScore = tempScore - self._rewardConfig[i].nNeedScore
        else
            break
        end
    end
    return level
end

function GoldSilverModel:GetRoomScoreConfig( )
    if self._info and next(self._info) ~= nil then
        if self._info.stRoomScore and next(self._info.stRoomScore) ~= nil then
            return self._info.stRoomScore
        end
    end
    return nil
end

--nPayType    0:银杯   1:金杯
function GoldSilverModel:_payFor(nPayType)
    if self._waitingPayResult then return end
 
        --local gamecode = "hask"
        local exchangeid = 11362
        local DeviceModel = mymodel('DeviceModel'):getInstance()
        local szWifiID,szImeiID,szSystemID=DeviceModel.szWifiID,DeviceModel.szImeiID,DeviceModel.szSystemID
        local deviceId=string.format('%s,%s,%s',szWifiID,szImeiID,szSystemID)
    
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
                print("GoldSilverModel single app")
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
    
            print("GoldSilverModel pay_ext_args:", strPayExtArgs)
            return strPayExtArgs
            
        end
    
        local paymodel = mymodel("PayModel"):getInstance()
        local param = clone(paymodel:getPayMetaTable())
    
        if nPayType == Def.PAY_TYPE_SILVER then
            param["Product_Name"]   = "银杯"
        else
            param["Product_Name"]   = "金杯"
        end
    
        --param["Product_Count"]  = tostring(44000)
        param["Product_Id"] = ""  --sid
        
        local apptype = self:AppType()
        print("----------------------------------apptype = ",apptype)
        local payLevel = self._info.nPayLevel
        local price
        price,exchangeid = self:GetItem(apptype,nPayType,payLevel)
        print("------ price and exchangeid:",price,exchangeid)
        if apptype == Def.GOLDSILVER_APPTYPE_AN_TCY then
            print("GOLDSILVER_APPTYPE_AN_TCY")
        elseif apptype == Def.GOLDSILVER_APPTYPE_AN_SINGLE then
            print("GOLDSILVER_APPTYPE_AN_SINGLE")
        elseif apptype == Def.GOLDSILVER_APPTYPE_AN_SET then
            print("GOLDSILVER_APPTYPE_AN_SET")
            param["Product_Id"] = "com.uc108.mobile.gamecenter.tongbao" .. price
        elseif apptype == Def.GOLDSILVER_APPTYPE_IOS_TCY then
            print("GOLDSILVER_APPTYPE_IOS_TCY")
            param["Product_Id"] = "com.uc108.mobile.gamecenter.tongbao" .. price
        elseif apptype == Def.GOLDSILVER_APPTYPE_IOS_SINGLE then
            print("GOLDSILVER_APPTYPE_IOS_SINGLE")
            param["Product_Id"] = "com.uc108.mobile.hagd.deposit6.add45000"
        end
    
        --local through_data = string.format("{\"GameCode\":\"%s\",\"DeviceId\":\"%s\",\"RewardToGame\":%d,\"ExchangeId\":%d}", gamecode, deviceId, 0, exchangeid)
        local through_data = string.format("{\"RewardToGame\":%d,\"ExchangeId\":%d}", 0, exchangeid)
    
        param["pay_point_num"]  = 0
        param["Product_Price"] = tostring(price)     --价格
        param["Exchange_Id"]  = tostring(4)      --物品ID  1是银子 2是会员 3是积分 4是钻石
        param["through_data"] = through_data;
        param["ext_args"] = getPayExtArgs();

        local kpiData = my.getKPIClientData()
        param["RecomGameId"]   = tostring(kpiData.RecomGameId)
        param["RecomGameCode"] = kpiData.RecomGameCode
        param["RecomGameVers"] = ""
    
        if device.platform == 'windows' or cc.exports.isHSoxRaySupported() then
            print("To Create ActivityRechargeHSoxCtrl")
            dump(param, "GoldSilverModel:payForProduct param")
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


--comment

function GoldSilverModel:AppType()
    local type = Def.GOLDSILVER_APPTYPE_AN_TCY
    if device.platform == 'android' then
        if MCAgent:getInstance().getLaunchSubMode and MCAgent:getInstance().getLaunchMode then
            local launchMode = MCAgent:getInstance():getLaunchMode()
            local launchSubMode = MCAgent:getInstance():getLaunchSubMode()
            if launchSubMode == cc.exports.LaunchSubMode.PLATFORMSET then
                type = Def.GOLDSILVER_APPTYPE_AN_SET
            elseif launchMode == cc.exports.LaunchMode.PLATFORM then
                type = Def.GOLDSILVER_APPTYPE_AN_TCY
            else
                type = Def.GOLDSILVER_APPTYPE_AN_SINGLE
            end
        elseif MCAgent:getInstance().getLaunchMode then
            local launchMode = MCAgent:getInstance():getLaunchMode()
            if launchMode == cc.exports.LaunchMode.PLATFORM then
                type = Def.GOLDSILVER_APPTYPE_AN_TCY
            else
                type = Def.GOLDSILVER_APPTYPE_AN_SINGLE
            end
        else 
            type = Def.GOLDSILVER_APPTYPE_AN_TCY
        end
    elseif device.platform == 'ios' then
        local launchMode = MCAgent:getInstance():getLaunchMode()
        if launchMode == cc.exports.LaunchMode.PLATFORM then
            type = Def.GOLDSILVER_APPTYPE_IOS_TCY
        else
            type = Def.GOLDSILVER_APPTYPE_IOS_SINGLE
        end
    else
        --other os
    end

    return type
end

function GoldSilverModel:GetItem(appType,buyType,payLevel)
    if payLevel<0 and payLevel>3 then return end
    local priceConfig
    if appType == Def.GOLDSILVER_APPTYPE_AN_TCY or 
    appType == Def.GOLDSILVER_APPTYPE_AN_SINGLE then
        priceConfig = Def.PriceConfig_AN[payLevel+1]
    elseif appType == Def.GOLDSILVER_APPTYPE_AN_SET then
        priceConfig = Def.PriceConfig_SET[payLevel+1]
    elseif appType == Def.GOLDSILVER_APPTYPE_IOS_TCY or 
    appType == Def.GOLDSILVER_APPTYPE_IOS_SINGLE then
        priceConfig = Def.PriceConfig_IOS[payLevel+1]
    end

    if buyType == GoldSilverModel.BUY_TYPE_SILVER then
        return priceConfig.silver.price,priceConfig.silver.exchangeid
    else
        return priceConfig.gold.price,priceConfig.gold.exchangeid
    end
end


function GoldSilverModel:IsLevelGiftReward(nGiftType,nLevel)
    if not self._info or next(self._info) == nil then return true end

    local llStateLow
    local llStateHigh
    if nGiftType == 0 then
        llStateLow = self._info.llfreelowStatus
        llStateHigh = self._info.llfreehighStatus
    elseif nGiftType == 1 then
        llStateLow = self._info.llsilverlowStatus
        llStateHigh = self._info.llsilverhighStatus
    elseif nGiftType == 2 then
        llStateLow = self._info.llgoldlowStatus
        llStateHigh = self._info.llgoldhighStatus
    end


    if nLevel >0 and nLevel<=32 then
        local flag = bit.lshift(1,nLevel-1)
        return self:IsBitSet(llStateLow.nStateLow,flag)
    elseif nLevel>32 and nLevel<=64 then
        local flag = bit.lshift(1,nLevel-33)
        return self:IsBitSet(llStateLow.nStateHigh,flag)
    elseif nLevel>64 and nLevel<=96 then
        local flag = bit.lshift(1,nLevel-65)
        return self:IsBitSet(llStateHigh.nStateLow,flag)
    elseif nLevel>96 and nLevel<=128 then
        local flag = bit.lshift(1,nLevel-97)
        return self:IsBitSet(llStateHigh.nStateHigh,flag)
    end
    return true
end

function GoldSilverModel:IsBuySilverCup( )
    if self._info and next(self._info) ~= nil then
        return self._info.nSilverBuyStatus == 1
    end
    return false
end

function GoldSilverModel:IsBuyGoldCup( )
    if self._info and next(self._info) ~= nil then
        return self._info.nGoldBuyStatus == 1
    end
    return false
end

function GoldSilverModel:GetEndData( )
    local nowtimestamp = MyTimeStamp:getLatestTimeStamp()
    local strYear = os.date('%Y',nowtimestamp)
    local strMonth =os.date('%m',nowtimestamp)
    local strday=os.date('%d',nowtimestamp)

    local endDate
    local nYear = tonumber(strYear)
    local nMonth = tonumber(strMonth)
    if self:leapYear(nYear) then
        local tbl =  {30, 28, 30, 29, 30, 29, 30, 30, 29, 30, 29, 30}
        endDate = strYear .. strMonth .. tbl[nMonth] 
    else
        local tbl =  {30, 27, 30, 29, 30, 29, 30, 30, 29, 30, 29, 30}
        endDate = strYear .. strMonth .. tbl[nMonth]
    end
    return tonumber(endDate)
end

function GoldSilverModel:GetDuringTimeString( )
    local nowtimestamp = MyTimeStamp:getLatestTimeStamp()
    local strYear = os.date('%Y',nowtimestamp)
    local strMonth =os.date('%m',nowtimestamp)
    local strday=os.date('%d',nowtimestamp)

    local endDate
    local nYear = tonumber(strYear)
    local nMonth = tonumber(strMonth)
    if self:leapYear(nYear) then
        local tbl =  {30, 28, 30, 29, 30, 29, 30, 30, 29, 30, 29, 30}
        endDate = strMonth .. "月" .. tbl[nMonth] .. "日"
    else
        local tbl =  {30, 27, 30, 29, 30, 29, 30, 30, 29, 30, 29, 30}
        endDate = strMonth .. "月" .. tbl[nMonth] .. "日"
    end
    local prefix = ""
    if nMonth < 10 then
        prefix = "0"
    end
    return prefix .. string.format("%d月01日-", nMonth) .. endDate
end


function GoldSilverModel:leapYear(year)
    if(year%4==0 and year%100~=0) or (year%4==0 and year%400==0) then
        return true
    end

    return false
end

function GoldSilverModel:GetCountCanReward()
    local curLevel = self:GetCurLevel()
    local rewardConfig = self._rewardConfig
    local info = self._info
    if not rewardConfig or next(rewardConfig)==nil then return end
    if not info or next(info)==nil then return end
    if curLevel>#rewardConfig then return end

    local count = 0
    for i=1,curLevel do
        local item = rewardConfig[i]["stReward"]
        local freeSilver = item.nFreeSilver
        local freeTicket = item.nFreeTicket
        local silverSilver = item.nSilverSilver
        local silverTicket = item.nSilverTicket
        local goldSilver = item.nGoldSilver
        local goldTicket = item.nGoldTicket

        local bReward = false
        bReward = self:IsLevelGiftReward(Def.TAKETYPE_FREE,i)
        if not bReward and (freeSilver>0 or freeTicket>0) then
            count = count +1
        end

        if info.nSilverBuyStatus == 1 then
            bReward = self:IsLevelGiftReward(Def.TAKETYPE_SILVER,i)
            if not bReward and (silverSilver>0 or silverTicket>0) then
                count = count +1
            end
        end

        if info.nGoldBuyStatus == 1 then
            bReward = self:IsLevelGiftReward(Def.TAKETYPE_GOLD,i)
            if not bReward and (goldSilver>0 or goldTicket>0) then
                count = count +1
            end
        end
    end

    return count
end

function GoldSilverModel:updateUserTicketInfo(nCountTicket)
    if nCountTicket and nCountTicket>0 then
        ExchangeCenterModel:addTicketNum(nCountTicket)
    end
end

function GoldSilverModel:NeedPopGoldSilverBuyLayer( )
    local myGameData = self:getMyGameDataXml(user.nUserID)
    local date = self:getMonthDate()
    if date ~= myGameData.loginmonth then
        myGameData.loginmonth = date
        self:saveMyGameDataXml(myGameData, user.nUserID)
        if self:IsBuyGoldCup() and self:IsBuySilverCup() then
            return false
        end
        return true
    end
    return false
end

function GoldSilverModel:getMonthDate()
    local tmYear=os.date('%Y',os.time())
    local tmMon=os.date('%m',os.time())
    return tmYear.."_"..tmMon
end

function GoldSilverModel:saveMyGameDataXml(gameData, nUserID)
    my.saveCache("MyGameData"..nUserID..".xml", gameData)
end

function GoldSilverModel:getMyGameDataXml(nUserID)
    return my.readCache("MyGameData"..nUserID..".xml")
end

function GoldSilverModel:IsHejiPackage()
    if  MCAgent:getInstance().getLaunchSubMode and MCAgent:getInstance():getLaunchSubMode() == cc.exports.LaunchSubMode.PLATFORMSET then
        return true
    end
    return false
end

function GoldSilverModel:isRewardAvail( )
    local count = self:GetCountCanReward()
    if count and count>0 then
        return true
    end
    return false
end

function GoldSilverModel:DealPayResult(isBuySilverCup,isBuyGoldCup)
    local strDate = os.date("%Y%m%d")
    local curLevel = self:GetCurLevel()
    local recharge = self._info.nRecharge
    local safeDeposit = user.nSafeboxDeposit
    local deposit = user.nDeposit

    if isBuySilverCup == true then
        my.informPluginByName({pluginName='TipPlugin',params={tipString="购买银杯成功",removeTime=2}})
        --埋点
        local data = {
            nBuyDate = strDate,
            nBuyType = "silverCup",
            nCurLevel = curLevel,
            nRecharge = recharge,
            nSafeDeposit = safeDeposit,
            nSelfDeposit = deposit
        }
        my.dataLink(cc.exports.DataLinkCodeDef.GOLD_SILVER_PAY, data)
    elseif isBuyGoldCup == true then
        my.informPluginByName({pluginName='TipPlugin',params={tipString="购买金杯成功",removeTime=2}})
        local data = {
            nBuyDate = strDate,
            nBuyType = "GoldCup",
            nCurLevel = curLevel,
            nRecharge = recharge,
            nSafeDeposit = safeDeposit,
            nSelfDeposit = deposit
        }
        my.dataLink(cc.exports.DataLinkCodeDef.GOLD_SILVER_PAY, data)
    end
end

function GoldSilverModel:IsDuringLastTwoDays()
    local sysTime = MyTimeStamp:getLatestTimeStamp()
    local strYear = os.date('%Y',sysTime)
    local strMonth =os.date('%m',sysTime)
    local strday=os.date('%d',sysTime)

    local nYear = tonumber(strYear)
    local nMonth = tonumber(strMonth)
    local nDay = tonumber(strday)
    if self:leapYear(nYear) then
        local tbl =  {30, 28, 30, 29, 30, 29, 30, 30, 29, 30, 29, 30}
        if nDay >= tbl[nMonth] then
            return true
        end
    else
        local tbl =  {30, 27, 30, 29, 30, 29, 30, 30, 29, 30, 29, 30}
        if nDay >= tbl[nMonth] then
            return true
        end
    end
    return false
end

function GoldSilverModel:GetPackageType( )
    local apptype = 0
    if self:IsHejiPackage() then
        apptype = 1
    elseif device.platform == 'android' then
        apptype = 0
    elseif device.platform == 'ios' then
        apptype = 2
    end
    return apptype
end

function GoldSilverModel:OnSynIniConfig(data)
    self:GoldSilverInfoReq()
end

function GoldSilverModel:OnRewardConfigChanged(data)
    self:GoldSilverInfoReq()
end

function GoldSilverModel:GetMaxGoldSilver()
    local nMaxSilver = 0
    if self._rewardConfig and next(self._rewardConfig) ~= nil then
        for i=1,#self._rewardConfig do
            local reward = self._rewardConfig[i]["stReward"]
            if reward.nGoldSilver>nMaxSilver then
                nMaxSilver = reward.nGoldSilver
            end
        end
    end
    return nMaxSilver
end

function GoldSilverModel:IsBitSet(flag,mybit)
    return (mybit == bit.band(mybit, flag))
end

--获取当前等级能够获取的银两、礼券 inType 0:free 1:银杯 2:金杯
--返回 deposit, ticket
function GoldSilverModel:getRewardCountByCurLevel(inType)
    local deposit, ticket = 0, 0

    local curLevel = self:GetCurLevel()
    local rewardConfig = self._rewardConfig
    local info = self._info
    if not rewardConfig or next(rewardConfig)==nil then return deposit, ticket end
    if not info or next(info)==nil then return deposit, ticket end
    if curLevel>#rewardConfig then return deposit, ticket end

    for i=1,curLevel do
        local item = rewardConfig[i]["stReward"]
        local freeSilver = item.nFreeSilver
        local freeTicket = item.nFreeTicket
        local silverSilver = item.nSilverSilver
        local silverTicket = item.nSilverTicket
        local goldSilver = item.nGoldSilver
        local goldTicket = item.nGoldTicket

        local bReward = false
        if inType == Def.TAKETYPE_FREE then
            bReward = self:IsLevelGiftReward(Def.TAKETYPE_FREE,i)
            if not bReward and (freeSilver>0 or freeTicket>0) then
                deposit = deposit + freeSilver
                ticket = ticket + freeTicket
            end
        end

        if inType == Def.TAKETYPE_SILVER then
            bReward = self:IsLevelGiftReward(Def.TAKETYPE_SILVER,i)
            if not bReward and (silverSilver>0 or silverTicket>0) then
                deposit = deposit + silverSilver
                ticket = ticket + silverTicket
            end
        end

        if inType == Def.TAKETYPE_GOLD then
            bReward = self:IsLevelGiftReward(Def.TAKETYPE_GOLD,i)
            if not bReward and (goldSilver>0 or goldTicket>0) then
                deposit = deposit + goldSilver
                ticket = ticket + goldTicket
            end
        end
    end

    return deposit, ticket
end

--获取商品配置 nPayType 0:银杯 1:金杯
function GoldSilverModel:getGoodConfigByType(nPayType)
    local appType = self:AppType()
    local payLevel = self._info.nPayLevel

    if payLevel<0 and payLevel>3 then return end
    local priceConfig
    if appType == Def.GOLDSILVER_APPTYPE_AN_TCY or 
    appType == Def.GOLDSILVER_APPTYPE_AN_SINGLE then
        priceConfig = Def.PriceConfig_AN[payLevel+1]
    elseif appType == Def.GOLDSILVER_APPTYPE_AN_SET then
        priceConfig = Def.PriceConfig_SET[payLevel+1]
    elseif appType == Def.GOLDSILVER_APPTYPE_IOS_TCY or 
    appType == Def.GOLDSILVER_APPTYPE_IOS_SINGLE then
        priceConfig = Def.PriceConfig_IOS[payLevel+1]
    end
    if not priceConfig then return end

    if nPayType == Def.PAY_TYPE_SILVER then
        return priceConfig.silver
    elseif nPayType == Def.PAY_TYPE_GOLD then
        return priceConfig.gold
    end
    return 
end

--银两超过6位数，显示成XX万，保留1位小数，为10.0万时，显示成10万
function GoldSilverModel:getSilverNumString(num)
    local tipString
    if num > 999999 then
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

--获取大厅按钮配置
--返回bShow, tipString
function GoldSilverModel:getHallTipConfig()
    local bShow, tipString = false, "有大量银两可领取"
    if not self._info or self:IsDuringLastTwoDays() --不能购买、已购买都不显示
    or  self._info.nSilverBuyStatus ~= 0 
    or self._info.nGoldBuyStatus ~= 0 then
        return bShow, tipString
    end

    local expectedRewardDeposit, expectedRewardTicket = self:getRewardCountByCurLevel(Def.TAKETYPE_GOLD)
    local goodConfig = self:getGoodConfigByType(Def.PAY_TYPE_GOLD)

    if goodConfig and goodConfig.value
    and expectedRewardDeposit > goodConfig.value then
        bShow = true
        local numString = self:getSilverNumString(expectedRewardDeposit)
        tipString = string.format("有%s银两可领取", numString)
    end

    return bShow, tipString
end

return GoldSilverModel