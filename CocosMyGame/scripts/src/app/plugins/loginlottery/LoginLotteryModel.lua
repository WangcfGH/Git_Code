local LoginLotteryModel = class('LoginLotteryModel', require('src.app.GameHall.models.BaseModel'))
my.addInstance(LoginLotteryModel)

local LoginLotteryReq = import('src.app.plugins.loginlottery.LoginLotteryReq')
local AssistModel = mymodel('assist.AssistModel'):getInstance()
local PublicInterface = cc.exports.PUBLIC_INTERFACE
local treepack = cc.load('treepack')

local UserModel = mymodel('UserModel'):getInstance()
local DeviceModel = require("src.app.GameHall.models.DeviceModel"):getInstance()

local LoginLotteryDef = {
    GR_SEND_LOTTERYCOUNT_REQ                    = 403001, -- 获取抽奖次数
    GR_SEND_LOTTERYCOUNT_RESP                   = 403002, -- 回复抽奖次数

    GR_SEND_LOGIN_LOTTERY_CONFIG_REQ_EX         = 410014, -- 查询 登录抽奖配置(新)
    GR_SEND_LOGIN_LOTTERY_INFO_REQ_EX           = 410016, -- 查询登录抽奖信息（是否能抽奖，连续登录奖励信息）(新)
    GR_SEND_LOGIN_LOTTERY_DRAW_REQ              = 410005, -- 请求 每日抽奖
    GR_SEND_LOGIN_LOTTERY_REWARD_REQ_EX         = 410015, -- 请求 领取登录奖励(新)

    GR_SEND_LOGIN_LOTTERY_CONFIG_RESP           = 410002, -- 回复登录抽奖配置
    GR_SEND_LOGIN_LOTTERY_INFO_RESP             = 410004, -- 回复登录抽奖信息
    GR_SEND_LOGIN_LOTTERY_DRAW_RESP             = 410006, -- 回复 每日抽奖结果
    GR_SEND_LOGIN_LOTTERY_REWARD_RESP           = 410008, -- 回复 领取登录奖励结果
    GR_SEND_LOGIN_LOTTERY_DRAW_REQ_EX           = 410370,
    GR_LOGIN_LOTTERY_TAKE_EXTRA_REWARD          = 410371, --  抽奖领取额外奖励
    GR_LOGIN_LOTTERY_VIA_VIDEO                  = 410372
}

LoginLotteryModel.INFO_STATUS = {
    NO_CONFIG           = 0,
    NORMAL              = 1,
    REQUIRING           = 2,
    CONFIG_REQUIRING    = 3,
}

LoginLotteryModel.LOTTERY_STATUS = {
    NORMAL          = 0,			-- 能抽奖
	USER_DRAWN      = 1,		    -- 用户今日已抽
	DEVICE_DRAWN    = 2,	        -- 设备今日已抽
	NO_GAMECOUNT    = 3	            -- 两次抽奖之间未进行对局
}

LoginLotteryModel.EVENT_MAP = {
    ["onReturnLoginLotteryConfig"] = "onReturnLoginLotteryConfig",
    ["onReturnLoginLotteryInfo"] = "onReturnLoginLotteryInfo",
    ["onReturnLoginLotteryDraw"] = "onReturnLoginLotteryDraw",
    ["onReturnLoginLotteryViaVideo"] = "onReturnLoginLotteryViaVideo",
    ["onReturnLoginLotteryReward"] = "onReturnLoginLotteryReward",
    ["loginLotteryModel_rewardAvailChanged"] = "loginLotteryModel_rewardAvailChanged"
}

function LoginLotteryModel:onCreate()
    self._config = nil              -- 登录抽奖配置信息
    self._info = nil                -- 登录抽奖信息 （今天是否能抽奖）（连续登录奖励情况）

    self._assistResponseMap = {
        [LoginLotteryDef.GR_SEND_LOTTERYCOUNT_RESP] = handler(self, self.dealLotteryCountResp),
        [LoginLotteryDef.GR_SEND_LOGIN_LOTTERY_CONFIG_RESP] = handler(self, self.onReturnLoginLotteryConfig),
        [LoginLotteryDef.GR_SEND_LOGIN_LOTTERY_INFO_RESP] = handler(self, self.onReturnLoginLotteryInfo),
        [LoginLotteryDef.GR_SEND_LOGIN_LOTTERY_DRAW_RESP] = handler(self, self.onReturnLoginLotteryDraw),
        [LoginLotteryDef.GR_SEND_LOGIN_LOTTERY_REWARD_RESP] = handler(self, self.onReturnLoginLotteryReward),
        [LoginLotteryDef.GR_LOGIN_LOTTERY_VIA_VIDEO] = handler(self, self.onReturnLoginLotteryViaVideo),
        [LoginLotteryDef.GR_LOGIN_LOTTERY_TAKE_EXTRA_REWARD] = handler(self, self.onReturnLoginLotteryExtraReward)
    }
    AssistModel:registCtrl(self, self.dealAssistResponse)
