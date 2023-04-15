local VivoPrivilegeStartUpModel         = class('VivoPrivilegeStartUpModel', require('src.app.GameHall.models.BaseModel'))
local VivoPrivilegeStartUpDef           = require('src.app.plugins.VivoPrivilegeStartUp.VivoPrivilegeStartUpDef')
local RewardTipDef                      = import("src.app.plugins.RewardTip.RewardTipDef")
local AssistModel                       = mymodel('assist.AssistModel'):getInstance()
local user                              = mymodel('UserModel'):getInstance()
local deviceModel                       = mymodel('DeviceModel'):getInstance()

my.addInstance(VivoPrivilegeStartUpModel)

protobuf.register_file('src/app/plugins/VivoPrivilegeStartUp/pbVivoPrivilegeStartUp.pb')

function VivoPrivilegeStartUpModel:onCreate()
    self._config            = nil   -- 配置信息
    self._rewardState       = nil   -- Vivo特权活动领奖状态

    -- 注册回调
    self:initAssistResponse()
end

-- 注册回调
function VivoPrivilegeStartUpModel:initAssistResponse()
    self._assistResponseMap = {
        [VivoPrivilegeStartUpDef.GR_VIVO_PRIVILEGE_STARTUP_QUERY_CONFIG] = handler(self, self.onVivoPrivilegeStartUpConfig),
        [VivoPrivilegeStartUpDef.GR_VIVO_PRIVILEGE_STARTUP_QUERY_INFO] = handler(self, self.onVivoPrivilegeStartUpStateInfo),
        [VivoPrivilegeStartUpDef.GR_VIVO_PRIVILEGE_STARTUP_TAKE_REWARD] = handler(self, self.onTakeReward),
    }

    AssistModel:registCtrl(self, self.dealAssistResponse)
end

--请求Vivo特权活动配置数据
function VivoPrivilegeStartUpModel:reqVivoPrivilegeStartUpConfig()
    print("VivoPrivilegeStartUpModel:reqVivoPrivilegeStartUpConfig")
    if not cc.exports.isVivoVipActivitySupported()  then
        return
    end
      
    if user.nUserID == nil or user.nUserID < 0 then
        print("userinfo is not ok")
        return
    end

    local data = {
        userid = user.nUserID,
    }
    local pdata = protobuf.encode('pbVivoPrivilegeStartUp.ReqConfig', data)
    AssistModel:sendData(VivoPrivilegeStartUpDef.GR_VIVO_PRIVILEGE_STARTUP_QUERY_CONFIG, pdata, false)
end

--响应Vivo特权活动配置数据获取
function VivoPrivilegeStartUpModel:onVivoPrivilegeStartUpConfig(data)
    if string.len(data) == nil then return nil end
    if not cc.exports.isVivoVipActivitySupported() then return end

    local pdata = json.decode(data)

    dump(pdata, "VivoPrivilegeStartUpModel:onVivoPrivilegeStartUpConfig")

    self._config = pdata

    self:dispatchEvent({name = VivoPrivilegeStartUpDef.VIVO_PRIVILEGE_STARTUP_QUERY_CONFIG_RSP})
end

--请求Vivo特权活动领奖状态数据
function VivoPrivilegeStartUpModel:reqVivoPrivilegeStartUpStateInfo()
    print("VivoPrivilegeStartUpModel:reqVivoPrivilegeStartUpStateInfo")
    if not cc.exports.isVivoVipActivitySupported()  then
        return
    end
      
    if user.nUserID == nil or user.nUserID < 0 then
        print("userinfo is not ok")
        return
    end

    local data = {
        userid = user.nUserID,
    }
    local pdata = protobuf.encode('pbVivoPrivilegeStartUp.QueryInfoDataResp', data)
    AssistModel:sendData(VivoPrivilegeStartUpDef.GR_VIVO_PRIVILEGE_STARTUP_QUERY_INFO, pdata, false)
end

--响应Vivo特权活动领奖状态数据获取
function VivoPrivilegeStartUpModel:onVivoPrivilegeStartUpStateInfo(data)
    if string.len(data) == nil then return nil end
    if not cc.exports.isVivoVipActivitySupported() then return end

    local pdata = protobuf.decode('pbVivoPrivilegeStartUp.QueryInfoDataResp', data)
    protobuf.extract(pdata)
    dump(pdata, "VivoPrivilegeStartUpModel:onVivoPrivilegeStartUpStateInfo")

    self._state = pdata.rewardState

    self:dispatchEvent({name = VivoPrivilegeStartUpDef.VIVO_PRIVILEGE_STARTUP_QUERY_STATE_RSP})
end

