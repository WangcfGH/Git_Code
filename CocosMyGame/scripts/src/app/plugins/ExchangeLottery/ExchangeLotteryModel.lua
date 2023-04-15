local ExchangeLotteryModel =class('ExchangeLotteryModel',require('src.app.GameHall.models.BaseModel'))
local AssistModel = mymodel('assist.AssistModel'):getInstance()
local Def = require('src.app.plugins.ExchangeLottery.ExchangeLotteryDef')
local Req = require('src.app.plugins.ExchangeLottery.ExchangeLotteryReq')
local user = mymodel('UserModel'):getInstance()
--local AssistConnect = require('src.app.plugins.AssistModel.AssistConnect'):getInstance()
local BroadcastModel = mymodel("hallext.BroadcastModel"):getInstance()

local treepack = cc.load('treepack')

local coms=cc.load('coms')
local PropertyBinder=coms.PropertyBinder
my.setmethods(ExchangeLotteryModel,PropertyBinder)

my.addInstance(ExchangeLotteryModel)

function ExchangeLotteryModel:onCreate()
    self._info = {}
    self._channelOpen = false
    self._activityOpen = false

    self:initAssistResponse()
end

function ExchangeLotteryModel:reset( )
    self._info = {}
    self._channelOpen = false
    self._activityOpen = false
end

function ExchangeLotteryModel:initAssistResponse()
    self._assistResponseMap = {
        [Def.GR_EXCHAGNE_LOTTERY_INFO_RESP] = handler(self, self.onExchangeLotteryInfo),
        [Def.GR_EXCHAGNE_LOTTERY_DRAW_RESP] = handler(self, self.onExhcangeLotteryDrawRet),
        [Def.GR_SYN_EXCHAGNE_LOTTERY_CONFIG] = handler(self, self.synExchangeLotteryConfig),
        [Def.GR_EXPRESSION_LETTORY_GAME] = handler(self, self.synSeizeCount)
    }
    AssistModel:registCtrl(self, self.dealAssistResponse)
end

function ExchangeLotteryModel:gc_GetExchangeLotteryInfo(bGameWin)
    self._info = {}
    if user.nUserID == nil or user.nUserID < 0 then
        print("userinfo is not ok")
        return
    end
    local userPlugin = plugin.AgentManager:getInstance():getUserPlugin()
    local sdkName = userPlugin:getUsingSDKName()
    sdkName = string.lower(sdkName)
    if sdkName == "tcy" then
        if(cc.exports.LaunchMode["PLATFORM"] == MCAgent:getInstance():getLaunchMode())then
            sdkName = "tcyapp"
        end
    end

    local nBout = user.nBout
    if bGameWin then
        nBout = nBout + 1
    end
    local data = {
        nUserID = user.nUserID,
        nBout   = nBout,
        nChannelID =  BusinessUtils:getInstance().getTcyChannel and tonumber(BusinessUtils:getInstance():getTcyChannel()) or 0
    }

    AssistModel:sendRequest(Def.GR_EXCHAGNE_LOTTERY_INFO_REQ, Req.EXCHANGE_LOTTERY_INFO_REQ, data, false)
end

function ExchangeLotteryModel:onExchangeLotteryInfo(data)
    local info = AssistModel:convertDataToStruct(data,Req["EXCHANGE_LOTTERY_INFO_RESP"]);

    if info.nUserID ~= user.nUserID then
        return
    end

    self._info = info

    if info.nStateCode ~= Def.EXCHANGE_LOTTERY_SUCCESS then
        --通知活动要隐藏
        local activityCenterModel = import('src.app.plugins.activitycenter.ActivityCenterModel'):getInstance()
        activityCenterModel:setMatrixActivityNeedShow(Def.EXCHANGE_LOTTERY_ID,false)
        return
    end

    --通知活动要显示
    local activityCenterModel = import("src.app.plugins.activitycenter.ActivityCenterModel"):getInstance()
    activityCenterModel:setMatrixActivityNeedShow(Def.EXCHANGE_LOTTERY_ID, true)

    self._activityOpen = true
    self:onBroadCast()
    self:updateRedDot()
    self:dispatchEvent({name = Def.ExchangeLotteryInfoRet})
end

function ExchangeLotteryModel:gc_ExchangeLotteryDrawReq(nDrawCount)
    if user.nUserID == nil or user.nUserID < 0 then
        print("userinfo is not ok")
    end

    local userPlugin = plugin.AgentManager:getInstance():getUserPlugin()
    local sdkName = userPlugin:getUsingSDKName()
    sdkName = string.lower(sdkName)
    if sdkName == "tcy" then
        if(cc.exports.LaunchMode["PLATFORM"] == MCAgent:getInstance():getLaunchMode())then
            sdkName = "tcyapp"
        end
    end

    local data = {
        nUserID = user.nUserID,
        nBout = user.nBout,
        szUserName = user.szUsername,
        nChannelID =  BusinessUtils:getInstance().getTcyChannel and tonumber(BusinessUtils:getInstance():getTcyChannel()) or 0,
        nDrawCount = nDrawCount
    }

    AssistModel:sendRequest(Def.GR_EXCHAGNE_LOTTERY_DRAW_REQ, Req.EXCHANGE_LOTTERY_DRAW_REQ, data, false)
