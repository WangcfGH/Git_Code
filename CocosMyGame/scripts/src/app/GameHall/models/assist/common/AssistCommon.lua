local AssistCommon = class('AssistCommon', require('src.app.GameHall.models.BaseModel'))
my.addInstance(AssistCommon)

local AssistCommonReq = import('src.app.GameHall.models.assist.common.AssistCommonReq')
local AssistModel = mymodel('assist.AssistModel'):getInstance()
local user=mymodel('UserModel'):getInstance()
local PublicInterface = cc.exports.PUBLIC_INTERFACE
local treepack = cc.load('treepack')

local ChannelConfig = cc.load("json").json.decode(cc.FileUtils:getInstance():getStringFromFile("ChannelConfig.json"))

local AssistCommonDef = {
    ASSIT_NOTICY_ASSITSVR_USERID = 401500,

    GR_JSON_REQUEST = 409012, --Json请求
    JR_GET_APPMODULECONFIG  = 10000,  --请求模块配置
    JR_GET_APPJSONCONFIG = 10001, --请求客户端json配置
    JR_GET_MODULECONFIG_DEFINEDBYSERVER = 10002,  --请求模块配置

    -- chunklog记录充值埋点
    GR_RECHARGE_LOG_REQ          = 407001,

    --记录理牌埋点
    GR_SORTCARD_LOG_REQ         = 407003,
    GR_TAKERELIEF_LOG_REQ       = 407004, -- 领取低保日志
    GR_GAMELOADING_LOG_REQ      = 407006, -- 游戏加载日志

    GR_SEND_OTHER_JSON_CONFIG_REQ = 409001, -- 查询assist服务上的限时礼包json配置
    GR_SEND_OTHER_JSON_CONFIG_RESP = 409002, -- 回复assist服务上的限时礼包json配置

    GR_DOLE_EXCHANGE_VOUCHER = 404105,   --申请获取兑换券
    GR_SEND_GET_QUICK_BUY_CONFIG_REQ = 400100, --快速购买配置
    GR_EXCHANGE_SHOP_CONFIG = 400103,   --兑换商城配置（新版）
    GR_GAME_JSON_CONFIG = 400104,   --读取json文件的配置

    --配置修改通知
    GR_NOTIFY_CONFIG_MODIFIED = 410030,

    --不洗牌相关
    GR_SEND_NO_SHUFFLE_REQ              = 408001, -- 查询不洗牌是否开启
    GR_SEND_NO_SHUFFLE_RESP             = 408002, -- 回复不洗牌是否开启和时间
    
    GR_NOTICY_ASSITSVR_USERID_EX                = 410400,
}


function AssistCommon:onCreate()
    self._assistResponseMap = {
        [AssistCommonDef.GR_JSON_REQUEST] = handler(self, self.dealResponseOfJsonRequest),

        [AssistCommonDef.GR_SEND_OTHER_JSON_CONFIG_RESP] = handler(self, self.dealOtherJsonConfigResp),
        [AssistCommonDef.GR_SEND_GET_QUICK_BUY_CONFIG_REQ] = handler(self, self.DealQuickConfigResp),
        [AssistCommonDef.GR_EXCHANGE_SHOP_CONFIG] = handler(self, self.dealExchangeShopConfigResp),
        [AssistCommonDef.GR_GAME_JSON_CONFIG] = handler(self, self.DealGameJsonConfigResp),

        [AssistCommonDef.GR_NOTIFY_CONFIG_MODIFIED] = handler(self, self.onNotifyConfigModified),
        [AssistCommonDef.GR_SEND_NO_SHUFFLE_RESP] = handler(self, self.onReturnNoShuffleInfo)
    }
    AssistModel:registCtrl(self, self.dealAssistResponse)
end

