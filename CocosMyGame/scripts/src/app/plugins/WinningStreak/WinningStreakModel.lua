local WinningStreakModel =class('WinningStreakModel',require('src.app.GameHall.models.BaseModel'))
local AssistModel = mymodel('assist.AssistModel'):getInstance()
local WinningStreakDef = require('src.app.plugins.WinningStreak.WinningStreakDef')
local WinningStreakReq = require('src.app.plugins.WinningStreak.WinningStreakReq')
local user = mymodel('UserModel'):getInstance()
local BroadcastModel = mymodel("hallext.BroadcastModel"):getInstance()

local treepack = cc.load('treepack')
local json = cc.load("json").json

local coms=cc.load('coms')
local PropertyBinder=coms.PropertyBinder
my.setmethods(WinningStreakModel,PropertyBinder)

my.addInstance(WinningStreakModel)

function WinningStreakModel:onCreate()
    self._winningStreakConfig = nil
    self._winningStreakInfo = nil

    self:initAssistResponse()
end

function WinningStreakModel:reset( )
    self._winningStreakConfig = nil
    self._winningStreakInfo = nil
end

function WinningStreakModel:initAssistResponse()
    self._assistResponseMap = {
        [WinningStreakDef.GR_GET_WINNING_STREAK_INFO] = handler(self, self.onWinningStreakInfo),
        [WinningStreakDef.GR_BUY_WINNING_STREAK_CHANCE] = handler(self, self.onWinningStreakOpenRet),
        [WinningStreakDef.GR_TAKE_WINNING_STREAK_AWARD] = handler(self, self.onWinningStreakAwardRet),
        [WinningStreakDef.GR_BUY_WINNING_STREAK_SUCCESS] = handler(self, self.onWinningStreakBuySuccessRet),
        [WinningStreakDef.GR_BUY_CHALLENGE_CHANCE_FAIL] = handler(self, self.onWinningStreakBuyFailRet),
        [WinningStreakDef.GR_AUTO_TAKE_WINNING_STREAK_AWARD] = handler(self, self.onWinningStreakAutoReward),
    }
    AssistModel:registCtrl(self, self.dealAssistResponse)
end

function WinningStreakModel:gc_GetWinningStreakInfo()
    if not cc.exports.isWinningStreakSupported()  then
        local activityCenterModel = import('src.app.plugins.activitycenter.ActivityCenterModel'):getInstance()
        --通知活动要隐藏
        activityCenterModel:setMatrixActivityNeedShow(WinningStreakDef.WINNING_STREAK_ID,false)
        return
    end

    self._info = {}
    if user.nUserID == nil or user.nUserID < 0 then
        print("userinfo is not ok")
        return
    end

    local platFormType = WinningStreakDef.WINNING_STREAK_APPTYPE_AN
    if MCAgent:getInstance().getLaunchSubMode and MCAgent:getInstance():getLaunchSubMode() == 1 then
        platFormType = WinningStreakDef.WINNING_STREAK_APPTYPE_SET
    elseif cc.exports.LaunchMode["PLATFORM"] == MCAgent:getInstance():getLaunchMode() then
        if device.platform == 'ios' then
            platFormType = WinningStreakDef.WINNING_STREAK_APPTYPE_IOS
        else
            platFormType = WinningStreakDef.WINNING_STREAK_APPTYPE_AN
        end
    end

    local data = {
        nUserID = user.nUserID,
        nPlatformType = platFormType,
        szUserName = user.szUsername
    }

    AssistModel:sendRequest(WinningStreakDef.GR_GET_WINNING_STREAK_INFO, WinningStreakReq.QUERY_WINNINGSTREAK_INFO, data, false)
end

