local GiftExchangeModel = class('GiftExchangeModel', require('src.app.GameHall.models.BaseModel'))
local AssistModel = mymodel('assist.AssistModel'):getInstance()
local user = mymodel('UserModel'):getInstance()
local device=mymodel('DeviceModel'):getInstance()
local userPlugin = plugin.AgentManager:getInstance():getUserPlugin()
local RewardTipDef = import("src.app.plugins.RewardTip.RewardTipDef")
local CardRecorderModel = import("src.app.plugins.shop.cardrecorder.CardRecorderModel"):getInstance()
local NobilityPrivilegeModel = import("src.app.plugins.NobilityPrivilege.NobilityPrivilegeModel"):getInstance()
local TimingGameModel = import('src.app.plugins.TimingGame.TimingGameModel'):getInstance()
local PromoteCodeModel      = require("src.app.plugins.PromoteCode.PromoteCodeModel"):getInstance()

protobuf.register_file('src/app/plugins/giftexchange/GiftExchange.pb')

my.addInstance(GiftExchangeModel)

local UsageType = {
    TCY         = 1,    --单包
    TCYAPP      = 2,    --同城游
    PLATFORMSET = 3,    --合集包
}

local GiftReqStatus = {
    failed = 'failed',
    success = 'success'
}

-- 后台礼包错误码
local GiftErrorCode = {
    [10005] = '系统错误',
    [30001] = '参数错误',
    [30002] = '用户验证不通过',
    [30003] = '错误领取达到上限',
    [30004] = '礼包码不存在',
    [30005] = '您已经领取当前礼包',
    [30006] = '当前礼包码已被使用过',
    [30007] = '当前礼包码已被领完',
    [30011] = '礼包码关联游戏不匹配',
    [30012] = '您的账号已达领取上限',
    [30013] = '您的设备已达领取上限',
    [30014] = '关联渠道不匹配',
    [30015] = '服务异常',
    [30016] = '您已绑定本游戏的推广码',
    [30017] = '已超过注册时间限制',
    [40001] = '礼包码未开始',
    [40002] = '礼包码已过期',
    [40003] = '礼包码未启用'
}
setmetatable(GiftErrorCode, {__index = function() return '兑换失败，请稍后再试' end})

GiftExchangeModel.UPDATE_RESULT = "UPDATE_RESULT"

---- 礼包兑换--
local GR_GIFT_EXCHAHGE_REQREWARD          = (400000 + 6000)

function GiftExchangeModel:ctor()
    GiftExchangeModel.super.ctor(self)
    AssistModel:registCtrl(self, self._onReceivedData)
end

function GiftExchangeModel:isResponseID(responseId)
    local responseIdTbl = {
        [GR_GIFT_EXCHAHGE_REQREWARD] = true,
    }
    if not responseIdTbl[responseId] then
        return false
    else 
        return true
    end
end

function GiftExchangeModel:_onReceivedData(dataMap)
    local responseId, rawdata = unpack(dataMap.value)
    if responseId == GR_GIFT_EXCHAHGE_REQREWARD then
        self:onRspGift(rawdata)
    end
end

function GiftExchangeModel:getDeviceId()
	local szWifiID,szImeiID,szSystemID=device.szWifiID,device.szImeiID,device.szSystemID
	local deviceId=string.format('%s,%s,%s',szWifiID,szImeiID,szSystemID)
	return deviceId
end

function GiftExchangeModel:getUsageType()
    if  MCAgent:getInstance().getLaunchSubMode and MCAgent:getInstance():getLaunchSubMode() > 0 then
        return UsageType.PLATFORMSET
    end
    if cc.exports.LaunchMode["PLATFORM"] == MCAgent:getInstance():getLaunchMode() then
        return UsageType.TCYAPP
    else
        return UsageType.TCY
    end
end

function GiftExchangeModel:sendReqGift(exchangeCode, exchangeCodeType)
    local usageType     = self:getUsageType()
    local subChannelId  = BusinessUtils:getInstance():getRecommenderId()
    local channelId     = subChannelId                          -- 单包的情况
    if usageType ~= UsageType.TCY then
        channelId = BusinessUtils:getInstance():getTcyChannel() -- 非单包情况
    end

    local deviceID = self:getDeviceId()

    local data = {
        userid          = user.nUserID or 0,
        accessToken     = userPlugin:getAccessToken(),
        exchangeCode    = exchangeCode or "",
        GameId          = BusinessUtils:getInstance():getGameID(),
        DeviceId        = deviceID,
        ChannelId       = channelId,
        codeType        = exchangeCodeType,
    }
    dump(data, "GiftExchange: parameter")
    local pbdata = protobuf.encode('GiftExchange.ReqGift', data)
    AssistModel:sendData(GR_GIFT_EXCHAHGE_REQREWARD, pbdata)