function AssistCommon:onAssistConnectOK()
    self:sendNoticyAssitSvrUserId() --发自己的ID过去
    self:sendNoticyAssitSvrUserIdEX()
    --获取配置信息
    self:SendQuickBuyDataReq()
    --self:JR_RequestModuleConfig() --开关配置统一使用AdditionConfig控制
    --self:JR_RequestModuleConfigDefinedByServer({"DoubleExchange"})
    --self:JR_RequestAppJsonConfig()
    self:SendExchangeShopConfigDataReq()
    self:sendGameJsonConfig()
    --self:getLimitTimeGiftConfig()
end

function AssistCommon:sendNoticyAssitSvrUserId()
    local playerInfo = PublicInterface:GetPlayerInfo()
    if playerInfo == nil then
        return 
    end 

    if playerInfo.nUserID == nil then
        return
    end

    if playerInfo.nUserID <=0 then 
        return 
    end

    local NOTICY_ASSITSVR_USERID = AssistCommonReq["NOTICY_ASSITSVR_USERID"]
    local data     = {
        nUserID = playerInfo.nUserID
    }
    local pData = treepack.alignpack(data, NOTICY_ASSITSVR_USERID)
    AssistModel:sendData(AssistCommonDef.ASSIT_NOTICY_ASSITSVR_USERID, pData)
end

function AssistCommon:sendNoticyAssitSvrUserIdEX()
    local playerInfo = PublicInterface:GetPlayerInfo()
    if playerInfo == nil then
        return 
    end 

    if playerInfo.nUserID == nil then
        return
    end

    if playerInfo.nUserID <=0 then 
        return 
    end

    local bPFGPlayer = require("src.app.plugins.PhoneFeeGift.PhoneFeeGiftModel"):getInstance():getActivityCheckResult()
    local GR_NITICY_ASSITSVR_USERID_EX = AssistCommonReq["NOTICY_USERIDEX"]
    local data     = {
        nUserID = playerInfo.nUserID,
        nChannelID = BusinessUtils:getInstance().getTcyChannel and tonumber(BusinessUtils:getInstance():getTcyChannel()) or 0,
        bNewPlayerCond1 = bPFGPlayer
    }
    local pData = treepack.alignpack(data, GR_NITICY_ASSITSVR_USERID_EX)
    if self._client then
        self._client:sendData(AssistCommonDef.GR_NOTICY_ASSITSVR_USERID_EX, pData)
    end
end

--请求功能开关配置
--[[function AssistCommon:JR_RequestModuleConfig()
    local requestParams = {
        ["sdkName"] = my.getSelfSdkName(),
        ["configNames"] = {
            "DWCSDKName"
        },
    }

    print("JR_RequestModuleConfig")
    dump(requestParams)
    self:sendJsonRequest(AssistCommonDef.JR_GET_APPMODULECONFIG, requestParams)
end]]--

--[[function AssistCommon:JR_RequestAppJsonConfig()
    local requestParams = {
        ["configName"] = "ClientJsonConfigNo1",
        --["configVersion"] = "20191009092945" 
    }

    print("JR_RequestAppJsonConfig")
    dump(requestParams)
    self:sendJsonRequest(AssistCommonDef.JR_GET_APPJSONCONFIG, requestParams)
end]]--

--请求服务端定义的活动配置
function AssistCommon:JR_RequestModuleConfigDefinedByServer(moduleNames)
    if moduleNames == nil then return end

    local requestParams = {
        ["sdkName"] = my.getSelfSdkName(),
        ["tcyChannel"] = tostring(my.getTcyChannelId()),
        ["moduleNames"] = moduleNames
    }

    print("JR_RequestModuleConfigDefinedByServer")
    dump(requestParams)
    self:sendJsonRequest(AssistCommonDef.JR_GET_MODULECONFIG_DEFINEDBYSERVER, requestParams)
end

