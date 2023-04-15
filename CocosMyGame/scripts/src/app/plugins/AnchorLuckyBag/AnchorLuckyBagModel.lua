local AnchorLuckyBagModel = class('AnchorLuckyBagModel', require('src.app.GameHall.models.BaseModel'))
local AssistModel = mymodel('assist.AssistModel'):getInstance()
local UserModel = mymodel('UserModel'):getInstance()
my.addInstance(AnchorLuckyBagModel)
protobuf.register_file('src/app/plugins/AnchorLuckyBag/pbAnchorLuckyBag.pb')

AnchorLuckyBagModel.GR_ANCHORLUCKYBAG_QUERY_TIKTOK_ACCOUNT = 403900
AnchorLuckyBagModel.GR_ANCHORLUCKYBAG_QUERY_REWARDLIST = 403901
AnchorLuckyBagModel.GR_ANCHORLUCKYBAG_COMMIT_REWARD_INFO = 403902


AnchorLuckyBagModel.EVENT_QUERY_TIKTOKACCOUNT_OK = 'EVENT_QUERY_TIKTOKACCOUNT_OK'
AnchorLuckyBagModel.EVENT_QUERY_REWARDLIST_OK = 'EVENT_QUERY_REWARDLIST_OK'
AnchorLuckyBagModel.EVENT_COMMIT_REWARDINFO_OK = 'EVENT_COMMIT_REWARDINFO_OK'

AnchorLuckyBagModel.ANCHORLUCKYBAG_RESULT_COMMIT_SUCCEED = 0    --中奖信息提交成功
AnchorLuckyBagModel.ANCHORLUCKYBAG_RESULT_COMMIT_FAILED = 1     --中奖信息提交失败
AnchorLuckyBagModel.ANCHORLUCKYBAG_RESULT_REWARDINFO_EXISTS = 2 --中奖信息重复提交
AnchorLuckyBagModel.ANCHORLUCKYBAG_RESULT_NOREWARDITEM = 3      --奖励信息没有配置
AnchorLuckyBagModel.ANCHIRLUCKYBAG_RESULT_ACCOUNT_EXISTS = 4    --抖音账号已被绑定
AnchorLuckyBagModel.ANCHIRLUCKYBAG_RESULT_INVALID_ACCOUNT = 5   --抖音号规则不正确


AnchorLuckyBagModel.ANCHORLUCKYBAG_REWARDSTATE_WAITINGREWARD = 0 -- 等待审核
AnchorLuckyBagModel.ANCHORLUCKYBAG_REWARDSTATE_REJECTREWARD = 1 -- 审核不通过
AnchorLuckyBagModel.ANCHORLUCKYBAG_REWARDSTATE_REWARDED = 2 -- 审核通过并发奖

function AnchorLuckyBagModel:onCreate()
    self._rewardList = {}
    self._tiktokAccount = ''
    self:initAssistResponse()
end

function AnchorLuckyBagModel:initAssistResponse()
    self._assistResponseMap = {
        [AnchorLuckyBagModel.GR_ANCHORLUCKYBAG_QUERY_TIKTOK_ACCOUNT] = handler(self, self.onQueryTiktokAccountRsp),
        [AnchorLuckyBagModel.GR_ANCHORLUCKYBAG_QUERY_REWARDLIST] = handler(self, self.onQueryRewardListRsp),
        [AnchorLuckyBagModel.GR_ANCHORLUCKYBAG_COMMIT_REWARD_INFO] = handler(self, self.onCommitRewardInfoRsp)
    }

    AssistModel:registCtrl(self, self.dealAssistResponse)
end

function AnchorLuckyBagModel:queryTiktokAcount()
    local params = {
        userid = UserModel.nUserID
    }

    local pdata = protobuf.encode('pbAnchorLuckyBag.QueryTiktokAcountReq', params)
    AssistModel:sendData(AnchorLuckyBagModel.GR_ANCHORLUCKYBAG_QUERY_TIKTOK_ACCOUNT, pdata, false)
end