function WinningStreakModel:onWinningStreakInfo(data)
    local winningStreakInfo,winningStreakConfig = AssistModel:convertDataToStruct(data,WinningStreakReq["WINNINGSTREAK_INFO_RSP"]);

    self._winningStreakConfig = json.decode(winningStreakConfig)
    self._winningStreakInfo = winningStreakInfo

    if self._winningStreakInfo and self._winningStreakInfo.nChallengeType > 0 then
        CacheModel:saveInfoToCache("WinningStreakType", self._winningStreakInfo.nChallengeType)
    end

    --活动没开始不显示
    local activityCenterModel = import('src.app.plugins.activitycenter.ActivityCenterModel'):getInstance()
    if not self:isAlive() then
        if my.isInGame() then   --游戏内也要分发消息
            self:dispatchEvent({name = WinningStreakDef.WinningStreakInfoRet})
        end
        self:updateRedDot()
        --通知活动要隐藏
        if activityCenterModel:isNeedRefresh(WinningStreakDef.WINNING_STREAK_ID,false) then
            activityCenterModel:setMatrixActivityNeedShow(WinningStreakDef.WINNING_STREAK_ID,false)
        end
        return
    end

    if not my.isInGame() then   --游戏内
        --通知活动要显示
        local pageInfo = activityCenterModel:getMatrixInfoByKey(1, WinningStreakDef.WINNING_STREAK_ID)
        if pageInfo and not pageInfo.showByActivityReturn then
            activityCenterModel:setMatrixActivityNeedShow(WinningStreakDef.WINNING_STREAK_ID,true)
        end
    end

    self._activityOpen = true
    self:onBroadCast()
    self:updateRedDot()
    self:dispatchEvent({name = WinningStreakDef.WinningStreakInfoRet})
end

function WinningStreakModel:gc_WinningStreakOpen(nChallengeType)
    if user.nUserID == nil or user.nUserID < 0 then
        print("userinfo is not ok")
    end

    local platFormType = WinningStreakDef.WINNING_STREAK_APPTYPE_AN
    if MCAgent:getInstance().getLaunchSubMode and MCAgent:getInstance():getLaunchSubMode() == 1 then
        platFormType = WinningStreakDef.WINNING_STREAK_APPTYPE_SET
    elseif cc.exports.LaunchMode["PLATFORM"] == MCAgent:getInstance():getLaunchMode() then
        if device.platform == 'ios' then
            platFormType = WinningStreakDef.WINNING_STREAK_APPTYPE_IOS
        else
            platFormType = WinningStreakDef.WINNING_STREAK_APPTYPE_AN
        end
    end

    local nBuyType = WinningStreakDef.WINNING_STREAK_HALL
    if my.isInGame() then  
        nBuyType = WinningStreakDef.WINNING_STREAK_GAME      --游戏内开启
    end

    local data = {
        nUserID = user.nUserID,
        nPlatformType = platFormType,
        nChallengeType = nChallengeType,
        nBuyType = nBuyType,
        kpiClientData = AssistModel:getKPIClientData(),
    }

    AssistModel:sendRequest(WinningStreakDef.GR_BUY_WINNING_STREAK_CHANCE, WinningStreakReq.BUY_CHALLENGE_CHANCE, data, false)
end

function WinningStreakModel:onWinningStreakOpenRet(data)
    local chooseType = CacheModel:getCacheByKey("WinningStreakType")
    if chooseType == WinningStreakDef.WINNING_STREAK_GOLD or chooseType == WinningStreakDef.WINNING_STREAK_DIAMOND then
        WinningStreakModel:_payFor(chooseType,"hall")
    end
--    my.informPluginByName({pluginName = 'TipPlugin',params = {tipString = "挑战已开启", removeTime = 3}})
--    self:gc_GetWinningStreakInfo()

--    --刷新银两
--    local playerModel = mymodel("hallext.PlayerModel"):getInstance()
--    playerModel:update({'SafeboxInfo','MemberInfo','UserGameInfo'})
end

function WinningStreakModel:onWinningStreakBuySuccessRet(data)
    my.informPluginByName({pluginName = 'TipPlugin',params = {tipString = "挑战已开启", removeTime = 3}})
    self:gc_GetWinningStreakInfo()

    CacheModel:saveInfoToCache("WinStreakOnClickOpen", 0)

    --刷新银两
    local playerModel = mymodel("hallext.PlayerModel"):getInstance()
    playerModel:update({'SafeboxInfo','MemberInfo','UserGameInfo'})