function AssistCommon:sendJsonRequest(jsonRequestId, requestParams)
    if jsonRequestId == nil then return end

    local JSON_REQUEST_INFO = AssistCommonReq["JSON_REQUEST_INFO"]
    local strJsonData = ""
    if requestParams ~= nil and type(requestParams) == "table" then
        strJsonData = cc.load("json").json.encode(requestParams)
    end
    local userId = -1
    local playerInfo = PublicInterface.GetPlayerInfo()
    if playerInfo and playerInfo.nUserID then
        userId = playerInfo.nUserID
    end
    local vMajor, vMinor, vBuildNo = self:_parseVersion(my.getGameVersion())
    local data     = {
        ["nUserId"] = userId,
        ["nGameId"] = my.getGameID(),
        ["szExeName"] = my.getGameShortName(),
        ["channelId"] = ChannelConfig["recommander_id"],
        ["vMajor"] = vMajor,
        ["vMinor"] = vMinor,
        ["vBuildNo"] = vBuildNo,
        ["nRequestId"] = jsonRequestId,
        ["nJsonLen"] = string.len(strJsonData),
        ["nReserved"] = {-1, -1, -1, -1}
    }
    print("recommander_id", ChannelConfig["recommander_id"])
    local pData = treepack.alignpack(data, JSON_REQUEST_INFO)
    if data["nJsonLen"] > 0 then
        pData = pData..strJsonData
    end
    AssistModel:sendData(AssistCommonDef.GR_JSON_REQUEST, pData)
end

function AssistCommon:_parseVersion(version)
    local verTab = {}
    verTab = cc.exports.string_split(version,'.')

    local ma = 1
    local mi = 0
    local bu = 0
    if #verTab >= 3 then
        ma = verTab[1]
        mi = verTab[2]
        bu = verTab[3]
    end

    return ma,mi,bu
end

function AssistCommon:dealResponseOfJsonRequest(responseData)
    if responseData == nil then return end

    print("AssistCommon:dealResponseOfJsonRequest")
    local jsonResponseInfo = treepack.unpack(responseData, AssistCommonReq["JSON_RESPONSE_INFO"])
    if jsonResponseInfo == nil then
        print("jsonResponseInfo null!!!")
        return
    end
    dump(jsonResponseInfo)

    local leftData = responseData
    leftData = string.sub(leftData, AssistCommonReq["JSON_RESPONSE_INFO"].maxsize + 1)
    local jsonData = self:_parseJsonData(leftData, jsonResponseInfo["nJsonLen"])
    dump(jsonData)

    leftData = string.sub(leftData, jsonResponseInfo["nJsonLen"] + 1)
    local additionData = self:_parseJsonData(leftData, jsonResponseInfo["nAdditionDataLen"])
    dump(additionData)

    --处理各个json请求id
    print("json request received, id=" .. tostring(jsonResponseInfo["nResponseId"]))
    if jsonResponseInfo["nResponseId"] == AssistCommonDef.JR_GET_APPMODULECONFIG then
        --self:_onJR_AppModuleConfig(jsonData, additionData)
    elseif jsonResponseInfo["nResponseId"] == AssistCommonDef.JR_GET_APPJSONCONFIG then
        --self:_onJR_AppJsonConfig(jsonData, additionData)
    elseif jsonResponseInfo["nResponseId"] == AssistCommonDef.JR_GET_MODULECONFIG_DEFINEDBYSERVER then
        self:_onJR_ModuleConfigDefinedByServer(jsonData, additionData)
    else
        print("unknown json request received, id=" .. tostring(jsonResponseInfo["nResponseId"]))
    end
end

function AssistCommon:_parseJsonData(rawData, jsonDataLen)
    if rawData == nil then return nil end
    if jsonDataLen == nil or jsonDataLen <= 0 then return nil end

    local jsonBodyTemplate = clone(AssistCommonReq["JSON_BODY_TEMPLATE"])      
    jsonBodyTemplate.lengthMap[1] = jsonDataLen
    jsonBodyTemplate.formatKey = string.format(jsonBodyTemplate.formatKey, jsonDataLen)
    jsonBodyTemplate.deformatKey = string.format(jsonBodyTemplate.deformatKey, jsonDataLen)
    jsonBodyTemplate.maxsize = jsonDataLen
    local jsonBody = treepack.unpack(rawData, jsonBodyTemplate)
    local jsonData = cc.load("json").json.decode(jsonBody.szJson)
    return jsonData