end

-- 登录抽奖 配置获取
function LoginLotteryModel:onGetLoginLotteryConfig()
    AssistModel:sendData(LoginLotteryDef.GR_SEND_LOGIN_LOTTERY_CONFIG_REQ_EX)
end

-- 登录抽奖 抽奖和连续奖励信息
function LoginLotteryModel:onGetLoginLotteryInfo()
    local playerInfo = PublicInterface.GetPlayerInfo()
    local deviceCombineID = DeviceModel.szHardID..DeviceModel.szMachineID..DeviceModel.szVolumeID
    local data = {
        nUserID     = playerInfo.nUserID,
        szDeviceID  = deviceCombineID
    }
    local loginLotteryInfoReq = LoginLotteryReq["LOGIN_LOTTERY_INFO_REQ"]
    local pData = treepack.alignpack(data, loginLotteryInfoReq)
    AssistModel:sendData(LoginLotteryDef.GR_SEND_LOGIN_LOTTERY_INFO_REQ_EX, pData)
end

-- 抽奖请求
function LoginLotteryModel:onLoginLotteryDraw()
    local deviceCombineID = DeviceModel.szHardID..DeviceModel.szMachineID..DeviceModel.szVolumeID
    local playerInfo = PublicInterface.GetPlayerInfo()
    local data = {
        nUserID     = playerInfo.nUserID,
        szUserName  = playerInfo.szUsername,
        szDeviceID  = deviceCombineID,
        kpiClientData = AssistModel:getKPIClientData()
    }
    local loginLotteryDrawReq = LoginLotteryReq["LOGIN_LOTTERY_DRAW_REQ"]
    local pData = treepack.alignpack(data, loginLotteryDrawReq)
    AssistModel:sendData(LoginLotteryDef.GR_SEND_LOGIN_LOTTERY_DRAW_REQ_EX, pData)
end

-- 抽奖请求, 消耗视频次数
function LoginLotteryModel:onLoginLotteryViaVideo()
    local deviceCombineID = DeviceModel.szHardID..DeviceModel.szMachineID..DeviceModel.szVolumeID
    local playerInfo = PublicInterface.GetPlayerInfo()
    local data = {
        nUserID     = playerInfo.nUserID,
        szUserName  = playerInfo.szUsername,
        szDeviceID  = deviceCombineID,
        kpiClientData = AssistModel:getKPIClientData()
    }
    local loginLotteryDrawReq = LoginLotteryReq["LOGIN_LOTTERY_DRAW_REQ"]
    local pData = treepack.alignpack(data, loginLotteryDrawReq)
    AssistModel:sendData(LoginLotteryDef.GR_LOGIN_LOTTERY_VIA_VIDEO, pData)
end

-- 登录抽奖 领奖请求
function LoginLotteryModel:onLoginLotteryReward(nDays)
    local playerInfo = PublicInterface.GetPlayerInfo()
    local data = {
        nUserID     = playerInfo.nUserID,
        nDays       = nDays,
        nCount      = 0,  --随便发一个数据
        kpiClientData = AssistModel:getKPIClientData()
    }
    local loginLotteryRewardReq = LoginLotteryReq["LOGIN_LOTTERY_REWARD_REQ_EX"]
    local pData = treepack.alignpack(data, loginLotteryRewardReq)
    AssistModel:sendData(LoginLotteryDef.GR_SEND_LOGIN_LOTTERY_REWARD_REQ_EX, pData)
end

function LoginLotteryModel:sendLotteryCountReq()

end