end

function WinningStreakModel:onWinningStreakBuyFailRet()
    my.informPluginByName({pluginName = 'TipPlugin',params = {tipString = "挑战开启失败，请重试", removeTime = 3}})
    self:gc_GetWinningStreakInfo()

    CacheModel:saveInfoToCache("WinStreakOnClickOpen", 0)
end

-- Add Shuy. 2020.5.8 收到邮件自动发奖的通知
function WinningStreakModel:onWinningStreakAutoReward()
    -- 延时3秒后请求邮件列表
    my.scheduleOnce(function()
        mymodel("hallext.EmailModel"):getInstance():getEmailList()
    end, 3)
end

function WinningStreakModel:gc_WinningStreakAward()
    if user.nUserID == nil or user.nUserID < 0 then
        print("userinfo is not ok")
    end

    local data = {
        nUserID = user.nUserID,
        szUserName = user.szUsername
    }

    AssistModel:sendRequest(WinningStreakDef.GR_TAKE_WINNING_STREAK_AWARD, WinningStreakReq.TAKE_CHALLELLENGE_AWARD, data, false)
end

function WinningStreakModel:onWinningStreakAwardRet(data)
    local awardRet = AssistModel:convertDataToStruct(data,WinningStreakReq["TAKE_CHALLELLENGE_AWARD_RSP"]);

    if awardRet.nUserID ~= user.nUserID then
        return
    end

     --刷新银两
    local playerModel = mymodel("hallext.PlayerModel"):getInstance()
    playerModel:update({'SafeboxInfo','MemberInfo','UserGameInfo'})

    dump(awardRet)

    self:updateRedDot()
    if awardRet.nSliverTotalAward >0 then
        local rewardList = {}
        local data = nil
        local awardData = nil
        if awardRet.nChallengeType == WinningStreakDef.WINNING_STREAK_DIAMOND then
            data = self._winningStreakConfig["diamond"]
        elseif awardRet.nChallengeType == WinningStreakDef.WINNING_STREAK_GOLD then
            data = self._winningStreakConfig["gold"]
        elseif awardRet.nChallengeType == WinningStreakDef.WINNING_STREAK_SILVER then
            data = self._winningStreakConfig["silver"]
        else
            data = self._winningStreakConfig["bronze"]
        end

        awardData = data[WinningStreakDef.WINNING_STREAK_APPTYPE_AN]   --默认安卓
        if MCAgent:getInstance().getLaunchSubMode and MCAgent:getInstance():getLaunchSubMode() == 1 then      --合集
            awardData = data[WinningStreakDef.WINNING_STREAK_APPTYPE_SET]
        elseif cc.exports.LaunchMode["PLATFORM"] == MCAgent:getInstance():getLaunchMode() then
            if device.platform == 'ios' then
                awardData = data[WinningStreakDef.WINNING_STREAK_APPTYPE_IOS]
            else
                awardData = data[WinningStreakDef.WINNING_STREAK_APPTYPE_AN]
            end
        end

        local winningStreakAwardList = awardData["WinningStreakAwardList"]
        local totalReward = 0
        for i, j in pairs(winningStreakAwardList) do
            if awardRet and awardRet.nBout and awardRet.nBout >= j.bout then
                totalReward = j.TotalAward
            end
        end

        local nMultiple = string.format("%0.1f",awardRet.nSliverTotalAward/totalReward)
        table.insert( rewardList,{nType = 1,nCount = awardRet.nSliverTotalAward,nMultiple = nMultiple})
        my.informPluginByName({pluginName = 'WinningStreakRewardCtrl', params = {data = rewardList,callback = function()
            self:dispatchEvent({name = WinningStreakDef.WinningStreakAwardRet,value = {awardRet = awardRet}})
        end}})

        self:gc_GetWinningStreakInfo()
    end