end

--[[function AssistCommon:_onJR_AppModuleConfig(jsonData, additionData)
    print("AssistCommon:_onJR_AppModuleConfig")
    if jsonData == nil then return end

    local switches = jsonData["switches"]
    for name, val in pairs(switches) do
        cc.exports.moduleSwitches[name] = self:_getSwitchVal(switches, name)
    end
    --测试代码
    --cc.exports.moduleSwitches["CustomerService"] = false
end

function AssistCommon:_getSwitchVal(switches, switchName)
    if switches[switchName] == nil then
        return false
    end

    if switches[switchName] == 0 then
        return false
    else
        return true
    end

    return false
end]]--

--[[function AssistCommon:_onJR_AppJsonConfig(jsonData, additionData)
    print("AssistCommon:_onJR_AppJsonConfig")
    if additionData == nil then
        return
    end
    
    local RoomListModel = import("src.app.GameHall.room.model.RoomListModel"):getInstance()
    RoomListModel:updateAndSaveRoomConfigCustom(additionData)
end]]--

function AssistCommon:_onJR_ModuleConfigDefinedByServer(jsonData, additionData)
    print("AssistCommon:_onJR_AppModuleConfig")
    if jsonData == nil then return end

    local configData = jsonData["config"]
    dump(configData)

    if configData["DoubleExchange"] then
        configData["DoubleExchange"]["lastUpdateTime"] = os.time()
        CommonData:setAppData("DoubleExchangeConfig", configData["DoubleExchange"])
    end
end

-- 充值埋点begin
function AssistCommon:onReChargeLogReq(reqdata)
    local RECHARGE_LOG_REQ_DATA = AssistCommonReq["RECHARGE_LOG_REQ"]
    local pData = treepack.alignpack(reqdata, RECHARGE_LOG_REQ_DATA)

    dump(reqdata) -- add by wuym
    AssistModel:sendData(AssistCommonDef.GR_RECHARGE_LOG_REQ, pData)
end

--理牌埋点begin
function AssistCommon:onSortCardLogReq(reqdata)
    local logreq = AssistCommonReq["SORTCARD_LOG_REQ"]
    local pData = treepack.alignpack(reqdata, logreq)
    dump(reqdata)
    AssistModel:sendData(AssistCommonDef.GR_SORTCARD_LOG_REQ, pData)
end

--低保埋点
function AssistCommon:onTakeReliefLogReq(reqdata)
    local logreq = AssistCommonReq["RELIEF_LOG"]
    local pData = treepack.alignpack(reqdata, logreq)
    dump(reqdata)
    AssistModel:sendData(AssistCommonDef.GR_TAKERELIEF_LOG_REQ, pData)
end

--游戏加载埋点
function AssistCommon:onGameLoadingLogReq(reqdata)
    local logreq = AssistCommonReq["GAME_LOADING_LOG"]
    local pData = treepack.alignpack(reqdata, logreq)
    dump(reqdata)
    AssistModel:sendData(AssistCommonDef.GR_GAMELOADING_LOG_REQ, pData)
end

function AssistCommon:getLimitTimeGiftConfig()
    local payConfig = nil
    if cc.exports.IsHejiPackage() then
        payConfig = "LimitTimeGiftconfig_HJ.json"
    else    
        local targetPlatform = cc.Application:getInstance():getTargetPlatform()
        if device.platform == "ios" then
            if cc.exports.LaunchMode["ALONE"] == MCAgent:getInstance():getLaunchMode() then
                payConfig = "LimitTimeGiftconfig_ios.json"
            else
                payConfig = "LimitTimeGiftconfig_ios_tcyapp.json"
            end
        else
            payConfig = "LimitTimeGiftconfig.json"
        end
    end
    self:sendGetOtherJsonConfig(payConfig)