-- 领取额外奖励
function LoginLotteryModel:onTakeExtraReward(extraRewardIdx)
    local playerInfo = PublicInterface.GetPlayerInfo()
    local data = {
        nUserID = playerInfo.nUserID,
        nExtraRewardIdx = extraRewardIdx
    }
    local packedData = treepack.alignpack(data, LoginLotteryReq["LOGIN_LOTTERY_TAKE_EXTRA_REWARD"])
    AssistModel:sendData(LoginLotteryDef.GR_LOGIN_LOTTERY_TAKE_EXTRA_REWARD, packedData)
end

function LoginLotteryModel:dealLotteryCountResp(responseData)
    printf('send lotterycount resp')
    local lotteryCountInfo = LoginLotteryReq["LOTTERY_COUNT_RESP"]
    local msgLotteryCountInfo = treepack.unpack(responseData, lotteryCountInfo)
    dump(msgLotteryCountInfo)

    if self._LotteryCtrl then
        self._LotteryCtrl:updateLotteryCount(msgLotteryCountInfo)
    end

    cc.exports.gameProtectData.lotteryCount = msgLotteryCountInfo.nLotteryCount

end

-- 返回 登录抽奖配置信息
function LoginLotteryModel:onReturnLoginLotteryConfig(data)
    local dataMap = json.decode(data)
    dataMap = checktable(dataMap)
    dump(dataMap)
    if next(dataMap) ~= nil then
        self._configState = nil
        self._config = dataMap
        self.config = dataMap

        self:dispatchEvent({name = LoginLotteryModel.EVENT_MAP["onReturnLoginLotteryConfig"]})
    end


    --登录弹窗模块
    local PluginProcessModel = mymodel("hallext.PluginProcessModel"):getInstance()
    PluginProcessModel:setPluginReadyStatus("LoginLotteryCtrl", true)
    PluginProcessModel:startPluginProcess()
end

-- 返回 抽奖和连续登录奖励信息
function LoginLotteryModel:onReturnLoginLotteryInfo(data)
    local loginLotteryInfo = LoginLotteryReq["LOGIN_LOTTERY_INFO_RESP"]
    local dataMap = treepack.unpack(data, loginLotteryInfo)
    dump(dataMap)
    dataMap = checktable(dataMap)
    if next(dataMap) ~= nil then
        self._infoState = nil
        self._info = dataMap
        self._infoDate = self._infoCacheDate or self:getTodayDate()
        self:saveInfoCache()
        self:dispatchEvent({name = LoginLotteryModel.EVENT_MAP["onReturnLoginLotteryInfo"]})
    end

    -- 刷新红点
    self._myStatusDataExtended["isNeedReddot"] = self:isNeedRedDot()
    self:dispatchModuleStatusChanged("lottery", LoginLotteryModel.EVENT_MAP["loginLotteryModel_rewardAvailChanged"])

end

-- 返回 每日抽奖结果
function LoginLotteryModel:onReturnLoginLotteryDraw(data)
    local loginLotteryDraw = LoginLotteryReq["LOGIN_LOTTERY_DRAW_RESP"]
    local dataMap = treepack.unpack(data, loginLotteryDraw)
    dump(dataMap)

    if dataMap.nResult >= 0 then
        self._info.nLotteryCount = dataMap.nLotteryCount
        if dataMap.nLotteryCount > 0 then
            self._info.nLotteryStatus = LoginLotteryModel.LOTTERY_STATUS.NORMAL
        else
            self._info.nLotteryStatus = LoginLotteryModel.LOTTERY_STATUS.USER_DRAWN
        end
        self._info.nExtraRewardIdx = dataMap.nExtraRewardIdx
        self:saveInfoCache()

        -- 刷新红点
        self._myStatusDataExtended["isNeedReddot"] = self:isNeedRedDot()
        self:dispatchModuleStatusChanged("lottery", LoginLotteryModel.EVENT_MAP["loginLotteryModel_rewardAvailChanged"])
    else
        self:clearExtraReward()
    end
    self:dispatchEvent({name = LoginLotteryModel.EVENT_MAP["onReturnLoginLotteryDraw"], value = dataMap})
end