end

function WinningStreakModel:synWinningStreakConfig(data)
    self:gc_GetWinningStreakInfo()
end

function WinningStreakModel:GetWinningStreakInfo()
    if self._winningStreakInfo then
        return self._winningStreakInfo
    end
    return nil
end

function WinningStreakModel:GetWinningStreakConfig()
    if self._winningStreakConfig then
        return self._winningStreakConfig
    end
    return nil
end

function WinningStreakModel:updateRedDot()
    self:dispatchEvent({name = WinningStreakDef.WinningStreakUpdateRedDot})

    if self:NeedShowRedDot() then
        local activityCenterModel = import('src.app.plugins.activitycenter.ActivityCenterModel'):getInstance()
        activityCenterModel._myStatusDataExtended["isNeedReddot"] = true
        activityCenterModel:dispatchModuleStatusChanged("activity", "activity_newContentAvail")
    end
end

function WinningStreakModel:NeedShowRedDot()
    if not self:isAlive() then
        return false
    end

    local sStatusWinningStreak = string.format("WinningStreak%s", os.date("%Y%m%d"))
    if CacheModel:getCacheByKey(sStatusWinningStreak) == {} then
        return true
    end

    if not self._winningStreakInfo then return false end

    if self._winningStreakInfo.nState == WinningStreakDef.WINNING_STREAK_UNSTARTED then
        return false
    elseif self._winningStreakInfo.nState == WinningStreakDef.WINNING_STREAK_STARTING then
        return false
    elseif self._winningStreakInfo.nState == WinningStreakDef.WINNING_STREAK_UNTAKE then
        return true
    end

    if CacheModel:getCacheByKey(sStatusWinningStreak) == 1 then
        return false
    end

    return true
end

function WinningStreakModel:onBroadCast()
    local myWinningStreakData = my.readCache("MyWinningStreakData".. user.nUserID ..".xml")

    if not myWinningStreakData.WinningStreak then
        myWinningStreakData.WinningStreak = true
        my.saveCache("MyWinningStreakData"..user.nUserID..".xml", myWinningStreakData)
        local data={
            MessageInfo = {
                enMsgType = 0,
                szMsg = WinningStreakDef.Broadcast,
                nReserved = {0,0,0,0}
            },
            nDelaySec = -1,
            nInterval = 0,
            nRepeatTimes = 2,
            nRoadID = 0,
            nReserved = {0,0,0,0}
        }

        BroadcastModel:insertBroadcastMsg(data)
    end
end

--开启挑战付费
--参数  平台  种类（大厅游戏 翻倍） 档位
function WinningStreakModel:GetItem(appType,nPayLevel,nPayType)
    print("--------apptype ---nPayLevel--- nPayType",appType, nPayLevel, nPayType)
    if nPayLevel < WinningStreakDef.WINNING_STREAK_BRONZE and nPayLevel > WinningStreakDef.WINNING_STREAK_DIAMOND then return end
    local priceConfig
    if appType == WinningStreakDef.WINNING_STREAK_APPTYPE_AN then
        priceConfig = WinningStreakDef.PriceConfig_AN[nPayLevel]
    elseif appType == WinningStreakDef.WINNING_STREAK_APPTYPE_IOS then
        priceConfig = WinningStreakDef.PriceConfig_IOS[nPayLevel]
    elseif appType == WinningStreakDef.WINNING_STREAK_APPTYPE_SET then
        priceConfig = WinningStreakDef.PriceConfig_SET[nPayLevel]
    end

    return priceConfig[nPayType].price,priceConfig[nPayType].exchangeid
end

function WinningStreakModel:AppType()
    local platFormType = WinningStreakDef.WINNING_STREAK_APPTYPE_AN
    if MCAgent:getInstance().getLaunchSubMode and MCAgent:getInstance():getLaunchSubMode() == 1 then
        platFormType = WinningStreakDef.WINNING_STREAK_APPTYPE_SET
    elseif cc.exports.LaunchMode["PLATFORM"] == MCAgent:getInstance():getLaunchMode() then
        if device.platform == 'ios' then
            platFormType = WinningStreakDef.WINNING_STREAK_APPTYPE_IOS
        else
            platFormType = WinningStreakDef.WINNING_STREAK_APPTYPE_AN
        end
    end

    return platFormType
