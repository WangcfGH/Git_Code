local CardRecorderModel = class('CardRecorderModel', require('src.app.GameHall.models.BaseModel'))
my.addInstance(CardRecorderModel)

local CardRecorderReq = import('src.app.plugins.shop.cardrecorder.CardRecorderReq')
local AssistModel = mymodel('assist.AssistModel'):getInstance()
local PublicInterface = cc.exports.PUBLIC_INTERFACE
local treepack = cc.load('treepack')

local CardRecorderDef = {
    GR_QUERY_CARDMARKER_INFO_REQ = 410202, -- 查询记牌器信息
    GR_QUERY_CARDMARKER_INFO_RESP = 410203, -- 回包
}

CardRecorderModel.EVENT_MAP = {
}

CardRecorderModel.CARD_MAKER_UPDATE = "CARD_MAKER_UPDATE"

function CardRecorderModel:onCreate()
    self._assistResponseMap = {
        [CardRecorderDef.GR_QUERY_CARDMARKER_INFO_RESP] = handler(self, self.dealCardMakerInfoResp)
    }
    AssistModel:registCtrl(self, self.dealAssistResponse)
end

function CardRecorderModel:sendGetCardMakerInfo() --记牌器情况
    local SCORE_INFO_FOR_PLAYER_REQ = CardRecorderReq["SCORE_INFO_FOR_PLAYER_REQ"]
    local data      = {
        nUserID     = PublicInterface.GetPlayerInfo().nUserID
    }

    local pData = treepack.alignpack(data, SCORE_INFO_FOR_PLAYER_REQ)
    AssistModel:sendData(CardRecorderDef.GR_QUERY_CARDMARKER_INFO_REQ, pData)
end

function CardRecorderModel:dealCardMakerInfoResp(data)
    printf('deal dealCardMakerInfoResp resp')
    local QUERY_CARDMARKERINFO_RESP = CardRecorderReq["QUERY_CARDMARKERINFO_RESP"]
    local resultInfo = treepack.unpack(data, QUERY_CARDMARKERINFO_RESP)

    cc.exports.CardMakerInfo.nUserID = resultInfo.nUserId
    cc.exports.CardMakerInfo.nCardMakerNum = resultInfo.nCardMakerNum
    cc.exports.CardMakerInfo.nCardMakerCountdown = tonumber(resultInfo.nLastSeconds)

    cc.exports.ExpressionInfo.nLightingNum   = resultInfo.nLightingNum
    cc.exports.ExpressionInfo.nLightingNum10 = resultInfo.nLightingNum10
    cc.exports.ExpressionInfo.nRoseNum       = resultInfo.nRoseNum
    self:onCardRecorderInfoChanged()
end

function CardRecorderModel:onCardRecorderInfoChanged()
    if cc.exports.CardMakerInfo.nCardMakerCountdown > 0 then
        if not self._CardMakerTimer then
            self._CardMakerTimer = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, self.updateCardMakerTime),1,false)
        end
    end
    self:dispatchEvent({name = CardRecorderModel.CARD_MAKER_UPDATE})
end

function CardRecorderModel:updateCardMakerTime(delta)
    if cc.exports.CardMakerInfo.nCardMakerCountdown >= 0 then
        cc.exports.CardMakerInfo.nCardMakerCountdown = cc.exports.CardMakerInfo.nCardMakerCountdown - 1
    else
        if self._CardMakerTimer then
            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self._CardMakerTimer)
            self._CardMakerTimer = nil
        end
    end
end

function CardRecorderModel:updateByReq(rewardList)
    if type(rewardList) ~= 'table' then
        return
    end
    local RewardTipDef = import("src.app.plugins.RewardTip.RewardTipDef")
    local bHasCardMaker = false
    for _, v in pairs(rewardList) do
        local t = v.nType 
        if t == RewardTipDef.TYPE_CARDMARKER_1D or t ==  RewardTipDef.TYPE_CARDMARKER_7D or t == RewardTipDef.TYPE_CARDMARKER_30D or 
            t == RewardTipDef.TYPE_CARDMARKER then
                bHasCardMaker = true
                break
        end
    end
    if bHasCardMaker then
        self:sendGetCardMakerInfo()
    end
end

return CardRecorderModel