end

function ExchangeLotteryModel:onExhcangeLotteryDrawRet(data)
    local result = AssistModel:convertDataToStruct(data,Req["EXCHANGE_LOTTERY_DRAW_RESP"]);

    if result.nUserID ~= user.nUserID then
        return
    end

    if result.nStateCode ~= Def.EXCHANGE_LOTTERY_SUCCESS then
        if result.nStateCode ==Def.EXCHANGE_LOTTERY_NO_DRAWCOUNT then
            --次数不同步，向服务器发请求同步信息
            self:gc_GetExchangeLotteryInfo()
        end
        local tipString = self:GetStringByStateCode(result.nStateCode)
        my.informPluginByName({pluginName='TipPlugin',params={tipString=tipString,removeTime=2}})
        self:dispatchEvent({name = Def.ExchangeLotteryDrawFailed})
        return
    end

    if self._info and next(self._info) ~= nil then
        if result.nUsedFirstFree == 1 then
            self._info.nFirstFree = 0
        else
            self._info.nCount = math.max(self._info.nCount - result.nDrawCount, 0)
        end
    end
    dump(result.nResultList)

    my.scheduleOnce(function()
        if result.nDrawCount>1 and self._info.nGiveCardMaker~=0 then --抽十次送一天记牌器
            local giveCardMakerDays, _ = math.modf(result.nDrawCount/10)
            cc.exports.CardMakerInfo.nCardMakerCountdown = cc.exports.CardMakerInfo.nCardMakerCountdown + giveCardMakerDays*24*60*60
            local CardRecorderModel = import("src.app.plugins.shop.cardrecorder.CardRecorderModel"):getInstance()
            CardRecorderModel:onCardRecorderInfoChanged()
            --AssistConnect:DealPayResultCardMakerInfo()
        end
        local playerModel = mymodel("hallext.PlayerModel"):getInstance()
        local ExchangeCenterModel = require("src.app.plugins.ExchangeCenter.ExchangeCenterModel"):getInstance()

        local nSilver = 0
        local nTicket = 0
        for i =1,result.nResultList.nNum do
            local award = result.nResultList.stReward[i]
            if award.nType == Def.REWARD_TYPE_SILVER then
                nSilver = nSilver + award.nCount
            elseif award.nType == Def.REWARD_TYPE_TICKET then
                nTicket = nTicket + award.nCount
            elseif award.nType == Def.REWARD_TYPE_CARDMARKER_1D then
                cc.exports.CardMakerInfo.nCardMakerCountdown = cc.exports.CardMakerInfo.nCardMakerCountdown + 24*60*60
                local CardRecorderModel = import("src.app.plugins.shop.cardrecorder.CardRecorderModel"):getInstance()
                CardRecorderModel:onCardRecorderInfoChanged()
                --AssistConnect:DealPayResultCardMakerInfo()
            elseif award.nType == Def.REWARD_TYPE_CARDMARKER_7D then
                cc.exports.CardMakerInfo.nCardMakerCountdown = cc.exports.CardMakerInfo.nCardMakerCountdown + 7*24*60*60
                local CardRecorderModel = import("src.app.plugins.shop.cardrecorder.CardRecorderModel"):getInstance()
                CardRecorderModel:onCardRecorderInfoChanged()
               -- AssistConnect:DealPayResultCardMakerInfo()
            elseif award.nType == Def.REWARD_TYPE_CARDMARKER_30D then
                cc.exports.CardMakerInfo.nCardMakerCountdown = cc.exports.CardMakerInfo.nCardMakerCountdown + 30*24*60*60
                local CardRecorderModel = import("src.app.plugins.shop.cardrecorder.CardRecorderModel"):getInstance()
                CardRecorderModel:onCardRecorderInfoChanged()
                --AssistConnect:DealPayResultCardMakerInfo()
            end
        end
        if nSilver>0 then
            playerModel:update({'SafeboxInfo','MemberInfo','UserGameInfo'})
        end
        if nTicket>0 then
            ExchangeCenterModel:getTicketNum()
        end
    end,4)

    self:updateRedDot()
    if result.nResultList.nNum>1 and self._info.nGiveCardMaker~=0 then
        local rewardList = {}
        local giveCardMakerDays, _ = math.modf(result.nDrawCount/10)
        table.insert( rewardList,{nType = 3,nCount = giveCardMakerDays})
        my.informPluginByName({pluginName = 'RewardTipCtrl', params = {data = rewardList,showOkOnly = true,callback = function()
            self:dispatchEvent({name = Def.ExchangeLotteryDrawRet,value = {resultList = result.nResultList}})
        end}})
    else
        self:dispatchEvent({name = Def.ExchangeLotteryDrawRet,value = {resultList = result.nResultList}})
    end
