local RewardTipDef = {
    TYPE_SILVER = 1,
    TYPE_TICKET = 2,
    TYPE_CARDMARKER_1D = 3,
    TYPE_CARDMARKER_7D = 4,
    TYPE_CARDMARKER_30D = 5,
    TYPE_ROSE = 6,
    TYPE_LIGHTING = 7,
    TYPE_CARDMARKER = 8,
    TYPE_PROP_LIANSHENG = 9,
    TYPE_PROP_JIACHENG = 10,
    TYPE_PROP_BAOXIAN =11,
    TYPE_RED_PACKET = 12,
    TYPE_RED_PACKET_VOCHER = 13,
    TYPE_REWARDTYPE_LOTTERY_TIME  = 14,
    TYPE_REWARDTYPE_LUCKY_CAT  = 15,
    TYPE_REWARDTYPE_NOBILITY_EXP  = 16,
    TYPE_REWARDTYPE_TIMINGGAME_TICKET  = 17,
    TYPE_PHONE  = 18,

    getItemImgPath = function (self, nType, nCount)
        local Def = self
        local dir = "hallcocosstudio/images/plist/RewardCtrl/"
        local path = nil

        if nType == Def.TYPE_SILVER then --银子
            if nCount>=10000 then 
                path = dir .. "Img_Silver4.png"
            elseif nCount>=5000 then
                path = dir .. "Img_Silver3.png"
            elseif nCount>=1000 then
                path = dir .. "Img_Silver2.png"
            else
                path = dir .. "Img_Silver1.png"
            end
        elseif nType == Def.TYPE_TICKET then --礼券
            if nCount>=100 then 
                path = dir .. "Img_Ticket4.png"
            elseif nCount>=50 then
                path = dir .. "Img_Ticket3.png"
            elseif nCount>=20 then
                path = dir .. "Img_Ticket2.png"
            else
                path = dir .. "Img_Ticket1.png"
            end
        elseif nType == Def.TYPE_CARDMARKER_1D then --1d记牌器
            path = dir .. "1tian.png"
        elseif nType == Def.TYPE_CARDMARKER_7D then --7d记牌器
            path = dir .. "7tian.png"
        elseif nType == Def.TYPE_CARDMARKER_30D then --30d记牌器
            path = dir .. "30tian.png"
        elseif nType == Def.TYPE_ROSE then --玫瑰
            path = dir .. "Img_Rose.png"
        elseif nType == Def.TYPE_LIGHTING then --闪电
            path = dir .. "Img_Lighting.png"
        elseif nType == Def.TYPE_CARDMARKER then
            path = dir .. "Img_CardMarker.png"
        elseif nType == Def.TYPE_PROP_LIANSHENG then
            path = dir .. "Img_Prop_Liansheng.png"
        elseif nType == Def.TYPE_PROP_JIACHENG then
            path = dir .. "Img_Prop_Jiacheng.png"
        elseif nType == Def.TYPE_PROP_BAOXIAN then
            path = dir .. "Img_Prop_Baoxian.png"
        elseif nType == Def.TYPE_RED_PACKET then --红包
            path = dir .. "Img_RedPacket_100.png"
        elseif nType == Def.TYPE_RED_PACKET_VOCHER then --红包礼券
            path = dir .. "Img_RedPacket_Vocher.png"
        elseif nType == Def.TYPE_REWARDTYPE_LOTTERY_TIME then --惊喜夺宝
            path = dir .. "Img_RewardType_Lottery.png"
        elseif nType == Def.TYPE_REWARDTYPE_NOBILITY_EXP then --贵族经验
            path = dir .. "Img_Prop_Jiacheng.png"
        elseif nType == Def.TYPE_REWARDTYPE_TIMINGGAME_TICKET then --定时赛门票
            path = dir .. "Img_TimingTicket1.png"
        elseif nType == Def.TYPE_PHONE then --话费
            path = dir .. "Img_Phone.png"
        end
        return path
    end,

    getItemName = function (self, nType, nCount)
        local Def = self
        local str = ""
        if nType == Def.TYPE_SILVER then --银子
            str = string.format("%d两银子", nCount)
        elseif nType == Def.TYPE_TICKET then --礼券
            str = string.format("礼券*%d", nCount)
        elseif nType == Def.TYPE_CARDMARKER_1D then --1d记牌器
            str = string.format("1天记牌器*%d", nCount)
        elseif nType == Def.TYPE_CARDMARKER_7D then --7d记牌器
            str = string.format("7天记牌器*%d", nCount)
        elseif nType == Def.TYPE_CARDMARKER_30D then --30d记牌器
            str = string.format("30天记牌器*%d", nCount)
        elseif nType == Def.TYPE_ROSE then --玫瑰
            str = string.format("玫瑰*%d", nCount)
        elseif nType == Def.TYPE_LIGHTING then --闪电
            str = string.format("闪电*%d", nCount)
        elseif nType == Def.TYPE_CARDMARKER then
            str = string.format("1局记牌器*%d", nCount)
        elseif nType == Def.TYPE_PROP_LIANSHENG then
            str = string.format("连胜符*%d", nCount)
        elseif nType == Def.TYPE_PROP_JIACHENG then
            str = string.format("胜利加成*%d", nCount)
        elseif nType == Def.TYPE_PROP_BAOXIAN then
            str = string.format("抢分保险*%d", nCount)
        elseif nType == Def.TYPE_RED_PACKET then --红包
            str = string.format("红包*%d", nCount)
        elseif nType == Def.TYPE_RED_PACKET_VOCHER then --红包礼券
            str = string.format("红包礼券*%d", nCount)
        elseif nType == Def.TYPE_REWARDTYPE_LOTTERY_TIME then --惊喜夺宝
            str = string.format("惊喜夺宝*%d", nCount)
        elseif nType == Def.TYPE_REWARDTYPE_NOBILITY_EXP then --贵族经验
            str = string.format("贵族经验*%d", nCount)
        elseif nType == Def.TYPE_REWARDTYPE_TIMINGGAME_TICKET then --定时赛门票
            str = string.format("定时赛门票*%d", nCount)
        elseif nType == Def.TYPE_PHONE then --话费
            str = string.format("话费*%d", nCount)
        end
        return str
    end,

    getItemShortName = function (self, nType, nCount)
        local Def = self
        local str = ""
        if nType == Def.TYPE_SILVER then --银子
            str = string.format("银子*%d", nCount)
        elseif nType == Def.TYPE_TICKET then --礼券
            str = string.format("礼券*%d", nCount)
        elseif nType == Def.TYPE_CARDMARKER_1D then --1d记牌器
            str = string.format("记牌器*%d", nCount)
        elseif nType == Def.TYPE_CARDMARKER_7D then --7d记牌器
            str = string.format("记牌器*%d", nCount)
        elseif nType == Def.TYPE_CARDMARKER_30D then --30d记牌器
            str = string.format("记牌器*%d", nCount)
        elseif nType == Def.TYPE_ROSE then --玫瑰
            str = string.format("玫瑰*%d", nCount)
        elseif nType == Def.TYPE_LIGHTING then --闪电
            str = string.format("闪电*%d", nCount)
        elseif nType == Def.TYPE_CARDMARKER then
            str = string.format("记牌器*%d", nCount)
        elseif nType == Def.TYPE_PROP_LIANSHENG then
            str = string.format("连胜符*%d", nCount)
        elseif nType == Def.TYPE_PROP_JIACHENG then
            str = string.format("胜利加成*%d", nCount)
        elseif nType == Def.TYPE_PROP_BAOXIAN then
            str = string.format("抢分保险*%d", nCount)
        elseif nType == Def.TYPE_RED_PACKET then --红包
            str = string.format("红包*%d", nCount)
        elseif nType == Def.TYPE_RED_PACKET_VOCHER then --红包礼券
            str = string.format("红包礼券*%d", nCount)
        elseif nType == Def.TYPE_REWARDTYPE_LOTTERY_TIME then --惊喜夺宝
            str = string.format("惊喜夺宝*%d", nCount)
        elseif nType == Def.TYPE_REWARDTYPE_NOBILITY_EXP then --贵族经验
            str = string.format("经验*%d", nCount)
        elseif nType == Def.TYPE_REWARDTYPE_TIMINGGAME_TICKET then --定时赛门票
            str = string.format("门票*%d", nCount)
        elseif nType == Def.TYPE_PHONE then --话费
            str = string.format("话费*%d", nCount)
        end
        return str
    end
}



return RewardTipDef