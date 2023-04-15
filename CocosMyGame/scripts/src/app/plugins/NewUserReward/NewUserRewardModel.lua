local NewUserRewardModel    = class('NewUserRewardModel', require('src.app.GameHall.models.BaseModel'))
local NewUserRewardDef      = require('src.app.plugins.NewUserReward.NewUserRewardDef')
local AssistModel           = mymodel('assist.AssistModel'):getInstance()
local DeviceModel           = mymodel('DeviceModel'):getInstance()
local RewardTipDef          = import("src.app.plugins.RewardTip.RewardTipDef")

my.addInstance(NewUserRewardModel)

protobuf.register_file('src/app/plugins/NewUserReward/pbNewUserReward.pb')

function NewUserRewardModel:onCreate()
    self:initData()
    -- 注册回调
    self:initAssistResponse()
end

function NewUserRewardModel:initData()
    self._rewardState = NewUserRewardDef.NEWUSERREWARD_REWARDSTATE_NOTHISREWARD
    self._rewardList = {}
end

-- 注册回调
function NewUserRewardModel:initAssistResponse()
    self._assistResponseMap = {
        [NewUserRewardDef.GR_NEWUSERREWARD_QUERY_REWARDSTATE] = handler(self, self.onQueryRewardStateResp),
        [NewUserRewardDef.GR_NEWUSERREWARD_TAKE_REWARD] = handler(self, self.onTakeRewardResp),
    }

    AssistModel:registCtrl(self, self.dealAssistResponse)
end

function NewUserRewardModel:getPlatformType()
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

function NewUserRewardModel:saveRewardStateToCache()
    local user = mymodel('UserModel'):getInstance()
    local rewarded = self._rewardState == NewUserRewardDef.NEWUSERREWARD_REWARDSTATE_REWARDED
    CacheModel:saveInfoToCache("NewUserRewardState" .. user.nUserID, {Rewarded = rewarded})
end

-- 查询新手奖励状态
function NewUserRewardModel:queryRewaredState()
    if not cc.exports.isNewUserRewardSupported() then
        self:startPluginProcess()
        return
    end

    local user = mymodel('UserModel'):getInstance()
    if user.nUserID == nil or user.nUserID < 0 then
        print('NewUserRewardModel 玩家ID有误')
        self:startPluginProcess()
        return
    end

    if (not user.nBout) or (user.nBout and user.nBout > 0) then
        print('NewUserRewardModel 玩家局数有误 ', user.nUserID, user.nBout)
        self:startPluginProcess()
        return
    end
    
    local data = {
        userid = user.nUserID,
        deviceid = DeviceModel.szHardID,
        channelid = tostring(BusinessUtils:getInstance():getTcyChannel()),
        platformtype = self:getPlatformType(),
    }
    local pdata = protobuf.encode('pbNewUserReward.QueryRewardStateReq', data)
    AssistModel:sendData(NewUserRewardDef.GR_NEWUSERREWARD_QUERY_REWARDSTATE, pdata, false)
end

-- 查询到新手奖励状态
function NewUserRewardModel:onQueryRewardStateResp(data)
    if string.len(data) == nil then return nil end

    if not cc.exports.isNewUserRewardSupported() then return end

    local pdata = protobuf.decode('pbNewUserReward.QueryRewardStateResp', data)
    protobuf.extract(pdata)

    self._rewardState = pdata.rewardstate

    self:startPluginProcess()
end

function NewUserRewardModel:takeReward()
    if not cc.exports.isNewUserRewardSupported()  then
        return
    end
      
    local user = mymodel('UserModel'):getInstance()
    if user.nUserID == nil or user.nUserID < 0 then
        return
    end

    local data = {
        userid = user.nUserID,
        deviceid = DeviceModel.szHardID,
        channelid = tostring(BusinessUtils:getInstance():getTcyChannel()),
        platformtype = self:getPlatformType(),
    }

    local pdata = protobuf.encode('pbNewUserReward.TakeRewardReq', data)
    AssistModel:sendData(NewUserRewardDef.GR_NEWUSERREWARD_TAKE_REWARD, pdata, false)
end

