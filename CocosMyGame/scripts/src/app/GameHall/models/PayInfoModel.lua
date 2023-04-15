local PayInfoModel = class("PayInfoModel")


function PayInfoModel:ctor()
    self._BuyType  = 0     --购买类型
    self._BuyID  = 0       --购买ID
    self._BuyPartNum  = 0   --购买部分
    self._GivePartNum  = 0  --赠送部分
end

function PayInfoModel:getInstance()
    PayInfoModel._instance = PayInfoModel._instance or PayInfoModel:create()
    return PayInfoModel._instance
end

function PayInfoModel:setInfo(infoTab)
    print("PayInfoModel:setInfo")
    dump(infoTab)
    local buyType = tonumber(infoTab.buyType)
    local buyID = tonumber(infoTab.buyID)

    if buyType and buyID then
        self._BuyType  = buyType     --购买类型
        self._BuyID  = buyID       --购买ID
    else
        print("PayInfoModel:setInfo error")
        return
    end

    local buynum = tonumber(infoTab.buyNum) or 0
    local givenum = tonumber(infoTab.giveNum) or 0

    self._BuyPartNum  = buynum   --购买部分
    self._GivePartNum  = givenum  --赠送部分
    print(self._BuyPartNum, self._BuyPartNum)
end

function PayInfoModel:getInfo()
    local infoTab = {}
    infoTab.buyType = self._BuyType
    infoTab.buyID = self._BuyID
    infoTab.buyNum = self._BuyPartNum
    infoTab.giveNum = self._GivePartNum

    return infoTab
end

cc.exports.PayInfoType = {
    PAY_INFO_TYPE_SILVER = 1,           --购买银子
    PAY_INFO_TYPE_CARD_MAKER = 2,       --记牌器
    PAY_INFO_TYPE_EXPRESSION = 3,       --表情
    PAY_INFO_TYPE_TIMING_TICKET = 4,    --定时赛门票
}

cc.exports.PayInfoModel = {
    setPayInfo                   = function(infoTab)
		return PayInfoModel:getInstance():setInfo(infoTab)
    end,
    getPayInfo                   = function()
		return PayInfoModel:getInstance():getInfo()
    end,
}
       
return PayInfoModel