function AnchorLuckyBagModel:queryRewardList()
    local params = {
        userid = UserModel.nUserID
    }

    local pdata = protobuf.encode('pbAnchorLuckyBag.QueryRewardListReq', params)
    AssistModel:sendData(AnchorLuckyBagModel.GR_ANCHORLUCKYBAG_QUERY_REWARDLIST, pdata, false)
end

function AnchorLuckyBagModel:commitRewardInfo(tiktokAccount, anchorAccount, rewardDateTime)
    local params = {
        rewardinfo = {
            userid = UserModel.nUserID,
            rewarddatetime = rewardDateTime,
            tiktokaccount = tiktokAccount,
            anchoraccount = anchorAccount
        }
    }

    local pdata = protobuf.encode('pbAnchorLuckyBag.CommitRewardInfoReq', params)
    AssistModel:sendData(AnchorLuckyBagModel.GR_ANCHORLUCKYBAG_COMMIT_REWARD_INFO, pdata, false)
end

function AnchorLuckyBagModel:onQueryTiktokAccountRsp(data)
    if string.len(data) == nil then
        return nil
    end

    local pdata = protobuf.decode('pbAnchorLuckyBag.QueryTiktokAcountRsp', data)
    protobuf.extract(pdata)

    self._tiktokAccount = pdata.tiktokaccount
    self:dispatchEvent({name = AnchorLuckyBagModel.EVENT_QUERY_TIKTOKACCOUNT_OK})
end

function AnchorLuckyBagModel:onQueryRewardListRsp(data)
    if string.len(data) == nil then
        return nil
    end

    local pdata = protobuf.decode('pbAnchorLuckyBag.QueryRewardListRsp', data)
    protobuf.extract(pdata)

    self._rewardList = pdata.rewardlist
    self:dispatchEvent({name = AnchorLuckyBagModel.EVENT_QUERY_REWARDLIST_OK})
end

function AnchorLuckyBagModel:onCommitRewardInfoRsp(data)
    if string.len(data) == nil then
        return nil
    end

    local pdata = protobuf.decode('pbAnchorLuckyBag.CommitRewardInfoRsp', data)
    protobuf.extract(pdata)
    
    local success = false
    if pdata.commitresult == AnchorLuckyBagModel.ANCHORLUCKYBAG_RESULT_COMMIT_FAILED then
        my.informPluginByName({pluginName = 'ToastPlugin', params = {tipString = '奖励信息提交失败，请稍后再试'}})
    elseif pdata.commitresult == AnchorLuckyBagModel.ANCHORLUCKYBAG_RESULT_REWARDINFO_EXISTS then
        my.informPluginByName({pluginName = 'ToastPlugin', params = {tipString = '奖励信息重复提交，请检查后重新输入'}})
    elseif pdata.commitresult == AnchorLuckyBagModel.ANCHORLUCKYBAG_RESULT_NOREWARDITEM then
        my.informPluginByName({pluginName = 'ToastPlugin', params = {tipString = '后台奖励配置异常，请稍后再试'}})
    elseif pdata.commitresult == AnchorLuckyBagModel.ANCHIRLUCKYBAG_RESULT_ACCOUNT_EXISTS then
        my.informPluginByName({pluginName = 'ToastPlugin', params = {tipString = '该抖音账号已被他人绑定，请更换抖音账号'}})
    elseif pdata.commitresult == AnchorLuckyBagModel.ANCHIRLUCKYBAG_RESULT_INVALID_ACCOUNT then
        my.informPluginByName({pluginName = 'ToastPlugin', params = {tipString = '抖音号只包含字母数字下划线和点，请检查后重新输入'}})
    else
        success = true
        table.insert(self._rewardList, pdata.rewardinfo)
        self._tiktokAccount = pdata.rewardinfo.tiktokaccount
        my.informPluginByName({pluginName = 'ToastPlugin', params = {tipString = '奖励信息提交成功，请耐心等待审核~'}})
    end

    self:dispatchEvent({name = AnchorLuckyBagModel.EVENT_COMMIT_REWARDINFO_OK, value = { commitSuccess = success }})
end

function AnchorLuckyBagModel:getTiktokAccount()
    return self._tiktokAccount
end

function AnchorLuckyBagModel:getRewardList()
    return self._rewardList
end

return AnchorLuckyBagModel
