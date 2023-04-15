local PropModel = class('PropModel', require('src.app.GameHall.models.BaseModel'))
my.addInstance(PropModel)

local PropReq = import('src.app.plugins.shop.prop.PropReq')
local AssistModel = mymodel('assist.AssistModel'):getInstance()
local PublicInterface = cc.exports.PUBLIC_INTERFACE
local treepack = cc.load('treepack')

local arenaRankData = require("src.app.plugins.ArenaRank.ArenaRankData"):getInstance()
local RewardTipDef      = import("src.app.plugins.RewardTip.RewardTipDef")
local Player            = mymodel('hallext.PlayerModel'):getInstance()

local PublicInterFace = cc.exports.PUBLIC_INTERFACE

local PropDef = {
    GR_GET_USER_PROP = 404120, --获取道具数据
    GR_USE_USER_PROP = 404121, --消耗道具
    GR_BUY_USER_PROP = 404122, --购买道具数据
    GR_BUY_USER_PROP_FAIL = 404123, --购买道具失败
    GR_EXPRESSION_PROP_GAME  = 410210, --使用表情 or 购买表情
}

PropModel.EVENT_MAP = {
}

function PropModel:onCreate()
    self._assistResponseMap = {
        [PropDef.GR_GET_USER_PROP] = handler(self, self.onGetUserProp),
        [PropDef.GR_BUY_USER_PROP_FAIL] = handler(self, self.onBuyUserPropFail),
        [PropDef.GR_BUY_USER_PROP] = handler(self, self.onBuyUserPropOk),
        [PropDef.GR_USE_USER_PROP] = handler(self, self.onGetUserProp)
    }
    AssistModel:registCtrl(self, self.dealAssistResponse)
end

--道具相关
function PropModel:sendGetUserPropInfo()
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

    local GET_INFO_WITH_USERID = PropReq["GET_INFO_WITH_USERID"]
    local data     = {
        nUserID = playerInfo.nUserID
    }
    local pData = treepack.alignpack(data, GET_INFO_WITH_USERID)
    AssistModel:sendData(PropDef.GR_GET_USER_PROP, pData)
end

function PropModel:sendBuyUserProp(propID, propNum)
    local playerInfo = PublicInterFace:GetPlayerInfo()
    if playerInfo == nil then
        return 
    end 

    if playerInfo.nUserID == nil then
        return
    end

    if playerInfo.nUserID <=0 then 
        return 
    end
    local nPlatform = 0
    if device.platform == "ios" and cc.exports.LaunchMode["PLATFORM"] ~= MCAgent:getInstance():getLaunchMode() then
        nPlatform = 1
    end

    if not cc.exports.isSafeBoxSupported() then
        nPlatform = 2 -- 2代表扣携银
    end

    --local ExchangeLotteryModel = require('src.app.plugins.ExchangeLottery.ExchangeLotteryModel'):getInstance()
    local nOpen = 0
    if cc.exports.isExchangeLotterySupported() then
        nOpen = 1
    end
    --预留接口
    local PARAM_PROP_INFO = PropReq["PARAM_PROP_INFO"]
    local data     = {
        nUserID = playerInfo.nUserID,
        nPropID = propID,
        nPropNum = propNum or 1,
        nOSType = nPlatform,
        kpiClientData = AssistModel:getKPIClientData(),
        nOpen = nOpen
    }
    local pData = treepack.alignpack(data, PARAM_PROP_INFO)
    AssistModel:sendData(PropDef.GR_BUY_USER_PROP, pData)
end

function PropModel:updatePropByReq(rewardList)
    if type(rewardList) ~= 'table' then
        return
    end
    local bHasProp = false
    for _, v in pairs(rewardList) do
        local t = v.nType
        if t == RewardTipDef.TYPE_ROSE or t == RewardTipDef.TYPE_LIGHTING or t == RewardTipDef.TYPE_PROP_LIANSHENG or t == RewardTipDef.TYPE_PROP_BAOXIAN then
            bHasProp = true
            break
        end
    end
    if bHasProp then
        self:sendGetUserPropInfo()
    end
end

function PropModel:onGetUserProp(data)
    local userPropInfo = PropReq["USER_PROP_INFO"]
    local userPropData = treepack.unpack(data, userPropInfo)

    arenaRankData:onGetUserPropOK(userPropData)