end

function ExchangeLotteryModel:synExchangeLotteryConfig(data)
    -- local result = AssistModel:convertDataToStruct(data,Req["EXCHANGE_LOTTERY_CONFIG_CHANGE"]);

    -- if self._info and next(self._info) ~= nil then
    --     self._info.nGiveCardMaker = result.nGiveCardMaker
    --     self._info.nBoutLimit = result.nBoutLimit
    --     if result.nFirstFree == 0 then
    --         self._info.nFirstFree = result.nFirstFree
    --     end
    --     --self._info.nFirstFree = result.nFirstFree--这个不能通过配置设置
    --     self._info.stRewardList = result.stRewardList
    -- end

    -- self:updateRedDot()
    -- self:dispatchEvent({name = Def.ExchangeLotteryConfigChange})

    self:gc_GetExchangeLotteryInfo()
end

function ExchangeLotteryModel:synSeizeCount(data)
    local expressionLottery = AssistModel:convertDataToStruct(data,Req["GAME_EXPRESSION_LOTTERY"]);

    if self._info and next(self._info) ~= nil then
        self._info.nCount = expressionLottery.nSeizeCount
    end
    
    self:updateRedDot()
    self:dispatchEvent({name = Def.ExchangeLotterySynSeizeCount})
end

function ExchangeLotteryModel:addSeizeCount(count)
    if self._info and next(self._info) ~= nil then
        self._info.nCount = self._info.nCount + count
    end
    
    self:updateRedDot()
    self:dispatchEvent({name = Def.ExchangeLotterySynSeizeCount})
end

function ExchangeLotteryModel:GetExchangeLotteryInfo()
    if self._info and next(self._info) ~= nil then
        return self._info
    end
    return nil
end

function ExchangeLotteryModel:updateRedDot()
    self:dispatchEvent({name = Def.ExchangeLotteryUpdateRedDot})
end

function ExchangeLotteryModel:NeedShowRedDot()
    if self._info and next(self._info) ~= nil then
        local nSeizeCount = self._info.nCount
        local nFirstFree = self._info.nFirstFree
        if nSeizeCount>0 or nFirstFree == 1 then
            return true
        end
    end
    return false
end

function ExchangeLotteryModel:GetStringByStateCode(nStateCode)
    local tipString = Def.ErrorString1
    if nStateCode == Def.EXCHANGE_LOTTERY_FAILED then
        tipString = Def.ErrorString1
    elseif nStateCode == Def.EXCHANGE_LOTTERY_HAS_END then
        tipString = Def.ErrorString2
    elseif nStateCode == Def.EXCHANGE_LOTTERY_NOT_REACH_BOUT then
        tipString = Def.ErrorString3
    elseif nStateCode == Def.EXCHANGE_LOTTERY_REDIS_ERROR then
        tipString = Def.ErrorString4
    elseif nStateCode == Def.EXCHANGE_LOTTERY_NO_DRAWCOUNT then
        tipString = Def.ErrorString5
    end
    return tipString
end

function ExchangeLotteryModel:SetChannelOpen(isOpen)
    self._channelOpen = isOpen
end

function ExchangeLotteryModel:GetChannelOpen()
    return self._channelOpen
end

function ExchangeLotteryModel:SetActivityOpen(isOpen)
    self._activityOpen = isOpen
end

function ExchangeLotteryModel:GetActivityOpen()
    return self._activityOpen
end

function ExchangeLotteryModel:GetBoutLimit()
    if self._info and next(self._info) ~= nil then
        return self._info.nBoutLimit
    end
    return nil
end

function ExchangeLotteryModel:onBroadCast()
    local myGameData = my.readCache("MyGameData".. user.nUserID ..".xml")

    if not myGameData.ExchangeLottery then
        myGameData.ExchangeLottery = true
        my.saveCache("MyGameData"..user.nUserID..".xml", myGameData)
        local data={
            MessageInfo = {
                enMsgType = 0,
                szMsg = Def.Broadcast,
                nReserved = {0,0,0,0}
            },
            nDelaySec = -1,
            nInterval = 0,
            nRepeatTimes = 1,
            nRoadID = 0,
            nReserved = {0,0,0,0}
        }
    
        BroadcastModel:insertBroadcastMsg(data)
    end
end
return ExchangeLotteryModel