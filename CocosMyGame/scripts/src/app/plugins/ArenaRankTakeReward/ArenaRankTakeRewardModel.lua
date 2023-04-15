local ArenaRankTakeRewardModel = class("ArenaRankTakeRewardModel")
local User = mymodel('UserModel'):getInstance()
local ExchangeCenterModel = require("src.app.plugins.ExchangeCenter.ExchangeCenterModel"):getInstance()
local Player            = mymodel('hallext.PlayerModel'):getInstance()
--local MyMsgBox = require("src.app.Common.MyMsgBox.MyMsgBox"):getInstance()

my.addInstance(ArenaRankTakeRewardModel)

local event = cc.load('event')
event:create():bind(ArenaRankTakeRewardModel)

ArenaRankTakeRewardModel.TAKE_REWARD_OK = "TAKE_REWARD_OK"
ArenaRankTakeRewardModel.TAKE_REWARD_UPDATE_RICH = "TAKE_REWARD_UPDATE_RICH"

ArenaRankTakeRewardModel.STATUS_SUCCESSED = "STATUS_SUCCESSED"
ArenaRankTakeRewardModel.STATUS_ERROR = "STATUS_ERROR"

--ͬArenaRank.json, prizeID
ArenaRankTakeRewardModel.TYPE_SILVER = 1
ArenaRankTakeRewardModel.TYPE_EXCHANGE = 2
ArenaRankTakeRewardModel.TYPE_CARDMASTER = 3

function ArenaRankTakeRewardModel:ctor()
    self:resetData()
end

function ArenaRankTakeRewardModel:resetData()
    self._data = {
        ["status"] = nil,
        ["rank"] = nil,
        ["score"] = nil,
        ["reward"] = nil
    }

    self._userID = nil
end

function ArenaRankTakeRewardModel:onGetDataOK(data)
    self._userID = data.nUserID       

    self._data["rank"] = data.nRank
    self._data["score"] = data.nScore
    self._data["reward"] = {}
    for i, prizeItem in ipairs(data.stReward) do
        local item = {}
        item["prizeID"] = prizeItem.nPrizeID
        item["count"] = prizeItem.nNum
        table.insert(self._data["reward"], item)
    end

    if data.nState == 1 then
        self._data["status"] = ArenaRankTakeRewardModel.STATUS_SUCCESSED
        self:dealWithResult()
    else
        self._data["status"] = ArenaRankTakeRewardModel.STATUS_ERROR
    end 

    dump(data)
    self:dispatchEvent({name = ArenaRankTakeRewardModel.TAKE_REWARD_OK})
end

function ArenaRankTakeRewardModel:dealWithResult()
    local prizeList = self:getReward()
    for i, prize in ipairs(prizeList) do
        if prize.prizeID == ArenaRankTakeRewardModel.TYPE_SILVER then
            Player:update({'UserGameInfo'})
            --User.nDeposit = User.nDeposit + prize.count 
            --self:dispatchEvent({name = ArenaRankTakeRewardModel.TAKE_REWARD_UPDATE_RICH})    
        elseif prize.prizeID == ArenaRankTakeRewardModel.TYPE_EXCHANGE then
            ExchangeCenterModel:addTicketNum(prize.count)
        --[[elseif prize.prizeID == ArenaRankTakeRewardModel.TYPE_CARDMASTER then
            local price = cc.exports.GetCardMasterPriceByDays(prize.count)
            cc.exports.SaveLastBuyToolItem("CardMaster", price, true, prize.count)
            --MyMsgBox:newMsgInMyToolBox()]]
        end
    end
end

function ArenaRankTakeRewardModel:isDataAvailable()
    if self._userID
        and self._userID == User.nUserID 
        and self._data["status"]
        and self._data["rank"] 
        and self._data["score"] 
        and self._data["reward"]  then
        return true
    end

    return false
end

function ArenaRankTakeRewardModel:getRank()
    return self._data["rank"]
end

function ArenaRankTakeRewardModel:getScore()
    return self._data["score"]
end

function ArenaRankTakeRewardModel:getReward()
    return self._data["reward"]
end

function ArenaRankTakeRewardModel:getStatus()
    return self._data["status"]
end

return ArenaRankTakeRewardModel