end

function PropModel:onBuyUserPropFail(data)
    local BUY_PROP_INFO_FAIL = PropReq["BUY_PROP_INFO_FAIL"]
    local buyFail = treepack.unpack(data, BUY_PROP_INFO_FAIL)

    buyFail.failMsg = MCCharset:getInstance():gb2Utf8String(buyFail.failMsg, string.len(buyFail.failMsg))
    print("PropModel:onBuyUserPropFail", buyFail.failMsg)

    my.informPluginByName({ pluginName = 'TipPlugin', params = { tipString = buyFail.failMsg, removeTime = 2 }})
end

function PropModel:onBuyUserPropOk(data)
    local userPropInfo = PropReq["USER_PROP_INFO"]
    local userPropData = treepack.unpack(data, userPropInfo)

    arenaRankData:onBuyUserPropOk(userPropData)

    if tonumber(userPropData.nPropIDCurrent) == 6 then --闪电10，特殊处理成10个闪电
        for i=1, #userPropData.nPropID do 
            if tonumber(userPropData.nPropID[i]) == 5 then  --闪电
                cc.exports.ExpressionInfo.nLightingNum = userPropData.nPropNum[i]
                -- Player:addGameDeposit(-27000)

                local rewardList = {}
                table.insert( rewardList,{nType = RewardTipDef.TYPE_LIGHTING, nCount = 10})
                my.informPluginByName({pluginName = 'RewardTipCtrl', params = {data = rewardList,paySuccess = true}})
                break
            end
        end
    elseif tonumber(userPropData.nPropIDCurrent) == 8 then --闪电100，特殊处理成100个闪电
        for i=1, #userPropData.nPropID do 
            if tonumber(userPropData.nPropID[i]) == 5 then  --闪电
                cc.exports.ExpressionInfo.nLightingNum = userPropData.nPropNum[i]
                -- Player:addGameDeposit(-270000)

                local rewardList = {}
                table.insert( rewardList,{nType = RewardTipDef.TYPE_LIGHTING, nCount = 100})
                my.informPluginByName({pluginName = 'RewardTipCtrl', params = {data = rewardList,paySuccess = true}})
                break
            end
        end
    elseif tonumber(userPropData.nPropIDCurrent) == 10 then --定时赛门票
        local count = 0
        for i=1, #userPropData.nPropID do 
            if tonumber(userPropData.nPropID[i]) == 10 then  --定时赛门票
                count = count + tonumber(userPropData.nPropNum[i])
            end
        end
        if count > 0 then
            local rewardList = {}
            table.insert( rewardList,{nType = RewardTipDef.TYPE_REWARDTYPE_TIMINGGAME_TICKET, nCount = count})
            my.informPluginByName({pluginName = 'RewardTipCtrl', params = {data = rewardList,paySuccess = true}})
            local TimingGameModel = import('src.app.plugins.TimingGame.TimingGameModel'):getInstance()
            TimingGameModel:reqTimingGameInfoData()
        end
    else
        for i=1, #userPropData.nPropID do
            local sliver = 0
            local nPropID = tonumber(userPropData.nPropID[i])
            local nPropIDCurrent = tonumber(userPropData.nPropIDCurrent)

            local propIDs = {4,5,6,7}
            local propCount = {cc.exports.CardMakerInfo.nCardMakerNum, cc.exports.ExpressionInfo.nLightingNum, cc.exports.ExpressionInfo.nLightingNum10, cc.exports.ExpressionInfo.nRoseNum}
            local propSilver = {-500, -3000, -27000, -1000}
            local propType = {RewardTipDef.TYPE_CARDMARKER, RewardTipDef.TYPE_LIGHTING, RewardTipDef.TYPE_LIGHTING, RewardTipDef.TYPE_ROSE}
            
            local isFind = false
            for j=1, #propIDs do
                if nPropID == propIDs[j] and nPropIDCurrent == propIDs[j] then
                    local num = propCount[j] or 0
                    propCount[j] = userPropData.nPropNum[i]

                    if j == 1 then
                        cc.exports.CardMakerInfo.nCardMakerNum = propCount[j]
                    elseif j == 2 then
                        cc.exports.ExpressionInfo.nLightingNum = propCount[j]
                    elseif j == 3 then
                        cc.exports.ExpressionInfo.nLightingNum10 = propCount[j]
                    elseif j == 4 then
                        cc.exports.ExpressionInfo.nRoseNum = propCount[j]
                    end

                    local sliver = ( propCount[j] - num) * propSilver[j]
                    if sliver < 0 then
                        local rewardList = {}
                        table.insert( rewardList,{nType = propType[j], nCount = propCount[j] - num})
                        my.informPluginByName({pluginName = 'RewardTipCtrl', params = {data = rewardList,paySuccess = true}})
                        -- Player:addGameDeposit(sliver)
                    end

                    isFind = true
                    break
                end
            end

            if isFind then
                break
            end
            --[[
            if nPropID == 4 and nPropIDCurrent == 4 then  --记牌器
                local num = cc.exports.CardMakerInfo.nCardMakerNum or 0
                cc.exports.CardMakerInfo.nCardMakerNum = userPropData.nPropNum[i]

                sliver = (cc.exports.CardMakerInfo.nCardMakerNum - num) *(-500)
                if sliver < 0 then
                    local rewardList = {}
                    table.insert( rewardList,{nType = RewardTipDef.TYPE_CARDMARKER, nCount = cc.exports.CardMakerInfo.nCardMakerNum - num})
                    my.informPluginByName({pluginName = 'RewardTipCtrl', params = {data = rewardList,paySuccess = true}})
                end
            elseif nPropID == 5 and nPropIDCurrent == 5 then --闪电
                local num = cc.exports.ExpressionInfo.nLightingNum or 0
                cc.exports.ExpressionInfo.nLightingNum = userPropData.nPropNum[i]

                sliver = (cc.exports.ExpressionInfo.nLightingNum - num) *(-3000)
                if sliver < 0 then
                    local rewardList = {}
                    table.insert( rewardList,{nType = RewardTipDef.TYPE_LIGHTING, nCount = cc.exports.ExpressionInfo.nLightingNum - num})
                    my.informPluginByName({pluginName = 'RewardTipCtrl', params = {data = rewardList,paySuccess = true}})
                end
            elseif nPropID == 6 and nPropIDCurrent == 6 then --闪电10
                cc.exports.ExpressionInfo.nLightingNum10 = userPropData.nPropNum[i]

                sliver = -27000
            elseif nPropID == 7 and nPropIDCurrent == 7 then --玫瑰
                local num = cc.exports.ExpressionInfo.nRoseNum or 0
                cc.exports.ExpressionInfo.nRoseNum = userPropData.nPropNum[i]

                sliver = (cc.exports.ExpressionInfo.nRoseNum - num) *(-1000)
                if sliver < 0 then
                    local rewardList = {}
                    table.insert( rewardList,{nType = RewardTipDef.TYPE_ROSE, nCount = cc.exports.ExpressionInfo.nRoseNum - num})
                    my.informPluginByName({pluginName = 'RewardTipCtrl', params = {data = rewardList,paySuccess = true}})
                end
            end

            if sliver ~= 0 then
                Player:addGameDeposit(sliver)
                break
            end
            --]]
        end
    end
end

function PropModel:onBuyExpression(data)
    local GAME_EXPRESSION_PROP = PropReq["GAME_EXPRESSION_PROP"]

    local pData = treepack.alignpack(data, GAME_EXPRESSION_PROP)
    AssistModel:sendData(PropDef.GR_EXPRESSION_PROP_GAME, pData)
end

function PropModel:DealExpression(data)
    local GAME_EXPRESSION_PROP = PropReq["GAME_EXPRESSION_PROP"]
    local expressionThrow = treepack.unpack(data, GAME_EXPRESSION_PROP)
    dump(expressionThrow)
    return expressionThrow
end
function PropModel:updateRoseNum(count)
    local nCurrentCount = count or 0
    cc.exports.ExpressionInfo.nRoseNum = nCurrentCount
end

function PropModel:updateLightingNum(count)
    local nCurrentCount = count or 0
    cc.exports.ExpressionInfo.nLightingNum = nCurrentCount
end

return PropModel