--领取Vivo特权活动领奖
function VivoPrivilegeStartUpModel:reqTakeReward()
    print("VivoPrivilegeStartUpModel:reqTakeReward")
    if not cc.exports.isVivoVipActivitySupported()  then
        return
    end
      
    if user.nUserID == nil or user.nUserID < 0 then
        print("userinfo is not ok")
        return
    end

    local nPlatform = 0
    if device.platform == "ios" and cc.exports.LaunchMode["PLATFORM"] ~= MCAgent:getInstance():getLaunchMode() then
        nPlatform = 1
    end

    local nOpen = 0
    if cc.exports.isExchangeLotterySupported() then
        nOpen = 1
    end

    local rewardTypes   = {}
    local rewardPropIDs = {}
    local rewardNums    = {}
    for i=1, #self._config["Reward"] do
        table.insert(rewardTypes, self._config["Reward"][i]["RewardType"])
        table.insert(rewardPropIDs, self._config["Reward"][i]["PropID"])
        table.insert(rewardNums, self._config["Reward"][i]["RewardNum"])
    end
    local data = {
        userid          = user.nUserID,
        osType          = nPlatform,
        open            = nOpen,
        rewardType      = rewardTypes,
        rewardPropID    = rewardPropIDs,
        rewardNum       = rewardNums,
    }
    local pdata = protobuf.encode('pbVivoPrivilegeStartUp.TakeRewardReq', data)
    AssistModel:sendData(VivoPrivilegeStartUpDef.GR_VIVO_PRIVILEGE_STARTUP_TAKE_REWARD, pdata, false)
end

-- 退出
function VivoPrivilegeStartUpModel:GetRewardTipType(rewardType, propID)
    if rewardType == VivoPrivilegeStartUpDef.REWARD_TYPE_SILVER then
        return RewardTipDef.TYPE_SILVER
    elseif rewardType == VivoPrivilegeStartUpDef.REWARD_TYPE_EXCHANGE then
        return RewardTipDef.TYPE_TICKET
    else
        if propID == VivoPrivilegeStartUpDef.REWARD_PROP_ID_EXPRESSION_ROSE then
            return RewardTipDef.TYPE_ROSE
        elseif propID == VivoPrivilegeStartUpDef.REWARD_PROP_ID_EXPRESSION_LIGHTNING then
            return RewardTipDef.TYPE_LIGHTING
        elseif propID == VivoPrivilegeStartUpDef.REWARD_PROP_ID_ONEBOUT_CARDMARKER then
            return RewardTipDef.TYPE_CARDMARKER
        elseif propID == VivoPrivilegeStartUpDef.REWARD_PROP_ID_TIMING_GAME_TICKET then
            return RewardTipDef.TYPE_REWARDTYPE_TIMINGGAME_TICKET
        end
    end
end

--响应Vivo特权活动领奖领取
function VivoPrivilegeStartUpModel:onTakeReward(data)
    if string.len(data) == nil then return nil end
    if not cc.exports.isVivoVipActivitySupported() then return end

    local pdata = protobuf.decode('pbVivoPrivilegeStartUp.TakeRewardResp', data)
    protobuf.extract(pdata)
    dump(pdata, "VivoPrivilegeStartUpModel:onTakeReward")

    self._state = pdata.rewardedState

    if self._state == VivoPrivilegeStartUpDef.VIVO_PRIVILEGE_STARTUP_REWARDED then
        if #pdata.rewardType > 0 then
            local rewardType = RewardTipDef.TYPE_SILVER
            local rewardNum = 0
            local rewardList = {}            
            for i=1, #pdata.rewardType do
                rewardType = self:GetRewardTipType(pdata.rewardType[i], pdata.rewardPropID[i])
                rewardNum = pdata.rewardNum[i]
                table.insert( rewardList,{nType = rewardType,nCount = rewardNum})
            end
            if #rewardList > 0 then
                my.informPluginByName({pluginName = 'RewardTipCtrl', params = {data = rewardList,showOkOnly = true}})
                -- 更新数据
                -- 道具
                local PropModel = require('src.app.plugins.shop.prop.PropModel'):getInstance()
                PropModel:updatePropByReq(rewardList)
                -- 记牌器
                local CardRecorderModel = import("src.app.plugins.shop.cardrecorder.CardRecorderModel"):getInstance()
                CardRecorderModel:updateByReq(rewardList)
                -- 定时赛门票
                local TimingGameModel = import('src.app.plugins.TimingGame.TimingGameModel'):getInstance()
                TimingGameModel:reqTimingGameInfoData()
            end
        end
    end

    self:dispatchEvent({name = VivoPrivilegeStartUpDef.GR_VIVO_PRIVILEGE_STARTUP_TAKE_REWARD_RSP})
end

-- 获取配置信息
function VivoPrivilegeStartUpModel:getConfig()
    return self._config
end

-- 获取领奖状态信息
function VivoPrivilegeStartUpModel:getState()
    return self._state
end

-- 获取领奖状态信息
function VivoPrivilegeStartUpModel:startUpGame()
    cc.exports.autoPopVivoPrivilegeStartUp = true
    my.scheduleOnce(function()
        DeviceUtils:getInstance():openApp("GameStore")
    end, 0.1)
end

-- 获取首登自动弹窗最后日期
function VivoPrivilegeStartUpModel:getCacheLoginOpenDate()
    if user.nUserID == nil or user.nUserID < 0 then return end

    local cacheDate = CacheModel:getCacheByKey("VivoPrivilegeStartUpOpenDate"..user.nUserID)
    return cacheDate
end

-- 设置首登自动弹窗最后日期
function VivoPrivilegeStartUpModel:setCacheLoginOpenDate(date)
    if user.nUserID == nil or user.nUserID < 0 then return end
    CacheModel:saveInfoToCache("VivoPrivilegeStartUpOpenDate"..user.nUserID, date)
end

return VivoPrivilegeStartUpModel