function LoginLotteryModel:onReturnLoginLotteryViaVideo(data)
    local loginLotteryDraw = LoginLotteryReq["LOGIN_LOTTERY_DRAW_RESP"]
    local dataMap = treepack.unpack(data, loginLotteryDraw)

    if dataMap.nResult >= 0 then
        self._info.nVideoCount = dataMap.nVideoCount
        self._info.nExtraRewardIdx = dataMap.nExtraRewardIdx
        self:saveInfoCache()

        -- 刷新红点
        self._myStatusDataExtended["isNeedReddot"] = self:isNeedRedDot()
        self:dispatchModuleStatusChanged("lottery", LoginLotteryModel.EVENT_MAP["loginLotteryModel_rewardAvailChanged"])
    else
        self:clearExtraReward()
    end
    self:dispatchEvent({name = LoginLotteryModel.EVENT_MAP["onReturnLoginLotteryViaVideo"], value = dataMap})
end

function LoginLotteryModel:onReturnLoginLotteryExtraReward(data)
    local parsedData = treepack.unpack(data, LoginLotteryReq["LOGIN_LOTTERY_TAKE_EXTRA_REWARD_RSP"])
    if not parsedData then 
        return
    end
    if parsedData.nResult >= 0 then
        self:clearExtraReward()
        local rewardList = {}
        for i = 1, parsedData.nCount do
            local t = parsedData.nRewardType[i]
            local count = parsedData.nRewardCount[i]
            table.insert(rewardList, { nType = t, nCount = count })
        end
        if #rewardList > 0 then
            my.informPluginByName({pluginName = "RewardTipCtrl", params = {data = rewardList}})
            -- 更新数据
            -- 道具
            local PropModel = require('src.app.plugins.shop.prop.PropModel'):getInstance()
            PropModel:updatePropByReq(rewardList)
            -- 记牌器
            local CardRecorderModel = import("src.app.plugins.shop.cardrecorder.CardRecorderModel"):getInstance()
            CardRecorderModel:updateByReq(rewardList)
            -- 定时赛门票
            local TimingGameModel = import('src.app.plugins.TimingGame.TimingGameModel'):getInstance()
            TimingGameModel:updateTicketByReq(rewardList)
        end
    else
        self:clearExtraReward()
        print("[ERROR] take extra-reward failed...")
    end
end

-- 返回 领奖结果
function LoginLotteryModel:onReturnLoginLotteryReward(data)
    local loginLotteryRewardResp = LoginLotteryReq["LOGIN_LOTTERY_REWARD_RESP"]
    local dataMap = treepack.unpack(data, loginLotteryRewardResp)
    dump(dataMap)
    self:dispatchEvent({name = LoginLotteryModel.EVENT_MAP["onReturnLoginLotteryReward"], value = dataMap})
    if dataMap.nResult > 0 then
        local rewardConfig = self._config["continuousLoginConfig"]["extraReward"]
        local nIndex = 0
        for i = 1, 4 do
            if rewardConfig[i]["days"] == dataMap.nResult then
                nIndex = i
                break
            end
        end

        -- 更新缓存
        if nIndex > 0 then
            self._info.bTakes[nIndex] = 1
        end
        self:saveInfoCache()
        --刷新红点
        self._myStatusDataExtended["isNeedReddot"] = self:isNeedRedDot()
        self:dispatchModuleStatusChanged("lottery", LoginLotteryModel.EVENT_MAP["loginLotteryModel_rewardAvailChanged"])
    end
end

-- 是否有转盘次数或者奖励可领
function LoginLotteryModel:isNeedRedDot()
    if self._config and self._info then
        local isNeed = false
        isNeed = (self._info.nLotteryStatus == LoginLotteryModel.LOTTERY_STATUS.NORMAL)
        if isNeed then
            return true
        else
            local rewardConfig = self._config["continuousLoginConfig"]["extraReward"]
            for i = 1, 4 do
                isNeed = (self._info.nDays[i] == rewardConfig[i].days) and (self._info.bTakes[i] < 1)
                if isNeed then return true end
            end
        end
    end
    return false
end

-- 返回转盘可用次数（无论是否有对局）
function LoginLotteryModel:getLotteryCount()
    if self._info then
        return self._info.nLotteryCount
    end
    return 0
end

function LoginLotteryModel:getInfo()
    return self._info
end

function LoginLotteryModel:getConfig()
    return self._config
end

function LoginLotteryModel:clearExtraReward()
    if self._info then
        self._info.nExtraRewardIdx = 0
    end