end

function AssistCommon:sendGetOtherJsonConfig(payConfigName) --获取文件名对应的配置
    local GR_JSON_CONFIG_REQ = AssistCommonReq["GET_JSON_CONFIG_REQ"]
    local data      = {
        cFileName     = payConfigName,
    }

    local pData = treepack.alignpack(data, GR_JSON_CONFIG_REQ)
    AssistModel:sendData(AssistCommonDef.GR_SEND_OTHER_JSON_CONFIG_REQ, pData)
end

function AssistCommon:dealOtherJsonConfigResp(data)
    local gameJsonConfig = cc.load("json").json.decode(data)
    local configJson = clone(gameJsonConfig)
    if configJson == nil then return end

    if configJson["fileName"] == "LimitTimeGiftConfig" then
		cc.exports._gameJsonConfig.LimitTimeGiftConfig = configJson
		--self:saveCacheOtherConfig(configJson)
	end

	-- 获取的 国庆活动配置
	if configJson["fileName"] == "NationalDaysActivity" then
		cc.exports._gameJsonConfig.NationalDaysActivity = configJson
		local isVisible = false
		if configJson then
			isVisible = true
		end

        local NationalDayActivityModel = import("src.app.plugins.NationalDayActivity.NationalDayActivityModel"):getInstance()
        NationalDayActivityModel._myStatusDataExtended["isPluginAvail"] = isVisible
        NationalDayActivityModel:dispatchModuleStatusChanged("topRank", NationalDayActivityModel.EVENT_MAP["topRank_pluginAvailChanged"])
	end
end

--nType  1 为新手  2为签到
function AssistCommon:sendQueryExchangeVoucherReq(nType, DayCount)
	local playerInfo = PublicInterface.GetPlayerInfo()

    local bIsmember = 0

	local DOLE_EXCHANGE_VOUCHER = AssistCommonReq["DOLE_EXCHANGE_VOUCHER"]
	local data = {
		nUserID = playerInfo.nUserID,
        nType = nType,
        nDayCount = DayCount,
        nMember = bIsmember,
        kpiClientData = AssistModel:getKPIClientData()
	}
	local pData = treepack.alignpack(data, DOLE_EXCHANGE_VOUCHER)
	AssistModel:sendData(AssistCommonDef.GR_DOLE_EXCHANGE_VOUCHER, pData)
end

function AssistCommon:SendQuickBuyDataReq()
    local GR_TASK_DATA_REQ = AssistCommonReq["TASK_PARAM_REQ"]
    local data      = {
        nUserID     = 0,
    }
    --随便发个数据过去
    local pData = treepack.alignpack(data, GR_TASK_DATA_REQ)
    AssistModel:sendData(AssistCommonDef.GR_SEND_GET_QUICK_BUY_CONFIG_REQ, pData)
end

function AssistCommon:DealQuickConfigResp(data)
    local quickConfig = AssistCommonReq["QUICK_BUY_CONFIG"]
    local msgQuickConfig = treepack.unpack(data, quickConfig)

	cc.exports._QuickBuyConfig = {nDeposit = {}, nMoney = {}}
    local depositIndex = 1
    local moneyIndex = 1
    for i = 1, 10 do
        if msgQuickConfig.nDeposit[i] > 0 then
            cc.exports._QuickBuyConfig.nDeposit[depositIndex] = msgQuickConfig.nDeposit[i]
            depositIndex = depositIndex+1
        end
        if msgQuickConfig.nMoney[i] > 0 then
            cc.exports._QuickBuyConfig.nMoney[moneyIndex] = msgQuickConfig.nMoney[i]
            -- 因为ios没有2元礼包，所以，如果是ios，最低6元
            if device.platform == "ios" and tonumber(cc.exports._QuickBuyConfig.nMoney[moneyIndex]) < 6 then
                cc.exports._QuickBuyConfig.nMoney[moneyIndex] = 6
            end
            
            moneyIndex = moneyIndex+1
        end
    end
    