end

function GiftExchangeModel:onRspGift(data)
    if not data then 
        print("[ERROR] GiftExchange: No reponse data.")
        return 
    end
    
    local rspGift = protobuf.decode('GiftExchange.RspGift', data)
    protobuf.extract(rspGift)
    if not rspGift then 
        print("[ERROR] GiftExchange: pb_decode error.")
        return 
    end 
    dump(rspGift, "GiftExchange request gift result = ")

    if rspGift.errcode == GiftReqStatus.failed then
        local errorString = GiftErrorCode[rspGift.suberrcode or -1]
        self:dispatchEvent({name = self.UPDATE_RESULT, value = errorString})
    elseif rspGift.errcode == GiftReqStatus.success then
        self:dispatchEvent({name = self.UPDATE_RESULT, value = "礼包领取成功"})
        if rspGift.codeType == 1 and rspGift.promoteCode and toint(rspGift.promoteCode) > 0 then
            PromoteCodeModel:setPromoteCode(toint(rspGift.promoteCode))
        end
        -- 显示奖励弹窗
        local rewardList = {}
        local totalRewardItems = {}
        if rspGift.customRewards then
            totalRewardItems = rspGift.customRewards
        end
        if rspGift.channelReward then
            self._moveDeposits = 0
            for _, name in pairs(rspGift.channelReward.items or {}) do
                if self:_isDeposit(name) then
                    local count = self:_getCountFromName(name)
                    if count and count > 0 then       -- 1 - 银子
                        self:_merge2table( rewardList, { nType = RewardTipDef.TYPE_SILVER, nCount = count })
                        self._moveDeposits = self._moveDeposits + count
                    end
                    print("[INFO] GiftExchange, Get Deposit...")
                elseif self:_isGiftVoucher(name) then
                    print("[INFO] GiftExchange, Get GiftVoucher...")
                    local count = self:_getCountFromName(name)
                    if count and count > 0 then      -- 2 - 礼券
                        self:_merge2table( rewardList, { nType = RewardTipDef.TYPE_TICKET, nCount = count })
                    end
                end
            end
        end
        
        
        for u, v in pairs(totalRewardItems) do
            table.insert( rewardList,{nType = v.itemID,nCount = v.count})
        end
        if #rewardList > 0 then
            my.informPluginByName({
                pluginName = 'RewardTipCtrl', 
                params = {
                    data = rewardList,
                    showOkOnly = true, 
                    callback =  handler(self, self._onPluginClosed)
                }
            })
            CardRecorderModel:sendGetCardMakerInfo() --查询记牌器信息
        end
        for i,v in pairs(rewardList) do
            if v.nType == RewardTipDef.TYPE_REWARDTYPE_NOBILITY_EXP then
                NobilityPrivilegeModel:gc_GetNobilityPrivilegeInfo() --查询贵族信息
            elseif v.nType == RewardTipDef.TYPE_REWARDTYPE_TIMINGGAME_TICKET then
                TimingGameModel:reqTimingGameInfoData()
            end
        end
        my.scheduleOnce(function()
            local playerModel = mymodel("hallext.PlayerModel"):getInstance()
            playerModel:update({'SafeboxInfo','MemberInfo','UserGameInfo'})
        end, 2) 
        
    else 
        print("[ERROR] GiftExchange: Unknown errcode:", rspGift.errcode)
    end
end

function GiftExchangeModel:_onPluginClosed()
    local moveDeposits = self._moveDeposits
    if not moveDeposits then 
        return
    end
end 

function GiftExchangeModel:_merge2table(items, item)
    local isInTable = false
    for _, v in pairs(items) do
        if v.nType == item.nType then
            v.nCount = v.nCount + item.nCount
            isInTable = true 
            break
        end
    end
    if not isInTable then
        table.insert(items, item)
    end
end

-- 是否为银两
function GiftExchangeModel:_isDeposit(rewardName)
    if not rewardName then 
        return false 
    end
    local res = string.find(rewardName, "银子")
    if res then
        return true 
    end
    return false
end

-- 是否为礼券
function GiftExchangeModel:_isGiftVoucher(rewardName)
    if not rewardName then return false end
    local res = string.find(rewardName, '礼券')
    if res then
        return true 
    end 
    return false
end

function GiftExchangeModel:_getCountFromName(rewardName)
    if not rewardName then 
        return 0
    end
    local s, e = string.find(rewardName, '%d+')
    if s and e then
        return tonumber(string.sub(rewardName, s, e))
    end
    return 0
end

return GiftExchangeModel