end

-- 返回还未领取的银子数量
function LoginLotteryModel:getAvailableRewardMoney()
    local total = 0
    if self._info and self._config then
        local rewardConfig = self._config["continuousLoginConfig"]["extraReward"]
        for i = 1, 4 do
            if (self._info.nDays[i] == rewardConfig[i].days) and (self._info.bTakes[i] < 1) then
                total = total + rewardConfig[i].count
            end
        end
    end
    return total
end

-- 检查配置与信息
function LoginLotteryModel:checkInfo()
    if not self._config then
        if not self.config then
            if self._configState == LoginLotteryModel.INFO_STATUS.CONFIG_REQUIRING then
                return self._configState
            end
            print("Login Lottery Ctrl: Config do not exist!!!!")
            self:onGetLoginLotteryConfig()
            self._configState = LoginLotteryModel.INFO_STATUS.CONFIG_REQUIRING
        end
        self._config = self.config
    end
    
    -- 检查用户ID，防止游戏内切换用户读取错误数据
    if self._info then
        if self._info.nUserID ~= UserModel.nUserID 
            or self._info.nUserID == 0 then
            self._info = nil
        end
    end

    if self._info then
        return LoginLotteryModel.INFO_STATUS.NORMAL
    end
    
    if self._infoState == LoginLotteryModel.INFO_STATUS.REQUIRING then
        return self._infoState
    end

    self._infoCacheDate = self:getTodayDate()    -- 记录请求时间作为缓存时间
    self:onGetLoginLotteryInfo()
    self._infoState = LoginLotteryModel.INFO_STATUS.REQUIRING
    return LoginLotteryModel.INFO_STATUS.REQUIRING
end

-- 检查局数是否满足要求
function LoginLotteryModel:checkGameBoutEnough()
    if self._info and self._info.nLotteryCount and self._info.nLotteryCount > 0 and self._info.nLotteryStatus and self._info.nLotteryStatus == LoginLotteryModel.LOTTERY_STATUS.NO_GAMECOUNT then
        self._info.nLotteryStatus = LoginLotteryModel.LOTTERY_STATUS.NORMAL
        --刷新红点
        self._myStatusDataExtended["isNeedReddot"] = self:isNeedRedDot()
        self:dispatchModuleStatusChanged("lottery", LoginLotteryModel.EVENT_MAP["loginLotteryModel_rewardAvailChanged"])
    end    
end

--[Comment]
-- 读缓存
function LoginLotteryModel:readInfoCache()
    local dataMap
    local filename = self:getCacheFileName()
    if (false == my.isCacheExist(filename)) then
        return false
    end

    dataMap=my.readCache(filename)
    dataMap=checktable(dataMap)
    local date = self:getTodayDate()
    -- 如果不是今天的缓存，则无效
    if (date ~= dataMap.szDate) then
        return false
    end
    self._infoDate = dataMap.szDate
    print("readLoginLotteryInfoCache",filename)
    dump(dataMap)
    return dataMap
end

-- 写缓存
function LoginLotteryModel:saveInfoCache()
    if not self._infoCacheDate then
        self._infoCacheDate = self:getTodayDate()
    end
    -- 构造缓存
    local cache = {
        szDate = self._infoCacheDate,
        info = self._info,
    }
    self._infoCacheDate = nil
    local data  = checktable(cache)
    dump(data)
    my.saveCache(self:getCacheFileName(), data)
end

function LoginLotteryModel:getCacheFileName()
    return "LoginLottery"..tostring(UserModel.nUserID)..".xml"
end

-- 获取今天日期
function LoginLotteryModel:getTodayDate()
    local tmYear=os.date('%Y',os.time())
    local tmMon=os.date('%m',os.time())
    local tmMday=os.date('%d',os.time())
    return tmYear.."_"..tmMon.."_"..tmMday
end

function LoginLotteryModel:isSupportAdvertVideo()
    if not cc.exports.isLoginLotteryApplyVideo() then 
        return false
    end
    local AdPlugin = plugin.AgentManager:getInstance():getAdsPlugin()
    if not AdPlugin then 
        return false
    end
    if not (AdPlugin.loadChannelAd and AdPlugin.showChannelAd) then
        return false
    end  
    return true -- 现假定为true,具体逻辑再定
end

return LoginLotteryModel