end

function AssistCommon:SendExchangeShopConfigDataReq()
    local SHZChannelConfig = AssistCommonReq["SHZChannelConfig"]
    local userPlugin = plugin.AgentManager:getInstance():getUserPlugin()
    if device.platform == "windows" then
        local sdkName = userPlugin:getUsingSDKName()
        sdkName = "tcy"
        local data = {
		    sChannelSdkName = sdkName
	    }
	    local pData = treepack.alignpack(data, SHZChannelConfig)
	    AssistModel:sendData(AssistCommonDef.GR_EXCHANGE_SHOP_CONFIG, pData)
        return
    end
    if(userPlugin:isFunctionSupported('getUsingSDKName'))then
        local sdkName = userPlugin:getUsingSDKName()
        sdkName = string.lower(sdkName)
        if sdkName == "tcy" then
            if(cc.exports.LaunchMode["PLATFORM"] == MCAgent:getInstance():getLaunchMode())then
                sdkName = "tcyapp"
            end
        end
        local data = {
		    sChannelSdkName = sdkName
	    }
	    local pData = treepack.alignpack(data, SHZChannelConfig)
	    AssistModel:sendData(AssistCommonDef.GR_EXCHANGE_SHOP_CONFIG, pData)
    end
end

function AssistCommon:dealExchangeShopConfigResp(data)
    local quickConfig = AssistCommonReq["ExchangeShopConfigResp"]
    local msgQuickConfig = treepack.unpack(data, quickConfig)

    cc.exports._newPlayerExchangeVoucherNum = msgQuickConfig.newPlayerExchange
    cc.exports._checkinExchangeVoucherNum = msgQuickConfig.checkinExchange
    cc.exports._checkinExchangeMemberVoucherNum = msgQuickConfig.checkinMemberExchange
end

function AssistCommon:sendGameJsonConfig()
	local GR_TASK_DATA_REQ = AssistCommonReq["TASK_PARAM_REQ"]
    local data      = {
        nUserID     = 0,
    }
    --随便发个数据过去
    local pData = treepack.alignpack(data, GR_TASK_DATA_REQ)
    AssistModel:sendData(AssistCommonDef.GR_GAME_JSON_CONFIG, pData)
end

function AssistCommon:DealGameJsonConfigResp(data)
    print("AssistCommon:DealGameJsonConfigResp")
    local json = cc.load("json").json
	local gameJsonConfig = json.decode(data)
    if cc.exports._gameJsonConfig and cc.exports._gameJsonConfig.LimitTimeGiftConfig then
        gameJsonConfig.LimitTimeGiftConfig = cc.exports._gameJsonConfig.LimitTimeGiftConfig
    end
    if cc.exports._gameJsonConfig and cc.exports._gameJsonConfig.NationalDaysActivity then
        gameJsonConfig.NationalDaysActivity = cc.exports._gameJsonConfig.NationalDaysActivity
    end
    dump(gameJsonConfig, "gameJsonConfig")
    cc.exports._gameJsonConfig = clone(gameJsonConfig)
    if cc.exports._gameJsonConfig == nil then
        cc.exports._gameJsonConfig = {}
    else
        --self:saveCacheNoShuffleRooms()
        local ActivityJoinUpConfig = cc.exports._gameJsonConfig.ActivityJoinUp
        if ActivityJoinUpConfig then
            -- 根据GameConfig里的ActivityJoinUp是否使能，按需加载长假活动等配置
            for i=1, table.maxn(ActivityJoinUpConfig) do 
                if true == ActivityJoinUpConfig[i].Enable then
                    local fileName = ActivityJoinUpConfig[i].FileName
                    self:sendGetOtherJsonConfig(fileName)
                end
            end
        end

        mymodel("ShopModel"):getInstance():onUpdateExpressionTips()

    end

    self:DealTCYGameConfig()

    local RoomListModel = import("src.app.GameHall.room.model.RoomListModel"):getInstance()
    RoomListModel:updateAndSaveRoomConfigCustom(cc.exports._gameJsonConfig)

    local ExchangeCenterModel = require("src.app.plugins.ExchangeCenter.ExchangeCenterModel"):getInstance()
    ExchangeCenterModel:onGameJsonConfigUpdated()
