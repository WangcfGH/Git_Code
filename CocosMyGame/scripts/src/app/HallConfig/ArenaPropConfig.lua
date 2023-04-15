local ArenaPropConfig = {
    ["BuyPropSuccess"] = "购买成功",
    ["ArenaPropList"] = {
        {
            ["nType"] = 1,
            ["price"] = 500,
            ["title"] = "胜利加成",
            ["desc"] = "胜利得分加10%"
        },
        {
            ["nType"] = 2,
            ["price"] = 500,
            ["title"] = "抢分保险",
            ["desc"] = "保分阶段得分加10%"
        },
        {
            ["nType"] = 3,
            ["price"] = 500,
            ["title"] = "连胜符",
            ["desc"] = "失败连胜记录不清零"
        },
        {
            ["nType"] = 4,
            ["price"] = 500,
            ["title"] = "记牌器",
            ["desc"] = "统计其他玩家未出的牌"
            --["disable"] = true
        }
    },
}

return ArenaPropConfig