end

function WinningStreakModel:_payFor(nPayLevel,nPayType)
    if self._waitingPayResult then return end
 
    local exchangeid = 11362
    
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
            print("WinningStreakModel single app")
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
    
        print("WinningStreakModel pay_ext_args:", strPayExtArgs)
        return strPayExtArgs
            
    end
    
    local paymodel = mymodel("PayModel"):getInstance()
    local param = clone(paymodel:getPayMetaTable())
    
    if nPayLevel == WinningStreakDef.WINNING_STREAK_BRONZE then
        param["Product_Name"]   = "青铜"
    elseif nPayLevel == WinningStreakDef.WINNING_STREAK_SILVER then
        param["Product_Name"]   = "白银"
    elseif nPayLevel == WinningStreakDef.WINNING_STREAK_GOLD then
        param["Product_Name"]   = "黄金"
    elseif nPayLevel == WinningStreakDef.WINNING_STREAK_DIAMOND then
        param["Product_Name"]   = "钻石"
    end
    
    param["Product_Id"] = ""  --sid
        
    local apptype = self:AppType()
    print("----------------------------------apptype = ",apptype)
    local price
    price,exchangeid = self:GetItem(apptype,nPayLevel,nPayType)
    print("------ price and exchangeid:",price,exchangeid)
    if apptype == WinningStreakDef.WINNING_STREAK_APPTYPE_AN then
        print("WINNING_STREAK_APPTYPE_AN")
    elseif apptype == WinningStreakDef.WINNING_STREAK_APPTYPE_SET then
        print("WINNING_STREAK_APPTYPE_SET")
        param["Product_Id"] = "com.uc108.mobile.gamecenter.tongbao" .. price
    elseif apptype == WinningStreakDef.WINNING_STREAK_APPTYPE_IOS then
        print("WINNING_STREAK_APPTYPE_IOS")
        param["Product_Id"] = "com.uc108.mobile.gamecenter.tongbao" .. price
    end
    
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
        if nPayLevel == WinningStreakDef.WINNING_STREAK_BRONZE then
            param["Product_Name"]   = "开启青铜挑战"
        elseif nPayLevel == WinningStreakDef.WINNING_STREAK_SILVER then
            param["Product_Name"]   = "开启白银挑战"
        elseif nPayLevel == WinningStreakDef.WINNING_STREAK_GOLD then
            param["Product_Name"]   = "开启黄金挑战"
        elseif nPayLevel == WinningStreakDef.WINNING_STREAK_DIAMOND then
            param["Product_Name"]   = "开启钻石挑战"
        end 
        print("To Create ActivityRechargeHSoxCtrl")
        dump(param, "WinningStreakModel:payForProduct param")       
        my.informPluginByName({pluginName='ActivityRechargeHSoxCtrl',params = param})
        CacheModel:saveInfoToCache("WinStreakOnClickOpen", 0)
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
                CacheModel:saveInfoToCache("WinStreakOnClickOpen", 0)
                
                if string.len(msg) ~= 0 then
                    --刷新消息，让充值按钮可以点击
                    self:gc_GetWinningStreakInfo()
                    --self:dispatchEvent({name = WinningStreakDef.WinningStreakChargeCancel})
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

function WinningStreakModel:isAlive()
    if not cc.exports.isWinningStreakSupported()  then
        return  false
    end

    if  not self._winningStreakInfo then
        return false
    end

    if self._winningStreakInfo and self._winningStreakInfo.bShow and self._winningStreakInfo.bShow == 0  then
        return false
    end

    if user.nBout < cc.exports.getWinningStreakNeedBout() then
        return false
    end

    return true
end

return WinningStreakModel