end

function AssistCommon:DealTCYGameConfig()
    local gameJsonConfig = cc.exports._gameJsonConfig
    if gameJsonConfig then
        cc.exports._TCYGameGuide = false
        cc.exports._TCYGameShowEntry = false --同城游下载入口
        local TCYGameConfig = gameJsonConfig.TCYGameConfig
        if TCYGameConfig and TCYGameConfig.Channgel and TCYGameConfig.version then
            local sdkName = "tcy"
            local userPlugin = plugin.AgentManager:getInstance():getUserPlugin()
            if(userPlugin:isFunctionSupported('getUsingSDKName'))then
                sdkName = userPlugin:getUsingSDKName()
                sdkName = string.lower(sdkName)
                if sdkName == "tcy" then
                    if(cc.exports.LaunchMode["PLATFORM"] == MCAgent:getInstance():getLaunchMode())then
                        sdkName = "tcyapp"
                    end
                end
            end

            local version = my.getGameVersion()
            if TCYGameConfig.Channgel[sdkName] == 1 and TCYGameConfig.version[version] == 1 then
                cc.exports._TCYGameGuide = true
                if device.platform ~= "ios" and not DeviceUtils:getInstance():isAppInstalled("com.uc108.mobile.gamecenter") then
                    cc.exports._TCYGameShowEntry = true
                end
            end
        end
        --cc.load('MainCtrl'):getInstance():onGuidDownloadSuccess()
    end
end

--接收到配置修改的通知
function AssistCommon:onNotifyConfigModified(data)
    local notifyItemStruct = AssistCommonReq["NOTIFY_CONFIG_MODIFIED_ITEM"]
    local notifyItem = treepack.unpack(data, notifyItemStruct)

    if notifyItem.fileName == "GameConfig" then
        --去拿gameConfig的配置
        self:sendGameJsonConfig()
    elseif notifyItem.fileName == "ArenaRankMatchConfig" then
        local ArenaModel = import("src.app.plugins.arena.ArenaModel"):getInstance()
        ArenaModel:sendGetArenaRankMatchConfig()
    elseif notifyItem.fileName == "ArenaRankAwardConfig" then
        local ArenaModel = import("src.app.plugins.arena.ArenaModel"):getInstance()
        ArenaModel:sendGetArenaRankRewardList()
    elseif notifyItem.fileName == "NationalDaysActivity" then
        self:sendGetOtherJsonConfig("NationalDaysActivity")
    end
end


--不洗牌 
function AssistCommon:onGetNoShuffleInfo()
    AssistModel:sendData(AssistCommonDef.GR_SEND_NO_SHUFFLE_REQ)
end

--不洗牌 
function AssistCommon:onReturnNoShuffleInfo(data)
    local noShuffle = AssistCommonReq["NO_SHUFFLE_REQ"]
    local triggerResp = treepack.unpack(data, noShuffle)
    dump(triggerResp)
    local openTag = triggerResp.nOpenTag

    --[[aaaa if openTag == 0 then  --房间未开启
        self.SHUFFLE_TIME = triggerResp.nStartTime..":00-"..triggerResp.nEndTime..":00"
        self:dispatchEvent({name = self.SHOW_SHUFFLE_TIME})
    else
        self:dispatchEvent({name = self.HIDE_SHUFFLE_TIME})
    end]]--
end

return AssistCommon