function NewUserRewardModel:onTakeRewardResp(data)
    if string.len(data) == nil then return nil end
    if not cc.exports.isNewUserRewardSupported() then return end

    local pdata = protobuf.decode('pbNewUserReward.TakeRewardResp', data)
    protobuf.extract(pdata)

    if pdata.rewardresult == NewUserRewardDef.NEWUSERREWARD_REWARDRESULT_SUCCESS then
        if #pdata.rewardlist > 0 then
            local rewardType = RewardTipDef.TYPE_SILVER
            self._rewardList = {}
            for i = 1, #pdata.rewardlist do
                local rewardInfo = pdata.rewardlist[i]
                rewardType = self:GetRewardTipType(rewardInfo.rewardtype, rewardInfo.propid)
                table.insert( self._rewardList,{nType = rewardType,nCount = rewardInfo.rewardcount})
            end
        end
        self._rewardState = NewUserRewardDef.NEWUSERREWARD_REWARDSTATE_REWARDED
    elseif pdata.rewardresult == NewUserRewardDef.NEWUSERREWARD_REWARDRESULT_REWARDED then
        self._rewardState = NewUserRewardDef.NEWUSERREWARD_REWARDSTATE_REWARDED
    elseif pdata.rewardresult == NewUserRewardDef.NEWUSERREWARD_REWARDRESULT_NOTHISCONFIG then
        self._rewardState = NewUserRewardDef.NEWUSERREWARD_REWARDSTATE_NOTHISREWARD
    elseif pdata.rewardresult == NewUserRewardDef.NEWUSERREWARD_REWARDRESULT_UPTOLIMIT then
        self._rewardState = NewUserRewardDef.NEWUSERREWARD_REWARDSTATE_UPTOLIMIT
    elseif pdata.rewardresult == NewUserRewardDef.NEWUSERREWARD_REWARDRESULT_FAILD then

    end

    self:dispatchEvent({name = NewUserRewardDef.EVENT_NEWUSERREWARD_TAKE_REWARD_OK, value=pdata})
end

function NewUserRewardModel:GetRewardTipType(rewardType, propID)
    if rewardType == NewUserRewardDef.NEWUSERREWARD_ITEMTYPE_SILVER then
        return RewardTipDef.TYPE_SILVER
    elseif rewardType == NewUserRewardDef.NEWUSERREWARD_ITEMTYPE_EXCHANGE then
        return RewardTipDef.TYPE_TICKET
    else
        if propID == NewUserRewardDef.REWARD_PROP_ID_EXPRESSION_ROSE then
            return RewardTipDef.TYPE_ROSE
        elseif propID == NewUserRewardDef.REWARD_PROP_ID_EXPRESSION_LIGHTNING then
            return RewardTipDef.TYPE_LIGHTING
        elseif propID == NewUserRewardDef.REWARD_PROP_ID_ONEBOUT_CARDMARKER then
            return RewardTipDef.TYPE_CARDMARKER
        elseif propID == NewUserRewardDef.REWARD_PROP_ID_TIMING_GAME_TICKET then
            return RewardTipDef.TYPE_REWARDTYPE_TIMINGGAME_TICKET
        elseif propID == NewUserRewardDef.REWARD_PROP_ID_ONEDAY_CARD_MARKER then
            return RewardTipDef.TYPE_CARDMARKER_1D
        end
    end
end

function NewUserRewardModel:canTakeReward()
    return self._rewardState == NewUserRewardDef.NEWUSERREWARD_REWARDSTATE_CANTAKE
end

function NewUserRewardModel:getRewardState()
    return self._rewardState
end

function NewUserRewardModel:getRewardList()
    return self._rewardList
end

function NewUserRewardModel:startPluginProcess()
    local PluginProcessModel = mymodel('hallext.PluginProcessModel'):getInstance()
    if self._rewardState == NewUserRewardDef.NEWUSERREWARD_REWARDSTATE_CANTAKE then
        PluginProcessModel:setPluginReadyStatus("NewUserRewardPlugin",true)
        PluginProcessModel:startPluginProcess()
    else
        PluginProcessModel:setPluginReadyStatus("NewUserRewardPlugin",false)
        PluginProcessModel:startPluginProcess()
    end
end

function NewUserRewardModel:onLoginOff()
    self:initData()
end

return NewUserRewardModel